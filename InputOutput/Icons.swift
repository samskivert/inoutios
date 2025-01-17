import SwiftUI

func squareIcon(_ name :String, _ dwidth :CGFloat = 0, _ dheight :CGFloat = 0) -> AnyView {
  AnyView(Image(systemName: name).resizable().frame(width: 22+dwidth, height: 18+dheight).padding(.all, 0))
}

func rectIcon(_ name :String, _ dwidth :CGFloat = 0, _ dheight :CGFloat = 0) -> AnyView {
  AnyView(Image(systemName: name).resizable().frame(width: 18+dwidth, height: 18+dheight).padding([.leading, .trailing], 2-dwidth/2))
}

enum Icon {
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

func readItemIcon (_ format: ReadType) -> AnyView {
  switch format {
  case .book:
    squareIcon("book")
  case .paper:
    squareIcon("newspaper")
  case .article:
    rectIcon("magazine")
  case .audiobook:
    rectIcon("headphones")
  }
}

func watchItemIcon (_ format: WatchType) -> AnyView {
  switch format {
  case .film:
    squareIcon("film")
  case .video:
    squareIcon("video")
  case .show:
    rectIcon("tv")
  case .other:
    squareIcon("eye")
  }
}

func playItemIcon (_ platform: Platform) -> AnyView {
  switch platform {
  case .pc:
    squareIcon("pc")
  case .table:
    squareIcon("table.furniture")
  case .mobile:
    squareIcon("iphone.gen1")
  case .nswitch, .vita:
    squareIcon("formfitting.gamecontroller", 0, -3)
  case .n3ds, .wiiu, .wii, .cube, .n64, .gameboy, .dcast:
    squareIcon("gamecontroller")
  case .ps1, .ps2, .ps3, .ps4, .ps5:
    squareIcon("playstation.logo")
  case .xbox:
    rectIcon("xbox.logo", 1)
  }
}

func listenItemIcon (_ format: ListenType) -> AnyView {
  switch format {
  case .song:
    rectIcon("headphones")
  case .album:
    rectIcon("record.circle.fill")
  case .podcast:
    rectIcon("microphone", -4)
  case .other:
    rectIcon("waveform.circle.fill")
  }
}

