///////////////////////////////////////////////////////////////////////////////
// filename:    wTime.uc
// revision:    100
// authors:     various UnrealWiki members (http://wiki.beyondunreal.com)
//              http://wiki.beyondunreal.com/WUtils
///////////////////////////////////////////////////////////////////////////////

class wTime extends Object exportstructs;

struct DateTime
{
  var int year,month,day,hour,minute,second;
};

static final function int mktime(int year, int mon, int day, int hour, int min, int sec)
{
	mon -= 2;
	if (mon <= 0) {	/* 1..12 -> 11,12,1..10 */
		mon += 12;	/* Puts Feb last since it has leap day */
		year -= 1;
	}
	return (((
	    (year/4 - year/100 + year/400 + 367*mon/12 + day) +
	      year*365 - 719499
	    )*24 + (hour-1) /* now have hours */
	   )*60 + min  /* now have minutes */
	  )*60 + sec; /* finally seconds */
}

static final function string date(string format, optional int year, optional int mon, optional int day, optional int hour, optional int min, optional int sec)
{
  local array<string> f,t;
  f.length = 12;
  t.length = 12;
  f[0] = "yyyy";
  t[0] = Right("0000"$year, 4);
  f[1] = "yy";
  t[1] = Right("00"$year, 2);
  f[2] = "mm";
  t[2] = Right("00"$mon, 2);
  f[3] = "m";
  t[3] = Right("0"$mon, 1);
  f[4] = "dd";
  t[4] = Right("00"$day, 2);
  f[5] = "d";
  t[5] = Right("0"$day, 1);
  f[6] = "hh";
  t[6] = Right("00"$hour, 2);
  f[7] = "h";
  t[7] = Right("0"$hour, 1);
  f[8] = "nn";
  t[8] = Right("00"$min, 2);
  f[9] = "n";
  t[9] = Right("0"$min, 1);
  f[10] = "ss";
  t[10] = Right("00"$sec, 2);
  f[11] = "s";
  t[11] = Right("0"$sec, 1);
  return class'wString'.static.StrReplace(format, f, t);
}

// number of seconds between Later and Earlier
static final function int SpanSeconds(DateTime Later, DateTime Earlier)
{
  return mktime(later.year, later.month, later.day, later.hour, later.minute, later.second)-mktime(Earlier.year, Earlier.month, Earlier.day, Earlier.hour, Earlier.minute, Earlier.second);
}

// Same as date but accepts DateTime
static final function string date2(string format, DateTime dt)
{
  return date(format, dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
}

// Returns true if it's a leap year
static final function bool isLeap(int year)
{
  if ((year%100) == 0)
  {
    return ((year%400) == 0);
  }
  return ((year%4) == 0);
}

// returns the duration broken down into minutes/ hours/ days/ months/ years
static final function DateTime duration(int seconds)
{
  local DateTime dt;
  dt.year = (seconds / 31536000);
  seconds = seconds % 31536000;
  dt.month = (seconds / 2628000);
  seconds = seconds % 2628000;
  dt.day = (seconds / 86400);
  seconds = seconds % 86400;
  dt.hour = (seconds / 3600);
  seconds = seconds % 3600;
  dt.minute = (seconds / 60);
  dt.second = seconds % 60;
  return dt;
}

// returns how many years/months/days/hours/minutes and x number of seconds is
static final function DateTime Stats(int seconds)
{
  local DateTime dt;
  dt.year = (seconds / 31536000);
  dt.month = (seconds / 2628000);
  dt.day = (seconds / 86400);
  dt.hour = (seconds / 3600);
  dt.minute = (seconds / 60);
  dt.second = seconds;
  return dt;
}
