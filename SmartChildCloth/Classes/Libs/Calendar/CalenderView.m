//
//  CalenderView.m
//  日历表
//
//  Created by apple on 16/6/14.
//  Copyright © 2016年 雷晏. All rights reserved.
//

#import "CalenderView.h"

@interface CalenderCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) NSDate *date;

@end

@implementation CalenderCell

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc]init];
        CGRect frame = self.bounds;
        CGFloat width = frame.size.width <= frame.size.height ? frame.size.width : frame.size.height;
        _bgImageView.frame = CGRectMake(0, 0, width, width);
        _bgImageView.center = CGPointMake(_dateLabel.center.x, _dateLabel.center.y);
        _bgImageView.backgroundColor = RGB(60, 121, 173);
        _bgImageView.layer.masksToBounds = YES;
        _bgImageView.layer.cornerRadius = width * 0.5;
        _bgImageView.hidden = YES;
        [self insertSubview:_bgImageView belowSubview:_dateLabel];
    }
    return _bgImageView;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.frame = self.bounds;
        [_dateLabel setTextAlignment:NSTextAlignmentCenter];
        [_dateLabel setFont:[UIFont systemFontOfSize:17]];
        _dateLabel.layer.cornerRadius = _dateLabel.bounds.size.height * 0.5;
        _dateLabel.layer.masksToBounds = YES;
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}



@end

@interface CalenderView()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) NSCalendar *currentCalendar;
@property (nonatomic,strong) NSArray *weekDayArray;
@property (nonatomic,strong) NSDate *currentDate;
@property (nonatomic,strong) NSDate *selectDate;
@property (weak, nonatomic) UICollectionView *collectionview;
@property (weak, nonatomic) UILabel *titleLabel;
@property (nonatomic,strong) NSMutableArray *selectStauts;
@end

@implementation CalenderView

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        
        _currentDate = [NSDate date];
        _selectDate = _currentDate;
        _selectStauts = @[].mutableCopy;
        
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
        
        UIView *titleView = [UIView new];
        titleView.frame = CGRectMake(0, 0, frame.size.width, 40);
        titleView.backgroundColor = KColor;
        [self addSubview:titleView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleView.bounds];
        titleLabel.text = [self stirngFromDate:_currentDate];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:20.f];
        [titleView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.center = CGPointMake(25, titleLabel.center.y);
        leftBtn.bounds = CGRectMake(0, 0, 25, 25);
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"bt_previous"] forState:UIControlStateNormal];
        [titleView addSubview:leftBtn];
        [leftBtn addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];

        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.center = CGPointMake(titleLabel.bounds.size.width - 25, titleLabel.center.y);
        rightBtn.bounds = CGRectMake(0, 0, 25, 25);
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"bt_next"] forState:UIControlStateNormal];
        [titleView addSubview:rightBtn];
        [rightBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat itemWidth = (frame.size.width-2) / 7;
        CGFloat itemHeight = (frame.size.height - 40-2) / 7;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        UICollectionView *collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(1, titleView.bounds.size.height+1, frame.size.width-2, frame.size.height - titleView.bounds.size.height-2) collectionViewLayout:layout];
        collectionview.backgroundColor = [UIColor whiteColor];
        [self addSubview:collectionview];
        [collectionview registerClass:[CalenderCell class] forCellWithReuseIdentifier:@"cell"];
        collectionview.dataSource = self;
        collectionview.delegate = self;
        collectionview.scrollEnabled = NO;
        collectionview.showsVerticalScrollIndicator = NO;
        _collectionview = collectionview;
    }
    return self;
}


#pragma mark - UICollectionView DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section == 0){
        return self.weekDayArray.count;
    }else{
        return 42;
    }
}

-(CalenderCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CalenderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(indexPath.section == 0){
        cell.dateLabel.text = _weekDayArray[indexPath.row];
        cell.dateLabel.textColor = RGB(29, 112, 167);
        cell.bgImageView.hidden = YES;
    }else{
        //一个月里所有的天数
        NSInteger daysInThisMonth = [self getDaysOfMonth];
        //一个月里的第一天是星期几
        NSInteger firstWeekday = [self getWeekOfDayOfMonth];
        NSInteger day = 0;
        
        //行数不大于第一天的星期数
        if (indexPath.row < firstWeekday) {
            NSDate *date = [self getPerviousMonth:_currentDate];
            NSInteger days = [self.currentCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%zd",days-firstWeekday+1+indexPath.row]];
            [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
            date = [GLDateUtils monthLastDate:date];
            date = [GLDateUtils weekFirstDate:date];
            cell.date = [GLDateUtils dateByAddingDays:indexPath.row-1 toDate:date];
//            DLog(@"1111date=%@",cell.date);
            
        //行数大于第一天所在的星期数＋这个月的天数－1
        }else if (indexPath.row > firstWeekday + daysInThisMonth - 1){
            NSDate *date = [self getNextMonth:_currentDate];
            [cell.dateLabel setText:[NSString stringWithFormat:@"%zd",indexPath.row-firstWeekday-daysInThisMonth+1]];
            [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
            
            date = [GLDateUtils monthFirstDate:date];
            cell.date = [GLDateUtils dateByAddingDays:indexPath.row-firstWeekday-daysInThisMonth toDate:date];
//            DLog(@"2222date=%@",cell.date);
            
        }else{
            NSDate *date = [GLDateUtils monthFirstDate:_currentDate];
            day = indexPath.row - firstWeekday + 1;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%li",(long)day]];
            [cell.dateLabel setTextColor:[UIColor blackColor]];
            cell.date = [GLDateUtils dateByAddingDays:day-1 toDate:date];
//            DLog(@"3333date=%@",cell.date);
        }
        
        if ([GLDateUtils date:self.selectDate isSameDayAsDate:cell.date]){
            cell.bgImageView.hidden = NO;
            [cell.dateLabel setTextColor:[UIColor whiteColor]];
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }else{
            
            if(indexPath.row >= firstWeekday && indexPath.row <= firstWeekday + daysInThisMonth - 1)
            {
                [cell.dateLabel setTextColor:[UIColor blackColor]];

            }else{
                [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
            }
            cell.bgImageView.hidden = YES;
            
        }
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        CalenderCell *cell = (CalenderCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //一个月里所有的天数
        NSInteger daysInThisMonth = [self getDaysOfMonth];
        //一个月里的第一天是星期几
        NSInteger firstWeekday = [self getWeekOfDayOfMonth];
        if(indexPath.row >= firstWeekday && indexPath.row <= firstWeekday + daysInThisMonth - 1){

            [cell.dateLabel setTextColor:[UIColor whiteColor]];
            cell.bgImageView.hidden = NO;
            
        }else if (indexPath.row < firstWeekday) {
            
            [self previous];
            
        }else{
            [self next];
        }
        
        self.selectDate = cell.date;
        if (self.delegate && [self.delegate respondsToSelector:@selector(calenderView:SelectItem:WithDate:)]) {
            [self.delegate calenderView:self SelectItem:indexPath WithDate:self.selectDate];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        CalenderCell *deselectedCell = (CalenderCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //一个月里所有的天数
        NSInteger daysInThisMonth = [self getDaysOfMonth];
        //一个月里的第一天是星期几
        NSInteger firstWeekday = [self getWeekOfDayOfMonth];
        
        if(indexPath.row >= firstWeekday && indexPath.row <= firstWeekday + daysInThisMonth - 1){
            
            [deselectedCell.dateLabel setTextColor:[UIColor blackColor]];
            deselectedCell.bgImageView.hidden = YES;
        }

    }
    
}

#pragma -mark btn事件
-(void)previous{
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionCurveLinear animations:^(void) {
        _currentDate = [self getPerviousMonth:_currentDate];
        _titleLabel.text = [self stirngFromDate:_currentDate];
        [_collectionview reloadData];
    } completion:nil];
}

-(void)next{
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionCurveLinear animations:^(void) {
        _currentDate = [self getNextMonth:_currentDate];
        _titleLabel.text = [self stirngFromDate:_currentDate];
        [_collectionview reloadData];
    }completion:nil];
}

#pragma mark - Get 初始化
-(NSCalendar *)currentCalendar{
    if(!_currentCalendar){
        _currentCalendar = [NSCalendar currentCalendar];
    }
    return _currentCalendar;
}

-(NSArray *)weekDayArray{
    _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    return _weekDayArray;
}

/**
 *  取到北京时间
 *
 *  @return <#return value description#>
 */
-(NSDate *)getLocalDate{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];
    return localDate;
}

/**
 *  得到这个月的第一天
 *
 *  @return <#return value description#>
 */
-(NSDate *)getFirstDayOfCurrentMonth
{
    double interval = 0;
    NSDate *beginDate = nil;
    //    NSDate *endDate = nil;
    
    [self.currentCalendar setFirstWeekday:1];//设定周一为周首日
    BOOL ok = [self.currentCalendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:_currentDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        //        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
    }
    return beginDate;
}
/**
 *  得到这个月的第一天是星期几
 *
 *  @return <#return value description#>
 */
-(NSUInteger)getWeekOfDayOfMonth{
    NSUInteger weekCount = [self.currentCalendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:[self getFirstDayOfCurrentMonth]] - 1;
    return weekCount;
}

/**
 *  得到这个月的天数
 *
 *  @return <#return value description#>
 */
-(NSUInteger)getDaysOfMonth{
    NSUInteger daysCount = [self.currentCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:_currentDate].length;
    return daysCount;
}

/**
 *  得到这个月的周数
 *
 *  @return <#return value description#>
 */
-(NSUInteger)getWeeksOfMonth{
    NSUInteger weekDay = [self getWeekOfDayOfMonth];
    NSUInteger days = [self getDaysOfMonth];
    NSUInteger weeks = 0;
    
    if(weekDay > 1){
        weeks+=1;
        days-=(7-weekDay+1);
    }
    
    weeks+=days/7;
    weeks+=(days%7>0)?1:0;
    return weeks;
}

/**
 *  NSDate 转成字符串
 *
 *  @param wtime <#wtime description#>
 *
 *  @return <#return value description#>
 */
-(NSString *)stirngFromDate:(NSDate *)wtime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    return [dateFormatter stringFromDate:wtime];
}

/**
 *  下一个月
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (NSDate*)getNextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

/**
 *  上一个月
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (NSDate*)getPerviousMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}
@end
