//
//  ViewController.swift
//  han.parkingattendant
//
//  Created by Jelle Pals on 4/13/19.
//  Copyright © 2019 Jelle Pals. All rights reserved.
//

import UIKit
import AVKit
import Vision
import OpenALPRSwift

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let alprScanner = OAScanner(country: "eu")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createCamera();
    }
    
    private func createCamera(){
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {  return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage? = self.convert(cmage: ciimage)
        
        alprScanner?.scanImage(image, onSuccess: { (plates) in
            plates?.forEach({ (plate) in
                print("result: \(plate.number)")
            })
        }, onFailure: { (error) in
            print("error: \(error?.localizedDescription)")
        })
        
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
}
