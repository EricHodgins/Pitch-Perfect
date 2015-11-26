//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Eric Hodgins on 2015-11-21.
//  Copyright © 2015 Eric Hodgins. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}
