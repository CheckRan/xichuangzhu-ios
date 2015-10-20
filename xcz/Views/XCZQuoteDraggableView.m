//
//  XCZXCZQuoteDraggableView.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteDraggableView.h"

#define ACTION_MARGIN 120 // distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 // how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 // upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 // the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 // strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 // Higher = stronger rotation angle

@interface XCZQuoteDraggableView ()

@property (nonatomic) CGFloat xFromCenter;
@property (nonatomic) CGFloat yFromCenter;
@property (nonatomic) CGPoint originalPoint;

@end

@implementation XCZQuoteDraggableView

@dynamic delegate;

- (instancetype)initWithQuote:(XCZQuote *)quote
{
    self = [super initWithQuote:quote];
    if (!self) {
        return nil;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
    return self;
}

- (void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.xFromCenter = [gestureRecognizer translationInView:self].x;
    self.yFromCenter = [gestureRecognizer translationInView:self].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            
        case UIGestureRecognizerStateChanged:{
            // dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(self.xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            // degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            // amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            // move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + self.xFromCenter, self.originalPoint.y + self.yFromCenter);
            
            // rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            // scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            // apply transformations
            self.transform = scaleTransform;
            //            [self updateOverlay:xFromCenter];
            
            break;
        };
            
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
    
}

- (void)afterSwipeAction
{
    if (self.xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (self.xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                         }];
    }
}

- (void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2 * self.yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(quoteViewSwipedLeft:)]) {
                             [self.delegate quoteViewSwipedLeft:self];
                         }
                     }];
}

- (void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(quoteViewSwipedRight:)]) {
                             [self.delegate quoteViewSwipedRight:self];
                         }
                     }];
}

- (void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y - 50);
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(quoteViewSwipedLeft:)]) {
                             [self.delegate quoteViewSwipedLeft:self];
                         }
                     }];
}

- (void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y - 50);
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(quoteViewSwipedRight:)]) {
                             [self.delegate quoteViewSwipedRight:self];
                         }
                     }];
}

@end