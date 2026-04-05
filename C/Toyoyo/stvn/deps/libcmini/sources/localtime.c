#include <time.h>
#include <mint/osbind.h>
#include <time.h>


struct tm*
localtime(const time_t* timep)
{
    time_t t = *timep;

    tzset();
	t -= timezone;

    return gmtime(&t);
}
