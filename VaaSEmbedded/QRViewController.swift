//
//  ViewController.swift
//  VaaSEmbedded
//
//  Created by Brian Keane on 1/20/21.
//

import AVFoundation
import UIKit
import WebKit

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, WKNavigationDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var webView: WKWebView?
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        var videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("error capturing video")
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            handleFailure()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

                if (captureSession.canAddOutput(metadataOutput)) {
                    captureSession.addOutput(metadataOutput)

                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.qr]
                } else {
                    handleFailure()
                    return
                }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = view.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(previewLayer)

                captureSession.startRunning()
    }

    func handleFailure() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            print("starting capture session")
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()

            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                handleCodeFound(code: stringValue)
            }

            dismiss(animated: true)
        }

    func handleCodeFound(code: String) {
        self.webView = WKWebView()
        self.webView!.navigationDelegate = self
        view = webView!
        webView!.setNeedsFocusUpdate()

        let url = URL(string: code)!
        let urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        webView?.load(urlRequest)
    }


    override var prefersStatusBarHidden: Bool { return true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }

}

