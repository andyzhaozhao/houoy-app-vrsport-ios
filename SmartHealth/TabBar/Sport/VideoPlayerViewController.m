#import <UIKit/UIKit.h>

#import "VideoPlayerViewController.h"

#import "GVRVideoView.h"
#import "SportCollectionViewCell.h"

@interface VideoPlayerViewController () <GVRVideoViewDelegate>
@property(nonatomic) IBOutlet GVRVideoView *videoView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;


@end

@implementation VideoPlayerViewController {
  BOOL _isPaused;
}

- (instancetype)init {
  self = [super initWithNibName:nil bundle:nil];
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
  // Build source attribution text view.

  _videoView.delegate = self;
  _videoView.enableFullscreenButton = YES;
  _videoView.enableCardboardButton = YES;
  _videoView.enableTouchTracking = YES;

  _isPaused = YES;

  // Load the sample 360 video, which is of type stereo-over-under.
  NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"congo" ofType:@"mp4"];
  [_videoView loadFromUrl:[[NSURL alloc] initFileURLWithPath:videoPath]
                   ofType:kGVRVideoTypeStereoOverUnder];

  // Alternatively, this is how to load a video from a URL:
  //NSURL *videoURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/googlevr/gvr-ios-sdk"
  //                                       @"/master/Samples/VideoWidgetDemo/resources/congo.mp4"];
  //[_videoView loadFromUrl:videoURL ofType:kGVRVideoTypeStereoOverUnder];

}

-( void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionViewLayout.itemSize = CGSizeMake(self.view.frame.size.width, 250);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (!_isPaused) {
        [_videoView pause];
    }
}
#pragma mark - GVRVideoViewDelegate

- (void)widgetViewDidTap:(GVRWidgetView *)widgetView {
  if (_isPaused) {
    [_videoView play];
  } else {
    [_videoView pause];
  }
  _isPaused = !_isPaused;
}

- (void)widgetView:(GVRWidgetView *)widgetView didLoadContent:(id)content {
  NSLog(@"Finished loading video");
  [_videoView play];
  _isPaused = NO;
}

- (void)widgetView:(GVRWidgetView *)widgetView
    didFailToLoadContent:(id)content
        withErrorMessage:(NSString *)errorMessage {
  NSLog(@"Failed to load video: %@", errorMessage);
}

- (void)videoView:(GVRVideoView*)videoView didUpdatePosition:(NSTimeInterval)position {
  // Loop the video when it reaches the end.
  if (position == videoView.duration) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确定结束本次运动！" preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

      }];
      UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"shareSport" sender:nil];
      }];
      [alertController addAction:cancelAction];
      [alertController addAction:okAction];
      [self presentViewController:alertController animated:YES completion:nil];
  }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SportCollectionViewCell * cell = (SportCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"sport_cell" forIndexPath:indexPath];
    [cell loadImage];
    return cell;
}
@end
