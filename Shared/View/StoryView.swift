//
//  StoryView.swift
//  StoryView
//
//  Created by Michele Manniello on 11/08/21.
//

import SwiftUI

struct StoryView: View {
    @EnvironmentObject var storyData : StoryViewModel
    var body: some View {
        if storyData.showStory{
            TabView(selection: $storyData.currentStory) {
//                Stories..
                ForEach($storyData.stores){ $bundle in
                    StoryCardView(bundle: $bundle)
                        .environmentObject(storyData)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
//            transition from Bottom
            .transition(.move(edge: .bottom))
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct StoryCardView: View {
    
    @Binding var bundle : StoryBundle
    @EnvironmentObject var storyData : StoryViewModel
//    Timer And changing Stories Based On timer...
    @State var timer = Timer.publish(every: 0.1,on: .main, in: .common).autoconnect()
//    progres
    @State var timerProgress: CGFloat = 0
    var body: some View{
        //        For 3D rotation
        GeometryReader{proxy in
            ZStack{
//                Getting Current Index...
//                And updating Data...
                let index = min(Int(timerProgress), bundle.stories.count - 1)
                if let story = bundle.stories[index]{
                    
                    Image(story.imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            tapping...
            .overlay(
                HStack{
                        Rectangle()
                        .fill(.black.opacity(0.01))
                        .onTapGesture {
//                            Checking and updating...
                            if (timerProgress - 1) < 0{
                                updateStory()
                            }else{
                                timerProgress = CGFloat(Int(timerProgress - 1))
                            }
                        }
                    Rectangle()
                    .fill(.black.opacity(0.01))
                    .onTapGesture {
//                        cheking and updating to next...
                        if (timerProgress + 1) > CGFloat(bundle.stories.count){
//                            update to next Bundle...
                            updateStory()
                        }else{
//                            Update to next sotry..
                            timerProgress = CGFloat(Int(timerProgress + 1))
                        }
                    }
                }
            )
    //            close button
            .overlay(
                HStack(spacing:13) {
                    Image(bundle.profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                    Text(bundle.profileName)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    Button(action: {
                        withAnimation {
                            storyData.showStory = false
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    })
                        .padding()
                }
                ,alignment: .topTrailing
            )
//            top Timer Capsule...
            .overlay(
                
                HStack(spacing:5){
                    ForEach(bundle.stories.indices){ index in
                        GeometryReader{proxy in
                            let width = proxy.size.width
//                            getting progress by eliminating current index with progress..
//                            so that remaining all with be at 0 when previous is loading...
//                            Setting max to 1...
//                            Min to 0...
//                            for perfect timer...
                            let progress = timerProgress - CGFloat(index)
                            let perfectProgress = min(max(progress, 0),1)
                            Capsule()
                                .fill(.gray.opacity(0.5))
                                .overlay(
                                    Capsule()
                                        .fill(.white)
                                        .frame(width: width * perfectProgress)
                                    ,alignment: .leading
                                )
                        }
                    }
                }
                .frame(height: 1.4)
                .padding(.horizontal)
                ,alignment: .top
            )
//            Rotation
            .rotation3DEffect(getAngle(proxy: proxy),
                              axis: (x: 0, y: 1, z: 0),
                              anchor: proxy.frame(in: .global).minX > 0 ? .leading: .trailing ,
                              perspective: 2.5)
        }
//        Resetting timer...
        .onAppear(perform: {
            timerProgress = 0
        })
        .onReceive(timer) { _ in
//            Updating Seen Status on Realtime...
            if storyData.currentStory == bundle.id{
                if !bundle.isSeen{
                    bundle.isSeen = true
                }
//                Updating Timer...
                if timerProgress < CGFloat(bundle.stories.count){
                    timerProgress += 0.03
                }else{
                    updateStory()
                }
            }
        }
    }
//    updating OnEnd...
    func updateStory(forward: Bool = false){
        let index = min(Int(timerProgress), bundle.stories.count - 1)
        let story = bundle.stories[index]
        
        if !forward{
//            if its not fisrt then moving backward...
//            else set timer to 0..
            if let first = storyData.stores.first,first.id != bundle.id{
//                get Index...
                let bundleIndex = storyData.stores.firstIndex{ currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                withAnimation {
                    storyData.currentStory = storyData.stores[bundleIndex - 1].id 
                }
            }else{
                timerProgress = 0
            }
            return
        }
        
        if let last = bundle.stories.last,last.id == story.id{
//            if there id another story the moving to that...
//            else closing view...
            if let lastBundle = storyData.stores.last,lastBundle.id == bundle.id{
//                closing...
                withAnimation {
                    storyData.showStory = false
                }
//                timerProgress = 0
            }else{
//                updating to next One...
                let bundleIndex = storyData.stores.firstIndex{ currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                withAnimation {
                    storyData.currentStory = storyData.stores[bundleIndex + 1].id
                }
            }
        }
    }
    func getAngle(proxy: GeometryProxy) -> Angle{
//        converting Offset into 45 Deg ratation...
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        let rotationAngle: CGFloat = 45
        let degress = rotationAngle * progress
        return Angle(degrees: Double(degress))
    }
}
