#set document(title: "Tugas Praktikum Ensemble Method dan Class Imbalance", author: "Malfino Muhammad Willianz")

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
  #text(16pt, weight: "bold")[Tugas Praktikum Ensemble Method dan Class Imbalance] \

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

Dataset yang digunakan pada praktikum ini adalah _Credit Card Fraud Detection_ yang diperoleh dari Kaggle. Dataset berisi catatan transaksi kartu kredit selama dua hari, dengan tujuan membedakan transaksi normal dan transaksi penipuan.

Berkas yang digunakan adalah `creditcard.csv` dengan 284.807 baris dan 31 kolom. Atribut `Class` merupakan label target, di mana nilai `0` menandakan transaksi normal dan nilai `1` menandakan transaksi penipuan. Sebanyak 28 atribut, yaitu `V1` sampai `V28`, merupakan hasil transformasi _Principal Component Analysis_ (PCA) dari atribut asli yang dirahasiakan untuk melindungi privasi pemegang kartu. Atribut `Time` mencatat selisih waktu dalam detik dari transaksi pertama, sedangkan `Amount` mencatat nilai transaksi.

#v(1em)

Secara umum, atribut pada dataset dapat dikelompokkan menjadi beberapa tipe:

#table(
  columns: (1.2fr, 1.2fr, 3.6fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [*Atribut*], [*Tipe Atribut*], [*Penjelasan*],

  [`Time`],
  [Numerik Kontinu],
  [Selisih waktu dalam detik dari transaksi pertama. Tidak bermakna langsung sehingga diturunkan menjadi fitur jam.],

  [`V1`--`V28`],
  [Numerik Kontinu],
  [Komponen hasil PCA yang telah dinormalisasi dan saling ortogonal.],

  [`Amount`],
  [Numerik Kontinu],
  [Nilai transaksi dalam satuan mata uang, dengan skala jauh lebih besar dibanding `V1`--`V28`.],

  [`Class`],
  [Nominal Biner],
  [Label target. `0` = transaksi normal, `1` = transaksi penipuan (_fraud_).],
)

#v(1em)

Pemeriksaan awal menunjukkan dataset tidak memiliki nilai hilang, sehingga tahapan praproses lebih berfokus pada penanganan skala fitur dan distribusi kelas yang tidak seimbang.

= Eksplorasi Distribusi Kelas

== Ketidakseimbangan Kelas

Langkah pertama adalah mengidentifikasi distribusi kelas pada atribut `Class`. Hasilnya menunjukkan ketidakseimbangan yang sangat ekstrem.

#table(
  columns: (1.5fr, 1fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [*Kelas*], [*Jumlah*], [*Persentase*],

  [Normal (0)], [284.315], [99,8273%],
  [Fraud (1)], [492], [0,1727%],
)

#v(1em)

Rasio antara kelas mayoritas dan kelas minoritas mencapai sekitar *578:1*. Kondisi ini berarti kelas minoritas hampir tidak terwakili dalam dataset.

#v(0.5em)

#figure(
  image("class_distribution.png", height: 6cm),
  caption: [Distribusi Jumlah Transaksi per Kelas (Skala Linear dan Logaritmik)],
)

Perbedaan jumlah yang sangat besar membuat akurasi menjadi metrik yang menyesatkan. Model yang selalu memprediksi kelas normal akan memperoleh akurasi di atas 99%, tetapi sama sekali tidak mampu mendeteksi penipuan. Oleh karena itu, penanganan _class imbalance_ menjadi langkah yang wajib sebelum pemodelan.

== Statistik Deskriptif dan Pola Fitur

Atribut `Amount` memiliki distribusi yang sangat menceng ke kanan. Nilai rata-ratanya sebesar 88,35 sedangkan median hanya 22,00, yang mengindikasikan keberadaan sejumlah transaksi bernilai sangat besar.

#table(
  columns: (1.5fr, 1fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [*Statistik*], [*Amount*], [*Time (detik)*],

  [Jumlah observasi], [284.807], [284.807],
  [Rata-rata], [88,35], [94.813,86],
  [Standar deviasi], [250,12], [47.488,15],
  [Minimum], [0,00], [0,00],
  [Median], [22,00], [84.692,00],
  [Maksimum], [25.691,16], [172.792,00],
)

#v(0.5em)

#figure(
  image("amount_distribution.png", height: 6cm),
  caption: [Distribusi `Amount` dan Perbandingannya Antar Kelas],
)

#figure(
  image("fraud_by_hour.png", height: 6cm),
  caption: [Jumlah Transaksi dan Rasio Fraud per Jam],
)

Dari sisi waktu, jumlah transaksi mengikuti pola harian dengan aktivitas terendah pada dini hari. Menariknya, rasio penipuan justru meningkat pada jam-jam dengan volume transaksi rendah, terutama sekitar pukul 02.00 sampai 05.00. Pola ini menunjukkan bahwa `Time` menyimpan informasi yang relevan dan lebih berguna ketika diturunkan menjadi fitur jam.

#figure(
  image("corr_class.png", height: 9cm),
  caption: [Korelasi Setiap Fitur terhadap Kelas Target],
)

Beberapa komponen PCA memiliki korelasi yang cukup kuat terhadap kelas target. `V17`, `V14`, `V12`, dan `V10` berkorelasi negatif, sedangkan `V11`, `V4`, dan `V2` berkorelasi positif. Sebaliknya, `Amount` hanya memiliki korelasi yang sangat lemah, sehingga nilai transaksi saja tidak cukup untuk membedakan penipuan.

= Praproses Data

== Penskalaan Fitur

Fitur `Amount` distandarisasi menggunakan _z-score_ melalui `StandardScaler` agar skalanya sebanding dengan `V1`--`V28` yang telah dinormalisasi oleh PCA. Fitur `Time` diubah menjadi fitur `Hour` karena nilai detik mentah tidak bermakna langsung bagi model. Atribut asli `Time` dan `Amount` kemudian dihapus untuk menghindari redundansi.

Dataset tidak mengandung nilai hilang sehingga tidak diperlukan tahap imputasi.

== Pembagian Data Latih dan Uji

Dataset dibagi menjadi data latih dan data uji dengan perbandingan 80:20 menggunakan parameter `stratify=y` agar proporsi kelas tetap terjaga. Hasilnya, data latih berisi 227.845 baris dengan 394 transaksi penipuan (0,1729%), sedangkan data uji berisi 56.962 baris dengan 98 transaksi penipuan (0,1720%).

= Penanganan Class Imbalance

Tiga pendekatan penanganan _class imbalance_ diterapkan pada data latih:

#v(0.3em)

- *SMOTE* (_oversampling_). Sampel sintetis pada kelas minoritas dibangkitkan melalui interpolasi antar tetangga terdekat. Jumlah kelas fraud pada data latih meningkat dari 394 menjadi 227.451 sehingga menjadi seimbang, tanpa menduplikasi data secara langsung.
- *Undersampling*. Kelas mayoritas dikurangi dengan membuang sebagian transaksi normal hingga jumlahnya seimbang dengan kelas fraud. Data latih menyusut drastis dari 227.845 menjadi hanya 788 baris.
- *Cost-sensitive learning* (_class weighting_). Data tidak diubah, tetapi model diberi penalti lebih besar pada kesalahan klasifikasi kelas minoritas melalui parameter `class_weight`.

#v(0.5em)

#figure(
  image("resampling.png", height: 4.5cm),
  caption: [Distribusi Kelas pada Data Latih Sebelum dan Sesudah Resampling],
)

Resampling hanya diterapkan pada data latih. Data uji tetap menggunakan distribusi aslinya, yaitu dengan rasio penipuan 0,17%, agar evaluasi mencerminkan performa model pada kondisi nyata.

= Membangun Model Klasifikasi

Seluruh model yang dibandingkan merupakan _ensemble_ pada level model, yaitu model yang menggabungkan banyak model dasar di dalam proses pelatihannya. Dua keluarga utama digunakan sesuai ketentuan praktikum, kemudian ditambahkan tiga implementasi _gradient boosting_ modern sebagai pembanding:

#v(0.3em)

- *Random Forest*, yaitu metode _bagging_ yang membangun banyak pohon keputusan pada sampel _bootstrap_ dan menggabungkan hasilnya melalui _voting_. Konfigurasi yang digunakan adalah 200 pohon.
- *Gradient Boosting*, yaitu metode _boosting_ yang membangun pohon secara berurutan untuk memperbaiki kesalahan model sebelumnya. Implementasi yang digunakan adalah `HistGradientBoostingClassifier` dengan 300 iterasi dan _learning rate_ 0,1.
- *CatBoost, XGBoost, dan LightGBM*, yaitu tiga implementasi _gradient boosting_ modern dengan mekanisme penanganan _class imbalance_ bawaan.

#v(0.3em)

Random Forest dan Gradient Boosting masing-masing diuji pada empat konfigurasi, yaitu baseline, _class weighting_, SMOTE, dan undersampling. Ketiga _boosting_ modern ditambahkan pada konfigurasi terbaiknya masing-masing, sehingga terdapat sebelas model yang dibandingkan pada data uji yang sama.

Penanganan _imbalance_ pada ketiga _boosting_ modern dilakukan melalui pembobotan gradien pada fungsi objektif:

#v(0.3em)

- *XGBoost* menggunakan `scale_pos_weight` sebesar 577,29, yang mengalikan gradien kelas minoritas sehingga kesalahan pada kelas fraud dianggap lebih mahal.
- *LightGBM* menggunakan `class_weight="balanced"`, yang memberikan bobot berbanding terbalik dengan frekuensi kelas.
- *CatBoost* menggunakan `auto_class_weights="Balanced"`, yang menyeimbangkan bobot kelas secara otomatis selama pelatihan.

= Evaluasi Model

== Perbandingan Metrik

Evaluasi difokuskan pada kelas minoritas (fraud) menggunakan _precision_, _recall_, F1-score, dan AUC-ROC. Karena dataset sangat tidak seimbang, ditambahkan pula metrik AUC-PR (_average precision_) yang lebih sensitif terhadap kelas minoritas.

#table(
  columns: (2fr, 0.85fr, 0.85fr, 0.85fr, 0.85fr, 0.9fr, 0.8fr),
  inset: 5pt,
  stroke: 0.4pt + gray,
  align: center,

  [*Model*], [*Prec.*], [*Recall*], [*F1*], [*ROC*], [*AUC-PR*], [*Waktu*],

  [RF Baseline], [0,9405], [0,8061], [0,8681], [0,9619], [0,8584], [73,8 s],
  [RF class_weight], [0,9176], [0,7959], [0,8525], [0,9608], [0,8663], [29,3 s],
  [RF SMOTE], [0,8511], [0,8163], [0,8333], [0,9750], [0,8679], [133,9 s],
  [RF Undersampling], [0,0430], [0,9184], [0,0822], [0,9780], [0,6909], [0,5 s],
  [GB Baseline], [0,5250], [0,6429], [0,5780], [0,7258], [0,4721], [0,7 s],
  [GB class_weight], [0,3110], [0,8980], [0,4619], [0,9497], [0,7343], [0,9 s],
  [GB SMOTE], [0,6466], [0,8776], [0,7446], [0,9572], [0,8172], [4,3 s],
  [GB Undersampling], [0,0331], [0,9184], [0,0638], [0,9750], [0,6547], [0,6 s],
  [CatBoost], [0,7059], [0,8571], [0,7742], [0,9683], [0,8626], [7,2 s],
  [*XGBoost*], [0,8830], [0,8469], [0,8646], [0,9686], [*0,8847*], [6,3 s],
  [*LightGBM*], [*0,9195*], [0,8163], [*0,8649*], [0,9604], [0,8677], [5,5 s],
)

#v(0.5em)

#figure(
  image("metric_comparison.png", height: 8cm),
  caption: [Perbandingan F1-score dan AUC-PR Antar Model],
)


Pada keluarga _ensemble_ inti, Random Forest bersifat jauh lebih tahan terhadap ketidakseimbangan kelas dibanding Gradient Boosting. Bahkan pada konfigurasi baseline, Random Forest sudah mencapai _recall_ 0,8061 dan AUC-PR 0,8584, sedangkan Gradient Boosting baseline hanya mencapai _recall_ 0,6429 dengan AUC-PR 0,4721. Hal ini karena setiap pohon pada Random Forest dibangun dari sampel _bootstrap_ dengan pemilihan _split_ pada subset fitur acak, sehingga kelas minoritas tetap sering terwakili pada simpul-simpul pohon. Sebaliknya, pada Gradient Boosting setiap pohon baru berfokus memperbaiki sisa kesalahan yang didominasi kelas mayoritas.

Setelah penanganan _imbalance_, performa Gradient Boosting melonjak tajam: SMOTE menaikkan _recall_ menjadi 0,8776 dan AUC-PR menjadi 0,8172. Hal ini menunjukkan bahwa Gradient Boosting sangat bergantung pada penanganan _imbalance_, sedangkan Random Forest jauh lebih mandiri.

Ketiga _boosting_ modern tampil sangat kuat dan konsisten. XGBoost dengan `scale_pos_weight` menjadi model tunggal terbaik secara AUC-PR, yaitu 0,8847, disusul LightGBM (0,8677) dan CatBoost (0,8626). Ketiganya tidak memerlukan data sintetis karena penanganan _imbalance_ dilakukan melalui bobot gradien internal, sehingga waktu pelatihannya hanya 5--7 detik, jauh lebih singkat dibanding Random Forest dengan SMOTE yang memerlukan 134 detik.

Undersampling menghasilkan _recall_ tertinggi pada kedua keluarga _ensemble_ inti, yaitu 0,9184, tetapi _precision_-nya anjlok hingga 0,0330--0,0430. Hal ini wajar karena data latih menyusut drastis, sehingga model kehilangan banyak informasi kelas mayoritas dan menjadi terlalu agresif menandai fraud.

AUC-ROC seluruh model tampak tinggi (0,94--0,98) dan sulit dibedakan, sedangkan AUC-PR menyebar cukup lebar (0,47--0,88). Perbedaan ini menegaskan bahwa AUC-PR jauh lebih mampu membedakan kualitas model pada dataset yang sangat tidak seimbang.

== Confusion Matrix

#figure(
  image("confusion_matrices.png", height: 7cm),
  caption: [Confusion Matrix Random Forest dan Gradient Boosting pada Data Uji],
)

#figure(
  image("confusion_matrices_extra.png", height: 5cm),
  caption: [Confusion Matrix CatBoost, XGBoost, dan LightGBM pada Data Uji],
)

Confusion matrix memperjelas _trade-off_ antar pendekatan. Pada Random Forest baseline, terdapat 19 _false negative_ (penipuan yang lolos) dan hanya 5 _false positive_. Setelah SMOTE, _false negative_ turun menjadi 18 dengan _false positive_ 14.

Perbedaan yang jauh lebih mencolok terlihat pada Gradient Boosting. Baseline menghasilkan 35 _false negative_, lalu turun menjadi 10 dengan _class weighting_ dan 12 dengan SMOTE. Penurunan ini menunjukkan bahwa penanganan _imbalance_ pada Gradient Boosting tidak hanya menaikkan metrik secara agregat, tetapi benar-benar mengurangi jumlah penipuan yang lolos.

Undersampling pada kedua keluarga menekan _false negative_ paling rendah, yaitu 8, tetapi konsekuensinya _false positive_ meledak hingga 2.001 sampai 2.633 transaksi normal yang salah ditandai. Hal ini membuat pendekatan tersebut kurang praktis meskipun _recall_-nya tinggi.

Ketiga _boosting_ modern menghasilkan confusion matrix yang seimbang. LightGBM hanya melewatkan 18 penipuan dengan 7 _false positive_, sedangkan XGBoost dan CatBoost masing-masing melewatkan 15 dan 14 penipuan dengan _false positive_ 11 dan 35. Pada kasus deteksi penipuan, _false negative_ jauh lebih merugikan karena penipuan yang tidak terdeteksi menimbulkan kerugian finansial langsung, sedangkan _false positive_ hanya menambah beban verifikasi. Kombinasi yang dicapai ketiga model ini karena itu merupakan hasil yang paling diinginkan.

== Kurva ROC dan Precision-Recall

#figure(
  image("roc_pr_curves.png", height: 6.5cm),
  caption: [Kurva ROC dan Kurva Precision-Recall Model Terpilih],
)

Kurva ROC menunjukkan hampir seluruh model memiliki AUC-ROC di atas 0,94, sehingga kurva tampak berdekatan dan sulit dibedakan. Hal ini merupakan konsekuensi dari dominasi kelas mayoritas, di mana _true negative_ yang sangat banyak membuat _false positive rate_ tetap rendah sehingga kurva ROC cenderung bergerak mendekati sudut kiri atas.

Kurva Precision-Recall jauh lebih informatif untuk dataset tidak seimbang. Garis putus-putus merepresentasikan performa model acak, yaitu sebesar prevalensi kelas fraud (0,0017). Di sini pemisahan antar model menjadi jelas: XGBoost dan LightGBM berada paling atas, diikuti CatBoost dan Random Forest, sedangkan Gradient Boosting baseline berada jauh di bawah.

Bentuk kurva ketiga _boosting_ modern juga lebih stabil pada area _recall_ tinggi dibanding Random Forest. Hal ini menunjukkan bahwa selain lebih cepat dilatih, ketiganya menghasilkan peringkat probabilitas yang lebih tajam pada transaksi yang paling mencurigakan.

== Mengapa Accuracy Tidak Cukup

Untuk menunjukkan mengapa akurasi tidak memadai, dibandingkan performa model yang selalu memprediksi kelas normal dengan model XGBoost yang terbaik.

#table(
  columns: (2.6fr, 1fr, 1fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt + gray,

  [*Model*], [*Accuracy*], [*Recall (Fraud)*], [*F1 (Fraud)*],

  [Prediksi selalu Normal], [0,9983], [0,0000], [0,0000],
  [XGBoost], [0,9995], [0,8469], [0,8646],
)

#v(0.5em)

Model yang selalu memprediksi kelas normal memperoleh akurasi 0,9983. Angka ini terlihat sangat baik, tetapi model tersebut sama sekali tidak berguna karena tidak mampu mendeteksi satu pun transaksi penipuan (_recall_ = 0).

Akurasi mengukur proporsi keseluruhan prediksi yang benar, sehingga setiap transaksi normal yang diprediksi benar menyumbang nilai akurasi yang sama besarnya dengan transaksi penipuan. Ketika kelas mayoritas mendominasi 99,8% data, akurasi menjadi tidak sensitif terhadap kesalahan pada kelas minoritas. Padahal pada kasus deteksi penipuan, kelas minoritas justru merupakan kelas yang paling penting untuk dikenali.

Oleh karena itu, metrik yang lebih sesuai adalah _precision_, _recall_, F1-score, dan AUC-PR yang berfokus pada performa pada kelas minoritas. AUC-ROC tetap dapat dilaporkan, tetapi harus dibaca dengan hati-hati karena dapat memberikan kesan performa yang terlalu optimistis pada data yang sangat tidak seimbang.

= Analisis Fitur dan Threshold

== Feature Importance

#figure(
  image("feature_importance.png", height: 8cm),
  caption: [15 Fitur Paling Penting pada Random Forest dengan SMOTE],
)

Fitur yang paling berpengaruh pada model didominasi oleh komponen PCA tertentu. `V14` menjadi fitur terpenting dengan kontribusi mendekati 0,20, diikuti `V10`, `V4`, `V17`, dan `V12`. Urutan ini konsisten dengan hasil analisis korelasi sebelumnya, di mana `V14` dan `V17` berkorelasi negatif kuat terhadap kelas fraud, sedangkan `V4` dan `V11` berkorelasi positif. Fitur turunan `Hour` juga masuk ke dalam 15 fitur teratas, sedangkan `Amount_scaled` tidak muncul sehingga kontribusinya relatif kecil.

Temuan ini menegaskan bahwa pola penipuan lebih tercermin pada kombinasi pola tersembunyi dalam `V1`--`V28` dibandingkan pada nilai transaksi itu sendiri.

== Threshold Tuning

#figure(
  image("threshold_tuning.png", height: 7cm),
  caption: [Precision, Recall, dan F1 terhadap Threshold pada Model Terbaik],
)

Ambang batas keputusan secara langsung mempengaruhi keseimbangan antara _precision_ dan _recall_. Pada model terbaik, yaitu XGBoost dengan `scale_pos_weight`, F1 meningkat dari 0,8646 pada threshold default 0,5 menjadi 0,8743 pada threshold optimal 0,9376. Threshold yang lebih tinggi membuat model hanya menandai transaksi yang probabilitasnya sangat tinggi sebagai penipuan, sehingga _precision_ naik.

Sebaliknya, menurunkan threshold akan menandai lebih banyak transaksi sebagai penipuan sehingga _recall_ meningkat, tetapi _precision_ menurun. Pemilihan threshold optimal bergantung pada preferensi risiko: apabila biaya kehilangan penipuan jauh lebih besar daripada biaya pemeriksaan transaksi normal, threshold yang menghasilkan _recall_ tinggi lebih disarankan.

= Kesimpulan

Berdasarkan hasil pemodelan, terdapat beberapa temuan utama.

Dataset _Credit Card Fraud Detection_ memiliki distribusi kelas yang sangat tidak seimbang, dengan hanya 0,1727% transaksi berupa penipuan, atau rasio sekitar 578:1.

Ketahanan model _ensemble_ terhadap _imbalance_ berbeda antar algoritma. Random Forest tetap kompetitif bahkan pada konfigurasi baseline, dengan _recall_ 0,8061 dan AUC-PR 0,8584, sedangkan Gradient Boosting baseline jauh lebih lemah dengan _recall_ 0,6429 dan AUC-PR 0,4721. Hal ini menunjukkan bahwa pemilihan algoritma _ensemble_ sama pentingnya dengan teknik resampling yang digunakan.

Penerapan SMOTE, _undersampling_, dan _class weighting_ meningkatkan kemampuan Gradient Boosting secara drastis. SMOTE menaikkan _recall_ menjadi 0,8776 dan AUC-PR menjadi 0,8172, sedangkan _class weighting_ menghasilkan _recall_ 0,8980. Sebaliknya, _undersampling_ menghasilkan _recall_ tertinggi (0,9184) tetapi dengan _precision_ yang sangat rendah (0,0430) karena membuang terlalu banyak data kelas mayoritas.

Tiga implementasi _boosting_ modern tampil paling kuat dan konsisten. XGBoost dengan `scale_pos_weight` menjadi model tunggal terbaik secara AUC-PR (0,8847), sedangkan LightGBM unggul pada F1 (0,8649) dan CatBoost mencapai _recall_ 0,8571. Ketiganya menangani _imbalance_ melalui pembobotan gradien internal sehingga tidak memerlukan data sintetis, dan menghasilkan _false negative_ rendah tanpa ledakan _false positive_.

Dari sisi evaluasi, AUC-PR lebih representatif dibanding AUC-ROC untuk dataset yang sangat tidak seimbang, karena AUC-ROC seluruh model tampak tinggi dan sulit dibedakan. Akurasi juga tidak dapat dijadikan metrik utama karena didominasi kelas mayoritas. Terakhir, penyesuaian threshold keputusan dapat meningkatkan F1 model terbaik dari 0,8646 menjadi 0,8743, sehingga pemilihan threshold perlu disesuaikan dengan preferensi risiko.

#pagebreak()

= Referensi

#set enum(numbering: "[1]")

+ Breiman, L. (2001). _Random Forests_. Machine Learning, 45(1), 5--32.
+ Chen, T., & Guestrin, C. (2016). _XGBoost: A Scalable Tree Boosting System_. Proceedings of the 22nd ACM SIGKDD.
+ Chawla, N. V., Bowyer, K. W., Hall, L. O., & Kegelmeyer, W. P. (2002). _SMOTE: Synthetic Minority Over-sampling Technique_. Journal of Artificial Intelligence Research, 16, 321--357.
+ He, H., & Garcia, E. A. (2009). _Learning from Imbalanced Data_. IEEE Transactions on Knowledge and Data Engineering, 21(9), 1263--1284.
+ Ke, G., et al. (2017). _LightGBM: A Highly Efficient Gradient Boosting Decision Tree_. NeurIPS.
+ Pedregosa, F., et al. (2011). _Scikit-learn: Machine Learning in Python_. Journal of Machine Learning Research, 12, 2825--2830.
+ Prokhorenkova, L., et al. (2018). _CatBoost: Unbiased Boosting with Categorical Features_. NeurIPS.
