import 'package:e_agritech_app/models/problem_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProblemDetailScreen extends StatelessWidget {
  final ProblemModel problem;

  const ProblemDetailScreen({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit functionality
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => EditProblemScreen(problem: problem)),
              // );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildDetailSection('Assistance Type', problem.assistanceType),
            const SizedBox(height: 16),
            _buildDetailSection('Description', problem.description),
            const SizedBox(height: 16),
            _buildDetailSection('Category', problem.categoryTag),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 24),
            if (problem.imageUrl != null) _buildImageSection(),
            if (problem.imageUrl != null) const SizedBox(height: 24),
            if (problem.audioUrl != null) _buildAudioSection(),
            const SizedBox(height: 24),
            _buildTimestampSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              problem.status == 'completed'
                  ? Icons.check_circle
                  : Icons.pending,
              color:
                  problem.status == 'completed' ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    problem.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final url =
                'https://www.google.com/maps/search/?api=1&query=${problem.location}';
            // if (await canLaunch(url)) {
            //   await launch(url);
            // }
          },
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  problem.location,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attached Image',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            problem.imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Text('Failed to load image'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice Recording',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.audiotrack),
            title: const Text('Play recording'),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () async {
                // if (await canLaunch(problem.audioUrl!)) {
                //   await launch(problem.audioUrl!);
                // }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampSection() {
    final formattedDate =
        DateFormat('MMM dd, yyyy - hh:mm a').format(problem.timestamp.toDate());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submitted on',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
