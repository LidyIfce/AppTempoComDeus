//
//  MainTabBarController.swift
//  tempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 13/08/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: Properties
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        configureUI()
    }
    
    // MARK: Selectors
    
    // MARK: Helpers
        
    func configureUI() {
        tabBar.barTintColor = .backgroundColor
        tabBar.clipsToBounds = true
        tabBar.isTranslucent = false
    }
    func configureViewControllers() {
        let biblia = BibliaViewController()
        let navBiblia = templeteNavigationController(image: UIImage(named: "icon_biblia_unselected"),
                                                     title: "Biblia",
                                                     rootViewController: biblia)

        let notas = NotasViewController()
        let navNotas = templeteNavigationController(image: UIImage(named: "icon_nota_unselected"),
                                                    title: "Anotações", rootViewController: notas)
        
        viewControllers = [navBiblia, navNotas]
        
    }
    
    func templeteNavigationController(image: UIImage?, title: String,
                                      rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.title = title
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .backgroundColor
        return nav
    }

}
