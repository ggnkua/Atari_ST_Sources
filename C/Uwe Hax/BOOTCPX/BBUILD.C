/**********************************************/
/* File : BBUILD.C                            */
/* ------------------------------------------ */
/* Module : BOOT.CPX             Versie 1.00  */
/* (C) 1990 by MAXON Computer                 */
/* Auteurs : Uwe Hax & Oliver Scholz          */
/* Gebruikte compiler : Turbo-C 2.0           */
/**********************************************/


/* De gebruikelijke header gegevens --------- */

#include <portab.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>


struct foobar		/* Wordt normaal in       */
{					/* "*.rsh" gedefinieerd   */
  WORD dummy;		/* en wordt in            */
  WORD *image;		/* "xcontrol.h" gebruikt  */
};

#include	"xcontrol.h"


/* Definities voor een betere leesbaarheid    */

#define	SOURCE		"BOOT.PRG"
#define	DESTINATION	"BOOT.CPX"

#define	TRUE	1
#define	FALSE	0


/* Globale variabelen ----------------------- */

/* Header definitie */
CPX_HEADER header;

/* Image-gegevens */
LONG data[24]={	0x00000000L, 0x00000000L,
				0x00000000L, 0x00000000L,
				0x00000000L, 0x00000000L,
				0x00000000L, 0x00000000L,
				0x00000000L, 0x00000000L,
				0x00001c00L, 0x00003c00L,
				0x00003c00L, 0xc0007c00L,
				0xe3ffffffL, 0x7ffffffbL,
				0xfffffffeL, 0x7ffffffaL,
				0xe07ffffcL, 0xc0000000L,
				0x00000000L, 0x00000000L,
				0x00000000L, 0x00000000L
			  };

/* Prototypen voor Turbo-C ----------------- */

VOID main(VOID);
VOID abort_main(VOID *buffer,WORD fd);


VOID main(VOID)
{
  VOID *buffer;
  DTA *dta=Fgetdta();
  WORD fd;
  WORD i;
  
  /* Kenmerk voor CPX-files */
  header.magic=100;
  
  /* Bitvector : flags voor laad-modus */
  header.flags.set_only=FALSE;
  header.flags.boot_init=FALSE;
  header.flags.resident=FALSE;
  
  /* Verkorte naam */
  strncpy(header.cpx_id,"BOOT",4);
  
  /* Versienummer */
  header.cpx_version=0x100;
  
  /* Icon-naam */
  strcpy(header.icon_name,"DAS BOOT");
  
  /* Image file */
  for (i=0; i<24; i++)
    header.icon_data[i]=data[i];
    
  /* Icon: kleur 4, geen hoofdletters */
  header.icon_info=0x4000;
  
  /* Programma naam */
  strcpy(header.cpx_name,"Boot-selector");
  
  /* Kleuren */
  header.obj_state=0x1280;
  
  /* Header en programma samenvoegen */
  
  if (Fsfirst(SOURCE,0)<0)
    abort_main(0L,-1);
  
  if ((buffer=Malloc(dta->d_length))<0)
    abort_main(0L,-1);
  
  if ((fd=Fopen(SOURCE,0))<0)
    abort_main(buffer,-1);
    
  if (Fread(fd,dta->d_length,buffer)<0)
    abort_main(buffer,fd);
  Fclose(fd);
  
  if ((fd=Fcreate(DESTINATION,0))<0)
    abort_main(buffer,-1);
  
  if (Fwrite(fd,512L,&header)!=512L)
    abort_main(buffer,fd);
    
  if (Fwrite(fd,dta->d_length,buffer)!=dta->d_length)
    abort_main(buffer,fd);
    
  Mfree(buffer);
  Fclose(fd);
  exit(0);
}

VOID abort_main(VOID *buffer,WORD fd)
{
  if (buffer)
    Mfree(buffer);
  if (fd>=0)
    Fclose(fd);
  form_alert(1,"[3][CPX-Datei konnte nicht|\
erzeugt werden!][ Abbruch ]");
    exit(1);
}
