import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Servicio para exportar resultados a Excel
class ExportService {
  
  /// Exporta los resultados de los estudiantes a un archivo Excel
  static Future<bool> exportStudentResults({
    required List<Map<String, dynamic>> students,
    required String sessionTitle,
    required BuildContext context,
  }) async {
    try {
      final excel = Excel.createExcel();
      
      // Hoja de resumen general
      final summarySheet = excel['Resumen'];
      _createSummarySheet(summarySheet, students, sessionTitle);
      
      // Hoja de detalle por estudiante
      final detailSheet = excel['Detalle Estudiantes'];
      _createDetailSheet(detailSheet, students);
      
      // Hoja de estad?sticas
      final statsSheet = excel['Estad?sticas'];
      _createStatsSheet(statsSheet, students);
      
      // Eliminar la hoja por defecto
      excel.delete('Sheet1');
      
      // Generar el archivo
      final bytes = excel.save();
      if (bytes == null) {
        throw Exception('Error al generar el archivo Excel');
      }
      
      // Nombre del archivo con fecha
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(now);
      final fileName = 'Resultados_${sessionTitle.replaceAll(' ', '_')}_$dateStr';
      
      // Guardar el archivo
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error exportando a Excel: $e');
      return false;
    }
  }
  
  /// Crea la hoja de resumen
  static void _createSummarySheet(
    Sheet sheet, 
    List<Map<String, dynamic>> students,
    String sessionTitle,
  ) {
    // T?tulo
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('RESUMEN DE RESULTADOS');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));
    
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Sesi?n: $sessionTitle');
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Total estudiantes: ${students.length}');
    
    // Encabezados de tabla
    final headers = ['#', 'Nombre', 'Porcentaje', 'Clasificaci?n', 'Estado'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 6));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }
    
    // Datos de estudiantes
    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final rowIndex = 7 + i;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(student['name'] ?? 'Sin nombre');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = DoubleCellValue((student['percentage'] ?? 0.0).toDouble());
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(_getClassification(student['percentage'] ?? 0.0));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue(student['status'] ?? 'Desconocido');
    }
    
    // Ajustar anchos de columna
    sheet.setColumnWidth(0, 5);   // #
    sheet.setColumnWidth(1, 25);  // Nombre
    sheet.setColumnWidth(2, 12);  // Porcentaje
    sheet.setColumnWidth(3, 18);  // Clasificaci?n
    sheet.setColumnWidth(4, 15);  // Estado
  }
  
  /// Crea la hoja de detalle
  static void _createDetailSheet(Sheet sheet, List<Map<String, dynamic>> students) {
    // Encabezados
    final headers = ['Nombre', 'Porcentaje', 'Respuestas Correctas', 'Respuestas Totales', 'Tiempo Promedio', '?ltima Actividad'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#70AD47'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }
    
    // Datos
    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final rowIndex = 1 + i;
      final responses = student['responses'] as Map<String, dynamic>? ?? {};
      final correctCount = responses.values.where((r) => r['isCorrect'] == true).length;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(student['name'] ?? 'Sin nombre');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue('${(student['percentage'] ?? 0.0).toStringAsFixed(1)}%');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = IntCellValue(correctCount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = IntCellValue(responses.length);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue(_calculateAvgTime(responses));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(student['lastActivity'] ?? '-');
    }
    
    // Ajustar anchos
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 20);
    sheet.setColumnWidth(3, 18);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 20);
  }
  
  /// Crea la hoja de estad?sticas
  static void _createStatsSheet(Sheet sheet, List<Map<String, dynamic>> students) {
    // Calcular estad?sticas
    final percentages = students
        .map((s) => (s['percentage'] ?? 0.0) as double)
        .toList();
    
    final avg = percentages.isEmpty ? 0.0 : 
        percentages.reduce((a, b) => a + b) / percentages.length;
    final max = percentages.isEmpty ? 0.0 : 
        percentages.reduce((a, b) => a > b ? a : b);
    final min = percentages.isEmpty ? 0.0 : 
        percentages.reduce((a, b) => a < b ? a : b);
    
    // Contar por clasificaci?n
    int excelentes = 0, muyBuenos = 0, buenos = 0, regulares = 0, bajos = 0;
    for (final p in percentages) {
      if (p >= 90) excelentes++;
      else if (p >= 80) muyBuenos++;
      else if (p >= 70) buenos++;
      else if (p >= 60) regulares++;
      else bajos++;
    }
    
    // T?tulo
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('ESTAD?STICAS GENERALES');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('B1'));
    
    // Estad?sticas b?sicas
    final stats = [
      ['Total Estudiantes', students.length.toString()],
      ['Promedio General', '${avg.toStringAsFixed(1)}%'],
      ['Puntaje M?ximo', '${max.toStringAsFixed(1)}%'],
      ['Puntaje M?nimo', '${min.toStringAsFixed(1)}%'],
      ['', ''],
      ['DISTRIBUCI?N POR NIVEL', ''],
      ['Excelente (90-100%)', '$excelentes estudiantes'],
      ['Muy Bueno (80-89%)', '$muyBuenos estudiantes'],
      ['Bueno (70-79%)', '$buenos estudiantes'],
      ['Regular (60-69%)', '$regulares estudiantes'],
      ['Necesita Mejorar (<60%)', '$bajos estudiantes'],
    ];
    
    for (var i = 0; i < stats.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3 + i))
          .value = TextCellValue(stats[i][0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3 + i))
          .value = TextCellValue(stats[i][1]);
      
      if (stats[i][0].contains('DISTRIBUCI?N') || i < 4) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3 + i))
            .cellStyle = CellStyle(bold: true);
      }
    }
    
    // Ajustar anchos
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 20);
  }
  
  /// Obtiene la clasificaci?n seg?n el porcentaje
  static String _getClassification(double percentage) {
    if (percentage >= 90) return '? Excelente';
    if (percentage >= 80) return '?? Muy Bueno';
    if (percentage >= 70) return '?? Bueno';
    if (percentage >= 60) return '?? Regular';
    return '?? En Progreso';
  }
  
  /// Calcula el tiempo promedio de respuesta
  static String _calculateAvgTime(Map<String, dynamic> responses) {
    if (responses.isEmpty) return '-';
    
    int totalMs = 0;
    int count = 0;
    
    for (final response in responses.values) {
      if (response['responseTimeMs'] != null) {
        totalMs += (response['responseTimeMs'] as int);
        count++;
      }
    }
    
    if (count == 0) return '-';
    
    final avgMs = totalMs / count;
    final avgSec = avgMs / 1000;
    
    return '${avgSec.toStringAsFixed(1)}s';
  }
}
