//
//  MainScreenFunctions.swift
//  Barker
//
//  Created by Matt Leirdahl on 11/26/21.
//

import Foundation
import CoreData
import SwiftUI
import CloudKit

class mainScreen{
    func searchResults(searchParm: String) -> String{
       // getRecords()
        //Compare value passed to list of values
        //find list of all foods
        let isGood = isFoodGood(searchParm: searchParm.uppercased())
        var returnVal = ""
        
        if isGood == 1{
            returnVal = "This food is ok to eat"
        }else if isGood == 2{
            returnVal = "This food is not ok to eat"
        }else{
            returnVal = ""
        }
        return returnVal
    }
    func isFoodGood(searchParm: String) -> Int{
        
        var returnVal = 0
        switch searchParm {
        case "PEANUT", "PEANUTS":
            returnVal = 1
        case "ALMOND", "ALMONDS":
            returnVal = 1
        case "GRAPE", "GRAPES":
            returnVal = 2
        default:
            returnVal = 0
        }
        return returnVal
    }
}
struct NavigationBarModifier: ViewModifier {
  var backgroundColor: UIColor
  var textColor: UIColor

  init(backgroundColor: UIColor, textColor: UIColor) {
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithTransparentBackground()
    coloredAppearance.backgroundColor = .clear
      coloredAppearance.titleTextAttributes = [.foregroundColor: textColor, .font: UIFont(name: Fonts().mainFont, size: 32) as Any]
    coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]

    UINavigationBar.appearance().standardAppearance = coloredAppearance
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    UINavigationBar.appearance().tintColor = textColor
  }

  func body(content: Content) -> some View {
    ZStack{
       content
        VStack {
          GeometryReader { geometry in
             Color(self.backgroundColor)
                .frame(height: geometry.safeAreaInsets.top)
                .edgesIgnoringSafeArea(.top)
              Spacer()
          }
        }
     }
  }
}
extension View {
  func navigationBarColor(_ backgroundColor: UIColor, textColor: UIColor) -> some View {
    self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
  }
}
extension View {
  var blueNavigation: some View {
      self.navigationBarColor(Colors().hexStringToUIColor(hex: Colors().mainColor), textColor: UIColor.white)
  }
}
class HostingController<Content> : UIHostingController<Content> where Content : View {
  @objc override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
     return .lightContent
  }
}
extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(.white)
            .padding(10)
    }
}
