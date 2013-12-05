//
//  ViewObject.h
//  iDrop
//
//  Created by ronin on 13-11-30.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewObject : NSObject

@property float x;
@property float y;
@property float vx;
@property float vy;
@property bool isExist;
@property (strong, nonatomic) UIImage *image;
@property float containerWidth;
@property float containerHeight;

-(id) initWithContainerWidth:(float)width Height:(float)height
                   selfImage:(UIImage*) image;
@end