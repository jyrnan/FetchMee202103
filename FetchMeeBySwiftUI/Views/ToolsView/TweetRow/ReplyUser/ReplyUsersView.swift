//
//  ReplyUsersView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ReplyUsersView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var fetchMee: User
    var replyUsers: [String] {viewModel.replyUsers!}
    
    var viewModel: ReplyUserViewModel
    
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        Text("hello")
//        NSAttributedStringView(myCustomAttributedModel: viewModel.attributedString)
//            .border(Color.red)
        
        
//        Group {
//            () -> AnyView in
////            guard !self.replyUsers.isEmpty else {return AnyView(EmptyView())}
//            var replyUsersView = Text("Replying to ").foregroundColor(.gray)
//            for replyUser in self.replyUsers {
//                replyUsersView = replyUsersView
//                + Text(" ")
//                    + Text(replyUser)
//                    .foregroundColor(.accentColor)
//                    }
//            return AnyView(replyUsersView)
//        }
        
    }
}

//struct ReplyUsersView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReplyUsersView(viewModel: ReplyUserViewModel(status: JSON))
//    }
//}




//struct NSAttributedStringView: View {
//
//    var myCustomAttributedModel = MyCustomTextModel()
//        var width: CGFloat
//    var body: some View {
//
//            //Wrapping an UILabel
//        TextWithAttributedString(width: width, attributedString: myCustomAttributedModel.myCustomAttributedString)
//    }
//
//}
//
//struct TextWithAttributedString: UIViewRepresentable {
//    var width: CGFloat
//    var attributedString:NSMutableAttributedString
//
//    func makeUIView(context: Context) -> UILabel {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//
//        return label
//    }
//
//    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<TextWithAttributedString>) {
//
//        uiView.preferredMaxLayoutWidth = width
//        uiView.attributedText = attributedString
//    }
//}
