//
//  Character.h
//  iDrop
//
//  Created by ronin on 13-12-3.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "ViewObject.h"

@interface Character : ViewObject
@property float vMov;
@property float gravity;
-(id) initWithContainerWidth:(float)width Height:(float)height selfImage:(UIImage*)image speedup:(float)speedup;
@end
