import VectorMath;
import scene.Actor;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.resources.Parcels.Preload;
import uk.aidanlee.flurry.api.resources.builtin.PageFrameResource;

using uk.aidanlee.flurry.api.gpu.drawing.Frames;

class Bullet extends Actor
{
    final vel : Vec2;

    final angle : Float;

    var timeToDeath : Float;

    public function new(_pos : Vec2, _vel : Vec2)
    {
        super(_pos);

        vel         = _vel;
        angle       = angleBetween(vec2(0), vel);
        timeToDeath = 2;
    }

    public function onUpdate(_dt : Float)
    {
        pos.x += vel.x;
        pos.y += vel.y;

        timeToDeath -= _dt;

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

        if (timeToDeath <= 0)
        {
            die();
        }
    }

    public function onRender(_ctx : GraphicsContext)
    {
        _ctx.drawFrame(
            Game.resources.getAs(Preload.img_bullet1, PageFrameResource),
            pos,
            vec2(0.5, 0.5),
            angleBetween(vec2(0), vel));
    }
}