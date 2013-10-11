//
//  VLPBPKModelPhysicalParameterCalculator.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLPBPKModelPhysicalParameterCalculator.h"

#define TISSUE_DENSITY 1.04f
#define AIR_DENSITY 0.001185
#define LUNG_DENSITY 0.173

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

#pragma mark - public get
-(CGFloat)getVolumeForCompartmentWithSymbol:(NSString *)compartment_symbol
{
    CGFloat volume = 0.0f;
    
    // process each compartment -
    if ([compartment_symbol isCaseInsensitiveLike:kLiverSymbol] == YES)
    {
        volume = [self calculateLiverVolumeFromModelTree:[self myModelTree]];
        self.liverVolume = volume;
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kKidneySymbol] == YES)
    {
        volume = [self calculateKidneyVolumeFromModelTree:[self myModelTree]];
        self.kidneyVolume = volume;
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kHeartSymbol] == YES)
    {
        volume = [self calculateHeartVolumeFromModelTree:[self myModelTree]];
        self.heartVolume = volume;
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kArterialBloodPoolSymbol] == YES)
    {
        volume = 0.5f*[self calculateBloodVolumeFromModelTree:[self myModelTree]];
        self.arterialBloodVolume = volume;
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kVenousBloodPoolSymbol] == YES)
    {
        volume = 0.5f*[self calculateBloodVolumeFromModelTree:[self myModelTree]];
        self.venousBloodVolume = volume;
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kLungSymbol] == YES)
    {
        volume = [self calculateLungVolumeFromModelTree:[self myModelTree]];
        self.lungVolume = volume;
    }
    
    return volume;
}

-(CGFloat)getVolumetricBloodFlowRateWithCompartmentSymbol:(NSString *)compartment_symbol
{
    CGFloat flow_rate = 0.0;
    
    // process each compartment -
    if ([compartment_symbol isCaseInsensitiveLike:kLiverSymbol] == YES)
    {
        flow_rate = [self calculateLiverBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kKidneySymbol] == YES)
    {
        flow_rate = [self calculateKidneyBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kHeartSymbol] == YES)
    {
        flow_rate = [self calculateHeartBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kArterialBloodPoolSymbol] == YES)
    {
        flow_rate = 0.5f*[self calculateArterialBloodPoolBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kVenousBloodPoolSymbol] == YES)
    {
        flow_rate = 0.5f*[self calculateVenousBloodPoolBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([compartment_symbol isCaseInsensitiveLike:kLungSymbol] == YES)
    {
        flow_rate = [self calculateLungBloodFlowRateFromModelTree:[self myModelTree]];
    }

    return flow_rate;
}

-(CGFloat)calculateVolumetricBloodFlowRateWithBetweenStartCompartmentWithSymbol:(NSString *)start_symbol
                                                    andEndCompartmentWithSymbol:(NSString *)end_symbol
{
    CGFloat flow_rate = 0.0;
    
    if ([start_symbol isCaseInsensitiveLike:kLungSymbol] == YES &&
        [end_symbol isCaseInsensitiveLike:kArterialBloodPoolSymbol] == YES)
    {
        flow_rate = [self calculateLungBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([start_symbol isCaseInsensitiveLike:kArterialBloodPoolSymbol] == YES &&
             [end_symbol isCaseInsensitiveLike:kHeartSymbol] == YES)
    {
        flow_rate = [self calculateHeartBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([start_symbol isCaseInsensitiveLike:kArterialBloodPoolSymbol] == YES &&
             [end_symbol isCaseInsensitiveLike:kLiverSymbol] == YES)
    {
        flow_rate = [self calculateLiverBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([start_symbol isCaseInsensitiveLike:kArterialBloodPoolSymbol] == YES &&
             [end_symbol isCaseInsensitiveLike:kKidneySymbol] == YES)
    {
        flow_rate = [self calculateKidneyBloodFlowRateFromModelTree:[self myModelTree]];
    }
    else if ([start_symbol isCaseInsensitiveLike:kVenousBloodPoolSymbol] == YES &&
             [end_symbol isCaseInsensitiveLike:kLungSymbol] == YES)
    {
        flow_rate = [self calculateLungBloodFlowRateFromModelTree:[self myModelTree]];
    }

    return flow_rate;
}

#pragma mark - private methods to calculate the correlations
-(CGFloat)calculateLiverBloodFlowRateFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat flow_rate = 0.0;
    
    // hard code for now -
    CGFloat literature_mean_value = 1.32f;
    CGFloat literature_std_value = 0.22f;
    flow_rate = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:literature_mean_value
                                                            andStandardDeviation:literature_std_value];
    
    return flow_rate;
}

-(CGFloat)calculateLungBloodFlowRateFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat flow_rate = 0.0;
    
    // hard code for now -
    CGFloat literature_mean_value = 8.00f;
    CGFloat literature_std_value = 1.35f;
    
    if (_lungBloodFlowRate == -1)
    {
        flow_rate = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:literature_mean_value
                                                                andStandardDeviation:literature_std_value];
        
        // cache this -
        _lungBloodFlowRate = flow_rate;
    }
    else
    {
        flow_rate = _lungBloodFlowRate;
    }
    
    return flow_rate;
}

-(CGFloat)calculateKidneyBloodFlowRateFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat flow_rate = 0.0;
    
    // hard code for now -
    CGFloat literature_mean_value = 1.17f;
    CGFloat literature_std_value = 0.25f;
    flow_rate = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:literature_mean_value
                                                            andStandardDeviation:literature_std_value];

    
    return flow_rate;
}

-(CGFloat)calculateHeartBloodFlowRateFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat flow_rate = 0.0;
    
    // hard code for now -
    CGFloat literature_mean_value = 0.73f;
    CGFloat literature_std_value = 0.25f;
    flow_rate = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:literature_mean_value
                                                            andStandardDeviation:literature_std_value];
    
    return flow_rate;
}

-(CGFloat)calculateVenousBloodPoolBloodFlowRateFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat flow_rate = 0.0;
    
    if (_lungBloodFlowRate == -1.0f)
    {
        flow_rate = [self calculateLungBloodFlowRateFromModelTree:modelTree];
    }
    else
    {
        // this should be the lung rate -
        flow_rate = _lungBloodFlowRate;
    }
    
    return flow_rate;
}

-(CGFloat)calculateArterialBloodPoolBloodFlowRateFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat flow_rate = 0.0;
    
    if (_lungBloodFlowRate == -1.0f)
    {
        flow_rate = [self calculateLungBloodFlowRateFromModelTree:modelTree];
    }
    else
    {
        // this should be the lung rate -
        flow_rate = _lungBloodFlowRate;
    }
    
    return flow_rate;
}

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
    volume = (1.0f/TISSUE_DENSITY)*(1/1000.0f)*(1072.8*body_surface_area - 345.7);
    
    // return -
    return volume;
}

-(CGFloat)calculateKidneyVolumeFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat volume = 0.0f;
    CGFloat weight = [[self myBodyWeight] floatValue];
    CGFloat height = [[self myBodyHeight] floatValue];
    
    // calculate the kidney volume -
    volume = (1.0f/TISSUE_DENSITY)*(1.0f/1000.0f)*(15.4 + 2.04*weight+51.8*height);
    
    // return -
    return volume;
}

-(CGFloat)calculateHeartVolumeFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat volume = 0.0f;
    CGFloat weight = [[self myBodyWeight] floatValue];
    CGFloat height = [[self myBodyHeight] floatValue];
    
    // calculate the kidney volume -
    volume = (1.0f/TISSUE_DENSITY)*(1.0f/1000.0f)*((22.81*height)*(powf(weight, 0.5)) - 4.15);
    
    // return -
    return volume;
}

-(CGFloat)calculateBloodVolumeFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat volume = 0.0f;
    CGFloat weight = [[self myBodyWeight] floatValue];
    CGFloat height = [[self myBodyHeight] floatValue];
    CGFloat height_in_cm = height*100;
    
    // calculate the kidney volume -
    volume = (1.0f/1000.0f)*(1.0f/0.5723)*(13.1*height_in_cm+18.05*weight - 480);
    
    // return -
    return volume;
}


-(CGFloat)calculateLungVolumeFromModelTree:(NSXMLDocument *)modelTree
{
    CGFloat left_volume = 0.0f;
    CGFloat right_volume = 0.0f;
    CGFloat weight = [[self myBodyWeight] floatValue];
    CGFloat height = [[self myBodyHeight] floatValue];
    
    // calculate the kidney volume -
    left_volume = (1/LUNG_DENSITY)*(1.0f/1000.f)*(29.08*height + sqrtf(weight) + 11.06);
    right_volume = (1/LUNG_DENSITY)*(1.0f/1000.0f)*(35.47*height + sqrtf(weight) + 5.53);
    
    // return -
    return (left_volume + right_volume);
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
        NSString *compartment_symbol = [[compartment attributeForName:@"symbol"] stringValue];
        
        // process each compartment -
        if ([compartment_symbol isCaseInsensitiveLike:kLiverSymbol] == YES)
        {
            volume = [self calculateLiverVolumeFromModelTree:[self myModelTree]];
            self.liverVolume = volume;
        }
        else if ([compartment_symbol isCaseInsensitiveLike:kKidneySymbol] == YES)
        {
            volume = [self calculateKidneyVolumeFromModelTree:[self myModelTree]];
            self.kidneyVolume = volume;
        }
        else if ([compartment_symbol isCaseInsensitiveLike:kHeartSymbol] == YES)
        {
            volume = [self calculateHeartVolumeFromModelTree:[self myModelTree]];
            self.heartVolume = volume;
        }
        else if ([compartment_symbol isCaseInsensitiveLike:kArterialBloodPoolSymbol] == YES)
        {
            volume = [self calculateBloodVolumeFromModelTree:[self myModelTree]];
            self.arterialBloodVolume = 0.5f*volume;
        }
        else if ([compartment_symbol isCaseInsensitiveLike:kVenousBloodPoolSymbol] == YES)
        {
            volume = [self calculateBloodVolumeFromModelTree:[self myModelTree]];
            self.venousBloodVolume = 0.5*volume;
        }
        else if ([compartment_symbol isCaseInsensitiveLike:kLungSymbol] == YES)
        {
            volume = [self calculateLungVolumeFromModelTree:[self myModelTree]];
            self.lungVolume = volume;
        }
    }
    
    // set the _lungBloodFlowRate
    _lungBloodFlowRate = -1.0f;
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
