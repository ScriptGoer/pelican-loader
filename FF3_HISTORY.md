# FF3 V26.4: retained history and optional private JSONBin sync

V26.17 fixes route-dependent MOD/TRUST/Fit eligibility, regrades other eligible receivers’ fresh cached paths and favors shorter ready completions. Strict Bullet limits, final native validation and the 75-ms takeoff target remain. [Current selection policy](FF3_OPPORTUNITIES.md).

The old report overwrote `PELICAN_FF3_AUTO_QB_REPORT.txt` and retained only six throw decisions. V26.4 adds a bounded structured history alongside that report. It records run boundaries, actual automatic/manual AWAY request outcomes, native power and trajectory, receiver/defender observations, selected-mode comparisons, sampled blocked decisions, possession ending and error-stop reasons. It does not change the V26.3 aiming or safety rules.

## Device history

Recording starts automatically with FF3 live Auto QB. Two alternating files, `PELICAN_FF3_HISTORY_A.json` and `PELICAN_FF3_HISTORY_B.json`, retain the newest valid checkpoint across reexecution and fresh sessions where the executor preserves its filesystem. Writes are checked by reading the saved bytes. A torn bank can recover from the other valid bank. Unknown schemas, two invalid banks, permission failures and uncertain writes preserve the existing files and leave history in memory. A write-only executor does not overwrite history it cannot inspect.

The history retains at most 100 events; JSON snapshots/exports are trimmed to 80,000 bytes, whichever limit is reached first. Fixed lifetime counters for runs, requests, accepted APIs, ambiguous APIs, blocked samples, errors and evictions survive individual-event eviction. These are not completion/interception statistics. Blocked records are sampled per mode/reason at most once every ten seconds; counts describe recorded samples, not every planning tick.

Normal checkpoints run at most once per ten seconds after release work. With cancellable deferred tasks they execute in an owned worker. Executors without those APIs save at the existing report-preservation boundaries instead. Stop, teleport shutdown and COPY flush locally when safe. Forced app termination can lose events since the last completed checkpoint. Existing file APIs are not evidence of durable iOS storage across reinstalls or executor filesystem resets.

Tap the status pill, then **DATA**, to copy the rolling JSON history. **COPY** still copies the usual readable report. DATA's clipboard result is API acceptance, not iOS readback. The report adds `HISTORY_STORAGE`, `HISTORY_RECORDS`, `HISTORY_REVISION`, `HISTORY_SAVED_REVISION`, `HISTORY_JSONBIN` and `HISTORY_SYNCED_REVISION`. `READBACK_VERIFIED` refers to the particular file or remote snapshot, not a catch.

Player labels are anonymous and local to each run. History includes actor positions/velocities, but no usernames, UserIds, server JobId, chat contents, credentials, paid source or full report text. The ordinary manually copied report is unchanged and may still include player names. Up to twelve defenders are included in each throw snapshot, with the full defender count recorded; this truncation does not change the planner's defender checks. The actor label map caps at 64 per run.

## Private JSONBin setup

Cloud sync is optional and off without configuration. The bin ID alone cannot authenticate a private bin. A JSONBin **Access Key** with Read and Update permission is recommended. V26.4.1 also accepts an explicitly configured `MasterKey` for users who choose to use their account key; configure exactly one credential field, never both. Enter the chosen credential only in a private local executor script. It is held in memory, supplied in the HTTP header and excluded from reports/files/history. Do not commit or send that script/key.

Use one dedicated bin and one device writer. If the bin is new, initialize its contents in JSONBin to this explicit marker:

```json
{"Schema":"PELICAN_FF3_HISTORY_EMPTY_V1"}
```

Do not replace existing bin contents unless you intend to dedicate it to this history. The recorder accepts that exact marker or an empty object only with `Initialize=true`. It refuses arbitrary sample data, an unknown schema, another writer, a newer remote revision or a conflicting equal revision.

Run this local configuration before the usual loader; replace only the placeholders on your device:

```lua
getgenv().PELICAN_FF3_JSONBIN = {
    BinId = "YOUR_BIN_ID",
    AccessKey = "ENTER_YOUR_ACCESS_KEY_ONLY_ON_YOUR_DEVICE",
    Initialize = true,
    IntervalSeconds = 120,
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

`Initialize=true` only authorizes the empty/marker case; it never authorizes overwriting unrelated data. After the first successful sync it can be removed. If you deliberately use a Master Key, replace the `AccessKey` field with `MasterKey`; do not set both. No real account/bin credentials or IDs are embedded in the public loader. Local configuration must be supplied again if the executor clears its environment.

Sync needs HttpService JSON support, `task.defer`, `task.cancel`, and an executor HTTP request function (`request`, `http_request`, `syn.request`, or `http.request`). Missing capability is reported and does not cause a blocking network fallback. The adapter only addresses `https://api.jsonbin.io/v3/b/<24-hex-id>`, uses `X-Access-Key` or the explicitly selected `X-Master-Key`, identifies itself with `User-Agent: PelicanFF3History/26.10`, and verifies `metadata.private=true`. It does not probe alternate credential headers automatically.

The first sync can start after ten seconds; later changed snapshots sync at most once per 120 seconds by default (configurable 60–3600). A changed snapshot uses **GET latest → PUT → GET latest** with structural echo/readback checks. Unchanged snapshots consume no periodic requests. PUT disables bin versioning; the rolling history is not an unlimited cloud archive. Account request limits still apply: a successful changed-snapshot sync usually uses three requests. Authenticated privacy/update requests and initialization readback were verified during V26.4.1 setup; the phone executor sync path remains unverified.

A failed/ambiguous sync does not retry automatically in that controller. An outstanding network task times out after twenty seconds and is cancelled where the executor permits; uncertain native IO blocks subsequent automatic sync in the same executor environment, including X reloads. Stop cancels owned workers and saves locally; it does not start a final blocking cloud upload. If worker cancellation fails, cleanup cannot be confirmed. Network/storage failures leave the QB decision logic working and report the recorder failure; they do not authorize another football request.

JSONBin does not provide a compare-and-swap contract here. The preflight checks reduce accidental overwrites but cannot guarantee concurrent multi-device merges. A device with missing local history does not automatically replace another writer or import an ahead remote snapshot. Preserve/export those records and reconcile them deliberately. This implementation stores rolling snapshots and counters, not a database of every throw forever.

## How the data helps development

The history never changes aiming rules automatically. Every request remains `Catch="UNKNOWN"`; API acceptance and possession loss are insufficient evidence of a catch, incompletion or interception. There is no verified game-outcome attribution/calibration in this release. Useful next evidence is a DATA export plus a note identifying the failed throw and what visibly happened. Native requested/actual power, flight, coverage and blocked receipts can then support a specific code change.

An assistant does not automatically gain access to a private bin by knowing its ID, and cannot read files on the iPhone. Share the DATA export for analysis. Any future authenticated remote retrieval requires a separate secure read-access arrangement; do not paste an API key into chat. The public loader does not make a private bin publicly readable.

## Validation

138 controller checks cover persistence across fresh mocked executor environments, alternating-bank corruption recovery, future-schema preservation, storage failures, bounded retention, anonymous exports, block sampling, private preflight/readback, initialization markers, other-writer/ahead/conflicting bins, 429/network/ambiguous PUT failures without retries, hung worker cancellation/timeout, explicit cancellation failure, missing capabilities, error-stop evidence, and exact packet/target/mode/release-tick parity with archived V26.3 at three distances. JSON codec, executor IO and HTTP are mocks, not real cloud or filesystem durability evidence.

Together with the existing current suites, **987 mocked assertions pass**. The generated bundle and runtime load under Lua 5.4. No Roblox session, phone, live chat or football request was tested. Actual JSONBin privacy/initialization readback was checked separately; mocked executor sync checks are not a phone runtime test. iPhone IO latency, current executor HTTP support, phone-side key use/quota, persistence and live catchability remain unverified. This is substantial progress in retained diagnostic evidence; it is not proof of improved passing outcomes.

The loader pins `ff3-v26.15, preserving the V26 controller contract. The exact prior controller is archived privately in `archive/ff3-v26.3`; immutable public `ff3-v26.3` remains available. Other game routes are unchanged.

Protocol references: [JSONBin Read API](https://jsonbin.io/api-reference/bins/read/) and [Update API](https://jsonbin.io/api-reference/bins/update/).

V26.4.1 adds fifteen authentication checks for explicit MasterKey selection, exclusive headers, application identification, secret exclusion and invalid/ambiguous configuration. Passing decisions and packet timing remain unchanged.

V26.5 adds the optional [chat-triggered current-session uploader](FF3_CHAT_UPLOAD.md). Its manual configuration replaces periodic uploads, while ordinary device history remains automatic. Current validation totals 1,074 mocked assertions; phone-side chat/upload remains unverified.

V26.6 attaches passive [receiver movement and ball evidence](FF3_RECEIVER_EVIDENCE.md) to the original throw IDs. Partial snapshots are supported and no extra request attempts are counted. V26.6 validation totaled 1,143 mocked assertions; actual game catch/dive pose calibration and causal attribution remain unverified.

V26.7 adds `CurrentSettings`, tagged with session/run and observation time, for exact last-verified lead values, active comfort policy and bounded anonymous native power-control status. This captures qualified settings even before a throw. A current-session snapshot excludes prior-session settings; per-throw settings retain their historical values. It does not recover observations that were never recorded. [Comfort and evidence update](FF3_BULLET_COMFORT.md).

V26.9 saves PassPlan, 20-yard DeepYards and WideOpenJump in current settings; throw records add the active plan, catch depth beyond LOS, observed deep-comeback flag and wide-open/Jump-preference result. These are policy/model observations, not game catch awards. [Plan behavior](FF3_PASS_PLANS.md).

V26.10 retains ReceiverFilter (ANY or FRIENDS) in current settings and per-throw metadata. The friendship cache, platform user IDs and friend list are not exported. [Friend-filter behavior](FF3_FRIENDS.md).

V26.11 adds coverage-based friend route calls. The last attempted instruction appears in the controller report; friendship caches and friend identities remain outside retained history. [Call policy](FF3_ROUTE_CALLS.md).

V26.12 retains MagTrial Enabled/ExtraY/calibration policy in current settings, and per-throw MagTrial, MagExtraY, anonymous MagTrustSource, MagBaseLead and explicit unverified catch calibration. Base LeadSettings remain unchanged; Lead records the actual scoped value and LeadControls.YOffset identifies MagTrial.ExtraY. Manual-trust/friend identities are not exported. [Trial and trust behavior](FF3_TRUSTED_MAG.md).

V26.13 retains AdaptiveAngle in current settings, and ActualAngleDegrees, AngleRequest, NativeAngleAdjustment, AdaptiveAngle and EndzoneTarget in throw records. AngleRequest stores the requested angle, estimated flight, native power cap, projected blocker count and policy reason; the actual native trajectory remains authoritative. [Adaptive angles and goal changes](FF3_ADAPTIVE_ANGLE.md).

V26.14 retains OpenComfort in settings and throws, plus JumpBulletReason / JumpBulletChest when a custom trial qualifies. The counterfactual stores native normal-Bullet time and modeled endpoint/lane clearance; it does not establish an actual catch outcome. Reports identify guide render/status/draw count. The existing upload companion is unchanged. [Policy and evidence limits](FF3_OPEN_COMFORT.md).

V26.15 retains actual profile/source, explicit screen flag, native covered-Jump identity, geometric coverage layer counts and Fit counterfactual reason/modes. The legacy JumpBulletReason/JumpBulletChest container also describes native Jump's chest comparison; actual Mode/NativeMode identify Jump. These are model observations, not verified league assignments, catch awards or calibrated reach. The companion is unchanged. [Competitive policy and limits](FF3_LEAGUE.md).

V26.16 retains JumpDelaySeconds/CoverageWindows in current settings, with JumpDelayTarget, JumpObservedDelay and JumpTimingSource for automatic requests. The timestamp is a local takeoff observation, not a sub-frame impulse or server timestamp; slow frames and late safe windows can produce measured overshoot. Both profiles now record shared coverage evidence. [Timing and shared coverage](FF3_JUMP_TIMING.md).
