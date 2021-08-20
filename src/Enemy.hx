import VectorMath;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.resources.Parcels.Preload;
import scene.Actor;

using uk.aidanlee.flurry.api.gpu.drawing.Frames;

class Enemy extends Actor
{
    var angle : Float;

    public function new(_angle)
    {
        super(vec2(Game.display.width / 2, Game.display.height / 2));

        angle = _angle;
    }

	public function onUpdate(_dt : Float)
    {
        wander();

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

    function wander()
    {
        final centre = pos + polarToCartesian(128, angle);
        final offset = randomPointInUnitCircle() * 16;
        final target = centre + offset;

        angle = angleBetween(pos, target);
        pos += polarToCartesian(3, angle);
    }

    public static inline function randomPointInUnitCircle()
    {
        final r = Math.sqrt(Math.random());
        final t = (-1 + (2 * Math.random())) * (Math.PI * 2);

        return vec2(r * Math.cos(t), r * Math.sin(t));
    }
}