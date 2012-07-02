#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "JWFolders.h"

#define CELL_HEIGHT 75

@implementation ViewController
@synthesize tableView = _tableView;
@synthesize dataSource = _dataSource;

- (void)loadView {
    [super loadView];
    self.dataSource = [NSArray arrayWithObjects:@"Clothes", @"Knife", @"Gun", @"Rose",@"GOd", @"lady", @"wrong", @"COCOCOA", nil];
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
}

#pragma mark - Folder Example


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    [[cell textLabel] setText:[self.dataSource objectAtIndex:indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell)
        return;
    
    NSLog(@"%f", tableView.contentOffset.y);
    CGPoint openPoint = CGPointMake(.0f, cell.frame.origin.y+cell.frame.size.height-tableView.contentOffset.y); //arbitrary point
    sampleFolder = [[FolderViewController alloc] initWithNibName:NSStringFromClass([FolderViewController class]) bundle:nil];
    CGRect frame = sampleFolder.view.frame;
    if (openPoint.y < 260)
        frame.origin.y = openPoint.y;
    else
        frame.origin.y = 260;
    sampleFolder.view.frame = frame;
    [self openFolderWithContentView:sampleFolder.view position:openPoint];
}

- (void)openFolderWithContentView:(UIView *)contentView position:(CGPoint)openPoint {
    [JWFolders openFolderWithContentView:contentView
                                position:openPoint 
                           containerView:self.view 
                                  sender:self 
                               openBlock:^(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                   //perform custom animation here on contentView if you wish
                                   NSLog(@"Folder view: %@ is opening with duration: %f", contentView, duration);
                               }
                              closeBlock:^(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                  //also perform custom animation here on contentView if you wish
                                  NSLog(@"Folder view: %@ is closing with duration: %f", contentView, duration);
                              }
                         completionBlock:^ {
                             //the folder is closed and gone, lets do something cool!
                             NSLog(@"Folder view is closed.");
                         }
     ];

}
@end
