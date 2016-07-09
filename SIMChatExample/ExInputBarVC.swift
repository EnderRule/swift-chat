//
//  ExInputBarVC.swift
//  SIMChatExample
//
//  Created by sagesse on 6/27/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

//class InputAccessoryView: UIView, UITextViewDelegate {
//    
//    let textView = UITextView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        // This is required to make the view grow vertically
//        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight
//        
//        // Setup textView as needed
//        self.addSubview(self.textView)
//        self.textView.translatesAutoresizingMaskIntoConstraints = false
//        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[textView]|", options: [], metrics: nil, views: ["textView": self.textView]))
//        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textView]|", options: [], metrics: nil, views: ["textView": self.textView]))
//        
//        self.textView.delegate = self
//        self.textView.backgroundColor = UIColor.brownColor()
//        self.backgroundColor = UIColor.orangeColor()
//        
//        // Disabling textView scrolling prevents some undesired effects,
//        // like incorrect contentOffset when adding new line,
//        // and makes the textView behave similar to Apple's Messages app
//        self.textView.scrollEnabled = false
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    @IBOutlet weak var x12: UITextField!
//    
//    override func intrinsicContentSize() -> CGSize {
//        // Calculate intrinsicContentSize that will fit all the text
//        let textSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.width, height: CGFloat.max))
//        return CGSize(width: self.bounds.width, height: textSize.height)
//    }
//    
//    // MARK: UITextViewDelegate
//    
//    func textViewDidChange(textView: UITextView) {
//        // Re-calculate intrinsicContentSize when text changes
//        self.invalidateIntrinsicContentSize()
//    }
//}
//
//class TestView:UIView {
//    override func willMoveToWindow(newWindow: UIWindow?) {
//        print(#function + ".begin")
//        super.willMoveToWindow(newWindow)
//        print(#function + ".end")
//    }
//    override func willMoveToSuperview(newSuperview: UIView?) {
//        print(#function + ".begin")
//        super.willMoveToSuperview(newSuperview)
//        print(#function + ".end")
//    }
//    override func didMoveToWindow() {
//        print(#function + ".begin")
//        super.didMoveToWindow()
//        print(#function + ".end")
//    }
//    override func didMoveToSuperview() {
//        print(#function + ".begin")
//        super.didMoveToSuperview()
//        print(#function + ".end")
//    }
//    override func layoutSubviews() {
//        print(#function + ".begin")
//        super.layoutSubviews()
//        print(#function + ".end")
//    }
//}

/// 输入框测试
class ExInputBarVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.contents = UIImage(named: "t1.jpg")?.CGImage
        self.view.layer.contentsGravity = kCAGravityResizeAspectFill
        self.view.layer.masksToBounds = true
        
        self.inputBar2 = SIMChatInputBar()
        //self.inputBar.shadowImage = UIImage(named: "t2.jpg")
        //self.inputBar2?.translucent = false
        //self.inputBar2?.barTintColor = UIColor(argb: 0xFFECEDF1)
        
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 253 + 49, 0)
//        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        
//        let tb = UIView(frame:CGRectMake(0,0,320,44))//UIToolbar(frame:CGRectMake(0,0,320,44))
//    //public convenience init(title: String?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector)
//        
////        tb.items = [
////            UIBarButtonItem(title:"h1", style: .Plain, target: self, action:#selector(sh1)),
////            UIBarButtonItem(title:"h2", style: .Plain, target: self, action:#selector(sh2)),
////        ]
//        
//        self.tb?.hidden = true
//        self.tb?.userInteractionEnabled = false
//        
//        self.tb = tb
        
        print(#function)
    }
    
    var tb:UIView?//UIToolbar?
    
    
    override func reloadInputViews() {
        print(#function)
        super.reloadInputViews()
        print(#function)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print(#function)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(#function)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    lazy var _inputBar = SIMChatInputBar(frame:CGRectMake(0, 0, 320, 44))
//    //lazy var _inputPanel = UIView(frame:CGRectMake(0, 0, 320, 80))
////    override func canResignFirstResponder() -> Bool {
////        return false
////    }
//    override func canBecomeFirstResponder() -> Bool {
//        return true
//    }
//    override func becomeFirstResponder() -> Bool {
//        print(#function)
//        return super.becomeFirstResponder()
//    }
//    
//    override func resignFirstResponder() -> Bool {
//        print(#function)
//        return super.resignFirstResponder()
//    }
    
//    override var inputView: UIView? {
//        return _inputPanel
//    }
    
//    override var inputAccessoryView: UIView? {
//        return tb
////        return _inputBar
//    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 99
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = "\(indexPath)"
    }
    
    @IBOutlet weak var x12: UITextField!
    @IBOutlet weak var tableView: UITableView!
}
