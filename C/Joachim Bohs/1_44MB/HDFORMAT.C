/* FORMATIEREN VON HD-DISKETTEN - QUICK&DIRTY VERSION
** Written 1989 by Joachim Bohs and Claus Brod
** (C) 1989 MAXON Computer
*/

#define TURBOC		1				/* 1: TURBO-C */
#define LASERC		0				/* 1: LASER-C */

#include <string.h>
#include <stdio.h>
#include <ctype.h>

#if TURBOC
#	include <tos.h>
#endif
#if LASERC
#	include <osbind.h>
#	include <portab.h>
#endif

#if LASERC
	long	_sysbase;
#endif
#if TURBOC
	long 	*_sysbase = (long *)0x4f2;
#endif

#define  seekrate 	 		0x440L
#define 	_hdv_init 			0x46AL

#define	PUT(a)				putchar(a)
#define	ESC					PUT(27)
#define  SAVE_CURSOR			ESC;PUT('j') /* Cursorpos. retten */
#define 	RESTORE_CURSOR		ESC;PUT('k') /* Cursor positionieren */
#define 	CLS 					ESC;PUT('E') /* L”schen */
#define  CLS_AB_CURSOR		ESC;PUT('J') /* Ab Cursor l”schen */
#define 	HOME					ESC;PUT('H') /* Home */
#define 	REVERSE_VIDEO		ESC;PUT('p') /* Revers an */
#define 	NORMAL_VIDEO		ESC;PUT('q') /* Revers aus */
#define	C_OFF					ESC;PUT('f') /* Cursor aus */
#define 	C_ON					ESC;PUT('e') /* Cursor an */
#define 	FILLER				0L

#define 	CON 					2

#define	SPF					9			/* Sektoren pro FAT */
#define	DIRSIZE				14			/* Platz fr 14*16=224 Eintr„ge */
#define	SPC					1			/* 1 Sektor pro Cluster */

#if TURBOC
#define	WORD					int
#define	UWORD					unsigned int
#define	VOID					void
#define 	UBYTE					unsigned char
#define	FALSE					0
#define	TRUE					(!FALSE)
#define	ULONG					unsigned long
#define	disk_info			DISKINFO
#define	bpb					BPB
#endif

WORD 		os_version = 0;
WORD		side		= 2,
			tracks	= 80;
WORD		drive_typ = 0;		/* 0 = 3.5", 1 = 5.25" */
WORD		spt = 18;			/* Sektoren pro Track */

static UBYTE fat_buffer[SPF*512] =
{
	0
};

#if LASERC					/* Vorw„rtsdeklarationen */
WORD 	formatdisk();
VOID 	step();
WORD 	version();
VOID 	dpoke();
WORD 	*spiral();
UBYTE inkey();
#endif

#if TURBOC					/* Prototypen */
VOID	dpoke(ULONG, WORD);
UBYTE inkey( UBYTE * );
WORD 	errchk( WORD, WORD, UBYTE *, WORD, WORD );
WORD 	*spiral( UWORD, UWORD, UWORD );
WORD	formatdisk( WORD, WORD, WORD );
VOID 	main();
VOID 	d_free( WORD );
VOID 	step( WORD );
WORD 	writeboot( WORD, WORD );
VOID 	marksec(WORD, WORD, WORD, WORD, char *, WORD);
VOID 	header(VOID);
#endif


/* dpoke: Schreibt inhalt.w in adresse */
VOID dpoke( adresse, inhalt )
ULONG adresse;
WORD inhalt;
{
	*(WORD *)adresse = inhalt;
}

/* inkey: Holt bestimmte Tasten */
UBYTE inkey( auswahl )
UBYTE *auswahl;
{
	UBYTE c, i;

	do
	{
		while (!Bconstat(CON));
			c = (UBYTE)Bconin(CON);
		for(i = 0; *(UBYTE *)((ULONG)auswahl+i) != (UBYTE)0; i++ )
			if ( *(UBYTE *)((ULONG)auswahl+i) == c )
				break;

	} while ( !( *(UBYTE *)((ULONG)auswahl+i) == c) );

	return(c);
}

/* header: Gibt Header-Meldung aus */
VOID header()
{
	CLS;
	printf(" \33p============HD-Formatter!============\33q\n");
	printf(" (C) 1989 by Joachim Bohs & Claus Brod\n");
	printf("            TOS-Version %d.%d\n\n",
								os_version>>8, os_version & 0xff);
}

/* errchk: Fehlerbehandlung */
WORD errchk( spur, seite, wo, fehler, drive )
WORD spur, seite, drive;
UBYTE *wo;
WORD fehler;
{
	UBYTE c;
	WORD i;

	if (fehler)
	{
		SAVE_CURSOR;
		if (fehler == -13)
			printf( "\n Schreibschutzfehler beim %s! \n", wo );
		else
			printf( "\n Fehler %d beim %s! \n",fehler, wo );

		printf( " Drive %c: \n", (char)drive+'A' );
		printf( " Spur %d  Seite %d \n\n", spur, seite );
		printf( " [1] weiter \n" );
		printf( " [2] nochmal \n" );
		printf( " [3] raus \n");

		fehler	= 	(WORD)(inkey("123")-'0');
		RESTORE_CURSOR;
		CLS_AB_CURSOR;

		if (fehler < 3) fehler--;

	} /* endif fehler */

	return (fehler);
} /* end errchk() */


/* spiral: Berechnet Spiralisierung */
WORD *spiral( max_side, track, side )
UWORD max_side;
UWORD track;
UWORD side;
{
	UWORD start_sector, i, spiral;
	static WORD sector_field[18];

	spiral = 15;
	if (drive_typ == 1) spiral = 12;
	
	if (max_side == 2)
	{
		start_sector=(1+(((track+1)*max_side-1+side)-1)*spiral) % spt;
		for (i=0; i<spt; i++)
      	sector_field[i] = ((start_sector+i-1) % spt)+1;
	}

	return(&sector_field[0]);
}

/* marksec: Markiert Sektor in der FAT als defekt */
void marksec(track, side, sides, sector, fatbuf, pattern)
WORD track, side, sides, sector, pattern;
char *fatbuf;
{
	WORD logsec, cluster, cluspos;
	WORD firstsec;

	logsec = (track*sides + side) * spt + sector - 1;
	firstsec = 1+SPF*2+DIRSIZE;

	if (logsec >= firstsec)
	{
		cluster = ((logsec - firstsec) / SPC) + 2;
		cluspos = cluster + cluster/2;

		if (cluster % 2)
		{
			fatbuf[cluspos] &= 0x0f;
			fatbuf[cluspos] |= (pattern<<4);
			fatbuf[cluspos + 1] = (pattern>>8);
		}
		else
		{
			fatbuf[cluspos] = (pattern & 0xff);
			fatbuf[cluspos + 1] &= 0xf0;
			fatbuf[cluspos + 1] |= (pattern>>8);
		}
	}
}

/* writeboot: Schreibt Bootsektor und FATs */
WORD writeboot( drive, exflag )
WORD drive, exflag;
{
	static UBYTE boot_buffer[ 512 ] =
	{
 		0xEB, 0x34, 0x90, 0x49, 0x42, 0x4D, 0x20, 0x20,
 		0xBE, 0x00, 0x9C, 0x00, 0x02, 0x01, 0x01, 0x00,
 		0x02, 0xE0, 0x00, 0x40, 0x0B, 0xF0, 0x09, 0x00,
 		0x12, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
 		0x00
 	};

 	static UBYTE cleansector[512] =
 	{
 		0
 	};

	WORD		fehler = 0,
				s, t, i, secs;

	boot_buffer[21] = (UBYTE)0xf0;

	HOME;
	printf("\n\n\n\n\n\n\n\n\n Schreibe Bootsektor\n" );

	secs = tracks * side * spt;

	Protobt( boot_buffer, 0x01000001L, -1, exflag );

	boot_buffer[26] = (UBYTE)side;
	boot_buffer[27] = (UBYTE)0;

	boot_buffer[19] = (UBYTE)(secs % 256);
	boot_buffer[20] = (UBYTE)(secs / 256);
	boot_buffer[24] = (UBYTE)(spt % 256);
	boot_buffer[25] = (UBYTE)(spt / 256);

	do
	{
		fehler = Flopwr( boot_buffer, FILLER, drive, 1, 0, 0, 1 );
		fehler = errchk( 0, 0, " Schreiben des Bootsektors\n", fehler, drive );
	} while ( fehler == 1 );

	if( !fehler )
	{
		fehler = Rwabs(0, 0L, 2, 0, drive);		/* Wechsel anmelden */
		(void) Getbpb( drive );

		printf(" Schreibe FAT\n" );
		do
		{
			for (i = 1+SPF*2; i<= 1+SPF*2+DIRSIZE; i++)
			{
				fehler	= 	Rwabs( 1, cleansector, 1, i, drive );
				fehler	= 	errchk( 0, 1, " Schreiben des Wurzelverzeichnisses\n", fehler, drive );
			}
			fat_buffer[0] = 0xf0;
			fat_buffer[1] = 0xff;
			fat_buffer[2] = 0xff;
			fehler	= 	Rwabs( 1, fat_buffer, 9, 1, drive);
			fehler	= 	Rwabs( 1, fat_buffer, 9, 10, drive);
			fehler	=	errchk( 0, 1, " Schreiben der FATs\n", fehler, drive );
		} while( fehler == 1 );

	} /* endif !fehler */

	return( fehler );
} /* end writeboot() */


/* formatdisk: Disk formatieren */
formatdisk( drive, exflag, fastload )
WORD drive, exflag, fastload;
{
	static UBYTE format_buffer[ 20000 ] =
	{
		0
	};

	WORD 		*bufpnt;
	WORD 		virgin = 0xe5e5,
				fehler = 0,
				intleave = -1,
				s, t, i;
	long		filler;
	ULONG		l_fehler,
				magic	= 0x87654321;
	bpb 		*dummy;

	HOME; C_OFF;

	for (t = tracks-1; t > -1 ; t--)
	{
		for (s = side-1; s > -1; s--)
		{
			HOME;
			printf("\n\n\n\n Formatiere Spur %02d, Seite %1d \n", t, s );
			do
			{
				for (i = 1; i <= spt; i++)
					marksec(t, s, 2, i, fat_buffer, 0 );

				/* Jetzt wird erst richtig formatiert. Ist das fastload-Flag
				** gesetzt, wird ein spezieller Trick eingesetzt, um ein Format
				**	zur erzeugen, das sich auch ohne Fastload-Programm doppelt
				** so schnell l„dt (s. SCHEIBENKLEISTER, Kap. 8). Allerdings
				** vertragen nicht alle Laufwerke Fastload (zu langes Nach-
				** schwingen der Lesek”pfe)!
				** Ist das fastload-Flag gel”scht, wird ab TOS 1.2 Tempo durch
				** Spiralisierung gemacht (Faktor 15, entspricht HYPERFORMAT-
				** Faktor 3). Mit Fastload erreicht man mehr als 40 KB/s, mit
				** Spiralisierung immer noch mehr als 35 KB/s (zum Vergleich:
				** Schnelle Normal-Disks liegen bei 20 KB/s).
				*/
				if (fastload)
				{
					filler = FILLER;
					intleave = 21;
					if (drive_typ == 1)
						intleave = 18;
				}
				else
				{
					if (os_version >= 0x0102)
					{
						filler = (long) spiral( side, t, s );
						intleave = -1;
					}
					else
					{
						filler = FILLER;
						intleave = 1;
					}
				}
				fehler = Flopfmt(format_buffer, filler, drive,
										spt, t, s, intleave,
										magic, virgin);

				if (fehler == -16)
				{
					bufpnt = (WORD *)format_buffer;
					while (*bufpnt)
					{
						HOME;
						printf("\n\n\n\n\n\n \7Fehler auf Spur %d, Seite %d, Sektor %d  \n",
								t,s,*bufpnt);
						marksec(t, s, 2, *bufpnt++, fat_buffer, 0xff7 );
					}
				}
				fehler = errchk( t, s, "Formatieren", fehler, drive );

			} while ( fehler == 1 );

			if (fehler) t = -1;

			} /* endfor side */

		} /* endfor tracks */

	if( !fehler )
	{
		fehler	= 	writeboot(drive, exflag);
		fehler	= 	(int)Rwabs(0, 0L, 2, 0, drive);
	}

	C_ON;
	return(fehler);

} /* end formatdisk() */


/* step: Steprate einstellen */
VOID step(steprate)
WORD steprate;
{
	long hdv_init, old_stack;

	old_stack = Super(NULL);
	dpoke(seekrate, steprate);
	hdv_init = *(ULONG *)_hdv_init;
	(void) Super( (void *)old_stack );

	Supexec(hdv_init);
}


/* d_free: Wieviel Platz haben wir? */
VOID d_free( drive )
WORD drive;
{
	disk_info buf;

	(void) Rwabs(0, 0L, 2, 0, drive);		/* Wechsel anmelden */

	if( Dfree( &buf, drive+1 ) != -46 )
		printf("\n %ld Bytes auf Diskette frei \n\n",
							buf.b_free * buf.b_clsiz * buf.b_secsiz );
	else
		printf("Fehler bei Dfree() \n\n");
}


void main()
{
	UBYTE 	c;
	UBYTE 	*drive_string;
	WORD 		format, nochmal, fastload;
	WORD 		drive, exflag, i;
	long		ssp;

	exflag	= fastload = FALSE ;

	ssp = Super( NULL );
#if TURBOC
	os_version = *(WORD *)(*_sysbase + 2);
#endif
#if LASERC
	os_version = *(WORD *)(_sysbase + 2);
#endif
	(void) Super((void *)ssp);

	drive = 0;
	spt = 18;
	
	do
	{
		header();
		printf("\n \33pL\33qaufwerk:  %c\n", 'A'+drive);
		printf(" \33pD\33qrive-Typ: ");
		if (drive_typ==1)
			printf("5.25\"\n");
		else
			printf("3.5\"\n");
	
		printf(" \33pF\33qastload:  o");
		if (fastload) printf("n\n"); else printf("ff\n");
		printf("\n \33pM\33qach los!\n");
		printf(" \33pQ\33quit\n");

		c = toupper(inkey("LlfFmMqQdD"));

		switch (c)
		{
		case 'L':	drive = 1 - drive;
						break;
		case 'F':	fastload = !(fastload);
						break;
		case 'D':	drive_typ = 1 - drive_typ;
						break;
		case 'M':
						if (drive_typ == 1)
							spt = 15;
						else
							spt = 18;
							
						if (drive == 0)
							drive_string = "A:";
						else
							drive_string = "B:";

						printf("\n Wirklich eine \33p2HD\33q-Disk \n" );
						printf(" in Drive \33p%s\33q formatieren (J/N)?\n\n",
								drive_string );

						c = toupper(inkey("jJnN"));
						if ( c == 'J' )
						{
							step( 0 );
							header();
							(void) formatdisk( drive, exflag, fastload );
							(void) Getbpb( drive );
							d_free(drive);
							Cnecin();
						}
						else
							printf(" Abbruch\n");
						break;
		} /* switch */

	} while (c != 'Q');

} /* end main() */
