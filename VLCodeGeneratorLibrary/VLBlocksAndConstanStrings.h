//
//  VLBlocksAndConstanStrings.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

// define blocks -
typedef void (^MyVarnerlabCodeGenerationOperationBlock)(void);
typedef void (^MyVarnerlabCodeGenerationOperationCompletionBlock)(void);

// notification types -
FOUNDATION_EXPORT NSString *const VLTransformationJobDidCompleteNotification;
FOUNDATION_EXPORT NSString *const VLTransformationJobProgressUpdateNotification;

// keys -
FOUNDATION_EXPORT NSString *const kXMLModelTree;
FOUNDATION_EXPORT NSString *const kXMLTransformationTree;

// organs for PBPK models -
FOUNDATION_EXPORT NSString *const kLiverSymbol;
FOUNDATION_EXPORT NSString *const kKidneySymbol;
FOUNDATION_EXPORT NSString *const kHeartSymbol;
FOUNDATION_EXPORT NSString *const kLungSymbol;
FOUNDATION_EXPORT NSString *const kVenousBloodPoolSymbol;
FOUNDATION_EXPORT NSString *const kArterialBloodPoolSymbol;