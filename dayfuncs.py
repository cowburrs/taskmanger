import calendar
from datetime import datetime, timedelta
from typing import Callable

import holidays

def dayofyear(date: datetime):
    return date.timetuple().tm_yday

def datetoint(date: datetime, timed=timedelta(0)):
    return (date + timed).strftime("%Y%m%d%H%M")

def hour(date: datetime):
    return date.hour

def dayofweek(date: datetime):
    return date.weekday()

def absweek(date: datetime):
    return (date - datetime(1970, 1, 1)).days // 7

def week(date: datetime):
    return date.isocalendar().week

def year(date: datetime):
    return date.year

def month(date: datetime):
    return date.month

def weekofmonth(date: datetime):
    return (date.day - 1) // 7 + 1

def islastdayofyear(date: datetime):
    return date.month == 12 and date.day == 31

def islastdayofmonth(date: datetime):
    return date.day == calendar.monthrange(date.year, date.month)[1]

def daystoendofmonth(date: datetime):
    return calendar.monthrange(date.year, date.month)[1] - date.day

def daystoendofyear(date: datetime):
    return (datetime(date.year, 12, 31) - date).days

def ispublicholiday(date: datetime, holidaylist):
    return date.date() in holidaylist
