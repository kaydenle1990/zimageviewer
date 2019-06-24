# ZImageViewer

A customize full-screen image viewer flutter plugin with shared image transition support, pinch to zoom, swipe to dismiss, and share image to another application on device.

ZImageViewer base on [NYTPhotoViewer](https://github.com/nytimes/NYTPhotoViewer) with [SDWebImage](https://github.com/SDWebImage/SDWebImage) for iOS And [StfalconImageViewer](https://github.com/stfalcon-studio/StfalconImageViewer) with [Picasso](https://github.com/square/picasso) for Android.

## Usage
To use this plugin, add `zimageviewer` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS Integration

In the Info.plist follow add :

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Our application needs permission to write photos.</string>
    
### Android Integration

Add <provider> inside <application>

    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="co.izeta.imageviewer.fileprovider"
        android:grantUriPermissions="true"
        android:exported="false">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/filepaths" />
    </provider> 

### Example
``` dart
Future<void> displayImageviewer() async {

    List<String> photos = [
        'https://list25.com/wp-content/uploads/2019/01/powerful-marvel-characters.jpg',
        'https://ultimatecomics.com/wp-content/uploads/2017/11/11-1-2017-23.jpg',
        'https://cdn.gamerant.com/wp-content/uploads/marvel-characters-games.jpg.optimal.jpg',
        'https://cdn3.whatculture.com/images/2018/07/05790009d77f36ba-600x338.jpg'
        ];

    List<String> captions = [
        'Powerful marvel characters',
        'Captain america',
        'Marvel characters games',
        '10 Marvel Characters Who Became Venom'
        ];

    int startIndex = 1;
    String textMsg = '';
    try {
        bool result = await Zimageviewer.displayImageviewer(photos, captions, startIndex);
        if (result == true) textMsg = 'Successed';
        else textMsg = 'Failed';
    } on PlatformException {
        textMsg = 'Failed';
    }

    setState(() {
    _imageViewerResult = textMsg;
    });
}
```
