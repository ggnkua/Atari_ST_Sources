/***************************************************************************/
/*                                                                         */
/*  REVERSI Desk Accessory.  Written by Christophe Bonnet.  5/08/86        */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing.    */
/*                                                                         */
/*  Small portion of the code derived from ACCSKEL.C (Developer's Toolkit) */
/*                                                                         */
/***************************************************************************/

#include "gemdefs.h"                        /** Gem Aes & Vdi link files  **/

#define HIDE_MOUSE  graf_mouse(M_OFF,0x0L); /**** constants declaration ****/
#define SHOW_MOUSE  graf_mouse(M_ON,0x0L);
#define WI_KIND     (MOVER|NAME|CLOSER|INFO)
#define NO_WINDOW   (-1)
#define TRUE 1              /**********************************************/
#define FALSE 0             /*                WARNING !                   */
#define WHITE 0             /*                                            */
#define BLACK 1             /* If you have the Hippo C Compiler, you MUST */
#define RED 2               /* add appropriate link files for the two     */
#define MEDIUM 1            /* XBios functions GETREZ and RANDOM...       */
#define LOW    0            /* Please look at Antic (march'86) for the    */
#define HIGH   2            /* procedures to use.                         */
                            /**********************************************/

#define Getrez()  (int)xbios(4)  /* define these two links here so you */
#define Random()  xbios(17)      /*   don't have to include OSBIND.H   */

extern long xbios();                        /**** External Communications **/
extern int  gl_apid;

/* Global variables : For use in Gem aes and vdi calls *********************/
/* Note: A great part of these variables are the same as in ACCSKEL.C      */

int menu_id,phys_handle,handle,wi_handle,top_window;
int xdesk,ydesk,hdesk,wdesk,hchar,wchar,hbox,wbox,xold,yold,hold,wold;
int xwork,ywork,hwork,wwork,hidden,fulled,handed,screen_rez;
int msgbuff[8],keycode,mx,my,butdown,pstatus,ret,ret1,ret2,ret3,ret4;
int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int work_in[11],work_out[57],pxyarray[10];

typedef struct grect       /*  this structure for clipping and rectangle   */
{                          /*  drawings. Must be defined here because we   */
          int  g_x;        /*  don't include OBDEFS.H library file to save */
          int  g_y;        /*  memory and compilation time ...             */
          int  g_w;
          int  g_h;
} GRECT;

/* These for use in the main part of the program: game variables ***********/

int b_grid[10][10],c_grid[10][10];
int b_init[10][10]={  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
                      0, 16, -4,  5,  1,  1,  5, -4, 16,  0,
                      0, -4,-12, -2, -2, -2, -2,-12, -4,  0,
                      0,  5, -2,  4,  2,  2,  4, -2,  5,  0,
                      0,  1, -2,  2,  1,  1,  2, -2,  1,  0,
                      0,  1, -2,  2,  1,  1,  2, -2,  1,  0,
                      0,  5, -2,  4,  2,  2,  4, -2,  5,  0,
                      0, -4,-12, -2, -2, -2, -2,-12, -4,  0,
                      0, 16, -4,  5,  1,  1,  5, -4, 16,  0,
                      0,  0,  0,  0,  0,  0,  0,  0,  0,  0  };

int score[4],phase,adv,pass,v,w,valide,value,end=FALSE,x_offset,y_offset; 
int c_wstart,c_hstart,c_width,c_heigth,w_width,w_heigth,x_rad,y_rad;
int x_border,y_border,dial_a,dial_b,score_a,score_b,size,tab;

/*  open a virtual screen workstation ***** from ACCSKEL.C *****************/

open_vwork()
{
int i;
      for(i=0;i<10;work_in[i++]=1);
      work_in[10]=2;                        /* Raster Coordinates */
      handle=phys_handle;
      v_opnvwk(work_in,&handle,work_out);
}

/*  open a Gem window ******************************************************/

open_window()
{
      wi_handle=wind_create(WI_KIND,xdesk,ydesk,wdesk,hdesk);
      wind_set(wi_handle,WF_NAME," REVERSI ",0,0);
      wind_set(wi_handle,WF_INFO,"            \0",0,0);
      wind_open(wi_handle,xdesk+wdesk/2 -(w_width/2),ydesk+hdesk/2 -(w_heigth/2),w_width,w_heigth);
      wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
}

/*  entry point of this program  **********************************************/

main()
{
      appl_init();
      phys_handle=graf_handle(&ret1,&ret2,&ret3,&ret4);
      menu_id=menu_register(gl_apid,"  Reversi  ");
      wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
      wi_handle=NO_WINDOW;
      top_window=butdown=TRUE;
      hidden=handed=fulled=FALSE;
      screen();                           /* draw the game board      */
      init();                             /* initialize the variables */
      multi();
}

/*  accessory tasks dispatched by the MULTI function ***********************/

multi()
{
int  event; 
      while (TRUE)  {
       event=evnt_multi(MU_MESAG |MU_BUTTON |MU_KEYBD |MU_M1 |MU_M2 ,
                        1,1,1,
                        0,xwork,ywork,wwork,hwork,
                        1,xwork,ywork,wwork,hwork,
                        msgbuff,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

       wind_update(TRUE);
       wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);
            
       if (event & MU_MESAG)  switch (msgbuff[0])  {
            
          case  WM_NEWTOP:
          case  WM_TOPPED:
              if(msgbuff[3] == wi_handle) wind_set(wi_handle,WF_TOP,0,0,0,0);
          break;

          case  AC_CLOSE:
              if((msgbuff[3] == menu_id)&&(wi_handle != NO_WINDOW)){
                                v_clsvwk(handle);
                                wi_handle=NO_WINDOW;                }
              break;

          case  WM_CLOSED:
              if(msgbuff[3] == wi_handle){
                                wind_close(wi_handle);
                                graf_shrinkbox(xwork+wwork/2,ywork+hwork/2,0,0,xwork,ywork,wwork,hwork);
                                wind_delete(wi_handle);
                                v_clsvwk(handle);
                                wi_handle=NO_WINDOW;
                                          }
          break;

          case  AC_OPEN:
              if(msgbuff[4] == menu_id){
                 if(wi_handle == NO_WINDOW){
                              open_vwork();
                              open_window();
                              event=0;
                                           }
                 else wind_set(wi_handle,WF_TOP,0,0,0,0);
                                        }
         break;

         case  WM_REDRAW:
             if(msgbuff[3] == wi_handle)
               do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
         break;

         case  WM_SIZED:
         case  WM_MOVED:
             if(msgbuff[3] == wi_handle){
               wind_set(wi_handle,WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
               wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
                                        }
         break;


         }  /* switch msgbuff[0] */

         if((event & MU_BUTTON) && (top_window == wi_handle) && (handed))
                          {
                          pass=0;
                          turn();
                          }  

         if((event & MU_M1) && (top_window == wi_handle))
                          {
                           if(!handed) {graf_mouse(POINT_HAND,0x0L);
                                       handed=TRUE;}
                           }

         if(event & MU_M2)
                          {
                           if(handed) {graf_mouse(ARROW,0x0L);
                                        handed=FALSE;}
                          }
         if((event & MU_KEYBD) && (top_window == wi_handle))
                          {
                          pass=1;        /* if the player press a key    */
                          turn();        /* then go to ATARI game turn   */
                          }

    wind_update(FALSE);

      }        /* while TRUE        */
}              /* multi()           */

/*  drawing of game board and counters ************************************/

board()
{
register int i,j,temp[4];

      vswr_mode(handle,1);
      rectangle(xwork,ywork,wwork,hwork,BLACK);
      HIDE_MOUSE;
      if(screen_rez == HIGH) vsf_style(handle,4);
       else vsf_color(handle,RED);           /* change this color to your */
          temp[0]=x_border+xwork;            /* preference, if you wish.. */
          temp[1]=y_border+ywork;
          temp[2]=xwork+x_border+(c_width * 8);
          temp[3]=ywork+y_border+(c_heigth * 8);
      v_bar(handle,temp);

      vsf_color(handle,BLACK);
      for(i=1;i<10;i++)        {
          temp[0]=xwork+(i * c_width) - c_wstart;
          temp[1]=ywork+y_border;
          temp[2]=xwork+(i * c_width) - c_wstart;
          temp[3]=ywork+y_border+(c_heigth * 8);
        v_pline(handle,2,temp);
          temp[0]=xwork+x_border;
          temp[1]=ywork+(i * c_heigth) - c_hstart;
          temp[2]=xwork+x_border+(c_width * 8);
          temp[3]=ywork+(i * c_heigth) - c_hstart;
        v_pline(handle,2,temp);
                                }

      for(i=1;i<9;i++)         {
       for(j=1;j<9;j++)         {
        if(c_grid[i][j] > 1)     {
          vsf_interior(handle,2);
          vsf_style(handle,8);
          vsf_color(handle,1);
          if(c_grid[i][j] == 3)                vsf_color(handle,0);
          v_ellipse(handle,xwork+(i * c_width)-x_border+x_offset,ywork+(j * c_heigth)-y_border+y_offset,x_rad,y_rad);
                                 }   /* if(c_grid) */
                                }   /* for(j=...) */
                               }   /* for(i=...) */

      vsf_color(handle,WHITE);
      v_ellipse(handle,xwork+wwork-x_rad-3,ywork+dial_a,x_rad+3,y_rad+3);
      v_ellipse(handle,xwork+wwork-x_rad-3,ywork+dial_b,x_rad+3,y_rad+3);

      vsf_color(handle,BLACK);
      v_ellipse(handle,xwork+wwork-x_rad-3,ywork+dial_a,x_rad,y_rad);

      display();

      wind_set(wi_handle,WF_INFO,"Your move...\0",0,0);
      SHOW_MOUSE;
}
                              
/*  clipping rectangles coordinates ******* from ACCSKEL.C *****************/

set_clip(x,y,w,h)
int x,y,w,h;
{
int clip[4];
     clip[0]=x;     clip[1]=y;     clip[2]=x+w;     clip[3]=y+h;
     vs_clip(handle,1,clip);
}

/* find and redraw all clipping rectangles ***** from ACCSKEL.C ************/

do_redraw(xc,yc,wc,hc)
int xc,yc,hc,wc;
{
GRECT  t1,t2;
     HIDE_MOUSE;
     wind_update(TRUE);
     t2.g_x=xc;     t2.g_y=yc;     t2.g_w=wc;     t2.g_h=hc;
     wind_get(wi_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
     while(t1.g_w && t1.g_h){
          if (rc_intersect(&t2,&t1)){
                                     set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
                                     board();
                                    }

     wind_get(wi_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
                            }
     wind_update(FALSE);
     SHOW_MOUSE;
}

/* game turn of the human player (you!) ************************************/

player()
{                      /* transform mouse coordinates in grid coordinates */
int i,j,vj,wj,temp[4];
                           v=(mx+c_wstart-xwork)/c_width;
                           w=(my+c_hstart-ywork)/c_heigth;
                           if(v>0 && v<9 && w>0 && w<9)   sub_1();
}

/* game turn of the computer ***********************************************/
atari()
{
int verify(),i,j,point = (-99),flip;

          value = (-99);
          for(i=1;i<9;i++)
  {       for(j=1;j<9;j++)
    {   if(c_grid[i][j] == 1)
      { flip=verify(i,j);
        if(flip > 0)
        {       if(score[2]+score[3] < 34) flip = (-flip);
                if(score[2]+score[3] > 56) flip = flip * 6;
                value=(b_grid[i][j] * 3) + flip;

                if(value > point)  {
                                     point=value; 
                                     v=i;
                                     w=j;
                                    }
                if((value == point) && ((Random() & 10) < 5)) {
                                                                point=value; 
                                                                v=i;
                                                                w=j;
                                                               }

        }   /* if flip     */
      }     /* if c_grid   */
    }       /* for j       */
  }         /* for i       */
        if(point == (-99)) pass++;  else  change(v,w);
}

/* display the score of both players ***************************************/
display()
{     
int units,tens;  
char string[10];

       HIDE_MOUSE;
       vst_color(handle,BLACK);
       vst_height(handle,size,&wchar,&hchar,&wbox,&hbox);
       rectangle(xwork+wwork-tab,ywork+score_a-hchar,wbox * 2,hbox,BLACK);
       rectangle(xwork+wwork-tab,ywork+score_b-hchar,wbox * 2,hbox,BLACK);
       vswr_mode(handle,3);
           tens=score[2]/10;                   /* convert an integer in */
           units=( score[2]-( tens * 10));     /* a string of char...   */
           string[0]=tens + 48;
           string[1]=units + 48;
           string[2]='\0';
       v_gtext(handle,xwork+wwork-tab,ywork+score_a,string);
           tens=score[3]/10;
           units=( score[3]-( tens * 10));
           string[0]=tens + 48;
           string[1]=units + 48;
       v_gtext(handle,xwork+wwork-tab,ywork+score_b,string);
       vswr_mode(handle,1);
       SHOW_MOUSE;
}

/* game turn : PLAYER ---> ATARI, and return to MULTI function *************/
turn()
{
   if(end == TRUE) { end=FALSE;
                     pass=0;
                     init();
                     set_clip(xwork,ywork,wwork,hwork);
                     board();
                   }
   else            { valide=FALSE;
                     phase=2;
                     adv=3;
                     if(pass == 0) player();
                     else valide=TRUE;
                     display();

                     if(valide == TRUE)
                        {
                         wait();
                         if(score[2]+score[3] == 64) end=TRUE;
                         phase=3;
                         adv=2;
                         atari();
                         display();
                         if(pass == 2 || score[2] + score[3] == 64) end=TRUE;
                        }

   HIDE_MOUSE;
   wind_update(TRUE);

   if(end == FALSE) wind_set(wi_handle,WF_INFO,"Your move...\0",0,0);
     else    stop();       
   wind_update(FALSE);
   SHOW_MOUSE;
                       } /* else */
}

/* sub-routine 1 of player loop ********************************************/

sub_1()
{
       if(c_grid[v][w] == 1) sub_2();
}

/* sub-routine 2 of player loop ********************************************/

sub_2()
{
int verify(),flip;

    flip=verify(v,w); 
    if(flip > 0) {
                  change(v,w);
                  valide = TRUE;
                 }
}

/* verify if the phasing player could return at least 1 opposing counter ***/

int verify(a,b)
int a,b;
{
int flop,i,j,dx,dy,flap,flag;
                flop=0;
                for(i = (-1);i<2;i++)
   {            for(j = (-1);j<2;j++)
     {           if(i != 0 || j != 0)
       {           flap=0;
                   flag=0;
                   dx=a+i;
                   dy=b+j;
           while((c_grid[dx][dy] > 1) && (flag == 0))
         {        if(c_grid[dx][dy] == phase)
             {
                      flag=1;
                      flop+=flap;
             }
                   flap++;
                   dx+=i;
                   dy+=j;
         } /* while */
       }   /* if () */
     }     /* for j */
   }       /* for i */
          return(flop);
}

/* return counters on screen and as variables ******************************/

change(a,b)
int a,b;
{
int i,j,dx,dy,flag1,flag2,flop;

     wind_update(TRUE);
     set_clip(xwork,ywork,wwork,hwork);
     vswr_mode(handle,1);
     vsf_interior(handle,2);
     vsf_style(handle,8);
     vsf_color(handle,1);
     if(phase == 3)          vsf_color(handle,0);
     HIDE_MOUSE;
     v_ellipse(handle,xwork+(a * c_width)-x_border+x_offset,ywork+(b * c_heigth)-y_border+y_offset,x_rad,y_rad);
     c_grid[a][b]=phase;
     score[phase]++;
     modify(a,b);
     for(i = (-1);i<2;i++)
        {             for(j = (-1);j<2;j++)
           {           if((i != 0) || (j != 0))
              {         
                dx=a;
                dy=b;
                flag1=0;
                flop=0;
                do {    dx+=i;
                        dy+=j;
                        if(c_grid[dx][dy] < 2) flag1=1;
                        if(c_grid[dx][dy] == adv) flop+=1;
                        if(c_grid[dx][dy] == phase) 
                          {flag1=1;
                           if(flop >0)
                             {flag2=0;
                              do {     dx-=i;
                                       dy-=j;
                                       if((dx == a) && (dy == b)) flag2=1;
                                       else
            {  c_grid[dx][dy]=phase;
               v_ellipse(handle,xwork+(dx * c_width)-x_border+x_offset,ywork+(dy * c_heigth)-y_border+y_offset,x_rad,y_rad);
               score[phase]++;
               score[adv]--;
            } /* else */
                                 } while(flag2 == 0);
                           }          /* if flop  */
                         }            /* if phase */
            } while(flag1 == 0);
         }                  /* if   */
      }                     /* for j */
    }                       /* for i */
    SHOW_MOUSE;
    wind_update(FALSE);
}                          /* change() */

/* modify values of some cases following a move ****************************/

modify(a,b)
int a,b;
{
int i,j;
         if(b_grid[a][b] == 16)
           {
            for(i=a + (-2);i<a+3;i++)
           {if(i > 0 && i < 9)  {
            for(j=b + (-2);j<b+3;j++)
           {if(j > 0 && j < 9)  {
                                   if(b_grid[i][j] < (-3)) b_grid[i][j]=0;
                                }
           }
                                }
           }
           }
         else if(b_grid[a][b] == 5)
           {
            for(i=a + (-1);i<a+2;i++)
           {
            for(j=b + (-1);j<b+2;j++)
           {
                if(b_grid[i][j] == 1)    b_grid[i][j]=3;
                if(b_grid[i][j] == (-2)) b_grid[i][j]=1;
           }
           }
           }
}

/* end of the game *********************************************************/

stop()
{
char *buffer;

     if(score[2] == score[3]) buffer="Null game !!\0";
else if(score[2] >  score[3]) buffer="You WIN   !!\0";
else                          buffer="You LOSE  !!\0";

     wind_set(wi_handle,WF_INFO,buffer,0,0);
}

/* variables initialisation ************************************************/

init()
{
int i,j;
          for(i=0;i<10;i++)
              for(j=0;j<10;j++)        b_grid[i][j]=b_init[i][j];

          for(i=0;i<10;i++)
         {for(j=0;j<10;j++)
         {if((i == 0) || (j == 0) || (i == 9) || (j == 9)) c_grid[i][j]=0;
          else        c_grid[i][j]=1;
         }
         }

     c_grid[4][4]=c_grid[5][5]=2;     c_grid[4][5]=c_grid[5][4]=3;
     score[2]=2;                      score[3]=2;
}

/* draw a filled rectangle of specified size and color *********************/

rectangle(x,y,w,h,color)
int x,y,w,h,color;
{
int temp[4];

     HIDE_MOUSE;
     vsf_interior(handle,2);
     vsf_style(handle,8);
     vsf_color(handle,color);
     temp[0]=x;     temp[1]=y;     temp[2]=x+w-1;      temp[3]=y+h-1;
     v_bar(handle,temp);
     SHOW_MOUSE;
}

/* delay loop during computer's turn ***************************************/

wait()
{
int i,j;
        wind_set(wi_handle,WF_INFO,"......      \0",0,0);
        for(i=0;i<6;i++)    for(j=0;j<32000;j++);
}

/* allocate values to drawing variables ,dependent of screen resolution ****/

screen()
{
          x_border=y_border=6;                 /*   variables used for  */
          x_rad=y_rad=9;                       /* drawing of game board */
          x_offset=y_offset=2;
          c_wstart=c_hstart=14;    c_width=c_heigth=20;
          w_width=200;             w_heigth=210;
          dial_a=40;               dial_b=100;
          score_a=60;              score_b=120;
          tab=20;                  size=6;
          screen_rez = Getrez();               /* get screen resolution */

     switch(screen_rez)  {
                         case  LOW:
     x_border=3;    x_rad=4;       x_offset=1;    c_wstart=7;
     c_width=10;    w_width=100;   tab=12;        size=4;
                         case  MEDIUM:
     y_border=3;    y_rad=4;       y_offset=1;    c_hstart=7;
     c_heigth=10;   w_heigth=110;  score_a=37;    score_b=67;
     dial_a=20;     dial_b=50;
                         }                     /* OK, it's the end, guy !!*/
}

                                  /* Christophe BONNET 1986 */

