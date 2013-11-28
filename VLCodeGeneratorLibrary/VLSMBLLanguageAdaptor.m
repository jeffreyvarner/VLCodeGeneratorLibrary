//
//  VLSMBLLanguageAdaptor.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 11/28/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLSMBLLanguageAdaptor.h"

#define NAME 0
#define REACTANTS 1
#define PRODUCTS 2
#define FORWARD 4
#define REVERSE 3
#define TYPE 5

@interface VLSMBLLanguageAdaptor ()

-(NSMutableString *)xmlDocumentFromFlatFileBuffer:(NSMutableArray *)array;
-(NSMutableArray *)estimateModelSpeciesFromFlatFile:(NSMutableArray *)array;
-(NSMutableString *)formulateSpeciesBlock:(NSMutableArray *)array;
-(NSMutableString *)formulateReactionBlock:(NSMutableArray *)array;
-(NSMutableArray *)processRawReactionRates:(NSMutableArray *)array;
-(NSMutableString *)processParametersBlock:(NSMutableArray *)array;


@end

@implementation VLSMBLLanguageAdaptor

-(NSString *)generateSBMLFileFromVFFWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // get the tree's
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    __unused NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    // ok, the model tree is the xml version of a VFF -
    // Get all the data out of the reaction records
    NSMutableArray *reaction_array = [[NSMutableArray alloc] init];
    NSArray *reaction_records = [model_tree nodesForXPath:@".//reaction_records/@data" error:nil];
    for (NSXMLElement *reaction_node in reaction_records)
    {
        NSString *value = [reaction_node stringValue];
        [reaction_array addObject:value];
    }
    
    // Need to pre-process the rates to estimate what type of rate it is *and* to split
    // reverible rates
    NSMutableArray *spiltRates = [self processRawReactionRates:reaction_array];
    
    // Ok, so we need to convert the VFF into a simple XML document -
    buffer = [self xmlDocumentFromFlatFileBuffer:spiltRates];

    // return
    return buffer;
}

#pragma mark - transformation specific methods
-(NSMutableArray *)processRawReactionRates:(NSMutableArray *)array
{
    // Initialize a new array -
    __block NSMutableArray *newReactionArray = [NSMutableArray array];
    
    // enumerate through the old array - if we have reversible rate, split.
    // also estimate what type of reaction we have -
    [array enumerateObjectsUsingBlock:^(NSArray *reactionArray,NSUInteger index,BOOL *stop){
        
        // Ok, so let's check to see if we have a -inf in the reverse slot -
        NSString *tmpReverseField = [reactionArray objectAtIndex:REVERSE];
        if ([tmpReverseField isEqualToString:@"-inf"])
        {
            // Ok, so we need to spilt this reaction into two -
            NSString *newNameForward = [NSString stringWithFormat:@"%@_FORWARD",[reactionArray objectAtIndex:NAME]];
            NSString *newNameReverse = [NSString stringWithFormat:@"%@_REVERSE",[reactionArray objectAtIndex:NAME]];
            NSString *tmpReactants = [reactionArray objectAtIndex:REACTANTS];
            NSString *tmpProducts = [reactionArray objectAtIndex:PRODUCTS];
            
            // Build *two* new rates -
            // Forward -
            NSArray *myForwardArray = [NSArray arrayWithObjects:newNameForward,
                                       tmpReactants,
                                       tmpProducts,
                                       @"0",
                                       @"inf;",
                                       @"FORWARD", nil];
            
            NSMutableArray *tmpForwardRate = [NSMutableArray arrayWithArray:[myForwardArray copy]];
            [newReactionArray addObject:tmpForwardRate];
            
            
            // Reverse -
            NSArray *myReverseArray = [NSArray arrayWithObjects:newNameReverse,
                                       tmpProducts,
                                       tmpReactants,
                                       @"0",
                                       @"inf;",
                                       @"REVERSE", nil];
            
            NSMutableArray *tmpReverseRate = [NSMutableArray arrayWithArray:[myReverseArray copy]];
            [newReactionArray addObject:tmpReverseRate];
            
            
        }
        else
        {
            // Copy this element?
            NSMutableArray *tmpReactionArray = [NSMutableArray arrayWithArray:[reactionArray copy]];
            [tmpReactionArray insertObject:@"CATALYTIC" atIndex:TYPE];
            
            // Add this reaction to the container -
            [newReactionArray addObject:tmpReactionArray];
            
        }
        
    }];
    
    // return the new array -
    return newReactionArray;
}

-(NSMutableString *)xmlDocumentFromFlatFileBuffer:(NSMutableArray *)array
{
    // Local buffer -
    __block NSMutableString *localBuffer = [NSMutableString string];
    
    // Get the name -
    NSString *tmpModelName = @"TEST";
    NSString *tmpCompartment = @"TEST";
    
    
    // Add the header line -
    [localBuffer appendString:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n"];
    [localBuffer appendString:@"<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" level=\"3\" version=\"1\">\n"];
    [localBuffer appendFormat:@"<model name=\"%@\">\n",tmpModelName];
    [localBuffer appendString:@"<listOfCompartments>\n"];
    [localBuffer appendFormat:@"<compartment id=\"%@\" name=\"%@\" constant=\"true\"/>\n",tmpCompartment,tmpCompartment];
    [localBuffer appendString:@"</listOfCompartments>\n"];
    [localBuffer appendString:@"<listOfSpecies>\n"];
    
    // Get the list of species -
    NSString *tmpSpeciesList = [self formulateSpeciesBlock:array];
    [localBuffer appendString:tmpSpeciesList];
    
    [localBuffer appendString:@"</listOfSpecies>\n"];
    [localBuffer appendString:@"<listOfParameters>\n"];
    
    NSString *tmpParameterBlock = [self processParametersBlock:array];
    [localBuffer appendString:tmpParameterBlock];
    
    [localBuffer appendString:@"</listOfParameters>\n"];
    [localBuffer appendString:@"<listOfReactions>\n"];
    
    // Formulate the reaction block -
    NSString *tmpReactionBlock = [self formulateReactionBlock:array];
    [localBuffer appendString:tmpReactionBlock];
    
    [localBuffer appendString:@"</listOfReactions>\n"];
    
    
    [localBuffer appendString:@"</model>\n"];
    [localBuffer appendString:@"</sbml>\n"];
    
    // return the buffer -
    return localBuffer;
}

-(NSMutableString *)processParametersBlock:(NSMutableArray *)array
{
    // Initialize the buffer -
    __block NSMutableString *tmpBuffer = [NSMutableString string];
    
    //<parameter id="GENE_SOURCE" name="k_88" value="3.52661490065774" constant="true"/>
    [array enumerateObjectsUsingBlock:^(NSArray *reactionArray,NSUInteger index,BOOL *stop){
        
        // Get the name -
        NSString *tmpReactionName = [reactionArray objectAtIndex:NAME];
        
        // fire up the buffer -
        [tmpBuffer appendFormat:@"<parameter id=\"R%ld_%@\" name=\"k_%ld\"",index,tmpReactionName,index];
        
        // Get the type -
        NSString *tmpReactionType = [reactionArray objectAtIndex:TYPE];
        if ([tmpReactionType isEqualToString:@"FORWARD"])
        {
            CGFloat value = 10.0f*(((float)rand())/RAND_MAX);
            [tmpBuffer appendFormat:@" value=\"%.3f\" constant=\"true\"/>\n",value];
        }
        else if ([tmpReactionType isEqualToString:@"REVERSE"])
        {
            CGFloat value = 0.1f*(((float)rand())/RAND_MAX);
            [tmpBuffer appendFormat:@" value=\"%.3f\" constant=\"true\"/>\n",value];
        }
        else
        {
            CGFloat value = 1.0f*(((float)rand())/RAND_MAX);
            [tmpBuffer appendFormat:@" value=\"%.3f\" constant=\"true\"/>\n",value];
        }
        
    }];
    
    // return the buffer -
    return tmpBuffer;
}

-(NSMutableString *)formulateReactionBlock:(NSMutableArray *)array
{
    __block NSMutableString *tmpBuffer = [NSMutableString string];
    
    
    // parse the record array
    [array enumerateObjectsUsingBlock:^(NSArray *rowArray,NSUInteger index,BOOL *stop){
        
        // Ok, Get the reactant and product string -
        NSString *tmpReactants = [rowArray objectAtIndex:REACTANTS];
        NSString *tmpProducts = [rowArray objectAtIndex:PRODUCTS];
        NSString *tmpName = [rowArray objectAtIndex:NAME];
        NSString *tmpIDField = [NSString stringWithFormat:@"R%ld_%@",index,tmpName];
        NSString *tmpSBMLReactionName = [NSString stringWithFormat:@"%@ = %@",tmpReactants,tmpProducts];
        
        // Formulate the reaction string -
        [tmpBuffer appendFormat:@"<reaction id=\"%@\" name=\"%@\" reversible=\"false\" fast=\"false\">\n",tmpIDField,tmpSBMLReactionName];
        
        // Ok, let's cut around the +'s
        NSArray *chunksReactants = [tmpReactants componentsSeparatedByString:@"+"];
        [tmpBuffer appendString:@"<listOfReactants>\n"];
        
        // Process the chunks array -
        [chunksReactants enumerateObjectsUsingBlock:^(NSString *species,NSUInteger species_index,BOOL *species_stop){
            
            // Process all species *except* the empty set
            if ([species isNotEqualTo:@"[]"])
            {
                // Ok, so we need to check for stcoeff -
                NSRange range = [species rangeOfString:@"*" options:NSCaseInsensitiveSearch];
                if(range.location == NSNotFound)
                {
                    // Ok, so if I get here I have only 1's at the stcoeff -
                    [tmpBuffer appendFormat:@"<speciesReference species=\"%@\" stoichiometry=\"1\" constant=\"false\"/>\n",species];
                }
                else
                {
                    // Ok, so we have a stcoeff - cut around it
                    NSArray *chunksStCoeff = [species componentsSeparatedByString:@"*"];
                    NSString *speciesWithCoeff = [chunksStCoeff lastObject];
                    NSString *speciesCoeff = [chunksStCoeff objectAtIndex:0];
                    
                    // Put the speciesReference in and the stcoeff -
                    [tmpBuffer appendFormat:@"<speciesReference species=\"%@\" stoichiometry=\"%@\" constant=\"false\"/>\n",speciesWithCoeff,speciesCoeff];
                }
            }
            else {
                // Ok, so if I get here I have only 1's at the stcoeff -
                [tmpBuffer appendString:@"<speciesReference stoichiometry=\"1\" constant=\"false\"/>\n"];
            }
        }];
        
        // add closing reactants line -
        [tmpBuffer appendString:@"</listOfReactants>\n"];
        
        // Ok, so we need to process the products -
        [tmpBuffer appendString:@"<listOfProducts>\n"];
        NSArray *chunksProducts = [tmpProducts componentsSeparatedByString:@"+"];
        
        // Process the chunks array -
        [chunksProducts enumerateObjectsUsingBlock:^(NSString *species,NSUInteger species_index,BOOL *species_stop){
            
            // Process all species *except* the empty set
            if ([species isNotEqualTo:@"[]"])
            {
                // Ok, so we need to check for stcoeff -
                NSRange range = [species rangeOfString:@"*" options:NSCaseInsensitiveSearch];
                if(range.location == NSNotFound)
                {
                    // Ok, so if I get here I have only 1's at the stcoeff -
                    [tmpBuffer appendFormat:@"<speciesReference species=\"%@\" stoichiometry=\"1\" constant=\"false\"/>\n",species];
                }
                else
                {
                    // Ok, so we have a stcoeff - cut around it
                    NSArray *chunksStCoeff = [species componentsSeparatedByString:@"*"];
                    NSString *speciesWithCoeff = [chunksStCoeff lastObject];
                    NSString *speciesCoeff = [chunksStCoeff objectAtIndex:0];
                    
                    // Put the speciesReference in and the stcoeff -
                    [tmpBuffer appendFormat:@"<speciesReference species=\"%@\" stoichiometry=\"%@\" constant=\"false\"/>\n",speciesWithCoeff,speciesCoeff];
                }
            }
            else {
                // Ok, so if I get here I have only 1's at the stcoeff -
                [tmpBuffer appendString:@"<speciesReference stoichiometry=\"1\" constant=\"false\"/>\n"];
            }
        }];
        
        // add close product line -
        [tmpBuffer appendString:@"</listOfProducts>\n"];
        
        // add the end tag -
        [tmpBuffer appendFormat:@"</reaction>\n"];
    }];
    
    return tmpBuffer;
}

-(NSMutableString *)formulateSpeciesBlock:(NSMutableArray *)array
{
    __block NSMutableString *tmpBuffer = [NSMutableString string];
    
    //<species id="P_L1_C" name="P_L1_C" compartment="ThreeGeneLogical" initialConcentration="0" hasOnlySubstanceUnits="false" boundaryCondition="false" constant="false"/>
    
    // Get the name -
    NSString *tmpCompartment = @"TEST";
    
    // Get the species array -
    NSMutableArray *tmpSpeciesArray = [self estimateModelSpeciesFromFlatFile:array];
    [tmpSpeciesArray enumerateObjectsUsingBlock:^(NSString *tmpSpecies,NSUInteger index,BOOL *stop){
        
        NSString *tmpRow = [NSString stringWithFormat:@"<species id=\"%@\" name=\"%@\" compartment=\"%@\" initialConcentration=\"0\" hasOnlySubstanceUnits=\"false\" boundaryCondition=\"false\" constant=\"false\"/>\n",tmpSpecies,tmpSpecies,tmpCompartment];
        
        // Add row to buffer -
        [tmpBuffer appendString:tmpRow];
    }];
    
    return tmpBuffer;
}

-(NSMutableArray *)estimateModelSpeciesFromFlatFile:(NSMutableArray *)array
{
    // Initialize -
    __block NSMutableArray *tmpSpeciesArray = [NSMutableArray array];
    
    // parse the record array
    [array enumerateObjectsUsingBlock:^(NSArray *rowArray,NSUInteger index,BOOL *stop){
        
        // Ok, Get the reactant and product string -
        NSString *tmpReactants = [rowArray objectAtIndex:REACTANTS];
        NSString *tmpProducts = [rowArray objectAtIndex:PRODUCTS];
        NSString *tmpSpeciesRaw = [NSString stringWithFormat:@"%@+%@",tmpReactants,tmpProducts];
        NSArray *chunks = [tmpSpeciesRaw componentsSeparatedByString:@"+"];
        
        // Process the chunks array -
        [chunks enumerateObjectsUsingBlock:^(NSString *species,NSUInteger species_index,BOOL *species_stop){
            
            // Process all species *except* the empty set
            if ([species isNotEqualTo:@"[]"])
            {
                // Ok, so we need to check for stcoeff -
                NSRange range = [species rangeOfString:@"*" options:NSCaseInsensitiveSearch];
                if(range.location == NSNotFound)
                {
                    // add this to the species array -
                    if ([tmpSpeciesArray containsObject:species]==NO)
                    {
                        [tmpSpeciesArray addObject:species];
                    }
                }
                else {
                    
                    // Ok, so we have a stcoeff - cut around it
                    NSArray *chunks = [species componentsSeparatedByString:@"*"];
                    
                    // The last object will be the species symbol -
                    NSString *lastObject = [chunks lastObject];
                    if ([tmpSpeciesArray containsObject:lastObject]==NO)
                    {
                        [tmpSpeciesArray addObject:lastObject];
                    }
                }
                
            }
        }];
    }];
    
    // return -
    return tmpSpeciesArray;
}


@end
