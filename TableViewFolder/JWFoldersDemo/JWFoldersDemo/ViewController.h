#import <UIKit/UIKit.h>
#import "FolderViewController.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    FolderViewController *sampleFolder;
    UILabel *_logo;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataSource;

@end
