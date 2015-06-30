//
//  ViewController.m
//  TestActionSheet
//
//  Created by Dono Air on 2014. 1. 1..
//  Copyright (c) 2014년 Dono Air. All rights reserved.
//

#import "ViewController.h"
#import "DoActionSheet+Demo.h"

#import	<AssetsLibrary/AssetsLibrary.h>

@interface ViewController () <DoActionSheetDelegate>
@end


@implementation ViewController {
	DoActionSheet *vActionSheet;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_sgSelect.selectedSegmentIndex = 0;
	_sgType.selectedSegmentIndex = 0;
	_sgStyle.selectedSegmentIndex = 0;
	
	[self onSelect:nil];
	[self onSelectAnimationType:nil];
	[self onSelectStyle:nil];
}

- (IBAction)onShowAlert:(id)sender
{
	[self startCollectingImages];
	vActionSheet = [[DoActionSheet alloc] init];
	vActionSheet.delegate = self;
	vActionSheet.doScrollingImagesHeight = DO_SCROLLING_IMAGES_HEIGHT_SLIM;
	
	vActionSheet.nAnimationType = (int)_sgType.selectedSegmentIndex;
	
	if (_sgStyle.selectedSegmentIndex == 0)
		[vActionSheet setStyle1];
	else if (_sgStyle.selectedSegmentIndex == 1)
		[vActionSheet setStyle2];
	else if (_sgStyle.selectedSegmentIndex == 2)
		[vActionSheet setStyle3];
	
	
	if (_sgSelect.selectedSegmentIndex != 1) {
		vActionSheet.dRound = 5;
	}
	
	vActionSheet.dButtonRound = 2;
	
	if (_sgSelectImage.selectedSegmentIndex == 1)
	{
		vActionSheet.iImage = [UIImage imageNamed:@"pic1.jpg"];
		vActionSheet.nContentMode = DoASContentImageSubset;
	}
	else if (_sgSelectImage.selectedSegmentIndex == 2)
	{
		vActionSheet.iImage = [UIImage imageNamed:@"pic2.jpg"];
		vActionSheet.nContentMode = DoASContentImageSubset;
	}
	else if (_sgSelectImage.selectedSegmentIndex == 3)
	{
		vActionSheet.nContentMode = DoASContentMap;
		vActionSheet.dLocation = @{@"latitude" : @(37.78275123), @"longitude" : @(-122.40416442), @"altitude" : @200};
	}
	
	
	switch (_sgSelect.selectedSegmentIndex) {
		case 0:
			vActionSheet.nDestructiveIndex = 2;
			vActionSheet.doSelectedButtonColor = [UIColor redColor];
			vActionSheet.doSelectedButtonTextColor = [UIColor whiteColor];
			
			[vActionSheet showC:@"What do you want for this photo? "
						 cancel:@"Cancel"
						buttons:@[@"Post to facebook", @"Post to Instagram", @"Delete this photo"]
			 ];
			break;
			
		case 1:
			[vActionSheet showC:@"What do you want for this photo?"
						 cancel:@"Cancel"
						buttons:@[@"Post to facebook", @"Post to twitter", @"Post to Instagram", @"Send a mail", @"Save to camera roll"]
			 ];
			break;
			
		case 2:
			[vActionSheet showC:@"Cancel"
						buttons:@[@"Open with Safari", @"Copy the link"]
			 ];
			break;
			
		case 3:
			[vActionSheet show:@"What do you want?"
					   buttons:@[@"Open with Safari", @"Copy the link"]
			 ];
			break;
			
		case 4:
			[vActionSheet show:@[@"Open with Safari", @"Copy the link"]
						images:nil
			 ];
			break;
			
		default:
			break;
	}
}

- (IBAction)onSelect:(id)sender
{
	switch (_sgSelect.selectedSegmentIndex) {
		case 0:
			_lbMode.text = @"With title, destructive button, cancel, others";
			break;
		case 1:
			_lbMode.text = @"With title, cancel, others";
			break;
		case 2:
			_lbMode.text = @"Cancel, others";
			break;
		case 3:
			_lbMode.text = @"With title, others";
			break;
		case 4:
			_lbMode.text = @"Only normal buttons";
			break;
			
		default:
			break;
	}
}

- (IBAction)onSelectAnimationType:(id)sender
{
	switch (_sgType.selectedSegmentIndex) {
		case DoASTransitionStyleNormal:
			_lbType.text = @"DoTransitionStyleNormal";
			break;
		case DoASTransitionStyleFade:
			_lbType.text = @"DoTransitionStyleFade";
			break;
		case DoASTransitionStylePop:
			_lbType.text = @"DoTransitionStylePop";
			break;
			
		default:
			break;
	}
}

- (IBAction)onSelectStyle:(id)sender
{
	switch (_sgStyle.selectedSegmentIndex) {
		case 0:
			_lbStyle.text = @"Style 1";
			break;
		case 1:
			_lbStyle.text = @"Style 2";
			break;
		case 2:
			_lbStyle.text = @"Style 3";
			break;
			
		default:
			break;
	}
}

#pragma mark - Private

- (void)startCollectingImages {
	
	int imagesToRetrieve = 10;
	NSMutableArray *images = [[NSMutableArray alloc] init];
	NSMutableArray *alAssets = [[NSMutableArray alloc] init];
	dispatch_semaphore_t sem = dispatch_semaphore_create(0);
	
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		// Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
		[library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
			
			// Within the group enumeration block, filter to enumerate just photos.
			[group setAssetsFilter:[ALAssetsFilter allPhotos]];
			// Chooses the photo at the last index
			[group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
				
				// The end of the enumeration is signaled by asset == nil.
				if (alAsset) {
					UIImage *latestPhoto = [UIImage imageWithCGImage:[alAsset thumbnail]];
					if (latestPhoto != nil) {
						[images addObject:latestPhoto];
						[alAssets addObject:alAsset];
					}
					if ([images count] >= imagesToRetrieve) {
						// Stop the enumerations
						*innerStop = YES;
					}
				}
			}];
			
			if (group == nil) {
				*stop = YES;
				dispatch_semaphore_signal(sem);
			}
			
		} failureBlock: ^(NSError *error) {
			// Typically you should handle an error more gracefully than this.
			dispatch_semaphore_signal(sem);
		}];
	});
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			if ([images count]) {
				[vActionSheet updateHorizontallyScrollingImages:images alAssetsLibrary:library alAssets:alAssets];
			}
		});
	});
}

#pragma mark - DoActionSheetDelegate

- (void)doActionSheetDidCancel:(DoActionSheet *)sheet {
	NSLog( @"Action Sheet cancelled" );
}
- (void)doActionSheet:(DoActionSheet *)sheet didSelectButton:(int)buttonIndex title:(NSString *)title {
	NSLog( @"Action Sheet selected button: %d [%@]", buttonIndex, title );
}

- (void)doActionSheet:(DoActionSheet *)sheet didSelectImage:(int)imageIndex image:(UIImage *)image {
	NSLog( @"Action Sheet selected image: %d [%@]", imageIndex, NSStringFromCGSize([image size]));
}

- (void)doActionSheet:(DoActionSheet *)sheet didSelectImageSubset:(UIImage *)image {
	NSLog( @"Action Sheet selected ImageSubset: [%@]", NSStringFromCGSize([image size]));
}


@end
