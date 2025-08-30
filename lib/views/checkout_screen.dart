






/*import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLocating = false;
  String? _address;
  Position? _position;
  String? _nfcCardData; // تخزين بيانات NFC

  // تحقق من صلاحية الوصول للموقع واطلبها إن لزم
  Future<bool> _handleLocationPermission() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // خدمة الموقع متوقفة على الجهاز
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // المستخدم رفض الإذن
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // الصلاحية مرفوضة نهائياً
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied, please enable from settings.')),
      );
      return false;
    }

    return true;
  }

  // استخراج الموقع الحالي
  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      setState(() {
        _isLocating = true;
      });

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _position = pos;
      });

      await _getAddressFromLatLng(pos.latitude, pos.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not determine location: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // تحويل الاحداثيات لعنوان نصي
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final formatted = [
          if (p.name != null && p.name!.isNotEmpty) p.name,
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
          if (p.country != null && p.country!.isNotEmpty) p.country,
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        setState(() {
          _address = formatted;
        });
      } else {
        setState(() {
          _address = 'Address not found';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Failed to get address: $e';
      });
    }
  }

  // قراءة بيانات NFC
  Future<void> _readNFC() async {
    try {
      NfcTag tag = await NfcKit.poll(); // الانتظار لقراءة بطاقة NFC
      setState(() {
        _nfcCardData = tag.id; // تخزين بيانات بطاقة الـ NFC
      });
      await NfcKit.finish();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NFC reading failed: $e')),
      );
    }
  }

  // UI reuse من النسخة اللي عندك
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // --- Address card (GPS integration) ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_address != null)
                  Text(
                    _address!,
                    style: const TextStyle(fontSize: 14),
                  )
                else
                  const Text(
                    'No address selected',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLocating ? null : _getCurrentLocation,
                      icon: _isLocating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.location_on),
                      label: Text(_isLocating ? 'Locating...' : 'Use current location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // اختياري: فتح شاشة لإدخال العنوان يدويًا
                        final manual = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final ctrl = TextEditingController();
                            return AlertDialog(
                              title: const Text('Enter delivery address'),
                              content: TextField(
                                controller: ctrl,
                                decoration: const InputDecoration(hintText: 'Address'),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
                              ],
                            );
                          },
                        );
                        if (manual != null && manual.isNotEmpty) {
                          setState(() {
                            _address = manual;
                          });
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Enter address'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // NFC Card reading
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NFC Card Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_nfcCardData != null)
                  Text(
                    _nfcCardData!,
                    style: const TextStyle(fontSize: 14),
                  )
                else
                  const Text(
                    'No NFC card scanned',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _readNFC,
                  child: const Text('Scan NFC Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // --- Cart items list ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCartItem("Pizza Margherita", "assets/images/pizza.png", 2, 120),
                _buildCartItem("Cheeseburger", "assets/images/burger.png", 1, 75),
                _buildCartItem("French Fries", "assets/images/fries.png", 3, 45),
              ],
            ),
          ),

          // --- Summary + Place Order ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildSummaryRow("Subtotal", "240 EGP"),
                const SizedBox(height: 8),
                _buildSummaryRow("Delivery", "20 EGP"),
                const Divider(height: 20, thickness: 1),
                _buildSummaryRow("Total", "260 EGP", isTotal: true),
                const SizedBox(height: 12),

                // Show small address preview above the button
                if (_address != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Deliver to: $_address',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_address == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select delivery address first')),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order placed successfully!")),
                      );
                    },
                    child: const Text(
                      "Place Order",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(String title, String image, int quantity, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title\nx$quantity",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            "${price * quantity} EGP",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.orange : Colors.black,
          ),
        ),
      ],
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart'; 

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLocating = false;
  String? _address;
  Position? _position;
  String? _nfcCardData; // لتخزين بيانات NFC

  // تحقق من صلاحية الوصول للموقع واطلبها إن لزم
  Future<bool> _handleLocationPermission() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied, please enable from settings.')),
      );
      return false;
    }

    return true;
  }

  // استخراج الموقع الحالي
  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      setState(() {
        _isLocating = true;
      });

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _position = pos;
      });

      await _getAddressFromLatLng(pos.latitude, pos.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not determine location: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // تحويل الاحداثيات لعنوان نصي
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final formatted = [
          if (p.name != null && p.name!.isNotEmpty) p.name,
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
          if (p.country != null && p.country!.isNotEmpty) p.country,
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        setState(() {
          _address = formatted;
        });
      } else {
        setState(() {
          _address = 'Address not found';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Failed to get address: $e';
      });
    }
  }
Future<void> _readNFC() async {
  try {
    // تحقق من دعم NFC في الجهاز
    bool isNfcAvailable = await NfcKit.isNfcAvailable();
    if (!isNfcAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This device does not support NFC')),
      );
      return;
    }

    // تحقق مما إذا كانت NFC مفعلة على الجهاز
    bool isNfcEnabled = await NfcKit.isNfcEnabled();
    if (!isNfcEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable NFC in your device settings')),
      );
      return;
    }

    // الانتظار لقراءة بطاقة NFC
    NfcTag tag = await NfcKit.poll();
    setState(() {
      _nfcCardData = tag.id;  // تخزين بيانات البطاقة NFC
    });
    
    await NfcKit.finish();  // إنهاء عملية القراءة
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('NFC reading failed: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // --- Address card (GPS integration) ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_address != null)
                  Text(
                    _address!,
                    style: const TextStyle(fontSize: 14),
                  )
                else
                  const Text(
                    'No address selected',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLocating ? null : _getCurrentLocation,
                      icon: _isLocating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.location_on),
                      label: Text(_isLocating ? 'Locating...' : 'Use current location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final manual = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final ctrl = TextEditingController();
                            return AlertDialog(
                              title: const Text('Enter delivery address'),
                              content: TextField(
                                controller: ctrl,
                                decoration: const InputDecoration(hintText: 'Address'),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
                              ],
                            );
                          },
                        );
                        if (manual != null && manual.isNotEmpty) {
                          setState(() {
                            _address = manual;
                          });
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Enter address'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // NFC Card reading
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NFC Card Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_nfcCardData != null)
                  Text(
                    _nfcCardData!,
                    style: const TextStyle(fontSize: 14),
                  )
                else
                  const Text(
                    'No NFC card scanned',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _readNFC,
                  child: const Text('Scan NFC Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // --- Cart items list ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCartItem("Pizza Margherita", "assets/images/pizza.png", 2, 120),
                _buildCartItem("Cheeseburger", "assets/images/burger.png", 1, 75),
                _buildCartItem("French Fries", "assets/images/fries.png", 3, 45),
              ],
            ),
          ),

          // --- Summary + Place Order ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildSummaryRow("Subtotal", "240 EGP"),
                const SizedBox(height: 8),
                _buildSummaryRow("Delivery", "20 EGP"),
                const Divider(height: 20, thickness: 1),
                _buildSummaryRow("Total", "260 EGP", isTotal: true),
                const SizedBox(height: 12),

                // Show small address preview above the button
                if (_address != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Deliver to: $_address',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_address == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select delivery address first')),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order placed successfully!")),
                      );
                    },
                    child: const Text(
                      "Place Order",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(String title, String image, int quantity, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title\nx$quantity",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            "${price * quantity} EGP",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.orange : Colors.black,
          ),
        ),
      ],
    );
  }
}
