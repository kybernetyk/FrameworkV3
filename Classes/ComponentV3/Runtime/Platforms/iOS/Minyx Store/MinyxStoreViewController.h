//
//  MinyxStoreViewController.h
//  Fruitmunch
//
//  Created by jrk on 6/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MinyxStoreViewController : UIViewController 
{
	UIActivityIndicatorView *activity;
	UITableView *tableView;
	NSArray *products;

	NSString *productIdToShow;
	
	id productInformationDataSource;
}
@property (readwrite, assign) id productInformationDataSource;
@property (readwrite, retain) IBOutlet UIActivityIndicatorView *activity;
@property (readwrite, retain) IBOutlet UITableView *tableView;
@property (readwrite, retain) NSArray *products;
@property (readwrite, retain) NSString *productIdToShow;

- (void) showDetailViewForProduct: (SKProduct *) product animated: (BOOL) animated;

- (IBAction) restorePurchases: (id) sender;
@end
