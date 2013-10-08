//
//  VLCoreUtilitiesLib.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCoreUtilitiesLib.h"

@implementation VLCoreUtilitiesLib


#pragma mark - load/parse file methods
+(NSXMLDocument *)createXMLDocumentFromSNLFile:(NSURL *)fileURL
{
    // Make sure we have a URL -
    if (fileURL==nil)
    {
        NSLog(@"ERROR: Blueprint file URL is nil.");
        return nil;
    }
    
    // Create a tmp buffer -
    NSMutableString *xml_buffer = [NSMutableString string];
    [xml_buffer appendString:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n"];
    [xml_buffer appendString:@"<Model>\n"];
    
    // Create error instance -
	NSError *error = nil;
    
    // Load the file -
    NSString *fileString = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
    
    // Ok, we need to walk through this file, and put it an array -
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
    while (![scanner isAtEnd])
    {
        // Ok, let'd grab a row -
        NSString *record_string;
        [scanner scanUpToString:@"\n" intoString:&record_string];
        
        // Skip comments -
        NSRange range = [record_string rangeOfString:@"//" options:NSCaseInsensitiveSearch];
        if(range.location == NSNotFound)
        {
            // Cut around the spaces -
            NSArray *fragments_array = [record_string componentsSeparatedByString:@" "];
            NSUInteger number_of_fragments = [fragments_array count];
            if (number_of_fragments == 3)
            {
                // get data -
                NSString *reactants_string = [fragments_array objectAtIndex:0];
                NSString *action_string = [fragments_array objectAtIndex:1];
                NSString *products_string = [fragments_array objectAtIndex:2];
                NSString *id_string = [VLCoreUtilitiesLib generateUUIDString];
                
                
                // encode into xml -
                [xml_buffer appendFormat:@"\t<interaction id=\"%@\" source_string=\"%@\" ",id_string,reactants_string];
                [xml_buffer appendFormat:@"target_string=\"%@\" ",products_string];
                [xml_buffer appendFormat:@"rule_string=\"%@\" ",@""];
                [xml_buffer appendFormat:@"direction_string=\"%@\" ",@""];
                [xml_buffer appendFormat:@"interaction_type=\"%@\" ",@"0"];
                [xml_buffer appendFormat:@"record_string=\"%@\" ",record_string];
                [xml_buffer appendFormat:@"action_string=\"%@\"/>\n",action_string];
            }
            else if (number_of_fragments == 7)
            {
                // get data -
                NSString *reactants_string = [fragments_array objectAtIndex:0];
                NSString *action_string = [fragments_array objectAtIndex:1];
                NSString *products_string = [fragments_array objectAtIndex:2];
                NSString *rule_string = [fragments_array objectAtIndex:5];
                NSString *direction_string = [fragments_array objectAtIndex:6];
                NSString *id_string = [VLCoreUtilitiesLib generateUUIDString];
                
                // encode into xml -
                [xml_buffer appendFormat:@"\t<interaction id=\"%@\" source_string=\"%@\" ",id_string,reactants_string];
                [xml_buffer appendFormat:@"target_string=\"%@\" ",products_string];
                [xml_buffer appendFormat:@"rule_string=\"%@\" ",rule_string];
                [xml_buffer appendFormat:@"direction_string=\"%@\" ",direction_string];
                [xml_buffer appendFormat:@"interaction_type=\"%@\" ",@"1"];
                [xml_buffer appendFormat:@"record_string=\"%@\" ",record_string];
                [xml_buffer appendFormat:@"action_string=\"%@\"/>\n",action_string];
            }
            else
            {
                // ok, so if we don't have either 3 -or- 7 then we have a
                // strange sentence format ...
                
                // notify the user -
                // ...
            }
        }
    }
    
    // close -
    [xml_buffer appendString:@"</Model>\n"];
    
    // create document from buffer -
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:xml_buffer options:NSXMLDocumentTidyXML error:&error];
    
    // Check to make sure all is ok -
    if (error==nil)
    {
        // return -
        return document;
    }
    else
    {
        NSLog(@"ERROR in createXMLDocumentFromSNLFile: = %@",[error description]);
        return nil;
    }
}

+(NSString *)generateUUIDString
{
    // create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the snstring representation of the UUID
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    
    // return (autoreleased) -
    return uuidString;
}


+(NSXMLDocument *)createXMLDocumentFromFile:(NSURL *)fileURL
{
    // Make sure we have a URL -
    if (fileURL==nil)
    {
        NSLog(@"ERROR: Blueprint file URL is nil.");
        return nil;
    }
    
    // Create error instance -
	NSError *errObject = nil;
	
    // Set the NSXMLDocument reference on the tree model
	NSXMLDocument *tmpDocument = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL
                                                                      options:NSXMLNodeOptionsNone error:&errObject];
    
    // Check to make sure all is ok -
    if (errObject==nil)
    {
        // return -
        return tmpDocument;
    }
    else
    {
        NSLog(@"ERROR in createXMLDocumentFromFile: = %@",[errObject description]);
        return nil;
    }
}

+(NSMutableArray *)loadGenericFlatFile:(NSString *)filePath
                 withRecordDeliminator:(NSString *)recordDeliminator
                  withFieldDeliminator:(NSString *)fieldDeliminator
{
    // Method attributes -
    NSError *error = nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // Load the file -
    NSURL *tmpFileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    
    // Load the file -
    NSString *fileString = [NSString stringWithContentsOfURL:tmpFileURL encoding:NSUTF8StringEncoding error:&error];
    
    // Ok, we need to walk through this file, and put it an array -
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
    while (![scanner isAtEnd])
    {
        // Ok, let'd grab a row -
        NSString *tmpString;
        [scanner scanUpToString:recordDeliminator intoString:&tmpString];
        
        // Skip comments -
        NSRange range = [tmpString rangeOfString:@"//" options:NSCaseInsensitiveSearch];
        if(range.location == NSNotFound)
        {
            // Ok, so let's cut around the tabs -
            NSArray *chunks = [tmpString componentsSeparatedByString:fieldDeliminator];
            
            // Load the row -
            [tmpArray addObject:chunks];
        }
    }
    
    // return -
    return [NSArray arrayWithArray:tmpArray];
}


+(void)writeBuffer:(NSString *)buffer
             toURL:(NSURL *)fileURL
{
    // if no buffer -or- no url then exit
    if (buffer == nil || fileURL == nil)
    {
        return;
    }
    
    
    // write -
    NSError *error = nil;
    
    // ok, so we need to check to see if the directory exists -
    // Get the directory from the URL -
    NSURL *output_directory = [fileURL URLByDeletingLastPathComponent];
    NSFileManager *filesystem_manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([filesystem_manager fileExistsAtPath:[output_directory path] isDirectory:&isDirectory] == NO)
    {
        // build new directory -
        [filesystem_manager createDirectoryAtURL:output_directory withIntermediateDirectories:YES
                                      attributes:nil error:nil];
    }
    
    
    [buffer writeToFile:[fileURL path]
             atomically:YES
               encoding:NSUTF8StringEncoding
                  error:&error];
    
    if (error!=nil)
    {
        NSLog(@"ERROR: There is an issue writing the simulations results to disk - %@",[error description]);
    }
}


#pragma mark - xpath methods
+(NSArray *)executeXPathQuery:(NSString *)xpath withXMLTree:(NSXMLDocument *)document
{
    // Check for null args
    if (xpath==nil || document==nil)
    {
        NSLog(@"ERROR: Either the xpath string or the document was nil");
        return nil;
    }
    
    // Execute -
    NSError *error = nil;
    NSArray *tmpArray = [document nodesForXPath:xpath error:&error];
    
    // Check -
    if (error!=nil)
    {
        NSLog(@"ERROR - xpath = %@ did not complete",[error description]);
    }
    else
    {
        return tmpArray;
    }
    
    // return -
    return nil;
}

+(NSString *)lookupInputPathForTransformationWithName:(NSString *)transformName
                                               inTree:(NSXMLDocument *)blueprintTree
{
    // Formulate the xpath -
    NSString *xpath = @".//listOfGlobalTransformationProperties/property[@key='INPUT_FILE_PATH']/@value";
    NSArray *resultArray = [VLCoreUtilitiesLib executeXPathQuery:xpath withXMLTree:blueprintTree];
    if (resultArray!=nil)
    {
        NSXMLElement *pathElment = [resultArray lastObject];
        return [pathElment stringValue];
    }
    else
    {
        return nil;
    }
}


+(NSString *)lookupOutputPathForTransformationWithName:(NSString *)transformName
                                                inTree:(NSXMLDocument *)blueprintTree
{
    // Formulate the xpath -
    NSString *xpath = @".//listOfGlobalTransformationProperties/property[@key='OUTPUT_FILE_PATH']/@value";
    NSArray *resultArray = [VLCoreUtilitiesLib executeXPathQuery:xpath withXMLTree:blueprintTree];
    if (resultArray!=nil)
    {
        NSXMLElement *pathElment = [resultArray lastObject];
        return [pathElment stringValue];
    }
    else
    {
        return nil;
    }
}

+(NSString *)lookupOutputFileNameForTransformationWithName:(NSString *)transformName inTree:(NSXMLDocument *)blueprintTree
{
    // Formulate the xpath -
    NSString *xpath = [NSString stringWithFormat:@".//Transformation[@name='%@']/property[@key='OUTPUT_FILE_NAME']/@value",transformName];
    NSArray *resultArray = [VLCoreUtilitiesLib executeXPathQuery:xpath withXMLTree:blueprintTree];
    if (resultArray!=nil)
    {
        NSXMLElement *pathElment = [resultArray lastObject];
        return [pathElment stringValue];
    }
    else
    {
        return nil;
    }
}

#pragma mark - numerics methods
+(CGFloat)generateSampleFromNormalDistributionWithMean:(CGFloat)mean
                                  andStandardDeviation:(CGFloat)standard_deviation
{
    float perturbation = ((float)arc4random())/((float)RAND_MAX);
    CGFloat random_value = mean + perturbation*standard_deviation;
    return random_value;
}

@end
