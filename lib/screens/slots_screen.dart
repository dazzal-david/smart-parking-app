import 'package:flutter/material.dart';
import 'package:smart_parking_app/models/parking_place.dart';
import 'package:smart_parking_app/models/parking_slot.dart';
import 'package:smart_parking_app/services/supabase_service.dart';

class SlotsScreen extends StatefulWidget {
  final ParkingPlace place;

  const SlotsScreen({Key? key, required this.place}) : super(key: key);

  @override
  _SlotsScreenState createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  final _supabaseService = SupabaseService();
  final _vehicleNumberController = TextEditingController();
  List<ParkingSlot> _slots = [];
  List<Map<String, dynamic>> _userVehicles = [];
  bool _isLoading = true;
  String? _selectedSlotId;
  int _selectedDuration = 1;
  bool _isManualEntry = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load both slots and user vehicles in parallel
      final futures = await Future.wait([
        _supabaseService.getParkingSlots(widget.place.id),
        _supabaseService.getUserVehicles(),
      ]);

      setState(() {
        _slots = futures[0] as List<ParkingSlot>;
        _userVehicles = futures[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _bookSlot() async {
    final vehicleNumber = _isManualEntry 
        ? _vehicleNumberController.text 
        : _vehicleNumberController.text.split(' - ')[0];

    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a slot first')),
      );
      return;
    }

    if (vehicleNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a vehicle number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabaseService.bookParkingSlotWithDetails(
        widget.place.id,
        _selectedSlotId!,
        _selectedDuration,
        vehicleNumber,
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildVehicleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_userVehicles.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Vehicle',
              border: OutlineInputBorder(),
            ),
            items: _userVehicles.map((vehicle) {
              final displayText = '${vehicle['vehicle_number']} - ${vehicle['brand']} ${vehicle['model']} (${vehicle['vehicle_type']})';
              return DropdownMenuItem(
                value: displayText,
                child: Text(displayText),
              );
            }).toList(),
            onChanged: _isManualEntry ? null : (value) {
              setState(() {
                _vehicleNumberController.text = value ?? '';
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Or enter manually'),
              const SizedBox(width: 8),
              Switch(
                value: _isManualEntry,
                onChanged: (value) {
                  setState(() {
                    _isManualEntry = value;
                    _vehicleNumberController.clear();
                  });
                },
              ),
            ],
          ),
        ],
        if (_isManualEntry || _userVehicles.isEmpty) ...[
          TextField(
            controller: _vehicleNumberController,
            decoration: const InputDecoration(
              labelText: 'Enter Vehicle Number',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            enabled: _isManualEntry || _userVehicles.isEmpty,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Slots - ${widget.place.name}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _slots.length,
                    itemBuilder: (context, index) {
                      final slot = _slots[index];
                      return GestureDetector(
                        onTap: slot.isOccupied
                            ? null
                            : () {
                                setState(() {
                                  _selectedSlotId = slot.id;
                                });
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: slot.isOccupied
                                ? Colors.grey
                                : _selectedSlotId == slot.id
                                    ? Colors.blue
                                    : Colors.white,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              slot.slotNumber,
                              style: TextStyle(
                                color: slot.isOccupied || _selectedSlotId == slot.id
                                    ? Colors.white
                                    : Colors.blue,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildVehicleSelection(),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedDuration,
                        decoration: const InputDecoration(
                          labelText: 'Duration (hours)',
                          border: OutlineInputBorder(),
                        ),
                        items: [1, 2, 3, 4, 5, 6].map((hours) {
                          return DropdownMenuItem(
                            value: hours,
                            child: Text('$hours hour${hours > 1 ? 's' : ''}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDuration = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedSlotId == null ? null : _bookSlot,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Book Selected Slot'),
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