import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Servicio profesional para exportar resultados a Excel
/// Genera reportes con formato ejecutivo, gr?ficos de datos y an?lisis completo
class ExportService {
  
  // ============================================================
  // COLORES CORPORATIVOS PROFESIONALES
  // ============================================================
  static final _primaryColor = ExcelColor.fromHexString('#1E3A5F');      // Azul oscuro profesional
  static final _secondaryColor = ExcelColor.fromHexString('#C5A065');    // Dorado elegante
  static final _accentGreen = ExcelColor.fromHexString('#2E7D32');       // Verde éxito
  static final _accentRed = ExcelColor.fromHexString('#C62828');         // Rojo alerta
  static final _accentOrange = ExcelColor.fromHexString('#EF6C00');      // Naranja advertencia
  static final _lightGray = ExcelColor.fromHexString('#F5F5F5');         // Gris claro fondo
  static final _mediumGray = ExcelColor.fromHexString('#E0E0E0');        // Gris medio bordes
  static final _darkGray = ExcelColor.fromHexString('#424242');          // Gris oscuro texto
  static final _white = ExcelColor.fromHexString('#FFFFFF');             // Blanco
  
  // ============================================================
  // ESTILOS PREDEFINIDOS
  // ============================================================
  static CellStyle get _titleStyle => CellStyle(
    bold: true,
    fontSize: 18,
    fontColorHex: _white,
    backgroundColorHex: _primaryColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  
  static CellStyle get _subtitleStyle => CellStyle(
    bold: true,
    fontSize: 12,
    fontColorHex: _primaryColor,
    horizontalAlign: HorizontalAlign.Left,
  );
  
  static CellStyle get _headerStyle => CellStyle(
    bold: true,
    fontSize: 11,
    fontColorHex: _white,
    backgroundColorHex: _primaryColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  
  static CellStyle get _subHeaderStyle => CellStyle(
    bold: true,
    fontSize: 10,
    fontColorHex: _darkGray,
    backgroundColorHex: _mediumGray,
    horizontalAlign: HorizontalAlign.Center,
  );
  
  static CellStyle get _dataStyleCenter => CellStyle(
    fontSize: 10,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  
  static CellStyle get _dataStyleLeft => CellStyle(
    fontSize: 10,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
  );
  
  static CellStyle _getPercentageStyle(double percentage) {
    ExcelColor bgColor;
    ExcelColor fontColor = _darkGray;
    
    if (percentage >= 90) {
      bgColor = ExcelColor.fromHexString('#E8F5E9'); // Verde muy claro
      fontColor = _accentGreen;
    } else if (percentage >= 80) {
      bgColor = ExcelColor.fromHexString('#F1F8E9'); // Lima muy claro
    } else if (percentage >= 70) {
      bgColor = ExcelColor.fromHexString('#FFF8E1'); // ?mbar muy claro
    } else if (percentage >= 60) {
      bgColor = ExcelColor.fromHexString('#FFF3E0'); // Naranja muy claro
      fontColor = _accentOrange;
    } else {
      bgColor = ExcelColor.fromHexString('#FFEBEE'); // Rojo muy claro
      fontColor = _accentRed;
    }
    
    return CellStyle(
      fontSize: 10,
      bold: true,
      fontColorHex: fontColor,
      backgroundColorHex: bgColor,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
  }
  
  /// Exporta los resultados de los estudiantes a un archivo Excel profesional
  static Future<bool> exportStudentResults({
    required List<Map<String, dynamic>> students,
    required String sessionTitle,
    required BuildContext context,
  }) async {
    try {
      debugPrint('Iniciando exportaci?n Excel con ${students.length} estudiantes');
      
      final excel = Excel.createExcel();
      
      // 1. PORTADA Y RESUMEN EJECUTIVO
      final coverSheet = excel['?? Resumen Ejecutivo'];
      _createCoverSheet(coverSheet, students, sessionTitle);
      
      // 2. RANKING DE ESTUDIANTES
      final rankingSheet = excel['?? Ranking'];
      _createRankingSheet(rankingSheet, students);
      
      // 3. DETALLE INDIVIDUAL
      final detailSheet = excel['?? Detalle Individual'];
      _createDetailSheet(detailSheet, students);
      
      // 4. AN?LISIS ESTAD?STICO
      final statsSheet = excel['?? An?lisis Estad?stico'];
      _createStatsSheet(statsSheet, students);
      
      // 5. HISTORIAL DE RESPUESTAS
      final historySheet = excel['?? Historial Respuestas'];
      _createHistorySheet(historySheet, students);
      
      // 6. HOJA DE MEDALLAS Y LOGROS
      final medalsSheet = excel['?? Logros y Medallas'];
      _createMedalsSheet(medalsSheet, students);
      
      // Eliminar la hoja por defecto
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }
      
      // Generar el archivo
      final bytes = excel.save();
      if (bytes == null) {
        debugPrint('Error: bytes es null al guardar Excel');
        throw Exception('Error al generar el archivo Excel');
      }
      
      debugPrint('Excel generado: ${bytes.length} bytes');
      
      // Nombre del archivo profesional con fecha
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(now);
      final safeTitle = sessionTitle.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
      final fileName = 'Reporte_${safeTitle}_$dateStr';
      
      debugPrint('Guardando archivo: $fileName.xlsx');
      
      // Guardar el archivo
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
      
      debugPrint('Archivo guardado exitosamente');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error exportando a Excel: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
  
  // ============================================================
  // HOJA 1: PORTADA Y RESUMEN EJECUTIVO
  // ============================================================
  static void _createCoverSheet(
    Sheet sheet, 
    List<Map<String, dynamic>> students,
    String sessionTitle,
  ) {
    // Calcular métricas
    final percentages = students.map((s) => (s['percentage'] ?? 0.0) as double).toList();
    final avg = percentages.isEmpty ? 0.0 : percentages.reduce((a, b) => a + b) / percentages.length;
    final max = percentages.isEmpty ? 0.0 : percentages.reduce((a, b) => a > b ? a : b);
    final min = percentages.isEmpty ? 0.0 : percentages.reduce((a, b) => a < b ? a : b);
    final aprobados = percentages.where((p) => p >= 60).length;
    final tasaAprobacion = students.isEmpty ? 0.0 : (aprobados / students.length) * 100;
    
    // T?TULO PRINCIPAL
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F3'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('REPORTE DE EVALUACI?N');
    titleCell.cellStyle = _titleStyle;
    
    // SUBT?TULO - NOMBRE DEL CURSO
    sheet.merge(CellIndex.indexByString('A4'), CellIndex.indexByString('F4'));
    final subtitleCell = sheet.cell(CellIndex.indexByString('A4'));
    subtitleCell.value = TextCellValue(sessionTitle.toUpperCase());
    subtitleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: _secondaryColor,
      horizontalAlign: HorizontalAlign.Center,
    );
    
    // INFORMACI?N DEL REPORTE
    final now = DateTime.now();
    final dateFormatted = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es').format(now);
    final timeFormatted = DateFormat('HH:mm').format(now);
    
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Fecha de generaci?n:');
    sheet.cell(CellIndex.indexByString('A6')).cellStyle = _subtitleStyle;
    sheet.cell(CellIndex.indexByString('B6')).value = TextCellValue(dateFormatted);
    
    sheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Hora:');
    sheet.cell(CellIndex.indexByString('A7')).cellStyle = _subtitleStyle;
    sheet.cell(CellIndex.indexByString('B7')).value = TextCellValue(timeFormatted);
    
    // M?TRICAS PRINCIPALES - DASHBOARD
    sheet.merge(CellIndex.indexByString('A9'), CellIndex.indexByString('F9'));
    final metricsTitle = sheet.cell(CellIndex.indexByString('A9'));
    metricsTitle.value = TextCellValue('M?TRICAS PRINCIPALES');
    metricsTitle.cellStyle = _headerStyle;
    
    // Fila de métricas
    final metrics = [
      ['Total Estudiantes', students.length.toString()],
      ['Promedio General', '${avg.toStringAsFixed(1)}%'],
      ['Puntaje M?ximo', '${max.toStringAsFixed(1)}%'],
      ['Puntaje M?nimo', '${min.toStringAsFixed(1)}%'],
      ['Tasa Aprobaci?n', '${tasaAprobacion.toStringAsFixed(1)}%'],
      ['Aprobados/Total', '$aprobados/${students.length}'],
    ];
    
    for (var i = 0; i < metrics.length; i++) {
      // Etiqueta
      final labelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 10));
      labelCell.value = TextCellValue(metrics[i][0]);
      labelCell.cellStyle = _subHeaderStyle;
      
      // Valor
      final valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 11));
      valueCell.value = TextCellValue(metrics[i][1]);
      valueCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: _primaryColor,
        horizontalAlign: HorizontalAlign.Center,
      );
    }
    
    // DISTRIBUCI?N POR NIVELES
    sheet.merge(CellIndex.indexByString('A14'), CellIndex.indexByString('F14'));
    final distTitle = sheet.cell(CellIndex.indexByString('A14'));
    distTitle.value = TextCellValue('DISTRIBUCI?N POR NIVEL DE DESEMPE?O');
    distTitle.cellStyle = _headerStyle;
    
    // Calcular distribuci?n
    int excelentes = 0, muyBuenos = 0, buenos = 0, regulares = 0, bajos = 0;
    for (final p in percentages) {
      if (p >= 90) excelentes++;
      else if (p >= 80) muyBuenos++;
      else if (p >= 70) buenos++;
      else if (p >= 60) regulares++;
      else bajos++;
    }
    
    final distribution = [
      ['? Excelente', '90-100%', excelentes, ExcelColor.fromHexString('#1B5E20')],
      ['?? Muy Bueno', '80-89%', muyBuenos, ExcelColor.fromHexString('#2E7D32')],
      ['?? Bueno', '70-79%', buenos, ExcelColor.fromHexString('#558B2F')],
      ['?? Regular', '60-69%', regulares, ExcelColor.fromHexString('#F57C00')],
      ['?? En Progreso', '0-59%', bajos, ExcelColor.fromHexString('#C62828')],
    ];
    
    // Encabezados de distribuci?n
    final distHeaders = ['Nivel', 'Rango', 'Cantidad', 'Porcentaje', 'Barra Visual'];
    for (var i = 0; i < distHeaders.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 15));
      cell.value = TextCellValue(distHeaders[i]);
      cell.cellStyle = _subHeaderStyle;
    }
    
    // Datos de distribuci?n
    for (var i = 0; i < distribution.length; i++) {
      final rowIdx = 16 + i;
      final count = distribution[i][2] as int;
      final pct = students.isEmpty ? 0.0 : (count / students.length) * 100;
      final barLength = (pct / 10).round();
      final bar = '?' * barLength + '?' * (10 - barLength);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
          .value = TextCellValue(distribution[i][0] as String);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
          .value = TextCellValue(distribution[i][1] as String);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx))
          .value = IntCellValue(count);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx))
          .value = TextCellValue('${pct.toStringAsFixed(1)}%');
      
      final barCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx));
      barCell.value = TextCellValue(bar);
      barCell.cellStyle = CellStyle(
        fontColorHex: distribution[i][3] as ExcelColor,
        fontSize: 10,
      );
    }
    
    // NOTA AL PIE
    sheet.merge(CellIndex.indexByString('A23'), CellIndex.indexByString('F23'));
    final footerCell = sheet.cell(CellIndex.indexByString('A23'));
    footerCell.value = TextCellValue('Generado autom?ticamente por Sistema de Evaluaci?n - Literatura Sapiencial');
    footerCell.cellStyle = CellStyle(
      italic: true,
      fontSize: 9,
      fontColorHex: _darkGray,
      horizontalAlign: HorizontalAlign.Center,
    );
    
    // Ajustar anchos de columna
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 18);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 20);
    sheet.setColumnWidth(5, 15);
  }
  
  // ============================================================
  // HOJA 2: RANKING DE ESTUDIANTES
  // ============================================================
  static void _createRankingSheet(Sheet sheet, List<Map<String, dynamic>> students) {
    // T?tulo
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('G2'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('?? RANKING DE ESTUDIANTES');
    titleCell.cellStyle = _titleStyle;
    
    // Ordenar por porcentaje descendente
    final sortedStudents = List<Map<String, dynamic>>.from(students);
    sortedStudents.sort((a, b) => 
        ((b['percentage'] ?? 0.0) as double).compareTo((a['percentage'] ?? 0.0) as double));
    
    // Encabezados
    final headers = ['Posici?n', 'Estudiante', 'Puntaje', 'Nivel', 'Medalla', 'Respuestas', 'Estado'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }
    
    // Datos del ranking
    for (var i = 0; i < sortedStudents.length; i++) {
      final student = sortedStudents[i];
      final rowIdx = 5 + i;
      final percentage = (student['percentage'] ?? 0.0) as double;
      final responses = student['responses'] as Map<String, dynamic>? ?? {};
      final correctCount = responses.values.where((r) => r['isCorrect'] == true).length;
      
      // Medalla seg?n posici?n
      String medal = '';
      if (i == 0) medal = '??';
      else if (i == 1) medal = '??';
      else if (i == 2) medal = '??';
      else if (i < 10) medal = '??';
      
      // Posici?n
      final posCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx));
      posCell.value = TextCellValue('#${i + 1}');
      posCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
        fontColorHex: i < 3 ? _secondaryColor : _darkGray,
      );
      
      // Nombre
      final nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx));
      nameCell.value = TextCellValue(student['name'] ?? 'Sin nombre');
      nameCell.cellStyle = _dataStyleLeft;
      
      // Puntaje con formato condicional
      final scoreCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx));
      scoreCell.value = TextCellValue('${percentage.toStringAsFixed(1)}%');
      scoreCell.cellStyle = _getPercentageStyle(percentage);
      
      // Nivel
      final levelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx));
      levelCell.value = TextCellValue(_getClassificationText(percentage));
      levelCell.cellStyle = _dataStyleCenter;
      
      // Medalla
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx))
          .value = TextCellValue(medal);
      
      // Respuestas
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
          .value = TextCellValue('$correctCount/${responses.length}');
      
      // Estado
      final statusCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIdx));
      statusCell.value = TextCellValue(_formatStatus(student['status']));
      statusCell.cellStyle = _dataStyleCenter;
      
      // Fondo alternado para filas
      if (i % 2 == 1) {
        for (var col = 0; col < 7; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIdx));
          cell.cellStyle = (cell.cellStyle ?? CellStyle()).copyWith(
            backgroundColorHexVal: _lightGray,
          );
        }
      }
    }
    
    // Ajustar anchos
    sheet.setColumnWidth(0, 10);  // Posici?n
    sheet.setColumnWidth(1, 28);  // Estudiante
    sheet.setColumnWidth(2, 12);  // Puntaje
    sheet.setColumnWidth(3, 15);  // Nivel
    sheet.setColumnWidth(4, 10);  // Medalla
    sheet.setColumnWidth(5, 12);  // Respuestas
    sheet.setColumnWidth(6, 15);  // Estado
  }
  
  // ============================================================
  // HOJA 3: DETALLE INDIVIDUAL
  // ============================================================
  static void _createDetailSheet(Sheet sheet, List<Map<String, dynamic>> students) {
    // T?tulo
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H2'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('?? DETALLE INDIVIDUAL DE ESTUDIANTES');
    titleCell.cellStyle = _titleStyle;
    
    // Encabezados
    final headers = [
      'N°', 'Nombre Completo', 'Puntaje Final', 'Correctas', 'Incorrectas', 
      'Tasa Acierto', 'Tiempo Prom.', '?ltima Actividad'
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }
    
    // Datos
    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final rowIdx = 5 + i;
      final percentage = (student['percentage'] ?? 0.0) as double;
      final responses = student['responses'] as Map<String, dynamic>? ?? {};
      final correctCount = responses.values.where((r) => r['isCorrect'] == true).length;
      final incorrectCount = responses.length - correctCount;
      final hitRate = responses.isEmpty ? 0.0 : (correctCount / responses.length) * 100;
      
      // N°
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
          .value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
          .cellStyle = _dataStyleCenter;
      
      // Nombre
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
          .value = TextCellValue(student['name'] ?? 'Sin nombre');
      
      // Puntaje
      final scoreCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx));
      scoreCell.value = TextCellValue('${percentage.toStringAsFixed(1)}%');
      scoreCell.cellStyle = _getPercentageStyle(percentage);
      
      // Correctas (verde)
      final correctCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx));
      correctCell.value = IntCellValue(correctCount);
      correctCell.cellStyle = CellStyle(
        fontColorHex: _accentGreen,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
      
      // Incorrectas (rojo)
      final incorrectCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx));
      incorrectCell.value = IntCellValue(incorrectCount);
      incorrectCell.cellStyle = CellStyle(
        fontColorHex: incorrectCount > 0 ? _accentRed : _darkGray,
        horizontalAlign: HorizontalAlign.Center,
      );
      
      // Tasa de acierto
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
          .value = TextCellValue('${hitRate.toStringAsFixed(1)}%');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
          .cellStyle = _dataStyleCenter;
      
      // Tiempo promedio
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIdx))
          .value = TextCellValue(_calculateAvgTime(responses));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIdx))
          .cellStyle = _dataStyleCenter;
      
      // ?ltima actividad
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIdx))
          .value = TextCellValue(_formatDateTime(student['lastActivity']));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIdx))
          .cellStyle = _dataStyleCenter;
    }
    
    // Ajustar anchos
    sheet.setColumnWidth(0, 5);
    sheet.setColumnWidth(1, 28);
    sheet.setColumnWidth(2, 14);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 12);
    sheet.setColumnWidth(5, 14);
    sheet.setColumnWidth(6, 14);
    sheet.setColumnWidth(7, 20);
  }
  
  // ============================================================
  // HOJA 4: AN?LISIS ESTAD?STICO
  // ============================================================
  static void _createStatsSheet(Sheet sheet, List<Map<String, dynamic>> students) {
    // T?tulo
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D2'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('?? AN?LISIS ESTAD?STICO COMPLETO');
    titleCell.cellStyle = _titleStyle;
    
    // Calcular estad?sticas avanzadas
    final percentages = students.map((s) => (s['percentage'] ?? 0.0) as double).toList();
    
    if (percentages.isEmpty) {
      sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('No hay datos para analizar');
      return;
    }
    
    // Estad?sticas b?sicas
    final avg = percentages.reduce((a, b) => a + b) / percentages.length;
    final max = percentages.reduce((a, b) => a > b ? a : b);
    final min = percentages.reduce((a, b) => a < b ? a : b);
    
    // Mediana
    final sortedPct = List<double>.from(percentages)..sort();
    final median = sortedPct.length % 2 == 0
        ? (sortedPct[sortedPct.length ~/ 2 - 1] + sortedPct[sortedPct.length ~/ 2]) / 2
        : sortedPct[sortedPct.length ~/ 2];
    
    // Desviaci?n est?ndar
    final variance = percentages.map((p) => (p - avg) * (p - avg)).reduce((a, b) => a + b) / percentages.length;
    final stdDev = variance > 0 ? (variance as num).toDouble() : 0.0;
    final stdDevSqrt = stdDev > 0 ? _sqrt(stdDev) : 0.0;
    
    // Rango
    final range = max - min;
    
    // SECCI?N: Estad?sticas Descriptivas
    sheet.merge(CellIndex.indexByString('A4'), CellIndex.indexByString('B4'));
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('ESTAD?STICAS DESCRIPTIVAS');
    sheet.cell(CellIndex.indexByString('A4')).cellStyle = _headerStyle;
    
    final descriptiveStats = [
      ['Media (Promedio)', '${avg.toStringAsFixed(2)}%'],
      ['Mediana', '${median.toStringAsFixed(2)}%'],
      ['Desviaci?n Est?ndar', '${stdDevSqrt.toStringAsFixed(2)}%'],
      ['Valor M?ximo', '${max.toStringAsFixed(2)}%'],
      ['Valor M?nimo', '${min.toStringAsFixed(2)}%'],
      ['Rango', '${range.toStringAsFixed(2)}%'],
      ['Muestra (n)', '${students.length} estudiantes'],
    ];
    
    for (var i = 0; i < descriptiveStats.length; i++) {
      final cell1 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5 + i));
      cell1.value = TextCellValue(descriptiveStats[i][0]);
      cell1.cellStyle = _subtitleStyle;
      
      final cell2 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5 + i));
      cell2.value = TextCellValue(descriptiveStats[i][1]);
      cell2.cellStyle = CellStyle(bold: true, fontSize: 11);
    }
    
    // SECCI?N: Indicadores de Rendimiento
    sheet.merge(CellIndex.indexByString('A14'), CellIndex.indexByString('B14'));
    sheet.cell(CellIndex.indexByString('A14')).value = TextCellValue('INDICADORES DE RENDIMIENTO');
    sheet.cell(CellIndex.indexByString('A14')).cellStyle = _headerStyle;
    
    final aprobados = percentages.where((p) => p >= 60).length;
    final excelentes = percentages.where((p) => p >= 90).length;
    final enRiesgo = percentages.where((p) => p < 60).length;
    
    final kpis = [
      ['Tasa de Aprobaci?n (?60%)', '${(aprobados / students.length * 100).toStringAsFixed(1)}%'],
      ['Tasa de Excelencia (?90%)', '${(excelentes / students.length * 100).toStringAsFixed(1)}%'],
      ['Estudiantes en Riesgo (<60%)', '$enRiesgo (${(enRiesgo / students.length * 100).toStringAsFixed(1)}%)'],
      ['Brecha de Rendimiento', '${range.toStringAsFixed(1)}%'],
    ];
    
    for (var i = 0; i < kpis.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 15 + i))
          .value = TextCellValue(kpis[i][0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 15 + i))
          .cellStyle = _subtitleStyle;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 15 + i))
          .value = TextCellValue(kpis[i][1]);
    }
    
    // SECCI?N: An?lisis de Cuartiles
    sheet.merge(CellIndex.indexByString('A21'), CellIndex.indexByString('B21'));
    sheet.cell(CellIndex.indexByString('A21')).value = TextCellValue('AN?LISIS POR CUARTILES');
    sheet.cell(CellIndex.indexByString('A21')).cellStyle = _headerStyle;
    
    final q1Idx = (sortedPct.length * 0.25).floor();
    final q2Idx = (sortedPct.length * 0.5).floor();
    final q3Idx = (sortedPct.length * 0.75).floor();
    
    final quartiles = [
      ['Cuartil 1 (25%)', '${sortedPct.isNotEmpty ? sortedPct[q1Idx].toStringAsFixed(1) : 0}%'],
      ['Cuartil 2 (50% - Mediana)', '${sortedPct.isNotEmpty ? sortedPct[q2Idx].toStringAsFixed(1) : 0}%'],
      ['Cuartil 3 (75%)', '${sortedPct.isNotEmpty ? sortedPct[q3Idx].toStringAsFixed(1) : 0}%'],
    ];
    
    for (var i = 0; i < quartiles.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 22 + i))
          .value = TextCellValue(quartiles[i][0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 22 + i))
          .value = TextCellValue(quartiles[i][1]);
    }
    
    // Ajustar anchos
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 25);
  }
  
  // ============================================================
  // HOJA 5: HISTORIAL DE RESPUESTAS
  // ============================================================
  static void _createHistorySheet(Sheet sheet, List<Map<String, dynamic>> students) {
    // T?tulo
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F2'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('?? HISTORIAL DETALLADO DE RESPUESTAS');
    titleCell.cellStyle = _titleStyle;
    
    // Encabezados
    final headers = ['Estudiante', 'Actividad', 'Respuesta', 'Correcta', 'Tiempo', 'Puntos'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }
    
    // Recopilar todas las respuestas
    int rowIdx = 5;
    for (final student in students) {
      final name = student['name'] ?? 'Sin nombre';
      final responses = student['responses'] as Map<String, dynamic>? ?? {};
      
      if (responses.isEmpty) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
            .value = TextCellValue(name);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
            .value = TextCellValue('Sin respuestas registradas');
        rowIdx++;
        continue;
      }
      
      for (final entry in responses.entries) {
        final activityId = entry.key;
        final response = entry.value as Map<String, dynamic>;
        final isCorrect = response['isCorrect'] == true;
        final timeMs = response['responseTimeMs'] as int? ?? 0;
        final points = response['points'] as double? ?? 0.0;
        
        // Estudiante
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
            .value = TextCellValue(name);
        
        // Actividad
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
            .value = TextCellValue(activityId);
        
        // Respuesta
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx))
            .value = TextCellValue(response['selectedOption']?.toString() ?? '-');
        
        // Correcta
        final correctCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx));
        correctCell.value = TextCellValue(isCorrect ? '? S?' : '? No');
        correctCell.cellStyle = CellStyle(
          fontColorHex: isCorrect ? _accentGreen : _accentRed,
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
        
        // Tiempo
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx))
            .value = TextCellValue('${(timeMs / 1000).toStringAsFixed(1)}s');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx))
            .cellStyle = _dataStyleCenter;
        
        // Puntos
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
            .value = TextCellValue('+${points.toStringAsFixed(1)}');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
            .cellStyle = _dataStyleCenter;
        
        rowIdx++;
      }
    }
    
    // Ajustar anchos
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 12);
    sheet.setColumnWidth(5, 10);
  }
  
  // ============================================================
  // HOJA 6: LOGROS Y MEDALLAS
  // ============================================================
  static void _createMedalsSheet(Sheet sheet, List<Map<String, dynamic>> students) {
    // T?tulo
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E2'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('?? LOGROS Y MEDALLAS DE ESTUDIANTES');
    titleCell.cellStyle = _titleStyle;
    
    // Encabezados
    final headers = ['#', 'Estudiante', 'Total Medallas', 'Racha Actual', 'Medallas Obtenidas'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }
    
    // Ordenar estudiantes por cantidad de medallas
    final sortedStudents = List<Map<String, dynamic>>.from(students)
      ..sort((a, b) {
        final medalsA = (a['medals'] as List?)?.length ?? 0;
        final medalsB = (b['medals'] as List?)?.length ?? 0;
        return medalsB.compareTo(medalsA);
      });
    
    int rowIdx = 5;
    for (var i = 0; i < sortedStudents.length; i++) {
      final student = sortedStudents[i];
      final name = student['name'] ?? 'Sin nombre';
      final medals = student['medals'] as List? ?? [];
      final streak = student['consecutiveCorrect'] as int? ?? 0;
      
      // Posici?n
      final posCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx));
      posCell.value = TextCellValue('${i + 1}');
      posCell.cellStyle = _dataStyleCenter;
      
      // Nombre
      final nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx));
      nameCell.value = TextCellValue(name);
      nameCell.cellStyle = _dataStyleLeft;
      
      // Total medallas
      final totalCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx));
      totalCell.value = IntCellValue(medals.length);
      totalCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: medals.isNotEmpty ? _secondaryColor : _darkGray,
        horizontalAlign: HorizontalAlign.Center,
      );
      
      // Racha
      final streakCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx));
      streakCell.value = TextCellValue(streak > 0 ? '?? $streak' : '-');
      streakCell.cellStyle = _dataStyleCenter;
      
      // Lista de medallas
      String medalsStr = '-';
      if (medals.isNotEmpty) {
        final medalsList = medals.map((m) {
          if (m is Map) {
            return '${m['emoji'] ?? '??'} ${m['name'] ?? ''}';
          }
          return '??';
        }).join(', ');
        medalsStr = medalsList;
      }
      final medalsCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx));
      medalsCell.value = TextCellValue(medalsStr);
      medalsCell.cellStyle = _dataStyleLeft;
      
      rowIdx++;
    }
    
    // Secci?n de resumen de medallas
    rowIdx += 2;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx));
    final summaryTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx));
    summaryTitleCell.value = TextCellValue('?? RESUMEN DE LOGROS');
    summaryTitleCell.cellStyle = _subHeaderStyle;
    rowIdx += 2;
    
    // Contar medallas por tipo
    final medalCounts = <String, int>{};
    for (final student in students) {
      final medals = student['medals'] as List? ?? [];
      for (final medal in medals) {
        if (medal is Map) {
          final name = medal['name']?.toString() ?? 'Desconocida';
          medalCounts[name] = (medalCounts[name] ?? 0) + 1;
        }
      }
    }
    
    // Mostrar conteo
    if (medalCounts.isNotEmpty) {
      final sortedMedals = medalCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (final entry in sortedMedals) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
            .value = TextCellValue(entry.key);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx))
            .value = TextCellValue('${entry.value} estudiante(s)');
        rowIdx++;
      }
    } else {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
          .value = TextCellValue('No se han otorgado medallas en esta sesi?n');
    }
    
    // Ajustar anchos
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 45);
  }
  
  // ============================================================
  // FUNCIONES AUXILIARES
  // ============================================================
  
  static String _getClassificationText(double percentage) {
    if (percentage >= 90) return 'Excelente';
    if (percentage >= 80) return 'Muy Bueno';
    if (percentage >= 70) return 'Bueno';
    if (percentage >= 60) return 'Regular';
    return 'En Progreso';
  }
  
  static String _formatStatus(dynamic status) {
    if (status == null) return 'Desconocido';
    final s = status.toString().toLowerCase();
    if (s.contains('connected') || s.contains('conectado')) return '?? Conectado';
    if (s.contains('responded') || s.contains('respondido')) return '? Respondi?';
    if (s.contains('idle') || s.contains('inactivo')) return '?? Inactivo';
    return status.toString();
  }
  
  static String _calculateAvgTime(Map<String, dynamic> responses) {
    if (responses.isEmpty) return '-';
    
    int totalMs = 0;
    int count = 0;
    
    for (final response in responses.values) {
      if (response is Map && response['responseTimeMs'] != null) {
        totalMs += (response['responseTimeMs'] as int);
        count++;
      }
    }
    
    if (count == 0) return '-';
    
    final avgMs = totalMs / count;
    final avgSec = avgMs / 1000;
    
    if (avgSec < 60) {
      return '${avgSec.toStringAsFixed(1)}s';
    } else {
      final mins = (avgSec / 60).floor();
      final secs = (avgSec % 60).round();
      return '${mins}m ${secs}s';
    }
  }
  
  static String _formatDateTime(dynamic dateTime) {
    if (dateTime == null || dateTime == '-') return '-';
    try {
      final dt = DateTime.parse(dateTime.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return dateTime.toString();
    }
  }
  
  /// Calcula ra?z cuadrada simple
  static double _sqrt(double value) {
    if (value <= 0) return 0;
    double guess = value / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }
}
