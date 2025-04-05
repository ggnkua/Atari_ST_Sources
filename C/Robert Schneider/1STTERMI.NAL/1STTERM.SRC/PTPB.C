#define STRING01 "*****   (Maus-)Taste = MenÅ   *****"
#define STRING03 "          Zeit im System   %s      "
#define STRING04 " %3d.MenÅzeile wird geladen  "
#define STRING06 "M a i l b o x"

#define FORM01 "[%c][%s]"
#define FORM011 "[PROFIBOX]"
#define FORM02 "[2][Sind alle Angaben richtig ?][Ja|Nein|Abbruch]"

#define DIVI asm{DIVU #0,D0}

overlay "mailbox"

#include <gembind.h>
#include <osbind.h>
#include <megatadd.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

#define  Auxis()   while(!Bconstat(1)) if(mouse_but==3) return(0);
 


extern char *ptadr();
extern char *index();
extern char *rindex();

static pb_alert();
static pb_usnum();
static pb_password();
static pb_getnum();
static pb_usnew();
static show_menu();
static show_main();
static menu_update();
static get_main();
static get_sub();
static get_text();
static getsprofi();
static getsmen();

static int direct_men =0;

#define CLOSER 1        /* OBJECT in TREE #0 */
#define TITEL 2         /* OBJECT in TREE #0 */
#define INFOL 3         /* INFO-ZEILE */
#define SLIDEOUT 5      /* OBJECT in TREE #0 */
#define SLIDEIN 6       /* OBJECT in TREE #0 */
#define WINUP 7         /* OBJECT in TREE #0 */
#define WINDOWN 8       /* OBJECT in TREE #0 */
#define AREA 9

char *bwstring[] = {
"THIS IS THE WINDOW-TITEL 1111111111111111111111111111111111111111",
"  THIS IS THE INFO-LINE 11111111111111111111111111111111111111111",
""};

TEDINFO bwted[] = {
0L, 2L, 2L, 3, 6, 2, 0x1191, 0x0, -1, 66,1,
1L, 2L, 2L, 3, 6, 0, 0x1181, 0x0, -1, 66,1
};

#ifdef COLOR
OBJECT bwobj[] = {
-1,  1,  9, G_BOX,     NONE,      NORMAL, 0xFE1100L,    0, 12, 640,189, 
 2, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x5FF1100L,   1,  1,  16,  8, 
 3, -1, -1, G_BOXTEXT, NONE,      NORMAL, 0x0L,        18,  1, 621,  8, 
 4, -1, -1, G_BOXTEXT, NONE,      NORMAL, 0x1L,         1,  9, 621,  8, 

 9,  5,  8, G_BOX,     NONE,      NORMAL, 0xFF1101L,  623,  9,  15,180, 
 7,  6,  6, G_BOX,     TOUCHEXIT, NORMAL, 0xFF1151L,    1,  9,  15,162, 
 5, -1, -1, G_BOX,     TOUCHEXIT, NORMAL, 0xFF1101L,    0, 16,  15, 24, 

 8, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L,   1,  1,  15,  8, 
 4, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L,   1,172,  15,  8, 
 0, -1, -1, G_BOX,     LASTOB,    NORMAL, 0x11000l,     0, 17, 622,171  
};
#else
OBJECT bwobj[] = {
-1,  1,  9, G_BOX,     NONE,      NORMAL, 0xFE1100L,    0, 20, 640,378, 
 2, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x5FF1100L,   1,  1,  16, 16, 
 3, -1, -1, G_BOXTEXT, NONE,      NORMAL, 0x0L,        18,  1, 621, 16, 
 4, -1, -1, G_BOXTEXT, NONE,      NORMAL, 0x1L,         1, 18, 621, 16, 

 9,  5,  8, G_BOX,     NONE,      NORMAL, 0xFF1101L,  623, 18,  15,360, 
 7,  6,  6, G_BOX,     TOUCHEXIT, NORMAL, 0xFF1151L,    1, 18,  15,325, 
 5, -1, -1, G_BOX,     TOUCHEXIT, NORMAL, 0xFF1101L,    0, 32,  15, 48, 

 8, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L,   1,  1,  15, 16, 
 4, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L,   1,345,  15, 16, 
 0, -1, -1, G_BOX,     LASTOB,    NORMAL, 0x11000l,     0, 35, 622,343  
};
#endif

pb_alert()
{
   char s1[360];
   char s2[360];
   char icon,is_button,button[4];
   register char *p,*p1,*p2;
   register int a,c,b;
   

   TASSE;
   Auxis();
   icon=Bconin(1);
   p= &is_button;
   *p=0;
   if(icon=='2'||icon=='6')
   {
      *p=Bconin(1);
      *p=(*p>3||*p<1)? 2 : *p;
      for(b=0;b<*p;b++)
         button[b]=Bconin(1);
   }
   for(a=0;a<360;)
   {
      Auxis();
      c=Bconin(1);
      if(c==13)
         c='|';
      if(c=='\33')
         break;
      if(c>=' '&&c!=0x7f)
         s1[a++]=c;
   }
   s1[a]=0;
   p=s1; p1=s2;

   for(a=0;a<9;a++)
   {
      for(b=0;b<40;b++)
      {
         if(!*p)
            break;

         *p1=*p++;

         if(*p1++=='|')
            break;
      }
      *p1=0;

      if(!*p)
         break;

      if(b==40)
      {
         if((p2=index(p1-20,' ')))
         {
            *p2='|';
         }
         else
         {
            if((p2=index(p1-20,',')))
            {
               *p2='|';
            }
            else
            {
               *(p1)='|';
            }
         }
      }
   }
   sprintf(s1,FORM01,icon,s2);
   if(is_button)
   {
      s2[0]='[';
      s2[1]=button[0];
      for(a=1,b=2;a<is_button;s2[b++]='|',s2[b++]=button[a++]);
      s2[b++]=']';
      s2[b]=0;
      strcat(s1,s2);
   }
   else
      strcat(s1,FORM011);

   PFEIL;
   a=brain_alert(1,s1);
   if(is_button)
      Bconout(1,button[--a]);
   Bconout(1,13);
}

pb_usnum()
{
   int exit;
   char string[50];

   ptadr(logon_di,LG_USNUM,0);
   ptadr(logon_di,LG__PASS,0);
   undo_objc(logon_di,LG_USNUM,DISABLED);
   OB_FLAGS(logon_di,LG__OKAY)|=DEFAULT;
   do_objc(logon_di,LG__PASS,DISABLED);
   exit = hndl_dial(logon_di,LG_USNUM,SMXY,SMWH);

   undo_objc(logon_di,exit,SELECTED);

   switch(exit)
   {
      case LG__OKAY: ports(ptadr(logon_di,LG_USNUM,1));break;
      case LG___NEU: ports("\33N");break;
      case LG__GAST: ports("\33G");break;
      default      : break;
   }
   portc(13);
}

pb_password()
{
   int exit;
   char string[50];

   ptadr(logon_di,LG__PASS,0);
   undo_objc(logon_di,LG__PASS,DISABLED);
   OB_FLAGS(logon_di,LG__OKAY)|=DEFAULT;

   do_objc(logon_di,LG_USNUM,DISABLED);

   exit = hndl_dial(logon_di,LG__PASS,SMXY,SMWH);

   undo_objc(logon_di,exit,SELECTED);

   ports(ptadr(logon_di,LG__PASS,1));
   portc(13);

   if(main_da)
   {
      buf_end=menu[main_anz]+strlen(menu[main_anz]);
      main_da=0;
      main_anz=0;
   }
}

getsprofi(p,anz)
char *p;
int anz;
{
   for(;anz;anz--)
   {
      while(!Bconstat(1))
         if(mouse_but==3)
         {
            *p=0; return;
         }
      
      *p=Bconin(1);

      if(*p==27)
         break;

      if(*p>=' ')
         p++;
   }

   while(Bconstat(1))
      Bconin(1);

   *(p)=0;
}

pb_getnum()
{
   int exit,a=0;
   char string[50],*p;

   TASSE;
   p=ptadr(boxnr_di,BN__TEXT,0);
   getsprofi(p,40);
   PFEIL;

   ptadr(boxnr_di,BN____NR,0);

   exit = hndl_dial(boxnr_di,BN____NR,SMXY,SMWH);

   undo_objc(boxnr_di,exit,SELECTED);

   ports(ptadr(boxnr_di,BN____NR,1));
   portc(13);
}

pb_usnew()
{

   register int a,exit;
   register char *p;

   p=ptadr(user__di,US___NUM,0);
   ptadr(user__di,US___TEL,0);
   ptadr(user__di,US_PUTER,0);
   ptadr(user__di,USSTREET,0);
   ptadr(user__di,US__WOHN,0);
   ptadr(user__di,US__PASS,0);
   ptadr(user__di,US__NAME,0);

   for(a=0;a<4;a++)            /* Usernummer eintragen */
   {
      Auxis();
      p[a]=Bconin(1);
   }
   p[a]=0;

   do
   {
      exit = hndl_dial(user__di,US__NAME,SMXY,SMWH);
      undo_objc(user__di,exit,SELECTED);

      a=brain_alert(2,FORM02 );
   }while(a==2);

   if(a==3)
   {
      ports("\15\15\15\15\15\15");
      return;
   }
   ports(ptadr(user__di,US__NAME,1)); portc(13);
   ports(ptadr(user__di,US__PASS,1)); portc(13);
   ports(ptadr(user__di,US__WOHN,1)); portc(13);
   ports(ptadr(user__di,USSTREET,1)); portc(13);
   ports(ptadr(user__di,US___TEL,1)); portc(13);
   ports(ptadr(user__di,US_PUTER,1)); portc(13);
}

menu_update(y,h,wm,ob,an)
long y,h;
int wm,*ob,an;
{
   int a,b;

   if(y>1000) y=1000;
   if(y<0)    y=0;

   an-=2;
   *ob=(((an-max_ycur)*y)/1000);

#ifdef COLOR
   bwobj[SLIDEIN].ob_y=(int)(162l*(*ob))/an;
#else
   bwobj[SLIDEIN].ob_y=(int)(322l*(*ob))/an;
#endif

   objc_draw(bwobj,SLIDEOUT,1,SXY,SWH);
   objc_draw(bwobj,AREA,0,SXY,SWH);

   b=wm+*ob+2;
   for(a=0;a<max_ycur&&a<an-*ob;a++)
   {
      xcur=0; ycur=a;
      out_s(menu[a+b]);
   }
}

show_main(what,what_menu,anz)
int what,what_menu,anz;
{
   int a,b;
   char c;
   char string[100];
   long sli_y,sli_h;
   int winob;
   int oberste,x_xor,w_xor,end_y,end_anz;
   int mbuf[16];
   int mx,my,mb,mk,mkr,mbr;
   int revers=0;
   int exit=0;
   int event;
   int s_cr= when_cr;
   int vt52_save=onli_vt52;

   if(what_menu==100 && !sub_da)
   {
      ports("99\15");
      return;
   }

   if(!what_menu && !main_da)
   {
      ports("\33HN\15");
      return;
   }

   if(what)
   {
      a=1;
      TASSE;
      do
      {
         Auxis();         
         c=Bconin(1);
      }while(c!='(');
      a=0;
      do
      {
         *(menu[what_menu+1]+a++)=c;
         Auxis();
         c=Bconin(1);
      }while(c!=')');
      *(menu[what_menu+1]+a++)=c;
      *(menu[what_menu+1]+a)=0;
      PFEIL;
   }

   hide_mouse();

   when_cr=240;
   onli_vt52=0;


   bwted[0].te_ptext=bwstring[0];
   bwted[0].te_ptmplt=bwstring[2];
   bwted[0].te_pvalid=bwstring[2];

   bwted[1].te_ptext=bwstring[1];
   bwted[1].te_pvalid=bwstring[2];
   bwted[1].te_ptmplt=bwstring[2];

   bwobj[TITEL].ob_spec=(char *)&bwted[0];
   bwobj[INFOL].ob_spec=(char *)&bwted[1];

   strcpy(bwstring[0],menu[what_menu]);
   sprintf(bwstring[1],STRING03,menu[what_menu+1]);

#ifdef COLOR
   set_xy_cur(-1,8,30,616,171);
   if(anz<=max_ycur)
   {
      bwobj[SLIDEIN].ob_x=0;
      sli_y=bwobj[SLIDEIN].ob_y=0;
      sli_h=bwobj[SLIDEIN].ob_height=162;
   }
   else
   {
      sli_y=bwobj[SLIDEIN].ob_y=0;        
      sli_h=bwobj[SLIDEIN].ob_height=(int)((161l*(max_ycur+1))/(anz-2l));
   }
#else
   set_xy_cur(-1,8,57,616,343);
   if(anz<=max_ycur)
   {
      bwobj[SLIDEIN].ob_x=0;
      sli_y=bwobj[SLIDEIN].ob_y=0;
      sli_h=bwobj[SLIDEIN].ob_height=325;
   }
   else
   {
      sli_y=bwobj[SLIDEIN].ob_y=0;        
      sli_h=bwobj[SLIDEIN].ob_height=(int)((324l*(max_ycur+1))/(anz-2l));
   }
#endif

   objc_draw(bwobj,8l,SXY,SWH);

   for(a=2;a<max_ycur+2&&a<anz;a++)
   {
      xcur=0;
      ycur=a-2;
      out_s(menu[what_menu+a]);
   }
   oberste=0;
   set_mouse();

   x_xor=null_xcur+8;
   w_xor=null_xcur+608;
   end_anz=(max_ycur>anz-2) ? anz-2 : max_ycur;
#ifdef COLOR
   end_y=(end_anz<<3)+null_ycur-1;
#else
   end_y=(end_anz<<4)+null_ycur-1;
#endif

   while(mouse_but);
   while(Bconstat(1))
      Bconin(1);
   do
   {
      while(mouse_but!=1)
      {
         if(Bconstat(2))
         {
            Bconin(2);
            exit=1;
            goto ABFLUG;
         }
                        
         if(Bconstat(1))
         {
            exit=1;
            goto ABFLUG;
         }
                        

         if(mouse_but==2)
         {
            revers = 0;
            hide_mouse();
            form_dial(3,0l,0l,SXY,SWH);
            onli_vt52=vt52_save;
            set_xy_cur(wi_han1);              /* Parameter fÅr redraw   */
            do_redraw();
            while(mouse_but==2);
            onli_vt52=0;
            objc_draw(bwobj,8l,SXY,SWH);
#ifdef COLOR
            set_xy_cur(-1,8,30,616,171);
#else
            set_xy_cur(-1,8,57,616,343);      /* Parameter fÅr redraw und text*/
#endif
            menu_update(sli_y,sli_h,what_menu,&oberste,anz);
            show_mouse();
         }

         if(mouse_y<null_ycur||mouse_y>end_y||mouse_x>w_xor||mouse_x<x_xor+1)
         {
            if(revers)
            {
               hide_mouse();
#ifdef COLOR
               xor_box(x_xor,revers,w_xor,revers+7);
#else
               xor_box(x_xor,revers,w_xor,revers+16);
#endif
               show_mouse();
            }
            revers=0;
         }
         else
         {
#ifdef COLOR
            a=(mouse_y-null_ycur)>>3;
            a=(a<<3)+null_ycur;
            if(revers!=a)
            {
               hide_mouse();
               if(revers)
                  xor_box(x_xor,revers,w_xor,revers+7);
               revers=a;
               xor_box(x_xor,revers,w_xor,revers+7);
               show_mouse();
            }
         }
#else
            a=(mouse_y-null_ycur)>>4;
            a=(a<<4)+null_ycur;
            if(revers!=a)
            {
               hide_mouse();
               if(revers)
                  xor_box(x_xor,revers,w_xor,revers+16);
               revers=a;
               xor_box(x_xor,revers,w_xor,revers+16);
               show_mouse();
            }
         }
#endif
      }

      if(revers)
      {
         hide_mouse();
#ifdef COLOR
         xor_box(x_xor,revers,w_xor,revers+7);
#else
         xor_box(x_xor,revers,w_xor,revers+16);
#endif
         show_mouse();
      }
      revers=0;

      winob=objc_find(bwobj,0,8,mouse_x,mouse_y);
      if(winob!=-1)
         winob&=0x7fff;
      if(winob>0)
         switch(winob)
         {
            case SLIDEIN  :
               if(anz<max_ycur)
                  break;

               sli_y=graf_slidebox(bwobj,SLIDEOUT,SLIDEIN,1);
               menu_update(sli_y,sli_h,what_menu,&oberste,anz);
               break;

            case SLIDEOUT:
               if(anz<max_ycur)
                  break;

               objc_offset(bwobj,SLIDEIN,&a,&b);
               if(mouse_y<b)
               {
                  /* Page up */
#ifdef COLOR
                     sli_y-=((sli_h*1000)/162);
#else
                     sli_y-=((sli_h*1000)/324);
#endif
                     sli_y=(sli_y>0) ? sli_y : 0;
                     menu_update(sli_y,sli_h,what_menu,&oberste,anz);
               }
               else
               {
#ifdef COLOR
                     sli_y+=((sli_h*1000)/162);
#else
                     sli_y+=((sli_h*1000)/324);
#endif
                     sli_y=(sli_y<1000) ? sli_y : 1000;
                     menu_update(sli_y,sli_h,what_menu,&oberste,anz);
               }
               break;

               case WINUP:             /* EINE ZEILE NACH OBEN */
                  if(!oberste||anz<max_ycur)
                     break;
                  sli_y-= (1000/(anz-2)+4);
                  sli_y = (sli_y>0) ? sli_y : 0;
                  menu_update(sli_y,sli_h,what_menu,&oberste,anz);
                  break;


               case WINDOWN:           /* EINE ZEILE NACH UNTEN */
                  if(sli_y>=1000||anz<max_ycur)
                     break;
                  sli_y+= (1000/(anz-2)+4);
                  sli_y = (sli_y<1000) ? sli_y : 1000;
                  menu_update(sli_y,sli_h,what_menu,&oberste,anz);
                  break;

               case AREA:
                  a=mouse_y-null_ycur;
                  if(a<0)
                     break;
#ifdef COLOR
                  a>>=3;
#else
                  a>>=4;
#endif
                  a+=oberste+1;
                  if(a>anz)
                     break;
                  if(mouse_x<x_xor||mouse_x>w_xor)
                     break;
                  if(mouse_y<null_ycur||mouse_y>end_y)
                     break;
                  if(a!=anz-2)
                  {
                     if(a==anz-3)
                        strcpy(string,"99\15");
                     else
                        sprintf(string,"%d\15",a);
                        ports(string);
                     exit=1;
                     break;
                  }

            case CLOSER:
               ports("\33Q\15");
               login=0; main_anz=0; main_da=0;
               buf_end=buf_start+ buf_size;
               boxstart=buf_point; sub_anz=0; sub_da=0;
               exit=1; 
               break;

            default    : break;
         }
   }while(!exit);


ABFLUG:
   form_dial(3,0l,0l,SXY,SWH);
   onli_vt52=vt52_save;
   set_xy_cur(wi_han1);
   do_redraw();

   when_cr=s_cr;
}

show_menu()
{
   int a;
   char c;

   Auxis();
   c=Bconin(1);

   if(!direct_men)
   {
      out_c(7);
#ifndef COLOR
      if(onli_vt52)
         out_s(STRING01);
      else
#endif
         wind_set(wi_han1,WF_NAME,STRING01);
      while(!Bconstat(2))
         if(mouse_but)
            break;
#ifndef COLOR
      if(onli_vt52)
      {
         hide_mouse();
         clr_line(ycur);
         show_mouse();
      }
      else
#endif
         wind_set(wi_han1,WF_NAME,windtitel);
     while(mouse_but);
   }

   while(Bconstat(2))
      Bconin(2);
   direct_men=0;

/*
   a=alert_akt;
   alert_akt=0;
   irq_menu=1;
   wind_update(END_MCTRL);
*/
   switch(c)
   {
      case 'H' : show_main(1,0,main_anz); break;
      case 'S' : show_main(1,100,sub_anz); break;
   }
/*
   wind_update(BEG_MCTRL);
   irq_menu=0;
   alert_akt=a;
*/
}

getsmen(plus)
int plus;
{
   int a,b,c,d;
   char string[300];

   for(b=0;b<100;b++)
   {
      sprintf(string,STRING04,b+1);
#ifndef COLOR
      if(onli_vt52)
      {
         xcur=0;
         out_s(string);
      }
      else
#endif
         wind_set(wi_han1,WF_NAME,string);

      if(b<2)
         a=0;
      else
      {
         sprintf(string,"  %3d     ",b-1);
         a=10;
      }

      for(;a<240;a++)
      {

         while(!Bconstat(1))
            if(mouse_but==3)
            {
#ifndef COLOR
               if(onli_vt52)
               {
                  hide_mouse();
                  clr_line(ycur);
                  show_mouse();
               }
               else   
#endif
                  wind_set(wi_han1,WF_NAME,windtitel);
               return(0);
            }
         Auxis();
         c=Bconin(1);
         if(c==13||c==10)
         {
            a--;
            continue;
         }
         if(c==0||c=='\33')
            break;
         string[a]=c;
      }
      string[a]=0;
      buf_end-=a+1;
      if(buf_end-80<=buf_point)
      {
         PFEIL;
         buf_wrong();
         TASSE;
      }
      strcpy(buf_end,string);
      menu[b+plus]=buf_end;
      if(c=='\33')
         break;
   }
#ifndef COLOR
   if(onli_vt52)
   {
      hide_mouse();
      clr_line(ycur);
      show_mouse();
   }
   else
#endif
      wind_set(wi_han1,WF_NAME,windtitel);
   return(b);
}

get_main()
{
   TASSE;

   if(!main_da)
   {
      if((main_anz=getsmen(0)))
         main_da=1;
      else
         main_da=0;
   }
   else
   {
      do
      {
         Auxis();
      }while((char)Bconin(1)!=27);
   }

   PFEIL;
}

get_sub()
{
   TASSE;

   buf_end=menu[main_anz];

   if((sub_anz=getsmen(100)))
      sub_da=1;
   else
      sub_da=0;

   PFEIL;
}

get_text()
{
   char *p,string[100];
   char e_string[42];
   int a=0;

   TASSE;
   p=e_string;
   getsprofi(p,40);

   string[0]=0;

   PFEIL;
   file_name(STRING06,string,string,e_string,string);
   ports(string);
   portc(13);
}

escape()
{
   char c;
   int x,y;

   Auxis();
   c=Bconin(1);

   if(onli_vt52&&(c!=' '))
      vt_what(c);
   else
   {
      if(profibox)
      {
         set_mouse();
         x=xcur;
         y=ycur;
         xcur=0;
         ycur=max_ycur;
         Auxis();
         c=Bconin(1);

         wind_update(END_MCTRL);
         wind_update(BEG_MCTRL);
         alert_akt=1;
         irq_menu=0;
         save_screen();
         switch(c)
         {
            case'A': pb_usnum(); break;
            case'B': pb_password(); break;
            case'C': pb_usnew(); break;
            case'D': direct_men=1;break;
            case'F': pb_alert(); break;
            case'M': while(!Bconstat(1))
                        if(mouse_but==3)
                           break;
                     if(Bconstat(1))
                     {
                        c=Bconin(1);
                        switch(c)
                        {
                           case 'H' : get_main(); break;
                           case 'S' : get_sub(); break;
                        }
                     }
                     break;
            case'N': direct_men=0;pb_getnum(); break;
            case'S': show_menu(); break;
            case'T': get_text(); break;
            default: break;
         }
         do_redraw();
         alert_akt=0;
         xcur=x;
         ycur=y;
      }
   }
}
