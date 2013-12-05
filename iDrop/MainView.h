//
//  MainView.h
//  iDrop
//
//  Created by ronin on 13-12-4.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainView : UIView {
    NSMutableArray *viewObjects;
}

- (void) setViewObjects:(NSMutableArray*)viewObjects;
//- (void)drawImage:(UIImage*)image atPoint:(CGPoint)point;
@end
