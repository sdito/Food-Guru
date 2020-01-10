//
//  TutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TutorialVC: UIPageViewController {
    let button = UIButton()
    private var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        
        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        
    }
    
    
    
    lazy var pages: [UIViewController] = {
        return [self.newVc(viewController: "One"),
                self.newVc(viewController: "Two"),
                self.newVc(viewController: "Three"),
                self.newVc(viewController: "Four"),
                self.newVc(viewController: "Five"),
                self.newVc(viewController: "Six")
        ]
    }()
    
    private func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    private func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 45, width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = .black
        self.pageControl.pageIndicatorTintColor = .white
        self.pageControl.currentPageIndicatorTintColor = .black
        self.view.addSubview(pageControl)
        
        
        #warning("need to fix this mess of a way to exit the tutorial screen")
        
        button.setTitle("Done", for: .normal)
        let font = UIFont(name: "futura", size: 20)
        button.titleLabel?.font = font
        let size = "Done".sizeForText(font: font!)
        let padding: CGFloat = 8.0
        button.clipsToBounds = true
        button.frame = CGRect(x: (UIScreen.main.bounds.width - (size.width * 1.5)) ,y: UIScreen.main.bounds.maxY - 45, width: size.width + padding,height: size.height)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: padding/2, bottom: 0.0, right: padding/2)
        button.titleLabel?.widthAnchor.constraint(equalToConstant: size.width + padding).isActive = true
        button.setTitleColor(.systemRed, for: .normal)
        if #available(iOS 13.0, *) {
            button.titleLabel?.backgroundColor = .systemBackground
        } else {
            button.titleLabel?.backgroundColor = .white
        }
        button.addTarget(self, action: #selector(dismissTutorial), for: .touchUpInside)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.borderWidth = 1.0
        button.titleLabel?.textAlignment = .center
        self.view.addSubview(button)
    }
    
    @objc private func dismissTutorial() {
        print("dismissTutorial was called")
        self.dismiss(animated: true, completion: nil)
    }
}



extension TutorialVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return pages.last }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return pages.first }
        guard pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = pages.firstIndex(of: pageContentViewController)!
        
        
    }
    
}




