//
//  CustomARView.swift
//  InteractivityInRealityKit
//
//  Created by Mark Horgan on 26/05/2022.
//

import RealityKit
import ARKit

class CustomARView: ARView, ARSessionDelegate {
    private var showARPlanes = true
    private let arPlaneMaterial = SimpleMaterial(color: .init(white: 1.0, alpha: 0.5), isMetallic: false)
    private var anchorEntitiesByAnchor: [ARAnchor: AnchorEntity] = [:]
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.delegate = self
        session.run(config, options: [])
        
        addCoaching()
    }
    
    @objc required dynamic init?(coder decorder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard showARPlanes else { return }
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let anchorEntity = AnchorEntity(anchor: planeAnchor)
                let planeEntity = buildPlaneEntity(planeAnchor: planeAnchor)
                anchorEntity.addChild(planeEntity)
                scene.addAnchor(anchorEntity)
                anchorEntitiesByAnchor[planeAnchor] = anchorEntity
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard showARPlanes else { return }
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, let anchorEntity = anchorEntitiesByAnchor[planeAnchor] {
                anchorEntity.children.remove(at: 0)
                anchorEntity.addChild(buildPlaneEntity(planeAnchor: planeAnchor))
            }
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard showARPlanes else { return }
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, let anchorEntity = anchorEntitiesByAnchor[planeAnchor] {
                scene.removeAnchor(anchorEntity)
                anchorEntitiesByAnchor.removeValue(forKey: planeAnchor)
            }
        }
    }
    
    private func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
    
    private func buildPlaneEntity(planeAnchor: ARPlaneAnchor) -> ModelEntity {
        let geometry = planeAnchor.geometry
        var descriptor = MeshDescriptor(name: "ARPlaneVisualized")
        descriptor.positions = MeshBuffer(geometry.vertices)
        descriptor.primitives = .triangles(geometry.triangleIndices.map { UInt32($0) })
        descriptor.textureCoordinates = MeshBuffer(geometry.textureCoordinates)
        return ModelEntity(mesh: try! .generate(from: [descriptor]), materials: [arPlaneMaterial])
    }
}
