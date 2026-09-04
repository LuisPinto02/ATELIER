import 'package:flutter/material.dart';
import '../models/furniture_model.dart';
import '../models/workshop_catalog_model.dart';
import '../models/cost_breakdown_model.dart';
import '../models/cutting_layout_model.dart';
import '../models/alert_model.dart';
import '../services/bom_engine.dart';
import '../services/cutting_optimizer.dart';
import '../services/costing_engine.dart';
import '../services/validation_engine.dart';
import 'widgets/alerts_banner.dart';
import 'widgets/furniture_config_view.dart';
import 'widgets/bom_view.dart';
import 'widgets/cutting_view.dart';
import 'widgets/costing_view.dart';
import 'widgets/quotation_view.dart';
import 'widgets/catalog_settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  // Estado Central del Proyecto
  FurnitureModel _furniture = FurnitureModel.fromPreset(FurniturePreset.roperoCloset);
  WorkshopCatalog _catalog = WorkshopCatalog.defaultCatalog();
  double _targetMarginPercent = 30.0;
  double? _manualPrice;
  BoliviaTaxRegime _taxRegime = BoliviaTaxRegime.sieteRg;
  double? _operatingExpensesPercent;
  double? _financialExpensesPercent;

  @override
  Widget build(BuildContext context) {
    // Pipeline de Cálculos Reactivos en Tiempo Real
    final bom = BomEngine.generateBom(_furniture, _catalog);
    final optimization = CuttingOptimizer.optimize(pieces: bom.pieces, catalog: _catalog);
    final cost = CostingEngine.calculateCost(
      furniture: _furniture,
      bom: bom,
      optimization: optimization,
      catalog: _catalog,
      targetMarginPercent: _targetMarginPercent,
      manualPrice: _manualPrice,
      taxRegime: _taxRegime,
      operatingExpensesPercentOverride: _operatingExpensesPercent,
      financialExpensesPercentOverride: _financialExpensesPercent,
    );
    final alerts = ValidationEngine.validate(
      furniture: _furniture,
      pieces: bom.pieces,
      cost: cost,
      optimization: optimization,
    );

    final criticalAlertsCount = alerts.where((a) => a.severity == AlertSeverity.critical).length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ATELIER',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _furniture.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_furniture.height.toInt()}×${_furniture.width.toInt()}×${_furniture.depth.toInt()} mm | ${_furniture.melamineColorName} (${_furniture.melamineThickness.toInt()}mm)',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Badge de Precio Activo y Margen
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cost.actualMarginPercent < 20.0
                  ? Colors.red.shade800
                  : const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bs ${cost.activePriceBs.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${cost.actualMarginPercent.toStringAsFixed(0)}% mg',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Indicador de Alertas
          if (alerts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: '${alerts.length} alertas activas',
                child: Badge(
                  label: Text('${alerts.length}'),
                  backgroundColor: criticalAlertsCount > 0 ? Colors.red : Colors.orange,
                  child: IconButton(
                    icon: Icon(
                      criticalAlertsCount > 0 ? Icons.warning_rounded : Icons.info_outline_rounded,
                      color: criticalAlertsCount > 0 ? Colors.amberAccent : Colors.white70,
                    ),
                    onPressed: () {
                      _showAllAlertsDialog(context, alerts);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          return Column(
            children: [
              // Banner superior si existen alertas críticas o de inviabilidad técnica
              if (alerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: AlertsBanner(alerts: alerts),
                ),
              // Contenido Principal
              Expanded(
                child: Row(
                  children: [
                    if (isWide)
                      NavigationRail(
                        selectedIndex: _currentTab,
                        onDestinationSelected: (idx) => setState(() => _currentTab = idx),
                        labelType: NavigationRailLabelType.all,
                        elevation: 1,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.tune_rounded),
                            selectedIcon: Icon(Icons.tune_rounded),
                            label: Text('1. Mueble'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.format_list_bulleted_rounded),
                            selectedIcon: Icon(Icons.format_list_bulleted_rounded),
                            label: Text('2. Despiece'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.crop_free_rounded),
                            selectedIcon: Icon(Icons.crop_free_rounded),
                            label: Text('3. Cortes 2D'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.monetization_on_outlined),
                            selectedIcon: Icon(Icons.monetization_on_rounded),
                            label: Text('4-5. P&L / Costos'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.receipt_long_outlined),
                            selectedIcon: Icon(Icons.receipt_long_rounded),
                            label: Text('7. Cotización'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.table_chart_outlined),
                            selectedIcon: Icon(Icons.table_chart_rounded),
                            label: Text('Tarifas'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: _buildCurrentModuleView(
                        bom: bom,
                        optimization: optimization,
                        cost: cost,
                        alerts: alerts,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 800
          ? NavigationBar(
              selectedIndex: _currentTab,
              onDestinationSelected: (idx) => setState(() => _currentTab = idx),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.tune_rounded),
                  label: 'Mueble',
                ),
                NavigationDestination(
                  icon: Icon(Icons.format_list_bulleted_rounded),
                  label: 'Despiece',
                ),
                NavigationDestination(
                  icon: Icon(Icons.crop_free_rounded),
                  label: 'Cortes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.monetization_on_rounded),
                  label: 'P&L / Costos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'Cotización',
                ),
                NavigationDestination(
                  icon: Icon(Icons.table_chart_rounded),
                  label: 'Tarifas',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildCurrentModuleView({
    required BomResult bom,
    required OptimizationResult optimization,
    required dynamic cost,
    required List<BusinessAlert> alerts,
  }) {
    switch (_currentTab) {
      case 0:
        return FurnitureConfigView(
          furniture: _furniture,
          onChanged: (updated) {
            setState(() {
              _furniture = updated;
            });
          },
        );
      case 1:
        return BomView(bom: bom);
      case 2:
        return CuttingView(optimization: optimization);
      case 3:
        return CostingView(
          cost: cost,
          onTargetMarginChanged: (m) {
            setState(() {
              _targetMarginPercent = m;
            });
          },
          onManualPriceChanged: (p) {
            setState(() {
              _manualPrice = p;
            });
          },
          onTaxRegimeChanged: (regime) {
            setState(() {
              _taxRegime = regime;
            });
          },
          onOperatingExpensePercentChanged: (val) {
            setState(() {
              _operatingExpensesPercent = val;
            });
          },
          onFinancialExpensePercentChanged: (val) {
            setState(() {
              _financialExpensesPercent = val;
            });
          },
        );
      case 4:
        return QuotationView(
          furniture: _furniture,
          bom: bom,
          cost: cost,
          optimization: optimization,
        );
      case 5:
        return CatalogSettingsView(
          catalog: _catalog,
          onCatalogChanged: (c) {
            setState(() {
              _catalog = c;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showAllAlertsDialog(BuildContext context, List<BusinessAlert> alerts) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.rule_folder_outlined, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Reglas de Negocio y Alertas (${alerts.length})'),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: AlertsBanner(alerts: alerts),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
