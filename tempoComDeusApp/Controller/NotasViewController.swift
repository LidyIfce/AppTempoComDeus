//
//  NotasViewController.swift
//  tempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 13/08/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.
//

import UIKit

class NotasViewController: UIViewController {

    // MARK: Properties
    var collectionView : UICollectionView?
    var notas :[Notas] = []{
        didSet{
            initialLabel.text = " "
            collectionView?.reloadData()
            
        }
    }
    
    let initialLabel: UILabel = {
        var label = UILabel()
        label.text = "Clique + para adicionar uma nova anotação."
        label.textColor = .myGray
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let leftButton: UIButton = {
        var button = UIButton()
        let img = UIImage(named: "plus")
        button.setImage(img, for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.setDimensions(width: 20, height: 20)
        return button
    }()
    
    let navTitle: UILabel = {
        var label = UILabel()
        label.text = "Anotações"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
     let backView = BackView()
         
      // MARK: Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addBackground()
        addTextInicial()
        notas = Notas.mock()
       
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
         
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionView?.register(NotasCollectionViewCell.self, forCellWithReuseIdentifier: "notasCell")
        
        collectionView?.backgroundColor = .clear
      
        collectionView?.delegate = self
        collectionView!.dataSource = self
      
        view.insertSubview(collectionView ?? UICollectionView(), at: 1)
        
       // adicionarHeader()
          // Do any additional setup after loading the view.
      }
      
      // MARK: Selectors
       
       
       // MARK: Helpers
      
      func configureUI(){
    
        navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = .blueBackgroud
        navigationItem.title = "Anotações"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = .blueAct
    }

    func addTextInicial(){
        backView.addSubview(initialLabel)
        initialLabel.anchor(left: backView.leftAnchor, right: backView.rightAnchor,paddingLeft: 16, paddingRight: 16)
        initialLabel.centerY(inView: backView)
    }
    
    func addBackground(){
         
          let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = (window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (navigationController?.navigationBar.frame.height ?? 0 )
          let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
          view.insertSubview(backView, at: 0)
          backView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: statusBarHeight, paddingLeft: 8, paddingBottom: tabBarHeight, paddingRight: 8)
      }
    
    func adicionarHeader(){
          
          let window = UIApplication.shared.windows.first { $0.isKeyWindow }
          let top: CGFloat = window?.safeAreaInsets.top ?? 44
          
         let stackView = UIStackView(arrangedSubviews: [UIView(), navTitle, leftButton])
         stackView.distribution = .equalCentering
       
         
         backView.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: top + 8, paddingLeft: 0, paddingRight: 24)
     }


}

extension NotasViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        notas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "notasCell", for: indexPath) as! NotasCollectionViewCell
        myCell.createCell(text: notas[indexPath.row].text, date: notas[indexPath.row].date)
        return myCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth =  collectionView.frame.width / 2 - 15
        let cellHeigth = collectionView.frame.height / 5 - 10
        return CGSize(width: cellWidth, height: cellHeigth)
    }
    
}
