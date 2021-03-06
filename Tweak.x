#import <UIKit/UIKit.h>
#import <CaptainHook/CaptainHook.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (SBBKit)

+(UIImage*) kitImageNamed:(NSString*) name;

@end

@interface SBApplication : NSObject

-(int) statusBarStyle;

@end

@interface SpringBoard : UIApplication

-(SBApplication*) _accessibilityFrontMostApplication;

@end

@class BBAction, BBObserver, BBAssertion, BBAttachments, BBSound, BBContent;

@interface BBBulletin : NSObject <NSCopying, NSCoding>
@property(copy, nonatomic) NSSet *alertSuppressionAppIDs_deprecated;
@property(assign, nonatomic) unsigned realertCount_deprecated;
@property(retain, nonatomic) BBObserver *observer;
@property(retain, nonatomic) BBAssertion *lifeAssertion;
@property(copy, nonatomic) BBAction *expireAction;
@property(retain, nonatomic) NSDate *expirationDate;
@property(retain, nonatomic) NSMutableDictionary *actions;
@property(copy, nonatomic) NSString *unlockActionLabelOverride;
@property(retain, nonatomic) BBAttachments *attachments;
@property(retain, nonatomic) BBContent *content;
@property(retain, nonatomic) NSDate *lastInterruptDate;
@property(retain, nonatomic) NSDictionary *context;
@property(assign, nonatomic) BOOL expiresOnPublisherDeath;
@property(copy, nonatomic) NSArray *buttons;
@property(copy, nonatomic) BBAction *replyAction;
@property(copy, nonatomic) BBAction *acknowledgeAction;
@property(copy, nonatomic) BBAction *defaultAction;
@property(readonly, assign, nonatomic) int primaryAttachmentType;
@property(retain, nonatomic) BBSound *sound;
@property(assign, nonatomic) BOOL clearable;
@property(assign, nonatomic) int accessoryStyle;
@property(retain, nonatomic) NSTimeZone *timeZone;
@property(assign, nonatomic) BOOL dateIsAllDay;
@property(assign, nonatomic) int dateFormatStyle;
@property(retain, nonatomic) NSDate *recencyDate;
@property(retain, nonatomic) NSDate *endDate;
@property(retain, nonatomic) NSDate *date;
@property(retain, nonatomic) BBContent *modalAlertContent;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *subtitle;
@property(copy, nonatomic) NSString *title;
@property(assign, nonatomic) int sectionSubtype;
@property(assign, nonatomic) int addressBookRecordID;
@property(copy, nonatomic) NSString *publisherBulletinID;
@property(copy, nonatomic) NSString *recordID;
@property(copy, nonatomic) NSString *sectionID;
@property(copy, nonatomic) NSString *section;
@property(copy, nonatomic) NSString *bulletinID;
+ (id)bulletinWithBulletin:(id)bulletin;
- (void)_fillOutCopy:(id)copy withZone:(NSZone*)zone;
- (void)deliverResponse:(id)response;
- (id)responseSendBlock;
- (id)responseForExpireAction;
- (id)responseForButtonActionAtIndex:(unsigned)index;
- (id)responseForAcknowledgeAction;
- (id)responseForReplyAction;
- (id)responseForDefaultAction;
- (id)_responseForActionKey:(id)actionKey;
- (id)_actionKeyForButtonIndex:(unsigned)buttonIndex;
- (id)attachmentsCreatingIfNecessary:(BOOL)necessary;
- (NSUInteger)numberOfAdditionalAttachmentsOfType:(int)type;
- (NSUInteger)numberOfAdditionalAttachments;
@end

@interface SBBulletinBannerItem : NSObject {
	BBBulletin *_seedBulletin;
	NSArray *_additionalBulletins;
}
+ (id)itemWithBulletin:(BBBulletin *)bulletin;
+ (id)itemWithSeedBulletin:(BBBulletin *)seedBulletin additionalBulletins:(NSArray *)bulletins;
- (id)_initWithSeedBulletin:(BBBulletin *)seedBulletin additionalBulletins:(NSArray *)bulletins;
- (UIImage *)attachmentImage;
- (UIImage *)iconImage;
- (NSString *)_appName;
- (NSString *)title;
- (NSString *)message;
- (NSString *)attachmentText;
- (BOOL)playSound;
- (void)killSound;
- (void)sendResponse;
- (id)launchBlock;
- (BBBulletin *)seedBulletin;
@end

@interface SBBannerView : UIView {
	SBBulletinBannerItem *_item;
	UIView *_iconView;
	UILabel *_titleLabel;
	UILabel *_messageLabel;
	CGFloat _imageWidth;
	UIImageView *_bannerView;
	UIView *_underlayView;
}
- (id)initWithItem:(SBBulletinBannerItem *)item;
- (SBBulletinBannerItem *)item;
- (void)_createSubviewsWithBannerImage:(UIImage *)bannerImage;
- (UIImage *)_bannerMaskStretchedToWidth:(CGFloat)width;
- (UIImage *)_bannerImageWithAttachmentImage:(UIImage *)attachmentImage;
@end

@interface SBBannerAndShadowView : NSObject

-(SBBannerView*) banner;

@end

@interface SBBulletinBannerController : NSObject

+(SBBulletinBannerController*) sharedInstance;
-(void) dismissBanner;

@end

@interface UILabel (Marquee)
- (void)setMarqueeEnabled:(BOOL)marqueeEnabled;
- (void)setMarqueeRunning:(BOOL)marqueeRunning;
@end

// Thanks to NCPad for this code!
#define SBBWidthForOrient(orient) (UIDeviceOrientationIsLandscape(orient)||UIInterfaceOrientationIsLandscape(orient)?[[UIScreen mainScreen]bounds].size.height:[[UIScreen mainScreen]bounds].size.width)

%config(generator=internal);

%hook SBBulletinBannerController

-(CGRect)_normalBannerFrameForOrientation:(int)orientation
{
	CGRect frame = %orig;
	frame.origin.x = 0;
	frame.size.width = SBBWidthForOrient(orientation);
	frame.size.height = 20.0f;
	return frame;
}

-(CGRect)_currentBannerFrameForOrientation:(int)orientation
{
	CGRect frame = %orig;
	frame.origin.x = 0;
	frame.size.width = SBBWidthForOrient(orientation);
	frame.size.height = 20.0f;
	return frame;
}

static NSTimeInterval dismissInterval(SBBulletinBannerController* ctr, SEL selector, NSTimeInterval delay)
{
	NSString* selStr = NSStringFromSelector(selector);
	if ([selStr isEqualToString:@"_dismissIntervalElapsed"])
	{
		SBBannerAndShadowView** _bannerAndShadowView = CHIvarRef(ctr, _bannerAndShadowView, SBBannerAndShadowView*);
		SBBannerView* banner = [*_bannerAndShadowView banner];

		UILabel** _titleLabel = CHIvarRef(banner, _titleLabel, UILabel*);
		UILabel** _messageLabel = CHIvarRef(banner, _messageLabel, UILabel*);

		NSString* text = ([*_messageLabel isHidden] ? [*_titleLabel text] : [*_messageLabel text]);
		CGSize size = [text sizeWithFont:[*_messageLabel font]];

		float distance = size.width - [*_messageLabel frame].size.width;
		if (distance > 0)
			return MAX(6.5f, (distance / 30.0f) + 2.0f);
	}

	return delay;
}

-(void) performSelector:(SEL) selector withObject:(id) obj afterDelay:(NSTimeInterval) delay inModes:(NSArray*) modes
{
	delay = dismissInterval(self, selector, delay);
	%orig;
}

%end

/*
%hook SBBannerAndShadowView

- (void)setBannerFrame:(CGRect)frame
{
	frame.origin.x = 0.0f;
	frame.size.height = 20.0f;
	frame.size.width = [UIScreen mainScreen].bounds.size.width;
	%orig();
}

- (CGRect)_frameForBannerFrame:(CGRect)bannerFrame
{
	CGRect result = %orig();
	result.origin.x = 0.0f;
	result.size.height -= 20.0f;
	result.size.width = [UIScreen mainScreen].bounds.size.width;
	return result;
}

%end
*/

%hook SBBannerView

- (UIImage *)_bannerImageWithAttachmentImage:(UIImage *)attachmentImage
{
	return nil;
}

static BOOL DBShouldHideBiteSMSButton()
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpetrich.dietbulletin.plist"];
	NSNumber* bite = [settings objectForKey:@"DBHideBiteSMSButton"];
	return bite.boolValue;
}

static int DBBannerStyle()
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpetrich.dietbulletin.plist"];
	NSNumber* style = [settings objectForKey:@"DBBannerStyle"];
	return style.intValue;
}

static BOOL DBShouldShowTitleForDisplayIdentifier(NSString *displayIdentifier)
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpetrich.dietbulletin.plist"];

	id smart = [settings objectForKey:@"DBSmartTitles"];
	if ([smart boolValue])
	{
		return ([displayIdentifier rangeOfString:@"com.apple."].location == 0);
	}

	NSString *key = [NSString stringWithFormat:@"DBShowTitle-%@", displayIdentifier];
	id value = [settings objectForKey:key];
	return !value || [value boolValue];
}

static int statusBarStyle()
{
	SpringBoard* sb = (SpringBoard*)[UIApplication sharedApplication];
	SBApplication* app = [sb _accessibilityFrontMostApplication];
	int sbStyle = (app ? app.statusBarStyle : sb.statusBarStyle);
	switch (DBBannerStyle())
	{
		case 1: 
			return (sbStyle == 0 ? 2 : 0);
		case 2:
			return 2;
		case 3:
			return 0;
	}

	return sbStyle;
}

- (SBBannerView*)initWithItem:(id)item
{
	if ((self = %orig())) 
	{
		UISwipeGestureRecognizer* gr = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBannerRight)] autorelease];
		[self addGestureRecognizer:gr];

//		gr = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBannerLeft)] autorelease];
//		gr.direction = UISwipeGestureRecognizerDirectionLeft;
//		[self addGestureRecognizer:gr];

		[self setClipsToBounds:YES];

		CALayer* layer = self.layer;
		switch (statusBarStyle())
		{
			case 0:
				[self setBackgroundColor:[UIColor blackColor]];
				layer.contents = (id)[UIImage kitImageNamed:@"Silver_Base.png"].CGImage;
				break;
			default:
				[self setBackgroundColor:[UIColor blackColor]];
				layer.contents = (id)[UIImage kitImageNamed:@"Black_Base.png"].CGImage;
				break;
		}
	}
	return self;
}


- (void)layoutSubviews
{
	%orig();
	UIImageView **_iconView = CHIvarRef(self, _iconView, UIImageView *);
	UILabel **_titleLabel = CHIvarRef(self, _titleLabel, UILabel *);
	UILabel **_messageLabel = CHIvarRef(self, _messageLabel, UILabel *);
	UIView **_underlayView = CHIvarRef(self, _underlayView, UIView *);
	if (_iconView && _titleLabel && _messageLabel && _underlayView) {
		float width = 16.0f;
		[*_iconView setFrame:(CGRect){ { 1.0f, 2.0f }, { width, width } }];
		CGRect bounds = [self bounds];

		switch (statusBarStyle())
		{
			case 0:
				[*_titleLabel setTextColor:[UIColor blackColor]];
				[*_messageLabel setTextColor:[UIColor blackColor]];
				break;
			case 1:
				[*_titleLabel setTextColor:[UIColor whiteColor]];
				[*_messageLabel setTextColor:[UIColor whiteColor]];
				break;
			default:
				[*_titleLabel setTextColor:[UIColor whiteColor]];
				[*_messageLabel setTextColor:[UIColor whiteColor]];
				break;
		}

		[*_messageLabel setFont:[UIFont boldSystemFontOfSize:12]];
		[*_titleLabel setFont:[UIFont boldSystemFontOfSize:12]];

		// handle biteSMS button
		UIView* b = [self viewWithTag:844610];
		b.hidden = DBShouldHideBiteSMSButton();

		if (*_messageLabel == nil)
		{
			[*_titleLabel setFrame:(CGRect){ { width + 6.0f, 0.5f }, { bounds.size.width - width - 8.0f - (b != nil && !b.hidden ? 40 : 0), 19.0f } }];
		}
		else
		{
			if (![*_titleLabel isHidden])
			{
				if (DBShouldShowTitleForDisplayIdentifier(self.item.seedBulletin.sectionID)) 
				{
					NSString* title = [*_titleLabel text];
					NSString* message = [*_messageLabel text];
				
					NSMutableString* str = [NSMutableString stringWithCapacity:10];
					if (title.length > 0)
					{
						[str appendString:title];
						if (message.length > 0)
							[str appendString:@": "];
					}
	
					if (message.length > 0)
						[str appendString:message];
					
					[*_messageLabel setText:str];
				}
			}
	
			[*_titleLabel setHidden:YES];
	
			// Fix for Reveal - since Reveal puts the messageLabel in a scrollview, this catches that case.
			BOOL isMessageScrolling = [[*_messageLabel superview] isKindOfClass:UIScrollView.class];
	
			if (isMessageScrolling)
			{
				[*_messageLabel sizeToFit];
				[[*_messageLabel superview] setFrame:(CGRect){ { width + 6.0f, 2.0f }, { bounds.size.width - width - 8.0f - (b != nil && !b.hidden ? 40 : 0), 19.0f } }];
			}
			else
			{
				[*_messageLabel setFrame:(CGRect){ { width + 6.0f, 0.5f }, { bounds.size.width - width - 8.0f - (b != nil && !b.hidden ? 40 : 0), 19.0f } }];
	
				if ([UILabel instancesRespondToSelector:@selector(setMarqueeEnabled:)] && [UILabel instancesRespondToSelector:@selector(setMarqueeRunning:)]) {
					[*_messageLabel setMarqueeEnabled:YES];
					[*_messageLabel setMarqueeRunning:YES];
				}
			}
	
			[*_underlayView setHidden:YES];
		}
	}
}

%new -(void) swipeBannerRight
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect r = self.frame;
        r.origin.x = 2000;
        self.frame = r;
    } completion:^(BOOL finished) {        
        [[%c(SBBulletinBannerController) sharedInstance] dismissBanner];
    }];
}

%new -(void) swipeBannerLeft
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect r = self.frame;
        r.origin.x = -2000;
        self.frame = r;
    } completion:^(BOOL finished) {        
        [[%c(SBBulletinBannerController) sharedInstance] dismissBanner];
    }];
}

%end

static NSInteger suppressMessageOverride;
static NSMutableDictionary *textExtractors;

typedef struct {
	NSRange titleRange;
	NSRange messageRange;
} DBTextRanges;
typedef DBTextRanges (^DBTextExtractor)(NSString *message);

%hook SBBulletinBannerItem

- (NSString *)title
{
	NSString *displayIdentifier = self.seedBulletin.sectionID;
	DBTextExtractor extractor = (DBTextExtractor)[textExtractors objectForKey:displayIdentifier];
	if (extractor) {
		if (DBShouldShowTitleForDisplayIdentifier(displayIdentifier)) {
			suppressMessageOverride++;
			NSString *message = self.message;
			suppressMessageOverride--;
			DBTextRanges result = extractor(message);
			if (result.titleRange.location != NSNotFound) {
				return [message substringWithRange:result.titleRange];
			}
		}
	}
	return %orig();
}

- (NSString *)message
{
	if (suppressMessageOverride) {
		return %orig();
	}
	NSString *displayIdentifier = self.seedBulletin.sectionID;
	DBTextExtractor extractor = (DBTextExtractor)[textExtractors objectForKey:displayIdentifier];
	if (extractor) {
		if (DBShouldShowTitleForDisplayIdentifier(displayIdentifier)) {
			NSString *message = %orig();
			DBTextRanges result = extractor(message);
			if (result.messageRange.location != NSNotFound) {
				return [message substringWithRange:result.messageRange];
			}
			return message;
		}
	}
	return %orig();
}

%end

static inline void DBRegisterTextExtractor(NSString *displayIdentifier, DBTextExtractor textExtractor)
{
	[textExtractors setObject:textExtractor forKey:displayIdentifier];
}

static inline DBTextRanges DBTextExtractUnchanged(NSString *message)
{
	return (DBTextRanges){ (NSRange){ NSNotFound, -1 }, (NSRange){ 0, [message length] } };
}

static inline DBTextRanges DBTextExtractAllAsTitle(NSString *message)
{
	return (DBTextRanges){ (NSRange){ 0, [message length] }, (NSRange){ 0, 0 } };
}

static inline DBTextRanges DBTextExtractSplitAround(NSString *message, NSInteger skipBefore, NSInteger continueInto, NSString *splitAround, NSInteger skipAfter, NSInteger skipEnd)
{
	NSInteger length = [message length];
	NSInteger location = [message rangeOfString:splitAround options:0 range:(NSRange) { skipBefore, length - skipBefore }].location;
	if (location != NSNotFound) {
		return (DBTextRanges){ (NSRange){ skipBefore, location - skipBefore + continueInto }, (NSRange){ location + skipAfter, length - location - skipAfter - skipEnd } };
	}
	return DBTextExtractUnchanged(message);
}

static BOOL characterAtIndexIsUpperCase(NSString *text, NSInteger index)
{
	NSString *justCharacter = [text substringWithRange:(NSRange){ index, 1 }];
	return ![justCharacter isEqualToString:[justCharacter lowercaseString]];
}

static inline DBTextRanges DBTextExtractLeadingCapitals(NSString *message)
{
	NSInteger length = [message length];
	NSInteger spaceLocation;
	NSRange remainingRange = (NSRange){ 0, length - 1 };
	while ((spaceLocation = [message rangeOfString:@" " options:0 range:remainingRange].location) != NSNotFound) {
		if (!characterAtIndexIsUpperCase(message, spaceLocation + 1)) {
			return (DBTextRanges){ (NSRange){ 0, spaceLocation }, (NSRange){ spaceLocation + 1, length - spaceLocation - 1} };
		}
		remainingRange.location = spaceLocation + 1;
		remainingRange.length = length - spaceLocation - 2;
	}
	return DBTextExtractUnchanged(message);
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init();
	textExtractors = [[NSMutableDictionary alloc] init];
	// Tweetbot
	DBRegisterTextExtractor(@"com.tapbots.Tweetbot", ^(NSString *message){
		return DBTextExtractSplitAround(message, 0, 0, @" ", 1, 0);
	});
	// Instagram
	DBRegisterTextExtractor(@"com.burbn.instagram", ^(NSString *message){
		return DBTextExtractSplitAround(message, 0, 0, @" ", 1, 0);
	});
	// Foursquare
	DBRegisterTextExtractor(@"com.naveenium.foursquare", ^(NSString *message){
		return DBTextExtractSplitAround(message, 0, 1, @". ", 2, 0);
	});
	// Whatsapp
	DBRegisterTextExtractor(@"net.whatsapp.WhatsApp", ^(NSString *message){
		return DBTextExtractSplitAround(message, 0, 0, @": ", 2, 0);
	});
	// PayPal
	DBRegisterTextExtractor(@"com.yourcompany.PPClient", ^(NSString *message){
		if ([message hasPrefix:@"You received "]) {
			return DBTextExtractSplitAround(message, 13, 0, @" from ", 1, 0);
		}
		return DBTextExtractUnchanged(message);
	});
	// Skype
	DBRegisterTextExtractor(@"com.skype.skype", ^(NSString *message){
		if ([message hasPrefix:@"Call from "] || [message hasPrefix:@"Voicemail from "]) {
			return DBTextExtractAllAsTitle(message);
		}
		if ([message hasPrefix:@"New message from "]) {
			return DBTextExtractSplitAround(message, 17, 0, @": ", 2, 0);
		}
		return DBTextExtractUnchanged(message);
	});
	// BeejiveIM
	DBRegisterTextExtractor(@"com.beejive.BeejiveIM", ^(NSString *message){
		return DBTextExtractSplitAround(message, 0, 0, @": ", 2, 0);
	});
	// Trillian
	DBRegisterTextExtractor(@"com.ceruleanstudios.trillian.iphone", ^(NSString *message){
		return DBTextExtractSplitAround(message, 0, 0, @": ", 2, 0);
	});
	// Facebook
	DBRegisterTextExtractor(@"com.facebook.Facebook", ^(NSString *message){
		return DBTextExtractLeadingCapitals(message);
	});
	// Batch
	DBRegisterTextExtractor(@"com.batch.batch-iphone", ^(NSString *message){
		return DBTextExtractLeadingCapitals(message);
	});
	// Path
	DBRegisterTextExtractor(@"com.path.Path", ^(NSString *message){
		return DBTextExtractLeadingCapitals(message);
	});
	[pool drain];
}
