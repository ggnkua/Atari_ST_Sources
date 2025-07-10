/*
		Konvertiert Cybersculpt 3D2-Files in das POV-Sourceformat.

		(c) Juni 1994 Jochen Knaus
									Nickeleshalde 19
									88400 Biberach
									07351 / 24483

		Datum:				27.7.1994
		Update:				30.9.1994
		Version:			1.20

		Dieses Konvertierprogramm ist Freeware, im Geiste des POV.
		Irgendwann demnÑchst wird's auf "smooth triangles" erweitert.

		GegenÅber Versionen <=1.01 wurde das Kommandozeilenformat geÑndert.
		Die Files vertragen sich jetzt auch mit POV 2.x (Åber Option "-v2").
		
		Es kann nun auch eine "bounded_by" Optimierung erzeugt werden.
		Ab Version 1.2: Schneller und kleiner...

		Aufruf:	CYB_POV -s<source> -d<destin> -n<objektnamen> -v<povversion>
										-b<mode>
*/

#include<tos.h>
#include<stdio.h>
#include<string.h>
#include<portab.h>
#include<stdlib.h>
#include<limits.h>

#define VERSION_A	1
#define VERSION_B 2
#define	PATHLEN	256+1

int	abbruch( void );

/* Filehandles global... */
int source, destin;

int	main( int argc, char *argv[] )
{
	WORD					header[128], anz_obj, anz_punkte, anz_facetten,
								*punkte, *facetten;
	char					obj_name[10], buffer[2560], buffer2[256],
								buffer3[4] = { '}', 13, 10, 0 },
								def_file[PATHLEN] = "STD.POV", def_name[64] = "DEFOBJ",
								source_file[PATHLEN], minus[2] = { '-', 0 }, nullos[2] = { 0 },
								*vorzeichen[6];
	register int	i, j, m;
	int						pov_mode = 1, bounds = 0;					/* POV-Version. */
	int						wandel[6], minmax[6];

	puts( "" );
	printf( "3D2->POV Converter vers. %d.%d, (c) 1994 by Jochen Knaus (AURA), Freeware.\n",
					VERSION_A, VERSION_B );
	puts( "" );

	if( argc <= 1 ) return( -1 );									/* Keine Parameter ? */

	for( i=1, source_file[0] = '\0' ; i < argc ; i++ )
	{
		if( (argv[i])[0] == '-' )										/* Parameter ? */
		{
			switch( (argv[i])[1] )
			{
				/* Zielfile ? */
				case	'd':	strncpy( def_file, argv[i]+2, 127 ); break;
				/* Objektnamen ? */
				case	'n':	strncpy( def_name, argv[i]+2, 63 ); break;
				/* Sourcefile ? */
				case	's':	strncpy( source_file, argv[i]+2, 127 ); break;
				/* POV-Version ? */
				case	'v':	pov_mode = (int) ((argv[i])[2] - '0'); break;
				/* Grenzbox berechnen. */
				case	'b':	bounds = (int) ((argv[i])[2] - '0') ; break;
			}
		}
	}

	if( strlen( source_file ) == 0 )							/* Kein 3D2-File angegeben ? */
	{ puts( "No source (3D2) file." );
		return( -1 ); }

	/* Quelldatei îffnen. */
	if( ( source = Fopen( source_file, FO_READ ) ) < 0 )
	{	puts( "Cannot open sourcefile. ");
		return( source ); }

	/* Zieldatei erzeugen. */
	if( ( destin = Fcreate( def_file, (int) 0 ) ) < 0 ) 
	{	puts( "Cannot create destinationfile." );
		return( destin ); }

	/* Header lesen. */
	if( Fread( source, (long) 256, header ) < 0 ) return( abbruch() );

	if( header[0] != 15618 ) 											/* 3D2-File ? */
	{	puts( "Kein 3D2 File..." );
		return( abbruch() ); }

	anz_obj = header[1];
	printf( "%s: convert %d object(s).\n\n", source_file, anz_obj );

	sprintf( buffer, "#declare %s = union {%s", def_name, &buffer3[1] );
	Fwrite( destin, strlen(buffer), buffer );

	if( bounds != 0 )															/* Grenzwerte initialisieren. */
	{
		minmax[0] = INT_MAX; minmax[1] = INT_MIN;
		minmax[2] = INT_MAX; minmax[3] = INT_MIN;
		minmax[4] = INT_MAX; minmax[5] = INT_MIN;
	}

	for( i=0 ; i<anz_obj ; i++ )									/* Alle Objekte ! */
	{
		Fread( source, (long) 9, obj_name );				/* Objektnamen */
		Fread( source, (long) 2, &anz_punkte );

		if( anz_punkte > 0 )
		{
			/* Speicher fÅr Punkte reservieren. */
			if( ( punkte = malloc( (long) (anz_punkte * 6) ) ) == NULL )
				return( abbruch() );
			else
				Fread( source, (long) anz_punkte*3*2, punkte ); /* Punkte einlesen. */

			if( bounds != 0 )										/* Objektgrenzen feststellen ? */
			{
				for( j = 0 ; j < anz_punkte ; j++ )		/* Objektextremas festellen. */
				{
					if( punkte[j*3+0] < minmax[0] ) minmax[0] = punkte[j*3+0];
					if( punkte[j*3+0] > minmax[1] ) minmax[1] = punkte[j*3+0];
					if( punkte[j*3+1] < minmax[2] ) minmax[2] = punkte[j*3+1];
					if( punkte[j*3+1] > minmax[3] ) minmax[3] = punkte[j*3+1];
					if( punkte[j*3+2] < minmax[4] ) minmax[4] = punkte[j*3+2];
					if( punkte[j*3+2] > minmax[5] ) minmax[5] = punkte[j*3+2];
				}
			}

			/* Anzahl Facetten. */
			Fread( source, (long) 2, &anz_facetten );

			printf( "'%s' %d facettes: ", obj_name, anz_facetten );

			/* Speicher fÅr Dreiecke. */
			if( ( facetten = malloc( (long) (anz_facetten * 8) ) ) == NULL )
			{	free( punkte ); return( abbruch() ); }
			else
				/* Facetten einlesen. */
				Fread( source, (long) anz_facetten*4*2, facetten );

			/* Facetten konvertieren. */
			for( j = 0, buffer[0] = '\0' ; j<anz_facetten ; j++ )
			{
				strcat( buffer, " triangle{" );

				/* Punkte wandeln... 2 Stellen Nachkomma reichen (/100), weitere
					 Verkleinerung muû POV Åbernehmen... */
				for( m=0 ; m<3 ; m++ )
				{
					wandel[0] = (punkte[facetten[j*4+m]*3+0]);			/* x */
					wandel[1] = (punkte[facetten[j*4+m]*3+1]);			/* y */
					wandel[2] = (punkte[facetten[j*4+m]*3+2]);			/* z */
					wandel[3] = abs( wandel[0] );										/* FÅr Nachkomma... */
					wandel[4] = abs( wandel[1] );
					wandel[5] = abs( wandel[2] );
					if( wandel[0] < 0 ) vorzeichen[0] = minus; else vorzeichen[0] = nullos;
					if( wandel[1] < 0 ) vorzeichen[1] = minus; else vorzeichen[1] = nullos;
					if( wandel[2] < 0 ) vorzeichen[2] = minus; else vorzeichen[2] = nullos;

					if( pov_mode == 1 )										/* POV vers.1 : Keine Kommas */
						sprintf( buffer2, "<%s%d.%d %s%d.%d %s%d.%d>",
											vorzeichen[0], wandel[3] / 100, wandel[3] % 100,
											vorzeichen[1], wandel[4] / 100, wandel[4] % 100,
											vorzeichen[2], wandel[5] / 100, wandel[5] % 100 );
					else
						sprintf( buffer2, "<%s%d.%d,%s%d.%d,%s%d.%d>",
											vorzeichen[0], wandel[3] / 100, wandel[3] % 100,
											vorzeichen[1], wandel[4] / 100, wandel[4] % 100,
											vorzeichen[2], wandel[5] / 100, wandel[5] % 100 );

					strcat( buffer, buffer2 );
				}

				strcat( buffer, buffer3 );

				if( j%10 == 0 )															/* Alle 10 Dreiecke schreiben. */
				{
					printf( "." );
					Fwrite( destin, strlen(buffer), buffer );
					buffer[0] = '\0';
				}
			}

			if( strlen( buffer ) > 0 )										/* Restlichen Punkte schreiben. */
				Fwrite( destin, strlen(buffer), buffer );

			free(punkte); free(facetten);
		}

		puts( " done." );
	}

	if( bounds != 0 )																	/* <bounded_by> schreiben. */
	{
		wandel[0] = abs( minmax[0] ); wandel[1] = abs( minmax[1] );
		wandel[2] = abs( minmax[2] ); wandel[3] = abs( minmax[3] );
		wandel[4] = abs( minmax[4] ); wandel[5] = abs( minmax[5] );
		if( minmax[0] < 0 ) vorzeichen[0] = minus; else vorzeichen[0] = nullos;
		if( minmax[1] < 0 ) vorzeichen[1] = minus; else vorzeichen[1] = nullos;
		if( minmax[2] < 0 ) vorzeichen[2] = minus; else vorzeichen[2] = nullos;
		if( minmax[3] < 0 ) vorzeichen[3] = minus; else vorzeichen[3] = nullos;
		if( minmax[4] < 0 ) vorzeichen[4] = minus; else vorzeichen[4] = nullos;
		if( minmax[5] < 0 ) vorzeichen[5] = minus; else vorzeichen[5] = nullos;

		if( pov_mode == 1 )
			sprintf( buffer, " bounded_by{box{<%s%d.%d %s%d.%d %s%d.%d><%s%d.%d %s%d.%d %s%d.%d>}}",
								vorzeichen[0], wandel[0] / 100, wandel[0] % 100,
								vorzeichen[2], wandel[2] / 100, wandel[2] % 100,
								vorzeichen[4], wandel[4] / 100, wandel[4] % 100,
								vorzeichen[1], wandel[1] / 100, wandel[1] % 100,
								vorzeichen[3], wandel[3] / 100, wandel[3] % 100,
								vorzeichen[5], wandel[5] / 100, wandel[5] % 100 );
		else
			sprintf( buffer, " bounded_by{box{<%s%d.%d,%s%d.%d,%s%d.%d><%s%d.%d,%s%d.%d,%s%d.%d>}}",
								vorzeichen[0], wandel[0] / 100, wandel[0] % 100,
								vorzeichen[2], wandel[2] / 100, wandel[2] % 100,
								vorzeichen[4], wandel[4] / 100, wandel[4] % 100,
								vorzeichen[1], wandel[1] / 100, wandel[1] % 100,
								vorzeichen[3], wandel[3] / 100, wandel[3] % 100,
								vorzeichen[5], wandel[5] / 100, wandel[5] % 100 );

		Fwrite( destin, strlen( buffer ), buffer );
		buffer[0] = 13; buffer[1] = 10; buffer[2] = '\0';
		Fwrite( destin, 2, buffer );
	}

	Fwrite( destin, strlen(buffer3), buffer3 );
	Fclose( source ); Fclose( destin );
	return( 0 );
}

int abbruch()
{
	Fclose( source );
	Fclose( destin );
	return( -1 );								/* Gemdosfehler: <0 */
}