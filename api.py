import calendar
from datetime import datetime, timedelta
from typing import Callable

import holidays

# TODO: This should be a helper object not an object i also instantiate, methinks 
# TODO: Actually its fine, but real i think it should be called daydata instead
class api:
    def __init__(self, date: datetime) -> None:
        self.date = date

    def dayofyear(self):
        return self.date.timetuple().tm_yday

    def hash(self, timed = timedelta(0)):
        return (self.date + timed).strftime("%Y%m%d%H%M")

    def hour(self):
        return self.date.hour

    def datetime(self):
        return self.date

    def dayofweek(self):
        return self.date.weekday()

    def absweek(self):
        return (self.date - datetime(1970, 1, 1)).days // 7

    def week(self):
        return self.date.isocalendar().week

    def year(self):
        return self.date.year

    def month(self):
        return self.date.month

    def weekofmonth(self):
        return (self.date.day - 1) // 7 + 1

    def islastdayofyear(self):
        return self.date.month == 12 and self.date.day == 31

    def islastdayofmonth(self):
        return self.date.day == calendar.monthrange(self.date.year, self.date.month)[1]

    def daystoendofmonth(self):
        return calendar.monthrange(self.date.year, self.date.month)[1] - self.date.day

    def daystoendofyear(self):
        return (datetime(self.date.year, 12, 31) - self.date).days

    # holidays.Australia(state="ACT", years=self.date.year)
    def ispublicholiday(self, holidaylist):
        return self.date.date() in holidaylist
