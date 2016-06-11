//
//  menuBar.swift
//  
//
//  Created by Wassim Seifeddine on 12/5/15.
//
//

import UIKit


@objc protocol menuBarDelegate{
    func menuBarDidSelectButtonAtIndex(index : Int)
    optional func menuBarWillClose()
    optional func menuBarWillOpen()
    
}
class menuBar: NSObject, menuBarTableViewControllerDelegate {
    
    let barWidth : CGFloat = 150.0
    let menuBarTableViewTopInset : CGFloat = 64.0
    let menuBarContainerView : UIView = UIView()
    let menuBarTableViewControllerInstance : menuBarTableViewController = menuBarTableViewController()
    var originView : UIView!
   
    
    var animator : UIDynamicAnimator!
    var delegate : menuBarDelegate?
    var isMenuBarOpen : Bool = false
    override init() {
        super.init()
        
    }
    
    
    
    init(sourceView : UIView, menuItems : Array<String>) {
        super.init()
        originView = sourceView
        menuBarTableViewControllerInstance.tableData = menuItems
        
        setupMenuBar()
        animator = UIDynamicAnimator(referenceView: originView)
        
        
        let showGestureRecognizer : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        originView.addGestureRecognizer(showGestureRecognizer)
        
        
        let hideGestureRecognizer : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        originView.addGestureRecognizer(hideGestureRecognizer)

        
    }
    
    func setupMenuBar(){

        menuBarContainerView.frame = CGRectMake(-barWidth - 1 , originView.frame.origin.y , barWidth, originView.frame.size.height)
        menuBarContainerView.backgroundColor = UIColor.clearColor()
        menuBarContainerView.clipsToBounds = false
        originView.addSubview(menuBarContainerView)
        
        
        
        let blurView : UIVisualEffectView  = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = menuBarContainerView.bounds
        menuBarContainerView.addSubview(blurView)
        
        
        menuBarTableViewControllerInstance.delegete = self
        menuBarTableViewControllerInstance.tableView.frame = menuBarContainerView.bounds
        menuBarTableViewControllerInstance.tableView.clipsToBounds = false
        menuBarTableViewControllerInstance.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        menuBarTableViewControllerInstance.tableView.backgroundColor = UIColor.clearColor()
        menuBarTableViewControllerInstance.tableView.scrollsToTop = false
        menuBarTableViewControllerInstance.tableView.contentInset = UIEdgeInsetsMake(menuBarTableViewTopInset, 0, 0, 0)
        
        menuBarTableViewControllerInstance.tableView.reloadData()
        menuBarContainerView.addSubview(menuBarTableViewControllerInstance.tableView)
        
    }
    
    func handleSwipe(recognizer : UISwipeGestureRecognizer){
        
        
        
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left {
            
            showMenuBar(false)
            delegate?.menuBarWillClose?()
        }else{
            
          
            showMenuBar(true)
            delegate?.menuBarWillOpen?()
        }
        
        
    }
    
    
    func showMenuBar(shouldOpen: Bool){
        
        animator.removeAllBehaviors()
        isMenuBarOpen = shouldOpen
        
        let gravityX : CGFloat = (shouldOpen) ? 0.5 : -0.5
        let magnitude : CGFloat = (shouldOpen) ? 20 : -20
        let boundaryX : CGFloat = (shouldOpen) ? barWidth : -barWidth - 1
        
        
        let gravityBehavoir : UIGravityBehavior  = UIGravityBehavior(items: [menuBarContainerView])
        gravityBehavoir.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavoir)
        
        
        let collisionBehavoir : UICollisionBehavior  = UICollisionBehavior(items: [menuBarContainerView])
        collisionBehavoir.addBoundaryWithIdentifier("menuBarBoundary", fromPoint:  CGPointMake(boundaryX , 20), toPoint:  CGPointMake(boundaryX, originView.frame.size.height))
        
        animator.addBehavior(collisionBehavoir)
        
        
        let pushBehavoir : UIPushBehavior = UIPushBehavior(items: [menuBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavoir.magnitude = magnitude
        animator.addBehavior(pushBehavoir)
        
        
        let menuBarBehavoir : UIDynamicItemBehavior = UIDynamicItemBehavior(items: [menuBarContainerView])
        menuBarBehavoir.elasticity = 0.3
        animator.addBehavior(menuBarBehavoir)
        
        
        
    }
  

    
    func menuBarControllerDidSelectRow(indexPath: NSIndexPath) {
        
        delegate?.menuBarDidSelectButtonAtIndex(indexPath.row)
    }

}
