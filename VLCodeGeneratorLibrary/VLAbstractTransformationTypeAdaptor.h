//
//  VLAbstractTransformationTypeAdaptor.h
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 11/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLAbstractTransformationTypeAdaptor : NSObject
{
    
}

// properties -
@property (strong) NSString *myTransformationName;

// lifecycle
-(void)cleanMyMemory;

// general methods for all model types -
-(NSString *)generateModelDataStructureBufferWithOptions:(NSDictionary *)options;

// kinetics -
-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelOperationKineticsHeaderBufferWithOptions:(NSDictionary *)options;

// forcing -
-(NSString *)generateModelForcingHeaderBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelForcingBufferWithOptions:(NSDictionary *)options;

// massbalances -
-(NSString *)generateModelMassBalancesImplBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelMassBalancesHeaderBufferWithOptions:(NSDictionary *)options;

// driver -
-(NSString *)generateModelDriverImplBufferWithOptions:(NSDictionary *)options;

// make -
-(NSString *)generateModelMakeFileBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelSolveModelScriptBufferWithOptions:(NSDictionary *)options;

// debug methods -
-(NSString *)generateModelDebugBufferWithOptions:(NSDictionary *)options;

// file conversion methods
-(NSString *)generateSBMLFileFromVFFWithOptions:(NSDictionary *)options;

// logic method
-(NSString *)processTransformationSelector:(SEL)selector withOptions:(NSDictionary *)options;


@end
