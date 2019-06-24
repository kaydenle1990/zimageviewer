#import "ZimageviewerPlugin.h"

@interface ZimageviewerPlugin()

#pragma mark - NYTPhotosViewController Declaration
@property (nonatomic, strong) NYTPhotoViewerArrayDataSource *dataSource;
@property (nonatomic, strong) NYTPhotosViewController *photoViewerVC;
@property (nonatomic, strong) FlutterViewController* rootViewController;

@end

@implementation ZimageviewerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"co.izeta.dev/zimageviewer"
            binaryMessenger:[registrar messenger]];
  ZimageviewerPlugin* instance = [[ZimageviewerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  if ([@"displayImageViewer" isEqualToString:call.method]) {
      NSArray *photos = [call.arguments objectForKey:@"photos"];
      NSArray *captions = [call.arguments objectForKey:@"captions"];
      int startIndex = [[call.arguments objectForKey:@"start_position"] intValue];
      
      if ([photos isKindOfClass:[NSArray class]]) {
          self.rootViewController = (FlutterViewController *)[(FlutterAppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController;
          __weak typeof(self) weakSelf = self;
          dispatch_async(dispatch_get_main_queue(), ^{
              [weakSelf displayPhotoViewer:photos rootController:weakSelf.rootViewController captions:captions index:startIndex];
          });
          
          result(@"SUCCESS");
      } else {
          result(@"ERROR");
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - Generate data sources
- (void) displayPhotoViewer:(NSArray *)urls rootController:(UIViewController *)rootVC captions:(NSArray *) captions index:(int) startIndex {
    
    self.dataSource = [self buildDataSourceFromUrls: urls captions: captions];
    self.photoViewerVC = [[NYTPhotosViewController alloc] initWithDataSource:self.dataSource initialPhotoIndex:startIndex delegate:self];
    [rootVC presentViewController:self.photoViewerVC animated:NO completion:nil];
    //[self updateImagesOnPhotosViewController:self.photoViewerVC afterDelayWithDataSource:self.dataSource];
}

- (NYTPhotoViewerArrayDataSource *) buildDataSourceFromUrls:(NSArray *)urls captions:(NSArray *) captions {
    
    NSMutableArray *photos = [NSMutableArray array];
    
    // Create NYTShowViewPhoto
    for (NSUInteger i = 0; i < [urls count]; i++) {
        NYTShowViewPhoto *photo = [NYTShowViewPhoto new];
        photo.attributedCaptionTitle = [self attributedTitleFromString: captions[i]];
        [photos addObject:photo];
        
        // Request load web-image
        NSString *photoUrl = [urls objectAtIndex:i];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:photoUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            // Do nothing
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            photo.image = image;
            [self.photoViewerVC updatePhoto: photo];
        }];
    }
    
    return [NYTPhotoViewerArrayDataSource dataSourceWithPhotos: photos];
}

- (NSAttributedString *)attributedTitleFromString:(NSString *)caption {
    return [[NSAttributedString alloc] initWithString:caption attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
}

- (void)updateImagesOnPhotosViewController:(NYTPhotosViewController *)photosViewController afterDelayWithDataSource:(NYTPhotoViewerArrayDataSource *)dataSource {
    
    if (dataSource != self.dataSource) {
        return;
    }
    
    CGFloat updateImageDelay = 0.25;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(updateImageDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NYTShowViewPhoto *photo in dataSource.photos) {
            if (photo.image) {
                [photosViewController updatePhoto:photo];
            }
        }
    });
}

#pragma mark - Handle NYTPhotosViewControllerDelegate
- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController referenceViewForPhoto:(id <NYTPhoto>)photo {
    return nil;
}

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController loadingViewForPhoto:(id <NYTPhoto>)photo {
    return nil;
}

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController captionViewForPhoto:(id <NYTPhoto>)photo {
    return nil;
}

- (CGFloat)photosViewController:(NYTPhotosViewController *)photosViewController maximumZoomScaleForPhoto:(id <NYTPhoto>)photo {
    return 2.0f;
}

- (NSDictionary *)photosViewController:(NYTPhotosViewController *)photosViewController overlayTitleTextAttributesForPhoto:(id <NYTPhoto>)photo {
    return @{NSForegroundColorAttributeName: [UIColor clearColor]};
}

- (NSString *)photosViewController:(NYTPhotosViewController *)photosViewController titleForPhoto:(id<NYTPhoto>)photo atIndex:(NSInteger)photoIndex totalPhotoCount:(nullable NSNumber *)totalPhotoCount {
    return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)photoIndex+1, (unsigned long)totalPhotoCount.integerValue];
}

- (void)photosViewController:(NYTPhotosViewController *)photosViewController didNavigateToPhoto:(id <NYTPhoto>)photo atIndex:(NSUInteger)photoIndex {
    //NSLog(@"Did Navigate To Photo: %@ identifier: %lu", photo, (unsigned long)photoIndex);
}

- (void)photosViewController:(NYTPhotosViewController *)photosViewController actionCompletedWithActivityType:(NSString *)activityType {
    //NSLog(@"Action Completed With Activity Type: %@", activityType);
}

- (void)photosViewControllerDidDismiss:(NYTPhotosViewController *)photosViewController {
    //NSLog(@"Did Dismiss Photo Viewer: %@", photosViewController);
}

@end
