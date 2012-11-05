//
//  ShareUtil.m
//  prototype
//
//  Created by Ari Ronen on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShareUtil.h"
#include <zlib.h>
#import "FileUpload.h"
#import "World.h"
#import "FileDownload.h"

#ifdef DEBUG
/*static NSString* UPLOAD_URL=@"http://184.106.168.6/upload.php";
static NSString* LIST_URL=@"http://184.106.168.6/list.php";
static NSString* MAPS_URL=@"http://184.106.168.6/eden_maps/";
static NSString* UPLOAD_URL=@"http://66.228.42.169/upload2.php";
static NSString* LIST_URL=@"http://66.228.42.169/list2.php";
static NSString* MAPS_URL=@"http://files.edengame.net/";
static NSString* UPLOAD_URL=@"http://www.edengame.net/upload.php";
static NSString* LIST_URL=@"http://www.edengame.net/list.php";
static NSString* MAPS_URL=@"http://www.edengame.net/eden_maps/";
static NSString* UPLOAD_URL=@"http://localhost:8080/upload2.php";
static NSString* LIST_URL=@"http://localhost:8080/list2.php";
static NSString* MAPS_URL=@"http://files.edengame.net/";*/

static NSString* UPLOAD_URL=@"http://edengame.net/upload2.php";
static NSString* LIST_URL=@"http://edengame.net/list2.php";
static NSString* MAPS_URL=@"http://files.edengame.net/";
static NSString* POPULAR_URL=@"http://edengame.net/popularlist2.txt";
#else
static NSString* UPLOAD_URL=@"http://edengame.net/upload2.php";
static NSString* LIST_URL=@"http://edengame.net/list2.php";
static NSString* MAPS_URL=@"http://files.edengame.net/";
static NSString* POPULAR_URL=@"http://files.edengame.net/popularlist.txt";
#endif

@implementation ShareUtil
@synthesize listresult;
-(id)init{
    dlmanager=NULL;
    listresult=NULL;
	return self;	
}

-(void)loadSharedPreview:(NSString*)file_name{
	
	
    NSString* fullString=[NSString stringWithFormat:@"%@%@.png",MAPS_URL,file_name];	
    NSString* realfile_name=[NSString stringWithFormat:@"%@/temp",[World getWorld].fm.documents];

    NSURL* url = [[NSURL alloc] initWithString:fullString];
    if(dlmanager){
        [dlmanager cancel];
        [dlmanager release];
        dlmanager=NULL;
    }
	dlmanager=[[FileDownload alloc] initWithURL:url
                                       filePath:realfile_name
                                       delegate:self 
                                   doneSelector:@selector(downloadSuccess:)
                                  errorSelector:@selector(downloadError:)
                               progressSelector:@selector(downloadProgress:)                                       ];	
    [url release];
	[[World getWorld].menu.sbar clear];	
    isPreview=TRUE;
    isWorldlist=FALSE;
}

-(void)loadShared:(NSString*)file_name{
	
	NSString* fullString=[NSString stringWithFormat:@"%@%@",MAPS_URL,file_name];	
  
	
	
    
    //NSData* theData = [FileDownload downloadFile:fullString];
    
	//NSData* newData=[self gzipInflate:theData];
	NSString* realfile_name=[NSString stringWithFormat:@"%@/%@",[World getWorld].fm.documents,file_name];
   
	//[newData writeToFile:realfile_name atomically:FALSE];
	
	//[theData release];
    NSURL* url = [[NSURL alloc] initWithString:fullString];
    if(dlmanager){
        [dlmanager cancel];
        [dlmanager release];
        dlmanager=NULL;
    }
	dlmanager=[[FileDownload alloc] initWithURL:url
                                       filePath:realfile_name
                                       delegate:self 
                                   doneSelector:@selector(downloadSuccess:)
                                  errorSelector:@selector(downloadError:)
                               progressSelector:@selector(downloadProgress:)                                       ];	
    
    
    
    [url release];
	
	[[World getWorld].menu.sbar clear];
	isPreview=FALSE;
    isWorldlist=FALSE;
	
}
-(void)canceldl{
    
    if(dlmanager){
        [dlmanager cancel];
        [dlmanager release];
        dlmanager=NULL;
        [[World getWorld].menu.shared_list.sbar setStatus:@"Download cancelled":1];
    }
}
- (void)shareWorld:(NSString*)file_name{
	NSLog(@"share world %@",file_name);
	
	NSLog(@"attempting upload");
	NSURL* serverUrl=[[NSURL alloc] initWithString:UPLOAD_URL];
	FileUpload* fu=[[FileUpload alloc] initWithURL:serverUrl 
										  filePath:file_name 
                                           imgPath:[NSString stringWithFormat:@"%@.png",file_name]
										  delegate:self 
									  doneSelector:@selector(uploadSuccess:)
									 errorSelector:@selector(uploadError:)
                                  progressSelector:@selector(uploadProgress:)];	

	[fu release];
	[serverUrl release];
}
- (void)getSharedWorldList{
    [[World getWorld].menu.shared_list.sbar setStatus:@"Loading.." :9999];
	NSLog(@"getting shared world list");    
    NSString* nsurl;
    if([World getWorld].menu.shared_list.cur_sort==1){
        nsurl=POPULAR_URL;
    }else
	nsurl=[NSString stringWithFormat:@"%@?start=%d&sort=%d",LIST_URL,0,[World getWorld].menu.shared_list.cur_sort ] ;
    
    
    NSURL* url = [[NSURL alloc] initWithString:nsurl];
    if(dlmanager){
        [dlmanager cancel];
        [dlmanager release];
        dlmanager=NULL;
    }
	dlmanager=[[FileDownload alloc] initWithURL:url
                                       filePath:NULL
                                       delegate:self 
                                   doneSelector:@selector(downloadSuccess:)
                                  errorSelector:@selector(downloadError:)
                               progressSelector:@selector(downloadProgress:)                                       ];	
    [url release];
	[[World getWorld].menu.sbar clear];	
    isWorldlist=TRUE;
    isPreview=FALSE;
    
    
	
    /*NSData* theData = [FileDownload downloadFile:nsurl];
	NSString *worldList = [[[NSString alloc] initWithData:theData
                                             encoding:NSUTF8StringEncoding]
                       autorelease];
	[worldList retain];
	NSLog(@"world list1:%@",worldList);
   
	[theData release];*/
	
	return;
	
}
- (NSString*)searchSharedWorlds:(NSString*)query{
    NSLog(@"searching shared world list");
    NSString* urlString = [query stringByAddingPercentEscapesUsingEncoding:
                           NSASCIIStringEncoding];
   
	NSString* nsurl=[NSString stringWithFormat:@"%@?search=%@",LIST_URL,urlString];
	     
    NSData* theData = [FileDownload downloadFile:nsurl];
	NSString *worldList = [[[NSString alloc] initWithData:theData
                                                 encoding:NSUTF8StringEncoding]
                           autorelease];
	[worldList retain];
	NSLog(@"world list:%@",worldList);
	[theData release];
	
	return worldList;
    
}


-(void)uploadSuccess:(id)obj{
	[World getWorld].menu.is_sharing=FALSE;
	[[World getWorld].menu.sbar setStatus:@"Successfully shared world!":2];
	NSLog(@"upload success: %@",obj);
	
}
-(void)uploadError:(id)obj{
	[World getWorld].menu.is_sharing=FALSE;
	[[World getWorld].menu.sbar setStatus:@"Connection error sharing world":3];
	NSLog(@"upload error: %@",obj);
}
-(void)uploadProgress:(id)ipct{
    int pct=(int)ipct;
    if(pct==100)
        [[World getWorld].menu.sbar setStatus:@"Upload Complete, Processing...":10];
    else
      [[World getWorld].menu.sbar setStatus:[NSString stringWithFormat:@"Uploading world %d%%",pct] :5];
}
-(void)downloadProgress:(id)ipct{
    int pct=(int)ipct;
    if(isWorldlist){
         [[World getWorld].menu.shared_list.sbar setStatus:[NSString stringWithFormat:@"Getting List... %d%%",pct] :5];
         [[World getWorld].menu.sbar setStatus:[NSString stringWithFormat:@"Getting List... %d%%",pct] :5];
    }else
    if(isPreview){
      
        [[World getWorld].menu.shared_list.sbar setStatus:[NSString stringWithFormat:@"Fetching Preview %d%%",pct] :5];
    }else{
       
      
            [[World getWorld].menu.shared_list.sbar setStatus:[NSString stringWithFormat:@"Downloading World... %d%%",pct] :5];
        
    }
}
-(void)downloadSuccess:(id)obj{
	//
    [[World getWorld].menu.sbar setStatus:@"Successfully downloaded world":3];
    if(isWorldlist){
        [World getWorld].menu.shared_list.finished_list_dl=true;
        if(listresult){
            [listresult release];
            listresult=NULL;
        }
        listresult=[[NSString alloc] initWithData:dlmanager.result encoding:NSUTF8StringEncoding];
        [listresult retain];
    }else
    if(!isPreview)
	[World getWorld].menu.shared_list.finished_dl=true;
    else 
    [World getWorld].menu.shared_list.finished_preview_dl=true;
	NSLog(@"dl success: %@",obj);
    [dlmanager release];
    dlmanager=NULL;
    
	
}
-(void)downloadError:(id)obj{
	
    if(isWorldlist){
        [[World getWorld].menu.shared_list.sbar setStatus:@"Connection error getting shared world list.":4];
        [[World getWorld].menu.sbar setStatus:@"Connection error getting shared world list.":4];
    }else{
        [[World getWorld].menu.sbar setStatus:@"Error downloading world!":4];
        [[World getWorld].menu.shared_list.sbar setStatus:@"Error downloading world!":4];

    }
	NSLog(@"dl error: %@",obj);
    [dlmanager release];
    dlmanager=NULL;
     
}



- (NSData *)gzipInflate:(NSData*) data
{
	if ([data length] == 0) return data;
	
	unsigned full_length = [data length];
	unsigned half_length = [data length] / 2;
	
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	strm.next_in = (Bytef *)[data bytes];
	strm.avail_in = [data length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd (&strm) != Z_OK) return nil;
	
	// Set real length.
	if (done)
	{
		[decompressed setLength: strm.total_out];
		NSData* ret=[NSData dataWithData: decompressed];
		
		return ret;
	}
	else return nil;
}

@end