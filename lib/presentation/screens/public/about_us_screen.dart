import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class CompanyAboutUsScreen extends StatelessWidget {
  const CompanyAboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              color: AppColors.mrfRed,
              child: const Column(
                children: [
                  Text(
                    'About Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Trusted name in tyre retreading for over 6 years',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Mission and Vision
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Text('Our Mission', style: TextStyle(fontSize: 20, color: AppColors.mrfRed, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text(
                              'To provide high-quality retreaded tyres that extend the life of your tyres and save you money while maintaining the highest standards of safety and reliability.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Text('Our Vision', style: TextStyle(fontSize: 20, color: AppColors.mrfRed, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text(
                              'To be the leading tyre retreading service provider in Pune District, known for our quality, reliability, and customer satisfaction.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Company Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Jagadale Retreads has been a trusted name in the tyre retreading industry for over 6 years, offering durable and cost-effective solutions for commercial vehicles across Pune District. We are committed to providing high-quality retreaded tyres that extend the life of your tyres and save you money.\n\nOur expert retreading team works tirelessly to ensure that our customers receive the best possible results. We have extensive experience in handling various retreading techniques. Our team is also trained to provide personalized advice and recommendations based on your specific vehicle needs.\n\nJagadale Retreads is a MRF Authorised Pre-treaders Near You, which means that our retreading services are genuinely guaranteed to be safe, efficient, and effective. We are committed to providing our customers with a smooth and enjoyable experience while retreading their tyres.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset('assets/images/Screenshot 2024-06-27 142313.webp'),
            ),

            // Process Timeline
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'What we do exactly?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.mrfRed),
              ),
            ),
            _buildProcessStep(
              '1. Initial Inspection',
              'assets/images/Initial Inspection.jpg',
              'Objective: Evaluate the suitability of the tyre casing for remolding.\nInspection:\n- Damage Assessment: Identify any cuts, punctures, or structural weaknesses.\n- Compliance with Standards: Verify that the casing adheres to safety and quality requirements.',
            ),
            _buildProcessStep(
              '2. Buffing',
              'assets/images/Buffing.jpeg',
              'Objective: Remove the worn-out tread.\nProcess: The tyre is mounted on a buffing machine, which scrapes off the old tread to prepare the surface for the new one.\nBenefits: This process ensures the surface is clean and even, providing a suitable base for the new tread.',
            ),
            _buildProcessStep(
              '3. Casing Repair',
              'assets/images/Casing Repair.jpg',
              'Objective: Repair minor defects in the casing.\nRepairs: Small punctures or damages are repaired using patches or fillers. The structural integrity of the tyre casing is ensured after repairs.',
            ),
            _buildProcessStep(
              '4. Applying Bonding Agent',
              'assets/images/Applying Bonding Agent .jpg',
              'Objective: Establish a robust bond between the existing casing and the new tread.\nProcedure: A layer of rubber cement or bonding adhesive is applied to the polished surface of the casing.',
            ),
            _buildProcessStep(
              '5. Tread Application',
              'assets/images/Tread Application.jpg',
              'Objective: Attach the newly manufactured tread material to the tyre casing.\nPreparations: Pre-cured tread designs (ready-made tread patterns) or raw rubber strips are meticulously wrapped around the tyre. In the instance of raw rubber, the tread pattern is established during the curing process.',
            ),
            _buildProcessStep(
              '6. Enveloping and Mounting',
              'assets/images/Enveloping and Mounting.jpg',
              'Objective: Prepare the tyre for curing.\nProcedure: The tyre is enclosed in an airtight envelope or fitted with a rubber sleeve to ensure the formation of a secure bond between the new tread and the rubber during curing.',
            ),
            _buildProcessStep(
              '7. Vulcanization (Curing)',
              'assets/images/Vulcanization .jpg',
              'Objective: Permanently adhere the newly installed tread to the casing.\nProcedure: The tyre is placed within a curing chamber or autoclave, which is subjected to controlled temperatures, pressures, and durations.\nProcess: Vulcanization strengthens the rubber and ensures the secure attachment of the new tread.',
            ),
            _buildProcessStep(
              '8. Final Inspection',
              'assets/images/Final Inspection.jpg',
              'Objective: Ensure the remolded tyre conforms to established quality standards.\nVisual Inspection and Specialized Testing: The tyre undergoes a comprehensive visual inspection, complemented by specialized equipment, to assess its proper bonding, alignment, and uniformity.\nPressure Testing: Pressure testing is conducted to identify any air leaks or structural anomalies.',
            ),
            _buildProcessStep(
              '9. Finishing',
              'assets/images/Finishing.jpg',
              'Objective: Smooth and refine the remolded tyre.\nProcedure: Excess rubber or imperfections are trimmed, and the tyre is cleaned and polished to achieve a polished and finished appearance.',
            ),
            _buildProcessStep(
              '10. Quality Certification and Distribution',
              'assets/images/Distribution.jpeg',
              'Objective: Certify remolded tyres for use.\nProcedure: Each tyre is labeled with pertinent information, including specifications and certifications. The tyres are packaged and dispatched to customers or retailers.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep(String title, String imagePath, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(imagePath, height: 200, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(height: 200, child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
