import scene.Scene;
import VectorMath;
import haxe.io.Bytes;
import haxe.ds.Vector;
import haxe.io.ArrayBufferView;
import uk.aidanlee.flurry.Flurry;
import uk.aidanlee.flurry.FlurryConfig;
import uk.aidanlee.flurry.api.gpu.Colour;
import uk.aidanlee.flurry.api.gpu.ShaderID;
import uk.aidanlee.flurry.api.gpu.SurfaceID;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.gpu.camera.Camera2D;
import uk.aidanlee.flurry.api.gpu.pipeline.PipelineID;
import uk.aidanlee.flurry.api.gpu.geometry.UniformBlob;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.input.Keycodes;
import uk.aidanlee.flurry.api.resources.Parcels.Preload;
import uk.aidanlee.flurry.api.resources.ResourceID;
import uk.aidanlee.flurry.api.resources.builtin.PageFrameResource;

using uk.aidanlee.flurry.api.gpu.drawing.Frames;

class Main extends Flurry
{
    var pipeline : PipelineID;

    var camera : PlayerCamera;

    var hud : Camera2D;

    var pos : Vec2;

    var angle : Float;

    var player : Player;

    var scene : Scene;

    override function onConfig(_config : FlurryConfig) : FlurryConfig
    {
        _config.window.title  = 'Demo';
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

        scene.add(player = new Player(camera));
        
        for (_ in 0...10)
        {
            scene.add(new Enemy(Math.random() * 360));
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

        player.onRenderHud(_ctx);
    }
}