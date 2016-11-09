//
//  ViewController.swift
//  BookaaPool
//

import UIKit

class ViewController: UIViewController {
 
    @IBOutlet var posS: UISlider!
    @IBOutlet var m_Angle: UITextField!
    @IBOutlet var m_Position: UITextField!
    @IBOutlet var m_text: UITextField!
    @IBOutlet var m_deviation: UITextField!
    @IBOutlet var m_button: UIButton!
    
    var last: ShapeView?
    var standard_shape: ShapeView?
    var standard_shape_small: ShapeView?
    var refer_shape_small: ShapeView?
    var shape_white : ShapeView?
    var shape_red : ShapeView?
    var shape_black : ShapeView?
    var shape_line1 : UIView?
    var shape_line2 : UIView?
    var lastpos : Float = 0.5
    var scale : Float = 0.5
    var hint = 0
    var showed_hint = false

    @IBAction func onHint(_ sender: UIButton) {
        if !self.showed_hint {
            self.refer_shape_small?.center = CGPoint(x: radius_little, y: radius_little)
            self.show_hints()
            return
        }
        self.hint += 1
        if self.hint == 5 {
            self.hint = 0
        }
        self.show_hints()
    }
    func show_hints() {
        let pos1 = self.shape_white!.center
        let pos2 = self.shape_red!.center
        let pos3 = self.shape_black!.center
        let pos : CGPoint
        let rate : CGFloat
        let angle : CGFloat
        (pos, rate, angle) = TryPointPool(pos1, pos2:pos2, pos3:pos3)
        self.show_hints_with_pos(pos: pos)
    }
    func show_hints_with_pos(pos : CGPoint) {
        self.hide_hint()
        if self.hint == 1 {
            self.hint1(pos: pos)
        }
        else if self.hint == 2 {
            self.hint1(pos: pos)
            self.hint2(pos: pos)
        }
        else if self.hint == 3 {
            self.hint1(pos: pos)
            self.hint3(pos: pos)
        }
        else if self.hint == 4 {
            self.hint1(pos: pos)
            self.hint4(pos: pos)
        }
        self.showed_hint = true
    }
    func hide_hint() {
        self.showed_hint = false
        self.shape_line1?.isHidden = true
        self.shape_line2?.isHidden = true
        self.standard_shape?.isHidden = true
        self.standard_shape_small?.isHidden = true
        self.refer_shape_small?.isHidden = true
        m_Angle.isHidden = true
        m_Position.isHidden = true
        m_deviation.isHidden = true
    }
    @IBAction func onReplay(_ sender: UIButton) {
        self.hide_hint()
        self.ReArrange()
    }
    func ReArrange() {
        var point1 : CGPoint?
        var point2 : CGPoint?
        var point3 : CGPoint?
        let minX = self.view.bounds.minX
        let midX = self.view.bounds.midX
        let maxX = self.view.bounds.maxX
        let minY = self.view.bounds.minY
        let midY = self.view.bounds.midY
        let maxY = self.view.bounds.maxY
        //let centerX = self.view.center.x
        //let centerY = self.view.center.y
        //print("minX \(minX) midX \(midX) maxX \(maxX) minY \(minY) midY \(midY) maxY \(maxY)")
        //print("centerX \(centerX) centerY \(centerY)")
        //minX 0.0 midX 384.0 maxX 768.0 minY 0.0 midY 512.0 maxY 1024.0
        //centerX 384.0 centerY 512.0
        if true {
            let fact1 = CGFloat(arc4random() % 256) / 256.0
            let fact2 = CGFloat(arc4random() % 256) / 256.0
            let x = minX + maxX * fact1
            let y = minY + maxY * fact2
            point1 = CGPoint(x:x,y:y)
        }
        if true { // 相反的方向
            let fact1 = CGFloat(arc4random() % 256) / 256.0
            let fact2 = CGFloat(arc4random() % 256) / 256.0
            var x : CGFloat
            if point1!.x > midX {
                x = minX + midX * fact1
            } else {
                x = midX + midX * fact1
            }
            var y : CGFloat
            if point1!.y > midY {
                y = minY + midY * fact2
            } else {
                y = midY + midY * fact2
            }
            point3 = CGPoint(x:x,y:y)
        }
        if true {
            let a1 = arc4random() % 31
            let angle1 = Int32(a1) - 15 // it is -15 ... 0 ... 15
            let angle = angle1 * 5 // it is -75 ... 0 ... 75
            point2 = getredposition_withangle(point1!, posBlack: point3!, angle : CGFloat(angle))
            if point2 == CGPoint(x: 0, y: 0) {
                ReArrange()
                return
            }
        }
        self.shape_white?.center = point1!
        self.shape_red?.center = point2!
        self.shape_black?.center = point3!
    }
    
    @IBAction func onButton(_ sender: UIButton) {
        //print("button down")
        if !m_Angle.isHidden {
            self.hide_hint()
            return
        }
        
        let pos1 = self.shape_white!.center
        let pos2 = self.shape_red!.center
        let pos3 = self.shape_black!.center
        let pos : CGPoint
        let rate : CGFloat
        let angle : CGFloat
        (pos, rate, angle) = TryPointPool(pos1, pos2:pos2, pos3:pos3)
        // pos from -2.0 to 2.0, if error then 5.0

        self.show_hints_with_pos(pos: pos)
        
        self.standard_shape?.center.x = self.view.center.x + radius_big * rate
        self.standard_shape?.center.y = 80
        self.standard_shape?.isHidden = false
        
        let rate2 = (self.last!.center.x - self.view.center.x) / radius_big
        let rate3 = Int((rate2 - rate) * 1000.0)
        let s_rate = NSString(format: "%.3f", rate)
        let s_angle = NSString(format: "%.1f", angle)
        //m_text?.text = "\(rate3) rate \(s_rate) angle \(s_angle)"
        
        m_Angle.isHidden = false
        m_Position.isHidden = false
        m_Angle.text = "\(s_angle)°"
        m_Position.text = "\(s_rate)"
        if rate2 > 2.0 || rate2 < -2.0 {
            m_deviation.isHidden = true
        } else {
            m_deviation.isHidden = false
            if rate3 > 500 || rate3 < -500 {
                m_deviation.text = "太偏"
            } else {
                m_deviation.text = "偏\(rate3)"
            }
        }
        
    }
    func hint1(pos : CGPoint) {
        self.standard_shape_small?.center = pos
        self.standard_shape_small?.isHidden = false
        self.refer_shape_small?.isHidden = false
    }
    func hint2(pos : CGPoint) {
        if self.shape_line1 != nil {
            self.shape_line1!.removeFromSuperview()
            self.shape_line1 = nil
        }
        let pos1 = self.shape_white!.center
        let pos2 = self.shape_red!.center
        let pos3 = self.shape_black!.center
        if true {
            let p5 = extend_line(p2: pos1, p1: pos)
            let p6 = extend_line(p2: pos3, p1: pos2)
            let blueSquare = View_lines(p1: pos1,p2: p5,p3: pos3,p4: p6)
            
            view.addSubview(blueSquare)
            self.shape_line1 = blueSquare
        }
    }
    func hint3(pos : CGPoint) {
        if self.shape_line1 != nil {
            self.shape_line1!.removeFromSuperview()
            self.shape_line1 = nil
        }
        if self.shape_line2 != nil {
            self.shape_line2!.removeFromSuperview()
            self.shape_line2 = nil
        }
        let pos1 = self.shape_white!.center
        let pos2 = self.shape_red!.center
        let pos3 = self.shape_black!.center
        let p5 = get_vertical_pnt(p1: pos3, p2: pos2, p3: pos1)
        let p6 = get_vertical_pnt(p1: pos1, p2: pos, p3: pos3)
        if true {
            let blueSquare = View_lines(p1: pos1,p2: p6,p3: pos3,p4: p5)
            
            view.addSubview(blueSquare)
            self.shape_line1 = blueSquare
        }
        if true {
            let blueSquare = View_lines(p1: pos1,p2: p5,p3: pos3,p4: p6)
            
            view.addSubview(blueSquare)
            self.shape_line2 = blueSquare
        }
    }
    func extend_line(p2 : CGPoint, p1: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x + p1.x - p2.x, y: p1.y + p1.y - p2.y)
    }
    func hint4(pos : CGPoint) {
        if self.shape_line1 != nil {
            self.shape_line1!.removeFromSuperview()
            self.shape_line1 = nil
        }
        if self.shape_line2 != nil {
            self.shape_line2!.removeFromSuperview()
            self.shape_line2 = nil
        }
        let pos1 = self.shape_white!.center
        let pos2 = self.shape_red!.center
        let pos3 = self.shape_black!.center
        if true {
            let p1,p2,p3,p4 : CGPoint
            (p1,p2,p3,p4) = getEnclosedTwoBall(pos2,pos2:pos3,r:radius_little)
            let p5 = extend_line(p2: p4, p1: p1)
            let p6 = extend_line(p2: p3, p1: p2)
            let blueSquare = View_back(p1: p5,p2: p6,p3: p3,p4: p4)
            
            view.addSubview(blueSquare)
            self.shape_line1 = blueSquare
        }
        if true {
            let p1,p2,p3,p4 : CGPoint
            (p1,p2,p3,p4) = getEnclosedTwoBall(pos,pos2:pos1,r:radius_little)

            let p5 = extend_line(p2: p4, p1: p1)
            let p6 = extend_line(p2: p3, p1: p2)

            let blueSquare = View_back(p1: p5,p2: p6,p3: p3,p4: p4)
            
            view.addSubview(blueSquare)
            self.shape_line2 = blueSquare
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_text.isHidden = true
        var point0 = CGPoint(x:self.view.center.x, y:80)
        let view00 = ShapeView(origin: point0, flg : 0)
        self.view.addSubview(view00)

        self.standard_shape = ShapeView(origin: CGPoint(x: 900, y: 900), flg : 0)
        self.view.addSubview(self.standard_shape!)
        self.standard_shape_small = ShapeView(origin: CGPoint(x: 900, y: 900), size : radius_little,
                                              col : UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        self.view.addSubview(self.standard_shape_small!)
        
        if true {
            self.refer_shape_small = ShapeView(origin: CGPoint(x: radius_little, y: radius_little), size : radius_little,
                                                  col : UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0))
            self.view.addSubview(self.refer_shape_small!)
            self.refer_shape_small?.isHidden = true
        }
        
        point0.x += 70
        let shapeView = ShapeView(origin: point0, flg : 2)
        
        self.last = shapeView
        
        self.view.addSubview(shapeView)

        var point1 : CGPoint?
        var point2 : CGPoint?
        if true {
            point2 = self.view.center
            
            let col = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            let shapeView = ShapeView(origin: point2!, size: radius_little, col: col)
            
            self.shape_red = shapeView
            
            self.view.addSubview(shapeView)
            
        }
        if true {
            point1 = self.view.center
            
            let col = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            let shapeView = ShapeView(origin: point1!, size: radius_little, col: col)
            
            self.shape_white = shapeView
            
            self.view.addSubview(shapeView)
            
        }
        if true {
            let point3 = self.view.center
            
            let col = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            let shapeView = ShapeView(origin: point3, size: radius_little, col: col)
            
            self.shape_black = shapeView
            
            self.view.addSubview(shapeView)
        }
        self.hide_hint()
        self.ReArrange()
    }
    
    @IBAction func onScale(_ sender: UISlider) {
        self.scale = sender.value
        posS.value = 0.5
        self.lastpos = 0.5
    }
    @IBAction func onTouchDown(_ sender: UISlider) {
        //print("onTouchDown")
        self.lastpos = sender.value
    }
    @IBAction func ChangeX(_ sender: UISlider) {
        //print("ValueChanged")
        let x = sender.value - self.lastpos
        self.lastpos = sender.value
        //last?.center.x.advancedBy(CGFloat((x-0.5)*200))
        last?.center.x += CGFloat(x*self.scale*400)
        //print("x \(x) \(last?.center.x)")
    }

}

