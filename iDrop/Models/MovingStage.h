//
//  MovingStage.h
//  iDrop
//
//  Created by ronin on 13-12-14.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "Stage.h"

@interface MovingStage : Stage
@property CGFloat speed;
-(id) initWithContainerWidth:(float)width Height:(float)height selfImage:(UIImage*)image speedup:(float)speedup;
@end
