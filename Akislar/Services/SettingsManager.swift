import SwiftUI

@MainActor
class SettingsManager: ObservableObject {
    @AppStorage("appLanguage") var appLanguageCode: String = AppLanguage.english.code
    @AppStorage("streamLanguage") var streamLanguageCode: String = StreamLanguage.english.code
    @AppStorage("selectedAppIcon") var selectedAppIcon: String = "AppIcon"
    
    var appLanguage: AppLanguage {
        get { AppLanguage.allCases.first { $0.code == appLanguageCode } ?? .english }
        set { appLanguageCode = newValue.code }
    }
    
    var streamLanguage: StreamLanguage {
        get { StreamLanguage.allCases.first { $0.code == streamLanguageCode } ?? .english }
        set { streamLanguageCode = newValue.code }
    }
    
    struct AlternateIcon: Identifiable {
        let id: String
        let name: String
        let previewName: String
        let description: String
    }
    
    let availableIcons: [AlternateIcon] = [
        AlternateIcon(id: "AppIcon", name: "Default", previewName: "icon_default", description: "Classic Akislar"),
        AlternateIcon(id: "AppIcon-Dark", name: "Dark Mode", previewName: "icon_dark", description: "Sleek dark theme"),
        AlternateIcon(id: "AppIcon-Gold", name: "Gold", previewName: "icon_gold", description: "Premium gold"),
        AlternateIcon(id: "AppIcon-Ottoman", name: "Ottoman", previewName: "icon_ottoman", description: "Ottoman inspired")
    ]
    
    func changeAppIcon(to iconName: String) {
        #if os(iOS)
        let name: String? = iconName == "AppIcon" ? nil : iconName
        
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(name) { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.selectedAppIcon = iconName
                }
            }
        }
        #endif
    }
    
    // Localized string helper
    func localizedString(_ key: String) -> String {
        let strings = LocalizedStrings.strings[appLanguageCode] ?? LocalizedStrings.strings["en"]!
        return strings[key] ?? key
    }
}

// MARK: - Localized Strings
struct LocalizedStrings {
    static let strings: [String: [String: String]] = [
        "en": [
            "home": "Home",
            "browse": "Browse",
            "settings": "Settings",
            "search": "Search series...",
            "trending": "Trending Now",
            "continue_watching": "Continue Watching",
            "featured": "Featured",
            "all_series": "All Series",
            "episodes": "Episodes",
            "season": "Season",
            "play": "Play",
            "account": "Account",
            "sign_in": "Sign In",
            "sign_out": "Sign Out",
            "sign_up": "Sign Up",
            "email": "Email",
            "password": "Password",
            "name": "Name",
            "app_language": "App Language",
            "stream_language": "Stream Language",
            "app_icon": "App Icon",
            "about": "About",
            "version": "Version",
            "guest": "Guest",
            "login_google": "Continue with Google",
            "login_email": "Continue with Email",
            "or": "or",
            "cast": "Cast",
            "genres": "Genres",
            "synopsis": "Synopsis",
            "select_language": "Select Language",
            "no_results": "No results found",
        ],
        "tr": [
            "home": "Ana Sayfa",
            "browse": "Keşfet",
            "settings": "Ayarlar",
            "search": "Dizi ara...",
            "trending": "Trendler",
            "continue_watching": "İzlemeye Devam Et",
            "featured": "Öne Çıkanlar",
            "all_series": "Tüm Diziler",
            "episodes": "Bölümler",
            "season": "Sezon",
            "play": "Oynat",
            "account": "Hesap",
            "sign_in": "Giriş Yap",
            "sign_out": "Çıkış Yap",
            "sign_up": "Kayıt Ol",
            "email": "E-posta",
            "password": "Şifre",
            "name": "İsim",
            "app_language": "Uygulama Dili",
            "stream_language": "Yayın Dili",
            "app_icon": "Uygulama Simgesi",
            "about": "Hakkında",
            "version": "Sürüm",
            "guest": "Misafir",
            "login_google": "Google ile Devam Et",
            "login_email": "E-posta ile Devam Et",
            "or": "veya",
            "cast": "Oyuncular",
            "genres": "Türler",
            "synopsis": "Özet",
            "select_language": "Dil Seçin",
            "no_results": "Sonuç bulunamadı",
        ],
        "ar": [
            "home": "الرئيسية",
            "browse": "تصفح",
            "settings": "الإعدادات",
            "search": "ابحث عن مسلسل...",
            "trending": "الأكثر رواجاً",
            "continue_watching": "متابعة المشاهدة",
            "featured": "المميز",
            "all_series": "جميع المسلسلات",
            "episodes": "الحلقات",
            "season": "الموسم",
            "play": "تشغيل",
            "account": "الحساب",
            "sign_in": "تسجيل الدخول",
            "sign_out": "تسجيل الخروج",
            "sign_up": "إنشاء حساب",
            "email": "البريد الإلكتروني",
            "password": "كلمة المرور",
            "name": "الاسم",
            "app_language": "لغة التطبيق",
            "stream_language": "لغة البث",
            "app_icon": "أيقونة التطبيق",
            "about": "حول",
            "version": "الإصدار",
            "guest": "زائر",
            "login_google": "المتابعة مع Google",
            "login_email": "المتابعة بالبريد",
            "or": "أو",
            "cast": "الممثلون",
            "genres": "التصنيفات",
            "synopsis": "الملخص",
            "select_language": "اختر اللغة",
            "no_results": "لا توجد نتائج",
        ],
        "ur": [
            "home": "ہوم",
            "browse": "براؤز",
            "settings": "ترتیبات",
            "search": "سیریز تلاش کریں...",
            "trending": "ٹرینڈنگ",
            "continue_watching": "دیکھنا جاری رکھیں",
            "featured": "نمایاں",
            "all_series": "تمام سیریز",
            "episodes": "اقساط",
            "season": "سیزن",
            "play": "چلائیں",
            "account": "اکاؤنٹ",
            "sign_in": "سائن ان",
            "sign_out": "سائن آؤٹ",
            "sign_up": "سائن اپ",
            "email": "ای میل",
            "password": "پاسورڈ",
            "name": "نام",
            "app_language": "ایپ کی زبان",
            "stream_language": "سٹریم کی زبان",
            "app_icon": "ایپ آئیکن",
            "about": "کے بارے میں",
            "version": "ورژن",
            "guest": "مہمان",
            "login_google": "Google کے ساتھ جاری رکھیں",
            "login_email": "ای میل کے ساتھ جاری رکھیں",
            "or": "یا",
            "cast": "کاسٹ",
            "genres": "انواع",
            "synopsis": "خلاصہ",
            "select_language": "زبان منتخب کریں",
            "no_results": "کوئی نتیجہ نہیں ملا",
        ],
        "fr": [
            "home": "Accueil",
            "browse": "Explorer",
            "settings": "Paramètres",
            "search": "Rechercher...",
            "trending": "Tendances",
            "continue_watching": "Continuer",
            "featured": "À la une",
            "all_series": "Toutes les séries",
            "episodes": "Épisodes",
            "season": "Saison",
            "play": "Lecture",
            "account": "Compte",
            "sign_in": "Connexion",
            "sign_out": "Déconnexion",
            "sign_up": "Inscription",
            "email": "E-mail",
            "password": "Mot de passe",
            "name": "Nom",
            "app_language": "Langue de l'app",
            "stream_language": "Langue de diffusion",
            "app_icon": "Icône de l'app",
            "about": "À propos",
            "version": "Version",
            "guest": "Invité",
            "login_google": "Continuer avec Google",
            "login_email": "Continuer par e-mail",
            "or": "ou",
            "cast": "Distribution",
            "genres": "Genres",
            "synopsis": "Synopsis",
            "select_language": "Choisir la langue",
            "no_results": "Aucun résultat",
        ],
        "de": [
            "home": "Startseite",
            "browse": "Durchsuchen",
            "settings": "Einstellungen",
            "search": "Serien suchen...",
            "trending": "Im Trend",
            "continue_watching": "Weiterschauen",
            "featured": "Empfohlen",
            "all_series": "Alle Serien",
            "episodes": "Folgen",
            "season": "Staffel",
            "play": "Abspielen",
            "account": "Konto",
            "sign_in": "Anmelden",
            "sign_out": "Abmelden",
            "sign_up": "Registrieren",
            "email": "E-Mail",
            "password": "Passwort",
            "name": "Name",
            "app_language": "App-Sprache",
            "stream_language": "Stream-Sprache",
            "app_icon": "App-Symbol",
            "about": "Über",
            "version": "Version",
            "guest": "Gast",
            "login_google": "Weiter mit Google",
            "login_email": "Weiter mit E-Mail",
            "or": "oder",
            "cast": "Besetzung",
            "genres": "Genres",
            "synopsis": "Inhalt",
            "select_language": "Sprache wählen",
            "no_results": "Keine Ergebnisse",
        ],
        "es": [
            "home": "Inicio",
            "browse": "Explorar",
            "settings": "Ajustes",
            "search": "Buscar series...",
            "trending": "Tendencias",
            "continue_watching": "Seguir viendo",
            "featured": "Destacado",
            "all_series": "Todas las series",
            "episodes": "Episodios",
            "season": "Temporada",
            "play": "Reproducir",
            "account": "Cuenta",
            "sign_in": "Iniciar sesión",
            "sign_out": "Cerrar sesión",
            "sign_up": "Registrarse",
            "email": "Correo",
            "password": "Contraseña",
            "name": "Nombre",
            "app_language": "Idioma de la app",
            "stream_language": "Idioma de transmisión",
            "app_icon": "Icono de la app",
            "about": "Acerca de",
            "version": "Versión",
            "guest": "Invitado",
            "login_google": "Continuar con Google",
            "login_email": "Continuar con correo",
            "or": "o",
            "cast": "Reparto",
            "genres": "Géneros",
            "synopsis": "Sinopsis",
            "select_language": "Seleccionar idioma",
            "no_results": "Sin resultados",
        ],
    ]
}
