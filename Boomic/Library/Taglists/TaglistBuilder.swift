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
    var art: MediaArt?
    private var useBuilder: Bool
    
    var editing: Bool = false {
        didSet {
            if editing == false {
                positiveRules = positiveRules.filter { !$0.isEmpty }
                negativeRules = negativeRules.filter { !$0.isEmpty }
            }
        }
    }
    
    let new: Bool
    let forTagView: Bool
    
    func builderSongs(from songs: [Song]) async -> [Song] {
        if useBuilder {
            songs.filter { song in
                Taglist.evaluate(song.tags, onPositiveRules: self.positiveRules, onNegativeRules: self.negativeRules)
            }
        } else {
            songs.filter { song in
                baseTaglist.evaluate(song.tags)
            }
        }
    }
    
    init(
        _ taglist: Taglist
        , new: Bool = false
        , forTagView: Bool = false
    ) {
        self.title = taglist.title
        self.baseTaglist = taglist
        self.positiveRules = taglist.positiveRules
        self.negativeRules = taglist.negativeRules
        self.art = taglist.art
        self.new = new
        self.forTagView = forTagView
        self.editing = new ? true : false
        self.useBuilder = false
    }
    
    public func asNewTaglist() -> Taglist {
        Taglist(
            title: title
            , positiveRules: positiveRules
            , negativeRules: negativeRules
            , songs: []
            , art: art
        )
    }
    
    public func asTaglistUpdate() -> TaglistUpdate {
        let base = baseTaglist
        let newTitle = base.title != self.title ? self.title : nil
        let newPositiveRules = base.positiveRules != self.positiveRules ? self.positiveRules : nil
        let newNegativeRules = base.negativeRules != self.negativeRules ? self.negativeRules : nil
        let newArt = base.art != self.art ? self.art : nil
                
        return TaglistUpdate(
            taglist: baseTaglist
            , newTitle: newTitle
            , positiveRules: newPositiveRules
            , negativeRules: newNegativeRules
            , art: newArt
        )
    }
    
    public var disableSave: Bool {
        title == "" || (positiveRules.hasNoRules && negativeRules.hasNoRules) || !self.asTaglistUpdate().willModify(baseTaglist)
    }
}
