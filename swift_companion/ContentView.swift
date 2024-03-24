//
//  ContentView.swift
//  swift_companion
//
//  Created by yusei ikeda on 2024/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var showUserDetail = false
    @State private var fetchedData: String = ""
    @State private var isValidUser = false // APIからのレスポンスを元に設定

    var body: some View {
        NavigationStack {
            VStack {
                TextField("ユーザー名を入力してください", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                    .keyboardType(.asciiCapable)

                Button("検索") {
                    authenticateAndFetchData(for: username)
                }
                .disabled(username.isEmpty)
                
                // APIからのレスポンスが有効なユーザーであると判断した場合にのみ表示
                if isValidUser {
                    NavigationLink("ユーザー詳細を表示", isActive: $showUserDetail) {
                        // ここでUserDetailViewを表示し、fetchedDataを渡す
                        UserDetailView(userData: fetchedData)
                    }
                }
            }
            .navigationBarTitle("ユーザー検索")
        }
    }
    
    func authenticateAndFetchData(for user: String) {
        guard let tokenURL = URL(string: "https://api.intra.42.fr/oauth/token") else {
            print("Invalid token URL")
            return
        }

        var tokenRequest = URLRequest(url: tokenURL)
        tokenRequest.httpMethod = "POST"
        tokenRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "grant_type": "client_credentials",
            "client_id": "",
            "client_secret": ""
        ]
        
        tokenRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        URLSession.shared.dataTask(with: tokenRequest) { data, response, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let accessToken = json?["access_token"] as? String
                    
                    DispatchQueue.main.async {
                        self.fetchUserData(for: user, with: accessToken ?? "")
                    }
                } catch {
                    print("Error obtaining access token: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func fetchUserData(for user: String, with accessToken: String) {
        guard let usersURL = URL(string: "https://api.intra.42.fr/v2/users/\(user)") else {
            print("Invalid user URL")
            return
        }
        
        var usersRequest = URLRequest(url: usersURL)
        usersRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: usersRequest) { data, response, error in
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.fetchedData = dataString
                    self.isValidUser = true
                    self.showUserDetail = true
                }
            } else {
                DispatchQueue.main.async {
                    self.fetchedData = "Fetch failed: \(error?.localizedDescription ?? "Unknown error")"
                    self.isValidUser = false
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
