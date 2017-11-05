#import <UIKit/UIKit.h>

#import "VideoPlayerViewController.h"
#import <UtoVRPlayer/UtoVRPlayer.h>
#import "SportCollectionViewCell.h"
#import "SmartHealth-Swift.h"

@interface VideoPlayerViewController () <UVPlayerDelegate>
@property (nonatomic,strong) UVPlayer *player;
@property (nonatomic,strong) NSMutableArray *itemsToPlay;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic,strong) SHVideoresultDataModel *model;

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
    //把要播放的内容添加到播放器
    [self.player appendItems:self.itemsToPlay];
    [self.player pause];
}

-( void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //调整frame。你可以使用任何其它布局方式保证播放视图是你期望的大小
    CGRect frame;
    
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        self.navigationController.navigationBarHidden = YES;
        frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
        self.navigationController.navigationBarHidden = NO;
        frame = CGRectMake(0, 0, self.playerView.bounds.size.width, self.playerView.bounds.size.height );
    }
    
    self.player.playerView.frame = frame;

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //退出时不要忘记调用prepareToRelease
    [self.player prepareToRelease];

}
#pragma mark - Helper

-(void)back:(UIButton*)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你好" message:@"你可以点击我完成退出页面等操作" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
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
}

-(void)playerFinished:(UVPlayer *)player{
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
