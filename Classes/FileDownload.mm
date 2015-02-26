//
//  DownloadManager.m
//  Eden
//
//  Created by Ari Ronen on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileDownload.h"

@interface FileDownload (Private)

- (void)download;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data;

//- (NSData *)gzipDeflate: (NSData *)data;
- (void)downloadSucceeded: (BOOL)success;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

@end

@implementation FileDownload
@synthesize result;
-(id)init{
    result=NULL;
    return self;
}
+ (NSData*)downloadFile:(NSString*)file_name{
    NSURL* url = [[NSURL alloc] initWithString:file_name];
    NSData *theData = [[NSData alloc] initWithContentsOfURL:url];
    [url release];
    return theData;
    
   
    
}
-(void)cancel{
    if(connection){
        NSLog(@"connection cancelled");
        [connection cancel];
        [connection release];
    }
    if(fileStream){
        [fileStream close];
        fileStream=NULL;
    }
}
- (void)download{
    downloadDidSucceed=FALSE;
    if(filePath!=NULL){
    fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    if(fileStream == nil)[self downloadSucceeded:NO];
    
    [fileStream retain];
    [fileStream open];
    }else{
        fileStream = [NSOutputStream outputStreamToMemory];
        if(fileStream == nil)[self downloadSucceeded:NO];
        
        [fileStream retain];
        [fileStream open];
       // fileStream=NULL;
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:serverURL];
    if(request == nil)[self downloadSucceeded:NO];
    connection =
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection==nil)[self downloadSucceeded:NO];
    
}
- (id)initWithURL: (NSURL *)aServerURL   // IN
         filePath: (NSString *)aFilePath // IN
         delegate: (id)aDelegate         // IN
     doneSelector: (SEL)aDoneSelector    // IN
    errorSelector: (SEL)anErrorSelector  // IN
progressSelector: (SEL)aProgressSelector
{
    if ((self = [super init])) {
       
		
        serverURL = [aServerURL retain];
        if(aFilePath==NULL){filePath=NULL;
            if(result){[result release];
                result=NULL;
            }
        }
        filePath = [aFilePath retain];
        delegate = [aDelegate retain];
        doneSelector = aDoneSelector;
        errorSelector = anErrorSelector;
		progressSelector= aProgressSelector;
        [self download];
    }
    return self;
}


- (void)dealloc
{
    [serverURL release];
    serverURL = nil;
    if(filePath)
    [filePath release];
    if(result)
        [result release];
    result=NULL;
    filePath = nil;
    [delegate release];
    delegate = nil;
    doneSelector = NULL;
    errorSelector = NULL;
	
    [super dealloc];
}
- (void)downloadSucceeded: (BOOL)success // IN
{
    [delegate performSelector:success ? doneSelector : errorSelector
                   withObject:self];
}

- (void)connection:(NSURLConnection *)con // IN
  didFailWithError:(NSError *)error              // IN
{
    NSLog(@"%s: self:0x%p, connection error:%s\n",
		  __func__, self, [[error description] UTF8String]);
    [con release];
    if(fileStream){
    [fileStream close];
     [fileStream release];
    }
    [self downloadSucceeded:NO];
}



static int downloadSize=0;
static int dataSize=0;
-(void)       connection:(NSURLConnection *)connection // IN
      didReceiveResponse:(NSURLResponse *)response     // IN
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
    dataSize=0;
    downloadSize = (int)[response expectedContentLength];
     NSLog(@"%d,%d  %f%%",downloadSize,dataSize,((float)dataSize/downloadSize));
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)con // IN
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
    result=(NSData*)[fileStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    [result retain];
    [connection release];
    if(fileStream){
    [fileStream close];
    [fileStream release];
    }
    [self downloadSucceeded:downloadDidSucceed];
}

- (void)connection:(NSURLConnection *)con // IN
    didReceiveData:(NSData *)data                // IN
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
        
    dataLength = [data length];
    dataBytes  = (const uint8_t * )[data bytes];
    
    bytesWrittenSoFar = 0;
    if(fileStream!=NULL){
    do {
        NSLog(@"%d",(int)bytesWrittenSoFar);
        bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
             [self downloadSucceeded:NO];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
    }
	
    dataSize+=[data length];
    if(dataSize==downloadSize){
        downloadDidSucceed=TRUE;
    }
    [delegate performSelector:progressSelector withObject:(id)(long)(100*dataSize/downloadSize)];
 
	
    
}
@end
