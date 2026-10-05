import 'package:flutter/material.dart';
import '../modelos/opcion_votacion.dart';
import '../modelos/votacion.dart';
import '../modelos/resultado_opcion.dart';
import '../logica/resultado_voto.dart';
import '../logica/servicio_votacion.dart';
import 'confetti_animado.dart';

class VotacionScreen extends StatefulWidget {
  const VotacionScreen({super.key});

  @override
  State<VotacionScreen> createState() => _VotacionScreenState();
}

class _VotacionScreenState extends State<VotacionScreen> {
  late final Votacion _votacion;
  late final ServicioVotacion _servicio;
  final TextEditingController _idUsuarioController = TextEditingController();
  int _contadorVecinos = 1;

  @override
  void initState() {
    super.initState();
    _votacion = Votacion(
      pregunta: '¿Qué obra prioritaria debe realizar el municipio este año?',
      opciones: [
        OpcionVotacion(id: 'jardin', texto: 'Rehabilitación del Jardín Principal'),
        OpcionVotacion(id: 'biblioteca', texto: 'Nueva Biblioteca Digital'),
        OpcionVotacion(id: 'alumbrado', texto: 'Alumbrado en el Barrio de Analco'),
        OpcionVotacion(id: 'parque', texto: 'Parque Infantil en la Colonia Guanajuato'),
      ],
      fechaCierre: DateTime.now().add(const Duration(days: 7)),
    );
    _servicio = ServicioVotacion(_votacion);
    _idUsuarioController.text = 'vecino-$_contadorVecinos';
  }

  @override
  void dispose() {
    _idUsuarioController.dispose();
    super.dispose();
  }

  bool get _usuarioActualYaVoto {
    final id = _idUsuarioController.text.trim();
    return id.isNotEmpty && _votacion.votantes.contains(id);
  }

  void _generarNuevoId() {
    setState(() {
      _contadorVecinos++;
      _idUsuarioController.text = 'vecino-$_contadorVecinos';
    });
  }

  void _votar(String idOpcion) {
    final id = _idUsuarioController.text.trim();
    if (id.isEmpty) {
      _mensaje('Por favor ingresa un ID de votante para emitir tu voto.');
      return;
    }

    final resultado = _servicio.registrarVoto(idUsuario: id, idOpcion: idOpcion);
    if (resultado == ResultadoVoto.exitoso) {
      setState(() {});
      _mensaje('¡Voto registrado con éxito por $id!');
    } else if (resultado == ResultadoVoto.usuarioYaVoto) {
      _mensaje('Ya registramos tu voto en este plebiscito ($id).');
    } else if (resultado == ResultadoVoto.votacionCerrada) {
      _mensaje('Esta votación ya cerró.');
    } else if (resultado == ResultadoVoto.opcionInvalida) {
      _mensaje('La opción seleccionada no es válida.');
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _verGanador() {
    final ganadores = _servicio.determinarGanador();
    final bool hayGanadorSinEmpate = ganadores.length == 1;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ganador',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Stack(
          children: [
            if (hayGanadorSinEmpate)
              const Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiAnimado(),
                ),
              ),
            ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
              child: FadeTransition(
                opacity: anim1,
                child: AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hayGanadorSinEmpate)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.celebration, color: Colors.amber, size: 28),
                        ),
                      const Flexible(
                        child: Text(
                          'Resultado del plebiscito',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    ganadores.length == 1
                        ? 'La opción ganadora es:\n\n${ganadores.first.texto}'
                        : 'Hay un empate entre:\n\n${ganadores.map((g) => g.texto).join('\n')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      key: const Key('btn_cerrar_dialogo'),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _servicio.obtenerResultados();
    final totalVotantes = _votacion.votantes.length;
    final yaVoto = _usuarioActualYaVoto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plebiscito Vecinal - Dolores Hidalgo'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de Identificación de Usuario (ID)
          Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 20),
            color: Colors.indigo.shade50.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.indigo.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: Colors.indigo),
                      const SizedBox(width: 8),
                      const Text(
                        'Identificador de Votante (ID)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          yaVoto ? 'Ya votó' : 'Listo para votar',
                          style: TextStyle(
                            fontSize: 12,
                            color: yaVoto ? Colors.orange.shade900 : Colors.green.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: yaVoto ? Colors.orange.shade100 : Colors.green.shade100,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('input_id_usuario'),
                          controller: _idUsuarioController,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa o genera tu ID de usuario',
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            prefixIcon: Icon(Icons.person, size: 20),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        key: const Key('btn_nuevo_id'),
                        onPressed: _generarNuevoId,
                        icon: const Icon(Icons.autorenew, size: 18),
                        label: const Text('Nuevo ID'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total de vecinos que han votado: $totalVotantes',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),

          // Pregunta del plebiscito
          Text(
            _votacion.pregunta,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Lista de opciones con barras animadas
          ...resultados.map((r) => _BarraOpcion(
                resultado: r,
                puedeVotar: !yaVoto,
                onVotar: () => _votar(r.opcion.id),
              )),
          const SizedBox(height: 20),

          // Botón ver ganador con confeti
          ElevatedButton.icon(
            key: const Key('btn_ver_ganador'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _verGanador,
            icon: const Icon(Icons.emoji_events),
            label: const Text(
              'Ver resultado del plebiscito',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraOpcion extends StatelessWidget {
  final ResultadoOpcion resultado;
  final bool puedeVotar;
  final VoidCallback onVotar;

  const _BarraOpcion({
    required this.resultado,
    required this.puedeVotar,
    required this.onVotar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  resultado.opcion.texto,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: resultado.porcentaje),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, valor, _) => Text(
                  '${valor.toStringAsFixed(0)}% (${resultado.opcion.votos})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 18,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: resultado.porcentaje / 100),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, valor, _) => Container(
                      height: 18,
                      width: constraints.maxWidth * valor,
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          if (puedeVotar)
            OutlinedButton(
              key: Key('btn_votar_${resultado.opcion.id}'),
              onPressed: onVotar,
              child: const Text('Votar por esta opción'),
            ),
        ],
      ),
    );
  }
}
