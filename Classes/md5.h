//
//  md5.h
//  Eden
//
//  Created by Ari Ronen on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include <CoreFoundation/CoreFoundation.h>
#define FileHashDefaultChunkSizeForReadingData 4096
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath, 
                                      size_t chunkSizeForReadingData);