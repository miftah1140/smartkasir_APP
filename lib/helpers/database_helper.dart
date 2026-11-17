// Mengimpor pustaka dasar Flutter, SQLite, dan path
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// Mengimpor model data Produk dan Karyawan
import '../models/produk.dart';
import '../models/karyawan.dart';

// Kelas pengelola koneksi dan operasi basis data SQLite lokal SmartKasir
class DatabaseHelper {
  // --- DESIGN PATTERN SINGLETON ---
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // --- GETTER DATABASE ASINKRON ---
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartkasir.db');
    return _database!;
  }

  // --- INISIALISASI DUAL-PLATFORM (Chrome Web & Android) ---
  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        filePath,
        version: 2, // Versi 2: menambahkan tabel karyawan
        onCreate: _createDB,
        onUpgrade: _onUpgradeDB, // Migrasi untuk user yang sudah punya DB v1
      );
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  // --- DDL: BUAT TABEL & SEEDING DATA AWAL (DB BARU) ---
  Future _createDB(Database db, int version) async {
    // 1. Pembuatan Tabel Produk
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_produk TEXT UNIQUE,
        nama_produk TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli REAL NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        gambar_path TEXT,
        diskon_persen INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // 2. Pembuatan Tabel Karyawan
    await db.execute('''
      CREATE TABLE karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_karyawan TEXT NOT NULL,
        pin TEXT NOT NULL,
        peran TEXT NOT NULL
      )
    ''');

    // Seeding produk awal
    for (final produk in produkAwalSQLite) {
      await db.insert('produk', produk.toMap());
    }

    // Seeding karyawan awal (2 staf default)
    await db.rawInsert(
      "INSERT INTO karyawan (nama_karyawan, pin, peran) VALUES (?, ?, ?)",
      ['Ahmad Kasir', '1234', 'Kasir'],
    );
    await db.rawInsert(
      "INSERT INTO karyawan (nama_karyawan, pin, peran) VALUES (?, ?, ?)",
      ['Siti Supervisor', '5678', 'Supervisor'],
    );
  }

  // --- DDL: MIGRASI SKEMA (DB LAMA v1 → v2) ---
  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Membuat tabel karyawan untuk database pengguna yang sudah ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS karyawan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_karyawan TEXT NOT NULL,
          pin TEXT NOT NULL,
          peran TEXT NOT NULL
        )
      ''');
      // Memasukkan staf awal jika tabel baru dibuat
      await db.rawInsert(
        "INSERT INTO karyawan (nama_karyawan, pin, peran) VALUES (?, ?, ?)",
        ['Ahmad Kasir', '1234', 'Kasir'],
      );
      await db.rawInsert(
        "INSERT INTO karyawan (nama_karyawan, pin, peran) VALUES (?, ?, ?)",
        ['Siti Supervisor', '5678', 'Supervisor'],
      );
    }
  }

  // ==========================================
  // METODE CRUD: TABEL KARYAWAN
  // ==========================================

  // 1. CREATE: Menyimpan Karyawan Baru ke SQLite
  Future<int> insertKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.insert('karyawan', karyawan.toMap());
  }

  // 2. READ: Mengambil Seluruh Daftar Karyawan
  Future<List<Karyawan>> getAllKaryawan() async {
    final db = await instance.database;
    final result = await db.query('karyawan', orderBy: 'id ASC');
    return result.map((json) => Karyawan.fromMap(json)).toList();
  }

  // 3. UPDATE: Memperbarui Data Karyawan
  Future<int> updateKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.update(
      'karyawan',
      karyawan.toMap(),
      where: 'id = ?',
      whereArgs: [karyawan.id],
    );
  }

  // 4. DELETE: Menghapus Karyawan Berdasarkan ID
  Future<int> deleteKaryawan(int id) async {
    final db = await instance.database;
    return await db.delete(
      'karyawan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // METODE CRUD: TABEL PRODUK
  // ==========================================

  // CREATE: Menyimpan Produk Baru
  Future<int> insertProduk(Produk produk) async {
    final db = await instance.database;
    return await db.insert(
      'produk',
      produk.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: Semua Produk (urut harga jual termurah)
  Future<List<Produk>> getAllProduk() async {
    final db = await instance.database;
    final result = await db.query('produk', orderBy: 'harga_jual ASC');
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // READ: Filter Kategori
  Future<List<Produk>> getProdukByKategori(String kategori) async {
    final db = await instance.database;
    if (kategori == 'Semua') return await getAllProduk();
    final result = await db.query(
      'produk',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'harga_jual ASC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // READ: Pencarian SQL LIKE
  Future<List<Produk>> searchProduk(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'produk',
      where: 'nama_produk LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // UPDATE: Perbarui Data Produk
  Future<int> updateProduk(Produk produk) async {
    final db = await instance.database;
    return await db.update(
      'produk',
      produk.toMap(),
      where: 'id = ?',
      whereArgs: [produk.id],
    );
  }

  // DELETE: Hapus Produk
  Future<int> deleteProduk(int id) async {
    final db = await instance.database;
    return await db.delete(
      'produk',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
