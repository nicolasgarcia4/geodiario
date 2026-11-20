String _doisDigitos(int n) => n.toString().padLeft(2, '0');

/// Ex.: 20/11/2026
String formatarData(DateTime d) =>
    '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year}';

/// Ex.: 14:05
String formatarHora(DateTime d) =>
    '${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}';

/// Ex.: 20/11/2026 às 14:05
String formatarDataHora(DateTime d) => '${formatarData(d)} às ${formatarHora(d)}';

/// Ex.: -19.932100, -43.938600
String formatarCoordenadas(double lat, double lng) =>
    '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
