/************************************************************************
 *
 *      OVERSCAN.C      Karsten Isakovic,Berlin 28.04.89
 * 
 *    MEGAMAX C Version 1.2 
 */

/*.......................... HIGH-RES */
    #define HIGH_X     672
    #define HIGH_Y     480
    #define HIGH_OFF  1608
/*.......................... MID-RES  */
    #define MID_X      848
    #define MID_Y      280
    #define MID_OFF   5640
/*.......................... LOW-RES  */
    #define LOW_X      416
    #define LOW_Y      280
    #define LOW_OFF   5640

#include <osbind.h>
extern char *_base;

int  inst_ok;   /* Wurde installiert oder nicht ?                       */
int  RezX;      /* Breite des Bildschirms                               */
int  RezY;      /* Hîhe   des Bildschirms                               */
int  BpL;       /* BytesPerLine , also Bytes pro Bildschirmzeile        */
long LineA;     /* Zeiger auf LineA Variablen                           */
long WorkOut;   /* Zeiger auf das WorkOut-Feld der 'v_opnwk()' aufruf-  */
                /*   enden Funktion (hoffentlich der DESKTOP !)         */
long Back;      /* RÅcksprungAddresse zu dieser Funktion                */
long SaveBasAdd;/* Zwischenspeicher zur Restauration des Desktops nach  */
long SaveVidAdd;/* einem inkompatiblen Programm                         */ 

main()
{
long  keep,prgtop;
int   do_setup();

 Supexec(do_setup);
 switch(inst_ok)
   {
   case 0 : Cconws("\n\rOVERSCAN Version 1.2 installiert\n\r");
            asm { move.l  A7,prgtop(A6) }      /* A7 steht auf Ende und */
            keep = (prgtop+200L)-(long)_base;  /* _base auf Anfang des  */
            Ptermres( keep,0);                 /* Programms             */
            break;
   case 1 : Cconws("\n\r   Kein gÅltiges TOS 1.4 / BETA-TOS");
            Cconws("\n\rOVERSCAN Version 1.2 nicht installiert\n\r");
            Cconin();
   case 2 : Cconws("\n\rOVERSCAN Version 1.2 nicht installiert\n\r");
            break;
   }
}

/******************** NEGATIVE LINE-A VARIABLEN ********************/

#define WKXRez          -0x2b4
#define WKYRez          -0x2b2
#define V_CEL_HT        -0x2e 
#define V_CEL_MX        -0x2c 
#define V_CEL_MY        -0x2a 
#define V_CEL_WR        -0x28 
#define V_REZ_HZ        -0xc  
#define V_REZ_VT        -4    
#define BYTES_LIN       -2    
#define V_PLANES        0
#define WIDTH           2

/*********************** HARDWARE **********************************/

#define GEMTRAP      0x088
#define MEMTOP       0x436
#define RESO         0x44c
#define V_BAS_ADD    0x44e
#define DUMPFLAG     0x4ee
#define SYSBASE      0x4f2
#define HARDCOPY     0x502
#define VID_BASHIGH  0xff8201L
#define VID_BASMID   0xff8203L
#define VID_ISMID    0xff8207L

#define ADD_LEN      0x9000L

do_setup()
{
  asm   {
        movem.l D0-A6,-(A7)
        lea     SaveA4(PC),A0   ; GLOBAL Zeiger A4 retten
        move.l  A4,(A0)         ; 
        move.w  #2,inst_ok(A4)  ; noch nicht installiert
        move.b  VID_BASMID,D0   ; Testen ob der Schalter umgelegt ist
        move    D0,D1           ; Es wird gewartet bis der VideoAddress-
        add     #0x7d,D1        ; ZÑhler bis zum Ende der normalen
Wait1:  cmp.b   VID_ISMID,D1    ; Bildschirmseite hochgezÑhlt hat.
        bne     Wait1           ; Dann wird getestet, ob er auf den
Wait2:  cmp.b   VID_ISMID,D1    ; Anfang zurÅckspringt. Wenn nicht ist
        beq     Wait2           ; der Schalter umgelegt.
        cmp.b   VID_ISMID,D0    ;
        beq     ende            ; Nicht umgelegt -> Beenden
;-----------------------------------------------------------
        move    #1,inst_ok(A4)  ; auf BETA RAMTOS testen
        move.l  #0x170ee,A0     ;
        cmpi.l  #0xe848cec0,(A0); LSR #4,D0 / MULU D0,D7
        bne     RAMTOS1_4       ; Kein BETA-RAMTOS -> Teste TOS 1.4
        bra     TOSok
RAMTOS1_4:
        move.l  #0x17192,A0     ;
        cmpi.l  #0xe848cec0,(A0); LSR #4,D0 / MULU D0,D7
        bne     ROMTOS1_4       ; Kein RAMTOS 1.4  -> Teste ROMTOS 1.4
ROMTOS1_4:
        move.l  SYSBASE,A0      ; _sysbase
        cmpi.w  #0x0104,2(A0)     ; os_version 1.04 ?
        bne     ende            ; Kein ROMTOS 1.4  -> ENDE
TOSok:
        move    #0,inst_ok(A4)  ;
        dc.w    0xA000          ; LineA-Init
        move.l  A0,LineA(A4)    ; Zeiger auf Variablen retten
        lea     OldVec(PC),A0   ; Alten GemTrapVektor retten
        move.l  GEMTRAP,(A0)    ;
        lea     MyGem(PC),A0    ;
        move.l  A0,GEMTRAP      ; und neuen Vektor eintragen
        clr.l   D0              ;
        move.b  RESO,D0         ; 
        cmpi.w  #2,D0           ; Auflîsung HIGH ?
        bne     ende            ; nein -> weiter
        lea     OldHard(PC),A0  ; Alten HardcopyVektor retten
        move.l  HARDCOPY,(A0)   ;
        lea     MyHard(PC),A0   ;
        move.l  A0,HARDCOPY     ; und neuen Vektor eintragen
ende:   
        lea     Patched(PC),A0  ; PatchFlag lîschen
        clr.l   (A0)            ;
        movem.l (A7)+,D0-A6     ;
        bra     end_setup       ; Ende des Setup-Teils
;------------------------------------------------------------------------
SaveA4: move.l  #0,-(A7)        ; (dc.l)  Speicher fÅr GLOBAL-Zeiger
Patched:move.l  #0,-(A7)        ; (dc.l)  Speicher fÅr PatchFlag

        dc.b    "XBRAOVER"      ; XBRA-Protokoll  ! (Ja das ist alles !!)
OldVec: move.l  #0,-(A7)        ; (dc.l)  Alter Vektor
MyGem:
        lea     Patched(PC),A0  ; 
        tst.w   (A0)            ; Ist LineA schon geÑndert ?
        bne     Normal          ;   ja -> weiter
        cmp.w   #0x73,D0        ; Ist es ein VDI-Aufruf ?
        bne.s   Normal          ;   nein -> weiter
        move.l  D1,A0           ; D1 ist Addresse der VDI-Parameterfelder
        move.l  A4,-(A7)        ; A4 Register retten 
        move.l  SaveA4(PC),A4   ; und GLOBAL-Zeiger holen
        move.l  12(A0),WorkOut(A4);  WorkOut-Zeiger speichern
        move.l  (A0),A0         ; VDI-Control[0] entspricht dem VDI-Befehl
        cmpi.w   #1,(A0)        ; ist es Open-WorkStation ?
        bne.s   Norm2           ;    nein-> weiter
        move.l  6(A7),Back(A4)  ; RÅcksprung merken
        lea     PatchIt(PC),A0  ; und PatchIt als RÅcksprung eintragen
        move.l  A0,6(A7)        ;   
Norm2:  move.l  (A7)+,A4        ; A4 Register zurÅckholen
Normal:
        move.l  OldVec(PC),A0   ;
        jmp     (A0)            ; Orginal-Routine ausfÅhren
;------------------------------------------------------------------------
PatchIt:  
        move.l  SaveA4(PC),A1           ; GLOBAL-Zeiger in A1 holen !
        ;--------------------------------------------------------------
        move.l  #0x170ee,A0             ; auf BETA RAMTOS testen
        cmpi.l  #0xe848cec0,(A0)        ; 
        bne     isRAMTOS1_4             ; nein -> TOS 1.4
is_BETATOS1_4:
        move.l  0x522e,A0               ; BETA TOS 
        subi.l  #ADD_LEN,8(A0)          ; Memory-Free-List 
        subi.l  #ADD_LEN,MEMTOP         ;
        move.l  #0xcec0e84f,0x170ee     ; Patch fÅr Scrolling unter TOS
                                        ; MULU D0,D7 / LSR  #4,D7  statt
                                        ; LSR  #4,D0 / MULU Do,D7
        bra     weiter
isRAMTOS1_4:
        move.l  #0x17192,A0
        cmpi.l  #0xe848cec0,(A0)
        bne     isROMTOS1_4
        move.l  0x522e,A0               ; RAMTOS 1.4
        subi.l  #ADD_LEN,8(A0)          ; Memory-Free-List 
        subi.l  #ADD_LEN,MEMTOP         ;
        move.l  #0xcec0e84f,0x17192     ; zweimal Patchen
        move.l  #0xcec0e84f,0x1711d6    ;
        bra     weiter 
isROMTOS1_4:
        move.l  0x5328,A0               ; ROMTOS 1.4 
tst_ROMTOS:
        tst.l   (A0)            ; letzten Eintrag der Memory-Free-List
        beq     do_ROMTOS       ; suchen        
        move.l  (A0),A0         
        bra     tst_ROMTOS
do_ROMTOS:
        subi.l  #ADD_LEN,8(A0)          ; Memory-Free-List 
        subi.l  #ADD_LEN,MEMTOP         ;
        ;---------------------------------------------------------------
weiter: clr.l   D0
        move.b  RESO,D0         ; Jetzige Auflîsung 
low:    bne     mid             ; ist es LOW-RES ?        
        move.w  #LOW_X,RezX(A1) ; 
        move.w  #LOW_Y,RezY(A1) ;
        move.w  #236,BpL(A1)    ;
        move.l  MEMTOP,V_BAS_ADD;
        subi.l  #0x1600L,V_BAS_ADD
        move.l  #LOW_OFF,D0     ; Offset
        bra     set    
        ;---------------------------------------------------
mid:    cmpi.w  #1,D0           ; ist es MID-RES ?
        bne     high            ;   nein -> weiter
        move.w  #MID_X,RezX(A1) ;  
        move.w  #MID_Y,RezY(A1) ;
        move.w  #236,BpL(A1)    ;
        move.l  MEMTOP,V_BAS_ADD;
        subi.l  #0x1600L,V_BAS_ADD
        move.l  #MID_OFF,D0     ; Offset
        bra     set
        ;---------------------------------------------------
high:   move.w  #HIGH_X,RezX(A1);also  HIGHRES 
        move.w  #HIGH_Y,RezY(A1);
        move.w  #100,BpL(A1)    ;
        move.l  MEMTOP,V_BAS_ADD;
        addi.l  #0x2000L,V_BAS_ADD
        move.l  #HIGH_OFF,D1    ; vor dem Bildschirmspeicher
        asr.l   #2,D1           ; RÅcklaufstrahl auf Schwarz setzen
        addq.l  #1,D1           ;
        move.l  V_BAS_ADD,A0    ;
h_clp:  move.l  #-1,(A0)+       ;
        dbf     D1,h_clp        ;
        move.l  #HIGH_OFF,D0    ; Offset 
        ;---------------------------------------------------
set:    move.b  0x44fL,VID_BASHIGH      ; VideoAddresse setzen
        move.b  0x450L,VID_BASMID       ;
        move.l  V_BAS_ADD,SaveVidAdd(A1); VideoAddresse retten
        add.l   D0,V_BAS_ADD            ; Offset anbringen
        move.l  V_BAS_ADD,SaveBasAdd(A1); v_bas_add retten
        move.l  #0x4400,D1              ; Bildschirmspeicher auf Schwarz
        move.l  V_BAS_ADD,A0            ; lîschen
sc_clp: move.l  #-1,(A0)+               ;
        dbf     D1,sc_clp               ;
        bsr     setLineA(PC)            ; LineA Werte eintragen
        move.l  WorkOut(A1),A0          ; 
        move.w  RezX(A1),0(A0)          ; Work_out[0] = Breite
        move.w  RezY(A1),2(A0)          ; Work_out[1] = Hîhe
        lea     Patched(PC),A0          ; den Patch nur einmal ausfÅhren,
        move.l  #-1,(A0)                ;   also setzen wir ein Flag
        move.l  Back(A1),-(A7)          ; Zum 'v_opnwk()' - Aufrufer
        rts                             ;   zurÅckspringen
;------------------------------------------------------------------------
setLineA:
        movem.l D0/A0-A1,-(A7)
        move.l  SaveA4(PC),A1           ; GLOBAL Zeiger in A1 holen !
        move.l  LineA(A1),A0            ; LineA Zeiger holen
        move.w  RezX(A1),V_REZ_HZ(A0)   ; Breite setzen
        move.w  RezX(A1),WKXRez(A0)     ; 
        subi.w  #1,WKXRez(A0)           ; Breite-1
        move.w  RezY(A1),V_REZ_VT(A0)   ; Hîhe   setzen
        move.w  RezY(A1),WKYRez(A0)     ;
        subi.w  #1,WKYRez(A0)           ; Hîhe-1
        move.w  BpL(A1) ,BYTES_LIN(A0)  ; Bytes pro Zeile setzen
        move.w  BpL(A1),WIDTH(A0)       ; 
        move.w  RezX(A1),D0             ;
        asr.w   #3,D0                   ;
        subq.w  #1,D0                   ; Breite/8 -1
        move.w  D0,V_CEL_MX(A0)         ; -> Anzahl Buchstaben pro Zeile
        clr.l   D0                      ;
        move.w  RezY(A1),D0             ;
        divu.w  V_CEL_HT(A0),D0         ;
        subq.w  #1,D0                   ; Hîhe/Buchstabenhîhe -1
        move.w  D0,V_CEL_MY(A0)         ; -> Anzahl Buchstabenzeilen 
        move.w  V_CEL_HT(A0),D0         ; 
        mulu.w  BpL(A1),D0              ; AnzBuchstaben*BytesProZeile
        move.w  D0,V_CEL_WR(A0)         ; -> BlocklÑnge fÅr Scrolling
        movem.l (A7)+,D0/A0-A1
        rts
;------------------------------------------------------------------------
        dc.b    "XBRAOVER"              ;  HARDCOPY nur bei HIGH-RES 
OldHard:move.w  #0,-(A7)                ; (dc.l)
MyHard: movem.l D0-D4/A0-A1/A4,-(A7)    ;
        move.l  SaveA4(PC),A4           ; GLOBAL Zeiger holen
        lea     SaveVidAdd(A4),A0       ; VideoAddressZeiger setzen
        move.b  1(A0),VID_BASHIGH       ;
        move.b  2(A0),VID_BASMID        ; 
        move.l  SaveBasAdd(A4),V_BAS_ADD; v_bas_add setzen
        bsr     setLineA(PC)            ; LineA nochmal setzen (wird zB von
                                        ;                DEGAS verÑndert )
        clr.l   D0                      ;
        move.l  #-1L,D4                 ; Lîschwert (Schwarze Pixel)
        move.l  SaveVidAdd(A4),A1       ;
        move.l  SaveBasAdd(A4),A0       ;
        subq.l  #2,A0                   ; Falls HIGH_OFF nicht /4 teilbar
Hflp:   move.l  D4,(A1)+                ; Vor dem Bildschirm RÅcklauf
        cmpa.l  A0,A1                   ; Pixel auf Schwarz setzen
        blt     Hflp                    ;
        ;----------------------------------
        move.l  SaveBasAdd(A4),A0       ;
        clr.l   D0                      ; Den ungenutzten Bereich im
        clr.l   D1                      ; RÅcklauf auf Schwarz setzen
        move    BpL(A4),D0              ; 
        move    RezX(A4),D1             ; BytesProZeile-Breite/8
        asr     #3,D1                   ; -> Breite des Bereichs
        sub     D1,D0                   ;
        move    RezY(A4),D2             ; Hîhe des Bereichs
        subq    #1,D2                   ;
        subq    #1,D0                   ;
Hlp1:   adda.l  D1,A0                   ; Normalen Bildbereich Åberspringen
        move    D0,D3                   ;
Hlp2:   move.b  D4,(A0)+                ; Bereich lîschen
        dbf     D3,Hlp2                 ;
        dbf     D2,Hlp1                 ;
        ;----------------------------------
        move.l  #250,D0                 ; 1000 Bytes weiterlîschen
        move.l  A0,D0                   ;
        andi.l  #0xffffffeL,D0          ;
        move.l  D0,A0                   ;
Hlp3:   move.l  D4,(A0)+                ;
        dbf     D0,Hlp3                 ;
        move    #-1,DUMPFLAG            ; DumpFlag lîschen
        movem.l (A7)+,D0-D4/A0-A1/A4
        rts
;-------------------------------------------------------------------------
end_setup: 
        }
}

