//
//  TieZiViewController.m
//  ChildCloth
//
//  Created by cmfchina on 16/7/18.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "TieZiViewController.h"
#import "TextViewCell.h"
#import "TextViewCellModal.h"
#import "TZTestCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LxGridViewFlowLayout.h"
#import "TZImageManager.h"

@interface TieZiViewController ()<UITextViewDelegate,TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,TextViewCellDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UILabel *uilabel1;
    UILabel *uilabel2;
    UITextView *titleTextView;
    UITextView *zhengwen;
    
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
    LxGridViewFlowLayout *_layout;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIImagePickerController *imagePickerVc;
@property (nonatomic,strong) NSIndexPath *indexpath;

@end

@implementation TieZiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"发帖";

    [self initData];
    [self initNavigationBar];

    [self initTable];
    [self configCollectionView];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:tap];
}

- (void)initData
{
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    
    self.dataArr = [NSMutableArray array];
    for (NSInteger i=0; i<2; i++) {
        TextViewCellModal *modal = [[TextViewCellModal alloc]init];
        modal.title = @"";
        modal.content = @"";
        [self.dataArr addObject:modal];
    }
}

- (void)initNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(fasongTieZi)];
}


- (void)initTable
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 100) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)configCollectionView {
    _layout = [[LxGridViewFlowLayout alloc] init];
    _margin = 4;
    _itemWH = (self.view.width - 2 * _margin - 4) / 3 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), SCREENWIDTH, self.view.height - CGRectGetMaxY(self.tableView.frame)) collectionViewLayout:_layout];
//    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = RGB(244, 244, 244);
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[TZTestCell class] forCellWithReuseIdentifier:@"TZTestCell"];
    [self.view addSubview:_collectionView];
    
}

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

#pragma mark - hideKeyboard
- (void)hideKeyboard
{
//    [self.view endEditing:YES];
    if (self.indexpath) {
        TextViewCell *textCell = [self.tableView cellForRowAtIndexPath:self.indexpath];
        if (textCell.textView.isFirstResponder) {
            [textCell.textView resignFirstResponder];
        }
    }
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TextViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.delegate = self;
    if (indexPath.row == 0) {
        cell.textView.placeholder = @"请输入帖子标题";
        
    }else{
        cell.textView.placeholder = @"请输入帖子正文";
        
    }
    TextViewCellModal *model = self.dataArr[indexPath.row];
    [cell setTitle:model.title withContent:model.content withIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextViewCellModal *model = self.dataArr[indexPath.row];
    
    if (model.size.height>50.0f) {
        
        return model.size.height;
        
    }else
    {
        return 50.0;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

#pragma mark - TextViewCellDelegate
-   (void)textViewCellDidChangeText:(NSString*)text withIndexPath:(NSIndexPath*)indexPath
{
    TextViewCell *textCell = [self.tableView cellForRowAtIndexPath:indexPath];
    TextViewCellModal *model = self.dataArr[indexPath.row];
    model.content = text;
    CGSize fitSize = [textCell.textView sizeThatFits:CGSizeMake(textCell.textView.frame.size.width,CGFLOAT_MAX)];
    model.size = CGSizeMake(textCell.textView.frame.size.width,fitSize.height>40.0f?fitSize.height+10:40.0f);
    [self.dataArr replaceObjectAtIndex:indexPath.row withObject:model];
    
    CGFloat height = 0;
    for (TextViewCellModal *model in self.dataArr) {
        height += model.size.height;
    }
    
    self.indexpath = indexPath;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.row == _selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn"];
        cell.deleteBtn.hidden = YES;
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.row];
        cell.asset = _selectedAssets[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self hideKeyboard];
    
    //选择照片按钮
    if (indexPath.row == _selectedPhotos.count) {
        [self pushImagePickerController];
    } else { // preview photos or video / 预览照片或者视频
        id asset = _selectedAssets[indexPath.row];
        BOOL isVideo = NO;
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = asset;
            isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = asset;
            isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        }
        if (isVideo) {
            // perview video / 预览视频
            //去掉视频预览
            
        } else { // preview photos / 预览照片
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
            imagePickerVc.allowPickingOriginalPhoto = YES;
            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                _selectedPhotos = [NSMutableArray arrayWithArray:photos];
                _selectedAssets = [NSMutableArray arrayWithArray:assets];
                _isSelectOriginalPhoto = isSelectOriginalPhoto;
                _layout.itemCount = _selectedPhotos.count;
                [_collectionView reloadData];
                _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
            }];
            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    
    if (sourceIndexPath.item >= _selectedPhotos.count || destinationIndexPath.item >= _selectedPhotos.count) return;
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    if (image) {
        [_selectedPhotos exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
        [_selectedAssets exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
        [_collectionView reloadData];
    }
}

#pragma mark - TZImagePickerController

- (void)pushImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    // 1.如果你需要将拍照按钮放在外面，不要传这个参数
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        NSLog(@"block返回选择的照片");
        
//        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//        imageView.image = [photos objectAtIndex:0];
//        [self.view addSubview:imageView];
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = YES;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        [_selectedAssets addObject:assetModel.asset];
                        [_selectedPhotos addObject:image];
                        [_collectionView reloadData];
                    }];
                }];
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
// - (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
// NSLog(@"cancel");
// }

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    _layout.itemCount = _selectedPhotos.count;
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}


#pragma mark Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    _layout.itemCount = _selectedPhotos.count;
    
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}

-(void)fasongTieZi
{
    [self hideKeyboard];
    
    NSString *url = @"http://123.57.164.156:8080/smart_child_cloth/circle/sendPost";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    
    TextViewCellModal *m1 = self.dataArr[0];
    TextViewCellModal *m2 = self.dataArr[1];
    
    NSDictionary *parameters = @{@"token":token, @"title":m1.content, @"content":m2.content};
    [self postPictureWithUrl:url parameters:parameters];
}

- (void)postPictureWithUrl:(NSString *)url parameters:(NSDictionary *)parameters
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"text/plain",
                                                         nil];
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i=0; i<_selectedPhotos.count; i++) {
            
            UIImage *image = _selectedPhotos[i];
            NSData *imageData =UIImageJPEGRepresentation(image,0.5);
            
            /*
                1.name:多文件上传时,name不能重复，不能重复，不能重复
                2.fileName:不能重复，这个名字由用户决定，只要不重复，其它没有要求
                3.mimeType:你所要上传文件的类型，各种文件所对应的类型详情请自己百度
             */
            
            //上传的参数(上传图片，以文件流的格式)
            [formData appendPartWithFileData:imageData
                                        name:[NSString stringWithFormat:@"picture[%d]",i]
                                    fileName:[NSString stringWithFormat:@"image%d.jpg",i]
                                    mimeType:@"image/jpeg"];
        }
        
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
        DLog(@"%@",uploadProgress);
        [SVProgressHUD showWithStatus:@"正在发布"];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        DLog(@"dict = %@",dict);
        if ([[dict objectForKey:@"code"]integerValue] == 0) {
            //上传成功
            NSDictionary *result = [dict objectForKey:@"jsonResult"];
            DLog(@"acc = %@",result);
            [SVProgressHUD showSuccessWithStatus:@"发布帖子成功"];
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {
            [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"发布失败"];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


@end
