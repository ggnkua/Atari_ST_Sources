#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include <sys/time.h>


#ifndef TZ_STRLEN_MAX
# define TZ_STRLEN_MAX  255
#endif /* !defined TZ_STRLEN_MAX */

#ifndef TZ_DEFAULT
# define TZ_DEFAULT	"   "
#endif /* !defined TZ_DEFAULT */

#define ISDIGIT(c)  ((c) >= '0' && (c) <= '9')


static char _tzname[2][TZ_STRLEN_MAX + 1] = { "", "" };
static char	_tzval[TZ_STRLEN_MAX + 1]     = "";
static int	_tzset                        = 0;
static char _tzdflt[]                     = TZ_DEFAULT;


int   _bios_is_gmt = 0;
long  timezone     = 0;
char* tzname[2]    = { _tzdflt, _tzdflt };


static const char* get_tz_name(const char* src, char* dest);
static const char* get_tz_offset(const char* src, int* error);


void
tzset()
{
    const char* tzval = getenv("TZ");

    if (tzval == NULL) {
		tzval = "";
	}

	if (!_tzset || strcmp(_tzval, tzval) != 0) {
		int error;

		_tzset = (strlen(tzval) < sizeof(_tzval));

		if (_tzset) {
			strcpy(_tzval, tzval);
		}

		tzval = get_tz_name(tzval, _tzname[0]);
		tzval = get_tz_offset(tzval, &error);

		if (error) {
			tzname[0] = _tzdflt;
			tzname[1] = _tzdflt;
		} else {
			tzval = get_tz_name(tzval, _tzname[1]);

			tzname[0] = _tzname[0];
			tzname[1] = _tzname[1];
		}
	}
}


const char*
get_tz_name(const char* src, char* dest)
{
	int tzlen = 0;

	if (*src != ':') {
		while (*src != '\0' && *src != ',' && *src != '+' && *src != '-' && !ISDIGIT(*src) && tzlen < TZ_STRLEN_MAX) {
			*dest++ = *src++;
			++tzlen;
		}
	}

	if (tzlen == 0) {
		strcpy(dest, _tzdflt);
	} else {
		*dest = '\0';
	}

	return src;
}


const char*
get_tz_offset(const char* src, int* error)
{
	if (*src == '\0') {
		timezone = 0;
		*error   = 0;
	} else {
		enum { Hours, Minutes, Seconds };

		int  tim[3] = { 0, 0, 0 };
		long mul    = 1L;

		register int i;

		if (*src == '-') {
			mul = -1L;
			++src;
		} else if (*src == '+') {
			++src;
		}

		for (i = 0; i < sizeof(tim) / sizeof(tim[0]); ++i) {
			if (*src == '\0') {
				/* invalid */
				mul = 0L;
			} else if (ISDIGIT(*src)) {
				tim[i] = *src++ - '0';

				if (ISDIGIT(*src)) {
					tim[i] = 10 * tim[i] + *src++ - '0';

					if (ISDIGIT(*src)) {
						/* not more than two digits allowed */
						mul = 0L;
					}
				}
			}

			if (mul == 0L) {
				/* invalid offset format */
				break;
			} else if (*src == ':') {
				/* next field */
				++src;
			} else {
				/* end of offset information */
				break;
			}
		}

		if (tim[Minutes] > 59 || tim[Seconds] > 59) {
			/* invalid minutes or seconds */
			mul = 0L;
		}

		timezone = mul * ((long)tim[Seconds] + 60L * (long)tim[Minutes] + 3600L * (long)tim[Hours]);
		*error   = (mul == 0L);
	}

	return src;
}
