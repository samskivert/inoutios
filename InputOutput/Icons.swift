import SwiftUI

func squareIcon(_ name :String, _ width :CGFloat, _ height :CGFloat) -> AnyView {
  AnyView(Image(systemName: name).resizable().frame(width: width, height: height).padding(.all, 0))
}

func rectIcon(_ name :String, _ width :CGFloat, _ height :CGFloat) -> AnyView {
  AnyView(Image(systemName: name).resizable().frame(width: width, height: height).padding([.leading, .trailing], 2))
}

func readItemIcon (_ format: ReadType) -> AnyView {
  switch format {
  case .book:
    squareIcon("book", 22, 18)
  case .paper:
    squareIcon("newspaper", 22, 18)
  case .article:
    rectIcon("magazine", 18, 18)
  case .audiobook:
    rectIcon("headphones", 18, 18)
  }
}

func watchItemIcon (_ format: WatchType) -> AnyView {
  switch format {
  case .film:
    squareIcon("film", 22, 18)
  case .video:
    squareIcon("video", 22, 18)
  case .show:
    squareIcon("tv", 22, 18)
  case .other:
    squareIcon("eye", 22, 18)
  }
}
