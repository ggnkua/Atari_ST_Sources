/*--------------------------------------------------------*/
/*                 G E M _ O B J C . C                    */
/*           ------------------------------               */
/*                                                        */
/*      Beispielprogramm zum GEM-Manager                  */
/*                                                        */
/*                                                        */
/*      Version 1.00    vom 29.11.1992                    */
/*                                                        */
/*      entwickelt auf ATARI TT030                        */
/*                 mit Mark Williams C  Version 3.09      */
/*                                                        */
/*      (c) 1992  by Volker Nawrath                       */
/*--------------------------------------------------------*/

/* Include-Dateien
 * --------------- */
#include  <aesbind.h>
#include  <gemdefs.h>
#include  <gemprog.h>
#include  <gemprog1.h>
#include  <gemsys.h>
#include  <obdefs.h>
#include  <osbind.h>
#include  <vdibind.h>
#include  <window.h>


/* Felder
 * ------ */
/*   extern    int  Prog_End; */
extern    EXT       fenster[10];
extern    OBJECT    *buttdial;


/* Prototypen - GEM-Manager
 * ------------------------ */
void del_flag();
void do_objc();
unsigned  int  is_objc();
void set_flag();
void undo_objc();


/* Prototypen - Programm
 * --------------------- */
void icon_dclick();


/* ####################################################################
 * Verarbeitung fÅr Doppelklick auf Icon
 * Aufgabe: Objekt unter BerÅcksichtigung der Rechteckliste ausgeben
 * #################################################################### */

void icon_dclick()
{
     int  button,fensternr,i;

     /* Dialogbox initialisieren
      * ------------------------ */
     for (i=1;i<=9;i++)
     {
          if (fenster[i].offen)
          {
               switch (i)
               {
                    case 1:
                    {
                         do_objc(buttdial,BUTTCRO1,SELECTED);
                         do_objc(buttdial,BUTTTXT1,DISABLED);
                         del_flag(buttdial,BUTTFEN1,SELECTABLE);
                         break;
                    }
                    case 2:
                    {
                         do_objc(buttdial,BUTTCRO2,SELECTED);
                         do_objc(buttdial,BUTTTXT2,DISABLED);
                         del_flag(buttdial,BUTTFEN2,SELECTABLE);
                         break;
                    }
                    case 3:
                    {
                         do_objc(buttdial,BUTTCRO3,SELECTED);
                         do_objc(buttdial,BUTTTXT3,DISABLED);
                         del_flag(buttdial,BUTTFEN3,SELECTABLE);
                         break;
                    }
                    case 4:
                    {
                         do_objc(buttdial,BUTTCRO4,SELECTED);
                         do_objc(buttdial,BUTTTXT4,DISABLED);
                         del_flag(buttdial,BUTTFEN4,SELECTABLE);
                         break;
                    }
                    case 5:
                    {
                         do_objc(buttdial,BUTTCRO5,SELECTED);
                         do_objc(buttdial,BUTTTXT5,DISABLED);
                         del_flag(buttdial,BUTTFEN5,SELECTABLE);
                         break;
                    }
                    case 6:
                    {
                         do_objc(buttdial,BUTTCRO6,SELECTED);
                         do_objc(buttdial,BUTTTXT6,DISABLED);
                         del_flag(buttdial,BUTTFEN6,SELECTABLE);
                         break;
                    }
                    case 7:
                    {
                         do_objc(buttdial,BUTTCRO7,SELECTED);
                         do_objc(buttdial,BUTTTXT7,DISABLED);
                         del_flag(buttdial,BUTTFEN7,SELECTABLE);
                         break;
                    }
                    case 8:
                    {
                         do_objc(buttdial,BUTTCRO8,SELECTED);
                         do_objc(buttdial,BUTTTXT8,DISABLED);
                         del_flag(buttdial,BUTTFEN8,SELECTABLE);
                         break;
                    }
                    case 9:
                    {
                         do_objc(buttdial,BUTTCRO9,SELECTED);
                         do_objc(buttdial,BUTTTXT9,DISABLED);
                         del_flag(buttdial,BUTTFEN9,SELECTABLE);
                         break;
                    }
               }
          } /* ENDE: if (fenster[i].offen) */
          else
          {
               switch (i)
               {
                    case 1:
                    {
                         undo_objc(buttdial,BUTTCRO1,SELECTED);
                         undo_objc(buttdial,BUTTTXT1,DISABLED);
                         set_flag(buttdial,BUTTFEN1,SELECTABLE);
                         break;
                    }
                    case 2:
                    {
                         undo_objc(buttdial,BUTTCRO2,SELECTED);
                         undo_objc(buttdial,BUTTTXT2,DISABLED);
                         set_flag(buttdial,BUTTFEN2,SELECTABLE);
                         break;
                    }
                    case 3:
                    {
                         undo_objc(buttdial,BUTTCRO3,SELECTED);
                         undo_objc(buttdial,BUTTTXT3,DISABLED);
                         set_flag(buttdial,BUTTFEN3,SELECTABLE);
                         break;
                    }
                    case 4:
                    {
                         undo_objc(buttdial,BUTTCRO4,SELECTED);
                         undo_objc(buttdial,BUTTTXT4,DISABLED);
                         set_flag(buttdial,BUTTFEN4,SELECTABLE);
                         break;
                    }
                    case 5:
                    {
                         undo_objc(buttdial,BUTTCRO5,SELECTED);
                         undo_objc(buttdial,BUTTTXT5,DISABLED);
                         set_flag(buttdial,BUTTFEN5,SELECTABLE);
                         break;
                    }
                    case 6:
                    {
                         undo_objc(buttdial,BUTTCRO6,SELECTED);
                         undo_objc(buttdial,BUTTTXT6,DISABLED);
                         set_flag(buttdial,BUTTFEN6,SELECTABLE);
                         break;
                    }
                    case 7:
                    {
                         undo_objc(buttdial,BUTTCRO7,SELECTED);
                         undo_objc(buttdial,BUTTTXT7,DISABLED);
                         set_flag(buttdial,BUTTFEN7,SELECTABLE);
                         break;
                    }
                    case 8:
                    {
                         undo_objc(buttdial,BUTTCRO8,SELECTED);
                         undo_objc(buttdial,BUTTTXT8,DISABLED);
                         set_flag(buttdial,BUTTFEN8,SELECTABLE);
                         break;
                    }
                    case 9:
                    {
                         undo_objc(buttdial,BUTTCRO9,SELECTED);
                         undo_objc(buttdial,BUTTTXT9,DISABLED);
                         set_flag(buttdial,BUTTFEN9,SELECTABLE);
                         break;
                    }
               }
          } /* ENDE: else... if (fenster[i].offen) */
          
     }
      
     button = do_movedial(buttdial,BUTTDRAG,0);
     
     if (button == BUTTOK)
     {
          /* Verarbeitung durchfÅhren
           * ------------------------ */
          if (is_objc(buttdial,BUTTFEN1,SELECTED) & SELECTED)
               fensternr=1;
          if (is_objc(buttdial,BUTTFEN2,SELECTED) & SELECTED)
               fensternr=2;
          if (is_objc(buttdial,BUTTFEN3,SELECTED) & SELECTED)
               fensternr=3;
          if (is_objc(buttdial,BUTTFEN4,SELECTED) & SELECTED)
               fensternr=4;
          if (is_objc(buttdial,BUTTFEN5,SELECTED) & SELECTED)
               fensternr=5;
          if (is_objc(buttdial,BUTTFEN6,SELECTED) & SELECTED)
               fensternr=6;
          if (is_objc(buttdial,BUTTFEN7,SELECTED) & SELECTED)
               fensternr=7;
          if (is_objc(buttdial,BUTTFEN8,SELECTED) & SELECTED)
               fensternr=8;
          if (is_objc(buttdial,BUTTFEN9,SELECTED) & SELECTED)
               fensternr=9;
          
          fenster_aktion(fensternr,1);

     }
     
} /* ENDE: icon_dclick() */

