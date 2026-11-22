local DEBUG_APK = 'app/build/outputs/apk/debug/app-debug.apk'
local APP_ID = '$(apkanalyzer manifest application-id ' .. DEBUG_APK .. ')'

local function map(lhs, shell_command, desc)
  vim.keymap.set('n', lhs, '<cmd>botright split | terminal ' .. shell_command .. '<cr>', { buffer = true, desc = desc })
end

map(
  '<leader>Ar',
  './gradlew installDebug && adb shell monkey -p ' .. APP_ID .. ' -c android.intent.category.LAUNCHER 1',
  'Android build & run'
)
map('<leader>At', './gradlew testDebugUnitTest', 'Android unit tests')
map('<leader>Al', 'adb logcat -v color --pid=$(adb shell pidof -s ' .. APP_ID .. ')', 'Android logcat (app)')
