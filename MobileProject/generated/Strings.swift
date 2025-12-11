// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
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
