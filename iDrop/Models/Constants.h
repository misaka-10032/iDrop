//
//  Constants.h
//  iDrop
//
//  Created by ronin on 13-11-30.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#ifndef iDrop_Constants_h
#define iDrop_Constants_h

#define nWidthUnits (6)
#define nHeightUnits (6)

//#define ascVelocity (3)
//#define movVelocity (6)
//#define gravity (2)

// (306, 349) in iPhone
// the higher the num, the lower the sensitivity
// 3 in 349
#define ascVelocityInv (250)
// 6 in 306
#define movVelocityInv (100)
#define stgVelocityInv (150)
// 3 in 349
#define gravityInv (300)
#define difficultyChangePoint (12)
#define difficultyChangeRate (1.05)
//#define difficultyChangePoint (1)
//#define difficultyChangeRate (2)

enum Status {START, RESUME, GAMING, PAUSE, RESTART, GAMEOVER};

#endif
