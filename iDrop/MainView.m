//
//  MainView.m
//  iDrop
//
//  Created by ronin on 13-12-4.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "MainView.h"
#import "ViewObject.h"

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setViewObjects:(NSMutableArray *)_viewObjects {
    viewObjects = _viewObjects;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    for (ViewObject *viewObject in viewObjects) {
        CGRect rect = CGRectMake(0.0, 0.0, viewObject.image.size.width, viewObject.image.size.height);
        CGPoint point = CGPointMake(viewObject.x, viewObject.y);
        [viewObject.image drawAtPoint:point];
    }
}



@end
