#include <time.h>

char * unites[] = {
	  "ZEHROH", "AXN", "DAX", "TR<WUH", "KAHTR", "SINK", "SIHS", "SEHT",
	  "UXIHT", "NAX1>F","DIHS", "AONZ", "DUXZ", "TREHZ", "KAETOHRZ",
	  "KINZ", "SEHZ", "DIHSEHT", "DIHZWIHT", "DIHZNAX1>F", "VAXEHN" };
char *dizaines[] = {
	  "VAXEHNT", "TRAENT", "KAERAENT", "SINKAENT" };

char *et_une = "EHUXN";
char *HEURES = "AX1R ";
char *ZHEURES = "ZAX1R ";
char *THEURES = "TAX1R ";
char *MINUTES = "MINUXT ";
char *SECONDES = "SAXGOHND ";

extern int cdecl say(int mode, ...);
extern int cdecl set_pitch(int val);
extern int cdecl set_rate(int val);

main(argc, argv)
	int argc;
	char *argv[];
{
	time_t	horloge;
	int	h;
	struct tm *heure;
	char	format = 0;

	while (argc > 1 && argv[1][0] == '-') {
		switch(argv[1][1]) {
		case 'm':	format = 'm'; break;
		case 's':	format = 's'; break;
		case 'r':	set_rate(atoi(argv[1]+2)); break;
		case 'p':	set_pitch(atoi(argv[1]+2)); break;
		}
		argv++;
		argc--;
	}

	time(&horloge);
	heure = localtime(&horloge);

	h = heure->tm_hour;
	dire(h);
	if (h == 2 || h==3 || h == 22 || h == 23)
		say(0, ZHEURES);
	else if (h == 20)
		say(0, THEURES);
	else
		say(0,HEURES);

	dire(heure->tm_min);
	if (format != 'm') {
		say(0, MINUTES);
		if (format != 's') {
			dire(heure->tm_sec);
			say(0, SECONDES);
		}
	}
	say(1,0L);
}
		
dire(nombre)
	int nombre;
{
	if (nombre <= 20)
		say(0, unites[nombre]);
	else {
		int uni = nombre %10;
		say(2, dizaines[nombre/10-2]);
		if (uni == 1)
			say(0,et_une);
		else if (uni)
			say(0,unites[uni]);
	}	
}
