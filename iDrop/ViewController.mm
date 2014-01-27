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
#import "MovingStage.h"
#import "FragileStage.h"
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
    
    // responders
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondNotification:)
                                                 name:@"gameState" object:nil];
    [self.startButton addTarget:self action:@selector(onRestartClick) forControlEvents:UIControlEventTouchDown];
    [self.resumeButton addTarget:self action:@selector(onResumeClick) forControlEvents:UIControlEventTouchDown];
    [self.restartButton addTarget:self action:@selector(onRestartClick) forControlEvents:UIControlEventTouchDown];
    [self.pauseButton addTarget:self action:@selector(onPauseClick) forControlEvents:UIControlEventTouchDown];
    [self.shareButton addTarget:self action:@selector(onShareClick) forControlEvents:UIControlEventTouchDown];
    
    // show highest score
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kUserDataName
                                                                ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userData = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        highestScore = [[userData valueForKey:@"highestScore"] intValue];
        self.highestScoreLabel.text = [NSString stringWithFormat:@"%d", highestScore];
    }
    currentScore = 0;
    currentSpeedup = 1;
    self.currentScoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
    
    // assign images
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        characterImageName = @"misaka-30x30.png";
        normalStageImageName = @"normalStage-100x10.png";
        movingStageImageName = @"normalStage-100x10.png";
        fragileStageImageName = @"fragileStage-100x10.png";
    } else {
        characterImageName = @"misaka-60x60.png";
        normalStageImageName = @"normalStage-200x20.png";
        movingStageImageName = @"normalStage-200x20.png";
        fragileStageImageName = @"fragileStage-200x20.png";
    }
    
    // set background
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-319x510.jpg"]]];
    
    // set instructions to English, if not in China
//    NSLog(@"%s", ((NSString*)[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]).UTF8String);
    if([[self currentLanguage] compare:@"zh-Hans" options:NSCaseInsensitiveSearch]==NSOrderedSame || [[self currentLanguage] compare:@"zh-Hant" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
//        lang = @"zh";
        // nothing to be done
        
    } else {
//        lang = @"en";
        self.instructionText.text = @"Get FAMILIAR with control BEFORE playing using the PREVIEW window at the top-left corner. Adjust distance, angle to stablize recognition. Control the purple line inside/outside the yellow bounds. KEEP RECOGNIZED! Better recognition if glasses are put off.";
    }
    
}

-(NSString*)currentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    return currentLang;
}

//+ (NSString *)getCountryCode
//{
//    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
//}
//
//+ (NSString *)getLanguageCode
//{
//    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
//}

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
    Mat image_t(image.rows, image.cols, image.type());
    Mat frame_gray;
    
    // transpose for processing
    // i.e. image for showing
    // image_t for processing
    int ch1[] = {0,3, 1,2, 2,1, 3,0};
    mixChannels(&image, 1, &image_t, 1, ch1, 4);
    image_t = image_t.t();
    
    // prepare for detecting
    cvtColor(image_t, frame_gray, CV_BGRA2GRAY);    
    equalizeHist(frame_gray, frame_gray);
    
    // prepare for tracking
    Mat hsv, hue, mask;
    int smin = 30, vmin = 10, vmax = 256;
    int hsize = 16;
    float hranges[] = {0, 180};
    const float* phranges = hranges;
    cvtColor(image_t, hsv, CV_BGR2HSV);
    inRange(hsv, Scalar(0, smin, MIN(vmin,vmax)),
            Scalar(180, 256, MAX(vmin, vmax)), mask);
    int ch[] = {0, 0};
    hue.create(hsv.size(), hsv.depth());
    mixChannels(&hsv, 1, &hue, 1, ch, 1);
    // convert to SHOW mode
//    mask = mask.t();
//    hue = hue.t(); 
    
    // detect!
    face_cascade.detectMultiScale(frame_gray, faces, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE,
                                  cv::Size(120, 120), cv::Size(300, 300));
    
    // take the transposed as SHOW coordinate, used to judge
    // take the original as IMAGE coordinate
    int size = faces.size();
    int bound = 16;
    cv::Point center;
    if (size > 0) { // detected
        isDetected = true;
        cv::Rect face = faces[0]; // choose only the first face detected
        cv::Rect faceInImage = cv::Rect(face.y, face.x, face.height, face.width);
        // draw rect
        rectangle(image, faceInImage, cv::Scalar(255,128,255,255), 3);
        center = cv::Point(face.x + face.width/2,
                           face.y + face.height/2);
        
        // prepare for tracking
        lastFace = face;
        Mat roi(hue, face);
        Mat maskroi(mask, face);
        calcHist(&roi, 1, 0, maskroi, lastHist, 1, &hsize, &phranges);
        normalize(lastHist, lastHist, 0, 255, CV_MINMAX);
        
    } else { // not detected
        isDetected = false;
        if (lastFace.area() > 0) { // only track when last face exists
            // try tracking
            Mat backproj;
            calcBackProject(&hue, 1, 0, lastHist, backproj, &phranges);
            backproj &= mask;
            RotatedRect trackBox = CamShift(backproj, lastFace, TermCriteria( CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 10, 1 ));
            RotatedRect trackBoxInImage;
            trackBoxInImage.center = cv::Point(trackBox.center.y, trackBox.center.x);
            trackBoxInImage.size = cv::Size(trackBox.size.height, trackBox.size.width);
            trackBoxInImage.angle = -trackBox.angle;
            ellipse( image, trackBoxInImage, Scalar(255,0,0,255), 3, CV_AA );
            center = trackBox.center;
        }
    }
    // judge direction
    if (center.x < frame_gray.cols/2-bound)
        direction = RIGHT;
    else if (center.x > frame_gray.cols/2+bound)
        direction = LEFT;
    else {
        direction = STOP;
    }
    [self suggestRecognizedDirection];
    // draw center alignment
    cv::line(image, cv::Point(0, image.rows/2-bound), cv::Point(image.cols-1, image.rows/2-bound), Scalar(0, 255, 255,255), 3);
    cv::line(image, cv::Point(0, image.rows/2+bound), cv::Point(image.cols-1, image.rows/2+bound), Scalar(0, 255, 255,255), 3);
    cv::line(image, cv::Point(0, center.x), cv::Point(image.cols-1, center.x), Scalar(255, 128, 255,255), 3);
    
    int bias = 60;
    self.mainView.bound1 = (float) (image.rows/2-bias-bound)/(image.rows-bias*2);
    self.mainView.bound2 = (float) (image.rows/2-bias+bound)/(image.rows-bias*2);
    self.mainView.pos = (float) center.x/image.rows;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
#endif

#pragma mark - interaction
- (void)respondNotification:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"gameState"])
    {
        if (state==START || state==GAMEOVER) return;
        NSDictionary* userInfo = notification.userInfo;
        Status receivedState = (Status) [[userInfo objectForKey:@"gameState"] intValue];
        switch (receivedState) {
//            case RESUME:
            case PAUSE:
                if (state==START || state==GAMEOVER) break;
                state = PAUSE;
                self.menuView.hidden = NO;
                self.startButton.hidden = YES;
                self.resumeButton.hidden = NO;
                self.restartButton.hidden = NO;
                self.shareButton.hidden = YES;
                self.greetingText.text = @"Pause";
                self.greetingText.hidden = NO;
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
    currentScore = 0;
    currentCounter = 1;
    currentSpeedup = 1;
    self.currentScoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
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

- (void)onShareClick {
    [self sendMessageToWeixin];
}

- (void)showGameOver {
    dispatch_sync( dispatch_get_main_queue(), ^{
        state = GAMEOVER;
        self.menuView.hidden = NO;
        self.resumeButton.hidden = YES;
        self.restartButton.hidden = NO;
        self.startButton.hidden = YES;
        self.shareButton.hidden = NO;
        self.greetingText.text = @"You Die!";
        self.greetingText.hidden = NO;
        if (currentScore > highestScore) {
            self.greetingText.text = @"New Record!";
            highestScore = currentScore;
            self.highestScoreLabel.text = [NSString stringWithFormat:@"%d", highestScore];
            [userData setValue:[NSNumber numberWithInt:highestScore] forKey:@"highestScore"];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:kUserDataName ofType:@"plist"];
            [userData writeToFile:filePath atomically:YES];
        }
    });
}

#define BUFFER_SIZE 1024 * 100
- (void) sendMessageToWeixin {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"iDrop晒分";
    message.description = [NSString stringWithFormat:@"我在iDrop中成功降下%d层，不服来战！",currentScore];
    [message setThumbImage:[UIImage imageNamed:@"Icon-72@2x.png"]];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"<xml>extend info</xml>";
    ext.url = @"https://itunes.apple.com/cn/app/idrop/id784504288?mt=8";
    
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    ext.fileData = data;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}

#pragma mark - gameControl
- (void)initScene {
    float width = self.mainView.bounds.size.width;
    float height = self.mainView.bounds.size.height;
    character = [[Character alloc] initWithContainerWidth:width Height:height selfImage:[UIImage imageNamed:characterImageName] speedup:currentSpeedup];
    viewObjects = [[NSMutableArray alloc] init];
    [viewObjects addObject:character];
    for (int i=0; i<nHeightUnits; i++) {
        int y = (i+1) * height / nHeightUnits;
        // all normal at first, in case stood on the fragile stage 
        Stage *stage = [[NormalStage alloc] initWithContainerWidth:width Height:height selfImage:[UIImage imageNamed:normalStageImageName] speedup:currentSpeedup];
        stage.y = y;
        [viewObjects addObject:stage];
        if (i==nHeightUnits/2) { // init the character on the middle stage
            character.x = stage.x + (stage.image.size.width-character.image.size.width)/2;
            character.y = stage.y - character.image.size.height;
        }
    }
    currentCounter = 0;
}

// TODO: different stages
- (Stage*)genStage {
    Stage *stage;
    CGFloat width = self.mainView.bounds.size.width;
    CGFloat height = self.mainView.bounds.size.height;
    int dice = arc4random() % 10; // 0..9
    if (dice <= 6) { // generate normal stage
        stage = [[NormalStage alloc] initWithContainerWidth:width Height:height selfImage:[UIImage imageNamed:normalStageImageName] speedup:currentSpeedup];
    } else if (dice <= 8) {
        stage = [[MovingStage alloc] initWithContainerWidth:width Height:height selfImage:[UIImage imageNamed:movingStageImageName] speedup:currentSpeedup];
    } else {
        stage = [[FragileStage alloc] initWithContainerWidth:width Height:height selfImage:[UIImage imageNamed:fragileStageImageName] speedup:currentSpeedup];
    }
    return stage;
}

- (void)updateAll {
    ViewObject *viewObjectToRemove;
    for (ViewObject *viewObject in viewObjects) {
        // all move up
        viewObject.y += viewObject.vy;
        if (viewObject.y<0) viewObjectToRemove = viewObject;
        // update Moving stage
        if ([viewObject isMemberOfClass:[MovingStage class]]) {
            CGFloat width = self.mainView.bounds.size.width;
            if (viewObject.x <= 0 || viewObject.x+viewObject.image.size.width >= width)
                viewObject.vx = -viewObject.vx;
            viewObject.x += viewObject.vx;
            if (viewObject.x <= 0) viewObject.x = 0;
            else if (viewObject.x+viewObject.image.size.width >= width)
                viewObject.x = width - viewObject.image.size.width;
        }
        // TODO: different stages
    }
    if (viewObjectToRemove) {
        if ([viewObjectToRemove isKindOfClass:[Stage class]]) {            
            Stage *stage = [self genStage];
            [viewObjects addObject:stage];
        }
        [viewObjects removeObject:viewObjectToRemove];
        viewObjectToRemove = nil;

        currentScore++;
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.currentScoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
        });
            
        // change difficulty
        if (currentScore < difficultyChangePoint) return; // adapting period
        if ((currentScore-difficultyChangePoint)>>currentCounter) {
            currentCounter++;
            currentSpeedup *= difficultyChangeRate;
            for (ViewObject *viewObject in viewObjects) {
                viewObject.vy *= difficultyChangeRate;
            }
            character.vMov *= difficultyChangeRate;
            character.gravity *= sqrt(difficultyChangeRate);
        }
        
        
//            if (!(currentScore%(difficultyChangePoint*nHeightUnits)) && (currentScore/(difficultyChangePoint*nHeightUnits)<2)) {
//                currentSpeedup *= difficultyChangeRate;
//                for (ViewObject *viewObject in viewObjects) {
//                    viewObject.vy *= difficultyChangeRate;
//                }
//                character.vMov *= difficultyChangeRate;
//                character.gravity *= sqrt(difficultyChangeRate);
//            }
//        }
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
        if ([self isCharacterOnStage:(Stage*)stage] &&
            stage.y < miny) {
            miny = stage.y;
            currStage = (Stage*)stage;
        }
    }
    if (currStage) { // is on stage
        // ignore disappeared fragile stage
        if ([currStage isMemberOfClass:[FragileStage class]] &&
            !((FragileStage*)currStage).isExist) {
            character.vy += character.gravity;
        } else {
            character.vy = currStage.vy;
            character.y = currStage.y - character.image.size.height;
            if ([currStage isMemberOfClass:[MovingStage class]]) { // on moving stage
                character.x += currStage.vx;
            } else if ([currStage isMemberOfClass:[FragileStage class]]) { // on fragile stage
                ((FragileStage*)currStage).isExist = false;
            }
        }
    } else {
        character.vy += character.gravity;
    }
    if ([self isCharacterDied]) {
        state = GAMEOVER;
        [self showGameOver];
    }
}

- (void)suggestRecognizedDirection {
    dispatch_sync( dispatch_get_main_queue(), ^{
        if (!isDetected) self.notRecognizedSuggester.hidden = NO;
        else self.notRecognizedSuggester.hidden = YES;
        switch (direction) {
            case STOP:
                self.leftSuggester.hidden = YES;
                self.rightSuggester.hidden = YES;
                break;
            case LEFT:
                self.leftSuggester.hidden = NO;
                self.rightSuggester.hidden = YES;
                break;
            case RIGHT:
                self.leftSuggester.hidden = YES;
                self.rightSuggester.hidden = NO;
                break;
            default:
                break;
        }
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
            dispatch_sync( dispatch_get_main_queue(), ^{
                // ui-update
                [self.mainView setViewObjects:viewObjects];
                [self.mainView setCharacter:character];
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
    if (character.y+character.image.size.height >= stage.y-1 && // this frame, 1 is disturbance
        character.y+character.image.size.height-character.vy <= stage.y-stage.vy+1 && // last frame
        character.x+character.image.size.width > stage.x &&
        character.x < stage.x+stage.image.size.width) return true;
    return false;
}


@end
