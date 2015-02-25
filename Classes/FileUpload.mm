//
//  FileUpload.m
//  prototype
//
//  Created by Ari Ronen on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileUpload.h"

#import "zlib.h"
#import "zpipe.h"

#import "World.h"

static NSString * const BOUNDRY = @"0xasdfasdfasdfasdfasdf";
static NSString * const FORM_FLE_INPUT = @"uploaded";
static NSString * const FORM_FLE_INPUT2 = @"uploaded2";

#define ASSERT(x) NSAssert(x, @"")

@interface FileUpload (Private)

- (void)upload;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data
                               image: (NSData *)imgData;

- (NSData *)gzipDeflate: (NSData *)data;
- (void)uploadSucceeded: (BOOL)success;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

@end

@implementation FileUpload



- (id)initWithURL: (NSURL *)aServerURL   // IN
         filePath: (NSString *)aFilePath // IN
          imgPath: (NSString *)aimgPath
         delegate: (id)aDelegate         // IN
     doneSelector: (SEL)aDoneSelector    // IN
    errorSelector: (SEL)anErrorSelector  // IN
progressSelector: (SEL)aProgressSelector
{
    if ((self = [super init])) {
        ASSERT(aServerURL);
        ASSERT(aFilePath);
        ASSERT(aDelegate);
        ASSERT(aDoneSelector);
        ASSERT(anErrorSelector);
		
        serverURL = [aServerURL retain];
        filePath = [aFilePath retain];
        delegate = [aDelegate retain];
        imgPath=[aimgPath retain];
        doneSelector = aDoneSelector;
        errorSelector = anErrorSelector;
		progressSelector= aProgressSelector;
        uploadDidSucceed=FALSE;
        [self upload];
    }
    return self;
}


- (void)dealloc
{
    [serverURL release];
    serverURL = nil;
    [filePath release];
    filePath = nil;
    [imgPath release];
    imgPath=nil;
    [delegate release];
    delegate = nil;
    doneSelector = NULL;
    errorSelector = NULL;
	
    [super dealloc];
}

- (NSString *)filePath
{
    return filePath;
}


@end // Uploader


@implementation FileUpload (Private)



- (void)upload
{
    
    const char* fname=[filePath cStringUsingEncoding:NSUTF8StringEncoding];
    NSString* temp_name=[NSString stringWithFormat:@"%@/temp",[World getWorld].fm.documents];
    const char* tname=[temp_name cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE* fsource = fopen(fname, "rb");
    if(!fsource){
        NSLog(@"cant open %s",fname);
        [self uploadSucceeded:NO];
        return;
    }
    
    
    FILE* fdest = fopen(tname, "wb");
    if(!fdest)
    {
        NSLog(@"cant open temp");
        [self uploadSucceeded:NO];
        return;
    }
    NSLog(@"source: %s\ndest: %s\n",fname,tname);
    int ret=compressFile(fsource, fdest,Z_DEFAULT_COMPRESSION);
    
    
    fclose(fsource);
    fclose(fdest);
    if (ret != Z_OK){
        zerr(ret);
        [self uploadSucceeded:NO];
        remove(tname);
        return;
    }
    
    NSData *compressedData = [NSData dataWithContentsOfFile:temp_name];
    if (!compressedData || [compressedData length] == 0) {
        [self uploadSucceeded:NO];
        return;
    }
    // NSString* img_temp_name=[NSString stringWithFormat:@"%@/temp",[World getWorld].fm.documents];
    NSData* imgData = [NSData dataWithContentsOfFile:imgPath];
    if (!imgData || [imgData length] == 0) {
        [self uploadSucceeded:NO];
        return;
    }
    NSURLRequest *urlRequest = [self postRequestWithURL:serverURL
                                                boundry:BOUNDRY
                                                   data:compressedData
                                                  image:imgData];
    if (!urlRequest) {
        [self uploadSucceeded:NO];
        return;
    }
    remove(tname);
    NSURLConnection * connection =
    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (!connection) {
        [self uploadSucceeded:NO];
    }
    
    // Now wait for the URL connection to call us back.
}



- (NSURLRequest *)postRequestWithURL: (NSURL *)url        // IN
                             boundry: (NSString *)boundry // IN
                                data: (NSData *)data      // IN
                               image: (NSData *)imgData
{
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:
     [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry]
      forHTTPHeaderField:@"Content-Type"];
	
    NSMutableData *postData =
    [NSMutableData dataWithCapacity:[data length]+[imgData length] + 512];
    [postData appendData:
     [[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:
     [[NSString stringWithFormat:
       @"Content-Disposition: form-data; name=\"%@\"; filename=\"file.bin\"\r\n\r\n", FORM_FLE_INPUT]
      dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:data];
    //
    [postData appendData:
    [[NSString stringWithFormat:@"\r\n--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:
     [[NSString stringWithFormat:
       @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.bin\"\r\n\r\n", FORM_FLE_INPUT2]
      dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imgData];

    NSLog(@"img length: %d",[imgData length]);
    
    //
    [postData appendData:
     [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
    /*
     Content-Type: multipart/form-data; boundary=AaB03x
     
     --AaB03x
     Content-Disposition: form-data; name="submit-name"
     
     Larry
     --AaB03x
     Content-Disposition: form-data; name="files"
     Content-Type: multipart/mixed; boundary=BbC04y
     
     --BbC04y
     Content-Disposition: file; filename="file1.txt"
     Content-Type: text/plain
     
     ... contents of file1.txt ...
     --BbC04y
     Content-Disposition: file; filename="file2.gif"
     Content-Type: image/gif
     Content-Transfer-Encoding: binary
     
     ...contents of file2.gif...
     --BbC04y--
     --AaB03x--
     */
	
    [urlRequest setHTTPBody:postData];
    return urlRequest;
}


//unused
- (NSData *)gzipDeflate:(NSData*) data
{
	if ([data length] == 0) return data;
	
	z_stream strm;
	
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[data bytes];
	strm.avail_in = [data length];
	
	// Compresssion Levels:
	//   Z_NO_COMPRESSION
	//   Z_BEST_SPEED
	//   Z_BEST_COMPRESSION
	//   Z_DEFAULT_COMPRESSION
	
	if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	
	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
	
	do {
		
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy: 16384];
		
		strm.next_out = ((Bytef*)[compressed mutableBytes]) + strm.total_out;
		strm.avail_out = [compressed length] - strm.total_out;
		
		deflate(&strm, Z_FINISH);  
		
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	
	[compressed setLength: strm.total_out];
	return [NSData dataWithData:compressed];
}



- (void)uploadSucceeded: (BOOL)success // IN
{
    [delegate performSelector:success ? doneSelector : errorSelector
                   withObject:self];
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection // IN
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
    [connection release];
    [self uploadSucceeded:uploadDidSucceed];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    [delegate performSelector:progressSelector withObject:(id)(100*totalBytesWritten /totalBytesExpectedToWrite)];
   // NSLog(@"uploading %f%%",((float)totalBytesWritten /totalBytesExpectedToWrite));
    
}


- (void)connection:(NSURLConnection *)connection // IN
  didFailWithError:(NSError *)error              // IN
{
    NSLog(@"%s: self:0x%p, connection error:%s\n",
		  __func__, self, [[error description] UTF8String]);
    [connection release];
    [self uploadSucceeded:NO];
}


static int downloadSize=0;
static int dataSize=0;
-(void)       connection:(NSURLConnection *)connection // IN
      didReceiveResponse:(NSURLResponse *)response     // IN
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
    dataSize=0;
    downloadSize = [response expectedContentLength];
    
}


- (void)connection:(NSURLConnection *)connection // IN
    didReceiveData:(NSData *)data                // IN
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
	
    NSString *reply = [[[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding]
                       autorelease];
    NSLog(@"%s: data: %s\n", __func__, [reply UTF8String]);
    dataSize+=[data length];
    NSLog(@"%d,%d",downloadSize,dataSize);
	
    if ([reply hasPrefix:@"YES"]) {
        uploadDidSucceed = YES;
    }
    if([reply hasPrefix:@"NOTHX"]){
        uploadDidSucceed=NO;
        
    }
}



@end
