import 'package:flutter/material.dart';
import 'package:pet_track/components/google_auth.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/auth_io.dart'; // Importa para AuthClient
import 'package:pet_track/services/calendar_service.dart'; // Asegúrate de que la ruta sea correcta

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  late final AuthService _authService;
  CalendarService? _calendarService;
  String? _petTrackCalendarId;
  List<gcal.Event> _selectedEvents = [];
  bool _isLoadingEvents = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ca_ES', null);
    _selectedDay = _focusedDay; // Inicializa _selectedDay al día actual
    _authService = AuthService();
    _initializeCalendarService();
  }

  Future<void> _initializeCalendarService() async {
    final AuthClient? client = await _authService.getAuthenticatedClient();
    if (client != null) {
      _calendarService = CalendarService(client);
      _petTrackCalendarId = await _calendarService!.ensurePetTrackCalendarExists();
      if (_petTrackCalendarId != null) {
        _getEventsForSelectedDay(_selectedDay!);
      } else {
        setState(() {
          _isLoadingEvents = false; // Detener la carga si el calendario no se pudo obtener/crear
        });
        print('No se pudo obtener o crear el calendario PetTrack.');
      }
    } else {
      setState(() {
        _isLoadingEvents = false; // Detener la carga si el cliente de autenticación es nulo
      });
      print('No se pudo obtener el cliente autenticado.');
    }
  }

  Future<void> _getEventsForSelectedDay(DateTime day) async {
    if (_calendarService == null || _petTrackCalendarId == null) {
      setState(() {
        _selectedEvents = [];
        _isLoadingEvents = false;
      });
      return;
    }

    setState(() {
      _isLoadingEvents = true;
      _selectedEvents = []; // Limpia eventos anteriores antes de cargar nuevos
    });

    try {
      // Obtener el inicio y fin del día seleccionado
      final DateTime startOfDay = DateTime(day.year, day.month, day.day, 0, 0, 0);
      final DateTime endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

      final events = await _calendarService!.getEvents(
        _petTrackCalendarId!,
        startOfDay,
        endOfDay,
      );
      setState(() {
        _selectedEvents = events;
        _isLoadingEvents = false;
      });
    } catch (e) {
      print('Error al obtener eventos para el día seleccionado: $e');
      setState(() {
        _selectedEvents = [];
        _isLoadingEvents = false;
      });
    }
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
                    backgroundColor: _calendarFormat == CalendarFormat.month
                        ? AppColors.primary
                        : AppColors.backgroundComponentHover,
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarFormat = CalendarFormat.month;
                    });
                  },
                  child: Text(
                    'Mes',
                    style: AppTextStyles.midText(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _calendarFormat == CalendarFormat.week
                        ? AppColors.primary
                        : AppColors.backgroundComponentHover,
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarFormat = CalendarFormat.week;
                    });
                  },
                  child: Text(
                    'Setmana',
                    style: AppTextStyles.midText(
                      context,
                    ).copyWith(color: Colors.white),
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
              _getEventsForSelectedDay(selectedDay); // Carga eventos para el nuevo día seleccionado
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
          // --- Sección de eventos ---
          const Divider(),
          Expanded(
            child: _isLoadingEvents
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : _selectedEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No hi ha res agendat per aquest dia.',
                          style: AppTextStyles.midText(context)
                              .copyWith(color: AppColors.black),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _selectedEvents.length,
                        itemBuilder: (context, index) {
                          final event = _selectedEvents[index];
                          // Asegúrate de manejar los eventos que podrían no tener start o end
                          final eventStartTime = event.start?.dateTime ?? event.start?.date;
                          final eventEndTime = event.end?.dateTime ?? event.end?.date;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: AppColors.backgroundComponent,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.summary ?? 'Sin título',
                                    style: AppTextStyles.bigText(context).copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (event.description != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        event.description!,
                                        style: AppTextStyles.midText(context).copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  if (eventStartTime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Inici: ${eventStartTime.toLocal().toString().substring(0, 16)}',
                                        style: AppTextStyles.tinyText(context).copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  if (eventEndTime != null && eventStartTime != eventEndTime)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Fi: ${eventEndTime.toLocal().toString().substring(0, 16)}',
                                        style: AppTextStyles.tinyText(context).copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  if (event.location != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Lloc: ${event.location!}',
                                        style: AppTextStyles.tinyText(context).copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Añadir nuevo evento para el día: $_selectedDay');
        },
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