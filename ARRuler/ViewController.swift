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
        print(distance)
    }
}
