import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

// Kelas ini berisi fungsi-fungsi bantuan yang bisa dipakai di mana saja.
class ImagePickerUtil {

  // Fungsi statis untuk memilih dan mengompres gambar.
  // Bisa dipanggil langsung: ImagePickerUtil.pickAndCompressImage()
  static Future<Uint8List?> pickAndCompressImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 1080,
    int quality = 85,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return null;
    }

    final bytes = await pickedFile.readAsBytes();

    // Proses kompresi
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes; // Kembalikan bytes asli jika gagal decode

    img.Image resizedImage = img.copyResize(image, width: maxWidth);

    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: quality));
  }
}