//
//  CreateAndEditNoteViewController.swift
//  tempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 15/08/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.

import UIKit
import CoreData
class CreateAndEditNoteViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Properties
    private let action: Action
    private let service: CoreDataService!
    private var stackViewHeader: UIStackView!
    private var stackViewBottom: UIStackView!
    var verse: Verse?
    var onUpdateNotes: (() -> Void)?

    private var noteViewModel: NoteViewModel? {
        didSet {
            textView.text = noteViewModel?.text
            textView.backgroundColor = .getColor(number: Int(noteViewModel?.color ?? 1))
        }
    }
    
    private var color: Int16 = 1 {
        didSet {
            switch action {
            case .create: break
            case .edit:
                self.saveButton.isEnabled = !(self.textView.text == noteViewModel?.text &&
                                                color == noteViewModel?.color)
            }
        }
    }
    
    lazy var textView: UITextView = {
        let text = UITextView()
        text.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        text.isEditable = true
        text.textAlignment = .left
        text.font = UIFont.systemFont(ofSize: 20)
        text.textColor = .label
        text.layer.cornerRadius = 8
        text.clipsToBounds = true
        text.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return text
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancelar", for: .normal)
        button.setTitleColor(.blueAct, for: .normal)
        button.addTarget(self, action: #selector(cancelar), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Salvar", for: .normal)
        button.setTitleColor(.blueAct, for: .normal)
        button.setTitle("", for: .disabled)
        button.isEnabled = false
        button.addTarget(self, action: #selector(salvar), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    init(service: CoreDataService?, noteViewModel: NoteViewModel?, action: Action) {
        self.service = service
        self.action = action
        if let noteViewModel = noteViewModel {
            self.noteViewModel = noteViewModel
            self.color = noteViewModel.color
        }
        super.init(nibName: nil, bundle: nil)
        
        if let noteViewModel = noteViewModel, action == .create {
            self.textView.text = noteViewModel.text
            self.saveButton.isEnabled = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("We aren't using storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardHiden),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        view.layoutIfNeeded()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        self.textView.becomeFirstResponder()
    }
    
    // MARK: Selectors
    
    @objc func tapDone(sender: UITextView) {
        textView.resignFirstResponder()
    }
    
    @objc func cancelar() {
        switch action {
        case .create:
            if let text = textView.text, text.isEmpty {
                self.dismiss(animated: true, completion: nil)
            } else { displayActionSheet() }
        case .edit:
            if  textView.text == noteViewModel?.text && color == noteViewModel?.color {
                    self.dismiss(animated: true, completion: nil)
            } else { displayActionSheet() }
        }
    }
    
    @objc func salvar() {
        
        if let noteViewModel = noteViewModel {
            noteViewModel.updateNote(text: textView.text, color: color)
        } else {
            noteViewModel = NoteViewModel(service: service, text: textView.text, color: color)
        }
        if let verse = verse, let noteViewModel = noteViewModel {
            noteViewModel.setKeyVerse(
                keyVerse: verse.abbreviation + "\(verse.chapterNumber)-\(verse.verseNumber)-note")
            verse.updateNoteId(noteId: noteViewModel.noteId)
            UserDefaultsPersistence.shared.setNoteId(verse: verse)
        }
        onUpdateNotes?()
        textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changeColor(_ sender: UIButton) {
        guard let noteColor = sender.backgroundColor else { return }
        textView.backgroundColor = noteColor
        self.color = Int16(MyColors.getColorNumber(color: noteColor.cgColor))
    }
    
    @objc func keyboardHiden(notification: NSNotification) {
        if let duration =  notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: duration) {
                self.view.frame = UIScreen.main.bounds
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                                NSValue)?.cgRectValue {
            if let duracao = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                
                UIView.animate(withDuration: duracao) {
                    self.view.frame = CGRect(
                        x: UIScreen.main.bounds.origin.x,
                        y: UIScreen.main.bounds.origin.y,
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height - keyboardSize.height
                    )
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: Helpers
    
    private func configureUI() {
        navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = .backgroundColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        
        addStackHeader()
        addStackBottom()
        addTextView()
        setFonteSize()
    }
    
    private func createButtonCor(cor: Int) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .getColor(number: cor)
        button.layer.borderWidth = 0.3
        button.layer.borderColor = UIColor.black.cgColor
        button.setDimensions(width: 32, height: 32)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        addShadowing(view: button)
        return button
    }
    
    func addShadowing(view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    func addStackHeader() {
        stackViewHeader = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stackViewHeader.distribution = .equalSpacing
        view.addSubview(stackViewHeader)
        stackViewHeader.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               left: view.leftAnchor,
                               right: view.rightAnchor,
                               paddingTop: 0,
                               paddingLeft: 8,
                               paddingRight: 8)
    }
    
    func addTextView() {
        textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        textView.text = noteViewModel?.text
        textView.backgroundColor = .getColor(number: Int(noteViewModel?.color ?? 1))
        textView.delegate = self
        view.addSubview(textView)
        textView.anchor(top: stackViewHeader.bottomAnchor,
                        left: view.leftAnchor,
                        bottom: stackViewBottom.topAnchor,
                        right: view.rightAnchor,
                        paddingTop: 8,
                        paddingLeft: 8,
                        paddingBottom: 8,
                        paddingRight: 8)
    }
    
    func setFonteSize() {
        let fontSize = UserDefaultsPersistence.shared.getDefaultFontSize()
        textView.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    func addStackBottom() {
        var arrangedButtons: [UIButton] = []
        for number in 1...5 {
            let buttonColor = createButtonCor(cor: number)
            buttonColor.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
            arrangedButtons.append(buttonColor)
        }
        arrangedButtons.append(UIButton())
        stackViewBottom = UIStackView(arrangedSubviews: arrangedButtons)
        stackViewBottom.alignment = .leading
        stackViewBottom.spacing = 10
      
        view.addSubview(stackViewBottom)
        stackViewBottom.anchor(
                               left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               right: view.rightAnchor,
                               
                               paddingLeft: 16,
                               paddingBottom: 16,
                               paddingRight: 16)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.textView {
            switch action {
            case .create:
                self.saveButton.isEnabled = !textView.text.isEmpty
            case .edit:
                self.saveButton.isEnabled = !(self.textView.text == noteViewModel?.text &&
                                                color == noteViewModel?.color)
            }
        }
    }
    
    func displayActionSheet() {
        let menu = UIAlertController(title: nil, message: "Descartar alterações?", preferredStyle: .actionSheet)
        let deleteAtion = UIAlertAction(title: "Descartar", style: .destructive, handler: { _ in
            if self.action == .create {
                self.service.delete(noteModel: self.noteViewModel?.note)
            }
            self.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        menu.addAction(deleteAtion)
        menu.addAction(cancelAction)
        self.present(menu, animated: true, completion: nil)
        menu.removeErrorConstraints()
    }
}
