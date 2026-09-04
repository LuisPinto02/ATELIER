import 'package:flutter/material.dart';

enum AlertSeverity {
  critical, // Rojo
  warning,  // Ámbar/Naranja
  info,     // Azul/Verde
}

extension AlertSeverityExtension on AlertSeverity {
  Color get color {
    switch (this) {
      case AlertSeverity.critical:
        return const Color(0xFFD32F2F);
      case AlertSeverity.warning:
        return const Color(0xFFED6C02);
      case AlertSeverity.info:
        return const Color(0xFF0288D1);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertSeverity.critical:
        return const Color(0xFFFFEBEE);
      case AlertSeverity.warning:
        return const Color(0xFFFFF4E5);
      case AlertSeverity.info:
        return const Color(0xFFE1F5FE);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.critical:
        return Icons.error_outline_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  String get prefix {
    switch (this) {
      case AlertSeverity.critical:
        return 'CRÍTICO';
      case AlertSeverity.warning:
        return 'ADVERTENCIA';
      case AlertSeverity.info:
        return 'CONSEJO TÉCNICO';
    }
  }
}

class BusinessAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final String module; // 'Financiero', 'Estructura', 'Corte', 'Herrajes'

  const BusinessAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.module,
  });
}

