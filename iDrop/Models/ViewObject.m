//
//  ViewObject.m
//  iDrop
//
//  Created by ronin on 13-11-30.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "ViewObject.h"
#include "Constants.h"

@implementation ViewObject

-(id) initWithContainerWidth:(float)width Height:(float)height
                   selfImage:(UIImage*) image{
    self = [super init];
    if (self) {
        self.containerWidth = width;
        self.containerHeight = height;
        self.image = image;
        self.x = (self.containerWidth-image.size.width) * (arc4random()%nWidthUnits) / (nWidthUnits-1);
        self.y = height;
        self.vx = 0;
        self.vy = - self.containerHeight/ascVelocityInv;
        self.isExist = true;
    }
    return self;
}

@end
