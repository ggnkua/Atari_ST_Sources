/***********************************************/
/* Datei: BBUILD.C                             */
/* ------------------------------------------- */
/* Modul: BOOT.CPX                Version 1.00 */
/* (C) 1990 by MAXON Computer                  */
/* Autoren: Uwe Hax & Oliver Scholz            */
/* verwendeter Compiler: Turbo-C 2.0           */
/***********************************************/


/* die Åblichen Header-Dateien --------------- */

#include <portab.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>


struct foobar   /* ist normalerweise in   */
{               /* "*.rsh" definiert und  */
  WORD dummy;   /* wird in "xcontrol.h"   */
  WORD *image;  /* benîtigt               */
};

#include "xcontrol.h"


/* Definitionen zur besseren Lesbarkeit ------ */

#define SOURCE       "BOOT.PRG"
#define DESTINATION  "BOOT.CPX"

#define TRUE         1
#define FALSE        0


/* globale Variablen ------------------------- */

/* Header-Definiton */
CPX_HEADER header;
          
/* Image-Daten */
LONG data[24]={  0x00000000L, 0x00000000L,
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
 

/* Prototypen fÅr Turbo-C -------------------- */

VOID main(VOID);
VOID abort_main(VOID *buffer,WORD fd);


VOID main(VOID)
{
  VOID *buffer;
  DTA *dta=Fgetdta();
  WORD fd;
  WORD i;
  
  /* Kennung fÅr *.CPX-Datei */
  header.magic=100;   

  /* Bitvektor: Flags fÅr Lade-Modus */
  header.flags.set_only=FALSE;
  header.flags.boot_init=FALSE;
  header.flags.resident=FALSE;
  
  /* Kurzkennung */
  strncpy(header.cpx_id,"BOOT",4); 

  /* Versionsnummer */
  header.cpx_version=0x100; 

  /* Icon-Name */
  strcpy(header.icon_name,"DAS BOOT");  

  /* Image-Daten */
  for (i=0; i<24; i++)
    header.icon_data[i]=data[i];

  /* Icon: Farbe 4, kein Buchstabe */
  header.icon_info=0x4000; 

  /* Programmname */
  strcpy(header.cpx_name,"Boot-Selektor");  

  /* Farben */
  header.obj_state=0x1280;  


  /* Header und Programm zusammenbauen */

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

