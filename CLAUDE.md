# Vynema — Flutter Film & Dizi Keşif Uygulaması

## Proje Amacı

TMDB (The Movie Database) API kullanan bir Flutter mobil uygulaması geliştiriyoruz. Kullanıcılar filmleri ve dizileri keşfedebilecek, detaylarını inceleyebilecek ve favorilerine ekleyebilecek.

## Hedef Platform

- Android ve iOS

## Temel Özellikler

- Trend olan film ve dizileri listeleme
- Popüler film ve dizi listeleri
- Film/dizi arama
- Detay sayfası (özet, puan, oyuncular vb.)
- Favorilere ekleme/çıkarma (yerel depolama)
- Dark/Light tema desteği

## Tasarım Beklentileri

- Modern, premium hissiyat veren bir UI
- Koyu tema ağırlıklı (dark mode varsayılan)
- Smooth animasyonlar ve geçişler
- Glassmorphism ve gradient kullanımı

## TMDB API

- API v3 kullanılacak: `https://api.themoviedb.org/3`
- Görsel base URL: `https://image.tmdb.org/t/p/`
- API key gerekli — kullanıcıdan alınacak
- Veriler Türkçe çekilmeli (`language=tr-TR`)

## Mimari ve Teknoloji Yığını

Bunlar projenin onaylanmış kalıcı mimari kararlarıdır:

- **State yönetimi:** Riverpod (`flutter_riverpod` 3.x). `Notifier`/`NotifierProvider`
  kullanılır (deprecated `StateNotifier` değil); provider'lar varsayılan olarak
  auto-dispose.
- **Yerel depolama (favoriler):** Hive — JSON map olarak saklanır (typed adapter/codegen yok).
- **HTTP:** Dio + interceptor (her isteğe `api_key` ve `language=tr-TR` enjekte eder).
- **API key:** `flutter_dotenv` ile `.env` dosyasından okunur; asla koda gömülmez.
- **Navigasyon:** go_router + `StatefulShellRoute` (alt menü: Keşfet/Ara/Favoriler) ve
  `/detail/:type/:id` rotası.
- **Klasör yapısı:** feature-first → `lib/features/{discover,favorites}` + `lib/core` + `lib/shared`.

## Tercihler ve Kısıtlamalar

- Uygulama dili: Türkçe
- Kod ve yorumlar: İngilizce
- API key güvenliği önemli — doğrudan koda gömülmemeli
- Temiz, ölçeklenebilir bir mimari tercih edilir
- Şu anki flutter projemiz için .gitignore dosyasının doğru şekilde yapılandırıldığından her zaman emin ol
- `.env` dosyası `.gitignore`'a eklenmeli

## Bu Dosya Hakkında

- Bu dosya proje için temel referans dokümandır.
- Önemli mimari kararlar, teknoloji seçimleri ve proje kuralları netleştikçe güncellenebilir. Ancak küçük uygulama detayları, günlük geliştirme kararları ve geçici notlar bu dosyaya eklenmemelidir.
- Bu dosya yalnızca proje yönünü etkileyen kalıcı kararlar değiştiğinde güncellenmelidir.
