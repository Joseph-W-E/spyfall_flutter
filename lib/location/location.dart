import 'dart:async';
import 'dart:math' as Math;

import 'package:flutter/services.dart' show rootBundle;

import 'package:spyfall/utils/data_structures.dart';

/// Handles scanning files to find (and supply) [Location] objects from files.
class LocationManager {
  RefreshableSet _locations = new RefreshableSet(true);
  LocationInputFormat inputFormat;

  LocationManager(this.inputFormat);

  /// Gets a random location that hasn't been chosen in awhile
  Location get location => _locations.take;

  /// The file reader is looking for:
  ///   location names
  ///   roles that only one player can have
  ///   roles that any number of players can have
  /// Locations found are stored in [_locations].
  ///
  /// @param fileName - the file to be parsed
  Future parseFile({String fileName: 'assets/text/locations.txt'}) async {
    String file = await _loadLocationsAsString(fileName);
    Location location = new Location();

    for (String line in file.split("\n")) {
      if (location == null) location = new Location();

      if (inputFormat.isLocation(line)) {
        location.location = _trim(line);
      } else if (inputFormat.isSingleRole(line)) {
        location.addSingleRole(_trim(line));
      } else if (inputFormat.isMultiRole(line)) {
        location.addMultiRole(_trim(line));
      } else {
        _locations.add(location);
        location = null;
      }
    }

    if (location != null) _locations.add(location);
    _locations.refreshAfter = Math.min(5, _locations.all.length);
  }

  /// Keeps only A-z, removes everything else.
  String _trim(String line) {
    return line.replaceAll(new RegExp(r"[^A-z0-9 ]"), '');
  }

  /// Assumes the given path is a text-file-asset.
  Future<String> _loadLocationsAsString(String path) async {
    return await rootBundle.loadString(path);
  }
}

/// Handles all information for a single location.
class Location {
  /// The location the players are at.
  String location;

  /// The set of roles that only one play can have.
  RefreshableSet _singleRoles = new RefreshableSet(false);

  /// The set of roles that any number of players can have.
  RefreshableSet _multiRoles = new RefreshableSet(true);

  Location();

  String get singleRole => _singleRoles.take;
  String get multiRole => _multiRoles.take;

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
    bool success = _multiRoles.add(role);
    if (success) _multiRoles.refreshAfter++;
    return success;
  }

  /// Returns a [String] representation of all known roles for the location.
  String toString() {
    var buffer = new StringBuffer();

    buffer.writeln("Location: $location");
    buffer.writeln();

    buffer.writeln("Single Roles:");
    for (String role in _singleRoles.all) {
      buffer.writeln(role);
    }
    buffer.writeln();

    buffer.writeln("Multi Roles:");
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
  Pattern locationPattern;
  Pattern singleRolePattern;
  Pattern multiRolePattern;

  LocationInputFormat(this.locationPattern, this.singleRolePattern, this.multiRolePattern);

  /// This constructor forces the input to come as a string
  LocationInputFormat.asRegExp(String locationRegex, String singleRoleRegex, String multiRoleRegex) {
    locationPattern = new RegExp(locationRegex);
    singleRolePattern = new RegExp(singleRoleRegex);
    multiRolePattern = new RegExp(multiRoleRegex);
  }

  bool isLocation(String line) => line.startsWith(locationPattern)
      && !line.startsWith(singleRolePattern) && !line.startsWith(multiRolePattern);

  bool isSingleRole(String line) => !line.startsWith(locationPattern)
      && line.startsWith(singleRolePattern) && !line.startsWith(multiRolePattern);

  bool isMultiRole(String line) => !line.startsWith(locationPattern)
      && !line.startsWith(singleRolePattern) && line.startsWith(multiRolePattern);
}

/// Enum to help dictate what types of lines the file parser has encountered.
enum LocationLineType { LOCATION, SINGLE_ROLE, MULTI_ROLE, NONE }
