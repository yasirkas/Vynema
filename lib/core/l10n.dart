import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'network/dio_client.dart';

/// Convenient access to the generated localizations: `context.l10n.someKey`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Turns an error thrown by the data layer into a localized, user-facing string.
String localizeError(AppLocalizations l10n, Object error) {
  if (error is ApiException) {
    switch (error.kind) {
      case ApiErrorKind.noApiKey:
        return l10n.errorNoApiKey;
      case ApiErrorKind.timeout:
        return l10n.errorTimeout;
      case ApiErrorKind.noConnection:
        return l10n.errorNoConnection;
      case ApiErrorKind.invalidApiKey:
        return l10n.errorInvalidApiKey;
      case ApiErrorKind.server:
        return l10n.errorServer((error.statusCode ?? 0).toString());
      case ApiErrorKind.unknown:
        return l10n.errorUnknown;
    }
  }
  return l10n.errorUnknown;
}
