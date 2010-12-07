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
}
@property (readwrite, assign) id dataSource;
@property (readwrite, retain) SKProduct *product;

- (IBAction) buyTheShit: (id) sender;

@end
