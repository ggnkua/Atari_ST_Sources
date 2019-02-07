/* Mountain.  Written by Michael C. Gilbert
** Copyright 1990 by Antic Publishing, Inc.
*/
#include<gemdefs.h>
#include<stdio.h>
#include<osbind.h>
#include <obdefs.h>
#include "mountain.h"
OBJECT *dialog,*dialog2;
#define TRUE 1
#define FALSE 0

#define MyApp	0  /*  my application  		   */
#define Control	7  /*  divide by 200 prescale  */
#define Data	0  /*  Countdown from		   */
				   /* 1 byte, 1, 2, ... 254, 255, 0 = 256 */
#define Off		0

extern  dispatcher();	/* labels in in-line assembly must be declared. */
extern  set_timer();
extern  unset_timer();


long ticks; 	/* local tick counter.					*/
long oldvector;			/* storage for old terminate vector.	*/


MFDB DECK1,DECK2,DEST,PAD;
FILE *f1,*fopen();
int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int work_in[12],work_out[57],pxarray[10];
int regno,bitno,gr_mkmy,gr_mkkstate,gr_mkmx,gr_mkmstate;
int *screen,*holder;
int *ptr;

char fname[] ="DECK1.PI2";
char fname1[]="DECK2.PI2";
char fname2[]="RULES.PI2";
char fname12[]="HIGH.DAT";
char errstr[128];
char ptect3[20];
char pval3[20];
char champ_name[20];
int namelength;
extern int	gl_apid;
int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;	/* system sizes */

int  phys_handle;	/* physical workstation handle */
char *screen1,*holder1,*screen2,*holder2,*screen3,*holder3;
char *screen4,*holder4;
int screen_ptr;
int handle;
int color[16];
int hidden;
int pxy[8];
int pxy1[8];
int cards[53];
int cards_used[53];
int msgbuff[8];
int deck_flag,show,timer_flag,score,high_score;
int undo_score,undo_high_score;
int *pict2;
int mountain;
int card_value[53];
int card_suit[53];
int level1[8];
int level2[8];
int level3[8];
int level4[8];
int level5[8];
int level6[8];
int level7[8];
int undo_level1[8];
int undo_level2[8];
int undo_level3[8];
int undo_level4[8];
int undo_level5[8];
int undo_level6[8];
int undo_level7[8];
int maxticks,timer_selected;
int card_count,used_cards,help_flag,replay_flag,error2;
int undo_card_count,undo_used_cards;
char sound1[] = { 
	0, 151, 1, 1, 2, 48, 3, 0, 6, 2, 7, 252, 8, 16, 9, 16, 
	10, 16, 11, 204, 12, 6, 13, 0, 255, 0 };
char sound2[] = { 
	0, 175, 1, 2, 2, 143, 3, 6, 6, 2, 7, 252, 8, 16, 9, 16, 
	10, 16, 11, 204, 12, 6, 13, 0, 255, 0 };
char sound3[] = { 
	0, 239, 1, 0, 2, 222, 3, 1, 4, 140, 5, 5, 7, 248, 8, 16, 
	9, 16, 10, 16, 11, 208, 12, 164, 13, 0, 255, 0 };

ticker()
{
	ticks++;
}

main()
{

 int i,data,x;
 appl_init();
 phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
 for(i=0;i<10;work_in[i++] = 1);
 work_in[10] = 2;
 v_opnvwk(work_in, &handle, work_out);
 for(x=0;x!=4;x++)
 {
  for(i=0;i!=13;i++)
  {
   card_value[i+(x*13)]=i+2;
   card_suit[i+(x*13)]=x+1;
  }
 }

 i=Getrez();
 if(i!=1)
 {
  form_alert(1, "[0][Sorry medium rez only|Terminating ...][OK]");
  exit(1);
 }

/******************************************************************/	
	screen1=malloc(32000+256);		/* allocating space for buffer*/				
	if((long) screen1 &0xff)
		screen1=screen1+0x100-((long) screen1 & 0xff);
	holder1=screen1;
/******************************************************************/
/******************************************************************/	
	screen2=malloc(32000+256);		/* allocating space for buffer*/				
	if((long) screen2 &0xff)
		screen2=screen2+0x100-((long) screen2 & 0xff);
	holder2=screen2;
/******************************************************************/
/******************************************************************/	
	screen3=malloc(32000+256);		/* allocating space for buffer*/				
	if((long) screen3 &0xff)
		screen3=screen3+0x100-((long) screen3 & 0xff);
	holder3=screen3;
/******************************************************************/
/******************************************************************/	
	screen4=malloc(32000+256);		/* allocating space for buffer*/				
	if((long) screen4 &0xff)
		screen4=screen4+0x100-((long) screen4 & 0xff);
	holder4=screen4;
/******************************************************************/

 init_mfdb(&DECK1,&DECK2,&DEST,&PAD);
 screen =(int *)(Logbase);
 if (!rsrc_load("mountain.rsc"))
 {
  form_alert(1, "[0][Cannot find MOUNTAIN.RSC|Terminating ...][OK]");
 }
 data = -1;
 hide_mouse();
 Setscreen(screen,screen,data);

 graf_mouse(3,0x0L);

 if((f1=fopen(fname,"br")) == NULL)
 {
  strcat(errstr, "[0][Can't open ");
  strcat(errstr, fname);
  strcat(errstr, "|Terminating ...][OK]");
  form_alert(1, errstr);
  exit(1);
 }

 data=getw(f1);
 for(x=0;x!=16;x++)
 {
  data=getw(f1);
  color[x]=Setcolor(x,data);
 }

 for(x=0;x!=32000;x++)
 {
  data = getc(f1);
  *screen1 = data;
  ++screen1;
 }

 if((f1=fopen(fname1,"br")) == NULL)
 {
  strcat(errstr, "[0][Can't open ");
  strcat(errstr, fname1);
  strcat(errstr, "|Terminating ...][OK]");
  form_alert(1, errstr);
  exit(1);
 }

 data=getw(f1);
 for(x=0;x!=16;x++)
 {
  data=getw(f1);
 }

 for(x=0;x!=32000;x++)
 {
  data = getc(f1);
  *screen2 = data;
  ++screen2;
 }

 fclose(f1);
 show=1;
 rsrc_gaddr(0,ROOT,&dialog);
 for(x=1;x!=8;x++)
 {
  level1[x]=99;
  if(x<7)
   level2[x]=99;
  if(x<6)
   level3[x]=99;
  if(x<5)
   level4[x]=99;
  if(x<4)
   level5[x]=99;
  if(x<3)
   level6[x]=99;
  if(x<2)
   level7[x]=99;
 }

 if((f1=fopen(fname12,"r")) == NULL)
 {
  high_score=0;
 }else
 {
  high_score=getw(f1);
  namelength=getw(f1);
  for(x=0;x!=namelength+1;x++)
  {
    champ_name[x]=getc(f1);
  }
  fclose(f1);
 }
 
 hide_mouse();
 screen1=holder1;
 timer_flag=0;
 ticks=0L;
 help_flag=0;
 maxticks=140;
 timer_selected=0;
 score=0;
 mountain=0;
 reset();
 title();
 hide_mouse();
 put_icons();
 menu_bar(dialog,show);
 menu_ienable(dialog,SLOW,0);
 menu_ienable(dialog,MED,0);
 menu_ienable(dialog,FAST,0);
 put_high(high_score);
 vs_curaddress(handle,1,40);
 printf("High score by:\n");
 vs_curaddress(handle,1,55);
 printf("%s\n",champ_name);
 shuffle_deck();
 place_card();
 if(timer_selected !=1)
  copy_undo();
 show_mouse();
 
 deal();
 hide_mouse();
 reset();
 restore_colors();
 show_mouse();
 v_clsvwk(handle);
 appl_exit();

} /*  END OF MAIN  */

reset()
{
 screen1=holder1;
asm{
	move.l screen,A0
	move.l screen1,A1
    move.l #0,(A1)
	move.l #0,D0
loop1:move.l (A1),(A0)+
		add.l #1,D0
		cmp.l #8000,D0
		bne loop1
	}
}

hide_mouse()
{
 if(! hidden)
 {
  graf_mouse(M_OFF,0x0L);
  hidden=TRUE;
 }
}

show_mouse()
{
 if(hidden)
 {
  graf_mouse(M_ON,0x0L);
  hidden=FALSE;
 }
}

init_mfdb(src1,src2,destin,src3)
MFDB *src1,*src2,*destin,*src3;
{

 src1 ->fd_addr =(long)screen1;
 src1 ->fd_w = 640;
 src1 ->fd_h = 200;
 src1 ->fd_wdwidth = 40;
 src1 ->fd_stand = 0;
 src1 ->fd_nplanes = 2;

 src2 ->fd_addr =(long)screen2;
 src2 ->fd_w = 640;
 src2 ->fd_h = 200;
 src2 ->fd_wdwidth = 40;
 src2 ->fd_stand = 0;
 src2 ->fd_nplanes = 2;

 destin ->fd_addr = Logbase();
 destin ->fd_w = 640;
 destin ->fd_h = 200;
 destin ->fd_wdwidth = 40;
 destin ->fd_stand = 0;
 destin ->fd_nplanes = 2;

 src3 ->fd_addr =(long)screen3;
 src3 ->fd_w = 640;
 src3 ->fd_h = 200;
 src3 ->fd_wdwidth = 40;
 src3 ->fd_stand = 0;
 src3 ->fd_nplanes = 2;
}

restore_colors()
{
 int x;
 for(x=0;x!=16;x++)
 {
  Setcolor(x,color[x]);
 }
}
place_card()
{
 int x_offset,y_offset,i,j,l,k,gap;

 x_offset = 2;
 y_offset = 1;
 gap = 15;

 l=1;
 k=2;

 pxy[0] = x_offset + (k*63);
 pxy[1] = y_offset + (l*45);
 pxy[2] = pxy[0]+62;
 pxy[3] = pxy[1]+44;

 pxy[4] = (10*63)-63;
 pxy[5] = 12;
 pxy[6] = pxy[4]+62;
 pxy[7] = pxy[5]+44;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

 for(i=1;i!=8;i++)
 {
  j=cards[i]-1;
  level1[i]=j; 
  find_card(j);

  pxy[4] = ((i*63)-63)+((gap*i)+30);
  pxy[5] = 150;
  pxy[6] = pxy[4]+63;
  pxy[7] = pxy[5]+45;

  form_dial(FMD_GROW,567,12,62,44,pxy[4],pxy[5],62,44);
  Dosound(sound2);
  if(deck_flag ==1)
   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
  else 
   vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
   put_count(i);
 }
}

shuffle_deck()
{
 int x,card,y,i;
 int set_card;
 int used_card;

 vs_curaddress(handle,3,33);
 printf("SHUFFLING DECK\n");

 for(y=1;y!=53;y++)
  cards[y]=0;
 
 y=1;
 for(x=1;x!=53;x++)
 {
  set_card = 0;
  while(set_card == 0)
  {
   used_card = 0;
   card = rndom(52);
   for(i=1;i!=y;i++)
   {
    if(card == cards[i])
     used_card = 1;
   }
   if(used_card == 0)
   {
    cards[x] = card;
    set_card = 1;
    y++;
   }
  }
 }
 delay(60000);
 vs_curaddress(handle,3,33);
 printf("              \n");
 
}

rndom(size)
int size;
{
	int y,rnds;
	y=1;
	if(size >2){
loope:
	rnds=xbios(17);
	rnds=rnds & 0xff;
	rnds=rnds+1;
	if(rnds > size || rnds < 1)
		goto loope;
	y=rnds;
  }
 return(y);
}

deal()
{
 int x_play,y_play,x_width,y_width,play,event;
 int xloc,yloc,evbutt,evstate,ret,card;
 int display,x,good,key;

 x_play=10;
 y_play=20;
 x_width=620;
 y_width=180;
 play =1;
 card_count=8;
 used_cards=0;
 display=0;

 while(play)
 {
  event = evnt_multi(MU_MESAG | MU_M1 | MU_BUTTON | MU_KEYBD,
  1,3,1,
  0,x_play,y_play,x_width,y_width,
  0,0,0,0,0,
  msgbuff,10,0,&xloc,&yloc,&evbutt,&evstate,&key,&ret);


  if(event & MU_KEYBD)
  {
   event=0;
   if(key==24832 && timer_selected!=1)
   {
    retrieve_undo();
   }
  }

  if((event & MU_BUTTON) && evbutt==0)
   evbutt=1;

  if(mountain==1)
  {
   hide_mouse();
   reward();
   show_mouse();
  }
  if(ticks == maxticks || ticks > maxticks)
  {
   timer_flag=1;
   fflush(stdout);
   ticks = 0L;
  }
  if(event & MU_MESAG)
  {
   switch(msgbuff[4])
   {
    case DEMO:
             release();
             menu_tnormal(dialog,OPTIONS,1);
             do_demo();
             copy_undo();
             break;
    case MOUNTAIN:
             release();
             form_alert(1, "[1][ |       MOUNTAIN |          BY       |     MICHAEL GILBERT |(C) 1990 by Antic Publishing ][OK]");	
             menu_tnormal(dialog,DSK,1);
             graf_mouse(3,0x0L);
             copy_undo();
             break;
    case RSET:
             release();
             menu_tnormal(dialog,FLE,1);
             high_score=0;
             namelength=1;
             for(x=0;x!=20;x++)
             {
              champ_name[x]=' ';
             }
             hide_mouse();
             put_high(high_score);
             f1=fopen(fname12,"w+");
             putw(high_score,f1);
             putw(namelength,f1);
             for(x=0;x!=namelength+1;x++)
             {
              putc(champ_name[x],f1);
             }
             fclose(f1);

             vs_curaddress(handle,1,40);
             printf("High score by:\n");
             vs_curaddress(handle,1,55);
             printf("%s\n",champ_name);
             copy_undo();
             show_mouse();
             break;     
    case REPLAY:
             release();
             menu_tnormal(dialog,OPTIONS,1);
             replay_flag=1;
             goto restart;
             break;                         
    case TIMER:
             release();
             if(timer_selected ==0)
             {
               timer_selected=1;
               maxticks=140;
               menu_icheck(dialog,TIMER,1);
               menu_ienable(dialog,SLOW,1);
               menu_ienable(dialog,MED,1);
               menu_ienable(dialog,FAST,1);
               menu_icheck(dialog,MED,1);
               set_timer();
               set_terminate();
               ticks =0L;
               timer_flag=0;               
             }else
             {
               timer_selected=0;
               menu_icheck(dialog,TIMER,0);
               menu_ienable(dialog,SLOW,0);
               menu_ienable(dialog,MED,0);
               menu_ienable(dialog,FAST,0);
               menu_icheck(dialog,SLOW,0);
               menu_icheck(dialog,MED,0);
               menu_icheck(dialog,FAST,0);
               unset_terminate();
               unset_timer();		/* turn off timer */ 
             }
             menu_tnormal(dialog,OPTIONS,1);
             break;
    case SLOW:
             release();
             maxticks=200;
             menu_icheck(dialog,SLOW,1);
             menu_icheck(dialog,MED,0);
             menu_icheck(dialog,FAST,0);
             menu_tnormal(dialog,OPTIONS,1);
             ticks=0L;
             timer_flag=0;
             break;
    case MED:
             release();
             maxticks=140;
             menu_icheck(dialog,SLOW,0);
             menu_icheck(dialog,MED,1);
             menu_icheck(dialog,FAST,0);
             menu_tnormal(dialog,OPTIONS,1);
             ticks=0L;
             timer_flag=0;
             break;
    case FAST:
             release();
             maxticks=95;
             menu_icheck(dialog,SLOW,0);
             menu_icheck(dialog,MED,0);
             menu_icheck(dialog,FAST,1);
             menu_tnormal(dialog,OPTIONS,1);
             ticks=0L;
             timer_flag=0;
             break;                
	case QUIT:
              release();
              if(timer_selected==1)
              {
               unset_terminate();
               unset_timer();		/* turn off timer */
              }		
		      show=0;
              play=0;
              break;
    case NEW:
              release();
    restart:
              card_count=8;
              used_cards=0;
              for(x=1;x!=8;x++)
              {
               level1[x]=99;
               if(x<7)
                level2[x]=99;
               if(x<6)
                level3[x]=99;
               if(x<5)
                level4[x]=99;
               if(x<4)
                level5[x]=99;
               if(x<3)
                level6[x]=99;
               if(x<2)
                level7[x]=99;
              }
              hide_mouse();
              menu_tnormal(dialog,OPTIONS,1);
              fade(0);
              screen1=holder1;
              reset();
              put_icons();
              menu_ienable(dialog,DEMO,1);
              menu_bar(dialog,show);
              if(score > high_score)
              {
               high_score=score;
               do_dialog2();
               f1=fopen(fname12,"w+");
               putw(high_score,f1);
               putw(namelength,f1);
               for(x=0;x!=namelength+1;x++)
               {
                putc(champ_name[x],f1);
               }
               fclose(f1);
               put_high(high_score);
               high_score_pointer();
              }else
               put_high(high_score);
              if(replay_flag==0)
               shuffle_deck();
              replay_flag=0;
              place_card();
              show_mouse();
              ticks =0L;
              timer_flag=0;
              score=0;
              mountain=0;
              vs_curaddress(handle,1,40);
              printf("High score by:\n");
              vs_curaddress(handle,1,55);
              printf("%s\n",champ_name);
              copy_undo();
              break;              
   }
  }
  if(event & MU_M1 || timer_flag==1)
  {

   if(evbutt==3)
   {
    release();
    play=0;
   }

   if(evbutt==1 && xloc < 565)
   {
     release();
     if(timer_selected !=1)
      copy_undo(); 
     if(used_cards >0)
     {
      card = cards_used[used_cards];
      good=verify(card,xloc,yloc,0);
      if(good==0)
      {
       Dosound(sound1);
       delay(5000);
       Dosound(sound1);
      }
      if(good==1)
      {
       find_card(card);
       used_cards--;
      
       find_card_position(xloc,yloc,0);

       hide_mouse();

       form_dial(FMD_GROW,567,60,62,44,pxy[4],pxy[5],62,44);
       Dosound(sound2);
       if(deck_flag ==1)
        vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
       else 
        vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
       if(used_cards == 0)
       {
        pxy1[0] = 2 + (5*63);
        pxy1[1] = 3 + (2*45);
        pxy1[2] = pxy1[0]+62;
        pxy1[3] = pxy1[1]+44;

        pxy1[4] = (10*63)-63;
        pxy1[5] = 60;
        pxy1[6] = pxy1[4]+62;
        pxy1[7] = pxy1[5]+44;
        vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
       }else
       {
        card=cards_used[used_cards];
        find_card(card);
        pxy[4] = (10*63)-63;
        pxy[5] = 60;
        pxy[6] = pxy[4]+63;
        pxy[7] = pxy[5]+45;
        if(deck_flag ==1)
         vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
        else 
         vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
       }
       ticks=0L;
       show_mouse();
      }      
     }
   }
   if(evbutt==1 || timer_flag==1 || evbutt==2)
   {
    release();
    display=0;
    if((xloc>566 && xloc<630) && (used_cards >0) 
      && (timer_selected==0) || evbutt==2)
    {
     if(timer_selected !=1)
      copy_undo();
     if(yloc>59 && yloc<105 && evbutt !=2)
     {
      hide_mouse();
      pxy1[0] = 2;
      pxy1[1] = 60;
      pxy1[2] = pxy1[0]+638;
      pxy1[3] = pxy1[1]+48;

      pxy1[4] = 2;
      pxy1[5] = 60;
      pxy1[6] = pxy1[4]+638;
      pxy1[7] = pxy1[5]+48;
      vro_cpyfm(handle,3,pxy1,&DEST,&PAD);

      pxy1[0] = 2;
      pxy1[1] = 91;
      pxy1[2] = pxy1[0]+638;
      pxy1[3] = pxy1[1]+48;

      pxy1[4] = 2;
      pxy1[5] = 60;
      pxy1[6] = pxy1[4]+638;
      pxy1[7] = pxy1[5]+48;
      vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
      for(x=1;x!=used_cards+1;x++)
      {
       card=cards_used[x];
       find_card(card);

       pxy[4] = (x*11)-6;
       pxy[5] = 62;
       pxy[6] = pxy[4]+63;
       pxy[7] = pxy[5]+45;
       Dosound(sound2);
       if(deck_flag ==1)
        vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
       else 
        vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
       delay(500);
      }
      show_mouse();

      vs_curaddress(handle,2,1);
      printf(" \n");

      gemdos(0x1);
      show_mouse();
      hide_mouse();
      pxy1[0] = 2;
      pxy1[1] = 60;
      pxy1[2] = pxy1[0]+638;
      pxy1[3] = pxy1[1]+48;

      pxy1[4] = 2;
      pxy1[5] = 60;
      pxy1[6] = pxy1[4]+638;
      pxy1[7] = pxy1[5]+48;
      vro_cpyfm(handle,3,pxy1,&PAD,&DEST);
      show_mouse();
      display=1;           
     }
    }
    if(card_count < 53 && display==0 && (xloc>566 && xloc< 630 
    && yloc<59 && yloc>11 || timer_flag==1 || evbutt==2))
    {
     card=cards[card_count]-1;
     find_card(card);
     used_cards++;
     cards_used[used_cards]=card;
     pxy[4] = (10*63)-63;
     pxy[5] = 60;
     pxy[6] = pxy[4]+63;
     pxy[7] = pxy[5]+45;

     hide_mouse();

     form_dial(FMD_GROW,567,12,62,44,pxy[4],pxy[5],62,44);
     Dosound(sound2);
     if(card_count ==52)
     {
      pxy1[0] = 2 + (5*63);
      pxy1[1] = 3 + (2*45);
      pxy1[2] = pxy1[0]+62;
      pxy1[3] = pxy1[1]+44;

      pxy1[4] = (10*63)-63;
      pxy1[5] = 12;
      pxy1[6] = pxy1[4]+62;
      pxy1[7] = pxy1[5]+44;
      vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
      menu_ienable(dialog,DEMO,0);
     }
     if(deck_flag ==1)
      vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
     else 
      vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
     show_mouse();
     timer_flag=0;
     put_count(card_count);
     card_count++;
    }
   }
  }
 }
}

find_card(q)
int q;
{
 int l,k;

 deck_flag = 0;
 if(q<10)
 {
  l=0;
  k=q;
 }

 if(q>9 && q< 20)
 {
  l=1;
  k=q-10;
 }

 if(q>19 && q< 30)
 {
  l=2;
  k=q-20;
 }

 if(q>29 && q< 40)
 {
  l=3;
  k=q-30;
 }
 
 if(q>39 && q< 50)
 {
  l=0;
  k=q-40;
  deck_flag=1;
 }
 if(q>49)
 {
  l=1;
  k=q-50;
  deck_flag=1;
 }

 pxy[0] = 2 + (k*63);
 pxy[1] = 1 + (l*45);
 pxy[2] = pxy[0]+63;
 pxy[3] = pxy[1]+45;

}
find_card_position(x_cord,y_cord,z)
int x_cord,y_cord,z;
{
 int level,spot;
 int x_offset,y_offset;

 if(z==1)
 {
  level = x_cord;
  spot  = y_cord;
  switch(level)
  {
   case 1:
        x_offset = 13;
        y_offset = 128;
        break;
   case 2:
        x_offset = 52;
        y_offset = 106;
        break;
   case 3:
        x_offset = 91;
        y_offset = 84;
        break;
   case 4:
        x_offset = 130;
        y_offset = 62;
        break;
   case 5:
        x_offset = 169;
        y_offset = 40;
        break;
   case 6:
        x_offset = 208;
        y_offset = 18;
        break;
  }
 }
 if(z==0)
 {
  if(y_cord > 150)
   level=1;
  if(y_cord >128 && y_cord < 151)
   level=2;
  if(y_cord >106 && y_cord < 129)
   level=3;
  if(y_cord >84 && y_cord < 107)
   level=4;
  if(y_cord >62 && y_cord < 85)
   level=5;
  if(y_cord >40 && y_cord < 63)
   level=6;
  switch(level)
  {
   case 1:
        x_offset = 13;
        y_offset = 128;
        if(x_cord >= 76 && x_cord< 154)
           spot=1;
        if(x_cord >= 154 && x_cord< 232)
           spot=2;
        if(x_cord >= 232 && x_cord< 310)
           spot=3;
        if(x_cord >= 310 && x_cord< 388)
           spot=4;
        if(x_cord >= 388 && x_cord< 466)
           spot=5;
        if(x_cord >= 466 && x_cord< 544)
           spot=6;
        break;
   case 2:
        x_offset = 52;
        y_offset = 106;
        if(x_cord >= 115 && x_cord< 193)
           spot=1;
        if(x_cord >= 193 && x_cord< 271)
           spot=2;
        if(x_cord >= 271 && x_cord< 349)
           spot=3;
        if(x_cord >= 349 && x_cord< 427)
           spot=4;
        if(x_cord >= 427 && x_cord< 505)
           spot=5;
        break;
   case 3:
        x_offset = 91;
        y_offset = 84;
        if(x_cord >= 154 && x_cord< 232)
           spot=1;
        if(x_cord >= 232 && x_cord< 310)
           spot=2;
        if(x_cord >= 310 && x_cord< 388)
           spot=3;
        if(x_cord >= 388 && x_cord< 466)
           spot=4;
        break;
   case 4:
        x_offset = 130;
        y_offset = 62;
        if(x_cord >= 193 && x_cord< 271)
           spot=1;
        if(x_cord >= 271 && x_cord< 349)
           spot=2;
        if(x_cord >= 349 && x_cord< 427)
           spot=3;
        break;
   case 5:
        x_offset = 169;
        y_offset = 40;
        if(x_cord >= 222 && x_cord< 310)
           spot=1;
        if(x_cord >= 310 && x_cord< 388)
           spot=2;
        break;
   case 6:
        x_offset = 208;
        y_offset = 18;
        if(x_cord >= 261 && x_cord< 349)
           spot=1;
        break;            
  }/* END CASE  */
 }
 pxy[4] = x_offset+(spot*63)+((spot-1)*15);
 pxy[5] = y_offset;
 pxy[6] = pxy[4]+63;
 pxy[7] = pxy[5]+45;

}
release()
{
 int mouse_state,dum;
 mouse_state=1;
 while(mouse_state !=0)
 {
  graf_mkstate(&dum,&dum,&mouse_state,&dum);
 }
}		
verify(s,x_cord,y_cord,z)
int s,x_cord,y_cord,z;
{
 int level,spot,good,flag;
 int base_value1,base_value2;
 int base_suit1,base_suit2;

 good=0;
 flag=0;
 if(z==1)
 {
  level = x_cord;
  spot  = y_cord;
 }
 if(z==0)
 {
  if(y_cord > 150)
   level=1;
  if(y_cord >128 && y_cord < 151)
   level=2;
  if(y_cord >106 && y_cord < 129)
   level=3;
  if(y_cord >84 && y_cord < 107)
   level=4;
  if(y_cord >62 && y_cord < 85)
   level=5;
  if(y_cord >40 && y_cord < 63)
   level=6;
  switch(level)
  {
   case 1:
        if(x_cord >= 76 && x_cord< 154)
           spot=1;
        if(x_cord >= 154 && x_cord< 232)
           spot=2;
        if(x_cord >= 232 && x_cord< 310)
           spot=3;
        if(x_cord >= 310 && x_cord< 388)
           spot=4;
        if(x_cord >= 388 && x_cord< 466)
           spot=5;
        if(x_cord >= 466 && x_cord< 544)
           spot=6;
        break;
   case 2:
        if(x_cord >= 115 && x_cord< 193)
           spot=1;
        if(x_cord >= 193 && x_cord< 271)
           spot=2;
        if(x_cord >= 271 && x_cord< 349)
           spot=3;
        if(x_cord >= 349 && x_cord< 427)
           spot=4;
        if(x_cord >= 427 && x_cord< 505)
           spot=5;
        break;
   case 3:
        if(x_cord >= 154 && x_cord< 232)
           spot=1;
        if(x_cord >= 232 && x_cord< 310)
           spot=2;
        if(x_cord >= 310 && x_cord< 388)
           spot=3;
        if(x_cord >= 388 && x_cord< 466)
           spot=4;
        break;
   case 4:
        if(x_cord >= 193 && x_cord< 271)
           spot=1;
        if(x_cord >= 271 && x_cord< 349)
           spot=2;
        if(x_cord >= 349 && x_cord< 427)
           spot=3;
        break;
   case 5:
        if(x_cord >= 222 && x_cord< 310)
           spot=1;
        if(x_cord >= 310 && x_cord< 388)
           spot=2;
        break;
   case 6:
        if(x_cord >= 261 && x_cord< 349)
           spot=1;
        break;            
  }/* END CASE  */
 }

 if(level==1)
 {
  if(level2[spot]==99)
  {
   flag=1;
   base_value1 = card_value[level1[spot]];
   base_value2 = card_value[level1[spot+1]];
   base_suit1 = card_suit[level1[spot]];
   base_suit2 = card_suit[level1[spot+1]];
  }
 }
 if(level==2)
 {
  if(level3[spot]==99)
  {
   flag=1;
   base_value1 = card_value[level2[spot]];
   base_value2 = card_value[level2[spot+1]];
   base_suit1 = card_suit[level2[spot]];
   base_suit2 = card_suit[level2[spot+1]];
  }
 }
 if(level==3)
 {
  if(level4[spot]==99)
  {
   flag=1;
   base_value1 = card_value[level3[spot]];
   base_value2 = card_value[level3[spot+1]];
   base_suit1 = card_suit[level3[spot]];
   base_suit2 = card_suit[level3[spot+1]];
  }
 }
 if(level==4)
 {
  if(level5[spot]==99)
  {
   flag=1;
   base_value1 = card_value[level4[spot]];
   base_value2 = card_value[level4[spot+1]];
   base_suit1 = card_suit[level4[spot]];
   base_suit2 = card_suit[level4[spot+1]];
  }
 }
 if(level==5)
 {
  if(level6[spot]==99)
  {
   flag=1;
   base_value1 = card_value[level5[spot]];
   base_value2 = card_value[level5[spot+1]];
   base_suit1 = card_suit[level5[spot]];
   base_suit2 = card_suit[level5[spot+1]];
  }
 }
 if(level==6)
 {
  if(level7[spot]==99)
  {
   flag=1;
   base_value1 = card_value[level6[spot]];
   base_value2 = card_value[level6[spot+1]];
   base_suit1 = card_suit[level6[spot]];
   base_suit2 = card_suit[level6[spot+1]];
  }
 }

 if(flag==1)
 {
  if(card_value[s]==14)
  {
   if(base_value1 ==99 || base_value2 ==99)
   {
    good=0;
    goto done;
   }
   if(base_value1 ==0 || base_value2 ==0)
   {
    good=0;
    goto done;
   }
   good=1;
   goto done;
  }
  if(base_value1==14 || base_value2==14)
  {
   if(base_value1 ==0 || base_value2 ==0)
   {
    good=0;
    goto done;
   }
   if(base_value1 ==99 || base_value2 ==99)
   {
    good=0;
    goto done;
   }
   if(base_value1==14 && base_value2==14)
   {
    good=1;
    goto done;
   }
   if(base_value1!=14)
   {
    if(card_value[s]==base_value1+1)
    {
     good=1;
     goto done;
    }
    if(card_value[s]==base_value1-1 && base_value1>2)
    {
     good=1;
     goto done;
    }
    if(card_value[s]==base_value1-2 && base_value1>3)
    {
     good=1;
     goto done;
    }
    if(card_suit[s]==base_suit1 || card_value[s] == base_value1)
    {
     good=1;
     goto done;
    }
   }
   if(base_value2!=14)
   {
    if(card_value[s]==base_value2+1)
    {
     good=1;
     goto done;
    }
    if(card_value[s]==base_value2-1 && base_value2>2)
    {
     good=1;
     goto done;
    }
    if(card_value[s]==base_value2-2 && base_value2>3)
    {
     good=1;
     goto done;
    }
    if(card_suit[s]==base_suit2 || card_value[s] == base_value2)
    {
     good=1;
     goto done;
    }
   }
   if(base_value1!=14)
   {
    if(card_value[s]==base_value1+2 && base_value1<13)
    {
     good=1;
     goto done;
    }
   }
   if(base_value2!=14)
   {
    if(card_value[s]==base_value2+2 && base_value2<13)
    {
     good=1;
     goto done;
    }
   }      
  }  
 }
 if(base_value1==base_value2 && card_value[s]==base_value1)
 {
  good=1;
  goto done;
 }
 if(base_suit1==base_suit2 && base_suit1 == card_suit[s])
 {
  good=1;
  goto done;
 }
 if(card_value[s]==base_value1 && card_suit[s] == base_suit2)
 {
  good=1;
  goto done;
 }
 if(card_value[s]==base_value2 && card_suit[s] == base_suit1)
 {
  good=1;
  goto done;
 }
 if(base_value1 == base_value2-1 && base_value1 == card_value[s]-2)
 {
  if(card_value[s]<14)
  {
   good=1;
   goto done;
  }
 }
 if(base_value1 == base_value2-1 && base_value1 == card_value[s]+1)
 {
  if(card_value[s]<14)
  {
   good=1;
   goto done;
  }
 }
 if(base_value1 == base_value2+1 && base_value1 == card_value[s]+2)
 {
  if(card_value[s]<14)
  {
   good=1;
   goto done;
  }
 }
 if(base_value1 == base_value2+1 && base_value1 == card_value[s]-1)
 {
  if(card_value[s]>=2)
  {
   good=1;
   goto done;
  }
 }
 if(base_value1 == base_value2-2 && base_value1 == card_value[s]-1)
 {
  good=1;
  goto done;
 }
 if(base_value1 == base_value2+2 && base_value1 == card_value[s]+1)
 {
  good=1;
  goto done;
 }
 done:
 if(good==1)
 {
  if(level==1)
   level2[spot]=s;   
  if(level==2)
   level3[spot]=s;
  if(level==3)
   level4[spot]=s;
  if(level==4)
   level5[spot]=s;
  if(level==5)
   level6[spot]=s;
  if(level==6)
  {
   level7[spot]=s;
   mountain=1;
  }
  if(z==0)
  {
   score=score+level;
   put_score(score);
  }
 }
 return(good);
}

delay(j)
int j;
{
 int x,y;

 for(x=1;x!=5;x++)
  for(y=1;y!=j;y++);
}

terminate()
{
	/*
		Clear 68901 timer interrupt
	*/
	unset_timer();

	/*
		Restore the old process terminate vector
	*/
	Setexc(0x0102, oldvector);
}

/*
	Get the old terminate application vector and setup
	the local terminate function.
*/
set_terminate()
{
	long user_stack = Super(0L);

	oldvector = Setexc(0x0102, -1L);
	Setexc(0x0102, terminate);

	Super(user_stack);
}


unset_terminate()
{
	/*
		Restore the old process terminate vector
	*/
	Supexec(Setexc(0x0102, oldvector));
}


/* 
	This is the interrupt dispatcher routine.
*/
asm {
dispatcher:
			jsr		ticker		/* our function								*/

			bclr.b	#5,0xfffa0f /* Tell MFP the interrupt has been serviced	*/
			rte		 			/* return from exception					*/
}


/*
	This function is callled by the main() function to set up the
	application terminate function and the 68901 function timer.
*/
set_timer()
{
	register	char	*globals;


	/*
		Tell the timer chip to call the dispatcher routine for the interrupt.
	*/
	Xbtimer(MyApp, Control, Data, dispatcher);
}


/*
	Turn off the timer and reset the terminate vector.
*/
unset_timer()
{
	/*
		Turn off the application timer.
	*/
	Xbtimer(MyApp, Off, Off, NULL);
}
put_icons()
{
 
 pxy[0] = 254;
 pxy[1] = 66;
 pxy[2] = pxy[0]+29;
 pxy[3] = pxy[1]+15;

 pxy[4] = (2*63)-63;
 pxy[5] = 20;
 pxy[6] = pxy[4]+29;
 pxy[7] = pxy[5]+15;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

 pxy[4] = (2*63)-63;
 pxy[5] = 37;
 pxy[6] = pxy[4]+29;
 pxy[7] = pxy[5]+15;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

 pxy[4] = (2*63)-63;
 pxy[5] = 54;
 pxy[6] = pxy[4]+29;
 pxy[7] = pxy[5]+15;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

 pxy[0] = 380;
 pxy[1] = 46;
 pxy[2] = pxy[0]+41;
 pxy[3] = pxy[1]+7;

 pxy[4] = 3;
 pxy[5] = 41;
 pxy[6] = pxy[4]+41;
 pxy[7] = pxy[5]+7;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);


 pxy[0] = 380;
 pxy[1] = 54;
 pxy[2] = pxy[0]+41;
 pxy[3] = pxy[1]+7;

 pxy[4] = 3;
 pxy[5] = 24;
 pxy[6] = pxy[4]+41;
 pxy[7] = pxy[5]+7;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

 pxy[0] = 380;
 pxy[1] = 62;
 pxy[2] = pxy[0]+41;
 pxy[3] = pxy[1]+7;

 pxy[4] = 3;
 pxy[5] = 58;
 pxy[6] = pxy[4]+41;
 pxy[7] = pxy[5]+7;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

}

put_count(count)
int count;
{
 int d,t;
 int d1,t1;

 t=count/10;
 t1=count % 10;

 d=t1;
 
 pxy[0] = 380;
 pxy[1] = 62;
 pxy[2] = pxy[0]+41;
 pxy[3] = pxy[1]+7;

 pxy[4] = 3;
 pxy[5] = 58;
 pxy[6] = pxy[4]+41;
 pxy[7] = pxy[5]+7;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

 if(t>0)
 {
   pxy[0] = 254+((t-1)*10);
   pxy[1] = 47;
   pxy[2] = pxy[0]+10;
   pxy[3] = pxy[1]+7;

   pxy[4] = (2*63)-58;
   pxy[5] = 24;
   pxy[6] = pxy[4]+10;
   pxy[7] = pxy[5]+7;

   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
 }
 if(d==0)
  d=10;
 pxy[0] = 254+((d-1)*10);
 pxy[1] = 47;
 pxy[2] = pxy[0]+10;
 pxy[3] = pxy[1]+7;

 pxy[4] = (2*63)-48;
 pxy[5] = 24;
 pxy[6] = pxy[4]+10;
 pxy[7] = pxy[5]+7;

   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

}
put_score(count)
int count;
{
 int d,t;
 int d1,t1;

 t=count/10;
 t1=count % 10;

 d=t1;
 
 if(t>0)
 {
   pxy[0] = 254+((t-1)*10);
   pxy[1] = 57;
   pxy[2] = pxy[0]+10;
   pxy[3] = pxy[1]+7;

   pxy[4] = (2*63)-58;
   pxy[5] = 41;
   pxy[6] = pxy[4]+10;
   pxy[7] = pxy[5]+7;

   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
 }
 if(d==0)
  d=10;
 pxy[0] = 254+((d-1)*10);
 pxy[1] = 57;
 pxy[2] = pxy[0]+10;
 pxy[3] = pxy[1]+7;

 pxy[4] = (2*63)-48;
 pxy[5] = 41;
 pxy[6] = pxy[4]+10;
 pxy[7] = pxy[5]+7;

   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

}
put_high(count)
int count;
{
 int d,t;
 int d1,t1;

 t=count/10;
 t1=count % 10;

 pxy[0] = 254;
 pxy[1] = 66;
 pxy[2] = pxy[0]+29;
 pxy[3] = pxy[1]+15;

 pxy[4] = (2*63)-63;
 pxy[5] = 54;
 pxy[6] = pxy[4]+29;
 pxy[7] = pxy[5]+15;

 vro_cpyfm(handle,3,pxy,&DECK2,&DEST);


 d=t1;
 
 if(t>0)
 {
   pxy[0] = 254+((t-1)*10);
   pxy[1] = 47;
   pxy[2] = pxy[0]+10;
   pxy[3] = pxy[1]+7;

   pxy[4] = (2*63)-58;
   pxy[5] = 58;
   pxy[6] = pxy[4]+10;
   pxy[7] = pxy[5]+7;

   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
 }
 if(d==0)
  d=10;
 pxy[0] = 254+((d-1)*10);
 pxy[1] = 47;
 pxy[2] = pxy[0]+10;
 pxy[3] = pxy[1]+7;

 pxy[4] = (2*63)-48;
 pxy[5] = 58;
 pxy[6] = pxy[4]+10;
 pxy[7] = pxy[5]+7;

   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);

}
reward()
{
    int display,card;
    display=0;
    if(card_count==53)
    {
     display=1;
    }
    while(card_count < 53 && display==0)
    {
     card=cards[card_count]-1;
     find_card(card);
     used_cards++;
     cards_used[used_cards]=card;
     pxy[4] = (10*63)-63;
     pxy[5] = 60;
     pxy[6] = pxy[4]+63;
     pxy[7] = pxy[5]+45;

     hide_mouse();

     form_dial(FMD_GROW,567,12,62,44,pxy[4],pxy[5],62,44);
     Dosound(sound2);
     if(card_count ==52)
     {
      pxy1[0] = 2 + (5*63);
      pxy1[1] = 3 + (2*45);
      pxy1[2] = pxy1[0]+62;
      pxy1[3] = pxy1[1]+44;

      pxy1[4] = (10*63)-63;
      pxy1[5] = 12;
      pxy1[6] = pxy1[4]+62;
      pxy1[7] = pxy1[5]+44;
      vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
     }
     if(deck_flag ==1)
      vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
     else 
      vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
     show_mouse();
     timer_flag=0;
     put_count(card_count);
     card_count++;
     score=score+1;
     put_score(score);
    }
    mountain=0;
    hide_mouse();
    flip_cards();
    show_mouse();
}
flip_cards()
{
 int level,spot;
 int x_offset,y_offset,i,j;

 for(i=1;i!=8;i++)
 {
  pxy[0] = 2 + (2*63);
  pxy[1] = 1 + (1*45);
  pxy[2] = pxy[0]+62;
  pxy[3] = pxy[1]+44;

  pxy[4] = ((i*63)-63)+((15*i)+30);
  pxy[5] = 150;
  pxy[6] = pxy[4]+63;
  pxy[7] = pxy[5]+45;

  vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
  delay(1000);
 }

 for(level=1;level!=7;level++)
 {
  switch(level)
  {
   case 1:
        x_offset = 13;
        y_offset = 128;
        break;
   case 2:
        x_offset = 52;
        y_offset = 106;
        break;
   case 3:
        x_offset = 91;
        y_offset = 84;
        break;
   case 4:
        x_offset = 130;
        y_offset = 62;
        break;
   case 5:
        x_offset = 169;
        y_offset = 40;
        break;
   case 6:
        x_offset = 208;
        y_offset = 18;
        break;
  }
  for(spot=1;spot!=8-level;spot++)
  {

   pxy[4] = x_offset+(spot*63)+((spot-1)*15);
   pxy[5] = y_offset;
   pxy[6] = pxy[4]+63;
   pxy[7] = pxy[5]+45;

   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
   delay(1000);
  }
 }
 for(i=1;i!=8;i++)
 {
  j=level1[i]; 
  find_card(j);

  pxy[4] = ((i*63)-63)+((15*i)+30);
  pxy[5] = 150;
  pxy[6] = pxy[4]+63;
  pxy[7] = pxy[5]+45;

  Dosound(sound2);
  if(deck_flag ==1)
   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
  else 
   vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
  delay(10000);
 }
 for(level=1;level!=7;level++)
 {
  switch(level)
  {
   case 1:
        x_offset = 13;
        y_offset = 128;
        break;
   case 2:
        x_offset = 52;
        y_offset = 106;
        break;
   case 3:
        x_offset = 91;
        y_offset = 84;
        break;
   case 4:
        x_offset = 130;
        y_offset = 62;
        break;
   case 5:
        x_offset = 169;
        y_offset = 40;
        break;
   case 6:
        x_offset = 208;
        y_offset = 18;
        break;
  }
  for(spot=1;spot!=8-level;spot++)
  {
   if(level==1)
   {
    j=level2[spot];
   }
   if(level==2)
   {
    j=level3[spot];
   }
   if(level==3)
   {
    j=level4[spot];
   }
   if(level==4)
   {
    j=level5[spot];
   }
   if(level==5)
   {
    j=level6[spot];
   }
   if(level==6)
   {
    j=level7[spot];
   }
   if(j!=99)
   {
    find_card(j);
    pxy[4] = x_offset+(spot*63)+((spot-1)*15);
    pxy[5] = y_offset;
    pxy[6] = pxy[4]+63;
    pxy[7] = pxy[5]+45;
 
    if(level==6)
     Dosound(sound1);
    else    
     Dosound(sound2);
    if(deck_flag ==1)
     vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
    else 
     vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
    delay(10000);
   }
  }
 }
}

reset1()
{
 screen4=holder4;
asm{
	move.l screen,A0
	move.l screen4,A1
	move.l #0,D0
loop2:move.l (A1)+,(A0)+
		add.l #1,D0
		cmp.l #8000,D0
		bne loop2
	}
}
reset2()
{
 screen3=holder3;
asm{
	move.l screen3,A0
	move.l screen,A1
	move.l #0,D0
loop3:move.l (A1)+,(A0)+
		add.l #1,D0
		cmp.l #8000,D0
		bne loop3
	}
}
reset3()
{
 screen3=holder3;
asm{
	move.l screen,A0
	move.l screen3,A1
	move.l #0,D0
loop4:move.l (A1)+,(A0)+
		add.l #1,D0
		cmp.l #8000,D0
		bne loop4
	}
}
do_help()
{
 int card,spot,level,x;
 int good_flag;

 help_flag=0;
 card = cards_used[used_cards];
 if(used_cards==0)
  return;
 for(level=1;level!=7;level++)
 {
  for(spot=1;spot!=8-level;spot++)
  {
   good_flag=verify(card,level,spot,1);
   if(good_flag==1)
   {
    help_flag=1;
    goto mark;
   }
  }
 }
 mark:
 if(good_flag==1)
 {
  find_card(card);
  used_cards--;
      
  find_card_position(level,spot,1);

  hide_mouse();

  form_dial(FMD_GROW,567,60,62,44,pxy[4],pxy[5],62,44);
  Dosound(sound2);
  if(deck_flag ==1)
   vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
  else 
   vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
  if(used_cards == 0)
  {
    pxy1[0] = 2 + (5*63);
    pxy1[1] = 3 + (2*45);
    pxy1[2] = pxy1[0]+62;
    pxy1[3] = pxy1[1]+44;

    pxy1[4] = (10*63)-63;
    pxy1[5] = 60;
    pxy1[6] = pxy1[4]+62;
    pxy1[7] = pxy1[5]+44;
    vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
   }else
   {
    card=cards_used[used_cards];
    find_card(card);
    pxy[4] = (10*63)-63;
    pxy[5] = 60;
    pxy[6] = pxy[4]+63;
    pxy[7] = pxy[5]+45;
    if(deck_flag ==1)
     vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
    else 
     vro_cpyfm(handle,3,pxy,&DECK1,&DEST); 
  }  
  show_mouse();
 }
}
do_demo()
{
 int card,display;
 
 display=0;

 vs_curaddress(handle,3,15);
 printf("   DEMO     \n");

 while(card_count < 53 && display==0 && mountain==0)
 {

     card=cards[card_count]-1;
     find_card(card);
     used_cards++;
     cards_used[used_cards]=card;
     pxy[4] = (10*63)-63;
     pxy[5] = 60;
     pxy[6] = pxy[4]+63;
     pxy[7] = pxy[5]+45;

     hide_mouse();

     form_dial(FMD_GROW,567,12,62,44,pxy[4],pxy[5],62,44);
     Dosound(sound2);
     if(card_count ==52)
     {
      pxy1[0] = 2 + (5*63);
      pxy1[1] = 3 + (2*45);
      pxy1[2] = pxy1[0]+62;
      pxy1[3] = pxy1[1]+44;

      pxy1[4] = (10*63)-63;
      pxy1[5] = 12;
      pxy1[6] = pxy1[4]+62;
      pxy1[7] = pxy1[5]+44;
      vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
      menu_ienable(dialog,DEMO,0);
     }
     if(deck_flag ==1)
      vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
     else 
      vro_cpyfm(handle,3,pxy,&DECK1,&DEST);
     show_mouse();
     timer_flag=0;
     put_count(card_count);
     card_count++;
     delay(8000);
     help_flag=1;
     while(help_flag==1)
     {
      do_help();
      delay(15000);
     }
 }
 vs_curaddress(handle,3,15);
 printf("            \n");
}
fade(set)
int set;
{
 int x;
 int color1,color2,color3,color0;

 x=-1;
 color0=Setcolor(0,x);
 color1=Setcolor(1,x);
 color2=Setcolor(2,x);
 color3=Setcolor(3,x);

 for(x=1;x!=6;x++)
 {
  if(x==1)
  {
   Setcolor(1,1280);
   Setcolor(2,96);
   Setcolor(3,1638);
  }
  if(x==2)
  {
   Setcolor(1,1024);
   Setcolor(2,64);
   Setcolor(3,1365);
  }
  if(x==3)
  {
   Setcolor(1,768);
   Setcolor(2,48);
   Setcolor(3,1092);
  }  
  if(x==4)
  {
   Setcolor(1,256);
   Setcolor(2,32);
   Setcolor(3,819);
  }
  if(set==0)
  {
   if(x==5)
   {
    Setcolor(1,514);
    Setcolor(2,514);
    Setcolor(3,514);
   }
  }else
  {
    Setcolor(1,0);
    Setcolor(2,0);
    Setcolor(3,0);
  }
  delay(1500);
 }
 reset();
 Setcolor(1,color1);
 Setcolor(2,color2);
 Setcolor(3,color3); 
}
high_score_pointer()
{
 int x;

 pxy1[0] = (2*63)-20;
 pxy1[1] = 54;
 pxy1[2] = pxy1[0]+28;
 pxy1[3] = pxy1[1]+15;

 pxy1[4] = (2*63)-20;
 pxy1[5] = 54;
 pxy1[6] = pxy1[4]+28;
 pxy1[7] = pxy1[5]+15;

 vro_cpyfm(handle,3,pxy1,&DEST,&PAD);

 for(x=1;x!=4;x++)
{
  pxy[0] = 284;
  pxy[1] = 66;
  pxy[2] = pxy[0]+28;
  pxy[3] = pxy[1]+15;

  pxy[4] = (2*63)-20;
  pxy[5] = 54;
  pxy[6] = pxy[4]+28;
  pxy[7] = pxy[5]+15;

  vro_cpyfm(handle,3,pxy,&DECK2,&DEST);
  Dosound(sound1);
  delay(12000);
  vro_cpyfm(handle,3,pxy1,&PAD,&DEST);
  delay(5000);
 }
}
title()
{
 int color1,x;
 
 x=-1;
 color1=Setcolor(0,x);
 Setcolor(0,0);
 hide_mouse();
 pxy1[0] = 2 + (7*63);
 pxy1[1] = 1 + (1*45);
 pxy1[2] = pxy1[0]+150;
 pxy1[3] = pxy1[1]+17;

 pxy1[4] = (2*63)+111;
 pxy1[5] = 92;
 pxy1[6] = pxy1[4]+150;
 pxy1[7] = pxy1[5]+17;

 vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
 Dosound(sound3);
 delay(60000);
 delay(10000);
 fade(0);
 reset();
 delay(8000);

 pxy1[0] = 593;
 pxy1[1] = 1 + (1*45);
 pxy1[2] = pxy1[0]+40;
 pxy1[3] = pxy1[1]+17;

 pxy1[4] = (2*63)+167;
 pxy1[5] = 92;
 pxy1[6] = pxy1[4]+40;
 pxy1[7] = pxy1[5]+17;

 vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
 delay(60000);
 fade(0);
 reset();
 delay(8000);

 pxy1[0] = 317;
 pxy1[1] = 28 + (1*45);
 pxy1[2] = pxy1[0]+324;
 pxy1[3] = pxy1[1]+ 17;

 pxy1[4] = (2*63)+30;
 pxy1[5] = 92;
 pxy1[6] = pxy1[4]+324;
 pxy1[7] = pxy1[5]+17;

 vro_cpyfm(handle,3,pxy1,&DECK2,&DEST);
 delay(60000);
 delay(45000);
 fade(1);
 reset();
 delay(10000);
 Setcolor(0,color1);
 show_mouse(); 
}
do_dialog2()
{
	static int cx, cy, cw, ch,ct;
	int good,inp,x;
    rsrc_gaddr(0, TREE01, &dialog2);
    hide_mouse();
    reset2();
    x=0; 
    for(x=0;x!=20;x++)
    {
     pval3[x]='X';
     ptect3[x]=0;
    } 
  
	((TEDINFO *)dialog2[CNAME].ob_spec)->te_ptext = ptect3;
	((TEDINFO *)dialog2[CNAME].ob_spec)->te_pvalid = pval3;
	((TEDINFO *)dialog2[CNAME].ob_spec)->te_txtlen = 21;
	form_center(dialog2, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0,0,0,0,cx, cy, cw, ch);
	objc_draw(dialog2, ROOT, 1, cx, cy, cw, ch);
    show_mouse();
	form_do(dialog2,0);
	form_dial(FMD_FINISH, 0,0,0,0,cx, cy, cw, ch);
	dialog2[OKC].ob_state &= ~SELECTED;
	dialog2[CNAME].ob_state &= ~SELECTED;
    hide_mouse();
    reset3();
    for(x=0;x!=20;x++)
    {
     champ_name[x]=ptect3[x];
    }
    namelength=strlen(champ_name);
    show_mouse();
} 
copy_undo()
{
 int x,y;

 undo_score=score;
 undo_high_score=high_score;
 undo_card_count=card_count;
 undo_used_cards=used_cards;

 for(x=1;x!=8;x++)
 {
   undo_level1[x]=level1[x];
   if(x<7)
    undo_level2[x]=level2[x];
   if(x<6)
    undo_level3[x]=level3[x];
   if(x<5)
    undo_level4[x]=level4[x];
   if(x<4)
    undo_level5[x]=level5[x];
   if(x<3)
    undo_level6[x]=level6[x];
   if(x<2)
    undo_level7[x]=level7[x];
 }

 pict2=(int *)(Logbase);
 screen3=holder3;
 hide_mouse();
 asm{
     move.l pict2,A2
     move.l screen3,A3
     move.l #0,D0
lop8:move.l (A2)+,(A3)+
     add.l #1,D0
     cmp.l #8000,D0
     bne lop8
	}
 show_mouse();
}

retrieve_undo()
{
 int x,y;


 score=undo_score;
 high_score=undo_high_score;
 card_count=undo_card_count;
 used_cards=undo_used_cards;
 for(x=1;x!=8;x++)
 {
   level1[x]=undo_level1[x];
   if(x<7)
    level2[x]=undo_level2[x];
   if(x<6)
    level3[x]=undo_level3[x];
   if(x<5)
    level4[x]=undo_level4[x];
   if(x<4)
    level5[x]=undo_level5[x];
   if(x<3)
    level6[x]=undo_level6[x];
   if(x<2)
    level7[x]=undo_level7[x];
 }
 hide_mouse();   
 pict2=(int *)(Logbase);
 screen3=holder3;
 asm{
     move.l pict2,A0
     move.l screen3,A1
     move.l #0,D0
lop3:move.l (A1)+,(A0)+
     add.l #1,D0
     cmp.l #8000,D0
     bne lop3
    }
 show_mouse();
}	
