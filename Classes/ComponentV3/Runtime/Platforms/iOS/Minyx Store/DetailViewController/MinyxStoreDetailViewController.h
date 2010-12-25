//
//  DetailViewController.h
//  Fruitmunch
//
//  Created by jrk on 7/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//
#pragma oncde
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "CocosDenshion.h"
#import "CDAudioManager.h"

@interface MinyxStoreDetailViewController : UIViewController 
{
	SKProduct *product;
	id dataSource;
	
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *priceLabel;
	IBOutlet UITextView *detailText;
	IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activity;
	IBOutlet UIButton *buyButton;
	IBOutlet UIButton *showDetialButton;
	IBOutlet UIButton *showYTButton;
	
	IBOutlet UIView *detailImageView;
	IBOutlet UIImageView *detailImageView_imageView;
	IBOutlet UIButton *detailImageView_closeButton;
	IBOutlet UILabel *detailImageView_captionLabel;
	
	IBOutlet UIView *youtubeView;
	IBOutlet UIWebView *webView;
	IBOutlet UIButton *youtubeView_closeButton;
	IBOutlet UIActivityIndicatorView *youtubeView_activity;
	IBOutlet UIButton *youtubeView_close2Button;
	
	CGRect small_detail_frame;
	CGRect large_detail_frame;
	
	CGRect large_yt_frame;
	CGRect small_yt_frame;
	tAudioManagerMode _lolmode;
	BOOL reinit_sfx;
}
@property (readwrite, assign) id dataSource;
@property (readwrite, retain) SKProduct *product;

- (IBAction) buyTheShit: (id) sender;

- (IBAction) showYTVideo: (id) sender;
- (IBAction) dismissYTVideo: (id) sender;

- (IBAction) showDetailImage: (id) sender;
- (IBAction) dismissDetailImage: (id) sender;

@end
