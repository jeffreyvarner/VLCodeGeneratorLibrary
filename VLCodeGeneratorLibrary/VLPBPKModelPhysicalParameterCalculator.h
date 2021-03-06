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
    
    CGFloat _lungBloodFlowRate;
    CGFloat _heartBloodFlowRate;
    CGFloat _kidneyBloodFlowRate;
    CGFloat _liverBloodFlowRate;
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

// get method -
-(CGFloat)getVolumeForCompartmentWithSymbol:(NSString *)symbol;
-(CGFloat)getVolumetricBloodFlowRateWithCompartmentSymbol:(NSString *)symbol;
-(CGFloat)calculateVolumetricBloodFlowRateWithBetweenStartCompartmentWithSymbol:(NSString *)start_symbol andEndCompartmentWithSymbol:(NSString *)end_symbol;

@end
