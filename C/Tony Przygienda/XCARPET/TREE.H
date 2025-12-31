/* 'definition'-module von tree.c */

extern double   variables[3]; /* Werte der Variablen */

extern boolean  error;  /* allgemeine Fehlermeldung !fÅr alle Module! */
extern char     errorstring[90]; /* hier wird die Fehlermeldung reingequetscht */

extern double   funcwert(double, double);
extern double   power(double, double);
extern void     give_function(char *,char **);