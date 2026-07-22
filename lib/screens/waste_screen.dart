import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_app/screens/collector_screen.dart';
import 'package:suchigo_app/screens/login_screen.dart';
import 'package:suchigo_app/models/order_model.dart';
import 'package:suchigo_app/providers/profile_provider.dart';
import 'package:suchigo_app/services/bill_api_service.dart';

class WasteScreen extends StatefulWidget {
  final OrderModel orderData;
  const WasteScreen({super.key, required this.orderData});

  @override
  State<WasteScreen> createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen> {
  String selectedBag = "Select Bag";
  Map<String, int> bagCounts = {
    "SMALL": 0,
    "MEDIUM": 0,
    "X SMALL": 0,
    "NO BAG": 0,
    "TVM BAG": 0,
  };

  String wasteType = "";
  bool isResidential = true;
  String qty = "";

  bool isCash = true;
  TextEditingController partialCash = TextEditingController();

  final List<String> wasteButtons = [
    "SANITARY PAD",
    "MEDICAL WASTE",
    "ADULT DIAPER",
    "KIDS DIAPER",
    "HAIR",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Waste Type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // BAG DROPDOWN
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: GestureDetector(
                onTap: () => openBagPopup(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedBag, style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // BAG DETAILS
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.shade100,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Bag size",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "QTY",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "PRICE",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (bagCounts[selectedBag] != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedBag),
                        Text(bagCounts[selectedBag].toString()),
                        const Text("7.00"),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // RESIDENTIAL / COMMERCIAL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.shade100,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Radio(
                        value: true,
                        groupValue: isResidential,
                        onChanged: (v) => setState(() => isResidential = true),
                      ),
                      const Text("Residential"),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: false,
                        groupValue: isResidential,
                        onChanged: (v) => setState(() => isResidential = false),
                      ),
                      const Text("Commercial"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // WASTE TYPE
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Waste Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: wasteButtons.map((w) {
                      return GestureDetector(
                        onTap: () => setState(() => wasteType = w),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: wasteType == w
                                ? Color(0xFF4CAF50)
                                : const Color.fromARGB(255, 154, 190, 230),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            w,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QUANTITY
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter QTY",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => qty = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (qty.isNotEmpty) openPaymentPopup(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "UPDATE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BAG POPUP
  void openBagPopup(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bagTile("SMALL", 7.00),
              bagTile("MEDIUM", 10.00),
              bagTile("X SMALL", 5.00),
              bagTile("NO BAG", 0.00),
              bagTile("TVM BAG", 7.00),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  child: Text("Back", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // BAG TILE
  Widget bagTile(String name, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(price.toStringAsFixed(2)),
          ElevatedButton(
            onPressed: () {
              setState(() {
                bagCounts[name] = bagCounts[name]! + 1;
                selectedBag = name;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("ADD", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // PAYMENT POPUP
  void openPaymentPopup(BuildContext context) {
    bool isSubmitting = false;
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Payment Mode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: isCash,
                          onChanged: isSubmitting ? null : (v) => setStatePopup(() => isCash = true),
                        ),
                        const Text("Cash"),
                        const SizedBox(width: 30),
                        Radio(
                          value: false,
                          groupValue: isCash,
                          onChanged: isSubmitting ? null : (v) => setStatePopup(() => isCash = false),
                        ),
                        const Text("Online"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // QR CODE WHEN ONLINE
                    if (!isCash)
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/Qrcodes.png",
                              height: 220,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "SCAN & PAY USING ANY UPI APP",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: isSubmitting ? null : () => Navigator.pop(sheetContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setStatePopup(() {
                                    isSubmitting = true;
                                  });

                                  try {
                                    final parsedQty = double.tryParse(qty) ?? 0.0;
                                    final weight = parsedQty > 0 ? parsedQty : 1.0;
                                    final rate = selectedBag == "SMALL"
                                        ? 7.0
                                        : selectedBag == "MEDIUM"
                                            ? 10.0
                                            : selectedBag == "X SMALL"
                                                ? 5.0
                                                : selectedBag == "TVM BAG"
                                                    ? 7.0
                                                    : 10.0;
                                    final totalAmount = weight * rate;

                                    await BillApiService.createBill(
                                      pickupId: widget.orderData.id,
                                      weight: weight,
                                      rate: rate,
                                      totalAmount: totalAmount,
                                      paymentMethod: isCash ? "cash" : "online",
                                      paymentStatus: "paid",
                                      wasteType: wasteType.isNotEmpty
                                          ? wasteType
                                          : widget.orderData.itemsDescription,
                                      collectorName: context.read<ProfileProvider>().username,
                                      wardName: widget.orderData.ward,
                                      localBody: widget.orderData.localBody,
                                    );

                                    if (context.mounted) {
                                      Navigator.of(sheetContext).pop(); // Close bottom sheet
                                      Future.delayed(
                                        const Duration(milliseconds: 80),
                                        () {
                                          if (context.mounted) {
                                            showSuccessPopup(context);
                                          }
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      setStatePopup(() {
                                        isSubmitting = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to submit collection: $e'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Complete",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Payment Successful"),
        content: const Text("The transaction has been completed successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                dialogContext,
                rootNavigator: true,
              ).pop(); // close popup

              Future.delayed(const Duration(milliseconds: 50), () {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CollectorScreen()),
                  );
                }
              });
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
