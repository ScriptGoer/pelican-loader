"""Exercise repaired and original full controllers; no live gameplay claim."""
from pathlib import Path
import subprocess,sys,json,tempfile
ROOT=Path(__file__).resolve().parents[2]
for name in ['repair_runtime.lua','comparative_model.lua','presentation_oscillation.lua','replication_readiness.lua','jump_coverage.lua','trajectory_ranking.lua','jump_policy.lua','movement_guide.lua','throw_policy_repair.lua','admission_certificates.lua','release_pipeline.lua','native_schedule.lua','bullet_coverage.lua','contested_comparison.lua','guide_readiness.lua']:
 subprocess.run([sys.executable,str(ROOT/'tests/experimental/run_lua.py'),str(ROOT/'tests/experimental'/name)],cwd=ROOT,check=True)
subprocess.run([sys.executable,str(ROOT/'scripts/replay_bad_play.py'),'/tmp/pelican-b3-runtime-report.json'],cwd=ROOT,check=True)
subprocess.run([sys.executable,str(ROOT/'scripts/replay_bad_play.py'),'/tmp/pelican-zigzag-runtime-report.json'],cwd=ROOT,check=True)

# An altered analytic-risk receipt must fail even if its ranking tier is unchanged.
report=json.loads(Path('/tmp/pelican-b3-runtime-report.json').read_text())
for frame in report['Possession']['Frames']:
 for row in frame['Rows'].values():
  if row.get('Status')=='EVALUATED':
   row['Input']['Context']['Guard']['Margin']+=1
   with tempfile.NamedTemporaryFile(mode='w',suffix='.json') as f:
    json.dump(report,f);f.flush()
    r=subprocess.run([sys.executable,str(ROOT/'scripts/replay_bad_play.py'),f.name],capture_output=True,text=True)
   assert r.returncode!=0 and 'GUARD_margin' in r.stdout,r.stdout+r.stderr
   print('PASS corrupted analytic-risk evidence produces nonzero replay status')
   raise SystemExit(0)
raise AssertionError('No evaluated fixture row available for corruption test')
