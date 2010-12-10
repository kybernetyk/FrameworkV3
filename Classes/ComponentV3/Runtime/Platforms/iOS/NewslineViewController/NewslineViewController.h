//
//  NewslineViewController.h
//  Fruitmunch
//
//  Created by jrk on 10/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewslineViewController : UIViewController 
{
	IBOutlet UILabel *textLabel;
	IBOutlet UIButton *moreButton;
	
	NSArray *newsItems;
	
	NSMutableData *receivedData;
	NSString *link;
	
	CGRect visibleFrame;
	CGRect hiddenFrame;
}

@property (readwrite, retain) NSArray *newsItems;
@property (readwrite, retain) NSString *link;

- (void) start;

- (IBAction) visitLink: (id) sender;

@end
