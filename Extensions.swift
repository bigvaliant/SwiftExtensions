import UIKit

let hairline: CGFloat = 1 / UIScreen.mainScreen().scale

// Extensions

extension CGRect {
    func getMid() -> CGPoint {
        return CGPoint(x: width * 0.5, y: height * 0.5)
    }
}

extension UIColor {
    class func colorWithRGB(rgb: UInt, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIImage {
    func getColorForPixelAt(point: CGPoint) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var pixelInfo: Int = ((Int(self.size.width * scale) * Int(point.y * scale)) + Int(point.x * scale)) * 4
        
        var r = CGFloat(data[pixelInfo])
        var g = CGFloat(data[pixelInfo + 1])
        var b = CGFloat(data[pixelInfo + 2])
        var a = CGFloat(data[pixelInfo + 3])
        
        return (r / 255.0, g / 255.0, b / 255.0, a / 255.0)
    }
    
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillRect(ctx, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }

    func scaledToWidth(width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let height = self.size.height * scale
        return scaledToSize(CGSize(width: width, height: height))
    }

    func scaledToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func scaledAndCroppedToSize(size: CGSize) -> UIImage {
        var scaledWidth = size.width
        var scaledHeight = size.height
        var thumbnailPoint = CGPoint(x: 0, y: 0)
        
        if !CGSizeEqualToSize(self.size, size) {
            let widthFactor = size.width / self.size.width
            let heightFactor = size.height / self.size.height
            let scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor
            
            scaledWidth = self.size.width * scaleFactor
            scaledHeight = self.size.height * scaleFactor
            
            //center the image
            if widthFactor > heightFactor {thumbnailPoint.y = (size.height - scaledHeight) * 0.5}
            else if widthFactor < heightFactor {thumbnailPoint.x = (size.width - scaledWidth) * 0.5}
        }
        
        UIGraphicsBeginImageContext(size) // this will crop
        let thumbnailRect = CGRect(origin: thumbnailPoint, size: CGSize(width: scaledWidth, height: scaledHeight))
        self.drawInRect(thumbnailRect)
        let scaledCroppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledCroppedImage
    }
}

extension UIFont {
    func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat(DBL_MAX)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self], context: nil).size
    }
}

extension UILabel {
    func sizeToFit(width: CGFloat) {
        var rect = frame
        rect.size = font.sizeOfString(text!, constrainedToWidth: width)
        rect.size.width = width
        rect.size.height = ceil(rect.size.height)
        frame = rect
    }
}

extension UIView {
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    var xCenter: CGFloat {
        get {
            return center.x
        }
        
        set {
            var point = center
            point.x = newValue
            center = point
        }
    }
    
    var xRight: CGFloat {
        get {
            return frame.origin.x + bounds.width
        }
        
        set {
            var rect = frame
            rect.origin.x = newValue - bounds.width
            frame = rect
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    var yCenter: CGFloat {
        get {
            return center.y
        }
        
        set {
            var point = center
            point.y = newValue
            center = point
        }
    }
    
    var yBottom: CGFloat {
        get {
            return frame.origin.y + bounds.height
        }
        
        set {
            var rect = frame
            rect.origin.y = newValue - bounds.height
            frame = rect
        }
    }
    
    var width: CGFloat {
        get {
            return bounds.width
        }
        
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return bounds.height
        }
        
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    func horizontalHairline(bottom: Bool = false) {
        height = hairline
        if bottom {y += 1 - hairline}
    }
    
    func verticalHairline(right: Bool = false) {
        width = hairline
        if right {x += 1 - hairline}
    }
    
    func getScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        self.drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot
    }
}