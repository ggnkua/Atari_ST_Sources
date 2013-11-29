/*........................ include header files ..............................*/

#include <vdibind.h>    /* VDI stuff */
#include <gemdefs.h>    /* AES stuff */
#include <obdefs.h>     /* more AES stuff */
#include <osbind.h>     /* GEMDOS, BIOS, XBIOS stuff */
#include <taddr.h>      /* OB macros */
#include <portab.h>     
#include <machine.h>    /* LW macros */
#include <cz_andrd.h>   /* created by RCS */
#include <defines.h>
#include <globals.h>

/* key command array */

int keycmds[96]={
0x1700,DESK,INFO,      0x1e01,FILE,ATOFILE,      0x3002,FILE,BTOFILE,
0x1312,FILE,RENAME,    0x2d18,FILE,ERASE,        0x2106,FILE,FORMAT, 
0x1e00,FILE,FILETOA,   0x3000,FILE,FILETOB,      0x1205,EDIT,BEGIN, 
0x3200,EDIT,MONITOR,   0x2e03,EDIT,COMPARE,      0x1200,EDIT,CPSWENVS,
0x260c,EDIT,CPSWLINE,  0x1615,EDIT,UNDOEDIT,     0x320d,OPTIONS,MIDICH, 
0x1f00,OPTIONS,BANK,   0x310e,OPTIONS,NAME,      0x1709,OPTIONS,INIT, 
0x1e61,OPTIONS,DROID,  0x2000,OPTIONS,DISTORT,   0x2308,OPTIONS,HARDCOPY,
0x1f13,OPTIONS,SAFETY, 0x1011,QUIT,QUITQUIT};
#define NKEYCMDS 23

int keylock=0;
int mlock=0;
int sequence=0;   /* copy-protection stuff */
int pro_pass;     /* copy-protection stuff */
int timebomb;     /* copy-protection stuff */
int Alock;        /* copy-protection stuff */
char secret[41]=    "Master Disk:                            ";
char copyright[39]= "CZ-Android, Copyright 1986 Tom Bajoras";
char chksync1[150]= "[2][Sync Box not connected.|";
#define CHKSYNC2   &"Select IGNORE if a CZ-Android|"
#define CHKSYNC3   &"Key disk is in drive A or B.]"
#define CHKSYNC4   &"[Retry|Ignore|Quit]"
char keypath[35]=   "A:\\SYNCBOX";
extern char wbatitl[],wbbtitl[],cztitl[];   /* window titles */
 
/*............................ main program ..................................*/

main()
{
   if (!startup())      /* if initialization succeeded, do body of program */
      czdroid();   
   finishup();          /* clean up stuff before exiting back to desktop */
} /* end main() */

/*........................... initialization .................................*/
 
startup()      /* return 0 for success, 1 for failure */
{
   int loc_intin[11],loc_out[57],event,key;
   int x1,x2,x3,x4,y1,y2;
   long *ramtest;
   register int i,no_box=1;

/* weird stuff related to copy-protection */
   weird();

/* initialize the workspace and both workbanks */
   strcpy(ws_dat,INITNAME);
   copybyte(initvoic,&ws_dat[17],135);
   for (i=0; i<16; i++)
   {
      strcpy(&wba_dat[17*i],INITNAME);
      strcpy(&wbb_dat[17*i],INITNAME);
      copybyte(initvoic,&wba_dat[272+135*i],135);
      copybyte(initvoic,&wbb_dat[272+135*i],135);
   }

/* not in edit mode */
   editmode= 0;
   editmon=  1;   /* edit monitoring defaults to on */

/* initialize the application */
   if ( appl_init() < 0 )
   {
      form_alert(1,BADINIT);
      return(1);
   }

/* can't run with TOS in RAM */
   ramtest= 0x5a60L;
   if (*ramtest == 0x9bcd2b6dL)
   {
      form_alert(1,BADRAM);
      return(1);
   }

/* get the global workstation handle */
   gl_hand= graf_handle(&dummy,&dummy,&dummy,&dummy);

/* open the workstation */
   for (i=0; i<10; i++)
      loc_intin[i]= 1;      /* all attributes are their default values */
   loc_intin[10]= 2;        /* raster coordinates */
   v_opnvwk(loc_intin,&gl_hand,loc_out);

/* which drive were we booted from? */
   drive= Dgetdrv();   /* = 0 or 1 (drive A or B) */

/* load the resource file */
   if (!rsrc_load(&"CZ_ANDRD.RSC"))
   {
      form_alert(1,BADRSRC);
      return(1);
   }

/* MTST users, check for Sync Box */
   keypath[0]= keypath[0]+drive;
   if (!Fsfirst(keypath,0))
   {
      strcat(chksync1,CHKSYNC2);
      strcat(chksync1,CHKSYNC3);
      strcat(chksync1,CHKSYNC4);
      while (no_box=plover())
      {
         i= form_alert(1,chksync1);
         if (i==3) return(1);
         if (i==2) break;
      }
   }         

/* part of copy-protection */
   if (no_box) Alock= alock();

/* change mouse cursor to an arrow */
   graf_mouse(0,0L);        

/* get screen resolution */
   if ( !(rez= Getrez()) )
   {
      form_alert(1,BADREZ);

/*** this code was to guard against beta-tester piracy...

      event= evnt_multi(MU_TIMER|MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,
             &dummy,500,0,&dummy,&dummy,&dummy,&dummy,&key,&dummy);    
      if (event & MU_TIMER) return(1);
      if (key != 0x6100) return(1);
      event= evnt_multi(MU_TIMER|MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,
             &dummy,500,0,&dummy,&dummy,&dummy,&dummy,&key,&dummy);    
      if (event & MU_TIMER) return(1);
      if (key != 0x6100) return(1);
      event= evnt_multi(MU_TIMER|MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,
             &dummy,500,0,&dummy,&dummy,&dummy,&dummy,&key,&dummy);    
      if (event & MU_TIMER) return(1);
      if (key != 0x6100) return(1);
      Cconws(secret);
      Crawcin();

      ***/

      return(1);      
   }

/* set up screen fdb */  
   scrfdb.fd_addr=0L;
   scrfdb.fd_w= 640;
   scrfdb.fd_h= 200*rez;
   scrfdb.fd_wdwidth= 40;
   scrfdb.fd_stand= 0;
   if (rez==1) 
      scrfdb.fd_nplanes= 2;
   else
      scrfdb.fd_nplanes= 1;
   saveptr= Malloc(32000L);

/* put up menu bar */
   rsrc_gaddr(R_TREE,CZMENU,&menuaddr);
   menu_bar(menuaddr,1);
   
/* calculate coordinates for the four windows */
   i= (640-4*WBWIDTH)/5;
   x1= i-12;                           /* WB A */
   x2= x1+WBWIDTH+i-3;                 /* WS   */
   x3= x2+WBWIDTH+i-29;                /* CZ   */
   x4= x3+WBWIDTH+i+4;                 /* WB B */
   y1= rez*((200-WBHEIGHT)/2 + 4);
   y2= rez*((200-WSHEIGHT)/2 + 4);

/* open the four windows */
   wba_hand= wind_create(WI_KIND,x1,y1,WBWIDTH+48,rez*WBHEIGHT);
   strcpy(wbatitl,&" Workbank A ");
   wind_set(wba_hand,WF_NAME,&wbatitl,0,0);
   wind_open(wba_hand,x1,y1,WBWIDTH+48,rez*WBHEIGHT);
   cz_hand= wind_create(WI_KIND,x3,y1,WBWIDTH,rez*WBHEIGHT);
   strcpy(cztitl,&" CZ Internal ");
   wind_set(cz_hand,WF_NAME,&cztitl,0,0);
   wind_open(cz_hand,x3,y1,WBWIDTH,rez*WBHEIGHT);
   wbb_hand= wind_create(WI_KIND,x4,y1,WBWIDTH+48,rez*WBHEIGHT);
   strcpy(wbbtitl,&" Workbank B ");
   wind_set(wbb_hand,WF_NAME,&wbbtitl,0,0);
   wind_open(wbb_hand,x4,y1,WBWIDTH+48,rez*WBHEIGHT);
   ws_hand= wind_create(WI_KIND,x2,y2,WBWIDTH+48,rez*WSHEIGHT);
   wind_set(ws_hand,WF_NAME," Workspace ",0,0);
   wind_open(ws_hand,x2,y2,WBWIDTH+48,rez*WSHEIGHT);
   
/* default CZ bank = internal bank, cz101/1000 */
   bankset= 0x20;
   syntype= 0;
   numtype= numtyp1;
   rsrc_gaddr(R_TREE,CZBANK,&bankaddr);
   sel_obj(bankaddr,INT1000);

/* default MIDI transmission channel = 1 */
   midi_ch= 0;    
   rsrc_gaddr(R_TREE,CZMIDI,&midiaddr);
   sel_obj(midiaddr,MIDI1);

/* default pathnames for next file to be erased, loaded, saved, etc. */
   strcpy(dir_def,"A:\\*.*");
   dir_def[0]= dir_def[0]+drive;   /* dir_def[0] is A or B */

/* default drive and side for formatting */
   rsrc_gaddr(R_TREE,CZFMT,&fmtaddr);
   sel_obj(fmtaddr,SIDE1);   
   if (drive)
      sel_obj(fmtaddr,DRIVEB);
   else
      sel_obj(fmtaddr,DRIVEA);

/* get pointers to trees which draw dialogs */
   rsrc_gaddr(R_TREE,CZINFO,&infoaddr);
   rsrc_gaddr(R_TREE,CZHELP,&helpaddr);
   rsrc_gaddr(R_TREE,CZSAFETY,&safeaddr);
   rsrc_gaddr(R_TREE,CZLINES,&lineaddr);
   rsrc_gaddr(R_TREE,CZENVS,&envsaddr);

/* default safety levels */
   sel_obj(safeaddr,ALLSSAFE);    saf_alls= 1;
   sel_obj(safeaddr,CZSAFE);      saf_cz= 1;
   desel_obj(safeaddr,ALLSAFE);   saf_x= 0;

/* default no active slot, topped window = WS window */
   act_slot= 0;
   top_hand= ws_hand;

/* get coords and size of desktop window */
   wind_get(0,WF_WORKXYWH,&work_x,&work_y,&work_w,&work_h);

/* successful return */
   return(0);
} /* end startup() */

/*................................. finishup .................................*/

finishup()
{
   menu_bar(menuaddr,0);   /* take down menu bar */
   v_clsvwk(gl_hand);      /* close the workstation */
   appl_exit();            /* clean up AES */
   unweird();              /* related to copy-protection */
}

/*............................ body of program ...............................*/

czdroid()
{
   int done=0;
   int event,mousex,mousey,mstate,kstate,top;
   int mbefore=0;
   int key,ntries;

/* loop until user requests quit */
   while (!done)
   {
      wind_get(dummy,WF_TOP,&top,&dummy,&dummy,&dummy);
      if (editmode)
      {
         vq_mouse(gl_hand,&mstate,&mousex,&mousey);
         kstate=Kbshift(0xffff);
         if ((mstate&3)&&!mbefore&&!mlock)
            ed_mouse(mousex,mousey,mstate,kstate);
         if (!mstate&&mlock) mlock=0;
         do_event();    /* copy-protection stuff */
         event= evnt_multi(MU_MESAG|MU_TIMER|MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,
                &messbuf,0,0,&mousex,&mousey,&dummy,&dummy,&key,&dummy);    
         if (event & MU_MESAG) 
            done= do_mesag();
         else
         {
            if (event & MU_KEYBD)
            {
               if (   (key==0x1205)&&(!keylock)&&(!menulock())   )
                  quitedit();
               else
               {
                  if (key==0x6100) 
                     ed_undo(mousex,mousey);
                  else
                     if (key && !mstate) done= do_key(key);
               } /* end if (   (key==0x1205)&&(!keylock)   ) */
            } /* end if (event & MU_KEYBD) */
         } /* end if (event & MU_MESAG) */
         mbefore=mstate;
      }
      else   /* not in edit mode */
      {
         do_event();   /* copy-protection stuff */
         event= evnt_multi(MU_MESAG|MU_BUTTON|MU_KEYBD,1,1,1,0,0,0,0,0,0,0,
               0,0,0,&messbuf,0,0,&mousex,&mousey,&mstate,&dummy,&key,&dummy);
         if (event & MU_BUTTON)
            do_mouse(mousex,mousey);
         else
         {
            if (event & MU_MESAG)
               done= do_mesag();
            else
               if (event & MU_KEYBD) done= do_key(key);
         }
      }
   } /* end while(!done) */

} /* end czdroid() */

/*............................. handle message ...............................*/

do_mesag() /* return 0 not done or 1 done */
{

   switch (messbuf[0])
   {
      case MN_SELECTED:
         wind_update(3);
         return(do_menu());
      case WM_REDRAW:
         redraw(messbuf[3],messbuf[4],messbuf[5],messbuf[6],messbuf[7]);
         if ((editmode==2)&&(messbuf[3]==ws_hand))    
         {                                        
            wind_set(messbuf[3],WF_TOP,0,0,0,0);   
            wind_update(2);
            keylock=0;
            editmode=1;
         }
         if ((editmode==3)&&(messbuf[3]==ws_hand))    
         {                                        
            wind_update(2);
            keylock=0;
            editmode=0;
         }
         return(0);
      case WM_TOPPED:
      case WM_NEWTOP:
         wind_set(messbuf[3],WF_TOP,0,0,0,0);
         undoslot();   /* clear active slot if there was one */
         top_hand= messbuf[3];
         return(0);
      case WM_MOVED:
         if ((editmode==0)||(editmode==1))
            wind_set(messbuf[3],WF_CURRXYWH,messbuf[4],messbuf[5],messbuf[6], 
                     messbuf[7]);
         return(0);
      case WM_CLOSED:
         quitedit();
         return(0);
   }  /* end switch(messbuf[0])  */
   return(0);   /* ignore illegal messages */
}   /* end do_mesag() */

/*............................. handle mouse click............................*/

do_mouse(mousex,mousey)
register int mousex,mousey;
{
   int x,y,w,h,x2,y2,w2,h2;
   int state;
   int slot1,slot2,window2;
   int box_x,box_y,box_w,box_h;
   int new_x,new_y;
   long tree;

/* if mouse clicked over desktop, deactivate active slot (if there is one) */
   window2= wind_find(mousex,mousey);
   if (!window2)
   {   undoslot();   return;   }

/* if mouse clicked outside of top window that's none of our business */
   wind_get(top_hand,WF_WORKXYWH,&x,&y,&w,&h); 
   if ((mousex<x)||(mousex>(x+w))||(mousey<y)||(mousey>(y+h))) return;

/* if mouse clicked inside top window: get slot # clicked, deactivate any
   other slot and activate the clicked slot, but don't change active pointer
   or menu items yet.  Define box for moving box which will track mouse. */

   if (top_hand == ws_hand) 
   {
      slot1=1;
      box_x=x; box_y=y; box_w=w; box_h=h;
   }
   else
   {
      slot1= getslot(y,h,mousey,&box_y,&box_h);
      box_x=x; box_w=w;
   }
   if ((syntype==3)&&(slot1>4)&&(slot1<17)) return(form_alert(1,BAD230S));

   if (slot1 != act_slot)
   {
      if (act_slot) deact_slot(top_hand,act_slot);
      activ_slot(top_hand,slot1);         
   }

/* dragging */  
   vq_mouse(gl_hand,&state,&new_x,&new_y);
   if (state&1)
   {
      graf_dragbox(box_w,box_h,box_x+new_x-mousex,box_y+new_y-mousey,
                   work_x,work_y,work_w,work_h,&dummy,&dummy);
      vq_mouse(gl_hand,&dummy,&new_x,&new_y);
   }
   else
   {   new_x= mousex;  new_y= mousey;   }

/* get slot under where mouse button went up */
   window2= wind_find(new_x,new_y);
   if ((window2)&&(window2!=ws_hand)&&(window2!=wba_hand)
     &&(window2!=wbb_hand)&&(window2!=cz_hand))
   {
      form_alert(1,BADCPY2);
      deact_slot(top_hand,slot1);
      undoslot();
      return;
   }
   if (window2) 
   {
      if (window2 == ws_hand)
         slot2= 1;
      else
      {
         wind_get(window2,WF_WORKXYWH,&x2,&y2,&w2,&h2); 
         slot2= getslot(y2,h2,new_y,&dummy,&dummy);
      }
      if ((syntype==3)&&(slot2>4)&&(slot2<17))
      {  
         form_alert(1,BAD230S);
         deact_slot(top_hand,slot1);
         undoslot();
         return;
      }
   }
   if ((!window2) || ((window2==top_hand)&&(slot1==slot2)) )
   {
      if (slot1==act_slot) 
         undoslot();
      else
      {
         act_slot= slot1;
         act_menu(top_hand,slot1);
      }
   }
   else
   {
      if (   !do_copy(top_hand,slot1,window2,slot2)
             && (window2!=cz_hand) && (slot2!=17)      )
      {                                        /* flash the destination slot */
         activ_slot(window2,slot2);
         deact_slot(window2,slot2);
      }
      deact_slot(top_hand,slot1);
      undoslot();
   }
} /* end do_mouse(mousex,mousey) */       

/*.......................... process key commands ............................*/

do_key(key)          /* returns 0 not done, 1 for done */
register int key;
{
   int i;
   long tree=menuaddr;  /* needed by OB macros */

/* locked out */
   if (keylock) return(0);
   if (menulock()) return(0);

   for (i=0; i<NKEYCMDS; i++)
   {
      if (key==keycmds[3*i])
      {
         if (LWGET(OB_STATE(keycmds[3*i+2])) & DISABLED) return(0);
         messbuf[3]=keycmds[3*i+1];   messbuf[4]=keycmds[3*i+2];
         wind_update(3);
         return(do_menu());
      }
   }
   if (key==0x6200)
   {
      wind_update(3);
      do_help();
      wind_update(2);
   }
   return(0);
} /* end do_key(key) */

/*.......................... process menu choice .............................*/

do_menu()   /* return 1 for quit, 0 for any other menu choice or aborted quit */
{
   int exit_obj,state;

/* de-highlight the selected menu title */
      menu_tnormal(menuaddr,messbuf[3],1);
/* wait for mouse button to be released */
   state=1;
   while(state&1) graf_mkstate(&dummy,&dummy,&state,&dummy);
   if ((editmode==2)||(editmode==3))
   {
      wind_update(2);
      return(0);
   }
/* branch according to the menu choice */
      switch (messbuf[3])
      {
         case DESK :
            info();
            wind_update(2);
            return(0);
         case FILE :
            switch (messbuf[4])
            {
               case FILETOA : filetoa(); break;
               case FILETOB : filetob(); break;
               case ATOFILE : atofile(); break;
               case BTOFILE : btofile(); break;
               case RENAME  : rename();  break;
               case ERASE   : erase();   break;
               case FORMAT  : format();  break;
            }
            wind_update(2);
            return(0);
         case EDIT :
            switch (messbuf[4])
            {
               case BEGIN    : edit(); keylock=1; return(0);
               case MONITOR  : monitor();  break;
               case COMPARE  : compare();  break;
               case CPSWENVS : cpswenvs(); break;
               case CPSWLINE : cpswline(); break;
               case UNDOEDIT : undoedit(); break;
               case CZ1PARS  : cz1pars(); mlock=1; break;
            }   
            wind_update(2);
            return(0);
         case OPTIONS :
            switch (messbuf[4])
            {
               case MIDICH   : midich();   break;
               case BANK     : czbank();   break;
               case NAME     : name();     break;
               case INIT     : init();     break;
               case DISTORT  : distort();  break;
               case DROID    : droid();    break;
               case HARDCOPY : 
                  if (act_slot==17)
                     hardlist();
                  else
                     hardcopy(); 
                  break;
               case SAFETY   : safety();   break;
            }
            wind_update(2);
            return(0);
         case QUIT :
            wind_update(2);
            if (form_alert(1,CHEKQUIT) != 1) return(1);
            return(0);
      } /* end switch(messbuf[3]); */
 }  /* end do_menu() */

/*.......................... process copy command.............................*/

do_copy(w1,s1,w2,s2)         /* returns 1 error, 0 ok */
register int w1,s1,w2,s2;
{

   int i,errflag;
   char *fromdat,*fromnam,*todat,*tonam;
   
/* error trapping for illegal copy requests */
   if ((s1==17)&&(s2<17))
   {
      form_alert(1,BADCPY1); return(1);
   }

/* do safety check */
   if (    (saf_x) || ((saf_alls)&&(s2==17)) || ((saf_cz)&&(w2==cz_hand))   )
   {
      if (form_alert(1,CHEKSAFE) == 2) return(1);
   }

   if ((w1==cz_hand) || (w2==cz_hand)) graf_mouse(255,&midijack);
   errflag= 1;  /* default: there's an error, don't update screen */

/* 1-to-1 copies and 1-to-16 copies */
   if (s1<17)  /* set up from areas */
   {
      if (w1==cz_hand)
      {
         if (getsyn(s1,tempbuf,diskbuf))
            goto endcopy;
         else
         {
            fromdat= &tempbuf[0];
            fromnam= &diskbuf[0];
         }
      }
      if (w1==ws_hand)
      {
         fromdat= &ws_dat[17];
         fromnam= &ws_dat[0];
      }
      if (w1==wba_hand)
      {
         fromdat= &wba_dat[272+135*(s1-1)];
         fromnam= &wba_dat[17*(s1-1)];
      }
      if (w1==wbb_hand)
      {
         fromdat= &wbb_dat[272+135*(s1-1)];
         fromnam= &wbb_dat[17*(s1-1)];
      }

      if (s2<17)      /* 1-to-1 copies */
      {
         if (w2==cz_hand)
            putsyn(s2,fromdat,fromnam);
         else
         {
            if (w2==ws_hand)
            {
               todat= &ws_dat[17];
               tonam= &ws_dat[0];
            }
            if (w2==wba_hand)
            {
               todat= &wba_dat[272+135*(s2-1)];
               tonam= &wba_dat[17*(s2-1)];
            }
            if (w2==wbb_hand)
            {
               todat= &wbb_dat[272+135*(s2-1)];
               tonam= &wbb_dat[17*(s2-1)];
            }
            strcpy(tonam,fromnam);
            copybyte(fromdat,todat,135);
         } /* end if (w2==cz_hand) */
      } /* end if (s2<17) */
      if (s2==17)    /* 1-to-16 copies */
      {
         if (w2==cz_hand)
         {
            for (i=1; i<17; i++)
               if (putsyn(i,fromdat,fromnam)) goto endcopy;
         }
         if (w2==wba_hand)
         {
            for (i=0; i<16; i++)
            {
               strcpy(&wba_dat[17*i],fromnam);
               copybyte(fromdat,&wba_dat[272+135*i],135);
            }
         }               
         if (w2==wbb_hand)
         {
            for (i=0; i<16; i++)
            {
               strcpy(&wbb_dat[17*i],fromnam);
               copybyte(fromdat,&wbb_dat[272+135*i],135);
            }
         }               
      } /* end if (s2==17) */
   } /* end if (s1<17) */   

/* 16-to-16 copies */
   if ((s1==17)&&(s2==17))
   {
      if (w1==cz_hand)
      {
         if (getall(tempbuf,diskbuf))
            goto endcopy;
         else
         {
            fromdat= &tempbuf[0];
            fromnam= &diskbuf[0];
         }
      }
      if (w1==wba_hand)
      {
         fromdat= &wba_dat[272];
         fromnam= &wba_dat[0];
      }
      if (w1==wbb_hand)
      {
         fromdat= &wbb_dat[272];
         fromnam= &wbb_dat[0];
      }
      if (w2==cz_hand) putall(fromdat,fromnam);
      if (w2==wba_hand)
      {
         copybyte(fromnam,&wba_dat[0],272);
         copybyte(fromdat,&wba_dat[272],2160);
      }
      if (w2==wbb_hand)
      {
         copybyte(fromnam,&wbb_dat[0],272);
         copybyte(fromdat,&wbb_dat[272],2160);
      }
   } /* end if ((s1==17)&&(s2==17)) */   
   errflag= 0;   /* no error occurred */
      
endcopy:   
   if ((w1==cz_hand) || (w2==cz_hand)) graf_mouse(0,0L);

/* update screen */
   if ((w2 != cz_hand)&&(!errflag)) update(w2,s2);

/* ok return */
   return(errflag);

} /* end do_copy(w1,s1,w2,s2) */

/*............................. menu lock out ................................*/

menulock()   /* returns 1 if interacting with a menu, else 0 */
{
   long tree=menuaddr;  /* needed by OB macros */

   if (     (LWGET(OB_STATE(DESK)) & SELECTED) 
          ||(LWGET(OB_STATE(FILE)) & SELECTED) 
          ||(LWGET(OB_STATE(EDIT)) & SELECTED) 
          ||(LWGET(OB_STATE(OPTIONS)) & SELECTED)
          ||(LWGET(OB_STATE(QUIT)) & SELECTED)          ) return(1);
   return(0);
} /* end menulock() */

/* EOF */
