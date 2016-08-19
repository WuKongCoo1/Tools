//
//  WKAnimatedView.m
//  AnimatedPaths
//
//  Created by 吴珂 on 16/6/1.
//
//

#import "WKAnimatedView.h"
#import <CoreText/CoreText.h>

typedef void (^FinishBLock)(void);

@implementation WKAnimatedView
{
    CGFloat _stringWidth;
    FinishBLock _finishBlock;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    _fontName = @"Helvetica-Bold";//Helvetica-Bold
    _fontSize = 40.f;
    _animatedString = @"我就是这么吊asdasd a";
    _storkeColor = [UIColor cyanColor];
    _animatedTime = 5.f;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
//        [self setupTextLayer];
    }
}

- (void) setupTextLayer
{
    if (self.pathLayer != nil) {
        
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
        
    }
    
    // Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)_fontName, _fontSize, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:_animatedString
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    
    pathLayer.bounds = CGRectMake(0, 0, 100.f, 100.f);
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = _storkeColor.CGColor;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    
    CGRect boudingF = CGPathGetBoundingBox(path.CGPath);
    _stringWidth = CGRectGetWidth(boudingF);
    
    pathLayer.frame = self.bounds;
    
    [self.layer addSublayer:pathLayer];
    self.pathLayer = pathLayer;
}

- (void)startAnimationWithFinishBlock:(void (^)(void))finishBlock
{
    [self.pathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = _animatedTime;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
     pathAnimation.delegate = self;
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    _finishBlock = finishBlock;
    
}

- (CGFloat)stringWidth
{
    [self setupTextLayer];
    return _stringWidth;
}

#pragma mark - Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    CALayer *layer = [anim valueForKey:@"strokeEnd"];
    
    if (_finishBlock) {
        _finishBlock();
    }
}



@end
