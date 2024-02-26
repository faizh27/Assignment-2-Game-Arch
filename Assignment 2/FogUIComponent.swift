//
//  FogUIComponent.swift
//  Assignment 2
//
//  Created by Lukasz Bednarek on 2024-02-25.
//

import UIKit

class FogUIComponent: UIView {
    // Declare sliders and buttons
    let slider1 = UISlider()
    let slider2 = UISlider()
    let button1 = UIButton(type: .system)
    let button2 = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Customize sliders
        slider1.frame = CGRect(x: 20, y: 20, width: frame.width - 40, height: 20)
        slider1.minimumValue = 0
        slider1.maximumValue = 100
        addSubview(slider1)
        
        slider2.frame = CGRect(x: 20, y: 60, width: frame.width - 40, height: 20)
        slider2.minimumValue = 0
        slider2.maximumValue = 100
        addSubview(slider2)
        
        // Customize buttons
        button1.frame = CGRect(x: 20, y: 100, width: frame.width - 40, height: 40)
        button1.setTitle("Button 1", for: .normal)
        addSubview(button1)
        
        button2.frame = CGRect(x: 20, y: 150, width: frame.width - 40, height: 40)
        button2.setTitle("Button 2", for: .normal)
        addSubview(button2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

