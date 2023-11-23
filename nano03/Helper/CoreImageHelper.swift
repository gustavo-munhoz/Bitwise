//
//  CoreImageHelper.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 26/09/23.
//

import UIKit
import CoreImage.CIFilterBuiltins

class CoreImageHelper {
    let shared = CoreImageHelper()
    
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
        }
        return nil
    }
}
