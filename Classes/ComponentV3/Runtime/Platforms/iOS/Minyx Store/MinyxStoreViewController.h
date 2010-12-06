//
//  MinyxStoreViewController.h
//  Fruitmunch
//
//  Created by jrk on 6/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MinyxStoreViewController : UIViewController 
{
	id delegate;
	UIActivityIndicatorView *activity;
	UITableView *tableView;
	NSArray *products;
}

@property (readwrite, assign) id delegate;
@property (readwrite, retain) IBOutlet UIActivityIndicatorView *activity;
@property (readwrite, retain) IBOutlet UITableView *tableView;
@property (readwrite, retain) NSArray *products;
- (IBAction) dismissStore: (id) sender;

@end
