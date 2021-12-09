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


struct AboutView: View {
    let version : String! = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
    let build : String! = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
    let shadow = 2 as CGFloat
    let padding = 5 as CGFloat
    
    @Environment(\.colorScheme) var colorScheme
    
    
    @State var showSafariPro = false
    @State var urlStringPro = "https://www.aspca.org/pet-care/animal-poison-control/people-foods-avoid-feeding-your-pets"
    
    var body: some View {
       /* ZStack{
        /*Circle().fill(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().boxMain)), Color(Colors().hexStringToUIColor(hex: Colors().boxSecondary))]), startPoint: .top, endPoint: .bottom))
                .frame(width: 400, height: 400)
                .position(x: 0)*/
            VStack(alignment: .leading){
                Text("About this app").font(.titleCustom).padding(padding)
            ZStack{
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    //.fill(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().boxMain)), Color(Colors().hexStringToUIColor(hex: Colors().boxSecondary))]), startPoint: .top, endPoint: .bottom))
                    .fill(.white)
           
                .frame(height: 50)
                .shadow(radius: shadow)
                .padding(padding)
                Text("Version: \(version) and Build: \(build)").font(.headlineCustom).foregroundColor(.black)
                
            }
                Text("Data").font(.titleCustom).padding(padding)
            ZStack{
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    //.fill(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().boxMain)), Color(Colors().hexStringToUIColor(hex: Colors().boxSecondary))]), startPoint: .top, endPoint: .bottom))
                    .fill(.white)
                .frame(height: 100)
                .shadow(radius: shadow)
                .padding(padding)
                Text("All food data is provided via the ASPCA").font(.headlineCustom).foregroundColor(.black)
            }
           Spacer()
        }
      
        }*/
        Form{
            Section(header: Text("Data").font(.headlineCustom)){
                    Text("All food data is based on information provided by the ASPCA").font(.headlineCustom)
                    Button(action: {
                               // update the URL if you'd like to
                               // tell the app that we want to show the Safari VC
                               self.showSafariPro = true
                    }) {
                          Text("ASPCA data source").foregroundColor(colorScheme == .dark ? Color.white : Color.black).fontWeight(.light).font(.headlineCustom)
                     }
                           // summon the Safari sheet
                    .fullScreenCover(isPresented: $showSafariPro) {
                        SafariView(url:URL(string: self.urlStringPro)!)
                    }
            }
            Section(header: Text("This App").font(.headlineCustom)){
                Button(action: {
                    //SKStoreReviewController.requestReview()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }) {
                      Text("Rate Barker").foregroundColor(colorScheme == .dark ? Color.white : Color.black).fontWeight(.light).font(.headlineCustom)
                 }.font(.headlineCustom)
                HStack{
                    Text("Version").font(.headlineCustom)
                    Spacer()
                    Text("\(version)").font(.headlineCustom)
                }
                HStack{
                    Text("Build").font(.headlineCustom)
                    Spacer()
                    Text("\(build)").font(.headlineCustom)
                }
                Text("© 2021, Garbage Pizza Industries").font(.headlineCustom)
            }
        }
        .blueNavigation
         .navigationBarTitle(Text("About"), displayMode: .inline)
         .background(LinearGradient(gradient: Gradient(colors: [Color(Colors().hexStringToUIColor(hex: Colors().mainColor)), Color(Colors().hexStringToUIColor(hex: Colors().gradientSecondaryColor))]), startPoint: .top, endPoint: .bottom))
    }
    struct SafariView: UIViewControllerRepresentable {

        let url: URL

        func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }

        func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

        }

    }
}
