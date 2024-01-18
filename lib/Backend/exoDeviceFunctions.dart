import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class exoDeviceFunctions extends ChangeNotifier {
  late StreamSubscription _receiverSubscription;
  int _speed_setting = 1;
  double _flexionCounter = 0;
  double _extensionCounter = 0;
  double _curFlexAngle = 80;
  double _flexLimit = 20;
  double _extLimit = 180;
  bool _isROMLimitEnabled = false;
  bool _isAngleControlEnabled = false;
  BluetoothCharacteristic? _serialRX;

  BluetoothDevice? _connectedDevice;

  int get speed_setting => _speed_setting;
  double get flexLimit => _flexLimit;
  double get extensionCounter => _extensionCounter;
  double get flexionCounter => _flexionCounter;
  double get curFlexAngle => _curFlexAngle;
  double get extLimit => _extLimit;
  bool get isROMLimitEnabled => _isROMLimitEnabled;
  bool get isAngleControlEnabled => _isAngleControlEnabled;
  BluetoothCharacteristic? get serialRX => _serialRX;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<void>? test_flex(bool testing) {
    if (testing == true) {
      _curFlexAngle -= _speed_setting;
      notifyListeners();
    } else if (curFlexAngle > 0 && curFlexAngle >= flexLimit) {
      _curFlexAngle -= _speed_setting;
      notifyListeners();
    }
    return null;
  }

  Future<void>? test_extend(bool testing) {
    if (testing == true) {
      _curFlexAngle += _speed_setting;
      notifyListeners();
    } else if (curFlexAngle < 180 && curFlexAngle <= extLimit) {
      _curFlexAngle += _speed_setting;
      notifyListeners();
    }
    return null;
  }

  void setSerialRX(BluetoothCharacteristic serialRX) {
    _serialRX = serialRX;

    notifyListeners();
  }

  void setConnectedDevice(BluetoothDevice connectedDevice) {
    _connectedDevice = connectedDevice;
    notifyListeners();
  }

  void setSpeed(int speed) {
    _speed_setting = speed;
    notifyListeners();
  }

  void setFlexLimit(double limit) {
    _flexLimit = limit;
    notifyListeners();
  }

  void setExtLimit(double limit) {
    _extLimit = limit;
    notifyListeners();
  }

  void setFlexionCounter(double counter) {
    _flexionCounter = counter;
    notifyListeners();
  }

  void setExtensionCounter(double counter) {
    _extensionCounter = counter;
    notifyListeners();
  }

  void setCurFlexAngle(double angle) {
    _curFlexAngle = angle;

    notifyListeners();
  }

  void setROMLimitEnabled(bool enabled) {
    _isROMLimitEnabled = enabled;
    notifyListeners();
  }

  void setAngleControlEnabled(bool enabled) {
    _isAngleControlEnabled = enabled;
    notifyListeners();
  }

  test() {
    print("test");
  }

  startreceiverSubscription(
      /////////////////////////////////////////////////////////// TO DO : ARDUNIO NOT REPORTING BACK/ FAHAD
      BluetoothDevice connectedDevice,
      BluetoothCharacteristic serialRX) {
    _receiverSubscription = serialRX.onValueReceived.listen((value) {
      String rx_str = ascii.decode(value);

      List<String> commands = rx_str.split(" ");
      print(commands);
      if (commands[0] == "A") {
        setCurFlexAngle(double.parse(commands[1]));
      } else if (commands[0] == "P0") {
        setAngleControlEnabled(int.parse(commands[1]) == 1 ? true : false);
      } else if (commands[0] == "P1") {
        setROMLimitEnabled(int.parse(commands[1]) == 1 ? true : false);
      } else if (commands[0] == "P2") {
        setFlexLimit(double.parse(commands[1]));
      } else if (commands[0] == "P3") {
        setExtLimit(double.parse(commands[1]));
      }
    });
    connectedDevice.cancelWhenDisconnected(_receiverSubscription);
    serialRX.setNotifyValue(true);
  }
}

class exoBluetoothControlFunctions extends ChangeNotifier {
  BluetoothCharacteristic? _serialTX;

  BluetoothCharacteristic? get serialTX => _serialTX;

  void setSerialTX(BluetoothCharacteristic serialTX) {
    _serialTX = serialTX;

    notifyListeners();
  }

  void extend(
    int? speed,
    BluetoothCharacteristic serialTX,
  ) {
    String tx_str = "E" + " " + "${speed ?? ""} ";
    serialTX!.write(utf8.encode(tx_str));
  }

  void flex(int? speed, BluetoothCharacteristic serialTX) {
    String tx_str = "F" + " " + "${speed ?? ""} ";
    serialTX.write(utf8.encode(tx_str));
  }

  void CPM(int cpm, BluetoothCharacteristic serialTX) {
    String tx_str = "C" + " " + cpm.toString();
    serialTX!.write(utf8.encode(tx_str));
  }

  void entendByAngle(double angle, BluetoothCharacteristic serialTX) {
    String tx_str = "J" + " " + angle.toString();
    serialTX!.write(utf8.encode(tx_str));
  }

  void flexByAngle(double angle, BluetoothCharacteristic serialTX) {
    String tx_str = "I" + " " + angle.toString();
    serialTX!.write(utf8.encode(tx_str));
  }

  void angleControl(BluetoothCharacteristic serialTX) {
    String tx_str = "G" + " " + "3";
    serialTX!.write(utf8.encode(tx_str));
  }

  void disableAngleControl(BluetoothCharacteristic serialTX) {
    String tx_str = "G" + " " + "2";
    serialTX!.write(utf8.encode(tx_str));
  }

  void setSpeed(int speed, BluetoothCharacteristic serialTX) {
    String tx_str = "S" + " " + "${speed * 40}";
    serialTX!.write(utf8.encode(tx_str));
  }

  void setFlexLimit(BluetoothCharacteristic serialTX) {
    String tx_str = "M" + " " + "0";
    serialTX!.write(utf8.encode(tx_str));
  }

  void setExtLimit(BluetoothCharacteristic serialTX) {
    String tx_str = "M" + " " + "1";
    serialTX!.write(utf8.encode(tx_str));
  }

  void setROMLimitEnabled(bool enabled, BluetoothCharacteristic serialTX) {
    String tx_str = "G" + " " + (enabled ? "1" : "0");
    serialTX!.write(utf8.encode(tx_str));
  }

  void setAngleControlEnabled(bool enabled, BluetoothCharacteristic serialTX) {
    String tx_str = "G" + " " + (enabled ? "3" : "2");
    serialTX!.write(utf8.encode(tx_str));
  }

  void resetSetPoint(BluetoothCharacteristic serialTX) {
    String tx_str = "G 5";
    serialTX!.write(utf8.encode(tx_str));
  }

  void setZero(BluetoothCharacteristic serialTX) {
    String tx_str = "Z 0";
    serialTX!.write(utf8.encode(tx_str));
  }

  void stop(BluetoothCharacteristic serialTX) {
    String tx_str = "S 0";
    serialTX.write(utf8.encode(tx_str));
  }

  void EmergencyStop(BluetoothCharacteristic serialTX) {
    String tx_str = "X 0";
    serialTX!.write(utf8.encode(tx_str));
  }

  // void unwindIntergral(BluetoothCharacteristic serialTX) {
  //   String tx_str = "G 4";
  //   serialTX.write(utf8.encode(tx_str));
  // }
}
