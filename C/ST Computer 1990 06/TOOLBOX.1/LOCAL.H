/*
 * Listing 1.1, Datei : local.h
 * Modifikationsdatum : 17-Nov-89
 * Abh„ngigkeiten     : -
 */

typedef short      BOOLEAN;

#define FALSE      0
#define TRUE       1

#define ERROR      (-1L)

#define todigit(ch) ((ch) - '0')

#define isoctal(ch) ((ch) >= '0' && (ch) <= '7')
