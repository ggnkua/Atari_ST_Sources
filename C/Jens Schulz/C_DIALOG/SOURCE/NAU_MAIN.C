/* 		NAUMANN šBUNG C-PROGRAMM
		========================

        Jens Schulz
        Rosenstraže 5
        W-2207 Kiebitzreihe
        04121/5885
*/

#include <tos.h>
#include <vdi.h>
#include <aes.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "nau_rsc.h"
#include "nau_feld.h"
#include "nau_graf.h"
#include "nau_rout.h"
#include "nau_game.h"
 
/************ Globale Variablen. **********************************/

int work_in[12],
       work_out[57];

int handle,
       phys_handle;

int gl_hchar,	/* Zeichenhoehe  */
    gl_wchar,	/* Zeichenbreite */
    gl_hbox,	/* Box-Hoehe und */
    gl_wbox;	/* Box-Breite in die ein Char passt */

int gl_apid;  /* Applikations-Handle vom AES */

screen_param sc;

/*********************** Prototypen *******************************/

boolean open_vwork( void );
void    close_vwork( void );
void    gem_prg( void );

/* -------------------- HAUPTPROGRAMM -------------------------------- */

void main( void )
{
   int ret;

   if ( open_vwork( ) == TRUE )
   {
     ret = rsrc_load("NAU_RSC.RSC");   /* RSC laden */
     if (ret == 0)
       form_alert(1,"[3][Resource-Datei|nicht gefunden !][Abbruch]");
     else
     {
       gem_prg( );

       close_vwork( );
       exit ( 0 );
     }
   }
   else
   {
      form_alert(1,"[3][Fehler bei der|Programminitialisierung !][Abbruch]");
      exit ( -1 );
   }
}

/* -------------- Virtual Workstation ”ffnen ------------------------- */

boolean open_vwork( void )
{
   register int i;

   if (( gl_apid = appl_init() ) != -1 )
   {
      for ( i = 1; i < 10; work_in[i++] = 1 );
      work_in[10] = 2;
      phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
      work_in[0]  = handle = phys_handle;

      v_opnvwk( work_in, &handle, work_out );

      return ( TRUE );
   }
   else
      return ( FALSE );
}

/* ------------Virtual Workstation schliežen ---------------------- */

void close_vwork( void )
{
   v_clsvwk( handle );

   appl_exit( );
}

/*=========== Zentraler GEM-Verteiler ================================*/
  
void gem_prg()
{

   int      event,                  /* Ergebnis mit Ereignissen.        */
            mx, my,                 /* Mauskoordinaten.                 */
            mbutton,                /* Mausknopf.                       */
            mstate,                 /* Status des Mausknopfs.           */
            keycode,                /* Scancode einer Tastatureingabe.  */
            mclicks,                /* Anzahl Mausklicks.    */
            totalabort,             /* Abbruch mit F10       */
			abbruch,status,
            t_stufe,ergebnis,
            punktanzahl,count,
            wi_handle;              /* Handle des Fensters   */

    char zw_str[6],spieler[10],ausg_str[100],*temp_str;

    boolean ende={FALSE};           /* Spielabbruch      */

    long    menutree;               /* Menuadresse */

    int Msgbuff[8];                 /* Message-Puffer */
    char boot_path[128];            /* String zum Boot-Pfad merken */     
    const int WI_KIND = 0;

/* Programminitialisierung */

	status = graf_init();

    get_akt_path(boot_path); /* Boot-Pfad holen */
              
    if (status == 0)
    {
      rsrc_gaddr(R_TREE,MENU1,&menutree);         /* Menueadresse    */

      if(status == 0)  /* Den Rest nur, wenn Startmeldung OK */
      {
         menu_bar((OBJECT *)menutree,1);             /* Menue anzeigen  */
	   
         wi_handle = wind_create(WI_KIND,0,sc.MENUKOPF, /* Fenster anmelden */
	                  sc.X_PIXEL,sc.Y_PIXEL-sc.MENUKOPF);
	     wind_open(wi_handle,0,sc.MENUKOPF,sc.X_PIXEL,  /* Fenster zeichnen */
	                sc.Y_PIXEL-sc.MENUKOPF);
          

          /*  Eigene Programminitialisierung */

	      do
	      {
	        abbruch = 1;
            hndl_dial(SHAREMLD,0,3,1,1);
		    MAUS_HAND;	/* Maus auf Zeigende Hand */
	      
	        do
	        { 

	          event = evnt_multi( 0x0033, /* Mausklick, Tastatur & Message */
	                              1, 1, 1, /* druecken des linken Knopfes */
	                              0, 0, 0, 0, 0,
	                              0, 0, 0, 0, 0,
	                              Msgbuff,0,0,
	                              &mx, &my,
	                              &mbutton, &mstate,
	                              &keycode, &mclicks);



	          if((event & 0x0010) != 0) /* Message */
	          { 
	            if((Msgbuff[0] == WM_REDRAW) &&
	               (Msgbuff[3] == wi_handle) &&
	               (Msgbuff[1] != 0))             /* Fenster neuzeichnen */
	            {
	              /* fprintf(stdprn,"Fenster neu !! %d\n",Msgbuff[1]); */ 
	              MAUS_AUS;
                  form_alert(1,"[1]Hier h„tte ich gerne den|Hintergrund restauriert !][Let's poke]");
	              MAUS_EIN;
	            }
	            else 
	            if (Msgbuff[0] == MN_SELECTED)   /* Men selektiert */
	            {
	               menu_tnormal((OBJECT *)menutree,Msgbuff[3],TRUE);
	               switch (Msgbuff[4])          /* Menverteiler */
	               {
	                 case QUIT:                 /* Quit */
	                   ende = TRUE;
	                   totalabort = 1;
	                   break;

	                 case TTIME :             /* Zeitlimit setzen */
    	               abbruch = form_alert(1,"[1][Warnung !|Bei Žnderung des Zeitlimits|erfolgt ein Familienkrach !][ Krach |Abbruch]");
	                   if (abbruch == 1)
	                      tournament_limit((OBJECT *)menutree,&t_stufe);
	                   break;  

	                 case GRUND:       /* YEAH */
	                   hndl_dial(GRUNDAUF,0,3,1,1);
	                   break;

	                 case PROGINFO:       /* Programminfo */
                       hndl_dial(SHAREMLD,0,3,1,1);
	                   break;  

                     case EDITME:        /* Eingabe in Dialog */  
                       /* HSNR = Highscoreplatz (Nr.)
                          HSPUNKTE = Highscorepunkte
                          HSNAME = Highscorename EDIT-Feld */
                       punktanzahl = 12345;   /* Beispielpunkte */
                       count = 33;            /* Beispielplatz  */
                       temp_str = get_dial_str_adr(HISCORE,HSNR,G_STRING);
                       itoa(count+1,zw_str,10);
                       strcpy(temp_str,zw_str);
                       temp_str = get_dial_str_adr(HISCORE,HSPUNKTE,G_STRING);
                       itoa(punktanzahl,zw_str,10);
                       strcpy(temp_str,zw_str);
                       ergebnis = hndl_dial (HISCORE,HSNAME,2,1,1);
                       if (ergebnis == FORGET)
                       {
                          abbruch = form_alert(1,"[1][Hmmh !|Dann wollen wir das mal|vergessen !][ Okay ]");
                       }
                       else
                       {
                          /* Name nach Spieler holen */
                          strcpy(spieler,get_dial_str_adr(HISCORE,HSNAME,G_FTEXT));  
                          /* @ in Editfeld rckt Cursor ganz nach links !! */
                          if (spieler[0] == '@')
                          strcpy(spieler,"No Name !!");  
                          strcpy(ausg_str,"[1][Name = ");
                          strcat(ausg_str,spieler);
                          strcat(ausg_str,"|Eingelesen fr|Nirwana ram save !][ Okay ]");
                          abbruch = form_alert(1,ausg_str);
                       }
                       break;
	               }

	            }
	         }  
	     
	         if((event & 0x0001) != 0)  /*********** Tastatur ******************/
	         {
	            /* printf("\n %8x",keycode); 
                 Tastaturcode erfragen in Hex */    
	            switch (keycode)
	            {

	              case 0x4400:             /* F10 Quit*/
	                ende = TRUE;
	                totalabort = 1;
	                break;

	              case 0x151a:             /* Crtl Z Zeitlimit */
	                abbruch = form_alert(1,"[1][Warnung !|Bei Žnderung des Zeitlimits|erfolgt ein Familienkrach !][ Krach |Abbruch]");
	                if (abbruch == 1)
	                   tournament_limit((OBJECT *)menutree,&t_stufe);
	                break;   

	                case 0x2207:       /* YEAH */
	                  hndl_dial(GRUNDAUF,0,3,1,1);
	                  break;

	             }
	          }  

	        } while (ende == FALSE);
	      } while ((abbruch == 1) && (totalabort == 0)); 

          ende_meldung(&abbruch);    /* Endemeldung */
          wind_close(wi_handle);    /* Fenster schliessen */
          wind_delete(wi_handle);   /* Fenser wieder abmelden */
   	  }
    }
    else
    if(status == 1)
       form_alert(1,"[3][Fehler beim Laden|der Bilddaten !][Abbruch]");
	else
	if(status == 2)
       form_alert(1,"[3][Falsche Bildschirmaufl”sung|Modus mit 16 Farben oder|Monochrom n”tig !][Abbruch]");

}
