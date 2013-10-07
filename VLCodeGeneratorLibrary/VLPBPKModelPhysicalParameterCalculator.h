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
    
}

// public properties -
@property (assign) CGFloat liverVolume;

// custom init -
+(VLPBPKModelPhysicalParameterCalculator *)buildCalculatorForModelTree:(NSXMLDocument *)modelTree;

@end
