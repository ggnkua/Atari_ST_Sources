#include "ptvars.h"

#ifdef COLOR
   #define FORM01 "[1][Diese Version erfordert|einen  Farb-Monitor][OK]"
#else
   #define FORM01 "[1][Diese Version erfordert|einen  Monochrome-Monitor][OK]"
#endif

#define FORM02 "[1][Kein Window zur VerfÅgung !][OK]"


#include <osbind.h>
#include <gembind.h>
#include <megatadd.h>

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

extern OBJECT **load_rsrc();
extern char *ptadr();

ptexit(what)
{
   GRECT work;
   long save;
   long new,old;

/* Diskettenmitschrift close */
   if(jo_handle>5)
      Fclose(jo_handle);

   Jdisint(13);

   save=Super(0l);
   asm
   {
      BCLR #3,0X484
   }
   Super(save);

   if(what==-2)
   {
      if(!onli_vt52)	
         wind_close(wi_han1);

      graf_shrinkbox(SMXY,SMWH,window_box);
      wind_delete(wi_han1);

      asm
      {
         MOVE.L   OLDMMOVE(PC), new(A6)
      }
      vex_motv(vdi_handle,new,&old);

      asm
      {
         MOVE.L   OLDMBUTT(PC), new(A6)
      }
      vex_butv(vdi_handle,new,&old);

      mousemov(0l);
      rtsinit(0);

      /********** iorec zurÅcksetzen **********/
      *iorec = old_io;

   }
   v_clsvwk(vdi_handle);
   appl_exit();
}


/* Initialisierung */
init_pb()
{
   OBJECT ** adr;
   GRECT box;
   int handle;
   int a,b;
   long *butvex, *movvex;
   long save_su;
   char *temp;
   char string[30];

   aes_init();
   open_vwork();

   wind_update(BEG_UPDATE);
   TASSE;

#ifdef COLOR
   if(work_out[0]!=639||work_out[1]!=199)
#else
   if(work_out[0]!=639||work_out[1]!=399)
#endif
   {
      wind_update(END_UPDATE);
      graf_mouse(ARROW);
      brain_alert(1,FORM01);
      return(0);
   }

   asm
   {
      DC.W  0XA000
      MOVE.L   A0, line_a_var(A4)
   }
   getfont();

   wind_update(END_UPDATE);

#ifdef COLOR
   adr=load_rsrc("1ST_TERM.RSC");
#else
   adr=load_rsrc("1ST_TERM.RSM");
#endif

   if(!adr)
      return(0);
   jornaldi   = adr[JORNALDI];
   time__di   = adr[TIME__DI];
   mainmenu   = adr[MAINMENU];
   deskmenu   = adr[DESKMENU];
   fkey_di    = adr[F_KEY_DI];
   outputdi   = adr[OUTPUTDI];
   rs232_di   = adr[RS232_DI];
   about_di   = adr[ABOUT_DI];
   disk__di   = adr[DISK__DI];
   finam_di   = adr[FINAM_DI];
   setup_di   = adr[SETUP_DI];
   transfer_di= adr[TRANS_DI];
   proto_di   = adr[XMODEMDI];
   kermitdi   = adr[KERMITDI];
   logon_di   = adr[LOGON_DI];
   user__di   = adr[USER__DI];
   boxnr_di   = adr[BOXNR_DI];
   help__di   = adr[HELP__DI];
   dial__di   = adr[DIAL__DI];

   screen_base=(char *)Physbase();

   wholefree=Malloc(-1l)-5000l;
   reserved=(char *)Malloc(wholefree);

   box_space=reserved;
   if(!box_space||wholefree<20000l)
   {
      form_error(39);
      return(0);
   }

   if(wholefree<100000l)
   {
      form_error(39);
      return(0);
   }
   
   space0=&space80[80];

   screen.fd_addr=0l;
   save.fd_w=640;
#ifdef COLOR
   save.fd_h=200;
   save.fd_wdwidth=40;
   save.fd_nplanes=2;
#else
   save.fd_h=400;
   save.fd_wdwidth=40;
   save.fd_nplanes=1;
#endif
   save.fd_stand=0;
   save.fd_addr=(long)((long)box_space+20000l);
   save.fd_addr +=(save.fd_addr & 1) ? 1 : 0;

/************** iorec verbiegen *****************/
   new_io.isize = 32000;
   new_io.ibuf = (char *)((long)save.fd_addr+32000l);
   new_io.ihd=new_io.itl = 0;
   new_io.ilow=(new_io.isize>>2);
   new_io.ihi =new_io.ilow+(new_io.isize>>1);

   iorec = (IOREC *)Iorec(0);

   old_io = *iorec;
   *iorec = new_io;

/************ Pufferbereich reservieren **************/

   buf_size = wholefree-84000l;
   buf_point = buf_start = (char *)((long)new_io.ibuf+32000l);
   buf_end   = buf_start + buf_size-256;

/************* Funktionstasten init ****************/

   fkey[0] = fbuffer;
   for(a=1;a<41;a++)
   {
      fkey[a] = &fbuffer[43*a];
      strcpy(fkey[a]-2, "\15\12");
   }

   ptadr(dial__di,DL___COM,0);
   for(b=0,a=0;a<10;a++,b+=3)
   {
      numdoc[a]=ptadr(dial__di,DL___NR1+b,0);
      nums[a]=ptadr(dial__di,DL___NR1+b+1,0);
   }

   for(a=0;a<17;a++)
      regs[a]=ptadr(dial__di,DL____R0+a,0); 

   temp=(char *)proto_di;
   temp+=10;

   digi_flag[0]=(int *)((char *)temp+(XM____1A*24));
   digi_flag[1]=(int *)((char *)temp+(XM____1B*24));
   digi_flag[2]=(int *)((char *)temp+(XM____1C*24));
   digi_flag[3]=(int *)((char *)temp+(XM____1D*24));
   digi_flag[4]=(int *)((char *)temp+(XM____1E*24));
   digi_flag[5]=(int *)((char *)temp+(XM____1F*24));
   digi_flag[6]=(int *)((char *)temp+(XM____1G*24));

   digi_flag[7]=(int *)((char *)temp+(XM___10A*24));
   digi_flag[8]=(int *)((char *)temp+(XM___10B*24));
   digi_flag[9]=(int *)((char *)temp+(XM___10C*24));
   digi_flag[10]=(int *)((char *)temp+(XM___10D*24));
   digi_flag[11]=(int *)((char *)temp+(XM___10E*24));
   digi_flag[12]=(int *)((char *)temp+(XM___10F*24));
   digi_flag[13]=(int *)((char *)temp+(XM___10G*24));

   digi_flag[14]=(int *)((char *)temp+(XM__100A*24));
   digi_flag[15]=(int *)((char *)temp+(XM__100B*24));
   digi_flag[16]=(int *)((char *)temp+(XM__100C*24));
   digi_flag[17]=(int *)((char *)temp+(XM__100D*24));
   digi_flag[18]=(int *)((char *)temp+(XM__100E*24));
   digi_flag[19]=(int *)((char *)temp+(XM__100F*24));
   digi_flag[20]=(int *)((char *)temp+(XM__100G*24));

   digi_index[0]=XM____1A;
   digi_index[1]=XM____1B;
   digi_index[2]=XM____1C;
   digi_index[3]=XM____1D;
   digi_index[4]=XM____1E;
   digi_index[5]=XM____1F;
   digi_index[6]=XM____1G;
   digi_index[7]=XM___10A;
   digi_index[8]=XM___10B;
   digi_index[9]=XM___10C;
   digi_index[10]=XM___10D;
   digi_index[11]=XM___10E;
   digi_index[12]=XM___10F;
   digi_index[13]=XM___10G;
   digi_index[14]=XM__100A;
   digi_index[15]=XM__100B;
   digi_index[16]=XM__100C;
   digi_index[17]=XM__100D;
   digi_index[18]=XM__100E;
   digi_index[19]=XM__100F;
   digi_index[20]=XM__100G;

   old_ein=8;
   old_zehn=8;
   old_hun=8;

   do_objc(fkey_di,TEXT_BUT,SELECTED);
   do_objc(fkey_di,F1___KEY,SELECTED);
   do_objc(fkey_di,FNOR_KEY,SELECTED);

   cur_up=ptadr(fkey_di,FK____UP,0);
   cur_dn=ptadr(fkey_di,FK____DN,0);
   cur_lt=ptadr(fkey_di,FK____LT,0);
   cur_rt=ptadr(fkey_di,FK____RT,0);

/************ schau ob 1ST_TERM.FKY ***************/

   load_fkey(2);

/************ schau ob 1ST_TERM.TEL ***************/

   nums_disk(2);

/************ schau ob 1ST_TERM.LOG ***************/

   load_auto(1);

/************ schau ob 1ST_TERM.PAR ***************/

   baud=1;
   xmode=0;
   data=8;
   stop=1;
   parity=0;
   jo_screen=1;
   bremser=0;
   modemon=0;
   OB_STATE(mainmenu,MN_MODEM)|=DISABLED;
   load_para(1);

/********* Shift-Status bei Bconin mitliefern **********/


/* Der folgende Mist bezieht sich auf die Ermittlung der Position und  */
/* Grîûe der MenÅleiste, und dem initialisieren der Interrupts DCD und */
/* RI sowie dem VerÑndern der Mouse-Movement und Mouse-Button-Change   */

   objc_xywh(mainmenu,2,&box);
   a=box.g_x;
   asm
   {
         LEA      MX1(PC), A0
         MOVE.W   a(A6), (A0)                ; x von links
   }
   a=box.g_y+box.g_h-1;
   asm
   {
         LEA      MY1(PC), A0
         CLR.W    (A0)                       ; y von oben
         LEA      MY2(PC), A0
         MOVE.W   a(A6), (A0)                ; y von unten
   }
   a=box.g_x+box.g_w-1;

   save_su=Super(0l);
   asm
   {
         BSET.B      #3, 0X484		   ; doofer Shift-Status

         MOVE.W   SR,-(A7)
         ORI.W    #0X0700,SR

         LEA      MX2(PC), A0
         MOVE.W   a(A6), (A0)                ; x von ganz rechts

         LEA      MSX(PC), A0
         LEA      mouse_x(A4), A1
         MOVE.L   A1, (A0)
         LEA      MSY(PC), A0
         LEA      mouse_y(A4), A1
         MOVE.L   A1, (A0)
         LEA      MB(PC), A0
         LEA      mouse_but(A4), A1
         MOVE.L   A1, (A0)
         LEA      IRQ_MENU(PC), A0
         LEA      irq_menu(A4), A1
         MOVE.L   A1, (A0)
         LEA      OLDMBUTT(PC), A0
         MOVE.L   A0, butvex(A6)            /* Adresse wo die alten */
         LEA      OLDMMOVE(PC), A0
         MOVE.L   A0, movvex(A6)            /* Routinen hinkommen   */

         LEA      ALERT_AKT(PC), A0
         LEA      alert_akt(A4), A1
         MOVE.L   A1, (A0)
         CLR.W    (A1)
         MOVE.W   (A7)+,SR
   }
   Super(save_su);

/* exactly bis hierher */



 /************ MenÅleisteninit **********************/
   init_menu();
 /************* Windowinitialisierung **************/

   wind_update(BEG_UPDATE);
   wind_get(0,WF_WXYWH,&gl_xfull,&gl_yfull,&gl_wfull,&gl_hfull);

   hide_mouse();

   wi_han1=wind_create(47
                       ,gl_xfull-1,gl_yfull,gl_wfull,gl_hfull);
   if(wi_han1 == -1)
   {
      wind_update(END_UPDATE);
      graf_mouse(ARROW,0l);
      brain_alert(1,FORM02);
      return(-1);
   }
   wind_set(wi_han1,WF_NAME,windtitel,0,0);

   gl_xfull = align_x(gl_xfull);

   do_open(wi_han1,SMXY,
           align_x(gl_xfull)-1,gl_yfull,gl_wfull,gl_hfull);
   do_full(wi_han1,0);

   wi_han_off=wi_han1;
   set_xy_cur(wi_han1);
   clr_window(wi_han1);
   top_window=wi_han1;

   vex_butv(vdi_handle,MBUTTON,butvex);   /* Ab jetzt habe ich    */
   vex_motv(vdi_handle,MMOVE,movvex);     /* das groûe Sagen !!!  */

   mousemov(&mouse);    /* Mausabschaltung initialisieren */
   rtsinit(1);
   t_start();           /* TIMER A starten */

   PFEIL;
   show_mouse();
   wind_update(END_UPDATE);
   return(1);
}


portc(byte)
int byte;
{
   asm
   {
      PEA      PORT_C
      MOVE.W   #38,-(A7)
      TRAP     #14
      ADDQ.L   #6,A7
      TST.W    D0
      BEQ      NOSEND
      MOVE.W   byte(A6),-(A7)
      MOVE.W   #0X04,-(A7)
      TRAP     #1
      ADDQ.L   #4,A7
NOSEND:
      UNLK     A6
      RTS

NOTCLEAR:
      MOVE.L   #0x0bffffl,-(A7)
      TRAP     #13
      ADDQ.L   #4,A7
      ANDI.W   #0X000E,D0
      CMPI.W   #0X000E,D0
      BNE      PORT_C
      MOVEA.L  iorec(A4),A0
      MOVE.W   20(A0),22(A0)
      BRA      RET0
PORT_C:
      MOVEA.L  iorec(A4), A0
      MOVE.W   20(A0), D1         ; HEAD INDEX RS232-PUFFER OUT
      CMP.W    22(A0), D1         ; TAIL INDEX RS232-PUFFER OUT
      BNE      NOTCLEAR          ; SIND NOCH ZEICHEN ZU SENDEN

      MOVE.W   bremser(A4), D0
      BEQ      OK

      SUBQ.W   #1, D0

BREMS:
      MOVE.W   #8, D1

BREMS2:
      MOVE.W   0X4000, 0X4000    ; 20 TAKTZYKLEN
      MOVE.W   0X4000, 0X4000    ; 20 TAKTZYKLEN
      MOVE.W   0X4000, 0X4000    ; 20 TAKTZYKLEN
      NOP                        ;  4 TAKTZYKLEN
      BTST.L   #0, D0            ;  6 TAKTZYKLEN
      DBF      D1, BREMS2
      DBF      D0, BREMS         ; 10 TAKTZYKLEN
                                 ;-----------------------------------
                                 ; 70 TAKTZYKLEN = 1/10 MILLISEKUNDE
OK:   MOVEQ    #1,D0
      RTS
RET0:
      MOVEQ    #0,D0
      RTS
   }
}

ports(string)
char *string;
{
   register char *p1,*p2,*p3;
   register long a,b,c,d,e;

   while(*string)
      portc(*string++);
}

overlay "patch"
patch()
{
   asm
   {
DC.B "PATCH "
DC.W 3,4,87,1,500,00
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 /*0*/
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 /*256*/
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 /*512*/
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 /*768*/
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2 
DC.W 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2
/* 1024 */
   }
} 
