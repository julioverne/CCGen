//
//  ViewController.m
//  tubedo
//
//  Created by vm mac on 06/05/16.
//  Copyright © 2016 Julio. All rights reserved.
//

#import "ViewController.h"

static id instance;
@implementation ViewControllerC
@synthesize currentCC, currentPrefix, currentCCcvv, currentCCtype, timer, yearCC, storedBIN;
- (id)init
{
    if(instance) {
        return instance;
    }
    instance = [super init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    currentPrefix = [[userDefaults objectForKey:@"ccPrefix"]?:@"xxxxxxxxxxxxxxxx" lowercaseString];
    storedBIN = [[userDefaults objectForKey:@"ccSavedBIN"]?:@{} mutableCopy];
    currentCCcvv = [[userDefaults objectForKey:@"ccCVV"]?:@YES boolValue];
    currentCCtype = [[userDefaults objectForKey:@"ccType"]?:@(0) intValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    NSInteger yearNow = [yearString integerValue];
    yearCC = @[@(yearNow+1), @(yearNow+2), @(yearNow+3), @(yearNow+4), @(yearNow+5)];
    
    return instance;
}
- (id)specifiers {
    if (!_specifiers) {
        NSMutableArray* specifiers = [NSMutableArray array];
        PSSpecifier* spec;
        
        spec = [PSSpecifier preferenceSpecifierNamed:nil
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [spec setProperty:[NSString stringWithFormat:@"CCGen © %d julioverne", [yearCC[0] intValue]-1] forKey:@"footerText"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:nil
                                              target:self
                                                 set:@selector(setCellCCvalue:)
                                                 get:@selector(cellCCvalue)
                                              detail:Nil
                                                cell:PSEditTextCell
                                                edit:Nil];
        [specifiers addObject:spec];
        spec = [PSSpecifier preferenceSpecifierNamed:@"Copy"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSButtonCell
                                                edit:Nil];
        spec->action = @selector(copyCCvalue);
        [spec setProperty:NSClassFromString(@"SSTintedCell") forKey:@"cellClass"];
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"copy" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
        spec = [PSSpecifier preferenceSpecifierNamed:@"💳 Type"
                                              target:self
                                                 set:@selector(setCurrentCCtype:specifier:)
                                                 get:@selector(getCurrentCCtype)
                                              detail:NSClassFromString(@"PSListItemsController")
                                                cell:PSLinkListCell
                                                edit:Nil];
        [spec setProperty:@0 forKey:@"default"];
        [spec setValues:@[@0, @1, @2, @3]
                 titles:@[@"Pattern/BIN",
                          @"MasterCard",
                          @"Visa",
                          @"Amex"]];
        [specifiers addObject:spec];
        spec = [PSSpecifier preferenceSpecifierNamed:@"📥 Saved Pattern/BIN"
                                              target:self
                                                 set:@selector(setCurrentSavedPrefix:specifier:)
                                                 get:@selector(getCurrentSavedPrefix:)
                                              detail:NSClassFromString(@"PSListItemsController")
                                                cell:PSLinkListCell
                                                edit:Nil];
        //[spec setProperty:currentPrefix forKey:@"default"];
        [spec setValues:[storedBIN allKeys] titles:[storedBIN allKeys]];
        [specifiers addObject:spec];
        spec = [PSSpecifier preferenceSpecifierNamed:@"🔩 Pattern/BIN"
                                              target:self
                                                 set:@selector(setCurrentPrefix:specifier:)
                                                 get:@selector(getCurrentPrefix:)
                                              detail:Nil
                                                cell:PSEditTextCell
                                                edit:Nil];
        [specifiers addObject:spec];
        spec = [PSSpecifier preferenceSpecifierNamed:@"📅 Random Date/CVV2"
                                              target:self
                                                 set:@selector(setCurrentCCcvv:specifier:)
                                                 get:@selector(getCurrentCCcvv)
                                              detail:Nil
                                                cell:PSSwitchCell
                                                edit:Nil];
        [specifiers addObject:spec];
        spec = [PSSpecifier preferenceSpecifierNamed:@"Generate"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSButtonCell
                                                edit:Nil];
        spec->action = @selector(genCCvalue);
        [spec setProperty:NSClassFromString(@"SSTintedCell") forKey:@"cellClass"];
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gen" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
        
        _specifiers = [specifiers copy];
    }
    return _specifiers;
}
- (id)getCurrentCCtype
{
    return @(currentCCtype);
}
- (void)setCurrentCCtype:(id)value specifier:(PSSpecifier *)specifier
{
    if(currentCCtype != [value intValue]) {
        currentCCtype = [value intValue];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(currentCCtype) forKey:@"ccType"];
        [userDefaults synchronize];
        [self genCCvalue];
    }
}
- (void)setCurrentSavedPrefix:(id)value specifier:(PSSpecifier *)specifier
{
    currentPrefix = [value lowercaseString];
    [specifier setValues:[storedBIN allKeys] titles:[storedBIN allKeys]];
    //[specifier setProperty:currentPrefix forKey:@"default"];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentPrefix  forKey:@"ccPrefix"];
    [userDefaults synchronize];
    [[self table] reloadData];
    [self genCCvalue];
}
- (void)setCurrentPrefix:(id)value specifier:(PSSpecifier *)specifier
{
    currentPrefix = [value lowercaseString];
    
    PSSpecifier* specif = [self specifierForID:@"📥 Saved Pattern/BIN"];
    [specif setValues:[storedBIN allKeys] titles:[storedBIN allKeys]];
    //[specif setProperty:currentPrefix forKey:@"default"];
    [self reloadSpecifierID:@"📥 Saved Pattern/BIN"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentPrefix  forKey:@"ccPrefix"];
    [userDefaults synchronize];
    [[self table] reloadData];
    [self genCCvalue];
}
- (void)setBarButtom
{
    UIBarButtonItem *rightButton = nil;
    if(currentCCtype == 0 && currentPrefix.length>0) {
        if([storedBIN objectForKey:currentPrefix]) {
            rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(delBIN)];
        } else {
            rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveBIN)];
        }
    }
    self.navigationItem.rightBarButtonItem = rightButton;
}
- (void)delBIN
{
    [self saveCurrentBIN:NO];
}
- (void)saveBIN
{
    [self saveCurrentBIN:YES];
}
- (void)saveCurrentBIN:(BOOL)save
{
    [self.view endEditing:YES];
    if(currentPrefix.length<=0) {
        return;
    }
    UIAlertView *hud = nil;
    if(save) {
        hud = [[UIAlertView alloc] initWithTitle:@"✅ Saved Current Pattern/BIN"
                                         message:nil
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:nil];
        [storedBIN setObject:currentPrefix forKey:currentPrefix];
    } else {
        hud = [[UIAlertView alloc] initWithTitle:@"❌ Deleted Current Pattern/BIN"
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
        [storedBIN removeObjectForKey:currentPrefix];
    }
    [hud show];
    [self performSelector:@selector(closeAlert:) withObject:hud afterDelay:0.3f];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:storedBIN  forKey:@"ccSavedBIN"];
    [userDefaults synchronize];
    [self setBarButtom];
    PSSpecifier* spec = [self specifierAtIndex:4];
    [spec setValues:[storedBIN allKeys] titles:[storedBIN allKeys]];
    [[self table] reloadData];
}
- (id)getCurrentSavedPrefix:(PSSpecifier *)specifier
{
    [specifier setProperty:@(currentCCtype==0) forKey:@"enabled"];
    //[specifier setProperty:currentPrefix forKey:@"default"];
    [specifier setValues:[storedBIN allKeys] titles:[storedBIN allKeys]];
    return [storedBIN objectForKey:currentPrefix]?:@"";
}
- (id)getCurrentPrefix:(PSSpecifier *)specifier
{
    [specifier setProperty:@(currentCCtype==0) forKey:@"enabled"];
    return currentPrefix;
}
- (id)getCurrentCCcvv
{
    return @(currentCCcvv);
}
- (void)setCurrentCCcvv:(id)value specifier:(PSSpecifier *)specifier
{
    if(currentCCcvv != [value boolValue]) {
        currentCCcvv = [value boolValue]?YES:NO;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(currentCCcvv) forKey:@"ccCVV"];
        [userDefaults synchronize];
        [self genCCvalue];
    }
}
- (NSString *)gerarCC:(BOOL)cvv type:(int)type
{
    NSString* ret = @"";
    
    if(type == 1) {
        ret = [[self generateMasterCard] copy];
    } else if(type == 2) {
        ret = [[self generateVisa] copy];
    } else {
        ret = [[self generateAmex] copy];
    }
    
    if(cvv) {
        ret = [ret stringByAppendingString:@", "];
        ret = [ret stringByAppendingString:[[yearCC objectAtIndex:(arc4random() % [yearCC count])] stringValue]];
        ret = [ret stringByAppendingString:@"/"];
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"%02d", (arc4random() % 12)+1]];
        ret = [ret stringByAppendingString:@", "];
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"%03d", (arc4random() % 997)+1]];
    }
    
    return ret;
}
- (void)setCellCCvalue:(NSString*)value
{
    [self.view endEditing:YES];
    currentCC = value;
}
- (NSString*)cellCCvalue
{
    if(!currentCC) {
        currentCC = [[self gerarCC:currentCCcvv type:currentCCtype] copy];
    }
    return currentCC;
}
- (void)copyCCvalue
{
    [self.view endEditing:YES];
    [UIPasteboard generalPasteboard].string = [self cellCCvalue];
    UIAlertView *hud = [[UIAlertView alloc] initWithTitle:@"👻 Copied"
                                     message:nil
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:nil];
    [hud show];
    [self performSelector:@selector(closeAlert:) withObject:hud afterDelay:0.1f];
}
- (void)closeAlert:(UIAlertView *)alert
{
    if(!alert) {
        return;
    }
    [alert dismissWithClickedButtonIndex:0 animated:NO];
}
- (void)genCCvalue
{
    [self.view endEditing:YES];
    [self setBarButtom];
    currentCC = [[self gerarCC:currentCCcvv type:currentCCtype] copy];
    [[self table] reloadData];
}
- (NSString*)generateMasterCard
{
    NSArray *masterCardPrefixes = @[@"51", @"52", @"53", @"54", @"55"];
    return [self credit_card_number:masterCardPrefixes :16];
}
- (NSString*)generateVisa
{
    NSArray *visaPrefixes = @[@"4539", @"4556", @"4532", @"4929", @"40240071", @"4485", @"4716", @"4"];
    return [self credit_card_number:visaPrefixes :16];
}
- (NSString*)generateAmex
{
    NSArray *amexPrefixes = @[@"34", @"37"];
    return [self credit_card_number:amexPrefixes :16];
}
- (NSString*)credit_card_number :(NSArray*)prefixList :(int)length
{
    int randomArrayIndex = arc4random() % [prefixList count];
    NSString *ccnumber = [prefixList objectAtIndex:randomArrayIndex];
    return [self completed_number:ccnumber :length];
}

- (NSString*)completed_number :(NSString*)prefix :(int)length
{
    NSMutableString *ccnumber = nil;
    if(currentCCtype == 0) {
        NSString* ccnumberStr = [NSString stringWithFormat:@"%@", currentPrefix];
        length = (int)ccnumberStr.length;
        for (int i = 0; i < length; i++) {
            if ([[ccnumberStr substringWithRange:NSMakeRange(i, 1)] isEqual:@"x"]) {
                NSRange range = NSMakeRange(i, 1);
                ccnumberStr = [ccnumberStr stringByReplacingCharactersInRange:range withString:[@(floor(arc4random() % 10)) stringValue]];
            }
        }
        ccnumber = [ccnumberStr mutableCopy];
    } else {
        ccnumber = [[NSMutableString alloc] initWithFormat:@"%@", prefix];
        while ([ccnumber length] < length) {
            int num = floor(arc4random() % 10);
            [ccnumber appendString:[NSMutableString stringWithFormat:@"%d", num]];
        }
    }
    
    if([ccnumber length] > 0) {
        [ccnumber deleteCharactersInRange:NSMakeRange([ccnumber length]-1, 1)];
    }
    
    NSString *reversedCCnumber = [self reverseString:(NSString*)ccnumber];
    NSMutableArray *reversedCCNumList = [NSMutableArray array];
    for (int i = 0; i < [reversedCCnumber length]; i++) {
        NSString *ch = [reversedCCnumber substringWithRange:NSMakeRange(i, 1)];
        [reversedCCNumList addObject:ch];
    }
    int sum = 0;
    int pos = 0;
    while (pos < length - 1) {
        int odd = [[reversedCCNumList objectAtIndex:pos] intValue] * 2;
        if (odd > 9) {
            odd -= 9;
        }
        sum += odd;
        if (pos != (length - 2)) {
            sum += [[reversedCCNumList objectAtIndex:pos + 1] intValue];
        }
        pos += 2;
    }
    int digitInt = ((floor(sum / 10) + 1) * 10 - sum);
    int checkDigit = digitInt % 10;
    [ccnumber appendString:[NSMutableString stringWithFormat:@"%d", checkDigit]];
    return ccnumber;
}

- (NSString*)reverseString :(NSString*)str
{
    NSMutableArray *temp=[[NSMutableArray alloc] init];
    for(int i = 0; i < [str length]; i++)
    {
        [temp addObject:[NSString stringWithFormat:@"%c", [str characterAtIndex:i]]];
    }
    temp = [NSMutableArray arrayWithArray:[[temp reverseObjectEnumerator] allObjects]];
    NSString *reverseString = @"";
    for(int i = 0; i < [temp count]; i++)
    {
        reverseString = [NSString stringWithFormat:@"%@%@", reverseString, [temp objectAtIndex:i]];
    }
    return reverseString;
}

- (void)_returnKeyPressed:(id)arg1
{
    //[super _returnKeyPressed:arg1];
    [self.view endEditing:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"CCGen";
    [self setBarButtom];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell && [indexPath section] == 0 && [indexPath row] == 0) {
        [cell setBackgroundColor:[UIColor colorWithRed:0.79 green:0.85 blue:0.97 alpha:1.0]];
    } else if(cell && [indexPath section] == 0 && [indexPath row] == 6) {
        for(UILongPressGestureRecognizer* gest in cell.gestureRecognizers) {
            if([gest isKindOfClass:[UILongPressGestureRecognizer class]]) {
                return cell;
            }
        }
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(genTouchGest:)];
        gestureRecognizer.cancelsTouchesInView = YES;
        gestureRecognizer.minimumPressDuration = 0.0000001;
        [cell addGestureRecognizer:gestureRecognizer];
    } else if(cell && [indexPath section] == 0 && [indexPath row] == 3) {
        [cell setValue:[storedBIN objectForKey:currentPrefix]];
    } else if(cell && [indexPath section] == 0 && [indexPath row] == 4) {
        [cell setTitle:[NSString stringWithFormat:@"🔩 Pattern/BIN[%d]:", (int)currentPrefix.length]];
    }
    return cell;
}
- (void)genTouchGest:(UILongPressGestureRecognizer*)gesture
{
    //NSLog(@"*** TouchGest %@", gesture);
    if (gesture.state == UIGestureRecognizerStateBegan){
        if (timer != nil) {
            [timer invalidate];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(genCCvalue) userInfo:nil repeats:YES];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        if (timer != nil) {
            [timer invalidate];
            timer = nil;
        }
    }
    [self genCCvalue];
}

@end


