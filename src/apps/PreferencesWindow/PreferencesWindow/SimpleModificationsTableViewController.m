#import "SimpleModificationsTableViewController.h"
#import "KarabinerKit/KarabinerKit.h"
#import "NotificationKeys.h"
#import "SimpleModificationsTableCellView.h"
#import "weakify.h"

@interface SimpleModificationsTableViewController ()

@property(weak) IBOutlet NSTableView* tableView;

@end

@implementation SimpleModificationsTableViewController

+ (void)selectPopUpButtonMenu:(NSPopUpButton*)popUpButton representedObject:(NSString*)representedObject {
  NSArray* items = popUpButton.itemArray;
  if (items) {
    for (NSMenuItem* item in items) {
      if ([item.representedObject isEqualToString:representedObject]) {
        [popUpButton selectItem:item];
        return;
      }
    }
  }
  [popUpButton selectItem:nil];
}

- (void)setup {
  [[NSNotificationCenter defaultCenter] addObserverForName:kKarabinerKitConfigurationIsLoaded
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification* note) {
                                                  [self.tableView reloadData];
                                                }];

  [[NSNotificationCenter defaultCenter] addObserverForName:kSelectedProfileChanged
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification* note) {
                                                  [self.tableView reloadData];
                                                }];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)valueChanged:(id)sender {
  NSInteger row = [self.tableView rowForView:sender];

  SimpleModificationsTableCellView* fromCellView = [self.tableView viewAtColumn:0 row:row makeIfNecessary:NO];
  SimpleModificationsTableCellView* toCellView = [self.tableView viewAtColumn:1 row:row makeIfNecessary:NO];

  NSString* fromValue = fromCellView.popUpButton.selectedItem.representedObject;
  if (fromValue && ![fromValue isEqualToString:@""]) {
    // If toCellView is not selected, set fromCellView value to toCellView.
    NSString* toValue = toCellView.popUpButton.selectedItem.representedObject;
    if (!toValue || [toValue isEqualToString:@""]) {
      [SimpleModificationsTableViewController selectPopUpButtonMenu:toCellView.popUpButton representedObject:fromValue];
      toValue = toCellView.popUpButton.selectedItem.representedObject;
    }
    toCellView.popUpButton.enabled = YES;

    KarabinerKitCoreConfigurationModel* coreConfigurationModel = [KarabinerKitConfigurationManager sharedManager].coreConfigurationModel;
    [coreConfigurationModel setSelectedProfileSimpleModificationAtIndex:row from:fromValue to:toValue];
    [coreConfigurationModel save];
  }
}

- (void)removeItem:(id)sender {
  NSInteger row = [self.tableView rowForView:sender];

  KarabinerKitCoreConfigurationModel* coreConfigurationModel = [KarabinerKitConfigurationManager sharedManager].coreConfigurationModel;
  [coreConfigurationModel removeSelectedProfileSimpleModificationAtIndex:row];
  [coreConfigurationModel save];

  [self.tableView reloadData];
}

- (IBAction)addItem:(id)sender {
  KarabinerKitCoreConfigurationModel* coreConfigurationModel = [KarabinerKitConfigurationManager sharedManager].coreConfigurationModel;
  [coreConfigurationModel addSimpleModificationToSelectedProfile];

  [self.tableView reloadData];
}

@end
