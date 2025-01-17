//
//  GameScene.swift
//  BaseController Shared
//
//  Created by Pedro Cacique.
//  Contributor Joaquim Pessoa Filho
//

import SpriteKit
import GameController

class GameScene: SKScene, JoystickDelegate {

    var animal = SKSpriteNode(imageNamed: "parrot")
    let initialPosition = CGPoint(x: 100, y: 100)
    let multiplier: CGFloat = 4000
    let joystickController: JoystickController = JoystickController()
    var lastActionTime: TimeInterval = TimeInterval.zero
    let whaitForNextAction: Double = 1
    
    class func newGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }
    
    func setUpScene() {
        joystickController.delegate = self
        joystickController.observeForGameControllers()
        physicsWorld.gravity = .zero
        
        createAnimal()
    }
    
    func createAnimal() {
        let animalName = ["parrot", "bear", "buffalo", "chick"]
                let index = Int.random(in: 0..<animalName.count)
                
                animal.removeFromParent()
                animal = SKSpriteNode(imageNamed: animalName[index])
                animal.position = initialPosition
                
                let physicsBody = SKPhysicsBody(circleOfRadius: 100)
                physicsBody.mass = 1
                
                animal.physicsBody = physicsBody
                
                self.addChild(animal)
    }
    
    func moveAnimal(dx: CGFloat, dy: CGFloat) {
        var xValue = dx * multiplier
        var yValue = dy * multiplier
        let resultSpeed = sqrt(pow(animal.physicsBody!.velocity.dx, 2) + pow(animal.physicsBody!.velocity.dy, 2))
//        if xValue > self.size.width {
//            xValue = 0
//        }
//        if xValue < 0 {
//            xValue = self.size.width
//        }
//        if yValue > self.size.height {
//            yValue = 0
//        }
//        if yValue < 0 {
//            yValue = self.size.height
//        }
//
        //animal.position = CGPoint(x: xValue, y: yValue)
        if resultSpeed < 400 {
            animal.physicsBody?.applyForce(CGVector(dx: xValue, dy: yValue))
        }
    }
    
    func applyDragAnimal() {
        animal.physicsBody?.applyForce(CGVector(dx: animal.physicsBody!.velocity.dx * -6, dy: animal.physicsBody!.velocity.dy * -6))
       
    }
    
    func resetAnimal() {
        animal.position = initialPosition
        createAnimal()
    }
    
    override func update(_ currentTime: TimeInterval) {
        joystickController.update(currentTime)
        applyDragAnimal()
        print(animal.physicsBody?.velocity)
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif
    
    //MARK :- iOS and tvOS
#if os(iOS) || os(tvOS)
// Touch-based event handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
#endif
    
#if os(OSX)
// Mouse-based event handling
    override func mouseDown(with event: NSEvent) {}
    override func mouseDragged(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {}
    
    // evita o beep quando aperta uma tecla normalmente
    override func keyDown(with event: NSEvent) { }
    override func keyUp(with event: NSEvent) { }
#endif
    
    //MARK:- JoystickDelegate
    func controllerDidConnect(controller: GCController) {
        print("Controller connected")
    }
    
    func controllerDidDisconnect() {
        print("Controller disconnected")
    }
    
    func keyboardDidConnect(keyboard: GCKeyboard) {
        print("Keyboard connected")
    }
    
    func keyboardDidDisconnect(keyboard: GCKeyboard) {
        print("Keyboard disconnected")
    }
    
    func buttonPressed(command: GameCommand) {
        print("pressed: \(command)")
        var dx:CGFloat = 0
        var dy:CGFloat = 0
        
        switch command {
        case .UP:
            dy = 1
        case .DOWN:
            dy = -1
        case .RIGHT:
            dx = 1
        case .LEFT:
            dx = -1
        case .ACTION:
            resetAnimal()
            return
        }
        
        self.moveAnimal(dx: dx, dy: dy)
    }
    
    func buttonReleased(command: GameCommand) {
        print("released: \(command)")
    }
    
    func joystickUpdate(_ currentTime: TimeInterval){
        if let gamePadLeft = joystickController.gamePadLeft {
            let dx: CGFloat = CGFloat(gamePadLeft.xAxis.value)
            let dy: CGFloat = CGFloat(gamePadLeft.yAxis.value)
            if gamePadLeft.xAxis.value != 0 || gamePadLeft.xAxis.value != 0{
                
                //print("dpad: \(dx), \(dy)")
                moveAnimal(dx: dx, dy: dy)
            }
        }
        
        if let buttonX = joystickController.buttonX {
            if buttonX.isPressed{
                // print("X Button: \(buttonX.isPressed)")
                if(lastActionTime + whaitForNextAction < currentTime) {
                    resetAnimal()
                    lastActionTime = currentTime
                }
            }
        }
    }
}
