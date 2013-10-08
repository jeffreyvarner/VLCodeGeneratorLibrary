//
//  VLPBPKModelPhysicalParameterCalculator.h
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLPBPKModelPhysicalParameterCalculator : NSObject
{
    @private
    NSXMLDocument *_myModelTree;
    
    // demographic information -
    NSString *_myBodyWeight;
    NSString *_myBodyHeight;
    NSString *_myAge;
    NSString *_myGender;
    
    // pbpk model parameters -
    CGFloat _liverVolume;
    CGFloat _kidneyVolume;
    CGFloat _heartVolume;
    CGFloat _lungVolume;
    CGFloat _venousBloodVolume;
    CGFloat _arterialBloodVolume;
}

// public properties -
@property (assign) CGFloat liverVolume;
@property (assign) CGFloat kidneyVolume;
@property (assign) CGFloat heartVolume;
@property (assign) CGFloat lungVolume;
@property (assign) CGFloat venousBloodVolume;
@property (assign) CGFloat arterialBloodVolume;

// custom init -
+(VLPBPKModelPhysicalParameterCalculator *)buildCalculatorForModelTree:(NSXMLDocument *)modelTree;

@end
