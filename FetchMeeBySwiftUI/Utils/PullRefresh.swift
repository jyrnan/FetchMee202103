//
//  PullRefresh.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/18.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
class RefreshData: ObservableObject {
    @Binding var isDone: Bool
    
    @Published var showText: String
    @Published var showRefreshView: Bool {
        didSet {
            self.showText = "Loading"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if self.showRefreshView {
                    self.showRefreshView = false
                    self.showDone = true
                    self.showText = "Done"
                }
            }
        }
    }
    @Published var pullStatus: CGFloat
    @Published var showDone: Bool {
        didSet {
            if self.showDone && self.isDone {
                self.showDone = false
                self.showText = "Pull to refresh"
            }
            print(self.isDone)
        }
    }
    
    init(isDone:Binding<Bool>) {
        self._isDone = isDone
        self.showText = "Pull to refresh"
        self.showRefreshView = false
        self.pullStatus = 0
        self.showDone = false
    }
}


@available(iOS 13.0, macOS 10.15, *)
struct Spinner: View {
    @Binding var percentage: CGFloat
    
    var body: some View {
        GeometryReader{ geometry in
            ForEach(1...10, id: \.self) { i in
                Rectangle()
                    .fill(Color.gray)
                    .cornerRadius(1)
                    .frame(width: 2.5, height: 8)
                    .opacity(self.percentage * 10 >= CGFloat(i) ? Double(i)/10.0 : 0)
                    .offset(x: 0, y: -8)
                    .rotationEffect(.degrees(Double(36 * i)), anchor: .bottom)
            }.offset(x: 20, y: 12)
        }.frame(width: 40, height: 40)
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct PullToRefreshView<Content: View>: View {
    let content: () -> Content
    let action: () -> Void
    @Binding var isDone: Bool
    @ObservedObject var data: RefreshData
    init(action: @escaping () -> Void,isDone: Binding<Bool> ,@ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
        self._isDone = isDone
        self.data = RefreshData(isDone: isDone)
    }
    
    var body: some View {
        GeometryReader{ geometry in
            //            RefreshView(data: self.data)
            self.content()
                .opacity(Double(185 - (geometry.frame(in: CoordinateSpace.global).origin.y)) / 20) //根据下拉距离来改变透明度
                .preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(bounds: geometry.frame(in: CoordinateSpace.global))])
            //                .offset(y: -70)
        }
        .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
            guard let bounds = values.first?.bounds else { return }
            self.data.pullStatus = CGFloat((bounds.origin.y - 106) / 80)
            self.refresh(offset: bounds.origin.y)
        }
    }
    
    func refresh(offset: CGFloat) {
        if offset > 185 && self.isDone == true
//            && !self.data.showRefreshView
//            && !self.data.showDone
        {
//            self.data.showRefreshView = true
            self.isDone = false //必须在这里设置才能确保段时间内只执行一次
            DispatchQueue.main.async {
                self.action()
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, *) //做成SWiftUI的
struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.stopAnimating() : uiView.startAnimating()
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct RefreshableKeyTypes {
    
    struct PrefData: Equatable {
        let bounds: CGRect
    }

    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []

        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }

        typealias Value = [PrefData]
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner(percentage: .constant(1))
    }
}

