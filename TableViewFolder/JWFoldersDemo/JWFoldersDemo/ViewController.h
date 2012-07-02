#import <UIKit/UIKit.h>
#import "FolderViewController.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    FolderViewController *sampleFolder;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataSource;

@end
