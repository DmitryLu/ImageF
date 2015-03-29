//
//  ViewController.swift
//  ImageF
//
//  Created by Dmitry Luzhetsky on 3/28/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

import UIKit
import Foundation

let apiKey = "2b9d21e095e9d637c900b908c00485a4"

class ViewController:
    UIViewController
{
    
    @IBOutlet weak var labelTextToView: UILabel!
    var imageView = UIImageView()
    
    private var searches = [FlickrSearchResults]()
    let flickr = Flickr()

//MARK: - Text input Done
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.imageView.removeFromSuperview()
        self.internetChecking()
        
        if (self.labelTextToView.text == ""){
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            self.view.addSubview(activityIndicator)
            activityIndicator.frame = self.view.bounds
            activityIndicator.startAnimating()
            
            textField.placeholder = "searching...\(textField.text)";
            textField.text=checkInputValuesToTextBox(textField.text)
            flickr.searchFlickrForTerm(textField.text) {
                results, error in
                
                activityIndicator.removeFromSuperview()
                
                if error != nil {
                    self.labelTextToView.text="Беда со связью,\nКартинок не будет\nПопробуй позже"
                    println("Error searching : \(error)")
                }
                if results != nil {
                    self.labelTextToView.text=""
                    println("Found picture for your WORD(s):\(results!.searchTerm)")
                    textField.placeholder = "Type New Request";
                    self.searches.insert(results!, atIndex: 0)
                    self.drawImageToView()
                }
            }
        }
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
    
//MARK: - Image
    private func drawImageToView(){
        
        let flickrPhoto = self.photoForIndexPath(0)
        var imageToShow:UIImage=flickrPhoto.thumbnail!
        
        var kof:Float = Float (imageToShow.size.width / imageToShow.size.height)
        
        var _width: Int = Int(imageToShow.size.width)
        var _height:Int = Int(imageToShow.size.height)

        var _viewSizeWidht: Int = Int(countTrueViewSize().width)
        var _viewSizeHeight:Int = Int(countTrueViewSize().height)
        
        if (_width > _viewSizeWidht-20){
            _width = _viewSizeWidht-20
            _height=Int(Float(_width)/kof)
        }
        if (_height > _viewSizeHeight-100){
            _height = _viewSizeHeight-100
            _width = Int(Float(_height)*kof)
        }
        println("Размер картинки x:\(_width) y:\(_height) ко:\(kof) screen x:\(_viewSizeWidht) y:\(_viewSizeHeight)")

        self.imageView.removeFromSuperview()
        self.imageView.image=imageToShow
        self.imageView.image=makeNewImageWithGoodSize(imageToShow, _width: _width, _height: _height)
        self.imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.imageView)
        
        var myConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 10)
       self.view.addConstraint(myConstraint)
        myConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        self.view.addConstraint(myConstraint)
        
    }
    
    func photoForIndexPath(index: Int) -> FlickrPhoto {
        return searches[index].searchResults[index]
    }
    
//MARK: - Counts & Chechings-
    
    // iOS > 8.0
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if self.imageView.image != nil{
            self.drawImageToView()
        }
    }
    
    // iOS < 8.0
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if self.imageView.image != nil{
            self.drawImageToView()
        }
    }
    
    func internetChecking() {
        let internet = Reachability()
        if internet.isConnectedToNetwork(){
            self.labelTextToView.text=""
        }
        else{
            self.labelTextToView.text="Нет инетернета\n=\nНет картинок\n;("
        }
    }

    
    func checkInputValuesToTextBox(inputText:NSString)->NSString{
        var outText:NSString = inputText.stringByReplacingOccurrencesOfString(" ", withString:"")
        
        if outText.length==0{
            outText="\(arc4random()%1000)"
        }
        else {outText = inputText
        }
        
        if outText.componentsSeparatedByString(" ").count>4{
            outText = "\(arc4random()%1000)"
        }
        
        return outText
    }
    
    func countTrueViewSize()->CGSize{
        
        var _viewSizeWidht: Int = Int(self.view.frame.width)
        var _viewSizeHeight:Int = Int(self.view.frame.height)
        
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            //println("land")
            if _viewSizeWidht < _viewSizeHeight{
                var temp = _viewSizeWidht
                _viewSizeWidht = _viewSizeHeight
                _viewSizeHeight = temp
            }}
        else {
            //println("port")
            if _viewSizeHeight < _viewSizeWidht{
                var temp = _viewSizeWidht
                _viewSizeWidht = _viewSizeHeight
                _viewSizeHeight = temp
            }}
        var outSize:CGSize = CGSize(width: _viewSizeWidht, height: _viewSizeHeight)
        return outSize
    }
    
    func makeNewImageWithGoodSize (image:UIImage, _width:Int,_height:Int)->UIImage{
        let image = image.CGImage
        let width = UInt(_width)
        let height = UInt(_height)
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let bytesPerRow = CGImageGetBytesPerRow(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image)
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image)
        let scaledImage = UIImage(CGImage: CGBitmapContextCreateImage(context))
        
        return scaledImage!
    }
}