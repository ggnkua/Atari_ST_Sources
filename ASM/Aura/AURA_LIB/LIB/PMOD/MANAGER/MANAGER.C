/*	PMOD Manager.

		Startdatum:			2.6.1994
		Letzes Update:	5.6.1992
		Autor:					Jochen Knaus
		Aka:						BDCannibal / AURA (Independent)
		Version:				1.00
		Compiler:				Pure-C
		Copyright:			Keines, allerdings ist Verkauf (auch einer geÑnderten Version)
										verboten. énderungen mÅssen dokumentiert werden, geÑnderte
										Versionen dÅrfen nur MIT Source und meinem Originalmanager
										gespreaded werden !
		Bemerkung:			Alles andere als glorreich programmiert, aber: ein Tool
										un alles sollte schnell, schnell, schnell gehen, auch wenn
										die Eleganz und vorallem die Cleanness leidet...
		Bemerkungen 2:	Libraryverwaltung noch auf 200 Mods begrenzt, da keine dyna-
										mische Verwaltung der eingelesenen DatensÑtze, das ist auch
										das, was ich wohl als nÑchstes einbauen werde, wenn ich mal
										eine eigene Lib habe, die die 200 Mods sprengt.
		Bemerkungen 3:	Das ARGV-Format mit den erweiterten Kommandozeilen wird
										noch nicht unterstÅtzt, da 127 Zeichen fÅr zwei Fileangaben,
										auch mit Pfaden ausreichen sollten, da wahrscheinlich niemand
										seine Library unter 12 Ornder tief in seinem Directorydsch-
										ungel vergrÑbt.
*/

#include<tos.h>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

#define	true	-1
#define false	0

#define MAX_MODS	200								/* Noch keine dynamische Speicherverwaltung. */

typedef struct
{
	char	modul[16];
	char	autor[16];
	unsigned int		startdatum;
	unsigned int		update;
	unsigned int		version;
	char	hardware[12+1];
	long	laenge;
	char	file[14];										/* Nix isch mit langen Filenamen... */
}header;

int		help( void );									/* Gibt Helptext aus. */
int		convert( char *, char * );		/* Konvertiert PRG. */
int		list( char *, char *, int );	/* Listet Module in bestimmten Pfad auf. */
int		chk_file( void );							/* Gibt Fileinformationen aus. */
int		crypt( char * );							/* Lîscht PMOD-Header in fertigem PRG */

DTA			_dta;
header	lib[MAX_MODS+1];
int			anzahl = 0;
char		versione[5] = {"1.00"};

/* Hardwarekennungen... */
char		hardwares[] = {"D12BFEVvTYtMAfHMCNVRPSLp"};
char		*hards[]		= {"DSP56k", "68881-FPU", "68882-FPU", "Blitter",
											 "Falcon-Audio", "STE-Audio", "Falcon-Video", "STE-Video",
											 "TT-Video", "YM-2149", "ACIA-6850", "ACIA-Midi",
											 "Ajax", "FDC-1772", "HDD", "MFP",
											 "Clock", "NVM-Ram", "VME-Bus", "ROM-Port",
											 "Parallel", "Seriell", "LAN", "PMMU" };

int main( int argc, char *argv[] )
{
	char		commando[4], file1[128], file2[128];

	printf("\nPMOD-Manager Version %s: (C) 1994 by Jochen Knaus\n%s\n\n",
					versione,
					 "                               AURA: Software fÅr Psychopathen !!!");

	file1[0] = '\0'; file2[0] = '\0';

	if( argc <= 1 )									/* Ohne Angaben: HELP-Page zeigen */
		return( help() );

	strncpy( commando, argv[1], (size_t) 3 );
	if( argc>2 ) strcpy( file1, argv[2] );
	if( argc>3 ) strcpy( file2, argv[3] );

	Fsetdta( &_dta );											/* Neuen DTA-Buffer setzen (global) */

	/* <-c> Konvertiert PC-relatives Programm in PMOD File */
	if( strcmp( commando, "-c" ) == 0 )
		return( convert( file1, file2 ) );

	/* <-l> Listet Module in bestimmtem Directory */
	if( strcmp( commando, "-l" ) == 0 ) return( list( file1, file2, false ) );

	/* <-x> Listet Module mit allen Infos auf. */
	if( strcmp( commando, "-x" ) == 0 ) return( list( file1, file2, true ) );

	/* <-y> Lîscht PMOD Header in Programmfile. */
	if( strcmp( commando, "-y" ) == 0 ) return( crypt( file1 ) );

	puts( "Unbekanntes Kommando..." );
	Crawcin();
	return( false );								/* Falsches Kommando */
}

  /*************************************************************/
 /* öberschreibt alle PMOD-Header in einem Programm mit MÅll. */
/*************************************************************/
int	crypt( char *file )
{
	int		file_handle, anz_found = 0;
	char	*memory, wandel[6];
	long	i, m;

	if( Fsfirst( file, 0 ) < 0 )
		return( false );

	if( ( file_handle = Fopen( file, FO_READ ) ) < 0 )
		return( false );

	memory = malloc( _dta.d_length );			/* Ganzes File laden... */

	if( Fread( file_handle, _dta.d_length , memory ) < 0 )
	{
		free( memory );
		return( false );
	}

	if( Fclose( file_handle ) < 0 )				/* File schlieûen */
	{
		free( memory );
		return( false );
	}

	srand( Tgettime() );												/* Randomizer starten */

	for( i=0, wandel[4]=0 ; i<_dta.d_length; i++ )
	{
		wandel[0] = memory[i];		wandel[1] = memory[i+1];
		wandel[2] = memory[i+2];	wandel[3] = memory[i+3];
		if( strcmp( wandel, "PMOD" ) == 0 )
			for( m=0, anz_found++ ; m<52 ; m++ )		/* 52 Bytes Åberschreiben. */
				strncpy( &memory[i+m], itoa( rand(), &memory[i+m], m/2 ), 2 );
	}

	printf("\n\nAnzahl gefundene PMOD-Header: %d", anz_found );

	file_handle = Fopen( file, FO_WRITE );			/* File geÑndert zurÅck */
	Fwrite( file_handle, _dta.d_length , memory );
	Fclose( file_handle );

	free( memory );
	Crawcin();
	return( true );
}

   /*************************************************************/
  /* Lîscht Header und Symboltabelle eines pc-relatives Prgs,  */
 /* testet aber vorher auf dessen "RelativitÑt"...					  */
/*************************************************************/
int	convert( char *pfad1, char *pfad2 )
{
	int		file_handle;
	long	longus = 28, longus_sym;
	int		*memory;

	if( Fsfirst( pfad1, 0 ) < 0 )
		return( false );

	if( ( file_handle = Fopen( pfad1, FO_READ ) ) < 0 )
		return( false );

	memory = malloc( _dta.d_length );			/* Ganzes File laden... */

	if( Fread( file_handle, _dta.d_length , memory ) < 0 )
	{
		free( memory );
		return( false );
	}

	if( Fclose( file_handle ) < 0 )				/* File schlieûen */
	{
		free( memory );
		return( false );
	}

	if( memory[0] != 24602 )							/* Existiert Headerbranch ? */
	{
		free( memory );
		puts( "Kein Programmfile !!!" );
		Crawcin();
		return( false );
	}

	/* BSS-Grîûe muû 0 betragen, sondst nicht PC-relativ ! */
	if( memory[5] != 0 || memory[6] != 0 )
	{
		printf( "\nProgramm nicht PC-relativ, BSS-Segment: $%x%x Bytes.\n", memory[5], memory[6] );
		free( memory );
		Crawcin();
		return( false );
	}

	longus += (long)(memory[1])*65536 + (long) memory[2];	/* Grîûe Textsegment */
	longus += (long)(memory[3])*65536 + (long) memory[4];	/* Grîûe Datensegment */
	longus_sym = longus - 28;															/* Grîûe ohne Symboltabelle und Header */
	longus += (long)(memory[7])*65536 + (long) memory[8];	/* Grîûe Symboltabelle */

	if( ( (long)(memory[longus/2])*65536 + (long)memory[longus/2+1] ) != 0 )
	{
		puts( "Programm nicht PC-relativ, Reloziertabelle vorhanden !" );
		free( memory );
		Crawcin();
		return( false );
	}

	if( strlen(pfad2) <= 0 )
	{
		puts( "Kein Zielfile..." );
		free( memory );
		Crawcin();
		return( false );
	}

	if( ( file_handle = Fcreate( pfad2, 0 ) ) < 0 )
	{
		free( memory );
		return( false );
	}

	/* File ohne Header (28 Bytes) und Symboltabelle sichern. */
	if( ( Fwrite( file_handle, longus_sym, &memory[14] ) ) < 0 )
	{
		free( memory );
		return( false );
	}

	printf( "\nKonvertierung %s -> %s nahm ein grÅnes Ende:\n%s nun pc-relativ und ohne Header und Symboltabelle..."
					, pfad1, pfad2, pfad2 );
	Crawcin();
	free( memory );

	return( Fclose( file_handle ) );
}

  /***************************/
 /* VerÑuûert Minihelppage. */
/***************************/
int help()							/* Einblendung Hilfetext. */
{
	puts("");
	puts("Kommando:  <-x> <source> <destination>");
	puts("");
	puts("Kommandos:");
	puts("    -c : Konvertiert <source> -> <destination>");
	puts("    -l : Auflistung aller Files im Pfad <source> Åber Device <destination>");
	puts("    -x : Wie <-l>, aber mit Informationen zur Hardware.");
	puts("    -y : öberschreibt alle PMOD-Header in einem Programm mit MÅll.");
	Crawcin();
	return( false );
}

	/*************************************************************************/
 /* Listet alle Module in bestimmtem Pfad Åber bestimmte File/Device auf. */ 
/*************************************************************************/
int list( char *pfad, char *pfad2, int mode )		/* Listet alle Module in einem Pfad auf. */
{
	char	path[128], *poi;
	int		anz = 0, i, m, anz_hw;
	FILE	*handle;

	if( strlen( pfad ) == 0 )			/* Pfadangaben ? */
		Dgetpath( path, (int) 0 );	/* nein => aktuelles Laufwerk */
	else
	{
		strcpy( path, pfad );
		if( Dsetpath( path ) < 0 )	/* ja => holen und setzen */
		{
			puts( "Illegale Pfadangabe !" );
			return( false );
		}
	}

	if( Fsfirst( "*.INC", 0 ) < 0 )
		return( false );						/* Kein einzigstes File */

	do														/* Alle Files durchchecken... */
		anz += chk_file();					/* File checken. */
	while( ( Fsnext() == 0 ) || ( anz >= MAX_MODS ) );

	if( anz >= MAX_MODS )
		printf("<manager> verwaltet nur %d Module, Anzahl erreicht, break.", MAX_MODS );

	if( strlen( pfad2 ) <= 0 )		/* Device/Datei angegeben ? */
		strcpy( pfad2, "con:" );		/* Fehlt: Console als AusgabegerÑt */

	if( ( handle = fopen( pfad2, "w" ) ) == NULL )
		return( false );

	printf( "Writing list to: '%s'\n", pfad2 );
	fprintf( handle, "\nPMOD-Manager, (c) June 1994, Jochen Knaus, BDC/AURA\n\n" );

	for( i=0 ; i<anz ; i++ )
	{
		fprintf( handle, "%12s : <%15s> by %15s, ver. %.2u.%.2u - %li Bytes.\n",
						 lib[i].file, lib[i].modul, lib[i].autor,
						 lib[i].version/100, lib[i].version%100,
						 lib[i].laenge );

		if( mode )													/* Zusatzangaben erwÅnscht ??? */
		{
			fprintf( handle, "                    Startdatum: %.2u/19%.2u, Letztes Update: %.2u/19%.2u\n",
							 lib[i].startdatum/100, lib[i].startdatum%100,
							 lib[i].update/100, lib[i].update%100 );
			fprintf( handle, "                    CPU: 680%c%c  Hardware:",
							 lib[i].hardware[0], lib[i].hardware[1] );

			for( m = 2, anz_hw = 0 ; m < 12 ; m++ )
				if( ( poi = strchr( hardwares, lib[i].hardware[m] ) ) != NULL )
				{
					anz_hw++;
					fprintf( handle, " %s", hards[poi-hardwares] );
				}

			if( anz_hw == 0 )
				fprintf( handle, " ---\n\n" );
			else
				fprintf( handle, "\n\n" );
		}
	}

	fprintf( handle, "\nPMODfiles in '%s'= %d\n", path, anz );
	fclose( handle );												/* Vor Taste schlieûen wegen Bufferung */

	if( strcmp( pfad2, "con:" ) == 0 )			/* Bei Consolenausgabe auf Taste */
		Crawcin();														/* warten. */

	return( true );
}

   /*************************************************************************/
  /* Testet File, welches gerade im DTA-Buffer genannt ist, ob es im PMOD- */
 /* Format vorliegt...  																									*/
/*************************************************************************/
int	chk_file()									/* Checkt File und gibt Angaben aus... */
{																/* Hier werden die TOS-Filerouts benutzt */
	int		file_handle, i;
	char	mem[1024], *controll, output[255], wandel[8];

	sprintf( output, "%12s - ", _dta.d_fname );

	if( ( file_handle = Fopen( _dta.d_fname, (int) 0 ) ) < 0 )
		return(0);

	if( Fread( file_handle, (long) 1024, mem ) < 0 )
		return(0);

	if( Fclose( file_handle ) < 0 )
		return(0);

	/* Kennung im Speicher suchen, ween gefunden, File auswerten. */
	for( i=0 ; i<1024-4 ; i++ )
		if( ( controll = strstr( &mem[i], "PMOD" ) ) != NULL )
		{
			lib[anzahl].laenge = _dta.d_length;
			strncpy( lib[anzahl].file, _dta.d_fname, 14);

			strncpy( lib[anzahl].modul, controll+4, (int) 16 );
			strncpy( lib[anzahl].autor, controll+20, (int) 16 );
			lib[anzahl].startdatum = atoi( strncpy( wandel, controll+36, 4 ) );
			lib[anzahl].update = atoi( strncpy( wandel, controll+40, 4 ) );
			lib[anzahl].version = atoi( strncpy( wandel, controll+44, 4 ) );
			strncpy( lib[anzahl++].hardware, controll+48, (int) 12 );

			return(1);
		}

	strcat( output, "Illegales Modulformat..." );
	puts( output );
	return(0);
}