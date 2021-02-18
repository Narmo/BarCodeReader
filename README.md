# BarCodeReader

Lightweight library which allows reading various barcode types on iOS devices. Supported barcode types are included in [`AVMetadataObject.ObjectType`](https://developer.apple.com/documentation/avfoundation/avmetadataobject/objecttype).

# Usage

**Swift**

```swift
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
```

**Objective-C**

```objc
- (void)startScan {
	CMGViewController *v = [[CMGViewController alloc] init];
	v.delegate = self;
	v.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:v animated:true completion:nil];
}

#pragma mark - CMGViewControllerDelegate

- (void)didScanWithResult:(NSString *)result {
	DDLogDebug(@"Scanned code with result: %@", result);
}

- (void)didFailWithError:(NSError *)error {
	DDLogError(@"Failed to scan code with error: %@", error);
}

- (NSArray<AVMetadataObjectType> *)dataTypes {
	return @[AVMetadataObjectTypeQRCode];
}
```

# License

BarCodeReader is available under the BSD-2-Clause License. See the LICENSE file for more info.
