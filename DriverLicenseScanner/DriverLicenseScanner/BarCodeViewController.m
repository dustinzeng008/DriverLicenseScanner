//
//  BarCodeViewController.m
//  BarCodeReader
//
//  Created by Big_Mac on 8/3/15.
//  Copyright (c) 2015 CT Analytical Corporation. All rights reserved.
//

#import "BarCodeViewController.h"
#import "UIImage+RenderImage.h"
#import "UIColor+FlatUI.h"

//Device width/height/coordinate
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
#define KDeviceFrame [UIScreen mainScreen].bounds

static const float kLineMinY = 250;
static const float kLineMaxY = 350;
static const float kReaderViewWidth = 260;
static const float kReaderViewHeight = 100;

@interface BarCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) NSTimer *lineTimer;

@end

@implementation BarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
    [self setOverlayPickerView];
    [self startBarCodeReading];
    [self initNavigationBar];
}



// ********************************** Initialize navigation bar **********************************
- (void)initNavigationBar
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,kDeviceWidth, 64)];
    bgView.backgroundColor = [UIColor turquoiseColor];
    [self.view addSubview:bgView];
    
    // set navigation bar title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((kDeviceWidth - 150) / 2.0, 28, 150, 20)];
    titleLabel.text = @"Scan Bar Code";
    titleLabel.shadowColor = [UIColor lightGrayColor];
    titleLabel.shadowOffset = CGSizeMake(0, - 1);
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    
    // set navigation bar Button
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 16, 100, 44)];
    button.tintColor = [UIColor whiteColor];
    [button setTitle:@" Back" forState:UIControlStateNormal];
    [button setImage:[UIImage renderImage:@"bar_back"] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button addTarget:self action:@selector(cancleBarCodeReading) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


- (void)initUI
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //device.focusMode =  AVCaptureFocusModeAutoFocus;
    
    //Check Camera
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error)
    {
        NSLog(@"No Camera-%@", error.localizedDescription);
        
        return;
    }
    
    //set output(Metadata)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //set output delegate
    //use main thread
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    // reading quality
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else
    {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }

    
    output.metadataObjectTypes = [output availableMetadataObjectTypes];
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
        [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:preview atIndex:0];
    self.videoPreviewLayer = preview;
    self.captureSession = session;
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    return CGRectMake(kLineMinY / KDeviceHeight, ((kDeviceWidth - asize.width) / 2.0) / kDeviceWidth, asize.height / KDeviceHeight, asize.width / kDeviceWidth);
}

- (void)setOverlayPickerView
{
    //draw the line in the middle
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((kDeviceWidth - 300) / 2.0, kLineMinY, 300, 12 * 300 / 320.0)];
    [_line setImage:[UIImage imageNamed:@"QRCodeLine"]];
    [self.view addSubview:_line];
    
    //upper view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kLineMinY)];//80
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //left view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMinY, (kDeviceWidth - kReaderViewWidth) / 2.0, kReaderViewHeight)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //rightview
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(kDeviceWidth - CGRectGetMaxX(leftView.frame), kLineMinY, CGRectGetMaxX(leftView.frame), kReaderViewHeight)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    CGFloat space_h = KDeviceHeight - kLineMaxY;
    
    //bottom view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMaxY, kDeviceWidth, space_h)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    //four corner
    UIImage *cornerImage = [UIImage imageNamed:@"QRCodeTopLeft"];
    
    //left view
    UIImageView *leftView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    leftView_image.image = cornerImage;
    [self.view addSubview:leftView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodeTopRight"];
    
    //right view
    UIImageView *rightView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    rightView_image.image = cornerImage;
    [self.view addSubview:rightView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomLeft"];
    
    //bottom view
    UIImageView *downView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downView_image.image = cornerImage;
    [self.view addSubview:downView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomRight"];
    
    UIImageView *downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downViewRight_image.image = cornerImage;
    [self.view addSubview:downViewRight_image];
    
    //label
    UILabel *labIntroudction = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame = CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMinY(downView.frame) + 25, kReaderViewWidth, 20);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont boldSystemFontOfSize:13.0];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"Align Bar Code within frame to scan";
    [self.view addSubview:labIntroudction];
    
    UIView *scanCropView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - 1,kLineMinY,self.view.frame.size.width - 2 * CGRectGetMaxX(leftView.frame) + 2, kReaderViewHeight + 2)];
    scanCropView.layer.borderColor = [UIColor greenColor].CGColor;
    scanCropView.layer.borderWidth = 2.0;
    [self.view addSubview:scanCropView];
}


#pragma mark -
#pragma mark the delegate method of output

//recognize QRCode and complete convertion
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypePDF417Code];
    
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        if (detectionString != nil)
        {
            if (self.BarCodeSuncessBlock) {
                self.BarCodeSuncessBlock(self,detectionString);
            }
            else
            {
                if (self.BarCodeFailBlock) {
                    self.BarCodeFailBlock(self);
                }
            }

            break;
        }
        else{
            if (self.BarCodeFailBlock) {
                self.BarCodeFailBlock(self);
            }
        }
        //NSLog(@"end");
    }
    
}


#pragma mark -

- (void)startBarCodeReading
{
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    
    [self.captureSession startRunning];
    
    NSLog(@"start reading");
}

- (void)stopBarCodeReading
{
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    
    [self.captureSession stopRunning];
    
    NSLog(@"stop reading");
}

//Cancel Scanning
- (void)cancleBarCodeReading
{
    [self stopBarCodeReading];
    
    if (self.BarCodeCancleBlock)
    {
        self.BarCodeCancleBlock(self);
    }
    NSLog(@"cancle reading");
}


#pragma mark -
#pragma mark scanning line

- (void)animationLine
{
    __block CGRect frame = _line.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = kLineMinY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 5;
            _line.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (_line.frame.origin.y >= kLineMinY)
        {
            if (_line.frame.origin.y >= kLineMaxY - 12)
            {
                frame.origin.y = kLineMinY;
                _line.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    
                    frame.origin.y += 5;
                    _line.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
    
    //NSLog(@"_line.frame.origin.y==%f",_line.frame.origin.y);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
