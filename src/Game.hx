import VectorMath;
import hxrx.schedulers.IScheduler;
import uk.aidanlee.flurry.api.input.Input;
import uk.aidanlee.flurry.api.display.Display;
import uk.aidanlee.flurry.api.resources.ResourceSystem;

class Game
{
    public static final room = vec2(768, 512);

    public static var input : Input;

    public static var display : Display;

    public static var resources : ResourceSystem;

    public static var mainThread : IScheduler;

    public static var taskPool : IScheduler;

    public static var player : Player;

    public static var enemies : Array<Enemy> = [];
}