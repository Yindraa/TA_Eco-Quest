-- ═══════════════════════════════════════════════
-- TABEL QUIZ
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS quiz_questions (
  question_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question      TEXT NOT NULL,
  option_a      TEXT NOT NULL,
  option_b      TEXT NOT NULL,
  option_c      TEXT NOT NULL,
  option_d      TEXT NOT NULL,
  correct_answer CHAR(1) NOT NULL CHECK (correct_answer IN ('A','B','C','D')),
  explanation   TEXT NOT NULL,
  eco_fact      TEXT NOT NULL,
  category      TEXT DEFAULT 'general',
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS daily_quiz_attempts (
  attempt_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quiz_date        DATE NOT NULL DEFAULT CURRENT_DATE,
  score            INTEGER NOT NULL DEFAULT 0,
  total_questions  INTEGER NOT NULL DEFAULT 5,
  exp_earned       INTEGER NOT NULL DEFAULT 0,
  completed_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, quiz_date)
);

-- RLS
ALTER TABLE quiz_questions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quiz_questions_read"    ON quiz_questions      FOR SELECT TO authenticated USING (true);
CREATE POLICY "quiz_attempts_select"   ON daily_quiz_attempts FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "quiz_attempts_insert"   ON daily_quiz_attempts FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- ═══════════════════════════════════════════════
-- RPC: SELESAIKAN QUIZ + BERI EXP
-- ═══════════════════════════════════════════════

CREATE OR REPLACE FUNCTION complete_daily_quiz(
  p_user_id UUID,
  p_score   INTEGER,
  p_total   INTEGER
)
RETURNS JSON
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_exp      INTEGER;
  v_already  BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM daily_quiz_attempts
    WHERE user_id = p_user_id AND quiz_date = CURRENT_DATE
  ) INTO v_already;

  IF v_already THEN
    RETURN json_build_object('success', false, 'exp_earned', 0, 'message', 'already_completed');
  END IF;

  v_exp := CASE
    WHEN p_score = p_total          THEN 50
    WHEN p_score >= CEIL(p_total * 0.6) THEN 20
    ELSE 10
  END;

  INSERT INTO daily_quiz_attempts(user_id, quiz_date, score, total_questions, exp_earned)
  VALUES (p_user_id, CURRENT_DATE, p_score, p_total, v_exp);

  UPDATE profiles SET total_points = total_points + v_exp WHERE id = p_user_id;

  RETURN json_build_object('success', true, 'exp_earned', v_exp);
END;
$$;

-- ═══════════════════════════════════════════════
-- SEED: 25 SOAL QUIZ
-- ═══════════════════════════════════════════════

INSERT INTO quiz_questions (question, option_a, option_b, option_c, option_d, correct_answer, explanation, eco_fact, category) VALUES

('Termasuk jenis sampah apakah botol plastik bekas minuman?',
 'Organik', 'Anorganik', 'B3 (Berbahaya Beracun)', 'Residu',
 'B', 'Botol plastik termasuk sampah anorganik yang dapat didaur ulang. Pisahkan dari sampah organik agar bisa diproses kembali menjadi produk baru.',
 'Indonesia menghasilkan sekitar 6,8 juta ton sampah plastik per tahun, menjadikannya salah satu penyumbang polusi plastik terbesar di dunia.',
 'pilah_sampah'),

('Berapa lama waktu yang dibutuhkan botol plastik untuk terurai di alam?',
 '10–20 tahun', '100–200 tahun', '450–1.000 tahun', '50–100 tahun',
 'C', 'Plastik sangat sulit terurai secara alami. Botol plastik membutuhkan 450–1.000 tahun untuk terurai sempurna — itulah mengapa mengurangi penggunaan plastik sangat penting.',
 'Setiap menit, setara dengan 1 truk sampah plastik dibuang ke laut di seluruh dunia.',
 'lingkungan'),

('Manakah yang termasuk sampah organik?',
 'Kaleng bekas', 'Koran bekas', 'Kulit pisang', 'Baterai bekas',
 'C', 'Sampah organik berasal dari makhluk hidup. Kulit pisang dapat dijadikan kompos yang bermanfaat untuk menyuburkan tanah.',
 'Sampah organik yang diolah menjadi kompos dapat mengurangi volume sampah hingga 70% dan menyuburkan tanah.',
 'pilah_sampah'),

('Apa kepanjangan 3R dalam pengelolaan sampah?',
 'Remove, Replace, Recycle', 'Reduce, Reuse, Recycle', 'Reduce, Replace, Renew', 'Reduce, Reuse, Renew',
 'B', '3R adalah prinsip dasar pengelolaan sampah: Reduce (kurangi), Reuse (pakai ulang), Recycle (daur ulang). Urutan ini penting — mencegah lebih baik daripada mengolah.',
 'Mendaur ulang 1 ton kertas dapat menyelamatkan 17 pohon dan menghemat 26.000 liter air.',
 'daur_ulang'),

('Termasuk jenis sampah apakah baterai bekas?',
 'Organik', 'Anorganik biasa', 'B3 (Berbahaya Beracun)', 'Sampah residu',
 'C', 'Baterai mengandung logam berat seperti merkuri dan timbal yang berbahaya. Jangan dibuang sembarangan — serahkan ke tempat pengumpulan B3 khusus.',
 'Satu baterai AA bekas dapat mencemari 1.000 liter air tanah dan mengancam ekosistem selama puluhan tahun.',
 'b3'),

('Apa yang disebut "pulau sampah" terbesar di dunia?',
 'Great Barrier Reef', 'Great Pacific Garbage Patch', 'Pacific Trash Island', 'Ocean Waste Zone',
 'B', 'Great Pacific Garbage Patch adalah gumpalan sampah (sebagian besar plastik) di Samudra Pasifik yang luasnya sekitar dua kali lipat Texas, Amerika Serikat.',
 'Sekitar 80% sampah di lautan berasal dari daratan, dan plastik menyumbang lebih dari 80% dari total sampah laut.',
 'lingkungan'),

('Berapa energi yang dihemat saat mendaur ulang aluminium dibanding memproduksi baru?',
 '25%', '50%', '75%', '95%',
 'D', 'Mendaur ulang aluminium menghemat 95% energi dibanding membuatnya dari bahan mentah. Kaleng aluminium adalah salah satu material paling efisien untuk didaur ulang.',
 'Kaleng aluminium yang didaur ulang bisa kembali ke rak toko hanya dalam 60 hari.',
 'daur_ulang'),

('Warna tempat sampah yang umum digunakan untuk sampah anorganik/daur ulang di Indonesia adalah?',
 'Hijau', 'Merah', 'Kuning', 'Biru',
 'C', 'Di Indonesia, tempat sampah kuning umumnya digunakan untuk sampah anorganik yang dapat didaur ulang seperti plastik, kertas, dan logam.',
 'Pemilahan sampah dari sumber (rumah tangga) dapat meningkatkan efisiensi daur ulang hingga 3 kali lipat.',
 'pilah_sampah'),

('Gas rumah kaca utama yang dihasilkan dari pembusukan sampah organik di TPA adalah?',
 'Karbon dioksida (CO₂)', 'Metana (CH₄)', 'Nitrogen dioksida (NO₂)', 'Ozon (O₃)',
 'B', 'Sampah organik yang membusuk di TPA menghasilkan gas metana yang 25 kali lebih kuat dari CO₂ dalam menangkap panas. Komposting adalah cara terbaik mencegah emisi ini.',
 'Sektor persampahan bertanggung jawab atas sekitar 5% emisi gas rumah kaca global.',
 'lingkungan'),

('Apa yang dimaksud dengan "upcycling"?',
 'Mendaur ulang dengan menurunkan kualitas material', 'Mengupload foto sampah ke media sosial', 'Mengubah sampah menjadi produk bernilai lebih tinggi', 'Membuang sampah ke tempat yang lebih jauh',
 'C', 'Upcycling adalah proses kreatif mengubah barang bekas menjadi sesuatu yang bernilai lebih tinggi. Contoh: botol kaca menjadi vas bunga, ban bekas menjadi kursi.',
 'Industri upcycling global bernilai lebih dari $50 miliar dan terus berkembang seiring meningkatnya kesadaran lingkungan.',
 'daur_ulang'),

('Manakah yang TIDAK termasuk sampah B3 rumah tangga?',
 'Cat bekas', 'Obat kadaluarsa', 'Kardus bekas', 'Lampu neon bekas',
 'C', 'Kardus bekas adalah sampah anorganik biasa yang dapat didaur ulang. Cat, obat kadaluarsa, dan lampu neon mengandung bahan berbahaya dan harus dibuang secara khusus.',
 'Satu lampu neon mengandung merkuri yang cukup untuk mencemari 30.000 liter air jika dibuang sembarangan.',
 'b3'),

('Fenomena apa yang terjadi ketika sampah plastik terurai menjadi partikel sangat kecil (<5mm)?',
 'Nanoplastik', 'Mikroplastik', 'Poliplastik', 'Fotoplastik',
 'B', 'Mikroplastik adalah partikel plastik berukuran kurang dari 5mm. Partikel ini telah ditemukan di air minum, seafood, bahkan dalam darah manusia.',
 'Rata-rata manusia mengonsumsi sekitar 5 gram mikroplastik per minggu — setara berat satu kartu kredit plastik.',
 'lingkungan'),

('Berapa lama waktu yang dibutuhkan styrofoam untuk terurai?',
 '10 tahun', '100 tahun', '500 tahun', 'Hampir tidak terurai secara alami',
 'D', 'Styrofoam (polystyrene) sangat sulit terurai dan bisa bertahan lebih dari 500 tahun. Pecahannya menjadi mikroplastik berbahaya bagi ekosistem laut.',
 'Styrofoam membentuk 30% dari volume TPA di seluruh dunia, padahal 98% komposisinya adalah udara.',
 'lingkungan'),

('Apa yang harus dilakukan sebelum membuang botol plastik ke tempat sampah daur ulang?',
 'Menghancurkannya terlebih dahulu', 'Membersihkan dan mengeringkannya', 'Merendamnya dalam air', 'Membakarnya sebentar',
 'B', 'Botol plastik yang bersih lebih mudah didaur ulang dan tidak mencemari material lain. Langkah sederhana ini meningkatkan kualitas hasil daur ulang secara signifikan.',
 'Kontaminasi sampah daur ulang dengan sisa makanan adalah penyebab utama kegagalan proses daur ulang.',
 'daur_ulang'),

('Program apa yang mengajak masyarakat membawa sampah pilah untuk ditukarkan dengan uang?',
 'Program 3M', 'Bank Sampah', 'TPA Modern', 'Program Zero Waste',
 'B', 'Bank sampah adalah fasilitas pengelolaan sampah berbasis masyarakat di mana warga dapat menabung sampah pilah dan mendapatkan imbalan berupa uang atau sembako.',
 'Indonesia memiliki lebih dari 10.000 unit bank sampah yang melibatkan jutaan nasabah.',
 'daur_ulang'),

('Apakah kertas yang terkena minyak atau makanan masih bisa didaur ulang?',
 'Ya, selama masih berbentuk kertas', 'Tidak, kontaminasi minyak merusak proses daur ulang', 'Ya, cukup dikeringkan saja', 'Semua kertas tidak bisa didaur ulang',
 'B', 'Kertas yang terkontaminasi minyak (seperti kardus pizza berminyak) tidak dapat didaur ulang karena minyak mengganggu proses pengolahan serat kertas.',
 'Mendaur ulang 1 ton kertas menghemat 17 pohon dan 26.000 liter air.',
 'daur_ulang'),

('Manakah yang termasuk sampah residu (tidak bisa didaur ulang, bukan B3)?',
 'Botol plastik bersih', 'Kertas koran', 'Pembalut bekas', 'Kaleng susu',
 'C', 'Sampah residu adalah sampah yang tidak dapat didaur ulang dan tidak berbahaya, seperti pembalut, tisu bekas, dan sedotan kotor. Harus diminimalkan karena langsung ke TPA.',
 'Rata-rata satu orang menghasilkan sampah residu 0,5 kg/hari yang bisa dikurangi 50% dengan pilihan produk lebih bijak.',
 'pilah_sampah'),

('Bagaimana cara yang benar membuang obat-obatan kadaluarsa?',
 'Dibuang ke toilet/saluran air', 'Dicampur dengan sampah biasa', 'Dikubur di tanah', 'Diserahkan ke apotek atau fasilitas kesehatan',
 'D', 'Obat kadaluarsa mengandung bahan kimia yang dapat mencemari air tanah. Apotek dan puskesmas menyediakan fasilitas pengumpulan obat kadaluarsa untuk pembuangan yang aman.',
 'Lebih dari 40% sumber mata air di Eropa terdeteksi mengandung residu obat-obatan yang mempengaruhi kesehatan ekosistem.',
 'b3'),

('Apa yang dimaksud dengan "zero waste" dalam pengelolaan sampah?',
 'Tidak menghasilkan sampah sama sekali', 'Membuang semua sampah ke TPA', 'Pendekatan meminimalkan sampah ke TPA mendekati nol', 'Mendaur ulang 50% sampah',
 'C', 'Zero waste adalah filosofi yang bertujuan meminimalkan sampah ke TPA melalui desain produk lebih baik, pemilahan, komposting, dan daur ulang.',
 'Kota San Francisco berhasil mengalihkan 80% sampahnya dari TPA melalui program zero waste komprehensif.',
 'lingkungan'),

('Manakah pernyataan yang BENAR tentang mendaur ulang kertas?',
 'Kertas hanya bisa didaur ulang 1 kali', 'Mendaur ulang kertas lebih boros energi dari memproduksi baru', 'Kertas dapat didaur ulang 5–7 kali sebelum seratnya terlalu pendek', 'Kertas tidak bisa didaur ulang sama sekali',
 'C', 'Setiap kali didaur ulang, serat kertas menjadi lebih pendek. Setelah 5–7 kali, serat terlalu pendek untuk dipakai lagi dan harus dijadikan kompos.',
 'Mendaur ulang kertas menggunakan 70% lebih sedikit energi dan menghasilkan 73% lebih sedikit polusi udara.',
 'daur_ulang'),

('Apa dampak langsung membuang sampah di pantai terhadap ekosistem?',
 'Meningkatkan oksigen di laut', 'Memberi makan ikan', 'Merusak terumbu karang dan mengancam biota laut', 'Tidak ada dampak signifikan',
 'C', 'Sampah di laut, terutama plastik, merusak terumbu karang, mencekik penyu dan ikan, serta terurai menjadi mikroplastik yang masuk ke rantai makanan laut.',
 'Sekitar 1 juta burung laut dan 100.000 mamalia laut mati setiap tahun akibat menelan atau terjerat plastik.',
 'lingkungan'),

('Sisa makanan yang sudah busuk paling tepat diolah menjadi?',
 'Pupuk kompos', 'Langsung dibuang ke sungai', 'Dibakar agar tidak bau', 'Ditimbun bersama sampah plastik',
 'A', 'Sisa makanan dapat dijadikan kompos yang menyuburkan tanah. Komposting di rumah adalah cara paling mudah mengolah sampah organik.',
 '1 kg sisa makanan yang dikomposkan menghasilkan sekitar 0,25 kg kompos berkualitas tinggi yang dapat menggantikan pupuk kimia.',
 'pilah_sampah'),

('Taman Nasional mana dekat Manado yang terancam oleh polusi sampah plastik?',
 'Taman Nasional Komodo', 'Taman Nasional Bunaken', 'Taman Nasional Lorentz', 'Taman Nasional Bromo',
 'B', 'Taman Nasional Bunaken di Sulawesi Utara adalah salah satu ekosistem terumbu karang terkaya di dunia. Sampah plastik dari daratan mengancam kelestariannya.',
 'Bunaken memiliki lebih dari 70% spesies ikan yang ada di seluruh perairan Indonesia, menjadikannya aset alam tak ternilai.',
 'lokal'),

('Apa nama penghargaan lingkungan dari pemerintah Indonesia untuk kota yang berhasil menjaga kebersihan?',
 'Program Eco-City', 'Penghargaan Green Belt', 'Adipura', 'Clean Ocean Award',
 'C', 'Adipura adalah penghargaan lingkungan hidup dari pemerintah Indonesia untuk kota/kabupaten yang berhasil menjaga kebersihan dan kelestarian lingkungan hidupnya.',
 'Kota penerima Adipura rata-rata memiliki tingkat daur ulang 3 kali lebih tinggi dan biaya pengelolaan sampah 30% lebih rendah.',
 'lokal'),

('Apa hubungan antara membuang sampah di sungai dengan kualitas air laut?',
 'Tidak ada hubungannya', 'Sungai membersihkan sampah secara alami', 'Sampah dari sungai mengalir ke laut dan mencemari ekosistem pesisir', 'Air laut membersihkan sampah dari sungai',
 'C', 'Lebih dari 80% sampah laut berasal dari sungai. Sampah yang dibuang di sungai akan terbawa arus ke laut, mencemari pesisir dan mengancam biota laut.',
 'Sungai Tondano yang mengalir melalui Manado bermuara ke Teluk Manado, membawa sampah langsung ke kawasan Bunaken jika tidak dikelola dengan baik.',
 'lokal');
