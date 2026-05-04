import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/explore/data/models/channel_model.dart';
import '../../features/explore/data/models/stream_model.dart';
import '../../features/recordings/data/models/recording_model.dart';

final demoModeProvider = StateProvider<bool>((_) => false);

class DemoData {
  static final UserModel user = UserModel(
    userId: 'demo-user-001',
    email: 'demo@blume.app',
    fullName: 'Usuario Demo',
    username: 'demo_user',
    role: 'STUDENT',
    provider: 'LOCAL',
  );

  static final List<ChannelModel> channels = [
    ChannelModel(
      id: 'ch-001',
      name: 'Ingeniería de Software',
      description: 'Principios, patrones y buenas prácticas para construir software de calidad.',
      instructorName: 'Carlos Mendoza Ríos',
      instructorId: 'prof-001',
    ),
    ChannelModel(
      id: 'ch-002',
      name: 'Algoritmos y Estructuras de Datos',
      description: 'Análisis de complejidad, sorting, grafos y programación dinámica.',
      instructorName: 'María Torres Vega',
      instructorId: 'prof-002',
    ),
    ChannelModel(
      id: 'ch-003',
      name: 'Bases de Datos Avanzadas',
      description: 'Modelado relacional, NoSQL, transacciones y optimización de queries.',
      instructorName: 'Diego Herrera Castillo',
      instructorId: 'prof-003',
    ),
    ChannelModel(
      id: 'ch-004',
      name: 'Inteligencia Artificial',
      description: 'Machine learning, redes neuronales y procesamiento de lenguaje natural.',
      instructorName: 'Lucía Gómez Restrepo',
      instructorId: 'prof-004',
    ),
  ];

  static final List<StreamModel> liveStreams = [
    StreamModel(
      id: 'stream-001',
      channelId: 'ch-001',
      title: 'Clean Architecture en proyectos reales',
      description: 'Implementando hexagonal architecture con Spring Boot y casos de uso bien definidos.',
      instructorName: 'Carlos Mendoza Ríos',
      status: 'LIVE',
      visibility: 'PUBLIC',
      accessMode: 'OPEN',
      streamKey: 'devkey',
    ),
    StreamModel(
      id: 'stream-002',
      channelId: 'ch-002',
      title: 'Árboles AVL y B-Trees',
      description: 'Implementación, balanceo y casos de uso de árboles de búsqueda balanceados.',
      instructorName: 'María Torres Vega',
      status: 'LIVE',
      visibility: 'PUBLIC',
      accessMode: 'OPEN',
      streamKey: 'devkey2',
    ),
  ];

  static final List<StreamModel> allStreams = [
    ...liveStreams,
    StreamModel(
      id: 'stream-003',
      channelId: 'ch-003',
      title: 'Introducción a PostgreSQL',
      description: 'Fundamentos de PostgreSQL, tipos de datos y consultas avanzadas.',
      instructorName: 'Diego Herrera Castillo',
      status: 'SCHEDULED',
      visibility: 'PUBLIC',
      accessMode: 'OPEN',
      scheduledAt: '2026-05-06T10:00:00Z',
    ),
    StreamModel(
      id: 'stream-004',
      channelId: 'ch-001',
      title: 'SOLID Principles con ejemplos',
      description: 'Los 5 principios SOLID aplicados a código real con refactorizaciones en vivo.',
      instructorName: 'Carlos Mendoza Ríos',
      status: 'ENDED',
      visibility: 'PUBLIC',
      accessMode: 'OPEN',
    ),
    StreamModel(
      id: 'stream-005',
      channelId: 'ch-004',
      title: 'Redes Neuronales desde cero',
      description: 'Implementando backpropagation en Python sin librerías externas.',
      instructorName: 'Lucía Gómez Restrepo',
      status: 'ENDED',
      visibility: 'PUBLIC',
      accessMode: 'OPEN',
    ),
    StreamModel(
      id: 'stream-006',
      channelId: 'ch-002',
      title: 'Grafos: BFS, DFS y Dijkstra',
      description: 'Recorridos en grafos y algoritmos de caminos mínimos con implementación en vivo.',
      instructorName: 'María Torres Vega',
      status: 'ENDED',
      visibility: 'PUBLIC',
      accessMode: 'OPEN',
    ),
  ];

  static final List<RecordingModel> recordings = [
    RecordingModel(
      id: 'rec-001',
      streamKey: 'devkey-old-1',
      title: 'SOLID Principles con ejemplos',
      description: 'Los 5 principios SOLID aplicados a código real.',
      instructorName: 'Carlos Mendoza Ríos',
      durationSec: 3720,
      objectKey: 'recordings/rec-001.mp4',
      playbackUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      status: 'ready',
      createdAt: '2026-05-01T14:30:00Z',
    ),
    RecordingModel(
      id: 'rec-002',
      streamKey: 'devkey-old-2',
      title: 'Redes Neuronales desde cero',
      description: 'Implementando backpropagation en Python sin librerías.',
      instructorName: 'Lucía Gómez Restrepo',
      durationSec: 5400,
      objectKey: 'recordings/rec-002.mp4',
      playbackUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      status: 'ready',
      createdAt: '2026-04-28T09:15:00Z',
    ),
    RecordingModel(
      id: 'rec-003',
      streamKey: 'devkey-old-3',
      title: 'Grafos: BFS, DFS y Dijkstra',
      description: 'Algoritmos de recorrido y caminos mínimos.',
      instructorName: 'María Torres Vega',
      durationSec: 4200,
      objectKey: 'recordings/rec-003.mp4',
      playbackUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      status: 'ready',
      createdAt: '2026-04-25T16:00:00Z',
    ),
  ];

  static List<StreamModel> streamsForChannel(String channelId) =>
      allStreams.where((s) => s.channelId == channelId).toList();
}
