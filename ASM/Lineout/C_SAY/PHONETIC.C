/*
 * demo des routines odieusement extraites de speaktex.tos
 * - say_copyright: adresse du message de copyright. (on est honnete ou pas)
 * - int say( int mode, char *buf)
 *		mode == 0   -> retour immediat, silence en fin de phrase
 *		mode == 1   -> attend la fin de la phrase
 *		mode == 2   -> retour immediat, sans silence
 *		mode == 3   -> test voix en cours
 *		buf == NULL -> retour sans prononciation
 *		*buf == 0   -> repetition phrase precedente
 *
 * - int set_pitch(int n):   fixe la hauteur du son (20 200).
 * - int set_pitch(int n):   fixe la vitesse.
 */


#include <stdio.h>
#include <stdlib.h>

extern char say_copyright[];
extern int cdecl set_pitch(int);
extern int cdecl set_rate(int);
extern int cdecl say(int mode, ...);

main(argc, argv)
int argc; char **argv;
{
    char buf[256];
    int ret = 0;

    if (argc > 1) {
	buf[0] = '\0';
	while (argc-- > 1) {
		strcat(buf, (++argv)[0]);
		strcat(buf, " ");
	}
	say(1, buf);
	exit(0);
    }
    printf(say_copyright);
    printf("type '=number' for setting pitch, '#number' for setting rate\n");

    for (;;) {

	if (say(3)) {			/* multitachons un peu */
		while (say(3)) {
			int i;
			putchar('.');
			fflush(stdout);
			for (i=0; i< 5000; i++);	/* tempo */
		}
		putchar('\n');
	}
	printf("(%d)Phonetic: ", ret);
	if (gets(buf) == NULL)
		break;
	switch (buf[0]) {
	case '=':
		set_pitch(atoi(&buf[1]));
		break;
	case '#':
		set_rate(atoi(&buf[1]));
		break;
	default:
		ret = say(0, buf);
	}

    }
    say(1, NULL);
}
