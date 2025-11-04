// admin_setting_screen.dart
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/settings_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminSettingScreen extends StatefulWidget {
  const AdminSettingScreen({super.key});

  @override
  State<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchGlobalPromo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: adminCustomAppBar(
        context: context,
        title: "App Settings",
        showBackButton: true,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo Code Management Section
              PromoCodeManagementWidget(),
              
              SizedBox(height: 24),
              
              // Add more settings widgets here
              // const NotificationSettingsWidget(),
              // const MaintenanceModeWidget(),
              // const AppVersionControlWidget(),
            ],
          ),
        ),
      ),
    );
  }
}



class PromoCodeManagementWidget extends StatelessWidget {
  const PromoCodeManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.tag5, size: 24,color: KprimaryColor,),
            SizedBox(width: 8),
            Text(
              'Promo Codes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: KprimaryColor),
            ),
          ],
        ),
        SizedBox(height: 12),
        _AddPromoForm(),
        SizedBox(height: 16),
        _PromoCodeList(),
      ],
    );
  }
}

class _AddPromoForm extends StatefulWidget {
  const _AddPromoForm();

  @override
  State<_AddPromoForm> createState() => _AddPromoFormState();
}

class _AddPromoFormState extends State<_AddPromoForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isExpanded = false;

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _pickDateTime(bool isStart) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: isStart ? DateTime.now() : (_startTime ?? DateTime.now()),
      maxTime: DateTime(2030, 12, 31),
      onConfirm: (date) => setState(() => isStart ? _startTime = date : _endTime = date),
      currentTime: (isStart ? _startTime : _endTime) ?? DateTime.now(),
      locale: LocaleType.en,
    );
  }

  void _addPromo() {
    if (!_formKey.currentState!.validate() || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    if (_endTime!.isBefore(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    context.read<SettingsProvider>().saveGlobalPromo(
      code: _codeController.text,
      discountPercent: double.parse(_discountController.text),
      startTime: _startTime!,
      endTime: _endTime!,
    );

    _codeController.clear();
    _discountController.clear();
    setState(() {
      _startTime = null;
      _endTime = null;
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add New Promo Code'),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'Code',
                              hintText: 'SUMMER25',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (v) => v == null || v.trim().length < 3
                                ? 'Min 3 chars'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'Discount %',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final d = double.tryParse(v ?? '');
                              return d == null || d <= 0 || d > 100
                                  ? 'Invalid'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DateTimeButton(
                            label: 'Start',
                            dateTime: _startTime,
                            onTap: () => _pickDateTime(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateTimeButton(
                            label: 'End',
                            dateTime: _endTime,
                            onTap: () => _pickDateTime(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : _addPromo,
                        icon: provider.isLoading
                            ?  SizedBox(
                                width: 16,
                                height: 16,
                                child: SmallLoader(strokeWidth: 2,backgroundColor: KprimaryColor),
                              )
                            : const Icon(Icons.add, size: 20),
                        label: Text(provider.isLoading ? 'Adding...' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final VoidCallback onTap;

  const _DateTimeButton({
    required this.label,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              dateTime != null
                  ? DateFormat('MMM dd, yy hh:mm a').format(dateTime!)
                  : 'Select date & time',
              style: TextStyle(
                fontSize: 13,
                color: dateTime != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCodeList extends StatelessWidget {
  const _PromoCodeList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    if (provider.isLoading && !provider.isLoaded) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final promoCodes = provider.promoCodes;

    if (promoCodes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.discount_outlined, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No promo codes yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${promoCodes.length} Promo${promoCodes.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showClearDialog(context, provider),
                  icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                  label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: promoCodes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final promo = promoCodes[index];
              final isActive = promo.isCurrentlyValid;
              final isExpired = promo.hasExpired;

              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isActive
                      ? Colors.green
                      : isExpired
                          ? Colors.red
                          : Colors.orange,
                  child: Icon(
                    isActive ? Icons.check : isExpired ? Icons.close : Icons.schedule,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      promo.code,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${promo.discountPercent}% OFF',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('MMM dd, yy').format(promo.startTime.toDate())} - ${DateFormat('MMM dd, yy').format(promo.endTime.toDate())}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive ? 'Active' : isExpired ? 'Expired' : 'Scheduled',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.green
                            : isExpired
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  onPressed: () => _showDeleteDialog(context, provider, promo.code),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SettingsProvider provider, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Promo'),
        content: Text('Remove "$code"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.removePromo(code);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Promos'),
        content: const Text('Remove all promo codes? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearAllPromos();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}