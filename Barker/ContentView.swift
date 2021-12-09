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
    @State var showingCreateNewPet = false
    @State var showingPetDetails = false
    @State var currentPet = ""
    
    @State var pets = [petData]()
    @FetchRequest(
      entity: Pet.entity(),
      sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var petRecs: FetchedResults<Pet>
    
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
                VStack(){
                    ForEach(petRecs, id: \.self) { pet in
                       /* Button(action: {
                            print("button push")
                        }){
                            
                        }.foregroundColor(.white)*/
                        petCard(filter: pet.idNum!).onTapGesture{
                            print("going to open object \(pet.idNum!)")
                            currentPet = pet.idNum!
                            print("this is the pet \(currentPet)")
                            showingPetDetails.toggle()
                        }.frame(height: 100).padding(10)
                      
                    }
                }
            }
           .navigationBarTitle(Text("Barker"), displayMode: .inline)
                .blueNavigation
                .background(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().mainColor)), Color(Colors().hexStringToUIColor(hex: Colors().gradientSecondaryColor))]), startPoint: .top, endPoint: .bottom))
                .navigationBarItems(leading:
                                        Button(action: {
                                            
                                        }){
                                            Image(systemName: "plus").foregroundColor(.white).font(.system(size: 16)).onTapGesture {
                                                    //self.showingCheatSheet.toggle()
                                                    print("Tapped")
                                                    showingCreateNewPet.toggle()
                                                }
                                        },
                                    
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
                                            
                                        }.sheet(isPresented: $showingCreateNewPet) {
                                            NavigationView{
                                                CreatePetView()
                                            }
                                            
                                        }.sheet(isPresented: $showingPetDetails) {
                                            NavigationView{
                                                petDetails(currentPet: $currentPet)
                                            }.onAppear{
                                                print("called nav view for \(currentPet)")
                                            }
                                        }

        }.onAppear{
            resetData()
            findPets()
            createAllItems()
        }
    }
    @FetchRequest(
           sortDescriptors: [NSSortDescriptor(keyPath: \Food.timestamp, ascending: true)],
           animation: .default)
    
    
    var items: FetchedResults<Food>
   // var pets: FetchedResults<Pet>
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
        /*for pet in petRecs{
            self.moc.delete(pet)
        }*/
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
            print("\(String(describing: item.foodName)) and \(item.attribute)")
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
    func findPets(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pet")
                //request.predicate = NSPredicate(format: "age = %@", "12")
                request.returnsObjectsAsFaults = false
                do {
                    let result = try moc.fetch(request)
                    for data in result as! [NSManagedObject] {
                       // print("result1: \(result.name)")
                        //pets.append(petData(name: (data.value(forKey: "name") as! String), birthday: (data.value(forKey: "birthday") as! Date), petid: data.value(forKey: "idNum") as! String))
                        //pets[].name = data.value(forKey: "name") as! String
                        for element in pets {
                            //print("arr val: \(element.petid)")
                        }
                  }
                    print("here is the request:  \(result.count)")
                    
                } catch {
                    
                    print("Failed")
                }
        
              
                
    }
}
class petData: ObservableObject{
    var name: String = "test"
    var birthday: Date = Date()
    var image: Data = Data()
    var gotchaDate: Date = Date()
    var weight: Double = 0.0
    var foodAmount: Double = 0.0
    var foundFrequency: Int64 = 0
   // var picture: Image
    
}
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}*/


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
class petHelper{
    @Environment(\.managedObjectContext) var moc1
    let context = Barker.PersistenceController().container.viewContext
    
    func getPetInfo(filter: String) -> petData {
        var pet = petData()
        let fetchRequest: NSFetchRequest<Pet>
        fetchRequest = Pet.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "idNum == %@", filter
        )

        let objects = try? context.fetch(fetchRequest)
        
        let count = objects!.count
        
        pet.name = objects?.first?.name ?? "Where is the record?"
        pet.birthday = objects?.first?.birthday ?? Date()
        pet.weight = objects?.first?.weight ?? 0.0
        pet.gotchaDate = objects?.first?.gotcha ?? Date()
        pet.foodAmount = objects?.first?.foodAmount ?? 0.0
        pet.image = objects?.first?.picture ?? Data()

        return pet
    }
}
class pet{
    
}
struct petDetails: View {
    @Environment(\.managedObjectContext) var moc1
    @Binding var currentPet: String
    @State var petName: String = ""
    @State var petPicture: Data = Data()
    @State var petBirthday: Date = Date()
    @State var petGuy = petData()
    
    //@StateObject private var petDetails = petData(name: "", birthday: Date())
    
    var body: some View {
        GeometryReader { geometry in
        VStack(){
            HStack(){
                Image(uiImage: UIImage(data: petGuy.image) ?? UIImage()).resizable().frame(width: geometry.size.width / 2.5 ,height: geometry.size.width / 2.5 )
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(Circle().stroke(Color.black, lineWidth: 5))
                Spacer()
                VStack(){
                    VStack(){
                        Text("Born: \(petGuy.birthday, style: .date)").multilineTextAlignment(.leading).font(.headlineCustom)
                    }
                    VStack(){
                        Text("Gotcha: \(petGuy.gotchaDate, style: .date)").multilineTextAlignment(.leading).font(.headlineCustom)
                   
                    }
                   
                }
            }.padding(.top, geometry.size.height / 20)
                .padding(.leading, 10)
                .padding(.trailing, 10)
            Form{
                HStack(){
                    Text("Food").font(.headlineCustom)
                    Spacer()
                    Text("\(petGuy.foodAmount, specifier: "%.2f") cups per day").multilineTextAlignment(.trailing).font(.headlineCustom).foregroundColor(.gray)
                }
                HStack(){
                    Text("Weight").font(.headlineCustom)
                    Spacer()
                    Text(String(petGuy.weight)).multilineTextAlignment(.trailing).font(.headlineCustom).foregroundColor(.gray)
                }
                
            }.onAppear{
                UITableView.appearance().backgroundColor = .clear
            }
            
         
        }.onAppear{
            petGuy = petHelper().getPetInfo(filter: currentPet)
        
            print("onappear")
        }
        }.blueNavigation
            .navigationBarTitle(Text(petGuy.name), displayMode: .inline)
            .background(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().mainColor)), Color(Colors().hexStringToUIColor(hex: Colors().gradientSecondaryColor))]), startPoint: .top, endPoint: .bottom))
    }
}
struct petCard: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var fetchRequest: FetchedResults<Pet>
    @State var petName: String = ""
    
    init(filter: String) {
        _fetchRequest = FetchRequest<Pet>(sortDescriptors: [], predicate: NSPredicate(format: "idNum = %@", filter))
    }
    
    var body: some View {
        ForEach(fetchRequest, id: \.self) { pet in
            
            ZStack(){
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color(Colors().hexStringToUIColor(hex: Colors().complementatryMain))).shadow(radius: 10)
                HStack(alignment: .center){
                    Spacer()
                    Image(uiImage: UIImage(data: pet.picture ?? Data()) ?? UIImage()).resizable().frame(width: 75.0, height: 75.0)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .overlay(Circle().stroke(Color.black, lineWidth: 5))
                        .offset(x: -50)
                    Spacer()
                    Text(pet.name ?? "").font(.headlineCustom).offset(x: -25)
                    Spacer()
                    //Text(pet.birthday ?? Date(), style: .date)
                }
            }
        }
    }
}
