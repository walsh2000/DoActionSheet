//
//  DoActionSheet.m
//  TestActionSheet
//
//  Created by Donobono on 2014. 01. 01..
//

#import "DoActionSheet.h"
#import "UIImage+ResizeMagick.h"    //  Created by Vlad Andersen on 1/5/13.

#pragma mark - DoAlertViewController

@interface DoActionSheetController : UIViewController

@property (nonatomic, strong) DoActionSheet *actionSheet;

@end

@implementation DoActionSheetController {
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = _actionSheet;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [UIApplication sharedApplication].statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return [UIApplication sharedApplication].statusBarHidden;
}

@end

@implementation DoActionSheet {
	NSString                *_strTitle;
	NSString                *_strCancel;
	
	UIWindow                *_actionWindow;
	UIView                  *_vActionSheet;
	
	CGRect                  _rectActionSheet;
	UIImageView *_imageView;
	UIScrollView *_scrollView;
	NSArray *_horizontalScrollingImages;
	NSArray *_horizontalScrollingAlAssets;
	ALAssetsLibrary *_alAssetsLibrary;
}

@synthesize delegate = _delegate;
@synthesize nAnimationType = _nAnimationType;
@synthesize nContentMode = _nContentMode;
@synthesize nDestructiveIndex = _nDestructiveIndex;
@synthesize dRound = _dRound;
@synthesize dButtonRound = _dButtonRound;
@synthesize bDestructive = _bDestructive;
@synthesize nTag = _nTag;
@synthesize aButtons = _aButtons;
@synthesize iImage = _iImage;
@synthesize dLocation = _dLocation;
@synthesize doBackColor = _doBackColor;
@synthesize doButtonColor = _doButtonColor;;
@synthesize doCancelColor = _doCancelColor;
@synthesize doDestructiveColor = _doDestructiveColor;;
@synthesize doTitleTextColor = _doTitleTextColor;
@synthesize doButtonTextColor = _doButtonTextColor;
@synthesize doSelectedButtonTextColor = _doSelectedButtonTextColor;
@synthesize doCancelTextColor = _doCancelTextColor;
@synthesize doDestructiveTextColor = _doDestructiveTextColor;
@synthesize doDimmedColor = _doDimmedColor;
@synthesize doTitleFont = _doTitleFont;
@synthesize doButtonFont = _doButtonFont;
@synthesize doCancelFont = _doCancelFont;
@synthesize doTitleInset = _doTitleInset;
@synthesize doButtonInset = _doButtonInset;
@synthesize doButtonHeight = _doButtonHeight;
@synthesize doScrollingImagesHeight = _doScrollingImagesHeight;
@synthesize doScrollingImagesGap = _doScrollingImagesGap;
@synthesize nImageSubsetScaleWidth = _nImageSubsetScaleWidth;
@synthesize nImageSubsetDisplayHeight = _nImageSubsetDisplayHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        _nDestructiveIndex = -1;
    }
    return self;
}

- (void)setupHorizontalScrollView:(int)topGap {
	int height = self.doScrollingImagesHeight?:DO_SCROLLING_IMAGES_HEIGHT;
	int gap = self.doScrollingImagesGap?:DO_SCROLLING_IMAGES_GAP;
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topGap, 320, height)];
	UIColor *backColor = (self.doBackColor == nil) ? DO_AS_BACK_COLOR : self.doBackColor;
	[_scrollView setBackgroundColor:backColor];
	[_scrollView setCanCancelContentTouches:NO];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	_scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	_scrollView.clipsToBounds = YES;
	_scrollView.scrollEnabled = YES;
	_scrollView.pagingEnabled = NO;
	
	CGFloat cx = gap;
	int tagIndex = 0;
	for (UIImage *image in _horizontalScrollingImages) {
		//compute aspect ratio
		CGSize imageSize = [image size];
		CGFloat aspectRatio = imageSize.width/imageSize.height;
		CGFloat calculatedWidth = aspectRatio * (CGFloat) height;

		UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		imageButton.frame = CGRectIntegral(CGRectMake(cx, 0, calculatedWidth, height));
		
		[imageButton setImage:image forState:UIControlStateNormal];
		[imageButton addTarget:self action:@selector(imageButtonTarget:) forControlEvents:UIControlEventTouchUpInside];
		[imageButton setTag:(tagIndex)];
		tagIndex++;
		
		[_scrollView addSubview:imageButton];
		
		cx += imageButton.frame.size.width + gap;
	}
	
	[_scrollView setContentSize:CGSizeMake(cx, [_scrollView bounds].size.height)];
	[_vActionSheet addSubview:_scrollView];
	
}

// with cancel button and other buttons
- (void)showC:(NSString *)strTitle
       cancel:(NSString *)strCancel
      buttons:(NSArray *)aButtons
{
    _strTitle   = strTitle;
    _strCancel  = strCancel;
    _aButtons   = aButtons;
	_horizontalScrollingImages = nil;
	_horizontalScrollingAlAssets = nil;
	_alAssetsLibrary = nil;

	[self showActionSheet];
}

// with cancel button and other buttons, without title
- (void)showC:(NSString *)strCancel
      buttons:(NSArray *)aButtons
{
    _strTitle   = nil;
    _strCancel  = strCancel;
    _aButtons   = aButtons;
	_horizontalScrollingImages = nil;
	_horizontalScrollingAlAssets = nil;
	_alAssetsLibrary = nil;
	
	[self showActionSheet];
}

// with only buttons
- (void)show:(NSString *)strTitle
     buttons:(NSArray *)aButtons
{
    _strTitle   = strTitle;
    _strCancel  = nil;
    _aButtons   = aButtons;
	_horizontalScrollingImages = nil;
	_horizontalScrollingAlAssets = nil;
	_alAssetsLibrary = nil;

	[self showActionSheet];
}

// with only buttons, scrolling images, without title
- (void)show:(NSArray *)aButtons
{
	_strTitle   = nil;
	_strCancel  = nil;
	_aButtons   = aButtons;
	_horizontalScrollingImages = nil;
	_horizontalScrollingAlAssets = nil;
	_alAssetsLibrary = nil;
	
	[self showActionSheet];
}

// with only buttons, scrolling images, without title
- (void)show:(NSArray *)aButtons
	  images:(NSArray *)images
{
    _strTitle   = nil;
    _strCancel  = nil;
    _aButtons   = aButtons;
	_horizontalScrollingImages = images;
	_horizontalScrollingAlAssets = nil;
	_alAssetsLibrary = nil;

	[self showActionSheet];
}

- (UIImage *)scaledImageSubset:(UIImage *)original {
	int scaledWidth = [self scaledWidth];
	CGSize originalSize = [original size];
	int scaledHeight = (int)((CGFloat)(originalSize.height/originalSize.width)*(CGFloat)scaledWidth);
	return [original resizedImageWithMaximumSize:CGSizeMake(scaledWidth, scaledHeight)];
}

- (int)scaledDisplayHeight {
	return _nImageSubsetDisplayHeight?:125;
}

- (int)scaledWidth {
	return _nImageSubsetScaleWidth?:552;
}

- (void)updateFocusImage:(UIImage *)image {
	if (_nContentMode == DoASContentImage) {
		UIImage *iResized = [image resizedImageWithMaximumSize:CGSizeMake(360, 360)];
		BOOL needsReset = (_iImage == nil || !CGSizeEqualToSize([iResized size], [_iImage size]));

		_iImage = iResized;
		_imageView.frame = CGRectMake(self.doButtonInset.left, self.doButtonInset.top, iResized.size.width / 2, iResized.size.height / 2);
		_imageView.center = CGPointMake(_imageView.superview.center.x, _imageView.center.y);
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_imageView setImage:iResized];
		if (needsReset) {
			[self showActionSheet];
		}
	} else if (_nContentMode == DoASContentImageSubset) {
		_iImage = [self scaledImageSubset:image];
		[_imageView setImage:_iImage];
	}
}

- (void)updateHorizontallyScrollingImages:(NSArray *)images alAssetsLibrary:(ALAssetsLibrary *)alLibrary alAssets:(NSArray *)alAssets {

	self.doTitleInset = UIEdgeInsetsZero;
	_horizontalScrollingImages = images;
	_horizontalScrollingAlAssets = alAssets;
	_alAssetsLibrary = alLibrary;
	[self showActionSheet];
}

- (double)getTextHeight:(UILabel *)lbText
{
    double dHeight = 0.0;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
    {
        NSDictionary *attributes = @{NSFontAttributeName:lbText.font};
        CGRect rect = [lbText.text boundingRectWithSize:CGSizeMake(lbText.frame.size.width, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
        
        dHeight = ceil(rect.size.height);
    }
    else
    {
        CGSize size = [lbText.text sizeWithFont:lbText.font
                              constrainedToSize:CGSizeMake(lbText.frame.size.width, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        
        dHeight = ceil(size.height);
    }
    
    return dHeight;
}

- (void)setLabelAttributes:(UILabel *)lb
{
    lb.backgroundColor = [UIColor clearColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.numberOfLines = 0;
    
    lb.font = (self.doTitleFont == nil) ? DO_AS_TITLE_FONT : self.doTitleFont;
    lb.textColor = (self.doTitleTextColor == nil) ? DO_AS_TITLE_TEXT_COLOR : self.doTitleTextColor;
}

- (void)setButtonAttributes:(UIButton *)bt cancel:(BOOL)bCancel
{
    bt.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UIColor *buttonBackgroundColor;
    if (bCancel)
    {
		buttonBackgroundColor = (self.doCancelColor == nil) ? DO_AS_CANCEL_COLOR : self.doCancelColor;
        bt.backgroundColor = buttonBackgroundColor;
        bt.titleLabel.font = (self.doCancelFont == nil) ? DO_AS_TITLE_FONT : self.doCancelFont;
        [bt setTitleColor:(self.doCancelTextColor == nil) ? DO_AS_CANCEL_TEXT_COLOR : self.doCancelTextColor forState:UIControlStateNormal];
    }
    else
	{
		buttonBackgroundColor = (self.doButtonColor == nil) ? DO_AS_BUTTON_COLOR : self.doButtonColor;
		bt.backgroundColor = buttonBackgroundColor;
		bt.titleLabel.font = (self.doButtonFont == nil) ? DO_AS_BUTTON_FONT : self.doButtonFont;
		UIColor *buttonTextColor = (self.doButtonTextColor == nil) ? DO_AS_BUTTON_TEXT_COLOR : self.doButtonTextColor;
		[bt setTitleColor:buttonTextColor forState:UIControlStateNormal];
		[bt setTitleColor:(self.doSelectedButtonTextColor == nil) ? buttonTextColor : self.doSelectedButtonTextColor forState:UIControlStateHighlighted];
	}

    if (_dButtonRound > 0)
    {
        CALayer *layer = [bt layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:_dButtonRound];
    }

    [bt addTarget:self action:@selector(buttonTarget:) forControlEvents:UIControlEventTouchUpInside];

	[bt setBackgroundImage:nil forState:UIControlStateNormal];
	UIColor *selectedBackgroundColor = (self.doSelectedButtonColor == nil) ? buttonBackgroundColor : self.doSelectedButtonColor;
	[bt setBackgroundImage:[self imageWithColor:selectedBackgroundColor] forState:UIControlStateHighlighted];
}

- (UIImage *)imageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

- (void)showActionSheet
{
    double dHeight = 0;
    self.backgroundColor = (self.doDimmedColor == nil) ? DO_AS_DIMMED_COLOR : self.doDimmedColor;

	BOOL needShow = YES;
	if (_vActionSheet != nil) {
		needShow = NO;
		NSArray* subViews = [self subviews];
		for (UIView *aView in subViews) {
			[aView removeFromSuperview];
		}
	}

	// make back view -----------------------------------------------------------------------------------------------
    _vActionSheet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    _vActionSheet.backgroundColor = (self.doBackColor == nil) ? DO_AS_BACK_COLOR : self.doBackColor;
    [self addSubview:_vActionSheet];
    
    // Title --------------------------------------------------------------------------------------------------------
    if (_strTitle != nil && _strTitle.length > 0)
    {
        if (self.doTitleInset.top == 0 && self.doTitleInset.left == 0 && self.doTitleInset.bottom == 0 && self.doTitleInset.right == 0) {
            self.doTitleInset = DO_AS_TITLE_INSET;
        }
        
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.doTitleInset.left, self.doTitleInset.top,
                                                                     _vActionSheet.frame.size.width - (self.doTitleInset.left + self.doTitleInset.right) , 0)];
        lbTitle.text = _strTitle;
        [self setLabelAttributes:lbTitle];
        lbTitle.frame = CGRectMake(self.doTitleInset.left, self.doTitleInset.top, lbTitle.frame.size.width, [self getTextHeight:lbTitle]);
        lbTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_vActionSheet addSubview:lbTitle];
        
        dHeight = lbTitle.frame.size.height + self.doTitleInset.bottom;
        
        // underline
        UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(lbTitle.frame.origin.x, lbTitle.frame.origin.y + lbTitle.frame.size.height - 3, lbTitle.frame.size.width, 0.5)];
        vLine.backgroundColor = (self.doTitleTextColor == nil) ? DO_AS_TITLE_TEXT_COLOR : self.doTitleTextColor;
        vLine.alpha = 0.2;
        vLine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_vActionSheet addSubview:vLine];
    }
    else
        dHeight += self.doTitleInset.bottom;

    if (self.doButtonInset.top == 0 && self.doButtonInset.left == 0 && self.doButtonInset.bottom == 0 && self.doButtonInset.right == 0) {
        self.doButtonInset = DO_AS_BUTTON_INSET;
    }
	
	if ([_horizontalScrollingImages count]) {
		[self setupHorizontalScrollView:(self.doButtonInset.top + dHeight)];
		dHeight += self.doScrollingImagesHeight?:DO_SCROLLING_IMAGES_HEIGHT;
		dHeight += DO_AS_TITLE_INSET.bottom;	//put a standard title-gap below us
	}

	// add scrollview for many buttons and content
    UIScrollView *sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, dHeight + self.doButtonInset.top, 320, 370)];
    sc.backgroundColor = [UIColor clearColor];
    [_vActionSheet addSubview:sc];
    sc.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    double dYContent = 0;

    dYContent += [self addContent:sc];
    if (dYContent > 0)
        dYContent += self.doButtonInset.bottom + self.doButtonInset.top;

	CGFloat scale = [[UIScreen mainScreen] scale];
    // add buttons
    int nTagIndex = 0;
    for (NSString *str in _aButtons)
    {
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.tag = nTagIndex;
        [bt setTitle:str forState:UIControlStateNormal];
        
        [self setButtonAttributes:bt cancel:NO];
        bt.frame = CGRectMake(self.doButtonInset.left, dYContent,
                              _vActionSheet.frame.size.width - (self.doButtonInset.left + self.doButtonInset.right), (self.doButtonHeight > 0) ? self.doButtonHeight : DO_AS_BUTTON_HEIGHT);
        
        dYContent += ((self.doButtonHeight > 0) ? self.doButtonHeight : DO_AS_BUTTON_HEIGHT) + self.doButtonInset.bottom;
        
        [sc addSubview:bt];
		
		CGRect separatorFrame = bt.frame;
		separatorFrame.origin.y += separatorFrame.size.height;
		separatorFrame.origin.y ++;
		separatorFrame.size.height = (1.0/scale);
		UIView *separator = [[UIView alloc] initWithFrame:separatorFrame];
		[separator setBackgroundColor:[UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1]];
		dYContent += 2;
		[sc addSubview:separator];
		[separator setTranslatesAutoresizingMaskIntoConstraints:NO];
		NSArray *constraints = @[
								 [NSLayoutConstraint constraintWithItem:separator
															  attribute:NSLayoutAttributeTop
															  relatedBy:NSLayoutRelationEqual
																 toItem:bt
															  attribute:NSLayoutAttributeBottom
															 multiplier:1
															   constant:1],
								 [NSLayoutConstraint constraintWithItem:separator
															  attribute:NSLayoutAttributeHeight
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:1
															   constant:(1.0/scale)],
								 [NSLayoutConstraint constraintWithItem:separator
															  attribute:NSLayoutAttributeLeading
															  relatedBy:NSLayoutRelationEqual
																 toItem:bt
															  attribute:NSLayoutAttributeLeading
															 multiplier:1.0f
															   constant:0.0f],
								 [NSLayoutConstraint constraintWithItem:separator
															  attribute:NSLayoutAttributeTrailing
															  relatedBy:NSLayoutRelationEqual
																 toItem:bt
															  attribute:NSLayoutAttributeTrailing
															 multiplier:1.0f
															   constant:0.0f]
								 ];
		[sc addConstraints:constraints];

		if (nTagIndex == _nDestructiveIndex)
        {
            bt.backgroundColor = (self.doDestructiveColor == nil) ? DO_AS_DESTRUCTIVE_COLOR : self.doDestructiveColor;
            [bt setTitleColor:(self.doDestructiveTextColor == nil) ? DO_AS_DESTRUCTIVE_TEXT_COLOR : self.doDestructiveTextColor forState:UIControlStateNormal];
        }

        nTagIndex += 1;
   }
    
    sc.contentSize = CGSizeMake(sc.frame.size.width, dYContent);
    dHeight += self.doButtonInset.bottom + MIN(dYContent, sc.frame.size.height);
    
    // add Cancel button
    if (_strCancel != nil && _strCancel.length > 0)
    {
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.tag = DO_AS_CANCEL_TAG;
        [bt setTitle:_strCancel forState:UIControlStateNormal];
        
        [self setButtonAttributes:bt cancel:YES];
        bt.frame = CGRectMake(self.doButtonInset.left, dHeight + self.doButtonInset.top + self.doButtonInset.bottom,
                              _vActionSheet.frame.size.width - (self.doButtonInset.left + self.doButtonInset.right), (self.doButtonHeight > 0) ? self.doButtonHeight : DO_AS_BUTTON_HEIGHT);
        
        dHeight += ((self.doButtonHeight > 0) ? self.doButtonHeight : DO_AS_BUTTON_HEIGHT) + (self.doButtonInset.top + self.doButtonInset.bottom) * 2;
        
        [_vActionSheet addSubview:bt];
    }
    else
        dHeight += self.doButtonInset.bottom;
    
    _vActionSheet.frame = CGRectMake(0, 0, _vActionSheet.frame.size.width, dHeight + 10);

	
    if (!_actionWindow)
    {
		DoActionSheetController *viewController = [[DoActionSheetController alloc] initWithNibName:nil bundle:nil];
		viewController.actionSheet = self;

		UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        _actionWindow = window;
        
        self.frame = window.frame;
        _vActionSheet.center = window.center;
    }
    [_actionWindow makeKeyAndVisible];
    
    if (_dRound > 0)
    {
        CALayer *layer = [_vActionSheet layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:_dRound];
    }

	if (needShow) {
		[self showAnimation];
	} else {
		_vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 15,
										 self.bounds.size.width, _vActionSheet.frame.size.height);
	}
}

- (void)buttonTarget:(id)sender
{
	if (_delegate) {
		int buttonIndex = (int)[sender tag];
		if (buttonIndex == DO_AS_CANCEL_TAG) {
			[_delegate doActionSheetDidCancel:self];
		} else {
			NSString *buttonTitle = nil;
			if (buttonIndex >= 0 && buttonIndex <= [_aButtons count]) {
				buttonTitle = [_aButtons objectAtIndex:buttonIndex];
			}
			
			[_delegate doActionSheet:self didSelectButton:buttonIndex title:buttonTitle];
		}
	}
	[self hideAnimation];
}

- (void)imageButtonTarget:(id)sender
{
	if (_delegate) {
		int buttonIndex = (int)[sender tag];
		UIImage *buttonImage = nil;
		if (buttonIndex >= 0 && buttonIndex <= [_horizontalScrollingImages count]) {
			if ([_horizontalScrollingAlAssets count] > buttonIndex) {
				ALAsset *alAsset = [_horizontalScrollingAlAssets objectAtIndex:buttonIndex];
				ALAssetRepresentation *representation = [alAsset defaultRepresentation];
				buttonImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
			}
			if (buttonImage == nil) {
				buttonImage = [_horizontalScrollingImages objectAtIndex:buttonIndex];
			}
		}
		[_delegate doActionSheet:self didSelectImage:buttonIndex image:buttonImage];
	}
	[self hideAnimation];
}

- (double)addContent:(UIScrollView *)sc
{
    double dContentOffset = 0;
    
    if (self.doButtonInset.top == 0 && self.doButtonInset.left == 0 && self.doButtonInset.bottom == 0 && self.doButtonInset.right == 0) {
        self.doButtonInset = DO_AS_BUTTON_INSET;
    }
    switch (_nContentMode) {
        case DoASContentImage:
        {
            UIImageView *iv     = nil;
            if (_iImage != nil)
            {
                UIImage *iResized = [_iImage resizedImageWithMaximumSize:CGSizeMake(360, 360)];
                
                iv = [[UIImageView alloc] initWithImage:iResized];
                iv.contentMode = UIViewContentModeScaleAspectFit;
                iv.frame = CGRectMake(self.doButtonInset.left, self.doButtonInset.top, iResized.size.width / 2, iResized.size.height / 2);
                iv.center = CGPointMake(sc.center.x, iv.center.y);
                iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

                [sc addSubview:iv];
                dContentOffset = iv.frame.size.height + self.doButtonInset.bottom + self.doButtonInset.bottom;
            }
			_imageView = iv;
        }
            break;
        case DoASContentImageSubset:
        {
            UIImageView *iv = nil;
            if (_iImage != nil)
			{
				_iImage = [self scaledImageSubset:_iImage];
				int displayHeight = [self scaledDisplayHeight];
				iv = [[UIImageView alloc] initWithImage:_iImage];
				iv.contentMode = UIViewContentModeScaleAspectFill;
				iv.clipsToBounds = YES;
				iv.frame = CGRectMake(self.doButtonInset.left, self.doButtonInset.top, (sc.frame.size.width-(self.doButtonInset.left*2)), displayHeight);
				iv.center = CGPointMake(sc.center.x, iv.center.y);
				iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
				
				[sc addSubview:iv];
				dContentOffset = iv.frame.size.height + self.doButtonInset.bottom + self.doButtonInset.bottom;
				
				UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																								action:@selector(imageSubsetTapped:)];
				[tapRecognizer setNumberOfTapsRequired:1];
				[tapRecognizer setNumberOfTouchesRequired:1];
				[tapRecognizer setCancelsTouchesInView:NO];
				[tapRecognizer setDelaysTouchesBegan:NO];
				[iv setUserInteractionEnabled:YES];
				[iv addGestureRecognizer:tapRecognizer];
				[iv setTag:123456];
			}
            _imageView = iv;
        }			break;
			
        case DoASContentMap:
        {
            if (_dLocation == nil)
            {
                dContentOffset = 0;
                break;
            }
			
            MKMapView *vMap = [[MKMapView alloc] initWithFrame:CGRectMake(self.doButtonInset.left, self.doButtonInset.top,
                                                                          240, 180)];
            vMap.center = CGPointMake(sc.center.x, vMap.center.y);
            
            vMap.delegate = self;
            vMap.centerCoordinate = CLLocationCoordinate2DMake([_dLocation[@"latitude"] doubleValue], [_dLocation[@"longitude"] doubleValue]);
            vMap.camera.altitude = [_dLocation[@"altitude"] doubleValue];
            vMap.camera.pitch = 70;
            vMap.showsBuildings = YES;
            vMap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

            [sc addSubview:vMap];
            dContentOffset = 180 + self.doButtonInset.bottom;
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = vMap.centerCoordinate;
            annotation.title = @"Here~";
            [vMap addAnnotation:annotation];
        }
            break;
            
        default:
            break;
    }
    
    return dContentOffset;
}

- (void)hideActionSheet
{
	[self removeFromSuperview];
	[_actionWindow removeFromSuperview];
	//remove ourselves as the view for this VC
	[[_actionWindow rootViewController] setView:nil];
	//This should destroy the DoActionSheetController
	[_actionWindow setRootViewController:nil];
	_actionWindow = nil;
}

- (void)showAnimation
{
    self.alpha = 0.0;

    switch (_nAnimationType) {
        case DoASTransitionStyleNormal:
        case DoASTransitionStylePop:
            _vActionSheet.frame = CGRectMake(0, self.bounds.size.height,
                                             self.bounds.size.width, _vActionSheet.frame.size.height + _dRound + 5);
            break;

        case DoASTransitionStyleFade:
            _vActionSheet.alpha = 0.0;
            _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 5,
                                             self.bounds.size.width, _vActionSheet.frame.size.height + _dRound + 5);
            break;

        default:
            break;
    }
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.alpha = 1.0;

        [UIView setAnimationDelay:0.1];

        switch (_nAnimationType) {
            case DoASTransitionStyleNormal:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 15,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                
                break;
                
            case DoASTransitionStyleFade:
                _vActionSheet.alpha = 1.0;
                break;
                
            case DoASTransitionStylePop:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 10,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                
                break;
                
            default:
                break;
        }
    } completion:^(BOOL finished) {

        if (_nAnimationType == DoASTransitionStylePop)
        {
            [UIView animateWithDuration:0.1 animations:^(void) {

                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 18,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);

            } completion:^(BOOL finished) {

                [UIView animateWithDuration:0.1 animations:^(void) {
                    _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 15,
                                                     self.bounds.size.width, _vActionSheet.frame.size.height);
                    
                }];
            }];
        }
    }];
}

- (void)hideAnimation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [UIView animateWithDuration:0.2 animations:^(void) {

        switch (_nAnimationType) {
            case DoASTransitionStyleNormal:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                break;

            case DoASTransitionStyleFade:
                _vActionSheet.alpha = 0.0;
                break;
                
            case DoASTransitionStylePop:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 10,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);

                break;
        }

        [UIView setAnimationDelay:0.1];
        if (_nAnimationType != DoASTransitionStylePop)
        {
            _vActionSheet.alpha = 0.0;
            self.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {
        
        if (_nAnimationType == DoASTransitionStylePop)
        {
            [UIView animateWithDuration:0.1 animations:^(void) {
                
                [UIView setAnimationDelay:0.1];
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                
            } completion:^(BOOL finished) {

                [UIView animateWithDuration:0.1 animations:^(void) {
                    
                    [UIView setAnimationDelay:0.1];
                    self.alpha = 0.0;

                } completion:^(BOOL finished) {

                    [self hideActionSheet];
                
                }];
            }];
        }
        else
        {
            [self hideActionSheet];
        }
    }];
}

-(void)receivedRotate: (NSNotification *)notification
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [UIView animateWithDuration:0.2 animations:^(void) {
            _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 15,
                                             self.bounds.size.width, _vActionSheet.frame.size.height);
        }];
    });
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_vActionSheet.frame, pt))
        return;

	if (_delegate) {
		[_delegate doActionSheetDidCancel:self];
	}
    [self hideAnimation];
}

#pragma mark - Tap Gesture Recognizer

- (void)imageSubsetTapped:(UITapGestureRecognizer *)gesture {
	if (_delegate) {
		@autoreleasepool {
			//Need to cut a subset of _iImage
			CGSize scaledSize = [_imageView frame].size;	//the height of what we are showing
			CGSize imageSize = [_iImage size];
			CGFloat scale = imageSize.width / scaledSize.width;
			CGFloat cropHeight = (scaledSize.height * scale);
			int excessHeight = (int)((imageSize.height - cropHeight) / 2);
			CGRect cropRect = CGRectZero;
			cropRect.size.height = (int) cropHeight;
			cropRect.size.width = imageSize.width;
			cropRect.origin.x = 0;
			cropRect.origin.y = excessHeight;
			
			UIImage *croppedImage = [self croppedImage:_iImage withRect:cropRect];
			[_delegate doActionSheet:self didSelectImageSubset:croppedImage];
			[self hideAnimation];
		}
	}
}

#pragma mark - Image Resize

- (UIImage *)croppedImage:(UIImage *)image withRect:(CGRect)rect {
	
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
	CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
	[image drawInRect:drawRect];
	UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return subImage;
}


@end
