// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Add Folder
  internal static let addFolder = L10n.tr("Localizable", "Add Folder", fallback: "Add Folder")
  /// Add note
  internal static let addNote = L10n.tr("Localizable", "Add note", fallback: "Add note")
  /// Add to Favorites
  internal static let addToFavorites = L10n.tr("Localizable", "Add to Favorites", fallback: "Add to Favorites")
  /// All Notes
  internal static let allNotes = L10n.tr("Localizable", "All Notes", fallback: "All Notes")
  /// Audio Files
  internal static let audioFiles = L10n.tr("Localizable", "Audio Files", fallback: "Audio Files")
  /// Chat with this note
  internal static let chatWithThisNote = L10n.tr("Localizable", "Chat with this note", fallback: "Chat with this note")
  /// Confirm
  internal static let confirm = L10n.tr("Localizable", "Confirm", fallback: "Confirm")
  /// Delete
  internal static let delete = L10n.tr("Localizable", "Delete", fallback: "Delete")
  /// Discover all featureswith this note！
  internal static let discoverAllFeatureswithThisNote = L10n.tr("Localizable", "Discover all featureswith this note", fallback: "Discover all featureswith this note！")
  /// Edit Summary
  internal static let editSummary = L10n.tr("Localizable", "Edit Summary", fallback: "Edit Summary")
  /// Edit Transcript
  internal static let editTranscript = L10n.tr("Localizable", "Edit Transcript", fallback: "Edit Transcript")
  /// Favorites
  internal static let favorites = L10n.tr("Localizable", "Favorites", fallback: "Favorites")
  /// Folder
  internal static let folder = L10n.tr("Localizable", "Folder", fallback: "Folder")
  /// Home
  internal static let home = L10n.tr("Localizable", "Home", fallback: "Home")
  /// Purchase Error!
  internal static let mbBuyError = L10n.tr("Localizable", "mb-buy-error", fallback: "Purchase Error!")
  /// Purchase Successful!
  internal static let mbBuySuccess = L10n.tr("Localizable", "mb-buy-success", fallback: "Purchase Successful!")
  /// You are currently a subscriber
  internal static let mbEnableBuy = L10n.tr("Localizable", "mb-enable-buy", fallback: "You are currently a subscriber")
  /// Failed to restore purchases
  internal static let mbRestoreError = L10n.tr("Localizable", "mb-restore-error", fallback: "Failed to restore purchases")
  /// Your subscription has expired
  internal static let mbRestoreExpired = L10n.tr("Localizable", "mb-restore-expired", fallback: "Your subscription has expired")
  /// No active subscriptions found
  internal static let mbRestoreNone = L10n.tr("Localizable", "mb-restore-none", fallback: "No active subscriptions found")
  /// Subscription restored successfully
  internal static let mbRestoreSuccess = L10n.tr("Localizable", "mb-restore-success", fallback: "Subscription restored successfully")
  /// Me
  internal static let me = L10n.tr("Localizable", "Me", fallback: "Me")
  /// More
  internal static let more = L10n.tr("Localizable", "More", fallback: "More")
  /// Move to folder
  internal static let moveToFolder = L10n.tr("Localizable", "Move to folder", fallback: "Move to folder")
  /// My Notes
  internal static let myNotes = L10n.tr("Localizable", "My Notes", fallback: "My Notes")
  /// New Folder
  internal static let newFolder = L10n.tr("Localizable", "New Folder", fallback: "New Folder")
  /// New folder name
  internal static let newFolderName = L10n.tr("Localizable", "New folder name", fallback: "New folder name")
  /// New note
  internal static let newNote = L10n.tr("Localizable", "New note", fallback: "New note")
  /// The network is not connected or limited.
  internal static let notConnectedLimited = L10n.tr("Localizable", "not-connected-limited", fallback: "The network is not connected or limited.")
  /// notes
  internal static let notes = L10n.tr("Localizable", "Notes", fallback: "notes")
  /// Recording
  internal static let recording = L10n.tr("Localizable", "Recording", fallback: "Recording")
  /// Remove from Favorites
  internal static let removeFromFavorites = L10n.tr("Localizable", "Remove from Favorites", fallback: "Remove from Favorites")
  /// Rename
  internal static let rename = L10n.tr("Localizable", "Rename", fallback: "Rename")
  /// Reset
  internal static let reset = L10n.tr("Localizable", "Reset", fallback: "Reset")
  /// Save
  internal static let save = L10n.tr("Localizable", "Save", fallback: "Save")
  /// Search folders
  internal static let searchFolders = L10n.tr("Localizable", "Search folders", fallback: "Search folders")
  /// Search notes/folders
  internal static let searchNotesFolders = L10n.tr("Localizable", "Search notes/folders", fallback: "Search notes/folders")
  /// Share
  internal static let share = L10n.tr("Localizable", "Share", fallback: "Share")
  /// Share audio
  internal static let shareAudio = L10n.tr("Localizable", "Share audio", fallback: "Share audio")
  /// Share Summary in PDF
  internal static let shareSummaryInPDF = L10n.tr("Localizable", "Share Summary in PDF", fallback: "Share Summary in PDF")
  /// Share Summary in text
  internal static let shareSummaryInText = L10n.tr("Localizable", "Share Summary in text", fallback: "Share Summary in text")
  /// Share Transcript in PDF
  internal static let shareTranscriptInPDF = L10n.tr("Localizable", "Share Transcript in PDF", fallback: "Share Transcript in PDF")
  /// Share Transcript in text
  internal static let shareTranscriptInText = L10n.tr("Localizable", "Share Transcript in text", fallback: "Share Transcript in text")
  /// Summarize
  internal static let summarize = L10n.tr("Localizable", "Summarize", fallback: "Summarize")
  /// Transcription
  internal static let transcription = L10n.tr("Localizable", "Transcription", fallback: "Transcription")
  /// Translate
  internal static let translate = L10n.tr("Localizable", "Translate", fallback: "Translate")
  /// Try now
  internal static let tryNow = L10n.tr("Localizable", "Try now", fallback: "Try now")
  /// Welcome！
  internal static let welcome = L10n.tr("Localizable", "Welcome", fallback: "Welcome！")
  internal enum Subscribe {
    /// %d days
    internal static func dDays(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscribe.%d_days", p1, fallback: "%d days")
    }
    /// %d Days Free
    internal static func dFreeTrial(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscribe.%d_freeTrial", p1, fallback: "%d Days Free")
    }
    /// %d months
    internal static func dMonths(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscribe.%d_months", p1, fallback: "%d months")
    }
    /// %d weeks
    internal static func dWeeks(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscribe.%d_weeks", p1, fallback: "%d weeks")
    }
    /// %d years
    internal static func dYears(_ p1: Int) -> String {
      return L10n.tr("Localizable", "subscribe.%d_years", p1, fallback: "%d years")
    }
    /// day
    internal static let day = L10n.tr("Localizable", "subscribe.day", fallback: "day")
    /// Unlock Export Features
    internal static let desc = L10n.tr("Localizable", "subscribe.desc", fallback: "Unlock Export Features")
    /// Video
    internal static let feature1 = L10n.tr("Localizable", "subscribe.feature1", fallback: "Video")
    /// Audio
    internal static let feature2 = L10n.tr("Localizable", "subscribe.feature2", fallback: "Audio")
    /// Image
    internal static let feature3 = L10n.tr("Localizable", "subscribe.feature3", fallback: "Image")
    /// Gif
    internal static let feature4 = L10n.tr("Localizable", "subscribe.feature4", fallback: "Gif")
    /// Get Premium
    internal static let getPremium = L10n.tr("Localizable", "subscribe.getPremium", fallback: "Get Premium")
    /// Save & share all you want
    internal static let getPremiumTips = L10n.tr("Localizable", "subscribe.getPremiumTips", fallback: "Save & share all you want")
    /// month
    internal static let month = L10n.tr("Localizable", "subscribe.month", fallback: "month")
    /// No restorable purchases found
    internal static let noRestorablePurchases = L10n.tr("Localizable", "subscribe.noRestorablePurchases", fallback: "No restorable purchases found")
    /// Save your wonderful memories
    internal static let premiumTips = L10n.tr("Localizable", "subscribe.premiumTips", fallback: "Save your wonderful memories")
    /// Design & Create
    internal static let premiumTitle = L10n.tr("Localizable", "subscribe.premiumTitle", fallback: "Design & Create")
    /// Unable to obtain product information temporarily, please check the network and try again
    internal static let productNotFound = L10n.tr("Localizable", "subscribe.productNotFound", fallback: "Unable to obtain product information temporarily, please check the network and try again")
    /// Restore
    internal static let restore = L10n.tr("Localizable", "subscribe.restore", fallback: "Restore")
    /// week
    internal static let week = L10n.tr("Localizable", "subscribe.week", fallback: "week")
    /// year
    internal static let year = L10n.tr("Localizable", "subscribe.year", fallback: "year")
    internal enum Product {
      /// First %d days free, then %@
      internal static func freeTips(_ p1: Int, _ p2: Any) -> String {
        return L10n.tr("Localizable", "subscribe.product.freeTips", p1, String(describing: p2), fallback: "First %d days free, then %@")
      }
      /// %@/%@, unlimited access to all features, cancel anytime
      internal static func tips(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "subscribe.product.tips", String(describing: p1), String(describing: p2), fallback: "%@/%@, unlimited access to all features, cancel anytime")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

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
