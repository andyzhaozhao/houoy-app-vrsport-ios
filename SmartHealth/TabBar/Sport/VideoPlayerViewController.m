#import <UIKit/UIKit.h>

#import "VideoPlayerViewController.h"
#import <UtoVRPlayer/UtoVRPlayer.h>

#import "SportCollectionViewCell.h"

@interface VideoPlayerViewController () <UVPlayerDelegate>
@property (nonatomic,strong) UVPlayer *player;
@property (nonatomic,strong) NSMutableArray *itemsToPlay;
@property (weak, nonatomic) IBOutlet UIView *playerView;

@property (nonatomic,strong) NSString *localPath;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;


@end

@implementation VideoPlayerViewController {
}

-(NSString *)localPath {
    if (_localPath == nil) {
        _localPath = [[NSBundle mainBundle] pathForResource:@"wu" ofType:@"mp4"];
    }
    return _localPath;
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



- (instancetype)init {
  self = [super initWithNibName:nil bundle:nil];
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    NSMutableArray *items = [NSMutableArray array];
    UVPlayerItem *item1 = [[UVPlayerItem alloc] initWithPath:self.localPath type:UVPlayerItemTypeLocalVideo];
    [items addObject:item1];
    [self setItemsToPlay:items];
    
    
    //将播放视图添加到当前界面
    [self.playerView addSubview:self.player.playerView];
    
    if (self.player.viewStyle == UVPlayerViewStyleDefault) {
        //默认界面。设置竖屏返回按钮动作
        [self.player setPortraitBackButtonTarget:self selector:@selector(back:)];
    }
    
    //把要播放的内容添加到播放器
    [self.player appendItems:self.itemsToPlay];


  // Load the sample 360 video, which is of type stereo-over-under.
  //NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"congo" ofType:@"mp4"];

}

-( void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionViewLayout.itemSize = CGSizeMake(self.view.frame.size.width, 250);
    
    
    //调整frame。你可以使用任何其它布局方式保证播放视图是你期望的大小
    CGRect frame;
    
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
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

#pragma mark - PanoPlayerDelegate
-(void)player:(UVPlayer *)player willBeginPlayItem:(UVPlayerItem *)item {
    if (player.viewStyle == UVPlayerViewStyleDefault) {
        //设置横屏显示的title为当前播放资源的路径。你可以设置为其它的任何内容
        [player setTitleText:item.path];
    }
}

-(void)player:(UVPlayer*)player finishedPlayingItem:(UVPlayerItem*)item{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确定结束本次运动！" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.player replayLast ];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"shareSport" sender:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
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
