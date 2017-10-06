/********************************************************************/
/* MAKEORPH.C														*/
/********************************************************************/
/* MAKE ORPHAN	- verwaiste Cluster erstellen						*/
/*																	*/
/* (C)1991 Mathias Tobollik	fÅr das TOS-Magazin						*/
/*																	*/
/********************************************************************/
/* Diese kleine Programm manipuliert die FATs eines Laufwerkes		*/
/* und erzeugt genau 20 verwaiste Cluster. Damit kann man die 		*/
/* Funktion von ORPHAN.PRG testen.									*/
/*																	*/
/* Vorraussetzungen:												*/
/*																	*/
/*		- auf der Partition mÅssen mindestens 20 Cluster unbelegt	*/
/*		  sein														*/
/*		- die FAT muû 16-Bit-Format haben							*/
/********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <ext.h>
#include <hardwork.h>



int main( void )
{
BPB *bpb;		/* BIOS-Parameterblock */
int drive;		/* Laufwerksnummer */
INTELWD *fat;	/* Speicher fÅr die FAT	*/
int orph = 0;	/* Anzahl verwaister Cluster */
int n;			/* ZÑhler */

	/* Erstmal den Tastaturpuffer leeren: */
	while( Cconis() )
		Cnecin();

	printf( "\n Zu MAKEORPH.PRG:\n" );

	printf( "\n Dieses kleine Programm erzeugt auf einer Partition" );
	printf( "\n auf Wunsch genau 20 verwaiste Cluster. Diese kînnen" );
	printf( "\n dann mit dem ORPHAN.PRG wieder entfernt werden." );
	printf( "\n\n VORSICHT:" );
	printf( "\n\n Ohne ORPHAN.PRG (oder ein vergleichbares Utility)" );
	printf( "\n kînnen die durch die Verwendung dieses Programmes" );
	printf( "\n auf Ihrer Festplattenpartition erzeugten Fehler" );
	printf( "\n nur durch ein komplettes Lîschen bzw. Formatieren" );
	printf( "\n dieser Partition behoben werden ! " );
	printf( "\n(TASTE)\n" );
	getch();
	
	do{
		printf( "\n ***** WELCHE PARTITION BEARBEITEN ? *****" );
		printf( "\n (Laufwerksbuchstabe oder ESC fÅr Abbruch)" );
		drive = getch();
		if( drive == 27 )			return( 0 );
		if( drive >= (int)'a' )		drive -= (int)'a';
		if( drive >= (int)'A' )		drive -= (int)'A';
		
		printf( "\n Laufwerk %i.", drive );
	/* Wir nehmen nur vorhandene Laufwerke an: */
	}while( !( (1 << drive) & peek( 1218L ) ) );
	
	bpb = Getbpb( drive );
	
	if( !( 1 & bpb->bflags ) )
	{
		printf( "\n Sorry, dieses Laufwerk hat keine\n 16-Bit-FAT !\n (TASTE)" );
		getch();
		return( 0 );
	}

	/* Speicher fÅr FAT reservieren: */
	if( NULL == (fat = (INTELWD *)malloc( (size_t)( bpb->fsiz * bpb->recsiz ) )) )
	{
		printf( "\n malloc() - Fehler !\n (TASTE)" );
		getch();
		return( 0 );		
	}
	
	/* FAT laden: */
	load_fat( drive, bpb, fat );
	
	for( n = 2; n < bpb->fsiz * bpb->recsiz / 2; n++ )
	{
		if( fat[n] == 0 )	/* unbelegten Cluster suchen */
		{					/* und als belegt markieren	*/
			fat[n] = (INTELWD)mot( 5 );
			orph++;			/* mitzÑhlen */
		}
		if( orph == 20 )	/* bis genau 20 Cluster markiert sind */
			break;
	}
	
	if( orph == 20 )		/* Bei genau 20 Waisen: */
	{
		printf( "\n Manipulierte FAT wird geschrieben..." );
		save_fat( drive, bpb, fat );
		printf( "fertig !\n (TASTE)" );
	}
	else					/* sonst: */
	{
		printf( "\n Nicht genug freie Cluster vorhanden !\n (TASTE)" );
	}
	
	getch();
	free( fat );
	return( 0 );
}



void error( char *s )
{
	printf( "\n FEHLER: %s\n (TASTE)", s );
	getch();
	Pterm( -1 );
}