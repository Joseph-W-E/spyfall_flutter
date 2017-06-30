import 'package:spyfall/location/location.dart';
import 'package:test/test.dart';

void main() {
  group('LocationInputFormat', () {
    LocationInputFormat inputFormat;
    String location = "Ames";
    String singleRole = "*Timmy";
    String multiRole = "**Developer";

    setUp(() {
      RegExp locationPattern = new RegExp(r"[A-z]");
      RegExp singleRolePattern = new RegExp(r"\*[A-z]");
      String multiRolePattern = "**";
      inputFormat = new LocationInputFormat(
          locationPattern, singleRolePattern, multiRolePattern);
    });

    test('locations', () {
      expect(inputFormat.isLocation(location), isTrue);
      expect(inputFormat.isSingleRole(location), isFalse);
      expect(inputFormat.isMultiRole(location), isFalse);
    });

    test('single roles', () {
      expect(inputFormat.isLocation(singleRole), isFalse);
      expect(inputFormat.isSingleRole(singleRole), isTrue);
      expect(inputFormat.isMultiRole(singleRole), isFalse);
    });

    test('multi roles', () {
      expect(inputFormat.isLocation(multiRole), isFalse);
      expect(inputFormat.isSingleRole(multiRole), isFalse);
      expect(inputFormat.isMultiRole(multiRole), isTrue);
    });
  });

  group('Location', () {
    var lineLocation;
    var lineSingleRoles;
    var lineMultiRoles;
    Location location;

    setUp(() {
      lineLocation = "Ames";
      lineSingleRoles = ["Timmy", "Suzy"];
      lineMultiRoles = ["Developer", "Programmer"];
      location = new Location();

      location.location = lineLocation;
      lineSingleRoles.forEach(location.addSingleRole);
      lineMultiRoles.forEach(location.addMultiRole);
    });

    test('location', () {
      expect(location.location, equals(lineLocation));

      for (int i = 0; i < lineSingleRoles.length; i++) {
        expect(lineSingleRoles.contains(location.singleRole), isTrue);
      }

      // Multiply length by 2 to demonstrate refreshing
      for (int i = 0; i < lineMultiRoles.length * 2; i++) {
        expect(lineMultiRoles.contains(location.multiRole), isTrue);
      }
    });

    test('toString', () {
      expect(location.toString().contains(lineLocation), isTrue);

      for (String singleRole in lineSingleRoles) {
        expect(location.toString().contains(singleRole), isTrue);
      }

      for (String multiRole in lineMultiRoles) {
        expect(location.toString().contains(multiRole), isTrue);
      }
    });
  });

  group('LocationManager', () {
    // TODO(joey) parse assets doesn't work in unit testing?
  });
}