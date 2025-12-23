// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let floderDown = ImageAsset(name: "Floder_down")
  internal static let addFloders = ImageAsset(name: "add_floders")
  internal static let addNoteCheck = ImageAsset(name: "add_note_check")
  internal static let addNoteUnCheck = ImageAsset(name: "add_note_unCheck")
  internal static let allNote = ImageAsset(name: "all_note")
  internal static let audioDown = ImageAsset(name: "audio_down")
  internal static let backArrow = ImageAsset(name: "backArrow")
  internal static let cancel = ImageAsset(name: "cancel")
  internal static let canlande = ImageAsset(name: "canlande")
  internal static let chatIcon = ImageAsset(name: "chatIcon")
  internal static let chatAudio = ImageAsset(name: "chat_audio")
  internal static let delete = ImageAsset(name: "delete")
  internal static let editSummary = ImageAsset(name: "edit_summary")
  internal static let editTranscript = ImageAsset(name: "edit_transcript")
  internal static let favoriteTop = ImageAsset(name: "favorite_top")
  internal static let floder = ImageAsset(name: "floder")
  internal static let floderAdd = ImageAsset(name: "floder_add")
  internal static let homeFavorite = ImageAsset(name: "home_favorite")
  internal static let homeNote = ImageAsset(name: "home_note")
  internal static let homeType00 = ImageAsset(name: "home_type_00")
  internal static let homeType01 = ImageAsset(name: "home_type_01")
  internal static let moreAction = ImageAsset(name: "more_action")
  internal static let moreDelete = ImageAsset(name: "more_delete")
  internal static let moreFavorite = ImageAsset(name: "more_favorite")
  internal static let moreMoveFloder = ImageAsset(name: "more_move_floder")
  internal static let moreRename = ImageAsset(name: "more_rename")
  internal static let moreRight = ImageAsset(name: "more_right")
  internal static let moreShare = ImageAsset(name: "more_share")
  internal static let moreUnFavorite = ImageAsset(name: "more_unFavorite")
  internal static let playIcon = ImageAsset(name: "playIcon")
  internal static let processingAudio00 = ImageAsset(name: "processing_audio00")
  internal static let processingAudio01 = ImageAsset(name: "processing_audio01")
  internal static let processingBack = ImageAsset(name: "processing_back")
  internal static let processingBad = ImageAsset(name: "processing_bad")
  internal static let processingGood = ImageAsset(name: "processing_good")
  internal static let processingLoading = ImageAsset(name: "processing_loading")
  internal static let processingLoadingLight = ImageAsset(name: "processing_loading_light")
  internal static let processingPoints = ImageAsset(name: "processing_points")
  internal static let processingRemained = ImageAsset(name: "processing_remained")
  internal static let processingWrapping = ImageAsset(name: "processing_wrapping")
  internal static let pusac = ImageAsset(name: "pusac")
  internal static let recordAnimation = ImageAsset(name: "record_animation")
  internal static let recordBottomA = ImageAsset(name: "record_bottomA")
  internal static let recordCancel = ImageAsset(name: "record_cancel")
  internal static let recordCheck = ImageAsset(name: "record_check")
  internal static let recordDowm = ImageAsset(name: "record_dowm")
  internal static let recordPlay = ImageAsset(name: "record_play")
  internal static let recordPuase = ImageAsset(name: "record_puase")
  internal static let searchPop = ImageAsset(name: "searchPop")
  internal static let searchicon = ImageAsset(name: "searchicon")
  internal static let sectionEmpty = ImageAsset(name: "section_empty")
  internal static let sectionEmptyAdd = ImageAsset(name: "section_emptyAdd")
  internal static let selected = ImageAsset(name: "selected")
  internal static let shareAudio = ImageAsset(name: "share_audio")
  internal static let shareSummaryPdf = ImageAsset(name: "share_summary_pdf")
  internal static let shareSummaryText = ImageAsset(name: "share_summary_text")
  internal static let shareTop = ImageAsset(name: "share_top")
  internal static let shareTranscriptPdf = ImageAsset(name: "share_transcript_pdf")
  internal static let shareTranscriptText = ImageAsset(name: "share_transcript_text")
  internal static let timeShow = ImageAsset(name: "timeShow")
  internal static let translate = ImageAsset(name: "translate")
  internal static let type00 = ImageAsset(name: "type_00")
  internal static let type01 = ImageAsset(name: "type_01")
  internal static let unfavorite = ImageAsset(name: "unfavorite")
  internal static let vipIcon = ImageAsset(name: "vip_icon")
  internal static let addSelected = ImageAsset(name: "addSelected")
  internal static let addUnselected = ImageAsset(name: "addUnselected")
  internal static let homeSelected = ImageAsset(name: "homeSelected")
  internal static let homeUnSelected = ImageAsset(name: "homeUnSelected")
  internal static let meSelected = ImageAsset(name: "meSelected")
  internal static let meUnSelected = ImageAsset(name: "meUnSelected")
  internal static let tabbarButton = ImageAsset(name: "tabbar-button")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
