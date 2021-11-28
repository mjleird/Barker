//
//  ContentView.swift
//  Barker
//
//  Created by Matt Leirdahl on 11/26/21.
//

import SwiftUI
import CoreData
import CloudKit

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Food.timestamp, ascending: true)],
        animation: .default)
    private var foods: FetchedResults<Food>

    @State private var foodName = ""
    @State var displayValue = ""
    @State private var Foods = [""]
    
    var body: some View {
        NavigationView {
            VStack(){
                Text("Can my dog eat...")
                Text(foodName)
                Text(displayValue)
                TextField("type something...", text: $foodName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: foodName) {
                    print($0)
                    displayValue = isFoodGoodString(searchParm: foodName)
                }
                Button("Search") {
                    print("Button tapped!")
                    //send a request to check the server
                    displayValue = mainScreen().searchResults(searchParm: foodName)
                }
            }
           .navigationBarTitle(Text("Barker"), displayMode: .inline)
                .blueNavigation
        }.onAppear{
            resetData()
            createAllItems()
        }
    }
    @FetchRequest(
           sortDescriptors: [NSSortDescriptor(keyPath: \Food.timestamp, ascending: true)],
           animation: .default)
    private var items: FetchedResults<Food>
    func createAllItems(){
        
        Foods = []
        //let cloudContainer = CKContainer.default()
        let container = CKContainer(identifier: "iCloud.icloud.Barker.io")
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Foods", predicate: predicate)

        var queryOperation = CKQueryOperation(query: query)
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 10000
        queryOperation.desiredKeys = ["FoodName", "Value"]
        
        queryOperation.recordFetchedBlock = { (record) -> Void in
           //print("returned a value")
           let name = record["FoodName"] as! String
           let recordValue = record["Value"] as! Int64
           //print(name)
           let userInfo = Food(context: self.moc)
           userInfo.foodName = name
           userInfo.attribute = recordValue
           userInfo.timestamp = Date()
              do {
                  try self.moc.save()
                  print("Saved")
              } catch {
                  print((error.localizedDescription))
              }
           self.Foods.append(name)
        }

        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in

            if error != nil {
                print("Failed to get data")
                print(error?.localizedDescription)
                return
            }

            if cursor != nil {
                let newQueryOperation = CKQueryOperation(cursor: cursor!)
                newQueryOperation.cursor = cursor
                newQueryOperation.resultsLimit = queryOperation.resultsLimit
                newQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock

                queryOperation = newQueryOperation

                publicDatabase.add(queryOperation)
                return

            }
        }

        publicDatabase.add(queryOperation)
        
      
        print("Number of records :" + "\(items.count)")
        print("Values: " + (items.first?.foodName)!)
    }
    func resetData(){
        for item in items{
            self.moc.delete(item)
        }
        
    }
    func isFoodGoodString(searchParm: String) -> String{
        //return "Good"
        let returnInt = isFoodGoodCompare(searchParm: searchParm)
        if returnInt == 0{
            return "Food is OK"
        }else if returnInt == 1{
            return "Food is not OK"
        }else if returnInt == 2{
            return "Food is sometimes OK"
        }
        else{
            return "Couldn't find this food"
        }
    }
    func isFoodGoodCompare(searchParm: String) -> Int{
        print(items.count)
        var returnCode = 3
        for item in items{
            print("\(item.foodName) and \(item.attribute)")
            if searchParm == item.foodName{
                if(item.attribute == 0){
                    returnCode = 0
                    break
                }else if (item.attribute == 1){
                    returnCode = 1
                    break
                }else if (item.attribute == 2){
                    returnCode = 2
                    break
                }
            //Add a statement to add an S to the end of the string
            }else{
                returnCode = 3
            }
        }
        return returnCode
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


