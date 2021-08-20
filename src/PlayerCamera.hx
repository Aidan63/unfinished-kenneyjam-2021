import VectorMath;
import uk.aidanlee.flurry.api.gpu.camera.Camera2D;

class PlayerCamera extends Camera2D
{
    var isShaking : Bool;

    var shakeAmount : Float;

    public function new(_width : Int, _height : Int)
    {
        super(vec2(0, 0), vec2(_width, _height), vec4(0, 0, _width, _height));

        isShaking   = false;
        shakeAmount = 0;
    }

    public function update(_dt : Float)
    {
        pos.x = 0;
        pos.y = 0;

        if (isShaking)
        {
            pos += (randomPointInUnitCircle() * shakeAmount);

            shakeAmount *= 0.9;

            if (shakeAmount < 0.1)
            {
                shakeAmount = 0;
                isShaking   = false;
            }
        }
    }

    public function shake(_amount : Float)
    {
        isShaking   = true;
        shakeAmount = _amount;
    }

    public static inline function randomPointInUnitCircle()
    {
        final r = Math.sqrt(Math.random());
        final t = (-1 + (2 * Math.random())) * (Math.PI * 2);

        return vec2(r * Math.cos(t), r * Math.sin(t));
    }
}