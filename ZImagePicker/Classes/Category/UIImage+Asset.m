//
//  UIImage+Asset.m
//  QTImagePickerProject
//
//  Created by zhujiayong on 15/11/11.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "UIImage+Asset.h"
#import "ZImagePickerViewController.h"

@implementation UIImage (Asset)

typedef struct {
    void *assetRepresentation;
    int decodingIterationCount;
} ThumbnailDecodingContext;
static const int kThumbnailDecodingContextMaxIterationCount = 16;

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ThumbnailDecodingContext *decodingContext = (ThumbnailDecodingContext *)info;
    ALAssetRepresentation *assetRepresentation = (__bridge ALAssetRepresentation *)decodingContext->assetRepresentation;
    if (decodingContext->decodingIterationCount == kThumbnailDecodingContextMaxIterationCount) {
        NSLog(@"WARNING: Image %@ is too large for thumbnail extraction.", [assetRepresentation url]);
        return 0;
    }
    ++decodingContext->decodingIterationCount;
    NSError *error = nil;
    size_t countRead = [assetRepresentation getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    if (countRead == 0 || error != nil) {
        NSLog(@"ERROR: Failed to decode image %@: %@", [assetRepresentation url], error);
        return 0;
    }
    return countRead;
}

+ (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(CGFloat)size {
    NSParameterAssert(asset);
    NSParameterAssert(size > 0);
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    if (!representation) {
        return nil;
    }

    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = NULL
    };
    ThumbnailDecodingContext decodingContext = {
        .assetRepresentation = (__bridge void *)representation,
        .decodingIterationCount = 0
    };
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)&decodingContext, [representation size], &callbacks);
    NSParameterAssert(provider);
    if (!provider) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    NSParameterAssert(source);
    if (!source) {
        CGDataProviderRelease(provider);
        return nil;
    }
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0,(__bridge CFDictionaryRef) @{
        (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
        (NSString *)kCGImageSourceThumbnailMaxPixelSize: [NSNumber numberWithFloat:size],
        (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES
        });

    UIImage *image = nil;
    if (imageRef) {
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    CFRelease(source);
    CGDataProviderRelease(provider);
    return image;
}

+ (CGRect)imageViewFrameWithSize:(CGSize)size {
    
    CGSize boundsSize =  [[UIScreen mainScreen] bounds].size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    CGFloat widthRatio = boundsWidth/imageWidth;
    CGFloat heightRatio = boundsHeight/imageHeight;
    CGFloat minScale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    
    if (minScale >= 1) {
        minScale = 0.8;
    }
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    
    if ( imageWidth <= imageHeight &&  imageHeight <  boundsHeight ) {
        imageFrame.origin.x = floorf( (boundsWidth - imageFrame.size.width ) / 2.0) * minScale;
        imageFrame.origin.y = floorf( (boundsHeight - imageFrame.size.height ) / 2.0) * minScale;
    }else{
        imageFrame.origin.x = floorf( (boundsWidth - imageFrame.size.width ) / 2.0);
        imageFrame.origin.y = floorf( (boundsHeight - imageFrame.size.height ) / 2.0);
    }
    
    if (imageFrame.size.height > boundsHeight) {
        imageFrame.origin.y = 0;
//        imageFrame.size.height = boundsHeight;
    }
    
    return CGRectMake(0, (boundsHeight-imageFrame.size.height)/2, imageFrame.size.width, imageFrame.size.height);
}

//等比例压缩图片。限制9张。大图要压缩成1000x1000，然后图片质量是80
+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size
{
    int h = sourceImage.size.height;
    int w = sourceImage.size.width;
    
    if(h <= size.height && w <= size.width) {
        return sourceImage;
    } else {
        float destWith = 0.0f;
        float destHeight = 0.0f;
        
        float suoFang = (float)w/h;
        float suo = (float)h/w;
        if (w>h) {
            destWith = (float)size.width;
            destHeight = size.width * suo;
        }else {
            destHeight = (float)size.height;
            destWith = size.height * suoFang;
        }
        
        CGSize itemSize = CGSizeMake(destWith, destHeight);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0, 0, destWith, destHeight);
        [sourceImage drawInRect:imageRect];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImg;
    }
}

+ (UIImage *)z_loadImageFromBundleWithName:(NSString *)name {
    NSBundle *libBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZImagePickerViewController class]] pathForResource:@"ZImagePicker" ofType:@"bundle"]];

    NSString *fileName = nil;
    if ([UIScreen mainScreen].scale == 3) {
        fileName = [NSString stringWithFormat:@"/%@@3x", name];
    }
    else {
        fileName = [NSString stringWithFormat:@"/%@@2x", name];
    }
    NSString *file = [libBundle pathForResource:fileName ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:file];
    return img;
}

@end
