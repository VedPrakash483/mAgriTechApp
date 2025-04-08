import 'package:e_agritech_app/models/problem_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'dart:convert';


const String GEMINI_API_KEY = 'AIzaSyC8OFeKJfpquaP2i8X56Ulpv1eXvPgYI2Y';

class LanguageData {
  final String code;
  final String name;
  final String nativeName;

  const LanguageData(this.code, this.name, this.nativeName);
}

class AppConstants {
  static const List<LanguageData> indianLanguages = [
    LanguageData('hi', 'Hindi', 'हिन्दी'),
    LanguageData('bn', 'Bengali', 'বাংলা'),
    LanguageData('te', 'Telugu', 'తెలుగు'),
    LanguageData('ta', 'Tamil', 'தமிழ்'),
    LanguageData('mr', 'Marathi', 'मराठी'),
    LanguageData('gu', 'Gujarati', 'ગુજરાતી'),
    LanguageData('kn', 'Kannada', 'ಕನ್ನಡ'),
    LanguageData('ml', 'Malayalam', 'മലയാളം'),
    LanguageData('pa', 'Punjabi', 'ਪੰਜਾਬੀ'),
    LanguageData('ur', 'Urdu', 'اردو'),
  ];
}

class AnalysisHistoryItem {
  final String timestamp;
  final String originalText;
  final String translatedText;
  final String languageCode;
  final String languageName;

  AnalysisHistoryItem({
    required this.timestamp,
    required this.originalText,
    required this.translatedText,
    required this.languageCode,
    required this.languageName,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'originalText': originalText,
        'translatedText': translatedText,
        'languageCode': languageCode,
        'languageName': languageName,
      };

  factory AnalysisHistoryItem.fromJson(Map<String, dynamic> json) =>
      AnalysisHistoryItem(
        timestamp: json['timestamp'],
        originalText: json['originalText'],
        translatedText: json['translatedText'],
        languageCode: json['languageCode'],
        languageName: json['languageName'],
      );
}

class ProblemDetailScreen extends StatefulWidget {
  final ProblemModel problem;

  const ProblemDetailScreen({super.key, required this.problem});

  @override
  State<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen> {
  String _analysisResult = '';
  String _translatedText = '';
  bool _isLoading = false;
  bool _isAnalysisExpanded = false;
  final FlutterTts _flutterTts = FlutterTts();
  final translator = GoogleTranslator();
  List<AnalysisHistoryItem> _history = [];
  late final GenerativeModel model;
  LanguageData _selectedLanguage = AppConstants.indianLanguages[0]; // Default to Hindi
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _initializeTTS();
  }

  Future<void> _initializeApp() async {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: GEMINI_API_KEY,
    );
    await _loadHistory();
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage(_selectedLanguage.code);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('analysis_history');
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        setState(() {
          _history = decoded
              .map((item) => AnalysisHistoryItem.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      _showSnackBar('Error loading history: ${e.toString()}');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_history.map((e) => e.toJson()).toList());
      await prefs.setString('analysis_history', historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
      _showSnackBar('Error saving history: ${e.toString()}');
    }
  }

  Future<void> _translateText(String text) async {
    try {
      final translation = await translator.translate(
        text,
        to: _selectedLanguage.code,
      );
      setState(() {
        _translatedText = translation.text;
      });
    } catch (e) {
      _showSnackBar('Translation error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

 Future<void> _analyzeImage() async {
  if (widget.problem.imageUrl == null) {
    _showSnackBar('No image available to analyze');
    return;
  }

  setState(() {
    _isLoading = true;
    _analysisResult = '';
    _translatedText = '';
  });

  try {
    // Create a GenerativeModel with vision capabilities
    final visionModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: GEMINI_API_KEY,
    );

    // For now, let's use a text-only approach since we're having issues with the image API
    // We'll include the image URL in the prompt
    final prompt = 'Analyze this plant issue. Description: ${widget.problem.description}\n' +
                  'The plant image is available at: ${widget.problem.imageUrl}\n' +
                  'Please provide a detailed analysis of what might be happening to this plant based on the description.';
    
    // Generate content with text only
    final response = await visionModel.generateContent([
      Content.text(prompt),
    ]);

    // Clean up the response
    final result = response.text?.replaceAll(RegExp(r'\n\s*\n'), '\n')
                                .replaceAll(RegExp(r'\s+'), ' ')
                                .trim() ?? 'No response generated';

    setState(() {
      _analysisResult = result;
      _isAnalysisExpanded = true;
    });

    await _translateText(result);

    final historyItem = AnalysisHistoryItem(
      timestamp: DateTime.now().toIso8601String(),
      originalText: _analysisResult,
      translatedText: _translatedText,
      languageCode: _selectedLanguage.code,
      languageName: _selectedLanguage.name,
    );

    // Save history item
    _history.add(historyItem);
    await _saveHistory();
  } catch (e) {
    setState(() {
      _analysisResult = 'Error: ${e.toString()}';
    });
    _showSnackBar('Analysis error: ${e.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  Future<void> _speakTranslation() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    } else {
      await _flutterTts.speak(_translatedText);
    }
    setState(() {
      _isSpeaking = !_isSpeaking;
    });
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.indianLanguages.length,
                  itemBuilder: (context, index) {
                    final language = AppConstants.indianLanguages[index];
                    return ListTile(
                      title: Text('${language.name} (${language.nativeName})'),
                      selected: language.code == _selectedLanguage.code,
                      onTap: () async {
                        setState(() {
                          _selectedLanguage = language;
                        });
                        await _initializeTTS();
                        if (_analysisResult.isNotEmpty) {
                          await _translateText(_analysisResult);
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Analysis History'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Card(
                  child: ListTile(
                    title:
                        Text('Analysis from ${item.timestamp.split('T')[0]}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Original: ${item.originalText}'),
                        Text(
                            'Translation (${item.languageName}): ${item.translatedText}'),
                      ],
                    ),
                    onTap: () {
                      _flutterTts.speak(item.translatedText);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistoryDialog,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Uncomment to navigate to edit screen
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => EditProblemScreen(problem: widget.problem)),
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
            Row(
              children: [
                Text(
                  'Selected Language: ${_selectedLanguage.name} (${_selectedLanguage.nativeName})',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailSection('Assistance Type', widget.problem.assistanceType),
            const SizedBox(height: 16),
            _buildDetailSection('Description', widget.problem.description),
            const SizedBox(height: 16),
            _buildDetailSection('Category', widget.problem.categoryTag),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 24),
            if (widget.problem.imageUrl != null) _buildImageSection(),
            if (widget.problem.imageUrl != null) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _analyzeImage,
                    icon: const Icon(Icons.analytics),
                    label: Text(_isLoading ? 'Analyzing...' : 'Analyze Plant'),
                  ),
                ),
              ),
            if (_isLoading) 
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_analysisResult.isNotEmpty) _buildAnalysisSection(),
            const SizedBox(height: 24),
            if (widget.problem.audioUrl != null) _buildAudioSection(),
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
              widget.problem.status == 'completed'
                  ? Icons.check_circle
                  : Icons.pending,
              color:
                  widget.problem.status == 'completed' ? Colors.green : Colors.orange,
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
                    widget.problem.status.toUpperCase(),
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
            // final url =
            //     'https://www.google.com/maps/search/?api=1&query=${widget.problem.location}';
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
                  // problem.location,
                  "location",
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
            widget.problem.imageUrl!,
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

  Widget _buildAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        ExpansionTile(
          initiallyExpanded: _isAnalysisExpanded,
          title: const Text(
            'AI Plant Analysis',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'English Summary:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _analysisResult,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (_translatedText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Translated (${_selectedLanguage.name}):',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translatedText,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _speakTranslation,
                        icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                        label: Text(_isSpeaking ? 'Stop' : 'Speak Translation'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 32),
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
                // if (await canLaunch(widget.problem.audioUrl!)) {
                //   await launch(widget.problem.audioUrl!);
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
        DateFormat('MMM dd, yyyy - hh:mm a').format(widget.problem.timestamp.toDate());

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

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}