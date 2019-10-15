#include <stdio.h>
#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>
#include "dma_snd.h"

#define FEHLER -1
#define PRIMA 1
#define STR_ADR(baum,obj) (char*) (((struct object*) baum)[obj].ob_spec)   /* Adresse des Textes eines Strings */
#define BSTR_ADR(baum,obj) (char*)(((struct text_edinfo*) (((struct object*) baum)[obj].ob_spec))->te_ptext)   /* Adresse des Textes eines Boxtextes */
#define MENU_NORM menu_tnormal(menue_tree,titel,1)
#define OBDRAW(x,y) objc_draw(x,y,0,0,0,x_screen,y_screen)
#define BAUMDRAW(x,y) objc_draw(x,y,MAX_DEPTH,0,0,x_screen,y_screen)
#define BIENE graf_mouse(2,0)
#define PFEIL graf_mouse(0,0)
#define MICRODATA 0XFF8922      /* Adressen des Microwireinterface */
#define MICROMASK 0XFF8924
#define EDIT(x,y) do_flag(x,y,EDITABLE);
#define UNEDIT(x,y) undo_flag(x,y,EDITABLE);
#define HIDE(x,y) do_flag(x,y,HIDETREE);
#define UNHIDE(x,y) undo_flag(x,y,HIDETREE);
#define MAXSEQ 18              /* Maximale Zahl der SequencereintÑge */
#define COOKIE "_SND"          /* Name des Sound-Cookies */
#define C_VAL 2L               /* Bit 1 signalisiert DMA-Sound */


typedef struct dta_buffer
{
 char dummy[21];
 char file_attr;
 int time;
 int date;
 long size;
 char name[14];
} DTABUF;
 


int contrl[12],
    intin[128],
    intout[128],
    ptsin[128],
    ptsout[128],
    work_in[12],
    work_out[57],
    vdi_handle,
    phys_handle,
    x_screen,
    y_screen,
    volume,               /* Werte fÅr den MWI-Klangregler */
    l_vol,
    r_vol,
    hoehen,
    baesse,
    smnr,                 /* Nummer der 1. Marke */
    emnr,                 /* Nummer der 2. Marke */
    hertz,                /* 0 = 6.25  1 = 12.5... */
    play_mode,            /* 0 = play   1 = play endlos   2 = stop */
    stereo;               /* 0 = mono */
long desk_tree,
     menue_tree,
     memavail,      /* Anzahl der freien Bytes */
     stack,         /* fÅr die Funktion Super() */
     memory,        /* zeigt auf freien Speicher */
     mark_pos[8];   /* die Positionen der 8 Marken (relativ zu 'memory') */
 char fpath[160],
      fname[13];




main()
{
 if(init() == FEHLER)
   return;
 verwalter();
 ende();
}




verwalter()
{
 int ev_which,
     m_x,
     m_y,
     m_b,
     mitteilung[8],
     dummy,
     objekt,
     flag = 1;
     

 do
   {
    ev_which = evnt_multi(18,1,1,1,0,0,0,0,0,0,0,0,0,0,mitteilung,0,0,
                          &m_x,&m_y,&m_b,&dummy,&dummy,&dummy);
    wind_update(BEG_UPDATE);

    if((ev_which & 2) != 0)      /* Mausklick */
      {
       objekt = objc_find(desk_tree,0,8,m_x,m_y);
       if(objekt > 0)
         objc_handler(objekt);
      }

    if((ev_which & 16) != 0)         /* Message */
      {
       if(mitteilung[0] == MN_SELECTED)
         flag = menue_handler(mitteilung[4],mitteilung[3]);
      }
    wind_update(END_UPDATE);
   }
 while(flag == 1);   
}




test_cookie(kennung,wert)
long *kennung,
     wert;
{
 long stack,
      *c_j;

 stack = Super(0L);
 c_j = *((long**) 0x5A0L);
 Super(stack);
 
 if((long) c_j == 0L)
   return(FEHLER);

 do{
    if(c_j[0] == *kennung)
      {
       if((c_j[1] & wert) != 0L)
         return(PRIMA);
       else
         return(FEHLER);
      }
    else
      c_j += 2L;
   }while(c_j[0]);
 return(FEHLER);
}
 



/* Initialsierung etc. */
init()
{
 int wert,
     i,
     b_b,h_b,b_b_k,h_b_k,
     dummy;
 char a_str[111];
 long tree;


 appl_init();
 for(i = 0; i < 10;work_in[i++] = 1);
 work_in[10] = 2;
 vdi_handle = phys_handle = graf_handle(&b_b,&h_b,&b_b_k,&h_b_k);
 v_opnvwk(work_in,&vdi_handle,work_out);
 x_screen = work_out[0];       /* Auflîsung feststellen */
 y_screen = work_out[1];
 if(test_cookie(COOKIE,C_VAL) == FEHLER)
   {
    form_alert(1,"[1][| Leider besitzt Ihr Computer| keine DMA-Sound-Hardware!][ Ende ]");
    v_clsvwk(vdi_handle);
    appl_exit();
    return(FEHLER);   
   }
 if(x_screen < 639 || y_screen < 199)
   {
    sprintf(a_str,"[1][ Die Bildschirmauflîsung be-| trÑgt nur %d mal %d Pixel.| Ich brauche mindestens| 640 * 200 Pixel.][ Okay ]",x_screen,y_screen);
    form_alert(1,a_str);
    v_clsvwk(vdi_handle);
    appl_exit();
    return(FEHLER);
   }
 if(rsrc_load("DMA_SND.RSC") == 0)
  {
   form_alert(1,"[1][ Wo ist meine | .RSC Datei geblieben ?][ Mal schauen... ]");
   v_clsvwk(vdi_handle);
   appl_exit();
   return(FEHLER);
  }
    /* allen verfÅgbaren Speicher bis auf 20kB fÅr das System anfordern */
 memavail = (long)Malloc(-1L) - 20000L;
 memory = ((long)Malloc(memavail+2L) & 0xFFFFFFFE) + 2L;
 for(i = 0;i < 8;mark_pos[i++] = 0L)
   ;
 volume = 40;
 l_vol = r_vol = 20;
 hoehen = baesse = 6;
 smnr = 0;
 emnr = 1;
 play_mode = 2;
 hertz = 2;
 stereo = 0;

 set_klang(0,1);
 set_freq_st();
 make_klang();

 strcpy(fpath,"A:\\*.*");
 fpath[0] = 'A' + (char)Dgetdrv();
 strcpy(fname,"");

 wind_update(BEG_UPDATE);
 rsrc_gaddr(0,SEQ,&tree);
 for(i = 0;i < MAXSEQ;i++)
   strcpy(STR_ADR(tree,SEQ1 + i),"     ");
 rsrc_gaddr(0,LOADSAVE,&tree);
 do_objc(tree,LOADA,SELECTED);
 rsrc_gaddr(0,GET_MARK,&tree);
 do_objc(tree,ENDB,SELECTED);
 rsrc_gaddr(0,MO_ST,&tree);
 do_objc(tree,BB,SELECTED);
 do_objc(tree,ZC,SELECTED);
 rsrc_gaddr(0,DESK,&desk_tree);
 do_objc(desk_tree,STOP,SELECTED);              /* Desktop initialisieren */
 do_objc(desk_tree,KHZ25,SELECTED);
 do_objc(desk_tree,MONO,SELECTED);
 do_objc(desk_tree,MA1,SELECTED);
 do_objc(desk_tree,MB2,SELECTED);
 sprintf(BSTR_ADR(desk_tree,BEREICH),"Wertebereich: 0 bis %8ld",memavail);
 ((struct object*)desk_tree)[0].ob_width = x_screen + 1;  /* Richtige Grîsse setzen */
 ((struct object*)desk_tree)[0].ob_height = y_screen + 1;
 wind_set(0,WF_NEWDESK,desk_tree,0,0);           /* neuen Desktop anmelden */
 objc_draw(desk_tree,0,8,0,0,x_screen,y_screen);
 klang_info();
 marken_info();
 set_play();

 rsrc_gaddr(0,MENUE,&menue_tree);      /* Menue anmelden */
 menu_bar(menue_tree,1);
 wind_update(END_UPDATE);
 PFEIL;
 return(PRIMA);
}



ende()
{
 menu_bar(menue_tree,0);
 v_clsvwk(vdi_handle);
 rsrc_free();
 appl_exit();
}



/*------------------- Die DMA-Sound-routinen --------------------*/



/* Der MWI-Klangregler wird beeinfluût */
set_klang(funktion,wert)
int funktion,     /* Nummer des Registers */
    wert;        /* einzustellender Wert */
{
 long stack;
 unsigned int *data,
              *maske;

 maske = (unsigned int*) MICROMASK;
 data = (unsigned int*) MICRODATA;

 stack = Super(0L);         /* In Supervisormodus schalten */
 *maske = 0x7FF;            /* Erst das Maskenregister einrichten */
 *data = 0x400 + (funktion << 6) + wert;    /* dann die Daten Åbergeben */
 Super(stack);              /* zurÅck in Usermodus schalten */
}




/* setzt Frequenz und Stereomodus entsprechend der Variablen 'hertz' */
/* 'stereo' im Sound-modus-Register */
set_freq_st()
{
 unsigned char *modus,
               wert = 0;
 long stack;

 modus = (unsigned char*) 0xFF8921;

 wert = hertz + (1 - stereo) * 128;
 stack = Super(0L);
 *modus = wert;
 Super(stack);
}




/* rechnet das Format der Sampleinformationen vom STe in das Samplerformat */
/* oder umgekehrt (je nach momentanem Zustand) */
umrechnen(von,laenge)
long von,
     laenge;
{
 static gerade(),loop(),weiter(),loop2(),ende();

 von += (long)memory;
 asm
   {
             	movem.l   D0-A6,-(A7)
             	move.l    von(A6),D2           ; Adresse
             	movea.l   D2,A0
             	move.l    laenge(A6),D0
             	move.l    #0x80808080,D1
             	btst.b    #0,D2                ; Adresse gerade ?
             	beq.b     gerade
             	eor.b     D1,(A0)+
             	subq.l    #1,D0
   	gerade:
             	move.l    D0,D3
             	andi.l    #3,D3                ; D3 = laenge % 4
             	asr.l     #2,D0                ; laenge durch 4 teilen
             	beq.b     weiter
   	loop:
             	eor.l     D1,(A0)+             ; umrechnen
             	subq.l    #1,D0
             	bhi.b     loop
   	weiter:
             	tst.w     D3
             	beq.b     ende
   	loop2:
             	eor.b     D1,(A0)+
             	subq.w    #1,D3
             	bhi.b     loop2
   	ende:
             	movem.l   (A7)+,D0-A6
   }
}





/* setzt Sounddaten-Start- und Endregister sowie das DMA-Sound-Control-Reg. */
set_play()
{
 long ende,                /* absolute Endadresse */
      von,                 /* absolute Startadresse */
      stack;
 char *zeiger;


 von = mark_pos[smnr] + (long)memory;
 ende = mark_pos[emnr] + (long)memory;
 lorder(&von,&ende);                  /* in richtige Reihenfolge bringen */

 stack = Super(0L);            /* In Supervisormodus schalten */
              /* Startadresse Åbergeben: */
 zeiger = (char*) 0xFF8903;
 *zeiger = von >> 16 & 0xFFL;  /* High-Byte */
 zeiger += 2L;
 *zeiger = von >> 8 & 0xFFL;   /* Mid-Byte */
 zeiger += 2L;
 *zeiger = von & 0xFFL;        /* Low-Byte */

              /* Endadresse Åbergeben: */
 zeiger += 8;
 *zeiger = ende >> 16 & 0xFFL;  /* High-Byte */
 zeiger += 2L;
 *zeiger = ende >> 8 & 0xFFL;   /* Mid-Byte */
 zeiger += 2L;
 *zeiger = ende & 0xFFL;        /* Low-Byte */

 zeiger = (char*) 0xFF8901L;
 if(play_mode == 0)              /* einfach-Wiedergabe */
   *zeiger = (char) 1;
 if(play_mode == 1)              /* endlos-Wiedergabe */
   *zeiger = (char) 3;
 if(play_mode == 2)              /* Stop */
   *zeiger = (char) 0;

 Super(stack);       /* In Usermodus zurÅckschalten */
}




/* speichert ein File im SampleWizard-Format */
speichern()
{
 char pfad[111],            /* Der Sample-Zugriffspfad */
      f_i[186],
      puffer[350],
      help[14];
 int d_handle,              /* Der Datei-Handle fÅr das Sample */
     exit,
     exit2,
     lauf,
     p_len,
     var;
 unsigned int zeit;
 long start = mark_pos[smnr],
      end = mark_pos[emnr],
      tree;


 lorder(&start,&end);
 if(end - start == 0L)
			{
	 		form_alert(1,"[3][| Der Block hat die LÑnge 0!][ Abbruch ]");
	 		return;
			}
   
	fsel_input(fpath,fname,&exit);
	if(exit == 0)
	  return;
	strcpy(f_i,fpath);          /* Dateiname- und Pfad richtig zusammenkleben */
 p_len = strlen(f_i);
 for(var = 0;f_i[p_len - var] != '\\' && var <= p_len;var++)
    ;
 strcpy(&f_i[p_len - var + 1],fname);
	exit2 = Fsfirst(f_i,1);     /* lÑnge ermitteln */ 
	if(exit2 == 0)    
			{                           /* datei existiert nicht : */
	 		form_alert(1,"[3][| Diesen Namen gibt es schon!][ Abbruch ]");
	 		return;
			}

 rsrc_gaddr(0,LOADSAVE,&tree);
	sprintf(STR_ADR(tree,SLBIT),"8 Bit");
	sprintf(STR_ADR(tree,SLCH),"%d",stereo + 1);
 *((unsigned int*) &puffer[32]) =  zeit = Tgettime();
	sprintf(help,"%2d:",(zeit >> 11));
	sprintf(&help[3],"%2d:",(zeit >> 5) & 63);
	sprintf(&help[6],"%2d",2 * (zeit & 31));
	strcpy(STR_ADR(tree,SLTIME),help);
/**/ *((unsigned int*) &puffer[28]) =  zeit = Tgetdate();
	sprintf(help,"%2d.",(zeit & 31));
	sprintf(&help[3],"%2d.",(zeit >> 5) & 15);
	sprintf(&help[6],"%4d",(zeit >> 9) + 1980);
	strcpy(STR_ADR(tree,SLDATE),help);/**/
 strcpy(BSTR_ADR(tree,REM1),"");  /* Bemerkungen */
 strcpy(BSTR_ADR(tree,REM2),"");
 strcpy(BSTR_ADR(tree,REM3),"");
 strcpy(BSTR_ADR(tree,REM4),"");
	sprintf(STR_ADR(tree,SLFREQ),"%2.2f kHz",(1 << hertz) * 6.25);
	sprintf(STR_ADR(tree,SLLEN),"%8ld",end - start);
	HIDE(tree,LTEXT);
	HIDE(tree,LOADMS);
 boxdraw(tree,30,30,10,10);
 exit = form_do(tree,REM1);           /* Box bearbeiten */
 undo_objc(tree,exit,SELECTABLE);
 boxundraw(tree,30,30,10,10);
	UNHIDE(tree,LTEXT);
	UNHIDE(tree,LOADMS);
 if(exit == CANCEL3)
    return;

 *((long*)puffer) = 0x7E817E81L;       /* Kennung */
	*((int*)&puffer[4]) = 180;            /* HeaderlÑnge */
	*((int*)&puffer[6]) = 0;
 puffer[16] = puffer[17] = (char)8;       /* 8-bit Sample */
 puffer[23] = (char)(stereo + 1);         /* Stereo / Mono */
 *((int*) &puffer[24]) = (int) 0;
 strncpy(&puffer[34],BSTR_ADR(tree,REM1),30);  /* Bemerkungen */
 strncpy(&puffer[64],BSTR_ADR(tree,REM2),40);
 strncpy(&puffer[104],BSTR_ADR(tree,REM3),40);
 strncpy(&puffer[144],BSTR_ADR(tree,REM4),40);
 *((long*) &puffer[18])	= (long)(6250L * (1L << hertz));
 *((long*) &puffer[8]) = *((long*) &puffer[12]) = end - start;
 *((int*) &puffer[184]) = (int) 0;          /* 0 Marken */
 *((int*) &puffer[186]) = (int) 0;          /* keine Huffmantabelle */

 d_handle = Fcreate(f_i,0);                     /* die Sampledatei îffnen */
 if(d_handle < 0)
			{                           /* datei existiert nicht : */
	 		form_alert(1,"[3][| Ich kann die Datei| nicht îffnen!][ Abbruch ]");
	 		return;
			}
 if(Fwrite(d_handle,188L,puffer) != 188L)
			{
	 		form_alert(1,"[3][| Ich kann diese Datei| nicht korrekt schreiben!][ Abbruch ]");
	 		Fclose(d_handle);
	 		return;
			}
 if(Fwrite(d_handle,end - start,(long)memory + start) != end - start)
			{
	 		form_alert(1,"[3][| Ich kann diese Datei| nicht korrekt schreiben!][ Abbruch ]");
	 		Fclose(d_handle);
	 		return;
			}
 Fclose(d_handle);
}





/* lÑdt File und erkennt dabei automatisch SampleWizard-Dateien */
laden()
{
 char pfad[111],            /* Der Sample-Zugriffspfad */
      f_i[186],
      puffer[350],
      help[14];
 int d_handle,              /* Der Datei-Handle fÅr das Sample */
     exit,
     kanaele,
     exit2,
     lauf,
     e_marke,
     l_marke,
     p_len,
     var;
 unsigned int zeit;
 long laenge,               /* Die LÑnge der Sampledatei */
      info_len,             /* Die LÑnge des Sample-Infos */
      len,
      tree;
 DTABUF *dta;


	fsel_input(fpath,fname,&exit);
	if(exit == 0)
	  return;
	strcpy(f_i,fpath);          /* Dateiname- und Pfad richtig zusammenkleben */
 p_len = strlen(f_i);
 for(var = 0;f_i[p_len - var] != '\\' && var <= p_len;var++)
    ;
 strcpy(&f_i[p_len - var + 1],fname);
	dta = (DTABUF *) Fgetdta();
	exit2 = Fsfirst(f_i,1);     /* lÑnge ermitteln */ 
	if(exit2 != 0)    
			{                           /* datei existiert nicht : */
	 		form_alert(1,"[1][| Diese Datei gibt es nicht !][ Abbruch ]");
	 		return;
			}
	len = (*dta).size;         /* dateilaenge */
 if(len > memavail)
			{                           /* datei existiert nicht : */
	 		form_alert(1,"[1][| Dieses Sample ist zu groû !][ Abbruch ]");
	 		return;
			}

 d_handle = Fopen(f_i,0);                     /* die Sampledatei îffnen */
 Fread(d_handle,4L,puffer);                   /* Kennung lesen */

 rsrc_gaddr(0,LOADSAVE,&tree);
 if(*((long*)puffer) != 0x7E817E81L)
			{                           /* datei existiert nicht : */
	 		exit2 = form_alert(1,"[2][| Diese Datei hat kein| Info oder ist keine| SampleWizard-Datei!][ Laden | Abbruch ]");
	 		if(exit2 == 2)
	 		  {
	 		   Fclose(d_handle);
   	 		return;
   	 	}

   	sprintf(STR_ADR(tree,SLBIT),"");
   	sprintf(STR_ADR(tree,SLCH),"");
   	strcpy(STR_ADR(tree,SLTIME),"");
   	strcpy(STR_ADR(tree,SLDATE),"");
   	strcpy(BSTR_ADR(tree,REM1),"");  /* Bemerkungen */
    strcpy(BSTR_ADR(tree,REM2),"");
    strcpy(BSTR_ADR(tree,REM3),"");
    strcpy(BSTR_ADR(tree,REM4),"");
   	sprintf(STR_ADR(tree,SLFREQ),"");
   	len -= 4L;
   	sprintf(STR_ADR(tree,SLLEN),"%8ld",len);
			}
	else
	  {
	   Fread(d_handle,4L,&puffer[4]);
	   info_len = (long)(*((int*)&puffer[4]) + *((int*)&puffer[6]));
	   Fread(d_handle,info_len,&puffer[8]);
    
    if((int)puffer[16] == 4)        /* 4-bit Sample ? */
      {
       form_alert(1,"[1][| Diese Software ist nicht fÅr| 4 Bit Samples geeignet.][ Abbruch ]");
	 		   Fclose(d_handle);
   	 		return;
   	 	}
   	sprintf(STR_ADR(tree,SLBIT),"8 Bit");

    kanaele = (int)puffer[23];         /* Stereo / Mono */
   	sprintf(STR_ADR(tree,SLCH),"%d",kanaele);
    zeit = *((unsigned int*) &puffer[32]);
   	sprintf(help,"%2d:",(zeit >> 11));
   	sprintf(&help[3],"%2d:",(zeit >> 5) & 63);
   	sprintf(&help[6],"%2d",2 * (zeit & 31));
   	strcpy(STR_ADR(tree,SLTIME),help);
   	zeit = *((unsigned int*) &puffer[28]);
   	sprintf(help,"%2d.",(zeit & 31));
   	sprintf(&help[3],"%2d.",(zeit >> 5) & 15);
   	sprintf(&help[6],"%4d",(zeit >> 9) + 1980);
   	strcpy(STR_ADR(tree,SLDATE),help);
	
   	strncpy(BSTR_ADR(tree,REM1),&puffer[34],30);  /* Bemerkungen */
    strncpy(BSTR_ADR(tree,REM2),&puffer[64],40);
    strncpy(BSTR_ADR(tree,REM3),&puffer[104],40);
    strncpy(BSTR_ADR(tree,REM4),&puffer[144],40);
	
   	sprintf(STR_ADR(tree,SLFREQ),"%2.2f kHz",(double) *((long*) &puffer[18]) / 1000.0);
   	len = *((long*) &puffer[8]);
   	sprintf(STR_ADR(tree,SLLEN),"%8ld",len);
   }
 boxdraw(tree,30,30,10,10);
 UNEDIT(tree,REM1);
 UNEDIT(tree,REM2);
 UNEDIT(tree,REM3);
 UNEDIT(tree,REM4);
 exit = form_do(tree,0);           /* Box bearbeiten */
 EDIT(tree,REM1);
 EDIT(tree,REM2);
 EDIT(tree,REM3);
 EDIT(tree,REM4);
 undo_objc(tree,exit,SELECTABLE);
 boxundraw(tree,30,30,10,10);
 if(exit == CANCEL3)
   {
    Fclose(d_handle);
    return;
   }

 for(lauf = 0;lauf < 8;lauf++)            /* Lade-Marke feststellen */
   if(test_objc(tree,LOADA + lauf,SELECTED) == 1)
     l_marke = lauf;
 Fread(d_handle,len,mark_pos[l_marke] + (long)memory);
 Fclose(d_handle);
 
 e_marke = end_marke();
 if(e_marke != -1)
   mark_pos[e_marke] = mark_pos[l_marke] + len;
 boxundraw(tree,30,30,10,10);
 marken_info();
}




/* macht aus 2 Monosamples ein Stereosample */
z_mo_st()
{
 long tree,
      start = mark_pos[smnr],   /* Adressen des 1. Blocks */
      ende = mark_pos[emnr];
 int bl2_m,    /* Startmarke des 2. Blocks */
     ziel_m,   /* Zielmarke */
     e_marke,
     exit,
     lauf;


 rsrc_gaddr(0,MO_ST,&tree);
 boxdraw(tree,30,30,10,10);
 exit = form_do(tree,0);
 undo_objc(tree,exit,SELECTED);
 boxundraw(tree,30,30,10,10);
 if(exit == OKAY)
   {
    for(lauf = 0;lauf < 8;lauf++)
      if(test_objc(tree,BA + lauf,SELECTED) == 1)
        bl2_m = lauf;
    for(lauf = 0;lauf < 8;lauf++)
      if(test_objc(tree,ZA + lauf,SELECTED) == 1)
        ziel_m = lauf;
    lorder(&start,&ende);
           /* Der 1. Block kommt nach links: */
    do_m_st(start,mark_pos[bl2_m],ende - start,mark_pos[ziel_m]);
    e_marke = end_marke();
    if(e_marke != -1)
     	mark_pos[e_marke] = mark_pos[ziel_m] + 2 * (ende - start);
   }
 marken_info();
}




do_m_st(von_l,von_r,laenge,ziel)
long von_l,
     von_r,
     laenge,
     ziel;
{
 static loop();

 von_l += (long)memory;
 von_r += (long)memory;
 ziel += (long)memory;
 ziel += ziel % 2L; /* Wenn ungerade, auf nÑchsthîhere gearde Adresse setzen */

 asm
   {
              movem.l  D0-A6,-(A7)
              movea.l  von_l(A6),A0
              movea.l  von_r(A6),A1
              movea.l  ziel(A6),A2
              move.l   laenge(A6),D0
    loop:
              move.b   (A0)+,(A2)+      /* linken Kanal Åbertragen */
              move.b   (A1)+,(A2)+      /* rechten Kanal Åbertragen */
              subq.l   #1,D0
              bhi.b    loop
              movem.l  (A7)+,D0-A6
   }
}





sequenzer()
{
 static int mom_seq = 0,     /* aktueller Eintrag */
            which = 0,
            eintr[MAXSEQ][2];
 int exit,
     lauf,
     exit2,
     anzahl;
 long tree,
      von[MAXSEQ],
      laenge[MAXSEQ];


 rsrc_gaddr(0,SEQ,&tree);
 for(lauf = 0;lauf < 8;lauf++)
   sprintf(BSTR_ADR(tree,SA + lauf)," MARKE %c: %ld",'A' + lauf,mark_pos[lauf]);
 boxdraw(tree,30,30,10,10);

 do{
    exit = form_do(tree,0);
    undo_objc(tree,exit,SELECTED);
    for(lauf = 0;lauf < 8;lauf++)
      {
       if(exit == lauf + SA)           /* Markenbutton gedrÅckt ? */
         {
          if(mom_seq == 18)
            {
             form_alert(1,"[3][| Die Sequenzerliste ist voll!][ Abbruch ]");
             break;
            }
          if(which == 0)               /* Startmarke */
            {
             eintr[mom_seq][which] = lauf;
             which = 1;
             sprintf(STR_ADR(tree,SEQ1 + mom_seq)," %c-  ",'A' + lauf);
             OBDRAW(tree,SEQ1 + mom_seq);
            }
          else
            {
             eintr[mom_seq][which] = lauf;
             which = 0;
             sprintf(STR_ADR(tree,SEQ1 + mom_seq) + 3,"%c ",'A' + lauf);
             OBDRAW(tree,SEQ1 + mom_seq);
             mom_seq++;
            }
          break;
         }
      }

    if(exit == ERASEALL)       /* Die ganze Liste lîschen */
      {
       exit2 = form_alert(2,"[2][| Wollen Sie wirklich die| ganze Sequenzerliste lîschen?][ Ja | Abbruch ]");
       if(exit2 == 1)
         {
          mom_seq = 0;
          for(lauf = 0;lauf < MAXSEQ;lauf++)
             strcpy(STR_ADR(tree,SEQ1 + lauf),"     ");
          BAUMDRAW(tree,ALLSEQS);
         }
      }

    if(exit == ERASE)        /* Den letzten Eintrag lîschen */
      {
       if(mom_seq > 0)
         {
          if(which == 0)
            {
             strcpy(STR_ADR(tree,SEQ1 + mom_seq - 1),"     ");
             mom_seq--;
            }
          else
             strcpy(STR_ADR(tree,SEQ1 + mom_seq),"     ");
         }
       else
         strcpy(STR_ADR(tree,SEQ1),"     ");
       which = 0;
       BAUMDRAW(tree,ALLSEQS);
      }

    if(exit == PLAYSEQ)           /* Sequenz spielen */
      {
       anzahl = 0;
       for(lauf = 0;lauf < mom_seq;lauf++)
         {
          if(mark_pos[eintr[lauf][1]] - mark_pos[eintr[lauf][0]] > 0L)
            {
             von[anzahl] = mark_pos[eintr[lauf][0]] + (long)memory;
             laenge[anzahl] = mark_pos[eintr[lauf][1]] - mark_pos[eintr[lauf][0]];
             anzahl++;
            }
          if(mark_pos[eintr[lauf][1]] - mark_pos[eintr[lauf][0]] < 0L)
            {
             von[anzahl] = mark_pos[eintr[lauf][1]] + (long)memory;
             laenge[anzahl] = mark_pos[eintr[lauf][0]] - mark_pos[eintr[lauf][1]];
             anzahl++;
            }
         }
       if(anzahl)
         do_seq_nint(von,laenge,anzahl);
      }
    OBDRAW(tree,exit);
   }while(exit != ENDSEQ);
 boxundraw(tree,30,30,10,10);
}
            





/* ermîglich die SequenzerfÑhigkeiten des DMA-Sounds auszunutzen ohne */
/* Interruptprogrammierung */
do_seq_nint(von,laenge,anzahl)
long von,      /* Adresse des von-Array */
     laenge;   /* Adresse des laenge-Array */
int anzahl;
{
 static main_loop(),durch(),test_loop(),set_regs(),dma_stack();
 static dma_ende();
 

 asm
      {
                movem.l D0-A6,-(A7)
                clr.l   -(A7)
                move.w  #0x20,-(A7)
                trap    #1
                addq.l  #6,A7
                lea     dma_stack,A0
                move.l  D0,(A0)
                move.w  SR,-(A7)
                move.b  #100,0xFFFA1F     /* Timer-Data fÅllen */
                move.b  #8,0xFFFA19       /* Timer A auf EreigniszÑhlung */
        ; D0 versch.
        ; D1 versch.
        ; D2 versch.
        ; D4 Anzahl
        ;
        ; A0 versch.
        ; A1 versch.
        ; A4 Arrayzeiger laenge
        ; A5 Arrayzeiger von
        ;
                movea.l von(A6),A5
                move.l  laenge(A6),A4
                move.w  anzahl(A6),D4
                tst.w   D4
                beq     dma_ende
                subq.w  #1,D4
                move.l  (A4)+,D0             /* erste LÑnge holen */
                move.l  (A5)+,D1             /* erste Startadresse holen */
                bsr     set_regs             /* DMA-Sound-Register setzen */
                move.w  #3,0xFF8900          /* endlos spielen */
      main_loop:
                tst.w   D4                   /* Noch mehr Samples ? */
                beq     dma_ende
                subq.w  #1,D4
                move.l  (A4)+,D0             /* nÑchste LÑnge holen */
                move.l  (A5)+,D1             /* nÑchste Startadresse holen */
                bsr     set_regs             /* DMA-Sound-Register setzen */
                bsr     durch                /* warten, bis letztes Sample fertig */
                bra.b   main_loop



             /* Hier kommen die Subroutines */


      /* wartet solange, bis der Block gespielt ist */
      /* Der Data-Wert wechselt nur zwischen 100 und 99, so daû nie ein */
      /* Interrupt entstehen kînnte (der so wie so aus ist) */
      /* verÑndert D1,A0 */
         durch:
                 movea.l #0xFFFA1F,A0
                 move.b  #100,D1
         test_loop:
                 cmp.b   (A0),D1
                 beq.b   test_loop
                 move.b  #0,-6(A0)      /* Timer A aus, damit ... */
                 move.b  D1,(A0)        /* ...der Wert sofort Åbernommen wird. */
                 move.b  #8,-6(A0)      /* Timer A wieder an */
                 rts


      /* setzt die Register des DMA-Sounds */
      /* D0 = LÑnge     D1 = Startadresse */
      /* verÑndert: D1,D2,A1 */
       set_regs:
                lea     0xFF8903,A1
                move.l  D1,D2         /* Startadresse setzen */
                move.b  D2,4(A1)      /* Low-Byte */
                lsr.l   #8,D2
                move.b  D2,2(A1)      /* Mid-Byte */
                lsr.l   #8,D2
                move.b  D2,(A1)       /* High-Byte */
                add.l   D0,D1         /* Endadresse setzen */
                move.b  D1,16(A1)
                lsr.l   #8,D1
                move.b  D1,14(A1)
                lsr.l   #8,D1
                move.b  D1,12(A1)
                rts
                   
       
       dma_stack: dc.l    0

       dma_ende:
                bsr       durch
                move.w    #0,0xFF8900     /* nicht mehr spielen */
                move.b    #0,0xFFFA19     /* Timer A aus */
                move.w    (A7)+,SR        /* Interrupts wieder an */
                lea       dma_stack,A0
                move.l    (A0),-(A7)
                move.w    #0x20,-(A7)
                trap      #1
                addq.l    #6,A7
                movem.l   (A7)+,D0-A6
      }
}




record()
{
 long start,
      end;


 if(stereo == 1)
   {
    form_alert(1,"[1][| Eine Stereo-Aufnahme ist| nicht mîglich.][ Abbruch ]");
    return;
   }

 start = mark_pos[smnr];
 end = mark_pos[emnr];
 lorder(&start,&end);

 if(hertz == 0)
   do_rec(start,end - start,74);
 if(hertz == 1)
   do_rec(start,end - start,34);
 if(hertz == 2)
   do_rec(start,end - start,14);
 if(hertz == 3)
   do_rec(start,end - start,4);
}




/* verz: 4~50 kHz  14~25 kHz */
do_rec(von,laenge,verz)
long von,
     laenge;
int verz;
{
 static hauptloop(),timer(),fertigrec(),save_reg(),weiter();

 von+= memory;          /* Aus der relativen Adresse eine absolute machen */
 stack = Super(0L);
    asm
     {
                   movem.l    D0-A6,-(A7)
                   ori.w      #0x0700,SR  
                   movea.l    #0xFF8800,A1
                   movea.l    #0xFF8802,A2
                   move.b     #7,(A1)     
                   move.b     (A1),D4     
                   lea        save_reg,A3 
                   move.b     D4,(A3)
                   andi.b     #0x7F,D4    
                   move.b     D4,(A2)     
                   move.b     #14,(A1)    
                   move.l     #0x0E000000,D6
                   move.w     (A1),D6       
                   andi.w     #0xDF00,D6    
                   move.w     D6,D5
                   ori.w      #0x2000,D5    
                   move.b     #15,D7        
                   move.w     verz(A6),D4   
                   move.l     laenge(A6),D0
                   move.l     von(A6),A0
      hauptloop:
                   move.b     D7,(A1)       
                   move.b     (A1),(A0)+    
                   move.l     D6,(A1)       
                   move.w     D5,(A2)       
                   nop
                   nop
                   nop
                   nop
                   nop
                   nop
                   move.w     D4,D2         
      timer:
                   subq.w     #1,D2
                   bne.b      timer
                   subq.l     #1,D0         
                   bne.b      hauptloop     
      fertigrec:             
                   move.b     #7,(A1)       
                   lea        save_reg,A3
                   move.b     (A3),(A2)     
                   bra.b      weiter

      save_reg:    dc.l       0     

      weiter:
                   andi.w     #0xFBFF,SR    
                   movem.l    (A7)+,D0-A6    
     }
 Super(stack);
}

   

/*------------------ GEM-Routinen --------------------------*/



boxdraw(tree,x,y,w,h)
int x,y,w,h;
long tree;
{
 int xdial,ydial,wdial,hdial;
  
 form_center (tree,&xdial,&ydial,&wdial,&hdial);
 form_dial(0,x,y,w,h,xdial,ydial,wdial,hdial);
 form_dial(1,x,y,w,h,xdial,ydial,wdial,hdial);
 objc_draw(tree,0,8,xdial,ydial,wdial,hdial);
}



boxundraw(tree,x,y,w,h) 
int x,y,w,h;
long tree;
{
 int xdial,ydial,wdial,hdial;
 
 form_center (tree,&xdial,&ydial,&wdial,&hdial);
 form_dial(2,x,y,w,h,xdial,ydial,wdial,hdial);
 form_dial(3,x,y,w,h,xdial,ydial,wdial,hdial);
}




do_flag(tree,which,bit)   /* objc_flag setzen */
long tree;
int which,bit;
{
 int *zeiger;
 
 zeiger = (int*) (tree + which * 24L + 8L);
 *zeiger|= bit;
}


undo_flag(tree,which,bit)
long tree;
int which,bit;
{
 int *zeiger;
 
 zeiger = (int*) (tree + which * 24L + 8L);
 *zeiger &= (~bit);
}



do_objc(tree,which,bit)
long tree;
int which,bit;
{
 int *zeiger;
 
 zeiger = (int*) (tree + which * 24L + 10L);
 *zeiger |= bit;
}


undo_objc(tree,which,bit)
long tree;
int which,bit;
{
 int *zeiger;
 
 zeiger = (int*) (tree + which * 24L + 10L);
 *zeiger &= (bit ^ 0xFFFF);
}



test_objc(tree,which,bit)
long tree;
int which,bit;
{
 int *zeiger;
 
 zeiger = (int*) (tree + which * 24L + 10L);
 if((*zeiger & bit) > 0)
   return(1);
 else
   return(0);
}



klang_info()
{
 sprintf(BSTR_ADR(desk_tree,VOLUME),"%3d dB",volume * 2 - 80);    /* Klangregleranzeige setzen */
 sprintf(BSTR_ADR(desk_tree,VLINKS),"%3d dB",l_vol * 2 - 40);
 sprintf(BSTR_ADR(desk_tree,VRECHTS),"%3d dB",r_vol * 2 - 40);
 sprintf(BSTR_ADR(desk_tree,HOEHEN),"%3d dB",hoehen * 2 - 12);
 sprintf(BSTR_ADR(desk_tree,BAESSE),"%3d dB",baesse * 2 - 12);
 OBDRAW(desk_tree,VOLUME);
 OBDRAW(desk_tree,VLINKS);
 OBDRAW(desk_tree,VRECHTS);
 OBDRAW(desk_tree,HOEHEN);
 OBDRAW(desk_tree,BAESSE);
}



marken_info()
{
 int lauf;

 for(lauf = 0;lauf < 8;lauf++)                /* Markenanzeige machen */
   {
    sprintf(BSTR_ADR(desk_tree,POSA + lauf)," Marke %c: %8ld",'A' + (char) lauf,mark_pos[lauf]);
    OBDRAW(desk_tree,POSA + lauf);
   }
}





objc_handler(objekt)
int objekt;
{
 int mx_pos,
     my_pos,
     dummy,
     objekt2,
     lauf;

 switch(objekt)         /* simuliert TOUCHEXIT bzw. EXIT */
 		{
 		                     /* die folgenden Buttons sind TOUCHEXIT */
 		 case VUP:
 		 case VDO:
 		 case VLUP:
 		 case VLDO:
 		 case VRUP:
 		 case VRDO:
 		 case HUP:
 		 case HDO:
 		 case BUP:
 		 case BDO:
 		   objekt2 = objekt;
 		   break;
 		 default:            /* alle anderen Tasten EXIT */
 		   evnt_button(1,1,0,&mx_pos,&my_pos,&dummy,&dummy); /* wartet auf loslassen des mausknopfes */
 		   objekt2 = objc_find(desk_tree,0,8,mx_pos,my_pos);
 		   break;
 		}

 if(objekt2 == objekt)  /* beim loslassen immer noch Åber gleichen objekt ? */
   {

    for(lauf = MA1;lauf < MA1 + 8;lauf++)    /* 1. Blockmarke */
      {
       if(objekt == lauf)
         {
          undo_objc(desk_tree,smnr + MA1,SELECTED);
          do_objc(desk_tree,lauf,SELECTED);
          OBDRAW(desk_tree,smnr + MA1);
          OBDRAW(desk_tree,lauf);
          smnr = lauf - MA1;
         }
      }

    for(lauf = MA2;lauf < MA2 + 8;lauf++)    /* 2. Blockmarke */
      {
       if(objekt == lauf)
         {
          undo_objc(desk_tree,emnr + MA2,SELECTED);
          do_objc(desk_tree,lauf,SELECTED);
          OBDRAW(desk_tree,emnr + MA2);
          OBDRAW(desk_tree,lauf);
          emnr = lauf - MA2;
         }
      }

    for(lauf = KHZ6;lauf < KHZ6 + 4;lauf++)    /* Frequenz */
      {
       if(objekt == lauf)
         {
          undo_objc(desk_tree,hertz + KHZ6,SELECTED);
          do_objc(desk_tree,lauf,SELECTED);
          OBDRAW(desk_tree,hertz + KHZ6);
          OBDRAW(desk_tree,lauf);
          hertz = lauf - KHZ6;
          set_freq_st();
         }
      }

    switch(objekt)
      {
     /*----------------------- Klangregler setzen --------------------*/
       case VUP:
        do_klang(VUP,VOLUME,&volume,1,0,40);
        break;
       case VDO:
        do_klang(VDO,VOLUME,&volume,-1,0,40);
        break;
       case VLUP:
        do_klang(VLUP,VLINKS,&l_vol,1,0,20);
        break;
       case VLDO:
        do_klang(VLDO,VLINKS,&l_vol,-1,0,20);
        break;
       case VRUP:
        do_klang(VRUP,VRECHTS,&r_vol,1,0,20);
        break;
       case VRDO:
        do_klang(VRDO,VRECHTS,&r_vol,-1,0,20);
        break;
       case HUP:
        do_klang(HUP,HOEHEN,&hoehen,1,0,12);
        break;
       case HDO:
        do_klang(HDO,HOEHEN,&hoehen,-1,0,12);
        break;
       case BUP:
        do_klang(BUP,BAESSE,&baesse,1,0,12);
        break;
       case BDO:
        do_klang(BDO,BAESSE,&baesse,-1,0,12);
        break;
     /*-------------- neue Markenposition eingeben ------------------*/
       case POSA:
        new_mpos(0,POSA);
        break;
       case POSB:
        new_mpos(1,POSB);
        break;
       case POSC:
        new_mpos(2,POSC);
        break;
       case POSD:
        new_mpos(3,POSD);
        break;
       case POSE:
        new_mpos(4,POSE);
        break;
       case POSF:
        new_mpos(5,POSF);
        break;
       case POSG:
        new_mpos(6,POSG);
        break;
       case POSH:
        new_mpos(7,POSH);
        break;
      /*--------------------- Mono/Stereo -----------------------*/
       case MONO:
        undo_objc(desk_tree,STEREO,SELECTED);
        do_objc(desk_tree,MONO,SELECTED);
        OBDRAW(desk_tree,STEREO);
        OBDRAW(desk_tree,MONO);
        stereo = 0;
        set_freq_st();
        break;
       case STEREO:
        do_objc(desk_tree,STEREO,SELECTED);
        undo_objc(desk_tree,MONO,SELECTED);
        OBDRAW(desk_tree,STEREO);
        OBDRAW(desk_tree,MONO);
        stereo = 1;
        set_freq_st();
        break;
      /*--------------------- play_mode setzen ------------------*/
       case STOP:
        do_objc(desk_tree,STOP,SELECTED);
        undo_objc(desk_tree,PLAY,SELECTED);
        undo_objc(desk_tree,PNONSTOP,SELECTED);
        OBDRAW(desk_tree,STOP);
        OBDRAW(desk_tree,PLAY);
        OBDRAW(desk_tree,PNONSTOP);
        play_mode = 2;
        set_play();
        break;
       case PLAY:
        undo_objc(desk_tree,STOP,SELECTED);
        do_objc(desk_tree,PLAY,SELECTED);
        undo_objc(desk_tree,PNONSTOP,SELECTED);
        OBDRAW(desk_tree,STOP);
        OBDRAW(desk_tree,PLAY);
        OBDRAW(desk_tree,PNONSTOP);
        play_mode = 0;
        set_play();
        break;
       case PNONSTOP:
        undo_objc(desk_tree,STOP,SELECTED);
        undo_objc(desk_tree,PLAY,SELECTED);
        do_objc(desk_tree,PNONSTOP,SELECTED);
        OBDRAW(desk_tree,STOP);
        OBDRAW(desk_tree,PLAY);
        OBDRAW(desk_tree,PNONSTOP);
        play_mode = 1;
        set_play();
        break;
       case RECORD:
        do_objc(desk_tree,RECORD,SELECTED);
        OBDRAW(desk_tree,RECORD);
        record();
        undo_objc(desk_tree,RECORD,SELECTED);
        OBDRAW(desk_tree,RECORD);
        break;
      }
   }
}




menue_handler(punkt,titel)
int punkt,
    titel;
{
 long tree;
 int exit,
     flag = 1;

 switch(punkt)
   {
    case QUIT:
      exit = form_alert(2,"[2][| Wollen Sie wirklich| das Programm beenden?][ Ja | Nein ]");
      if(exit == 1)
        flag = 0;
      MENU_NORM;
      break;
    case MESSAGE:
      rsrc_gaddr(0,CPYRGHT,&tree);
      boxdraw(tree,30,30,10,10);
      exit = form_do(tree,0);
      boxundraw(tree,610,370,10,10);
      undo_objc(tree,exit,SELECTED);
      MENU_NORM;
      break;
    case FORMAT:
      if(mark_pos[smnr] < mark_pos[emnr])
        umrechnen(mark_pos[smnr],mark_pos[emnr] - mark_pos[smnr]);
      if(mark_pos[smnr] > mark_pos[emnr])
        umrechnen(mark_pos[emnr],mark_pos[smnr] - mark_pos[emnr]);
      MENU_NORM;
      break;
    case LOADSAM:
      laden();
      MENU_NORM;
      break;
    case SAVESAM:
      speichern();
      MENU_NORM;
      break;
    case ZMS:
      z_mo_st();
      MENU_NORM;
      break;
    case SEQUENZ:
      sequenzer();
      MENU_NORM;
      break;
   }
 return(flag);
}




/* setzt alle Register des Klangreglers anhand der entspr. Variablen */
make_klang()
{
 set_klang(3,volume);
 set_klang(5,l_vol);
 set_klang(4,r_vol);
 set_klang(2,hoehen);
 set_klang(1,baesse);
}



/* erledigt die Bearbeitung des Klangreglers */
do_klang(pfeil,text,var,aenderung,min,max)
int pfeil,      /* Pfeilobjekt */
    text,       /* das dazugehîrige Textobjekt */
    *var,       /* die zu verÑndernde Variable */
    aenderung,  /* der Wert um den '*var' geÑndert werden soll */
    min,        /* kleinster Wert dieses Register */
    max;        /* grîûter Wert */
{
 do_objc(desk_tree,pfeil,SELECTED);
 OBDRAW(desk_tree,pfeil);
 *var += aenderung;
 *var = (*var > max) ? max : *var;
 *var = (*var < min) ? min : *var;
 klang_info();
 make_klang();
 undo_objc(desk_tree,pfeil,SELECTED);
 OBDRAW(desk_tree,pfeil);
}




new_mpos(nr,objc)
int nr,       /* Markennummer */
    objc;     /* Objektnummer */
{
 double komma;
 long tree,
      newpos;
 int exit,
     flag;
 char **ptr;

 rsrc_gaddr(0,POS_BOX,&tree);
 sprintf(STR_ADR(tree,MARKE),"Marke: %c",'A' + (char)nr);
 sprintf(STR_ADR(tree,OLDPOS),"%8ld",mark_pos[nr]);
 sprintf(BSTR_ADR(tree,NEWPOS),"%8ld",mark_pos[nr]);
 boxdraw(tree,30,30,10,10);
 do{
    flag = 0;
    exit = form_do(tree,NEWPOS);
    undo_objc(tree,exit,SELECTED);
    if(exit == OKAY2)
      {
       sdtof(BSTR_ADR(tree,NEWPOS),&komma);
       newpos = (long)komma;
       if(newpos < 0L || newpos > memavail)
         {
          form_alert(1,"[1][| Die neue Position liegt| auûerhalb des Wertebereichs.][ Aha ]");
          OBDRAW(tree,exit);
          flag = 1;
         }
       else
         mark_pos[nr] = newpos;
      }
    }while(flag);
 boxundraw(tree,30,30,10,10);
 marken_info();
}




/* wandelt string in double-zahl (die Laser-C-Routinen funktionieren nicht */
/* so wie sie sollen) */
sdtof(zeiger,komma)
long *zeiger;    /* Zeiger auf den Textstring */
double *komma;
{
 long nachkomma = 1L;
 int zaehler,
     flag = 0,
     str_len;
 double zwischen = 0.0;
 char z[12];
 
 strcpy(z,zeiger);
 str_len = strlen(z);
 for(zaehler = 0;zaehler < str_len;zaehler++)
   {
    if((z[zaehler] < '0' || z[zaehler] > '9') && z[zaehler] != '.' && z[zaehler] != ' ' || z[zaehler] == ' ' && flag > 0 || z[zaehler] == '.' && flag == 2)
      break;
    if(z[zaehler] >= '0' && z[zaehler] <= '9')
      {
       zwischen += (double) z[zaehler] - 48.0;
       zwischen *= 10.0;
       if(flag == 0)                        /* erste ziffer ? */
         flag = 1;
       if(flag == 2)                        /* nachkommastelle ? */
         nachkomma *=10L;  
      }
    if(z[zaehler] == '.')
      flag = 2;
                                            /* es gibt Nachkommastellen*/
   }
 if(flag == 0)                              /* keine Zahl = -1 */
  {
   *komma = -1.0;
   return;
  } 
 *komma = zwischen / nachkomma / 10;       /* / 10 da einmal zwischen*= 10 zuviel */           
}



lorder(eins,zwei)
long *eins,
     *zwei;
{
 long help;
 if(*eins > *zwei)
   {
    help = *eins;
    *eins = *zwei;
    *zwei = help;
   }
}



/* lÑût eine Ende-Marke auswÑhlen: Return: Markennr. oder -1 */
end_marke()
{
 long tree;
 int exit,
     lauf;

 rsrc_gaddr(0,GET_MARK,&tree);
 boxdraw(tree,30,30,10,10);
 exit = form_do(tree,0);
 undo_objc(tree,exit,SELECTED);
 boxundraw(tree,30,30,10,10);
 if(exit == OKAY4)
 		{
 		 for(lauf = 0;lauf < 8;lauf++)
 		   if(test_objc(tree,ENDA + lauf,SELECTED) == 1)
 		     return(lauf);
 		}
 return(-1);
}
