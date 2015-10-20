//
//  XSMainTableViewController.m
//  XSAddressBook
//
//  Created by tarena13 on 15/9/26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "XSMainTableViewController.h"
#import "XSAddingNewContactViewController.h"
#import "XSGroup.h"
#import "XSPerson.h"
#import "ChineseString.h"
#import "pinyin.h"

@interface XSMainTableViewController ()

@property (nonatomic,strong) NSMutableArray *allContacts;
@property (nonatomic,strong) NSString *filePath;

@end

@implementation XSMainTableViewController

- (NSString *)filePath{
    if (!_filePath) {
        _filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"allContacts"];
    }
    return _filePath;
}

- (NSMutableArray *)allContacts{
    if (!_allContacts) {
        _allContacts = [NSMutableArray array];
    }
    return _allContacts;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        //a.创建反归档对象
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:self.filePath]];
        //b.针对要读的对象解码
        self.allContacts = [unarchiver decodeObjectForKey:@"allContacts"];
        //c.执行方归档
        [unarchiver finishDecoding];
    }
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewContact)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self obseveNotifications];
}

- (void)obseveNotifications{
    //监听新建联系人通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newContactDidAdd:) name:@"newContactDidAdd" object:nil];
    //监听程序进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newContactDidAdd" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)newContactDidAdd:(NSNotification *)notification{
    NSString *firstLetterOfName = [NSString string];
    XSPerson *newPerson = [XSPerson new];
    newPerson = notification.userInfo[@"newPesron"];
    //先判断名字首字母是否为中文
    int a = [newPerson.name characterAtIndex:0];
    if( a > 0x4e00 && a < 0x9fff){
        //把 newPerson.name 转换成拼音 如 郭富城 -> GFC
        ChineseString *chineseStr = [[ChineseString alloc] init];
        chineseStr.string = newPerson.name;
        NSString *pinYinResult=[NSString string];
        for(int i = 0; i < chineseStr.string.length; i++){
            NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseStr.string characterAtIndex:i])] uppercaseString];
            pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        chineseStr.pinYin=pinYinResult;
       // NSLog(@"%@", pinYinResult);
        firstLetterOfName = [chineseStr.pinYin substringToIndex:1];
    }else{
        firstLetterOfName = [[newPerson.name substringToIndex:1] uppercaseString];
    }
    for (XSGroup *group in self.allContacts) {
        if ([firstLetterOfName isEqualToString:group.title]) {
            [group.personGroup addObject:newPerson];
#warning 每个分组里面再排序
            [group.personGroup sortUsingComparator:^NSComparisonResult(XSPerson *obj1, XSPerson *obj2) {
                return [obj1.name compare:obj2.name];
            }];
            [self.tableView reloadData];
            return;
        }
    }
    XSGroup *newGroup = [XSGroup new];
    newGroup.title = firstLetterOfName;
    [newGroup.personGroup addObject:newPerson];
    [self.allContacts addObject:newGroup];
    [self reSortAllContacts];
    [self.tableView reloadData];
}

- (void)reSortAllContacts{
    NSMutableArray *sortedAllContacts = [NSMutableArray arrayWithArray:self.allContacts];
    [sortedAllContacts sortUsingComparator:^NSComparisonResult(XSGroup *obj1, XSGroup *obj2) {
        return [obj1.title compare:obj2.title];
    }];
    self.allContacts = sortedAllContacts;
}

- (void)addNewContact{
    XSAddingNewContactViewController *addingNewContactViewController = [XSAddingNewContactViewController new];
    [self.navigationController pushViewController:addingNewContactViewController animated:YES];
}

- (void)appDidEnterBackground{
    //a.准备可变数据对象NSMutableData
    NSMutableData *mutableData = [NSMutableData data];
    //b.创建归档对象NSKeyedArchiver
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mutableData];
    //c.针对要保存的对象进行编码encode
    [archiver encodeObject:self.allContacts forKey:@"allContacts"];
    //执行归档动作!!
    [archiver finishEncoding];

    //d.将数据写到文件中
    [mutableData writeToFile:self.filePath atomically:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allContacts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XSGroup *group = self.allContacts[section];
    return group.personGroup.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    XSGroup *group = self.allContacts[indexPath.section];
    XSPerson *person = group.personGroup[indexPath.row];
    cell.textLabel.text = person.name;
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return [self.allContacts valueForKey:@"title"];
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    XSGroup *group = self.allContacts[section];
    return group.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XSGroup *group = self.allContacts[indexPath.section];
        [group.personGroup removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (group.personGroup.count == 0) {
            [self.allContacts removeObjectAtIndex:indexPath.section];
            [tableView reloadData];
        }
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
