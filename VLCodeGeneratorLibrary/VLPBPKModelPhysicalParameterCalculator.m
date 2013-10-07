//
//  VLPBPKModelPhysicalParameterCalculator.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLPBPKModelPhysicalParameterCalculator.h"

#define TISSUE_DENSITY 1.04f

@interface VLPBPKModelPhysicalParameterCalculator ()

// private props -
@property (retain) NSXMLDocument *myModelTree;
@property (retain) NSString *myBodyWeight;
@property (retain) NSString *myBodyHeight;
@property (retain) NSString *myAge;
@property (retain) NSString *myGender;

// private methods -
-(void)setup;
-(void)cleanMyMemory;

@end

@implementation VLPBPKModelPhysicalParameterCalculator


+(VLPBPKModelPhysicalParameterCalculator *)buildCalculatorForModelTree:(NSXMLDocument *)modelTree
{
    // build me -
    VLPBPKModelPhysicalParameterCalculator *calculator = [[VLPBPKModelPhysicalParameterCalculator alloc] init];
    
    // grab the model tree -
    calculator.myModelTree = modelTree;
    
    // configure me -
    [calculator setup];
    
    // return -
    return calculator;
}

#pragma mark - private methods to calculate the correlations
-(CGFloat)calculateLiverVolumeFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat volume = 0.0f;
    CGFloat weight = [[self myBodyWeight] floatValue];
    CGFloat height = [[self myBodyHeight] floatValue];
    CGFloat height_in_cm = height*100;
    
    // surface area -
    // DuBois D, DuBois EF. A formula to estimate the approximate surface area if height and weight be known. Arch Intern Medicine. 1916; 17:863-71.
    CGFloat body_surface_area = 0.007184*(powf(weight, 0.425)*powf(height_in_cm, 0.725));
    
    // calculate the volume (assume male gender for the moment)
    volume = (1/TISSUE_DENSITY)*(1/1000.0f)*1.0728*body_surface_area - 345.7;
    
    // return -
    return volume;
}

#pragma mark - private methods 
-(void)setup
{
    // ok, so we need to go through and process *all* the compartments in the model -
    NSError *xpath_error;
    
    // extract demographic information -
    NSString *bw = [[[[self myModelTree] nodesForXPath:@".//listOfPhysicalProperties/property[@symbol='BW']/@value" error:&xpath_error] lastObject] stringValue];
    NSString *bh = [[[[self myModelTree] nodesForXPath:@".//listOfPhysicalProperties/property[@symbol='BH']/@value" error:&xpath_error] lastObject] stringValue];
    NSString *age = [[[[self myModelTree] nodesForXPath:@".//listOfPhysicalProperties/property[@symbol='AGE']/@value" error:&xpath_error] lastObject] stringValue];
    NSString *gender = [[[[self myModelTree] nodesForXPath:@".//listOfPhysicalProperties/property[@symbol='GENDER']/@value" error:&xpath_error] lastObject] stringValue];
    
    // grab these for later -
    self.myBodyWeight = bw;
    self.myBodyHeight = bh;
    self.myAge = age;
    self.myGender = gender;
    
    // process compartments -
    CGFloat volume;
    NSArray *compartment_vector = [[self myModelTree] nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    for (NSXMLElement *compartment in compartment_vector)
    {
        // Get the symbol for the compartment -
        NSString *compartment_symbol = [compartment stringValue];
        
        // process each compartment -
        if ([compartment_symbol isCaseInsensitiveLike:kLiverSymbol] == YES)
        {
            volume = [self calculateLiverVolumeFromModelTree:[self myModelTree]];
            self.liverVolume = volume;
        }
    }
}

-(void)cleanMyMemory
{
    // kia my iVars -
    self.myAge = nil;
    self.myBodyHeight = nil;
    self.myBodyWeight = nil;
    self.myGender = nil;
    self.myModelTree = nil;
}


@end
