//
//  ViewController.m
//  iDrop
//
//  Created by ronin on 13-11-29.
//  Copyright (c) 2013年 ronin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "AppDelegate.h"

#import "ViewObject.h"
#import "Character.h"
#import "Stage.h"
#import "NormalStage.h"
#include "Constants.h"

NSString* const kFaceCascadeName = @"haarcascade_frontalface_alt";
//NSString* const kFaceCascadeName = @"haarcascade_mcs_eyepair_small";
NSString* const kUserDataName = @"userdata";

#ifdef __cplusplus
CascadeClassifier face_cascade;
#endif

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - override
- (void)viewDidLoad {
    [super viewDidLoad];
    // camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:cameraView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.videoCamera.defaultFPS = 20;
    self.videoCamera.grayscaleMode = NO;
    NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:kFaceCascadeName
                                                                ofType:@"xml"];
#ifdef __cplusplus
    if(!face_cascade.load([faceCascadePath UTF8String])) {
        NSLog(@"Could not load face classifier!");
    }
#endif
    
    // responder
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondNotification:)
                                                 name:@"gameState" object:nil];
    [self.startButton addTarget:self action:@selector(onRestartClick) forControlEvents:UIControlEventTouchDown];
    [self.resumeButton addTarget:self action:@selector(onResumeClick) forControlEvents:UIControlEventTouchDown];
    [self.restartButton addTarget:self action:@selector(onRestartClick) forControlEvents:UIControlEventTouchDown];
    [self.pauseButton addTarget:self action:@selector(onPauseClick) forControlEvents:UIControlEventTouchDown];
    
    // show highest score
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kUserDataName
                                                                ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userData = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        highestScore = [[userData valueForKey:@"highestScore"] intValue];
        self.highestScoreLabel.text = [NSString stringWithFormat:@"%d", highestScore];
    }
    currentScore = 0;
    self.currentScoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
    
    // appoint images
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        characterImageName = @"misaka-30x30.jpg";
        normalStageImageName = @"normalStage-100x10.png";
    } else {
        characterImageName = @"misaka-50x50.jpg";
        normalStageImageName = @"normalStage-180x20.png";
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	// Do any additional setup after loading the view, typically from a nib.
    state = START;
    self.menuView.hidden = NO;
    self.startButton.hidden = NO;
    self.resumeButton.hidden = YES;
    self.restartButton.hidden = YES;
    [self.videoCamera start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Protocol CvVideoCameraDelegate
#ifdef __cplusplus
- (void) processImage:(Mat &)image
{
    vector<cv::Rect> faces;
    Mat frame_gray;
    
    cvtColor(image, frame_gray, CV_BGRA2GRAY);
    equalizeHist(frame_gray, frame_gray);
    frame_gray = frame_gray.t();
    
    face_cascade.detectMultiScale(frame_gray, faces, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE,
                                  cv::Size(180, 180), cv::Size(300, 300));
    
    // take care that the image is TRANSPOSED
    int size = faces.size();
    int bound = 8;
    if (size > 0) { // detected
        cv::Rect face = faces[0];
        rectangle(image, cv::Point(face.y, face.x),
                  cv::Point(face.y + face.height, face.x + face.width),
                  cv::Scalar(0,255,255));
        if (face.x+face.width/2 < frame_gray.cols/2-bound)
            direction = RIGHT; // it's flipped! though don't know why
        else if (face.x+face.width/2 > frame_gray.cols/2+bound)
            direction = LEFT;
        else direction = STOP;
    } else {
        direction = STOP;
    }
}
#endif

#pragma mark - responder
- (void)respondNotification:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"gameState"])
    {
        if (state==START) return;
        NSDictionary* userInfo = notification.userInfo;
        state = (Status) [[userInfo objectForKey:@"gameState"] intValue];
        switch (state) {
            case RESUME:
                if (state==START) break;
                self.menuView.hidden = NO;
                self.startButton.hidden = YES;
                self.resumeButton.hidden = NO;
                self.restartButton.hidden = NO;
                break;
            case PAUSE:
                break;
        }
    }
}


- (void)onResumeClick {
    state = GAMING;
    self.menuView.hidden = YES;
    [self dispatchQueue];
}

- (void)onRestartClick {
    state = GAMING;
    self.menuView.hidden = YES;
    [self initScene];
    [self dispatchQueue];
}

- (void)onPauseClick {
    if (state==START || state==GAMEOVER) return;
    state = PAUSE;
    self.menuView.hidden = NO;
    self.startButton.hidden = YES;
    self.resumeButton.hidden = NO;
    self.restartButton.hidden = NO;
    self.greetingText.text = @"Pause";
}

#pragma mark - gameControl
- (void)initScene {
    float width = self.mainView.bounds.size.width;
    float height = self.mainView.bounds.size.height;
    character = [[Character alloc] initWithContainerWidth:width Height:height
                                                selfImage:[UIImage imageNamed:characterImageName] ];
    viewObjects = [[NSMutableArray alloc] init];
    [viewObjects addObject:character];
    for (int i=0; i<nHeightUnits; i++) {
        int y = (i+1) * height / nHeightUnits;
        // TODO: different stages
        NormalStage *normalStage = [[NormalStage alloc] initWithContainerWidth:width Height:height
                                    selfImage:[UIImage imageNamed:normalStageImageName]];
        normalStage.y = y;
        [viewObjects addObject:normalStage];
        if (i==nHeightUnits-1) { // init the character on the last stage
            character.x = normalStage.x + (normalStage.image.size.width-character.image.size.width)/2;
            character.y = normalStage.y - character.image.size.height;
        }
    }
    currentCounter = 0;
}

- (void)updateAll {
    // all move up
    ViewObject *viewObjectToRemove;
    for (ViewObject *viewObject in viewObjects) {
        viewObject.y += viewObject.vy;
        if (viewObject.y>=0) continue;
        viewObjectToRemove = viewObject;
    }
    if (viewObjectToRemove) {
        if ([viewObjectToRemove isKindOfClass:[Stage class]]) {
            // TODO: different stages
            NormalStage *stage = [[NormalStage alloc] initWithContainerWidth:self.mainView.frame.size.width
                                                                      Height:self.mainView.frame.size.height selfImage:[UIImage imageNamed:normalStageImageName]];
            [viewObjects addObject:stage];
        }
        [viewObjects removeObject:viewObjectToRemove];
        viewObjectToRemove = nil;
        currentCounter = (currentCounter+1)%nHeightUnits;
        if (!currentCounter) {
            currentScore++;
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.currentScoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
            });
        }
    }
}

- (void)updateCharacter {
    switch (direction) {
        case STOP:
            character.vx = 0;
            break;
        case LEFT:
            character.vx = -character.vMov;
            break;
        case RIGHT:
            character.vx = character.vMov;
            break;
    }
    character.x += character.vx;
    
    Stage *currStage = nil;
    float miny = 100000; // drop on the first potential stage
    for (ViewObject* stage in viewObjects) {
        if (![stage isKindOfClass:[Stage class]]) continue;
        if ([self isCharacterOnStage:stage] &&
            stage.y < miny) {
            miny = stage.y;
            currStage = stage;
        }
    }
    if (currStage) { // is on stage
        character.vy = currStage.vy;
        character.y = currStage.y - character.image.size.height;
    } else {
        character.vy += character.containerHeight/gravityInv;
    }
    if ([self isCharacterDied])
        [self showGameOver];
}

- (void)showGameOver {
    dispatch_sync( dispatch_get_main_queue(), ^{
        state = GAMEOVER;
        self.menuView.hidden = NO;
        self.resumeButton.hidden = YES;
        self.restartButton.hidden = NO;
        self.startButton.hidden = YES;
//        [self.startButton setTitle:@"Again" forState:UIControlEventTouchDown];
        self.greetingText.text = @"You Die!";
        self.greetingText.hidden = NO;
        if (currentScore > highestScore) {
            self.greetingText.text = @"New Record!";
            highestScore = currentScore;
            self.highestScoreLabel.text = [NSString stringWithFormat:@"%d", highestScore];
            [userData setValue:[NSNumber numberWithInt:highestScore] forKey:@"highestScore"];
            [userData writeToFile:kUserDataName atomically:YES];
        }
        currentScore = 0;
        self.currentScoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
    });
}

- (void)dispatchQueue
{
    dispatch_queue_t queue = dispatch_queue_create("update views", 0);
    __block dispatch_source_t aTimer = CreateDispatchTimer(40ull * NSEC_PER_MSEC,0,queue,^{
        if (state==GAMING) {
            // time-consuming computation
            [self updateAll];
            [self updateCharacter];
            // update ui
            dispatch_async( dispatch_get_main_queue(), ^{
                // ui-update
                [self.mainView setViewObjects:viewObjects];
                [self.mainView setNeedsDisplay];
            });
        } else {
            dispatch_source_cancel(aTimer);
        }
    });
}

dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                       uint64_t leeway,
                                       dispatch_queue_t queue,
                                       dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0),
                                  interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume( timer);
    }
    return timer;
}

#pragma mark - checks

- (bool)isCharacterDied {
    if (character.y<0 ||
        character.y+character.image.size.height > self.mainView.bounds.size.height) return true;
    return false;
}

- (bool)isCharacterOnStage:(Stage*)stage {
    if (character.y+character.image.size.height <= stage.y+1 && // this frame, 1 is disturbance
        character.y+character.image.size.height+character.vy >= stage.y+stage.vy-1 && // next frame
        character.x+character.image.size.width > stage.x &&
        character.x < stage.x+stage.image.size.width) return true;
    return false;
}


@end
