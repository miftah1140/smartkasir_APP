// Model data representasi entitas Karyawan pada SmartKasir
class Karyawan {
  // --- ATRIBUT ENTITAS KARYAWAN ---
  // Nullable '?' karena ID otomatis di-generate SQLite via AUTOINCREMENT
  final int? id;
  // Nama lengkap atau nama panggilan staf kasir
  final String namaKaryawan;
  // PIN pengaman 4–6 digit angka untuk otentikasi giliran shift kasir
  final String pin;
  // Peran tanggung jawab kerja: 'Kasir', 'Admin', 'Manajer', atau 'Supervisor'
  final String peran;

  // --- KONSTRUKTOR MODEL KARYAWAN ---
  const Karyawan({
    this.id,
    required this.namaKaryawan,
    required this.pin,
    required this.peran,
  });

  // --- SERIALISASI: Dart Object → SQLite ROW MAP ---
  // Digunakan saat menyimpan data ke baris tabel SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_karyawan': namaKaryawan,
      'pin': pin,
      'peran': peran,
    };
  }

  // --- DESERIALISASI: SQLite ROW MAP → Dart Object ---
  // Digunakan saat merekonstruksi baris hasil kueri SQLite menjadi objek Dart
  factory Karyawan.fromMap(Map<String, dynamic> map) {
    return Karyawan(
      id: map['id'] as int?,
      namaKaryawan: map['nama_karyawan'] as String,
      pin: map['pin'] as String,
      peran: map['peran'] as String,
    );
  }
}
