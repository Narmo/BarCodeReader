//
//  CMGViewController.swift
//  BarCodeReader
//
//  Created by Chris Greening on 01/10/2013.
//  Copyright (c) 2013 Chris Greening. All rights reserved.
//
//  Swift version with improvements created by Nik Dyonin on 18.02.2021.
//  Copyright (c) 2021 Nik Dyonin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

@objc public protocol CMGViewControllerDelegate: NSObjectProtocol {
	@objc func didScan(result: String)
	@objc func didFail(error: Error)
	@objc optional func dataTypes() -> [AVMetadataObject.ObjectType]
}

@objc public class CMGViewController: UIViewController {
	private var session: AVCaptureSession?
	private var previewView: UIView?
	private var previewLayer: AVCaptureVideoPreviewLayer?
	private var overlayView: CMGOverlayView?
	private var loadingError: Error?
	@objc public weak var delegate: CMGViewControllerDelegate?
	
	public override func viewDidLoad() {
		super.viewDidLoad()

		session = AVCaptureSession()
		
		// create the preview layer
		previewLayer = AVCaptureVideoPreviewLayer(session: session!)
		
		previewView = UIView(frame: view.bounds)
		view.addSubview(previewView!)

		overlayView = CMGOverlayView(frame: view.bounds)
		view.addSubview(overlayView!)
		
		previewLayer!.frame = previewView!.layer.bounds
		previewView!.layer.addSublayer(previewLayer!)
		previewLayer!.videoGravity = .resize
		
		
		// Get the Camera Device
		
		let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
		guard let camera = (discoverySession.devices.first { $0.position == .back }) else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: "Failed to get camera device",
				NSLocalizedRecoverySuggestionErrorKey: "Check camera availability and privacy settings."
			]
			
			loadingError = NSError(domain: "BarCodeReader", code: -1001, userInfo: userInfo)
			
			return
		}

		do {
			try camera.lockForConfiguration()
		}
		catch {
			loadingError = error
			return
		}
		
		if camera.isFocusModeSupported(.continuousAutoFocus) {
			camera.focusMode = .continuousAutoFocus
		}
		
		if camera.isAutoFocusRangeRestrictionSupported {
			camera.autoFocusRangeRestriction = .near
		}
		
		camera.unlockForConfiguration()
		
		let cameraInput: AVCaptureDeviceInput?
		
		do {
			cameraInput = try AVCaptureDeviceInput(device: camera)
		}
		catch {
			loadingError = error
			return
		}
		
		session!.addInput(cameraInput!)
		
		let output = AVCaptureMetadataOutput()
		
		session!.addOutput(output)
		
		// see what types are supported (do this after adding otherwise the output reports nothing supported)
		
		let potentialDataTypes = delegate?.dataTypes?() ?? [AVMetadataObject.ObjectType.qr]
		var supportedMetaDataTypes: [AVMetadataObject.ObjectType] = []
		
		for availableMetadataObject in output.availableMetadataObjectTypes {
			if potentialDataTypes.contains(availableMetadataObject) {
				supportedMetaDataTypes.append(availableMetadataObject)
			}
		}
		
		output.metadataObjectTypes = supportedMetaDataTypes
		
		output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		
		session!.startRunning()
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let error = loadingError {
			delegate?.didFail(error: error)
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		previewView?.frame = view.bounds
		overlayView?.frame = view.bounds
		previewLayer?.frame = previewView?.layer.bounds ?? .zero
	}
	
	deinit {
		session?.stopRunning()
	}
}

extension CMGViewController: AVCaptureMetadataOutputObjectsDelegate {
	public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		if metadataObjects.count > 0 {
			session?.stopRunning()
			
			// draw where the recognised data is - for 1D barcodes this turns out to be just a line accross the code. For 2D barcodes it's a bit more interesting
			
			let path = CGMutablePath()
			let transform = CGAffineTransform(scaleX: overlayView!.bounds.size.width, y: overlayView!.bounds.size.height)
			
			metadataObjects.forEach {
				guard let object = $0 as? AVMetadataMachineReadableCodeObject else {
					return
				}
				
				let p1 = object.corners[0]
				let p2 = object.corners[1]
				let p3 = object.corners[2]
				let p4 = object.corners[3]
				
				path.move(to: CGPoint(x: 1 - p1.y, y: p1.x), transform: transform)
				path.addLine(to: CGPoint(x: 1 - p2.y, y: p2.x), transform: transform)
				path.addLine(to: CGPoint(x: 1 - p3.y, y: p3.x), transform: transform)
				path.addLine(to: CGPoint(x: 1 - p4.y, y: p4.x), transform: transform)
				
				path.closeSubpath()
			}
			
			(overlayView!.layer as! CAShapeLayer).path = path
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
				if let recognizedObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
					if let value = recognizedObject.stringValue {
						self?.delegate?.didScan(result: value)
					}
				}
			}
		}
	}
}
