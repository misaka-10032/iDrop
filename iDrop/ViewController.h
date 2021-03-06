//
//  ViewController.h
//  iDrop
//
//  Created by ronin on 13-11-29.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "Character.h"
#import "MainView.h"
#import "Constants.h"
using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate> {
    CvVideoCamera *_videoCamera;
    Mat currentFrame;
    IBOutlet UIImageView *cameraView;
    
    cv::Point lastCenter;
    // for tracking
    Mat lastHist;
    cv::Rect lastFace;

    bool isDetected;
    enum {STOP, LEFT, RIGHT} direction;
    enum Status state;
    NSMutableArray *viewObjects;
    Character *character;
    int highestScore;
    int currentScore;
    float currentSpeedup;
    int currentCounter;
    NSMutableDictionary *userData;
    
    NSString* characterImageName;
    NSString* normalStageImageName;
    NSString* movingStageImageName;
    NSString* fragileStageImageName;
    
}

@property (nonatomic, retain) CvVideoCamera *videoCamera;

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UITextView *greetingText;
@property (weak, nonatomic) IBOutlet UITextView *instructionText;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *highestScoreTitle;
@property (weak, nonatomic) IBOutlet UILabel *highestScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentScoreTitle;
@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;
@property (weak, nonatomic) IBOutlet MainView *mainView;
@property (weak, nonatomic) IBOutlet UIView *leftSuggester;
@property (weak, nonatomic) IBOutlet UIView *rightSuggester;
@property (weak, nonatomic) IBOutlet UILabel *notRecognizedSuggester;

@property (weak, nonatomic) UIImage *imageToDraw;
@property (strong, nonatomic) IBOutlet UIView *view;

@end
