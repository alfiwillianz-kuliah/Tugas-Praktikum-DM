#set document(title: "Tugas Praktikum Praproses Data", author: "Malfino Muhammad Willianz")

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
)

#set text(
  font: "Linux Libertine",
  size: 12pt,
  lang: "id",
)

#set par(
  justify: true,
  leading: 0.75em,
)

#set heading(numbering: "1.")


#align(center)[
  #text(16pt, weight: "bold")[Tugas Praktikum Praproses Data] \

  #text(12pt, weight: "bold")[
    Malfino Muhammad Willianz - 5054251028
  ] \

  #text(12pt)[
    Dept. Teknik Informatika,
    Prodi Rekayasa Kecerdasan Artifisial
  ]
]

#v(2em)


= Deskripsi Dataset

Dataset yang digunakan pada praktikum ini adalah _House Prices - Advanced Regression Techniques_ yang diperoleh dari Kaggle. Dataset berisi informasi penjualan rumah beserta sejumlah atribut yang menggambarkan ukuran bangunan, tahun pembangunan, kualitas material, kondisi rumah, hingga lokasi lingkungan tempat rumah berada.

Berkas yang digunakan adalah `train.csv` dengan 1.460 observasi dan 81 kolom. Atribut `Id` digunakan sebagai identitas baris, sedangkan `SalePrice` merupakan atribut target yang merepresentasikan harga jual rumah dalam satuan dolar. Tujuan tahapan praproses ini adalah menghasilkan dataset yang bersih, konsisten, dan siap digunakan untuk analisis maupun pemodelan _machine learning_.

#v(1em)

Secara umum, atribut pada dataset dapat dikelompokkan menjadi beberapa tipe:

#table(
  columns: (1.2fr, 1.2fr, 3.6fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [Kelompok Atribut], [Tipe], [Contoh dan Penjelasan],

  [`Id`],
  [Identifier],
  [Nomor identitas baris dan tidak memiliki makna sebagai besaran numerik, sehingga dikeluarkan dari proses transformasi.],

  [Atribut kategorikal],
  [Nominal \ dan Ordinal],
  [`MSZoning`, `Neighborhood`, `Street`, `ExterQual`, dan `KitchenQual`. Sebagian besar bersifat nominal, sedangkan atribut kualitas seperti `ExterQual` bersifat ordinal.],

  [Atribut numerik],
  [Diskret \ dan Kontinu],
  [`LotArea`, `GrLivArea`, `YearBuilt`, dan `GarageArea`. Atribut ini menggambarkan besaran kuantitatif yang dapat digunakan langsung dalam perhitungan.],

  [`MSSubClass`],
  [Nominal],
  [Walaupun tersimpan sebagai bilangan bulat, atribut ini merupakan kode tipe bangunan sehingga diperlakukan sebagai kategori.],

  [`SalePrice`],
  [Numerik Kontinu],
  [Harga jual rumah dalam dolar dan digunakan sebagai atribut target.],

  [`SaleType` & `SaleCondition`],
  [Nominal],
  [Menjelaskan jenis dan kondisi penjualan rumah, tanpa urutan alami.],
)


= Pemeriksaan Data Awal

Sebelum dilakukan praproses, struktur data diperiksa terlebih dahulu. Dataset memiliki 1.460 baris dan 80 atribut selain `Id`. Dari pemeriksaan tipe data, terdapat 38 atribut kategorikal dan 39 atribut numerik, dengan `SalePrice` sebagai target.

Distribusi `SalePrice` menunjukkan pola yang tidak simetris. Nilai rata-rata berada pada 180.921 dolar, sedangkan nilai median sebesar 163.000 dolar. Rata-rata yang lebih tinggi daripada median mengindikasikan adanya sejumlah rumah dengan harga jual yang sangat tinggi dan menarik ekor distribusi ke arah kanan.

#table(
  columns: (1.5fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [Statistik], [SalePrice (USD)],

  [Jumlah observasi], [1.460],
  [Rata-rata], [180.921],
  [Standar deviasi], [79.443],
  [Minimum], [34.900],
  [Kuartil 1], [129.975],
  [Median], [163.000],
  [Kuartil 3], [214.000],
  [Maksimum], [755.000],
)


= Pembersihan Data

== Penanganan Nilai Hilang

Pemeriksaan nilai hilang menunjukkan bahwa dari 80 atribut, terdapat 19 atribut yang memiliki nilai kosong. Sebagian besar nilai kosong tersebut terpusat pada sejumlah kecil atribut dengan proporsi yang sangat tinggi.

#table(
  columns: (1.7fr, 1fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [Atribut], [Jumlah Hilang], [Persentase],

  [`PoolQC`], [1.453], [99,52%],
  [`MiscFeature`], [1.406], [96,30%],
  [`Alley`], [1.369], [93,77%],
  [`Fence`], [1.179], [80,75%],
  [`MasVnrType`], [872], [59,73%],
  [`FireplaceQu`], [690], [47,26%],
  [`LotFrontage`], [259], [17,74%],
  [`GarageType`], [81], [5,55%],
  [`BsmtQual`], [37], [2,53%],
  [`Electrical`], [1], [0,07%],
)

#v(1em)

#figure(
  image("missing_raw.png", height: 9cm),
  caption: [Persentase Nilai Hilang per Atribut pada Data Mentah],
)

Penghapusan atribut dengan nilai hilang di atas 50%. Sebanyak 5 atribut memiliki proporsi nilai hilang lebih dari 50%, yaitu `PoolQC`, `MiscFeature`, `Alley`, `Fence`, dan `MasVnrType`. Kelima atribut tersebut dibuang karena jumlah informasi yang tersedia sangat sedikit sehingga tidak cukup andal untuk dianalisis. Setelah penghapusan, jumlah atribut berkurang dari 81 menjadi 76 atribut.

Penanganan nilai hilang pada atribut kategorikal. Untuk atribut seperti `FireplaceQu`, `GarageType`, `GarageFinish`, `GarageQual`, `GarageCond`, dan atribut _basement_ seperti `BsmtQual`, `BsmtCond`, `BsmtExposure`, `BsmtFinType1`, serta `BsmtFinType2`, nilai kosong sebenarnya menandakan bahwa fasilitas tersebut tidak dimiliki oleh rumah. Oleh karena itu, nilai kosong diisi dengan kategori baru bernama `None` agar maknanya menjadi eksplisit. Nilai kosong tunggal pada `Electrical` diisi dengan nilai modus atribut.

Penanganan nilai hilang pada atribut numerik. Nilai kosong pada `LotFrontage` diisi menggunakan median per lingkungan (`Neighborhood`), karena lebar muka tanah sangat bergantung pada karakteristik tiap kawasan. `GarageYrBlt` diisi dengan `YearBuilt`, dengan asumsi garasi dibangun bersamaan dengan rumah. `MasVnrArea` yang kosong diisi dengan nilai 0 karena ketiadaan data pada umumnya berarti rumah tersebut tidak memiliki pelapisan batu. Setelah seluruh langkah tersebut, dataset tidak lagi mengandung nilai hilang.


== Deteksi dan Penanganan Outlier

Deteksi _outlier_ dilakukan pada atribut numerik menggunakan metode _Interquartile Range_ (IQR), dengan batas 1,5 kali IQR di bawah kuartil pertama dan di atas kuartil ketiga. Hasil pemeriksaan menunjukkan terdapat 1.493 nilai _outlier_ yang tersebar pada 29 atribut numerik.

#v(0.5em)

#figure(
  image("boxplot_outlier.png", height: 6cm),
  caption: [Boxplot `SalePrice` dan `GrLivArea` sebelum Penanganan Outlier],
)

Untuk atribut `GrLivArea` (luas bangunan di atas tanah) ditemukan 31 observasi _outlier_. Sebagian besar _outlier_ tersebut merupakan rumah berukuran sangat besar dengan harga jual tinggi, sehingga masih merupakan observasi yang valid.

#v(0.5em)

#figure(
  image("scatter_outlier.png", height: 8cm),
  caption: [Hubungan `GrLivArea` dan `SalePrice` dengan Penanda Outlier IQR],
)

_Outlier_ pada dataset ini tidak dihapus. Alasan utamanya adalah bahwa nilai-nilai ekstrem tersebut merupakan data nyata dari proses penjualan rumah, bukan kesalahan pencatatan, dan justru mengandung informasi penting mengenai rumah berukuran besar maupun bernilai tinggi. Menghapusnya berpotensi menghilangkan pola yang relevan, terutama karena jumlah _outlier_ mencapai sekitar 61% baris jika dihitung per baris.

Sebagai gantinya, dua strategi digunakan:
#v(0.3em)

- _Winsorization_ (_capping_) diterapkan pada atribut numerik selain target, yaitu nilai yang berada di luar batas IQR dipotong ke batas tersebut. Sebanyak 30 atribut mengalami proses ini sehingga pengaruh nilai ekstrem dapat dikurangi tanpa menghilangkan observasi.
- Transformasi logaritmik diterapkan pada atribut dengan kemencengan tinggi agar distribusinya lebih mendekati normal.

#v(0.5em)

#figure(
  image("hist_livarea.png", height: 6cm),
  caption: [Perbandingan Distribusi `GrLivArea` sebelum dan sesudah Transformasi Logaritmik],
)

Transformasi `log1p` menurunkan kemencengan `GrLivArea` dari 1,37 menjadi sekitar 0,00, sehingga distribusinya menjadi jauh lebih simetris. Pendekatan ini membantu model yang sensitif terhadap skala dan nilai ekstrem.


= Transformasi Data

== Normalisasi / Standarisasi

Langkah standarisasi dilakukan menggunakan metode _z-score_ melalui `StandardScaler`, yaitu setiap atribut numerik dikurangi rata-ratanya dan dibagi dengan standar deviasinya. Proses ini diterapkan pada seluruh atribut numerik kecuali `Id` dan `SalePrice`.

#v(0.5em)

#figure(
  image("standardize_dist.png", height: 6cm),
  caption: [Distribusi `GrLivArea` sebelum dan sesudah Standarisasi],
)

Standarisasi tidak mengubah bentuk distribusi, tetapi menempatkan seluruh atribut pada skala yang sebanding, yaitu berpusat pada nilai 0 dengan simpangan baku 1. Hal ini penting karena banyak algoritma seperti PCA, _k-nearest neighbor_, dan regresi dengan regularisasi menjadi sensitif apabila antar-atribut memiliki skala yang jauh berbeda (`LotArea` dalam puluhan ribu meter persegi dibandingkan `OverallQual` yang bernilai 1--10).


== Encoding Atribut Kategorikal

Seluruh atribut kategorikal (sebanyak 38 atribut, termasuk `MSSubClass`) diubah menjadi representasi numerik menggunakan _one-hot encoding_. Setiap kategori diubah menjadi kolom biner baru yang bernilai 1 apabila kategori tersebut muncul dan 0 apabila tidak.

Setelah proses _encoding_, jumlah atribut berkembang dari 76 atribut asli menjadi 296 kolom, sedangkan jumlah baris tetap 1.460. Atribut `MSSubClass` ikut di-_encode_ karena meskipun bertipe bilangan bulat, nilainya merepresentasikan kode kategori tipe bangunan dan bukan besaran numerik yang dapat diurutkan.

Pendekatan _one-hot_ dipilih karena mayoritas atribut kategorikal bersifat nominal dan tidak memiliki urutan alami. Pemberian label angka pada atribut nominal dapat memunculkan asumsi urutan yang keliru pada model.


= Reduksi Dimensi

== Analisis Korelasi

Setelah _encoding_, dilakukan pemeriksaan korelasi antar-atribut numerik untuk mengidentifikasi atribut yang redundan. Ambang batas yang digunakan adalah korelasi absolut di atas 0,90, karena pasangan atribut dengan korelasi setinggi itu membawa informasi yang hampir sama.

#v(0.5em)

#figure(
  image("corr_heatmap.png", height: 9cm),
  caption: [Matriks Korelasi Atribut Numerik Utama terhadap `SalePrice`],
)

Hubungan terkuat terhadap `SalePrice` ditemukan pada `OverallQual` (0,79), `GrLivArea` (0,71), `GarageCars` (0,64), dan `GarageArea` (0,62). Beberapa pasangan atribut juga menunjukkan korelasi yang sangat tinggi, misalnya `GarageCars` dengan `GarageArea`, serta `TotalBsmtSF` dengan `1stFlrSF`.

Dari hasil tersebut, sebanyak 25 atribut yang sangat berkorelasi dengan atribut lain dibuang, sehingga jumlah kolom berkurang dari 296 menjadi 271 kolom. Pembuangan ini mengurangi redundansi dan dimensi data tanpa kehilangan informasi yang berarti.


== Principal Component Analysis (PCA)

Sebagai tahap reduksi dimensi lanjutan, _Principal Component Analysis_ (PCA) diterapkan pada matriks fitur yang telah distandarisasi. PCA mengubah atribut-asli menjadi komponen-komponen utama yang saling tegak lurus (_orthogonal_), dengan komponen pertama menangkap varians terbesar.

#v(0.5em)

#figure(
  image("pca_scree.png", height: 6cm),
  caption: [Scree Plot dan Cumulative Explained Variance dari PCA],
)

Hasil PCA menunjukkan bahwa varians data tersebar pada banyak komponen, yang mengindikasikan bahwa atribut-atribut pada dataset relatif tidak saling bergantung dan masing-masing menyumbang informasi tersendiri. Komponen pertama hanya menjelaskan sekitar 6--7% varians, dan untuk mencapai 90% varians total diperlukan sekitar 144 komponen.

#v(0.5em)

#figure(
  image("pca_scatter.png", height: 8cm),
  caption: [Proyeksi Data pada Dua Komponen Utama Pertama],
)

Ketika data diproyeksikan pada dua komponen pertama, terlihat sebagian struktur dan pengelompokan, namun `SalePrice` tidak terpisah secara jelas hanya berdasarkan dua komponen. Hal ini wajar mengingat informasi harga rumah tersebar di banyak atribut, sehingga dibutuhkan lebih banyak komponen untuk merepresentasikannya secara memadai.


= Ringkasan Dataset Akhir

Setelah seluruh tahapan praproses, dataset akhir memiliki karakteristik sebagai berikut:

#table(
  columns: (2.3fr, 1.3fr, 1.3fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [Tahapan], [Jumlah Baris], [Jumlah Kolom],

  [Data mentah], [1.460], [81],
  [Setelah hapus atribut >50% hilang], [1.460], [76],
  [Setelah imputasi nilai hilang], [1.460], [76],
  [Setelah winsorization & transformasi log], [1.460], [76],
  [Setelah standarisasi & one-hot encoding], [1.460], [296],
  [Setelah pemangkasan korelasi], [1.460], [271],
)

#v(1em)

Dataset akhir tersimpan dalam berkas `5054251028_Malfino Muhammad Willianz_Tugas_Praproses_Data.csv` dengan 1.460 baris dan 296 kolom hasil _encoding_. Versi dataset yang telah dipangkas korelasinya (271 kolom) digunakan untuk analisis PCA.

Seluruh nilai hilang sudah ditangani, nilai ekstrem telah di-_winsorize_ dan ditransformasi, atribut numerik telah distandarisasi, serta atribut kategorikal telah dikodekan menjadi bentuk numerik. Dengan demikian, dataset telah bersih, konsisten, dan siap digunakan untuk tahap pemodelan.


= Kesimpulan

Berdasarkan tahapan praproses yang dilakukan, terdapat beberapa temuan utama. Dataset awal memiliki 19 atribut dengan nilai hilang, di mana 5 di antaranya melewati ambang 50% dan dibuang. Nilai hilang lainnya ditangani secara terarah sesuai makna tiap atribut, baik dengan kategori `None`, pengisian median per lingkungan, maupun asumsi berbasis domain.

_Outlier_ yang terdeteksi melalui metode IQR tidak dihapus karena merupakan observasi valid, tetapi ditangani melalui _winsorization_ dan transformasi logaritmik agar pengaruhnya berkurang sekaligus mempertahankan informasi. Kemencengan `GrLivArea` berhasil diturunkan dari 1,37 menjadi mendekati 0.

Transformasi data menghasilkan seluruh atribut numerik berskala seragam melalui standarisasi, sedangkan 38 atribut kategorikal dikodekan dengan _one-hot encoding_ sehingga jumlah kolom berkembang menjadi 296. Reduksi dimensi melalui pemangkasan korelasi mengurangi 25 atribut redundan, dan PCA menunjukkan bahwa varians data tersebar pada banyak komponen sehingga 90% varians memerlukan sekitar 144 komponen. Secara keseluruhan, dataset akhir telah siap digunakan untuk analisis lanjutan maupun pemodelan _machine learning_.
