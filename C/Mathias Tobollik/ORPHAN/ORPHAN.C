/********************************************************************/
/* ORPHAN.C															*/
/********************************************************************/
/* ORPHAN	- verwaiste Cluster finden und entfernen				*/
/*																	*/
/* (C)1991 Mathias Tobollik	fÅr das TOS-Magazin						*/
/*																	*/
/********************************************************************/
/* Verfolgt alle Dateien und Verzeichnisse eines Laufwerks und 		*/
/* notiert sich die belegten Cluster. Falls danach Cluster Åbrig-	*/
/* bleiben, die als benutzt gekennzeichnet sind obwohl sie zu kei-	*/
/* ner Datei gehîren, werden diese verwaisten Cluster in den FATs 	*/
/* auf Wunsch wieder als frei markiert.								*/
/* 																	*/
/********************************************************************/
/* ORPHAN besteht aus mehreren Modulen:								*/
/*																	*/
/* - ORPHAN.C	Die Shell die mit dem Benutzer kommuniziert und den */
/*				Programmablauf steuert								*/
/* - GEM_INIT	An- und Abmeldung beim GEM/VDI						*/
/* - VQ_AES		eine Funktion die testet, ob das AES installiert	*/
/*				ist													*/
/* - OYSTER		die Resource										*/
/* - RESOURCE	die Routinen fÅr die direkte Einbindung der			*/
/*				Resource ins Programm								*/
/* - HARDWORK   die Routinen fÅr das Durchforsten der				*/
/*				Verzeichnisse, Dateien und FATs						*/
/*				(also der eigentlich interessante Teil!)			*/
/********************************************************************/



#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include <vq_aes.h>
#include <vdi.h>
#include <ext.h>
#include <gem_init.h>
#include <resource.h>		/*	Resource - Einbindung	*/
#include <oyster.h>			/*	Resource - Header		*/
#include <oyster.rsh>		/*	Resource - Source		*/
#include <hardwork.h>



/********************************************************************/
/* Makros fÅr Dialogverwaltung:										*/
/********************************************************************/
		/* Status abfragen: */
#define sta(T,O,S)		T[O].ob_state == S
		/* Status verÑndern:	*/
#define set(T,O,S)		T[O].ob_state = S
		/* Auf Textfeld zugreifen: */
#define txt(T,O)		T[O].ob_spec.tedinfo->te_ptext
		/* Auf String zugreifen: */
#define str(T,O)		T[O].ob_spec.free_string


/********************************************************************/
/* Funktionsprototypen:												*/
/********************************************************************/
int get_drive( void );
BPB *bpb_ok( int drive );
int check_drive( DRIVE *d, int drive, BPB *par, INTELWD *fat, INTELWD *dup );
int fix_drive( int drive, BPB *par, INTELWD *dup );
void no_aes( void );
void error( char *s );


/********************************************************************/
/* Globale und externe Variablen:									*/
/********************************************************************/
#include <gem_init.exp>		/* Parameterfelder, Handle-Nummern etc.	*/




/********************************************************************/
/********************************************************************/
/* Hauptprogramm:													*/
/********************************************************************/
/********************************************************************/

int main( void )
{
int drive;			/* Laufwerksnummer */
DRIVE d;			/* Laufwerksinfos */
BPB *par;			/* Zeiger auf BIOS-Parameterblock	*/
INTELWD *fat;		/* die FAT (INTEL-Format!)	*/
INTELWD *dup;		/* und ihr Duplikat */

	/* Erst nachschauen, ob das AES bereit steht: */
	if( ! vq_aes() )	
		no_aes();		/* Nein? Pech fÅr die Waisenkinder!	*/
		
	open_vwork();		/* VDI -  Workstation îffnen	*/

	/* Die eingebundene Resource vorbereiten: */
	rsrc_init( NUM_TREE, NUM_OBS, NUM_FRSTR, NUM_FRIMG,
			rs_strings, rs_frstr, rs_bitblk, rs_frimg, rs_iconblk,
			rs_tedinfo, rs_object, (OBJECT **)rs_trindex,
			(RS_IMDOPE *)rs_imdope);
	
	/* Und weg mit der hÑûlichen Biene: */
	graf_mouse( ARROW, NULL );
	
	/* Nach Laufwerk fragen: */
	while( 0 != (drive = get_drive()) )
	{
		/* BPB lesen und anzeigen: Die FAT muû */
		/* 16-Bit Format haben (Hard- und Ramdisks) */
		if( NULL != (par = bpb_ok( drive )) )
		{
			/* Speicher fÅr FAT und Duplikat reservieren: */
			if( NULL == (fat = (INTELWD *)malloc( (size_t)( par->fsiz * par->recsiz ) )) )
				error( "[3][ malloc() - Fehler ! | malloc() - error ! ][ OK ]" );
			if( NULL == (dup = (INTELWD *)malloc( (size_t)( par->fsiz * par->recsiz ) )) )
				error( "[3][ malloc() - Fehler ! | malloc() - error ! ][ OK ]" );
		
			/* Das Laufwerk wird durchgesiebt: */
			if( check_drive( &d, drive, par, fat, dup ) )
			{
				/* Wenn es verwaiste Cluster gibt, werden sie	*/
				/* hier auf Wunsch auch entfernt:				*/
				fix_drive( drive, par, dup );
			}
			
			/* So, den Speicher brauchen wir jetzt nicht mehr: */
			free( dup );
			free( fat );
		}
	}	
	
	close_vwork();	/* Programm beenden	*/
	return( 0 );	/* (eigentlich ÅberflÅssig) */
}




/********************************************************************/
/* Nach Laufwerk fragen												*/
/********************************************************************/
/* Das Formular mit der Laufwerksauswahl und der Mîglichkeit zum	*/
/* Beenden des Programmes wird aufgebaut und abgefragt.				*/

int get_drive( void )
{
OBJECT *tree;
int drive = 0,			/* Laufwerksnummer */
	fx, fy, fw, fh,		/* Formularkoordinaten */
	ex_objc,			/* Nummer des Exit-Objekts */
	n;

	tree = (OBJECT *)rs_trindex[DRIVESD];
	
	/* Nicht vorhandene Laufwerke ausblenden: */
	for( n = DRIVEC; n <= DRIVEP; n++ )
	{
		if( sta( tree, n, SELECTED ) )
			set( tree, n, NORMAL );
			
		if( ( 1 << (2 + n - DRIVEC) ) & peek( 1218L ) )
			set( tree, n, NORMAL );
		else
			set( tree, n, DISABLED );
	}
	
	/* Formular aufbauen: */
	form_center( tree, &fx, &fy, &fw, &fh );
	form_dial( FMD_START, 0, 0, 0, 0, fx, fy, fw, fh );
	objc_draw( tree, 0, MAX_DEPTH, fx, fy, fw, fh );
	
	/* Dialog ausfÅhren: */
	ex_objc = 255 & form_do( tree, 0 );
	form_dial( FMD_FINISH, 0, 0, 0, 0, fx, fy, fw, fh );
	
	if( ex_objc != QUIT )
		drive = 2 + ex_objc - DRIVEC;
	return( drive );
}



/********************************************************************/
/* BPB besorgen, anzeigen und FAT-Format prÅfen						*/
/********************************************************************/
/* "Tauglich" ist die FAT nur, wenn sie im 16-Bit-Format aufgebaut	*/
/* ist. 12-Bit-FATs gibt es ohnehin nur bei Disketten und auf 		*/
/* manchen c't-Festplatten (sog. "Billiglîsung") mit alter Treiber-	*/
/* software.														*/

BPB *bpb_ok( int drive )
{
OBJECT *tree;
BPB *p;					/* Zeiger auf BIOS-Parameterblock */
int	fx, fy, fw, fh;		/* Formularkoordinaten */

	tree = (OBJECT *)rs_trindex[INFOD];
	
	/* Infos eintragen: */
	p = Getbpb( drive );
	sprintf( str( tree, IRECSIZ ),	"%8i", p->recsiz	);
	sprintf( str( tree, ICLSIZ ),	"%8i", p->clsiz		);
	sprintf( str( tree, ICLSIZB ),	"%8i", p->clsizb	);
	sprintf( str( tree, IRDLEN ),	"%8i", p->rdlen		);
	sprintf( str( tree, IFSIZ ),	"%8i", p->fsiz		);
	sprintf( str( tree, IFATREC ),	"%8i", p->fatrec	);
	sprintf( str( tree, IDATREC ),	"%8i", p->datrec	);
	sprintf( str( tree, INUMCL ),	"%8i", p->numcl		);
	sprintf( str( tree, IBFLAGS ),	"%8i", p->bflags	);
	
	/* Formular aufbauen: */
	form_center( tree, &fx, &fy, &fw, &fh );
	form_dial( FMD_START, 0, 0, 0, 0, fx, fy, fw, fh );
	objc_draw( tree, 0, MAX_DEPTH, fx, fy, fw, fh );
	
	/* Dialog ausfÅhren: */
	form_do( tree, 0 );
	form_dial( FMD_FINISH, 0, 0, 0, 0, fx, fy, fw, fh );
	set( tree, BPBOK, NORMAL );
	
	/* Hat die FAT 16-Bit-Format ? */
	if( 1 & p->bflags )
	{
		return( p );
	}
	else
	{
		form_alert( 1, "[3][ Keine 16-Bit-FAT ! | No 16-Bit-FAT ! ][ OK ]" );
		return( NULL );
	}
}




/********************************************************************/
/* Laufwerk durchchecken:											*/
/********************************************************************/
/* Das logische Laufwerk wird vom Wurzelverzeichnis aus durch-		*/
/* forstet...														*/

int check_drive( DRIVE *d, int drive, BPB *par, INTELWD *fat, INTELWD *dup )
{
OBJECT *tree;
int	fx, fy, fw, fh;		/* Formularkoordinaten */
int n;					/* ZÑhler */

	graf_mouse( BUSYBEE, NULL );

	/* FAT laden und kopieren: */
	load_fat( drive, par, fat );
	memcpy( (void *)dup, (void *)fat, (size_t)( par->fsiz * par->recsiz ) );

	/* Das Durchsuchen des Wurzelverzeichnisses fÅhrt hier auto-	*/
	/* matisch zum Durchforsten der ganzen Partition:				*/
	d->files = d->subdir = d->badclus = d->orphan = 0;
	trace_root( par, fat, d, drive );

	/* Jetzt kînnen wir die defekten und verwaisten Cluster	*/
	/* zÑhlen. Dabei lassen wir die ersten beiden Cluster	*/
	/* aus, da sie eine spezielle Bedeutung haben:			*/
	for( n = 2; n < par->fsiz * par->recsiz / 2; n++ )
	{
		if( mot(fat[n]) > (unsigned int)0 )
		{		
			if( mot(fat[n]) >= 0xfff0 && mot(fat[n]) <= 0xfff7L )
			{
				(d->badclus)++;
			}
			else
			{
				(d->orphan)++;
				/* Der Fehler wird im FAT-Duplikat	*/
				/* schon mal korrigiert:			*/
				dup[n] = 0;
				/* Bei der 0 ist es Åbrigens egal, 	*/
				/* ob sie im INTEL- oder MOTOROLA-	*/
				/* Format geschrieben wird!			*/
			}
		}
	}

	/* Formular vorbereiten: */
	tree = (OBJECT *)rs_trindex[RESULTD];
	
	sprintf( str( tree, RFILES ),	"%8i", d->files		);
	sprintf( str( tree, RSUBDIR ),	"%8i", d->subdir	);
	sprintf( str( tree, RBADCLUS ),	"%8i", d->badclus	);
	sprintf( str( tree, RORPHAN ),	"%8i", d->orphan	);
	
	form_center( tree, &fx, &fy, &fw, &fh );
	form_dial( FMD_START, 0, 0, 0, 0, fx, fy, fw, fh );
	objc_draw( tree, 0, MAX_DEPTH, fx, fy, fw, fh );
	
	graf_mouse( ARROW, NULL );
		
	/* Dialog ausfÅhren: */
	form_do( tree, 0 );
	form_dial( FMD_FINISH, 0, 0, 0, 0, fx, fy, fw, fh );
	set( tree, RESOK, NORMAL );
	
	/* Am RÅckgabewert erkennt die aufrufende Funktion, */
	/* ob es auf der Platte etwas zu korrigieren gibt:	*/
	
	if( d->orphan > 0 )
		return( TRUE );
	else
		return( FALSE );
}




/********************************************************************/
/* Fehlerhafte EintrÑge entfernen:									*/
/********************************************************************/
/* Die EintrÑge der verwaisten Cluster wurden schon beim ZÑhlen		*/
/* (in check_drive()) im FAT-Duplikat auf 0 (unbelegt) gesetzt.		*/
/* Jetzt wird noch einmal gefragt, ob das Programm wirklich auf		*/
/* der PLatte herumpfuschen soll. Stimmt der Benutzer zu, wird das	*/
/* korrigierte FAT-Duplikat auf die Platte gestanzt - fertig!		*/
/*																	*/
/* (Eigentlich nicht ganz: Normalerweise mÅûte dem Betriebssystem	*/
/* noch gemeldet werden, daû sich an den Daten auf dem betreffenden */
/* Laufwerk etwas geÑndert hat - Stichwort Mediachange. Da das aber	*/
/* nicht immer zuverlÑssig hilft, empfehlen wir dem Benutzer die	*/
/* (zuverlÑssige) Holzhammermethode: Nach Programmende neu booten!	*/

int fix_drive( int drive, BPB *par, INTELWD *dup )
{
OBJECT *tree;
int ex_objc;			/* Exit-Objekt */
int	fx, fy, fw, fh;		/* Formularkoordinaten */

	/* Formular vorbereiten: */
	tree = (OBJECT *)rs_trindex[FIXD];
	form_center( tree, &fx, &fy, &fw, &fh );
	form_dial( FMD_START, 0, 0, 0, 0, fx, fy, fw, fh );
	objc_draw( tree, 0, MAX_DEPTH, fx, fy, fw, fh );
	
		
	/* Dialog ausfÅhren: */
	ex_objc = 255 & form_do( tree, 0 );
	form_dial( FMD_FINISH, 0, 0, 0, 0, fx, fy, fw, fh );
	set( tree, ex_objc, NORMAL );
	
	if( ex_objc != FIXOK )
		return( FALSE );
	
	/* Jetzt wird die korrigierte FAT-Version (steht in dup) 	*/
	/* in FAT 1 und 2 geschrieben. 								*/
	
	save_fat( drive, par, dup );
	
	/* Danach sollte neu gebootet werden, damit sichergestellt	*/
	/* ist, daû das GEMDOS sich die neuen FATs auch anschaut, 	*/
	/* bevor es irgendwas auf die Platte schreibt...			*/
	
	form_alert( 1, "[1][ Nach Programmende bitte       | neu booten!                   | Please reboot after quitting! ][ OK ]" );
	return( TRUE );
}




/********************************************************************/
/* Alertbox mit Fehlermeldung ausgeben und dann verabschieden		*/
/********************************************************************/

void error( char *s )
{
	if( vq_aes() )			/* Unter GEM: */
	{
		form_alert( 1, s );				/* Fehlerbox	*/
		close_vwork();					/* Programmende	*/
	}
	else					/* Unter TOS: */
	{
		printf( " FEHLER: %s", s );		/* Fehlerstring ausgeben */
		Pterm( -1 );					/* Programmende */
	}
}



/********************************************************************/
/* Fehlendes AES bemeckern und Programm abbrechen					*/
/********************************************************************/
void no_aes( void )
{
	while( Cconis() )
		Cnecin();	/* Tastaturpuffer leeren */
	
	printf( "\n **************************************************" );
	printf( "\n *      ORPHAN darf nicht aus dem AUTO-Ordner     *" );
	printf( "\n * gestartet werden, sondern nur vom DESKTOP aus! *" );
	printf( "\n **************************************************" );
	printf( "\n *   You can't run ORPHAN from the AUTO-folder!   *" );
	printf( "\n *      Start this program from the DESKTOP!      *" );
	printf( "\n **************************************************" );
	printf( "\n\n (TASTE) / (press a key)" );
	Cnecin();
	
	/* Ein Aufruf von close_vwork() wÑre hier tîdlich - wir befin-	*/
	/* den uns schlieûlich auf unterster TOS-Ebene, wenn diese		*/
	/* Funktion aufgerufen wird ! Also entsorgen wir das Programm	*/
	/* "umweltgerecht":												*/
	Pterm( 0 );
}
