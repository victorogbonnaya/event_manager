import 'dart:convert';
import 'dart:io';

class Event {
  String title;
  DateTime date;
  String time;
  String location;
  String description;
  List<Attendee> attendees;

  Event({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    this.attendees = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      attendees: (json['attendees'] as List<dynamic>? ?? [])
          .map((item) => Attendee.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'description': description,
      'attendees': attendees.map((a) => a.toJson()).toList(),
    };
  }
}

class Attendee {
  String name;
  bool isPresent;

  Attendee({
    required this.name,
    this.isPresent = false,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      name: json['name'] as String,
      isPresent: json['isPresent'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isPresent': isPresent,
    };
  }
}

class EventManager {
  List<Event> events = [];

  void addEvent(Event event) {
    events.add(event);
  }

  void editEvent(int index, Event newEvent) {
    if (index >= 0 && index < events.length) {
      events[index] = newEvent;
    }
  }

  void deleteEvent(int index) {
    if (index >= 0 && index < events.length) {
      events.removeAt(index);
    }
  }

  List<Event> getUpcomingEvents() {
    DateTime now = DateTime.now();
    return events.where((event) => event.date.isAfter(now)).toList();
  }

  List<Event> getPastEvents() {
    DateTime now = DateTime.now();
    return events.where((event) => event.date.isBefore(now)).toList();
  }

  void registerAttendee(int eventIndex, Attendee attendee) {
    if (eventIndex >= 0 && eventIndex < events.length) {
      events[eventIndex].attendees.add(attendee);
    }
  }

  List<Attendee> getAttendees(int eventIndex) {
    if (eventIndex >= 0 && eventIndex < events.length) {
      return events[eventIndex].attendees;
    }
    return [];
  }

  void markAttendance(int eventIndex, String attendeeName, bool isPresent) {
    if (eventIndex >= 0 && eventIndex < events.length) {
      for (var attendee in events[eventIndex].attendees) {
        if (attendee.name == attendeeName) {
          attendee.isPresent = isPresent;
        }
      }
    }
  }

  List<Event> getEventsInChronologicalOrder() {
    return events..sort((a, b) => a.date.compareTo(b.date));
  }

  bool checkForScheduleConflict(Event newEvent) {
    for (var event in events) {
      if (event.date == newEvent.date && event.time == newEvent.time) {
        return true;
      }
    }
    return false;
  }

  void saveToFile(String filename) {
    File file = File(filename);
    String jsonData = jsonEncode(events.map((e) => e.toJson()).toList());
    file.writeAsStringSync(jsonData);
  }

  void loadFromFile(String filename) {
    File file = File(filename);
    if (file.existsSync()) {
      String jsonData = file.readAsStringSync();
      List<dynamic> jsonList = jsonDecode(jsonData);
      events = jsonList.map((json) => Event.fromJson(json)).toList();
    }
  }
}

void main() {
  EventManager eventManager = EventManager();
  eventManager.loadFromFile('events.json');

  while (true) {
    print('\nTech Hub Event Manager');
    print('1. Add Event');
    print('2. Edit Event');
    print('3. Delete Event');
    print('4. List Upcoming Events');
    print('5. List Past Events');
    print('6. Register Attendee');
    print('7. View Attendees');
    print('8. Mark Attendance');
    print('9. List Events Chronologically');
    print('10. Check Schedule Conflict');
    print('11. Save and Exit');
    print('Choose an option: ');

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        _addEvent(eventManager);
        break;
      case '2':
        _editEvent(eventManager);
        break;
      case '3':
        _deleteEvent(eventManager);
        break;
      case '4':
        _listUpcomingEvents(eventManager);
        break;
      case '5':
        _listPastEvents(eventManager);
        break;
      case '6':
        _registerAttendee(eventManager);
        break;
      case '7':
        _viewAttendees(eventManager);
        break;
      case '8':
        _markAttendance(eventManager);
        break;
      case '9':
        _listEventsChronologically(eventManager);
        break;
      case '10':
        _checkScheduleConflict(eventManager);
        break;
      case '11':
        eventManager.saveToFile('events.json');
        print('Data saved. Exiting...');
        return;
      default:
        print('Invalid choice. Try again.');
    }
  }
}

void _addEvent(EventManager eventManager) {
  print('Enter event title:');
  String? title = stdin.readLineSync();
  print('Enter event date (YYYY-MM-DD):');
  DateTime? date = DateTime.tryParse(stdin.readLineSync() ?? '');
  print('Enter event time (HH:MM):');
  String? time = stdin.readLineSync();
  print('Enter event location:');
  String? location = stdin.readLineSync();
  print('Enter event description:');
  String? description = stdin.readLineSync();

  if (title != null && date != null && time != null && location != null && description != null) {
    Event event = Event(
      title: title,
      date: date,
      time: time,
      location: location,
      description: description,
    );
    if (eventManager.checkForScheduleConflict(event)) {
      print('Conflict detected. Event not added.');
    } else {
      eventManager.addEvent(event);
      print('Event added successfully.');
    }
  } else {
    print('Invalid input. Event not added.');
  }
}

void _editEvent(EventManager eventManager) {
  print('Enter event index to edit:');
  int index = int.parse(stdin.readLineSync() ?? '');
  if (index >= 0 && index < eventManager.events.length) {
    print('Enter new event title:');
    String? title = stdin.readLineSync();
    print('Enter new event date (YYYY-MM-DD):');
    DateTime? date = DateTime.tryParse(stdin.readLineSync() ?? '');
    print('Enter new event time (HH:MM):');
    String? time = stdin.readLineSync();
    print('Enter new event location:');
    String? location = stdin.readLineSync();
    print('Enter new event description:');
    String? description = stdin.readLineSync();

    if (title != null && date != null && time != null && location != null && description != null) {
      Event event = Event(
        title: title,
        date: date,
        time: time,
        location: location,
        description: description,
      );
      eventManager.editEvent(index, event);
      print('Event updated successfully.');
    } else {
      print('Invalid input. Event not updated.');
    }
  } else {
    print('Invalid event index.');
  }
}

void _deleteEvent(EventManager eventManager) {
  print('Enter event index to delete:');
  int index = int.parse(stdin.readLineSync() ?? '');
  if (index >= 0 && index < eventManager.events.length) {
    eventManager.deleteEvent(index);
    print('Event deleted successfully.');
  } else {
    print('Invalid event index.');
  }
}

void _listUpcomingEvents(EventManager eventManager) {
  List<Event> upcomingEvents = eventManager.getUpcomingEvents();
  if (upcomingEvents.isEmpty) {
    print('No upcoming events.');
  } else {
    for (var event in upcomingEvents) {
      print('${event.title} on ${event.date} at ${event.time}');
    }
  }
}

void _listPastEvents(EventManager eventManager) {
  List<Event> pastEvents = eventManager.getPastEvents();
  if (pastEvents.isEmpty) {
    print('No past events.');
  } else {
    for (var event in pastEvents) {
      print('${event.title} on ${event.date} at ${event.time}');
    }
  }
}

void _registerAttendee(EventManager eventManager) {
  print('Enter event index to register attendee:');
  int eventIndex = int.parse(stdin.readLineSync() ?? '');
  if (eventIndex >= 0 && eventIndex < eventManager.events.length) {
    print('Enter attendee name:');
    String? name = stdin.readLineSync();
    if (name != null) {
      Attendee attendee = Attendee(name: name);
      eventManager.registerAttendee(eventIndex, attendee);
      print('Attendee registered successfully.');
    } else {
      print('Invalid input. Attendee not registered.');
    }
  } else {
    print('Invalid event index.');
  }
}

void _viewAttendees(EventManager eventManager) {
  print('Enter event index to view attendees:');
  int eventIndex = int.parse(stdin.readLineSync() ?? '');
  List<Attendee> attendees = eventManager.getAttendees(eventIndex);
  if (attendees.isEmpty) {
    print('No attendees for this event.');
  } else {
    for (var attendee in attendees) {
      print('${attendee.name} - ${attendee.isPresent ? "Present" : "Absent"}');
    }
  }
}

void _markAttendance(EventManager eventManager) {
  print('Enter event index to mark attendance:');
  int eventIndex = int.parse(stdin.readLineSync() ?? '');
  if (eventIndex >= 0 && eventIndex < eventManager.events.length) {
    print('Enter attendee name to mark attendance:');
    String? name = stdin.readLineSync();
    print('Is the attendee present? (yes/no):');
    String? response = stdin.readLineSync();
    bool isPresent = response?.toLowerCase() == 'yes';
    eventManager.markAttendance(eventIndex, name ?? '', isPresent);
    print('Attendance marked successfully.');
  } else {
    print('Invalid event index.');
  }
}

void _listEventsChronologically(EventManager eventManager) {
  List<Event> events = eventManager.getEventsInChronologicalOrder();
  if (events.isEmpty) {
    print('No events to display.');
  } else {
    for (var event in events) {
      print('${event.title} on ${event.date} at ${event.time}');
    }
  }
}

void _checkScheduleConflict(EventManager eventManager) {
  print('Enter event title to check for conflicts:');
  String? title = stdin.readLineSync();
  print('Enter event date (YYYY-MM-DD):');
  DateTime? date = DateTime.tryParse(stdin.readLineSync() ?? '');
  print('Enter event time (HH:MM):');
  String? time = stdin.readLineSync();
  print('Enter event location:');
  String? location = stdin.readLineSync();
  print('Enter event description:');
  String? description = stdin.readLineSync();

  if (title != null && date != null && time != null && location != null && description != null) {
    Event newEvent = Event(
      title: title,
      date: date,
      time: time,
      location: location,
      description: description,
    );
    if (eventManager.checkForScheduleConflict(newEvent)) {
      print('Schedule conflict detected.');
    } else {
      print('No schedule conflict.');
    }
  } else {
    print('Invalid input.');
  }
}
