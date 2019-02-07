/**************************************************************************
*                                LOCK & KEY                               *
*                             by Jesse  Devine                            *
*                       (C) 1988 Antic Publishing Inc.                    *
*                                                                         *
*      This program was written entirely with Lattice C around 6/87,      *
*      and regularly re-written until 2/88.                               * 
***************************************************************************/

#define BYTE   char              /* signed 8 bit integer */
#define UBYTE  unsigned char     /* unsigned 8 bit int   */
#define WORD   short             /* signed 16 bit int    */
#define UWORD  unsigned short    /* unsigned 16 bit int  */
#define LONG   int               /* signed 32 bit int    */
#define ULONG  unsigned long     /* unsigned 32 bit int  */

main()
{
   LONG   size;

   WORD   work_in[12], work_out[57];
   WORD   handle,i,rc;
   WORD   gr_1,gr_2,gr_3,gr_4;

   BYTE   folder[13];
   BYTE   password[10];
   BYTE   *buffer;

/** Do the usual housekeeping stuff **/

   appl_init();
   handle=graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

   for(i=0; i<10; i++)
      work_in[i] = 1;
   work_in[10] = 2;
   v_opnvwk(work_in, &handle, work_out);

   graf_mouse(0,1);

   vsf_interior(handle,4);
   vsf_color(handle,1);
   v_show_c(handle);


/** This is where the meaty stuff begins **/

   retry:
   buffer = (BYTE *)infile("lockkey.dat",&size);
   if(buffer == 0){
      rc = form_alert(1,"[1][|SORRY! LOCKKEY.DAT|could not be opened.][RETRY|CANCEL]");
      if(rc == 1)
         goto retry;
      else
         goto end;
   }

   title:
   rc = form_alert(1,"[0][          Lock & Key          |     Installation Program     |        by Jesse Devine       |(C)1988 Antic Publishing, Inc.][OK|CANCEL]");
   if(rc == 2)
      goto end;

   fldr:
   rc = dialog("Please enter the name of","the folder you wish to make",
               "a key for.","",folder,"________.___","FFFFFFFFFFF",
               "OK","CANCEL",1);
   if(rc == 2)
      goto end;

   rc = dialog("Please enter the password you",
               "wish to use to access the folder.","","",
               password,"________","FFFFFFFF","OK","CANCEL",1);
   if(rc == 2)
      goto fldr;

/** Scramble password & folder, then insert in buffer **/

   for(i = 0 ; i != 11 ; i++)                /* Clear out previous folder   */
      buffer[i + 0x2dc] = 0;                 /* 0x2dc: folder starts        */
                                                                          
   for(i = 0 ; i != 8 ; i++)                 /* Clear out previous password */
      buffer[i + 0x2e8] = 0;                 /* 0x2e8: password starts      */

   for(i = 0;i != strlen(folder);i++)        /* Insert new scrambled folder */
      buffer[0x2dc + i] = folder[i] - 1;

   for(i = 0; i != strlen(password);i++)     /* Insert scrambled password   */
      buffer[0x2e8 + i] = password[i] - 1;


/** Write the file back to disk **/

   again:
   rc = form_alert(1,"[2][Which disk drive contains|the folder you wish to make|a key for?][  A  |  B  ]");
   if(rc == 1)
      gemdos(0x0e,0);                          /* Set current drive to A:   */
   else
      gemdos(0x0e,1);                          /* Set current drive to B:   */

   gemdos(0x3b,"\x5c");                        /* Set current dir to root   */

   rc = outfile("key.tos",buffer,size + 19);
   if(rc == 0){
      rc = form_alert(1,"[1][|Uh-Oh... I'm having trouble|writing a key to the disk.][RETRY|CANCEL]");
      if(rc == 1)
         goto again;
      else
         goto stop;
   }
   if(rc == -1)
      goto stop;

   form_alert(1,"[1][|Installation Complete.][OK]");

/** Close the workstation. **/

   stop:
   gemdos(0x49,(LONG)buffer);                  /* Release memory            */

   end:
   v_clsvwk(handle);                           /* Close virtual workstation */
   appl_exit();                                /* Release gem application   */

   _exit(0);                                   /* And exit                  */
   return 0;

}

/***************************************************************************
*                              D I A L O G                                 *
*                                                                          *
* dialog(str1,str2,str3,str4,text,template,valid,button1,button2,default); *
*                                                                          *
*       This function displays a dialog box with four lines of text, one   *
*  GEM input line, and one or two buttons.                                 *
***************************************************************************/

LONG dialog(st1,st2,st3,st4,te_ptext,te_ptmplt,te_pvalid,but1,but2,def)
BYTE *st1, *st2, *st3, *st4;
BYTE *te_ptext, *te_ptmplt, *te_pvalid;
BYTE *but1, *but2;
LONG def;
{

   LONG length,slen,blen;
   WORD rc,i,cx,cy,cw,ch,line;

   struct{
      char  *text;
      char  *mask;
      char  *valid;
      WORD  font;
      WORD  resvd1;
      WORD  just;
      WORD  color;
      WORD  resvd2;
      WORD  thick;
      WORD  txtlen;
      WORD  msklen;
   }ted[1];

   struct{
      WORD next;
      WORD start;
      WORD end;
      WORD type;
      WORD flags;
      WORD status;
      WORD thick;
      WORD color;
      WORD x;
      WORD y;
      WORD w;
      WORD h;
   }tree[8];

/*******************************************
*    Get length of longest string          *
*******************************************/

   length = strlen(st1);

   slen = strlen(st2);
   if(slen > length)
      length = slen;

   slen = strlen(st3);
   if(slen > length)
      length = slen;

   slen = strlen(st4);
   if(slen > length)
      length = slen;

   slen = strlen(te_ptmplt);
   if(slen > length)
      length = slen;

/*******************************************
*       Get length of longest button       *
*******************************************/

   blen = strlen(but1);

   if(strlen(but2) > blen)
      blen = strlen(but2);

/*******************************************
*         Create root object  #0           *
*******************************************/
   tree[0].next   = -1;
   tree[0].start  = 1;
   tree[0].end    = 7;
   tree[0].type   = 20;
   tree[0].flags  = 0;
   tree[0].status = 16;
   tree[0].thick  = 1;
   tree[0].color  = 4592;
   tree[0].x      = 0;
   tree[0].y      = 0;
   tree[0].w      = length + 4;
   tree[0].h      = 0;

   line = 0;

/*******************************************
*          Create first textline  #1       *
*******************************************/

   if(st1[0] != 0)
      line++;

   tree[1].next   = 2;
   tree[1].start  = -1;
   tree[1].end    = -1;
   tree[1].type   = 28;
   tree[1].flags  = 0;
   tree[1].status = 0;
   tree[1].thick  = ((LONG)st1) / 65536;
   tree[1].color  = ((LONG)st1) % 65536;
   tree[1].x      = 2;
   tree[1].y      = line;
   tree[1].w      = 0;
   tree[1].h      = 1;

/*******************************************
*       Create second textline  #2         *
*******************************************/

   if(st2[0] != 0)
      line++;

   tree[2].next   = 3;
   tree[2].start  = -1;
   tree[2].end    = -1;
   tree[2].type   = 28;
   tree[2].flags  = 0;
   tree[2].status = 0;
   tree[2].thick  = ((LONG)st2) / 65536;
   tree[2].color  = ((LONG)st2) % 65536;
   tree[2].x      = 2;
   tree[2].y      = line;
   tree[2].w      = 0;
   tree[2].h      = 1;

/*******************************************
*         Create third textline   #3       *
*******************************************/

   if(st3[0] != 0)
      line++;

   tree[3].next   = 4;
   tree[3].start  = -1;
   tree[3].end    = -1;
   tree[3].type   = 28;
   tree[3].flags  = 0;
   tree[3].status = 0;
   tree[3].thick  = ((LONG)st3) / 65536;
   tree[3].color  = ((LONG)st3) % 65536;
   tree[3].x      = 2;
   tree[3].y      = line;
   tree[3].w      = 0;
   tree[3].h      = 1;

/*******************************************
*        Create fourth textline   #4       *
*******************************************/

   if(st4[0] != 0)
      line++;

   tree[4].next   = 5;
   tree[4].start  = -1;
   tree[4].end    = -1;
   tree[4].type   = 28;
   tree[4].flags  = 0;
   tree[4].status = 0;
   tree[4].thick  = ((LONG)st4) / 65536;
   tree[4].color  = ((LONG)st4) % 65536;
   tree[4].x      = 2;
   tree[4].y      = line;
   tree[4].w      = 0;
   tree[4].h      = 1;

/*******************************************
*       Create editable textline  #5       *
*******************************************/

   line++;
   line++;

   tree[5].next   = 6;
   tree[5].start  = -1;
   tree[5].end    = -1;
   tree[5].type   = 29;
   tree[5].flags  = 8;
   tree[5].status = 0;
   tree[5].thick  = ((LONG)ted) / 65536;
   tree[5].color  = ((LONG)ted) % 65536;
   tree[5].x      = (tree[0].w / 2) - (strlen(te_ptmplt) / 2);
   tree[5].y      = line;
   tree[5].w      = strlen(te_ptmplt);
   tree[5].h      = 1;

/*******************************************
*         Create first button  #6          *
*******************************************/

   line++;
   line++;

   tree[6].next   = 7;
   tree[6].start  = -1;
   tree[6].end    = -1;
   tree[6].type   = 26;
   tree[6].flags  = 13;
   tree[6].status = 0;
   tree[6].thick  = ((LONG)but1) / 65536;
   tree[6].color  = ((LONG)but1) % 65536;
   tree[6].x      = 0;
   tree[6].y      = line;
   tree[6].w      = blen + 1;
   tree[6].h      = 1;

/*******************************************
*         Create second button  #7         *
*******************************************/
   tree[7].next   = 0;
   tree[7].start  = -1;
   tree[7].end    = -1;
   tree[7].type   = 26;
   tree[7].flags  = 0;
   tree[7].status = 0;
   tree[7].thick  = ((LONG)but2) / 65536;
   tree[7].color  = ((LONG)but2) % 65536;
   tree[7].x      = 0;
   tree[7].y      = line;
   tree[7].w      = blen + 1;
   tree[7].h      = 1;

/*******************************************
*          Adjust height of box            *
*******************************************/

   tree[0].h = line + 2;

/*******************************************
*            TEDINFO definitions           *
*******************************************/

   ted[0].text   = te_ptext;
   ted[0].mask   = te_ptmplt;
   ted[0].valid  = te_pvalid;
   ted[0].font   = 3;
   ted[0].resvd1 = 6;
   ted[0].just   = 0;
   ted[0].color  = 4480;
   ted[0].resvd2 = 0;
   ted[0].thick  = 0;
   ted[0].txtlen = ((WORD)strlen(te_pvalid) + 1);
   ted[0].msklen = ((WORD)strlen(te_pvalid) + 1);

/*******************************************
*        Convert object dimensions         *
*******************************************/

   for(i = 0; i != 8;i++)
      rsrc_obfix(tree,i);

/*******************************************
*            Figure out buttons            *
*******************************************/

   if(strcmp(but1,"") == 0)
      return -1;

   if(strcmp(but2,"") == 0){
      tree[6].x = (tree[0].w / 2) - (tree[6].w / 2);
      tree[7].type = 28;
   }
   else{
      tree[6].x = tree[0].x + 16;
      tree[7].x = tree[0].x + tree[0].w - tree[7].w - 16;
      tree[7].flags = 13;
   }

   tree[5 + def].flags = tree[5 + def].flags + 2;

/************* Center dialog box ************/

   form_center(tree,&cx,&cy,&cw,&ch);
   tree[0].x = cx;
   tree[0].y = cy;

/*************** Draw it and do it ************/


   form_dial(0,0,0,0,0,cx-4,cy-4,cw,ch);
   form_dial(1,0,0,0,0,cx,cy,cw,ch);

   objc_draw(tree,0,1,0,0,638,198);             /* Draw object tree          */
   rc = form_do(tree,5) - 5;

   form_dial(2,0,0,0,0,cx,cy,cw,ch);
   form_dial(3,0,0,0,0,cx-4,cy-4,cw,ch);

   return (LONG)rc;
}

/*****************************************************************************
*                                I N F I L E                                 *
*                                                                            *
*  infile(filename,&size);                                                   *
*                                                                            *
*     This function inputs the given file, after having allocated sufficient *
*  memory for it, and returns the address of the buffer where said file is   *
*  located. Additionally, it returns the size of the file.                   *
*****************************************************************************/

LONG infile(filename,size)
BYTE *filename;
LONG *size;
{
   LONG   rc;
   WORD   f1;
   BYTE   *buffer;
   static UBYTE dta[44];

   gemdos(26,dta);                                /* Pass DTA value to sys  */
   rc = gemdos(78,filename,7);                    /* Pass fname to system   */
   if(rc < 0)                                     /* If file cannot be      */
      goto abend;                                 /* Opened, goto end.      */

   *size = dta[27]*65536+dta[28]*256+dta[29];    /* Determine size of file */

   buffer = (BYTE *)gemdos(72,*size);             /* Request buffer space.  */
   if(buffer < 0)                                 /* If not enough memory,  */
      goto abend;                                 /* Goto abnormal end.     */

   f1 = gemdos(61,filename,0);                    /* Open file through GEM  */
   if(f1 < 0)                                     /* If file cannot be      */
      goto abend;                                 /* Goto end.              */

   rc = gemdos(63,f1,*size,(LONG)buffer);         /* Read entire file in    */
   if(rc < 0)                                     /* If trouble reading,    */
      goto abend;                                 /* goto end.              */

   gemdos(62,f1);                                 /* Close file through gem */

   return (LONG)buffer;                           /* Return buffer address  */

   abend:                                         /* Abnormal ending        */
   return 0;                                      /* Return a zero          */
}

/*****************************************************************************
*                                 O U T F I L E                              *
*                                                                            *
*  outfile(filename,buffer,size)                                             *
*                                                                            *
*     This function outputs the contents of the given buffer to the file     *
*  name given.                                                               *
*****************************************************************************/

LONG outfile(filename,buffer,size)
BYTE *filename,*buffer;
LONG size;
{
   LONG   rc;
   WORD   f1;

   f1 = gemdos(61,filename,0);                    /* Check if file exists   */
   if(f1 > 0){
      rc = form_alert(1,"[2][KEY.TOS already exists|on this disk. Write|over existing file?][OK|CANCEL]");
      if(rc == 2)
         return -1;                               /* Indicate immediate end */
   }

   f1 = gemdos(60,filename,0);                    /* Open file through GEM  */
   if(f1 < 0)                                     /* If file cannot be      */
      goto stop;                                  /* Goto stop.             */

   rc = gemdos(64,f1,size,buffer);                /* Write entire file out  */
   if(rc < 0)                                     /* If trouble writing,    */
      goto stop;                                  /* try again.             */

   gemdos(62,f1);                                 /* Close file through gem */

   return 1;                                      /* End function w/ rc = 1 */

   stop:                                          /* Abnormal ending        */
   return 0;                                      /* Return a 0             */

}


