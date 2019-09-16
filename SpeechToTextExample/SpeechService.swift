//
//  SpeechService.swift
//  SpeechToTextExample
//
//  Created by Jonathan Kopp on 9/6/19.
//  Copyright © 2019 Jonathan Kopp. All rights reserved.
//

import Foundation
import UIKit
import Speech

class SpeechService: UIViewController, SFSpeechRecognizerDelegate
{
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var mostRecentlyProcessedSegmentDuration: TimeInterval = 0
    
    //Add Privacy - Microphone Usage Description inside the info.plist
    //so that we can have access to users microphone
    func requestMicAccess()
    {
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
            switch authStatus {
            case .authorized:
                do {
                    try self.startRecording()
                } catch let error {
                    print("There was a problem starting recording: \(error.localizedDescription)")
                }
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Not available on this device")
            case .notDetermined:
                print("Not determined")
            @unknown default:
                print("Huh?")
            }
        }
    }
    
    func startRecording() throws
    {
        //print("Recording Audio")
        //Starts recording audio saving it to the audio engine
        mostRecentlyProcessedSegmentDuration = 0
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024,
                        format: recordingFormat) { [unowned self]
                            (buffer, _) in
                            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        //Audio engine now trys to transcribe the audio to convert to string
        try audioEngine.start()
        recognitionTask = speechRecognizer?.recognitionTask(with: request) {
            [unowned self]
            (result, _) in
            if let transcription = result?.bestTranscription {
                self.updateUIWithTranscription(transcription)
            }
            
        }
    }
    
    //Simply resets the audio recorder so we can go again if need be
    func stopRecording() {
        print("Stopping Recording Audio")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        recognitionTask?.cancel()
    }
    
    //Grabs the text from the transcript. Subscribe to notification "micOutput" to recieve the
    //string in another view controller.
    func updateUIWithTranscription(_ transcription: SFTranscription) {
        let text = transcription.formattedString
        actionCase(str: text)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "micOutput"), object: nil, userInfo: ["output" : text])
        if let lastSegment = transcription.segments.last,
            lastSegment.duration > mostRecentlyProcessedSegmentDuration {
            mostRecentlyProcessedSegmentDuration = lastSegment.duration
            print(lastSegment.substring)
        }
    }
    
    func actionCase(str: String)
    {
        switch str{
        case "Open Door":
            print("Now opening door")
        case "Open Sesame":
            print("Opening la door")
        case "Open Make School Front Door":
            print("Opening make school front door")
        case "Search":
            print("Searching!")
        default:
            print("Sorry I didn't catch that :(")
        }
    }
    
}
