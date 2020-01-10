//
//  TutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TutorialVC: UIPageViewController {
    
    var pageControl = UIPageControl()
    
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
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxX - 45, width: 60, height: 30)
        button.titleLabel?.textAlignment = .right
        button.setTitleColor(.systemRed, for: .normal)
        if #available(iOS 13.0, *) {
            button.titleLabel?.backgroundColor = .systemBackground
        } else {
            button.titleLabel?.backgroundColor = .white
        }
        button.addTarget(self, action: #selector(dismissTutorial), for: .touchUpInside)
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
