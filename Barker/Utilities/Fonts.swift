//
//  Fonts.swift
//  Barker
//
//  Created by Matt Leirdahl on 11/28/21.
//

import Foundation
import UIKit
import SwiftUI

extension Font {
   //var fontGuy = "GillSans"
   /// Create a font with the large title text style.
    public static var largeTitle: Font {
        return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }
    
   public static var largeTitleCustom: Font {
       return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
   }

   /// Create a font with the title text style.
   public static var titleCustom: Font {
       return Font.custom(Fonts().mainFont, size: 36)
   }
    public static var title: Font {
        return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .title1).pointSize)
    }

   /// Create a font with the headline text style.
   public static var headlineCustom: Font {
       return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
   }

    public static var headlineCustomBold: Font {
        return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
    }

    public static var headline: Font {
        return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
    }

   /// Create a font with the subheadline text style.
   public static var subheadline: Font {
       return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
   }

   /// Create a font with the body text style.
   public static var body: Font {
          return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize)
      }
    public static var bodyCustom: Font {
           return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize)
       }
    
   /// Create a font with the callout text style.
   public static var callout: Font {
          return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .callout).pointSize)
      }

   /// Create a font with the footnote text style.
   public static var footnote: Font {
          return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
      }

   /// Create a font with the caption text style.
   public static var caption: Font {
          return Font.custom(Fonts().mainFont, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
      }

   public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
       var font = Fonts().mainFont
       switch weight {
       case .bold: font = Fonts().mainFont
       case .heavy: font = Fonts().mainFont
       case .light: font = Fonts().mainFont
       case .medium: font = Fonts().mainFont
       case .semibold: font = Fonts().mainFont
       case .thin: font = Fonts().mainFont
       case .ultraLight: font = Fonts().mainFont
       default: break
       }
       return Font.custom(font, size: size)
   }
}
class Fonts{
    let underLabel = "Arial"
    let underLabelColor = UIColor.black
    
    let headerLabelColor = UIColor.white
    let headerFontSize = CGFloat(24)
    
    let mainMenuItemFontColor = "#2c3e50"
    
    let mainFont = "KohinoorBangla-Light"
}
