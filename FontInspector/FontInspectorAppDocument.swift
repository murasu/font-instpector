//
//  FontInspectorAppDocument.swift
//  FontInspectorApp
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

struct FontInspectorProject: Codable {  // Document
    var fontFile1Bookmark: Data?
}

struct FontInspectorAppDocument: FileDocument, Codable {
    var fiProject: FontInspectorProject // Document

    init(p: FontInspectorProject = FontInspectorProject()) {
        self.fiProject = p
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
