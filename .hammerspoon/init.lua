require("hs.ipc")

-- Install/update the `hs` IPC client in the existing Homebrew prefix.
hs.ipc.cliInstall("/opt/homebrew", true)

piNotify = require("pi-notify")
