//
//  MainView.h
//  iDrop
//
//  Created by ronin on 13-12-4.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Character.h"

@interface MainView : UIView {
    NSMutableArray *viewObjects;
    Character *character;
}

- (void) setViewObjects:(NSMutableArray*)viewObjects;
- (void) setCharacter:(Character*)character;

@property float bound1;
@property float bound2;
@property float pos;

@end
