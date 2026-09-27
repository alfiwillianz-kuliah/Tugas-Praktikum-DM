# **Tugas Praktikum 2: Praproses Data**

## 

## **Deskripsi Singkat**

Pada praktikum ini, mahasiswa melakukan tahapan praproses data agar dataset siap digunakan untuk analisis atau model machine learning: menangani nilai yang hilang, mendeteksi dan menangani outlier, serta melakukan transformasi data (normalisasi dan encoding).

## 

## **Tujuan Praktikum**

1. Memahami dan menerapkan langkah-langkah praproses data seperti pembersihan, transformasi, dan reduksi data.  
2. Meningkatkan kualitas data melalui penanganan nilai yang hilang dan data yang tidak konsisten.  
3. Menerapkan teknik transformasi data seperti normalisasi dan encoding.

## 

## **Ketentuan Dataset**

* Dataset: **House Prices \- Advanced Regression Techniques** (Kaggle), berisi informasi harga rumah beserta atribut seperti ukuran, tahun dibangun, dan kondisi rumah.  
* Link: [https://www.kaggle.com/competitions/house-prices-advanced-regression-techniques/data?select=train.csv](https://www.kaggle.com/competitions/house-prices-advanced-regression-techniques/data?select=train.csv)  
* Gunakan file **train.csv** saja (1460 baris, 81 kolom).

## 

## **Langkah-Langkah Praktikum**

**1\. Unduh dan Import Dataset**

* Unduh train.csv dari link di atas, lalu impor menggunakan pandas.  
* Tampilkan .head(), .shape, dan .info() untuk memahami struktur data.

  **2\. Pembersihan Data**

* Periksa jumlah nilai yang hilang pada setiap atribut menggunakan pandas.  
* Hapus kolom/atribut dengan proporsi nilai hilang lebih dari 50%.  
* Tangani nilai hilang   
    
  **3\. Deteksi dan Penanganan Outlier**

* Gunakan boxplot untuk mendeteksi outlier pada atribut numerik.  
* Tentukan apakah outlier dihapus atau disesuaikan, dan jelaskan alasannya.

  **4\. Transformasi Data**

* Lakukan normalisasi/standarisasi atribut.  
* Lakukan encoding atribut kategoris menggunakan one-hot encoding.

  **5\. Reduksi Dimensi**

* Gunakan analisis korelasi untuk mengidentifikasi atribut yang sangat berkorelasi, lalu buang salah satunya jika perlu.  
* Gunakan PCA (*Principal Component Analysis*) untuk mengurangi dimensi data.

  **6\. Penyusunan Laporan**

  Tulis laporan **minimal 2 halaman**, dilengkapi dengan visualisasi, berisi:

* Langkah-langkah praproses yang dilakukan.  
* Hasil dari setiap tahapan praproses.  
* Ringkasan dataset akhir setelah praproses.

## 

## **Hasil yang Diharapkan**

1. Dataset yang bersih dan siap digunakan, dengan nilai hilang dan outlier sudah ditangani.  
2. Transformasi data yang telah dilakukan (normalisasi/standarisasi dan encoding).  
3. Laporan minimal 2 halaman yang mencakup hasil tiap langkah praproses, dilengkapi dengan visualisasi.

## 

## **Ketentuan Repository GitHub**

* Gunakan **repository GitHub pribadi yang sama** (dan tetap **public**) seperti pada Praktikum 1\.  
* Untuk tugas ini, buat folder bernama **tugas-praproses-data** di dalam repository, berisi file .ipynb, .pdf, dan .csv (dataset akhir) sesuai ketentuan penamaan di bawah.

## 

## 

## **Contoh struktur repo**

nama-repo/  
├── tugas-scrapping-eda/  
│   └── ...  
├── tugas-praproses-data/  
│   ├── NRP\_Nama\_Tugas\_Praproses\_Data.ipynb  
│   ├── NRP\_Nama\_Tugas\_Praproses\_Data.pdf  
│   └── NRP\_Nama\_Tugas\_Praproses\_Data.csv  
└── (folder tugas praktikum lain menyusul setiap minggunya)

## 

## **Format Pengumpulan**

* File: .ipynb \+ .pdf \+ .csv (dataset hasil praproses)  
* Penamaan file: NRP\_Nama\_Tugas\_Praproses\_Data (kecuali .csv)  
* Pengumpulan: kirim **link folder tugas-praproses-data** pada repository GitHub melalui Google Form berikut: [https://forms.gle/Z91PQCFDfJR81uZx5](https://forms.gle/Z91PQCFDfJR81uZx5)  
* Deadline: **Minggu, 27 September 2026**, pukul 23:59 WIB

## 

## **Penilaian**

| Komponen | Bobot | Kriteria |
| :---- | :---- | :---- |
| Pembersihan Data | 30% | Ketepatan penanganan nilai hilang, outlier, dan data tidak konsisten |
| Transformasi Data | 30% | Kesesuaian penerapan normalisasi/standarisasi dan encoding (one-hot) |
| Reduksi Dimensi | 20% | Pemahaman dalam memilih atribut yang relevan |
| Laporan | 20% | Kerapihan, kelengkapan, dan kejelasan laporan |

