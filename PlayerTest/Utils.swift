//
//  Uitls.swift
//  PlayerTest
//
//  Created by Lourenço Gomes on 29/07/2021.
//

import UIKit

func millisToTime(_ timeMillis: Int) -> String {
    let seconds = abs(timeMillis / 1000)
    let minutes: Int = seconds / 60
    return String(format: "%02d:%02d", (minutes % 60), (seconds % 60))
}

func downloadImage(url: URL, imageView: UIImageView) {

        let documentName = url.lastPathComponent
        let data : Data? = CacheControl.getDataFromCache(documentName)
        if data != nil {
            if let photoImage  = UIImage.init(data: data!) {
                DispatchQueue.main.async() { () -> Void in
                    imageView.image=photoImage
                }
            }else {
                getDataFromUrl(url: url) { (data, response, error)  in
                    guard let data = data, error == nil else {
                        return
                    }
                    //print(response?.suggestedFilename ?? url.lastPathComponent)
                    let documentName = url.lastPathComponent
                    CacheControl.pushData(toCache: data, identifier: documentName)
                    
                    DispatchQueue.main.async() { () -> Void in
                        imageView.alpha = 0.0
                        UIView.transition(with: imageView, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                            imageView.image = UIImage(data: data)
                            imageView.alpha = 1.0;
                        }, completion: nil)
                    }
                }
            }
        }else {
            getDataFromUrl(url: url) { (data, response, error)  in
                guard let data = data, error == nil else {
                    return
                }
                //print(response?.suggestedFilename ?? url.lastPathComponent)
                let documentName = url.lastPathComponent
                CacheControl.pushData(toCache: data, identifier: documentName)
                
                DispatchQueue.main.async() { () -> Void in
                    imageView.alpha = 0.0
                    UIView.transition(with: imageView, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                        imageView.image = UIImage(data: data)
                        imageView.alpha = 1.0;
                    }, completion: nil)
                }
            }
        }
}

func downloadImage(url: URL, callback: @escaping  (UIImage)->() ) {

        let documentName = url.lastPathComponent
        let data : Data? = CacheControl.getDataFromCache(documentName)
        if data != nil {
            if let photoImage  = UIImage.init(data: data!) {
                DispatchQueue.main.async() { () -> Void in
                    callback(photoImage)
                }
            }else {
                getDataFromUrl(url: url) { (data, response, error)  in
                    guard let data = data, error == nil else {
                        return
                    }
                    //print(response?.suggestedFilename ?? url.lastPathComponent)
                    let documentName = url.lastPathComponent
                    CacheControl.pushData(toCache: data, identifier: documentName)
                    
                    DispatchQueue.main.async() { () -> Void in
                        callback(UIImage(data: data) ?? UIImage())
                    }
                }
            }
        }else {
            getDataFromUrl(url: url) { (data, response, error)  in
                guard let data = data, error == nil else {
                    return
                }
                //print(response?.suggestedFilename ?? url.lastPathComponent)
                let documentName = url.lastPathComponent
                CacheControl.pushData(toCache: data, identifier: documentName)
                
                DispatchQueue.main.async() { () -> Void in
                    callback(UIImage(data: data) ?? UIImage())
                }
            }
        }
}

func imageBase64(strUrl: String) -> String? {
    var strImage64 : String?
    if let url = URL.init(string: strUrl){
        let documentName = url.lastPathComponent
        let data : Data? = CacheControl.getDataFromCache(documentName)
        if data != nil {
            strImage64 = data?.base64EncodedString()
        }
    }
    return strImage64
}

func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
        }.resume()
}
