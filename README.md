# Vynema

TMDB tabanlı film ve dizi keşif uygulaması. Flutter ile geliştirilmiştir.

## Özellikler

- Trend olan ve popüler film/dizi listeleri
- Film ve dizi arama
- Detay sayfası — özet, puan, oyuncular, tür bilgisi
- Favorilere ekleme ve yönetme (yerel depolama)
- Dark / Light tema desteği

## Ekran Görüntüleri

> Yakında eklenecek

## Kurulum

### Gereksinimler

- Flutter SDK 3.x
- TMDB API key — [buradan ücretsiz alabilirsiniz](https://www.themoviedb.org/settings/api)

### Adımlar

1. Repoyu klonla:
   ```bash
   git clone https://github.com/yasirkas/Vynema.git
   cd Vynema
   ```

2. `.env.example` dosyasını kopyala ve API key'ini gir:
   ```bash
   cp .env.example .env
   ```
   `.env` dosyasını aç ve `TMDB_API_KEY=` satırına gerçek key'ini yaz.

3. Bağımlılıkları yükle:
   ```bash
   flutter pub get
   ```

4. Çalıştır:
   ```bash
   flutter run
   ```

## Teknoloji Yığını

| Katman | Teknoloji |
|---|---|
| State yönetimi | Riverpod 3.x (`Notifier` / `NotifierProvider`) |
| Yerel depolama | Hive (JSON map, codegen yok) |
| HTTP | Dio + interceptor (`api_key` + `language=tr-TR`) |
| Navigasyon | go_router + `StatefulShellRoute` |
| API key güvenliği | flutter_dotenv (`.env` dosyası, asla commit'lenmez) |

## Proje Yapısı

```
lib/
├── core/
│   ├── config/          # Env
│   ├── constants/       # API endpoint'leri
│   ├── network/         # Dio client + interceptor
│   ├── router/          # go_router tanımları
│   └── theme/           # Renkler ve tema
├── features/
│   ├── discover/        # Keşfet, Arama, Detay
│   └── favorites/       # Favoriler
└── shared/
    └── widgets/         # Ortak widget'lar
```

## API

[TMDB API v3](https://developer.themoviedb.org/reference/intro/getting-started) kullanılmaktadır. Tüm içerik Türkçe (`tr-TR`) olarak çekilmektedir.

## Lisans

MIT
