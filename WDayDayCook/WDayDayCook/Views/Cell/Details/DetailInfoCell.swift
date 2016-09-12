//
//  DetailInfoCell.swift
//  WDayDayCook
//
//  Created by wangju on 16/7/30.
//  Copyright © 2016年 wangju. All rights reserved.
//

import UIKit
import JavaScriptCore

let showDetailVcNotificationKey = "showDetailVcNotification"
let showAllCommentNotificationKey = "showAllCommentNotification"
// 定义协议SwiftJavaScriptDelegate 该协议必须遵守JSExport协议
@objc protocol SwiftJavaScriptDelegate: JSExport {
    // js调用App方法时传递多个参数 并弹出对话框 注意js调用时的函数名
    // 第二个参数首字母大写 
    //showDetailVcId('linkRecipeDtl', id);
    func showDetailVc(title: String, id: Int)
    
    func showAllComment()
    
}

@objc class SwiftJavaScriptModel:NSObject,SwiftJavaScriptDelegate
{
    
    weak var controller: UIViewController?
    weak var jsContext: JSContext?
    
    func showDetailVc(title: String, id: Int) {
        
        print(title)
        print(id)
        
        if title == "linkRecipeDtl" {
            NSNotificationCenter.defaultCenter().postNotificationName(showDetailVcNotificationKey, object: id)
        }
        
    }
    
    func showAllComment() {
        NSNotificationCenter.defaultCenter().postNotificationName(showAllCommentNotificationKey, object: nil)
        print("显示更多评论数据")
    }


}

class DetailInfoCell: UITableViewCell {

    var cellHeight:CGFloat = 0
    
    var loadFinished = false
    
    var loadFinishedAction:(()->Void)?
    
    var scrollEnabled:Bool = false{
   
        didSet{
            let oldHeight = cellHeight
            self.webView.scrollView.scrollEnabled = scrollEnabled
            self.webView.sizeToFit()
            cellHeight = webView.scrollView.contentSize.height
            self.webView.scrollView.scrollEnabled = false
            scrollEnabled = false
            if oldHeight == cellHeight {
                // 数据加载完，则不再加载
                return
            }
            
            if let action = loadFinishedAction {
                action()
            }
            
        
        }
    }
    
    var requestUrl:String?{
        
        willSet{
            if let _ = requestUrl {
                return
            }
        
        }
        
        didSet{
            
            guard let requestUrl = requestUrl else{
                return
            }
            
            let request = NSURLRequest(URL: NSURL(string: requestUrl)!)
                
            webView.loadRequest(request)
            
        }
    }
    
    @IBOutlet weak var webView: UIWebView!{
        didSet{
            webView.delegate = self
            webView.scrollView.scrollEnabled = false
            webView.stringByEvaluatingJavaScriptFromString(try! String(contentsOfURL: NSBundle.mainBundle().URLForResource("myJsf", withExtension: "js")!, encoding: NSUTF8StringEncoding))
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DetailInfoCell:UIWebViewDelegate
{
    func webViewDidStartLoad(webView: UIWebView) {
        self.webView.sizeToFit()
        cellHeight = webView.scrollView.contentSize.height
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        print(request.URL?.absoluteString)
//        print("_________________________")
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.webView.sizeToFit()
        self.sizeToFit()
        cellHeight = webView.scrollView.contentSize.height
        loadFinished = true
 
        
        if let action = loadFinishedAction {
            action()
        }
        
        print(webView.request?.URL?.absoluteString)
        

        let context = webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let model = SwiftJavaScriptModel()
        model.controller = UIApplication.sharedApplication().keyWindow?.rootViewController
        model.jsContext = context
        
        context.setObject(model, forKeyedSubscript: "WebViewJavascriptBridge")
        
        context.exceptionHandler = { (context, exception) in
            print("exception：", exception)
        }

    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error)
    }

}

