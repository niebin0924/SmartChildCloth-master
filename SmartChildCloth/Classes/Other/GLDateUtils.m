//
//  GLDateUtils.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-21.
//  Copyright (c) 2015年 glow. All rights reserved.
//

#import "GLDateUtils.h"

#define CALENDAR_COMPONENTS NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay


@implementation GLDateUtils

+ (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSCalendar *calendar = [GLDateUtils calendar];
    
    NSDateComponents *day1 = [calendar components:CALENDAR_COMPONENTS fromDate:date1];
    NSDateComponents *day2 = [calendar components:CALENDAR_COMPONENTS fromDate:date2];
    return ([day2 day] == [day1 day] &&
            [day2 month] == [day1 month] &&
            [day2 year] == [day1 year]);
}

+ (NSCalendar *)calendar {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSCalendar *cal = [threadDictionary objectForKey:@"GLCalendar"];
    if (!cal) {
        cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        cal.locale = [NSLocale currentLocale];
        [threadDictionary setObject:cal forKey:@"GLCalendar"];
    }
    return cal;
}

+ (NSDate *)weekFirstDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = components.weekday;//1 for Sunday
    if (weekday == 2) {
        return date;
    } else {
        return [GLDateUtils dateByAddingDays:(2 - weekday) toDate:date];
    }
}

+ (NSDate *)weekLastDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = components.weekday;//1 for Sunday
    if (weekday == 8) {//7 for Saturday
        return date;
    } else {
        return [GLDateUtils dateByAddingDays:(8 - weekday) toDate:date];
    }
}

+ (NSDate *)monthFirstDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDateComponents *result = [[NSDateComponents alloc] init];
    [result setDay:1];
    [result setMonth:[components month]];
    [result setYear:[components year]];
    [result setHour:0];
    [result setMinute:0];
    [result setSecond:0];
    
    return [calendar dateFromComponents:result];
}

+ (NSDate *)monthLastDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDateComponents *result = [[NSDateComponents alloc] init];
    [result setDay:[GLDateUtils days:date]];
    [result setMonth:[components month]];
    [result setYear:[components year]];
    [result setHour:0];
    [result setMinute:0];
    [result setSecond:0];
    
    return [calendar dateFromComponents:result];
}

+ (NSDate *)dateByAddingDays:(NSInteger )days toDate:(NSDate *)date {
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:days];
    return [calendar dateByAddingComponents:comps toDate:date options:0];
}

+ (NSDate *)dateByAddingMonths:(NSInteger )months toDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:months];
    return [calendar dateByAddingComponents:comps toDate:date options:0];
}

+ (NSDate *)cutDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:CALENDAR_COMPONENTS fromDate:date];
    return [calendar dateFromComponents:components];
}

+ (NSInteger)daysBetween:(NSDate *)beginDate and:(NSDate *)endDate
{
    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitDay fromDate:beginDate toDate:endDate options:0];
    return components.day;
}

+ (NSDate *)maxForDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    if ([date1 compare:date2] == NSOrderedAscending) {
        return date2;
    } else {
        return date1;
    }
}

+ (NSDate *)minForDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    if ([date1 compare:date2] == NSOrderedAscending) {
        return date1;
    } else {
        return date2;
    }
}

+ (NSString *)descriptionForDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:CALENDAR_COMPONENTS fromDate:date];
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)components.year, (long)components.month, (long)components.day];
}

+ (NSDate *)dateForDescription:(NSString *)dateString
{
    NSDateFormatter *datefromatter = [[NSDateFormatter alloc]init];//格式化
    [datefromatter setDateFormat:@"yyyy-MM-dd"];
    return [datefromatter dateFromString:dateString];
}

+ (NSDateComponents *)components:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:CALENDAR_COMPONENTS fromDate:date];
    return components;
}

+ (NSDate *)dateForYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    NSDateComponents *components = [[NSDateComponents alloc]init];
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSCalendar *calendar = [GLDateUtils calendar];
    return [calendar dateFromComponents:components];
}

+ (NSDate *)getCurrentZoneDate:(NSDate *)date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
    
    NSTimeInterval time = [zone secondsFromGMTForDate:date];// 以秒为单位返回当前时间与系统格林尼治时间的差
    
    NSDate *dateNow = [date dateByAddingTimeInterval:time];// 然后把差的时间加上,就是当前系统准确的时间
    return dateNow;
}

+ (NSInteger)days:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

+ (NSString *)weekdayStringFormDate:(NSDate *)date
{
    NSArray *weekdays = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *theComponents = [calendar components:NSCalendarUnitWeekday fromDate:date];
    
    return [weekdays objectAtIndex:theComponents.weekday];
}

static NSArray *months;
+ (NSString *)monthText:(NSInteger)month {
    if (!months) {
        months = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    }
    return [months objectAtIndex:(month - 1)];
}

@end
