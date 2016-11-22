//
//  BrowseDetailViewController.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseDetailViewController: UIViewController, BrowseContextTransitioning {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _commonInit()
    }
    
    weak var delegate: BrowseDelegate?
    weak var dataSource: BrowseDataSource?
    
    lazy var isInteractiving: Bool = false
    lazy var lastContentOffset: CGPoint = .zero
    
    lazy var extraContentInset = UIEdgeInsetsMake(0, -20, 0, -20)
    lazy var interactiveDismissGestureRecognizer = UIPanGestureRecognizer()
    
    lazy var collectionViewLayout: BrowseDetailViewLayout = BrowseDetailViewLayout()
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    
    var browseIndexPath: IndexPath? { 
        return collectionView.indexPathsForVisibleItems.last
    }
    var browseInteractiveDismissGestureRecognizer: UIGestureRecognizer? {
        return interactiveDismissGestureRecognizer
    }
    
    func browseContentSize(at indexPath: IndexPath) -> CGSize {
        return dataSource?.browser(self, assetForItemAt: indexPath).browseContentSize ?? .zero
    }
    func browseContentMode(at indexPath: IndexPath) -> UIViewContentMode {
        return .scaleAspectFill
    }
    func browseContentOrientation(at indexPath: IndexPath) -> UIImageOrientation {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BrowseDetailViewCell else {
            return .up
        }
        return cell.orientation
    }
    
    func browseTransitioningView(at indexPath: IndexPath, forKey key: UITransitionContextViewKey) -> UIView? {
        if let cell = collectionView.cellForItem(at: indexPath) as? BrowseDetailViewCell {
            return cell.detailView
        }
        collectionView.frame = UIEdgeInsetsInsetRect(view.bounds, extraContentInset)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.layoutIfNeeded()
        _currentIndex = indexPath.item
        if let cell = collectionView.cellForItem(at: indexPath) as? BrowseDetailViewCell {
            return cell.detailView
        }
        return nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detail"
        
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        view.addGestureRecognizer(interactiveDismissGestureRecognizer)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let cell = collectionView.visibleCells.first
        let indexPath = collectionView.indexPathsForVisibleItems.first
        collectionView.frame = UIEdgeInsetsInsetRect(view.bounds, extraContentInset)
        if let indexPath = indexPath, let cell = cell {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            collectionView.layoutIfNeeded()
            collectionView.bringSubview(toFront: cell)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.pop_delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.pop_delegate = nil
    }
    
    func dismissHandler(_ sender: UIPanGestureRecognizer) {
        
        if !isInteractiving {
            let velocity = sender.velocity(in: view)
            guard velocity.y > 0 && fabs(velocity.x / velocity.y) < 1.5 else {
                return
            }
            guard let cell = collectionView.visibleCells.last as? BrowseDetailViewCell else {
                return 
            }
            // 检查这个是否己经触发了bounces
            let mh = interactiveDismissGestureRecognizer.location(in: view).y
            let point = interactiveDismissGestureRecognizer.location(in: cell.detailView.superview)
            
            guard point.y - mh < 0 || cell.detailView.frame.height <= view.frame.height else {
                return
            }
            let offset = cell.containterView.contentOffset
            let frame = cell.detailView.frame
            let size = cell.containterView.frame.size
            let x = min(max(offset.x, frame.minX), max(frame.width, size.width) - size.width)
            let y = min(max(offset.y, frame.minY), max(frame.height, size.height) - size.height)
            
            isInteractiving = true
            lastContentOffset = CGPoint(x: x, y: y)
            
            DispatchQueue.main.async {
                cell.containterView.setContentOffset(self.lastContentOffset, animated: false)
                
                guard let nav = self.navigationController else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                nav.popViewController(animated: true)
            }
        } else {
            guard sender.state != .changed else {
                // change
                return
            }
            // 关闭
            isInteractiving = false
            
            guard let cell = collectionView.visibleCells.last as? BrowseDetailViewCell else {
                return 
            }
            DispatchQueue.main.async {
                cell.containterView.setContentOffset(self.lastContentOffset, animated: false)
            }
        }
    }
    
    fileprivate weak var _test: UIImageView?
    fileprivate var _currentIndex: Int = 0 {
        didSet {
            let asset = dataSource?.browser(self, assetForItemAt: IndexPath(item: _currentIndex, section: 0))
            
            _test?.image = asset?.browseImage
        }
    }
    
    fileprivate func _commonInit() {
        
        automaticallyAdjustsScrollViewInsets = false
        
        interactiveDismissGestureRecognizer.delegate = self
        interactiveDismissGestureRecognizer.maximumNumberOfTouches = 1
        interactiveDismissGestureRecognizer.addTarget(self, action: #selector(dismissHandler(_:)))
        
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = -extraContentInset.left * 2
        collectionViewLayout.minimumInteritemSpacing = -extraContentInset.right * 2
        collectionViewLayout.headerReferenceSize = CGSize(width: -extraContentInset.left, height: 0)
        collectionViewLayout.footerReferenceSize = CGSize(width: -extraContentInset.right, height: 0)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        collectionView.addGestureRecognizer(interactiveDismissGestureRecognizer)
        
        collectionView.register(BrowseDetailViewCell.self, forCellWithReuseIdentifier: "Asset")
//        collectionView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Image")
//        collectionView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Video")
        
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        view.image = UIImage(named: "cl_1")
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        _test = view
        
        toolbarItems = [
            BrowseCustomBarItem(size: CGSize(width: 0, height: 44), view: view),
            UIBarButtonItem(title: "Test", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "Test", style: .plain, target: nil, action: nil),
        ]
    //public convenience init(title: String?, style: UIBarButtonItemStyle, target: Any?, action: Selector?)
    }
    
    
}

extension BrowseDetailViewController: BrowseDetailViewDelegate, UINavigationBarDelegate {
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        // 正在旋转的时候不允许返回
        guard collectionView.isScrollEnabled else {
            return false
        }
        
        return true
    }
    
    
    func browseDetailView(_ browseDetailView: Any, _ containterView: BrowseContainterView, shouldBeginRotationing view: UIView?) -> Bool {
        collectionView.isScrollEnabled = false
        return true
    }
    func browseDetailView(_ browseDetailView: Any, _ containterView: BrowseContainterView, didEndRotationing view: UIView?, atOrientation orientation: UIImageOrientation) {
        collectionView.isScrollEnabled = true
    }
}

extension BrowseDetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if  interactiveDismissGestureRecognizer == gestureRecognizer  {
            let velocity = interactiveDismissGestureRecognizer.velocity(in: collectionView)
            // 检测手势的方向 => 上下
            guard fabs(velocity.x / velocity.y) < 1.5 else {
                return false
            }
            guard let cell = collectionView.visibleCells.last as? BrowseDetailViewCell else {
                return false
            }
            // 检查这个手势事件能不能超触发bounces
            let point = interactiveDismissGestureRecognizer.location(in: cell.detailView.superview)
            guard (point.y - view.frame.height) <= 0 else {
                return false
            }
            return true
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if interactiveDismissGestureRecognizer == gestureRecognizer  {
            // 如果己经开始交互, 那就是是独占模式
            guard !isInteractiving else {
                return false
            }
            guard let panGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }
            guard let view = panGestureRecognizer.view, view.superview is BrowseContainterView else {
                return false
            }
            return true
        }
        return false
    }
}

extension BrowseDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        _currentIndex = index
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.browser(self, numberOfItemsInSection: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Asset", for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BrowseDetailViewCell else {
            return
        }
        cell.asset = dataSource?.browser(self, assetForItemAt: indexPath)
        cell.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //dismissHandler(indexPath)
    }
}
