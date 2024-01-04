//
//  ViewController.swift
//  BrokenSwiftUIFetchRequest
//
//  Created by Lucas Derraugh on 1/3/24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGreen
        
        /*
         Steps to reproduce bug
         1. Tap "Open SwiftUI View" (At this point observe in memory debugger that 1 instance of SwiftUI.FetchController exists without a retain cycle)
         2. Tap "Add new person" in sheet (Now that same object exists but now has a retain cycle)
         3. Dismiss the sheet by swiping down
         4. Tap Clear DB (wait for "Persistent stores reloaded" in console)
         5. Tap "Open SwiftUI View"
         6. Tap "Add new person" in sheet
         (Observe Core Data throwing an exception)
         */
        
        let moc = AppDelegate.shared.persistentContainer.viewContext
        try? moc.performAndWait {
            let newPerson = Person(context: moc)
            newPerson.name = "Sally"
            moc.insert(newPerson)
            try moc.save()
        }
        
        let button = UIButton(primaryAction: .init(title: "Open SwiftUI View", handler: { [weak self] _ in
            let vc = UIHostingController(rootView: CoreDataView().environment(\.managedObjectContext, moc))
            self?.present(vc, animated: true)
        }))
        
        let clearOutDB = UIButton(primaryAction: .init(title: "Clear DB", handler: { [weak self] _ in
            self?.clearData()
        }))
        
        let stack = UIStackView(arrangedSubviews: [
            button,
            clearOutDB
        ])
        stack.axis = .vertical
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    public func clearData() {
        // Remove all objects from the contexts
        let persistentContainer = AppDelegate.shared.persistentContainer
        persistentContainer.viewContext.reset()

        do {
            // Delete each store (should only be one)
            for description in persistentContainer.persistentStoreDescriptions {
                if let storeURL = description.url {
                    try persistentContainer.persistentStoreCoordinator
                        .destroyPersistentStore(
                            at: storeURL,
                            ofType: description.type,
                            options: nil
                        )
                }
            }

            // Load persistent stores again, to allow the container to continue functioning
            // with a newly created persistent store.
            persistentContainer.loadPersistentStores { _, error in
                if let error {
                    print(
                        "Error loading persistent store after clearing data: \(error)"
                    )
                } else {
                    print("Persistent stores reloaded")
                }
            }

        } catch {
            print("Unable to clear persistent store: \(error)")
        }
    }
}

