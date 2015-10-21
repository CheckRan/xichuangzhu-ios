//
//  XCZRandomQuoteViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import "XCZWork.h"
#import "XCZWorkDetailViewController.h"
#import "XCZRandomQuoteViewController.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import <ionicons/IonIcons.h>
#import <Masonry.h>
#import <MBProgressHUD.h>
#import <AVOSCloud.h>

@interface XCZRandomQuoteViewController () <XCZQuoteDraggableViewDelegate>

@property (strong, nonatomic) NSMutableArray *quoteViews;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation XCZRandomQuoteViewController

#pragma mark - LifeCycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor colorWithRGBA:0xF2F2F2FF];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSMutableArray *buttons = [NSMutableArray new];
    
    // 刷新
    UIImage *refreshIcon = [IonIcons imageWithIcon:ion_ios_loop_strong size:24 color:[UIColor grayColor]];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithImage:refreshIcon style:UIBarButtonItemStylePlain target:self action:@selector(refreshQuote)];
    [buttons addObject:refreshButton];
    
    // 保存到相册
    UIImage *snapshotIcon = [IonIcons imageWithIcon:ion_ios_albums_outline size:24 color:[UIColor grayColor]];
    UIBarButtonItem *snapshotButton = [[UIBarButtonItem alloc] initWithImage:snapshotIcon style:UIBarButtonItemStylePlain target:self action:@selector(snapshot)];
    [buttons addObject:snapshotButton];
    
    self.navigationItem.rightBarButtonItems = buttons;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationItem.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"摘录";
}

#pragma mark - Layout

- (void)createViews
{
    [self loadQuoteView];
    [self loadQuoteView];
}

#pragma mark - Public Interface

#pragma mark - User Interface

- (void)refreshQuote
{
    [AVAnalytics event:@"refresh_quote"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [(XCZQuoteDraggableView *)[self.quoteViews firstObject] leftClickAction];
}

- (void)snapshot
{
    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    [AVAnalytics event:@"snapshot_quote"];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.hud.labelText = @"保存到相册";
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - XCZQuoteViewDelegate

- (void)quoteViewPressed:(XCZQuote *)quote
{
    UIViewController *controller = [[XCZWorkDetailViewController alloc] initWithWorkId:quote.workId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)quoteViewSwipedLeft:(UIView *)quoteView
{
    [self.quoteViews removeObjectAtIndex:0];
    [self loadQuoteView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)quoteViewSwipedRight:(UIView *)quoteView
{
    [self.quoteViews removeObjectAtIndex:0];
    [self loadQuoteView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Internal Helpers

- (void)loadQuoteView
{
    XCZQuoteDraggableView *quoteView = [[XCZQuoteDraggableView alloc] initWithQuote:[XCZQuote getRandomQuote]];
    quoteView.delegate = self;
    
    if (self.quoteViews.count == 0) {
        [self.view addSubview:quoteView];
    } else {
        [self.view insertSubview:quoteView belowSubview:[self.quoteViews lastObject]];
    }
    
    [quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(self.view).multipliedBy(.8);
    }];
    
    [self.quoteViews addObject:quoteView];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hud.labelText = @"已保存成功";
        self.hud.customView = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_checkmark size:37 color:[UIColor whiteColor]]];
        self.hud.mode = MBProgressHUDModeCustomView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        });
    });
}

#pragma mark - Getters & Setters

- (NSMutableArray *)quoteViews
{
    if (!_quoteViews) {
        _quoteViews = [NSMutableArray new];
    }
    
    return _quoteViews;
}

@end
