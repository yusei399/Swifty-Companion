//
//  UserDetailView.swift
//  swift_companion
//
//  Created by yusei ikeda on 2024/03/25.
//

import SwiftUI

// ユーザー詳細を表示するビュー
struct UserDetailView: View {
    let userData: String
    
    var body: some View {
        ScrollView {
            Text(userData)
                .padding()
        }
        .navigationBarTitle("ユーザー詳細", displayMode: .inline)
    }
}
