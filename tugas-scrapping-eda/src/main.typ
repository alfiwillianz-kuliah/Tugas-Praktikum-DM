#set document(title: "Tugas Praktikum EDA dan Scraping", author: "Malfino Muhammad Willianz")

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


// Placeholder gambar.
// Ganti pemanggilan fungsi ini dengan #image("nama-file.png", width: 90%)
// apabila gambar sudah tersedia.
#let image-placeholder(caption, height: 6cm) = figure(
  rect(
    width: 90%,
    height: height,
    stroke: 0.6pt + gray,
    radius: 4pt,
    inset: 10pt,
    align(center + horizon)[
      #text(fill: gray, style: "italic")[
        Placeholder Gambar \
        #caption
      ]
    ]
  ),
  caption: caption,
)


#align(center)[
  #text(16pt, weight: "bold")[Tugas Praktikum EDA dan Scraping] \

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

Dataset yang digunakan merupakan data planet kecil (*minor planets*) yang diperoleh melalui proses *web scraping* dari Wikipedia. Pengambilan data dilakukan terhadap 5.000 planet kecil pertama, dengan halaman sumber dibagi menjadi lima rentang yang masing-masing berisi 1.000 objek.

Hasil proses scraping menghasilkan dataset dengan *5.000 observasi* dan *6 atribut*. Atribut `number` digunakan sebagai nomor identifikasi objek, sedangkan lima atribut lainnya digunakan dalam proses eksplorasi data, yaitu tanggal penemuan, lokasi penemuan, penemu, kategori, dan diameter objek.

#table(
  columns: (1.2fr, 1.2fr, 3.6fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [*Atribut*], [*Tipe Atribut*], [*Penjelasan*],

  [`number`],
  [ Identifier],
  [Nomor katalog planet kecil. Walaupun disimpan dalam bentuk bilangan bulat, atribut ini digunakan sebagai identitas objek dan bukan sebagai besaran numerik.],

  [`discovery_date`],
  [Ordinal \ atau \ Temporal],
  [Tanggal penemuan memiliki urutan kronologis yang jelas dan dapat diturunkan menjadi tahun, dekade, maupun bulan untuk analisis temporal.],

  [`discovery_site`],
  [Nominal],
  [Nama lokasi atau observatorium tempat objek ditemukan dan tidak memiliki urutan alami.],

  [`discoverer`],
  [Nominal],
  [Nama individu, kelompok, atau institusi yang tercatat sebagai penemu tanpa tingkatan atau urutan tertentu.],

  [`category`],
  [Nominal],
  [Kategori planet kecil seperti EOS, THM, KOR, dan kategori lainnya tanpa urutan alami.],

  [`diameter_km`],
  [Numerik Kontinu],
  [Diameter objek dalam kilometer yang dapat memiliki nilai pecahan dan memiliki makna pengukuran kuantitatif.],
)

#v(1em)

Sebelum analisis dilakukan, atribut `discovery_date` dikonversi menjadi tipe data tanggal. Beberapa simbol pada `category` yang merepresentasikan informasi tidak tersedia juga diubah menjadi nilai kosong agar dapat dianalisis secara konsisten.


= Statistik Deskriptif

== Atribut Numerik

Atribut numerik utama yang dianalisis adalah `diameter_km`. Dari 5.000 objek, seluruh observasi memiliki informasi diameter.

#table(
  columns: (1.5fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [*Statistik*], [*Diameter (km)*],

  [Jumlah observasi], [5.000],
  [Rata-rata], [26,84],
  [Standar deviasi], [37,36],
  [Minimum], [0,25],
  [Kuartil 1], [7,50],
  [Median], [14,00],
  [Kuartil 3], [30,00],
  [Maksimum], [939,00],
)

Nilai rata-rata diameter sebesar 26,84 km berada cukup jauh di atas median sebesar 14 km. Perbedaan tersebut mengindikasikan distribusi yang tidak simetris dan adanya sejumlah objek dengan diameter yang jauh lebih besar dibandingkan mayoritas objek lainnya.

Tanggal penemuan dalam dataset berada pada rentang *1 Januari 1801* hingga *15 Agustus 1991*. Median tanggal penemuan berada sekitar tahun 1968, sedangkan kuartil ketiga berada sekitar tahun 1981.


== Atribut Kategorikal

Dataset memiliki *132 lokasi penemuan* yang berbeda. Lokasi yang paling sering muncul adalah *Heidelberg* dengan 797 penemuan.

Atribut `discoverer` memiliki *379 nilai unik*, dengan *K. Reinmuth* sebagai entri penemu yang paling sering muncul sebanyak 373 kali.

Sebelum penanganan nilai hilang, atribut `category` memiliki 2.120 nilai yang tersedia dan mencakup *196 kategori berbeda*. Kategori yang paling sering muncul adalah *EOS* sebanyak 270 observasi.


= Penanganan Data

== Nilai Hilang

#table(
  columns: (2fr, 1fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [*Atribut*], [*Jumlah Missing*], [*Persentase*],

  [`number`], [0], [0,00%],
  [`discovery_date`], [0], [0,00%],
  [`discovery_site`], [0], [0,00%],
  [`discoverer`], [0], [0,00%],
  [`category`], [2.880], [57,60%],
  [`diameter_km`], [0], [0,00%],
)

Analisis missing value menunjukkan bahwa hanya atribut `category` yang memiliki nilai hilang. Dari 5.000 observasi, terdapat *2.880 observasi* dengan kategori yang tidak tersedia atau sebesar *57,60%* dari keseluruhan dataset.

Karena jumlah nilai hilang mencapai lebih dari setengah dataset, penghapusan seluruh baris dengan `category` kosong tidak dilakukan. Menghapus observasi tersebut akan menyebabkan kehilangan informasi dalam jumlah yang sangat besar, termasuk informasi pada variabel lain yang sebenarnya lengkap.

Sebagai langkah penanganan, nilai kosong pada `category` dipertahankan sebagai sebuah kategori baru bernama `Unknown`. Pendekatan ini memungkinkan seluruh observasi tetap digunakan dalam analisis sekaligus mempertahankan informasi bahwa kategori asli objek tersebut tidak tersedia.


== Outlier

Deteksi outlier dilakukan terhadap `diameter_km` menggunakan metode *Interquartile Range* (IQR). Batas outlier ditentukan menggunakan aturan 1,5 kali IQR di bawah kuartil pertama dan di atas kuartil ketiga.

Hasil identifikasi menunjukkan terdapat *524 observasi* yang dikategorikan sebagai outlier. Mayoritas outlier berada pada sisi atas distribusi dan merepresentasikan planet kecil dengan diameter jauh lebih besar dibandingkan objek pada umumnya.



#figure(
  image("boxplot.png", height: 7cm),
  caption: [Distribusi Diameter Planet Kecil dan Identifikasi Outlier],
)


Outlier tersebut tidak dihapus karena objek dengan diameter sangat besar masih merupakan observasi yang valid secara domain. Sebagai gantinya, transformasi logaritmik digunakan pada beberapa visualisasi agar pola distribusi dan hubungan antarvariabel dapat terlihat lebih jelas.


= Visualisasi dan Interpretasi

== Distribusi Diameter Planet Kecil
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  
  figure(
  image("hist.png", height: 7cm),
  caption: [Histogram Distribusi Diameter Planet Kecil],
),

  figure(
  image("image (9).png", height: 7cm),
  caption: [Distribusi Diameter Planet Kecil pada Skala Logaritmik],
),
)


Distribusi `diameter_km` menunjukkan pola yang sangat *right-skewed*. Sebagian besar planet kecil memiliki diameter yang relatif kecil, sedangkan hanya sedikit objek yang memiliki diameter sangat besar. Kondisi tersebut menghasilkan ekor distribusi yang panjang ke arah kanan.

Boxplot menunjukkan terdapat 524 observasi yang teridentifikasi sebagai outlier berdasarkan aturan IQR, terutama pada objek dengan diameter puluhan hingga ratusan kilometer.

Ketika divisualisasikan menggunakan skala logaritmik, distribusi menjadi lebih jelas dan mendekati bentuk unimodal. Konsentrasi terbesar berada pada kisaran sekitar 10 km hingga beberapa puluh kilometer. Transformasi log membantu mengurangi dominasi nilai ekstrem sehingga pola distribusi utama lebih mudah diamati.

Hasil tersebut juga menunjukkan bahwa median lebih representatif dibandingkan rata-rata untuk menggambarkan ukuran tipikal planet kecil pada dataset.


== Jumlah Penemuan per Dekade

#figure(
  image("image (10).png", height: 7cm),
  caption: [Jumlah Penemuan Planet Kecil per Dekade],
)

Secara umum, jumlah penemuan planet kecil mengalami tren peningkatan dari abad ke-19 hingga abad ke-20. Peningkatan paling besar terlihat pada dekade 1970-an dan 1980-an.

Pola ini dapat mengindikasikan peningkatan kemampuan observasi astronomi dan berkembangnya metode survei dari waktu ke waktu.

Namun, rendahnya jumlah observasi pada dekade 1990-an tidak dapat langsung dianggap sebagai penurunan jumlah penemuan secara global. Dataset yang digunakan hanya mencakup 5.000 planet kecil pertama berdasarkan nomor katalog, sehingga distribusi temporalnya juga dipengaruhi oleh batas dataset.


== Distribusi Penemuan Berdasarkan Bulan


#figure(
  image("image (11).png", height: 7cm),
  caption: [Distribusi Penemuan Planet Kecil Berdasarkan Bulan],
)

Distribusi penemuan berdasarkan bulan menunjukkan pola yang tidak merata sepanjang tahun. Frekuensi tertinggi terjadi pada *September*, dengan jumlah mendekati 1.000 penemuan, kemudian diikuti oleh Oktober dan Agustus.

Sebaliknya, jumlah penemuan relatif rendah pada periode Mei hingga Juli, dengan titik terendah berada sekitar bulan Juni.

Pola tersebut menunjukkan indikasi *seasonality* pada waktu penemuan planet kecil dalam dataset. Akan tetapi, tingginya frekuensi pada bulan tertentu tidak dapat langsung diartikan sebagai probabilitas intrinsik planet kecil untuk ditemukan pada bulan tersebut. Pola ini juga dapat dipengaruhi kondisi cuaca, posisi objek astronomi, lokasi observatorium, serta intensitas kegiatan survei.


== Lokasi Penemuan

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,

  figure(
    image("image (12).png", height: 6cm),
    caption: [15 Lokasi Penemuan Planet Kecil Terbanyak],
  ),

  figure(
    image("image (13).png", height: 6cm),
    caption: [Persentase 15 Lokasi Penemuan Planet Kecil Teratas],
  ),
)

Distribusi lokasi penemuan menunjukkan bahwa aktivitas penemuan cukup terkonsentrasi pada beberapa observatorium tertentu. *Heidelberg* menjadi lokasi dengan jumlah penemuan terbesar, yaitu sekitar *15,9%* dari seluruh observasi, disusul oleh *Nauchnij* sebesar *13,7%*, *Palomar* sebesar *8,6%*, dan *Anderson Mesa* sebesar *7,6%*.

Empat lokasi tersebut secara bersama-sama menyumbang hampir setengah dari keseluruhan observasi. Di sisi lain, kategori `Lainnya`, yang mencakup seluruh lokasi di luar 15 besar, masih menyumbang sekitar *24,8%*.

Hal ini menunjukkan bahwa walaupun beberapa observatorium memiliki kontribusi yang sangat besar, aktivitas penemuan tetap tersebar pada banyak lokasi lainnya.

Dominasi suatu lokasi dapat dipengaruhi kapasitas observatorium, intensitas program survei, kualitas instrumen, dan periode operasional. Oleh karena itu, hasil ini tidak dapat digunakan untuk menyimpulkan bahwa suatu lokasi secara intrinsik lebih baik untuk menemukan planet kecil.


== Distribusi Penemu

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,

  figure(
    image("image (14).png", height: 6cm),
    caption: [15 Penemu Planet \ Kecil Terbanyak],
  ),

  figure(
    image("image (15).png", height: 6cm),
    caption: [Persentase 15 Penemu Planet Kecil Teratas],
  ),
)


Distribusi berdasarkan `discoverer` menunjukkan bahwa aktivitas penemuan lebih tersebar dibandingkan lokasi observasi. *K. Reinmuth* menjadi entri penemu dengan jumlah tertinggi dan menyumbang sekitar *7,5%* dari seluruh dataset.

Posisi berikutnya ditempati oleh *N. S. Chernykh* sebesar *6,1%*, *E. Bowell* sebesar *6,0%*, dan *M. F. Wolf* sebesar *4,5%*.

Kategori `Lainnya` mencapai *52,8%*. Dengan demikian, 15 entri penemu teratas hanya mencakup sekitar *47,2%* dari keseluruhan observasi. Hal ini menunjukkan bahwa aktivitas penemuan planet kecil tersebar pada banyak penemu.

Kolom `discoverer` juga tidak selalu merepresentasikan individu. Beberapa nilai merepresentasikan institusi seperti Purple Mountain dan Indiana University, sedangkan beberapa observasi mencantumkan beberapa orang sekaligus. Oleh karena itu, distribusi ini lebih tepat dipahami sebagai distribusi berdasarkan entri penemu yang tercatat pada sumber data, bukan perbandingan produktivitas individu secara langsung.


== Distribusi Kategori Planet Kecil

#figure(
  image("image (16).png", height: 7cm),
  caption: [Distribusi Kategori Planet Kecil],
)

Sebagian besar objek tidak memiliki informasi kategori, ditunjukkan oleh kelompok `Unknown` sebesar *57,6%*. Hal tersebut konsisten dengan hasil analisis missing value sebelumnya.

Di antara keseluruhan dataset, kategori *EOS* memiliki proporsi sekitar *5,4%*, diikuti oleh *THM* sebesar *4,9%*, serta *KOR* dan `slow` masing-masing sekitar *3,3%*. Kategori di luar kategori-kategori utama yang digabungkan menjadi `Lainnya` menyumbang sekitar *12,7%*.

Distribusi ini menunjukkan bahwa objek yang memiliki informasi kategori cukup beragam dan tidak didominasi secara ekstrem oleh satu kategori tertentu. Namun, karena lebih dari setengah nilai `category` tidak tersedia, komposisi kategori tidak dapat dianggap merepresentasikan distribusi kategori seluruh populasi planet kecil secara langsung.


== Hubungan Tahun Penemuan dan Diameter

#figure(
  image("image (17).png", height: 7cm),
  caption: [Hubungan Tahun Penemuan dan Diameter Planet Kecil],
)


Scatter plot menunjukkan adanya hubungan negatif antara tahun penemuan dan diameter planet kecil. Korelasi Spearman menghasilkan nilai *rho = -0,53*, yang menunjukkan hubungan negatif dengan kekuatan sedang.

Artinya, planet kecil yang ditemukan pada tahun yang lebih baru cenderung memiliki diameter yang lebih kecil dibandingkan objek yang ditemukan pada periode sebelumnya.

Garis tren yang menurun memperkuat pola tersebut. Pada awal periode observasi, objek yang ditemukan umumnya memiliki diameter relatif besar. Seiring waktu, distribusi diameter menjadi lebih luas dan mencakup semakin banyak objek berdiameter kecil.

Transformasi log10 terhadap diameter digunakan agar pengaruh objek dengan diameter ekstrem berkurang dan hubungan antarvariabel dapat diamati dengan lebih jelas.

Pola ini dapat mengindikasikan perkembangan kemampuan observasi astronomi, di mana peningkatan sensitivitas instrumen dan metode survei memungkinkan pendeteksian objek yang lebih kecil. Namun, hubungan tersebut bersifat korelasional dan tidak menunjukkan hubungan sebab-akibat secara langsung.


= Kesimpulan

Berdasarkan hasil eksplorasi, dataset planet kecil menunjukkan beberapa karakteristik utama. Distribusi diameter sangat menceng ke kanan dan mengandung sejumlah besar nilai ekstrem, sehingga penggunaan median dan transformasi logaritmik lebih sesuai untuk memahami pola ukuran objek.

Dari sisi temporal, jumlah penemuan meningkat secara umum menuju akhir abad ke-20, dengan pola musiman yang menunjukkan frekuensi penemuan relatif tinggi pada periode Agustus hingga Oktober.

Aktivitas penemuan cukup terkonsentrasi pada beberapa observatorium utama, tetapi lebih tersebar jika dilihat berdasarkan penemu. Selain itu, lebih dari setengah observasi tidak memiliki informasi kategori sehingga interpretasi komposisi kategori perlu dilakukan secara hati-hati.

Hubungan antara tahun penemuan dan diameter menghasilkan korelasi Spearman sebesar -0,53. Hal tersebut menunjukkan bahwa objek yang ditemukan pada periode yang lebih baru cenderung memiliki ukuran lebih kecil. Temuan ini konsisten dengan dugaan bahwa peningkatan kemampuan observasi memungkinkan pendeteksian objek berukuran lebih kecil, meskipun hubungan sebab-akibat tidak dapat ditentukan hanya berdasarkan EDA.