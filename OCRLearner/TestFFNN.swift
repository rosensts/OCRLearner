//
//  TestFFNN.swift
//  OCRLearner
//
//  Created by Rosenstein on 3/27/16.
//  Copyright © 2016 Rosenstein. All rights reserved.
//

import Foundation
import UIKit

class TestFFNN {
    
    var ocr: HandwritingTrainerChar
    
    init() {
        self.ocr = HandwritingTrainerChar()
        let filePath = NSURL(fileURLWithPath: "/Users/rosenstein/Documents/Sam/SP16/CSE5523/MLProject/iOSProjects/OCRLearner/OCRLearner").URLByAppendingPathComponent("char-ffnn-trained")
        self.ocr.network = FFNN.fromFile(filePath)!
        
        print("here")
        testA1()
        testB1()
        testC1()
        testD1()
        testJ1()
        testR1()
    }
    
    func testImage(image: UIImage, expectedLabel: HandwritingTrainerChar.Label) {
        
        let imageData = image.floatRepresentation()
        do {
            let answer = try self.ocr.network.update(inputs: imageData)
            print(answer)
            if let (label, confidence) = self.ocr.outputToLabel(answer) {
                print("expected to be label: " + "\(expectedLabel) " + "(\(expectedLabel.rawValue))")
                print("label: \(self.ocr.labelEnums[label].rawValue), confidence: \(confidence.toString())")
            } else {
                print("Unable to test image")
            }
        } catch {
            print("Unable to test")
        }
        
    }
    
    func testA1() {
        
        let image = UIImage(named: "img011-001.png")
        testImage(image!, expectedLabel: HandwritingTrainerChar.Label.A)
        
    }
    
    func testB1() {
        
        let image = UIImage(named: "img012-001.png")
        testImage(image!, expectedLabel: HandwritingTrainerChar.Label.B)
        
    }
    
    func testC1() {
        
        let image = UIImage(named: "img013-001.png")
        testImage(image!, expectedLabel: HandwritingTrainerChar.Label.C)
        
    }
    
    func testD1() {
        
        let image = UIImage(named: "img014-001.png")
        testImage(image!, expectedLabel: HandwritingTrainerChar.Label.D)
        
    }
    
    func testJ1() {
        
        let image = UIImage(named: "img020-011.png")
        testImage(image!, expectedLabel: HandwritingTrainerChar.Label.J)
    }
    
    func testR1() {
        
        let image = UIImage(named: "img028-011.png")
        testImage(image!, expectedLabel: HandwritingTrainerChar.Label.R)
        
    }
    
}
