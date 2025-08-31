import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

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
  bool _isNfcReading = false; // لتتبع حالة قراءة NFC



  @override
  void initState() {
    super.initState();
  }

  // تحقق من صلاحية الوصول للموقع واطلبها إن لزم
  Future<bool> _handleLocationPermission() async {
    try {
      LocationPermission permission;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // خدمة الموقع متوقفة على الجهاز
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return false;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // المستخدم رفض الإذن
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // الصلاحية مرفوضة نهائياً
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permissions are permanently denied, please enable from settings.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking location permissions: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
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

      // Show success message if we got a meaningful address
      if (mounted &&
          _address != null &&
          _address!.startsWith('Location:') == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location obtained successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not determine location: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // تحويل الاحداثيات لعنوان نصي
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    // Set coordinates as fallback immediately
    setState(() {
      _address =
          'Location: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    });

    try {
      // Add a timeout to prevent hanging
      final placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        // Create a list of address components with ultra-safe null checking
        final addressComponents = <String>[];

        // Use a helper function to safely extract text
        String? safeText(String? text) {
          if (text == null) return null;
          final trimmed = text.trim();
          return trimmed.isEmpty ? null : trimmed;
        }

        // Safely add each component
        final components = [
          safeText(p.name),
          safeText(p.street),
          safeText(p.subLocality),
          safeText(p.locality),
          safeText(p.administrativeArea),
          safeText(p.postalCode),
          safeText(p.country),
        ];

        // Filter out null values and add to list
        for (final component in components) {
          if (component != null) {
            addressComponents.add(component);
          }
        }

        // If we have meaningful address components, use them
        if (addressComponents.isNotEmpty) {
          final formatted = addressComponents.join(', ');
          setState(() {
            _address = formatted;
          });
        }
        // If no meaningful components, keep the coordinates fallback
      }
      // If no placemarks, keep the coordinates fallback
    } catch (e) {
      // Log the error for debugging but don't show to user since we already have coordinates
      debugPrint('Geocoding error: $e');

      // The coordinates are already set as fallback, so no need to show error message
      // This prevents the "Unexpected null value" error from bothering the user
    }
  }

  // قراءة بيانات NFC
  Future<void> _readNFC() async {
    if (_isNfcReading) return; // Prevent multiple simultaneous reads

    try {
      setState(() {
        _isNfcReading = true;
      });

      // تحقق من دعم NFC في الجهاز
      NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This device does not support NFC'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Show waiting message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please hold your NFC card near the device...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // الانتظار لقراءة بطاقة NFC
      NFCTag tag = await FlutterNfcKit.poll();
      setState(() {
        _nfcCardData = tag.id; // تخزين بيانات البطاقة NFC
      });

      await FlutterNfcKit.finish(); // إنهاء عملية القراءة

      // Show success notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NFC card read successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'NFC reading failed';

        // Handle specific platform errors
        if (e.toString().contains('PlatformException')) {
          if (e.toString().contains('NotFoundError') &&
              e.toString().contains('claimInterface')) {
            errorMessage =
                'NFC interface error: Please ensure NFC is enabled and try again';
          } else if (e.toString().contains('USBDevice')) {
            errorMessage =
                'USB device error: Please check your NFC reader connection';
          } else if (e.toString().contains('timeout')) {
            errorMessage = 'NFC reading timed out: Please try again';
          } else if (e.toString().contains('cancelled')) {
            errorMessage = 'NFC reading was cancelled';
          } else {
            errorMessage =
                'NFC reading failed: ${e.toString().split(':').last.trim()}';
          }
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'NFC reading timed out: Please try again';
        } else if (e.toString().contains('UserCancelledException')) {
          errorMessage = 'NFC reading was cancelled';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _readNFC(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNfcReading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final subtotal = cartProvider.totalAmount;
        const deliveryFee = 2.99;
        final tax = subtotal * 0.09; // 9% tax
        final total = subtotal + deliveryFee + tax;

        return Scaffold(
          backgroundColor: kbackgroundcolor,
          appBar: AppBar(
            title: const Text(
              "Checkout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: kprimarycolor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // --- Address card (GPS integration) ---
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: kprimarycolor, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Delivery Address',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_address != null && _address!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            _address!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: const Text(
                            'No address selected',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLocating ? null : _getCurrentLocation,
                              icon: _isLocating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.my_location, size: 18),
                              label: Text(
                                _isLocating ? 'Locating...' : 'Current Location',
                                style: const TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kprimarycolor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final TextEditingController controller =
                                    TextEditingController();
                                if (!mounted) return;

                                final manual = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Enter Address Manually'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your address',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (value) =>
                                          Navigator.of(context).pop(value),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pop(controller.text),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                if (mounted &&
                                    manual != null &&
                                    manual.trim().isNotEmpty) {
                                  setState(() {
                                    _address = manual.trim();
                                  });

                                  // Show success notification
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Address updated successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.edit_location, size: 18),
                              label: const Text('Manual Entry', style: TextStyle(fontSize: 14)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kprimarycolor,
                                side: BorderSide(color: kprimarycolor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                   Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NFC Card',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hold your NFC card near the device to read',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_nfcCardData != null && _nfcCardData!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card ID: $_nfcCardData',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _nfcCardData = null;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('NFC data cleared'),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'No NFC card read',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isNfcReading ? null : _readNFC,
                          icon: _isNfcReading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.nfc),
                          label: Text(
                            _isNfcReading ? 'Reading...' : 'Read NFC Card',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

                // --- Cart Items Section ---
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, color: kprimarycolor, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Cart Items',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (cartProvider.items.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kprimarycolor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${cartProvider.totalQuantity}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (cartProvider.items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add some delicious items to get started!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...cartProvider.items.values.map(
                          (item) => _buildCartItem(cartProvider, item),
                        ),
                    ],
                  ),
                ),

                // --- Payment Summary ---
                if (cartProvider.items.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long, color: kprimarycolor, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Order Summary',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          'Subtotal',
                          '\$${subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Delivery Fee',
                          '\$${deliveryFee.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Tax (9%)', '\$${tax.toStringAsFixed(2)}'),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Total',
                          '\$${total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                // --- Checkout Button ---
                if (cartProvider.items.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle checkout logic here
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Order Confirmation'),
                            content: const Text('Your order has been placed successfully!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  cartProvider.clear();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kprimarycolor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Place Order (\$${total.toStringAsFixed(2)})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem(CartProvider cartProvider, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: kprimarycolor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => cartProvider.decreaseQuantity(item.id),
                  icon: const Icon(Icons.remove, size: 18),
                  color: Colors.red,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => cartProvider.increaseQuantity(item.id),
                  icon: const Icon(Icons.add, size: 18),
                  color: Colors.green,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Remove button
          IconButton(
            onPressed: () {
              cartProvider.removeItem(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} removed from cart'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildNfcSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nfc, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'NFC Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hold your NFC card near the device to read',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          if (_nfcCardData != null && _nfcCardData!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Card ID: $_nfcCardData',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _nfcCardData = null;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('NFC data cleared'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Text(
                'No NFC card detected',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: 60,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _isNfcReading ? null : _readNFC,
              icon: _isNfcReading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.nfc, size: 18),
              label: Text(
                _isNfcReading ? 'Reading...' : 'Read NFC Card',
                style: const TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
            color: isTotal ? kprimarycolor : Colors.black,
          ),
        ),
      ],
    );
  }
}
