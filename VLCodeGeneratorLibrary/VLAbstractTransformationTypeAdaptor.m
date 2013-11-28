//
//  VLAbstractTransformationTypeAdaptor.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 11/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLAbstractTransformationTypeAdaptor.h"

@implementation VLAbstractTransformationTypeAdaptor

-(void)dealloc
{
    [self cleanMyMemory];
}

#pragma mark - lifecycle
-(void)cleanMyMemory
{
    // kia my iVars -
    self.myTransformationName = nil;
}

#pragma mark - routing method
-(NSString *)processTransformationSelector:(SEL)selector withOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // return -
    return buffer;
}

//-(NSString *)processTransformationSelector:(SEL)selector withOptions:(NSDictionary *)options
//{
//    // initialize the buffer -
//    NSMutableString *buffer = [[NSMutableString alloc] init];
//    
//    // ok, so what tree type do we have?
//    NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
//    NSString *xpath = @"//listOfGlobalTransformationProperties/property[@key='MODEL_TREE_TYPE']/@value";
//    NSString *model_type = [[[transformation_tree nodesForXPath:xpath error:nil] lastObject] stringValue];
//    if ([model_type isCaseInsensitiveLike:@"SBML"] == YES)
//    {
//        [[self myLanguageAdaptor] setMyModelTreeType:VLAbstractLanguageAdaptorModelTreeTypeSBML];
//    }
//    else if ([model_type isCaseInsensitiveLike:@"CCML"] == YES)
//    {
//        [[self myLanguageAdaptor] setMyModelTreeType:VLAbstractLanguageAdaptorModelTreeTypeCCML];
//    }
//    else if ([model_type isCaseInsensitiveLike:@"PBPKML"] == YES)
//    {
//        [[self myLanguageAdaptor] setMyModelTreeType:VLAbstractLanguageAdaptorModelTreeTypePBPKML];
//    }
//    
//    // ok, let's create a method pointer -
//    if ([[self myLanguageAdaptor] respondsToSelector:selector] == YES)
//    {
//        //specify the function pointer
//        typedef NSString* (*method_pointer)(id,SEL,NSDictionary*);
//        
//        // get the actual method -
//        method_pointer command = (method_pointer)[[self myLanguageAdaptor] methodForSelector:selector];
//        
//        // run the method
//        NSString *code_block = command([self myLanguageAdaptor],selector,options);
//        [buffer appendString:code_block];
//    }
//    else
//    {
//        // ooops ...
//        // Our language adaptor doesn't run this command. Send an error message -
//        // ...
//    }
//    
//    // return -
//    return buffer;
//}

#pragma mark - transformation methods
-(NSString *)generateSBMLFileFromVFFWithOptions:(NSDictionary *)options;
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}


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

-(NSString *)generateModelForcingHeaderBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelForcingBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}


#pragma mark - language agnostic generation methods
-(NSString *)generateModelSolveModelScriptBufferWithOptions:(NSDictionary *)options
{
    // buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    
    // get trees from the options -
    __unused NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    // get the output path -
    NSError *xpath_error;
    NSString *output_path = [[[transformation_tree nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='OUTPUT_FILE_PATH']/@value" error:&xpath_error] lastObject] stringValue];
    
    // buffer -
    [buffer appendString:@"#!/bin/sh \n"];
    [buffer appendFormat:@"readonly OUTPUT_FILE=%@test_sim.out\n",output_path];
    [buffer appendFormat:@"readonly KINETICS_FILE=%@Parameters.dat\n",output_path];
    [buffer appendFormat:@"readonly IC_FILE=%@InitialConditions.dat\n",output_path];
    [buffer appendFormat:@"readonly ST_MATRIX=%@StoichiometricMatrix.dat\n",output_path];
    [buffer appendFormat:@"readonly FLOW_MATRIX=%@CirculationMatrix.dat\n",output_path];
    [buffer appendFormat:@"readonly VOLUME_FILE=%@Volume.dat\n",output_path];
    [buffer appendFormat:@"readonly TSTART=0\n"];
    [buffer appendFormat:@"readonly TSTOP=700\n"];
    [buffer appendFormat:@"readonly Ts=0.1\n"];
    [buffer appendString:@"\n"];
    
    [buffer appendString:@"\n"];
    [buffer appendString:@"rm $OUTPUT_FILE\n"];
    [buffer appendString:@"./Driver $OUTPUT_FILE $KINETICS_FILE $IC_FILE $ST_MATRIX $FLOW_MATRIX $VOLUME_FILE $TSTART $TSTOP $Ts\n"];
    
    return [NSString stringWithString:buffer];
}

-(NSString *)generateModelDebugBufferWithOptions:(NSDictionary *)options
{
    // buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    NSUInteger counter = 1;
    NSUInteger parameter_counter = 1;
    
    // list of comparments -
    [buffer appendString:@"// List of compartments -- \n"];
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    NSError *xpath_error;
    NSArray *compartment_vector = [model_tree nodesForXPath:@".//listOfCompartments/compartment" error:&xpath_error];
    for (NSXMLElement *compartment_node in compartment_vector)
    {
        NSString *compartment_symbol = [[compartment_node attributeForName:@"symbol"] stringValue];
        [buffer appendFormat:@"%lu %@ \n",(counter++),compartment_symbol];
    }
    
    // new line -
    [buffer appendString:@"\n"];
    [buffer appendString:@"// List of species -- \n"];
    NSArray *state_vector = [model_tree nodesForXPath:@".//listOfSpecies/species" error:&xpath_error];
    
    // process each compartment -
    counter = 1;
    for (NSXMLElement *compartment in compartment_vector)
    {
        // get the symbol -
        NSString *compartment_symbol = [[compartment attributeForName:@"symbol"] stringValue];
        
        // process each species -
        for (NSXMLElement *species in state_vector)
        {
            NSString *species_symbol = [[species attributeForName:@"symbol"] stringValue];
            [buffer appendFormat:@"%lu %@_%@ \n",(counter++),species_symbol,compartment_symbol];
        }
    }
    
    [buffer appendString:@"\n"];
    [buffer appendString:@"// List of parameters -- \n"];
    NSArray *operations_array = [model_tree nodesForXPath:@".//operationsBlock/operation" error:&xpath_error];
    for (NSXMLElement *operation in operations_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[operation attributeForName:@"compartment"] stringValue];
        NSString *operation_type = [[operation attributeForName:@"type"] stringValue];
        NSString *operation_name = [[operation attributeForName:@"symbol"] stringValue];
        
        if ([operation_type isEqualToString:@"Michaelis–Menten"] == YES)
        {
            [buffer appendFormat:@"%lu kCAT_%@_%@ \n",parameter_counter++,operation_name,operation_compartment];
            
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
                    [buffer appendFormat:@"%lu K_%@_%@_%@ \n",parameter_counter++,operation_name,reactant_symbol,operation_compartment];
                }
            }
        }
        else if ([operation_type isCaseInsensitiveLike:@"Mass-action"] == YES)
        {
            [buffer appendFormat:@"%lu k_%@_%@ \n",parameter_counter++,operation_name,operation_compartment];
        }
    }
    
    // ok, so let's process the basalGenerationBlock -
    NSArray *basal_generation_array = [model_tree nodesForXPath:@".//basalGenerationBlock/generation_term" error:&xpath_error];
    for (NSXMLElement *basal_generation_term in basal_generation_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[basal_generation_term attributeForName:@"compartment"] stringValue];
        NSString *generation_symbol = [[basal_generation_term attributeForName:@"symbol"] stringValue];
        
        // write -
        [buffer appendFormat:@"%lu generation_rate_%@_%@ \n",parameter_counter++,generation_symbol,operation_compartment];
    }
    
    // ok, process the clearance block -
    NSArray *basal_clerance_array = [model_tree nodesForXPath:@".//basalClearanceBlock/clearance_term" error:&xpath_error];
    for (NSXMLElement *basal_clearance_term in basal_clerance_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_compartment = [[basal_clearance_term attributeForName:@"compartment"] stringValue];
        NSString *clearance_symbol = [[basal_clearance_term attributeForName:@"symbol"] stringValue];
        
        // write -
        [buffer appendFormat:@"%lu clearance_rate_%@_%@ \n",parameter_counter++,clearance_symbol,operation_compartment];
    }
    
    // process mass transfer block -
    NSArray *mass_transfer_array = [model_tree nodesForXPath:@".//massTransferBlock/mass_transfer_term" error:&xpath_error];
    for (NSXMLElement *mass_transfer_term in mass_transfer_array)
    {
        // ok, get some attributes of the operation -
        NSString *operation_from_compartment = [[mass_transfer_term attributeForName:@"from_compartment"] stringValue];
        NSString *operation_to_compartment = [[mass_transfer_term attributeForName:@"to_compartment"] stringValue];
        NSString *transfer_symbol = [[mass_transfer_term attributeForName:@"symbol"] stringValue];
        
        // write -
        [buffer appendFormat:@"%lu mass_transfer_rate_%@_%@_%@ \n",parameter_counter++,transfer_symbol,operation_from_compartment,operation_to_compartment];
    }
    
    return [NSString stringWithString:buffer];
}

@end
