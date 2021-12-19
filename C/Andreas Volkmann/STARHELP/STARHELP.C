/*************************************************/
/*                 STAR-INIT                     */
/*************************************************/
#include"superdat.h"
#include"starfrg.h"
long menu_tree;
int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int pxy[12];
int int_in[11],int_out[57];
int handle;
int phys_handle;
int ap_id;
int gl_hchar,gl_wchar,gl_wbox,gl_hbox;
int x,y,w,h;
int xdesk,ydesk,wdesk,hdesk;
int mausx,mausy;
int title,item,dummy;
char send1[]={3,27,52};
char send2[]={3,27,53};
char send3[]={4,27,73,1};
char send4[]={4,27,73,0};
char send5[]={4,27,45,1};
char send6[]={4,27,45,0};
char send7[]={4,27,83,0};
char send8[]={3,27,84};
char send9[]={4,27,83,1};
char send10[]={3,27,84};
char send11[]={3,27,80};
char send13[]={3,27,77};
char send15[]={3,27,15};
char send17[]={4,27,112,1};
char send18[]={4,27,112,0};
char send19[]={4,27,87,1};
char send20[]={4,27,87,0};
char send21[]={3,27,57};
char send22[]={3,27,56};
char send23[]={4,27,92,1};
char send24[]={4,27,92,0};
char send25[]={3,27,71};
char send26[]={3,27,72};
char send27[]={3,27,69};
char send28[]={3,27,70};
char send29[]={4,27,85,1};
char send30[]={4,27,85,0};
long ted_addr,tree;
char *addr;
int urand=0;
int lrand=0;
int rrand=80;
int mesag_buf[8];
char string[10];
extern gl_apid;
/*******************************/
/*       DESELECT              */
/*******************************/
deselect(tree,objekt)
long tree;
int objekt;
{
   int state;
   state=LWGET(OB_STATE(objekt));
   LWSET(OB_STATE(objekt),state & -2);
}
/****************************/
/*        CONVERT           */
/****************************/
convert(wert)
int wert;
{
   int zwsp,stelle,flag;
   stelle = 0;
   flag = 0;
   if( wert < 0 )
   {
      string[stelle++] = '-';
      wert *= -1;
   }
   else
      string[stelle++] = ' ';
   zwsp = wert/10000;
   berechne(&flag,&stelle,&zwsp);
   wert = wert - zwsp * 10000;
   zwsp = wert/1000;
   berechne(&flag,&stelle,&zwsp);
   wert = wert - zwsp * 1000;
   zwsp = wert/100;
   berechne(&flag,&stelle,&zwsp);
   wert = wert - zwsp * 100;
   zwsp = wert/10;
   berechne(&flag,&stelle,&zwsp);
   wert = wert - zwsp * 10;
   string[stelle++] = wert + '0';
   string[stelle] = '\0';
}
berechne(flag,stelle,zwsp)
int *flag,*stelle,*zwsp;
{
   if((*flag==0)&&(*zwsp<1))
   ;
   else
   {
      *flag = 1;
      string[*stelle] = *zwsp + '0';
      *stelle = *stelle + 1;
   }
}
/*************************************************/
/*             nix_rand                          */
/*************************************************/
nix_rand()
{
     urand=0;
     rsrc_gaddr(0,STARMENU,&tree);
     ted_addr=LLGET(OB_SPEC(URAND));
     addr=LLGET(ted_addr);
     *addr='0';
     *(addr+1)='0';
     deselect(tree,URANDL);
     objc_draw(menu_tree,URANDGES,8,x,y,w,h);
     gemdos(0x5,27);
     gemdos(0x5,79);
}
/*************************************************/
/*             message                           */
/*************************************************/
message(obj_ein,obj_aus,mess)
char mess[];
int obj_ein,obj_aus;
{
     int i;

     objc_change(menu_tree,obj_ein,0,x,y,w,h,1,1);
     objc_change(menu_tree,obj_aus,0,x,y,w,h,0,1);
     for(i=1;i<mess[0];i++)
          gemdos(0x5,mess[i]);
}
/*********************************************/
/*        haupt_prog                         */
/*********************************************/
haupt_prog()
{
     int ende,event;
     rsrc_gaddr(0,STARMENU,&menu_tree);
     form_center(menu_tree,&x,&y,&w,&h);
     form_dial(0,x,y,w,h);
     objc_draw(menu_tree,0,8,x,y,w,h);
     ende=FALSE;
     while(ende!=TRUE)
     {
          event=evnt_button(1,1,1,&mausx,&mausy,&dummy,&dummy);
          item=objc_find(menu_tree,STARMENU,8,mausx,mausy);
          switch(item)
          {
               case NLQE:
                    message(NLQE,NLQA,send1);
               break;
               case NLQA:
                    message(NLQA,NLQE,send2);
               break;
               case KURSE:
                    message(KURSE,KURSA,send3);
               break;
               case KURSA:
                    message(KURSA,KURSE,send4);
               break;
               case UNTE:
                    message(UNTE,UNTA,send5);
               break;
               case UNTA:
                    message(UNTA,UNTE,send6);
               break;
               case SUPE:
                    message(SUPE,SUPA,send7);
               break;
               case SUPA:
                    message(SUPA,SUPE,send8);
               break;
               case SUBE:
                    message(SUBE,SUBA,send9);
               break;
               case SUBA:
                    message(SUBA,SUBE,send10);
               break;
               case PICAE:
                    objc_change(menu_tree,PICAE,0,x,y,w,h,1,1);
                    objc_change(menu_tree,ELITEE,0,x,y,w,h,0,1);
                    objc_change(menu_tree,SCHME,0,x,y,w,h,0,1);
                    gemdos(0x5,18);
               break;
               case ELITEE:
                    objc_change(menu_tree,PICAE,0,x,y,w,h,0,1);
                    objc_change(menu_tree,ELITEE,0,x,y,w,h,1,1);
                    objc_change(menu_tree,SCHME,0,x,y,w,h,0,1);
                    gemdos(0x5,27);
                    gemdos(0x5,77);
               break;
               case SCHME:
                    objc_change(menu_tree,PICAE,0,x,y,w,h,0,1);
                    objc_change(menu_tree,ELITEE,0,x,y,w,h,0,1);
                    objc_change(menu_tree,SCHME,0,x,y,w,h,1,1);
                    gemdos(0x5,15);
               break;
               case PROPE:
                    message(PROPE,PROPA,send17);
               break;
               case PROPA:
                    message(PROPA,PROPE,send18);
               break;
               case BREITE:
                    message(BREITE,BREITA,send19);
               break;
               case BREITA:
                    message(BREITA,BREITE,send20);
               break;
               case PAPE:
                    message(PAPE,PAPA,send21);
               break;
               case PAPA:
                    message(PAPA,PAPE,send22);
               break;
               case NULSTR:
                    message(NULSTR,NULO,send23);
               break;
               case NULO:
                    message(NULO,NULSTR,send24);
               break;
               case DOPPELE:
                    message(DOPPELE,DOPPELA,send25);
               break;
               case DOPPELA:
                    message(DOPPELA,DOPPELE,send26);
               break;
               case FETTE:
                    message(FETTE,FETTA,send27);
               break;
               case FETTA:
                    message(FETTA,FETTE,send28);
               break;
               case UNIE:
                    message(UNIE,UNIA,send29);
               break;
               case UNIA:
                    message(UNIA,UNIE,send30);
               break;
               case VORSCH:
                    objc_change(menu_tree,VORSCH,0,x,y,w,h,0,1);
                    gemdos(0x5,27);
                    gemdos(0x5,74);
                    gemdos(0x5,1);
               break;
               case RESET:
                    objc_change(menu_tree,RESET,0,x,y,w,h,0,1);
                    gemdos(0x5,27);
                    gemdos(0x5,64);
               break;
               case URANDL:
                    rsrc_gaddr(0,STARMENU,&tree);
                    ted_addr=LLGET(OB_SPEC(URAND));          
                    addr=LLGET(ted_addr);
                    if(urand>0)
                    {
                         urand-=1;
                         convert(urand);
                         if(string[2]=='\0')
                         {
                              *addr='0';
                              *(addr+1)=string[1];
                         }
                         else
                         {
                              *addr=string[1];
                              *(addr+1)=string[2];
                         }
                         if(urand==0)
                              nix_rand();
                         else
                         {
                              gemdos(0x5,27);
                              gemdos(0x5,78);
                              gemdos(0x5,urand);
                         }
                    }
                    deselect(tree,URANDL);
                    objc_draw(menu_tree,URANDGES,8,x,y,w,h);
               break;
               case URANDR:
                    rsrc_gaddr(0,STARMENU,&tree);
                    ted_addr=LLGET(OB_SPEC(URAND));          
                    addr=LLGET(ted_addr);
                    if(urand<127)
                    {
                         urand+=1;
                         convert(urand);
                         if(string[2]=='\0')
                         {
                              *addr='0';
                              *(addr+1)=string[1];
                         }
                         else
                         {
                              *addr=string[1];
                              *(addr+1)=string[2];
                         }
                    gemdos(0x5,27);
                    gemdos(0x5,78);
                    gemdos(0x5,urand);
                    }
                    deselect(tree,URANDR);
                    objc_draw(menu_tree,URANDGES,8,x,y,w,h);
               break;
               case LRANDL:
                    rsrc_gaddr(0,STARMENU,&tree);
                    ted_addr=LLGET(OB_SPEC(LRAND));          
                    addr=LLGET(ted_addr);
                    if(lrand>0)
                    {
                         lrand-=1;
                         convert(lrand);
                         if(string[2]=='\0')
                         {
                              *addr='0';
                              *(addr+1)=string[1];
                         }
                         else
                         {
                              *addr=string[1];
                              *(addr+1)=string[2];
                         }
                    gemdos(0x5,27);
                    gemdos(0x5,108);
                    gemdos(0x5,lrand);
                    }
                    deselect(tree,LRANDL);
                    objc_draw(menu_tree,LRANDGES,8,x,y,w,h);
               break;
               case LRANDR:
                    rsrc_gaddr(0,STARMENU,&tree);
                    ted_addr=LLGET(OB_SPEC(LRAND));          
                    addr=LLGET(ted_addr);
                    if(lrand<80)
                    {
                         lrand+=1;
                         convert(lrand);
                         if(string[2]=='\0')
                         {
                              *addr='0';
                              *(addr+1)=string[1];
                         }
                         else
                         {
                              *addr=string[1];
                              *(addr+1)=string[2];
                         }
                    gemdos(0x5,27);
                    gemdos(0x5,108);
                    gemdos(0x5,lrand);
                    }
                    deselect(tree,LRANDR);
                    objc_draw(menu_tree,LRANDGES,8,x,y,w,h);
               break;
               case RRANDL:
                    rsrc_gaddr(0,STARMENU,&tree);
                    ted_addr=LLGET(OB_SPEC(RRAND));          
                    addr=LLGET(ted_addr);
                    if(rrand>1)
                    {
                         rrand-=1;
                         convert(rrand);
                         if(string[2]=='\0')
                         {
                              *addr='0';
                              *(addr+1)=string[1];
                         }
                         else
                         {
                              *addr=string[1];
                              *(addr+1)=string[2];
                         }
                    gemdos(0x5,27);
                    gemdos(0x5,81);
                    gemdos(0x5,rrand);
                    }
                    deselect(tree,RRANDL);
                    objc_draw(menu_tree,RRANDGES,8,x,y,w,h);
               break;
               case RRANDR:
                    rsrc_gaddr(0,STARMENU,&tree);
                    ted_addr=LLGET(OB_SPEC(RRAND));          
                    addr=LLGET(ted_addr);
                    if(rrand<136)
                    {
                         rrand+=1;
                         convert(rrand);
                         if(string[2]=='\0')
                         {
                              *addr='0';
                              *(addr+1)=string[1];
                         }
                         else
                         {
                              *addr=string[1];
                              *(addr+1)=string[2];
                         }
                    gemdos(0x5,27);
                    gemdos(0x5,81);
                    gemdos(0x5,rrand);
                    }
                    deselect(tree,RRANDR);
                    objc_draw(menu_tree,RRANDGES,8,x,y,w,h);
               break;
               case OKAY:
                    objc_change(menu_tree,OKAY,0,x,y,w,h,1,1);
                    form_dial(3,x,y,w,h);
                    ende=TRUE;
                    objc_change(menu_tree,OKAY,0,x,y,w,h,0,1);
               break;
          }                                     /* Ende switch     */
     }                                          /* Ende while      */
}                                               /* Ende haupt_prog */
/*************************************************/
/*                     main                       /
/*************************************************/
main()
{
     int i,x,y,w,h,event,wi_handle;
     int menu_id;
     appl_init();
     phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
     menu_id=menu_register(gl_apid,"  Star SG-10 Help");
     wind_get(0,4,&xdesk,&ydesk,&wdesk,&hdesk);
     rsrc_load("starhelp.rsc");
     rsrc_gaddr(0,STARMENU,&menu_tree);
     form_center(menu_tree,&x,&y,&w,&h);
     while(TRUE)
     {
          event=evnt_multi(MU_MESAG|MU_BUTTON|MU_KEYBD,
               1,1,1,0,0,0,0,0,0,0,0,0,0,
               mesag_buf,0,0,&mausx,&mausy,&dummy,&dummy,&dummy,&dummy);
          if(event&MU_MESAG)
          {
               switch(mesag_buf[0])
               {
                    case AC_OPEN:
                         if(mesag_buf[4]==menu_id)
                         {
                              for(i=0;i<10;int_in[i++]=1);
                              int_out[10]=2;
                              handle=phys_handle;
                              v_opnvwk(int_in,&handle,int_out);
                              wi_handle=wind_create(0,x,y,w,h);
                              wind_open(wi_handle,x,y,w,h);
                              haupt_prog();
                              wind_close(wi_handle);
                              wind_delete(wi_handle);
                              v_clsvwk(handle);
                         }
                    break;
               }                             /* Ende switch */
          }
     }                                       /* Ende while  */
}
