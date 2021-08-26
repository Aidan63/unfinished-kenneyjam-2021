import VectorMath;
import scene.Actor;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.resources.builtin.PageFrameResource;

using uk.aidanlee.flurry.api.gpu.drawing.Frames;

class Smoke extends Actor
{
    final img : PageFrameResource;

    var angle : Float;

    var opacity : Float;

    public function new(_x : Float, _y : Float, _img)
    {
        super(vec2(_x, _y));

        img     = _img;
        angle   = Math.random() * 360;
        opacity = 1;
    }

	public function onUpdate(_dt : Float)
    {
        opacity *= 0.975;
        angle += 0.25;

        if (opacity < 0.1)
        {
            die();
        }
    }

	public function onRender(_ctx : GraphicsContext)
    {
        _ctx.drawFrame(img, pos, vec2(0.5, 0.5), angle, vec4(1, 1, 1, opacity));
    }
}