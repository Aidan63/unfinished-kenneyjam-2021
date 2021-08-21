import fsm.StateMachine;
import VectorMath;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.resources.Parcels.Preload;
import scene.Actor;

using uk.aidanlee.flurry.api.gpu.drawing.Frames;
using hxrx.schedulers.IScheduler;

class Enemy extends Actor
{
    private static final MAX_VELOCITY = 3;

    private static final MAX_FORCE = 0.2;

    private static final MASS = 10;

    final fsm : StateMachine<EnemyState, EnemyTriggers>;

    final evadeRange : Float;

    var vel : Vec2;

    var angle : Float;

    var canStartSeeking : Bool;

    public function new(_pos, _angle)
    {
        super(_pos);

        fsm             = new StateMachine(Chasing);
        evadeRange      = 64 + (128 * Math.random());
        angle           = _angle;
        vel             = vec2(0);
        canStartSeeking = false;

        this.fsm
            .config(Chasing)
            .permit(PlayerTooClose, Evading);

        this.fsm
            .config(Evading)
            .permit(StartChasing, Chasing);
    }

	public function onUpdate(_dt : Float)
    {
        switch fsm.getCurrentState()
        {
            case Wandering:
                //
            case Chasing:
                chase();
            case Evading:
                evade();
        }

        angle = angleBetween(pos, pos + vel);

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
    }

	public function onRender(_ctx : GraphicsContext)
    {
        // Draw player shadow
        _ctx.drawFrame(cast Game.resources.get(Preload.img_ship1), pos - vec2(8, -8), vec2(0.5, 0.5), angle, vec4(0, 0, 0, 0.25));

        // Draw player
        _ctx.drawFrame(cast Game.resources.get(Preload.img_ship1), pos, vec2(0.5, 0.5), angle);
    }

    inline function seek(_target : Vec2)
    {
        final desired  = (_target - pos).normalize() * vec2(MAX_VELOCITY);
        final steering = (desired - vel).min(MAX_FORCE) / MASS;

        vel = (vel + steering).min(MAX_VELOCITY);
        pos += vel;

        // final speed    = 3;
        // final velocity = polarToCartesian(speed, angle);
        // final desired  = (_target - pos).normalize() * 1.5;
        // final steering = desired - velocity;

        // pos += (velocity + steering);
    }

    inline function flee(_target : Vec2)
    {
        final desired  = (pos - _target).normalize() * vec2(MAX_VELOCITY);
        final steering = (desired - vel).min(MAX_FORCE) / MASS;

        vel = (vel + steering).min(MAX_VELOCITY);
        pos += vel;

        // final speed    = 3;
        // final velocity = polarToCartesian(speed, angle);
        // final desired  = (pos - _target).normalize() * 1.5;
        // final steering = desired - velocity;

        // pos += (velocity + steering);
    }

    inline function wander()
    {
        final centre = pos + polarToCartesian(128, angle);
        final offset = randomPointInUnitCircle() * 16;
        final target = centre + offset;

        angle = angleBetween(pos, target);
        pos += polarToCartesian(3, angle);
    }

    inline function chase()
    {
        if (distanceBetween(pos, Game.player.pos) < evadeRange)
        {
            fsm.fire(PlayerTooClose);

            canStartSeeking = false;

            Game.mainThread.scheduleFunction(1 + Math.random(), () -> canStartSeeking = true);
        }
        else
        {
            // final distance = distanceBetween(pos, Game.player.pos) / 2;
            final target   = Game.player.pos + Game.player.getVelocity() * 2;
    
            seek(target);
        }
    }

    function evade()
    {
        if (distanceBetween(pos, Game.player.pos) > 256 && canStartSeeking)
        {
            fsm.fire(StartChasing);
        }
        else
        {
            final distance = distanceBetween(pos, Game.player.pos);
            final updates  = distance / MAX_VELOCITY;
            final target   = Game.player.pos + Game.player.getVelocity() * updates;
    
            flee(target);
        }
    }

    public static inline function randomPointInUnitCircle()
    {
        final r = Math.sqrt(Math.random());
        final t = (-1 + (2 * Math.random())) * (Math.PI * 2);

        return vec2(r * Math.cos(t), r * Math.sin(t));
    }
}

private enum EnemyState
{
    Wandering;
    Chasing;
    Evading;
}

private enum EnemyTriggers
{
    PlayerTooClose;
    StartChasing;
}