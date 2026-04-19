import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Queue', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.mrfBlack,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.mrfBlack,
              indicatorColor: AppColors.mrfBlack,
              tabs: [Tab(text: 'Pending'), Tab(text: 'In Progress'), Tab(text: 'Completed')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                   _buildQueueList(true),
                   _buildQueueList(false),
                   _buildQueueList(false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQueueList(bool isActionable) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      Text('Booking #BK-${900+index}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mrfRed)),
                      const Text('Today, 2:00 PM', style: TextStyle(color: Colors.grey, fontSize: 12)),
                   ],
                 ),
                 const Divider(),
                 const Text('Customer: Rahul Kumar (+91 9876543210)', style: TextStyle(fontWeight: FontWeight.w600)),
                 const SizedBox(height: 4),
                 const Text('Vehicle: Tata Ace (MH 14 AB 1122)'),
                 const SizedBox(height: 4),
                 const Text('Service: Retreading (2 Tyres)'),
                 if (isActionable) ...[
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Reschedule'))),
                       const SizedBox(width: 16),
                       Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfBlack), onPressed: () {}, child: const Text('Start Work'))),
                     ],
                   )
                 ]
              ],
            ),
          ),
        );
      },
    );
  }
}
