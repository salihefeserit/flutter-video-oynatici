# Flutter ile Video Oynatıcı

Bu proje, video_player paketi kullanılarak oluşturulmuş, özel kontrollere ve hareketle (gesture) ses ayarlama özelliğine sahip tam ekran bir video oynatıcıyı içeren bir Flutter uygulamasıdır.

## Özellikler

- **Tam Ekran Video Oynatma:** Videolar, cihaz yatay konuma getirilerek tam ekran modunda oynatılır.
- **Özelleştirilmiş Kontrol Arayüzü:** Videoyu yönetmek için bir kontrol paneli.
- **Hareketle Ses Ayarı:** Ekranda dikey olarak parmağınızı kaydırarak videonun ses seviyesini kolayca ayarlayabilirsiniz.
- **Temel Kontroller:**
    - Oynat / Durdur
    - 10 Saniye İleri Sarma
    - 10 Saniye Geri Sarma
- **İlerleme Çubuğu (Slider):** Videonun istediğiniz saniyesine anında geçiş yapmanızı sağlar.
- **Süre Gösterimi:** Videonun mevcut konumunu ve toplam süresini gösterir (01:23 / 05:40 formatında).
- **Ses Açma/Kapatma:** Tek dokunuşla videoyu sessize alma.
- **Döngü (Loop) Modu:** Videonun bittiğinde otomatik olarak yeniden başlamasını sağlayan tekrarlama özelliği.
- **Oynatma Listesi (Playlist):** Video oynatıcısının altında bulunan kartta isimleri bulunan videolara tıklayarak ilgili videonun oynatıcıda oynatılmasını sağlar.

## Kod Yapısı
- `lib/VideoFullScreenPage.dart`: Bu dosya, *FullScreenPlayer* adında bir StatefulWidget içerir. Bu widget, dışarıdan bir *VideoPlayerController* alarak tam ekran video oynatma deneyimini ve özel kontrol arayüzünü (`controlCard`) yönetir.

- **`_enterFullScreen()`** ve **`_exitFullScreen()`:** Cihazın oryantasyonunu ve sistem arayüzü (status bar vb.) görünümlerini yöneterek tam ekran moduna giriş/çıkış yapar.
- **`_handleVolumeGesture()`**: Dikey kaydırma hareketlerini algılayarak video sesini ayarlar.
- **`controlCard()`**: Slider, butonlar ve süre göstergelerini içeren alt kontrol panelini oluşturan metottur.

## Kullanılan Paketler

- [video_player](https://pub.dev/packages/video_player): Videoları oynatmak için temel paket.
- [flutter/services](https://api.flutter.dev/flutter/services/): Cihazın oryantasyonu ve sistem arayüzü gibi platforma özel servislerle etkileşim için kullanılmıştır.

## Eklenecek Özellikler

- [ ] Ekran rotasyonu değiştiğinde duruma göre videonun tam ekrana geçmesi.