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
    @State var medias: [ImageData] = [] {
        didSet {
            
        }
    }
    
    @State var isShowPhotoPicker: Bool = false
    @State var isShowAddPic: Bool = true
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                HStack(alignment: .top) {
                    Image(systemName: "person.circle.fill").resizable().aspectRatio(contentMode: .fill).frame(width: 42, height: 42, alignment: .center).padding(.leading, 18).padding(.top, 10)
                    VStack {
                        
                        TextEditor(text: self.$tweetText).frame(minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: 200, alignment: .center).padding(.top, 10)
                        
                        Divider()
                        HStack {
                            ForEach(self.medias, id: \.id) {
                                imageData in
                                Image(uiImage: (imageData.image ?? UIImage(systemName: "photo"))!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64, alignment: .center).cornerRadius(8)
                                    .onTapGesture {
                                        //点击图片则删除该图片数据
                                            self.medias.remove(at: self.medias.firstIndex {imageData.id == $0.id} ?? 0)
                                        //删除图片后将增加图片的按钮显示出来
                                            self.isShowAddPic = true
                                        
                                    }
                            }
                            if self.isShowAddPic {
                                Text("+ Picture").onTapGesture {
                                    self.medias.append(ImageData())
                                    self.isShowPhotoPicker = true
                                }
                                .sheet(isPresented: self.$isShowPhotoPicker, onDismiss: {
                                    if self.medias.count == 4 { //选择图片视图消失后检查是否已经有四张选择，如果是则设置增加图片按钮不显示
                                        self.isShowAddPic = false
                                    }
                                    if self.medias.last?.image == nil {
                                        self.medias.removeLast() //如果选择图片的时候选择了取消，也就是最后一个图片数据依然是nil，则移除该数据
                                    }
                                }) {
                                    PhotoPicker(imageData: self.$medias[self.medias.count - 1], isShowPhotoPicker: self.$isShowPhotoPicker)
                                }
                            }
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .navigationTitle("Tweet")
            } else {
                // Fallback on earlier versions
            }
        }
          
    }
}


struct ComposerMoreView_Previews: PreviewProvider {
    static var previews: some View {
        ComposerMoreView(isShowCMV: .constant(true))
    }
}
