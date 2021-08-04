//
//  Uitls.swift
//  PlayerTest
//
//  Created by Lourenço Gomes on 29/07/2021.
//
//  Copyright 2021 Lourenço Gomes
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in the
//  Software without restriction, including without limitation the rights to use, copy,
//  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//   PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR // OTHER LIABILITY, WHETHER IN AN ACTION
//   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

func millisToTime(_ timeMillis: Int) -> String {
    let seconds = abs(timeMillis / 1000)
    let minutes: Int = seconds / 60
    return String(format: "%02d:%02d", (minutes % 60), (seconds % 60))
}

func downloadImage(url: URL, imageView: UIImageView) {

    getDataFromUrl(url: url) { (data, response, error)  in
        guard let data = data, error == nil else {
            return
        }
        DispatchQueue.main.async() { () -> Void in
            imageView.alpha = 0.0
            UIView.transition(with: imageView, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                imageView.image = UIImage(data: data)
                imageView.alpha = 1.0;
            }, completion: nil)
        }
    }
}

func downloadImage(url: URL, callback: @escaping  (UIImage)->() ) {
    getDataFromUrl(url: url) { (data, response, error)  in
        guard let data = data, error == nil else {
            return
        }
        DispatchQueue.main.async() { () -> Void in
            callback(UIImage(data: data) ?? UIImage())
        }
    }
}

func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
        }.resume()
}
