//
//  MainView.m
//  iDrop
//
//  Created by ronin on 13-12-4.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import "MainView.h"
#import "ViewObject.h"
#import "FragileStage.h"
#import "Character.h"

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setViewObjects:(NSMutableArray*)_viewObjects {
    viewObjects = _viewObjects;
}

- (void)setCharacter:(Character *)_character {
    character = _character;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Drawing code
    for (ViewObject *viewObject in viewObjects) {
        if ([viewObject isMemberOfClass:[FragileStage class]] &&
            !((FragileStage*)viewObject).isExist) continue;
        // draw all
        CGPoint point = CGPointMake(viewObject.x, viewObject.y);
        [viewObject.image drawAtPoint:point];
        // draw suggesting lines
        CGSize size = character.image.size;
        CGContextSetRGBStrokeColor(context, 1, 1, 0, 1);
        CGContextSetLineWidth(context, 2);
        CGContextMoveToPoint(context, character.x+self.bound1*size.width, character.y);
        CGContextAddLineToPoint(context, character.x+self.bound1*size.width, character.y+size.height);
        CGContextMoveToPoint(context, character.x+self.bound2*size.width, character.y);
        CGContextAddLineToPoint(context, character.x+self.bound2*size.width, character.y+size.height);
        CGContextStrokePath(context);
        CGContextSetRGBStrokeColor(context, 1, 128.0/255, 1, 1);
        CGContextMoveToPoint(context, character.x+(1.0-self.pos)*size.width, character.y);
        CGContextAddLineToPoint(context, character.x+(1.0-self.pos)*size.width, character.y+size.height);
        CGContextStrokePath(context);
    }
}



@end
