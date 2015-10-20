//
//  XSAddingNewContactViewController.m
//  XSAddressBook
//
//  Created by tarena13 on 15/9/26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "XSAddingNewContactViewController.h"
#import "XSPerson.h"
#import "TSMessage.h"
#import "TSMessageView.h"

@interface XSAddingNewContactViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;

@end

@implementation XSAddingNewContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新建联系人";
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(didAddNewContact)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)didAddNewContact{
    if (self.nameTextField.text.length > 0) {
        XSPerson *person = [XSPerson new];
        person.name = self.nameTextField.text;
        person.tel = self.telTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newContactDidAdd" object:nil userInfo:@{@"newPesron":person}];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [TSMessage showNotificationWithTitle:@"温馨提醒！" subtitle:@"联系人姓名不能为空" type:TSMessageNotificationTypeWarning];
    }
}


@end
