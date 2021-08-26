import VectorMath;
import scene.Actor;
import fsm.StateMachine;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.input.Keycodes;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.resources.builtin.PageFrameResource;
import uk.aidanlee.flurry.api.resources.parcels.Preload;

using hxrx.schedulers.IScheduler;
using uk.aidanlee.flurry.api.gpu.drawing.Frames;
using uk.aidanlee.flurry.api.gpu.drawing.NineSlice;

class Player extends Actor
{
    final camera : PlayerCamera;

    final fsm : StateMachine<PlayerState, PlayerTriggers>;

    var angle : Float;

    var boost : Float;

    var shiftVel : Float;

    var shifts : Int;

    var maxBoostEnergy : Float;

    var boostEnergy : Float;

    var boostMultiplier : Float;

    var shootingTimer : Float;
    
    var shootingOffset : Float;

    public function new(_camera)
    {
        super(vec2(128, 128));

        camera          = _camera;
        fsm             = new StateMachine(Flying);
        angle           = 0;
        shifts          = 2;
        maxBoostEnergy  = 100;
        boostEnergy     = maxBoostEnergy;
        boostMultiplier = 1;
        depth           = 1;
        shootingTimer   = 0.25;
        shootingOffset  = 8;

        this.fsm
            .config(Flying)
            .permit(StartBoost, Boosting)
            .permit(StartShift, SideShift);

        this.fsm
            .config(Boosting)
            .permit(EndBoost, Flying)
            .onEntry(onBoostStart)
            .onExit(onBoostEnd);

        this.fsm
            .config(SideShift)
            .onEntryWith(onStartShift)
            .permit(EndShift, Flying);
    }

    public function onUpdate(_dt : Float)
    {
        switch fsm.getCurrentState()
        {
            case Flying:
                // Boost Management
                if (boostEnergy < maxBoostEnergy)
                {
                    boostEnergy += 0.5;
                }
                if (boostEnergy > maxBoostEnergy)
                {
                    boostEnergy = maxBoostEnergy;
                }

                // Movement
                if (Game.input.isKeyDown(Keycodes.key_a))
                {
                    angle += 2;
                }
                if (Game.input.isKeyDown(Keycodes.key_d))
                {
                    angle -= 2;
                }

                // Side Shift
                if (shifts > 0)
                {
                    if (Game.input.wasKeyPressed(Keycodes.key_q))
                    {
                        fsm.fireWith(StartShift, 10);
                    }
                    if (Game.input.wasKeyPressed(Keycodes.key_e))
                    {
                        fsm.fireWith(StartShift, -10);
                    }
                }

                // Boost Activation
                if (Game.input.wasKeyPressed(Keycodes.lshift))
                {
                    fsm.fire(StartBoost);
                }

                if (Game.input.isKeyDown(Keycodes.space) && shootingTimer <= 0)
                {
                    scene.add(
                        new Bullet(
                            vec2(pos) + polarToCartesian(shootingOffset, angle + 90),
                            polarToCartesian(7, angle)));

                    shootingTimer  = 0.25;
                    shootingOffset = -shootingOffset;
                }
            case Boosting:
                camera.shake(1);

                boostEnergy -= 0.9;

                if (Math.floor(boostEnergy) % 5 == 0)
                {
                    createSmoke();
                }

                if (Game.input.wasKeyReleased(Keycodes.lshift) || boostEnergy <= 0)
                {
                    fsm.fire(EndBoost);
                }
            case SideShift:
                pos += polarToCartesian(shiftVel, angle + 90);

                shiftVel *= 0.925;

                if (Math.floor(shiftVel) % 5 == 0)
                {
                    createSmoke();
                }

                if (Math.abs(shiftVel) < 0.8)
                {
                    shiftVel = 0;

                    fsm.fire(EndShift);
                }
        }

        pos += getVelocity();

        if (pos.x < 0)
        {
            pos.x = Game.room.x;
        }
        if (pos.y < 0)
        {
            pos.y = Game.room.y;
        }
        if (pos.x > Game.room.x)
        {
            pos.x = 0;
        }
        if (pos.y > Game.room.y)
        {
            pos.y = 0;
        }

        if (shootingTimer > 0)
        {
            shootingTimer -= (1 / 60);
        }
    }

    public inline function getVelocity()
    {
        return polarToCartesian(2.7 * boostMultiplier, angle);
    }

    public function onRender(_ctx : GraphicsContext)
    {
        // Draw player shadow
        _ctx.drawFrame(cast Game.resources.get(Preload.img_ship0), pos - vec2(8, -8), vec2(0.5, 0.5), angle, vec4(0, 0, 0, 0.25));

        // Draw player
        _ctx.drawFrame(cast Game.resources.get(Preload.img_ship0), pos, vec2(0.5, 0.5), angle);
    }

    public function onRenderHud(_ctx : GraphicsContext)
    {
        // HUD panel background.
        _ctx.drawNineSlice(cast Game.resources.get(Preload.ui_panel), vec2(128, 48), vec4(8, 8, 8, 8), vec2(32, 32));

        // Draw the boost bar outline then the bar with the actual boost amount.
        // Use Math.max to limit the displayed value to not be less than the slice region, otherwise the bar starts to get drawn backwards!
        _ctx.drawNineSlice(
            Game.resources.getAs(Preload.ui_bar_outline, PageFrameResource),
            vec2(128 - 16, 16),
            vec4(8, 8, 8, 8),
            vec2(32 + 8, 32 + 8));
        _ctx.drawNineSlice(
            Game.resources.getAs(Preload.ui_bar, PageFrameResource),
            vec2(Math.max((128 - 16) * (boostEnergy / maxBoostEnergy), 10), 16),
            vec4(8, 8, 8, 8),
            vec2(32 + 8, 32 + 8));

        // Draw outlines for all possible side shift charges.
        _ctx.drawNineSlice(
            Game.resources.getAs(Preload.ui_bar_outline, PageFrameResource),
            vec2(52, 16),
            vec4(8, 8, 8, 8),
            vec2(40, 48 + 8));

        _ctx.drawNineSlice(
            Game.resources.getAs(Preload.ui_bar_outline, PageFrameResource),
            vec2(52, 16),
            vec4(8, 8, 8, 8),
            vec2(100, 48 + 8));

        // Draw filled in bar for available side shift charges.
        if (shifts >= 1)
        {
            _ctx.drawNineSlice(
                Game.resources.getAs(Preload.ui_bar, PageFrameResource),
                vec2(52, 16),
                vec4(8, 8, 8, 8),
                vec2(40, 48 + 8));
        }
        if (shifts >= 2)
        {
            _ctx.drawNineSlice(
                Game.resources.getAs(Preload.ui_bar, PageFrameResource),
                vec2(52, 16),
                vec4(8, 8, 8, 8),
                vec2(100, 48 + 8));
        }
    }

    function onStartShift(_data : Any)
    {
        if (_data is Int)
        {
            shiftVel = _data;

            camera.shake(2);

            shifts--;

            Game.mainThread.scheduleFunction(3, () -> {
                if (shifts < 2)
                {
                    shifts++;
                }
            });
        }
    }

    function onBoostStart()
    {
        boostMultiplier = 2;
    }

    function onBoostEnd()
    {
        boostMultiplier = 1;
    }

    function createSmoke()
    {
        final p = PlayerCamera.randomPointInUnitCircle() * 8;

        scene.add(new Smoke(pos.x + p.x, pos.y + p.y, cast Game.resources.get(Preload.img_smoke)));
    }
}

private enum PlayerState
{
    Flying;
    Boosting;
    SideShift;
}

private enum PlayerTriggers
{
    StartBoost;
    EndBoost;
    StartShift;
    EndShift;
}