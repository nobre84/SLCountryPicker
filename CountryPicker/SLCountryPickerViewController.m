//  Created by Dmitry Shmidt on 5/11/13.
//  Copyright (c) 2013 Shmidt Lab. All rights reserved.
//  mail@shmidtlab.com

#import "SLCountryPickerViewController.h"

static NSString *CellIdentifier = @"CountryCell";
@interface SLCountryPickerViewController ()<UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic) UISearchDisplayController *searchController;
@end

@implementation SLCountryPickerViewController{
    NSArray *countries;
    NSMutableArray *filteredCountryArray;
}

- (void)createSearchBar {
        if (self.tableView && !self.tableView.tableHeaderView) {
            UISearchBar * theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,40)]; // frame has no effect.
            theSearchBar.delegate = self;

            theSearchBar.showsCancelButton = YES;
            
            
            self.tableView.tableHeaderView = theSearchBar;
            
            UISearchDisplayController *searchCon = [[UISearchDisplayController alloc]
                                                    initWithSearchBar:theSearchBar
                                                    contentsController:self ];
            self.searchController = searchCon;
            _searchController.delegate = self;
            _searchController.searchResultsDataSource = self;
            _searchController.searchResultsDelegate = self;
            
            [_searchController setActive:YES animated:YES];
            [theSearchBar becomeFirstResponder];

//            _searchController.displaysSearchBarInNavigationBar = YES;
        }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSearchBar];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    
    NSMutableArray *countriesUnsorted = [[NSMutableArray alloc] initWithCapacity:countryCodes.count];
    filteredCountryArray = [[NSMutableArray alloc] initWithCapacity:countryCodes.count];
    
    for (NSString *countryCode in countryCodes) {
        
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        NSDictionary *cd = @{@"name": displayNameString, @"code":countryCode};
        [countriesUnsorted addObject:cd];
        
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    
    countries = [countriesUnsorted sortedArrayUsingDescriptors:sortDescriptors];
//    [countries sortUsingSelector:@selector(localizedCompare:)];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
}
- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return filteredCountryArray.count;
    }
	else
	{
        return countries.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *cd = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        cd = filteredCountryArray[indexPath.row];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:cd[@"name"] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.785 alpha:1.000], NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
        [attributedTitle addAttribute:NSForegroundColorAttributeName
                                value:[UIColor blackColor]
                                range:[attributedTitle.string.lowercaseString rangeOfString:_searchController.searchBar.text.lowercaseString]];
        
        cell.textLabel.attributedText = attributedTitle;
    }
	else
	{
        cd = countries[indexPath.row];
        cell.textLabel.text = cd[@"name"];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }

    cell.imageView.image = [UIImage imageNamed:cd[@"code"]];
    NSLog(@"%@", cd[@"code"]);
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.completionBlock) {
        NSDictionary *cd = nil;
        
        if(tableView == self.searchDisplayController.searchResultsTableView) {
            cd = filteredCountryArray[indexPath.row];
        }
        else {
            cd = countries[indexPath.row];
        }
        self.completionBlock(cd[@"name"],cd[@"code"]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[filteredCountryArray removeAllObjects];
    
	// Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name BEGINSWITH[c] %@", searchText];
    NSArray *tempArray = [countries filteredArrayUsingPredicate:predicate];
    
    filteredCountryArray = [NSMutableArray arrayWithArray:tempArray];
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][searchOption]];
    
    return YES;
}
#pragma mark - searchBar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{

}

@end
