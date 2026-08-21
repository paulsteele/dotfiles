local M = {}
local PREFIX = "pi-desktop-notify:"
local RETIRE_INTERVAL_SECONDS = 0.1
local RETIRE_MAX_ATTEMPTS = 100

-- A slot is the independently managed notification stream for one terminal
-- window. A record remains retained until its exact delivered notification has
-- disappeared (or targeted retirement times out).
local slots = {}
local recordsByTag = {}
local notificationSequence = 0

-- Keep AX window objects captured while their Space is visible. hs.window.get(id)
-- cannot rediscover a window after the user switches to another macOS Space,
-- but the captured object remains usable for focusing it again.
local windowRefs = {}

local function result(ok, fields)
  local value = fields or {}
  value.ok = ok
  return hs.json.encode(value)
end

local function decode(value)
  if type(value) ~= "string" then return nil end
  local ok, decoded = pcall(hs.base64.decode, value)
  if not ok then return nil end
  return decoded
end

local function validKey(key)
  return type(key) == "string" and key:match("^pi%-mac%-%d+$") ~= nil
end

local function validWindowId(windowId)
  return type(windowId) == "number" and windowId > 0 and windowId == math.floor(windowId)
end

local function focusedWindowId()
  local window = hs.window.focusedWindow()
  return window and window:id() or nil
end

local function nextTag(key, generation)
  notificationSequence = notificationSequence + 1
  return string.format("%s%s:%d:%d", PREFIX, key, generation, notificationSequence)
end

local function deliveredWithTag(tag)
  local matches = {}
  for _, note in ipairs(hs.notify.deliveredNotifications()) do
    local ok, candidateTag = pcall(function() return note:getFunctionTag() end)
    if ok and candidateTag == tag then matches[#matches + 1] = note end
  end
  return matches
end

local function stopTimer(timer)
  if timer then pcall(function() timer:stop() end) end
end

local createRecord
local finishRecord

local function startPendingIfCurrent(slot)
  local pending = slot.pending
  if not pending or pending.generation ~= slot.generation or slot.current then return end
  slot.pending = nil
  local ok, errorMessage = createRecord(slot, pending)
  if not ok then
    hs.printf("[pi-notify] failed to send %s: %s", slot.key, tostring(errorMessage))
    if slots[slot.key] == slot and not slot.current and not slot.pending then slots[slot.key] = nil end
  end
end

finishRecord = function(record, removed, reason)
  if record.finished then return end
  record.finished = true
  stopTimer(record.retireTimer)
  stopTimer(record.activationTimer)
  record.retireTimer = nil
  record.activationTimer = nil
  recordsByTag[record.tag] = nil
  hs.notify.unregister(record.tag)

  local slot = slots[record.key]
  if slot and slot.current == record then slot.current = nil end

  if not removed then
    hs.printf(
      "[pi-notify] targeted retirement timed out for %s (%s); no other notifications were cleared",
      record.key,
      tostring(reason or "unknown")
    )
  end

  if slot and slots[record.key] == slot then
    -- A failed targeted retirement must not erase another generation's queued
    -- notification. Starting it may briefly leave both same-key notices visible,
    -- but preserving current intent is safer than losing it or clearing globally.
    startPendingIfCurrent(slot)
    if not slot.current and not slot.pending then slots[record.key] = nil end
  end
end

local function pollRetirement(record)
  if record.finished then return end
  record.retireAttempts = record.retireAttempts + 1

  local matches = deliveredWithTag(record.tag)
  if #matches > 0 then
    record.seenDelivered = true
    local allSucceeded = true
    for _, deliveredNote in ipairs(matches) do
      -- Withdraw the object returned by deliveredNotifications(). Withdrawing
      -- the originally-created object first can unlock Hammerspoon's shared
      -- record while leaving its Notification Center proxy behind.
      local ok = pcall(function() deliveredNote:withdraw() end)
      allSucceeded = allSucceeded and ok
    end
    if allSucceeded then record.withdrawRequested = true end
  elseif record.seenDelivered or record.withdrawRequested or record.state == "activated" then
    finishRecord(record, true, "removed")
    return
  end

  if record.retireAttempts >= RETIRE_MAX_ATTEMPTS then
    finishRecord(record, false, "notification never became individually withdrawable")
  end
end

local function beginRetirement(record, reason)
  if record.finished then return end
  if record.state ~= "retiring" then
    record.state = "retiring"
    record.retireReason = reason
    record.retireAttempts = 0
    record.retireTimer = hs.timer.doEvery(RETIRE_INTERVAL_SECONDS, function()
      pollRetirement(record)
    end)
  end
  pollRetirement(record)
end

local function focusStoredWindow(windowId)
  local target = windowRefs[windowId] or hs.window.get(windowId)
  if not target then return false end
  windowRefs[windowId] = target
  local ok = pcall(function()
    target:focus()
    target:raise()
  end)
  return ok
end

local function onActivated(record)
  if record.finished then return end
  focusStoredWindow(record.windowId)

  -- The native hs.notify delegate applies autoWithdraw after this callback
  -- returns. Do not withdraw here and never clear another notification.
  record.state = "activated"
  record.seenDelivered = true
  stopTimer(record.retireTimer)
  record.retireTimer = nil
  record.activationTimer = hs.timer.doAfter(0, function()
    finishRecord(record, true, "activated")
  end)
end

createRecord = function(slot, pending)
  if slots[slot.key] ~= slot or pending.generation ~= slot.generation then
    return false, "stale generation"
  end

  local tag = nextTag(slot.key, pending.generation)
  local record = {
    key = slot.key,
    tag = tag,
    windowId = pending.windowId,
    generation = pending.generation,
    state = "sending",
    retireAttempts = 0,
    seenDelivered = false,
    withdrawRequested = false,
    finished = false,
  }

  hs.notify.register(tag, function(_note) onActivated(record) end)
  local note = hs.notify.new(tag, {
    title = pending.title,
    subTitle = pending.subtitle,
    informativeText = pending.body,
    soundName = hs.notify.defaultNotificationSound,
    autoWithdraw = true,
    withdrawAfter = 0,
  })
  record.note = note
  slot.current = record
  recordsByTag[tag] = record

  local ok, sendError = pcall(function() note:send() end)
  if not ok then
    finishRecord(record, true, "send failed")
    return false, sendError
  end
  record.state = "sent"
  return true
end

local function requestClear(key, reason)
  local slot = slots[key]
  if not slot then return false end
  slot.generation = slot.generation + 1
  slot.pending = nil
  if slot.current then
    beginRetirement(slot.current, reason)
  else
    slots[key] = nil
  end
  return true
end

function M.resolve(markerBase64)
  local marker = decode(markerBase64)
  if not marker or marker == "" then return result(false, { error = "invalid_marker" }) end
  local window = hs.window.get(marker)
  if not window then return result(false, { error = "window_not_found" }) end
  local app = window:application()
  if not app or app:bundleID() ~= "org.alacritty" then
    return result(false, { error = "window_not_alacritty" })
  end
  local windowId = window:id()
  if not validWindowId(windowId) then return result(false, { error = "invalid_window_id" }) end
  windowRefs[windowId] = window
  return result(true, { windowId = windowId, focused = focusedWindowId() == windowId })
end

function M.preflight()
  local accessibility = hs.accessibilityState()
  return result(accessibility, {
    accessibility = accessibility,
    notifications = true,
    version = hs.processInfo.version,
  })
end

function M.isFocused(windowId)
  windowId = tonumber(windowId)
  if not validWindowId(windowId) then return result(false, { error = "invalid_window_id" }) end
  return result(true, { focused = focusedWindowId() == windowId })
end

function M.focus(windowId)
  windowId = tonumber(windowId)
  if not validWindowId(windowId) then return result(false, { error = "invalid_window_id" }) end

  local spaces, spacesError = hs.spaces.windowSpaces(windowId)
  if not spaces or #spaces == 0 then
    return result(false, { error = "window_space_not_found", detail = tostring(spacesError) })
  end

  local targetSpace = spaces[1]
  local alreadyActive = false
  for _, activeSpace in pairs(hs.spaces.activeSpaces()) do
    if activeSpace == targetSpace then
      alreadyActive = true
      break
    end
  end

  if alreadyActive then
    local focused = focusStoredWindow(windowId)
    return result(focused, {
      focused = focused,
      spaceChanged = false,
      spaceId = targetSpace,
      error = focused and nil or "window_not_found",
    })
  end

  local switched, switchError = hs.spaces.gotoSpace(targetSpace)
  if not switched then
    return result(false, { error = "space_switch_failed", detail = tostring(switchError) })
  end

  hs.timer.doAfter((hs.spaces.MCwaitTime or 0.3) + 0.2, function()
    focusStoredWindow(windowId)
  end)
  return result(true, { focused = true, spaceChanged = true, spaceId = targetSpace })
end

function M.send(keyBase64, windowId, titleBase64, subtitleBase64, bodyBase64)
  local key = decode(keyBase64)
  local title = decode(titleBase64)
  local subtitle = decode(subtitleBase64)
  local body = decode(bodyBase64)
  windowId = tonumber(windowId)

  if not validKey(key) or not validWindowId(windowId) or not title or not subtitle or not body then
    return result(false, { error = "invalid_arguments" })
  end
  if focusedWindowId() == windowId then
    requestClear(key, "focused")
    return result(true, { sent = false, reason = "focused" })
  end

  local window = windowRefs[windowId] or hs.window.get(windowId)
  if not window then return result(false, { error = "window_not_found" }) end
  windowRefs[windowId] = window

  local slot = slots[key]
  if not slot then
    slot = { key = key, generation = 0, windowId = windowId }
    slots[key] = slot
  end
  slot.windowId = windowId
  slot.generation = slot.generation + 1
  slot.pending = {
    generation = slot.generation,
    windowId = windowId,
    title = title,
    subtitle = subtitle,
    body = body,
  }

  if slot.current then
    beginRetirement(slot.current, "replaced")
    return result(true, { sent = false, queued = true, windowId = windowId })
  end

  local pending = slot.pending
  slot.pending = nil
  local ok, errorMessage = createRecord(slot, pending)
  if not ok then return result(false, { error = tostring(errorMessage) }) end
  return result(true, { sent = true, windowId = windowId, tag = slot.current.tag })
end

function M.clear(keyBase64)
  local key = decode(keyBase64)
  if not validKey(key) then return result(false, { error = "invalid_key" }) end
  local found = requestClear(key, "explicit clear")
  return result(true, { cleared = true, found = found, targeted = true })
end

-- Intentionally do nothing at module load. Notifications delivered by a prior
-- Hammerspoon configuration cannot be safely reconstructed for exact removal;
-- preserving them for manual dismissal is safer than clearing another window.
return M
