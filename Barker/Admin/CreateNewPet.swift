//
//  About.swift
//  Barker
//
//  Created by Matt Leirdahl on 11/28/21.
//

import Foundation
import SwiftUI
import StoreKit
import SafariServices
import UIKit
import CoreData


struct CreatePetView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var image: Image?
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    
    let shadow = 2 as CGFloat
    let padding = 5 as CGFloat
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var petName: String = ""
    @State var petBirthday: Date = Date.now
    @State var gotchaDay: Date = Date.now
    @State var weight: String = ""
    @State var foodAmount: String = ""
    @State var foodFrequency: String = ""
    @State var validSubmit: Bool = false
    @State var displayImage: String = ""
    @Binding var showingForm: Bool
    
    func save() {
            let pickedImage = inputImage?.jpegData(compressionQuality: 1.0)

            //  Save to Core Data
        }

        func loadImage() {
            guard let inputImage = inputImage else { return }
            image = Image(uiImage: inputImage)
        }

    
    var body: some View {
        VStack(){
            
            
            Form{
                Section(header: Text("Pet info").font(.headlineCustom).foregroundColor(colorScheme == .dark ? Color.white : Color.black)){
                    HStack(){
                        Text("Name").font(.headlineCustom)
                        Spacer()
                        TextField("Name", text: $petName).multilineTextAlignment(.trailing).font(.headlineCustom)
                        //TextField("Name", text: $petName)
                    }
                    HStack(){
                        Text("Birthday").font(.headlineCustom)
                        Spacer()
                        DatePicker("", selection: $petBirthday, displayedComponents: .date).font(.headlineCustom)
                        //TextField("Name", text: $petName)
                    }
                    HStack(){
                        Text("Gotcha Day").font(.headlineCustom)
                        Spacer()
                        DatePicker("", selection: $gotchaDay, displayedComponents: .date).font(.headlineCustom)
                        //TextField("Name", text: $petName)
                    }
                    HStack(){
                        Text("Weight").font(.headlineCustom)
                        Spacer()
                        TextField("Pounds", text: $weight).keyboardType(.decimalPad).multilineTextAlignment(.trailing).font(.headlineCustom)
                    }
                    HStack(){
                        Text("Cups per meal").font(.headlineCustom)
                        Spacer()
                        TextField("Cups", text: $foodAmount).keyboardType(.decimalPad).multilineTextAlignment(.trailing).font(.headlineCustom)
                    }
                    HStack(){
                        Text("Meals per day").font(.headlineCustom)
                        Spacer()
                        TextField("Meals", text: $foodFrequency).keyboardType(.decimalPad).multilineTextAlignment(.trailing).font(.headlineCustom)
                    }
                   
                }
                Section(header: Text("Picture", comment: "Section Header - Picture")) {
                                   if image != nil {
                                       image!
                                           .resizable()
                                           .scaledToFit()
                                           .onTapGesture { self.showImagePicker.toggle() }
                                   } else {
                                       Button(action: { self.showImagePicker.toggle() }) {
                                           Text("Select Image", comment: "Select Image Button")
                                               .accessibility(identifier: "Select Image")
                                }
                    }
                }
               
            }
            Button(action: {
                var isValid: Bool = checkIfValidSubmit()
                if isValid{
                    createPet()
                    showingForm.toggle()
                }else{
                    //message to user that submit is not valid here
                }
               
            }) {
                  Text("Submit").foregroundColor(colorScheme == .dark ? Color.white : Color.black).fontWeight(.light).font(.headlineCustom)
             }.font(.headlineCustom)
            
        }
        .blueNavigation
         .navigationBarTitle(Text("Create New Pet"), displayMode: .inline)
         .background(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().mainColor)), Color(Colors().hexStringToUIColor(hex: Colors().gradientSecondaryColor))]), startPoint: .top, endPoint: .bottom))
         .sheet(isPresented: $showImagePicker, onDismiss: loadImage) { ImagePicker(image: self.$inputImage) }
    }
    func checkIfValidSubmit() -> Bool{
        if (petName == ""){
            return false
        }else if(petBirthday == Date()){
            return false
        }else{
            return true
        }
    }
    func createPet(){
        let petInfo = Pet(context: moc)
        petInfo.name = petName
        petInfo.birthday = petBirthday
        petInfo.type = "Dog"
        petInfo.gotcha = gotchaDay
        petInfo.foodAmount = Double(foodAmount) ?? 0.0
        petInfo.foodFrequency = Int64(foodFrequency) ?? 0
        petInfo.weight = Double(weight) ?? 0.0
        
        let saveID = UUID().uuidString
        petInfo.idNum = saveID
        
        let pickedImage = inputImage?.jpegData(compressionQuality: 1.0)
        petInfo.picture = pickedImage
        
           do {
               try moc.save()
               print("Saved with id \(saveID)")
           } catch {
               print((error.localizedDescription))
           }
        print("Create pet now")
    }
    }
    struct SafariView: UIViewControllerRepresentable {

        let url: URL

        func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }

        func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

        }

    }
 

/*struct CreatePetView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePetView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}*/
struct ImagePicker: UIViewControllerRepresentable {

    // MARK: - Environment Object
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    // MARK: - Coordinator Class
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}
