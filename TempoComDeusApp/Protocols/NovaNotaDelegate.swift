//
//  NovaNotaDelegate.swift
//  TempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 02/09/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.
//

import Foundation

protocol NovaNotaDelegate: class {
    func updateNotas(notas: [Nota])
}

protocol NewNotaDelegate: class {
    func getNota(nota: Nota)
    func getVersos(versos: [Verso])
}
