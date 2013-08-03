/*  clock.h - general header file for clock drivers			*/



/*
**  TIME - structure for passing time and date info to and from drivers
*/

#define	TIME	struct _TimStruct

TIME
{
	int	ti_sec ;	/*  seconds      (0-59)			*/
	int	ti_min ;	/*  minutes      (0-59)			*/
	int	ti_hour ;	/*  hours        (0-23)			*/
	int	ti_daymo ;	/*  day of month (1-31)			*/
	int	ti_daywk ;	/*  day of week  (1-7)		Sun = 1	*/
	int	ti_mon ;	/*  month of year(1-12)			*/
	int	ti_year ;	/*  yr of century(0-99)			*/
} ;

/*
**  ti_year is the year in the current century.
**
**  the time indicated in this structure is the system base time.  If the
**	current implementation is a multi-user type system, or one in a
**	widely distributed network, then the base time should be something 
**	based on GMT, with the system converting to local time as needed.  
**	If, however, the implementation is a simple non-networking machine,
**	the base time may be local time.
**
**  the driver does not know anything about normal calendar arithmetic or
**	daylight savings time, or what century it is (that is up to the 
**	system, or anything other than keeping an increment in ms, seconds, 
**	minutes, etc from the base time with which it was
**	initialized.
*/

