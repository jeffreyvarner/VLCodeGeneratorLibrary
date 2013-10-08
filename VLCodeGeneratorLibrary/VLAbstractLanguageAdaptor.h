//
//  VLAbstractLanguageAdaptor.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLPBPKModelPhysicalParameterCalculator.h"

@interface VLAbstractLanguageAdaptor : NSObject
{
    
}



// general methods for all model types -
-(NSString *)generateModelDataStructureBufferWithOptions:(NSDictionary *)options;

// kinetics -
-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelOperationKineticsHeaderBufferWithOptions:(NSDictionary *)options;

// massbalances -
-(NSString *)generateModelMassBalancesImplBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelMassBalancesHeaderBufferWithOptions:(NSDictionary *)options;

// driver -
-(NSString *)generateModelDriverImplBufferWithOptions:(NSDictionary *)options;

// make -
-(NSString *)generateModelMakeFileBufferWithOptions:(NSDictionary *)options;

// matrix routines -
-(NSString *)generateModelStoichiometricMatrixBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelCirculationMatrixBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelInitialConditonsBufferWithOptions:(NSDictionary *)options;

// general methods
-(NSUInteger)calculateNumberOfStatesInModelTree:(NSXMLDocument *)model_tree;
-(NSUInteger)calculateNumberOfRatesInModelTree:(NSXMLDocument *)model_tree;
-(NSUInteger)calculateNumberOfCompartmentsInModelTree:(NSXMLDocument *)model_tree;
-(NSUInteger)calculateNumberOfSpeciesInModelTree:(NSXMLDocument *)model_tree;

@end
