//
//  ViewController.swift
//  AFNetworkingInSwift
//
//  Created by Suraj on 31/07/15.
//  Copyright (c) 2015 Suraj. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionViewPhotos: UICollectionView!
    @IBOutlet weak var activityIndicatorLoader: UIActivityIndicatorView!
    
    var arrPhotoURLs = Array<String>()
    var currentPageNo : NSInteger = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeAPICallToLoadImages(currentPageNo++)
        
        /*
        ////////                API call                ////////
        let parameters = ["q":"How do you do?", "langpair":"en|hi"] // en: English | hi: Hindi
        Alamofire.request(.GET, "http://api.mymemory.translated.net/get", parameters:parameters)
            .responseJSON { (_, _, JSON, _) -> Void in
                let translatedText: String? = JSON?.valueForKeyPath("responseData.translatedText") as! String?
                println("Translated text: \(translatedText)")
        }
        
        
        // Get Response as Data from API
        Alamofire.request(.GET, "http://httpbin.org/get")
            .response { (request, response, data, error) in
                println("Request: \(request)")
                println("Response: \(response)")
                println("Data: \(data)")
                println("Error: \(error)")
        }
        
        // Get Response as String from API
        Alamofire.request(.GET, "http://httpbin.org/get")
            .responseString { (request, response, string, error) in
                println("Request: \(request)")
                println("Response: \(response)")
                println("String: \(string)")
                println("Error: \(error)")
        }
        
        // Get Response as JSON from API
        Alamofire.request(.GET, "http://httpbin.org/get")
            .responseJSON {(request, response, JSON, error) in
                println("JSON: \(JSON)")
                // API response is not a JSON so, 'nil' will be printed in console
        }
        
        
        // Chaining successive methods
        // Requests can have multiple response handlers, which each execute asynchronously once the server has finished sending its response.
        Alamofire.request(.GET, "http://httpbin.org/get")
            .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                println("Total Bytes Read: \(totalBytesRead)")
            }
            .responseJSON { (request, response, JSON, error) in
                println("JSON: \(JSON)")
            }
            .responseString { (request, response, string, error) in
                println("String: \(string)")
        }
        

        var postsEndpoint: String = "http://jsonplaceholder.typicode.com/posts"
        var newPost = ["title": "Frist Psot", "body": "I iz fisrt", "userId": 1];
        Alamofire.request(.POST, postsEndpoint, parameters: newPost, encoding: .JSON)
            .responseJSON { (request, response, data, error) in
                if let anError = error
                {
                    // got an error in getting the data, need to handle it
                    println("error calling POST")
                    println(error)
                }
                else if let data: AnyObject = data
                {
                    // handle the results as JSON, without a bunch of nested if loops
                    //let post = JSON(data)
                    // to make sure it posted, print the results
                    println("The post is: \(data)" )
                }
        }
        */
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UICollectionView DataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrPhotoURLs.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCellID", forIndexPath: indexPath) as! UICollectionViewCell
        let imageURL = self.arrPhotoURLs[indexPath.row]
        
        // API call to load image in cell
        Alamofire.request(.GET, imageURL).response() {
            (_, _, data, _) in
            let image = UIImage(data: data!)
            
            if var imageView = cell.viewWithTag(1) as? UIImageView {
                imageView.image = image
            }
        }
        
        return cell
    }
    
    
    // UICollectionView Delegate Methods
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pageViewController = storyboard.instantiateViewControllerWithIdentifier("PageViewControllerID") as! PageViewController
        pageViewController.pageImages = self.arrPhotoURLs
        pageViewController.currentIndex = indexPath.row
        self.presentViewController(pageViewController, animated: true, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var bottomEdge :CGFloat! = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            // we are at the end
            makeAPICallToLoadImages(currentPageNo++)
        }
    }
    
    func makeAPICallToLoadImages (nextPageNo: NSInteger) {
        ////////                API call                ////////
        activityIndicatorLoader.startAnimating()
        Alamofire.request(.GET, "https://api.500px.com/v1/photos", parameters:["consumer_key":"dHgDdG3hQ0X5rYRujL5CsfItN6Tz89DD8TwtvZ1v", "page": "\(nextPageNo)", "feature": "fresh_today", "rpp": "21",  "include_store": "store_download", "include_states": "votes", "image_size": "4"]).responseJSON() {
            (_, _, JSON, _) in
            println(JSON)
            
            let photoInfos = (JSON!.valueForKey("photos") as! [NSDictionary]) // photosInfos = Array
            for index in 1..<photoInfos.count {
                // image_url parsed and stored in arrPhotoURLs Array
                println(photoInfos[index].objectForKey("image_url"))
                let strImageURL = photoInfos[index].objectForKey("image_url") as! String
                self.arrPhotoURLs.append(strImageURL)
            }
            
            self.collectionViewPhotos.reloadData()
            self.activityIndicatorLoader.stopAnimating()
        }
    }
   
    
}

