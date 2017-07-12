//
//  ViewController.swift
//  RaspiCatCam
//
//  Created by RAG on 7/2/17.
//  Copyright © 2017 RAG. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate , WKUIDelegate{
    //MARK: Properties
    
    @IBOutlet weak var titleNameLabel: UILabel!
    
    @IBOutlet weak var webCamera: WKWebView!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    var camURL = "http://192.168.1.115/ios_cam.php"
    var soundURL = "http://192.168.1.115/uploadaudio.php"
    
    // Basic Auth
    var userid = "myid"
    var passwd = "mypwd"
    
    let soundfile = "myaudio"
    let ext = ".wav"
    var soundFilename =  URL(fileURLWithPath: NSTemporaryDirectory() + "myaudio.wav")
    var recId = "123"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Audio Setup
            playBtn.isEnabled = false
        
            print (soundFilename)
        
        AVAudioSession.sharedInstance().requestRecordPermission () {
            [unowned self] allowed in
            if allowed {
                // Microphone allowed, do what you like!
                let recordSettings =
                    [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                     AVEncoderBitRateKey: 16,
                     AVNumberOfChannelsKey: 1,
                     AVSampleRateKey: 12000.0] as [String : Any]
                
                let audioSession = AVAudioSession.sharedInstance()
                
                do {
                    try audioSession.setCategory(
                        AVAudioSessionCategoryPlayAndRecord)
                } catch let error as NSError {
                    print("audioSession error: \(error.localizedDescription)")
                }
                
                do {
                    try self.audioRecorder = AVAudioRecorder(url: self.soundFilename,
                                                        settings: recordSettings as [String : AnyObject])
                    self.audioRecorder?.prepareToRecord()
                } catch let error as NSError {
                    print("audioSession error: \(error.localizedDescription)")
                }

                
            } else {
                // User denied microphone. Tell them off!
                print("audioSession: No Permission")
            }
        }
        
        // WEB CAMERA Setup
        let url = URL(string: camURL)
        let request = URLRequest(url: url!)
            webCamera.load(request)
        
        // WEB CAMERA Pull Refresh
        /*
        webCamera.scrollView.bounces = true
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.refreshWebView), for: UIControlEvents.valueChanged)
        webCamera.scrollView.addSubview(refreshControl)
        */
        }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   // Basic Auth ?
    /*
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webCamera = WKWebView(frame: .zero, configuration: webConfiguration)
        webCamera.uiDelegate = self
        view = webCamera
    */

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
            
            // BASIC AUTH
            let idpw = "\(userid):\(passwd)"
            let idpwdata = idpw.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            let base64idpw = idpwdata!.base64EncodedString()
            let authString = "BASIC \(base64idpw)"
            
            
            let boundary = "--------1439234533432299--------"
            let beginningBoundary = "--\(boundary)"
            let endingBoundary = "--\(boundary)--"
            let contentType = "multipart/form-data;boundary=\(boundary)"

            let filename = soundfile + ext
            let recording: NSData? = NSData(contentsOf: soundFilename)
            
            let header = "Content-Disposition: form-data; name=\"\(soundfile)\"; filename=\"\(filename)\"\r\n"
            let body = NSMutableData()
            
            body.append(("\(beginningBoundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append((header as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append(("Content-Type: application/octet-stream\r\n\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append(recording! as Data) // adding the recording here
            body.append(("\r\n\(endingBoundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            
            let request = NSMutableURLRequest()
            request.url = URL(string: soundURL)
            request.httpMethod = "POST"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            request.addValue(authString, forHTTPHeaderField: "Authorization")
            request.addValue(recId, forHTTPHeaderField: "REC-ID") // recId is defined elsewhere
            request.httpBody = body as Data
            
            print (request.httpBody ?? "NO DATA")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                print("upload complete")
                let dataStr = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                print(dataStr ?? "empty audio data")
                
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
    
    // BASIC AUTH
    func webCamera(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let user = userid
        let password = passwd
        let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
    }

    
    // Web Pull Down Refresh
    func refreshWebView(sender: UIRefreshControl) {
        print("WEBCAM: refresh")
        let url = URL(string: camURL)
        let request = URLRequest(url: url!)
        webCamera.load(request)
        sender.endRefreshing()
    }
}
