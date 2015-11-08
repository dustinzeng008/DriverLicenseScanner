//
//  BarCodeViewController.h
//  BarCodeReader
//
//  Created by Big_Mac on 8/3/15.
//  Copyright (c) 2015 CT Analytical Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BarCodeViewController : UIViewController

@property (nonatomic, copy) void (^BarCodeCancleBlock) (BarCodeViewController *);//Cancel Scan
@property (nonatomic, copy) void (^BarCodeSuncessBlock) (BarCodeViewController *,NSString *);//Scan result
@property (nonatomic, copy) void (^BarCodeFailBlock) (BarCodeViewController *);//Scan Fail

@end
