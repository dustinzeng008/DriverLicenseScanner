//
//  DriverLicenseInfoViewController.m
//  DriverLicenseScanner
//
//  Created by Big_Mac on 11/5/15.
//  Copyright © 2015 CT Analytical Corporation. All rights reserved.
//

#import "DriverLicenseInfoViewController.h"
#import "BarCodeViewController.h"
#import "UIImage+RenderImage.h"
#import "FUITextField.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "ActionSheetPicker.h"


#define DeviceWidth self.view.frame.size.width              // The width of Device
#define margin 5                                            // The margin between textfield
#define componentHeight 40                                  // The height of component(textfield&button)

@interface DriverLicenseInfoViewController()<UITextFieldDelegate>{
    NSArray *textFieldContentArray;                         // The hint text of textfield
    NSMutableArray *textFieldMArray;                        // MutableArray that store textfields
}

@property (strong, nonatomic) UIButton *btn_scanDriverLicense;
@property (strong, nonatomic) FUITextField *tf_firstName;
@property (strong, nonatomic) FUITextField *tf_lastName;
@property (strong, nonatomic) FUITextField *tf_driverLicence;
@property (strong, nonatomic) FUITextField *tf_gender;
@property (strong, nonatomic) FUITextField *tf_address;
@property (strong, nonatomic) FUITextField *tf_city;
@property (strong, nonatomic) FUITextField *tf_zipCode;
@property (strong, nonatomic) FUITextField *tf_dateOfBirth;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation DriverLicenseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    textFieldMArray = [[NSMutableArray alloc] init];
    textFieldContentArray = [NSArray arrayWithObjects:@"  First name", @"  Last name", @"  Driver Lic #", @"  Gender",
                             @"  Birthday", @"  Address", @"  City, State", @"  Zip Code", nil];
    [self initNavigationBar];
    [self initViews];
}


// ********************************** Initialize navigation bar **********************************
- (void)initNavigationBar{
    UINavigationItem *navItem = self.navigationItem;
    
    // set navigation bar title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Driver License Info";
    navItem.titleView = titleLabel;
}


// ********************************** Initialize view content **********************************
- (void)initViews{
    CGFloat btnScanDriverLicenseY = 20;
    CGFloat textFieldY = btnScanDriverLicenseY +15;
    CGFloat textFieldHeightIncrease = 4 + componentHeight;
    
    // initialite scrollview - hold textfield and button
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_scrollView];
    
    // Initialize Scan Driver Licence button
    _btn_scanDriverLicense=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btn_scanDriverLicense setFrame:CGRectMake(margin, btnScanDriverLicenseY, DeviceWidth - 2*margin, componentHeight)];
    [_btn_scanDriverLicense setTitle:@"Scan Driver License to import data" forState:UIControlStateNormal];
    [_btn_scanDriverLicense setBackgroundColor:[UIColor turquoiseColor]];
    [_btn_scanDriverLicense setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [[_btn_scanDriverLicense titleLabel] setFont:[UIFont boldSystemFontOfSize:18]];
    _btn_scanDriverLicense.layer.cornerRadius = 3.0;
    [_btn_scanDriverLicense addTarget:self action:@selector(scanDriverLicense) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_btn_scanDriverLicense];
    
    // Initialize textfield
    for (int i=0; i<8; i++) {
        textFieldY += textFieldHeightIncrease;
        if (i == 5) {
            textFieldY += 20;
        }
        FUITextField *textField = [self getTextField:textFieldY componentText:textFieldContentArray[i]];
        // if the textfield is gender textfield or birthday textfield add touch down function to it.
        if (i == 3) {
            [textField addTarget:self action:@selector(selectGender:) forControlEvents:UIControlEventTouchDown];
        }else if (i == 4){
            [textField addTarget:self action:@selector(selectBirthday:) forControlEvents:UIControlEventTouchDown];
        }
        [textFieldMArray addObject:textField];
    }
}

// ********************************** Function to create textfield **********************************
- (FUITextField *)getTextField:(CGFloat)componentY componentText:(NSString *)componentText{
    FUITextField *textField = [[FUITextField alloc] initWithFrame:CGRectMake(margin, componentY, (DeviceWidth - 2*margin), componentHeight)];
    textField.font = [UIFont flatFontOfSize:16];
    textField.backgroundColor = [UIColor clearColor];
    textField.edgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 10.0f);
    textField.textAlignment = NSTextAlignmentRight;
    textField.returnKeyType = UIReturnKeyNext;
    textField.textFieldColor = [UIColor whiteColor];
    textField.borderColor = [UIColor turquoiseColor];
    textField.borderWidth = 2.0f;
    textField.cornerRadius = 3.0f;
    textField.delegate = self;
    [_scrollView addSubview:textField];
    UILabel *lb_textfield = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 100, 25) ];
    [lb_textfield setText:componentText];
    [lb_textfield setFont:[UIFont fontWithName:@"Verdana" size:15]];
    [lb_textfield setTextColor:[UIColor grayColor]];
    textField.leftView = lb_textfield;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    return textField;
}

// ********************************** Function called when user touch down gender textfield **********************************
- (void)selectGender:(id)sender{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *colors = @[@"Male", @"Female"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Gender" rows:colors initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    
}

// ********************************** Function called when user touch down birthday textfield **********************************
- (void)selectBirthday:(id)sender{
    ActionDateDoneBlock done = ^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat : @"MM/dd/yyyy"];
            NSString* date = [formatter stringFromDate:selectedDate];
           
            [sender performSelector:@selector(setText:) withObject:date];
        }
    };
    
    ActionDateCancelBlock cancel = ^(ActionSheetDatePicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [minimumDateComponents setYear:1915];
    NSDateComponents *maximumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [maximumDateComponents setYear:1997];
    NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
    NSDate *maxDate = [calendar dateFromComponents:maximumDateComponents];
    
    [ActionSheetDatePicker showPickerWithTitle:@"SelectDate" datePickerMode:UIDatePickerModeDate selectedDate:maxDate minimumDate:minDate maximumDate:maxDate doneBlock:done cancelBlock:cancel origin:sender];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [_scrollView setContentOffset:CGPointMake(0,-_scrollView.contentInset.top) animated:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == textFieldMArray[5] || textField == textFieldMArray[6] || textField == textFieldMArray[7]) {
        CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y - _scrollView.contentInset.top-210);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
    
    if (textField == textFieldMArray[3] || textField == textFieldMArray[4]){
        return NO;
    }
    return YES;
}


// ********************************** Open Campera to scan **********************************
- (void)scanDriverLicense{
    //Scan Bar Code
    BarCodeViewController *vc_barCode = [[BarCodeViewController alloc] init];
    vc_barCode.BarCodeSuncessBlock = ^(BarCodeViewController *aqrvc,NSString *qrString){
        NSLog(@"Information----%@",qrString);
        [self setUIContents:qrString];
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    vc_barCode.BarCodeFailBlock= ^(BarCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    vc_barCode.BarCodeCancleBlock = ^(BarCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    [self presentViewController:vc_barCode animated:YES completion:nil];
}

// ********************************** Set UI values after scan driver license **********************************
- (void) setUIContents:(NSString*)theString{
    NSArray *splitArray = [theString componentsSeparatedByString:@"\n"];
    NSLog(@"length=%lu", (unsigned long)splitArray.count);
    NSString *strName=@"";
    NSString *strStreet=@"";
    NSString *strCity=@"";
    NSString *strState=@"";
    NSString *strZipCode=@"";
    NSString *strDriverLic=@"";
    NSString *strBirthday=@"";
    NSString *strGender=@"";
    for (int i =0; i<splitArray.count; i++) {
        if ([splitArray[i] rangeOfString:@"DAA"].location != NSNotFound) {
            strName = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DAA"].location+3];
            NSLog(@"strName: %@",strName);
            continue;
        }else if ([splitArray[i] rangeOfString:@"DAG"].location != NSNotFound){
            strStreet = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DAG"].location+3];
            NSLog(@"strStreet: %@",strStreet);
            continue;
        }else if ([splitArray[i] rangeOfString:@"DAI"].location != NSNotFound){
            strCity = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DAI"].location+3];
            NSLog(@"strCity: %@",strCity);
            continue;
        }else if ([splitArray[i] rangeOfString:@"DAJ"].location != NSNotFound){
            strState = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DAJ"].location+3];
            NSLog(@"strState: %@",strState);
            continue;
        }else if ([splitArray[i] rangeOfString:@"DAK"].location != NSNotFound){
            strZipCode = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DAK"].location+3];
            NSLog(@"strZipCode: %@",strZipCode);
            continue;
        }else if ([splitArray[i] rangeOfString:@"DAQ"].location != NSNotFound){
            strDriverLic = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DAQ"].location+3];
            NSLog(@"strDriverLic: %@",strDriverLic);
            continue;
        }else if ([splitArray[i] rangeOfString:@"DBB"].location != NSNotFound){
            strBirthday = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DBB"].location+3];
            NSLog(@"strBirthday: %@",strBirthday);
            continue;
        }else if ([splitArray[i] rangeOfString:@"DBC"].location != NSNotFound){
            strGender = [splitArray[i] substringFromIndex:[splitArray[i] rangeOfString:@"DBC"].location+3];
            NSLog(@"strGender: %@",strGender);
            continue;
        }
    }
    
    UITextField *firstNameTextField = textFieldMArray[0];
    UITextField *lastNameTextField = textFieldMArray[1];
    UITextField *driverLicenseTextField = textFieldMArray[2];
    UITextField *genderTextField = textFieldMArray[3];
    UITextField *birthdayTextField = textFieldMArray[4];
    UITextField *addressTextField = textFieldMArray[5];
    UITextField *cityTextField = textFieldMArray[6];
    UITextField *zipCodeTextField = textFieldMArray[7];
    
    dispatch_async(dispatch_get_main_queue(),^{
        NSArray *splitNameArray = [strName componentsSeparatedByString:@","];
        firstNameTextField.text = splitNameArray[1];
        lastNameTextField.text = splitNameArray[0];
        
        driverLicenseTextField.text = strDriverLic;
        
        if([strGender isEqualToString:@"1"]){
            genderTextField.text = @"MALE";
        }else{
            genderTextField.text = @"FEMALE";
        }
        NSString* formatedStrBirthday= [NSString stringWithFormat:@"%@/%@/%@",
                                        [strBirthday substringWithRange:NSMakeRange(4, 2)],
                                        [strBirthday substringWithRange:NSMakeRange(6, 2)],
                                        [strBirthday substringWithRange:NSMakeRange(0, 4)] ];
        birthdayTextField.text = formatedStrBirthday;
        addressTextField.text = strStreet;
        
        NSString* strCityAndState = [NSString stringWithFormat:@"%@, %@",
                                     strCity,strState];
        cityTextField.text = strCityAndState;
        zipCodeTextField.text = strZipCode;
    });
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
