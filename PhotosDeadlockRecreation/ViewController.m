//
//  ViewController.m
//  PhotosDeadlockRecreation
//
//  Created by Venkat Rao on 2/10/17.
//  Copyright © 2017 Rao Studios, Inc. All rights reserved.
//

#import "ViewController.h"

@import Photos;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
        // handle
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self requestPhotosWithInitialScroll:NO];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self requestPhotosWithInitialScroll:YES];
            }
        }];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"count: %ld", [ViewController defaultQueue].operationCount);
    }];
}

+(NSOperationQueue *)defaultQueue {
    static NSOperationQueue *defaultQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultQueue = [NSOperationQueue new];
        defaultQueue.qualityOfService = NSQualityOfServiceBackground;
        defaultQueue.maxConcurrentOperationCount = 200;
    });
    
    return defaultQueue;
}


-(void) requestPhotosWithInitialScroll:(BOOL)initialScroll {
        
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                              ascending:YES]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    
    
    PHFetchResult<PHAssetCollection *> *collections1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                                subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                                                options:nil];
    
    PHAssetCollection *collection = collections1[0];
    
    PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    
    NSLog(@"count: %ld", results.count);
    if (results) {
        
        for (PHAsset *asset in results) {
            
            PHImageManager *manager = [PHImageManager defaultManager];
            
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{

            [manager requestImageForAsset:asset
                                                            targetSize:CGSizeMake(400, 400)
                                                           contentMode:PHImageContentModeAspectFit
                                                               options:options
                                                         resultHandler:^(UIImage *result, NSDictionary *info) {
                                                             
                                                             
                                                         }];
  
            }];
            [[ViewController defaultQueue] addOperation:blockOperation];
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
