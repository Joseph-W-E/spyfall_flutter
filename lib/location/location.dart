import 'dart:convert';
import 'dart:io';
import 'package:spyfall/utils/data_structures.dart';

/// Handles scanning files to find (and supply) [Location] objects from files.
class LocationManager {
  /// Locations extracted from the file.
  RefreshableSet _locations = new RefreshableSet(true);

  /// How we determine what lines in a file belong to what.
  LocationInputFormat locationInputFormat;

  LocationManager(this.locationInputFormat);

  /// Returns a location that hasn't been chosen by this user
  /// in (at least) X amount of rounds.
  Location get location => _locations.take;

  /// The file reader is looking for:
  ///   location names
  ///   roles that only one player can have
  ///   roles that any number of players can have
  /// Locations found are stored in [_locations].
  ///
  /// @param fileName - the file to be parsed
  void parseFile({String fileName: 'package:spyfall/res/locations.txt'}) {
    new File(fileName)
        .openRead()
        .transform(UTF8.decoder)
        .transform(new LineSplitter())
        .listen(_handleParseFileLineFound,
            onDone: _handleParseFileDone, onError: _handleParseFileError);
  }

  /// A hacky way of constructing [Location] objects.
  /// This variable is only use for that purpose.
  Location _locationToBuild;

  /// When a line is read from a file, determine how to add it to a location.
  void _handleParseFileLineFound(String line) {
    if (locationInputFormat._isPotentiallyValidInput(line)) {
      if (_locationToBuild == null)
        _locationToBuild = new Location();
      _locationToBuild.addLineType(locationInputFormat.getLineType(line), line);
    } else {
      if (_locationToBuild != null) {
        _locations.add(_locationToBuild);
        _locationToBuild = null;
      }
    }
  }

  void _handleParseFileDone() {}

  void _handleParseFileError() {}
}

/// Handles all information for a single location.
class Location {
  /// The location the players are at.
  String _location;

  /// The set of roles that only one play can have.
  RefreshableSet _singleRoles = new RefreshableSet(false);

  /// The set of roles that any number of players can have.
  RefreshableSet _multiRoles = new RefreshableSet(true);

  Location();

  String get location => _location;
  String get singleRole => _singleRoles.take;
  String get multiRole => _multiRoles.take;

  bool addLineType(LocationLineType type, String line) {
    switch (type) {
      case LocationLineType.LOCATION:
        _location = line;
        break;
      case LocationLineType.SINGLE_ROLE:
        return addSingleRole(line);
      case LocationLineType.MULTI_ROLE:
        return addMultiRole(line);
      case LocationLineType.NONE:
        return false;
    }
    return true;
  }

  /// Adds a found singleRole to the set of known singleRoles.
  ///
  /// Returns true if successfully added the role, false otherwise.
  bool addSingleRole(String role) {
    return _singleRoles.add(role);
  }

  /// Adds a found multiRole to the set of known multiRoles.
  ///
  /// Returns true if successfully added the role, false otherwise.
  bool addMultiRole(String role) {
    return _multiRoles.add(role);
  }

  /// Returns a [String] representation of all known roles for the location.
  String toString() {
    var buffer = new StringBuffer();

    buffer.writeln("Location: $_location");

    buffer.writeln("Single Roles:");
    for (String role in _singleRoles.all) {
      buffer.writeln(role);
    }

    buffer.writeln("Multie Roles:");
    for (String role in _multiRoles.all) {
      buffer.writeln(role);
    }

    return buffer.toString();
  }
}

/// Determines if a given line from an input file is one of:
///   location
///   single role
///   multi role
class LocationInputFormat {
  RegExp regExpLocation;
  RegExp regExpSingleRole;
  RegExp regExpMultiRole;

  LocationInputFormat(
      this.regExpLocation, this.regExpSingleRole, this.regExpMultiRole);

  /// It's a work of art.
  LocationLineType getLineType(String line) => !_isPotentiallyValidInput(line)
      ? LocationLineType.NONE
      : _isLocation(line)
          ? LocationLineType.LOCATION
          : _isSingleRole(line)
              ? LocationLineType.SINGLE_ROLE
              : _isMultiRole(line)
                  ? LocationLineType.MULTI_ROLE
                  : LocationLineType.NONE;

  /// Evaluates to true if only the location regular expression matches.
  bool _isLocation(String line) =>
      regExpLocation.hasMatch(line) &&
      !regExpSingleRole.hasMatch(line) &&
      !regExpMultiRole.hasMatch(line);

  /// Evaluates to true if only the single-role regular expression matches.
  bool _isSingleRole(String line) =>
      !regExpLocation.hasMatch(line) &&
      regExpSingleRole.hasMatch(line) &&
      !regExpMultiRole.hasMatch(line);

  /// Evaluates to true if only the multi-role regular expression matches.
  bool _isMultiRole(String line) =>
      !regExpLocation.hasMatch(line) &&
      !regExpSingleRole.hasMatch(line) &&
      regExpMultiRole.hasMatch(line);

  /// Evaluates to true if any regular expression matches.
  bool _isPotentiallyValidInput(String line) =>
      regExpLocation.hasMatch(line) ||
      regExpSingleRole.hasMatch(line) ||
      regExpMultiRole.hasMatch(line);
}

/// Enum to help dictate what types of lines the file parser has encountered.
enum LocationLineType { LOCATION, SINGLE_ROLE, MULTI_ROLE, NONE }
