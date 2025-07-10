/*  EASYFSEL.H  */

#include <aes.h>
#include <ext.h>
#include <string.h>
#include <stdio.h>
#include <tos.h>

/* Typen */
typedef enum
{
	FALSE, TRUE
}
boolean;

/* Funktionsprototypen */
boolean easy_fsel(char *pfad, char *dateiname, char *text);
void build_filename(char *dest, char *pfad, char *dateiname);
boolean exist(const char *dateiname);
char *get_akt_path(char *path);
boolean get_cookie(char *cookie_name, long *cookie_value);
