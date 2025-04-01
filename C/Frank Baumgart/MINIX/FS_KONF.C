/*
	Filesystem-Konfiguration ermitteln

	Version 1.0 vom 23.06.93
	(c) by Frank Baumgart

	EWS: Pure C 1.1
*/


#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <mintbind.h>


long path_max = 0;
long filename_max = 0;


/*
	feststellen, ob MiNT installiert ist
*/
static int mint_active(void)
{
	long stack, *cookie;
	int mint = 0;

	stack = Super(0L);
	cookie = *(long **)0x5A0L;

	if (cookie)
	while (cookie[0])
	{
		if (cookie[0]==0x4D694E54L)
		mint = 1;
		cookie += 2;
	}

	Super((void *)stack);

	return mint;

} /* mint_active **


/*
	verfÅgbare Laufwerke ermitteln
*/
static long get_drives(void)
{
	long stack;
	long drives;

	stack = Super(NULL);

	drives = *(long *)0x4C2;

	/* ohne Diskettenlaufwerke */
	drives &= ~3;

	Super((void *) stack);

	return drives;

} /* get_drives */


/*
	Dateisysteme der Laufwerke ÅberprÅfen
*/
static void chk_drives(long drives)
{
	char path[] = "X:\\";
	long len;
	int n;

	for (n = 2; n < 26; n++)
	{
		if (!(drives & (1L << n)))
			continue;

		path[0] = 'A'+n;

		printf("%s ",path);

		/* maximale LÑnge eines Pfades */
		len = Dpathconf(path,2);
		if (len > path_max)  path_max = len;
		if (len == 0x7fffffffL)
			printf("Pfad: unbegrenzt  ");
		else
			printf("Pfad: %10ld  ",len);

		/* maximale LÑnge eines Dateinamens */
		len = Dpathconf(path,3);
		if (len > filename_max)  filename_max = len;
		if (len == 0x7fffffffL)
			printf("Datei: unbegrenzt");
		else
			printf("Datei: %10ld",len);
		puts("");
	}

	puts("=======================================");

	printf("Maximum:  ");
	if (path_max == 0x7fffffffL)
		printf("unbegrenzt");
	else
		printf("%10ld  ",path_max);
	printf("         ");
	if (filename_max == 0x7fffffffL)
		puts("unbegrenzt");
	else
		printf("%10ld\n",filename_max);

} /* chk_drives */


int main()
{
	if (!mint_active())
	{
		fprintf(stderr,"MiNT nicht installiert");
		exit(1);
	}

	chk_drives(get_drives());

	return 0;
}
