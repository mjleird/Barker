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
    @State var dogName = "doggo"
    @State var showingAbout = false
    
    var body: some View {
        NavigationView {
            VStack(){
                Text(displayValue).font(.headlineCustom).foregroundColor(.white).animation(.easeIn(duration:0.5)).multilineTextAlignment(.center).padding(10)
                HStack{
                    Image(systemName: "magnifyingglass")
                    SuperTextField(
                            placeholder: Text("Can my dog eat...").foregroundColor(.white),
                            text: $foodName
                        ).font(.headlineCustom)
                    .onChange(of: foodName) {
                        print($0)
                        displayValue = isFoodGoodString(searchParm: foodName)
                    }
                }.underlineTextField()
                    .animation(.linear(duration:0.5))
            }.offset(y: -100)
           .navigationBarTitle(Text("Barker"), displayMode: .inline)
                .blueNavigation
                .background(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().mainColor)), Color(Colors().hexStringToUIColor(hex: Colors().gradientSecondaryColor))]), startPoint: .top, endPoint: .bottom))
                .navigationBarItems(
                                    trailing:
                                        Button(action: {
                                            
                                        }){
                                            Image(systemName: "info.circle").foregroundColor(.white).font(.system(size: 16)).onTapGesture {
                                                    //self.showingCheatSheet.toggle()
                                                    print("Tapped")
                                                    showingAbout.toggle()
                                                }
                                        }
                                        ).sheet(isPresented: $showingAbout) {
                                            NavigationView{
                                                AboutView()
                                            }
                                            
                                        }
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
        //print("Values: " + (items.first?.foodName)!)
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
            if(searchParm.last == "s"){
                return "\(searchParm) are ok for \(dogName) to eat"
            }else{
                return "\(searchParm) is ok for \(dogName) to eat"
            }
        }else if returnInt == 1{
            if(searchParm.last == "s"){
                return "\(searchParm) are NEVER ok for \(dogName) to eat"
            }else{
                return "\(searchParm) is NEVER ok for \(dogName) to eat"
            }
        }else if returnInt == 2{
            if(searchParm.last == "s"){
                return "A little bit of \(searchParm) is ok for \(dogName) to eat"
            }else{
                return "A little bit of \(searchParm) is ok for \(dogName) to eat"
            }
        }
        else{
            if(searchParm.count > 3){
                return "Oops, doesn't look like we know what this food is"
            }else{
                return ""
            }
            
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
            }else if searchParm == (item.foodName! + "s"){
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
            }
            else{
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


struct SuperTextField: View {
    
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
    
}
