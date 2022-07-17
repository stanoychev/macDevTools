import Cocoa

class StatusBarIconAnimationUtils: NSObject {
    private var currentFrame = 0
    private var animTimer : Timer? = nil
    private let imageCount = 7

    override init() {
        //todo
        
        //self.animTimer = Timer.init()
        //super.init()
        //animTimer = Timer.scheduledTimer(timeInterval: 5.0 / 30.0, target: self, selector: #selector(self.updateImage(_:)), userInfo: nil, repeats: true)
    }

    @objc private func updateImage(_ timer: Timer?) {
        tickHandler(currentFrame)
        currentFrame += 1
        if currentFrame % imageCount == 0 {
            currentFrame = 0
        }
    }

    private func tickHandler(_ frameCount: Int) {
        //TODO
        let imagePath = "PATH TO IMAGE/\(frameCount)"
        print("Switching image to: \(imagePath)")
        print("Exists: \(FileManager.default.fileExists(atPath: imagePath))")
        
        let image = NSImage(byReferencingFile: NSImage.Name(imagePath))
        
        print(image == nil)
        //image?.isTemplate = true // best for dark mode
//        DispatchQueue.main.async {
//            //tick implementation
//        }
        
        NSWorkspace().setIcon(image, forFile: imagePath, options: [])
    }
}
