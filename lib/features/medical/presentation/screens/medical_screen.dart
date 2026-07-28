import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/medical_entities.dart';
import '../providers/medical_provider.dart';

class MedicalScreen extends ConsumerWidget {
  const MedicalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicalAsync = ref.watch(medicalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Add Medical Record',
            onPressed: () => _showAddRecordModal(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineModal(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.medication, color: Colors.white),
        label: const Text('Add Medicine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: medicalAsync.when(
        data: (data) => _buildMedicalContent(context, ref, data),
        loading: () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              LoadingShimmer(height: 140),
              SizedBox(height: 16),
              LoadingShimmer(height: 100),
              SizedBox(height: 16),
              LoadingShimmer(height: 180),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(medicalProvider),
        ),
      ),
    );
  }

  Widget _buildMedicalContent(BuildContext context, WidgetRef ref, MedicalState state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("Daily Medication Schedule", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (state.reminders.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No active medication reminders.')))
        else
          ...state.reminders.map((rem) => _buildReminderTile(ref, rem)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Medical Records & Documents", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.document_scanner, size: 18),
              label: const Text('Scan Doc'),
              onPressed: () => _showAddRecordModal(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.records.isEmpty)
          EmptyStateWidget(
            title: 'No Documents Saved',
            message: 'Scan lab results or prescriptions to keep your medical history organized.',
            actionLabel: 'Scan Document',
            onAction: () => _showAddRecordModal(context, ref),
          )
        else
          ...state.records.map((rec) => _buildRecordCard(context, rec)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildReminderTile(WidgetRef ref, MedicineReminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: reminder.isTaken,
        activeColor: AppColors.primary,
        onChanged: (_) => ref.read(medicalProvider.notifier).toggleMedicine(reminder.id),
        title: Text(
          reminder.medicineName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: reminder.isTaken ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${reminder.dosage} • ${reminder.timeOfDay}'),
        secondary: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: const Icon(Icons.medication, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, MedicalRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_shared_outlined, color: AppColors.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Chip(
                  label: Text(record.category.name),
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                  labelStyle: const TextStyle(color: AppColors.secondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Doctor: ${record.doctorName} • Date: ${record.date.day}/${record.date.month}/${record.date.year}', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
            const SizedBox(height: 8),
            Text(record.summary, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showAddMedicineModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController(text: '1 Tablet');
    final timeController = TextEditingController(text: '08:00 AM');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Medicine Reminder', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Medicine Name')),
              const SizedBox(height: 12),
              TextField(controller: dosageController, decoration: const InputDecoration(labelText: 'Dosage')),
              const SizedBox(height: 12),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time of Day')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameController.text.isEmpty) return;
                    ref.read(medicalProvider.notifier).addMedicine(
                          name: nameController.text,
                          dosage: dosageController.text,
                          timeOfDay: timeController.text,
                          category: MedicineCategory.pill,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Save Reminder'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddRecordModal(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final doctorController = TextEditingController(text: 'Dr. Michael Chen');
    final summaryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Medical Record', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Document Title')),
              const SizedBox(height: 12),
              TextField(controller: doctorController, decoration: const InputDecoration(labelText: 'Doctor / Clinic Name')),
              const SizedBox(height: 12),
              TextField(controller: summaryController, maxLines: 2, decoration: const InputDecoration(labelText: 'AI Summary / Notes')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Medical Record'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    if (titleController.text.isEmpty) return;
                    ref.read(medicalProvider.notifier).addRecord(
                          title: titleController.text,
                          doctorName: doctorController.text,
                          category: RecordCategory.labResult,
                          summary: summaryController.text.isNotEmpty ? summaryController.text : 'Medical report logged successfully.',
                        );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
