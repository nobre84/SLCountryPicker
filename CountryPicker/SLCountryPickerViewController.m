//  Created by Dmitry Shmidt on 5/11/13.
//  Copyright (c) 2013 Shmidt Lab. All rights reserved.
//  mail@shmidtlab.com

#import "SLCountryPickerViewController.h"

static NSString *CellIdentifier = @"CountryCell";
static NSString *featureIndexTitle = @"\u2605";
@interface SLCountryPickerViewController ()<UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic) UISearchDisplayController *searchController;
@end

@implementation SLCountryPickerViewController{
    NSMutableArray *_filteredList;
    NSArray *_sections;
    NSArray *_preferredSection;
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
            
//            [_searchController setActive:YES animated:YES];
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
    _filteredList = [[NSMutableArray alloc] initWithCapacity:countryCodes.count];
    
    for (NSString *countryCode in countryCodes) {
        
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode] ?: countryCode;
        NSDictionary *cd = @{@"name": displayNameString, @"code":countryCode};
        [countriesUnsorted addObject:cd];
        
    }
    _sections = [self partitionObjects:countriesUnsorted collationStringSelector:@selector(self)];
    
    if (self.preferredCountryCodes) {
        NSMutableArray *newSection = [NSMutableArray new];
        for (NSString *countryCode in self.preferredCountryCodes) {
            NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode] ?: countryCode;
            NSDictionary *cd = @{@"name": displayNameString, @"code":countryCode};
            [newSection addObject:cd];
        }
        _preferredSection = newSection;
    }

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

#pragma mark - Table view data source
-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    for (id object in array) {
        NSInteger index = [collation sectionForObject:object[@"name"] collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    for (NSMutableArray *section in unsortedSections) {
        NSArray *sortedArray = [section sortedArrayUsingDescriptors:sortDescriptors];
//        [collation sortedArrayFromArray:section collationStringSelector:selector]];
//    collationStringSelector:selector]];
        [sections addObject:sortedArray];
    }
    
    return sections;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *localizedIndexTitles = [UILocalizedIndexedCollation.currentCollation sectionIndexTitles];
    if (!_preferredSection) {
        return localizedIndexTitles;
    }
    NSMutableArray *sections = [localizedIndexTitles mutableCopy];
    [sections insertObject:featureIndexTitle atIndex:0];
    return sections;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
    if (!_sections) return 0;
    //we use sectionTitles and not sections
    NSInteger count = [[UILocalizedIndexedCollation.currentCollation sectionTitles] count];
    // If we have a featured section with most common countries, add another section
    if (_preferredSection) {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_filteredList count];
    }
    if (section == 0 && _preferredSection) {
        return [_preferredSection count];
    }
    NSInteger sectionIndex = section-(_preferredSection ? 1 : 0);
    return [_sections[sectionIndex] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    if (section == 0 && _preferredSection) {
        return self.preferredCountriesSectionName;
    }
    NSInteger sectionIndex = section-(_preferredSection ? 1 : 0);
    BOOL showSection = [[_sections objectAtIndex:sectionIndex] count] != 0;
    //only show the section title if there are rows in the section
    NSString *title = (showSection) ? [[UILocalizedIndexedCollation.currentCollation sectionTitles] objectAtIndex:sectionIndex] : nil;
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
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
        cd = _filteredList[indexPath.row];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:cd[@"name"] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.785 alpha:1.000], NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
        [attributedTitle addAttribute:NSForegroundColorAttributeName
                                value:[UIColor blackColor]
                                range:[attributedTitle.string.lowercaseString rangeOfString:_searchController.searchBar.text.lowercaseString]];
        
        cell.textLabel.attributedText = attributedTitle;
    }
	else
	{
        if (_preferredSection && indexPath.section == 0) {
            cd = _preferredSection[indexPath.row];
        }
        else {
            NSInteger sectionIndex = indexPath.section-(_preferredSection ? 1 : 0);
            cd = _sections[sectionIndex][indexPath.row];
        }
        
        cell.textLabel.text = cd[@"name"];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }

    cell.imageView.image = [UIImage imageNamed:cd[@"code"] inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
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
            cd = _filteredList[indexPath.row];
        }
        else {
            if (_preferredSection && indexPath.section == 0) {
                cd = _preferredSection[indexPath.row];
            }
            else {
                NSInteger sectionIndex = indexPath.section-(_preferredSection ? 1 : 0);
                cd = _sections[sectionIndex][indexPath.row];
            }
        }
        self.completionBlock(cd[@"name"],cd[@"code"]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredList removeAllObjects];
    
    for (NSArray *section in _sections) {
        for (NSDictionary *dict in section)
        {
                NSComparisonResult result = [dict[@"name"] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
                if (result == NSOrderedSame)
                {
                    [_filteredList addObject:dict];
                }
        }
    }
}
#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][searchOption]];
    
    return YES;
}
#pragma mark - searchBar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{

}

@end
