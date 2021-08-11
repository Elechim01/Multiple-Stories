//
//  StoryBundle.swift
//  StoryBundle
//
//  Created by Michele Manniello on 11/08/21.
//

import SwiftUI
//StoryBundel Model and Sample Stories...
//Storybundle -> Number of stories for each Users....
struct StoryBundle: Identifiable,Hashable {
    var id = UUID().uuidString
    var profileName: String
    var profileImage : String
    var isSeen : Bool = false
    var stories : [Story]
}
struct Story: Identifiable,Hashable {
    var id = UUID().uuidString
    var imageURL : String
}
