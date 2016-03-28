//
//  HandwritingTrainer.swift
//  OCRLearner
//
//  Created by Rosenstein on 3/23/16.
//  Copyright © 2016 Rosenstein. All rights reserved.
//

import Foundation
import UIKit

class HandwritingTrainerChar {
    
    let numberOfClasses = 6
    
    var network = FFNN(inputs: 704, hidden: 20, outputs: 6)
    
    private var trainingImages = [[Float]] ()
    private var trainingLabels = [[Float]] ()
    private var validationImages = [[Float]] ()
    private var validationLabels = [[Float]] ()
    
    // Correspond to number in sample folder
    // Only train network on A, B, C, D, J, and R
    
    internal enum Label: Int {
        case A = 11
        case B = 12
        case C = 13
        case D = 14
        case J = 20
        case R = 28
        
    }
    
    let labelEnums = [Label.A, Label.B, Label.C, Label.D, Label.J, Label.R]
    
    func constructNetwork() {
        
        for i in 0...labelEnums.count - 1 { // Iterate through all chacters
            print("Char: \(labelEnums[i])")
            let sampleName = "img0" + labelEnums[i].rawValue.stringRep() + "-0"
            let start = NSDate();
            
            // Train 55 samples of each character
            for j in 1...55 {
                let imageName = sampleName + j.stringRep() + ".png"
                let image = UIImage(named: imageName)
                let imageData = (image?.floatRepresentation())!
                trainingImages.append(imageData)
                trainingLabels.append(labelToArray(i, numberOfClasses: numberOfClasses))
                
                // Use the first ten samples of each character as validation data
                if j < 10 {
                    validationImages.append(imageData)
                    validationLabels.append(labelToArray(i, numberOfClasses: numberOfClasses))
                }
            }
            
            let end = NSDate();   // <<<<<<<<<<   end time
            let timeInterval: Double = end.timeIntervalSinceDate(start); // <<<<< Difference in seconds (double)
            print("Time for num \(labelEnums[i]): \(timeInterval) seconds");
            
        }
        
       
        do {
            try network.train(inputs: trainingImages, answers: trainingLabels, testInputs: validationImages, testAnswers: validationLabels, errorThreshold: 0.7)
        } catch {
            print("There was an error training the network")
        }
        
        // Save FFNN to project directory
        // let filePath = // Enter file location here
        // network.writeToFile(filePath)
    }
    
    private func labelToArray(label: Int, numberOfClasses: Int) -> [Float] {
        var answer = [Float](count: numberOfClasses, repeatedValue: 0)
        answer[Int(label)] = 1
        return answer
    }
    
    func outputToLabel(output: [Float]) -> (label: Int, confidence: Double)? {
        guard let max = output.maxElement() else {
            return nil
        }
        return (output.indexOf(max)!, Double(max / 1.0))
    }
}
