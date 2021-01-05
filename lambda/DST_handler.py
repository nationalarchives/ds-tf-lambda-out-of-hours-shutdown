from datetime import datetime, timedelta
import pytz


def london_time_now():

    time_london = pytz.timezone("Europe/London")
    changes = time_london._utc_transition_times
    bst_end = ""
    bst_start = ""
    year = datetime.now().year

    for dates in changes:
        if dates.year == year and dates.month == 3:
            bst_start = dates
            print("BST Start time: %s" % dates)
        elif dates.year == year and dates.month == 10:
            bst_end = dates
            print("BST End time: %s" % dates)

    if bst_start < datetime.now() < bst_end:
        print("Today we are in British Summer Time")
        now = datetime.utcnow() + timedelta(hours=1)
    else:
        print("Today we are in GMT")
        now = datetime.utcnow()

    return now
