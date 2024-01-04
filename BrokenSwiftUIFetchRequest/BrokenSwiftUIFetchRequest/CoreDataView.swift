//
//  CoreDataView.swift
//  BrokenSwiftUIFetchRequest
//
//  Created by Lucas Derraugh on 1/3/24.
//

import SwiftUI

struct CoreDataView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.name)
        ]
    )
    private var people: FetchedResults<Person>
    
    var body: some View {
        List(people) { person in
            Text(person.name ?? "")
        }
        
        Button("Add new person (BUG)") {
            try? moc.performAndWait {
                let newPerson = Person(context: moc)
                newPerson.name = "Buggy Bob"
                moc.insert(newPerson)
                try moc.save()
            }
        }
    }
}

#Preview {
    CoreDataView()
}
