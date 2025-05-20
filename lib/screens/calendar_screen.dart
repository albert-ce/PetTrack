import 'package:flutter/material.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ca_ES', null);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _calendarFormat == CalendarFormat.month
                            ? AppColors.primary
                            : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarFormat = CalendarFormat.month;
                    });
                  },
                  child: const Text(
                    'Mes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _calendarFormat == CalendarFormat.week
                            ? AppColors.primary
                            : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarFormat = CalendarFormat.week;
                    });
                  },
                  child: const Text(
                    'Setmana',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            locale: 'ca_ES',

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },

            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),

            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,

            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.primary, fontSize: 15),
              weekendStyle: TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),

            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: screenHeight * 0.08,
            height: screenHeight * 0.08,
            alignment: Alignment.center,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
