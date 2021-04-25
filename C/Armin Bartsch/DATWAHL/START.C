/**************************************************************************/
/*                                                                        */
/*   Beispielprogramm fÅr das Einbinden der File-Selector-Box             */
/*   in eigene Programme von :                                            */
/*                                                                        */
/*                         Armin Bartsch                                  */
/*                         Mîwenstr.5                                     */
/*                    2893 Butjadingen 1                                  */
/*                                                                        */
/*   1.Schritt : Einbinden der Datei SELECTOR.O in Megamax-Libary         */
/*                                                                        */
/*   2.Schritt : Aufrufen der Routine                                     */
/*                                                                        */
/*   int file_select(PFAD,DATEI,INFOZEILE,"EXT2","EXT3","EXT4","EXT5");   */
/*   char *PFAD,*DATEI,*INFOZEILE;                                        */
/*                                                                        */
/*   oder                                                                 */
/*                                                                        */
/*   int file_select(PFAD,DATEI,INFOZEILE,EXT2,EXT3,EXT4,EXT5);           */
/*   char *PFAD,*DATEI,*INFOZEILE,*EXT2,*EXT3,*EXT4,*EXT5;                */
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*   Die Extender 2-5 sind frei wÑhlbar, man sollte sich aber an das      */
/*   vorgeschriebene Format halten.                                       */
/*                                                                        */
/*   Weitere Informationen Åber die File-Selector-box finden Sie in       */ 
/*   der ST-Computer Nr.6/86 Seite 42                                     */
/*                                                                        */
/**************************************************************************/

#include <OSBIND.H>          /* Betriebssystemaufrufe(Cconws,Cconin) */

/**************************************************************************/

int    contrl[12];
int    intin[128];
int    intout[128];
int    ptsin[128];
int    ptsout[128];          /* Was GEM so braucht */

int    handle;
int    work_in[12];
int    work_out[57];

/**************************************************************************/

main()
{
    char pf[70],d[20],was[30];
    int i,fehler;

    appl_init();
    for(i = 0;i < 10;work_in[i++] = 1);
    work_in[10] = 2;
    v_opnvwk(work_in,&handle,work_out);
    graf_mouse(0,0x0L);

/**************************************************************************/
/*  Die folgenden 5 Zeilen sind der eigentliche Programmteil zum Aufruf   */
/**************************************************************************/

    strcpy(pf ,"A:\\*.*");        /* Maximal 49 Zeichen + Null-Byte */
    strcpy(d  ,"");               /* Sollte leer sein               */
    strcpy(was," Text laden ");   /* Maximal 29 Zeichen + Null-Byte */

    *pf = Dgetdrv()+65;           /* 1.Buchstaben von PFAD wird auf
                                     das aktuelle Laufwerk gesetzt. */

    fehler = file_select(pf,d,was,"*.DAT","*.KEY","*.EIN","*.AUS");

/**************************************************************************/

    printf("\n%d\n",fehler);
    Cconws(pf);    printf("\n");
    Cconws(d);     printf("\n");
    Cconin();
    v_clsvwk(handle);
    appl_exit();
    Pterm0();
}

/**************************************************************************/

