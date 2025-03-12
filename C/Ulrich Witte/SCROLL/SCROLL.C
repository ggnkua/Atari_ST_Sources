/*   Demo-Programm fÅr die Scrollroutinen     */
/*          von Ulrich Witte                  */
/*      (c) 1991 MAXON Computer               */

#include <osbind.h>
#include "scroll.h"

int contrl[12]; /* Globale VDI-Variablen */
int intin[256],  ptsin[256];
int intout[256], ptsout[256];

SCROLLER s[10];    

main()
{
   int taste;
       /* Flag fÅr Richtung */
   int links_oder_oben = 1; 
       /* Scrollgeschwindigkeit relativ , zu */
       /* scrollende Pixel pro Durchlauf */
   int x = 1,y = 1;          
       /* Scrollgeschwindigkeit absolut, */
       /* Pause pro Durchlauf */
   long pause = 0L;            
       /* Nummer der Workstation */
   int handle;                 
   
     /* GEM Bescheid sagen, daû wir da sind */
   appl_init();               
     /* VDI-Handle besorgen */
   handle = open_workstation(); 
     /* schnell die Maus ausmachen */
   asm {dc.w 0xa00a}           
    /* und den Bildschirm sÑubern */
   v_clrwk(handle);            
    
    /* ein bisschen Text und Grafik */
   mach_was_auf_den_bildschirm(handle);   
   scroll_bereiche_festlegen(links_oder_oben);
   
   while ((taste = Crawio(0xff) & 0xff ) != 27) 
   {      /* solange nicht ESC gedrÅckt */
     switch (taste)
     {
       case 32:    /* Space */                   
            links_oder_oben ^= 1;    
  /* Flag umdrehen, neue Initialisierung */   
     scroll_bereiche_festlegen(links_oder_oben);
            break;
       case 0x2b:/* '+' auf Zehnertastatur */
            if (++x >= 10) 
              x = 10; 
            break;  
       case 0x2d:   /* '-'  */
            if (--x <= 1) 
              x = 1; 
            break;    
       case 0x2a:   /* '*' */
            if (++y >= 10)
              y = 10; 
            break;  
       case 0x2f:   /* '/' */
            if (--y <= 1) 
              y = 1; 
            break;    
       case 0x28:   /* '(' */
            if (++pause >= 1000L) 
              pause = 1000L;
            break; 
       case 0x29:   /* ')' */
            if (--pause <= 0L) 
              pause = 0L; 
            break;    
       case 0xd:  /* 'Enter' */ 
              /* Parameter zurÅcksetzen */
            pause = 0L;
            x = y = 1;
            break; 
     }
  /* scroll_lr(&s[3],pause,x,!links_oder_oben);*/
     scroll_ou(&s[7],pause,y,links_oder_oben);

     scroll_lr(&s[0],pause,x,links_oder_oben);
  /* scroll_ou(&s[4],pause,y,!links_oder_oben);*/
     
     scroll_lr(&s[2],pause,1,!links_oder_oben);
/*   scroll_ou(&s[6],pause,1,!links_oder_oben);*/
     
          /* Diagonal */
     scroll_lr(&s[1],pause,1,!links_oder_oben);
     scroll_ou(&s[5],pause,1,links_oder_oben);
     
  /* scroll_ou(&s[8],pause,1,1);*/
     
   }  
   asm {dc.w 0xa009} /* Maus wieder an */
   v_clsvwk(handle); /* Workstation schlieûen */
   appl_exit();       /* Bei GEM abmelden */
   Pterm0();  /* und raus; nur nîtig, wenn in */
/* der INIT-C des  LASER der Sprung zur Exit- */
/* Routine entfernt wird (spart ca 3 Kb !) */
}                         

open_workstation()
{
    register int x;
    int  work_in[11],work_out[57],handle,dummy;

/* work_in Array fÅr GEM initialisieren */
    for(x = 0; x < 10; work_in[x++] = 1) 
         ;
    work_in[10] = 2;     
    handle = graf_handle(&dummy, &dummy, &dummy, 
                         &dummy);
    v_opnvwk(work_in, &handle, work_out);
    return handle;
}

mach_was_auf_den_bildschirm(handle)
register int handle;
{
   int dummy,rect[4];
   
   vst_height(handle,26,&dummy,&dummy,&dummy,
              &dummy);
   v_gtext(handle,128,100,
           "LEA.L _LAUFSCHRIFT,A0");
   
   vst_height(handle,13,&dummy,&dummy,&dummy,
              &dummy);
   v_gtext(handle,100,150,
"Dieser String scrollt in die andere Richtung.");

   vswr_mode(handle,2);           
   vsf_color(handle,1); /* Farbe schwarz */
   vsf_interior(handle,3); /* Strichmuster */ 
   vsf_style(handle,8);         
   
   rect_set(rect,159,199,208,380);
   v_bar(handle,rect);
   
   vsf_interior(handle,2);  /* Punktmuster */
   vsf_style(handle,4);
   rect_set(rect,319,299,560,330);
   v_bar(handle,rect);
   v_gtext(handle,330,320,
           "Z W E I BOXEN, die Scrollen!");
   
   vst_rotation(handle,900);
   vst_height(handle,6,&dummy,&dummy,&dummy,
              &dummy);
 /*  v_gtext(handle,40,350,"Das kommt doch auch 
             nicht schlecht, oder?");*/
}
 
scroll_bereiche_festlegen(links_oder_oben)
register int links_oder_oben;
{
   RECT koor;         

/* 2 Bereiche mit gleichen Koordinaten */
/* erlauben Diagonal Scrolling, wenn */
/* beide nacheinander gescrollt werden */

   rect_set(&koor,128,73,500,106);
   scrollinit(&koor,&s[0],links_oder_oben);    
   scrollinit(&koor,&s[4],!links_oder_oben);   
                                               
   rect_set(&koor,320,300,560,330);
   scrollinit(&koor,&s[1],!links_oder_oben);
   scrollinit(&koor,&s[5],links_oder_oben);
   
   rect_set(&koor,160,200,208,380);
   scrollinit(&koor,&s[2],!links_oder_oben);
   scrollinit(&koor,&s[6],!links_oder_oben);
   
   rect_set(&koor, 100,133,474,154);
   scrollinit(&koor,&s[3],!links_oder_oben);
   scrollinit(&koor,&s[7],links_oder_oben);
   
   rect_set(&koor,32,20,48,350);
   scrollinit(&koor,&s[8],links_oder_oben);
}
