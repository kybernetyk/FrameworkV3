//
//  AppController.m
//  Donnerfaust
//
//  Created by jrk on 2/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (void) setup
{
	NSLog(@"setup called!");
}


#pragma mark -
#pragma mark in app datasource
- (NSString *) youtubeURLForProductID: (NSString *) productID
{
//	if ([productID isEqualToString: kInAppFullGame])
//		return @"http://www.youtube.com/watch?v=40nLZt3lxEg";
	
	return nil;
}

- (NSString *) imageNameForProductID: (NSString *) productID
{
//	if ([productID isEqualToString: kInAppFullGame])
//		return @"full_game_screen.png";
	
	return nil;
}

- (NSString *) detailImageNameForProductID: (NSString *) productID
{
//	if ([productID isEqualToString: kInAppFullGame])
//		return @"puzzle_mode.png";
	
	return nil;
}

- (NSString *) detailImageCaptionForProductID: (NSString *) productID
{
//	if ([productID isEqualToString: kInAppFullGame])
//		return @"Puzzle Mode";
	
	return nil;
}

#pragma mark -
#pragma mark facebook datasource
- (void) fbDidFail: (NSNotification *) notification
{
}

- (void) fbDidSucceed: (NSNotification *) notification
{
}

- (NSString *) titleForFBShare
{
	return @"Fruit Munch";
}
- (NSString *) captionForFBShare
{
	
	return @"caption";
}
- (NSString *) descriptionForFBShare
{
	return @":-)";
}

- (NSString *) linkForFBShare
{
	return @"http://www.minyxgames.com/fruit-munch/";
}

- (NSString *) linkNameForFBShare
{
	return @"Fruit Munch!";
}

- (NSString *) picurlForFBShare
{
	return @"http://www.minyxgames.com/fruit-munch/fb_pic.png";
}
#pragma mark -
#pragma mark in inapp
- (NSSet *) inAppProductIDs
{
//	NSSet *iap = [NSSet setWithObjects:
//				  kInAppFullGame, nil ];
//	
//	return iap;	
	return nil;
}

#pragma mark -
#pragma mark news
- (NSArray *) newsItemsForOffline
{
	return nil;
}



@end
