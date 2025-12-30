import 'dart:developer';

import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/admin/state_tax_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/models/state_tax_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AdminStateSalesTaxScreen extends StatefulWidget {
  const AdminStateSalesTaxScreen({super.key});

  @override
  State<AdminStateSalesTaxScreen> createState() =>
      _AdminStateSalesTaxScreenState();
}

class _AdminStateSalesTaxScreenState extends State<AdminStateSalesTaxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StateTaxProvider>().fetchAllStateTaxes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: adminCustomAppBar(
        context: context,
        title: "State Sales Tax",
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KprimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
              onPressed: () => _showAddTaxDialog(context),
            ),
          )
        ],
      ),
      body: Consumer<StateTaxProvider>(
        builder: (context, provider, child) {
          if (provider.isloading) {
            return Center(child: SmallLoader());
          }

          if (provider.stateTaxes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No state taxes added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a state tax',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.stateTaxes.length,
            itemBuilder: (context, index) {
              final tax = provider.stateTaxes[index];
              return _StateTaxCard(tax: tax);
            },
          );
        },
      ),
    );
  }

  void _showAddTaxDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _TaxDialog(),
    );
  }
}

class _StateTaxCard extends StatelessWidget {
  final StateTaxModel tax;

  const _StateTaxCard({required this.tax});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDeleteConfirmation(context, tax),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: KprimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  tax.code,
                  style: TextStyle(
                    color: KprimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tax.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tax.taxRate.toStringAsFixed(2)}% tax rate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showUpdateDialog(context, tax),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: KprimaryColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  color: KprimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StateTaxModel tax) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete State Tax',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${tax.name} (${tax.taxRate.toStringAsFixed(2)}%)?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Consumer<StateTaxProvider>(
            builder: (context, provider, _) {
              return ElevatedButton(
                onPressed: provider.isdeleting
                    ? null
                    : () async {
                        await provider.deleteStateSalesTax(tax.id);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: provider.isdeleting
                    ? SizedBox(
                        height: 15,
                        width: 15,
                        child: SmallLoader(
                          backgroundColor: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, StateTaxModel tax) {
    showDialog(
      context: context,
      builder: (context) => _TaxDialog(existingTax: tax),
    );
  }
}

class _TaxDialog extends StatefulWidget {
  final StateTaxModel? existingTax;

  const _TaxDialog({this.existingTax});

  @override
  State<_TaxDialog> createState() => _TaxDialogState();
}

class _TaxDialogState extends State<_TaxDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taxRateController = TextEditingController();
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    if (widget.existingTax != null) {
      _selectedState = widget.existingTax!.name;
      _taxRateController.text = widget.existingTax!.taxRate.toString();
    }
  }

  @override
  void dispose() {
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StateTaxProvider>();
    final isUpdate = widget.existingTax != null;

    // Get list of available states (not already added)
    final addedStateNames = provider.stateTaxes.map((tax) => tax.name).toSet();
    final availableStates = provider.usStates
        .where((state) => !addedStateNames.contains(state['name']))
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUpdate ? 'Update State Tax' : 'Add State Tax',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'State',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: InputDecoration(
                  hintText: availableStates.isEmpty
                      ? 'All states added'
                      : 'Select a state',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                isExpanded: true,
                items: isUpdate
                    ? [
                        DropdownMenuItem<String>(
                          value: widget.existingTax!.name,
                          child: Text(
                            '${widget.existingTax!.name} (${widget.existingTax!.code})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ]
                    : availableStates.map((state) {
                        return DropdownMenuItem<String>(
                          value: state['name'],
                          child: Text(
                            '${state['name']} (${state['code']})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                onChanged: isUpdate
                    ? null
                    : (value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Tax Rate (%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _taxRateController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter tax rate',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixText: '%',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tax rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Enter a valid rate (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Consumer<StateTaxProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: (provider.isAddingTax || provider.isUpdateing)
                            ? null
                            : () => _handleSubmit(context, provider, isUpdate),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KprimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: (provider.isAddingTax == true ||
                                provider.isUpdateing == true)
                            ? Center(
                                child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: SmallLoader(
                                        backgroundColor: Colors.white,
                                        strokeWidth: 2)),
                              )
                            : Text(
                                isUpdate ? 'Update' : 'Add',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
      BuildContext context, StateTaxProvider provider, bool isUpdate) async {
    if (_formKey.currentState!.validate()) {
      if (isUpdate) {
        await provider.updateStateSalesTax(
          widget.existingTax!.id,
          _selectedState!,
          _taxRateController.text,
        );
      } else {
        log("[AdminStateSalesTaxScreen] [add sales tax] data ${_selectedState} ${_taxRateController.text}");
        await provider.addStateSalesTax(
            _selectedState!, _taxRateController.text);
      }
      Navigator.pop(context);
    }
  }
}