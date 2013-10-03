//
//  VLGSLLanguageAdaptor.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/3/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLGSLLanguageAdaptor.h"

@implementation VLGSLLanguageAdaptor

#pragma mark - kinetics methods
-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options
{
    // counters -
    NSUInteger rate_counter = 0;
    NSUInteger parameter_counter = 0;
    
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // get trees from the options -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    __unused NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    // headers -
    [buffer appendString:@"include \"Kinetics.h\"\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"static void Kinetics(double t,double const state_vector[], gsl_vector *pRateVector, void* parameter_object)\n"];
    [buffer appendString:@"{\n"];
    [buffer appendString:@"\t/* initialize -- */\n"];
    [buffer appendString:@"\tdouble dbl_tmp = 0.0;\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"\t/* Get the parameters - */\n"];
    [buffer appendString:@"\tstruct VLParameters* parameter_struct = (struct VLParameters *)parameter_object;\n"];
    [buffer appendString:@"\tgsl_vector *pV = parameter_struct->pModelParameterVector;\n"];
    [buffer appendString:@"\n"];
    
    // ok, so we need to load the operations, and generate the kinetics. The functional
    // form of the rate laws depends upon the type attribute *and* the type attribute on the species
    NSError *xpath_error;
    NSArray *operations_array = [model_tree nodesForXPath:@".//operationsBlock/operation" error:&xpath_error];
    for (NSXMLElement *operation in operations_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[operation attributeForName:@"compartment"] stringValue];
        
        if ([operation_compartment isEqualToString:@"all"] == YES)
        {
            // get the list of compartments, and build this rate law in each -
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
    
    [buffer appendString:@"}\n"];
    
    // return -
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
    [buffer appendFormat:@"\t/* index: %lu */\n",*rate_index];
    [buffer appendString:@"\t/* ---------------------------------------------------------------------------- */\n"];
    
    // what type?
    if ([operation_type isEqualToString:@"Michaelis–Menten"] == YES)
    {
        [buffer appendFormat:@"\tdouble kCAT_%@ = gsl_vector_get(pV,%lu);\n",operation_name,(*parameter_index)++];
        
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
                [buffer appendFormat:@"\tdouble K_%@_%@ = gsl_vector_get(pV,%lu);\n",operation_name,reactant_symbol,(*parameter_index)++];
            }
        }
        
        // build the rate law -
        [buffer appendFormat:@"\tdbl_tmp = kCAT_%@*",operation_name];
        
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
    [buffer appendString:@"	gsl_vector *pModelParameterVector;\n"];
    [buffer appendString:@"};\n\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"/* public methods */\n"];
    [buffer appendString:@"static void Kinetics(double t,double const state_vector[], gsl_vector *pRateVector, void* parameter_object);\n\n"];
    [buffer appendString:@"\n"];

    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateModelMassBalancesImplBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // headers -
    [buffer appendString:@"Yes...."];
    
    
    // return -
    return [NSString stringWithString:buffer];

}

-(NSString *)generateModelMassBalancesHeaderBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // headers -
    [buffer appendString:@"No..."];
    
    
    // return -
    return [NSString stringWithString:buffer];

}

-(NSString *)generateModelDriverImplBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // headers -
    [buffer appendString:@"Driver ..."];
    
    
    // return -
    return [NSString stringWithString:buffer];
}



@end
