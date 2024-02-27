//
//  FogUIComponent.swift
//  Assignment 2
//
//  Created by Lukasz Bednarek on 2024-02-25.
//

import UIKit

class FogUIComponent: UIView {
    let startDistanceSlider = UISlider()
    let endDistanceSlider = UISlider()
    let densitySlider = UISlider()
    
    let fogToggle = UIButton(type: .system)
    let grayFog = UIButton(type: .system)
    let redFog = UIButton(type: .system)
    let blueFog = UIButton(type: .system)
    let greenFog = UIButton(type: .system)
    
    var fogUIColorChangeHandler: ((UIColor) -> Void)?
    var fogToggleHandler: (() -> Void)?
    
    var startDistanceHandler: ((Float) -> Void)?
    var endDistanceHandler: ((Float) -> Void)?
    var densityHandler: ((Float) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Customize sliders
        startDistanceSlider.frame = CGRect(x: 20, y: 20, width: frame.width - 40, height: 20)
        startDistanceSlider.minimumValue = 0
        startDistanceSlider.maximumValue = 15
        startDistanceSlider.value = 0
        addSubview(startDistanceSlider)
        
        endDistanceSlider.frame = CGRect(x: 20, y: 60, width: frame.width - 40, height: 20)
        endDistanceSlider.minimumValue = 0
        endDistanceSlider.maximumValue = 15
        endDistanceSlider.value = 2.5
        addSubview(endDistanceSlider)
        
        densitySlider.frame = CGRect(x: 20, y: 100, width: frame.width - 40, height: 20)
        densitySlider.minimumValue = 1
        densitySlider.maximumValue = 2
        densitySlider.value = 1
        addSubview(densitySlider)
        
        // Customize buttons
        fogToggle.frame = CGRect(x: 110, y: 130, width: 90, height: 35)
        fogToggle.setTitle("On/Off", for: .normal)
        setButtonStyle(button: fogToggle, bgColor: UIColor.white)
        addSubview(fogToggle)
        
        grayFog.frame = CGRect(x: 50, y: 180, width: 90, height: 35)
        grayFog.setTitle("Gray Fog", for: .normal)
        setButtonStyle(button: grayFog, bgColor: UIColor.lightGray)
        addSubview(grayFog)
        
        redFog.frame = CGRect(x: 50, y: 230, width: 90, height: 35)
        redFog.setTitle("Red Fog", for: .normal)
        setButtonStyle(button: redFog, bgColor: UIColor.red)
        addSubview(redFog)
        
        blueFog.frame = CGRect(x: 180, y: 180, width: 90, height: 35)
        blueFog.setTitle("Blue Fog", for: .normal)
        setButtonStyle(button: blueFog, bgColor: UIColor.blue)
        addSubview(blueFog)
        
        greenFog.frame = CGRect(x: 180, y: 230, width: 90, height: 35)
        greenFog.setTitle("Green Fog", for: .normal)
        setButtonStyle(button: greenFog, bgColor: UIColor.green)
        addSubview(greenFog)
        
        // Add button functions
        grayFog.addTarget(self, action: #selector(grayFogTapped), for: .touchUpInside)
        redFog.addTarget(self, action: #selector(redFogTapped), for: .touchUpInside)
        blueFog.addTarget(self, action: #selector(blueFogTapped), for: .touchUpInside)
        greenFog.addTarget(self, action: #selector(greenFogTapped), for: .touchUpInside)
        fogToggle.addTarget(self, action: #selector(fogToggleTapped), for: .touchUpInside)
        
        // Add slider functions
        startDistanceSlider.addTarget(self, action: #selector(startDistanceChanged), for: .valueChanged)
        endDistanceSlider.addTarget(self, action: #selector(endDistanceChanged), for: .valueChanged)
        densitySlider.addTarget(self, action: #selector(densityChanged), for: .valueChanged)
    }
    
    // button and slider action methods
    @objc func grayFogTapped() {
        fogUIColorChangeHandler?(.gray)
    }
    
    @objc func redFogTapped() {
        fogUIColorChangeHandler?(.red)
    }
    
    @objc func blueFogTapped() {
        fogUIColorChangeHandler?(.blue)
    }
    
    @objc func greenFogTapped() {
        fogUIColorChangeHandler?(.green)
    }
    
    @objc func fogToggleTapped() {
        fogToggleHandler?()
    }
    
    @objc func startDistanceChanged() {
        startDistanceHandler?(startDistanceSlider.value)
    }

    @objc func endDistanceChanged() {
        endDistanceHandler?(endDistanceSlider.value)
    }

    @objc func densityChanged() {
        densityHandler?(densitySlider.value)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setButtonStyle(button: UIButton, bgColor: UIColor) {
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.backgroundColor = bgColor.cgColor
    }
}

