//
//  ComposerMoreView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct ComposerMoreView: View {
    @Binding var isShowCMV: Bool
    
    @State var tweetText: String = "Please input something here..."
    @State var medias: [ImageData] = [ImageData()] {
        didSet {
            
        }
    }
    
    @State var isShowPhotoPicker: Bool = false
    var body: some View {
        NavigationView {
            HStack(alignment: .top) {
                Image(systemName: "person.circle.fill").resizable().aspectRatio(contentMode: .fill).frame(width: 42, height: 42, alignment: .center).padding(.leading, 18).padding(.top, 10)
                VStack {
                    if #available(iOS 14.0, *) {
                        TextEditor(text: self.$tweetText).frame(minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: 200, alignment: .center).padding(.top, 10)
                    } else {
                        // Fallback on earlier versions
                    }
                    Divider()
                    HStack {
                        ForEach(self.medias, id: \.id) {
                            imageData in
                            //                            if imageData.image != nil {
                            //                            PhotoPickerIconView(imageData: self.$medias[(self.medias.firstIndex {imageData.id == $0.id} ?? 0)])
                            //                            }
                            Image(uiImage: (imageData.image ?? UIImage(systemName: "photo"))!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 64, height: 64, alignment: .center).cornerRadius(8)
                                .onTapGesture {
                                    if imageData.image == nil {
                                        self.isShowPhotoPicker = true
                                    } else {
                                        self.medias.remove(at: self.medias.firstIndex {imageData.id == $0.id} ?? 0)
//                                        if self.medias.count == 3 {
//                                            self.medias.append(ImageData())
//                                        }
                                    }
                                }
                                
                                
                                .sheet(isPresented: self.$isShowPhotoPicker,onDismiss: {
                                    if self.medias.count < 4 { self.medias.append(ImageData())}
                                }){PhotoPicker(imageData: self.$medias[self.medias.count - 1], isShowPhotoPicker: self.$isShowPhotoPicker)}
                        }
                        //                        if self.medias.count <= 4 {
                        //                            Text("+ Picture").onTapGesture {
                        //                                self.medias.append(ImageData())
                        //                                self.isShowPhotoPicker = true
                        //                            }
                        //                            .sheet(isPresented: self.$isShowPhotoPicker) {
                        //                                PhotoPicker(imageData: self.$medias[self.medias.count - 1], isShowPhotoPicker: self.$isShowPhotoPicker)
                        //                            }
                        //                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                
            }
            .navigationTitle("Tweet")
        }
        
        
    }
}


struct ComposerMoreView_Previews: PreviewProvider {
    static var previews: some View {
        ComposerMoreView(isShowCMV: .constant(true))
    }
}
