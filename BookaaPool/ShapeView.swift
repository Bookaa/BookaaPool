//
//  ShapeView.swift

import UIKit

class View_lines: UIView {
    let lineWidth: CGFloat = 1
    //var fillColor: UIColor!
    var path: UIBezierPath!
    
    init(p1:CGPoint, p2:CGPoint, p3:CGPoint, p4:CGPoint) {
        super.init(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
        self.isUserInteractionEnabled = false
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: p1.x, y: p1.y))
        path.addLine(to: CGPoint(x: p2.x, y: p2.y))
        //path.addLine(to: CGPoint(x: p3.x, y: p3.y))
        //path.addLine(to: CGPoint(x: p4.x, y: p4.y))
        path.close()
        
        self.path = path
        if true {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: p3.x, y: p3.y))
            path.addLine(to: CGPoint(x: p4.x, y: p4.y))
            path.close()
            self.path.append(path)
        }
        
        self.backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        self.path.lineWidth = self.lineWidth
        
        self.path.stroke()
    }
}

class View_back: UIView {
    let lineWidth: CGFloat = 1
    var path: UIBezierPath!
    
    init(p1:CGPoint, p2:CGPoint, p3:CGPoint, p4:CGPoint) {
        super.init(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
        self.isUserInteractionEnabled = false
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: p1.x, y: p1.y))
        path.addLine(to: CGPoint(x: p2.x, y: p2.y))
        path.addLine(to: CGPoint(x: p3.x, y: p3.y))
        path.addLine(to: CGPoint(x: p4.x, y: p4.y))
        path.close()
        
        self.path = path
        
        self.backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        self.path.lineWidth = self.lineWidth
        self.path.stroke()
    }
}

class ShapeView: UIView {
    
    var size: CGFloat = 150
    let lineWidth: CGFloat = 1
    var fillColor: UIColor!
    var path: UIBezierPath!
    var flg : Int = 3
    
    func randomColor() -> UIColor {
        let hue:CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.8)
    }
    
    func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }
    
    func regularPolygonInRect(_ rect:CGRect) -> UIBezierPath {
        let degree = arc4random() % 10 + 3
        
        let path = UIBezierPath()
        
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        
        var angle:CGFloat = -CGFloat(M_PI / 2.0)
        let angleIncrement = CGFloat(M_PI * 2.0 / Double(degree))
        let radius = rect.width / 2.0
        
        path.move(to: pointFrom(angle, radius: radius, offset: center))
        
        for i in 1...degree - 1 {
            angle += angleIncrement
            path.addLine(to: pointFrom(angle, radius: radius, offset: center))
        }
        
        path.close()
        
        return path
    }
    
    func trianglePathInRect(_ rect:CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.width / 2.0, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.width,y: rect.height))
        path.addLine(to: CGPoint(x: rect.origin.x,y: rect.height))
        path.close()
        
        
        return path
    }
    
    func randomPath() -> UIBezierPath {
        
        let insetRect = self.bounds.insetBy(dx: lineWidth,dy: lineWidth)
        
        
        let shapeType = 1 // arc4random() % 4
        // print("shape \(shapeType)")
        // 0 is a box with corner
        if shapeType == 0 {
            return UIBezierPath(roundedRect: insetRect, cornerRadius: 10.0)
        }
        
        if shapeType == 1 {
            return UIBezierPath(ovalIn: insetRect)
        }
        
        if (shapeType == 2) {
            return trianglePathInRect(insetRect)
        }
        // 3 is box rotate 90 degree
        return regularPolygonInRect(insetRect)
    }
    
    init(origin: CGPoint, flg : Int) {
        // this is large ball
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        
        self.fillColor = randomColor()
        let insetRect = self.bounds.insetBy(dx: lineWidth,dy: lineWidth)
        self.path = UIBezierPath(ovalIn: insetRect)

        let rect2 = self.bounds.insetBy(dx: self.bounds.width/2-2,dy: self.bounds.height/2-2)
        let path2 = UIBezierPath(ovalIn: rect2)
        self.path.append(path2)
        
        self.center = origin
        
        self.backgroundColor = UIColor.clear
        self.flg = flg
        
        if flg != 0 {
            initGestureRecognizers()
        }
    }
    init(origin: CGPoint, size : CGFloat, col : UIColor) {
        // this is small bal
        let size2 = size * 2.0
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: size2, height: size2))
        self.size = size2
        self.fillColor = col

        let insetRect = self.bounds.insetBy(dx: lineWidth,dy: lineWidth)

        self.path = UIBezierPath(ovalIn: insetRect)
        
        self.center = origin
        
        self.backgroundColor = UIColor.clear
        
        initGestureRecognizers()
    }
    
    func initGestureRecognizers() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(ShapeView.didPan(_:)))
        addGestureRecognizer(panGR)
    }
    
    func didPan(_ panGR: UIPanGestureRecognizer) {
        
        self.superview!.bringSubview(toFront: self)
        
        var translation = panGR.translation(in: self)
        
        translation = translation.applying(self.transform)
        
        self.center.x += translation.x
        if self.flg == 3 {
            self.center.y += translation.y
        }
        
        panGR.setTranslation(CGPoint.zero, in: self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        self.fillColor.setFill()
        
        self.path.fill()

        self.path.lineWidth = self.lineWidth
        
        self.path.stroke()
    }

}
