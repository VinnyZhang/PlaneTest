//
//  PlaneNode.swift
//  PlaneTest
//
//  Created by Zhang xiaosong on 2018/4/19.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class PlaneNode: SCNNode {
    
    var planeGeometry: SCNPlane!
    var anchor: ARPlaneAnchor!
    
    init(withAnchor anchor:ARPlaneAnchor) {
        super.init()
        self.anchor = anchor
        
//        创建平面
        planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
//        创建材质并用于平面
        let material = SCNMaterial()
//        let image = UIImage(named: "plane.png")
        material.diffuse.contents = UIColor.clear
        planeGeometry.materials = [material]
        
//        创建节点并作为当前节点的子节点
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        // SceneKit 里的平面默认是垂直的，所以需要旋转90度来匹配 ARKit 中的平面
        planeNode.transform = SCNMatrix4MakeRotation(-.pi/2.0, 1.0, 0.0, 0.0)
        
        setTextureScale()
        addChildNode(planeNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update(anchor: ARPlaneAnchor) {
        // 随着用户移动，平面 plane 的 范围 extend 和 位置 location 可能会更新。
        // 需要更新 3D 几何体来匹配 plane 的新参数。
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        
        // plane 刚创建时中心点 center 为 0,0,0，node transform 包含了变换参数。
        // plane 更新后变换没变 但 center 更新了，所以需要更新 3D 几何体的位置
        position  = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        setTextureScale()
        
    }
    
    func removePlaneNode(WithAnchor anchor:ARPlaneAnchor) {
        removeFromParentNode()
    }
    
    func setTextureScale() {
        let width = planeGeometry.width
        let height = planeGeometry.height
        
        // 平面的宽度/高度 width/height 更新时，我希望 tron grid material 覆盖整个平面，不断重复纹理。
        // 但如果网格小于 1 个单位，我不希望纹理挤在一起，所以这种情况下通过缩放更新纹理坐标并裁剪纹理
        
        let material = planeGeometry.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
        
    }
    
    
}
