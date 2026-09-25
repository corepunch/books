#include "book.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/CAMetalLayer.h>

@interface BookMetalView : UIView
@property BOOL dirty;
@end

@implementation BookMetalView
+ (Class)layerClass { return [CAMetalLayer class]; }
- (void)layoutSubviews { [super layoutSubviews]; self.dirty = YES; }
@end

@interface BookController : UIViewController
@property BookMetalView *page;
@property CADisplayLink *displayLink;
@property BOOL initialized;
@end

@implementation BookController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { return UIInterfaceOrientationLandscapeLeft; }
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:.13 green:.11 blue:.09 alpha:1];
    self.page = [BookMetalView new];
    self.page.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.page];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.page addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.allowedScrollTypesMask = UIScrollTypeMaskAll;
    [self.page addGestureRecognizer:pan];
    [tap requireGestureRecognizerToFail:pan];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.page.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.page.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [self.page.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [self.page.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor]
    ]];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    book_init(NSBundle.mainBundle.resourcePath.fileSystemRepresentation);
    if (!renderer_init((__bridge void *)self.page.layer)) fail("cannot initialize Metal");
    ui_init();
    self.initialized = YES;
    self.page.dirty = YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.displayLink invalidate]; self.displayLink = nil;
}
- (void)tick:(CADisplayLink *)link
{
    (void)link;
    if (self.view.window.windowScene.activationState != UISceneActivationStateForegroundActive ||
        !(self.page.dirty || ui_animating())) return;
    CGSize size = self.page.bounds.size;
    if (!renderer_begin(fsize2_round(fsize2(size.width,size.height)), self.view.window.screen.scale)) return;
    ui_draw();
    renderer_present();
    self.page.dirty = NO;
}
- (void)tap:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.page];
    ui_click(fvec2(point.x,point.y)); self.page.dirty = YES;
}
- (void)pan:(UIPanGestureRecognizer *)gesture
{
    CGPoint delta = [gesture translationInView:self.page];
    ui_scroll(delta.y);
    [gesture setTranslation:CGPointZero inView:self.page]; self.page.dirty = YES;
}
- (void)dealloc
{
    if (self.initialized) { text_shutdown(); renderer_shutdown(); scene_shutdown(); book_shutdown(); }
}
@end

@interface BookScene : UIResponder <UIWindowSceneDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation BookScene
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)options
{
    (void)session; (void)options;
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = [BookController new];
    [self.window makeKeyAndVisible];
}
- (void)sceneDidBecomeActive:(UIScene *)scene
{
    (void)scene;
    BookController *controller = (BookController *)self.window.rootViewController;
    controller.page.dirty = YES;
}
@end

@interface BookApplication : UIResponder <UIApplicationDelegate>
@end
@implementation BookApplication
@end

int main(int argc,char **argv)
{
    @autoreleasepool { return UIApplicationMain(argc,argv,nil,NSStringFromClass(BookApplication.class)); }
}
