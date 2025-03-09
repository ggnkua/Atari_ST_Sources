/**********************************************/
/* CPX-BUILDER:		NEC-BUILD										*/
/* ------------------------------------------	*/
/* Funktionen:																*/
/*		Erstellt aus NECPOWER.PRG ein CPX				*/
/* Ersteller:																	*/
/*		Hartmut Klindtworth, 11.04.1993					*/
/* Copyright 1993 by MAXON-Verlag, Eschborn		*/
/**********************************************/

/*	Åbliche HEADER-Dateien	*/
#include <portab.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>
#include <stddef.h>

struct foobar
{	/* ist normalerweise in "*.rsh" definiert   */
	/* und wird in "xcontrol.h" benîtigt.				*/
	WORD	dummy;
	WORD	*image;};

#include <xcontrol.h>

/* Definitionen zur besseren Lesbarkeit -----	*/
#define FARBEN		0x1280
#define PRG_NAME	"MAXON NEC Power"		
#define ICON_INFO	0x4000	/* Farbe 4,no Letter*/
#define ICON_NAME	"NEC P20/30"
#define VERSION		0x100		/* Version 1.00			*/
#define CPX_ID		"MNEC"	/* NUR 4 Zeichen		*/

/* ACHTUNG !!!! - Anpassung erforderlich!			*/
#define SOURCE		"MAXNECPO.PRG"
#define DESTINATION	"C:\\CPX\\MAXONNEC.CPX"
#define TRUE				1
#define FALSE				0

/**********************************************/
/* Globale Variablen ------------------------	*/
CPX_HEADER	header;			/* Header-Definition	*/
LONG data[24]={					/* Image-Daten 				*/
0x0L,       0x0L,       0x07FFFFF8L,0x04000008L, 
0x05BFFC68L,0x04000008L,0x05FFF7E8L,0x04000008L, 
0x058FF1E8L,0x04000008L,0x04000008L,0x0FFFFFFCL, 
0x1FFFFFFEL,0x10000002L,0x724624F2L,0x72893482L, 
0x73092CE2L,0x72892482L,0x12462482L,0x10000002L, 
0x1FFFFFFEL,0x0L,       0x0L,       0x0L,
					};
					
/* Prototypen fÅr Pure C --------------------	*/
void main( void );
void abort_main( void *buffer, WORD fd);

void main( void )
{
	void	*buffer;
	DTA	*dta=Fgetdta();
	WORD 	fd;
	WORD	i;
	
	/* Kennung fÅr *.CPX-Datei			*/
	header.magic=100;
	/* Bitvektor: Flags fÅr Lade-Modus	*/
	header.flags.boot_init=TRUE;
	header.flags.set_only=FALSE;
	header.flags.resident=FALSE;
	/* Kurzkennung	*/
	strncpy(header.cpx_id,CPX_ID,4);
	/* Versionsnummer	*/
	header.cpx_version=VERSION;
	/* Icon-Name		*/
	strcpy(header.icon_name,ICON_NAME);
	/* Image-Daten		*/
	for(i=0; i<24; i++)	
					header.icon_data[i]=data[i];
	/* Icon-Farbe		*/
	header.icon_info=ICON_INFO;
	/* Programmname	*/
	strcpy(header.cpx_name,PRG_NAME);
	/* Farben			*/
	header.obj_state=FARBEN;
	/* Header und Programm zusammenbauen	*/
	if(Fsfirst(SOURCE,0)<0)
			abort_main(NULL,-1);
	if((buffer=Malloc(dta->d_length))<0)
			abort_main(NULL,-1);
	if((fd=(WORD)Fopen(SOURCE,FO_READ))<0)
			abort_main(buffer,-1);
	if(Fread(fd,dta->d_length,buffer)<0)
			abort_main(buffer,-1);
	Fclose(fd);
	if((fd=(WORD)Fcreate(DESTINATION,0))<0)
			abort_main(buffer,-1);
	if(Fwrite(fd,512L,&header)!=512L)
			abort_main(buffer,-1);
	if(Fwrite(fd,dta->d_length,buffer)!= 
													dta->d_length)
			abort_main(buffer,-1);
	Mfree(buffer);
	Fclose(fd);
	exit(0);
}
void abort_main(void *buffer, WORD fd)
{
	if(buffer)	Mfree(buffer);
	if(fd>=0)	Fclose(fd);
	form_alert(1,"[3][CPX-Datei konnte"
					" nicht|erzeugt werden!][ Abbruch]");
	exit(1);
}
