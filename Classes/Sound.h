//
//  Sound.h
//  prototype
//
//  Created by Ari Ronen on 10/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioFileStream.h>
#define MAX_SOURCES 10

@interface Sound : NSObject {
	ALCcontext* mContext;
	ALCdevice* mDevice;
	NSMutableArray* bufferStorageArray;
	NSMutableArray* sources;
	NSMutableDictionary* soundDictionary;
	
}
-(void)initOpenAL;
-(void)loadAudioFile:(NSString*)path;
- (void)stopSound:(int)soundKey;
-(void)preloadSources;
- (int)playSound:(NSString*)soundKey 
			gain:(ALfloat)gain pitch:(ALfloat)pitch loops:(BOOL)loops;

-(AudioFileID)openAudioFile:(NSString*)filePath;
-(UInt32)audioFileSize:(AudioFileID)fileDescriptor;
-(NSUInteger)_nextAvailableSource;
-(void)cleanUpOpenAL;
@end
