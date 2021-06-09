//
//  ViewController.swift
//  SoundTouchDemo
//
//  Created by roni on 2021/6/7.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player = AVAudioPlayer()
    var activity = UIActivityIndicatorView(style: .medium)
    var sourcePath: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        activity.color = UIColor.cyan
        activity.backgroundColor = .black
        activity.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activity)
        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activity.widthAnchor.constraint(equalToConstant: 40),
            activity.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var pitchSlider: UISlider!

    @IBAction func tempoChange(_ sender: UISlider) {
        tempoLabel.text = String(format: "%.0f", sender.value)
    }

    @IBAction func rateChange(_ sender: UISlider) {
        rateLabel.text = String(format: "%.0f", sender.value)
    }
    
    @IBAction func pitchChange(_ sender: UISlider) {
        pitchLabel.text = String(format: "%.1f", sender.value)
    }

    @IBAction func soundChange(_ sender: Any) {

        let tempo = Int32(String(format: "%.0f", tempoSlider.value))!
        let rate = Int32(String(format: "%.0f", rateSlider.value))!
        let pitch = Float(String(format: "%.1f", pitchSlider.value))!

        print("tempo: \(tempo), rate: \(rate), pitch: \(pitch)")
        let changeConfig = SoundChangeConfig(tempo: tempo, pitch: pitch, rate: rate)
        guard let audioPath = Bundle.main.path(forResource: "123", ofType: "m4a") else {
            print("音频不存在")
            return
        }

        activity.startAnimating()
        let soundChanger = AudioSoundChanger.shared
        soundChanger.changeSound(audioPth: audioPath, soundConfig: changeConfig, outputConfig: .default) { [weak self] path in
            self?.output(path: path)
        } failure: { error in
            print("\(error)")
        }
    }

    @IBAction func playAudio(_ sender: Any) {
        guard let path = sourcePath else {
            return
        }

        player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        player.play()
    }

    @IBAction func stopAudio(_ sender: Any) {
        if player.isPlaying {
            player.stop()
        }
    }

    func output(path: String) {
        activity.stopAnimating()
        sourcePath = path
//        let activityViewController = UIActivityViewController(activityItems: [URL(fileURLWithPath: path)],
//                                                              applicationActivities: nil)
//        DispatchQueue.main.async {
//            if let popoverPresentationController = activityViewController.popoverPresentationController {
//                popoverPresentationController.barButtonItem = nil
//            }
//            activityViewController.popoverPresentationController?.sourceView = self.view
//            activityViewController.popoverPresentationController?.sourceRect = self.view.frame
//            self.present(activityViewController, animated: true, completion: nil)
//        }
    }
}

