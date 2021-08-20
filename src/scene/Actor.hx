package scene;

import VectorMath;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;

abstract class Actor
{
    public final pos : Vec2;

    public var dead (default, null) : Bool;

    public var depth : Int;

    public var scene : Null<Scene>;

    public function new(_pos)
    {
        pos   = _pos;
        dead  = false;
        depth = 0;
        scene = null;
    }

    public function die()
    {
        dead = true;
    }

    abstract public function onUpdate(_dt : Float) : Void;

    abstract public function onRender(_ctx : GraphicsContext) : Void;
}
