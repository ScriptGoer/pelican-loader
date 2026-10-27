"""Keep fresh native release checks while avoiding duplicate preview work.

An omitted native calculation is not evidence of an unsafe receiver. Only the
three bounded scheduling/pose failures below may retain a prepared sequence;
actual context, readiness and coverage failures still cancel normally.
"""


def repair(source):
    def one(old, new):
        nonlocal source
        assert source.count(old) == 1, (old[:100], source.count(old))
        source = source.replace(old, new, 1)

    one(
        "local function driveSequence(now)",
        """-- BEGIN RELEASE PIPELINE REPAIR
function controller.unified.ReleaseDeferred(reason)
    return reason=='NATIVE_FRAME_BUDGET' or reason=='QB_LAUNCH_POSE_CHANGED_REPLAN'
        or reason=='DECISION_STALE_AFTER_NATIVE_SOLVER'
end
-- END RELEASE PIPELINE REPAIR
local function driveSequence(now)""",
    )
    one(
        "            if not passed then cancelSequence('PREJUMP_WINDOW_CHANGED');cancelJump('PREJUMP_CANCELLED');return end",
        """            if not passed then
                if controller.unified.ReleaseDeferred(gate) then
                    seq.preJumpDeferred=gate
                    if controller.bad.current and controller.bad.current.PreJump then
                        controller.bad.current.PreJump.Deferred=gate
                        controller.bad.current.PreJump.Status='PREJUMP_DEFERRED'
                    end
                    setGate('PREJUMP_REPLAN')
                    return -- no jump and no packet; retry fresh on the next callback
                end
                -- A fresh refusal invalidates this receiver's optimistic cache;
                -- it must not repeatedly beat other current opportunities.
                shotCache[seq.player]=nil;opportunities[seq.player]=nil
                cancelSequence('PREJUMP_WINDOW_CHANGED');cancelJump('PREJUMP_CANCELLED');return
            end""",
    )
    one(
        "    elseif gate=='NATIVE_FRAME_BUDGET' or gate=='QB_LAUNCH_POSE_CHANGED_REPLAN' or gate=='DECISION_STALE_AFTER_NATIVE_SOLVER' then",
        "    elseif controller.unified.ReleaseDeferred(gate) then",
    )
    one(
        "    if not hum or not ascentTime(hum) then return false,'JUMP_PHYSICS_UNVERIFIED' end\n"
        "    if hum.Sit or hum.PlatformStand or not hum:GetStateEnabled(Enum.HumanoidStateType.Jumping) then return false,'NORMAL_JUMP_UNAVAILABLE' end\n"
        "    return true,'FRESH_ADMITTED_NATIVE_WINDOW'",
        """    local _,root=body(me)
    local ascent=hum and ascentTime(hum)
    local detail={PhysicsKnown=ascent~=nil,AscentSeconds=ascent,Gravity=workspace.Gravity,
        VerticalVelocity=root and root.AssemblyLinearVelocity.Y or nil}
    if hum then
        detail.Sit=hum.Sit;detail.PlatformStand=hum.PlatformStand;detail.Jump=hum.Jump
        detail.JumpingEnabled=hum:GetStateEnabled(Enum.HumanoidStateType.Jumping)
        detail.FloorMaterial=tostring(hum.FloorMaterial)
        local stateOK,state=pcall(function()return hum:GetState()end)
        detail.State=stateOK and tostring(state) or 'UNAVAILABLE'
        detail.UseJumpPower=hum.UseJumpPower;detail.JumpPower=hum.JumpPower;detail.JumpHeight=hum.JumpHeight
    end
    if not hum or not ascent then return false,'JUMP_PHYSICS_UNVERIFIED',detail end
    if detail.Sit or detail.PlatformStand or not detail.JumpingEnabled then return false,'NORMAL_JUMP_UNAVAILABLE',detail end
    return true,'FRESH_ADMITTED_NATIVE_WINDOW',detail""",
    )
    one(
        "            local jumpAllowed,jumpReason=false,'PREJUMP_WINDOW_CHANGED'",
        "            local jumpAllowed,jumpReason,jumpDetails=false,'PREJUMP_WINDOW_CHANGED',nil",
    )
    one(
        "jumpAllowed,jumpReason=controller.unified.AutoJumpAllowed(prepared,seq.selected.sample,ball.hum)",
        "jumpAllowed,jumpReason,jumpDetails=controller.unified.AutoJumpAllowed(prepared,seq.selected.sample,ball.hum)",
    )
    one(
        "controller.bad.current.Final.AutoJump={Allowed=jumpAllowed,Reason=jumpReason}",
        "controller.bad.current.Final.AutoJump={Allowed=jumpAllowed,Reason=jumpReason,Readiness=jumpDetails}",
    )
    one(
        "assistance.jumpPlan={hum=hum,model=ball.model,epoch=possession.epoch,before=hum.Jump,owned=true,requested=now}",
        "assistance.jumpPlan={hum=hum,model=ball.model,epoch=possession.epoch,before=hum.Jump,owned=true,requested=now,requestedFrame=motionFrame}",
    )
    one(
        "    elseif now>plan.requested or me.Character~=plan.model or stopped then cancelJump('JUMP_REQUEST_FINISHED') end",
        """    -- os.clock() advances within a Heartbeat: the later guide callback
    -- must not clear a jump requested earlier in that same physics turn.
    elseif motionFrame>plan.requestedFrame or me.Character~=plan.model or stopped then cancelJump('JUMP_REQUEST_FINISHED') end""",
    )
    one(
        "        if best.shot.mode=='Fit' or (best.shot.jumpBullet or best.shot.nativeCoverageJump) then\n"
        "            -- Reserve final calls for the candidate and fresh counterfactuals\n"
        "            -- (three for a league layer-window Fit). Avoid a redundant preview.",
        """        if throwing or best.shot.mode=='Fit' or (best.shot.jumpBullet or best.shot.nativeCoverageJump) then
            -- The bounded cached tuple chooses/locks a candidate only. Automatic
            -- releaseNow still solves the actual throw after current readiness,
            -- context and possession checks; it never sends this cached tuple.
            -- Save the duplicate native preview call for that fresh transaction.
            -- Selection-only mode retains its native preview below.""",
    )
    return source
