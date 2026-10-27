-- Synthetic movement/control tests. No live UI, chat or game-server actions.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local count=0
local function check(ok,label)count=count+1;assert(ok,label)end
local t=setup({ff3={Profile='CASUAL'}})
t.env.PELICAN_FF3_RISK_MODE='SAFE'
local hidden=Instance.new('Folder');hidden.Name='ExecutorOwned';hidden.Parent=Mock.services.CoreGui
gethui=function()return hidden end
local main=Instance.new('ScreenGui');main.Name='RandomWindow';main.Enabled=true;main.Parent=hidden
local opener=Instance.new('ScreenGui');opener.Name='RandomOpener';opener.Enabled=true;opener.Parent=hidden
local closed=Instance.new('ScreenGui');closed.Name='ClosedScript';closed.Enabled=false;closed.Parent=hidden
local pg=t.me:FindFirstChild('PlayerGui')
local gameHud=Instance.new('ScreenGui');gameHud.Name='GameHUD';gameHud.Enabled=true;gameHud.Parent=pg
local controls=Instance.new('ScreenGui');controls.Name='TouchGui';controls.Enabled=true;controls.Parent=pg
t.me.Chatted=t.signal()
local light={Brightness=3,ClockTime=14};Mock.services.Lighting=light
t.env.PELICAN_FF3_VISUAL_BASELINE={JobId=game.JobId,Source='USER_CAPTURED_BEFORE_VISUAL_MODS',Values={Brightness=1.25,ClockTime=20}}
local c=t.run();c.SetThrow(false);t.steps(10)
check(c.GetReport():find('\nRISK_MODE|TRUST\n',1,true),'TRUST startup ignores stale saved SAFE default')
check(c.SetRiskMode('SAFE') and c.GetReport():find('\nRISK_MODE|SAFE\n',1,true),'risk controls still work after TRUST startup')
local away=t.ui():FindFirstChild('ThrowAway')
check(away.Visible and away.Size.X.Offset==40,'AWAY is one tap away while menu is folded')
check(not c.badButton.Visible,'BAD report button remains out of the play area')
t.me.Chatted:Fire('Z');t.me.Chatted:Fire(' z');t.me.Chatted:Fire('zz')
check(not c.presentation.hidden,'only exact lowercase z toggles presentation')
t.me.Chatted:Fire('z')
check(c.presentation.hidden and not main.Enabled and not opener.Enabled,'z hides Yuna main GUI and separate opener in executor container')
check(not t.ui().Enabled and gameHud.Enabled and controls.Enabled,'z hides Pelican while preserving game HUD and touch controls')
check(light.Brightness==1.25 and light.ClockTime==20,'z applies captured original lighting, not guessed defaults')
local late=Instance.new('ScreenGui');late.Name='LateOpener';late.Enabled=true;late.Parent=hidden
c.presentation:update(Mock.time+1);check(not late.Enabled,'late executor GUIs are also hidden')
t.me.Chatted:Fire('z')
check(main.Enabled and opener.Enabled and not closed.Enabled and late.Enabled,'second z restores original GUI states including originally closed windows')
check(light.Brightness==3,'second z restores the prior visual presentation where still owned')
away.Activated:Fire();check(#t.requests==1,'always-visible AWAY invokes the existing deliberate throw-away action directly')
t.me.Chatted:Fire('z');check(c.Stop('USER_END'),'presentation cleanup is acknowledged')
check(main.Enabled and opener.Enabled and gameHud.Enabled,'stop while hidden restores external GUI states')
t.me.Chatted:Fire('z');check(not c.presentation.hidden,'stopped presentation listener cannot hide UI again')

local O=assert(loadfile('experimental/oscillation.lua'))()
local policy={MinMotionAge=.65,MinMoveSpeed=2,MinMotionTravel=2.4,Interval=.12}
local function path(xs)
 local out={};for i,x in ipairs(xs)do out[i]={at=(i-1)*.1,p=Vector3.new(x,6,30)}end;return out
end
local history=path({0,2,4,2,0,2,4,2,0})
local zig=O.detect(history,Vector3.new(0,0,-1),.8,policy)
check(zig and zig.Reversals>=2,'repeated observed lateral reversals qualify')
check(not O.detect(path({0,0,0,0,0,0,0,0,0}),Vector3.new(0,0,-1),.8,policy),'standing AFK receiver never qualifies')
check(not O.detect(path({0,1,2,3,4,5,6,7,8}),Vector3.new(0,0,-1),.8,policy),'straight route is not mislabeled as oscillation')
check(not O.detect(path({0,2,4,6,8,6,4,2,0}),Vector3.new(0,0,-1),.8,policy),'one comeback/cut does not qualify as repeated oscillation')
check(not O.detect(history,Vector3.new(0,0,-1),1,policy),'old movement cannot keep an AFK receiver eligible')
local s={p=Vector3.new(0,6,30),head={Position=Vector3.new(0,8,30)},v=Vector3.new(20,0,0),oscillation=zig}
local origin=Vector3.new(0,8,80);local lead={X=3,Y=0}
local power=O.power(s,origin,.9,28,20,lead)
check(not O.power(s,Vector3.new(0,8,300),.9,28,20,lead),'point adapter declines when native power cannot reach the observed area within the comfort request')
local x,time=O.control(s,origin,power,28,0,lead)
check(x<0 and math.abs(x+20*time)<.0001,'native lead cancellation offsets the modeled straight-line movement')
check(O.contains(s,Vector3.new(2,8,30),3) and not O.contains(s,Vector3.new(40,8,30),3),'actual native output must stay in the observed movement area')
for _,covered in ipairs({false,true})do
 local t=setup({ff3={Profile='CASUAL',RiskMode='TRUST'},nativeModes={Dime=true}})
 t.ar.Position=Vector3.new(20,6,30)
 if covered then t.dr.Position=Vector3.new(20,6,30)end
 local c=t.run();c.SetThrow(false);local maximum=0
 for i=1,30 do
  local phase=(i-1)%8;local x=phase<=4 and phase or 8-phase
  t.ar.Position=Vector3.new(20+x,6,30);t.ar.AssemblyLinearVelocity=Vector3.new(phase<4 and 10 or -10,0,0)
  if i==14 then c.SetThrow(true)end
  maximum=math.max(maximum,t.advance(.1));t.drain();if #t.requests>0 then break end
 end
 if covered then check(#t.requests==0,'covered zigzag receiver cannot borrow TRUST contest relief for a point Bullet')
 else
  local p=t.payload()
  check(#t.requests==1 and p and p.Variant=='ZigzagBullet','open repeated reversals actually release a native point Bullet through the controller')
  check(p.Power<95 and p.Time>=.855,'point Bullet keeps actual native comfort checks')
  check(t.leads.Bullet.X==3 and t.q.Power==95 and t.q.AutoThrowType.Enabled,'temporary point lead/power/type are restored after native solving')
  check(c.bad:flag(Mock.time),'actual zigzag release is available to BAD capture')
  local function json(v)
   if v==nil then return 'null' elseif type(v)=='string'then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n')..'"'
   elseif type(v)=='number'or type(v)=='boolean'then return tostring(v)end
   local out={};if #v>0 then for _,x in ipairs(v)do out[#out+1]=json(x)end;return '['..table.concat(out,',')..']'end
   for k,x in pairs(v)do out[#out+1]=json(tostring(k))..':'..json(x)end;return '{'..table.concat(out,',')..'}'
  end
  local f=assert(io.open('/tmp/pelican-zigzag-runtime-report.json','w'));f:write(json(c.bad:report()));f:close()
 end
 check(maximum<=8 and c.Stop('ZIGZAG_CASE'),'zigzag selection retains native call cap and cleanup')
end
print('PASS presentation/oscillation checks',count,'(mocked; native GUI ownership and catchability require live verification)')
