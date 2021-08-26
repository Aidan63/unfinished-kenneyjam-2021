import VectorMath;
import scene.Scene;
import uk.aidanlee.flurry.Flurry;
import uk.aidanlee.flurry.FlurryConfig;
import uk.aidanlee.flurry.api.gpu.ShaderID;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.gpu.camera.Camera2D;
import uk.aidanlee.flurry.api.gpu.pipeline.PipelineID;
import uk.aidanlee.flurry.api.resources.parcels.Preload;

using uk.aidanlee.flurry.api.gpu.drawing.Frames;

class Main extends Flurry
{
    var pipeline : PipelineID;

    var camera : PlayerCamera;

    var hud : Camera2D;

    var pos : Vec2;

    var angle : Float;

    var scene : Scene;

    override function onConfig(_config : FlurryConfig) : FlurryConfig
    {
        _config.window.title  = 'Jam';
        _config.window.width  = 768;
        _config.window.height = 512;

        _config.resources.preload = [ 'preload' ];

        return _config;
    }

    override function onReady()
    {
        Game.input      = input;
        Game.display    = display;
        Game.resources  = resources;
        Game.mainThread = mainThreadScheduler;
        Game.taskPool   = taskThreadScheduler;

        pipeline = renderer.createPipeline({ shader : new ShaderID(Preload.shd_basic) });
        camera   = new PlayerCamera(display.width, display.height);
        hud      = new Camera2D(vec2(0, 0), vec2(display.width, display.height), vec4(0, 0, display.width, display.height));
        scene    = new Scene();

        scene.add(Game.player = new Player(camera));
        
        for (_ in 0...10)
        {
            final x     = Math.random() * Game.room.x;
            final y     = Math.random() * Game.room.y;
            final actor = new Enemy(vec2(x, y), Math.random() * 360);

            scene.add(actor);
        }
    }

    override function onUpdate(_dt : Float)
    {
        camera.viewport.z = display.width;
        camera.viewport.w = display.height;
        camera.update(_dt);

        scene.onUpdate(_dt);
    }

    override function onRender(_ctx : GraphicsContext)
    {
        _ctx.usePipeline(pipeline);
        _ctx.useCamera(camera);
        _ctx.drawFrameTiled(cast resources.get(Preload.img_background), vec2(0, 0), vec2(display.width, display.height));

        scene.onRender(_ctx);

        _ctx.useCamera(hud);

        Game.player.onRenderHud(_ctx);
    }
}