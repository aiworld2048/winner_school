import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';

/// A reusable error state widget with retry functionality
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;

  /// Extracts a user-friendly error message from various error types
  static String extractErrorMessage(dynamic error) {
    // Handle ApiException directly
    if (error is ApiException) {
      return error.message;
    }

    final errorString = error.toString();
    
    if (errorString.contains('TimeoutException') || 
        errorString.contains('timed out')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (errorString.contains('403') || 
               errorString.contains('Forbidden') ||
               errorString.contains('not assigned to a teacher')) {
      return 'You do not have permission to access this resource.';
    } else if (errorString.contains('401') || 
               errorString.contains('Unauthorized')) {
      return 'Please log in again.';
    } else if (errorString.contains('402')) {
      return 'Insufficient balance.';
    } else if (errorString.contains('Failed to fetch') || 
               errorString.contains('Network error')) {
      return 'Network error. Please check your connection.';
    } else if (errorString.contains('ApiException')) {
      // Extract the actual message from ApiException
      // Format: ApiException(403): You are not assigned to a teacher yet.
      final match = RegExp(r'ApiException\(\d+\):\s*(.+)').firstMatch(errorString);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
      // Try alternative pattern
      final altMatch = RegExp(r':\s*(.+?)(?:\n|$)').firstMatch(errorString);
      if (altMatch != null && altMatch.group(1) != null) {
        return altMatch.group(1)!.trim();
      }
    }
    
    // Return generic message or truncated error
    if (errorString.length > 100) {
      return '${errorString.substring(0, 100)}...';
    }
    return errorString.isNotEmpty ? errorString : 'An unexpected error occurred.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

