import 'package:flutter/material.dart';
import 'package:talawa/constants/recurrence_values.dart';
import 'package:talawa/constants/routing_constants.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/view_model/after_auth_view_models/event_view_models/base_event_view_model.dart';

/// Dialog for showing recurrence options.
class ShowRecurrenceDialog extends StatefulWidget {
  const ShowRecurrenceDialog({
    super.key,
    required this.model,
  });
  final BaseEventViewModel model;

  @override
  State<ShowRecurrenceDialog> createState() => _ShowRecurrenceDialogState();
}

class _ShowRecurrenceDialogState extends State<ShowRecurrenceDialog> {
  @override
  Widget build(BuildContext context) {
    final weekDayName = days[widget.model.eventStartDate.weekday - 1];
    final weeklyText = 'Every ${weekDayName.substring(0, 3)}';
    final monthlyText = 'Every month on day ${widget.model.eventStartDate.day}';
    final yearlyText =
        'Every year on ${widget.model.eventStartDate.day} ${monthNames[widget.model.eventStartDate.month - 1]}';

    return Dialog(
      child: SizedBox(
        height: SizeConfig.screenHeight! * 0.6,
        child: RadioGroup<String>(
          groupValue: widget.model.recurrenceLabel,
          onChanged: (value) {
            if (value == null) return;
            switch (value) {
              case 'Does not repeat':
                updateModel(value, false, null, null);
              case 'Every day':
                updateModel(value, true, Frequency.daily, null);
              case 'Monday to Friday':
                updateModel(value, true, Frequency.weekly, {
                  WeekDays.monday,
                  WeekDays.tuesday,
                  WeekDays.wednesday,
                  WeekDays.thursday,
                  WeekDays.friday,
                });
              case 'Custom...':
                widget.model.isRecurring = true;
                navigationService.pushScreen(
                  Routes.customRecurrencePage,
                  arguments: widget.model,
                );
              default:
                if (value == weeklyText) {
                  updateModel(
                    value,
                    true,
                    Frequency.weekly,
                    {weekDayName},
                  );
                } else if (value == monthlyText) {
                  updateModel(value, true, Frequency.monthly, null);
                } else if (value == yearlyText) {
                  updateModel(value, true, Frequency.yearly, null);
                }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RadioListTile<String>(
                title: Text('Does not repeat'),
                value: 'Does not repeat',
              ),
              const RadioListTile<String>(
                title: Text('Every day'),
                value: 'Every day',
              ),
              RadioListTile<String>(
                title: Text(weeklyText),
                value: weeklyText,
              ),
              RadioListTile<String>(
                title: Text(monthlyText),
                value: monthlyText,
              ),
              RadioListTile<String>(
                title: Text(yearlyText),
                value: yearlyText,
              ),
              const RadioListTile<String>(
                title: Text('Monday to Friday'),
                value: 'Monday to Friday',
              ),
              const RadioListTile<String>(
                title: Text('Custom...'),
                value: 'Custom...',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Updates the model with selected recurrence options.
  ///
  /// **params**:
  /// * `value`: Text of the selected option
  /// * `isRecurring`: Whether event is recurring
  /// * `frequency`: Frequency type
  /// * `weekDays`: Set of week days
  /// * `count`: Number of occurrences (optional)
  ///
  /// **returns**:
  ///   None
  void updateModel(
    String value,
    bool isRecurring,
    String? frequency,
    Set<String>? weekDays, {
    int? count,
  }) {
    setState(() {
      widget.model.isRecurring = isRecurring;
      widget.model.recurrenceLabel = value;

      if (isRecurring && frequency != null) {
        widget.model.setRecurrenceFrequency(frequency);
        if (weekDays != null) {
          widget.model.weekDays = weekDays;
        }
        if (count != null) {
          widget.model.count = count;
          widget.model.eventEndType = EventEndTypes.after;
        } else {
          widget.model.eventEndType = EventEndTypes.never;
        }
        widget.model.interval = 1;
      } else {
        widget.model.resetRecurrenceSettings();
      }

      Navigator.pop(context, value);
    });
  }
}
