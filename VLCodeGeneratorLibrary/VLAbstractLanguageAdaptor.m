//
//  VLAbstractLanguageAdaptor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLAbstractLanguageAdaptor.h"

@implementation VLAbstractLanguageAdaptor


// blank method implementations -
-(NSString *)generateModelDataStructureBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelOperationKineticsHeaderBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelMassBalancesImplBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";

}

-(NSString *)generateModelMassBalancesHeaderBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelDriverImplBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelMakeFileBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

#pragma mark - general methods
-(NSString *)generateModelInitialConditonsBufferWithOptions:(NSDictionary *)options
{
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // ok, get the trees -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];

    NSError *xpath_error;
    NSArray *state_vector = [model_tree nodesForXPath:@".//listOfSpecies/species" error:&xpath_error];
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    
    // process each compartment -
    for (NSXMLElement *compartment in compartment_vector)
    {
        // get the symbol -
        NSString *compartment_symbol = [[compartment attributeForName:@"symbol"] stringValue];
        
        // process each species -
        for (NSXMLElement *species in state_vector)
        {
            // the default is 0.0 -> however, if we have a specifc initial value for this compartment then use this value
            NSString *xpath_string = [NSString stringWithFormat:@".//initial_amount[@compartment='%@']",compartment_symbol];
            NSArray *initial_amount_array = [species nodesForXPath:xpath_string error:&xpath_error];
            if (initial_amount_array == nil || [initial_amount_array count] == 0)
            {
                //NSString *species_symbol = [[species attributeForName:@"symbol"] stringValue];
                [buffer appendString:@"0.0\n"];
            }
            else
            {
                // ok, we have a record.
                NSString *average_value = [[[initial_amount_array lastObject] attributeForName:@"average_value"] stringValue];
                NSString *std_value = [[[initial_amount_array lastObject] attributeForName:@"std_value"] stringValue];
                
                // calculate random value -
                CGFloat float_average_value = [average_value floatValue];
                CGFloat float_std_value = [std_value floatValue];
                CGFloat float_ic_value = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:float_average_value
                                                                                     andStandardDeviation:float_std_value];
                
                // add random value to buffer -
                [buffer appendFormat:@"%f\n",float_ic_value];
            }
        }
    }
    
    
    
    
    return [NSString stringWithString:buffer];
}


-(NSString *)generateModelCirculationMatrixBufferWithOptions:(NSDictionary *)options
{
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // ok, get the trees -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    
    // how many species do we have?
    NSUInteger NUMBER_OF_SPECIES = [self calculateNumberOfSpeciesInModelTree:model_tree];
    NSUInteger NUMBER_OF_COMPARTMENTS = [self calculateNumberOfCompartmentsInModelTree:model_tree];
    
    // build calculator -
    VLPBPKModelPhysicalParameterCalculator *transport_calculator = [VLPBPKModelPhysicalParameterCalculator buildCalculatorForModelTree:model_tree];
    
    // get volume of heart, kidney and liver -
    CGFloat heart_volume = [transport_calculator heartVolume];
    
    NSLog(@"heart_volume = %f",heart_volume);
    
    return [NSString stringWithString:buffer];
}

-(NSString *)generateModelStoichiometricMatrixBufferWithOptions:(NSDictionary *)options
{
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // ok, get the trees -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    
    
    return [NSString stringWithString:buffer];
}

-(NSUInteger)calculateNumberOfSpeciesInModelTree:(NSXMLDocument *)model_tree
{
    
    NSError *xpath_error;
    NSArray *state_vector = [model_tree nodesForXPath:@".//listOfSpecies/species" error:&xpath_error];
    return [state_vector count];
}

-(NSUInteger)calculateNumberOfCompartmentsInModelTree:(NSXMLDocument *)model_tree
{
    NSError *xpath_error;
    
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    return [compartment_vector count];
}

-(NSUInteger)calculateNumberOfStatesInModelTree:(NSXMLDocument *)model_tree
{
    NSUInteger number_of_states = 0;
    NSError *xpath_error;
    
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    NSArray *state_vector = [model_tree nodesForXPath:@".//listOfSpecies/species" error:&xpath_error];
    number_of_states = [compartment_vector count]*[state_vector count];
    
    return number_of_states;
}

-(NSUInteger)calculateNumberOfRatesInModelTree:(NSXMLDocument *)model_tree
{
    NSUInteger number_of_rates = 0;
    NSError *xpath_error;
    
    // How many compartments do we have?
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    NSUInteger number_of_compartments = [compartment_vector count];
    
    // How many basal processes do we have?
    NSArray *basal_generation_array = [model_tree nodesForXPath:@".//basalGenerationBlock/generation_term" error:&xpath_error];
    for (NSXMLElement *basal_generation_term in basal_generation_array)
    {
        NSString *compartment = [[basal_generation_term attributeForName:@"compartment"] stringValue];
        if ([compartment isEqualToString:@"all"] == YES)
        {
            number_of_rates = number_of_rates + number_of_compartments;
        }
        else
        {
            number_of_rates++;
        }
    }
    
    NSArray *basal_clearance_array = [model_tree nodesForXPath:@".//basalClearanceBlock/clearance_term" error:&xpath_error];
    for (NSXMLElement *basal_clearance_term in basal_clearance_array)
    {
        NSString *compartment = [[basal_clearance_term attributeForName:@"compartment"] stringValue];
        if ([compartment isEqualToString:@"all"] == YES)
        {
            number_of_rates = number_of_rates + number_of_compartments;
        }
        else
        {
            number_of_rates++;
        }
    }
    
    NSArray *operations_array = [model_tree nodesForXPath:@".//operationsBlock/operation" error:&xpath_error];
    for (NSXMLElement *operation in operations_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[operation attributeForName:@"compartment"] stringValue];
        
        if ([operation_compartment isEqualToString:@"all"] == YES)
        {
            number_of_rates = number_of_rates + number_of_compartments;
        }
        else
        {
            number_of_rates++;
        }
    }
    
    return number_of_rates;
}


@end
