//
//  StoryViewModel.swift
//  StoryViewModel
//
//  Created by Michele Manniello on 11/08/21.
//

import SwiftUI

class StoryViewModel: ObservableObject{
//    List of Stories..
    @Published var stores : [StoryBundle] = [
        StoryBundle(profileName: "Michele", profileImage: "Pic1", stories: [
            Story(imageURL: "post1"),
            Story(imageURL: "post2"),
            Story(imageURL: "post3")
        ]),
        StoryBundle(profileName: "Alakin", profileImage: "Pic2", stories: [
            Story(imageURL: "post4"),
            Story(imageURL: "post5")
        ])
    ]
//    Properties...
    @Published var showStory : Bool = false
//    Will be unique Story Bundle ID....
    @Published var currentStory: String = ""
}
