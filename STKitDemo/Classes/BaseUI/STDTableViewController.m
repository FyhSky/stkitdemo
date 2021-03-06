//
//  STDTableViewController.m
//  STKitDemo
//
//  Created by SunJiangting on 13-12-27.
//  Copyright (c) 2013年 SunJiangting. All rights reserved.
//

#import "STDTableViewController.h"

@interface STDTableViewController ()

@property(nonatomic, strong) UITableView       *tableView;
@property(nonatomic, assign) UITableViewStyle   tableViewStyle;
@property(nonatomic, strong) STScrollDirector  *scrollDirector;

@end

@implementation STDTableViewController

- (instancetype) initWithStyle:(UITableViewStyle)tableViewStyle {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.tableViewStyle = tableViewStyle;
        self.clearsSelectionOnViewWillAppear = YES;
        
        self.scrollDirector = [[STScrollDirector alloc] init];
        [self.scrollDirector setTitle:@"下拉可以刷新" forState:STScrollDirectorStateRefreshNormal];
        [self.scrollDirector setTitle:@"松手开始刷新" forState:STScrollDirectorStateRefreshReachedThreshold];
        [self.scrollDirector setTitle:@"正在刷新..." forState:STScrollDirectorStateRefreshLoading];
        
        [self.scrollDirector setTitle:@"加载更多" forState:STScrollDirectorStatePaginationNormal];
        [self.scrollDirector setTitle:@"正在加载更多" forState:STScrollDirectorStatePaginationLoading];
        [self.scrollDirector setTitle:@"重新加载" forState:STScrollDirectorStatePaginationFailed];
        [self.scrollDirector setTitle:@"没有更多了" forState:STScrollDirectorStatePaginationReachedEnd];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)loadView {
    [super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGFloat value = [[[STPersistence standardPersistence] valueForKey:@"STDNavigationDefaultEdgeOffset"] doubleValue];
    if (value == 0) {
        value = 80;
        [[STPersistence standardPersistence] setValue:@(value) forKey:@"STDNavigationDefaultEdgeOffset"];
    }
    self.st_maximumInteractivePopEdgeDistance = value;

    CGFloat value1 = [[[STPersistence standardPersistence] valueForKey:@"STDNavigationDefaultOffset"] floatValue];
    if (value1 == 0) {
        value1 = 80;
        [[STPersistence standardPersistence] setValue:@(value1) forKey:@"STDNavigationDefaultOffset"];
    }
    self.st_interactivePopTransitionOffset = value1;
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(maximumInteractiveDistanceChanged:)
                                                 name:@"STDNavigationDefaultEdgeOffset"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(maximumInteractiveOffsetChanged:)
                                                 name:@"STDNavigationDefaultOffset"
                                               object:nil];
    
    self.scrollDirector.scrollView = self.tableView;
    [self.scrollDirector.refreshControl addTarget:self action:@selector(_refreshControlActionFired:) forControlEvents:UIControlEventValueChanged];
    [self.scrollDirector.paginationControl addTarget:self action:@selector(_paginationControlActionFired:) forControlEvents:UIControlEventValueChanged];
}

- (void)maximumInteractiveDistanceChanged:(id)sender {
    self.st_maximumInteractivePopEdgeDistance = [[[STPersistence standardPersistence] valueForKey:@"STDNavigationDefaultEdgeOffset"] floatValue];
}

- (void)maximumInteractiveOffsetChanged:(id)sender {
    self.st_interactivePopTransitionOffset = [[[STPersistence standardPersistence] valueForKey:@"STDNavigationDefaultOffset"] floatValue];
}

- (void)_refreshControlActionFired:(STRefreshControl *)refreshControl {
    [self.model loadDataFromRemote];
}

- (void)_paginationControlActionFired:(id) sender {
    [self.model loadDataFromPagination];
}

- (void)modelDidFinishLoadData:(STModel *)model {
    [super modelDidFinishLoadData:model];
    if (model.sourceType == STModelDataSourceTypeRemote) {
        [self.scrollDirector.refreshControl endRefreshing];
    }
    [self _reloadTableFooterView];
    [self.tableView reloadData];
}

- (void)modelDidFailedLoadData:(STModel *)model {
    [super modelDidFailedLoadData:model];
    if (model.sourceType == STModelDataSourceTypeRemote) {
        [self.scrollDirector.refreshControl endRefreshing];
    } else {
        if (model.sourceType == STModelDataSourceTypePagination) {
            self.scrollDirector.paginationControl.paginationState = STPaginationControlStateFailed;
            self.tableView.tableFooterView = self.scrollDirector.paginationControl;
        }
    }
    [self.tableView reloadData];
}

- (void)_reloadTableFooterView {
    if (self.model.hasNextPage) {
        self.scrollDirector.paginationControl.paginationState = STPaginationControlStateNormal;
    } else {
        self.scrollDirector.paginationControl.paginationState = STPaginationControlStateReachedEnd;
    }
    self.tableView.tableFooterView = self.scrollDirector.paginationControl;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /// config Cell
    return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

@end
