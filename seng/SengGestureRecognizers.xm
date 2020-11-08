#import "SharedDefs.h"

extern SengSBScreenEdgePanGestureRecognizer *panLeft, *panRight;

%subclass SengSBForceScreenEdgePanGestureRecognizer : SBSwitcherForcePressSystemGestureRecognizer

%new -(CGFloat)cumulativePercentage {
    CGPoint touchPoint = [self locationInView: [UIApplication sharedApplication].keyWindow];
    return touchPoint.x/screenWidth();
}

%new -(long long)projectedCompletionTypeForInterval:(CGFloat)interval {
    CGPoint velocity = [self velocityInView:[UIApplication sharedApplication].keyWindow];
    return [self isEqual:panLeft] ? (velocity.x > 0 ? 1 : -1) : (velocity.x < 0 ? 1 : -1);
}

%end

%subclass SengSBScreenEdgePanGestureRecognizer : SBScreenEdgePanGestureRecognizer

%new -(CGFloat)cumulativePercentage {
    CGPoint touchPoint = [self locationInView: [UIApplication sharedApplication].keyWindow];
    return touchPoint.x/screenWidth();
}

%new -(long long)projectedCompletionTypeForInterval:(CGFloat)interval {
    CGPoint velocity = [self velocityInView:[UIApplication sharedApplication].keyWindow];
    return [self isEqual:panLeft] ? (velocity.x > 0 ? 1 : -1) : (velocity.x < 0 ? 1 : -1);
}

%end

%subclass SengSBForceScreenRightEdgePanGestureRecognizer : SBSwitcherForcePressSystemGestureRecognizer

-(void)setEdges:(UIRectEdge)e {
    %orig(UIRectEdgeRight);
}

%new -(CGFloat)cumulativePercentage {
    CGPoint touchPoint = [self locationInView: [UIApplication sharedApplication].keyWindow];
    return touchPoint.x/screenWidth();
}

%new -(long long)projectedCompletionTypeForInterval:(CGFloat)interval {
    CGPoint velocity = [self velocityInView:[UIApplication sharedApplication].keyWindow];
    return [self isEqual:panLeft] ? (velocity.x > 0 ? 1 : -1) : (velocity.x < 0 ? 1 : -1);
}

%end
