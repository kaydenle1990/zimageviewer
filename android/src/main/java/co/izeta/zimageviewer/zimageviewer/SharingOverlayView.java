package co.izeta.zimageviewer.zimageviewer;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.content.FileProvider;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class SharingOverlayView extends RelativeLayout {

    private TextView textDescription;

    private TextView textPaging;

    public String currentUrl;

    public Activity currentActivity;

    public SharingOverlayView(Context context) {
        super(context);
        init();
    }

    public SharingOverlayView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public SharingOverlayView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        View view = inflate(getContext(), R.layout.view_image_overlay, this);
        view.findViewById(R.id.share_button).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Picasso.get().load(currentUrl).into(shareTarget);
            }
        });
        this.textDescription = view.findViewById(R.id.text_description);
        this.textPaging = view.findViewById(R.id.text_paging);
    }

    public void updatePagingContent(String url, String description, String pageInfo) {
        this.textDescription.setText(description);
        this.textPaging.setText(pageInfo);
        this.currentUrl = url;
    }

    private Target shareTarget = new Target() {

        @Override
        public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom from) {
            // Get access to the URI for the bitmap
            String fileName = getLocalBitmapUri(bitmap);
            String providerId = "co.izeta.zimageviewer.fileprovider";
            if (fileName != null) {
                File imagePath = new File(currentActivity.getCacheDir(), "images");
                File newFile = new File(imagePath, fileName);
                Uri contentUri = FileProvider.getUriForFile(currentActivity, providerId, newFile);

                if (contentUri != null) {
                    Intent shareIntent = new Intent();
                    shareIntent.setAction(Intent.ACTION_SEND);
                    shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION); // temp permission for receiving app to read this file
                    shareIntent.setDataAndType(contentUri, currentActivity.getContentResolver().getType(contentUri));
                    shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
                    currentActivity.startActivity(Intent.createChooser(shareIntent, currentActivity.getString(R.string.share_dialog_title)));
                } else {
                    Toast.makeText(getContext(), currentActivity.getString(R.string.share_fail_msg), Toast.LENGTH_SHORT).show();
                }
            } else {
                // ...sharing failed, handle error
                Toast.makeText(getContext(), currentActivity.getString(R.string.share_fail_msg), Toast.LENGTH_SHORT).show();
            }
        }

        @Override
        public void onBitmapFailed(Exception e, Drawable errorDrawable) {
            Toast.makeText(getContext(), currentActivity.getString(R.string.share_fail_msg), Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onPrepareLoad(Drawable placeHolderDrawable) {

        }
    };

    @SuppressLint("WrongThread")
    public String getLocalBitmapUri(Bitmap bitmap) {
        // Store image to default external storage directory
        String fileName = "image.png";
        try {
            File cachePath = new File(currentActivity.getCacheDir(), "images");
            cachePath.mkdirs();
            FileOutputStream stream = new FileOutputStream(cachePath + "/" + fileName);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
            stream.close();
            return fileName;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
