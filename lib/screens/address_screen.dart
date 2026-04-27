import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinController = TextEditingController();
  String? _selectedAddress;

  List<Map<String, String>> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    // Simulate loaded addresses
    setState(() {
      addresses = [
        {'name': 'Home', 'phone': '9876543210', 'address': '123 Luxury Street', 'city': 'Mumbai', 'state': 'Maharashtra', 'pin': '400001'},
        {'name': 'Office', 'phone': '9876543211', 'address': '456 Premium Tower', 'city': 'Delhi', 'state': 'Delhi', 'pin': '110001'},
      ];
    });
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        addresses.add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'pin': _pinController.text,
        });
        _clearForm();
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _pinController.clear();
  }

  void _setDefault(String name) {
    setState(() {
      _selectedAddress = name;
    });
  }

  void _deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGold.withOpacity(0.05),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 92,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Shipping Addresses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x80000000)),
              Shadow(offset: Offset(0, -2), blurRadius: 8, color: Colors.amber),
            ],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkBg, AppColors.primaryGold.withOpacity(0.3)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Addresses List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                      child: const Icon(Icons.location_on, color: AppColors.primaryGold),
                    ),
                    title: Text(addr['name'] ?? ''),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addr['address'] ?? ''),

                        Text('${addr['city'] ?? ''}, ${addr['state'] ?? ''} - ${addr['pin'] ?? ''}'),
                        Text(addr['phone'] ?? ''),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Radio<String>(
                          value: addr['name'] ?? '',
                          groupValue: _selectedAddress,
                          onChanged: (value) => _setDefault(value ?? ''),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAddress(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Add New Address Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Add New Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Label (Home/Office)'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Phone'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(labelText: 'Address'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            Row(
                              children: [
                                Expanded(child: TextFormField(
                                  controller: _cityController,
                                  decoration: const InputDecoration(labelText: 'City'),
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: TextFormField(
                                  controller: _pinController,
                                  decoration: const InputDecoration(labelText: 'PIN'),
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                )),
                              ],
                            ),
                            TextFormField(
                              controller: _stateController,
                              decoration: const InputDecoration(labelText: 'State'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: ElevatedButton(
                                  onPressed: _saveAddress,
                                  child: const Text('Save'),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Add New Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
