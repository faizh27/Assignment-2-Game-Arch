//
//  FogUIComponent.swift
//  Assignment 2
//
//  Created by Lukasz Bednarek on 2024-02-25.
//

import UIKit

class FogUIComponent: UIView {
    let startDistance = UISlider()
    let endDistance = UISlider()
    let density = UISlider()
    
    let fogToggle = UIButton(type: .system)
    let grayFog = UIButton(type: .system)
    let redFog = UIButton(type: .system)
    let blueFog = UIButton(type: .system)
    let greenFog = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Customize sliders
        startDistance.frame = CGRect(x: 20, y: 20, width: frame.width - 40, height: 20)
        startDistance.minimumValue = 0
        startDistance.maximumValue = 20
        addSubview(startDistance)
        
        endDistance.frame = CGRect(x: 20, y: 60, width: frame.width - 40, height: 20)
        endDistance.minimumValue = 0
        endDistance.maximumValue = 20
        addSubview(endDistance)
        
        density.frame = CGRect(x: 20, y: 100, width: frame.width - 40, height: 20)
        density.minimumValue = 1
        density.maximumValue = 2
        addSubview(density)
        
        // Customize buttons
        fogToggle.frame = CGRect(x: 110, y: 130, width: 90, height: 35)
        fogToggle.setTitle("On/Off", for: .normal)
        customizeButton(button: fogToggle, bgColor: UIColor.white)
        addSubview(fogToggle)
        
        grayFog.frame = CGRect(x: 50, y: 180, width: 90, height: 35)
        grayFog.setTitle("Gray Fog", for: .normal)
        customizeButton(button: grayFog, bgColor: UIColor.lightGray)
        addSubview(grayFog)
        
        redFog.frame = CGRect(x: 50, y: 230, width: 90, height: 35)
        redFog.setTitle("Red Fog", for: .normal)
        customizeButton(button: redFog, bgColor: UIColor.red)
        addSubview(redFog)
        
        blueFog.frame = CGRect(x: 180, y: 180, width: 90, height: 35)
        blueFog.setTitle("Blue Fog", for: .normal)
        customizeButton(button: blueFog, bgColor: UIColor.blue)
        addSubview(blueFog)
        
        greenFog.frame = CGRect(x: 180, y: 230, width: 90, height: 35)
        greenFog.setTitle("Green Fog", for: .normal)
        customizeButton(button: greenFog, bgColor: UIColor.green)
        addSubview(greenFog)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customizeButton(button: UIButton, bgColor: UIColor) {
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.backgroundColor = bgColor.cgColor
    }
}

