//
//  FakeStatusRow.swift
//  FetchMee
//
//  Created by jyrnan on 2021/7/13.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI

struct FakeStatusRow: View {
    @EnvironmentObject var store: Store
    
    var box: some View {
        Rectangle()
            .frame(height: 16)
            .foregroundColor(.secondary)
            .opacity(0.4)
    }
    
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(user: store.repository.getUser(byID: "0000"), width: 36, height: 36)
                .opacity(0.3)
            Spacer()
        }
        .frame(width:store.appState.setting.userSetting?.uiStyle.avatarWidth )
    }
    
    var nameAndcreated: some View {
        HStack{ box; Spacer(); box;  box }
    }
    
    var text: some View {
        VStack(alignment: .leading) {
            box
            box
            box
            box.frame(width: 200)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
                HStack(alignment: .top) {
                    avatar
                VStack(alignment: .leading){
                    nameAndcreated
                    text
                }
                
            }
            
            
        }
        .padding()
    }
}

struct FakeStatusRow_Previews: PreviewProvider {
    static var previews: some View {
        FakeStatusRow()
            .environmentObject(Store())
    }
}
