//
//  ViewController.swift
//  RaspiCatCam
//
//  Created by RAG on 7/2/17.
//  Copyright © 2017 RAG. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    //MARK: Properties
    
    @IBOutlet weak var titleNameLabel: UILabel!
    
    @IBOutlet weak var webCamera: UIWebView!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    var camURL = "http://192.168.1.115/cam_pic_led.php"
    var soundFileURL =  URL(fileURLWithPath: "file://myaudio.caf")
    var recId = "123"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Audio Setup
            playBtn.isEnabled = false
        
            let fileMgr = FileManager.default
            
            let dirPaths = fileMgr.urls(for: .documentDirectory,
                                        in: .userDomainMask)
            
            soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        
            print (soundFileURL)
        
            let recordSettings =
                [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                 AVEncoderBitRateKey: 16,
                 AVNumberOfChannelsKey: 2,
                 AVSampleRateKey: 44100.0] as [String : Any]
            
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setCategory(
                    AVAudioSessionCategoryPlayAndRecord)
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
            
            do {
                try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                    settings: recordSettings as [String : AnyObject])
                audioRecorder?.prepareToRecord()
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
        
        // WEB CAMERA Setup
        let url = URL(string: camURL)
        let request = URLRequest(url: url!)
            webCamera.loadRequest(request)
        
        }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    

    @IBAction func recordAudio(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            playBtn.isEnabled = true
            recordBtn.isEnabled = false
            audioRecorder?.record()
        }
    }
    
    
    @IBAction func stopAudio(_ sender: Any) {
        playBtn.isEnabled = false
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        }
        // Get the audio filename
        do {
            try audioPlayer = AVAudioPlayer(contentsOf:
                (audioRecorder?.url)!)
            // Send to Remote Web Server
            
            let boundary = "--------1439234533432299--------"
            let beginningBoundary = "--\(boundary)"
            let endingBoundary = "--\(boundary)--"
            let contentType = "multipart/form-data;boundary=\(boundary)"

            let filename = "TODO"
            let recording: NSData? = NSData(contentsOf: soundFileURL)
            
            var header = "Content-Disposition: form-data; name=\"\(filename)\"; filename=\"\(filename)\"\r\n"
            var body = NSMutableData()
            
            body.append(("\(beginningBoundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append((header as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append(("Content-Type: application/octet-stream\r\n\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append(recording! as Data) // adding the recording here
            body.append(("\r\n\(endingBoundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            
            var request = NSMutableURLRequest()
            request.url = soundFileURL
            request.httpMethod = "POST"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            request.addValue(recId, forHTTPHeaderField: "REC-ID") // recId is defined elsewhere
            request.httpBody = body as Data
            
            var session = URLSession.shared
            var task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                print("upload complete")
                let dataStr = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                print(dataStr ?? <#default value#>)
                
            })
            
            task.resume()
            
        } catch let error as NSError {
            print("audioPlayer error: \(error.localizedDescription)")
        }
        recordBtn.isEnabled = true

    }
    
        
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }
    
}
