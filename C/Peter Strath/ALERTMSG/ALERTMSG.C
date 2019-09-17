/************************************************************************
  Code that uses a variable argument list to enable a printf like
  routine that displays messages in a GEM alert box.
  
  18/12/95, Peter Strath.
 ************************************************************************/

#include <aes.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>


/*
  Displays an alert box with message.
*/
void AlertMessage
	(
	char * main_string,
	...
	)
{
	va_list ap;
	char alert_buffer[100];
	char whole_string[100];
	
	va_start(ap, main_string);
	vsprintf(whole_string, main_string, ap);
	va_end(ap);
	
	sprintf(alert_buffer, "[1][%s][OK]", whole_string);
	form_alert(1, alert_buffer);
}