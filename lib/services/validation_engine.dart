import '../models/alert_model.dart';
import '../models/furniture_model.dart';
import '../models/cut_piece_model.dart';
import '../models/cost_breakdown_model.dart';
import '../models/cutting_layout_model.dart';

class ValidationEngine {
  /// Evalúa todas las reglas de negocio técnicas y financieras
  static List<BusinessAlert> validate({
    required FurnitureModel furniture,
    required List<CutPiece> pieces,
    required CostBreakdownModel cost,
    required OptimizationResult optimization,
    double maxBoardLengthMm = 2750.0,
    double maxBoardWidthMm = 1830.0,
  }) {
    final List<BusinessAlert> alerts = [];

    // 1. REGLA FINANCIERA: MARGEN CRÍTICO Y PÉRDIDA ECONÓMICA
    if (cost.isManualPriceActive) {
      if (cost.netProfitBs < 0) {
        alerts.add(BusinessAlert(
          id: 'alert_margin_loss',
          title: '¡Pérdida Económica Inminente!',
          message:
              'El precio ingresado (Bs ${cost.activePriceBs.toStringAsFixed(2)}) no cubre los costos totales de producción, gastos operativos ni impuestos. Estás perdiendo Bs ${(-cost.netProfitBs).toStringAsFixed(2)}.',
          severity: AlertSeverity.critical,
          module: 'Financiero',
        ));
      } else if (cost.actualMarginPercent < 20.0) {
        alerts.add(BusinessAlert(
          id: 'alert_margin_critical',
          title: 'Alerta de Margen Crítico (< 20%)',
          message:
              '⚠️ Atención: El precio ingresado (Bs ${cost.activePriceBs.toStringAsFixed(2)}) genera un margen del ${cost.actualMarginPercent.toStringAsFixed(1)}%, el cual está por debajo del límite mínimo recomendado (30%).',
          severity: AlertSeverity.critical,
          module: 'Financiero',
        ));
      } else if (cost.actualMarginPercent < cost.targetMarginPercent) {
        alerts.add(BusinessAlert(
          id: 'alert_margin_warning',
          title: 'Margen por debajo del objetivo',
          message:
              'El margen neto actual (${cost.actualMarginPercent.toStringAsFixed(1)}%) es inferior a tu meta (${cost.targetMarginPercent.toInt()}%). Considera ajustar a Bs ${cost.grossMarginPriceBs.toStringAsFixed(2)}.',
          severity: AlertSeverity.warning,
          module: 'Financiero',
        ));
      }
    }

    // Validación informativa de Régimen SIETE-RG
    if (cost.taxRegime == BoliviaTaxRegime.sieteRg) {
      alerts.add(const BusinessAlert(
        id: 'alert_siete_rg_info',
        title: 'Régimen SIETE-RG (Simplificado) Activo',
        message:
            'Aplica un 5% plano sobre ventas. Recuerda que este régimen es válido únicamente para emprendimientos con ingresos totales menores a Bs 250.000 al año.',
        severity: AlertSeverity.info,
        module: 'Tributario',
      ));
    }

    // 2. REGLA TÉCNICA: RIESGO DE PANDEO / DEFLEXIÓN EN REPISAS
    // Una repisa de melamina de 15/18mm sin apoyo central de más de 900mm se pandeará con el peso
    final numDividers = furniture.verticalDividersCount;
    final internalWidth = furniture.width - (2 * furniture.melamineThickness);
    final shelfSpanMm = numDividers > 0
        ? (internalWidth - (numDividers * furniture.melamineThickness)) / (numDividers + 1)
        : internalWidth;

    if (shelfSpanMm > 900.0 && (furniture.shelvesFixedCount > 0 || furniture.shelvesMobileCount > 0)) {
      alerts.add(BusinessAlert(
        id: 'alert_shelf_deflection',
        title: 'Riesgo de Pandeo (Deflexión de Repisas)',
        message:
            'El vano libre de las repisas es de ${(shelfSpanMm / 10).toStringAsFixed(1)} cm (> 90 cm). La melamina de ${furniture.melamineThickness.toInt()}mm se flectará con libros o vajilla pesada. Se recomienda agregar 1 parante/división vertical o soporte posterior.',
        severity: AlertSeverity.warning,
        module: 'Estructura',
      ));
    }

    // 3. REGLA TÉCNICA: DIMENSIÓN MÁXIMA DE PIEZAS VS TABLERO
    // Plancha estándar: 2750 x 1830 mm (con refilado útil 2730 x 1810 mm)
    final maxUsableLength = maxBoardLengthMm - 20.0;
    final maxUsableWidth = maxBoardWidthMm - 20.0;

    for (final p in pieces) {
      final canFitStandard = (p.length <= maxUsableLength && p.width <= maxUsableWidth) ||
          (p.width <= maxUsableLength && p.length <= maxUsableWidth);

      if (!canFitStandard) {
        alerts.add(BusinessAlert(
          id: 'alert_oversized_${p.id}',
          title: 'Inviabilidad Técnica de Corte',
          message:
              'La pieza "${p.name}" (${p.length.toInt()} x ${p.width.toInt()} mm) excede las dimensiones máximas aprovechables de una plancha estándar (${maxUsableLength.toInt()} x ${maxUsableWidth.toInt()} mm). Debe dividirse en dos módulos o unir con junta.',
          severity: AlertSeverity.critical,
          module: 'Corte',
        ));
      }
    }

    // 4. REGLA TÉCNICA: PROFUNDIDAD PARA CAJONES
    if (furniture.drawersCount > 0 && furniture.depth < 350.0) {
      alerts.add(BusinessAlert(
        id: 'alert_shallow_drawers',
        title: 'Profundidad Reducida para Cajones',
        message:
            'La profundidad del mueble (${furniture.depth.toInt()} mm) es muy ajustada. Las correderas telescópicas más comunes inician en 350 mm o 400 mm. La corredera mínima disponible es de 300 mm.',
        severity: AlertSeverity.warning,
        module: 'Herrajes',
      ));
    }

    // 5. REGLA DE EFICIENCIA: DESPERDICIO ELEVADO (SCRAP > 25%)
    if (optimization.overallWastePercent > 25.0) {
      alerts.add(BusinessAlert(
        id: 'alert_high_waste',
        title: 'Porcentaje de Desperdicio Elevado (${optimization.overallWastePercent.toStringAsFixed(1)}%)',
        message:
            'El corte actual deja más del 25% de sobrantes/merma en tablero. Puedes ajustar ligeramente las medidas o planificar piezas secundarias (zócalos, refuerzos) para optimizar la plancha.',
        severity: AlertSeverity.info,
        module: 'Corte',
      ));
    }

    return alerts;
  }
}

