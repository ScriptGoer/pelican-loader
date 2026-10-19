# FF3 V26.5: separate auto-execute chat uploader

This companion runs alongside the usual Auto QB loader. It does not launch Auto QB or Yuna, replay GUI clicks, record a second history, or own a second HTTP worker. Auto QB V26.5 exposes a shared manual upload API; the companion supplies private connection configuration and listens for the local player's exact message **`a`**.

## Use

Put the provided private `FF3_CHAT_UPLOAD_AUTOEXEC.lua` file in the executor's auto-execute folder alongside the existing Auto QB loader. Either can load first. The private file contains the credential and embeds the companion source, so it makes no extra GitHub fetch and requires no separate startup launcher. Keep the usual QB loader entry point:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

Type lowercase `a`, with no spaces or extra text, in normal Roblox chat. The message remains an ordinary Roblox chat message; the script does not hide, rewrite, forward or send chat. It ignores other players, uppercase `A`, `aa`, surrounding spaces and commands such as `/e a`. Legacy `LocalPlayer.Chatted` and modern `TextChatService.SendingMessage` are supported; modern messages require the local player's TextSource UserId. Duplicate delivery is debounced for two seconds.

An accepted command schedules a session upload and produces a brief local notification. **Session upload verified** is announced only after the bin returns the uploaded snapshot and a subsequent GET confirms it. HTTP/API rejection, an unsupported executor, missing history or a busy worker reports a local status instead. No permanent button or HUD is added. The companion never sends notification text to Roblox chat.

The companion sets `ManualOnly=true` and `CurrentSessionOnly=true`. It disables future periodic cloud sync for that controller; typing `a` is the upload trigger. Local history recording and disk checkpoints remain automatic. A request already in flight before companion attachment may finish before the new configuration can be installed. Commands sent before Auto QB is ready report a wait; they do not queue an unexpected later upload.

## What gets uploaded

Only retained records tagged with the current game-session identity are included. That identity survives Auto QB reloads in the same executor environment, so reloading the QB does not erase the session grouping. A fresh executor environment or changed server creates a new identity. The server JobId is compared in memory only and is not uploaded. Player labels remain anonymous and per QB run.

The existing **100-event / 80,000-byte** bound remains. This is a snapshot of the retained current-session evidence, not an unlimited recording of every event since joining. Payload `Scope=CURRENT_SESSION`, `RetainedOnly=true` and `TotalsScope=RETAINED_SESSION_RECORDS` make the limit explicit; counters are recomputed from included records rather than copied from lifetime totals. Older records written before V26.5 have no session tag and cannot be retroactively assigned to the current session.

Each successful upload replaces the dedicated bin's latest snapshot. Unchanged data can be verified by GET without a PUT. A deliberate full-history-to-session switch is allowed for the same writer; foreign schema, another writer, unknown scope, a newer remote revision and conflicting equal-revision snapshots remain protected. The generic full-history export and DATA button still work independently.

The snapshot is captured by the deferred worker before its first network request. Events occurring afterward remain local until the next command. The companion uses the recorder's sole owned worker, private-bin checks, GET → PUT → GET confirmation, API credential selection, quota handling and timeout/cancellation behavior. A second command cannot compete with an active upload. There are no automatic retries. A fresh command may retry a failed non-mutating GET; ambiguous PUT or uncertain cancelled IO remains blocked to avoid overwriting an unknown result.

Stopping or replacing the companion disconnects its listeners and cancels only its own pending upload through the recorder. Failed cancellation prevents confirmed replacement. Auto QB shutdown cancels its owned worker; the companion can bind to the next controller. To upload after an Auto QB error-stop, reload the QB first; retained tagged records from earlier runs in the same session remain eligible. Without a running compatible Auto QB, the companion waits instead of creating an independent recorder/client. Missing LocalPlayer is handled by a bounded thirty-second startup wait.

## Generic configuration

The public companion contains no credentials or personal bin IDs. For a custom local setup, configure the private credential before loading it:

```lua
getgenv().PELICAN_FF3_CHAT_UPLOAD_CONFIG = {
    BinId = "YOUR_BIN_ID",
    AccessKey = "YOUR_PRIVATE_ACCESS_KEY",
    Initialize = true,
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-v26.5/diagnostics/ff3_chat_upload.lua"))()
```

Use `MasterKey` instead of `AccessKey` only if deliberately configuring a Master Key; never set both. The personalized auto-execute artifact already contains the chosen configuration and companion code. Its contents must not be committed to either repository. New dedicated bins must be private and empty or contain the exact `PELICAN_FF3_HISTORY_EMPTY_V1` initialization marker described in [history setup](FF3_HISTORY.md). No credentials or chat contents are included in session data, logs or reports.

The regular QB report adds manual/automatic upload mode and last upload result. The companion exposes `GetReport()` and saves its final safe status to `getgenv().PELICAN_FF3_CHAT_UPLOAD_LAST_REPORT`. Catch outcomes remain unknown without game evidence; no aiming rule self-tunes from uploads.

## Validation

87 new mocked checks cover both startup orders, delayed LocalPlayer availability and timeout, exact/case/whitespace matching, local modern/legacy identity and duplicate suppression, no chat-trigger blocking HTTP, no periodic uploads, current-session-only records/counts, reload grouping, fresh-session/server isolation without JobId disclosure, unchanged-snapshot readback, replacement cleanup, busy workers, cancellation failure, no ambiguous retries, explicit safe GET retry, same-writer scope changes, completed receipts, teleport and unrelated places. The tests send no real Roblox chats or game requests.

All twenty current suites pass: **1,074 mocked assertions**. The source, standalone private artifact and rebuilt bundle compile under Lua 5.4. Actual iPhone chat events, notifications, HTTP timing and end-to-end executor upload remain unverified. Prior JSONBin privacy/authentication/marker readback was verified separately; this change does not fabricate a successful phone upload or gameplay outcome. Other game routes, aiming rules and throw packets remain unchanged.
