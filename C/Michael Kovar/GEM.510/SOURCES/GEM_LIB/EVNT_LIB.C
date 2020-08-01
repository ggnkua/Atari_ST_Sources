/*--------------------------------------------------------*/
/*             e v n t _ l i b                            */
/*        ------------------------------                  */
/*                                                        */
/* Funktionen, die Handhabung des evnt_multi erleichtern. */
/*                                                        */
/*   => v_evntinit()                                      */
/*   => v_event()                                         */
/*                                                        */
/*   Version 1.11   vom 29.11.1992                        */
/*                                                        */
/*   entwickelt auf ATARI 1040 STF                        */
/*                  ATARI TT 030                          */
/*              mit Mark Williams C   Version 3.09        */
/*                                                        */
/*   (c) 1990  by Volker Nawrath                          */
/*--------------------------------------------------------*/


#include <aesbind.h>
#include <event.h>
#include <gemdefs.h>


/* Felder, die fr v_event() ben”tigt werden. Sie mssen der Programm-
 * datei, die den EVENT-Manager benutzt, global definiert werden
 * ------------------------------------------------------------------- */
extern    EVNT           event;
extern    EVNT_RETURN    event_return;


/* Funktionen vordefinieren
 * ------------------------ */
void v_evntinit(was);
void v_event();


/* #########################################################
 * Felder fr šbergabe- und Rckgabebereich  initialisieren. 
 * 0 ==> event inititalisieren 
 * 1 ==> event_return initialisieren
 * numerische Felder werden mit Null, alphanumerische Felder
 * mit dem Stringbegrenzer "/0" initialisiert!
 * ######################################################### */

void v_evntinit(was)
int  was; /* was soll initialisiert werden   */
{
     int  i;

     switch (was)
     {
          case 0:
          {
               event.event         = 0;
               event.clicks        = 0;
               event.button        = 0;
               event.state         = 0;
               event.m1inout       = 0;
               event.rectangle1.x  = 0;
               event.rectangle1.y  = 0;
               event.rectangle1.w  = 0;
               event.rectangle1.h  = 0;
               event.m2inout       = 0;
               event.rectangle2.x  = 0;
               event.rectangle2.y  = 0;
               event.rectangle2.w  = 0;
               event.rectangle2.h  = 0;
               event.lowtime       = 0;
               event.hightime      = 0;
               break;
          } /* ENDE case 0: */
     
          case 1:
          {
               event_return.event       = 0;
               event_return.mouse_x     = 0;
               event_return.mouse_y     = 0;
               event_return.mouse_b     = 0;
               event_return.mouse_k     = 0;
               event_return.times       = 0;
               event_return.key         = 0;
               event_return.low_key     = 0;
               event_return.high_key    = 0;
     
               for (i=0;i<8;i++)
                    event_return.buffer[i] = 0;

               event_return.fl_window   = 0;
               event_return.fl_menu     = 0;
               event_return.fl_acc      = 0;
               event_return.fl_alpha    = 0;
               event_return.fl_alphanum = 0;
               event_return.fl_num      = 0;
               event_return.fl_zifferbl = 0;
               event_return.fl_crsrtast = 0;
               event_return.fl_crsrpos  = 0;
               event_return.fl_fkttast  = 0;
               event_return.fl_sonstig  = 0;
     
               break;
          } /* ENDE case 1: */
     } /* ENDE switch(was) */
} /* ENDE v_evntinit() */


/* ####################################
 * Ein oder mehrere Ereignisse abwarten
 * #################################### */

void v_event()
{
     int  i;        /* Schleifenvariable          */

     /* Felder fr evnt_multi
      * --------------------- */
     int  selection;     /* Ereignis, das auftrat           */
     int  was;           /* relevante Ereignisse            */
     int  clicks;        /* Anzahl der erwarteten Klicks    */
     int  button;        /* welcher Knopf ist relevant      */
     int  bstate;        /* Kopfzustand (gedrckt/nicht
                          * gedrckt)                       */
     int  mevent1;       /* erstes Mausereignis             */
     int  xevent1;       /* Rechteck fr 1. Mausereignis    */
     int  yevent1;
     int  wevent1;
     int  hevent1;
     int  mevent2;       /* zweites Mausereignis            */
     int  xevent2;       /* Rechteck fr 2. Mausereignis    */
     int  yevent2;
     int  wevent2;
     int  hevent2;
     int  buffer[8];     /* Puffer fr Meldungen            */
     int  lowtime;       /* unt. Wort fr Timerereignis     */
     int  hightime;      /* oberes Wort fr Timerereignis   */
     int  place_x;       /* Wo fand Mausereignis statt      */
     int  place_y;
     int  place_b;
     int  place_k;
     int  key;           /* welche Taste wurde gedrckt     */
     int  times;         /* wie oft nahm Mausknopf ge-
                          * wnschten Zustand ein           */
     
     /* šbergabewerte in Zwischenspeicher bertragen
      * -------------------------------------------- */
     was            = event.event;
     clicks         = event.clicks;
     button         = event.button;
     bstate         = event.state;
     mevent1        = event.m1inout;
     mevent2        = event.m2inout;
     lowtime        = event.lowtime;
     hightime       = event.hightime;
     xevent1        = event.rectangle1.x;
     yevent1        = event.rectangle1.y;
     wevent1        = event.rectangle1.w;
     hevent1        = event.rectangle1.h;
     xevent2        = event.rectangle2.x;
     yevent2        = event.rectangle2.y;
     wevent2        = event.rectangle2.w;
     hevent2        = event.rectangle2.h;

     v_evntinit(1);

     /* Ereignis abwarten
      * ----------------- */
     selection = evnt_multi(was,clicks,button,bstate,
                              mevent1,xevent1,yevent1,
                              wevent1,hevent1,
                              mevent2,xevent2,yevent2,
                              wevent2,hevent2,
                              buffer,lowtime,hightime,
                              &place_x,&place_y,&place_b,
                              &place_k,&key,&times);

     /* Rckgabewerte bertragen
      * ------------------------ */
     event_return.event       = selection;
     event_return.mouse_x     = place_x;
     event_return.mouse_y     = place_y;
     event_return.mouse_b     = place_b;
     event_return.mouse_k     = place_k;
     event_return.times       = times;
     event_return.key         = key;
     event_return.low_key     = key & 255;
     event_return.high_key    = key >> 8;

     if (EVNT_KEYBD())
     {
          /* Prfen, welche Tastengruppe gedrckt wurde */
          if ((((event_return.high_key >= K_q)      &&
                (event_return.high_key <= K_m)       ) ||
               KEY_ae()                                ||
               KEY_oe()                                ||
               KEY_sz()                                ||
               KEY_ue()                           ) &&
              (!KEY_nr()                          ) &&
              (!KEY_plus()                        ) &&
              (!KEY_nreturn()                     ) &&
              (!KEY_tilde()                       )     )
          {
               /* alphabetische Taste */
               event_return.fl_alpha = 1;
          }
          if (((event_return.high_key >= K_1)  &&
               (event_return.high_key <= K_0)    ) ||
              ((event_return.high_key >= KA_1) &&
               (event_return.high_key <= KA_8)   ) ||
              ((event_return.high_key >= KA_9) &&
               (event_return.high_key <= KA_0)   ) ||
              ((event_return.high_key >= KZ_7) &&
               (event_return.high_key <= KZ_0)   )   )
          {
               /* numerische Taste */
               event_return.fl_num = 1;
          }
          if (event_return.fl_alpha || event_return.fl_num)
          {
               /* alphanumerische Taste */
               event_return.fl_alphanum = 1;
          }
          if (((event_return.high_key >= K_f1)  &&
               (event_return.high_key <= K_f10)   ) ||
              ((event_return.high_key >= KS_f1) &&
               (event_return.high_key <= KS_f10)  )   )
          {
               /* Funktionstaste */
               event_return.fl_fkttast = 1;
          }
          if (KEY_crsrup()    || KEY_crsrdown()  ||
              KEY_crsrright() || KEY_crsrleft()    )
          {
               /* Cursortaste */
               event_return.fl_crsrtast = 1;
          }
          if (event_return.fl_crsrtast            ||
              KEY_delete()    || KEY_insert()     ||
              KEY_home()      || KEY_backspace()  ||
              KEY_undo()      || KEY_help()       ||
              KEY_space()     || KEY_tab()          )
          {
               /* Cursor neu positionieren */
               event_return.fl_crsrpos = 1;
          }
          if (KEY_zplus()                              ||
              KEY_zminus()                             ||
              KEY_zpunkt()                             ||
              ((event_return.high_key >= KZ_klauf) &&
               (event_return.high_key <= KZ_mult )   ) ||
              ((event_return.high_key >= KZ_7) &&
               (event_return.high_key <= KZ_0)   )   )
          {
               /* Ziffernblock */
               event_return.fl_zifferbl = 1;
          }
          if (!event_return.fl_alpha    &&
              !event_return.fl_alphanum &&
              !event_return.fl_num      &&
              !event_return.fl_zifferbl &&
              !event_return.fl_crsrpos  &&
              !event_return.fl_crsrtast &&
              !event_return.fl_fkttast  )
          {
               /* sonstige Taste wurde gedrckt */
               event_return.fl_sonstig = 1;
          }
     } /* ENDE if (EVNT_KEYBD()) */
     
     if (EVNT_MESAG())
     {

          for (i=0;i<=7;i++)
               event_return.buffer[i] = buffer[i];

          /* Prfen, welche Nachrichtenart erstellt wurde */
          switch (buffer[0])
          {
               case MN_SELECTED:
               {
                    /* Menu - Ereignis */
                    event_return.fl_menu = 1;
                    break;
               }
               case AC_OPEN:
               case AC_CLOSE:
               {
                    /* Accessory - Ereignis */
                    event_return.fl_acc = 1;
                    break;
               }
               default:
               {
                    /* Windowereignis */
                    event_return.fl_window = 1;
                    break;
               }
          }
     } /* ENDE if (EVNT_MESAG()) */
} /* ENDE v_event() */

