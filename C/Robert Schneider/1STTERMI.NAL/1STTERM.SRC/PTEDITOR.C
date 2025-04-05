overlay "editor"

#include <osbind.h>
#include "ptvars.h"

extern char *ptadr();
extern char *index();
extern char *rindex();
extern long calc_xy_adr();
extern int bwstrcpy();

int max_lines;
int linecount;
int oberste;
char txtname[80];
char **edtext;

load_men()
{
   GRECT box;
   char name[20];
   char byte;
   int exit;
   int a;
   int handle;
   int b;
   long count=0;
   long len;
   long max;
   long fil_len();

   txtname[0]=name[0]=0;
   if(!file_select("Editierdatei ausw„hlen !",txtname,name,"*.*"))
      return(0);

   strcat(txtname,name);

   handle=Fopen(txtname,0);

   edtext=(char **)buf_start;
   max_lines=buf_size/86;
   max_lines=(max_lines>8100||max_lines<0) ? 8100 : max_lines;
   /* von wegen 4 Mega und so */
   edtext[0]=(char *)edtext;
   edtext[0]+=(max_lines<<2);
   for(a=1;a<max_lines;a++)
   {
      edtext[a]=edtext[a-1]+81;
      *edtext[a]=0;
   }

   if(handle<6)
   {
      a=brain_alert(1,"[2][Datei existiert noch nicht !|Einrichten ?][Ja|Nein]");
      if(a==1)
      {
         clr_window(top_window);
         save_screen();
         linecount=0;
         return(1);
      }
      else
         return(0);
   }

   clr_window(top_window);
   save_screen();

   TASSE;
   for(a=0;a<max_lines&&count<len;a++)
   {
      for(b=0;b<max_xcur&&count<len;b++)
      {
         if(Fread(handle,1l,&byte)!=1)
         {
            linecount=a;
            *(edtext[a]+b) = 0;
            Fclose(handle);
            PFEIL;
            return(1);
         }
         count++;

         if(byte!=13)
         {
            *(edtext[a]+b) = byte;
            continue;
         }

         if(byte==13)
         {
            Fread(handle,1l,&byte);
            count++;
         }
         break;

      }
      *(edtext[a]+b) = 0;
   }
   linecount=a;
   linecount=(linecount<max_lines) ? linecount : max_lines;
   Fclose(handle);
   PFEIL;
   return(1);
}

save_men()
{
   int a;
   int handle;
   char space[3];

   handle=Fcreate(txtname,0);
   if(handle<6)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }
   TASSE,
   strcpy(space,"\15\12");
   for(a=0;a<=linecount;a++)
   {
      Fwrite(handle,(long)strlen(edtext[a]),edtext[a]);
      Fwrite(handle,2l,space);
   }
   Fclose(handle);
   PFEIL;
}

ed_a_msg()
{
   int a;
   int scan;
   int asc;
   int topend=0;
   char string[360];
   char s[40];

   if((long)buf_start != (long)buf_point)
      if(brain_alert(1,"[1][Achtung !||Puffer wird gel”scht !][Abbruch|OK]")==1)
         return(0);

   if(!load_men())
      return(0);

   hide_mouse();

   top_of_text();

   do
   {
      cursor();
      asm
      {
         MOVE.W   #2,-(A7)
         MOVE.W   #2,-(A7)
         TRAP     #13
         ADDQ.L   #2,A7
         MOVE.W   D0,asc(A6)
         SWAP     D0
         ANDI.W   #0XFF, D0
         MOVE.W   D0,scan(A6)
      }
      del_cursor();

      if(asc>=0x20&&asc!=0x7f)
      {
         store(asc);
         continue;
      }
      if(asc==13)
      {
         carriage();
         continue;
      }
      if(asc==8)
      {
         backspace();
         continue;
      }
      if(asc==9)
      {
         a=xcur;
         a/=3;
         a*=3;
         a+=3;
         while(a>xcur&&xcur<max_xcur)
         {
            insert();
            right();
         }
         continue;
      }
      if(asc==0x7f)
      {
         delete();
         continue;
      }
      if(asc==0)
      {
         switch(scan)
         {
            case 0x61 : show_mouse();
                        if(brain_alert(1,"[2][Abspeichern ??][Ja|Nein]")==1)
                           save_men();
                        buf_point=buf_start;
                        return(1);

            case 0x3c : insert_line();
                        break;

            case 0x3b : delete_line();
                        break;

            case 0x3d : xcur=0; break;

            case 0x3e : xcur=strlen(edtext[oberste+ycur]); break;

            case 0x3f : *(edtext[oberste+ycur])=0; *(edtext[oberste+ycur]+1)=0;
                        xcur=0;
                        clr_line(ycur);
                        break;

            case 0x47 : if(topend)
                        {
                           topend=0;
                           top_of_text();
                        }
                        else
                        {
                           topend=1;
                           end_of_text();
                        }
                        break;

            case 0x44 : show_mouse();
                        sprintf(string,
"[1][Dateiname:|%s|Cursor: Zeile: %3d Spalte: %3d|momentane Zeilenanzahl: %4d|maximale Zeilenanzahl %4d][OK]",
                        txtname,oberste+ycur,xcur,linecount,max_lines-1);
                        brain_alert(1,string);
                        hide_mouse();
                        break;

            case 0x62 : show_mouse();
                        show_help();
                        hide_mouse();
                        break;

            case 0x48 : up(); break;
            case 0x50 : down(); break;
            case 0x4b : left(); break;
            case 0x4d : right(); break;

            case 0x52 : insert(); break;
         }
      }
   }while(1);
}

store(byte)
char byte;
{
   if(xcur>=max_xcur)
      return;

   if(*(edtext[oberste+ycur]+xcur))
      *(edtext[oberste+ycur]+xcur)=byte;
   else
   {
      *(edtext[oberste+ycur]+xcur)=byte;
      *(edtext[oberste+ycur]+xcur+1)=0;
   }
   out_c(byte);
}

carriage()
{
   xcur=0;
   if(ycur<max_ycur)
   {
      if(oberste+ycur>=linecount)
      {
         if(linecount<max_lines)
         {
            linecount++;
            *(edtext[linecount])=0;
            ycur++;
         }
      }
      else
         ycur++;
   }
   else
   {
      if(oberste+ycur<linecount)
      {
         oberste++;
         out_c(10);
         xcur=0;
         out_s(edtext[oberste+ycur]);
         xcur=0;
      }
      else
      {
         if(linecount<max_lines-1)
         {
            linecount++;
            oberste++;
            xcur=0;
            *(edtext[linecount])=0;
            out_c(10);
         }
      }
   }
}

insert()
{
   int a,b,x;

   if(strlen(edtext[oberste+ycur])>79)
      return;

   x=xcur;
   b=oberste+ycur;
   a=strlen(edtext[b]);
   for(xcur=a;xcur>=x;xcur--)
      *(edtext[b]+xcur+1)= *(edtext[b]+xcur);

   *(edtext[b]+xcur+1)=' ';
   xcur=0; out_s(edtext[b]);
   xcur=x;
}


backspace()
{
   int a,b,c,x;

   if(xcur<1)
      return;

   x=xcur;
   b=oberste+ycur;
   a=strlen(edtext[b]);
   xcur--;
   for(;xcur<a;xcur++)
   {
      *(edtext[b]+xcur)= *(edtext[b]+xcur+1);
      out_c(*(edtext[b]+xcur));
      xcur--;
   }
   out_c(' ');
   xcur=x-1;
}

delete()
{
   int a,b,c,x;

   x=xcur;
   b=oberste+ycur;
   a=strlen(edtext[b]);
   for(;xcur<a;xcur++)
   {
      *(edtext[b]+xcur)= *(edtext[b]+xcur+1);
      out_c(*(edtext[b]+xcur));
      xcur--;
   }
   out_c(' ');
   xcur=x;
}

insert_line()
{
   int a,y=ycur;

   if(linecount>=max_lines-1)
   {
      show_mouse();
      a=brain_alert(1,"[1][Letzte Zeile wrde verloren gehen !][Macht was|Macht nichts]");
      hide_mouse();
      if(a==1)
         return;
      else
         linecount--;
   }
   for(a=linecount;a>=oberste+ycur;a--)
      bwstrcpy(edtext[a+1],edtext[a]);

   linecount++;
   *(edtext[oberste+ycur])=0;

   xcur=0;
   clr_line(ycur);

   for(a=ycur+1;a<=max_ycur&&a+oberste<=linecount;a++)
   {
      xcur=0; ycur=a;
      clr_line(ycur);
      out_s(edtext[oberste+a]);
   }
   xcur=0;
   ycur=y;
}

delete_line()
{
   int a,x,y;

   x=xcur;
   y=ycur;

   if(linecount<1)
      return;

   for(a=ycur+oberste;a<linecount-1;a++)
   {
      asm
      {
         BRA   WOITER
         DC.B  "BWSTRCPY IN DEL_LINE"
WOITER:
      }
      bwstrcpy(edtext[a],edtext[a+1]);
   }

   *(edtext[a]+0)=0;
   *(edtext[a]+1)=0;
   linecount--;

   xcur=0;
   clr_line(ycur);
   out_s(edtext[oberste+y]);

   for(a=ycur+1;((a<=max_ycur)&&((a+oberste)<=linecount));a++)
   {
      xcur=0; ycur=a;
      clr_line(ycur);
      out_s(edtext[oberste+a]);
   }

   xcur=0;
   if(a<max_ycur)
   {
      for(;a<=max_ycur;a++)
         clr_line(a);
   }
   if(oberste+y<=linecount)
   {
      ycur=y;
      return;
   }
   if(y>0&&oberste+y>linecount)
   {
      ycur=y-1;
      return;
   }
   if(y==0&&oberste+y>linecount&&oberste>0)
   {
      ycur=y;
      oberste--;
      xcur=0;
      out_s(edtext[oberste]);
      xcur=0;
   }
}

top_of_text()
{
   int a;

   clr_window(top_window);
   for(a=0;a<=max_ycur&&a<=linecount;a++)
   {
      xcur=0; ycur=a;
      out_s(edtext[a]);
   }
   xcur=0;ycur=0;
   oberste=0;
}

end_of_text()
{
   int a;

   clr_window(top_window);
   oberste=(linecount-max_ycur>=0) ? linecount-max_ycur : 0;
   for(a=0;a+oberste<=linecount&&a<max_ycur;a++)
   {
      xcur=0; ycur=a;
      out_s(edtext[a+oberste]);
   }
   xcur=0; ycur=linecount-oberste;
}

show_help()
{
   int a;

   save_screen();
   a=hndl_dial(help__di,0,315,195,10,10);
   undo_objc(help__di,a,SELECTED);
   do_redraw();
}

up()
{
   int x=xcur;

   if(ycur>0)
      ycur--;
   else
   {
      if(oberste>0)
      {
         oberste--;
         xcur=0;
         hide_mouse();
         win_down();
         show_mouse();
         out_s(edtext[oberste+ycur]);
      }
   }
   xcur=(strlen(edtext[oberste+ycur])>x) ? x : strlen(edtext[oberste+ycur]);
   xcur=(xcur<max_xcur) ? xcur : max_xcur;
}

down()
{
   int x=xcur;

   if(ycur<max_ycur&&oberste+ycur<linecount)
      ycur++;
   else
   {
      if(oberste+ycur<linecount)
      {
         oberste++;
         out_c(10);
         xcur=0;
         out_s(edtext[oberste+ycur]);
      }
   }
   xcur=(strlen(edtext[oberste+ycur])>x) ? x : strlen(edtext[oberste+ycur]);
   xcur=(xcur<max_xcur) ? xcur : max_xcur;
}

left()
{
   if(xcur>0)
      xcur--;
}

right()
{
   if(xcur<max_xcur&&*(edtext[oberste+ycur]+xcur))
      xcur++;
}

fil_len(name)
char *name;
{
   int a;
   long len;

   a=Fopen(name,0);
   if(a<6)
      return(-1l);

   len=Fseek(0l,a,2);
   Fclose(a);
   return(len);
}

glumb()
{
   asm
   {
bwstrcpy:
      MOVE.L   4(A7), A0
      MOVE.L   8(A7), A1
BWL1:
      TST.B    (A1)
      BEQ.S    NULL
      MOVE.B   (A1)+, (A0)+
      BNE.S    BWL1
      RTS
NULL:
      MOVE.B   #0, (A0)+
      MOVE.B   #0, (A0)+
      RTS
   }
}


clr_line(which)
int which;
{
   int x=xcur;
   int y=ycur;

   xcur=0;ycur=which;

      asm
      {
         JSR      calc_xy_adr
         MOVEA.L  D0,A0 

         MOVEA.L  A0, A2

L1:      MOVE.W   s_up_w(A4), D1     ; BREITE IST INNERE SCHLEIFE
#ifdef COLOR

         SUBQ.W   #1, D1
L2:
         CLR.L    160(A0)
         CLR.L    320(A0)
         CLR.L    480(A0)
         CLR.L    640(A0)
         CLR.L    800(A0)
         CLR.L    960(A0)
         TST.W    onli_vt52(A4)
         BNE      VTCL
         CLR.L    1120(A0)
VTCL:
         CLR.L    (A0)+
         DBF      D1, L2

#else
         ASR.W    #1, D1
         SUBQ.W   #1, D1
         CLR.L    D3
L2:
         TST.W    onli_vt52(A4)
         BNE      VTCL
         CLR.L    0(A0)
VTCL:
         CLR.L    80(A0)
         CLR.L    160(A0)
         CLR.L    240(A0)
         CLR.L    320(A0)
         CLR.L    400(A0)
         CLR.L    480(A0)
         CLR.L    560(A0)
         CLR.L    640(A0)
         CLR.L    720(A0)
         CLR.L    800(A0)
         CLR.L    880(A0)
         CLR.L    960(A0)
         CLR.L    1040(A0)
         CLR.L    1120(A0)
         CLR.L    1200(A0)
         ADDQ.L   #4, D3
         ADDQ.L   #4, A0
         DBF      D1, L2
         ASR.W    #1,D3
         CMP.W    s_up_w(A4), D3
         BGE      LEFTSO
         TST.W    onli_vt52(A4)
         BNE      VTCL2
         CLR.W    0(A0)
VTCL2:
         CLR.W    80(A0)
         CLR.W    160(A0)
         CLR.W    240(A0)
         CLR.W    320(A0)
         CLR.W    400(A0)
         CLR.W    480(A0)
         CLR.W    560(A0)
         CLR.W    640(A0)
         CLR.W    720(A0)
         CLR.W    800(A0)
         CLR.W    880(A0)
         CLR.W    960(A0)
         CLR.W    1040(A0)
         CLR.W    1120(A0)
         CLR.W    1200(A0)
LEFTSO:

#endif     
      }
   xcur=x;
   ycur=y;
}
