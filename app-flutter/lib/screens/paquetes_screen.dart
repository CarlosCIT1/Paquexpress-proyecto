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
  List pendientes = [];
  List entregados = [];
  bool loading = true;
  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    setState(() => loading = true);
    final data = await ApiService.getPaquetes();
    setState(() {
      // Separamos la data en dos listas según el estado
      pendientes = data.where((p) => p['estado'] != 'entregado').toList();
      entregados = data.where((p) => p['estado'] == 'entregado').toList();
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

  // Widget para crear los encabezados de sección
  Widget seccionTitulo(String texto, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color),
          const SizedBox(width: 10),
          Text(
            texto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Paquetes"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: cargar, icon: const Icon(Icons.refresh))
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // --- SECCIÓN PENDIENTES ---
                if (pendientes.isNotEmpty) ...[
                  seccionTitulo("PAQUETES PENDIENTES", Colors.orange),
                  ...pendientes.map((p) => Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2, color: Colors.orange),
                          title: Text(p['descripcion'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Agente: ${p['agente']}\n${p['direccion']}"),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.map_outlined, color: Colors.indigo),
                            onPressed: () => abrirMapa(p['direccion']),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EntregaScreen(
                                  paqueteId: p['id'],
                                  descripcion: p['descripcion'],
                                  destinatario: p['agente'],
                                  direccion: p['direccion'],
                                ),
                              ),
                            ).then((_) => cargar());
                          },
                        ),
                      )),
                ],

                // --- SECCIÓN ENTREGADOS ---
                if (entregados.isNotEmpty) ...[
                  seccionTitulo("PAQUETES ENTREGADOS", Colors.green),
                  ...entregados.map((p) => Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 0,
                        color: Colors.grey[100], // Fondo gris para los terminados
                        child: ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text(
                            p['descripcion'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough, // Texto tachado
                            ),
                          ),
                          subtitle: Text("Agente: ${p['agente']}\n${p['direccion']}"),
                          isThreeLine: true,
                          trailing: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                          onTap: null, // Bloquea el clic
                        ),
                      )),
                ],

                // Si no hay nada en ninguna lista
                if (pendientes.isEmpty && entregados.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text("No hay paquetes asignados"),
                    ),
                  ),
              ],
            ),
    );
  }
}
