function setup_race_new_view(guessStartFrom) {
    var icons = {
        time: 'fa fa-clock-o',
        date: 'fa fa-calendar',
        up: 'fa fa-arrow-up',
        down: 'fa fa-arrow-down',
        previous: 'fa fa-arrow-left',
        next: 'fa fa-arrow-right',
        today: 'fa fa-calendar-check-o',
        clear: 'fa fa-eraser',
        close: 'fa fa-close'
    };
    $('#race_start_from').datetimepicker({
        icons: icons,
        locale: 'sv',
        useCurrent: false,
        defaultDate: false,
        sideBySide: true
    });
    $('#race_start_to').datetimepicker({
        icons: icons,
        locale: 'sv',
        useCurrent: false,
        defaultDate: false,
        sideBySide: true
    });

    // if we don't have a start time set, use current date but
    // set HH:mm to 12:00 which is a reasonable default, unless
    // guessStartFrom contains a value we can use
    $('#race_start_from').on('dp.show', function (e) {
        if ($('#race_start_from').data("DateTimePicker").date() == null) {
            var startFrom = moment().hour(12).minutes(0);
            if (guessStartFrom != '') {
                startFrom = moment(guessStartFrom);
            }
            $('#race_start_from').data("DateTimePicker").date(startFrom);
        }
    });
    // when the start time is modified, erase max start time
    // if it before min start time
    $('#race_start_from').on('dp.change', function (e) {
        var start_to = $('#race_start_to').data("DateTimePicker").date();
        $('#race_start_to').data("DateTimePicker").minDate(e.date);
        if (start_to != null && start_to.isBefore(e.date)) {
            $('#race_start_to').data("DateTimePicker").date(null);
        }
    });
    // when the max start time widget is displayed, set it to
    // min start time, unless it is already set
    $('#race_start_to').on('dp.show', function (e) {
        if ($('#race_start_to').data("DateTimePicker").date() == null) {
            $('#race_start_to').data("DateTimePicker").date(
                $('#race_start_from').data("DateTimePicker").date()
            );
        }
    });
};

    
