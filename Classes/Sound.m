//
//  Sound.m
//  prototype
//
//  Created by Ari Ronen on 10/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Sound.h"


@implementation Sound

-(id)init{
	[self initOpenAL];
	sources=[[NSMutableArray alloc] init];
	bufferStorageArray=[[NSMutableArray alloc] init];
	soundDictionary=[[NSMutableDictionary alloc] init];
	[self preloadSources];
	[self loadAudioFile:@"out"];
	[self playSound:@"out" gain:1.0 pitch:1.0 loops:TRUE];
	return self;
}
-(void)dealloc{
	[self cleanUpOpenAL];
	[super dealloc];
}
-(void)loadAudioFile:(NSString*)path{
	// get the full path of the file
	NSString* fileName = [[NSBundle mainBundle] pathForResource:path ofType:@"caf"];
	// first, open the file
	AudioFileID fileID = [self openAudioFile:fileName];
	// find out how big the actual audio data is
	UInt32 fileSize = [self audioFileSize:fileID];
	// this is where the audio data will live for the moment
	unsigned char * outData = malloc(fileSize);
	
	// this where we actually get the bytes from the file and put them
	// into the data buffer
	OSStatus result = noErr;
	result = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);
	AudioFileClose(fileID); //close the file
	
	if (result != 0) NSLog(@"cannot load effect: %@",fileName);
	
	NSUInteger bufferID;
	// grab a buffer ID from openAL
	alGenBuffers(1, &bufferID);
	
	// jam the audio data into the new buffer
	alBufferData(bufferID,AL_FORMAT_STEREO16,outData,fileSize,44100); 
	
	// save the buffer so I can release it later
	[bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
	
	// store this for future use
	[soundDictionary setObject:[NSNumber numberWithUnsignedInt:bufferID] forKey:path];	
	
	// clean up the buffer
	if (outData)
	{
		free(outData);
		outData = NULL;
	}
	
}
// find the audio portion of the file
// return the size in bytes
-(UInt32)audioFileSize:(AudioFileID)fileDescriptor
{
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if(result != 0) NSLog(@"cannot find file size");
	return (UInt32)outDataSize;
}


// open the audio file
// returns a big audio ID struct
-(AudioFileID)openAudioFile:(NSString*)filePath
{
	AudioFileID outAFID;
	// use the NSURl instead of a cfurlref cuz it is easier
	NSURL * afUrl = [NSURL fileURLWithPath:filePath];
	
	// do some platform specific stuff..
#if TARGET_OS_IPHONE
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
#else
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
	if (result != 0) NSLog(@"cannot openf file: %@",filePath);
	return outAFID;
}
// start up openAL
-(void)initOpenAL
{
	// Initialization
	mDevice = alcOpenDevice(NULL); // select the "preferred device"
	if (mDevice) {
		// use the device to make a context
		mContext=alcCreateContext(mDevice,NULL);
		// set my context to the currently active one
		alcMakeContextCurrent(mContext);
	}
}
// note: MAX_SOURCES is how many source you want
// to preload.  should keep it below 32
-(void)preloadSources
{
	// lazy init of my data structure
	if (sources == nil) sources = [[NSMutableArray alloc] init];
	
	// we want to allocate all the sources we will need up front
	NSUInteger sourceCount = MAX_SOURCES;
	NSInteger sourceIndex;
	NSUInteger sourceID;
	// build a bunch of sources and load them into our array.
	for (sourceIndex = 0; sourceIndex < sourceCount; sourceIndex++) {
		alGenSources(1, &sourceID);
		[sources addObject:[NSNumber numberWithUnsignedInt:sourceID]];
	}
}

// the main method: grab the sound ID from the library
// and start the source playing
- (int)playSound:(NSString*)soundKey gain:(ALfloat)gain pitch:(ALfloat)pitch loops:(BOOL)loops
{
	ALenum err = alGetError(); // clear error code 
	
	// first, find the buffer we want to play
	NSNumber * numVal = [soundDictionary objectForKey:soundKey];
	if (numVal == nil) return 0;
	NSUInteger bufferID = [numVal unsignedIntValue];	
	
	// now find an available source
	NSUInteger sourceID = [self _nextAvailableSource];	
	
	// make sure it is clean by resetting the source buffer to 0
	alSourcei(sourceID, AL_BUFFER, 0);
	// attach the buffer to the source
	alSourcei(sourceID, AL_BUFFER, bufferID); 
	
	// set the pitch and gain of the source
	alSourcef(sourceID, AL_PITCH, pitch);
	alSourcef(sourceID, AL_GAIN, gain);
	
	// set the looping value
	if (loops) {
		alSourcei(sourceID, AL_LOOPING, AL_TRUE);
	} else {
		alSourcei(sourceID, AL_LOOPING, AL_FALSE);
	}
	// check to see if there are any errors
	err = alGetError();
	if (err != 0) {
		NSLog(@"Error Playing Sound!");
		return 0;
	}
	// now play!
	alSourcePlay(sourceID);
	return sourceID; // return the sourceID so I can stop loops easily
}

- (void)stopSound:(int)soundKey
{
	
	alSourceStop(soundKey);
}

-(void)cleanUpOpenAL
{
	// delete the sources
	for (NSNumber * sourceNumber in [soundDictionary allValues]) {
		NSUInteger sourceID = [sourceNumber unsignedIntegerValue];
		alDeleteSources(1, &sourceID);
	}
	[soundDictionary removeAllObjects];
	
	// delete the buffers
	for (NSNumber * bufferNumber in bufferStorageArray) {
		NSUInteger bufferID = [bufferNumber unsignedIntegerValue];
		alDeleteBuffers(1, &bufferID);
	}
	[bufferStorageArray removeAllObjects];
	
	// destroy the context
	alcDestroyContext(mContext);
	// close the device
	alcCloseDevice(mDevice);
}
-(NSUInteger)_nextAvailableSource
{
	NSInteger sourceState; // a holder for the state of the current source
	
	// first check: find a source that is not being used at the moment.
	for (NSNumber * sourceNumber in sources) {
		alGetSourcei([sourceNumber unsignedIntValue], AL_SOURCE_STATE, &sourceState);
		// great! we found one! return it and shunt
		if (sourceState != AL_PLAYING) return [sourceNumber unsignedIntValue];
	}
	
	// in the case that all our sources are being used, we will find the first non-looping source
	// and return that.
	// first kick out an error
	NSLog(@"available source overrun, increase MAX_SOURCES");
	
	NSInteger looping;
	for (NSNumber * sourceNumber in sources) {
		alGetSourcei([sourceNumber unsignedIntValue], AL_LOOPING, &looping);
		if (!looping) {
			// we found one that is not looping, cut it short and return it
			NSUInteger sourceID = [sourceNumber unsignedIntValue];
			alSourceStop(sourceID);
			return sourceID;
		}
	}
	
	// what if they are all loops? arbitrarily grab the first one and cut it short
	// kick out another error
	NSLog(@"available source overrun, all used sources looping");
	
	NSUInteger sourceID = [[sources objectAtIndex:0] unsignedIntegerValue];
	alSourceStop(sourceID);
	return sourceID;
}

@end
