//
//  StrongFirstView.swift
//  TestTCA
//
//  Created by Yaroslav Golinskiy on 12/05/2025.
//

import SwiftUI

// MARK: - Example 1

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


// MARK: - Example 2

class SafeBankAccount {
    private var balance: Int = 0
    private let queue = DispatchQueue(label: "com.example.bankAccountQueue")
    
    // Метод депозиту
    func deposit(amount: Int) {
        queue.sync {
            balance += amount
            print("Deposited \(amount), new balance: \(balance)")
        }
    }
    
    // Метод зняття
    func withdraw(amount: Int) {
        queue.sync { // sync  означає, що потік, який його викликає, чекає, поки внутрішня операція закінчиться перед тим, як продовжити виконання
            if balance >= amount {
                balance -= amount
                print("Withdrew \(amount), new balance: \(balance)")
            } else {
                print("Not enough balance to withdraw \(amount)")
            }
        }
    }
    
    // Текущий баланс
    func getBalance() -> Int {
        return queue.sync {
            return balance
        }
    }
}


struct StrongView1: View {
    @State var path: [String] = []
    
    let account = SafeBankAccount()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Next") {
                    path.append("StrongView2")
                }
            }
            .navigationDestination(for: String.self) {
                if $0 == "StrongView2" {
                    StrongView2()
                }
            }
//            .onAppear {
//                DispatchQueue.global().async {
//                    account.deposit(amount: 100)
//                }
//
//                DispatchQueue.global().async {
//                    account.withdraw(amount: 50)
//                }
//
//                DispatchQueue.global().async {
//                    account.deposit(amount: 200)
//                }
//
//                DispatchQueue.global().async {
//                    print("Final balance: \(account.getBalance())")
//                }
//            }
        }
        
    }
}

struct StrongView2: View {
    let parent: Parent1? = Parent1()
    let pet: Pet1? = Pet1()
    
    
    var body: some View {
        VStack {
            
        }
        .onAppear {
            parent?.pet1 = pet
            pet?.parent1 = parent
            //pet?.parent1 = nil
            
        }
        
    }
}

class Parent1 {
    
    var pet1: Pet1?
    
    deinit {
        print("Parent1 was deitined")
    }
}


class Pet1 {
 var parent1: Parent1?
 //weak var parent1: Parent1?

    deinit {
        print("Pet1 was deitined")
    }
}
