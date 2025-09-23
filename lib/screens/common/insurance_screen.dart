import 'package:flutter/material.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      {"title": "Basic Plan", "price": "₹1,200/year", "coverage": "Covers minor repairs"},
      {"title": "Standard Plan", "price": "₹2,500/year", "coverage": "Covers major repairs & towing"},
      {"title": "Premium Plan", "price": "₹5,000/year", "coverage": "Full coverage + roadside assistance"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Insurance Plans"),
        backgroundColor: Colors. blue[100],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan["title"]!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(plan["coverage"]!, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 10),
                  Text(plan["price"]!, style: const TextStyle(fontSize: 18, color: Colors.green)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("You selected ${plan["title"]}")),
                      );
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text("Choose Plan"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
