import UIKit
import Foundation

// Constants

let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
let appCountry = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode)?.lowercaseString
let appLanguage = NSBundle.mainBundle().preferredLocalizations.first as! String

let hairline: CGFloat = 1 / UIScreen.mainScreen().scale

let PI = CGFloat(M_PI)
let PI2 = CGFloat(M_PI_2)

// Helpers

struct ActivityManager {
    static var activitiesCount = 0
    
    static func addActivity() {
        if activitiesCount == 0 {UIApplication.sharedApplication().networkActivityIndicatorVisible = true}
        activitiesCount++
    }
    
    static func removeActivity() {
        if activitiesCount > 0 {
            activitiesCount--
            if activitiesCount == 0 {UIApplication.sharedApplication().networkActivityIndicatorVisible = false}
        }
    }
}

func randomFileURLWithExtension(fileExtension: String) -> NSURL {
    let fileName = "/" + NSUUID().UUIDString + "." + fileExtension.stringByReplacingOccurrencesOfString(".", withString: "", options: .CaseInsensitiveSearch)
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
    let exportPath = documentsPath.stringByAppendingString(fileName) as String
    return NSURL.fileURLWithPath(exportPath)!
}

func executeAfter(delay: NSTimeInterval, closure: () -> ()) {
    if delay > 0 {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    } else {
        closure()
    }
}

func executeOnMainThread(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}

func executeOnBackgroundThread(closure: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), closure)
}

func radiansToDegrees(radians: CGFloat) -> CGFloat {
    return radians * 180 / PI
}

func degreesToRadians(degrees: CGFloat) -> CGFloat {
    return degrees * PI / 180
}

// Operators

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

// Extensions

extension String {
    var length: Int {
        return count(self.utf16)
    }
    
    var empty: Bool {
        return count(self.utf16) == 0
    }
}

extension NSDateFormatter {
    convenience init(dateFormat: String, timeZoneName: String? = nil) {
        self.init()
        if timeZoneName != nil {self.timeZone = NSTimeZone(name: timeZoneName!)}
        self.dateFormat = dateFormat
    }
}

extension NSNumberFormatter {
    convenience init(numberStyle: NSNumberFormatterStyle, maximumFractionDigits: Int? = nil, minimumFractionDigits: Int? = nil) {
        self.init()
        self.numberStyle = numberStyle
        if maximumFractionDigits != nil {self.maximumFractionDigits = maximumFractionDigits!}
        if minimumFractionDigits != nil {self.minimumFractionDigits = minimumFractionDigits!}
    }
}

extension NSTimeInterval {
    func stringWithDateFormat(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = format
        
        return dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: self))
    }
    
    var cmTimeValue: CMTime {
        return CMTimeMake(Int64(self * 25), 25)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: origin.x + width * 0.5, y: origin.y + height * 0.5)
    }
    
    var innerCenter: CGPoint {
        return CGPoint(x: width * 0.5, y: height * 0.5)
    }
    
    var x: CGFloat {
        get {
            return origin.x
        }
        
        set {
            origin.x = newValue
        }
    }
    
    var xCenter: CGFloat {
        get {
            return origin.x + size.width * 0.5
        }
        
        set {
            origin.x = newValue - size.width * 0.5
        }
    }
    
    var xRight: CGFloat {
        get {
            return origin.x + size.width
        }
        
        set {
            origin.x = newValue - size.width
        }
    }
    
    var y: CGFloat {
        get {
            return origin.y
        }
        
        set {
            origin.y = newValue
        }
    }
    
    var yCenter: CGFloat {
        get {
            return origin.y + size.height * 0.5
        }
        
        set {
            origin.y = newValue - size.height * 0.5
        }
    }
    
    var yBottom: CGFloat {
        get {
            return origin.y + size.height
        }
        
        set {
            origin.y = newValue - size.height
        }
    }
    
    var width: CGFloat {
        get {
            return size.width
        }
        
        set {
            size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return size.height
        }
        
        set {
            size.height = newValue
        }
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
    
    class func randomColorWithAlpha(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat(arc4random_uniform(255)) / 255.0,
            green: CGFloat(arc4random_uniform(255)) / 255.0,
            blue: CGFloat(arc4random_uniform(255)) / 255.0,
            alpha: alpha
        )
    }
}

extension UIImage {
    convenience init?(url: NSURL) {
        if let data = NSData(contentsOfURL: url) {
            self.init(data: data)
        } else {
            self.init()
            return nil
        }
    }
    
    func getColorForPixelAt(point: CGPoint) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        
        var r = CGFloat(data[pixelInfo]) / 255.0
        var g = CGFloat(data[pixelInfo+1]) / 255.0
        var b = CGFloat(data[pixelInfo+2]) / 255.0
        var a = CGFloat(data[pixelInfo+3]) / 255.0
        
        return (r, g, b, a)
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
    
    var grayScaleImage: UIImage {
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let ctx = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), 8, 0, colorSpace, CGBitmapInfo.allZeros)
        CGContextDrawImage(ctx, imageRect, self.CGImage)
        return UIImage(CGImage: CGBitmapContextCreateImage(ctx))!
    }
    
    func scaledToWidth(width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let height = self.size.height * scale
        return scaledToSize(CGSize(width: width, height: height))
    }
    
    func scaledToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
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
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
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
    
    func shrinkFontToFitTextToFrame() {
        if text != nil {
            while font.sizeOfString(text!, constrainedToWidth: bounds.size.width).height > bounds.size.height {
                font = UIFont(name: font.fontName, size: font.pointSize - 1)
            }
        }
    }
}

extension UIView {
    var x: CGFloat {
        get {return frame.x}
        set {frame.x = newValue}
    }
    
    var xCenter: CGFloat {
        get {return center.x}
        set {frame.xCenter = newValue}
    }
    
    var xRight: CGFloat {
        get {return frame.xRight}
        set {frame.xRight = newValue}
    }
    
    var y: CGFloat {
        get {return frame.y}
        set {frame.y = newValue}
    }
    
    var yCenter: CGFloat {
        get {return center.y}
        set {frame.yCenter = newValue}
    }
    
    var yBottom: CGFloat {
        get {return frame.yBottom}
        set {frame.yBottom = newValue}

    }
    
    var width: CGFloat {
        get {return bounds.width}
        set {frame.width = newValue}
    }
    
    var height: CGFloat {
        get {return bounds.height}
        set {frame.height = newValue}
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