//
//  MKStoreObserver.m
//  MKStoreKit
//
//  Created by Mugunth Kumar on 17-Nov-2010.
//  Copyright 2010 Steinlogic. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKStoreObserver.h"
#import "MKStoreManager.h"

@interface MKStoreManager (InternalMethods)

// these three functions are called from MKStoreObserver
- (void) transactionCanceled: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

- (void) provideContent: (NSString*) productIdentifier 
			forReceipt: (NSData*) recieptData;
@end

@implementation MKStoreObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	//NSLog(@"update transactions ...");
	for (SKPaymentTransaction *transaction in transactions)
	{
	//	NSLog(@"update: %@", transaction);
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				
                [self completeTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateFailed:
				
                [self failedTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateRestored:
				
                [self restoreTransaction:transaction];
				
            default:
				
                break;
		}			
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{	
	//	NSLog(@"failed transaction: %@", transaction);
	[[MKStoreManager sharedManager] transactionCanceled:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{		
	//NSLog(@"complete transaction: %@", transaction);
    [[MKStoreManager sharedManager] provideContent:transaction.payment.productIdentifier 
									   forReceipt:transaction.transactionReceipt];	

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{	
	//NSLog(@"restore transaction: %@", transaction);
    [[MKStoreManager sharedManager] provideContent: transaction.originalTransaction.payment.productIdentifier
									   forReceipt:transaction.transactionReceipt];
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
//	NSArray *transactions = [queue transactions];
//	
//	NSLog(@"restore finished!");
//	for (SKPaymentTransaction *transaction in transactions)
//	{
//		NSLog(@"update: %@", transaction);
//		switch (transaction.transactionState)
//		{
//            case SKPaymentTransactionStateRestored:
//				NSLog(@"restore trans ...");
//                [self restoreTransaction:transaction];
//            default:
//                break;
//		}			
//	}
//	
	[[MKStoreManager sharedManager] restoreFinished];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	//NSLog(@"restore err: %@", error);
	[[MKStoreManager sharedManager] restoreFinished];
}


@end
