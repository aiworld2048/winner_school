import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerWidget extends StatelessWidget {
  const PdfViewerWidget({
    super.key,
    required this.pdfUrl,
    this.title = 'PDF Document',
    this.height = 600,
  });

  final String pdfUrl;
  final String title;
  final double height;

  Future<void> _downloadPdf(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red[600], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadPdf(context, pdfUrl),
                tooltip: 'Download PDF',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SfPdfViewer.network(
                pdfUrl,
                onDocumentLoadFailed: (details) {
                  debugPrint('PDF load failed: ${details.error}');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load PDF: ${details.error}'),
                        action: SnackBarAction(
                          label: 'Open in Browser',
                          onPressed: () => _downloadPdf(context, pdfUrl),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

