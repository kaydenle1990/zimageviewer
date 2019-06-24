package co.izeta.zimageviewer.zimageviewer;

import android.app.Activity;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.squareup.picasso.Picasso;
import com.stfalcon.imageviewer.StfalconImageViewer;
import com.stfalcon.imageviewer.listeners.OnDismissListener;
import com.stfalcon.imageviewer.listeners.OnImageChangeListener;
import com.stfalcon.imageviewer.loader.ImageLoader;

import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;

/** ZimageviewerPlugin */
public class ZimageviewerPlugin implements MethodCallHandler {

  private static final String CHANNEL = "co.izeta.dev/zimageviewer";
  private static final String METHOD = "displayImageViewer";

  private final FlutterActivity activity;
  private final FlutterView flutterView;
  private final SharingOverlayView overlayView;

  private ZimageviewerPlugin(Activity activity) {
    this.activity = (FlutterActivity) activity;
    this.flutterView = this.activity.getFlutterView();
    this.overlayView = new SharingOverlayView(activity);
    this.overlayView.currentActivity = this.activity;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    channel.setMethodCallHandler(new ZimageviewerPlugin(registrar.activity()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals(METHOD)) {

      final List<String> photos = call.argument("photos");
      final List<String> captions = call.argument("captions");
      final Integer startIndex = call.argument("start_position");

      if (photos != null) {
        new StfalconImageViewer.Builder<>(this.activity, photos, new ImageLoader<String>() {
          @Override
          public void loadImage(ImageView imageView, String image) {
            Picasso.get().load(image).into(imageView);
          }
        }).withHiddenStatusBar(true)
                .allowSwipeToDismiss(true)
                .withImageMarginPixels(48)
                .withOverlayView(this.overlayView)
                .withImageChangeListener(new OnImageChangeListener() {
                  @Override
                  public void onImageChange(int position) {
                    ZimageviewerPlugin.this.overlayView
                            .updatePagingContent(photos.get(position), captions.get(position),
                                    String.format("%d/%d", position + 1, photos.size()));
                  }
                })
                .withDismissListener(new OnDismissListener() {
                  @Override
                  public void onDismiss() {
                    if(ZimageviewerPlugin.this.overlayView.getParent() != null) {
                      ((ViewGroup)ZimageviewerPlugin.this.overlayView.getParent()).removeView(ZimageviewerPlugin.this.overlayView);
                    }
                  }
                })
                .withStartPosition(startIndex)
                .show();

        // Setup information with start index
        ZimageviewerPlugin.this.overlayView
                .updatePagingContent(photos.get(startIndex), captions.get(startIndex),
                        String.format("%d/%d", startIndex + 1, photos.size()));

        result.success("SUCCESS");
      } else {
        result.error("UNAVAILABLE", "ERROR", null);
      }
    } else {
      result.notImplemented();
    }
  }
}
