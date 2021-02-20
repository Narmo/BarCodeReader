//
//  CMGOverlayView.swift
//  BarCodeReader
//
//  Created by Chris Greening on 01/10/2013.
//  Copyright (c) 2013 Chris Greening. All rights reserved.
//
//  Swift version with improvements created by Nik Dyonin on 18.02.2021.
//  Copyright (c) 2021 Nik Dyonin. All rights reserved.
//

import UIKit

public class CMGOverlayView: UIView {
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	private func commonInit() {
		let layer = self.layer as! CAShapeLayer
		
		layer.lineWidth = 1
		layer.strokeColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5).cgColor
		layer.fillColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).cgColor
	}
	
	public override class var layerClass: AnyClass {
		return CAShapeLayer.self
	}
}
