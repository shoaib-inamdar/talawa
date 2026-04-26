import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talawa/services/hive_manager.dart';
import 'package:talawa/view_model/connectivity_view_model.dart';

/// A tolerant comparator to ignore sub-pixel anti-aliasing differences
/// between local macOS generation and Ubuntu GitHub Actions.
class TolerantComparator extends LocalFileComparator {
  TolerantComparator(super.testFile, {this.tolerance = 0.005});

  /// Tolerated percentage of differently rendered pixels (0 to 1).
  /// 0.005 equals a 0.5% tolerance (safely covers font anti-aliasing).
  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= tolerance) {
      debugPrint(
        'A tolerable difference of ${(result.diffPercent * 100).toStringAsFixed(3)}% '
        'was found when comparing $golden.',
      );
      return true;
    }

    if (!result.passed) {
      final String error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return true;
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetController.hitTestWarningShouldBeFatal = true;

  if (goldenFileComparator is LocalFileComparator) {
    final Uri testUrl = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = TolerantComparator(
      Uri.parse('$testUrl/test.dart'),
      tolerance: 0.005,
    );
  }

  final Directory dir = await Directory.systemTemp.createTemp('talawa_test');
  // Hive.init(dir.path);
  await HiveManager.initializeHive(dir: dir);
  AppConnectivity.isOnline = true;
  // await setUpHive();
  await testMain();
}
