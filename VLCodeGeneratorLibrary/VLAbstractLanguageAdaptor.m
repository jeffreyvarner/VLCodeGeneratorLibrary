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
-(NSString *)generateModelParametersBufferWithOptions:(NSDictionary *)options
{
    // counters -
    NSUInteger rate_counter = 0;
    NSUInteger parameter_counter = 0;
    NSUInteger state_counter = 0;

    // buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // ok, get the trees -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    NSError *xpath_error;
    
    // ok, so we need to load the operations, and generate the kinetics. The functional
    // form of the rate laws depends upon the type attribute *and* the type attribute on the species
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    NSArray *operations_array = [model_tree nodesForXPath:@".//operationsBlock/operation" error:&xpath_error];
    for (NSXMLElement *operation in operations_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[operation attributeForName:@"compartment"] stringValue];
        
        if ([operation_compartment isEqualToString:@"all"] == YES)
        {
            // get the list of compartments, and build this rate law in each -
            for (NSXMLElement *compartment in compartment_vector)
            {
                NSString *local_compartment = [[compartment attributeForName:@"symbol"] stringValue];
                
                // ok, we have a specific compartment, build the rate law
                NSString *rate_law = [self formulateParametersForOperation:operation
                                                          inCompartment:local_compartment
                                                            atRateIndex:&rate_counter
                                                      andParameterIndex:&parameter_counter];
                
                [buffer appendString:rate_law];
            }
        }
        else
        {
            // ok, we have a specific compartment, build the rate law
            NSString *rate_law = [self formulateParametersForOperation:operation
                                                      inCompartment:operation_compartment
                                                        atRateIndex:&rate_counter
                                                  andParameterIndex:&parameter_counter];
            
            
            [buffer appendString:rate_law];
        }
    }
    
    // ok, so let's process the basalGenerationBlock -
    NSArray *basal_generation_array = [model_tree nodesForXPath:@".//basalGenerationBlock/generation_term" error:&xpath_error];
    for (NSXMLElement *basal_generation_term in basal_generation_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[basal_generation_term attributeForName:@"compartment"] stringValue];
        
        if ([operation_compartment isEqualToString:@"all"] == YES)
        {
            
        }
        else
        {
            NSString *generation_rate_law = [self formulateBasalGenerationParametersForOperation:basal_generation_term
                                                                                inCompartment:operation_compartment
                                                                                  atRateIndex:&rate_counter
                                                                            andParameterIndex:&parameter_counter];
            
            [buffer appendString:generation_rate_law];
        }
    }
    
    // ok, process the clearance block -
    NSArray *basal_clerance_array = [model_tree nodesForXPath:@".//basalClearanceBlock/clearance_term" error:&xpath_error];
    for (NSXMLElement *basal_clearance_term in basal_clerance_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[basal_clearance_term attributeForName:@"compartment"] stringValue];
        
        if ([operation_compartment isEqualToString:@"all"] == YES)
        {
            
        }
        else
        {
            NSString *clearance_rate_law = [self formulateBasalClearanceParametersForOperation:basal_clearance_term
                                                                              inCompartment:operation_compartment
                                                                                atRateIndex:&rate_counter
                                                                          andParameterIndex:&parameter_counter];
            
            [buffer appendString:clearance_rate_law];
        }
    }
    
    // Last, process the compartment volumes -
    VLPBPKModelPhysicalParameterCalculator *volume_calculator = [VLPBPKModelPhysicalParameterCalculator buildCalculatorForModelTree:model_tree];
    for (NSXMLElement *compartment in compartment_vector)
    {
        // ok, we have a specific compartment,
        NSString *local_compartment = [[compartment attributeForName:@"symbol"] stringValue];
        
        // calculate the volume -
        CGFloat volume = [volume_calculator getVolumeForCompartmentWithSymbol:local_compartment];
        [buffer appendFormat:@"%f\n",volume];
    }


    return [NSString stringWithString:buffer];
}

-(NSString *)formulateBasalClearanceParametersForOperation:(NSXMLElement *)operation
                                          inCompartment:(NSString *)compartment
                                            atRateIndex:(NSUInteger *)rate_index
                                      andParameterIndex:(NSUInteger *)parameter_index
{
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // ok, we have a record.
    NSString *average_value = [[operation attributeForName:@"average_rate_constant"] stringValue];
    NSString *std_value = [[operation attributeForName:@"std_rate_constant"] stringValue];

    
    // calculate random value -
    CGFloat float_average_value = [average_value floatValue];
    CGFloat float_std_value = [std_value floatValue];
    CGFloat float_sample_value = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:float_average_value
                                                                         andStandardDeviation:float_std_value];
    
    // add to buffer -
    [buffer appendFormat:@"%f\n",float_sample_value];
    
    // return the buffer -
    return [NSString stringWithString:buffer];
}

-(NSString *)formulateBasalGenerationParametersForOperation:(NSXMLElement *)operation
                                           inCompartment:(NSString *)compartment
                                             atRateIndex:(NSUInteger *)rate_index
                                       andParameterIndex:(NSUInteger *)parameter_index
{
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // ok, we have a record.
    NSString *average_value = [[operation attributeForName:@"average_rate_constant"] stringValue];
    NSString *std_value = [[operation attributeForName:@"std_rate_constant"] stringValue];
    
    // calculate random value -
    CGFloat float_average_value = [average_value floatValue];
    CGFloat float_std_value = [std_value floatValue];
    CGFloat float_sample_value = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:float_average_value
                                                                             andStandardDeviation:float_std_value];
    
    // add to buffer -
    [buffer appendFormat:@"%f\n",float_sample_value];
    
    // return the buffer -
    return [NSString stringWithString:buffer];
}

-(NSString *)formulateParametersForOperation:(NSXMLElement *)operation
                            inCompartment:(NSString *)compartment
                              atRateIndex:(NSUInteger *)rate_index
                        andParameterIndex:(NSUInteger *)parameter_index
{
    NSMutableString *buffer = [NSMutableString string];
    
    NSError *xpath_error;
    NSArray *parameter_array = [operation nodesForXPath:@".//listOfParameters/parameter" error:&xpath_error];
    for (NSXMLElement *parameter_node in parameter_array)
    {
        // ok, we have a record.
        NSString *average_value = [[parameter_node attributeForName:@"average_value"] stringValue];
        NSString *std_value = [[parameter_node attributeForName:@"std_value"] stringValue];
        
        // calculate random value -
        CGFloat float_average_value = [average_value floatValue];
        CGFloat float_std_value = [std_value floatValue];
        CGFloat float_sample_value = [VLCoreUtilitiesLib generateSampleFromNormalDistributionWithMean:float_average_value
                                                                                 andStandardDeviation:float_std_value];
        
        // add to buffer -
        [buffer appendFormat:@"%f\n",float_sample_value];

    }
    
    // return -
    return [NSString stringWithString:buffer];
}


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
