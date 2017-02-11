//
//  ViewController.h
//  tubedo
//
//  Created by vm mac on 06/05/16.
//  Copyright © 2016 Julio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <notify.h>
#import <Social/Social.h>
#import <objc/runtime.h>


typedef enum PSCellType {
    PSGroupCell,
    PSLinkCell,
    PSLinkListCell,
    PSListItemCell,
    PSTitleValueCell,
    PSSliderCell,
    PSSwitchCell,
    PSStaticTextCell,
    PSEditTextCell,
    PSSegmentCell,
    PSGiantIconCell,
    PSGiantCell,
    PSSecureEditTextCell,
    PSButtonCell,
    PSEditTextViewCell,
} PSCellType;

@interface PSSpecifier : NSObject {
@public
    id target;
    SEL getter;
    SEL setter;
    SEL action;
    Class detailControllerClass;
    Class editPaneClass;
    UIKeyboardType keyboardType;
    UITextAutocapitalizationType autoCapsType;
    UITextAutocorrectionType autoCorrectionType;
    int textFieldType;
@private
    NSString* _name;
    NSArray* _values;
    NSDictionary* _titleDict;
    NSDictionary* _shortTitleDict;
    id _userInfo;
    NSMutableDictionary* _properties;
}
@property(retain) NSString* name;
@property(retain) NSString* identifier;
+(id)preferenceSpecifierNamed:(NSString*)title target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cell edit:(Class)edit;
-(void)setProperty:(id)property forKey:(NSString*)key;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles;
-(NSMutableDictionary*)properties;
-(void)loadValuesAndTitlesFromDataSource;
- (id)userInfo;
@end


@interface PSListController : UIViewController
{
    NSMutableDictionary *_cells;
    UITableView *_table;
    NSArray *_specifiers;
}

@property (nonatomic) BOOL usesDarkTheme;

- (id)table;
- (void)reloadSpecifiers;
- (void)reloadSpecifier:(id)arg1;
- (void)reloadSpecifierID:(id)arg1;
- (id)specifierForID:(id)arg1;
- (PSSpecifier*)specifierAtIndex:(int)index;
- (void)reloadSpecifierAtIndex:(int)index animated:(BOOL)animated;
- (void)_returnKeyPressed:(id)arg1;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface ViewControllerC : PSListController
@property (nonatomic, strong) NSString *currentCC;
@property (nonatomic, strong) NSString *currentPrefix;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *yearCC;
@property (nonatomic, strong) NSMutableDictionary *storedBIN;
@property (assign) BOOL currentCCcvv;
@property (assign) int currentCCtype;
- (NSString *)gerarCC:(BOOL)cvv type:(int)type;
@end


@interface UITableViewCell ()
@property(retain, nonatomic) PSSpecifier *specifier;
- (UILabel*)titleLabel;
- (void)setValue:(id)arg1;
- (void)setTitle:(id)arg1;
@end
