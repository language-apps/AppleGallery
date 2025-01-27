//
//  DetailViewController.swift
//  AcornsMobilePlayerApp
//
//  Created by Dan Harvey on 7/23/15.
//  Copyright (c) 2015 Dan Harvey. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKUIDelegate {

    @IBOutlet var webView: [WKWebView]!

    var detailItem: AnyObject?
    
    var lessonNames = NSMutableArray() // Was [AnyObject]()
    var lessonObject: AcornsLessons?
    var lessonString: String!
    
    override func loadView()
    {
        let webConfiguration = WKWebViewConfiguration()
        
        if webView == nil
        {
            webView = []
            webView.append(WKWebView(frame: .zero, configuration: webConfiguration))
        }
        
        configureView()
        
        webView[0].uiDelegate = self
        view = webView[0]
        NSLog("Detail load view")
        
    }
    
    func stopLoad() {
        if webView != nil && webView.count > 0 {
            NSLog("Detail load stopping")
            webView[0].stopLoading()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateNavigationButtons()
        super.viewDidAppear(animated)
        NSLog("Detail did appear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func configureView() {
        // Update the user interface for the detail item.
        print("configure detail View")
        
       if webView != nil && webView.count > 0 {
            webView[0].stopLoading()
            if detailItem == nil
            {
                let lessonObject = AcornsLessons();
                let lessonNames = lessonObject.findLessons();
                if (lessonNames!.count == 0)
                {
                    let htmlPage = "<html><head></head><body><p align=center>No Lesson available to display<br/><br/> Select the file icon to display the samples<br/><br/>Otherwise download lessons created with the Acorns app<br /><br/>Check out cs.sou.edu/~harveyd/acorns or acornslinguistics.com for details</body></html><br><a href=sou.com>sou</a>"
                    webView[0].loadHTMLString(htmlPage, baseURL:nil)
                    NSLog("Load empty page")
                    return
                }
                
                let data = lessonNames!.object(at: 0)
                detailItem = data as AnyObject
            }
        
            /** Also need the following in the web page: <video id="player" width="480" height="320" webkit-playsinline> */
            if let _: AnyObject = self.detailItem {
                let lessonObject = AcornsLessons()
                let request = lessonObject.lessonURL(detailItem as! String)
                webView[0].configuration.defaultWebpagePreferences.allowsContentJavaScript = true
                webView[0].configuration.allowsInlineMediaPlayback = true
                webView[0].configuration.mediaTypesRequiringUserActionForPlayback = []

                webView[0].load(request)
                NSLog("detail %@", detailItem as! String)
            }
        
            updateNavigationButtons()
        
        }
    }
    
    func updateNavigationButtons() {
        if (detailItem != nil) {
            navigationController!.title = detailItem as? String
            title = detailItem as? String
        }
        else {
            navigationController!.title = "Empty Lesson List"
            title = "Detail"
        }
        
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let split = self.splitViewController
        let controllers = split!.viewControllers
        let navController = controllers.first as? UINavigationController
        let masterViewController = navController?.topViewController as? MasterViewController
        masterViewController?.updateNavigationBars()
        NSLog("Detail Did Load")
    }

    func deleteLesson(_ indexPath: IndexPath?) -> Int
    {
        if indexPath == nil { return  -1}
           
        stopLoad()
           
        let row = indexPath!.row
        let lessonName = lessonNames.object(at: row) as! String
        NSLog("delete %d %@", row, lessonName)
    
        lessonNames.removeObject(at: row)
        lessonObject!.deleteLessonFromGallery(lessonName)

        return row
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("Memory warning to dispose recreatable resources")
    }
    
    
    /** Web View delegate functions */
    func webViewDidStartProvisionalNavigation(_ webView: WKWebView)
    {
        NSLog("Started Loading Web Page")
    }
    
    func didFinishNavigation(_ webView: WKWebView)
    {
        NSLog("Finished Loading Web Page")
    }
    
    func webView(_ webView: WKWebView,
    didFailNavigation error: Error) {
        NSLog("Failed Loading Web Page")
    }


}

