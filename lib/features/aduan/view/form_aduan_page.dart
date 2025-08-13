import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jabar_caang/features/aduan/viewmodel/aduan_viewmodel.dart';
import 'package:provider/provider.dart';

class FormAduanPage extends StatefulWidget {
  const FormAduanPage({super.key});

  @override
  State<FormAduanPage> createState() => _FormAduanPageState();
}

class _FormAduanPageState extends State<FormAduanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hpController = TextEditingController();
  final _desaController = TextEditingController();
  final _keteranganController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _desaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AduanViewModel(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Buat Aduan Listrik'),
          centerTitle: true,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.blue.shade600,
        ),
        body: Consumer<AduanViewModel>(
          builder: (context, vm, child) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _namaController,
                      label: 'Nama Lengkap',
                      icon: Icons.person,
                      validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    _buildTextField(
                      controller: _hpController,
                      label: 'Nomor HP',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                    ),
                    _buildTextField(
                      controller: _desaController,
                      label: 'Desa',
                      icon: Icons.location_city,
                      validator: (value) => value!.isEmpty ? 'Desa tidak boleh kosong' : null,
                    ),
                    _buildTextField(
                      controller: _keteranganController,
                      label: 'Keterangan Aduan',
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) => value!.isEmpty ? 'Keterangan tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 20),

                    // Ambil Lokasi
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => vm.getCurrentLocation(),
                      icon: const Icon(Icons.location_on, color: Colors.blue),
                      label: const Text("Ambil Lokasi GPS Saat Ini"),
                    ),
                    if (vm.currentPosition != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Lokasi: ${vm.currentPosition!.latitude.toStringAsFixed(5)}, ${vm.currentPosition!.longitude.toStringAsFixed(5)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Upload Foto
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => vm.pickImage(),
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      label: const Text("Upload Foto (Opsional)"),
                    ),

                    const SizedBox(height: 10),

                    if (vm.imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          vm.imageBytes!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Tombol Kirim
                    vm.isLoading
                        ? Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(vm.loadingMessage),
                      ],
                    )
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (vm.currentPosition == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Harap ambil lokasi GPS terlebih dahulu.'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }

                          bool success = await vm.submitAduan(
                            nama: _namaController.text,
                            hp: _hpController.text,
                            desa: _desaController.text,
                            keterangan: _keteranganController.text,
                          );

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Aduan berhasil dikirim!'),
                              backgroundColor: Colors.green,
                            ));
                            context.pop();
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Gagal mengirim aduan. Coba lagi.'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                      child: const Text(
                        "KIRIM ADUAN",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
