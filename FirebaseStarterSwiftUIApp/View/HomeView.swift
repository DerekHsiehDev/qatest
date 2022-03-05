//
//  HomeView.swift
//  FirebaseStarterSwiftUIApp
//
//  Created by Duy Bui on 8/18/20.
//  Copyright © 2020 iOS App Templates. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

let db = Firestore.firestore()

struct HomeView: View {
    
    
    @State var score: Int = 0
    @State var isDrawerOpen: Bool = false
    @ObservedObject var state: AppState
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    Text("Welcome \(state.currentUser?.email ?? "Not found")")
                        .navigationBarItems(leading: Button(action: {
                            self.isDrawerOpen.toggle()
                        }) {
                            Image(systemName: "sidebar.left")
                    })
                    
                    Text("Score: \(self.score)")
                    
                    
                    Button(action: {
                        guard let userID = Auth.auth().currentUser?.uid else { return }
                        db.collection("users").document(userID).setData([
                            "score": (score + 1)
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                                db.collection("users").document(userID).getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                        let score = document.get("score")
                                        self.score = score as! Int
                                        
                                    } else {
                                        print("Document does not exist")
                                    }
                                }
                            }
                        }
                    }) {
                        Text("add one")
                    }
                    
                }
            }
            DrawerView(isOpen: self.$isDrawerOpen)
        }.navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .onAppear {
                guard let userID = Auth.auth().currentUser?.uid else { return }
                let docRef = db.collection("users").document(userID)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        let score = document.get("score")
                        self.score = score as! Int
                        
                    } else {
                        print("Document does not exist")
                    }
                }
            }
    
    }
      
}
