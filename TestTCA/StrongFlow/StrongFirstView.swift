//
//  StrongFirstView.swift
//  TestTCA
//
//  Created by Yaroslav Golinskiy on 12/05/2025.
//

import SwiftUI

struct StrongFirstView: View {
    
    @State var path: [String] = []
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("NEXT") {
                    path.append("SecondView")
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "SecondView" {
                    SecondView()
                }
            }
        }
    }
}

struct SecondView: View {
    
    var parent: Parent? = Parent()
    var pet: Pet? = Pet()
    
    var body: some View {
        VStack {
            
        }
        .onAppear {
            parent?.pet = pet
            pet?.parent = parent
            
        }
    }
}

class Parent {
    var pet: Pet?
    
    init(pet: Pet? = nil) {
        self.pet = pet
        print("Parent was initiated")
    }
    
    deinit {
        print("Parent was initiated")
    }
}

class Pet {
    //weak var parent: Parent?
    var parent: Parent?
    
    init(parent: Parent? = nil) {
        self.parent = parent
        print("Pet was deinited")

    }
    deinit {
        print("Pet was deinited")
    }
}

