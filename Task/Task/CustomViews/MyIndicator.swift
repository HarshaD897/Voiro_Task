//
//  MyIndicator.swift
//  Task
//
//  Created by apple on 29/08/22.
//

import UIKit


class MyIndicator: UIView {

    let imageView = UIImageView()
    let backgroundView = UIView()
    let fixedLabel = UILabel()
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        backgroundView.frame = bounds
        imageView.frame = CGRect(x: 25, y: 10, width: 50, height: 50)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fixedLabel.frame = CGRect(x: 0, y: bounds.maxY - 30, width: bounds.maxX, height: 20)
        fixedLabel.textAlignment = .center
        fixedLabel.text = "Please wait"
        fixedLabel.textColor = .black
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(fixedLabel)
        addSubview(backgroundView)
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    func startAnimating() {
        isHidden = false
        rotate()
    }

    func stopAnimating() {
        isHidden = true
        removeRotation()
    }

    private func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.imageView.layer.add(rotation, forKey: "rotationAnimation")
    }

    private func removeRotation() {
         self.imageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
