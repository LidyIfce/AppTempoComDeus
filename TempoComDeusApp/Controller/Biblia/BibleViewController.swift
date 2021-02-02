//
//  BibleViewController.swift
//  tempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 13/08/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.
//

import UIKit

class BibleViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    let dataPicker = DataPicker.data()
    let cellId = "CellId"
    let defaults = UserDefaults.standard
    var version: String = NVI
    var abbrev: String = "gn"
    let bible = Bible()
    var allBooks: [BookResume] = []
    var widthTitleButtonConstraint: NSLayoutConstraint?
    
    var fonteSize: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    var chapter: Int = 0 {
        didSet {
            showHiddenArrowsLeftRight()
            updateDefaultValues()
            updateButtonTitle()
            tableView.reloadData()
        }
    }
    
    var actualBook: BookResume? {
        didSet {
            updateDefaultValues()
            updateButtonTitle()
            showHiddenArrowsLeftRight()
            tableView.reloadData()
        }
    }
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blueAct
        button.setTitle("", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.tintColor = .white
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(showBooks), for: .touchUpInside)
        return button
    }()
    
    lazy var versionButton: UITextField = {
        let button = UITextField()
        button.backgroundColor = .blueAct
        button.text = ""
        button.textColor = .white
        button.tintColor = .clear
        button.textAlignment = .center
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setDimensions(width: 40, height: 30)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .backViewColor
        tableView.layer.cornerRadius = 8
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.alwaysBounceVertical = false
        tableView.alwaysBounceHorizontal = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var leftSwipeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "left"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(leftSwipe), for: .touchUpInside)
        button.setDimensions(width: 20, height: 20)
        return button
    }()
    
    lazy var rightSwipeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "right"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(rightSwipe), for: .touchUpInside)
        button.setDimensions(width: 20, height: 20)
        return button
    }()
    
    lazy var picker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .backgroundColor
        pickerView.isUserInteractionEnabled = true
        return pickerView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultsValues()
        abbrev = getDefaultAbbrev()
        version = getDefaultVersion()
        chapter = getDefaultChapter()
        
        allBooks = File().readBibleByVersion(version: version)
        bible.books = File().readBiblia()
       
        fonteSize = UserDefaults.standard.integer(forKey: FONTSIZE)
       
        actualBook = getActualBook(abbreviation: abbrev)
        versionButton.delegate = self
        updateTitleWidthConstraint()
        configureUI()
        setupTableView()
        setupPicker()
        setupButtonsNav()
        setupSwipeGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fonteSize = UserDefaults.standard.integer(forKey: FONTSIZE)
    }
    
    // MARK: Selectors
    
    @objc func showBooks() {
        let livrosTableView = BooksTableViewController()
        livrosTableView.delegate = self
        self.present(livrosTableView, animated: true)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
            case .right:
                leftSwipe()
            case .left:
                rightSwipe()
            default:
                break
            }
        }
    }
    
    // next
    @objc func rightSwipe() {
        for (ind, book) in bible.books.enumerated() where abbrev == book.abbrev["pt"] {
            if chapter <  (book.chapters ?? 0) - 1 {
                chapter += 1
                break
            } else if ind < (bible.books.count - 1) {
                self.chapter = 0
                abbrev = allBooks[ind + 1].abbrev
                actualBook = getActualBook(abbreviation: abbrev)
                break
            }
        }
        tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
    }
    
    // voltar
    @objc func leftSwipe() {
        for (ind, book) in bible.books.enumerated() where abbrev == book.abbrev["pt"] {
            if chapter > 0 {
                chapter -= 1
                break
            } else if ind > 0 {
                abbrev = allBooks[ind - 1].abbrev
                actualBook = getActualBook(abbreviation: abbrev)
                chapter = (actualBook?.chapters.count ?? 0) - 1
                break
            }
        }
        tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
    }
    
    // MARK: Helpers
    
    private func configureUI() {
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .backgroundColor
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .backgroundColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: versionButton)
    }
    
    func updateTitleWidthConstraint() {
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        widthTitleButtonConstraint?.isActive = false
        let buttonTitle = "\(getTitleName())"  + " " + "\((self.chapter ) + 1)"
        widthTitleButtonConstraint =
            titleButton.widthAnchor.constraint(equalToConstant: CGFloat(buttonTitle.count * 10 + 20))
        widthTitleButtonConstraint?.isActive = true
    }
    
    func getTitleName() -> String {
        for data in bible.books where data.abbrev["pt"] == actualBook?.abbrev {
            return data.name
        }
        
        return ""
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        false
    }
    
    func getActualBook(abbreviation: String) -> BookResume? {
        allBooks.filter {$0.abbrev == abbreviation}.first ?? nil
    }
    
    private func setupSwipeGestures() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        view.addGestureRecognizer(rightSwipe)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
    }
    
    private func setupDefaultsValues() {
        if defaults.object(forKey: ABBR) != nil { } else {
            defaults.set("gn", forKey: ABBR)
        }
        
        if defaults.object(forKey: VERSION) != nil { } else {
            defaults.set(NVI, forKey: VERSION)
        }
        
        if defaults.object(forKey: CHAPTER) != nil { } else {
            defaults.set(0, forKey: CHAPTER)
        }
    }
    
    private func getDefaultChapter() -> Int {
        defaults.integer(forKey: CHAPTER)
    }
    private func getDefaultAbbrev() -> String {
        defaults.string(forKey: ABBR) ?? "gn"
    }
    private func getDefaultVersion() -> String {
        defaults.string(forKey: VERSION) ?? NVI
    }
    
    private func updateDefaultValues() {
        defaults.set(abbrev, forKey: ABBR)
        defaults.set(chapter, forKey: CHAPTER)
        defaults.set(version, forKey: VERSION)
    }
    
    private func showHiddenArrowsLeftRight() {
        if actualBook?.abbrev == "gn" && chapter == 0 {
            leftSwipeButton.isEnabled = false } else {
            leftSwipeButton.isEnabled = true
        }
        
        if actualBook?.abbrev == "ap" && chapter == 21 {
            rightSwipeButton.isEnabled = false} else {
            rightSwipeButton.isEnabled = true
        }
    }
    
    private func updateButtonTitle() {
        let buttonTitle = "\(getTitleName())"  + " " + "\((self.chapter ) + 1)"
        titleButton.setTitle(buttonTitle, for: .normal)
        let versionButtonTitle = version.uppercased()
        versionButton.text = versionButtonTitle
        updateTitleWidthConstraint()
    }
    
    private func setupButtonsNav() {
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        titleButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let stackView = UIStackView(arrangedSubviews: [leftSwipeButton, titleButton, rightSwipeButton])
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        navigationItem.titleView = stackView
    }
}