import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/input_filters.dart';

void main() {
  test(
    'a device that filters itself always processes, whatever was chosen',
    () {
      expect(processingOn(byDevice: true, chosen: false), isTrue);
      expect(processingOn(byDevice: true, chosen: true), isTrue);
      expect(processingOn(byDevice: false, chosen: false), isFalse);
      expect(processingOn(byDevice: false, chosen: true), isTrue);
    },
  );

  test('stereo needs a stereo channel, no processing and stereo recording', () {
    expect(
      stereoMicrophone(
        channelStereo: true,
        processing: false,
        recordsStereo: true,
      ),
      isTrue,
    );
    expect(
      stereoMicrophone(
        channelStereo: true,
        processing: true,
        recordsStereo: true,
      ),
      isFalse,
    );
    expect(
      stereoMicrophone(
        channelStereo: false,
        processing: false,
        recordsStereo: true,
      ),
      isFalse,
    );
    expect(
      stereoMicrophone(
        channelStereo: true,
        processing: false,
        recordsStereo: false,
      ),
      isFalse,
    );
  });

  test(
    'a Mac stays mono in a stereo channel even with processing turned off',
    () {
      final processing = processingOn(byDevice: true, chosen: false);
      expect(
        stereoMicrophone(
          channelStereo: true,
          processing: processing,
          recordsStereo: false,
        ),
        isFalse,
      );
    },
  );
}
