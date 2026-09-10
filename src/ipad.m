#include "book.h"
#include <string.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/CAMetalLayer.h>

@interface BookMetalView : UIView
@property BOOL dirty;
@end

@implementation BookMetalView
+ (Class)layerClass { return [CAMetalLayer class]; }
- (void)layoutSubviews { [super layoutSubviews]; self.dirty = YES; }
@end

@interface BookController : UIViewController <UITextFieldDelegate>
@property BookMetalView *page;
@property UITextField *command;
@property CADisplayLink *displayLink;
@property BOOL initialized;
@end

@implementation BookController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { return UIInterfaceOrientationLandscapeLeft; }
- (UIButton *)button:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button.widthAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return button;
}
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

    self.command = [UITextField new];
    self.command.placeholder = @"Type a command";
    self.command.accessibilityLabel = @"Story command";
    self.command.borderStyle = UITextBorderStyleRoundedRect;
    self.command.autocorrectionType = UITextAutocorrectionTypeNo;
    self.command.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.command.returnKeyType = UIReturnKeyGo;
    self.command.delegate = self;
    [self.command setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *toolbar = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self button:@"Back" action:@selector(back)],
        [self button:@"Text" action:@selector(toggleText)], self.command,
        [self button:@"Go" action:@selector(submit)]]];
    toolbar.spacing = 8;
    toolbar.alignment = UIStackViewAlignmentCenter;
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolbar];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.page.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.page.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [self.page.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [self.page.bottomAnchor constraintEqualToAnchor:toolbar.topAnchor],
        [toolbar.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:12],
        [toolbar.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-12],
        [toolbar.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor],
        [toolbar.heightAnchor constraintEqualToConstant:52],
        [self.command.heightAnchor constraintEqualToConstant:44]
    ]];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    NSString *adventure = [NSBundle.mainBundle objectForInfoDictionaryKey:@"BookAdventure"];
    book_init(NSBundle.mainBundle.resourcePath.fileSystemRepresentation, adventure.UTF8String);
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
    [self becomeFirstResponder];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.displayLink invalidate]; self.displayLink = nil;
}
- (BOOL)canBecomeFirstResponder { return YES; }
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
    if (self.command.isFirstResponder) { [self.command resignFirstResponder]; return; }
    CGPoint point = [gesture locationInView:self.page];
    ui_click(fvec2(point.x,point.y)); self.page.dirty = YES;
}
- (void)pan:(UIPanGestureRecognizer *)gesture
{
    CGPoint delta = [gesture translationInView:self.page];
    ui_scroll(delta.y);
    [gesture setTranslation:CGPointZero inView:self.page]; self.page.dirty = YES;
}
- (void)back { ui_key(UI_KEY_ESCAPE); self.page.dirty = YES; }
- (void)toggleText { ui_key(UI_KEY_TAB); self.page.dirty = YES; }
- (void)submit
{
    if (ui_animating()) return;
    const char *command = (self.command.text ?: @"").UTF8String;
    if (strlen(command) >= MAX_COMMAND) return;
    ui_input(command); ui_key(UI_KEY_ENTER);
    self.command.text = @"";
    [self.command resignFirstResponder]; self.page.dirty = YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)field { (void)field; [self submit]; return YES; }
- (NSArray<UIKeyCommand *> *)keyCommands
{
    return @[
        [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(back)],
        [UIKeyCommand keyCommandWithInput:@"t" modifierFlags:UIKeyModifierCommand action:@selector(toggleText)],
        [UIKeyCommand keyCommandWithInput:@"l" modifierFlags:UIKeyModifierCommand action:@selector(focusCommand)],
        [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(scrollDown)],
        [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(scrollUp)]
    ];
}
- (void)focusCommand { [self.command becomeFirstResponder]; }
- (void)scrollDown { ui_key(UI_KEY_DOWN); self.page.dirty = YES; }
- (void)scrollUp { ui_key(UI_KEY_UP); self.page.dirty = YES; }
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
