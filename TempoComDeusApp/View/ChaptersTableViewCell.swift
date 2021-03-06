//
//  ChaptersTableViewCell.swift
//  tempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 19/08/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.

import UIKit

class ChaptersTableViewCell: UITableViewCell {

    var items: Int? {
        didSet {
            collectionView.reloadData()
        }
    }
    let cellId = "cellId"
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
                         
        let collectionView = UICollectionView(frame: self.contentView.frame, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .backViewColor
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
      }()
    
    var onDidTap: ((_ chapter: Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
      
    func createCell(items: Int) {
        self.items = items
        setupCollection()
    }
    
    func setupCollection() {
        collectionView.register(ChaptersCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        contentView.addSubview(collectionView)
        collectionView.anchor(top: contentView.topAnchor,
                              left: contentView.leftAnchor,
                              bottom: contentView.bottomAnchor,
                              right: contentView.rightAnchor,
                              paddingTop: 0,
                              paddingLeft: 0,
                              paddingBottom: 0,
                              paddingRight: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
extension ChaptersTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
            as? ChaptersCollectionViewCell else { return UICollectionViewCell()}
        cell.createCell(textLabel: "\(indexPath.row + 1)")
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onDidTap?(indexPath.row)
    }
}
