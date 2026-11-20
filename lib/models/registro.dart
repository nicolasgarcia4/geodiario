/// Um registro do diário: a foto e as informações associadas a ela.
///
/// A foto em si fica no armazenamento local do aparelho; aqui guardamos
/// apenas o caminho do arquivo ([caminhoFoto]).
class Registro {
  final int? id;
  final String titulo;
  final String descricao;
  final String caminhoFoto;
  final DateTime dataHora;
  final double latitude;
  final double longitude;

  Registro({
    this.id,
    required this.titulo,
    this.descricao = '',
    required this.caminhoFoto,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
  });

  /// Converte uma linha da tabela `registros` em um objeto [Registro].
  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: (map['descricao'] as String?) ?? '',
      caminhoFoto: map['caminho_foto'] as String,
      dataHora: DateTime.parse(map['data_hora'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  /// Converte o objeto em um Map com os nomes das colunas da tabela.
  /// O `id` só é enviado quando existe: na inclusão o SQLite gera o valor.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'caminho_foto': caminhoFoto,
      'data_hora': dataHora.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Registro copyWith({int? id}) {
    return Registro(
      id: id ?? this.id,
      titulo: titulo,
      descricao: descricao,
      caminhoFoto: caminhoFoto,
      dataHora: dataHora,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
