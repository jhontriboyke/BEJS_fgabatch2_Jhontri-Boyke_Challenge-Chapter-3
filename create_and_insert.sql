-- Membuat database dengan nama db_bank;
CREATE DATABASE db_bank;

-- Membuat tabel untuk entitas alamat
CREATE TABLE alamat (
	id UUID PRIMARY KEY,
	nama_jalan VARCHAR(100) NOT NULL,
	kota VARCHAR(100) NOT NULL,
	provinsi VARCHAR(100) NOT NULL,
	kode_pos VARCHAR(10) NOT NULL
);

-- Membuat tabel untuk entitas nasabah
CREATE TABLE nasabah (
	id UUID PRIMARY KEY,
	nama_awal VARCHAR(50) NOT NULL,
	nama_akhir VARCHAR(50) NOT NULL,
	tanggal_lahir DATE NOT NULL,
	no_telepon VARCHAR(20) NOT NULL,
	email VARCHAR(100),
	pekerjaan VARCHAR(75) NOT NULL,
	kebangsaan VARCHAR(50) NOT NULL,
	id_alamat UUID NOT NULL,
	FOREIGN KEY (id_alamat) REFERENCES alamat(id)
);

-- Membuat tabel untuk entitas tipe akun (Basic, Premium, dan Deluxe)
CREATE TABLE tipe_akun (
	id SERIAL PRIMARY KEY,
	nama VARCHAR(50) NOT NULL,
	deskripsi TEXT
);

-- Membuat tabel untuk entitas akun
CREATE TABLE akun (
	id UUID PRIMARY KEY,
	id_nasabah UUID NOT NULL,
	id_tipe_akun INT NOT NULL,
	no_akun VARCHAR(12) NOT NULL,
	saldo FLOAT NOT NULL,
	FOREIGN KEY (id_nasabah) REFERENCES nasabah(id),
	FOREIGN KEY (id_tipe_akun) REFERENCES tipe_akun(id)
);

-- Membuat tabel untuk entitas transaksi
CREATE TABLE transaksi (
	id UUID PRIMARY KEY,
	id_akun UUID NOT NULL,
	jenis_transaksi VARCHAR(25) NOT NULL,
	jumlah FLOAT NOT NULL,
	tanggal TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Menambahkan default dan fungsi generate UUID ke kolom id di tabel transaksi
ALTER TABLE transaksi
ALTER COLUMN id
SET DEFAULT gen_random_uuid();

-- Menambahkan dua data alamat
INSERT INTO 
alamat(id, nama_jalan, kota, provinsi, kode_pos)
VALUES
	('b4d4d052-6d30-489c-8c6e-2f2f2de364ba', 'Jalan Serdadu', 'Kapuas',
	'Kalimantan Tengah', '123456'),
	('5ec5c758-d2dd-488d-a4f5-5600614a9454', 'Jalan Kota Lama', 'Sampit',
	'Kalimantan Tengah', '123457');

-- Menambahkan dua data nasabah
INSERT INTO 
nasabah
	(id, nama_awal, nama_akhir, tanggal_lahir, no_telepon, 
	email, pekerjaan, kebangsaan, id_alamat)
VALUES
	('eb706567-7268-4809-b411-97f3f11b9fb8', 'Mamang', 'Suherman', '1998-05-15', '081234568901', 
	'mamang123@example.com', 'PNS', 'Indonesia', 'b4d4d052-6d30-489c-8c6e-2f2f2de364ba'),
	('437f4fd5-570a-46b5-9344-55c48e06da0b', 'Gudirman', 'Jomanto', '1985-02-23', '081234568952', 
	'jomanto_gudirman@example.com', 'Swasta', 'Indonesia', '5ec5c758-d2dd-488d-a4f5-5600614a9454');

-- Menambahkan tiga data tipe_akun
INSERT INTO tipe_akun(nama, deskripsi)
VALUES
	('Basic', 'Jenis akun yang cocok untuk keperluan sehari-hari anda'),
	('Premium', 'Jenis akun yang menawarkan fitur-fitur lengkap dan cepat'),
	('Deluxe', 'Jenis akun untuk anda yang termasuk prioritas dilengkapi fitur canggih');

-- Menambahkan dua data akun
INSERT INTO akun(id, id_nasabah, id_tipe_akun, no_akun, saldo)
VALUES
	('99d4c533-ae00-49f2-86b9-fea0ed9bc79b', 'eb706567-7268-4809-b411-97f3f11b9fb8', 1, 
	'332-552-3321', 5000),
	('415d87bf-332d-4306-964f-4c95e9cddb05', '437f4fd5-570a-46b5-9344-55c48e06da0b', 3,
	'990-111-1113', 150000);

-- Mencoba join tabel nasabah dengan tabel alamat
SELECT *
FROM nasabah n
JOIN alamat a on n.id_alamat  = a.id;

-- Membuat procedure tarik_uang untuk operasi penarikan (withdrawal)
CREATE OR REPLACE PROCEDURE tarik_uang(
  id_akun_tarik UUID,
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
	INSERT INTO transaksi (id_akun, jenis_transaksi, jumlah )
	VALUES (id_akun_tarik, 'Withdrawal', jumlah_tarik);

	COMMIT;
END$$

-- Panggil prosedur tarik_uang dengan parameter id_akun dan nominal uang
CALL tarik_uang('415d87bf-332d-4306-964f-4c95e9cddb05', 5000);

-- Menampilkan semua data untuk akun dengan akun.id
SELECT * FROM akun WHERE akun.id = '415d87bf-332d-4306-964f-4c95e9cddb05';

-- Membuat procedure simpan_uang untuk operasi penyimpanan (deposit)
CREATE OR REPLACE PROCEDURE simpan_uang(
  id_akun_tarik UUID,
  jumlah_tarik FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
	-- tambahkan saldo di akun
	UPDATE akun
	SET saldo = saldo + jumlah_tarik
	WHERE id = id_akun_tarik;

	-- tambahkan ke table transaksi
	INSERT INTO transaksi (id_akun, jenis_transaksi, jumlah )
	VALUES (id_akun_tarik, 'Deposit', jumlah_tarik);

	COMMIT;
END$$

-- Panggil prosedur simpan_uang dengan parameter id_akun dan nominal uang
CALL simpan_uang('415d87bf-332d-4306-964f-4c95e9cddb05', 10000);


-- SELESAI, untuk sekarang.... hehehe