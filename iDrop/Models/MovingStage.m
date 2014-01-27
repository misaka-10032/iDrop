//
//  MovingStage.m
//  iDrop
//
//  Created by ronin on 13-12-14.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "MovingStage.h"
#import "Constants.h"

@implementation MovingStage
-(id) initWithContainerWidth:(float)width Height:(float)height selfImage:(UIImage*)image speedup:(float)speedup {
    self = [super initWithContainerWidth:width Height:height selfImage:image speedup:speedup];
    self.speed = width/stgVelocityInv*speedup;
    self.vx = (arc4random()%2) ? -self.speed : self.speed;
    return self;
}
@end
