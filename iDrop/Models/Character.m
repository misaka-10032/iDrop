//
//  Character.m
//  iDrop
//
//  Created by ronin on 13-12-3.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "Character.h"
#import "Constants.h"

@implementation Character

-(id) initWithContainerWidth:(float)width Height:(float)height selfImage:(UIImage*)image speedup:(float)speedup {
    self = [super initWithContainerWidth:width Height:height selfImage:image speedup:speedup];
    self.vMov = self.containerWidth/movVelocityInv*speedup;
    self.gravity = self.containerHeight/gravityInv*sqrt(speedup);
    return self;
}

@end
