import VectorMath;
import uk.aidanlee.flurry.Flurry;
import uk.aidanlee.flurry.FlurryConfig;
import uk.aidanlee.flurry.api.gpu.ShaderID;
import uk.aidanlee.flurry.api.gpu.GraphicsContext;
import uk.aidanlee.flurry.api.gpu.camera.Camera2D;
import uk.aidanlee.flurry.api.gpu.pipeline.PipelineID;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.resources.parcels.Preload;
import uk.aidanlee.flurry.api.gpu.drawing.Shapes;

using uk.aidanlee.flurry.api.gpu.drawing.Frames;
using uk.aidanlee.flurry.api.gpu.drawing.Shapes;

class Steering extends Flurry
{
    var pipeline1 : PipelineID;

    var pipeline2 : PipelineID;

    var camera : Camera2D;

    override function onConfig(_config : FlurryConfig)
    {
        _config.window.title  = 'Demo';
        _config.window.width  = 768;
        _config.window.height = 512;

        _config.resources.preload = [ 'preload' ];

        return _config;
    }

    override function onReady()
    {
        pipeline1 = renderer.createPipeline({ shader : new ShaderID(Preload.shd_basic) });
        pipeline2 = renderer.createPipeline({ shader : new ShaderID(Preload.shd_shapes) });
        camera    = new Camera2D(vec2(0, 0), vec2(display.width, display.height), vec4(0, 0, display.width, display.height));
    }

    override function onRender(_ctx : GraphicsContext)
    {
        _ctx.usePipeline(pipeline1);
        _ctx.useCamera(camera);
        _ctx.drawFrameTiled(cast resources.get(Preload.img_background), vec2(0, 0), vec2(display.width, display.height));

        _ctx.usePipeline(pipeline2);
        _ctx.useCamera(camera);
        _ctx.drawCircleOutline(vec2(display.mouseX, display.mouseY), 16, 4, vec4(1, 0, 0, 0.75));

        // Define a line and draw it.
        final p0 = vec2(160, 32);
        final p1 = vec2(display.width - 160, display.height - 32);
        _ctx.drawLine(p0, p1, 4, vec4(1, 0, 0, 0.75));

        // Calculate what side of the line the cursor falls on.
        final cursor    = vec2(display.mouseX, display.mouseY);
        final direction = (cursor.x - p0.x) * (p1.y - p0.y) - (cursor.y - p0.y) * (p1.x - p0.x);

        // Draw a representation of the lines tangent from the centre of the line.
        // The tangent line is drawn according to the sign of the direction it falls on.
        final unit    = normalize(p1 - p0);
        final centre  = p0 + (unit * length(p1 - p0) * 0.5);
        final tangent = centre + (vec2(-unit.y, unit.x) * 32 * -sign(direction));
        _ctx.drawLine(centre, tangent, 4, vec4(1, 0, 0, 0.75));
        
        // Draw the sW circle.
        final maxRadius = 32;
        final sW = centre + (vec2(-unit.y, unit.x) * maxRadius * -sign(direction));
        _ctx.drawCircleOutline(sW, maxRadius, 4, vec4(1, 0, 0, 0.75));

        _ctx.drawLine(vec2(0, 0), vec2(32, 32));

        drawLine(_ctx, vec2(0, 0), vec2(32, 32));
    }
}