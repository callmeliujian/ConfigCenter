//
//  ConfigManager.m
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ConfigManager.h"

@implementation ConfigManager

+ (instancetype)shareInstance
{
    static ConfigManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[ConfigManager alloc] init];
        }
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //[JZWKWebViewEnableSwitch Reset];
    }
    return self;
}

-(void)clearCache:(NSDictionary*)dic{
    
    static NSDate * lastdate = nil;
    NSDate *lastDay = [NSDate dateWithTimeInterval:-20*24*60*60 sinceDate:[NSDate date]];
    if ([dic  isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@",dic);
        if(dic[@"since"]!=nil){
            NSString* date = dic[@"since"];
            if(date){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSDate* orderDate = [formatter dateFromString:date];
                if([orderDate compare:lastDay]==NSOrderedDescending){
                    lastDay = orderDate;
                }
            }
        }
    }
    if(lastdate ==nil || [lastdate compare:lastDay] == NSOrderedAscending){
        lastdate = lastDay;
        //[[DJVertualResources sharedInstance] clearCacheSinceDate:lastDay];
    }
}


- (void)createManager
{
    // 删除配置中心以前版本的老数据库
    [self deleteOldConfigDB];
    
    //NSString *cityid = [[JZUser shareInstance] getBussArea].cityId;
    
    // 注册key关联的model类名称
    [self DJConfigRegister];
    
    NSMutableDictionary *ConfigParam = [[NSMutableDictionary alloc] init];
    ConfigParam[@"appCode"] = @"101";
    ConfigParam[@"DBName"] = @"/jiazheng.bundle/files/configDB52.db";
    //这里一定要传入NEW_BASE_URL，否则会使用BASE_URL
    ConfigParam[@"BASE_URL"] = @"123";
    
    [[ConfigManager shareInstance] setupParams:ConfigParam];
    [[ConfigManager shareInstance] addDelegate:self];

}

- (void)DJConfigRegister
{
//    [[DJConfigManager shareInstance] registerWithKey:@"calendar_operation" modelClassName:@"WeatherBannerOperation"];
//    [[DJConfigManager shareInstance] registerWithKey:@"calendar_ad" modelClassName:@"WeatherBannerAd"];
//    //返回一个JZMineCellData数组
//    [[DJConfigManager shareInstance] registerWithKey:@"my_menu_list" modelClassName:@"JZMineCellData"];
//    //返回一个DJBannerModel数组
//    [[DJConfigManager shareInstance] registerWithKey:@"homepage_banner" modelClassName:@"DJBannerModel"];
//    //homepage_category数组
//    [[DJConfigManager shareInstance] registerWithKey:@"homepage_category_new" modelClassName:@"DJCatModel"];
//    //homepage_operation数组
//    [[DJConfigManager shareInstance] registerWithKey:@"homepage_operation" modelClassName:@"DJBusinessModel"];
//    //返回拼团抢购数组
//    [[DJConfigManager shareInstance] registerWithKey:@"groupentry" modelClassName:@"DJTimeLimitActivityModel"];
//    //homepage_hotChannel
//    [[DJConfigManager shareInstance] registerWithKey:@"homepage_hotChannel" modelClassName:@"DJServicesModel"];
//    //homepage_theme数组
//    [[DJConfigManager shareInstance] registerWithKey:@"homepage_theme" modelClassName:@"DJTopicModel"];
//    //all_category
//    [[DJConfigManager shareInstance] registerWithKey:@"all_category" modelClassName:@"DJCategoryModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"tabbarFestivalSetting" modelClassName:@"TabbarFestivalSetting"];
//    [[DJConfigManager shareInstance] registerWithKey:@"enableFestival" modelClassName:@"EnableFestival"];
//    [[DJConfigManager shareInstance] registerWithKey:@"activityBanner_new" modelClassName:@"DJActivityBannerModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"userTipFestival" modelClassName:@"UserTipFestival"];
//    [[DJConfigManager shareInstance] registerWithKey:@"jingangFestivalSetting" modelClassName:@"JingangFestivalSetting"];
//    [[DJConfigManager shareInstance] registerWithKey:@"busineBannerFestival" modelClassName:@"BusineBannerFestival"];
//    [[DJConfigManager shareInstance] registerWithKey:@"nearinfo" modelClassName:@"DJNearInfo"];
//    [[DJConfigManager shareInstance] registerWithKey:@"recruitmentbanner" modelClassName:@"DJRecruitmentBannerModel"];
//    
//    // 我的
//    [[DJConfigManager shareInstance] registerWithKey:@"myorder" modelClassName:@"JZMineModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"myother" modelClassName:@"JZMineModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"imservant" modelClassName:@"JZMineModel"];
//    
//    // [[DJConfigManager shareInstance] registerWithKey:@"recruitmentbanner" modelClassName:@"DJRecruitmentBannerModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"headlineconfig" modelClassName:@"JZTranNavRule"];
//    
//    [[DJConfigManager shareInstance] registerWithKey:@"cacheconfig" modelClassName:@"JZWBCacheSetting"];
//    [[DJConfigManager shareInstance] registerWithKey:@"hotcate" modelClassName:@"DJParentLevelCategoryModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"topcate" modelClassName:@"DJParentLevelCategoryModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"wkwebview" modelClassName:@"JZWKWebViewEnableSwitch"];
//    [[DJConfigManager shareInstance] registerWithKey:@"wkwebview_url_hit" modelClassName:@"JZWKWebViewEnableRule"];
//    [[DJConfigManager shareInstance] registerWithKey:@"reportreason" modelClassName:@"DJServiceReportModel"];
//    [[DJConfigManager shareInstance] registerWithKey:@"lanuch3dTouch" modelClassName:@"JZ3dTouchLanuchModel"];
    
    
    
}


#pragma mark DJConfigDelegate

//增量更新
- (void) partKeysChange:(NSDictionary *)keyValue{
    
    if(keyValue == nil)return;
    if(![keyValue isKindOfClass:[NSDictionary class]])return;
    
    NSDictionary* domainDic = keyValue[@"login_cookie_domain"];
    if ([domainDic  isKindOfClass:[NSDictionary class]]) {
        NSArray* domainArray = domainDic[@"domainlist"];
        if(domainArray != nil && [domainArray isKindOfClass:[NSArray class]] && [domainArray count] > 0){
            //[JZShellWebURLProtocol updateCookieDomainArray:domainArray];
        }
    }
    NSDictionary* jump = keyValue[@"jump"];
    if(jump != nil){
        //[[DJSuperJumpCenter sharedSuperJumpCenter] initJumpCenter:jump];
    }
    NSDictionary* dic = keyValue[@"H5VRCacheSince"];
    if(dic != nil){
        [self clearCache:dic];
    }
    
//    [JZWKWebViewEnableSwitch Update];
//
//    [[JZ3dTouchManager shareInstance] update3dLanuch];
//    [[JZSysSearchManager shareInstance] updateAppSearch];
//
//    isConfigDataFromNet = YES;
}

//全量更新
- (void) allKeysChange:(NSDictionary *)keyValue{
    if(keyValue == nil)return;
    if(![keyValue isKindOfClass:[NSDictionary class]])return;
    
    NSDictionary* jump = keyValue[@"jump"];
    if(jump != nil){
        //[[DJSuperJumpCenter sharedSuperJumpCenter] initJumpCenter:jump];
    }
    
    NSDictionary* domainDic = keyValue[@"login_cookie_domain"];
    if ([domainDic  isKindOfClass:[NSDictionary class]]) {
        NSArray* domainArray = domainDic[@"domainlist"];
        if(domainArray != nil && [domainArray isKindOfClass:[NSArray class]] && [domainArray count] > 0){
            //[JZShellWebURLProtocol updateCookieDomainArray:domainArray];
        }
    }
    
    NSDictionary* dic = keyValue[@"H5VRCacheSince"];
    if(dic != nil){
        [self clearCache:dic];
    }
//    [JZWKWebViewEnableSwitch Update];
//    [[JZ3dTouchManager shareInstance] update3dLanuch];
//    [[JZSysSearchManager shareInstance] updateAppSearch];
//
//    isConfigDataFromNet = YES;
}

- (void)deleteOldConfigDB
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    //获取5.1版本的数据库，并删除
    NSString* sourcePath = [NSString stringWithFormat:@"%@/configDB51.db" , path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
    
    //获取5.0版本的数据库，并删除
    sourcePath = [NSString stringWithFormat:@"%@/configDB50.db" , path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
    
    //获取4.6版本的数据库，并删除
    sourcePath = [NSString stringWithFormat:@"%@/configDB46.db" , path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
    
    //获取4.5版本的数据库，并删除
    sourcePath = [NSString stringWithFormat:@"%@/configDB45.db" , path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
    
    //获取4.4版本的数据库，并删除
    sourcePath = [NSString stringWithFormat:@"%@/configDB44.db" , path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
    
    //获取4.3版本的数据库，并删除
    sourcePath = [NSString stringWithFormat:@"%@/configDB43.db" , path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
    
    //获取4.2.1及之前版本的数据库，并删除
    sourcePath = [NSString stringWithFormat:@"%@/config.db" , path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
}

////城市id变化
//- (void) cityIdChange{
//
//}
//
////数据变化
//- (void) configDataChange{
//
//}
//
////请求返回了，没有数据发生变化
//- (void) congfigNoChange
//{
//
//}

@end
