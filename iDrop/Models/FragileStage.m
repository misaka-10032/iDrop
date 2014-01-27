//
//  FragileStage.m
//  iDrop
//
//  Created by ronin on 13-12-14.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "FragileStage.h"

@implementation FragileStage

-(id) initWithContainerWidth:(float)width Height:(float)height selfImage:(UIImage*)image speedup:(float)speedup {
    self = [super initWithContainerWidth:width Height:height selfImage:image speedup:speedup];
    self.isExist = true;
    return self;
}


@end
