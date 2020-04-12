//
//  ViewController.swift
//  ARRuler
//
//  Created by Fred Lefevre on 2020-04-12.
//  Copyright © 2020 Fred Lefevre. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var markerNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: sceneView) else { return }
        guard let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint).first else { return }
        addMarker(at: hitTestResult)
    }
    
    func addMarker(at hitResult: ARHitTestResult) {
        let cylinder = SCNCylinder(radius: 0.005, height: 0.02)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        cylinder.materials = [material]
        
        let markerNode = SCNNode(geometry: cylinder)
        let location = hitResult.worldTransform.columns.3
        markerNode.position = SCNVector3(location.x, location.y, location.z)
        sceneView.scene.rootNode.addChildNode(markerNode)
        markerNodes.append(markerNode)
        
        if markerNodes.count > 2 {
            markerNodes.first?.removeFromParentNode()
            markerNodes.remove(at: 0)
            calculate()
        } else if markerNodes.count == 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = markerNodes[0]
        let end = markerNodes[1]
        
        let startPosition = SCNVector3ToGLKVector3(start.worldPosition)
        let endPosition = SCNVector3ToGLKVector3(end.worldPosition)
        
        let distance = GLKVector3Distance(startPosition, endPosition)
        let sum = GLKVector3Add(startPosition, endPosition)
        let midpoint = SCNVector3(sum.x / 2, sum.y / 2, sum.z / 2)
        
        addText(text: metersToInches(meters: distance), location: midpoint)
    }
    
    func addText(text: String, location: SCNVector3) {
        let text = SCNText(string: text, extrusionDepth: 0.1)
        text.font = UIFont(name: "futura", size: 16)
        text.flatness = 0
        let scaleFactor = 0.05 / text.font.pointSize
        
        let constraint = SCNBillboardConstraint()
        textNode.constraints = [constraint]
        
        textNode.geometry = text
        textNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        
        let (min, max) = textNode.boundingBox
        let offset = (max.x - min.x) / 2 * Float(scaleFactor)
        let textPosition = SCNVector3(location.x - offset, location.y + 0.05, location.z)
        
        textNode.position = textPosition
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func metersToInches(meters: Float) -> String {
        let measurement = Measurement(value: Double(meters), unit: UnitLength.meters)
        let inches = measurement.converted(to: .inches)
        
        let inchString = String(format: "%.2f", inches.value)
        return inchString
    }
}
