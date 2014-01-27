//
//  Stage.h
//  iDrop
//
//  Created by ronin on 13-11-30.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewObject.h"

@interface Stage : ViewObject
-(id) initWithContainerWidth:(float)width Height:(float)height selfImage:(UIImage*)image speedup:(float)speedup;
@end
