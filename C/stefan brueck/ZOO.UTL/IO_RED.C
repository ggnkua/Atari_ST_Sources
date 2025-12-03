#include <ctype.h>


char * parse_io_redirection(b,c)
char *b, c;
{
	static char fname[64];
	char *s;
	int i;
	char *strchr();

	if ((s = strchr(b,c)) == (char *) 0L)
		return (char *) 0L;		/* juhu fertig! */

	*s++ = ' ';			/* das haekchen loeschen */
	/*
	 *	fuehrende blanks ueberlesen
	 */
	while ((*s != '\0') && (*s == ' '))
		s++;
	/*
  	 *	s zeigt jetzt auf den filenamen fuer 
	 *	die io_redirection oder auf '\0' 
	 */
	if (*s == '\0')
		return (char *) 0L;

	/*
	 *	den filenamen checken damit nicht so was vorkommt:
	 *	zoo a:I test < >murks
	 *	d.h. umleitung von stdin auf die datei >murks
	 *	
	 *	ersatzlos gestrichen (hehe)
	 */
	
	/*
	 *	den filenamen in grossbuchstaben umwandeln 
	 *	umkopieren und in der kommandozeile loeschen 
	 *	(durch ' ' ersetzen)
	 */

	for (i = 0; (*s != '\n' && *s != ' ' && *s != '\0') ; i++,s++)
	{
		fname[i] = toupper(*s);
		*s = ' ';
	}

	fname[i] = '\0';	/* abschliessendes nullbyte */
	return fname;		/* und fertig */
}
