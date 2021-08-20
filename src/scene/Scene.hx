package scene;

import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import haxe.ds.Vector;

class Scene
{
    final actors : Vector<Null<Actor>>;

    public function new()
    {
        actors = new Vector(1024);
    }

    public function add(_actor : Actor)
    {
        for (i in 0...actors.length)
        {
            switch actors[i]
            {
                case null:
                    _actor.scene = this;

                    actors[i] = _actor;

                    return;
                case _:
                    continue;
            }
        }
    }

    public function onUpdate(_dt : Float)
    {
        actors.sort(sort);

        for (actor in actors)
        {
            if (actor != null)
            {
                actor.onUpdate(_dt);
            }
        }

        for (i in 0...actors.length)
        {
            switch actors[i]
            {
                case null:
                    continue;
                case actor:
                    if (actor.dead)
                    {
                        actors[i] = null;
                    }
            }
        }
    }

    public function onRender(_ctx : GraphicsContext)
    {
        for (actor in actors)
        {
            if (actor != null)
            {
                actor.onRender(_ctx);
            }
        }
    }

    function sort(_a1 : Null<Actor>, _a2 : Null<Actor>)
    {
        final d1 = if (_a1 != null) _a1.depth else 0;
        final d2 = if (_a2 != null) _a2.depth else 0;

        return d1 - d2;
    }
}