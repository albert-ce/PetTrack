import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/auth_io.dart';

class CalendarService {
  final AuthClient _client;
  late final gcal.CalendarApi _calendarApi;

  CalendarService(this._client) {
    _calendarApi = gcal.CalendarApi(_client);
  }

  // Nuevo método: Obtener la lista de calendarios del usuario
  Future<List<gcal.CalendarListEntry>> getCalendarList() async {
    try {
      final calendarList = await _calendarApi.calendarList.list();
      return calendarList.items ?? [];
    } catch (e) {
      print('Error fetching calendar list: $e');
      return [];
    }
  }

  // Nuevo método: Crear un nuevo calendario
  Future<gcal.Calendar?> createCalendar(gcal.Calendar calendar) async {
    try {
      final createdCalendar = await _calendarApi.calendars.insert(calendar);
      return createdCalendar;
    } catch (e) {
      print('Error creating calendar: $e');
      return null;
    }
  }

  // Nuevo método: Comprobar y crear el calendario "PetTrack" si no existe
  Future<String?> ensurePetTrackCalendarExists() async {
    try {
      // (1) Obtener la lista de calendarios. Asegurarse de que se está listando correctamente.
      final calendarList = await _calendarApi.calendarList.list();
      final List<gcal.CalendarListEntry> userCalendars = calendarList.items ?? [];

      // (2) Buscar el calendario "PetTrack" de forma insensible a mayúsculas/minúsculas y espacios
      gcal.CalendarListEntry? petTrackCalendar;
      for (var cal in userCalendars) {
        if (cal.summary != null && cal.summary!.trim().toLowerCase() == 'pettrack') {
          petTrackCalendar = cal;
          break;
        }
      }

      if (petTrackCalendar != null && petTrackCalendar.id != null) {
        // El calendario "PetTrack" ya existe
        print('El calendario "PetTrack" ya existe con ID: ${petTrackCalendar.id}');
        return petTrackCalendar.id;
      } else {
        // El calendario "PetTrack" no existe, crearlo
        final newCalendar = gcal.Calendar()
          ..summary = 'PetTrack'
          ..description = 'Calendario para eventos relacionados con tus mascotas en PetTrack App.'
          ..timeZone = 'Europe/Madrid'; // Ajusta la zona horaria si es necesario

        final createdCalendar = await _calendarApi.calendars.insert(newCalendar);
        if (createdCalendar != null && createdCalendar.id != null) {
          print('Calendario "PetTrack" creado con ID: ${createdCalendar.id}');
          return createdCalendar.id;
        } else {
          print('Error: El calendario "PetTrack" no se pudo crear o no devolvió un ID válido.');
          return null;
        }
      }
    } catch (e) {
      print('Error en ensurePetTrackCalendarExists: $e');
      // Puedes añadir un SnackBar o un logging más detallado aquí
      return null;
    }
  }


  // Modificado: getEvents ahora recibe el calendarId
  Future<List<gcal.Event>> getEvents(String calendarId, DateTime startDate, DateTime endDate) async {
    try {
      final events = await _calendarApi.events.list(
        calendarId, // Usa el ID del calendario específico
        timeMin: startDate.toUtc(),
        timeMax: endDate.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      return events.items ?? [];
    } catch (e) {
      print('Error fetching events from $calendarId: $e');
      return [];
    }
  }

  // Modificado: createEvent ahora recibe el calendarId
  Future<gcal.Event?> createEvent(String calendarId, gcal.Event event) async {
    try {
      final createdEvent = await _calendarApi.events.insert(
        event,
        calendarId, // Usa el ID del calendario específico
      );
      return createdEvent;
    } catch (e) {
      print('Error creating event in $calendarId: $e');
      return null;
    }
  }

  // Modificado: updateEvent ahora recibe el calendarId
  Future<gcal.Event?> updateEvent(String calendarId, String eventId, gcal.Event event) async {
    try {
      final updatedEvent = await _calendarApi.events.update(
        event,
        calendarId, // Usa el ID del calendario específico
        eventId,
      );
      return updatedEvent;
    } catch (e) {
      print('Error updating event $eventId in $calendarId: $e');
      return null;
    }
  }

  // Modificado: deleteEvent ahora recibe el calendarId
  Future<void> deleteEvent(String calendarId, String eventId) async {
    try {
      await _calendarApi.events.delete(
        calendarId, // Usa el ID del calendario específico
        eventId,
      );
      print('Evento $eventId eliminado con éxito de $calendarId.');
    } catch (e) {
      print('Error deleting event $eventId from $calendarId: $e');
    }
  }
}