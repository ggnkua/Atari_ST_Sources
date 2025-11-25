/* F r a c t a l        File: FRAKT_TS.C   (auch: FEIGEN.C)     
   Ordner:  GRAPHIK
   Umsetzung von "GFA-Basic"  in  "Lattice-C":   Th. Schaerer
   UnterstÅtzung beim Entwurf des Fraktalteiles: Max Duenki
   Juli-88 / Sep-88(Zoom)
   ---------------------------------------------------------------------- */

#include "myheader.h"
#include "inigem.h"

#define norm_g  vswr_mode(handle,1);
#define exor_g  vswr_mode(handle,3);
#define tsch       xbios(28,  5,12+128);  xbios(28,12,6+128);
#define shortsalve xbios(28, 10,12+128);  xbios(28,18,6+128); 
#define longsalve  xbios(28,255,12+128);  xbios(28,31,6+128); 

          /* Define 3 und 5 :   Decay-Time (HÅllkurve) / Noise-Bandwidth */


char taste;
double a;
int dummy;


/* ..........6 verschiedene Funktionen des Fraktales..................... */


double f1(x)
double x;
{
   return (a*x*(1.-x));
}


double f2(x)
double x;
{
   return (a*sin(PI*x));
}


double f3(x)
double x;
{
   return (a*(sin(PI*x))*(sin(PI*x)));
}


double f4(x)
double x;
{
   return (a*x*x*(1-x));
}


double f5(x)
double x;
{
   return (a*x*(1-x)*(1-x));
}


double f6(x)
double x;
{
   return (a*x*x*(1-x)*(1-x));
}


/* ......................................................................*/

void shoot_on()       /* SOUND - Funktionen */
{
  xbios(28,247,7+128);                       /* Mixer:  Kanal_1 Rauschen */
  xbios(28,16,8+128);     /* Volume: HÅllkurve fÅr Kanal_1 ist aktiviert */
  xbios(28,255,11+128);                  /* HÅllkurvenperiode (Low-Byte) */
                             /*  HÅllk.(Highbyte) = Variabel in Funktion */
  xbios(28,9,13+128);               /* HÅllkurventypus:  Abfall, ein Mal */

}



void sound_off()
{
  int kanal;

        xbios(28,255,7+128);           /* Alle KanÑle = off */
  for(kanal=8;kanal<=10;kanal++)       /* Alle Volume = 0   */
          xbios(28,0,kanal+128);

}


/* . . . . . . . . . . .                       . . . . . . . . . . . . . */


void graphikende()     /* vorwiegend SOUND-Funktion  */
{

  /* Dreiklang-Tonleiter mit Accord */

  sound_off();

  xbios(28,16,8+128);            /* Volumen: HÅllkurve fÅr Kanal 1 */
  xbios(28,254,7+128);           /* Kanal 1 = on */
  xbios(28,255,11+128);          /* HÅllkper. Lowbyte */
  xbios(28,127,12+128);          /* HÅllkper. Highbyte */
  xbios(28,1,1+128);             /* Tonfrq.  Higbyte */

  xbios(28,9,13+128);            /* HÅllk-Typus. ein Mal Abfall */
  xbios(28,221,0+128);           /* Tonfrq.  Lowbyte = C_0 */
  sleep(700);
  xbios(28,9,13+128);            /* HÅllk-Typus. ein Mal Abfall */
  xbios(28,123,0+128);           /* Tonfrq.  Lowbyte = E_0 */
  sleep(700);
  xbios(28,9,13+128);            /* HÅllk-Typus. ein Mal Abfall */
  xbios(28,62,0+128);            /* Tonfrq.  Lowbyte = G_0 */
  sleep(1000);
  xbios(28,9,13+128);            /* HÅllk-Typus. ein Mal Abfall */
  xbios(28,248,7+128);           /* Kanal 1 bis 3 = on */
  xbios(28,255,12+128);          /* HÅllkper. Highbyte */
  xbios(28,16,9+128);            /* Volumen: HÅllkurve fÅr Kanal 2 */
  xbios(28,16,10+128);           /* Volumen: HÅllkurve fÅr Kanal 3 */

  pos_curs(0,75);
  puts("Ende");

  xbios(28,123,0+128);           /* Tonfrq.  Lowbyte  = E_0 */
  xbios(28,1,1+128);             /* Tonfrq.  Highbyte = E_0 */
  xbios(28,62,2+128);            /* Tonfrq.  Lowbyte  = G_0 */
  xbios(28,1,3+128);             /* Tonfrg.  Highbyte = G_0 */
  xbios(28,238,4+128);           /* Tonfrq.  Lowbyte  = C_1 */ 
  xbios(28,0,5+128);             /* Tonfrq.  Highbyte = C_1 */
  
}



/* ......................................................................*/


void kreise()
{
  WORD rad;

  for(rad=1;rad<50;rad+=3)
    v_circle(handle,500,200,rad);
}

/* ......................................................................*/



void titel()
{
  WORD pxyarray[4],pxyarray_1[4],type=0,x_rad,blink,style=6,height,
    repeat,salve,z,line;
    
  srand(Gettime());

  pxyarray[0]=pxyarray[1]=0;  pxyarray[2]=639;  pxyarray[3]=399; /* Black */ 
  vsf_interior(handle,1);
  vr_recfl(handle,pxyarray);
  
  revrs_curs();
  sleep(1000);
  pos_curs(11,3);
  printf("Beginne  ");                    sleep(300);
  printf("mit  ");                        sleep(300);
  printf("einem  ");                      sleep(300);
  printf("MG-Startschuss  ");             sleep(300);
  printf("und  ");                        sleep(300);
  printf("einer  ");                      sleep(300);
  printf("heftigen  ");                   sleep(300);
  printf("Explosion !");
  sleep(1000);
  pos_curs(20,10);
  puts("Drehe beim Monitor den Volume-Regler auf");
  pos_curs(21,10);
  puts("und drÅcke eine beliebige Taste .");
  catchkey();
  getch();
  
  pos_curs(11,3);                       /* Zeilen im Schwarzfeld lîschen */
  printf("                                        ");
  puts("                                          ");
  pos_curs(20,10);
  puts("                                          ");
  pos_curs(21,10);
  puts("                                          ");

  norm_curs();


  for(salve=0;salve<=16;salve++)          /* Seriefeuer auf Dynamitblock */
    {
    shortsalve;
    shoot_on();
    sleep(100);
    }


  sleep(200);
  longsalve;
  shoot_on();                             /* Der Dynamitblock explodiert */
  clr_scr();
  sleep(1000);


  for(type=0; type<=3; type+=3)
    {
    vswr_mode(handle,type);                    /* graphmode ist variabel */
    for(line=0; line<2000; line++)                      /* Line - Random */
      {
      pxyarray[0]=rand()%639;                         
      pxyarray[1]=rand()%399;
      pxyarray[2]=rand()%639;
      pxyarray[3]=rand()%399;
      v_pline(handle,2,pxyarray);
      if(line<100 && type==0)     sleep(300/line); /* Anfangsverzîgerung */  
      }
    }

  sound_off();     /* Soundchip desaktivieren (~ Wave 0,0 des GFA-Basic) */

  norm_g;
  vsf_interior(handle,0);

  for(x_rad=10;x_rad<=200; x_rad+=5)
    v_ellipse(handle,320,200,x_rad,x_rad/2);


  vst_effects(handle,4);                                /* Schrift-Stil */
  vst_height(handle,26,&dummy,&dummy,&dummy,&dummy);    /* Schrifthîhe  */

  exor_g;

  sleep(500);

  for(blink=0;blink<19;blink++)
    {
    v_gtext(handle,200,170,"F R A K T A L");
    sleep(70);
    }
  sleep(1000);

  norm_g;
  vst_height(handle,20,&dummy,&dummy,&dummy,&dummy);

  for(blink=0;blink<30;blink++)       /* Textblinken mit Style-Inversion */
    {
    vst_effects(handle,style);
    v_gtext(handle,235,230,"m i t   Z O O M");
    sleep(100);
    style^=2;                  
    }

  sleep(1000);

  v_ellipse(handle,320,200,x_rad,x_rad/2); /* Inhalt der Ellipse lîschen */
  sleep(500);

  exor_g;  
  vst_effects(handle,12);                                /* Schrift-Stil */

  for(repeat=0;repeat<3;repeat++)             /* 3 mal wachsende Schrift */
    {
    for(height=13;height<=26;height++)         
      {
      vst_height(handle,height,&dummy,&dummy,&dummy,&dummy);
    
      for(blink=0;blink<=1;blink++)
        {
        v_gtext(handle,215,200,"Z O O M");
        if(blink==0)  sleep(50);         /* nur Verzîgerung wenn Schrift */
        }
      }
    }

  v_gtext(handle,215,200,"Z O O M");
  sleep(2000);
  
  catchkey();
  norm_g;
  x_rad=240;
  v_ellipse(handle,320,200,x_rad,x_rad/2);
  sleep(500); 


  vst_height(handle,7,&dummy,&dummy,&dummy,&dummy);
  style=0; 

  z=145;
  vst_effects(handle,8);
  v_gtext(handle,180,z,"F R A K T A L :");
  v_gtext(handle,240,275,"Taste drÅcken");
  
  do
  {
    vst_effects(handle,style);
    v_gtext(handle,160,z+30,"Von einem Basicprogramm");
    v_gtext(handle,160,z+45,"in 'C' umgesetzt:");
    v_gtext(handle,160,z+60,"TH.SCHAERER");
    v_gtext(handle,160,z+80,"UnterstÅtzung durch:");
    v_gtext(handle,160,z+95,"MAX DöNKI");

    kreise();

    style^=2;                  
  }
  while(!inkey);


  catchkey();
  v_ellipse(handle,320,200,x_rad,x_rad/2);
  sleep(500);

    
  vst_effects(handle,8);
  v_gtext(handle,180,z,"Zoomen des Fraktal:");
  v_gtext(handle,240,275,"Taste drÅcken");
  
  do
  {
    vst_effects(handle,style);
    v_gtext(handle,160,z+30,"Eigenentwurf,erste Arbeit");
    v_gtext(handle,160,z+45,"mit Maus-Parameter:");
    v_gtext(handle,160,z+60,"TH.SCHAERER");
    v_gtext(handle,160,z+72,"_________________________");
    v_gtext(handle,160,z+95,"Arbeit beendet: Sept-88  ");

    kreise();

    style^=2;                  
  }
  while(!inkey);



  vsf_interior(handle,0);
  pxyarray[0]=0;      pxyarray[2]=640;      pxyarray[3]=400;
  pxyarray_1[0]=0;    pxyarray_1[2]=640;    pxyarray_1[3]=0;

  for(pxyarray[1]=400;pxyarray[1]>=200;pxyarray[1]-=2)   /* Bild lîschen */
    {
    pxyarray_1[1]=400-pxyarray[1];
    vr_recfl(handle,pxyarray); 
    vr_recfl(handle,pxyarray_1);
    }
}


/* ......................................................................*/


void zoom(vertline_a,vertline_b)
WORD *vertline_a,*vertline_b;
{
  WORD pstatus,vertline_1=0,vertline_2=0,pxyarray_1[4],pxyarray_2[4],
       count=0,x;  

  exor_g;

  pxyarray_1[1]=pxyarray_2[1]=0;  
  pxyarray_1[3]=pxyarray_2[3]=399; 

  pos_curs(0,0);
  puts("Zoom ausfÅhren (z)   /erst mîglich wenn 2.Strich gesetzt/");
  puts("              ");   

  graf_mouse(THIN_CROSS,0);
  show_mouse();
  catchkey();
  taste=' ';           /* damit 'z' von der MAIN-Funktion unwirksam ist */

  do
  {
    vq_mouse(handle,&pstatus,&x,&dummy);

    if(pstatus==1 && count<=1)                 /* Linie setzen l. Taste */    
      { 
      if(count==0)   { vertline_1=x;   pxyarray_1[0]=vertline_1; }
      if(count==1)   { vertline_2=x;   pxyarray_2[0]=vertline_2; }
      pxyarray_1[2]=pxyarray_1[0];
      pxyarray_2[2]=pxyarray_2[0];
      hide_mouse();
      
      if(count==0)                           
        v_pline(handle,2,pxyarray_1);               
      else if(count==1 && vertline_2!=vertline_1) 
        v_pline(handle,2,pxyarray_2);

      show_mouse();
      do {vq_mouse(handle,&pstatus,&dummy,&dummy);} while(pstatus==1);
      if(vertline_2!=vertline_1)  
      count++;                /* count=2 wenn beide Linien gesetzt sind */
      }
      
    else 
    if(pstatus==2 && count>=1)                /* Linie lîschen r. Taste */
      {               
      hide_mouse();

      if(count==1 && x==vertline_1) 
        {count--;  v_pline(handle,2,pxyarray_1);}
      else if(count==2 && x==vertline_2) 
        {count--;  v_pline(handle,2,pxyarray_2);}

      show_mouse();
      do {vq_mouse(handle,&pstatus,&dummy,&dummy);} while(pstatus==2);
      }

  }
  
  while(((taste=inkey)!='z') || (count!=2));


  if(vertline_1>vertline_2) {                /* Wundersame SWAP-Funktion */
    vertline_1^=vertline_2;                 
    vertline_2^=vertline_1;                  
    vertline_1^=vertline_2; }


  *vertline_a=vertline_1;                         /* Raus in die Adresse */
  *vertline_b=vertline_2;

  hide_mouse();
  norm_g;
}


/* ......................................................................*/




void type_blank()
{
  pos_curs(0,0);
  puts("                                                          ");
  puts("              ");
  puts("                    ");
  pos_curs(22,0);                      
  printf("                         \n");
  printf("                         \n");
  catchkey();
}


/* ......................................................................*/


void main()
{
  WORD vertline_1, vertline_2;
  double f1(), f2(), f3(), f4(), f5(), f6(); 
  double anf, ende, anf_x, ende_x, dif, cc, x;
  double (*f)();
  int breit = 639, hoch = 399, t;
  register int i,j;    
  char *txt[6],*ts;
     
  scr=(WORD *)Physbase();             /* Pixelstartwert:  put_pixel(x,y) */

  txt[0] = " FÅr 'a' in [0, 4]         f1(x)= a*x*(1-x)             ";
  txt[1] = " FÅr 'a' in [0, 1]         f2(x)= a*sin(pi*x)           ";
  txt[2] = " FÅr 'a' in [0, 1]         f3(x)= a*sin(pi*x)^2         ";
  txt[3] = " FÅr 'a' in [0, 6.75]      f4(x)= a*x*x*(1-x)           ";
  txt[4] = " FÅr 'a' in [0, 6.75]      f5(x)= a*x*(1-x)*(1-x)       ";
  txt[5] = " FÅr 'a' in [0, 16]        f6(x)= a*x*x*(1-x)*(1-x)     ";
  ts = "/     Taste: ";
 
  open_job();
  hide_mouse();

  titel();


  do
  {
    clr_scr();
    puts(" CHAOS  oder  ORDNUNG,  das ist hier die Frage ???????");
    puts(" _____________________________________________________");
    t = 1;
    pos_curs(4,0);

    for(t=1; t<=6; t++)
       printf("%s%s%d\n\n",txt[t-1],ts,t);                      /* Menue */
   
    puts("");   puts("");  
    puts(" Falls Sie jetzt schon genug haben.....            / Taste 'q'");

    catchkey();

    do
    {
       taste = getch();
    }
    while((taste<'1' || taste>'6') && taste != 'q');   

   
    if(taste != 'q') 
    {
      t = taste - '0';                 /* Zeichen - Zahl - Convertierung */
      clr_scr();
      pos_curs(3,2);
      printf("%s\n",txt[t-1]); 
      puts("  --------------------");     puts("");
      puts(".............................................................");
      pos_curs(10,5);
      printf(" Untere Grenze fuer  'a' :   ");
      scanf("%lf",&anf);    rewind(stdin);    
      pos_curs(12,5);
      printf(" Obere  Grenze fuer  'a' :   ");
      scanf("%lf",&ende);   rewind(stdin);
      pos_curs(20,30);     
      puts("Viel  Spass !");     sleep(1000);

      switch(taste)
        {                                           /* Wahl der Funktion */
        case '1':   f=f1;    break;
        case '2':   f=f2;    break;
        case '3':   f=f3;    break;
        case '4':   f=f4;    break;
        case '5':   f=f5;    break;
        case '6':   f=f6;    break;
        }
                  



      do   /* Innerhalb dieses Loop werden die gezoomten Fraktale kreirt */
      {
        
    
        dif = ende - anf;                  /* Bereich des Fraktal - Loop */
        cc  = dif/breit;

        clr_scr();
        pos_curs(0,0);
        puts("Zoom dimensionieren (z)                             ");
        puts("Abbrechen (q)                                       ");
        puts("Schrift lîschen (b) ");
        pos_curs(22,0);                      
        printf("Startwert = %2.7lf\n",anf);
        printf("Endwert   = %2.7lf\n",ende);


                                             /****************************/
        for(i=0; i<=breit; i++)              /* >>>> Fraktal - Loop <<<< */
          {                                  /*      ______________      */

          if(((taste=inkey)=='q') || (taste=='z'))  break;
          else if(taste=='b')                         type_blank(); 
          
          a = i * cc + anf;
          x = 0.567;                                  /* Startwert von x */
         
          for(j=1; j<=50; j++)  
            x = (*f)(x);                      /* 50 Rechnungen ohne Plot */

          for(j=1; j<=(int)(0.7*hoch); j++)
            {
            x = (*f)(x);            
            put_pixel((WORD)i,(WORD)(x*hoch));
            }
          }

          
        if(i<=breit)
          {
          sound_off();              /* Desaktivieren der KanÑle 2 u. 3 */
          if(taste=='z')           { tsch;        shoot_on(); }
          else if(taste=='q')      { longsalve;   shoot_on(); } 
          }


        else if(i>breit)
          {
          graphikende();
          while(((taste=getch())!='z') && (taste!='q'));
          }



        if(taste=='z')                     /* Ereignis nach dem Zoomen */
          {
          zoom(&vertline_1,&vertline_2);         /* Zoomen */
          anf_x =((double)vertline_1/(double)breit*(ende-anf))+anf; 
          ende_x=((double)vertline_2/(double)breit*(ende-anf))+anf;
          anf=anf_x;         /* Neuer Startwert in Parameter Åbergeben */
          ende=ende_x;       /* Neuer Startwert in Parameter Åbergeben */
          }
        else if(taste=='q')   break;



      }   /* Ende der Graphik */   
      while(taste!='q');

      clr_scr();
      pos_curs(10,5);
      puts(" Neues   F r a k t a l ?           j / n");

      while(((taste=getch())!='j') && (taste!='n'));
      
    }
  }
  while(taste=='j');

  pos_curs(22,30);  
  puts(" Schade ....");
  sleep(1500);
   
  show_mouse();
}              
/* Hinweis: EXOR-Graphmode beeinflusst 'put_pixel(x,y)' nicht !!!

                                                        PROGRAMM - ENDE 
                                                        ---------------
--------------------------------------------------------------------------*/
