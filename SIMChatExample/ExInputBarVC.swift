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

        
class TestBarItem:SIMChatInputBarItem {
    
    init(n: UIImage?, h: UIImage? = nil, s: UIImage? = nil, d: UIImage? = nil, sh: UIImage? = nil, alignment: SIMChatInputBarAlignment = .Automatic) {
        super.init()
        self.size = n?.size ?? CGSizeMake(34, 3)
        self.alignment = alignment
        
        self.setImage(n, forState: .Normal)
        self.setImage(h, forState: .Highlighted)
        self.setImage(d, forState: .Disabled)
        self.setImage(s ?? h,  forState: [.Selected, .Normal])
        self.setImage(sh, forState: [.Selected, .Highlighted])
    }
    
    init(size: CGSize, alignment: SIMChatInputBarAlignment) {
        super.init()
        self.size = size
        self.alignment = alignment
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 输入框测试
class ExInputBarVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SIMChatInputBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.contents = UIImage(named: "t1.jpg")?.CGImage
        self.view.layer.contentsGravity = kCAGravityResizeAspectFill
        self.view.layer.masksToBounds = true
        
        
        let ib = SIMChatInputBar()
        
        // 对齐测试
        // _topBarItems = [
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Left),
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Left),
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Left),
        //     TestBarItem(size: CGSizeMake(132, 34), alignment: .Right),
        // ]
        // _leftBarItems = [
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Bottom),
        // ]
        // _rightBarItems = [
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Top),
        // ]
        // _bottomBarItems = [
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .TopLeft),
        //     TestBarItem(size: CGSizeMake(24, 24), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .BottomLeft),
        //     TestBarItem(size: CGSizeMake(64, 64), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .BottomRight),
        //     TestBarItem(size: CGSizeMake(24, 24), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .TopRight),
        // ]
        
        // 图标测试
        // qqzone
        let topBarItems: [TestBarItem] = [
            TestBarItem(n: UIImage(named:"mqz_input_atFriend"), alignment: .Left),
            TestBarItem(n: UIImage(named:"mqz_ugc_inputCell_face_icon"), alignment: .Left),
            TestBarItem(n: UIImage(named:"mqz_ugc_inputCell_pic_icon"), alignment: .Left),
            TestBarItem(n: UIImage(named:"mqz_ugc_inputCell_private_icon"), alignment: .Right),
        ]
        // wexin
        let leftBarItems: [TestBarItem] = [
            TestBarItem(n: UIImage(named:"chat_bottom_PTT_nor"), h: UIImage(named:"chat_bottom_PTT_press")),
        ]
        let rightBarItems: [TestBarItem] = [
            TestBarItem(n: UIImage(named:"chat_bottom_emotion_nor"), h: UIImage(named:"chat_bottom_emotion_press")),
            TestBarItem(n: UIImage(named:"chat_bottom_more_nor"), h: UIImage(named:"chat_bottom_more_press")),
        ]
        // qq
        let bottomBarItems: [TestBarItem] = [
            TestBarItem(n: UIImage(named:"chat_bottom_PTT_nor"), h: UIImage(named:"chat_bottom_PTT_press"), alignment: .Left),
            TestBarItem(n: UIImage(named:"chat_bottom_PTV_nor"), h: UIImage(named:"chat_bottom_PTV_press")),
            TestBarItem(n: UIImage(named:"chat_bottom_photo_nor"), h: UIImage(named:"chat_bottom_photo_press")),
            TestBarItem(n: UIImage(named:"chat_bottom_Camera_nor"), h: UIImage(named:"chat_bottom_Camera_press")),
            TestBarItem(n: UIImage(named:"chat_bottom_red_pack_nor"), h: UIImage(named:"chat_bottom_red_pack_press")),
            TestBarItem(n: UIImage(named:"chat_bottom_emotion_nor"), h: UIImage(named:"chat_bottom_emotion_press")),
            TestBarItem(n: UIImage(named:"chat_bottom_more_nor"), h: UIImage(named:"chat_bottom_more_press"), alignment: .Right),
            
            // TestBarItem(n: UIImage(named:"chat_bottom_file_nor")),
            // TestBarItem(n: UIImage(named:"chat_bottom_keyboard_nor")),
            // TestBarItem(n: UIImage(named:"chat_bottom_location_nor")),
            // TestBarItem(n: UIImage(named:"chat_bottom_mypc_nor")),
            // TestBarItem(n: UIImage(named:"chat_bottom_shake_nor")),
        ]
        
        self.navigationItem
        
        ib.setBarItems(topBarItems, atPosition: .Top, animated: false)
        ib.setBarItems(leftBarItems, atPosition: .Left, animated: false)
        ib.setBarItems(rightBarItems, atPosition: .Right, animated: false)
        ib.setBarItems(bottomBarItems, atPosition: .Bottom, animated: false)
        ib.delegate = self
        
        self.inputBar2 = ib
        
        self.leftBarItems1 = [
            TestBarItem(size: CGSizeMake(34,34), alignment: .Automatic)
            //TestBarItem(n: UIImage(named:"chat_bottom_emotion_nor"), h: UIImage(named:"chat_bottom_emotion_press")),
        ]
        self.leftBarItems2 = [
            TestBarItem(size: CGSizeMake(88,34), alignment: .Automatic)
            //TestBarItem(n: UIImage(named:"chat_bottom_more_nor"), h: UIImage(named:"chat_bottom_more_press")),
            //TestBarItem(n: UIImage(named:"chat_bottom_more_nor"), h: UIImage(named:"chat_bottom_more_press")),
        ]
        
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
    
    var vs = 0
    
    var leftBarItems1: [SIMChatInputBarItem] = []
    var leftBarItems2: [SIMChatInputBarItem] = []
    
    var selectedItem: SIMChatInputBarItem?
    
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
    
    func inputBar(inputBar: SIMChatInputBar, shouldHighlightItem item: SIMChatInputBarItem) -> Bool {
        if selectedItem === item {
            return false
        }
        return true
    }
    
    func inputBar(inputBar: SIMChatInputBar, shouldSelectItem item: SIMChatInputBarItem) -> Bool {
        if let sitem = selectedItem {
            guard inputBar.canDeselectBarItem(sitem) else {
                return false
            }
            inputBar.deselectBarItem(sitem, animated: true)
        }
        return true
    }
    func inputBar(inputBar: SIMChatInputBar, didSelectItem item: SIMChatInputBarItem) {
        Log.trace()
        selectedItem = item
        
        if vs == 1 {
            vs = 0
            inputBar.setCenterBarItem(.defaultCenterBarItem)
            //inputBar.setBarItems(self.leftBarItems1, atPosition: .Left, animated: true)
        } else {
            vs = 1
            inputBar.setCenterBarItem(_customCenterBarItem)
            //inputBar.setBarItems(self.leftBarItems2, atPosition: .Left, animated: true)
        }
    }
    
    lazy var _customCenterBarItem: SIMChatInputBarItem = {
        return TestBarItem(size: CGSizeMake(22, 34), alignment: .Automatic)
    }()

    func inputBar(inputBar: SIMChatInputBar, shouldDeselectItem item: SIMChatInputBarItem) -> Bool {
        if selectedItem === item {
            return false
        }
        return true
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
