//
//  WKAnimatedView.h
//  AnimatedPaths
//
//  Created by 吴珂 on 16/6/1.
//
//

#import <UIKit/UIKit.h>

@interface WKAnimatedView : UIView

@property (nonatomic, strong) CALayer *animationLayer;
@property (nonatomic, strong) CAShapeLayer *pathLayer;

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, copy) NSString *animatedString;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *storkeColor;
@property (nonatomic, assign) CGFloat animatedTime;
@property (nonatomic, assign, readonly) CGFloat stringWidth;


- (void)startAnimationWithFinishBlock:(void (^)(void))finishBlock;
- (void)setupTextLayer;

@end
