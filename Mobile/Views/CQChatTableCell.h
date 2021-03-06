@class MVChatUser;
@class CQUnreadCountView;
@protocol CQChatViewController;

@interface CQChatTableCell : UITableViewCell {
	UIImageView *_iconImageView;
	UILabel *_nameLabel;
	CQUnreadCountView *_unreadCountView;
	NSString *_removeConfirmationText;
	NSMutableArray *_chatPreviewLabels;
	NSUInteger _maximumMessagePreviews;
	BOOL _showsUserInMessagePreviews;
	BOOL _available;
}
- (void) takeValuesFromChatViewController:(id <CQChatViewController>) controller;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) UIImage *icon;
@property (nonatomic) BOOL available;
@property (nonatomic) NSUInteger unreadCount;
@property (nonatomic) NSUInteger importantUnreadCount;

@property (nonatomic, copy) NSString *removeConfirmationText;
@property (nonatomic) NSUInteger maximumMessagePreviews;
@property (nonatomic) BOOL showsUserInMessagePreviews;
@property (nonatomic) BOOL showsIcon;

- (void) addMessagePreview:(NSString *) message fromUser:(MVChatUser *) user asAction:(BOOL) action animated:(BOOL) animated;
@end
