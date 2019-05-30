import 'package:flutter/material.dart';
import 'package:world_holidays/models/holiday_data.dart';
import '../resources/repository.dart';
import 'package:world_holidays/resources/months_color.dart';
import 'package:rxdart/rxdart.dart';

class HolidayBloc {
  final _repository = Repository();
  final currentSelectedCountryCode = BehaviorSubject<String>();
  final currentSelectedCountryName = BehaviorSubject<String>();
  final holidays = BehaviorSubject<HolidayData>();

  get holidaysValue {
    print("start get holidaysValue");
    if (holidays.value != null) {
      return holidays;
    } else {
      print("getHolidays");
      getHolidays();
      return holidays;
    }
  }

  getHolidays() async {
    print("currentCode " +
        (currentSelectedCountryCodeValue.value == null).toString());
    holidays.sink.add(
        await _repository.getHolidays(currentSelectedCountryCodeValue.value));
  }

  refreshHolidays() {
    holidays.sink.add(null);
    getHolidays();
  }

  void dispose() {
    currentSelectedCountryCode.close();
    currentSelectedCountryName.close();
    holidays.close();
  }

  BehaviorSubject<String> get currentSelectedCountryCodeValue {
    print("get currentSelectedCountryValue");
    if (currentSelectedCountryCode.value == null) {
      print("get currentSelectedCountryValue == null");

      _repository.getCountryCode().then((countryCode) {
        print("country code is null and from prefs is " + countryCode);
        currentSelectedCountryCode.sink.add(countryCode);
        return currentSelectedCountryCode;
      });
    }
    print("Code not null " + currentSelectedCountryCode.value.toString());

    return currentSelectedCountryCode;
  }

  BehaviorSubject<String> get currentSelectedCountryNameValue {
    // print("get currentSelectedCountryValue");
    if (currentSelectedCountryName.value == null) {
      print("get currentSelectedCountryValue == null");
      _repository.getCountryName().then((countryName) {
        print("country name is null and from prefs is " + countryName);
        currentSelectedCountryName.sink.add(countryName);
        return currentSelectedCountryName;
      });
    }

    print("Name not null" + currentSelectedCountryName.value.toString());

    return currentSelectedCountryName;
  }

  setCurrentCountryDetails(
      {@required String countryCode, @required String countryName}) async {
    await _repository.setCountryName(countryName);
    await _repository.setCountryCode(countryCode);

    currentSelectedCountryName.sink.add(countryName);
    currentSelectedCountryCode.sink.add(countryCode);

    refreshHolidays();
  }

  Map<String, List<Holiday>> getMapOfMonthToHolidayList(
      AsyncSnapshot snapshot) {
    Map<String, List<Holiday>> monthToHolidayListMap =
        Map<String, List<Holiday>>();

    HolidayData holidayData = snapshot.data;

    if (holidayData == null) {
      return monthToHolidayListMap;
    }
    Response response = holidayData.response;

    List<Holiday> holidays = response.holidays;

    monthToColorMap.forEach((month, color) {
      int monthPosition = monthToColorMap.keys.toList().indexOf(month) + 1;

      List<Holiday> monthHolidaysList = List();
      holidays.forEach((holiday) {
        if (holiday.date.datetime.month == monthPosition) {
          monthHolidaysList.add(holiday);
        }
        monthToHolidayListMap[month] = monthHolidaysList;
      });
    });

    return monthToHolidayListMap;
  }
}

final holidayBloc = HolidayBloc();
