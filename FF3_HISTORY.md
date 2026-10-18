# FF3 V26.4: retained history and optional private JSONBin sync

The old report overwrote `PELICAN_FF3_AUTO_QB_REPORT.txt` and retained only six throw decisions. V26.4 adds a bounded structured history alongside that report. It records run boundaries, actual automatic/manual AWAY request outcomes, native power and trajectory, receiver/defender observations, selected-mode comparisons, sampled blocked decisions, possession ending and error-stop reasons. It does not change the V26.3 aiming or safety rules.

## Device history

Recording starts automatically with FF3 live Auto QB. Two alternating files, `PELICAN_FF3_HISTORY_A.json` and `PELICAN_FF3_HISTORY_B.json`, retain the newest valid checkpoint across reexecution and fresh sessions where the executor preserves its filesystem. Writes are checked by reading the saved bytes. A torn bank can recover from the other valid bank. Unknown schemas, two invalid banks, permission failures and uncertain writes preserve the existing files and leave history in memory. A write-only executor does not overwrite history it cannot inspect.

The history retains at most 100 events; JSON snapshots/exports are trimmed to 80,000 bytes, whichever limit is reached first. Fixed lifetime counters for runs, requests, accepted APIs, ambiguous APIs, blocked samples, errors and evictions survive individual-event eviction. These are not completion/interception statistics. Blocked records are sampled per mode/reason at most once every ten seconds; counts describe recorded samples, not every planning tick.

Normal checkpoints run at most once per ten seconds after release work. With cancellable deferred tasks they execute in an owned worker. Executors without those APIs save at the existing report-preservation boundaries instead. Stop, teleport shutdown and COPY flush locally when safe. Forced app termination can lose events since the last completed checkpoint. Existing file APIs are not evidence of durable iOS storage across reinstalls or executor filesystem resets.

Tap the status pill, then **DATA**, to copy the rolling JSON history. **COPY** still copies the usual readable report. DATA's clipboard result is API acceptance, not iOS readback. The report adds `HISTORY_STORAGE`, `HISTORY_RECORDS`, `HISTORY_REVISION`, `HISTORY_SAVED_REVISION`, `HISTORY_JSONBIN` and `HISTORY_SYNCED_REVISION`. `READBACK_VERIFIED` refers to the particular file or remote snapshot, not a catch.

Player labels are anonymous and local to each run. History includes actor positions/velocities, but no usernames, UserIds, server JobId, chat contents, credentials, paid source or full report text. The ordinary manually copied report is unchanged and may still include player names. Up to twelve defenders are included in each throw snapshot, with the full defender count recorded; this truncation does not change the planner's defender checks. The actor label map caps at 64 per run.

## Private JSONBin setup

Cloud sync is optional and off without configuration. The bin ID alone cannot authenticate a private bin. Create a JSONBin **Access Key** with Read and Update permission; keep the master key out of this workflow. Enter the access key only in a private local executor script. It is held in memory, supplied in the HTTP header and excluded from reports/files/history. Do not commit or send that script/key.

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

`Initialize=true` only authorizes the empty/marker case; it never authorizes overwriting unrelated data. After the first successful sync it can be removed. No real account/bin credentials or IDs are embedded in the public loader. Local configuration must be supplied again if the executor clears its environment.

Sync needs HttpService JSON support, `task.defer`, `task.cancel`, and an executor HTTP request function (`request`, `http_request`, `syn.request`, or `http.request`). Missing capability is reported and does not cause a blocking network fallback. The adapter only addresses `https://api.jsonbin.io/v3/b/<24-hex-id>`, uses `X-Access-Key`, and verifies `metadata.private=true`.

The first sync can start after ten seconds; later changed snapshots sync at most once per 120 seconds by default (configurable 60–3600). A changed snapshot uses **GET latest → PUT → GET latest** with structural echo/readback checks. Unchanged snapshots consume no periodic requests. PUT disables bin versioning; the rolling history is not an unlimited cloud archive. Account request limits still apply: a successful changed-snapshot sync usually uses three requests. No live requests have been made for this implementation.

A failed/ambiguous sync does not retry automatically in that controller. An outstanding network task times out after twenty seconds and is cancelled where the executor permits; uncertain native IO blocks subsequent automatic sync in the same executor environment, including X reloads. Stop cancels owned workers and saves locally; it does not start a final blocking cloud upload. If worker cancellation fails, cleanup cannot be confirmed. Network/storage failures leave the QB decision logic working and report the recorder failure; they do not authorize another football request.

JSONBin does not provide a compare-and-swap contract here. The preflight checks reduce accidental overwrites but cannot guarantee concurrent multi-device merges. A device with missing local history does not automatically replace another writer or import an ahead remote snapshot. Preserve/export those records and reconcile them deliberately. This implementation stores rolling snapshots and counters, not a database of every throw forever.

## How the data helps development

The history never changes aiming rules automatically. Every request remains `Catch="UNKNOWN"`; API acceptance and possession loss are insufficient evidence of a catch, incompletion or interception. There is no verified game-outcome attribution/calibration in this release. Useful next evidence is a DATA export plus a note identifying the failed throw and what visibly happened. Native requested/actual power, flight, coverage and blocked receipts can then support a specific code change.

An assistant does not automatically gain access to a private bin by knowing its ID, and cannot read files on the iPhone. Share the DATA export for analysis. Any future authenticated remote retrieval requires a separate secure read-access arrangement; do not paste an API key into chat. The public loader does not make a private bin publicly readable.

## Validation

123 new controller checks cover persistence across fresh mocked executor environments, alternating-bank corruption recovery, future-schema preservation, storage failures, bounded retention, anonymous exports, block sampling, private preflight/readback, initialization markers, other-writer/ahead/conflicting bins, 429/network/ambiguous PUT failures without retries, hung worker cancellation/timeout, explicit cancellation failure, missing capabilities, error-stop evidence, and exact packet/target/mode/release-tick parity with archived V26.3 at three distances. JSON codec, executor IO and HTTP are mocks, not real cloud or filesystem durability evidence.

Together with the existing current suites, **972 mocked assertions pass**. The generated bundle and runtime load under Lua 5.4. No Roblox session, phone, actual JSONBin account, live chat or football request was tested. iPhone IO latency, current executor HTTP support, actual JSONBin key permissions/quota, persistence and live catchability remain unverified. This is substantial progress in retained diagnostic evidence; it is not proof of improved passing outcomes.

The loader pins `ff3-v26.4`, preserving the V26 controller contract. The exact prior controller is archived privately in `archive/ff3-v26.3`; immutable public `ff3-v26.3` remains available. Other game routes are unchanged.

Protocol references: [JSONBin Read API](https://jsonbin.io/api-reference/bins/read/) and [Update API](https://jsonbin.io/api-reference/bins/update/).
