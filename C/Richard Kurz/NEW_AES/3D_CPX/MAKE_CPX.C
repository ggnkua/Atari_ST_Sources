/*  MAKE_CPX.C
 *  Erzeugt einen Header und linkt ihn mit 3D_CPX.CP
 *  zum fertigen 3D_CPX.CPX.
 *  
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  Erstellt mit Pure C
 *
 *  ACHTUNG!!!! Alle Dateien mÅssen im gleichen Ordner sein!!!!!
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include <portab.h>
#include "cpx.h"
#include "icon.icn"  /* Das Icon.    */

/* Nur zur Beruhigung von Pure C.    */
struct foobar
{
    WORD    dummy;
    WORD    *image;
};

/* Der Kopf des Ganzen.             */
CPXHEAD header;

void main(void)
/* Macht aus 3D_CPX.CP ein CPX-Modul. */
{
    WORD i;     /* Hilfsvariable.       */
    FILE *fp,   /* Datei-Zeiger.        */
         *fp2;
    
    header.magic=100;           /* Dieser Wert muû immer 100 sein.  */
    header.flags.ram_resident=0;/* Resident oder nicht?             */
    header.flags.boot_init=1;   /* Soll das Modul bei der XControl- */
                                /* Initialisierung aufgerufen       */
                                /* werden? (cpx_init).              */
    header.flags.set_only =0;   /* Wenn set_only 1 ist, wird das    */
                                /* Modul nicht in die CPX-Liste     */
                                /* eingetragen.                     */
    
    header.cpx_id=(long)'3DFl'; /* ID-String des CPX-Moduls. Sollte */
                                /* fÅr jedes Modul einzigartig sein!*/
    header.cpx_version=0x0100;  /* Versions-Nr. des CPX-Moduls.     */

    strcpy(header.i_text,"by R. Kurz"); /*  Text unter dem Icon.    */
    /* Das Icon wird in den Header kopiert.                         */
    for(i=0;i<DATASIZE;i++) 
        header.icon[i]=icon[i];      
    header.i_info.i_color=1;            /* Farbe des Icons.         */
    header.i_info.reserved=0;
    header.i_info.i_char=0;
    strcpy(header.text,                 /* Titel des CPX-Moduls.    */
           "3D Effects"); 
    header.t_info.c_board=1;
    header.t_info.c_text=1;             /* Farbe des Titels.        */
    header.t_info.pattern=8;
    header.t_info.c_back=0;
    
    /* Wir basteln uns ein CPX-Modul.                               */
    puts("3D_CPX.CPX ist in Arbeit!");
    fp=fopen("3d_cpx.cpx","wb");
    if(fp==NULL)
    {
        puts("3d_cpx.cpx kann nicht erzeugt werden!!");
        exit(1);
    }
    fwrite(&header,sizeof(CPXHEAD),1,fp);
    fp2=fopen("3d_cpx.cp","rb");
    if(fp2==NULL)
    {
        puts("3d_cpx.cp kann nicht geîffnet werden!!");
        exit(1);
    }
    while(!feof(fp2))
    {
        i=getc(fp2);
        if(i==EOF) break;
        putc(i,fp);
    }
    puts("Fertig!");
    Cconout('\a');
    fclose(fp);
    fclose(fp2);
    exit(0);
}
