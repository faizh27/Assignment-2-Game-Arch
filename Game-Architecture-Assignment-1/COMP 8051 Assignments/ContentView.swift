//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab01: Draw red square using SceneKit
// Lab02: Make an auto-rotating cube with different colours on each side
// Lab03: Make a rotating cube with a crate texture that can be toggled
// Lab04: Make a cube that can be rotated with gestures
// Lab05: Add text that shows rotation angle of rotating cube
// Lab06: Add diffuse light
// Lab07: Add flashlight
// Lab08: Add fog
//
// Modified by Jun Earl Solomon to fit assignment 1 requirements
//
//====================================================================

import SwiftUI
import SceneKit
import SpriteKit
import UIKit

///
///source:
/// https://www.hackingwithswift.com/quick-start/swiftui/customizing-button-with-buttonstyle
///
struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Helvetica", size: 15))
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ContentView: View {
    @State var rotationOffset = CGSize.zero

    var body: some View {
        NavigationStack {
            List {
                NavigationLink{
                    let scene = Assignment1Crate()
                    ZStack {
                        SceneView(scene: scene, pointOfView: scene.cameraNode)
                            .ignoresSafeArea()
                        ZoomAndPanAndRotationView(mainScene: scene)
                            .ignoresSafeArea()
                        VStack {
                            Spacer()
                            HStack {
                                Button("Reset Cube ") {
                                    scene.resetCubePos()
                                }
                                .buttonStyle(GrowingButton())
                                Button("Toggle Ambient Light") {
                                    scene.toggleAmbientLight()
                                }
                                .buttonStyle(GrowingButton())
                            }	
                            HStack {
                                Button("Toggle Flashight") {
                                    scene.toggleFlashlight()
                                }
                                .buttonStyle(GrowingButton())
                                Button("Toggle Diffuse Light") {
                                    scene.toggleDiffuseLight()
                                }
                                .buttonStyle(GrowingButton())
                            }
                        }

                    }
                } label: { Text("Assignment 1") }
            }.navigationTitle("COMP 8051")
        }
    }
}

#Preview {
    ContentView()
}
