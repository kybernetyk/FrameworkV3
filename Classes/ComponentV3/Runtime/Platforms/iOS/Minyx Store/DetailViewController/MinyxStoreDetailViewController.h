//
//  DetailViewController.h
//  Fruitmunch
//
//  Created by jrk on 7/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

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
	
	IBOutlet UIView *detailImageView;
	IBOutlet UIImageView *detailImageView_imageView;
	IBOutlet UIButton *detailImageView_closeButton;
	IBOutlet UILabel *detailImageView_captionLabel;
	
	CGRect small_detail_frame;
	CGRect large_detail_frame;
}
@property (readwrite, assign) id dataSource;
@property (readwrite, retain) SKProduct *product;

- (IBAction) buyTheShit: (id) sender;

- (IBAction) showDetailImage: (id) sender;
- (IBAction) dismissDetailImage: (id) sender;

@end
