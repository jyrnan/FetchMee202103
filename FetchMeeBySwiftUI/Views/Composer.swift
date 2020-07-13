//
//  Composer.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Composer: View {
    @Binding var presentedModal: Bool
    
    var body: some View {
        Button("Dismiss") {self.presentedModal = false}
    }
}

struct Composer_Previews: PreviewProvider {
    static var previews: some View {
        Composer(presentedModal: .constant(true))
    }
}
