//
//  NYTShowViewPhoto.h
//  Runner
//
//  Created by Anh Tai LE on 07/06/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <NYTPhotoViewer/NYTPhoto.h>

@interface NYTShowViewPhoto : NSObject<NYTPhoto>

// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
