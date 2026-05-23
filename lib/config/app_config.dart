class AppConfig {
  /*
    Untuk sementara API Laravel belum ready, jadi app jalan pakai mock data.
    Nanti ketika endpoint Laravel sudah siap, ubah:
      useMockData = false
    lalu sesuaikan baseUrl di bawah.
  */
  static const bool useMockData = true;

  /*
    Pilih baseUrl sesuai tempat kamu menjalankan Flutter:

    1. Flutter Chrome/Desktop di laptop:
       http://127.0.0.1:8000/api/mobile

    2. Android Emulator:
       http://10.0.2.2:8000/api/mobile

    3. HP asli:
       http://IP-LAPTOP-KAMU:8000/api/mobile
       contoh: http://192.168.100.32:8000/api/mobile
  */
  static const String baseUrl = 'http://127.0.0.1:8000/api/mobile';
  // static const String baseUrl = 'http://192.168.100.32:8000/api/mobile';
}