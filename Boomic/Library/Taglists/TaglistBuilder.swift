//
//  TaglistBuilder.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/20/24.
//

import Foundation
import Models

@Observable
final class TaglistBuilder {
    var baseTaglist: Taglist
    var title: String
    var positiveRules: [TagRule]
    var negativeRules: [TagRule]
    
    var editing: Bool = false {
        didSet {
            if editing == false {
                positiveRules = positiveRules.filter { !$0.isEmpty }
                negativeRules = negativeRules.filter { !$0.isEmpty }
            }
        }
    }
    
    let new: Bool
    let subLibraryMode: Bool
    
    init(
        _ taglist: Taglist
        , new: Bool = false
        , forSubLibrary subLibraryMode: Bool = false
    ) {
        self.title = taglist.title
        self.baseTaglist = taglist
        self.positiveRules = taglist.positiveRules
        self.negativeRules = taglist.negativeRules
        self.new = new
        self.subLibraryMode = subLibraryMode
        self.editing = new ? true : false
    }
    
    public func asNewTaglist() -> Taglist {
        Taglist(
            title: title
            , positiveRules: positiveRules
            , negativeRules: negativeRules
            , songs: []
        )
    }
    
    public func asTaglistUpdate() -> TaglistUpdate {
        let base = baseTaglist
        let newTitle = base.title != self.title ? self.title : nil
        let newPositiveRules = base.positiveRules != self.positiveRules ? self.positiveRules : nil
        let newNegativeRules = base.negativeRules != self.negativeRules ? self.negativeRules : nil
                
        return TaglistUpdate(
            taglist: baseTaglist
            , newTitle: newTitle
            , positiveRules: newPositiveRules
            , negativeRules: newNegativeRules
        )
    }
    
    public var disableSave: Bool {
        title == "" || (positiveRules.hasNoRules && negativeRules.hasNoRules)
    }
}
