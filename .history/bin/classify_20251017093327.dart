import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const _kExtensions = ['png', 'jpg', 'svg', 'pdf'];

void main(List<String> arguments) {
  final parser = ArgParser();
  var inputDirectory = Directory.current;
  var outputDirectory = Directory.current;
  parser.addOption(
    'input',
    abbr: 'i',
    help: 'The path with the image.',
  );
  parser.addOption(
    'output',
    abbr: 'o',
    help: 'The path where the image will be saved.',
  );
  parser.addOption('separator',
      abbr: 's',
      help: 'Distinguisher for image magnification.',
      valueHelp: '@',
      defaultsTo: '@');
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'help',
    negatable: false,
  );

  final results = parser.parse(arguments);

  if (results.wasParsed('help')) {
    print(parser.usage);
    exit(0);
  }
  if (results.wasParsed('input')) {
    final path = results['input'] as String?;

    if (path != null) {
      final uri = Uri.directory(path, windows: Platform.isWindows);
      inputDirectory = Directory.fromUri(uri);
    }
  }

  if (!results.options.contains('output')) {
    outputDirectory = inputDirectory;
  }

  if (results.wasParsed('output')) {
    final path = results['output'] as String?;

    if (path != null) {
      final uri = Uri.directory(path, windows: Platform.isWindows);
      outputDirectory = Directory.fromUri(uri)..createSync(recursive: true);
    }
  }

  var listSync = inputDirectory.listSync(recursive: true);

  var list = listSync
      .where((element) => _kExtensions.contains(element.path.split('.').last));
  final ratios = <String, List<FileSystemEntity>>{};
  final regex = RegExp('(${results['separator']})(.*?)(x)');

  for (final dir in list) {
    final fileName = path.split(dir.path).last;
    final split = regex.allMatches(fileName);

    var ratio = '';

    for (final element in split) {
      ratio = '${element.group(2)}${element.group(3)}';
    }
    if (fileName.contains('${results['separator']}')) {
      ratios.update(
        ratio,
        (value) => value..add(dir),
        ifAbsent: () => [dir],
      );
    } else {
      ratios.update(
        '1x',
        (value) => value..add(dir),
        ifAbsent: () => [dir],
      );
    }
  }

  final outputDirs = <String>{};

  for (final ratio in ratios.entries) {
    if (ratio.key == '1x') {
      for (final dir in ratio.value) {
        final basNameWithExtension = path.basename(dir.path);
        final outputRegex =
            RegExp('(${inputDirectory.path.replaceAll(r'\', r'\\')})(.*?)($basNameWithExtension)');
        var allMatches = outputRegex.allMatches(dir.path);

        var restPath = '';
        for (var element in allMatches) {
          restPath = element.group(2)??'';
        }
        var directory =
            Directory('${outputDirectory.path}$restPath')..createSync(recursive: true);
        outputDirs.add(path.normalize(directory.path).replaceAll(r'\', '/'));
        File(dir.path)
            .copySync(path.joinAll([directory.path, basNameWithExtension]));
      }
    } else {
      for (final dir in ratio.value) {
        final basNameWithExtension = path.basename(dir.path);
        final outputRegex =
        RegExp('(${inputDirectory.path.replaceAll(r'\', r'\\')})(.*?)($basNameWithExtension)');
        var allMatches = outputRegex.allMatches(dir.path);
        var restPath = '';
        for (var element in allMatches) {
          restPath = element.group(2)??'';
        }
        var directory =
        Directory('${outputDirectory.path}$restPath${ratio.key}')..createSync(recursive: true);
        var replaceName = basNameWithExtension.replaceAll(regex, '');
        File(dir.path).copySync(path.joinAll([directory.path, replaceName]));
      }
    }
  }

  for (final outputDir in outputDirs.toList()..sort()) {
    print(outputDir);
  }
}