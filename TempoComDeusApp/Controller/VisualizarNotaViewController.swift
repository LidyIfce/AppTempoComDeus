//
//  VisualizarNotaViewController.swift
//  tempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 14/08/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.
//

import UIKit

class VisualizarNotaViewController: UIViewController {
    // MARK: Properties
    
    weak var delegate: UpdateNotaDelegate?
    
    var backView = BackView()
    private let notaRepository: NotaRepository
    private let notaID: UUID
    private var nota: Nota {
        didSet {
            textView.text = nota.body
            backView.backgroundColor = .getColor(name: nota.cor)
        }
    }
        
    let textView: UITextView = {
           let text = UITextView()
           text.allowsEditingTextAttributes = false
           text.isEditable = false
           text.textAlignment = .left
           text.backgroundColor = .clear
           text.showsVerticalScrollIndicator = false
           text.textColor = .label
           text.font = UIFont.systemFont(ofSize: 20)
           return text
         }()
    
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.tintColor = .blueAct
        button.addTarget(self, action: #selector(editNota), for: .touchUpInside)
        return button
    }()
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.tintColor = .blueAct
        button.addTarget(self, action: #selector(shareNota), for: .touchUpInside)
        return button
    }()
    
       // MARK: Lifecycle
       override func viewDidLoad() {
            super.viewDidLoad()
            configureUI()
            addBackView()
            addTextView()
            addStackViewButtons()
            setFonteSize()
       }
    
    init(notaRepository: NotaRepository, notaId: UUID) {
        self.notaRepository = notaRepository
        self.notaID = notaId
        self.nota = notaRepository.readItem(itemId: notaID) ?? Nota(body: nil, cor: nil, versos: [])
        textView.text = nota.body
        backView.backgroundColor = .getColor(name: nota.cor)
              
        super.init(nibName: nil, bundle: nil)
    }
   
       required init?(coder aDecoder: NSCoder) {
           fatalError("We aren't using storyboards")
       }
       
       // MARK: Selectors
        @objc  func editNota() {
            let notaViewController = CriarEditarNota(notaRepository: notaRepository, notaId: notaID, acao: .editar)
            notaViewController.modalPresentationStyle = .fullScreen
            notaViewController.notadelegate = self
            self.present(notaViewController, animated: true)
         }
        @objc func shareNota() {
            let viewActivity = UIActivityViewController(activityItems: [nota.body], applicationActivities: [])
            self.present(viewActivity, animated: true)
        }
        // MARK: Helpers
       
       func configureUI() {
        navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = .backgroundColor
       }
    
    private func addBackView() {
        view.insertSubview(backView, at: 0)
      backView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                      left: view.leftAnchor,
                      bottom: view.safeAreaLayoutGuide.bottomAnchor,
                      right: view.rightAnchor,
                      paddingTop: 0 ,
                      paddingLeft: 8,
                      paddingBottom: 0,
                      paddingRight: 8)
    }
    
    private func addStackViewButtons() {
        let stackButtons = UIStackView(arrangedSubviews: [editButton, shareButton])
        stackButtons.distribution = .equalSpacing
        stackButtons.spacing = 20
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackButtons)
    }
    
    func addTextView() {
        backView.addSubview(textView)
        textView.anchor(top: backView.topAnchor,
                        left: backView.leftAnchor,
                        bottom: backView.bottomAnchor,
                        right: backView.rightAnchor,
                        paddingTop: 20,
                        paddingLeft: 16,
                        paddingBottom: 20,
                        paddingRight: 16)
        
    }
    
    func setFonteSize() {
        if UserDefaults.standard.object(forKey: FONTSIZE) != nil {} else {
            UserDefaults.standard.set(17, forKey: FONTSIZE)
        }
        let fonteSize: Int? = UserDefaults.standard.integer(forKey: FONTSIZE)
        if let fonteSize = fonteSize {
            textView.font = UIFont.systemFont(ofSize: CGFloat(fonteSize))
        }
    }
}

extension VisualizarNotaViewController: NotaDelegate {

    func didChange(body: String, cor: String, notaId: UUID) {
        nota.body = body
        nota.cor = cor
        notaRepository.update(item: nota)
        nota = notaRepository.readItem(itemId: notaId) ?? Nota(body: nil, cor: nil, versos: [])
        self.delegate?.notaIsUpdated(updated: true)
    }

}
