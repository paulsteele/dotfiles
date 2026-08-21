local M = {}
local PREFIX = "pi-desktop-notify:"
local notifications = {}
local windowIds = {}
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

local function tagMatches(tag, matchingTag)
  if not matchingTag then return tag:sub(1, #PREFIX) == PREFIX end
  return tag == matchingTag or tag:sub(1, #matchingTag + 1) == matchingTag .. ":"
end

local function retryWithdraw(note, attempt)
  local ok = pcall(function() note:withdraw() end)
  if not ok and attempt < 50 then
    hs.timer.doAfter(0.1, function() retryWithdraw(note, attempt + 1) end)
  end
  return ok
end

local function withdrawDelivered(matchingTag)
  for _, note in ipairs(hs.notify.deliveredNotifications()) do
    local ok, tag = pcall(function() return note:getFunctionTag() end)
    if ok and type(tag) == "string" and tagMatches(tag, matchingTag) then
      retryWithdraw(note, 1)
    end
  end
end

local function retire(record, attempt)
  if not record then return end
  local ok = retryWithdraw(record.note, attempt)
  withdrawDelivered(record.tag)

  -- send() returns before macOS necessarily finishes dispatching. If clear is
  -- requested in that window, withdraw() raises and the notification used to
  -- appear later as an untracked orphan. Keep the exact original object until
  -- the retry loop above can withdraw it.
  if ok then hs.notify.unregister(record.tag) end
end

local function clearKey(key)
  local record = notifications[key]
  notifications[key] = nil
  windowIds[key] = nil
  if record then retire(record, 1) end
  withdrawDelivered(PREFIX .. key)

  -- hs.notify objects can become permanently "not yet dispatched" proxies on
  -- macOS even though their alerts are visible. The object-level withdraw then
  -- never succeeds. withdrawAll uses Notification Center's bulk-removal path
  -- and is reliable for both freshly delivered and restored notifications.
  -- This Hammerspoon config reserves native notifications for Pi.
  hs.notify.withdrawAll()
end

local function clearOrphans()
  -- Hammerspoon is dedicated to Pi notifications in this configuration, so
  -- bulk withdrawal is the only reliable way to remove orphaned native alerts
  -- left by a process/config reload.
  hs.notify.withdrawAll()
end

local function focusedWindowId()
  local window = hs.window.focusedWindow()
  return window and window:id() or nil
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

  local function focusWindow()
    local target = windowRefs[windowId] or hs.window.get(windowId)
    if target then
      windowRefs[windowId] = target
      target:focus()
      target:raise()
    end
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
    focusWindow()
    return result(true, { focused = true, spaceChanged = false, spaceId = targetSpace })
  end

  local switched, switchError = hs.spaces.gotoSpace(targetSpace)
  if not switched then
    return result(false, { error = "space_switch_failed", detail = tostring(switchError) })
  end

  -- gotoSpace initiates a Mission Control transition and returns before the
  -- destination's windows can accept focus. Focus only after that transition.
  hs.timer.doAfter((hs.spaces.MCwaitTime or 0.3) + 0.2, focusWindow)
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
    clearKey(key)
    return result(true, { sent = false, reason = "focused" })
  end
  local window = windowRefs[windowId] or hs.window.get(windowId)
  if not window then return result(false, { error = "window_not_found" }) end
  windowRefs[windowId] = window

  clearKey(key)
  windowIds[key] = windowId
  local tag
  local record
  local function onActivated(note)
    local targetId = windowIds[key] or windowId
    local target = windowRefs[targetId] or hs.window.get(targetId)

    -- The retained AX object can focus its window across Spaces directly. This
    -- was the original working path; do not put hs.spaces/Mission Control work
    -- ahead of it, because an error there prevents both focus and dismissal.
    if target then
      windowRefs[targetId] = target
      pcall(function()
        target:focus()
        target:raise()
      end)
    end

    notifications[key] = nil
    windowIds[key] = nil
    hs.notify.withdrawAll()
    hs.notify.unregister(tag)
  end

  -- Use a direct callback rather than the function-tag constructor. On
  -- Hammerspoon 1.1.1 the tagged constructor can return Notification Center
  -- proxy objects that claim to be delivered but still throw "not yet
  -- dispatched" forever when withdrawn. Direct-callback notifications remain
  -- withdrawable while retaining a custom tag for reload cleanup.
  local note = hs.notify.new(onActivated, {
    title = title,
    subTitle = subtitle,
    informativeText = body,
    soundName = hs.notify.defaultNotificationSound,
    autoWithdraw = true,
    withdrawAfter = 0,
  })
  tag = note:getFunctionTag()
  record = { note = note, tag = tag }
  notifications[key] = record
  note:send()
  return result(true, { sent = true, windowId = windowId })
end

function M.clear(keyBase64)
  local key = decode(keyBase64)
  if not validKey(key) then return result(false, { error = "invalid_key" }) end
  clearKey(key)
  return result(true, { cleared = true })
end

function M.clearAll()
  local keys = {}
  for key, _ in pairs(notifications) do keys[#keys + 1] = key end
  for _, key in ipairs(keys) do clearKey(key) end
  clearOrphans()
  return result(true, { cleared = true })
end

clearOrphans()
return M
