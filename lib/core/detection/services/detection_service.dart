import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/detection_result.dart';

class DetectionService {
  static const int inputSize = 800; // ini sesuai sama di trainignya
  static const double confThreshold = 0.45; // batas minimal yakin AI
  static const double iouThreshold = 0.45;
  static const double minBoxRatio =  0.002; // kotak < 1% gambar dibuang

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset('assets/models/best.tflite');
    print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
    print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
  }

  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw Exception(
        'Model belum dimuat. Panggil loadModel() terlebih dahulu.',
      );
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) throw Exception('Gagal mendekode gambar.');
    final original = img.bakeOrientation(decoded); // luruskan orientasi foto

    // dataset siang hari, jadi foto gelap ditolak
    if (_isTooDark(original)) {
      throw Exception(
        'Foto terlalu gelap. Gunakan aplikasi di siang hari atau tempat dengan cahaya cukup.',
      );
    }
    if (!_looksLikeRoad(original)) return []; // bukan jalan, skip

    // ini itu buat jaga aspek rasio, tambah padding abu"
    final scale = math.min(
      inputSize / original.width,
      inputSize / original.height,
    );
    final newWidth = (original.width * scale).round();
    final newHeight = (original.height * scale).round();
    final padX = ((inputSize - newWidth) / 2).round();
    final padY = ((inputSize - newHeight) / 2).round();

    final resized = img.copyResize(
      original,
      width: newWidth,
      height: newHeight,
    );
    final canvas = img.Image(width: inputSize, height: inputSize);
    img.fill(canvas, color: img.ColorRgb8(114, 114, 114));
    img.compositeImage(canvas, resized, dstX: padX, dstY: padY);

    // urutan channel ikut shape model
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final channelsLast = inputShape.length == 4 && inputShape[3] == 3;

    // ini buat normalisasi ke [0,1]
    final Object input;
    if (channelsLast) {
      input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(inputSize, (x) {
            final p = canvas.getPixel(x, y);
            return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
          }),
        ),
      );
    } else {
      input = List.generate(
        1,
        (_) => List.generate(
          3,
          (c) => List.generate(
            inputSize,
            (y) => List.generate(inputSize, (x) {
              final p = canvas.getPixel(x, y);
              if (c == 0) return p.r / 255.0;
              if (c == 1) return p.g / 255.0;
              return p.b / 255.0;
            }),
          ),
        ),
      );
    }

    // output YOLO11: bentuk [1, 4+jumlah_kelas, jumlah_kotak]
    final numClasses = kYoloClassNames.length;
    final numBoxes = _interpreter!.getOutputTensor(0).shape[2];

    final output = List.generate(
      1,
      (_) => List.generate(4 + numClasses, (_) => List.filled(numBoxes, 0.0)),
    );

    _interpreter!.run(input, output);
    final raw = output[0];

    // kalau koordinat 0..1, kali 800 biar jadi piksel
    double maxCoord = 0;
    for (int i = 0; i < numBoxes; i++) {
      maxCoord = math.max(maxCoord, math.max(raw[2][i], raw[3][i]));
    }
    final coordScale = maxCoord <= 2.0 ? inputSize.toDouble() : 1.0;

    final imgArea = original.width * original.height.toDouble();
    final candidates = <DetectionResult>[];

    for (int i = 0; i < numBoxes; i++) {
      // Cari skor kelas tertinggi untuk box ke-i
      double bestScore = 0;
      int bestClass = -1;
      for (int c = 0; c < numClasses; c++) {
        final score = raw[4 + c][i];
        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }
      if (bestScore < confThreshold || bestClass == -1) continue;

      // box dalam format cx, cy, w, h
      final cx = raw[0][i] * coordScale;
      final cy = raw[1][i] * coordScale;
      final w = raw[2][i] * coordScale;
      final h = raw[3][i] * coordScale;

      // buat konversi ke x1, y1, x2, y2
      // buat balikin padding Letterbox lalu scale ke ukuran gambar asli
      double x1 = (cx - w / 2 - padX) / scale;
      double y1 = (cy - h / 2 - padY) / scale;
      double x2 = (cx + w / 2 - padX) / scale;
      double y2 = (cy + h / 2 - padY) / scale;

      // jaga biar ga keluar gambar
      x1 = x1.clamp(0.0, original.width.toDouble()).toDouble();
      y1 = y1.clamp(0.0, original.height.toDouble()).toDouble();
      x2 = x2.clamp(0.0, original.width.toDouble()).toDouble();
      y2 = y2.clamp(0.0, original.height.toDouble()).toDouble();

      final boxArea = (x2 - x1) * (y2 - y1);
      if (boxArea / imgArea < minBoxRatio) continue;

      final className = kYoloClassNames[bestClass];
      candidates.add(
        DetectionResult(
          classId: bestClass,
          className: className,
          displayName: kClassDisplayNames[className] ?? className,
          confidence: bestScore,
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
        ),
      );
    }

    return _nonMaxSuppression(candidates);
  }

  // rata" kecerahan di bawah 60 dianggap gelap
  bool _isTooDark(img.Image image) {
    double lumSum = 0;
    int total = 0;
    for (int y = 0; y < image.height; y += 16) {
      for (int x = 0; x < image.width; x += 16) {
        final p = image.getPixel(x, y);
        lumSum += 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
        total++;
      }
    }
    final avg = total == 0 ? 0 : lumSum / total;
    print('Rata-rata kecerahan: $avg');
    return avg < 60;
  }

  // aspal itu abu-abu dan ga terlalu terang (keramik biasanya lebih terang)
  bool _looksLikeRoad(img.Image image) {
    int grayish = 0, total = 0;
    double lumSum = 0;

    for (int y = (image.height * 0.3).toInt(); y < image.height; y += 16) {
      for (int x = 0; x < image.width; x += 16) {
        final p = image.getPixel(x, y);
        final r = p.r.toDouble(), g = p.g.toDouble(), b = p.b.toDouble();
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
        if (sat < 0.25) grayish++; // warnanya pucat = abu-abu
        lumSum += 0.299 * r + 0.587 * g + 0.114 * b;
        total++;
      }
    }
    if (total == 0) return false;

    final grayRatio = grayish / total;
    final avgLum = lumSum / total;
    print('road check -> grayRatio=$grayRatio avgLum=$avgLum');

    return grayRatio > 0.4 && avgLum > 50 && avgLum < 170;
  }

  // gambar kotak merah + label di foto
  Uint8List drawDetections(
    Uint8List imageBytes,
    List<DetectionResult> detections,
  ) {
    final decoded = img.decodeImage(imageBytes)!;
    final image = img.bakeOrientation(decoded);
    final thickness = (image.width / 200).round().clamp(2, 10);

    for (final d in detections) {
      final x1 = d.x1.round();
      final y1 = d.y1.round();
      final x2 = d.x2.round();
      final y2 = d.y2.round();

      img.drawRect(
        image,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        color: img.ColorRgb8(255, 0, 0),
        thickness: thickness,
      );

      final label =
          '${d.displayName} ${(d.confidence * 100).toStringAsFixed(0)}%';
      final labelY = math.max(0, y1 - 30);
      final labelX2 = math.min(image.width - 1, x1 + label.length * 14 + 8);

      // latar merah buat tulisan label
      img.fillRect(
        image,
        x1: x1,
        y1: labelY,
        x2: labelX2,
        y2: labelY + 30,
        color: img.ColorRgb8(255, 0, 0),
      );
      img.drawString(
        image,
        label,
        font: img.arial24,
        x: x1 + 4,
        y: labelY + 2,
        color: img.ColorRgb8(255, 255, 255),
      );
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  // hapus kotak dobel yang numpuk
  List<DetectionResult> _nonMaxSuppression(List<DetectionResult> boxes) {
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));
    final selected = <DetectionResult>[];
    while (boxes.isNotEmpty) {
      final current = boxes.removeAt(0);
      selected.add(current);
      boxes.removeWhere((box) {
        if (box.classId != current.classId) return false;
        return _iou(current, box) > iouThreshold;
      });
    }
    return selected;
  }

  // hitung seberapa numpuk 2 kotak
  double _iou(DetectionResult a, DetectionResult b) {
    final interX1 = math.max(a.x1, b.x1);
    final interY1 = math.max(a.y1, b.y1);
    final interX2 = math.min(a.x2, b.x2);
    final interY2 = math.min(a.y2, b.y2);
    final interArea =
        math.max(0.0, interX2 - interX1) * math.max(0.0, interY2 - interY1);
    final areaA = (a.x2 - a.x1) * (a.y2 - a.y1);
    final areaB = (b.x2 - b.x1) * (b.y2 - b.y1);
    final unionArea = areaA + areaB - interArea;
    if (unionArea <= 0) return 0;
    return interArea / unionArea;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
