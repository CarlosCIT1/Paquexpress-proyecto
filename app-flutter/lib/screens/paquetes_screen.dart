import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'entrega_screen.dart';

class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({super.key});
  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  List paquetes = [];
  bool loading = true;
  final String baseUrl = "http://127.0.0.1:8000"; // URL de tu API

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await ApiService.getPaquetes();
    setState(() {
      paquetes = data;
      loading = false;
    });
  }

  Future<void> abrirMapa(String direccion) async {
    final encodedQuery = Uri.encodeComponent(direccion);
    final url = "https://www.google.com/maps/search/?api=1&query=$encodedQuery";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir el mapa")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Entregas"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: cargar, icon: const Icon(Icons.refresh))
        ],
      ),
      body: loading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: paquetes.length,
              itemBuilder: (context, index) {
                final p = paquetes[index];
                final bool isEntregado = p['estado'] == 'entregado';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(p['descripcion'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Agente: ${p['agente']}\n${p['direccion']}"),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.map_outlined, color: Colors.indigo),
                      onPressed: () => abrirMapa(p['direccion']),
                    ),
                    onTap: isEntregado ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntregaScreen(
                            paqueteId: p['id'],
                            descripcion: p['descripcion'],
                            destinatario: p['agente'],
                            direccion: p['direccion'], // ⚠️ Agregado el parámetro requerido
                          ),
                        ),
                      ).then((_) => cargar());
                    },
                  ),
                );
              },
            ),
    );
  }
}