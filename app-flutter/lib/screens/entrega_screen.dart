import 'dart:io';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EntregaScreen extends StatefulWidget {
  final int paqueteId;
  final String descripcion;
  final String destinatario;
  final String direccion;

  const EntregaScreen({
    super.key,
    required this.paqueteId,
    required this.descripcion,
    required this.destinatario,
    required this.direccion,
  });

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  File? imagen;
  Position? posicion;
  bool enviando = false;
  final String baseUrl = "http://127.0.0.1:8000";
  
  final MapController _mapController = MapController();

  Future<void> tomarFoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null && mounted) setState(() => imagen = File(picked.path));
  }

  Future<void> obtenerGPS() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position pos = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() => posicion = pos);
    _mapController.move(LatLng(pos.latitude, pos.longitude), 16.0);
  }

  void irADestino() {
    final LatLng destino = _direccionALatLng(widget.direccion);
    _mapController.move(destino, 16.0);
  }

  LatLng _direccionALatLng(String direccion) {
    if (direccion.toLowerCase().contains("central")) {
      return const LatLng(20.593, -100.392);
    }
    return const LatLng(20.592, -100.393);
  }

  Future<void> enviar() async {
    if (imagen == null || posicion == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falta foto o GPS")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final token = prefs.getString("token"); // 🔥 agregado

    if (userId == null || token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de sesión")),
      );
      return;
    }

    if (!mounted) return;
    setState(() => enviando = true);

    try {
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/entrega"));

      // 🔥 HEADER CON TOKEN (LO IMPORTANTE)
      request.headers['Authorization'] = 'Bearer $token';

      request.fields["paquete_id"] = widget.paqueteId.toString();
      request.fields["usuario_id"] = userId.toString();
      request.fields["latitud"] = posicion!.latitude.toString();
      request.fields["longitud"] = posicion!.longitude.toString();

      request.files.add(
        await http.MultipartFile.fromPath("foto", imagen!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al enviar")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng destino = _direccionALatLng(widget.direccion);
    final LatLng ubicacion = posicion != null
        ? LatLng(posicion!.latitude, posicion!.longitude)
        : destino;

    return Scaffold(
      appBar: AppBar(title: Text("Finalizar Entrega #${widget.paqueteId}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 60),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Agente: ${widget.destinatario}", style: const TextStyle(color: Colors.indigo)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: imagen == null
                  ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(imagen!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: ubicacion, initialZoom: 16),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.uteq.paquexpress',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: ubicacion,
                        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                      ),
                      Marker(
                        width: 40,
                        height: 40,
                        point: destino,
                        child: const Icon(Icons.flag, size: 40, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: tomarFoto,
                    icon: const Icon(Icons.camera),
                    label: const Text("Foto"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: enviando ? null : enviar,
                    icon: const Icon(Icons.send),
                    label: Text(enviando ? "..." : "Finalizar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: obtenerGPS,
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text("Mi ubicación"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: irADestino,
                    icon: const Icon(Icons.flag),
                    label: const Text("Ver Destino"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
