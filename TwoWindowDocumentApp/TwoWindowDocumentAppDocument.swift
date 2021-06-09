//
//  TwoWindowDocumentAppDocument.swift
//  TwoWindowDocumentApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var myproject: UTType {
        UTType(exportedAs: "com.murasu.myproject")
    }
}

struct MyProjectData: Codable {
    var myTitle     = ""
    var myFilename  = ""
}

struct TwoWindowDocumentAppDocument: FileDocument, Codable {
    var projectData: MyProjectData

    init(p: MyProjectData = MyProjectData()) {
        self.projectData = p
    }

    static var readableContentTypes: [UTType] { [.myproject] }

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents!
        self = try JSONDecoder().decode(Self.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}
