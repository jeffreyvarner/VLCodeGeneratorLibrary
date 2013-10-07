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
    
}

// public properties -
@property (assign) CGFloat liverVolume;
@property (assign) CGFloat kidneyVolume;
@property (assign) CGFloat heartVolume;

// custom init -
+(VLPBPKModelPhysicalParameterCalculator *)buildCalculatorForModelTree:(NSXMLDocument *)modelTree;

@end
