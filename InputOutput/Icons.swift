import SwiftUI

func squareIcon(_ name :String, _ dwidth :CGFloat = 0, _ dheight :CGFloat = 0) -> AnyView {
  AnyView(Image(systemName: name).resizable().frame(width: 22+dwidth, height: 18+dheight).padding(.all, 0))
}

func rectIcon(_ name :String, _ dwidth :CGFloat = 0, _ dheight :CGFloat = 0) -> AnyView {
  AnyView(Image(systemName: name).resizable().frame(width: 18+dwidth, height: 18+dheight).padding([.leading, .trailing], 2-dwidth/2))
}

enum Icon : Codable, CaseIterable, Identifiable {
  // read icons
  case book
  case paper
  case article
  case audiobook
  // watch icons
  case film
  case video
  case show
  case otherWatch
  // play icons
  case pc
  case table
  case mobile
  case vr
  case controller1
  case controller2
  case playstation
  case xbox
  case sawCredits
  // listen icons
  case song
  case album
  case podcast
  case otherListen

  var id: Self { self }
}

func icon (_ icon: Icon) -> AnyView {
  switch icon {
  // read icons
  case .book:
    squareIcon("book")
  case .paper:
    squareIcon("newspaper")
  case .article:
    rectIcon("magazine")
  case .audiobook:
    rectIcon("headphones")
  // watch icons
  case .film:
    squareIcon("film")
  case .video:
    squareIcon("video")
  case .show:
    rectIcon("tv")
  case .otherWatch:
    squareIcon("eye")
  // play icons
  case .pc:
    squareIcon("pc")
  case .table:
    squareIcon("table.furniture")
  case .mobile:
    squareIcon("iphone.gen1")
  case .vr:
    squareIcon("vision.pro")
  case .controller1:
    squareIcon("formfitting.gamecontroller", 0, -3)
  case .controller2:
    squareIcon("gamecontroller")
  case .playstation:
    squareIcon("playstation.logo")
  case .xbox:
    rectIcon("xbox.logo", 1)
  case .sawCredits:
    AnyView(Image(systemName: "flag.pattern.checkered").resizable().frame(width: 16, height: 16))
  // listen icons
  case .song:
    rectIcon("headphones")
  case .album:
    rectIcon("record.circle.fill")
  case .podcast:
    rectIcon("microphone", -4)
  case .otherListen:
    rectIcon("waveform.circle.fill")
  }
}
