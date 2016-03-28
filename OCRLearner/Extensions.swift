import Foundation
import UIKit
import CoreImage

/**
 author: Samuel Rosenstein
 
 note: much of this code is highly based off of extensions found in the SwiftAI example code
 
*/
extension UIImage {
    
    public func floatRepresentation() -> [Float] {
        let preImage = self.getGrayScale()
        let image = preImage!.shrinkImage()
        
        let numPixels = Int((image?.size.width)!) * Int((image?.size.height)!)
        
        
        let trainImagesData = UIImagePNGRepresentation(self) // UIImageJPEGRepresentation(self, 1.0)
        // Extract training image pixels
        var trainPixelsArray = [UInt8](count: numPixels, repeatedValue: 0)
        trainImagesData!.getBytes(&trainPixelsArray, range: NSMakeRange(0, numPixels)) //length: numPixels)
        // Convert pixels to Floats
        var trainPixelsFloatArray = [Float](count: numPixels, repeatedValue: 0)
        for (index, pixel) in trainPixelsArray.enumerate() {
            trainPixelsFloatArray[index] = Float(pixel) / 255 // Normalize pixel value
        }
        return Array(trainPixelsFloatArray[80...trainPixelsFloatArray.count-1])
    }
    
    // Get grayscale image from normal image.
    
    func getGrayScale() -> UIImage? {
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContextFromImage(inImage)
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        
        
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        let point: CGPoint = CGPointMake(0, 0)
        
        for var x = 0; x < Int(pixelsWide) ; x++ {
            for var y = 0; y < Int(pixelsHigh) ; y++ {
                let offset = 4*((Int(pixelsWide) * Int(y)) + Int(x))
                let alpha = dataType[offset]
                let red = dataType[offset+1]
                let green = dataType[offset+2]
                let blue = dataType[offset+3]
                
                let avg = (UInt32(red) + UInt32(green) + UInt32(blue))/3
                
                dataType[offset + 1] = UInt8(avg)
                dataType[offset + 2] = UInt8(avg)
                dataType[offset + 3] = UInt8(avg)
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let finalcontext = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, 8,  bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)
        return UIImage(CGImage: imageRef!, scale: self.scale,orientation: self.imageOrientation)
    }
    
    public func createARGBBitmapContextFromImage(inImage: CGImageRef) -> CGContextRef? {
        
        let width = CGImageGetWidth(inImage)
        let height = CGImageGetHeight(inImage)
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if colorSpace == nil {
            return nil
        }
        
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
        let context = CGBitmapContextCreate (bitmapData,
            width,
            height,
            8,      // bits per component
            bitmapBytesPerRow,
            colorSpace,
            CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        return context
    }
    
    public func shrinkImage() -> UIImage? {
        // Scale character to max 20px in either dimension
        let scaledImage = self.scaleImageToSize(self, maxLength: 20)
        // Center character in 28x28 white box
        let character = self.addBorderToImage(scaledImage)
        return character
    }
    
    public func cropImage(image: UIImage, toRect: CGRect) -> UIImage {
        let imageRef = CGImageCreateWithImageInRect(image.CGImage!, toRect)
        let newImage = UIImage(CGImage: imageRef!)
        return newImage
    }
    
    public func scaleImageToSize(image: UIImage, maxLength: CGFloat) -> UIImage {
        let size = CGSize(width: min(maxLength * image.size.width / image.size.height, maxLength), height: min(maxLength * image.size.height / image.size.width, maxLength))
        let newRect = CGRectIntegral(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.None)
        image.drawInRect(newRect)
        
        let newImageRef = CGBitmapContextCreateImage(context)! as CGImageRef
        let newImage = UIImage(CGImage: newImageRef, scale: 1.0, orientation: UIImageOrientation.Up)
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    public func addBorderToImage(image: UIImage) -> UIImage {
        let width = 28
        let height = 28
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let white = UIImage(named: "white")!
        white.drawAtPoint(CGPointZero)
        image.drawAtPoint(CGPointMake((CGFloat(width) - image.size.width) / 2, (CGFloat(height) - image.size.height) / 2))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}


extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}


extension Int {
    
    func stringRep() -> String {
        if self < 10 {
            return "0\(self)"
        } else {
            return "\(self)"
        }
    }
}

