import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @designCatalogTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Catálogo visual'**
  String get designCatalogTitle;

  /// No description provided for @skillRadarTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Radar de habilidades'**
  String get skillRadarTitle;

  /// No description provided for @skillRadarDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Uma prévia visual com dados falsos. A evolução real será calculada a partir do seu histórico.'**
  String get skillRadarDescription;

  /// No description provided for @skillRadarAccessibleTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Radar de habilidades de exemplo'**
  String get skillRadarAccessibleTitle;

  /// No description provided for @skillConsistency.
  ///
  /// In pt_BR, this message translates to:
  /// **'Constância'**
  String get skillConsistency;

  /// No description provided for @skillFocus.
  ///
  /// In pt_BR, this message translates to:
  /// **'Foco'**
  String get skillFocus;

  /// No description provided for @skillPlanning.
  ///
  /// In pt_BR, this message translates to:
  /// **'Planejamento'**
  String get skillPlanning;

  /// No description provided for @skillEnergy.
  ///
  /// In pt_BR, this message translates to:
  /// **'Energia'**
  String get skillEnergy;

  /// No description provided for @skillStrength.
  ///
  /// In pt_BR, this message translates to:
  /// **'Força'**
  String get skillStrength;

  /// No description provided for @todayGreeting.
  ///
  /// In pt_BR, this message translates to:
  /// **'Bom dia'**
  String get todayGreeting;

  /// No description provided for @todaySubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hoje o mínimo já conta.'**
  String get todaySubtitle;

  /// No description provided for @todayLevelXp.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nível 2 · 100 XP'**
  String get todayLevelXp;

  /// No description provided for @todayProgressTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Feitos hoje'**
  String get todayProgressTitle;

  /// No description provided for @todayProgressValue.
  ///
  /// In pt_BR, this message translates to:
  /// **'3 de 7'**
  String get todayProgressValue;

  /// No description provided for @nextActionTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Próxima ação'**
  String get nextActionTitle;

  /// No description provided for @nextActionTask.
  ///
  /// In pt_BR, this message translates to:
  /// **'Separar 10 minutos para organizar a manhã'**
  String get nextActionTask;

  /// No description provided for @completeAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Concluir'**
  String get completeAction;

  /// No description provided for @quickActionsTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ações rápidas'**
  String get quickActionsTitle;

  /// No description provided for @newHabitAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Novo hábito'**
  String get newHabitAction;

  /// No description provided for @newTaskAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nova tarefa'**
  String get newTaskAction;

  /// No description provided for @startFocusAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Iniciar foco'**
  String get startFocusAction;

  /// No description provided for @startWorkoutAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Iniciar treino'**
  String get startWorkoutAction;

  /// No description provided for @todayHabitsTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábitos de hoje'**
  String get todayHabitsTitle;

  /// No description provided for @habitMorning.
  ///
  /// In pt_BR, this message translates to:
  /// **'Respirar por 2 minutos'**
  String get habitMorning;

  /// No description provided for @habitMorningCue.
  ///
  /// In pt_BR, this message translates to:
  /// **'Depois de abrir a janela'**
  String get habitMorningCue;

  /// No description provided for @habitMorningStreak.
  ///
  /// In pt_BR, this message translates to:
  /// **'3 dias'**
  String get habitMorningStreak;

  /// No description provided for @habitReading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ler 10 páginas'**
  String get habitReading;

  /// No description provided for @habitReadingCue.
  ///
  /// In pt_BR, this message translates to:
  /// **'Depois do café'**
  String get habitReadingCue;

  /// No description provided for @habitReadingStreak.
  ///
  /// In pt_BR, this message translates to:
  /// **'5 dias'**
  String get habitReadingStreak;

  /// No description provided for @timelineTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Linha do tempo'**
  String get timelineTitle;

  /// No description provided for @timelineEmpty.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nenhum bloco marcado ainda. Quando você planejar algo, ele aparecerá aqui.'**
  String get timelineEmpty;

  /// No description provided for @welcomeTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seu dia em um só lugar.'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábitos, tarefas, rotina e treino — com gentileza nos dias difíceis.'**
  String get welcomeDescription;

  /// No description provided for @continueAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Começar'**
  String get continueAction;

  /// No description provided for @backupLink.
  ///
  /// In pt_BR, this message translates to:
  /// **'Já tenho um backup'**
  String get backupLink;

  /// No description provided for @localDataNote.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seus dados ficam neste aparelho.'**
  String get localDataNote;

  /// No description provided for @navToday.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hoje'**
  String get navToday;

  /// No description provided for @navPlan.
  ///
  /// In pt_BR, this message translates to:
  /// **'Plano'**
  String get navPlan;

  /// No description provided for @navHabits.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábitos'**
  String get navHabits;

  /// No description provided for @navWorkouts.
  ///
  /// In pt_BR, this message translates to:
  /// **'Treinos'**
  String get navWorkouts;

  /// No description provided for @navEvolution.
  ///
  /// In pt_BR, this message translates to:
  /// **'Evolução'**
  String get navEvolution;

  /// No description provided for @shellComingSoon.
  ///
  /// In pt_BR, this message translates to:
  /// **'Este destino será conectado nas próximas fases.'**
  String get shellComingSoon;

  /// No description provided for @flowRingSemanticLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Progresso do dia'**
  String get flowRingSemanticLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
