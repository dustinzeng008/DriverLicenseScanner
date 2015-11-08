//
//  UIImage+RenderImage.m
//  DriverLicenseScanner
//
//  Created by Big_Mac on 11/5/15.
//  Copyright © 2015 CT Analytical Corporation. All rights reserved.
//

#import "UIImage+RenderImage.h"

@implementation UIImage (RenderImage)
+(UIImage*)renderImage:(NSString *)imagName{
    return [[UIImage imageNamed:imagName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
@end
