//
//  XYWAudioFileSoundChanger.h
//  XYWSoundChanger
//
//  Created by Yuri on 2020/7/1.
//  Copyright © 2020 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYWAudioFileSoundChanger : NSObject
/// 单例
+(XYWAudioFileSoundChanger *)shared;
/**
 把某个音频文件进行变声操作

 @param audioPath 视频url
 @param tempo 速度 <变速不变调> 范围 -50 ~ 100
 @param pitch 音调  范围 -12 ~ 12 （-12男，12女）
 @param rate 声音速率 范围 -50 ~ 100
 */
-(void)changeAudio:(NSString *)audioPath withTempo:(int)tempo andPitch:(int)pitch andRate:(int)rate sucess:(void (^)(NSString *audioPath))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
