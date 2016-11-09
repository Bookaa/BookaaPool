//
//  poolmath.swift
//  ShapesTutorial
//
//  Created by xiaoka on 8/23/16.
//  Copyright © 2016 WeHeartSwift. All rights reserved.
//

import Foundation
import UIKit

let radius_big : CGFloat = 150.0/2.0
let radius_little : CGFloat = 50.0/2.0

func get_vertical_pnt(p1 : CGPoint, p2 : CGPoint, p3: CGPoint) -> CGPoint
{
    // 从P3向直线p1p2作垂线，返回垂足
    
    // make p1 as origin point
    let p2x = p2.x - p1.x
    let p2y = p2.y - p1.y
    let p3x = p3.x - p1.x
    let p3y = p3.y - p1.y
    
    let dist2 = p2x*p2x+p2y*p2y
    let dist = sqrt(dist2)
    // rotate p2 to x axis
    let cos1 = p2x / dist
    let sin1 = p2y / dist
    // rotate p3 negative angle 1
    let newp3x = cos1 * p3x + sin1 * p3y
    //let newp3y = cos1 * p3y - sin1 * p3x
    // new p3x is what we need, now rotate it
    let p4x = cos1 * newp3x
    let p4y = sin1 * newp3x
    return CGPoint(x: p1.x + p4x, y: p1.y + p4y)
}

func getredposition_withangle(_ posWhite: CGPoint, posBlack : CGPoint, angle : CGFloat) -> CGPoint
{
    if angle == 0.0 {
        let fact1 = CGFloat((arc4random() % 15) + 3) / 20.0 // try middle part

        let x = posWhite.x + (posBlack.x - posWhite.x) * fact1
        let y = posWhite.y + (posBlack.y - posWhite.y) * fact1
        
        return CGPoint(x: x, y: y)
    }
    let x3 = posBlack.x - posWhite.x
    let y3 = posBlack.y - posWhite.y
    
    let dist2 = x3*x3 + y3*y3
    let dist = sqrt(dist2)
    if dist < radius_little * 2 {
        return CGPoint(x: 0, y: 0)
    }
    
    let fact1 = CGFloat((arc4random() % 15) + 3) / 20.0 // try middle part
    let angle1 = angle * fact1
    let angle2 = angle - angle1
    let tan1 = tan(angle1 / 180.0 * CGFloat.pi)
    let tan2 = tan(angle2 / 180.0 * CGFloat.pi)
    if tan2 == 0.0 {
        return CGPoint(x: 0, y: 0)
    }
    
    let k = tan1 / tan2
    if k == -1.0 {
        return CGPoint(x: 0, y: 0)
    }
    let b1 = dist / (k + 1.0)
    //let b2 = dist - b1
    let h = tan1 * b1
    let x5 = b1
    let y5 = h
    
    let cos1 = x3 / dist
    let sin1 = y3 / dist
    
    let x6 = x5 * cos1 - y5 * sin1
    let y6 = y5 * cos1 + x5 * sin1
    
    return nearball(point1: CGPoint(x : x6 + posWhite.x, y : y6 + posWhite.y), point2: posBlack, r: radius_little)
}
//x1=cos(angle)*x-sin(angle)*y;
//y1=cos(angle)*y+sin(angle)*x;
//其中x，y表示物体相对于旋转点旋转angle的角度之前的坐标，x1，y1表示物体旋转angle后相对于旋转点的坐标

func nearball(point1 : CGPoint, point2 : CGPoint, r : CGFloat) -> CGPoint
{
    // 返回一个点，这个点在point1与point2线段上，与point1的距离为 r * 2
    let x = r * 2
    let y : CGFloat = 0.0

    let x3 = point2.x - point1.x
    let y3 = point2.y - point1.y

    let dist2 = x3*x3 + y3*y3
    let dist = sqrt(dist2)
    if dist < radius_little * 2 {
        return CGPoint(x: 0, y: 0)
    }

    let cos1 = x3 / dist
    let sin1 = y3 / dist

    let x6 = x * cos1
    let y6 = x * sin1

    return CGPoint(x: x6 + point1.x, y: y6 + point1.y)
}

func possible_hit(_ pos1: CGPoint, pos2 : CGPoint, pos3 : CGPoint) -> Bool
{
    let pos : CGPoint
    let rate : CGFloat
    let angle : CGFloat
    (pos, rate, angle) = TryPointPool(pos1, pos2: pos2, pos3: pos3)
    if rate == 5.0 {
        return false
    }
    return true
}

func TryPointPool(_ pos1: CGPoint, pos2 : CGPoint, pos3 : CGPoint) -> (CGPoint, CGFloat, CGFloat)
{
    /*
     A: pos1 is white ball, B: pos2 is color ball, pos3 is dest position
     C: dest is the visual position we should arm
     AB = a is distance of pos1 to pos2, a2 = a*a
     AC = b is distance of pos1 to dest, b2 = b*b
     alpha is vision angel of color ball's radius
     gama is angel ACB
     
    */
    let x1 = pos1.x - pos2.x
    let y1 = pos1.y - pos2.y
    let x3 = pos3.x - pos2.x
    let y3 = pos3.y - pos2.y
    
    
    let dest = TryGetDest(CGPoint(x: x3, y: y3))
    let dest2 = CGPoint(x: dest.x + pos2.x, y: dest.y + pos2.y)
    
    let a2 : CGFloat = x1*x1 + y1*y1
    let a : CGFloat = sqrt(a2)
    let b2 : CGFloat = (x1-dest.x)*(x1-dest.x) + (y1-dest.y)*(y1-dest.y)
    let b : CGFloat = sqrt(b2)
    if b2 > a2 || a < radius_little * 2 {
        return (dest2, 5.0, 0.0) // 5.0 means not possible
    }
    
    // now set new coordination origin point to dest2
    // point A becomes:
    let pntA = CGPoint(x: x1 - dest.x, y: y1 - dest.y)
    // new point E, you know what it mean
    let pntE = TryGetDest(pntA)
    // point B becomes:
    let pntB = CGPoint(x: -dest.x, y: -dest.y)
    // let angle alpha be what we need, so pntE rotate alpha will be pntB
    // pntB.x = cos_alpha * pntE.x - sin_alpha * pntE.y
    // pntB.y = cos_alpha * pntE.y + sin_alpha * pntE.x
    // so sin_alpha = (pntE.x * pntB.y - pntE.y * pntB.x) / (pntE.x * pntE.x + pntE.y * pntE.y)
    // and we already know pntE.x * pntE.x + pntE.y * pntE.y = radius_little * radius_little * 4.0
    let sin_alpha = (pntE.y * pntB.x - pntE.x * pntB.y) / (radius_little * radius_little * 4.0)
    let alpha = asin(sin_alpha) * 180.0 / CGFloat.pi
    let result = sin_alpha * 2.0
    return (dest2, result, alpha)
}

func TryGetDest(_ pos1 : CGPoint) -> CGPoint
{
    // line from pos1 to (0,0), and then distant to r, get dest point
    
    let r = radius_little * 2
    let x = pos1.x
    let y = pos1.y
        
    let dist = sqrt(x * x + y * y)
    if dist == 0.0 {
        return CGPoint(x: r, y: 0.0)
    }
    let k = r / dist
    
    let x2 = -k * x
    let y2 = -k * y
    return CGPoint(x: x2, y: y2)
}
func getEnclosedTwoBall(_ pos1: CGPoint, pos2 : CGPoint, r : CGFloat) -> (CGPoint, CGPoint, CGPoint, CGPoint)
{
    let x1 = pos1.x - pos2.x
    let y1 = pos1.y - pos2.y
    
    if x1 == 0.0 {
        let p1 = CGPoint(x: pos1.x-r, y: pos1.y)
        let p2 = CGPoint(x: pos1.x+r, y: pos1.y)
        let p3 = CGPoint(x: pos2.x+r, y: pos2.y)
        let p4 = CGPoint(x: pos2.x-r, y: pos2.y)
        return (p1,p2,p3,p4)
    }
    if y1 == 0.0 {
        let p1 = CGPoint(x: pos1.x, y: pos1.y+r)
        let p2 = CGPoint(x: pos1.x, y: pos1.y-r)
        let p3 = CGPoint(x: pos2.x, y: pos2.y-r)
        let p4 = CGPoint(x: pos2.x, y: pos2.y+r)
        return (p1,p2,p3,p4)
    }
    let k1 = x1 / y1
    let delta_x : CGFloat = r / sqrt(1 + k1*k1)
    let k2 = y1 / x1
    let delta_y : CGFloat = r / sqrt(1 + k2*k2)
    
    if (x1 > 0.0 && y1 > 0.0) {
        let p1 = CGPoint(x: pos1.x-delta_x, y: pos1.y+delta_y)
        let p2 = CGPoint(x: pos1.x+delta_x, y: pos1.y-delta_y)
        let p3 = CGPoint(x: pos2.x+delta_x, y: pos2.y-delta_y)
        let p4 = CGPoint(x: pos2.x-delta_x, y: pos2.y+delta_y)
        return (p1,p2,p3,p4)
    }
    if (x1 < 0.0 && y1 > 0.0) {
        let p1 = CGPoint(x: pos1.x-delta_x, y: pos1.y-delta_y)
        let p2 = CGPoint(x: pos1.x+delta_x, y: pos1.y+delta_y)
        let p3 = CGPoint(x: pos2.x+delta_x, y: pos2.y+delta_y)
        let p4 = CGPoint(x: pos2.x-delta_x, y: pos2.y-delta_y)
        return (p1,p2,p3,p4)
    }
    if (x1 < 0.0 && y1 < 0.0) {
        let p1 = CGPoint(x: pos1.x+delta_x, y: pos1.y-delta_y)
        let p2 = CGPoint(x: pos1.x-delta_x, y: pos1.y+delta_y)
        let p3 = CGPoint(x: pos2.x-delta_x, y: pos2.y+delta_y)
        let p4 = CGPoint(x: pos2.x+delta_x, y: pos2.y-delta_y)
        return (p1,p2,p3,p4)
    }
    let p1 = CGPoint(x: pos1.x+delta_x, y: pos1.y+delta_y)
    let p2 = CGPoint(x: pos1.x-delta_x, y: pos1.y-delta_y)
    let p3 = CGPoint(x: pos2.x-delta_x, y: pos2.y-delta_y)
    let p4 = CGPoint(x: pos2.x+delta_x, y: pos2.y+delta_y)
    return (p1,p2,p3,p4)
}
