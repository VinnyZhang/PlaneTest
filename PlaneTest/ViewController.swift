//
//  ViewController.swift
//  PlaneTest
//
//  Created by Zhang xiaosong on 2018/4/19.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

struct CollisionCategory {
    let rawValue:Int
    
    static let bottom = CollisionCategory(rawValue: 1 << 0)
    static let cube = CollisionCategory(rawValue: 1 << 1)
}

class ViewController: UIViewController,ARSCNViewDelegate {
    
    var scnView = ARSCNView()//AR视图
    var sessionConfig: ARConfiguration? //会话配置
    var maskView = UIView() // 遮罩视图
    var tipLabel = UILabel()//提示标签
    var infoLabel = UILabel() //信息展示标签
    
    var boxNode: SCNNode!
    
    
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutMySubItems()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {//判断是否支持6个自由度
            let worldTracking = ARWorldTrackingConfiguration()//6DOF【3个旋转轴 3个平移轴】
            worldTracking.planeDetection = .horizontal
            worldTracking.isLightEstimationEnabled = true
            sessionConfig = worldTracking
        }
        else {
            let orientationTracking = AROrientationTrackingConfiguration()//3DOF 【3个旋转轴】
            sessionConfig = orientationTracking
            tipLabel.text = "当前设备不支持6DOF跟踪"
        }
        scnView.session.run(sessionConfig!)
        
        
        //      添加3D立方体
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        let material = SCNMaterial()
        let img = UIImage(named: "gc.png")
        material.diffuse.contents = img
        //        boxGeometry.materials
        material.lightingModel = .physicallyBased
        boxGeometry.materials = [material]
        
        
        boxNode = SCNNode(geometry: boxGeometry)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scnView.session.pause()
    }
    
    
    //MARK: - 布局
    
    func layoutMySubItems()
    {
        scnView.frame = self.view.frame
        self.view.addSubview(scnView)
        scnView.delegate = self
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        
        maskView.frame = self.view.frame
        maskView.backgroundColor = UIColor.white
        maskView.alpha = 0.6
        self.view.addSubview(maskView)
        
        self.view.addSubview(tipLabel)
        tipLabel.frame = CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 50)
        tipLabel.textColor = UIColor.black
        tipLabel.numberOfLines = 0
        
        self.view.addSubview(infoLabel)
        infoLabel.frame = CGRect(x: 0, y: tipLabel.frame.origin.y + tipLabel.frame.size.height + 5, width: self.view.frame.size.width, height: 150)
        infoLabel.numberOfLines = 0
        infoLabel.textColor = UIColor.black
        
    }
//    从世界坐标系中的一个位姿中提取位置
    func positionWithWorldTrasform(worldTransfor:matrix_float4x4) -> SCNVector3{
        let vector = SCNVector3Make(worldTransfor.columns.3.x, worldTransfor.columns.3.y, worldTransfor.columns.3.z)
        return vector
    }
    
    //MARK: - ARSCNViewDelegate
    
    //相机状态变化
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        //判断状态
        switch camera.trackingState{
        case .notAvailable:
            tipLabel.text = "跟踪不可用"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.7
            }
        case .limited(ARCamera.TrackingState.Reason.initializing):
            let title = "有限的跟踪，原因是："
            let desc = "正在初始化，请稍后"
            tipLabel.text = title + desc
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .limited(ARCamera.TrackingState.Reason.relocalizing):
            tipLabel.text = "有限的跟踪，原因是：重新初始化"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .limited(ARCamera.TrackingState.Reason.excessiveMotion):
            tipLabel.text = "有限的跟踪，原因是：设备移动过快请注意"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .limited(ARCamera.TrackingState.Reason.insufficientFeatures):
            tipLabel.text = "有限的跟踪，原因是：提取不到足够的特征点，请移动设备"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .normal:
            tipLabel.text = "跟踪正常"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.0
            }
            //        default:
            //            print("cameraDidChange unknow")
            //        }
        }
    }
    
    //会话被中断
    func sessionWasInterrupted()
    {
        
        tipLabel.text = "会话中断"
    }
    
    //会话中断结束
    func sessionInterruptionEnded(_ session: ARSession) {
        tipLabel.text = "会话中断结束，已重置会话"
        scnView.session.run(self.sessionConfig!, options: .resetTracking)
    }
    
    //会话失败
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error.localizedDescription)
        tipLabel.text  = error.localizedDescription
    }
    
    /**
     实现此方法来为给定 anchor 提供自定义 node。
     
     @discussion 此 node 会被自动添加到 scene graph 中。
     如果没有实现此方法，则会自动创建 node。
     如果返回 nil，则会忽略此 anchor。
     @param renderer 将会用于渲染 scene 的 renderer。
     @param anchor 新添加的 anchor。
     @return 将会映射到 anchor 的 node 或 nil。
     */
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return nil
        }

        let node = PlaneNode(withAnchor: anchor)


        DispatchQueue.main.async(execute: {
            self.tipLabel.text = "检测到平面并已添加到场景中，点击屏幕可刷新会话"
        })
        
        return node
        
    }
    
    /**
     将新 node 映射到给定 anchor 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 映射到 anchor 的 node。
     @param anchor 新添加的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        guard let node = node as? PlaneNode else {
            return
        }
        node.update(anchor: anchor)
        DispatchQueue.main.async(execute: {

            if self.boxNode.parent == nil {
                self.boxNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
                node.addChildNode(self.boxNode)
            }
            
            
        })
        
    }
    
    /**
     将要用给定 anchor 的数据来更新时 node 调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 即将更新的 node。
     @param anchor 被更新的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        guard let node = node as? PlaneNode else {
            return
        }
        node.update(anchor: anchor)
        DispatchQueue.main.async(execute: {
            self.tipLabel.text = "场景内有平面更新"
            self.tipLabel.text = "\(anchor.center.x) , \(anchor.center.y) ,\(anchor.center.z)"
        })
        
    }
    
    /**
     使用给定 anchor 的数据更新 node 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 更新后的 node。
     @param anchor 更新后的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    /**
     从 scene graph 中移除与给定 anchor 映射的 node 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 被移除的 node。
     @param anchor 被移除的 anchor。
     */
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        guard let node = node as? PlaneNode else {
            return
        }
        node.removePlaneNode(WithAnchor: anchor)
        
        DispatchQueue.main.async(execute: {
            self.tipLabel.text = "场景内有平面被删除"
        })
        
    }
    
    //MARK: - 触控
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //当用户点击屏幕时，取出会话输出的帧
        var transform = self.scnView.session.currentFrame!.camera.transform
        
        var infoStr = String()
        for index in 0..<4 {
            if index == 0 {
                infoStr.append("\(transform.columns.0.x) , \(transform.columns.0.y) , \(transform.columns.0.z) , \(transform.columns.0.w)")
            }
            else if index == 1 {
                infoStr.append("\n \(transform.columns.1.x) , \(transform.columns.1.y) , \(transform.columns.1.z) , \(transform.columns.1.w)")
            }
            else if index == 2 {
                infoStr.append("\n \(transform.columns.2.x) , \(transform.columns.2.y) , \(transform.columns.2.z) , \(transform.columns.2.w)")
            }
            else if index == 3 {
                infoStr.append("\n \(transform.columns.3.x) , \(transform.columns.3.y) , \(transform.columns.3.z) , \(transform.columns.3.w)")
            }
        }
        
        infoLabel.text = infoStr
        
//        scnView.session.run(self.sessionConfig!, options: .removeExistingAnchors)
        
        let touch = touches.first
        if let point = touch?.location(in: self.scnView) {

            if let result = self.scnView.hitTest(point, types: .existingPlaneUsingExtent).first {
                print("目标距离%f米",result.distance)
                
                let vector = positionWithWorldTrasform(worldTransfor: result.worldTransform)
                
                let boxGeometry = SCNBox(width: 0.15, height: 0.15, length: 0.15, chamferRadius: 0.0)
                let material = SCNMaterial()
                let img = UIImage(named: "gc.png")
                material.diffuse.contents = img
                material.lightingModel = .physicallyBased
                boxGeometry.materials = [material]
                
                let boxNode = SCNNode(geometry: boxGeometry)
                
                // physicsBody 会让 SceneKit 用物理引擎控制该几何体
//                boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//                boxNode.physicsBody?.mass = 2
//                boxNode.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
                
                
                boxNode.position = vector
                
                scnView.scene.rootNode.addChildNode(boxNode)
                
            }
            else{
                print("未命中目标")
            }
            
            
        }
    
        
    }
    
    
    
}
