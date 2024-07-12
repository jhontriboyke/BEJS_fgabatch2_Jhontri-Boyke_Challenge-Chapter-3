-- Binar Academy JavaScript Backend Bootcamp - Challenge 3

-- Membuat database untuk sistem bank db_bank_binar
CREATE DATABASE db_bank_binar;

-- Table untuk entitas nasabah
CREATE TABLE nasabah (
	id BIGSERIAL PRIMARY KEY,
	nama VARCHAR(255) NOT NULL,
	alamat VARCHAR(255),
	no_telpon VARCHAR(16) NOT NULL,
	email VARCHAR(255),
	tanggal_lahir DATE
);

-- Table untuk jenis_akun (ex: Basic, Premium, dan Deluxe)
CREATE TABLE jenis_akun (
	id SERIAL PRIMARY KEY,
	nama VARCHAR(255) NOT NULL,
	deskripsi TEXT
);

-- Table untuk entitas akun
CREATE TABLE akun (
   id BIGSERIAL PRIMARY KEY,
   id_nasabah BIGINT NOT NULL,
   id_jenis_akun INT NOT NULL,
   saldo FLOAT NOT NULL,
   FOREIGN KEY (id_nasabah) REFERENCES nasabah(id),
   FOREIGN KEY (id_jenis_akun) REFERENCES jenis_akun(id)
);

-- Table untuk entitas transaksi
CREATE TABLE transaksi (
	id BIGSERIAL PRIMARY KEY,
	id_akun BIGINT NOT NULL,
	jenis VARCHAR(20) NOT NULL,
	jumlah FLOAT CHECK (jumlah > 0),
	tanggal TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (id_akun) REFERENCES akun(id)
);

-- Memasukan data ke table nasabah
INSERT INTO nasabah (nama, alamat, no_telpon, email, tanggal_lahir) 
VALUES
	('Jhontri Boyke', 'Kalimantan Tengah, Indonesia', 
	'+621234567901', 'jhontriboyke@example.com', '2024-01-23'),
	('Binar Agustian', 'Binar, Indonesia',
	'+621234567890', 'binar@example.com', '1998-05-11'),
	('Mamang Suherman', 'New York, USA',
	'+621234123125', 'mamangNYC@example.com', '1980-12-12');

-- Menghapus salah satu data di tabel nasabah menggunakan attribut id
DELETE FROM nasabah WHERE id = 2;

-- Memasukan data tiga jenis akun (Basic, Premium, dan Deluxe) ke table jenis_akun
INSERT INTO jenis_akun (nama, deskripsi) VALUES
	('Basic', 'Best suit tier for new-comer'),
	('Premium', 'Complete features for your daily life'),
	('Deluxe', 'Best treatment with best features');

-- Mengubah deskripsi salah satu data di tabel jenis_akun
UPDATE jenis_akun
SET deskripsi = 'Best plan for daily life'
WHERE nama = 'Premium';

-- Membuat dan memasukan data ke table akun
INSERT INTO akun (id_nasabah, id_jenis_akun, saldo) VALUES
	(1, 2, 15000),
	(2, 1, 5000),
	(2, 3, 50000),
	(3, 1, 6000);

-- Tampilkan semua data di tabel akun
SELECT * FROM akun;

-- Membuat dan melakukan procedure transaksi tarik_uang / withdrawal
CREATE OR REPLACE PROCEDURE tarik_uang(
  id_akun_tarik INT,
  jumlah_tarik FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
	-- kurangi saldo di akun
	UPDATE akun
	SET saldo = saldo - jumlah_tarik
	WHERE id = id_akun_tarik;

	-- tambahkan ke table transaksi
	INSERT INTO transaksi (id_akun, jenis, jumlah)
	VALUES (id_akun_tarik, 'Withdrawal', jumlah_tarik);

	COMMIT;
END$$

-- Jalankan procedure untuk tarik uang
CALL tarik_uang(1, 500)

-- Membuat dan melakukan procedure transaksi simpan_uang / deposit
CREATE OR REPLACE PROCEDURE simpan_uang (
	id_akun_simpan INT,
	jumlah_simpan FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
	-- tambah saldo di akun
	UPDATE akun
	SET saldo = saldo + jumlah_simpan
	WHERE id = id_akun_simpan;

	-- tambahkan ke table transaksi
	INSERT INTO transaksi (id_akun, jenis, jumlah)
	VALUES (id_akun_simpan, 'Deposit', jumlah_simpan);

	COMMIT;
END$$;

-- Jalankan procedure untuk simpan uang
CALL simpan_uang(1, 2000)

-- Tampilkan tabel transaksi
SELECT * FROM transaksi

-- Tampilkan semua transaksi dengan jenis 'Deposit'
SELECT * FROM transaksi WHERE jenis = 'Deposit';

-- Perintah untuk menghapus atau drop salah satu tabel
DROP TABLE jenis_akun;

-- Perintah untuk menghapus atau drop database
DROP DATABASE db_bank_binar;

