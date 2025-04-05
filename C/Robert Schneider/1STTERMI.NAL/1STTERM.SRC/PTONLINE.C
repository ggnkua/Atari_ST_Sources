#define STRING01 "Auto-Logon lÑuft  - Undo = Abbruch"
#define STRING011 "\15\12Auto-Logon lÑuft  - Undo = Abbruch\15\12"

#define STRING02 "\12\15*** Disk "
#define STRING03 "ein ***\15\12"
#define STRING04 "aus ***\15\12"
#define STRING05 "\15\12*** Drucker "

#define FORM01 "[1][Logon nicht geladen][OK]"
#define FORM02 "[1][Mitschriftfehler (Disk) !][Abschalten]"
#define FORM03 "[1][Ausgabe auf Drucker abschalten ?][Ja|Nein]"
#define FORM04 "[1][Puffer ist voll !!|Vor dem Lîschen ausgeben ?][Nein|Ja]"

#define FORM06 "[1][RS 232   : %5d Bd -  %d Daten -%s Stop|Handshake: "
#define FORM061 "   Aus  " 
#define FORM062 "Xon/Xoff"
#define FORM063 "\16\17 R/C "
#define FORM0631" Rts/Cts"
#define FORM064 " - ParitÑt : "
#define FORM065 "   keine|"
#define FORM066 "ungerade|"
#define FORM067 "  gerade|"
#define FORM068 "Transfer : Tastatur ->           "
#define FORM069 "  BinÑr|"
#define FORM610 "  ASCII|"
#define FORM611 "deutsch|"
#define FORM612 "  eigen|"
#define FORM613 "           Dateien  ->           "
#define FORM614 " XMODEM|"
#define FORM615 " KERMIT|"
#define FORM616 " 1ST_WORD|"
#define FORM617 "Lokales Echo = "
#define FORM618 "Ein"
#define FORM619 "Aus"
#define FORM620 "  - Paging :      "
#define FORM621 "  An|"
#define FORM622  " Aus|"
#define FORM623 "Pufferstatus      Grîûe          %7ld|"
#define FORM624 "                  belegt         %7ld|"
#define FORM625 "                  frei           %7ld][OK]"
#define FORM07 "[4][Alt-D = Disk   Alt-P = Drucker|Alt-T = Zeit   Alt-C = Cursor|Alt-S = Status Alt-Sft-T = Zeit -> 0|"
#define FORM071 "Alt-L = Logon  Alt-Sft-L = lade Logon|Home  = Home   Ctrl-Home = Clr-Screen||MenÅleiste ist immer aktiv !][OK]"

overlay "online"

#include <osbind.h>
#include <gembind.h>
#include "ptvars.h"

/********* defines fÅr Auto-Logon-Prozedur *************/
#define  WAITSTRING  0X10
#define  WAITTIME    0X11
#define  WAIT1T      0X13
#define  WAIT2       0X14
#define  WAIT2T      0X15
#define  SENDSTRING  0X20
#define  SENDFKEY    0X21
#define  DIAL        0X30
#define  T_START     0X40
#define  T_STOP      0X41
#define  T_RESET     0X42
#define  LGOTO       0X50
#define  LOGKONF     0X60
#define  BELL        0X70
#define  LOGNOP      0XEA

extern unsigned char *index();

extern int jo_diskwrong();
extern int jo_printwrong();
extern int buf_wrong();
extern int out_c();
extern int portc();
extern int print_out();
extern int TIMER(),STD(),MIN(),SEC(),SECONDS(),UHR_ON();

int *time;

do_online()
{
   register long conin;
   char asci;
   char scan;
   char shift;
   unsigned char byte;
   char string[81];
   char stringcrlf[163];
   char *s_point,*buf_help;
   char *suchstring;
   unsigned char *p;
   int pw1,pw2;
   int key,addkey,*i;
   int fnr,mark_box=0;
   int a,b,c,test_esc,test_mode;
   int spring=0;

   suchstring="BW86";

   seconds=(long *)&SECONDS;
   time=(int *)&UHR_ON;

   mark_box = 0;

   if(duplex)
      w_up=0;

   while(mouse_but);

   mouseset(1);                /* Mausabschaltung aktiv */

   test_esc = (profibox|onli_vt52);
   test_mode = xmode;
   when_cr=max_xcur;

   if(onli_curs)
   {
      curs_on=1;
      cursor();
   }

   if(onli_vt52)
      vt52mode=1;

   buf_help=buf_point;

   while(1)
   {
      if(jo_buff)
         buf_point=buf_help;

      asm
      {
/*
      Schau nach ob Zeichen im Puffer, hole bis keins mehr drin ist oder
      maximal 255 Zeichen in 'string'
*/
      
      CLR.L    D3                   ; StringlÑnge D3 = 0
      MOVE.L   iorec(A4), A1        ; iorec-Adresse in A1
      MOVE.L   (A1), A3             ; rs232-Puffer in A3
      MOVE.W   6(A1), D1            ; head-Pointer in D1
      MOVEA.L  buf_point(A4), A2    ; string-Adresse in A2
NOCH_ZEICHEN:                       ;
      CMP.W    8(A1), D1            ; head == tail
      BEQ      RAUS_ZEICHEN         ; Ja.
      CMPI.W   #255, D3              ; 80 Zeichen in string?
      BEQ      RAUS_ZEICHEN         ; Ja.
      ADDQ.W   #1, D1               ; head +1
      CMP.W    4(A1), D1            ; head == size
      BNE.S    NO_WRAP              ; Nein.
      CLR.W    D1                   ; Ja. head = 0
NO_WRAP:                            ;
      MOVE.B   0(A3,D1), (A2)+      ; rs232 -> string
      ADDQ.W   #1, D3               ; stringlÑnge +1
      TST.W    test_esc(A6)
      BEQ      NOCH_ZEICHEN         ;
      CMPI.B   #27, 0(A3,D1)        ; ESC -Zeichen
      BNE      NOCH_ZEICHEN
      MOVE.W   #1, mark_box(A6)     ; setze Kennzeichen
      SUBQ.W   #1, D3
      SUBQ.W   #1, A2

/*
   Hier wird 'string' angepaût und ausgegeben
*/


RAUS_ZEICHEN:                       ;
      TST.W    test_mode(A6)
      BEQ      NO_TEST
      BTST     #0,32(A1)
      BEQ      NO_TEST
      TST.B    30(A1)
      BEQ      NO_TEST
      MOVE.W   8(A0), D2
      MOVE.W   6(A0), D3
      CMP.W    D3, D2
      BHI      _NO_ADD
      ADD.W    4(A1),D2
_NO_ADD:
      SUB.W    D3,D2
      CMP.W    10(A1),D2
      MOVE.W   #17,-(A7)
      JSR      portc(PC)
      ADDQ.L   #2, A7
      CLR.B    30(A1)

NO_TEST:
      MOVE.W   D1, 6(A1)            ; head-Pointer setzen
      MOVEA.L  buf_point(A4), A1    ;Hole String und
      CLR.B    (A2)                 ;setze 0-Byte
      TST.W    D3
      BEQ      SCHLUSS
      SUBA.L   A1, A2               ; A1=Stringanfang A2=Stringende
      MOVE.W   A2, a(A6)            ; Differenz   ist   StringlÑnge
/*
   Hier wird das öbertragungsprotokoll angepasst
*/

      TST.W    transfer(A4)         ; irgend ein öbertragungsprotokoll ?
      BEQ      CRLF                 ; Nein.
      CMPI.W   #1, transfer(A4)     ; Welches Protokoll ?
      BEQ      ASCII                ; ASCII
      MOVEA.L  iwn_table(A4), A3    ; Startaddresse der Umwandlungstabellen.
      CLR.L    D3
      MOVE.W   a(A6), D3            ;
      MOVEA.L  A1, A2               ; Pointer in A2
      CLR.L    D2                   ; Tabellenpointer in D2

DBF_TABELLE:
      MOVE.B   (A1)+, D2            ; hole Zeichen nach D2
      MOVE.B   0(A3,D2), (A2)+      ; Inhalt der Tabelle in den String
      BNE      DBF_TAB              ; war in Ordnung
      SUBQ.L   #1, A2               ; der aber nicht !
DBF_TAB:
      DBF      D3, DBF_TABELLE
      CLR.B    (A2)                 ; 0-Byte.
      BRA      BRINGS_IN_ORDNUNG
                             
ASCII:
      MOVE.L   A2, D3               ; StringlÑnge in D3
DBF_ASCII:
      ANDI.B   #0X7F,(A1)+          ; 8.TES BIT LôSCHEN
      DBF      D3, DBF_ASCII        ; Nein.
      BRA      CRLF                 ; Alles in Ordnung.

BRINGS_IN_ORNUNG:
      MOVEA.L  buf_point(A4), A1
      SUBA.L   A1, A2               ; A1=Stringanfang A2=Stringende
      MOVE.W   A2, a(A6)            ; Differenz   ist   StringlÑnge
/*
   Hier wird nachgeschaut ob bei CR ein LF angehÑngt werden muû.
   Wenn ja, dann wird 'stringcrlf' aufgebaut.
*/

CRLF:
      TST.W    jo_disk(A4)          ;schau nach ob bei irgend einer
      BEQ      TST_PRINT            ;Mitschrift CRLF gesetzt ist.
      TST.W    lf_disk(A4)          ;
      BNE      COPY_LF              ;
TST_PRINT:                          ;
      TST.W    jo_print(A4)         ;
      BEQ      STRING_RAUS          ;
      TST.W    lf_print(A4)         ;
      BEQ      STRING_RAUS          ;
COPY_LF:                            ;
      LEA      stringcrlf(A6), A2   ;
      CLR.L    D3
      MOVE.W   a(A6), D3
DBF_LOOP:                           ;
      MOVE.B   (A1)+, (A2)          ; kopiere Zeichen string->stringcrlf
      CMPI.B    #13, (A2)+          ; CR ?
      BNE      _DBF                 ; Nein.
      MOVE.B   #10, (A2)+           ; Ja. LF -> stringcrlf
_DBF:                               ;
      DBF      D3, DBF_LOOP         ; loop
      LEA      stringcrlf(A6), A3   ;
      SUBA.L   A3, A2               ;
      MOVE.W   A2, b(A6)            ; stringcrlf lÑnge -> 'b'
/* 
   Hier wird der String auf den Bildschrim, Diskette und Drucker geschmissen.
*/

STRING_RAUS:                        ;
      TST.W    jo_screen(A4)        ;Auf Bildschirm ?
      BEQ      NO_SCREEN            ;Nein.
      MOVE.W   #1, out_string(A4)   ;setze flag fÅr out_c()
      MOVE.L   buf_point(A4), -(A7) ;öbergabe ist ein String
      JSR      out_c(PC)            ;
      ADDQ.L   #4, A7               ;
      CLR.W    out_string(A4)       ;lîsche flag

NO_SCREEN:                          ;
      TST.W    jo_disk(A4)          ;Auf Diskette ?
      BEQ      NO_DISK              ;Nein.
      TST.W    lf_disk(A4)
      BEQ      NO_LF_DISK
      PEA      stringcrlf(A6)
      MOVE.W   b(A6), D1
      SUBQ.W   #1, D1
      BRA      DO_DISK
NO_LF_DISK:
      MOVE.L  buf_point(A4), -(A7)  ;String > stack
      MOVE.W  a(A6), D1             ;hole LÑnge
DO_DISK:
      EXT.L    D1                   ;
      MOVE.L   D1, -(A7)            ;LÑnge > stack
      MOVE.W   jo_handle(A4), -(A7) ;Handle > stack
      MOVE.W   #0X40, -(A7)         ;Funktionsnr. > stack
      TRAP     #1                   ;
      ADDA.L   #12, A7              ;
      CMP.W    D0, D1               ;Alle Zeichen geschrieben?
      BEQ      NO_DISK              ;Ja.
      JSR      jo_diskwrong(PC)     ;Nein.
                                    ;
NO_DISK:                            ;
      TST.W    jo_print(A4)         ;Auf Drucker ?
      BEQ      DONE                 ;Nein.
      TST.W    lf_print(A4)
      BEQ      NO_LF_PRINT
      PEA      stringcrlf(A6)       ; ADRESSE FöR FWRITE(DRUCKER)
      MOVE.W   b(A6), D1
      SUBQ.W   #1, D1
      BRA      DO_PRINT
NO_LF_PRINT:
      MOVE.L  buf_point(A4), -(A7)  ;String > stack
      MOVE.W  a(A6), D1             ;hole LÑnge
DO_PRINT:
      EXT.L    D1                   ;
      MOVE.L   D1, -(A7)            ;LÑnge > stack
      JSR      print_out(PC)        ;
      ADDA.L   #8, A7               ;
DONE:
      CLR.L    D1
      MOVE.L   buf_point(A4), A1    ;String > A1
      MOVE.L   buf_end(A4),A2
      MOVE.W   a(A6), D1            ;hole LÑnge
      BMI      SCHLUSS              ;war gar nichts drin
      ADDA.L   D1, A1               ;neuer pointer
      CMPA.L   A2,A1                ;
      BLE      PUFFER_SET           ;
      JSR      buf_wrong(PC)
      BRA      DONE

PUFFER_SET:
      MOVE.L   A1, buf_help(A6)    ;

SCHLUSS:
/* und hier ist endlich Schluû */
      }

      if(auto_on)
      {
         if(Bconstat(2))
         {
            conin=Bconin(2);
            asm
            {
               MOVE.B   conin, asci(A6)
               SWAP     conin
               MOVE.B   conin, scan(A6)
               ASR.W    #8, conin
               MOVE.B   conin, shift(A6)
            }
         }
         else
            scan=0;
   
         if(scan&&scan!=0x61)
            goto HUPF_CHAR;

         if(autocode[code]==0xff||scan==0x61)
         {
#ifndef COLOR
            if(!onli_vt52)
#endif                  
               wind_set(wi_han1,WF_NAME,windtitel);
            auto_on=0; waiter=0; code=0;
            out_c(7);
            continue;
         }

         if(waiter)
         {
            if(waiter==WAIT2||waiter==WAIT2T)
            {
               if(!such2[0])  /* nur wait-char */
                  if(s_point>buf_point)
                     waittrue|=2;

               p=(unsigned char *)buf_point;
               while(*p)
               {
                  if(*p==such2[pw2])
                     pw2++;
                  else
                  {
                     if(pw2)
                     {
                        pw2=0;
                        continue;
                     }
                  }                
   
                  if(!such2[pw2])
                  {
                     waittrue|=2;
                     break;
                  }
                  p++;
               }
            }

            if(waiter!=WAITTIME)
            {
               if(!such1[0])
                  if(s_point>buf_point)
                     waittrue|=1;

               p=(unsigned char *)buf_point;
               while(*p)
               {
                  if(*p==such1[pw1])
                     pw1++;
                  else
                  {
                     if(pw1)
                     {
                        pw1=0;
                        continue;
                     }
                  }                
   
                  if(!such1[pw1])
                  {
                     waittrue|=1;
                     break;
                  }
                  p++;
               }
            }

            if(waiter==WAITTIME||waiter==WAIT1T||waiter==WAIT2T)
               if(*seconds<=0)
                  waittrue|=4;

            if(waittrue)
            {
               switch(waiter)
               {
                  case WAITSTRING: 
                     if(waittrue&1)
                        waiter=0;
                     break;
                  case WAIT1T:
                     if(waittrue&1)
                     {
                        waiter=0; spring=1; break;
                     }
                     if(waittrue&4)
                     {
                        waiter=0; spring=0; break;
                     }
                     break;
                  case WAIT2:
                     if(waittrue&1)
                     {
                        waiter=0; spring=1; break;
                     }
                     if(waittrue&2)
                     {
                        waiter=0; spring=0; break;
                     }
                     break;
                  case WAIT2T:
                     if(waittrue&1)
                     {
                        waiter=0; spring=2; break;
                     }
                     if(waittrue&2)
                     {
                        waiter=0; spring=1; break;
                     }
                     if(waittrue&4)
                     {
                        waiter=0; spring=0; break;
                     }
                  case WAITTIME:
                     if(waittrue&4)
                     {
                        waiter=0; spring=0;
                     }
                     break;
               }
               waittrue=0;
            }
         }

         if(waiter)
         {
            if(*time)
               t_show();

            continue;
         }

CODESPRUNG:

         switch(autocode[code++])
         {
            case  SENDSTRING  :
               raus_damit(&autocode[code]);
               code+=strlen(&autocode[code])+1;
               break;

            case  SENDFKEY    :
               fnr=autocode[code++];
               raus_damit(fkey[fnr]);
               break;

            case  WAITSTRING  :
               strncpy(such1,&autocode[code],100);
               pw1=0;
               waiter=WAITSTRING;
               s_point=buf_point;
               code+=strlen(such1)+1;
               waittrue=0;
               break;

            case  WAITTIME    :
               *seconds=autocode[code++]<<8;
               *seconds|=autocode[code++];
               waiter=WAITTIME;
               waittrue=0;
               break;

            case  WAIT1T      :  
               strncpy(such1,&autocode[code],100);
               pw1=0;
               code+=strlen(such1)+1;
               *seconds=autocode[code++]<<8;
               *seconds|=autocode[code++];
               s_point=buf_point;
               waiter=WAIT1T;
               waittrue=0;
               break;

            case  WAIT2       :  
            case  WAIT2T      :
               waiter=autocode[code-1];
               strncpy(such1,&autocode[code],50);
               pw1=0;
               code+=strlen(such1)+1;
               strncpy(such2,&autocode[code],50);
               pw2=0;
               code+=strlen(such2)+1;
               s_point=buf_point;
               if(waiter==WAIT2T)
               {
                  *seconds=autocode[code++]<<8;
                  *seconds|=autocode[code++];
               }
               waittrue=0;
               break;

            case  DIAL        :
               raus_damit("ATD");
               raus_damit(nums[autocode[code++]-1]);
               raus_damit("\15");
               break;

            case  T_START     :  
               *time=0xffff;
               break;
            case  T_STOP      :  
               *time=0;   
               break;
            case  T_RESET     :  
               t_null();   
               break;

            case  LGOTO       :  
               i=(int*)&autocode[code];
               code+=2;
               if(spring<=0)
                  code=*i;
               break;

            case LOGNOP       : break;
            case BELL         : out_c(7); break;
            case LOGKONF      :
               i=(int *)&autocode[code];
               if(*i>=0)
                  baud=*i++;
               if(*i>=0)
                  xmode=*i++;
               if(*i>=0)
                  parity=*i++;
               if(*i>=0)
                  data=*i++;
               if(*i>=0)
                  stop=*i;
               code+=10;
               set_config();
               break;

            default:
               auto_on=0;
#ifndef COLOR
               if(!onli_vt52)
#endif                  
                  wind_set(wi_han1,WF_NAME,windtitel);
               out_c(7);
               continue;
               break;   
         }

         if(spring>0)
         {
            if(autocode[code-1]!=LOGNOP)
               spring--;
            goto CODESPRUNG;
         }
      }
     
               
      if(Bconstat(2))
      {
         conin=Bconin(2);
         asm
         {
            MOVE.B   conin, asci(A6)
            SWAP     conin
            MOVE.B   conin, scan(A6)
            ASR.W    #8, conin
            MOVE.B   conin, shift(A6)
         }
HUPF_CHAR:
         key = 0;
         fnr = 0;

         if(scan==0x47)
            asci=0;

         if(!asci||(shift & 8))
         {
            key = 1;
            addkey=50;
            if(!(shift&15))
               addkey=0;
            if(shift&3)
               addkey=10;
            if(shift&4)
               addkey=20;
            if(shift&8)
               addkey=30;

            switch(scan)
            {
               case 0x30:  jo_buff=(jo_buff)?0:1;
                           out_s("\15\12*** Puffer ");
                           out_s((jo_buff)?"ein":"aus");
                           out_s(" ***\15\12");
                           break;

               case 3   :  portc(0);             /*"Control" + "2"*/
                           break;

               case 0x26:  if(shift&3)             /* Alt shift-L */
                           {
                              mouseset(0);
                              if(!load_auto(0))
                                 *autocode=0xff;
                              mouseset(1);
                              PFEIL;
                           }
                           else                    /* Alt - L */
                           {
                              if(autoda)
                              {
                                 auto_on=1; code=0; waiter=0;
#ifndef COLOR
                                 if(onli_vt52)
                                    out_s(STRING011);
                                 else
#endif
                                    wind_set(wi_han1,WF_NAME,
                                 STRING01);
                                 such1[0]=such2[0]=0;
                              }
                              else
                              {
                                 mouseset(0);
                                 brain_alert(1,FORM01);
                                 mouseset(1);
                              }
                           }
                           break;

               case 0x14:  if(shift&3)          /* Alt Shift-T */
                              t_null();
                           else
                              *time^=0xffff;    /* Alt - T */
                           break;

               case 0x48:  raus_damit(cur_up); break;       /* Cursor up */
               case 0x50:  raus_damit(cur_dn); break;       /* Cursor down */
               case 0x4b:  raus_damit(cur_lt); break;       /* Cursor left */
               case 0x4d:  raus_damit(cur_rt); break;       /* Cursor right */

               case 0x77:
               case 0x47:  if(onli_curs)                    /* Clr/Home */
                              del_cursor();
                           if(addkey==10)
                              clr_window(wi_han1);
                           xcur=0; ycur=0;
                           if(onli_curs)
                              cursor();
                           w_up=0;
                           break;

               case 98  :  onl_help();                      /* helptaste */
                           break;

               case 25  :  if(addkey != 30)                 /* Alternate P */
                           break;
                           onl_print();
                           break;

               case 32  :  if(addkey != 30)                 /* Alternate D */
                              break;
                           onl_disk();
                           break;

               case 31  :                                   /* Alternate S */
                           if(addkey!=30)
                              break;
                           onl_status();
                           break;

               case 46  :  if(addkey!=30)                   /* Alternate C */
                              break;
                           if(onli_curs)
                           {
                              onli_curs=0;
                              curs_on=0;
                              del_cursor();
                           }
                           else
                           {
                              onli_curs=1;
                              curs_on=1;
                              cursor(xcur,ycur);
                           }
                           break;

               case 45  :  *(char *)((char *)iorec+31)=0;
                                                   /* Alt-X Xon/Xoff lîschen */
                           break;

              default   :  if(scan>=59&&scan<=68)   /* fkey normal */
                           {
                              fnr=addkey+(scan-58);
                              key=1;
                              break;
                           }
                           if(scan>=84&&scan<=93)
                           {
                              fnr=addkey+(scan-83);   /* fkey mit zusatz */
                              key=1;
                              break;
                           }
                           if(scan>=103&&scan<=112) /* nummernblock-ziffern */
                           {
                              if(addkey!=30)
                                 break;
                              onl_alt123(asci);
                              asci=0;
                              break;
                           }
            }/* ende switch scan */

         }
         string[0]=asci;
         string[1]=0;

         if(key && (fflag[fnr] == '2')&& (fnr>0) && (fnr<41))
         {
            mouseset(0);
            send_raw(fkey[fnr]);
            mouseset(1);
         }

         if(key && (fflag[fnr] == '1')&& (fnr>0) && (fnr<41))
            strcpy(string,fkey[fnr]);

         if(string[0])
            raus_damit(string);
      }

      if(*time)
         t_show();

      if(duplex)
      {
         if(w_up>=max_ycur)
         {
            out_s("\15\12 *** weiter mit (Maus-) Taste ***\15");
            w_up=0;
            while(!Bconstat(2))
               if(mouse_but)
                  break;
            while(Bconstat(2))
               Bconin(2);
            out_s("                                 \15");
         }
      }

      if(profibox||vt52mode)
      {
         if(!login&&profibox)
         {
            p=(unsigned char *)buf_point;
            while(*p)
            {
               if(*p==suchstring[boxsuch])
                  boxsuch++;
               else
               {
                  if(boxsuch)
                  {
                     boxsuch=0;
                     continue;
                  }
               }                
  
               if(boxsuch==4)
               {
                  ports("TE86\15");
                  login=1;
                  break;
               }
               p++;
            }

         }

         if(mark_box)
         {
            mark_box=0;
            mouseset(0);
            hide_mouse();             
            if(onli_curs)
               if(curs_on)
               {
                  curs_on=0;
                  del_cursor();
               }
            
            escape();
            if(onli_curs)
            {
               curs_on=1;
               cursor();
            }
            set_mouse();
            mouseset(1);
         }
      }

      if(jo_buff)
         buf_point=buf_help;

      if(!auto_on&&irq_menu)
         break;
      else
         irq_menu=0;

      if(mouse_but)
      {
         if(mouse_but==1)
         {
            portc(19);
            while(mouse_but);
            portc(17);
         }

         if(mouse_but==2)
         {
            if(Kbshift(-1)&3)
               portc(3);
            else
               portc(24);
            while(mouse_but);
         }
      }
     
   }

   if(onli_curs)
      if(curs_on)
      {
         curs_on=0;
         del_cursor();
      }
   vt52mode=0;

   mouseset(0);          /* Mausabschaltung aus */
}

raus_damit(string)
unsigned char *string;
{
   int a,b;
   char own[6];

   b = 0;
   while(string[b])
   {
      switch(transfer)
      {
         case 0 :    portc(string[b]);
                     break;  /* binary */

         case 1 :    portc(string[b]&127); /* ascii  */
                     break;

         default :   if(a = *(own_table+string[b])) /*umwandlung */
                        portc(a);
                     break;
      }
      if(lf_rs232)
         if(string[b]==13)
            portc(10);
      b++;
   }
   if(echo)
   {
      while(b--)
      {
         iorec->ibuf[iorec->ihd]=string[b];

         if(iorec->ihd)
            iorec->ihd--;
         else
            iorec->ihd=iorec->isize-1;
      }
   }
}

jo_diskwrong()
{
   mouseset(0,0);
   brain_alert(1,FORM02);
   jo_disk=0;
   mouseset(1,1);
}

jo_printwrong()
{
   if(online)
      mouseset(0,0);
   jo_print=brain_alert(1,FORM03);
   jo_print -=1;
   if(online)
      mouseset(1,1);
   return(jo_print);
}

buf_wrong()
{
   int a,device;

   mouseset(0,0);
   a=brain_alert(1,FORM04);
   while(a==2)
   {
      device=do_output();
      do_print(device,buf_start,buf_point-(long)buf_start,1,1);
      a=brain_alert(1,FORM04);
   }

   buf_point = (char *)buf_start;
   mouseset(1,1);
}

onl_status()
{
   char string[100];
   char string2[400];
   int a=0,b;
   char *sb;

   switch(stop)
   {
      case 1   : sb=" 1 "; break;
      case 2   : sb="1.5"; break;
      case 3   : sb=" 2 "; break;
   }

   sprintf(string2,FORM06,19200/baud,data,sb);
   switch(xmode)
   {
      case 0   :  strcat(string2,FORM061);
                  break;
      case 1   :  strcat(string2,FORM062);
                  break;
      case 2   :  strcat(string2,FORM063);
                  break;
   }
   strcat(string2,FORM064);
   switch(parity)
   {
      case 0   :  strcat(string2,
                      FORM065);
                  break;
      case 1   :  strcat(string2,
                      FORM066);
                  break;
      case 2   :  strcat(string2,
                      FORM067);
                  break;
   }
   strcat(string2,FORM068);
   switch(transfer)
   {
      case 0   :  strcpy(string,FORM069); break;
      case 1   :  strcpy(string,FORM610); break;
      case 2   :  strcpy(string,FORM611); break;
      case 3   :  strcpy(string,FORM612); break;
   }
   strcat(string2,string);
   strcat(string2,FORM613);
   switch(mode)
   {
      case 0   :  break;
      case 1   :  strcpy(string,FORM614); break;
      case 2   :  strcpy(string,FORM615); break;
      case 3   :  strcpy(string,FORM616); break;
   }
   strcat(string2,string);

   strcat(string2,FORM617);
   if(echo)
      strcat(string2,FORM618);
   else
      strcat(string2,FORM619);

   strcat(string2,FORM620);
   if(duplex)
      strcat(string2,FORM621);
   else
      strcat(string2,FORM622);

   sprintf(string,
           FORM623
           ,(long)buf_end-(long)buf_start);
   strcat(string2,string);
   sprintf(string,
           FORM624
           ,(long)buf_point-(long)buf_start);
   strcat(string2,string);
   sprintf(string,
           FORM625
             
           ,(long)buf_end-(long)buf_point);
   strcat(string2,string);
   mouseset(0,0);
   brain_alert(1,string2);
   mouseset(1,1);
}

onl_disk()
{

   if(jo_handle > 5)
      jo_disk = (jo_disk)? 0 : 1 ;
   else
      if(jo_disk)
         jo_disk = 0;
      else
      {
         save_screen();
         mouseset(0,0);
         do_jornal();
         mouseset(1,1);
         do_redraw();
      }
   out_s(STRING02); 
   if(jo_disk)
      out_s(STRING03);
   else
      out_s(STRING04);

}

onl_help()
{
   char s[300];

   strcpy(s,FORM07);
   strcat(s,FORM071);
   mouseset(0,0);
   brain_alert(1,s);
   mouseset(1,1);
}

onl_print()
{
   jo_print = (jo_print)? 0 : 1 ;
   out_s(STRING05);
   if(jo_print)
      out_s(STRING03);
   else
      out_s(STRING04);
}

onl_alt123(asci1)
unsigned char asci1;
{
   unsigned int count;
   char conin;
   int pstatus;

   count = asci1-'0';

   do         /* while( pstatus & 8)   Alternate Taste gedrÅckt */
   {
      if(Bconstat(2))
      {
         conin = Bconin(2);
         if(conin>'9'||conin<'0')
            break;
         count *= 10;
         count += conin-'0';
         if(count > 255)
         {
            Bconout(2,7);
            return;
         }
      }
      vq_key_s(vdi_handle,&pstatus);

   }while(pstatus & 8);
   portc(count);
   if(echo)
      out_c(count);
}

print_out(len,string)
long len;
char *string;
{
   int a;
   while(len--)
   {
      while(!Cprnos())
      {
         if(Bconstat(2))
         {
            vq_key_s(vdi_handle,&a);
            if((a & 8) && (((Bconin(2)>>16)&0xff)==0x19))
               if(!jo_printwrong())
                  return;
         }
         if(mouse_but==3)
            if(!jo_printwrong())
               return;
      }
      Cprnout(*string++);
   }
}

t_start()
{
   asm
   {
      PEA      TIMER
      CLR.W    -(A7)
      MOVE.W   #7,-(A7)
      CLR.W    -(A7)
      MOVE.W   #31,-(A7)
      TRAP     #14
      ADDA.L   #12,A7
   }
}

t_stop()
{
   Jdisint(13);
}

t_show()
{
   int a,b;
   int std,min,sec;
   char s[30];

   asm
   {
      LEA      STD,A0
      MOVE.W   (A0)+,std(A6)
      MOVE.W   (A0)+,min(A6)
      MOVE.W   (A0),sec(A6)
   }
   sprintf(s,"%2d:%2d:%2d",std,min,sec);
   for(a=0,b=568;a<8;a++,b+=8)
   {
      if(s[a]==' ')
         s[a]='0';
      putbig(b,1,s[a]);
   }
}

t_null()
{
   asm
   {
      LEA      STD,A0
      CLR.L    (A0)+
      CLR.W    (A0)
   }
}

timer()
{
   asm
   {
STD:     DC.W  0
MIN:     DC.W  0
SEC:     DC.W  0
HERTZ:   DC.W  48
SECONDS: DC.L  0
UHR_ON:  DC.W  0

TIMER:
   MOVEM.L  D0-D7/A0-A6,-(A7)
   LEA      HERTZ,A0
   SUBQ.W   #1,(A0)        ; EIN 48.TEL HERTZ ABZIEHEN
   TST.W    (A0)           ; SCHON 48 RUNTERGEZéHLT ?
   BNE.S    NOMIN          ; NEIN, ABFLUG
   MOVE.W   #48,(A0)       ; HERTZ ZéHLER INITIALISIEREN
   LEA      SECONDS,A0     ; LAUFENDER ZAEHLER
   SUBQ.L   #1,(A0)        ; FUER VERSCHIEDENE AUFGABEN
   LEA      UHR_ON,A0
   TST.W    (A0)           ; STD MIN SEC EINGESCHALTEN ?
   BEQ      NOMIN          ; NEIN
   LEA      SEC,A0         ; JA
   LEA      MIN,A1
   LEA      STD,A2
   ADDQ.W   #1,(A0)        ; EINE SEKUNDE DAZU
   CMPI.W   #60,(A0)       ; SCHON 60 SECS
   BNE.S    NOMIN          ; NEIN
   CLR.W    (A0)           ; JA, AUF NULL
   ADDQ.W   #1,(A1)        ; EINE MINUTE DAZU
   CMPI.W   #60,(A1)       ; SCHON 60 MINS
   BNE.S    NOMIN          ; NEIN
   CLR.W    (A1)           ; JA, MINUTEN AUF NULL
   ADDQ.W   #1,(A2)        ; EINE STUNDE DAZU
   CMPI.W   #24,(A2)       ; SCHON 24 STUNDEN
   BNE.S    NOMIN          ; NEIN
   CLR.W    (A2)           ; STUNDEN AUF NULL
NOMIN:
   MOVEM.L  (A7)+,D0-D7/A0-A6
   BCLR     #5,0XFFFA0F
   RTE
   }
}

