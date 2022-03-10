/*
 * version.c
 *
 * Identification strings
 *
 * Defined here as strings to avoid having to keep recompiling everything
 * when the version changes
 */

#include "version.h"

char ANNOUNCE[] = _MAILER_NAME " " _MAILER_VER _MAILER_SER;
char xfer_id[] = _MAILER_SHORTNAME " " _MAILER_VER;
char MAILER_VER[] = _MAILER_VER;
char MAILER_SER[] = _MAILER_SER;
char MAILER_NAME[] = _MAILER_NAME;

char compile_date[] = __DATE__;
char ver_stuff[] = "Compiled on " __DATE__ " at " __TIME__ "\r\n\r\n";
