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
#include <externs.h>

long pageptr;
int prntrow;
char demomark[9]= "demoflag";
int demoflag=0;
char wbatitl[25],wbbtitl[25],cztitl[25];
char hardtitl[40];
extern int Ndiffer;
extern char ednorm[];
extern int sequence;   /* related to copy-protection */

/*...................... process menu choice = info ..........................*/

info()
{
   do_dial(infoaddr,CZINFO,-1);   /* copyright dialog */
}

/*...................... process menu choice = help ..........................*/

do_help()
{
   do_dial(helpaddr,CZHELP,-1);   /* help dialog */
}

/*...................... process menu choice = cz bank .......................*/

czbank()
{
   int exit_obj,new,old;
   long tree=bankaddr; /* tree needed by macros */
   long *newtype;

   old= whichbnk();
   exit_obj= do_dial(bankaddr,CZBANK,-1);  /* cz bank dialog */
   new= whichbnk();

   if (exit_obj == CANBANK)
   {
      desel_obj(bankaddr,new);  
      sel_obj(bankaddr,old);
      return;               
   }
   if (new==old) return;
   undoslot();       /* guard against illegal 230S condition */
/* new cz window title */
   if (new==CZ230S)
      strcpy(cztitl,&" CZ-230S ");
   else
   {
      if ((new==PRE1000)||(new==PRE3000A)||(new==PRE3000C))
          strcpy(cztitl,&" CZ Presets ");
      else
      {
         if (new==CRT1000)
            strcpy(cztitl,&" CZ Cartridge ");
         else
            strcpy(cztitl,&" CZ Internal ");
      }
   }
   wind_set(cz_hand,WF_NAME,&cztitl,0,0);
/* set bankset */
   if ((new==PRE1000)||(new==PRE3000A)||(new==INT1A)) bankset=0;
   if ((new==PRE3000C)||(new==INT1C)) bankset=0x10;
   if ((new==INT1000)||(new==INT3000A)||(new==INT1E)) bankset=0x20;
   if ((new==INT3000C)||(new==INT1G)) bankset=0x30;
   if (new==CRT1000) bankset=0x40;
   if (new==CZ230S) bankset=0x60;
/* set syntype */
   if ((new==PRE1000)||(new==INT1000)||(new==CRT1000)) syntype=0;
   if ((new==PRE3000A)||(new==PRE3000C)
     ||(new==INT3000A)||(new==INT3000C)) syntype=1;
   if ((new==INT1A)||(new==INT1C)||(new==INT1E)||(new==INT1G)) syntype=2;
   if (new==CZ230S) syntype=3;
/* set numtype */
   if (syntype==0) newtype=numtyp1;
   if ((new==PRE3000A)||(new==INT3000A)||(new==INT1A)) newtype=numtyp2;
   if ((new==PRE3000C)||(new==INT3000C)||(new==INT1C)) newtype=numtyp3;
   if (new==INT1E) newtype=numtyp4;
   if (new==INT1G) newtype=numtyp5;
   if (new==CZ230S) newtype=numtyp6;
/* modify send/request commands */
   if (syntype==2)
   {   fromcz1[5]= 0x11;   tocz1[5]= 0x21;   }
   else
   {   fromcz1[5]= 0x10;   tocz1[5]= 0x20;   }

/* if numtype is about to change, redraw windows except ws window */
   if (newtype != numtype)
   {
      numtype=newtype;
      redraw(cz_hand,0,0,0,0);
      redraw(wba_hand,0,0,0,0);
      redraw(wbb_hand,0,0,0,0);
   }

} /* end czbank() */

/*............... process menu choice = atofile or btofile ...................*/

atofile()
{
   if (demoflag) return(form_alert(1,BADDEMO));
   if (sequence!=3) return(form_alert(1,BADDEMO));
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,">>> WB A --> File");
   xtofile(&wba_dat);
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,"                 ");
}
  
btofile()
{ 
   if (demoflag) return(form_alert(1,BADDEMO));
   if (sequence!=3) return(form_alert(1,BADDEMO));
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,">>> WB B --> File");
   xtofile(&wbb_dat);
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,"                 ");
}

xtofile(wbptr)
char *wbptr;
{
   long error;
   int filehand,exit_obj;

   strcpy(dir_temp,dir_def);   /* set up default pathname to be saved */
   file_temp[0]= '\0';
   if (!fsel_input(&dir_temp,&file_temp,&exit_obj)) return;   /* get pathname */
   if (exit_obj)   /* if OK button clicked */
   {
      strcpy(dir_def,dir_temp);   /* save directory for next time */
      combine(dir_temp,file_temp);  /* dir_temp will contain pathname */
      graf_mouse(2,0L);
      error= Fopen(dir_temp,2);      /* try to open file */
      if (error<0L)                 /* if could not open file */
      {
         error= Fcreate(dir_temp,0);  /* try to create the file */
         if (error<0L)               /* if could not create file */
         {
           graf_mouse(0,0L);
           form_alert(1,BADCREAT);
           return;
         }
      }
      else
         if (form_alert(1,CHEKREPL) == 1) return;
      filehand=error;
      filehand= filehand+get_tr();  /* handle for created and/or opened file */
      graf_mouse(2,0L);
      copybyte(filecode,diskbuf,sequence+1);  /* note: sequence+1= 4 */
      copybyte(wbptr,&diskbuf[sequence+1],2432);
      error= Fwrite(filehand,2436L,diskbuf);   /* write the file */
      graf_mouse(0,0L);
      if (error != 2436L) form_alert(1,BADWRITE);
      Fclose(filehand);       /* close file */
   }  /* end if exit_obj */
}  /* end xtofile() */   

/*............... process menu choice = format disk ..........................*/

format()
{
   int driveno,sideno;
   register int trackno,i;
   long tree;
   int x,y,w,h;
   int xslide,yslide;
   int xyarray[10];
   int error;

   if (form_alert(1,CHEKFMT) == 1) return;
   if (do_dial(fmtaddr,CZFMT,-1) == CANFMT) return;
   tree= fmtaddr;
   if (LWGET(OB_STATE(DRIVEA)) & SELECTED)
      driveno= 0;
   else
      driveno= 1;
   if (LWGET(OB_STATE(SIDE1)) & SELECTED)
      sideno= 0;
   else
      sideno= 1;
   
   rsrc_gaddr(R_TREE,FMTTHING,&tree);
/* get coordinates to center the dialog box */
   form_center(tree,&x,&y,&w,&h);
/* save the screen which will lie under the box */
   form_dial(0,0,0,0,0,x,y,w,h);
/* put up the box */
   objc_draw(tree,ROOT,MAX_DEPTH,x,y,w,h);
/* calculate x- and y-coords for slider box */
   xslide= x+(w-242)/2-1;
   yslide= y+(h/2)+((h/2)-12*rez)/2;
/* draw slider box outline */
   xyarray[0]= xslide;
   xyarray[1]= yslide;
   xyarray[2]= xslide+242;
   xyarray[3]= yslide;
   xyarray[4]= xslide+242;
   xyarray[5]= yslide+10*rez;
   xyarray[6]= xslide;
   xyarray[7]= yslide+10*rez;
   xyarray[8]= xslide;
   xyarray[9]= yslide;
   set_clip(xslide,yslide,243,12*rez);
   v_hide_c(gl_hand);   
   v_pline(gl_hand,5,xyarray);
/* busybee mouse */
   graf_mouse(2,0L);   
   v_show_c(gl_hand);

/* do it, check for errors along the way */
   trackno= 0;
   error= 0;
   vsf_color(gl_hand,1);
   vsf_interior(gl_hand,2);   /* use a fill pattern */
   vsf_style(gl_hand,2);      /* the pattern to be used */
   vsf_perimeter(gl_hand,0);  /* no outline for filled areas */
   xyarray[0]= xslide+1;
   xyarray[1]= yslide;
   xyarray[3]= yslide;
   xyarray[5]= yslide+10*rez;
   xyarray[7]= yslide+10*rez;
   while ( (trackno<80) && !error)
   {
     for (i=0; i<=sideno; i++)
        error= Flopfmt(&diskbuf,0L,driveno,9,trackno,i,1,0x87654321L,0xe5e5);
     trackno++;
     xyarray[2]= xyarray[0]+3;
     xyarray[4]= xyarray[2];
     xyarray[6]= xyarray[0];
     v_hide_c(gl_hand);
     v_fillarea(gl_hand,4,xyarray);
     v_show_c(gl_hand);
     xyarray[0]= xyarray[0]+3;
   } /* end while */
   if (!error)
   {
      for (i=0; i<8192; i++) diskbuf[i]= 0;
      error= Flopwr(&diskbuf,0L,driveno,1,0,0,9);  
      if (!error)
      {
         error= Flopwr(&diskbuf,0L,driveno,1,1,0,9);  
         if (!error)
         {
           if (sideno)
              Protobt(&diskbuf,0x01000000,3,0);
           else
              Protobt(&diskbuf,0x01000000,2,0);
           error= Flopwr(&diskbuf,0L,driveno,1,0,0,1);
         }
      }
   }
/* arrow mouse */
   graf_mouse(0,0L);
/* restore the screen */
   form_dial(3,0,0,0,0,x,y,w,h);   
/* handle error */
   if (error) form_alert(1,BADFMT);
} /* end format() */

/*............... process menu choice = rename a file ........................*/

rename()
{
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,">>> Rename File");
   rrname();
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,"               ");
} /* end rename() */

rrname()
{
   long tree;
   int x,y,w,h;
   int exit_obj;
   long old_addr,new_addr;
   long error;
   int filehand;
   char newname[13];
   char newpath[52];
   
   strcpy(dir_temp,dir_def);   /* set up default directory to be renamed */
   file_temp[0]= '\0';
   if (!fsel_input(&dir_temp,&file_temp,&exit_obj)) return;  /* get pathname */
   if (!exit_obj) return;   /* if cancel button */
   strcpy(dir_def,dir_temp);   /* save directory for next time */
   combine(dir_temp,file_temp);  /* dir_temp will contain old pathname */
   error= Fopen(dir_temp,2);      /* try to open file */
   if (error<0L)                 /* if could not open file */
      form_alert(1,BADOPEN);
   else
   {
      filehand= error;
      Fclose(filehand);       /* close file */
      rsrc_gaddr(R_TREE,CZNAME,&tree);
      LLSET(OB_SPEC(OLDNAME),&file_temp);  
      new_addr= LLGET(OB_SPEC(NEWNAME));
      LLSET(new_addr,&newname);      /* newname field contains new file name */
      LWSET(TE_TXTLEN(new_addr),13);  /* length of newname field */
      strcpy(newname,"____________");  /* default newname */
      
      exit_obj= do_dial(tree,CZNAME,NEWNAME);
      if (exit_obj == OKNAME)
      {
         lc_to_uc(newname);
         if (filehand=parsfil(newname))   /* re-use filehand variable */
         {
            if (filehand==1) form_alert(1,BADFNM1);
            if (filehand==2) form_alert(1,BADFNM2);
            if (filehand==3) form_alert(1,BADFNM3);
            if (filehand==4) form_alert(1,BADFNM4);
            if (filehand==5) form_alert(1,BADFNM5);
            if ((filehand==6)||(filehand==7)) form_alert(1,BADFNM6);
         }
         else
         {
            strcpy(newpath,dir_def);
            combine(newpath,newname);   /* newpath contains new pathname */
            graf_mouse(2,0L);
            error= Frename(0,dir_temp,newpath);  /* try to rename */
            graf_mouse(0,0L);
            if (error) form_alert(1,BADRENAM);
         } /* end if(parserr) */
      }  /* end if (exit_obj == OKNAME) */
   } /* end if(error<0L) */
} /* end rrname() */

/*................... process menu choice = name something ...................*/

name()
{
   int x,y,w,h,state;
   long tree,new_addr;
   char newname[17],cmdline[40];
   int def_exit,not_exit;

   rsrc_gaddr(R_TREE,CZNAM,&tree);

/* set up pointer to newname field */
   new_addr= LLGET(OB_SPEC(XNEWNAM));
   LLSET(new_addr,&newname);      /* newname field contains new name */
   LWSET(TE_TXTLEN(new_addr),17);  /* length of newname field */

/* set up command line */
   if (top_hand==ws_hand)
   {
       strcpy(cmdline,&"Name Workspace");
       LLSET(OB_SPEC(XOLDNAM),&ws_dat);       
       strcpy(newname,ws_dat);  
       unhide_obj(tree,OLDNAM);
       unhide_obj(tree,XOLDNAM);
   }

   if (act_slot==17)
   {
      if (top_hand==wba_hand) strcpy(cmdline,&"Name all Workbank A slots");
      if (top_hand==wbb_hand) strcpy(cmdline,&"Name all Workbank B slots");
      hide_obj(tree,OLDNAM);
      hide_obj(tree,XOLDNAM);
      strcpy(newname,NONAME);                    /* default newname */
      def_exit= CANNAM;
      not_exit= OKNAM;
   }
   else
   {
      def_exit= OKNAM;
      not_exit= CANNAM;
   }
   state= LWGET(OB_FLAGS(def_exit));         
   LWSET(OB_FLAGS(def_exit),state | DEFFAULT);
   state= LWGET(OB_FLAGS(not_exit));
   LWSET(OB_FLAGS(not_exit),state & ~DEFFAULT);

   if ((top_hand != ws_hand)&&(act_slot<17))
   {
      unhide_obj(tree,OLDNAM);
      unhide_obj(tree,XOLDNAM);
      if (top_hand==wba_hand) 
      {
         strcpy(cmdline,&"Name Workbank A slot ");
         LLSET(OB_SPEC(XOLDNAM),&wba_dat[17*(act_slot-1)]);
         strcpy(newname,&wba_dat[17*(act_slot-1)]);
      }
      if (top_hand==wbb_hand)
      {
         strcpy(cmdline,&"Name Workbank B slot ");
         LLSET(OB_SPEC(XOLDNAM),&wbb_dat[17*(act_slot-1)]);
         strcpy(newname,&wbb_dat[17*(act_slot-1)]);
      }
      strcat(cmdline,*numtype+3*(act_slot-1));
   }
   LLSET(OB_SPEC(CMDNAM),&cmdline);

   if (do_dial(tree,CZNAM,XNEWNAM)==CANNAM) return;

/* execute the name request */
   do_name(newname);   /* note: this has no effect on a cz slot */
   
/* update screen */
   if (top_hand != cz_hand) update(top_hand,act_slot);

} /* end name() */   

/*................... process menu choice = init something ...................*/

init()
{
register int i;

/* edit mode */
   if (editmode)
   {
      copybyte(initvoic,ednorm,135);
      Ndiffer= ndiffer();
      monedit(ednorm);
      redraw(ws_hand,0,0,0,0);
      return;
   }

/* do safety check */
   if (    (saf_x) ||
      ((saf_alls)&&(act_slot==17)) ||
      ((saf_cz)&&(top_hand==cz_hand))   )
   {
      if (form_alert(1,CHEKSAFE) == 2) return;
   }

   if (top_hand==cz_hand) graf_mouse(255,&midijack);

   if (top_hand==ws_hand) copybyte(initvoic,&ws_dat[17],135);
   if (top_hand==cz_hand)
   {
      if (act_slot<17)
         putsyn(act_slot,&initvoic[0],INITNAME);
      else
      {
         for (i=1; i<17; i++)
            if (   putsyn(i,&initvoic[0],INITNAME)   ) break;
      }
   }
   if (top_hand==wba_hand)
   {
      if (act_slot<17)
         copybyte(&initvoic[0],&wba_dat[272+135*(act_slot-1)],135);
      else
      {
         for (i=0; i<16; i++)
            copybyte(&initvoic[0],&wba_dat[272+135*i],135);
      }
   }
   if (top_hand==wbb_hand)
   {
      if (act_slot<17)
         copybyte(&initvoic[0],&wbb_dat[272+135*(act_slot-1)],135);
      else
      {
         for (i=0; i<16; i++)
            copybyte(&initvoic[0],&wbb_dat[272+135*i],135);
      }
   }

   if (top_hand==cz_hand) graf_mouse(0,0L);

/* initialize the name(s) */
   if (top_hand!=cz_hand) do_name(INITNAME);

/* update screen */
   if (top_hand != cz_hand) update(top_hand,act_slot);

} /* end init() */

/*................... process menu choice = distort something ................*/

distort()
{ 
   register int i;

/* edit mode */
   if (editmode)
   {
      do_dist(ednorm);
      Ndiffer= ndiffer();
      monedit(ednorm);
      redraw(ws_hand,0,0,0,0);
      return;
   }

/* do safety check */
   if (    (saf_x) ||
      ((saf_alls)&&(act_slot==17)) ||
      ((saf_cz)&&(top_hand==cz_hand))   )
   {
      if (form_alert(1,CHEKSAFE) == 2) return;
   }

   if (top_hand==cz_hand) graf_mouse(255,&midijack);

/* distort the target data */
   if (top_hand==cz_hand)
   {
      if (act_slot<17)
      {
         if (!getsyn(act_slot,&tempbuf,&diskbuf))
         {
            do_dist(&tempbuf);
            putsyn(act_slot,&tempbuf,DISTNAME);
         }
      }
      else
      {
         if (!getall(&tempbuf,&diskbuf))
         {
            for (i=0; i<16; i++) do_dist(&tempbuf[135*i]);
            for (i=0; i<16; i++) copybyte(DISTNAME,&diskbuf[17*i],17);
            putall(&tempbuf,&diskbuf);
         }
      }
   } /* end if (top_hand==cz_hand) */
   if (top_hand==ws_hand) do_dist(&ws_dat[17]);
   if (top_hand==wba_hand)
   {
      if (act_slot<17)
         do_dist(&wba_dat[272+135*(act_slot-1)]);
      else
         for (i=0; i<16; i++) do_dist(&wba_dat[272+135*i]);
   }
   if (top_hand==wbb_hand)
   {
      if (act_slot<17)
         do_dist(&wbb_dat[272+135*(act_slot-1)]);
      else
         for (i=0; i<16; i++) do_dist(&wbb_dat[272+135*i]);
   }
      
   if (top_hand==cz_hand) graf_mouse(0,0L);

/* distort the name(s) */
   if (top_hand!=cz_hand) do_name(DISTNAME); 

/* update screen */
   if (top_hand != cz_hand) update(top_hand,act_slot);

} /* end distort() */

/*................... process menu choice = droid something ..................*/

droid()
{
   register int i;

/* edit mode */
   if (editmode)
   {
      do_droid(ednorm);
      Ndiffer= ndiffer();
      monedit(ednorm);
      redraw(ws_hand,0,0,0,0);
      return;
   }
/* do safety check */
   if (    (saf_x) ||
      ((saf_alls)&&(act_slot==17)) ||
      ((saf_cz)&&(top_hand==cz_hand))   )
   {
      if (form_alert(1,CHEKSAFE) == 2) return;
   }

   if (top_hand==cz_hand) graf_mouse(255,&midijack);

/* randomize the target data */
   if (top_hand==cz_hand)
   {
      if (act_slot<17)
      {
         do_droid(&tempbuf);
         putsyn(act_slot,&tempbuf,DROIDNAM);
      }
      else
      {
         for (i=0; i<16; i++) do_droid(&tempbuf[135*i]);
         for (i=0; i<16; i++) copybyte(DROIDNAM,&diskbuf[17*i],17);
         putall(&tempbuf,&diskbuf);
      }
   } /* end if (top_hand==cz_hand) */
   if (top_hand==ws_hand) do_droid(&ws_dat[17]);
   if (top_hand==wba_hand)
   {
      if (act_slot<17)
         do_droid(&wba_dat[272+135*(act_slot-1)]);
      else
         for (i=0; i<16; i++) do_droid(&wba_dat[272+135*i]);
   }
   if (top_hand==wbb_hand)
   {
      if (act_slot<17)
         do_droid(&wbb_dat[272+135*(act_slot-1)]);
      else
         for (i=0; i<16; i++) do_droid(&wbb_dat[272+135*i]);
   }

   if (top_hand==cz_hand) graf_mouse(0,0L);

/* droid the name(s) */
   if (top_hand!=cz_hand) do_name(DROIDNAM);  

/* update screen */
   if (top_hand != cz_hand) update(top_hand,act_slot);

} /* end droid() */

/*................... process menu choice = hardcopy something ...............*/

hardcopy()
{ 

/* hardcopy the target data */
   if (top_hand==cz_hand)
   {
      if (!getsyn(act_slot,&tempbuf,&hardtitl)) do_hard(&tempbuf,&hardtitl);
   }
   if (top_hand==ws_hand) do_hard(&ws_dat[17],&ws_dat[0]);
   if (top_hand==wba_hand) 
      do_hard(&wba_dat[272+135*(act_slot-1)],&wba_dat[17*(act_slot-1)]);
   if (top_hand==wbb_hand) 
      do_hard(&wbb_dat[272+135*(act_slot-1)],&wbb_dat[17*(act_slot-1)]);
} /* end hardcopy() */

do_hard(area,defname)
char area[];   /* 135 bytes */
char defname[];   /* 17 bytes */
{
   int i,j,k,kk;
   long tree,headaddr;
   char heading[41];
   char alertstr[160];

   for (i=0; i<=4239; i++) diskbuf[i]=0;   
   rsrc_gaddr(R_TREE,CZHARD,&tree);

/* set up pointer to heading field */
   headaddr= LLGET(OB_SPEC(NAMEHARD));
   LLSET(headaddr,&heading);      /* heading field contains heading */
   LWSET(TE_TXTLEN(headaddr),41);  /* length of heading field */
   strcpy(heading,defname);        /* heading field contains default name */

   if (do_dial(tree,CZHARD,NAMEHARD)==CANHARD) return;
/* check heading for unprintable characters */
   for (i=0; i<=40; i++)
   {
      if (!heading[i]) break;   /* all OK */
      if ((heading[i] < 0x20) || (heading[i] >= 0x7f))
      {
         strcpy(alertstr,&"[1][This title contains characters|");
         strcat(alertstr,&"which may have undesired|");
         strcat(alertstr,&"effects on the printer.][Cancel|OK]");
         if (form_alert(1,alertstr) == 1) return;
         break;      /* continue despite unprintable characters */
      }
   }  /* end for */
/* center heading within first line of page image */
   i=strlen(heading);
   strcpy(&diskbuf[(80-i)/2],heading);
/* construct template */
   strcpy(&diskbuf[324],&"Line");
   strcpy(&diskbuf[343],&"/------Detune------\\");
   strcpy(&diskbuf[365],&"/------Vibrato------\\");
   strcpy(&diskbuf[388],&"/-Octave-\\");
   strcpy(&diskbuf[403],&"Select");
   strcpy(&diskbuf[411],&"Modulation");
   strcpy(&diskbuf[423],&"+/- Octave Note Fine");
   strcpy(&diskbuf[445],&"Wave Delay Rate Depth");
   strcpy(&diskbuf[468],&"+/-  Range");
   strcpy(&diskbuf[642],&"----------------- 1 -----------------");
   strcpy(&diskbuf[682],&"----------------- 2 -----------------");
   strcpy(&diskbuf[883],&"DCO 1");     strcpy(&diskbuf[923],&"DCO 2");
   strcpy(&diskbuf[1923],&"DCW 1");    strcpy(&diskbuf[1963],&"DCW 2");
   strcpy(&diskbuf[2803],&"DCA 1");     strcpy(&diskbuf[2843],&"DCA 2");
   strcpy(&diskbuf[3600],&"CZ-1 Parameters:");
   strcpy(&diskbuf[4000],&"----------------------------------------");
   strcpy(&diskbuf[4040],&"----------------------------------------");
   strcpy(&diskbuf[4160],&"Comments:");
   for (i=0; i<=40; i=i+40)
   {
      strcpy(&diskbuf[1057+i],&"Waveform");
      strcpy(&diskbuf[1134+i],&"First   Second");
      strcpy(&diskbuf[1374+i],&"Envelope (Pitch)");
      strcpy(&diskbuf[2254+i],&"Envelope (Wave)");
      strcpy(&diskbuf[3134+i],&"Envelope (Amp)");
      strcpy(&diskbuf[2094+i],&"Key Follow:");
      strcpy(&diskbuf[2974+i],&"Key Follow:");
      strcpy(&diskbuf[3760+i],&"Level   /-------- Velocity --------\\");
      strcpy(&diskbuf[3848+i],&"amp:     wave:     pitch:");
      for (j=0; j<=1760; j=j+880)
      {
         strcpy(&diskbuf[1448+i+j],&"Step: 1  2  3  4  5  6  7  8");
         strcpy(&diskbuf[1528+i+j],&"Rate:");
         strcpy(&diskbuf[1607+i+j],&"Level:");
         strcpy(&diskbuf[1685+i+j],&"sus/end:");
      }
   } /* end for */

/* encode area into template */
   if (area[0]==0) strcpy(&diskbuf[484],&" 1  ");
   if (area[0]==1) strcpy(&diskbuf[484],&" 2  ");
   if (area[0]==2) strcpy(&diskbuf[484],&"1+1'");
   if (area[0]==3) strcpy(&diskbuf[484],&"1+2'");
   if (area[1]==0) {diskbuf[549]=' ';   diskbuf[555]='0';   }
   if (area[1]==1) {diskbuf[549]='+';   diskbuf[555]='1';   }
   if (area[1]==2) {diskbuf[549]='-';   diskbuf[555]='1';   }
   if (area[2]==0) diskbuf[504]='+'; else diskbuf[504]='-';
   encode(&diskbuf[520],area[3],2,1);
   diskbuf[509]= '0'+area[4];
   encode(&diskbuf[515],area[5],2,1);
   diskbuf[526]= '1'+area[6];
   encode(&diskbuf[531],area[7],2,1);
   encode(&diskbuf[537],area[8],2,1);
   encode(&diskbuf[542],area[9],2,1);
   encode(&diskbuf[3842],area[130],2,1);
   encode(&diskbuf[3853],area[127],2,1);
   encode(&diskbuf[3863],area[128],2,1);
   encode(&diskbuf[3874],area[129],2,1);
   encode(&diskbuf[3882],area[134],2,1);
   encode(&diskbuf[3893],area[131],2,1);
   encode(&diskbuf[3903],area[132],2,1);
   encode(&diskbuf[3914],area[133],2,1);
   for (kk=0; kk<=40; kk=kk+40)
   {   k= (kk/40) * 58;        /* kk= screen x-offset, k= area offset */
      diskbuf[kk+1216]='1'+area[k+10];
      diskbuf[kk+1225]='1'+area[k+11];
      if (diskbuf[kk+1225]=='9') diskbuf[kk+1225]='0';
      diskbuf[kk+2986]='0'+area[k+12];
      diskbuf[kk+2106]='0'+area[k+13];
      envpage(&area[k+14],&diskbuf[kk+3294]);
      envpage(&area[k+32],&diskbuf[kk+2414]);
      envpage(&area[k+50],&diskbuf[kk+1534]);
   } /* end for (kk=0; kk<=40; kk=kk+40) */
   
   if (area[126]==0) strcpy(&diskbuf[493],&"off");
   if (area[126]==1) strcpy(&diskbuf[493],&"ring");
   if (area[126]==2) strcpy(&diskbuf[493],&"noise");

/* change all 0x00's to 0x20's, note: no need for null-termination */
   for (i=0; i<=3918; i++) if (!diskbuf[i]) diskbuf[i]=0x20;
   graf_mouse(2,0L);
/* form-feed, then send page image to printer, at each line end insert CR/LF */
   pageptr= &diskbuf[0];
   prntrow= 53;
   prntpge();
   graf_mouse(0,0L);

} /* end do_hard(area,defname) */

envpage(fromarea,toarea)
char fromarea[];   /* --> envelope data */
char toarea[];     /* --> upper left corner of envelope page image */
{
   int step;

   for (step=0; step<=7; step++)
   {
      encode(&toarea[3*step],fromarea[1+2*step],2,1);
      encode(&toarea[3*step+80],fromarea[2+2*step],2,1);
   } /* end for */
   toarea[160+3*fromarea[0]]='E';
   if (fromarea[17]==8) return;
   toarea[160+3*fromarea[17]]='S';

} /* end envpage(fromarea,toarea) */

/*................... process menu choice = hardlist something ...............*/

hardlist()
{ 
   int error;

/* hardlist the target data */
   if (top_hand==cz_hand)
   {
      graf_mouse(255,&midijack);
      error= getall(&diskbuf,&tempbuf);
      graf_mouse(0,0L);
      if (!error) do_hlist(&tempbuf,&cztitl);
   }
   if (top_hand==wba_hand) do_hlist(&wba_dat[0],&wbatitl);
   if (top_hand==wbb_hand) do_hlist(&wbb_dat[0],&wbbtitl);
} /* end hardlist() */

do_hlist(area,defname)
char area[];   /* 272 bytes */
char defname[];   /* 25 bytes */
{
   int i,j;
   long tree,headaddr;
   char heading[41];
   char alertstr[160];

   for (i=0; i<=4239; i++) diskbuf[i]=0;   
   rsrc_gaddr(R_TREE,CZHARD,&tree);

/* set up pointer to heading field */
   headaddr= LLGET(OB_SPEC(NAMEHARD));
   LLSET(headaddr,&heading);      /* heading field contains heading */
   LWSET(TE_TXTLEN(headaddr),41);  /* length of heading field */
   strcpy(heading,defname);        /* heading field contains default name */

   if (do_dial(tree,CZHARD,NAMEHARD)==CANHARD) return;
/* check heading for unprintable characters */
   for (i=0; i<=40; i++)
   {
      if (!heading[i]) break;   /* all OK */
      if ((heading[i] < 0x20) || (heading[i] >= 0x7f))
      {
         strcpy(alertstr,&"[1][This title contains characters|");
         strcat(alertstr,&"which may have undesired|");
         strcat(alertstr,&"effects on the printer.][Cancel|OK]");
         if (form_alert(1,alertstr) == 1) return;
         break;      /* continue despite unprintable characters */
      }
   }  /* end for */
/* center heading within first line of page image */
   i=strlen(heading);
   strcpy(&diskbuf[(80-i)/2],heading);
/* copy names into rest of page image (center them) */
   if (syntype==3)
      j=3;   
   else
      j=15;
   for (i=0; i<=j; i++)
      strcpy(&diskbuf[272+80*i],&area[17*i]);
/* change all unprintable characters (including nulls) to 0x20's */
   for (i=0; i<=1440; i++) 
      if ((diskbuf[i]<0x20)||(diskbuf[i]>0x7f)) diskbuf[i]=0x20;
   graf_mouse(2,0L);
/* form-feed, then send page image to printer, at each line end insert CR/LF */
   pageptr= &diskbuf[0];
   prntrow= 19;
   prntpge();
   graf_mouse(0,0L);

} /* end do_hlist(area,defname) */

/*..............................update screen.................................*/

update(window,slot)
register int window,slot;
{
   int x,y,w,h;

   if ((window==ws_hand) || (slot==17))
      redraw(window,0,0,0,0);   /* update entire window */
   else
   {
      if ((window==top_hand)&&(slot==act_slot))
         activ_slot(window,slot);
      else
         deact_slot(window,slot);
   }
} /* end update(window,slot) */

/*............... process menu choice = filetoa or filetob ...................*/

filetoa()
{
   int x,y,w,h;

   if (demoflag) return(form_alert(1,BADDEMO));
   if (sequence!=3) return(form_alert(1,BADDEMO));
/* do safety check */
   if (saf_x || saf_alls)
   {
      if (form_alert(1,CHEKSAFE) == 2) return;
   }
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,">>> File --> WB A");
   if (!filetox(&wba_dat))               /* do not update names if error */
   {
      strcpy(wbatitl,&" WB A: ");
      strcat(wbatitl,file_temp);
      strcat(wbatitl,&" ");
      wind_set(wba_hand,WF_NAME,&wbatitl,0,0);
      wind_get(wba_hand,WF_WORKXYWH,&x,&y,&w,&h);  /* get work area */
      redraw(wba_hand,0,0,0,0);   /* update workbank A names */
   }
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,"                 ");
} /* end filetoa() */

filetob()
{
   int x,y,w,h;

   if (demoflag) return(form_alert(1,BADDEMO));
   if (sequence!=3) return(form_alert(1,BADDEMO));
/* do safety check */
   if (saf_x || saf_alls)
   {
      if (form_alert(1,CHEKSAFE) == 2) return;
   }
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,">>> File --> WB B");
   if (!filetox(&wbb_dat))                   /* do not update names if error */
   {
      strcpy(wbbtitl,&" WB B: ");
      strcat(wbbtitl,file_temp);
      strcat(wbbtitl,&" ");
      wind_set(wbb_hand,WF_NAME,&wbbtitl,0,0);
      wind_get(wbb_hand,WF_WORKXYWH,&x,&y,&w,&h);  /* get work area */
      redraw(wbb_hand,0,0,0,0);   /* update workbank B names */
   }
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,"                 ");
} /* end filetob() */

filetox(wbptr)   /* return 1 for error, 0 for ok */
char *wbptr;
{
   long error;
   int filehand,exit_obj;

   strcpy(dir_temp,dir_def);   /* set up default directory to be loaded */
   file_temp[0]= '\0';
   if (!fsel_input(&dir_temp,&file_temp,&exit_obj)) return(1); 
   if (!exit_obj) return(1);   /* error return for cancel button */

   strcpy(dir_def,dir_temp);     /* save directory for next time */
   combine(dir_temp,file_temp);  /* dir_temp will contain pathname */
   graf_mouse(2,0L);
   error= Fopen(dir_temp,2);     /* try to open file */
   if (error<0L)                 /* if could not open file */
   {
      form_alert(1,BADOPEN);
      return(1);
   }
   filehand= error+get_tr();         /* try to read file */
   error= Fread(filehand,2436L,diskbuf);
   Fclose(filehand);       /* close file */
   graf_mouse(0,0L);
   if (error != 2436L)       /* if could not read file */
   {
      form_alert(1,BADREAD);
      return(1);
   }
   /* note: sequence=3 */
   if ((diskbuf[0]!=filecode[0])||(diskbuf[1]!=filecode[1])
     ||(diskbuf[2]!=filecode[2])||(diskbuf[sequence]!=filecode[3]))
   {                            /* if file contained weird data */
      form_alert(1,BADDATA);
      return(1);
   }
   copybyte(&diskbuf[sequence+1],wbptr,2432);  /* copy disk buffer to wb A or B */
   return(0); /* successful */

}  /* end filetox() */   
        
/*...................... process menu choice = erase .........................*/

erase()
{
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
   v_gtext(gl_hand,480,2+6*rez,">>> Erase File");
   rrase();
   vs_clip(gl_hand,0,&dummy);   /* turn clipping off */  
   v_gtext(gl_hand,480,2+6*rez,"              ");
} /* end erase() */

rrase()
{
   int exit_obj;
   long error;

   strcpy(dir_temp,dir_def);    /* set up default directory to erase */
   file_temp[0]= '\0';    
   if (!fsel_input(&dir_temp,&file_temp,&exit_obj)) return;  /* get pathname */
   if (exit_obj)                /* if OK button clicked */
   {
      strcpy(dir_def,dir_temp);   /* save directory for next time */
      combine(dir_temp,file_temp);   /* dir_temp will contain pathname */
      graf_mouse(2,0L);   
      error= Fdelete(dir_temp);       /* try to erase file */
      graf_mouse(0,0L);            
      if (error) form_alert(1,BADERASE);
   }
}  /* end rrase() */   

/*..................... process menu choice = safety .........................*/

safety()
{
   int exit_obj;
   long tree; 

   exit_obj= do_dial(safeaddr,CZSAFETY,-1);  /* safety dialog */
   if (exit_obj == CANSAFE)
   {
      if (saf_alls)
         sel_obj(safeaddr,ALLSSAFE);
      else
         desel_obj(safeaddr,ALLSSAFE);   
      if (saf_cz)
         sel_obj(safeaddr,CZSAFE);
      else
         desel_obj(safeaddr,CZSAFE);   
      if (saf_x)
         sel_obj(safeaddr,ALLSAFE);
      else
         desel_obj(safeaddr,ALLSAFE);   
   }
   else
   {
      tree= safeaddr;  /* needed by LW macros */
      if (LWGET(OB_STATE(ALLSSAFE)) & SELECTED)
         saf_alls= 1;
      else
         saf_alls= 0;
      if (LWGET(OB_STATE(CZSAFE)) & SELECTED)
         saf_cz= 1;
      else
         saf_cz= 0;
      if (LWGET(OB_STATE(ALLSAFE)) & SELECTED)
         saf_x= 1;
      else
         saf_x= 0;
   } /* end if (exit_obj == CANSAFE) */
} /* end safety() */

/*..................... process menu choice = midich .........................*/

midich()
{
   int exit_obj,choice;
   char midimess[18];

   exit_obj= do_dial(midiaddr,CZMIDI,-1);       /* midi channel dialog */
   choice= which_ch();              /* which midi channel? = 0-15 */   
   if (exit_obj == CANMIDI)
   {
      desel_obj(midiaddr,(MIDI1+choice));  /* assumes contiguous objects */
      sel_obj(midiaddr,(MIDI1+midi_ch));   /* deselect the selected midi ch */
      return;                              /* reselect the former midi ch */
   }
   midi_ch= choice;   /* set the requested midi channel */
   if (midi_ch<9)
   {
      strcpy(midimess," MIDI Channel=  1");
      midimess[16]= midimess[16]+midi_ch;
   }
   else
   {
      strcpy(midimess," MIDI Channel= 10");
      midimess[16]= midimess[16]+midi_ch-9;
   }   
   menu_text(menuaddr,MIDICH,midimess);
} /* end midich() */

which_ch()   /* returns 0-15 = midich radio button # selected */
{
   long tree;

   tree= midiaddr;  /* tree needed by macros */
   if (LWGET(OB_STATE(MIDI1)) & SELECTED) return(0);
   if (LWGET(OB_STATE(MIDI2)) & SELECTED) return(1);
   if (LWGET(OB_STATE(MIDI3)) & SELECTED) return(2);
   if (LWGET(OB_STATE(MIDI4)) & SELECTED) return(3);
   if (LWGET(OB_STATE(MIDI5)) & SELECTED) return(4);
   if (LWGET(OB_STATE(MIDI6)) & SELECTED) return(5);
   if (LWGET(OB_STATE(MIDI7)) & SELECTED) return(6);
   if (LWGET(OB_STATE(MIDI8)) & SELECTED) return(7);
   if (LWGET(OB_STATE(MIDI9)) & SELECTED) return(8);
   if (LWGET(OB_STATE(MIDI10)) & SELECTED) return(9);
   if (LWGET(OB_STATE(MIDI11)) & SELECTED) return(10);
   if (LWGET(OB_STATE(MIDI12)) & SELECTED) return(11);
   if (LWGET(OB_STATE(MIDI13)) & SELECTED) return(12);
   if (LWGET(OB_STATE(MIDI14)) & SELECTED) return(13);
   if (LWGET(OB_STATE(MIDI15)) & SELECTED) return(14);
   return(15);
}

whichbnk()   /* returns which radio button selected in CZBANK */
{
   long tree=bankaddr;

   if (LWGET(OB_STATE(PRE1000)) & SELECTED) return(PRE1000);
   if (LWGET(OB_STATE(INT1000)) & SELECTED) return(INT1000);
   if (LWGET(OB_STATE(CRT1000)) & SELECTED) return(CRT1000);
   if (LWGET(OB_STATE(PRE3000A)) & SELECTED) return(PRE3000A);
   if (LWGET(OB_STATE(PRE3000C)) & SELECTED) return(PRE3000C);
   if (LWGET(OB_STATE(INT3000A)) & SELECTED) return(INT3000A);
   if (LWGET(OB_STATE(INT3000C)) & SELECTED) return(INT3000C);
   if (LWGET(OB_STATE(INT1A)) & SELECTED) return(INT1A);
   if (LWGET(OB_STATE(INT1C)) & SELECTED) return(INT1C);
   if (LWGET(OB_STATE(INT1E)) & SELECTED) return(INT1E);
   if (LWGET(OB_STATE(INT1G)) & SELECTED) return(INT1G);
   if (LWGET(OB_STATE(CZ230S)) & SELECTED) return(CZ230S);

} /* end whichbnk() */

/* EOF */
