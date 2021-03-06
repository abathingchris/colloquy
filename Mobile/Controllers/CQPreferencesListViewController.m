#import "CQPreferencesListViewController.h"

#import "CQPreferencesListEditViewController.h"

@implementation CQPreferencesListViewController
- (id) init {
	if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
		return nil;

	_items = [[NSMutableArray alloc] init];

	self.addItemLabelText = NSLocalizedString(@"Add item", @"Add item label");
	self.noItemsLabelText = NSLocalizedString(@"No items", @"No items label");
	self.editViewTitle = NSLocalizedString(@"Edit", @"Edit view title");

	self.navigationItem.rightBarButtonItem = self.editButtonItem;

	return self;
}

- (void) dealloc {
	[_items release];
	[_itemImage release];
	[_addItemLabelText release];
	[_noItemsLabelText release];
	[_editViewTitle release];
	[_editPlaceholder release];
	[_editingView release];
	[super dealloc];
}

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	self.tableView.allowsSelectionDuringEditing = YES;
}

- (void) viewWillAppear:(BOOL) animated {
	UITableView *tableView = self.tableView;

	if (_editingView) {
		NSIndexPath *changedIndexPath = [NSIndexPath indexPathForRow:_editingIndex inSection:0];
		NSArray *changedIndexPaths = [NSArray arrayWithObject:changedIndexPath];

		if (_editingIndex < _items.count) {
			if (_editingView.listItemText.length)
				[_items replaceObjectAtIndex:_editingIndex withObject:_editingView.listItemText];
			else [_items removeObjectAtIndex:_editingIndex];

			_pendingChanges = YES;

			[tableView beginUpdates];

			[tableView deleteRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationFade];

			if (_editingView.listItemText.length)
				[tableView insertRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationFade];

			[tableView endUpdates];
		} else if (_editingView.listItemText.length) {
			[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];

			[_items insertObject:_editingView.listItemText atIndex:_editingIndex];
			_pendingChanges = YES;

			[tableView insertRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationFade];

			[tableView selectRowAtIndexPath:changedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		}

		[_editingView release];
		_editingView = nil;
	}

	[super viewWillAppear:animated];

	if (!_items.count)
		self.editing = YES;
}

- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear:animated];

	if (_editingView || !_pendingChanges || !_action)
		return;

	if (!_target || [_target respondsToSelector:_action])
		if ([[UIApplication sharedApplication] sendAction:_action to:_target from:self forEvent:nil])
			_pendingChanges = NO;
}

#pragma mark -

@synthesize addItemLabelText = _addItemLabelText;

@synthesize noItemsLabelText = _noItemsLabelText;

@synthesize editViewTitle = _editViewTitle;

@synthesize editPlaceholder = _editPlaceholder;

@synthesize target = _target;

@synthesize action = _action;

@synthesize itemImage = _itemImage;

- (void) setItemImage:(UIImage *) image {
	id old = _itemImage;
	_itemImage = [image retain];
	[old release];

	[self.tableView reloadData];
}

@synthesize items = _items;

- (void) setItems:(NSArray *) items {
	_pendingChanges = NO;

	[_items setArray:items];

	[self.tableView reloadData];
}

#pragma mark -

- (void) editItemAtIndex:(NSUInteger) index {
	if (_editingView)
		return;

	_editingIndex = index;
	_editingView = [[CQPreferencesListEditViewController alloc] init];

	_editingView.title = _editViewTitle;
	_editingView.listItemText = (index < _items.count ? [_items objectAtIndex:index] : @"");
	_editingView.listItemPlaceholder = _editPlaceholder;

	[self.navigationController pushViewController:_editingView animated:YES];
}

#pragma mark -

- (void) setEditing:(BOOL) editing animated:(BOOL) animated {
	[super setEditing:editing animated:animated];

	if (_items.count) {
		NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:_items.count inSection:0]];
		if (editing) [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
		else [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];

		// Workaround a display bug where the cell separator isn't drawn for the new row.
		if (editing) [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
	} else {
		[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
	}

	if (!editing && _pendingChanges && _action && (!_target || [_target respondsToSelector:_action]))
		if ([[UIApplication sharedApplication] sendAction:_action to:_target from:self forEvent:nil])
			_pendingChanges = NO;
}

#pragma mark -

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	if (!self.editing && !_items.count)
		return 1;
	if (self.editing)
		return (_items.count + 1);
	return _items.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell = [UITableViewCell reusableTableViewCellInTableView:tableView];

	cell.hidesAccessoryWhenEditing = NO;

	if (indexPath.row < _items.count) {
		cell.textColor = [UIColor blackColor];
		cell.text = [_items objectAtIndex:indexPath.row];
		cell.image = _itemImage;
	} else if (self.editing) {
		cell.textColor = [UIColor blackColor];
		cell.text = _addItemLabelText;
		cell.image = nil;
	} else {
		cell.textColor = [UIColor lightGrayColor];
		cell.text = _noItemsLabelText;
		cell.image = nil;
	}

	return cell;
}

- (NSIndexPath *) tableView:(UITableView *) tableView willSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	if (self.editing)
		return indexPath;
	return nil;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	[self editItemAtIndex:indexPath.row];
}

- (UITableViewCellEditingStyle) tableView:(UITableView *) tableView editingStyleForRowAtIndexPath:(NSIndexPath *) indexPath {
	if (!self.editing)
		return UITableViewCellEditingStyleNone;

	if (indexPath.row >= _items.count)
		return UITableViewCellEditingStyleInsert;

	return UITableViewCellEditingStyleDelete;
}

- (BOOL) tableView:(UITableView *) tableView canEditRowAtIndexPath:(NSIndexPath *) indexPath {
	return YES;
}

- (void) tableView:(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[_items removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		_pendingChanges = YES;
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[self editItemAtIndex:indexPath.row];
	}
}

- (BOOL) tableView:(UITableView *) tableView canMoveRowAtIndexPath:(NSIndexPath *) indexPath {
	return (indexPath.row < _items.count);
}

- (UITableViewCellAccessoryType) tableView:(UITableView *) tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *) indexPath {
	return (self.editing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
}

- (NSIndexPath *) tableView:(UITableView *) tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *) sourceIndexPath toProposedIndexPath:(NSIndexPath *) proposedDestinationIndexPath {
	if (proposedDestinationIndexPath.row >= _items.count)
		return [NSIndexPath indexPathForRow:(_items.count - 1) inSection:0];
	return proposedDestinationIndexPath;
}

- (void) tableView:(UITableView *) tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath toIndexPath:(NSIndexPath *) toIndexPath {
	if (toIndexPath.row >= _items.count)
		return;

	id item = [[_items objectAtIndex:fromIndexPath.row] retain];
	[_items removeObject:item];
	[_items insertObject:item atIndex:toIndexPath.row];
	[item release];

	_pendingChanges = YES;
}
@end
