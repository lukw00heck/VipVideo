//
//  VipURLManager.m
//  VipVideo
//
//  Created by LiHongli on 2017/10/20.
//  Copyright © 2017年 SV. All rights reserved.
//

#import "VipURLManager.h"
#import "AppDelegate.h"
#import "JSONKit.h"

@implementation VipUrlItem

+ (instancetype)createTitle:(NSString *)title url:(NSString *)url{
    VipUrlItem *model = [[VipUrlItem alloc] init];
    model.title = title;
    model.url = url;
    return model;
}


@end

/*--------------------------*/

@interface VipMenuItem : NSMenuItem

@property (nonatomic, strong) VipUrlItem *item;

@end



@implementation VipMenuItem

@end

/*--------------------------*/


@implementation VipURLManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        
        self.itemsArray = [NSMutableArray array];
        self.platformItemsArray = [NSMutableArray array];
        
        [self initVipURLs];
        self.currentIndex = 0;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self initDefaultData];
        });
    }
    return self;
}

- (void)initDefaultData{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"viplist" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"%@,error %@",dict, error);
    [self transformJsonToModel:dict[@"list"]];
    [self transformPlatformJsonToModel:dict[@"platformlist"]];
}

- (void)initVipURLs{
    // 现有的json
    // {"platformlist":[{"name":"腾讯视频","url":"https://v.qq.com/"},{"name":"爱奇艺","url":"http://www.iqiyi.com/"},{"name":"芒果","url":"https://www.mgtv.com/"},{"name":"优酷","url":"https://www.youku.com/"},{"name":"乐视视频","url":"https://www.le.com/"},{"name":"52影院","url":"http://www.52xsba.com/"},{"name":"4080新视觉影院","url":"http://www.yy4080.com/"}],"list":[{"name":"无","url":""},{"name":"线路9(旋风动漫)","url":"http://api.xfsub.com/xfsub_api/?url="},{"name":"万能接口3","url":"http://vip.jlsprh.com/index.php?url="},{"name":"超清接口1_0","url":"http://www.52jiexi.com/tong.php?url="},{"name":"超清接口1_1","url":"http://www.52jiexi.com/yun.php?url="},{"name":"超清接口2","url":"http://jiexi.92fz.cn/player/vip.php?url="},{"name":"万能接口5","url":"http://jx.vgoodapi.com/jx.php?url="},{"name":"线路二(百域阁视频)","url":"http://api.baiyug.cn/vip/index.php?url="},{"name":"线路三(云解析)","url":"http://jiexi.92fz.cn/player/vip.php?url="},{"name":"金桥解析","url":"http://jqaaa.com/jx.php?url="},{"name":"线路四（腾讯暂不可用）","url":"http://api.nepian.com/ckparse/?url="},{"name":"线路五","url":"http://aikan-tv.com/?url="},{"name":"花园影视（可能无效）","url":"http://j.zz22x.com/jx/?url="},{"name":"花园影视1","url":"http://j.88gc.net/jx/?url="},{"name":"线路一(乐乐视频解析)","url":"http://www.662820.com/xnflv/index.php?url="},{"name":"表哥解析","url":"http://jx.biaoge.tv/index.php?url="},{"name":"1717ty","url":"http://1717ty.duapp.com/jx/ty.php?url="},{"name":"无名小站","url":"http://www.82190555.com/index/qqvod.php?url="},{"name":"品优解析","url":"http://api.pucms.com/xnflv/?url="},{"name":"爱跟影院","url":"http://2gty.com/apiurl/yun.php?url="},{"name":"六六视频","url":"http://qtv.soshane.com/ko.php?url="},{"name":"yun parse","url":"http://jx.api.163ren.com/vod.php?url="},{"name":"高端解析","url":"http://jx.vgoodapi.com/jx.php?url="},{"name":"速度牛","url":"http://api.wlzhan.com/sudu/?url="},{"name":"vip在线ve44","url":"http://api.pu.tn/ve44/?url="},{"name":"vip在线ve1010","url":"http://api.pu.tn/ve1010/?url="},{"name":"vip在线ve1111","url":"http://api.pu.tn/ve1111/?url="},{"name":"vip在线ve1212","url":"http://api.pu.tn/ve1212/?url="},{"name":"1","url":"http://17kyun.com/api.php?url="},{"name":"2","url":"http://www.85105052.com/admin.php?url="},{"name":"3","url":"http://api.iy11.cn/apiget.php?url="},{"name":"4","url":"http://jx.hanximeng.com/m3u8.php?url="},{"name":"5","url":"http://jx.39book.com/Client/apiget.php?url="},{"name":"6","url":"http://014670.cn/jx/ty.php?url="},{"name":"7","url":"http://www.ibb6.com/x1/?url="},{"name":"8","url":"http://tv.x-99.cn/api/wnapi.php?id="},{"name":"9","url":"http://49.4.144.33/xfjx/1.php?url="},{"name":"10","url":"http://7cyd.com/vip/?url="},{"name":"11","url":"https://47ksvip.duapp.com/vip/2mm/?vid="}]}
    
    NSURL *url = [NSURL URLWithString:@"https://iodefog.github.io/text/viplist.json"];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
       if(!connectionError){
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
           NSLog(@"%@",dict);
           [self transformJsonToModel:dict[@"list"]];
           [self transformPlatformJsonToModel:dict[@"platformlist"]];
           
           [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoRequestSuccess object:nil];
       }else {
           NSLog(@"connectionError = %@",connectionError);
       }
   }];
}

- (void)transformPlatformJsonToModel:(NSArray *)jsonArray
{
    if ([jsonArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *urlsArray = [NSMutableArray array];
        for (NSDictionary *dict in jsonArray) {
            VipUrlItem *item = [[VipUrlItem alloc] init];
            item.title = dict[@"name"];
            item.url = dict[@"url"];
            [urlsArray addObject:item];
        }
        
        [self.platformItemsArray removeAllObjects];
        [self.platformItemsArray addObjectsFromArray:urlsArray];
    }
}


- (void)transformJsonToModel:(NSArray *)jsonArray
{
    if ([jsonArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *urlsArray = [NSMutableArray array];
        for (NSDictionary *dict in jsonArray) {
            VipUrlItem *item = [[VipUrlItem alloc] init];
            item.title = dict[@"name"];
            item.url = dict[@"url"];
            [urlsArray addObject:item];
        }
        
        AppDelegate *delegate = (id)[NSApplication sharedApplication].delegate;
        NSMenuItem *listStatusItem = [delegate.statusItem.menu itemWithTitle:@"切换接口"];;
        NSMenuItem *listMainItem = [[NSApplication sharedApplication].mainMenu itemWithTitle:@"切换接口"];
        [listStatusItem.submenu removeAllItems];
        [listMainItem.submenu removeAllItems];
        [self.itemsArray removeAllObjects];
        [self.itemsArray addObjectsFromArray:urlsArray];
        
        [self configurationVipMenu:listMainItem.submenu];
        [self configurationVipMenu:listStatusItem.submenu];
    }
}

- (void)configurationVipMenu:(NSMenu *)menu{
    
   NSString *currentUrl = @"";

    
    NSInteger index = 0;
    for (VipUrlItem *item in [VipURLManager sharedInstance].itemsArray) {
        unichar key = ('1'+index);
        NSString *show = [NSString stringWithCharacters:&key length:1];
       
        VipMenuItem *menuItem = [[VipMenuItem alloc] initWithTitle:item.title action:@selector(vipClicked:) keyEquivalent:show];
        menuItem.item = item;
        menuItem.target = self;
        [menu addItem:menuItem];
        
        if ((!currentUrl && index == 0) || [currentUrl isEqualToString:item.url]) {
            menuItem.state = NSControlStateValueOn;
            self.currentIndex = index;
        }else {
            menuItem.state = NSControlStateValueOff;
        }
        
        index ++;
    }
}

- (NSMenuItem *)configurationGoBackMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"GoBack" key:'B' target:self action:@selector(goback:)];
    [menu addItem:item];
    return item;
}

- (NSMenuItem *)configurationGoForwardMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"GoForword" key:'F' target:self action:@selector(goForward:)];
    [menu addItem:item];
    return item;
}

- (NSMenuItem *)configurationQuitMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"退出" key:'Q' target:self action:@selector(quit:)];
    [menu addItem:item];
    return item;
}

- (NSMenuItem *)configurationChangeUpMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"切换上一个" key:'I' target:self action:@selector(upChange:)];
    [menu addItem:item];
    return item;
}

- (NSMenuItem *)configurationChangeNextMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"切换下一个" key:'J' target:self action:@selector(nextChange:)];
    [menu addItem:item];
    return item;
}

- (NSMenuItem *)configurationShowMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"展示窗口" key:'D' target:self action:@selector(openVip:)];
    [menu addItem:item];
    return item;
}

- (NSMenuItem *)configurationCreateMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"新建" key:'N' target:self action:@selector(createNew:)];
    [menu addItem:item];
    return item;
}

- (NSMenuItem *)configurationCopyMenuItem:(NSMenu *)menu{
    NSMenuItem *item = [VipURLManager addShowMenuItemTitle:@"复制链接" key:'C' target:self action:@selector(copyLink:)];
    [menu addItem:item];
    return item;
}

- (void)openVip:(id)sender{
    [[[NSApplication sharedApplication].windows firstObject] makeKeyAndOrderFront:nil];
}

-(void)quit:(id)sender {
    [NSApp terminate:self];
}

- (void)createNew:(id)sender{
    NSStoryboard *mainStroyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    // 必需得写成属性或者全局，不然不能弹出
    NSWindowController *windowVC = [mainStroyBoard instantiateControllerWithIdentifier:@"HLHomeWindowController"];
    
    //显示需要跳转的窗口
    [windowVC.window orderFront:nil];
    AppDelegate *delegate = (id)[NSApplication sharedApplication].delegate;
    [delegate.windonwArray addObject:windowVC];
}

- (void)nextChange:(id)sender{
    if (self.currentIndex+1 < self.itemsArray.count) {
        self.currentIndex ++;
    }
    else {
        self.currentIndex = 0;
    }
    VipUrlItem *item = self.itemsArray[self.currentIndex];
    [self changeVideoItem:item];
}

- (void)upChange:(id)sender{
    if (self.currentIndex-1 < 0) {
        self.currentIndex = self.itemsArray.count - 1;
    }
    else {
        self.currentIndex --;
    }
}

- (void)copyLink:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoDidCopyCurrentURL object:nil];
}

- (void)goback:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoGoBackCurrentURL object:nil];
}

- (void)goForward:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoGoForwardCurrentURL object:nil];
}


- (NSString *)currentVipApi{
    if (_currentVipApi) {
       return _currentVipApi;
    }
    else {
        VipUrlItem *item = [self.itemsArray firstObject];
        return item.url;
    }
}

- (void)vipClicked:(VipMenuItem *)sender{
    if (self.currentVipApi != sender.item.url) {
        self.currentVipApi = sender.item.url;
        [self changeVideoItem:sender.item];
    }
}

- (void)willChangeVideoItem:(VipUrlItem *)item{
    [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoWillChangeCurrentApi object:nil];
}

- (void)changeVideoItem:(VipUrlItem *)item{
    [self willChangeVideoItem:item];
    
    self.currentVipApi = item.url;
    self.currentIndex = [self.itemsArray indexOfObject:item];
    
    if (self.currentVipApi) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoDidChangeCurrentApi object:nil];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (_currentIndex != currentIndex) {
        VipUrlItem *item = self.itemsArray[currentIndex];
        self.currentVipApi = item.url;

        AppDelegate *delegate = (id)[NSApplication sharedApplication].delegate;
        NSMenuItem *listStatusItem = [delegate.statusItem.menu itemWithTitle:@"切换接口"];;
        NSMenuItem *listMainItem = [[NSApplication sharedApplication].mainMenu itemWithTitle:@"切换接口"];
        
        NSMenuItem *oldItem1 = nil;
        if (_currentIndex < listStatusItem.submenu.itemArray.count) {
            oldItem1 = [listStatusItem.submenu itemAtIndex:_currentIndex];
        }
        oldItem1.state = NSControlStateValueOff;
        NSMenuItem *oldItem2 = nil;
        if (_currentIndex < listMainItem.submenu.itemArray.count) {
            oldItem2 = [listMainItem.submenu itemAtIndex:_currentIndex];
        }
        oldItem2.state = NSControlStateValueOff;
        
        _currentIndex = currentIndex;
        
        NSMenuItem *newItem1 = nil;
        if (_currentIndex < listStatusItem.submenu.itemArray.count) {
            newItem1 = [listStatusItem.submenu itemAtIndex:_currentIndex];
        }
        
        newItem1.state = NSControlStateValueOn;
        
        NSMenuItem *newItem2 = nil;
        if (_currentIndex < listMainItem.submenu.itemArray.count) {
            newItem2 = [listMainItem.submenu itemAtIndex:_currentIndex];
        }
        newItem2.state = NSControlStateValueOn;
    }
}

+ (NSMenuItem *)addShowMenuItemTitle:(NSString *)title key:(unichar)key target:(id)target action:(SEL)action{
    NSString *show = [NSString stringWithCharacters:&key length:1];
    NSMenuItem *showItem = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:show];
    showItem.target = target;
    return showItem;
}


@end
