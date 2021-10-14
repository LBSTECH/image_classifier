import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const _kExtensions = ['png', 'jpg', 'svg', 'pdf'];

void main(List<String> arguments) async {
  var parser = ArgParser();
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
    inputDirectory = await Directory(results['input']).create();
  }

  if (!results.options.contains('output')) {
    outputDirectory = inputDirectory;
  }
  if (results.wasParsed('output')) {
    outputDirectory = await Directory(results['output']).create();
  }

  var listSync = inputDirectory.listSync(recursive: true);

  var list = listSync
      .where((element) => _kExtensions.contains(element.path.split('.').last));
  final ratios = <String, List<FileSystemEntity>>{};
  final regex = RegExp('(${results['separator']})(.*?)(x)');

  for (final dir in list) {
    final fileName = dir.path.split('/').last;
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

  for (final ratio in ratios.entries) {
    if (ratio.key == '1x') {
      for (final dir in ratio.value) {
        final basNameWithExtension = path.basename(dir.path);
        final outputRegex =
            RegExp('(${results['input']})(.*?)($basNameWithExtension)');
        var allMatches = outputRegex.allMatches(dir.path);
        var restPath = '';
        for (var element in allMatches) {
          restPath = element.group(2)??'';
        }
        var directory =
            await Directory('${outputDirectory.path}$restPath').create(recursive: true);
        print(directory.path.replaceAll('\\', '/'));
        File(dir.path)
            .copySync('${directory.path}/$basNameWithExtension');
      }
    } else {
      for (final dir in ratio.value) {
        final basNameWithExtension = path.basename(dir.path);
        final outputRegex =
        RegExp('(${results['input']})(.*?)($basNameWithExtension)');
        var allMatches = outputRegex.allMatches(dir.path);
        var restPath = '';
        for (var element in allMatches) {
          restPath = element.group(2)??'';
        }
        var directory =
        await Directory('${outputDirectory.path}$restPath${ratio.key}').create(recursive: true);
        var replaceName = basNameWithExtension.replaceAll(regex, '');
        File(dir.path).copySync('${directory.path}/$replaceName');
      }
    }
  }
}