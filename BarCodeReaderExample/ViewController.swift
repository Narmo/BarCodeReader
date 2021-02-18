//
//  ViewController.swift
//  BarCodeReaderExample
//
//  Created by Nik Dyonin on 18.02.2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
	@IBOutlet weak var scanButton: UIButton!
	@IBOutlet weak var resultLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		scanButton.addTarget(self, action: #selector(startScanner), for: .touchUpInside)
	}
	
	@objc private func startScanner() {
		let v = CMGViewController()
		v.delegate = self
		
		present(v, animated: true, completion: nil)
	}
}

extension ViewController: CMGViewControllerDelegate {
	func didScan(result: String) {
		resultLabel.text = "Scanned: \(result)"
	}
	
	func didFail(error: Error) {
		let error = error as NSError
		
		dismiss(animated: true) { [weak self] in
			let alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self?.present(alert, animated: true, completion: nil)
		}
	}
	
	func dataTypes() -> [AVMetadataObject.ObjectType] {
		return [.qr]
	}
}
