//
//  ViewController.swift
//  弹窗
//
//  Created by 雷馨 on 16/10/21.
//  Copyright © 2016年 雷馨. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class ViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    func MAX(a: CGFloat, b: CGFloat) ->CGFloat {return a > b ? a : b}
    func MIN(a: CGFloat, b: CGFloat) ->CGFloat {return a > b ? b : a}
    
    let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    var startContentOffsetY: CGFloat = 0
    var endContentOffsetY: CGFloat = 0
    
    var moveDirection: Int = 1
    
    lazy var control: UIControl = {
        let control = UIControl()
        control.backgroundColor = UIColor.clearColor()
        control.addTarget(self, action: #selector(ViewController.dismiss), forControlEvents: .TouchUpInside)
        return control
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("more", forState: .Normal)
        button.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.show), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var webView: UIWebView = {
        let web = UIWebView()
        let url = NSURL(string: "http://www.jianshu.com/users/9f0041d5aefd/latest_articles")
        let request = NSURLRequest(URL: url!)
        web.loadRequest(request)
        web.scrollView.delegate = self
        web.scrollView.bounces = false
        web.scrollView.backgroundColor = UIColor.whiteColor()
        //禁止左右滑动
        web.scrollView.contentInset = UIEdgeInsetsZero
        web.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        web.scrollView.showsHorizontalScrollIndicator = false
        return web
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configSubViews()
        
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(ViewController.handelPanGesture(_:)))
        self.webView.addGestureRecognizer(panGesture)
    }
    
    /**
     配置子控件
     */
    func configSubViews() {
        self.view.addSubview(control)
        self.view.addSubview(button)
        self.view.addSubview(webView)
        
        control.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        button.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(60, 30))
            make.top.equalTo(230)
            make.left.equalTo(5)
        }
        
        webView.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(SCREEN_HEIGHT)
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT))
        }
    }

    /**
     弹窗出现
     */
    func show() {
        self.webView.snp_remakeConstraints(closure: { (make) in
            make.top.equalTo(150)
            make.left.equalTo(0)
            make.size.equalTo(CGSizeMake(self.SCREEN_WIDTH, self.SCREEN_HEIGHT))
        })
        UIView.animateWithDuration(0.3, animations: {
            self.webView.layoutIfNeeded()
            }) { (finished) in
                print("show")
        }
    }
    
    /**
     弹窗消失
     */
    func dismiss() {
        self.webView.snp_remakeConstraints(closure: { (make) in
            make.top.equalTo(self.view.snp_bottom)
            make.left.equalTo(0)
            make.size.equalTo(CGSizeMake(self.SCREEN_WIDTH, self.SCREEN_HEIGHT))
        })
        UIView.animateWithDuration(0.3, animations: {
            self.webView.layoutIfNeeded()
            }) { (finished) in
                print("dismiss")
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.webView.scrollView.contentOffset.y > startContentOffsetY { //向上拖动
            if self.panGesture.view!.frame.origin.y != 0 { //没到顶头
                scrollView.contentOffset.y = 0
            }
        } else { //向下拖动
            if scrollView.contentOffset.y != 0 {
                panGesture.view!.center = self.view.center
                panGesture.setTranslation(CGPointZero, inView: self.view)
            }
        }
        startContentOffsetY = self.webView.scrollView.contentOffset.y

    }
    
    /*
     开始拖动滑块
    */
    func handelPanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Changed:
            let translation: CGPoint = sender.translationInView(self.view)
            var newCenter: CGPoint = CGPointMake(sender.view!.center.x,sender.view!.center.y + translation.y)
            sender.view!.center = newCenter
            sender.setTranslation(CGPointZero, inView: self.view)
            if sender.view!.center.y <= self.view.center.y {
                newCenter.y = self.view.center.y
                sender.view?.center = newCenter
            }
        case .Ended:
            if sender.view!.frame.origin.y < 44 {
                self.webView.snp_remakeConstraints(closure: { (make) in
                    make.edges.equalTo(0)
                })
                UIView.animateWithDuration(0.3, animations: {
                    self.webView.layoutIfNeeded()
                })
            } else if sender.view!.frame.origin.y > 44 && sender.view!.frame.origin.y < 200 {
                self.show()
            } else {
                self.dismiss()
            }
        default:
            break
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

