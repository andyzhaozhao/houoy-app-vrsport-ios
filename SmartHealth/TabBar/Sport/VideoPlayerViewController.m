#import <UIKit/UIKit.h>

#import "VideoPlayerViewController.h"
#import <UtoVRPlayer/UtoVRPlayer.h>
#import "SportCollectionViewCell.h"
#import "SmartHealth-Swift.h"
#import "HCKCommunicationGlobal.h"

@interface VideoPlayerViewController () <UVPlayerDelegate>
@property (nonatomic,strong) UVPlayer *player;
@property (nonatomic,strong) NSMutableArray *itemsToPlay;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property Boolean isStartPlayer;
@property (nonatomic,strong) SHVideoresultDataModel *model;
@property NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSMutableDictionary *heartsDictionary;
@property (nonatomic,strong) NSMutableDictionary *stepsDictionary;
@property (nonatomic,strong) SHDataApi *dataApi;
@end

@implementation VideoPlayerViewController {
}

#pragma mark - Getters
-(UVPlayer *)player {
    if (_player == nil) {
        _player = [[UVPlayer alloc] initWithConfiguration:nil];
        _player.delegate = self;
    }
    return _player;
}

-(NSMutableArray *)itemsToPlay {
    if (_itemsToPlay == nil) {
        _itemsToPlay = [[NSMutableArray alloc]init];
    }
    return _itemsToPlay;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (instancetype)init {
  self = [super initWithNibName:nil bundle:nil];
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
    self.model = (SHVideoresultDataModel *)self.modelObject;
    self.dataApi = [[SHDataApi alloc] init];
    self.heartsDictionary = [[NSMutableDictionary alloc] init];
    self.stepsDictionary = [[NSMutableDictionary alloc] init];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd-HH-mm";
    NSMutableArray *items = [NSMutableArray array];
    NSString *preVideoPath = [[NSBundle mainBundle] pathForResource:@"wu" ofType:@"mp4"];
    UVPlayerItem *itemPre = [[UVPlayerItem alloc] initWithPath:preVideoPath type:UVPlayerItemTypeLocalVideo];
    UVPlayerItem *item1 = [[UVPlayerItem alloc] initWithPath:self.localPath type:UVPlayerItemTypeLocalVideo];

    [items addObject:itemPre];
    [items addObject:item1];
    [self setItemsToPlay:items];
    
    self.descriptionLabel.text = self.model.video_desc;
     //将播放视图添加到当前界面
    [self.playerView addSubview:self.player.playerView];
    if (self.player.viewStyle == UVPlayerViewStyleDefault) {
        //默认界面。设置竖屏返回按钮动作
        [self.player setPortraitBackButtonTarget:self selector:@selector(back:)];
    }
    [self.player rightBarButtonItems];
    //把要播放的内容添加到播放器
    [self.player appendItems:self.itemsToPlay];
    self.player.gyroscopeEnabled = true;
    self.player.duralScreenEnabled = true;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //调整frame。你可以使用任何其它布局方式保证播放视图是你期望的大小
    CGRect frame;

    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
        frame = CGRectMake(0, 0, self.playerView.bounds.size.width, self.playerView.bounds.size.height );
    }
    self.player.playerView.frame = frame;
    [self.player.playerView setNeedsLayout];
    [self.player.playerView layoutIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //退出时不要忘记调用prepareToRelease
    [self.player prepareToRelease];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Helper
-(void)back:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"shareSport"]) {
        ShareViewController *share = (ShareViewController* )segue.destinationViewController;
        share.selectModel = self.model;
    }
}

#pragma mark - PanoPlayerDelegate
-(void)player:(UVPlayer *)player willBeginPlayItem:(UVPlayerItem *)item {
    if (player.viewStyle == UVPlayerViewStyleDefault) {
        //设置横屏显示的title为当前播放资源的路径。你可以设置为其它的任何内容
        [player setTitleText:self.model.video_name];
    }
    self.isStartPlayer = false;
    if (self.itemsToPlay.lastObject == item ){
        NSDate *date = [NSDate date];
        self.model.videoStartTime = [self.dateFormatter stringFromDate:date];
        self.isStartPlayer = YES;
    }
}

- (void)player:(UVPlayer *)player playingTimeDidChanged:(Float64)newTime {
    if (self.isStartPlayer){
        [self sendDataToAPi];
    }
}

- (void)sendDataToAPi {
    NSDate *date = [NSDate date];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    NSLog(@"%@", dateString);
    
    if([self.heartsDictionary objectForKey:dateString] == nil){
        SHHeartRateDataModel *heartmodel = [self.dataApi createHeartModelWithData:nil];
        [self.heartsDictionary setObject:heartmodel forKey:dateString];
        [HCKPeripheralManager.sharedPeripheralManager requestPeripheralLatestHeartRateDataWithTime:dateString successBlock:^(id returnData) {
//            SHHeartRateDataModel *heartmodel = [self.dataApi createHeartModelWithData:returnData];
//            [self.dataApi sendHeartSportDataWithModel:heartmodel];
            [self.dataApi sendStepSportDataWithModel:nil videoModel:self.model];
            [self.view makeToast:returnData];
            NSLog(@"returnData %@", returnData);
        } failedBlock:^(NSError *error) {
            NSLog(@"error %@", error.debugDescription);
        }];
    }
    
    if([self.stepsDictionary objectForKey:dateString] == nil){
        SHStepDataModel *stepModel = [self.dataApi createStepModelWithData:nil];
        [self.stepsDictionary setObject:stepModel forKey:dateString];
        [HCKPeripheralManager.sharedPeripheralManager requestPeripheralLatestStepDataWithTime:dateString successBlock:^(id returnData) {
//            SHStepDataModel *stepModel = [self.dataApi createStepModelWithData:returnData];
//            [self.dataApi sendStepSportDataWithModel:stepModel];
            
            [self.view makeToast:returnData];
            NSLog(@"returnData %@", returnData);
        } failedBlock:^(NSError *error) {
            NSLog(@"error %@", error.debugDescription);
        }];
    }
}

-(void)playerFinished:(UVPlayer *)player{
    [self playOver];
    //[self.player replayLast];
    //[self.player pause];
}

- (void)playOver{
    NSDate *date = [NSDate date];
    self.model.videoEndTime = [self.dateFormatter stringFromDate:date];
    self.isStartPlayer = NO;
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
@end
