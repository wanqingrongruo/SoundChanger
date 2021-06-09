//
//  AudioSoundChanger.swift
//  对音频变声
//
//  Created by roni on 2021/6/8.
//

import Foundation

public struct SoundChangeConfig {
    public let tempo: Int32  // 速度<变速不变调>, 范围 -50 ~ 100, (相较原始值的浮动比例)
    public let pitch: Float  // 音调, 范围 -12 ~ 12 (-12男, 12女)
    public let rate: Int32   // 声音速率, 范围 -50 ~ 100, (相较原始值的浮动比例)

    public init(tempo: Int32, pitch: Float, rate: Int32) {
        self.tempo = tempo
        self.pitch = pitch
        self.rate = rate
    }

    public static let original = SoundChangeConfig(tempo: 0, pitch: 0, rate: 0)
    public static let uncle = SoundChangeConfig(tempo: 0, pitch: -10, rate: 30)
    public static let lolita = SoundChangeConfig(tempo: 0, pitch: 10, rate: 30)
    public static let girl = SoundChangeConfig(tempo: 0, pitch: 8, rate: 0)
    public static let boy = SoundChangeConfig(tempo: 0, pitch: -6, rate: 0)
    public static let monster = SoundChangeConfig(tempo: -10, pitch: -12, rate: -4)
}

public struct SoundOutputConfig {

    // 输出音频格式, 可选 默认 AudioConvertOutputFormat_WAV  具体见AudioConvertOutputFormat
    public let outputFormat: AudioConvertOutputFormat
    // 输出文件的通道数, 可选 默认  1 可选择 1 或者 2 注意 最后输出的音频格式为mp3 时 通道数必须是 2 否则会造成编码后的音频变速
    public let outputChannelsPerFrame: Int32
    // 输出的采样率, 建议设置 8000 (优点: 采样率 越低 处理速度越快 缺点: 声音效果:反之 但非专业检测 不明显)
    public let outputSampleRate: Float64

    public init(outputFormat: AudioConvertOutputFormat, outputChannelsPerFrame: Int32, outputSampleRate: Float64) {
        self.outputFormat = outputFormat
        self.outputChannelsPerFrame = outputChannelsPerFrame
        self.outputSampleRate = outputSampleRate
    }

    public static let `default` = SoundOutputConfig(outputFormat: .MP3, outputChannelsPerFrame: 2, outputSampleRate: 8000)
}

public class AudioSoundChanger: NSObject {
    static let shared = AudioSoundChanger()
    private var success: ((_ outPath: String) -> Void)?
    private var failure: ((Error) -> Void)?
    private override init() {}

    /// 变声
    /// - Parameters:
    ///   - audioPth: 音频 url
    ///   - soundConfig: 声音配置
    ///   - success: 成功回调, outPath: 变声后的音频的地址
    ///   - failure: 失败回调
    public func changeSound(audioPth: String,
                            soundConfig: SoundChangeConfig,
                            outputConfig: SoundOutputConfig,
                            success: ((_ outPath: String) -> Void)?,
                            failure: ((Error) -> Void)?) {
        self.success = success
        self.failure = failure

        var convertConfig = AudioConvertConfig()
//        guard let chars = audioPth.cString(using: .utf8) else {
//            fatalError("音频路径有问题")
//        }
//        chars.withUnsafeBufferPointer { ptr in
//            convertConfig.sourceAuioPath = ptr.baseAddress
//        }
        convertConfig.sourceAuioPath = (audioPth as NSString).utf8String
        convertConfig.outputFormat = Int32(outputConfig.outputFormat.rawValue)
        convertConfig.outputChannelsPerFrame = outputConfig.outputChannelsPerFrame
        convertConfig.outputSampleRate = outputConfig.outputSampleRate

        convertConfig.soundTouchTempoChange = soundConfig.tempo
        convertConfig.soundTouchPitch = soundConfig.pitch
        convertConfig.soundTouchRate = soundConfig.rate
        AudioConvert.share().audioConvertBegin(convertConfig, withCallBackDelegate: self)
    }
}


extension AudioSoundChanger: AudioConvertDelegate {
    public func audioConvertOnlyDecode() -> Bool {
        return false
    }

    public func audioConvertHasEnecode() -> Bool {
        return true
    }

    public func audioConvertSoundTouchSuccess(_ audioPath: String!) {
        // 变声成功
        print("变声成功")
    }

    public func audioConvertSoundTouchFail() {
        // 变声失败
        print("变声失败")
        let error = NSError(domain: "audioConvertSoundTouchFail", code: -2, userInfo: ["errMsg": "audioConvertSoundTouchFail"])

        failure?(error)
    }

    public func audioConvertDecodeSuccess(_ audioPath: String!) {
        // 解码成功
        print("解码成功")
    }

    public func audioConvertDecodeFaild() {
        // 解码失败
        let error = NSError(domain: "audioConvertDecodeFaild", code: -1, userInfo: ["errMsg": "audioConvertDecodeFaild"])

        failure?(error)
    }

    public func audioConvertEncodeSuccess(_ audioPath: String!) {
        // 编码成功
        success?(audioPath)
    }

    public func audioConvertEncodeFaild() {
        // 编码失败
        let error = NSError(domain: "audioConvertEncodeFaild", code: -3, userInfo: ["errMsg": "audioConvertEncodeFaild"])

        failure?(error)
    }
}
