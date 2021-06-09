//
//  XYWAudioBufferSoundChanger.m
//  XYWSoundChanger
//
//  Created by Yuri on 2020/6/19.
//  Copyright © 2020 xueyognwei. All rights reserved.
//

#import "XYWAudioBufferSoundChanger.h"
#import "SoundTouch.h"

@interface XYWAudioBufferSoundChanger()
@property(nonatomic,assign) int audioSampleRate;
@property(nonatomic,assign) int tempo;
@property(nonatomic,assign) int pitch;
@property(nonatomic,assign) int rate;
@property(nonatomic,assign) int channels;
@end

@implementation XYWAudioBufferSoundChanger
{
     soundtouch::SoundTouch mSoundTouch;
}

+(XYWAudioBufferSoundChanger *)shared
{
    static XYWAudioBufferSoundChanger *changer = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        changer = [[self alloc] init];
    });
    return changer;
}
- (id)initWithSampleRate:(int)sampleRate tempo:(int)tempo pitch:(int)pitch rate:(int)rate channels:(int)channels
{
    self = [super init];
    if (self != nil) {
        self.audioSampleRate = sampleRate;
        self.tempo = tempo;
        self.pitch = pitch;
        self.rate = rate;
        self.channels = channels;
        [self setupSoundTouch];
    }
    return self;
}

-(void)setupSoundTouch {
    
    mSoundTouch.setSampleRate(self.audioSampleRate); //采样率
    mSoundTouch.setChannels(self.channels);       //设置声音的声道
    mSoundTouch.setTempoChange(self.tempo);    //这个就是传说中的变速不变调
    mSoundTouch.setPitchSemiTones(self.pitch); //设置声音的pitch (集音高变化semi-tones相比原来的音调)
    mSoundTouch.setRateChange(self.rate);     //设置声音的速率
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 15); //寻找帧长
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 6);  //重叠帧长
}

/// 变换声音
- (CMSampleBufferRef)changeSoundBuffer:(CMSampleBufferRef)ref {
    
    AudioBufferList audioBufferList;
    CMBlockBufferRef blockBuffer;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(ref, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);

    AudioBuffer audioBuffer = audioBufferList.mBuffers[0];
    Float32 *frame = (Float32*)audioBuffer.mData;
    NSMutableData *audioData=[[NSMutableData alloc] init];
    [audioData appendBytes:frame length:audioBuffer.mDataByteSize];

    char *pcmData = (char *)audioData.bytes;
    int pcmSize = (int)audioData.length;
    int nSamples = pcmSize / 2;
    mSoundTouch.putSamples((short *)pcmData, nSamples);


    if (audioData.length == 0) {
        return ref;
    }

    NSMutableData *soundTouchDatas = [[NSMutableData alloc] init];

    short *samples = new short[pcmSize];
    int numSamples = 0;

    memset(samples, 0, pcmSize);
    
    numSamples = mSoundTouch.receiveSamples(samples,nSamples);
    [soundTouchDatas appendBytes:samples length:numSamples*2];

    delete [] samples;

    CMItemCount timingCount;
    CMSampleBufferGetSampleTimingInfoArray(ref, 0, nil, &timingCount);
    CMSampleTimingInfo* pInfo = (CMSampleTimingInfo *)malloc(sizeof(CMSampleTimingInfo) * timingCount);
    CMSampleBufferGetSampleTimingInfoArray(ref, timingCount, pInfo, &timingCount);

    if (soundTouchDatas.length == 0) {
        return ref;
    }

    void *touchData = (void *)[soundTouchDatas bytes];
    CMSampleBufferRef touchSampleBufferRef = [self createAudioSample:touchData frames:(int)[soundTouchDatas length] timing:*pInfo];
    return touchSampleBufferRef;
}

/// 从sampleData转为CMSampleBufferRef
- (CMSampleBufferRef)createAudioSample:(void *)audioData frames:(UInt32)len timing:(CMSampleTimingInfo)timing
{
    int channels = 1;
    AudioBufferList audioBufferList;
    audioBufferList.mNumberBuffers = 1;
    audioBufferList.mBuffers[0].mNumberChannels=channels;
    audioBufferList.mBuffers[0].mDataByteSize=len;
    audioBufferList.mBuffers[0].mData = audioData;

    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = 44100;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = 0x29;
    asbd.mBytesPerPacket = 4;
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerFrame = 4;
    asbd.mChannelsPerFrame = 1;
    asbd.mBitsPerChannel = 32;
    asbd.mReserved = 0;

    CMSampleBufferRef buff = NULL;
    static CMFormatDescriptionRef format = NULL;

    OSStatus error = 0;
    error = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &asbd, 0, NULL, 0, NULL, NULL, &format);
    if (error) {
        return NULL;
    }

    error = CMSampleBufferCreate(kCFAllocatorDefault, NULL, false, NULL, NULL, format, len/4, 1, &timing, 0, NULL, &buff);
    if (error) {
        return NULL;
    }

    error = CMSampleBufferSetDataBufferFromAudioBufferList(buff, kCFAllocatorDefault, kCFAllocatorDefault, 0, &audioBufferList);
    if(error){
        return NULL;
    }

    return buff;
}

@end
