//
//  VLGSLLanguageAdaptor.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/3/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLGSLLanguageAdaptor.h"

#define NEW_LINE [buffer appendString:@"\n"]

@implementation VLGSLLanguageAdaptor

#pragma mark - kinetics methods
-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options
{
    // counters -
    NSUInteger rate_counter = 0;
    NSUInteger parameter_counter = 0;
    NSUInteger state_counter = 0;
    
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // get trees from the options -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    __unused NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    // headers -
    [buffer appendString:@"#include \"Kinetics.h\"\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"void Kinetics(double t,double const state_vector[], gsl_vector *pRateVector, void* parameter_object)\n"];
    [buffer appendString:@"{\n"];
    [buffer appendString:@"\t/* initialize -- */\n"];
    [buffer appendString:@"\tdouble dbl_tmp = 0.0;\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"\t/* Get the parameters - */\n"];
    [buffer appendString:@"\tstruct VLParameters *parameter_struct = (struct VLParameters *)parameter_object;\n"];
    [buffer appendString:@"\tgsl_vector *pV = parameter_struct->pModelKineticsParameterVector;\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"\t/* Alias elements of the state vector - */\n"];
    NSError *xpath_error;
    NSArray *state_vector = [model_tree nodesForXPath:@".//listOfSpecies/species" error:&xpath_error];
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    for (NSXMLElement *compartment in compartment_vector)
    {
        // get compartment -
        NSString *compartment_symbol = [[compartment attributeForName:@"symbol"] stringValue];
        
        for (NSXMLElement *state in state_vector)
        {
            NSString *state_symbol = [[state attributeForName:@"symbol"] stringValue];
            NSString *final_symbol = [NSString stringWithFormat:@"%@_%@",state_symbol,compartment_symbol];
            [buffer appendFormat:@"\tdouble %@ = state_vector[%lu];\n",final_symbol,state_counter++];
        }
    }
    
    [buffer appendString:@"\n"];
    
    // ok, so we need to load the operations, and generate the kinetics. The functional
    // form of the rate laws depends upon the type attribute *and* the type attribute on the species
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
                NSString *rate_law = [self formulateRateLawForOperation:operation
                                                          inCompartment:local_compartment
                                                            atRateIndex:&rate_counter
                                                      andParameterIndex:&parameter_counter];
                
                [buffer appendString:rate_law];
            }
        }
        else
        {
            // ok, we have a specific compartment, build the rate law
            NSString *rate_law = [self formulateRateLawForOperation:operation
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
            NSString *generation_rate_law = [self formulateBasalGenerationRateLawForOperation:basal_generation_term
                                                                                inCompartment:operation_compartment
                                                                                  atRateIndex:&rate_counter
                                                                            andParameterIndex:&parameter_counter];
            
            [buffer appendString:generation_rate_law];
        }
    }
    
    // Last, process the clearance block -
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
            NSString *clearance_rate_law = [self formulateBasalClearanceRateLawForOperation:basal_clearance_term
                                                                               inCompartment:operation_compartment
                                                                                 atRateIndex:&rate_counter
                                                                           andParameterIndex:&parameter_counter];
            
            [buffer appendString:clearance_rate_law];
        }
    }
    
    [buffer appendString:@"}\n"];
    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)formulateBasalClearanceRateLawForOperation:(NSXMLElement *)operation
                                           inCompartment:(NSString *)compartment
                                             atRateIndex:(NSUInteger *)rate_index
                                       andParameterIndex:(NSUInteger *)parameter_index
{
    NSMutableString *buffer = [NSMutableString string];
    
    NSString *species = [[operation attributeForName:@"symbol"] stringValue];
    NSString *species_symbol = [NSString stringWithFormat:@"%@_%@",species,compartment];
    
    [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
    [buffer appendFormat:@"\t/* Basal clerance: %@ */\n",species];
    [buffer appendFormat:@"\t/* Type: %@ */\n",@"FIRST_ORDER"];
    [buffer appendFormat:@"\t/* Compartment: %@ */\n",compartment];
    [buffer appendFormat:@"\t/* index: %lu */\n",*rate_index];
    [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
    [buffer appendFormat:@"\tdouble kCLEARANCE_%@_%@ = gsl_vector_get(pV,%lu);\n",species,compartment,(*parameter_index)++];
    [buffer appendFormat:@"\tdbl_tmp = (kCLEARANCE_%@)*%@;\n",species_symbol,species_symbol];
    [buffer appendString:@"\tgsl_vector_set(pRateVector,"];
    [buffer appendFormat:@"%lu,dbl_tmp);\n",(*rate_index)++];
    [buffer appendString:@"\n"];
    
    return [NSString stringWithString:buffer];
}

-(NSString *)formulateBasalGenerationRateLawForOperation:(NSXMLElement *)operation
                                           inCompartment:(NSString *)compartment
                                             atRateIndex:(NSUInteger *)rate_index
                                       andParameterIndex:(NSUInteger *)parameter_index
{
    NSMutableString *buffer = [NSMutableString string];
    
    NSString *species = [[operation attributeForName:@"symbol"] stringValue];
    
    [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
    [buffer appendFormat:@"\t/* Basal generation: %@ */\n",species];
    [buffer appendFormat:@"\t/* Type: %@ */\n",@"ZERO_ORDER"];
    [buffer appendFormat:@"\t/* Compartment: %@ */\n",compartment];
    [buffer appendFormat:@"\t/* index: %lu */\n",*rate_index];
    [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
    [buffer appendFormat:@"\tdouble GENERATION_%@_%@ = gsl_vector_get(pV,%lu);\n",species,compartment,(*parameter_index)++];
    [buffer appendString:@"\tgsl_vector_set(pRateVector,"];
    [buffer appendFormat:@"%lu,GENERATION_%@_%@);\n",(*rate_index)++,species,compartment];
    [buffer appendString:@"\n"];

    
    return [NSString stringWithString:buffer];
}

-(NSString *)formulateRateLawForOperation:(NSXMLElement *)operation
                            inCompartment:(NSString *)compartment
                              atRateIndex:(NSUInteger *)rate_index
                        andParameterIndex:(NSUInteger *)parameter_index
{
    NSMutableString *buffer = [NSMutableString string];
    NSString *operation_name = [[operation attributeForName:@"symbol"] stringValue];
    NSString *operation_type = [[operation attributeForName:@"type"] stringValue];
    
    [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
    [buffer appendFormat:@"\t/* Operation: %@ */\n",operation_name];
    [buffer appendFormat:@"\t/* Type: %@ */\n",operation_type];
    [buffer appendFormat:@"\t/* Compartment: %@ */\n",compartment];
    [buffer appendFormat:@"\t/* index: %lu */\n",*rate_index];
    [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
    
    // what type?
    if ([operation_type isEqualToString:@"Michaelis–Menten"] == YES)
    {
        NSString *enzyme_symbol;
        [buffer appendFormat:@"\tdouble kCAT_%@_%@ = gsl_vector_get(pV,%lu);\n",operation_name,compartment,(*parameter_index)++];
        
        // get the reactants -
        NSArray *reactants_array = [operation nodesForXPath:@"./listOfInputs/species_reference" error:nil];
        for (NSXMLElement *reactant in reactants_array)
        {
            NSString *reactant_type = [[reactant attributeForName:@"type"] stringValue];
            if ([reactant_type isEqualToString:@"dynamic"] == YES)
            {
                // Get the reactant symbol -
                NSString *reactant_symbol = [[reactant attributeForName:@"symbol"] stringValue];
                
                // build the line -
                [buffer appendFormat:@"\tdouble K_%@_%@_%@ = gsl_vector_get(pV,%lu);\n",operation_name,reactant_symbol,compartment,(*parameter_index)++];
            }
            else if ([reactant_type isEqualToString:@"enzyme"] == YES)
            {
                enzyme_symbol = [NSString stringWithFormat:@"E_%@",compartment];
            }
        }
        
        // build the rate law -
        [buffer appendFormat:@"\tdbl_tmp = kCAT_%@_%@*%@",operation_name,compartment,enzyme_symbol];
        if ([reactants_array count]>0)
        {
            [buffer appendString:@"*"];
        }
        else
        {
            [buffer appendString:@";\n"];
        }
        
        NSUInteger NUMBER_OF_REACTANTS = [reactants_array count];
        NSUInteger reactant_counter = 0;
        for (NSXMLElement *reactant in reactants_array)
        {
            NSString *reactant_type = [[reactant attributeForName:@"type"] stringValue];
            if ([reactant_type isEqualToString:@"dynamic"] == YES)
            {
                // Get the reactant symbol -
                NSString *reactant_symbol = [[reactant attributeForName:@"symbol"] stringValue];
                NSString *species_rate_symbol = [NSString stringWithFormat:@"%@_%@",reactant_symbol,compartment];
                
                // build the line -
                [buffer appendFormat:@"(%@/(K_%@_%@_%@ + %@))",species_rate_symbol,operation_name,reactant_symbol,compartment,species_rate_symbol];
                
                
                NSLog(@"(%lu,%lu)",reactant_counter,NUMBER_OF_REACTANTS);
                
                if (reactant_counter < (NUMBER_OF_REACTANTS - 2))
                {
                    [buffer appendString:@"*"];
                }
                else
                {
                    [buffer appendString:@";"];
                }
                
                reactant_counter++;
            }
        }
        
        [buffer appendString:@"\n"];
        [buffer appendString:@"\tgsl_vector_set(pRateVector,"];
        [buffer appendFormat:@"%lu,dbl_tmp);\n",(*rate_index)++];
        [buffer appendString:@"\n"];
    }
    
    
    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateModelOperationKineticsHeaderBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // headers -
    [buffer appendString:@"/* Load the GSL and other headers - */\n"];
    [buffer appendString:@"#include <stdio.h>\n"];
    [buffer appendString:@"#include <math.h>\n"];
    [buffer appendString:@"#include <time.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_errno.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_matrix.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_odeiv.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_vector.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_blas.h>\n\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"/* parameter struct */\n"];
    [buffer appendString:@"struct VLParameters\n"];
    [buffer appendString:@"{\n"];
    [buffer appendString:@"\tgsl_vector *pModelKineticsParameterVector;\n"];
    [buffer appendString:@"\tgsl_vector *pModelPhysicalParameterVector;\n"];
    [buffer appendString:@"};\n\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"/* public methods */\n"];
    [buffer appendString:@"void Kinetics(double t,double const state_vector[], gsl_vector *pRateVector, void* parameter_object);\n\n"];
    [buffer appendString:@"\n"];

    // return -
    return [NSString stringWithString:buffer];
}


#pragma mark - mass balances
-(NSString *)generateModelMassBalancesImplBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    NSUInteger balance_index = 0;
    NSUInteger physical_parameter_index = 0;
    NSUInteger state_counter = 0;
    
    // get trees from the options -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    
    // system dimension?
    NSUInteger NUMBER_OF_RATES = [self calculateNumberOfRatesInModelTree:model_tree];
    
    // headers -
    [buffer appendString:@"#include \"MassBalances.h\"\n"];
    NEW_LINE;
    
    [buffer appendString:@"/* Problem specific define statements -- */\n"];
    [buffer appendFormat:@"#define NUMBER_OF_RATES %lu\n",NUMBER_OF_RATES];
    NEW_LINE;
    
    [buffer appendString:@"int MassBalances(double t,const double x[],double f[],void * parameter_object)\n"];
    [buffer appendString:@"{\n"];
    [buffer appendString:@"\t/* Evaluate the kinetics */\n"];
    [buffer appendString:@"\tstruct VLParameters *parameter_struct = (struct VLParameters *)parameter_object;\n"];
    [buffer appendString:@"\tgsl_vector *pRateVector = gsl_vector_alloc(NUMBER_OF_RATES);\n"];
    [buffer appendString:@"\tKinetics(t,x,pRateVector,parameter_object);\n"];
    NEW_LINE;
    
    [buffer appendString:@"\t/* Get the physical parameter vector -- */\n"];
    [buffer appendString:@"\tgsl_vector *pV = parameter_struct->pModelPhysicalParameterVector;\n"];
    NEW_LINE;
    
    
    [buffer appendString:@"\t/* Evaluate the balances -- */\n"];
    [buffer appendString:@"\tdouble dbl_tmp = 0.0;\n"];
    NEW_LINE;
    
    // ok, formulate the mass balance equation -
    NSError *xpath_error;
    NSArray *state_vector = [model_tree nodesForXPath:@".//listOfSpecies/species" error:&xpath_error];
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    
    [buffer appendString:@"\t/* Alias the species -- */\n"];
    for (NSXMLElement *compartment in compartment_vector)
    {
        // get compartment -
        NSString *compartment_symbol = [[compartment attributeForName:@"symbol"] stringValue];
        
        for (NSXMLElement *state in state_vector)
        {
            NSString *state_symbol = [[state attributeForName:@"symbol"] stringValue];
            NSString *final_symbol = [NSString stringWithFormat:@"%@_%@",state_symbol,compartment_symbol];
            [buffer appendFormat:@"\tdouble %@ = x[%lu];\n",final_symbol,state_counter++];
        }
    }
    
    [buffer appendString:@"\n"];

    // load the circulatory map -
    NSXMLDocument *circulation_document;
    NSString *path_to_mapping_file = [[NSBundle mainBundle] pathForResource:@"Circulation" ofType:@"xml"];
    if (path_to_mapping_file!=nil)
    {
        // load XML file and get output nodes -
        circulation_document = [VLCoreUtilitiesLib createXMLDocumentFromFile:[NSURL fileURLWithPath:path_to_mapping_file]];
        
        for (NSXMLElement *compartment_node in compartment_vector)
        {
            // compartment symbol =
            NSString *compartment_symbol = [[compartment_node attributeForName:@"symbol"] stringValue];
            [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
            [buffer appendFormat:@"\t/* Compartment: %@ */\n",compartment_symbol];
            [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
            [buffer appendFormat:@"\tdouble V_%@ = gsl_vector_get(pV,%lu);\n",compartment_symbol,(physical_parameter_index)++];
            
            // find the inputs to this compartment -
            NSError *xpath_error;
            NSString *xpath_input_string = [NSString stringWithFormat:@".//organ_model[@symbol='%@']/listOfInputs/connection",compartment_symbol];
            NSArray *input_array = [circulation_document nodesForXPath:xpath_input_string error:&xpath_error];
            for (NSXMLElement *input_node in input_array)
            {
                NSString *from_compartment_string = [[input_node attributeForName:@"symbol"] stringValue];
                [buffer appendFormat:@"\tdouble FLOW_IN_%@_%@ = gsl_vector_get(pV,%lu);\n",compartment_symbol,from_compartment_string,(physical_parameter_index)++];
            }
            
            NSString *xpath_output_string = [NSString stringWithFormat:@".//organ_model[@symbol='%@']/listOfOutputs/connection",compartment_symbol];
            NSArray *output_array = [circulation_document nodesForXPath:xpath_output_string error:&xpath_error];
            for (NSXMLElement *output_node in output_array)
            {
                NSString *from_compartment_string = [[output_node attributeForName:@"symbol"] stringValue];
                [buffer appendFormat:@"\tdouble FLOW_OUT_%@_%@ = gsl_vector_get(pV,%lu);\n",compartment_symbol,from_compartment_string,(physical_parameter_index)++];
            }


            
            for (NSXMLElement *state_node in state_vector)
            {
                // balance string -
                NSString *balance_string = [self formulateBalanceEquationsForCirculatoryMap:circulation_document
                                                                              withModelTree:model_tree
                                                                             forCompartment:compartment_node
                                                                                 forSpecies:state_node
                                                                             atBalanceIndex:&balance_index
                                                                   atPhysicalParameterIndex:&physical_parameter_index];
                
                // grab -
                [buffer appendString:balance_string];
            }
            
            NEW_LINE;
        }
    }

    
    [buffer appendString:@"\treturn(GSL_SUCCESS);\n"];
    [buffer appendString:@"}\n"];
    
    // return -
    return [NSString stringWithString:buffer];

}

-(NSString *)formulateBalanceEquationsForCirculatoryMap:(NSXMLDocument *)circulatoryTree
                                          withModelTree:(NSXMLDocument *)modelTree
                                         forCompartment:(NSXMLElement *)compartment
                                             forSpecies:(NSXMLElement *)species
                                         atBalanceIndex:(NSUInteger *)balanceIndex
                               atPhysicalParameterIndex:(NSUInteger *)physicalParameterIndex


{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // What compartment -
    NSString *compartment_string = [[compartment attributeForName:@"symbol"] stringValue];
    NSString *species_string = [[species attributeForName:@"symbol"] stringValue];
    
    // balance -
    [buffer appendFormat:@"\tf[%lu] = ",(*balanceIndex)++];
    NSString *xpath_output_string = [NSString stringWithFormat:@".//organ_model[@symbol='%@']/listOfOutputs/connection",compartment_string];
    NSArray *output_array = [circulatoryTree nodesForXPath:xpath_output_string error:nil];
    for (NSXMLElement *output_node in output_array)
    {
        NSString *from_compartment_string = [[output_node attributeForName:@"symbol"] stringValue];
        [buffer appendFormat:@" - (FLOW_OUT_%@_%@)*%@_%@",compartment_string,from_compartment_string,species_string,compartment_string];
    }
    
    [buffer appendString:@";\n"];
    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateModelMassBalancesHeaderBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // headers -
    [buffer appendString:@"/* Load the GSL and other headers - */\n"];
    [buffer appendString:@"#include <stdio.h>\n"];
    [buffer appendString:@"#include <math.h>\n"];
    [buffer appendString:@"#include <time.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_errno.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_matrix.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_odeiv.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_vector.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_blas.h>\n\n"];
    
    NEW_LINE;
    [buffer appendString:@"/* Load the model specific headers - */\n"];
    [buffer appendString:@"#include \"Kinetics.h\"\n"];
    NEW_LINE;
    [buffer appendString:@"/* public methods */\n"];
    [buffer appendString:@"int MassBalances(double t,const double x[],double f[],void * parameter_object);\n"];
    
    
    // return -
    return [NSString stringWithString:buffer];

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

#pragma mark - driver
-(NSString *)generateModelDriverImplBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // main -
    [buffer appendString:@"/* Load the GSL and other headers - */\n"];
    [buffer appendString:@"#include <stdio.h>\n"];
    [buffer appendString:@"#include <math.h>\n"];
    [buffer appendString:@"#include <time.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_errno.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_matrix.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_odeiv.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_vector.h>\n"];
    [buffer appendString:@"#include <gsl/gsl_blas.h>\n\n"];
    
    NEW_LINE;
    [buffer appendString:@"/* Load the model specific headers - */\n"];
    [buffer appendString:@"#include \"MassBalances.h\"\n"];
    NEW_LINE;

    [buffer appendString:@"int main(int argc, char* const argv[])\n"];
    [buffer appendString:@"{\n"];
    [buffer appendString:@"\treturn 0;\n"];
    [buffer appendString:@"}\n"];
    
    // return -
    return [NSString stringWithString:buffer];
}

#pragma mark - make file
-(NSString *)generateModelMakeFileBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    NSMutableArray *file_name_array = [[NSMutableArray alloc] init];
    
    // get trees from the options -
    __unused NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    
    
    // build the flags at the beginning -
    [buffer appendString:@"CFLAGS = -std=c99 -pedantic -v -O2\n"];
    [buffer appendString:@"CC = gcc\n"];
    [buffer appendString:@"LFLAGS = /usr/local/lib/libgsl.a /usr/local/lib/libgslcblas.a -lm\n"];
    NEW_LINE;
    
    // Get the list of transformations -
    NSError *xpath_error;
    NSArray *transformation_array = [transformation_tree nodesForXPath:@"//Transformation" error:&xpath_error];
    for (NSXMLElement *transformation in transformation_array)
    {
        // get the children -
        NSString *output_file_name = [[[transformation nodesForXPath:@"./property[@key=\"OUTPUT_FILE_NAME\"]/@value" error:&xpath_error] lastObject] stringValue];
        
        // What is the extension?
        NSString *file_extension = [output_file_name pathExtension];
        if ([file_extension isEqualToString:@"c"] == YES || [file_extension isEqualToString:@".c"] == YES)
        {
            // ok, so grab -
            NSRange name_range = NSMakeRange(0, [output_file_name length] - 2);
            NSString *file_name = [output_file_name substringWithRange:name_range];
            [file_name_array addObject:file_name];
        }
    }
    
    // write driver target -
    [buffer appendString:@"Driver: "];
    for (NSString *file_name in file_name_array)
    {
        [buffer appendFormat:@"%@.c ",file_name];
    }
    NEW_LINE;
    
    // write the compile line -
    [buffer appendString:@"\t$(CC) $(CCFLAGS) -o Driver "];
    for (NSString *file_name in file_name_array)
    {
        [buffer appendFormat:@"%@.c ",file_name];
    }
    [buffer appendString:@"$(LFLAGS)"];
    NEW_LINE;
    
    // write the clean target -
    [buffer appendString:@"clean:\n\trm -f "];
    
    for (NSString *file_name in file_name_array)
    {
        [buffer appendFormat:@"%@.o %@ ",file_name,file_name];
    }
    NEW_LINE;
    
    // return -
    return [NSString stringWithString:buffer];
}


@end
