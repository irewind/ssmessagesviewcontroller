//
//  SSMessagesViewController.m
//  Messages
//
//  Created by Sam Soffes on 3/10/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "SSMessagesViewController.h"
#import "SSMessageTableViewCell.h"
#import "SSMessageTableViewCellBubbleView.h"
#import "SSTextField.h"
#import "UIView+FormScroll.h"

CGFloat kInputHeight = 40.0f;

@implementation SSMessagesViewController

@synthesize tableView = _tableView;
@synthesize inputBackgroundView = _inputBackgroundView;
@synthesize textField = _textField;
@synthesize sendButton = _sendButton;
@synthesize leftBackgroundImage = _leftBackgroundImage;
@synthesize rightBackgroundImage = _rightBackgroundImage;

#pragma mark NSObject

- (void)dealloc {
	self.leftBackgroundImage = nil;
	self.rightBackgroundImage = nil;
	[_tableView release];
	[_inputBackgroundView release];
	[_textField release];
	[_sendButton release];
	[super dealloc];
}


#pragma mark UIViewController

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowVK:) name:UIKeyboardWillShowNotification object:nil];
    
	self.view.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
	
	CGSize size = self.view.frame.size;
	
	// Table view
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height - kInputHeight) style:UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.backgroundColor = self.view.backgroundColor;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.separatorColor = self.view.backgroundColor;
	[self.view addSubview:_tableView];
	
	// Input
	_inputBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, size.height - kInputHeight, size.width, kInputHeight)];
	_inputBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_inputBackgroundView.image = [UIImage imageNamed:@"SSMessagesViewControllerInputBackground"];
	_inputBackgroundView.userInteractionEnabled = YES;
	[self.view addSubview:_inputBackgroundView];
	
	// Text field
	_textField = [[SSTextField alloc] initWithFrame:CGRectMake(6.0f, 0.0f, size.width - 75.0f, kInputHeight)];
	_textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_textField.backgroundColor = [UIColor whiteColor];
	_textField.background = [[UIImage imageNamed:@"SSMessagesViewControllerTextFieldBackground"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	_textField.delegate = self;
	_textField.font = [UIFont systemFontOfSize:15.0f];
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_textField.textEdgeInsets = UIEdgeInsetsMake(4.0f, 12.0f, 0.0f, 12.0f);
	[_inputBackgroundView addSubview:_textField];
	
	// Send button
	_sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_sendButton.frame = CGRectMake(size.width - 65.0f, 8.0f, 59.0f, 27.0f);
	_sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	_sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
	[_sendButton setBackgroundImage:[UIImage imageNamed:@"SSMessagesViewControllerSendButtonBackground"] forState:UIControlStateNormal];
	[_sendButton setTitle:Loc2(@"Send",nil) forState:UIControlStateNormal];
	[_sendButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
	[_inputBackgroundView addSubview:_sendButton];
	
	self.leftBackgroundImage = [[UIImage imageNamed:@"SSMessageTableViewCellBackgroundClear"] stretchableImageWithLeftCapWidth:24 topCapHeight:14];
	self.rightBackgroundImage = [[UIImage imageNamed:@"SSMessageTableViewCellBackgroundGreen"] stretchableImageWithLeftCapWidth:17 topCapHeight:14];
}


-(void)handleWillShowVK:(NSNotification*)notif
{
    NSValue* v = notif.userInfo[UIKeyboardFrameBeginUserInfoKey];
    CGRect r = v.CGRectValue;
    
    CGRect f = [self.view convertRect:r fromView:((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController.view];
    
    [self animateForKeyboardWithFrame:f];
}

#pragma mark SSMessagesViewController

// This method is intended to be overridden by subclasses
- (SSMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return SSMessageStyleLeft;
}


// This method is intended to be overridden by subclasses
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    SSMessageTableViewCell *cell = (SSMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[SSMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		[cell setBackgroundImage:self.leftBackgroundImage forMessageStyle:SSMessageStyleLeft];
		[cell setBackgroundImage:self.rightBackgroundImage forMessageStyle:SSMessageStyleRight];
    }
	
    cell.messageStyle = [self messageStyleForRowAtIndexPath:indexPath];
	cell.messageText = [self textForRowAtIndexPath:indexPath];
	
    return cell;
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [SSMessageTableViewCellBubbleView cellHeightForText:[self textForRowAtIndexPath:indexPath]];
}


#pragma mark UITextFieldDelegate

-(void) animateForKeyboardWithFrame:(CGRect)keyboardFrame
{
    [UIView beginAnimations:@"beginEditing" context:_inputBackgroundView];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3f];
    CGFloat bottomInset = keyboardFrame.size.height + kInputHeight;
	_tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset, 0.0f);
	_tableView.scrollIndicatorInsets = _tableView.contentInset;
    CGFloat y = self.view.frame.size.height - bottomInset;
	_inputBackgroundView.frame = CGRectMake(0.0f, y, self.view.frame.size.width, kInputHeight);
	[UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[UIView beginAnimations:@"endEditing" context:_inputBackgroundView];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3f];
	_tableView.contentInset = UIEdgeInsetsZero;
	_tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
	_inputBackgroundView.frame = CGRectMake(0.0f, _tableView.frame.size.height, self.view.frame.size.width, kInputHeight);
    [self.tableView scrollToY:0];
	[UIView commitAnimations];
}

@end
