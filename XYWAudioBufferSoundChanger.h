//
//  XYWAudioBufferSoundChanger.h
//  XYWSoundChanger
//
//  Created by Yuri on 2020/6/19.
//  Copyright © 2020 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYWAudioBufferSoundChanger : NSObject

/**
创建变声器

@param sampleRate buffer
@param tempo 速度 <变速不变调> 范围 -50 ~ 100
@param pitch 音调  范围 -12 ~ 12 （-12男，12女）
@param rate 声音速率 范围 -50 ~ 100
@param channels 声轨数 默认1
*/
- (id)initWithSampleRate:(int)sampleRate tempo:(int)tempo pitch:(int)pitch rate:(int)rate channels:(int)channels;

/// 对buffer变声
- (CMSampleBufferRef)changeSoundBuffer:(CMSampleBufferRef)ref;;

@end

NS_ASSUME_NONNULL_END
