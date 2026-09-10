#include "book.h"

#import <AppKit/AppKit.h>
#import <QuartzCore/CAMetalLayer.h>

@interface BookView : NSView <NSTextInputClient>
@property BOOL dirty;
@property NSMutableAttributedString *markedText;
@end

@implementation BookView
- (BOOL)isFlipped { return YES; }
- (BOOL)acceptsFirstResponder { return YES; }
- (BOOL)acceptsFirstMouse:(NSEvent *)event { (void)event; return YES; }
- (BOOL)wantsUpdateLayer { return YES; }
- (CALayer *)makeBackingLayer { return [CAMetalLayer layer]; }
- (void)updateLayer { self.dirty = YES; }
- (void)setFrameSize:(NSSize)size { [super setFrameSize:size]; self.dirty = YES; }
- (void)viewDidChangeBackingProperties { [super viewDidChangeBackingProperties]; self.dirty = YES; }
- (void)mouseDown:(NSEvent *)event
{
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    ui_click(fvec2(point.x, point.y));
    self.dirty = YES;
}
- (void)scrollWheel:(NSEvent *)event
{
    ui_scroll(event.scrollingDeltaY * (event.hasPreciseScrollingDeltas ? 1 : 30));
    self.dirty = YES;
}
- (void)keyDown:(NSEvent *)event
{
    NSString *characters = event.charactersIgnoringModifiers;
    if (characters.length && [characters characterAtIndex:0] == NSF5FunctionKey) {
        [self unmarkText];
        ui_key(UI_KEY_RELOAD);
    } else if (!(event.modifierFlags & NSEventModifierFlagCommand)) {
        [self interpretKeyEvents:@[event]];
    }
    self.dirty = YES;
}
- (void)doCommandBySelector:(SEL)selector
{
    if (selector == @selector(insertTab:)) ui_key(UI_KEY_TAB);
    else if (selector == @selector(cancelOperation:)) ui_key(UI_KEY_ESCAPE);
    else if (selector == @selector(insertNewline:)) ui_key(UI_KEY_ENTER);
    else if (selector == @selector(deleteBackward:)) ui_key(UI_KEY_BACKSPACE);
    else if (selector == @selector(moveDown:)) ui_key(UI_KEY_DOWN);
    else if (selector == @selector(moveUp:)) ui_key(UI_KEY_UP);
}
- (void)insertText:(id)string replacementRange:(NSRange)range
{
    (void)range;
    NSString *text = [string isKindOfClass:[NSAttributedString class]] ? [string string] : string;
    ui_input(text.UTF8String);
    [self unmarkText];
    self.dirty = YES;
}
- (void)setMarkedText:(id)string selectedRange:(NSRange)selected replacementRange:(NSRange)replacement
{
    (void)selected; (void)replacement;
    if (ui_animating()) return;
    self.markedText = [string isKindOfClass:[NSAttributedString class]] ?
        [string mutableCopy] : [[NSMutableAttributedString alloc] initWithString:string];
}
- (void)unmarkText { self.markedText = nil; }
- (BOOL)hasMarkedText { return self.markedText.length > 0; }
- (NSRange)markedRange { return self.hasMarkedText ? NSMakeRange(0, self.markedText.length) : NSMakeRange(NSNotFound, 0); }
- (NSRange)selectedRange { return NSMakeRange(0, 0); }
- (NSArray<NSAttributedStringKey> *)validAttributesForMarkedText { return @[]; }
- (NSAttributedString *)attributedSubstringForProposedRange:(NSRange)range actualRange:(NSRangePointer)actual
{
    (void)range;
    if (actual) *actual = NSMakeRange(NSNotFound, 0);
    return nil;
}
- (NSUInteger)characterIndexForPoint:(NSPoint)point { (void)point; return NSNotFound; }
- (NSRect)firstRectForCharacterRange:(NSRange)range actualRange:(NSRangePointer)actual
{
    if (actual) *actual = range;
    NSRect prompt = NSMakeRect(32, self.bounds.size.height - 40, 1, 32);
    return [self.window convertRectToScreen:[self convertRect:prompt toView:nil]];
}
@end

@interface BookApplication : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property NSWindow *window;
@property BookView *view;
@property NSTimer *timer;
@property BOOL smoke;
@property NSString *screenshot;
@property double preview;
@property int frames, missedFrames;
@end

@implementation BookApplication
- (void)stop
{
    [self.timer invalidate];
    [NSApp stop:nil];
    /* Wake the event loop so closing the last window also returns from run. */
    [NSApp postEvent:[NSEvent otherEventWithType:NSEventTypeApplicationDefined location:NSZeroPoint
        modifierFlags:0 timestamp:0 windowNumber:0 context:nil subtype:0 data1:0 data2:0] atStart:NO];
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    (void)sender; [self stop]; return NSTerminateCancel;
}
- (void)windowWillClose:(NSNotification *)notification { (void)notification; [self stop]; }
- (void)windowDidResize:(NSNotification *)notification { (void)notification; self.view.dirty = YES; }
- (void)windowDidChangeBackingProperties:(NSNotification *)notification { (void)notification; self.view.dirty = YES; }
- (void)windowDidDeminiaturize:(NSNotification *)notification { (void)notification; self.view.dirty = YES; }
- (void)windowDidChangeOcclusionState:(NSNotification *)notification { (void)notification; self.view.dirty = YES; }
- (void)tick:(NSTimer *)timer
{
    (void)timer;
    @autoreleasepool {
        if (!(self.view.dirty || self.smoke || ui_animating())) return;
        if (self.window.miniaturized) return;
        NSSize size = self.view.bounds.size;
        if (!renderer_begin(fsize2_round(fsize2(size.width, size.height)), self.window.backingScaleFactor)) {
            if (self.smoke && ++self.missedFrames >= 3) fail("cannot acquire Metal drawable for smoke capture");
            return;
        }
        ui_draw();
        if (self.screenshot && !renderer_screenshot(self.screenshot.fileSystemRepresentation))
            fail("cannot write screenshot");
        renderer_present();
        self.view.dirty = NO;
        if (self.smoke && self.frames == 0 && self.preview >= 0) ui_preview(self.preview);
        if (self.smoke && ++self.frames >= 3) [self stop];
    }
}
@end

void ui_run(bool smoke, const char *screenshot, double smoke_transition)
{
    @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        BookApplication *app = [BookApplication new];
        app.smoke = smoke;
        app.preview = smoke_transition;
        app.screenshot = screenshot ? [NSString stringWithUTF8String:screenshot] : nil;
        NSApp.delegate = app;
        NSMenu *menu = [NSMenu new];
        NSMenuItem *applicationItem = [NSMenuItem new];
        [menu addItem:applicationItem];
        NSMenu *applicationMenu = [[NSMenu alloc] initWithTitle:@"Book"];
        [applicationMenu addItemWithTitle:@"Quit Book" action:@selector(terminate:) keyEquivalent:@"q"];
        applicationItem.submenu = applicationMenu;
        NSMenuItem *windowItem = [NSMenuItem new];
        [menu addItem:windowItem];
        NSMenu *windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
        [windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
        [windowMenu addItemWithTitle:@"Zoom" action:@selector(performZoom:) keyEquivalent:@""];
        [windowMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
        windowItem.submenu = windowMenu;
        NSApp.mainMenu = menu;
        NSApp.windowsMenu = windowMenu;
        app.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, UI_WIDTH, UI_HEIGHT)
            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
            backing:NSBackingStoreBuffered defer:NO];
        app.window.title = @"Book";
        app.window.releasedWhenClosed = NO;
        app.window.contentMinSize = NSMakeSize(480, 360);
        app.window.delegate = app;
        app.view = [[BookView alloc] initWithFrame:NSMakeRect(0, 0, UI_WIDTH, UI_HEIGHT)];
        app.view.wantsLayer = YES;
        app.view.dirty = YES;
        app.window.contentView = app.view;
        [app.window makeFirstResponder:app.view];
        if (!renderer_init((__bridge void *)app.view.layer)) fail("cannot initialize Metal");
        ui_init();
        [app.window center];
        [app.window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        app.timer = [NSTimer timerWithTimeInterval:1.0 / 60 target:app selector:@selector(tick:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:app.timer forMode:NSRunLoopCommonModes];
        [NSApp run];
        [app.timer invalidate];
        text_shutdown();
        renderer_shutdown();
        app.window.delegate = nil;
        [app.window close];
        NSApp.delegate = nil;
    }
}
