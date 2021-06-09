//
//  XYWAudioFileSoundChanger.m
//  XYWSoundChanger
//
//  Created by Yuri on 2020/7/1.
//  Copyright © 2020 xueyognwei. All rights reserved.
//

#import "XYWAudioFileSoundChanger.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AudioConvert.h"

@interface XYWAudioFileSoundChanger()<AudioConvertDelegate>
@property (nonatomic,copy) void(^success)(NSString *videoPath);
@property (nonatomic,copy) void(^failure)(NSError *error);
//@property (nonatomic,assign)int tempo;
//@property (nonatomic,assign)int pitch;
//@property (nonatomic,assign)int rate;
//@property (nonatomic,copy)NSString *videoPath;
@end

@implementation XYWAudioFileSoundChanger

+(XYWAudioFileSoundChanger *)shared
{
    static XYWAudioFileSoundChanger *changer = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        changer = [[self alloc] init];
    });
    return changer;
}

/**
 把某个音频文件进行变声操作

 @param audioPath 视频url
 @param tempo 速度 <变速不变调> 范围 -50 ~ 100
 @param pitch 音调  范围 -12 ~ 12 （-12男，12女）
 @param rate 声音速率 范围 -50 ~ 100
 */
-(void)changeAudio:(NSString *)audioPath withTempo:(int)tempo andPitch:(int)pitch andRate:(int)rate sucess:(void (^)(NSString *audioPath))success failure:(void (^)(NSError *error))failure{
    
    self.success = success;
    self.failure = failure;
    
    AudioConvertConfig dconfig;
    dconfig.sourceAuioPath = [audioPath UTF8String];
    dconfig.outputFormat = AudioConvertOutputFormat_WAV;
    dconfig.outputChannelsPerFrame = 1;
    dconfig.outputSampleRate = 8000;
    dconfig.soundTouchPitch = pitch;
    dconfig.soundTouchRate = rate;
    dconfig.soundTouchTempoChange = tempo;
    CNLog(@"设置完毕，开始变声处理..");
    [[AudioConvert shareAudioConvert] audioConvertBegin:dconfig withCallBackDelegate:self];
}

#pragma mark - AudioConvertDelegate
- (BOOL)audioConvertOnlyDecode
{
    return  NO;
}
- (BOOL)audioConvertHasEnecode
{
    return YES;
}
/**
 * 对音频变声动作的回调
 **/
- (void)audioConvertSoundTouchSuccess:(NSString *)audioPath
{
    //变声成功
    CNLog(@"变声成功，即将播放");
}
- (void)audioConvertSoundTouchFail
{
    //变声失败
    CNLog(@"变声失败！");
}
/**
 * 对音频解码动作的回调
 **/
- (void)audioConvertDecodeSuccess:(NSString *)audioPath {
    //解码成功
    CNLog(@"解码成功");
}
- (void)audioConvertDecodeFaild
{
    //解码失败
    CNLog(@"解码失败");
}

/**
 * 对音频编码动作的回调
 **/
- (void)audioConvertEncodeSuccess:(NSString *)audioPath
{
    //编码完成
    CNLog(@"编码成功");
    self.success(audioPath);
}

- (void)audioConvertEncodeFaild
{
    //编码失败
    CNLog(@"编码失败");
    NSError *err = [NSError errorWithDomain:@"audioConvertEncodeFaild" code:500 userInfo:@{@"errMsg":@"audioConvertEncodeFaild"}];
    self.failure(err);
}
@end
