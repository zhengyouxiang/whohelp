//
//  ResetPasswordViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"

@implementation ResetPasswordViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize phone=phone_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loadingIndicator stopAnimating];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions on view
- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneButtonPressed:(id)sender
{
    
    [self.loadingIndicator startAnimating];
    [sender setEnabled:NO];
    
    NSMutableAttributedString *attributedString;
    NSString *decimalRegex = @"^[0-9]{11}$";
    NSPredicate *decimalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    if ([decimalTest evaluateWithObject:self.phone.text]){
        [self resetPasswordInfo:self.phone.text];
    }else{
        attributedString = [NSMutableAttributedString attributedStringWithString:@"请输入正确的手机号(11位)"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
    }
    
    [self.loadingIndicator stopAnimating];
    [sender setEnabled:YES];
    
}

#pragma mark - get the images
- (void)resetPasswordInfo: (NSString *)phone
{
    [self.loadingIndicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?ak=%@&p=%@", RESETURI, APPKEY, phone]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id data = [request responseData];
            id result = [jsonParser objectWithData:data];
            [jsonParser release];
            
            if ([[result objectForKey:@"status"] isEqualToString:@"Fail"]){
                NSMutableAttributedString *attributedString;
                attributedString = [NSMutableAttributedString attributedStringWithString:@"非注册手机号"];
                [attributedString setFont:[UIFont systemFontOfSize:14.0]];
                [attributedString setTextColor:[UIColor redColor]];
                self.errorLabel.attributedText = attributedString;
            } else{
                [self dismissModalViewControllerAnimated:YES];
            }
            
        } else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
}

#pragma mark - handling errors
- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message
{
    UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [Notpermitted show];
    [Notpermitted release];
}

- (void)warningNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"警告" forMessage:message];
}

- (void)errorNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"错误" forMessage:message];  
}

- (void)dealloc
{
    [loadingIndicator_ release];
    [errorLabel_ release];
    [phone_ release];
    [super dealloc];
}

@end
