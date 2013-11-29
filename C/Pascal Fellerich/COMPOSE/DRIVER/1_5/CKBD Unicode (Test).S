               >PART '---: History'

* Composed Characters Extended Keyboard Driver by Pascal Fellerich
* ----------------------------------------------------------------
*
* v0.3 : alle Grundfunktionen erstmals implementiert, noch kein Cookie.
* v0.7 : erste îffentliche Version
* v0.8 : Fehler bei der ParameterÅbergabe in einer internen Funktion behoben
* v0.9 : Register falsch initialisiert. Ist behoben
* v1.0 : 'definitive' Version. Absturz in kcl_hook & bell_hook unter TOS
*        1.0 bis 1.4 behoben! (savarea ist nîtig!!!)

* Desktop Butler James //  by Pascal Fellerich
* --------------------------------------------
* v0.1 : Testrelease, includes CKBD. Uses Cookie 'CKBD'.

* Intelligent Keyboard driver: Composed chars & Mouse Speeder
* -----------------------------------------------------------
*
* v1.2 : Testrelease, includes vectorial mouse speeder.
*        Finished 8-mar-94
*        PL1: 23-mar-94
*        PL2: 26-mar-94 (?final release?)
*        PL3: 03-apr-94 (!final release!) order indiff for deadkey
* v1.3 : Korrigiertes DeadKey (C. Nieber)
* v1.3a: Fehler in der Cookie-Jar Installation behoben
* v1.3b: + Setzen von bit 3 in conterm (BIOS Tastenstatus)
*        + Lîschen von LastC nach COMPOSE-Sequenz (wg. Extkey interferenzen)
*
* v1.4:  (8.12.1995/1.1.1996)
*        + Mask SDMA (MFP I7) Interrupt while executing IKBDSYS Irq.
*          (only if NOT MagicMac or no STE-SDMA)
*        + New Compose-Tables for NVDI 3.0
*        + Deadkey + Space = passed through transparently.
*        + AUTOLOAD cancelled
*        + Cookie Jar installed whenever old jar < own jar!
*
* v1.5:  betatest
*        + Automatic Multichar compose mode
*

VER            equ 1
REV            equ 5

               default 5
               output 'CKBD.PRG'

               endpart
               >PART 'DEFs'

* XBRA & COOIE JAR IDENTIFIER:
xb_id          equ 'CKBD'     ;WHATEVER

STKSIZE        equ 1024       ;Stack wÑhrend INIT Phase
MAXCKENTRIES   equ 32         ;Wieviele Cookie Jar EintrÑge in nachtrÑglich install. CKJ

*
* Funktionsdeklarationen fÅr SETUP-Funktionen:
*
* Der COOKIE enthÑlt *setup();
* C-Deklaration: cdecl long setup(int opcode, ...);
*
* Werte/Bezeichner fÅr opcode, ZUGEHôRIGE weitere Parameter:
*   0  IDENTIFY     gibt in d0 einen Zeiger auf einen C-type ASCIIstring zurÅck
*
*   1  EXTKEY       schaltet EXTKEY-Modus ein/aus bzw. fragt akt. Status ab
*         long setup(EXTKEY, int mode);
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*         return:   vorheriger Wert
*
*   2  COMPOSE      schaltet COMPOSE-Modus ein/aus bzw fragt akt. Status ab
*         long setup(COMPOSE, int mode);
*         mode:     -1 (INQUIRE)
*                   >=0: BITMAPPED:  0/1
*                       bit #0:     OFF/ON
*                       bit #1:     DEC/MULTICHAR MODE
*                       bit #2:     ORDER SENSITIVE NO/YES
*                       bit #3:     EXPLICIT/IMPLICIT COMPOSE
*         return:   vorheriger Wert
*
*   3  ALT_NNN      verwaltet die MSDOS-ALT-ASCII Funktion.
*         long setup(ALT_NNN, int mode);
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*         return:   vorheriger Wert
*
*   4  CKEYTBL      verwaltet die Tastaturtabellen.
*         long setup(CKEYTBL, char *unshift, char *shift, char *caps,
*                                                       char *compose );
*         unshift, shift, caps: Zeiger auf die entsprechenden Tabellen
*                   (siehe XBIOS Keytbl !!!!)
*         compose:  Zeiger auf die Compose-Tabelle.
*         return:   Zeiger auf  struct {
*                                   char    *unshift;
*                                   char    *shift;
*                                   char    *caps;
*                                   comptab *compose;
*                               } XKEYTAB;
*                   darin ist comptab *:
*                                   struct {
*                                       char    primary;
*                                       char    secondary;
*                                       char    composed;
*                                       char    flags;
*                                   } comptab[];
*         Bemerkung: wenn ein Zeiger den Wert 0 oder -1 besitzt, dann wird
*                   dieser Wert intern nicht verÑndert.
*                   Die vier Tabellen werden in einen internen Puffer kopiert,
*                   der Aufrufer braucht die Tabellen also nicht selbst im
*                   Speicher zu behalten.
*
*   5 CBIOSKEYS     setzt die Originaltabellen wieder ein oder schaltet
*                   zwischen den Tabellen hin und her
*         int setup(CBIOSKEYS, switch);
*         switch:   -1  INQUIRE  (returns XKEYTAB - adr only)
*                   >=0: bitmapped.
*                   bit #0: keyboard translation table - SET: use loaded -
*                   bit #1: compose tables             - SET: use loaded -
*         return:  last setup value.
*
*
*   6 DEADKEY       kontrolliert die Toten Tasten...
*         long setup(DEADKEY, short mode, char *deadkeys)
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON), 2 (SETUP)
*         return:   0 oder 1.
*                   Falls bei INQUIRE der char* ungleich NULL ist, wird der
*                   Deadkeystring an diese Stelle geschrieben.
*
*
* Mouse speeder config
* --------------------
*
*   7 MOUSE_CFG:    stellt die Mausbeschleuniger-Parameter ein
*         int setup(MOUSE_CFG, int mode, MSPEEDER_SETUP *mdata);
*         mode: WORD,
*               -1: INQUIRE, fill out MSPEEDER_SETUP structure if ptr set!
*                0: OFF - deactivate Speeder
*                1: ON  - activate Speeder
*                2: SET - install new params
*         return: zeiger auf MSPEEDER_SETUP-Struktur mit den aktiven Daten
*
*         Kontrollstruktur:
*         typedef struct {
*             union {
*                 unsigned resvd    :13;
*                 unsigned lefthand :1;       /* Button map change!?        */
*                 unsigned unused   :1;       /* old feature, removed...    */
*                 unsigned activity :1;       /* Speeder ON/OFF             */
*             } switches;
*             short       polynomial[4];      /* speeder polynomial         */
*             short       rotation;           /* rotation in degrees        */
*             short       ratio;              /* X:Y ratio * 256!           */
*             short       mouse_rez;          /* M.resolution in dpi (130)  */
*             short       screen_rez;         /* screen rez in dpi   ( 72)  */
*         } MSPEEDER_SETUP;
*
*         Die Polynomfaktoren und X-Y-Ratio Werte sind (int)(float_val*256)
*
*

IDENTIFY       equ 0
EXTKEY         equ 1
COMPOSE        equ 2
ALT_NNN        equ 3
CKEYTBL        equ 4
CBIOSKEYS      equ 5
DEADKEY        equ 6

MOUSE_CFG      equ 7          ;Mausbeschleuniger Einstellungen

MAXFUNC        equ 7          ;hîchste funktionsnummer...


*
* Allgemeine Def's
*
INQUIRE        equ -1
OFF            equ 0
ON             equ 1
SET            equ 2

*
* KBD: bitmapped stuff:
*
DEC_MODE       equ %0
MULTICHAR_MODE equ %10
ORDER_SENSITIVE equ %100
IMPLICIT_COMPOSE equ %1000

*
* composetable bitmapped stuff (flags)
*
ORDER          equ 1          ;preserve order flag in tables
ORDER_BITNO    equ 0


* Error Codes:
OK             equ 0          ;no error
ERROR          equ -1         ;general error
E_ILLFUNC      equ -2         ;illegal opcode
E_TABSIZE      equ -3         ;Tabelle zu groû!
E_NOMEM        equ -4         ;interner Speicher zu klein!

*
* XBIOS Opcodes
*
Iorec          equ 14
Keytbl         equ 16
Bioskeys       equ 24
Dosound        equ 32
Kbdvbase       equ 34
Supexec        equ 38

*
* GEMDOS Opcodes
*
Cconws         equ 9
Ptermres       equ 49




*
* SYSTEM VARIABLES
*
memvalid       equ $0420
_resvalid      equ $0426
_resvector     equ $042A
memval2        equ $043A
vblsem         equ $0452      ;VBL aktiviert?
nvbls          equ $0454      ;Anzahl Slots
_vblqueue      equ $0456      ;Ptr to queue
conterm        equ $0484
savptr         equ $04A2
_bufl          equ $04B2      ;Buffer List Ptr
_hz_200        equ $04BA      ;200 Hz System timer
_sysbase       equ $04F2
exec_os        equ $04FE
_p_cookies     equ $05A0      ;Cookie Jar Root Pointer
bell_hook      equ $05AC
kcl_hook       equ $05B0


               endpart

start:    bra       StartUp

; Cookie Jar Extension:
; Commandline bis hier = 128 = 16 EintrÑge
; plus:
               ds.l (MAXCKENTRIES-16)*2,'cJAR'

;********* RESIDENT CODE *******************************************************
               >PART 'XBRA: Defs'
**********************************************************************
* XBRA - UTILITIES                                                   *
*     sollten im Supermode aufgerufen werden, ->BUS ERROR            *
**********************************************************************
XB_MAGIC       equ -12
XB_ID          equ -8
XB_OLDVEC      equ -4
XB_CODE        equ 0
               endpart
               >PART 'KBD: CKBD defs'


* Aufbau der BIOS-Tastencodes:
* typedef struct {
*     char     kbshift;
*     char     scancode;
*     char     null;
*     char     ascii;
* } BIOS_code;
*
IBUF           equ 0
IBUFSIZ        equ 4
IBUFHD         equ 6
IBUFTL         equ 8

NKP_LOWSCAN    equ $67        ;lowest scancode Numeric KeyPad
NKP_HIGHSCAN   equ $70        ;highest....

COMPOSEKEYTICKS equ 400/5     ;400 msec compose key timeout!

               endpart
               >PART 'MSE: Mouse Speeder Defs'

BUTTON_REVERSE equ $F8FAF9FB
BUTTON_REVERS2 equ $FCFEFDFF
BUTTON_NORMAL  equ $F8F9FAFB
BUTTON_NORMA2  equ $FCFDFEFF

SQUARETABSIZ   equ 128        ;max. vectorial speed
MAXSPEED       equ 127*256    ;max. mouse speed

MREZ_REFERENCE equ 100        ;Standard mouse resolution
SREZ_REFERENCE equ 72         ;standard screen resolution


*
* MOUSE SPEEDER CONTROL STRUCTURE
*
;mouse_speeder_control:
               rsreset
MSC_switches:  rs.w 1         ;bitmapped switches
MSC_polynomial:rs.w 4         ;speeder polynomial
MSC_rotation:  rs.w 1         ;rotation angle
MSC_ratio:     rs.w 1         ;aspect ratio compensation
MSC_resolution:rs.w 1         ;mouse resolution in cps
MSC_screenrez: rs.w 1
MSC_sizeof     equ ^^RSCOUNT  ;

               endpart

;********* SYSTEM STUFF ********************************************************
               base A2,varbase
               >PART 'KBD: IKBDSYS + State machine'
******************************************************************
*
* Main IKBDSYS handler & dispatcher
*
******************************************************************
               dc.l 'XBRA',xb_id,0
MacKBDhandler:
          movea.l   kbd_iorec(pc),a0    ;Iorec holen
          move.w    IBUFTL(a0),-(sp)    ;alten Tail-Index merken
          movea.l   MacKBDhandler+XB_OLDVEC(pc),a0
          jsr       (a0)                ;Standard-IKBD-Routine ausfÅhren
          movea.l   kbd_iorec(pc),a0    ;Iorec zurÅckholen
          move.w    IBUFTL(a0),d1       ;neuen Tail-Index holen
          lea       varbase(pc),a2
          movea.l   nextstate(pc),a1    ;STATE MACHINE!
          cmp.w     (sp)+,d1            ;test for key
          jmp       (a1)                ;kontextsensitiv...

               dc.l 'XBRA',xb_id,0
KBDhandler:
          bclr      #7,$FFFFFA13.w      ;maskiere Sound-DMA Interrupts
          movea.l   kbd_iorec(pc),a0    ;Iorec holen
          move.w    IBUFTL(a0),-(sp)    ;alten Tail-Index merken
          movea.l   KBDhandler+XB_OLDVEC(pc),a0
          jsr       (a0)                ;Standard-IKBD-Routine ausfÅhren
          movea.l   kbd_iorec(pc),a0    ;Iorec zurÅckholen
          move.w    IBUFTL(a0),d1       ;neuen Tail-Index holen
          lea       varbase(pc),a2
          movea.l   nextstate(pc),a1    ;STATE MACHINE!
          bset      #7,$FFFFFA13.w      ;gib SDMA Interrupts frei
          cmp.w     (sp)+,d1            ;test for key
          jmp       (a1)                ;kontextsensitiv...
* FÅr angesprungene Funktion:
* Wenn Flags = NE dann wurde eine neue Taste gedrÅckt
*              EQ dann wurde evtl. eine Shift-Taste betÑtigt.
* Register: a0: Iorec Pointer
*           d1: new tail index
******************************************************************


******************************************************************
*
* Normal-Zustand: ALT/CONTROL Taste nicht gedrÅckt
*
******************************************************************
State_Normal_operation:
          bne.s     normal_key_pressed  ;normal key -> nothing!
          movea.l   kbshift(pc),a0      ;Ptr to _sys_kbshift_
          move.b    (a0),d0             ;get shiftstate
          cmp.b     lastshift(a2),d0    ;verÑndert?
          beq.s     exit_nop            ;nein, alles weitere Åberspringen
          move.b    d0,lastshift(a2)    ;sonst aktuellen Status merken
          btst      #3,d0               ;ALTERNATE ?
          bne.s     make_alt1
          andi.b    #%100,d0            ;Control unter anderem ??
          bne.s     make_control1
exit_nop: rts

;
; Normaler Tastencode, evtl mit Shift:
; hier setzt auch die DEADKEY Routine mit ein!
;
normal_key_pressed:
          bset      #3,conterm.w
          movea.l   (a0),a1             ;    movea.l   IBUF(a0),a1
          move.l    0(a1,d1.w),d0       ;    kompletten Tastencode merken
          move.l    compose_subroutine(pc),-(sp)
          rts                           ;jump to compose subroutine


; Alternate gedrÅckt -> State transition nach ALTPRESSED
make_alt1:
          move.l    #State_alternate_pressed,nextstate(a2)
          moveq     #COMPOSEKEYTICKS,d0 ;5*ticks msec warten
          add.l     _hz_200.w,d0
          move.l    d0,alt_timeout(a2)
          rts                           ;Fertig


; Control gedrÅckt -> State Transition nach CONTROLPRESSED
make_control1:
          move.l    #State_control_pressed,nextstate(a2)
          rts

******************************************************************
*
* Prepare: ALT ist gedrÅckt. Warte auf Loslassen:
*
******************************************************************
State_alternate_pressed:
          bne.s     other_key           ;sofort-Abbruch
          movea.l   kbshift(pc),a1      ;Ptr to _os_kbshift
          move.b    (a1),d0
          cmp.b     lastshift(a2),d0    ;was geÑndert?
          beq.s     exit_prep           ;nein, skip

          move.b    d0,lastshift(a2)    ;geÑnderten Status merken
          andi.b    #$0F,d0             ;CAPS ausmaskieren
          bne.s     other_shift1        ;falscher Shift-Status!!

; ALT released:
          btst      #0,composemode(a2)  ;COMPOSE feature enabled?
          beq       resetstate          ;disabled -> back to normal op.

          move.l    _hz_200.w,d0        ;sonst:
          cmp.l     alt_timeout(pc),d0  ;Timeout-Bedingung testen
          bhs       resetstate          ;schon zu lange her!

; Deadkey char composition pending?
          cmpi.l    #Compose_deadkey,compose_subroutine(a2)
          bne.s     select1             ;no, normal operation

; otherwise output dead character first
          movea.l   (a0),a1             ;IBUF(a0),a1
          move.l    lastc(pc),d0        ;last read character
          bsr       K_insert            ;return it!

select1:  lea       Compose_DEC_first(pc),a1
          btst      #1,composemode(a2)  ;DEC/MULTICHAR mode
          beq.s     select2             ;->DEC mode selected
          lea       Compose_first(pc),a1
select2:  move.l    a1,compose_subroutine(a2)
          move.l    #State_Normal_operation,nextstate(a2)
          movea.l   kcl_hook.w,a0       ;COMPOSE-CLICK als akustisches Signal!
          jmp       (a0)                ;KLICK!

other_shift1:
;          move.b    (a1),lastshift(a2)
          move.l    _hz_200.w,alt_timeout(a2)
exit_prep:
          rts

other_key:                              ;sonstige Taste -> timeout setzen
          move.l    _hz_200.w,alt_timeout(a2)
          tst.b     alt_nnnmode(a2)     ;das hier erlaubt?
          beq.s     exit_prep1          ;nein.
          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1
          move.w    0(a1,d1.w),d0       ;scancode holen
          subi.b    #NKP_LOWSCAN,d0     ;im Zehnerblock?
          blo.s     exit_prep1
          cmpi.b    #NKP_HIGHSCAN-NKP_LOWSCAN,d0
          bhi.s     exit_prep1

* alt-nnn Sequenz begonnen -> ersten CHAR mitnehmen.
          move.l    #State_Alt_NNN,nextstate(a2) ;soso!
          clr.w     altn_char(a2)       ;NULLchar
          clr.w     altn_count(a2)      ;Reset counter
          bra       altn_add            ;Zeichen in d0 dazu!

* Spezial Exit: -> wegen 'Fremd'-ALT-NNN kann ein 'Doppel-irq' auftreten
exit_prep1:
          movea.l   kbshift(pc),a1      ;Ptr to _os_kbshift
          move.b    (a1),d0
          btst      #3,d0               ;ALT noch gedrÅckt?
          bne.s     exit_prep           ;ja -> nichts Ñndern
          move.b    d0,lastshift(a2)
resetstate:                             ;sonst anderen Status annehmen.
          move.l    #State_Normal_operation,nextstate(a2)
          rts

               endpart
               >PART 'KBD: Composed Characters'
******************************************************************
*
* Compose mode not active
* -> then check for AUTOTRIGGER and DeadKey!
*
******************************************************************
Compose_idle:
;          move.l    d0,lastc(a2)        ; store char
;          lea       Dead_enabletab(pc),a1 ;  Deadkey on/off Tabelle
;          andi.w    #$FF,d0             ; convert to table index
;          move.b    0(a1,d0.w),d0       ; get enable bits
;          btst      #0,d0               ; is it a dead key?
;          bne.s     make_dead
;          btst      #1,d0               ; implicit compose trigger character?
;          beq.s     mquit               ; yes -> branch to Compose Multi
;          move.l    #Compose_multi,compose_subroutine(a2)
;mquit:    rts
;make_dead:
;          move.l    #Compose_deadkey,compose_subroutine(a2)
;          bra.s     K_remove            ;remove key from buffer & RTS

	move.l	d0,lastc(a2)		; store char
	tst.b	AutoMultiFlag(a2)	; Automulti enabled?
	bne.s	do_automulti		; yes -> disregard deadkeys
	tst.b	dead_onoff(a2)		; deadkey enabled?
	bne.s	check_deadkeys
	rts

do_automulti:
	move.l	#Compose_multi,compose_subroutine(a2)
	rts

check_deadkeys:
	lea	Unicode_DeadKey_String(pc),a1
	;?????? dead keys can only be ASCII or mapped UNIcodes?
	;?????? here the dead keys are stored as unicodes (numerically sorted)
try_next_deadkey:
	move.w	(a1)+,d2
	beq.s	not_a_deadkey		; end of list reached
	cmp.w	d2,d0			; list must be sorted!
	beq.s	is_a_deadkey		; deadkey found
	bcs.s	try_next_deadkey
	rts

; Deadkey gedrÅckt -> remove char & change state
is_a_deadkey:
	move.l	#Compose_deadkey,compose_subroutine(a2)
	bra.s	K_remove


******************************************************************
*
* Compose_1: der erste Buchstabe wird nun erwartet
* (DEC MODE)
*
* in: a0: IOREC ptr
*     d1: tail index
******************************************************************
Compose_DEC_first:
;          beq.s     nokey1              ;nichts gedrÅckt...
;          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1
;          move.l    0(a1,d1.w),d0       ;Tastencode holen
          move.l    d0,lastc(a2)        ;und merken
          bsr.s     idle_and_remove     ;Zeichen zurÅckbehalten!
          tst.w     d0                  ;NULL ignorieren
          beq.s     nokey1
          cmpi.w    #8,d0               ;BACKSPACE ???
          beq.s     nokey1
          cmpi.w    #27,d0              ;ESCAPE ???
          beq.s     nokey1
          move.l    #Compose_DEC_second,compose_subroutine(a2)
nokey1:   rts

; remove char from buffer & reset state!
idle_and_remove:
          move.l    #Compose_idle,compose_subroutine(a2)

* remove: nimmt die zuletzt gedrÅckte Taste zurÅck
* in:   a0: IorecPtr
K_remove: move.w    IBUFTL(a0),d1       ;last write position
          subq.w    #4,d1               ;eine Position weniger
          bpl.s     rem1                ;unter Null?
          move.w    IBUFSIZ(a0),d1      ;inverse wraparound
          subq.w    #4,d1
rem1:     move.w    d1,IBUFTL(a0)       ;neu setzen
          rts


******************************************************************
*
* Compose_2: der zweite Buchstabe wird erwartet!
*
* Dual Character, No Echo mode
*
******************************************************************
Compose_DEC_second:
;          beq.s     nokey1              ;nichts passiert!
;          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1
;          move.l    0(a1,d1.w),d0       ;Tastencode holen
          tst.w     d0                  ;NULL?
          beq.s     idle_and_remove
          cmpi.w    #8,d0               ;BACKSPACE?
          beq.s     idle_and_remove
          cmpi.w    #27,d0              ;ESC?
          beq.s     idle_and_remove

          move.w    lastc+2(pc),d2      ;letzten gÅltigen Code zurÅck

;          lsl.w     #8,d2               ;last char = highbyte
;          move.b    d0,d2               ;d2.w = suchzeichen
	swap	d2		; last unicode char = highword
	move.w	d0,d2		; current unicode = lowword

          bsr       bsearch             ;binary search
          bne.s     ccfound             ;?OK

; darfs auch umgekehrt sein (Hauptschalter)
          btst      #2,composemode(a2)  ;ORDER SENSITIVE?
          bne.s     ccnotfnd            ;yeah.

          rol.w     #8,d2               ;sonst vertauschen
          bsr       bsearch             ;nochmal suchen
;bsearch setzt Z-flag wenn nichts gefunden wird.
          beq.s     ccnotfnd
;Zeichen beim zweiten Versuch gefunden - ist es erlaubt (ORDER flag?)
          btst      #ORDER_BITNO,1(a0)
          bne.s     ccnotfnd

; char gefunden!
ccfound:  move.l    d0,0(a1,d1.w)       ;mit neuem Zeichen Åberschreiben
          clr.l     lastc(a2)           ;und bei Null anfangen
          move.l    #Compose_idle,compose_subroutine(a2)
          rts

ccnotfnd: movea.l   kbd_iorec(pc),a0
          bsr.s     K_remove
          move.l    #Compose_idle,compose_subroutine(a2)
          movea.l   bell_hook.w,a0      ;warning bell
          jmp       (a0)

******************************************************************
*
* Compose_3: der erste Buchstabe wird nun erwartet
* (MULTICHAR MODE!)
******************************************************************
Compose_first:
;          beq.s     nokey2              ;nichts gedrÅckt...
;          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1
;          move.l    0(a1,d1.w),d0       ;Tastencode holen
          move.l    d0,lastc(a2)        ;MERKEN!
          tst.b     d0                  ;NULL ignorieren
          beq.s     resetstate2
          cmpi.b    #8,d0               ;BACKSPACE ???
          beq.s     resetstate2
          cmpi.b    #27,d0              ;ESCAPE ???
          beq.s     reset_remove2
          move.l    #Compose_multi,compose_subroutine(a2)
;nokey2:
          rts


******************************************************************
*
* Compose_multi: ein weiterer Buchstabe wird nun erwartet
*         ESC bricht die Sequenz ab (termination character)
*
* MultiChar + Direct Echo mode.
*
******************************************************************
Compose_multi:
;          beq.s     nokey2              ;nichts passiert!
          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1
          move.l    0(a1,d1.w),d0       ;Tastencode holen
          tst.b     d0                  ;NULL?
          beq.s     resetstate2
          cmpi.b    #8,d0               ;BACKSPACE?
          beq.s     resetstate2
          cmpi.b    #27,d0              ;ESC?
          beq.s     reset_remove2

          move.w    lastc+2(pc),d2      ;letzten gÅltigen Code zurÅck

          move.l    d0,lastc(a2)        ;aktuellen Tastencode speichern
          lsl.w     #8,d2               ;last char = highbyte
          move.b    d0,d2               ;d2.w = suchzeichen

          pea       (a0)                ;fast idem EXTKEY!
          bsr.s     bsearch             ;binary search
          bne       cmfound             ;?OK

; darfs auch umgekehrt sein?
          btst      #2,composemode(a2)  ;ORDER SENSITIVE?
          bne.s     cmnotfnd            ;yeah.

          rol.w     #8,d2               ;sonst vertauschen
          bsr.s     bsearch             ;nochmal suchen
;bsearch setzt Z-flag wenn nichts gefunden wird.
          beq.s     cmnotfnd
	bra.s cmfound
	
;Zeichen beim zweiten Versuch gefunden - ist es erlaubt (ORDER flag?)
;U          btst      #ORDER_BITNO,1(a0)
;U          beq       cmfound

; char gefunden!
; cmfound: -> siehe kbfound

; nichts gefunden -> falls aktuelles Zeichen ein 'Triggerzeichen' ist,
; in State_Compose_Multi bleiben.

cmnotfnd: addq.w    #4,sp


;UNICODE: vun hei un ass nach neischt modifizeiert.
Den Automulti mode muss ugepasst gin

          lea       Dead_enabletab(pc),a1 ;  Deadkey on/off Tabelle
          move.w    lastc+2(pc),d0
          andi.w    #$FF,d0             ; convert char code to table index
          move.b    0(a1,d0.w),d0       ; get enable bits
          btst      #1,d0               ; implicit compose trigger character?
          bne.s     cmquit              ; yes -> stay in current state

resetstate2:
          move.l    #Compose_idle,compose_subroutine(a2)
cmquit:   rts

reset_remove2:
          move.l    #Compose_idle,compose_subroutine(a2)
          bra       K_remove

               endpart
               >PART 'KBD: binary search in ctab'
******************************************************************
*
* Binary search in der comptab-Tabelle
* ------------------------------------
* in:   d2.l: primary_char >> 16 | secondary_char
* out:  d0.l: 0L bei Fehler (nicht gefunden) oder Unicode (Long!)
*       a0: Adresse der Sequenz in der Tabelle   NOT!!!!!
*       Z-Flag gesetzt wenn nichts gefunden
* Regs: d0/a0
******************************************************************
bsearch:  movem.l   d1/d3-d4,-(sp)
          movea.l   keytbl_compose(pc),a0 ;  lea comptab(pc),a0
          moveq     #0,d0               ;low index
          move.w    tabsize(pc),d1      ;high index
bsloop:   move.w    d0,d3
          add.w     d1,d3		; d3 = (d1+d0)/2 (= mid index)
          lsr.w     #1,d3               ;i=(l+r)>>1
          move.w    d3,d4
;          lsl.w     #2,d4		; offset = index*4

; for 3 word entries (48 bit):
;	mulu	#6,d4
; or, alternatively:
	lsl.w	#2,d4		; *4
	add.w	d3,d4		; +1
	add.w	d3,d4		; +1 [ d3 = 4*d4 + d4 + d4 ]

;          cmp.w     0(a0,d4.w),d2       ;Obere 2 bytes vergleichen
	cmp.l	(a0,d4.w),d2	; compare both words
          beq.s     bsfound             ;schon gefunden
          bcc.s     bshigh
          cmp.w     d3,d0
          beq.s     bsnotfnd
          move.w    d3,d1
          bra.s     bsloop
bshigh:   cmp.w     d3,d0
          beq.s     bsnotfnd
          move.w    d3,d0
          bra.s     bsloop
bsfound:  moveq     #0,d0
;          lea       2(a0,d4.w),a0       ;Adresse Ersatzzeichen
;          move.b    (a0),d0             ;hole Ersatzzeichen
	move.w	4(a0,d4.w),d0		; hole 16 bit Ersatzzeichen
	
          movem.l   (sp)+,d1/d3-d4
          rts
bsnotfnd: moveq     #0,d0               ;nixda
          movem.l   (sp)+,d1/d3-d4
          rts

               endpart
               >PART 'KBD: ExtKey fashion c-chars'
******************************************************************
*
* Extkey: CONTROL ist gedrÅckt. Mîglicherweise Extkey-Kombinationen!!
*
******************************************************************
State_control_pressed:
          bne.s     ext_key             ;Aha. Control-Kombination erwÅnscht?
          movea.l   kbshift(pc),a1      ;Ptr to _os_kbshift
          btst      #2,(a1)             ;ist CONTROL noch gedrÅckt?
          bne.s     exit_cntrl          ;jawoll.
          btst      #3,(a1)             ;ALT noch gedrÅckt?
          bne.s     exit_altpressed
          move.l    #State_Normal_operation,nextstate(a2)
          rts
exit_altpressed:                        ;Control losgelassen, ALT gedrÅckt!!
          move.l    #State_alternate_pressed,nextstate(a2)
          move.l    _hz_200.w,alt_timeout(a2)
          rts

exit_cntrl:
          move.b    (a1),lastshift(a2)
exit_xkbd:
          rts


; jetzt kommt evtl. eine Spezialkombination!

ext_key:  tst.b     extkeymode(a2)      ;aktiv?
          beq.s     exit_xkbd           ;nî, Abbruch
          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1
          move.w    0(a1,d1.w),d0       ;nur scancode holen!!
          cmpi.b    #$78,d0             ;Spez. ALT-Scan-Code
          bcs.s     kbdrv1              ;-->Nein!
          subi.b    #$76,d0             ;Umrechnen auf normale ScanCodes
kbdrv1:   ext.w     d0                  ;highbyte lîschen (da scancode Û$7F !)
          movea.l   kbshift(pc),a1
          move.b    (a1),d2             ;shiftcodes
          movea.l   sys_keytbl(pc),a1   ;TOS systemadresse
          andi.b    #%11,d2             ;L-Shift oder R-Shift?
          beq.s     kbdrv2              ;nicht gedrÅckt
          movea.l   4(a1),a1            ;Shift-Tabelle benutzen
          bra.s     kbdrv3
kbdrv2:   movea.l   (a1),a1             ;Normal-tabelle benutzen
kbdrv3:   move.w    lastc+2(pc),d2
          lsl.w     #8,d2               ;vorherigen ASCII code ins highbyte
          move.b    0(a1,d0.w),d2       ;korresp. ASCII wert holen
          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1

;bsearch zerstîrt a0 und d0 !!
          pea       (a0)
          bsr       bsearch             ;binary search
          bne.s     kbfound             ;?OK

;-> nur wenn NICHT order sensitive !!
;          rol.w     #8,d2               ;sonst vertauschen
;          bsr       bsearch             ;nochmal suchen
;          bne.s     kbfound             ;OK?
* nichts gefunden -> also NORMAL-BEHANDLUNG!

          addq.l    #4,sp               ;stack aufrÑumen
          move.l    0(a1,d1.w),lastc(a2) ;Zeichen aber auch merken!
          rts

* Kombination gÅltig & gefunden -> reinfummeln.
cmfound:
kbfound:  move.l    #$0E0008,0(a1,d1.w) ;mit BACKSPACE Åberschreiben
          movea.l   (sp)+,a0
*
* Einstiegspunkt -> INSERT CHAR.
* in: d0: new CHAR / d1: tail index / a0: iorec / a1: iorec.buffer
*
K_insert: addq.w    #4,d1               ;Tail-Index erhîhen
          cmp.w     IBUFSIZ(a0),d1
          bcs.s     insrt
          moveq     #0,d1               ;Wrap around
insrt:    cmp.w     IBUFHD(a0),d1       ;Puffer voll?
          beq.s     insrt2              ;Abbruch. Passiert normalerw. nie!
          move.w    d1,IBUFTL(a0)       ;neuen Tail-Index speichern
insrt1:   move.l    d0,0(a1,d1.w)       ;Neues Zeichen in Buffer schreiben
          move.l    d0,lastc(a2)        ;auch dorthin!
insrt2:   rts

               endpart
               >PART 'KBD: MS DOS ALT-NNN chars'
******************************************************************
*
* ALT-Zehnerblock ist gedrÅckt worden
*
******************************************************************
State_Alt_NNN:
          beq.s     alt_shiftstate      ;Shiftstatus testen
          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1

          move.w    0(a1,d1.w),d0       ;SCANcode holen
          subi.b    #NKP_LOWSCAN,d0     ;im Zehnerblock?
          blo.s     altn_resrem         ;NO Numeric KeyPad
          cmpi.b    #NKP_HIGHSCAN-NKP_LOWSCAN,d0
          bhi.s     altn_resrem         ;nicht im num. Bereich -> Puffer reset
*
* altn_add: weiterer ScanCode dazu. Bei OverFlow wird ein Zeichen abgegeben
* in: d0 scanCode-highscan (muû korrekt sein)
* d1: IBUFTL / a0: iorec / a1: iorec.buffer
altn_add: ext.w     d0
          move.b    altn_scantab(pc,d0.w),d0 ;in d0.w nun der ASCII wert
          move.w    altn_char(pc),d2
          mulu      #10,d2
          add.w     d0,d2               ;neuen ASCII code berechnen
          cmpi.w    #256,d2
          bge.s     altn_flush          ;overflow -> empty buffer
          move.w    d2,altn_char(a2)    ;merken
          addq.w    #1,altn_count(a2)   ;noch ein Buchstabe...
          cmpi.w    #3,altn_count(a2)   ;Grenze erreicht?
          bge.s     altn_flush          ;auch hier entleeren ...
          bra       K_remove            ;ansonsten remove char & return to sys.

alt_released:
          move.l    #State_Normal_operation,nextstate(a2)
          move.b    (a1),lastshift(a2)
          tst.w     altn_count(a2)      ;Åberhaupt gefÅllt?
          beq.s     altn_reset          ;nî.

          movea.l   (a0),a1             ;get iorec.buffer
          moveq     #0,d0
          move.w    altn_char(a2),d0
          bra.s     K_insert            ;einfÅgen...
          rts
; ALT noch immer gedrÅckt?
alt_shiftstate:
          movea.l   kbshift(pc),a1
          btst      #3,(a1)
          beq.s     alt_released        ;nein, jetzt nicht mehr
          rts
*
* altn_flush: leert den Puffer und gibt ggf. ein ASCII Zeichen ab.
* -> der Tastaturpuffer darf noch nicht verÑndert worden sein
*    da das letzte Zeichen (IBUFTL!) einfach Åberschrieben wird.
* in: d1: IBUFTL / a0: iorec / a1: iorec.buffer
altn_flush:
          moveq     #0,d0
          move.w    altn_char(pc),d0    ;Abzugebendes Zeichen
          move.l    d0,0(a1,d1.w)       ;in den Tastaturpuffer!
          move.l    d0,lastc(a2)        ;und fÅr weitere Zwecke merken
*
* altn_reset: lîscht den Puffer.
altn_reset:
          clr.w     altn_char(a2)
          clr.w     altn_count(a2)
          rts
*
* altn_resrem: lîscht Puffer & entfernt Zeichen aus Tast.puffer
altn_resrem:
          clr.w     altn_char(a2)
          clr.w     altn_count(a2)
          bra       K_remove            ;entfernen & to system.


altn_scantab:  dc.b 7,8,9,4,5,6,1,2,3,0 ;interne öberstzungstabelle

               endpart
               >PART 'KBD: DeadKey'
******************************************************************
*
* Deadkey: der letzte Buchstabe war eine 'tote Taste'.
*
******************************************************************
Compose_deadkey:
;          beq.s     dead_exit           ;Shifttasten -> nichts
;          movea.l   (a0),a1             ;movea.l   IBUF(a0),a1
;          move.l    0(a1,d1.w),d0       ;aktuellen Tastencode holen
; Taste betÑtigt: So oder so wird DEADKEY abgebrochen
          move.l    #Compose_idle,compose_subroutine(a2)
          tst.b     d0                  ;ASCII NULL?
          beq.s     dknotfnd            ;      -> beide Zeichen durchgeben!
          cmpi.b    #32,d0              ;SPACE?
          beq.s     dknotfnd            ;      -> beide Zeichen durchgeben!
          cmpi.b    #8,d0               ;BACKSPACE?
          beq       K_remove            ;      -> verschlucke voriges Zeichen
          cmpi.b    #27,d0              ;ESC?
          beq       K_remove            ;      -> verschlucke voriges Zeichen
          move.w    lastc+2(pc),d2      ;letzten gÅltigen Code zurÅck
          cmp.b     d0,d2               ;identisches Zeichen? (2mal gedrÅckt?)
          beq.s     dkpassthrough       ;      -> passthrough

          lsl.w     #8,d2               ;sonst: last char ins highbyte
          move.b    d0,d2               ;this char ins lowbyte
          rol.w     #8,d2               ;Byte order vertauschen (Nebenzeichen zuerst!)

          bsr       bsearch             ;Suchen
          bne.s     dkfound             ;OK?
          rol.w     #8,d2               ;sonst vertauschen
          bsr       bsearch             ;nochmal suchen
          bne.s     dkfound

; nichts gefunden (Transparenz): Alten Buchstaben zuerst schicken, dann den aktuellen!
dknotfnd:
          movea.l   kbd_iorec(pc),a0
          move.l    0(a1,d1.w),d0       ;aktuellen Tastencode holen
          move.l    lastc(pc),0(a1,d1.w) ;..diesen Code Åberschreiben
          bra       K_insert            ;und den aktuellen Code wieder einfÅgen

; passthrough: das vorige Zeichen (lastc) wird wieder eingesetzt
dkpassthrough:
          move.l    lastc(pc),d0

; char gefunden: aktuellen Buchstaben durch neuen ersetzen
dkfound:  move.l    d0,0(a1,d1.w)       ;Zeichen reinfummeln
dead_exit:
          rts

               endpart
               >PART 'MSE: Mouse speeder Code'
*
* Maus-beschleuniger Opus 3
*
* Operationen:
*  0. Mausknopf-mapping
*  1. Main switch
*  2. ALT key disables
*  3. Berechnung der effektiven Geschwindigkeit SQRT(x^2+y^2)
*  4. Table-lookup zur Bestimmung des Speedup-faktors
*  5. SeitenverhÑltniskorrektur oder Achsenkreuzrotation
*

* Translate-Tabelle fÅr Mausklicks:
* Wertebereich: $F8..$FB
buttonset:     dc.b $F8,$F9,$FA,$FB
               dc.b $FC,$FD,$FE,$FF
buttonmap      equ *

*
* Aufruf der Beschleuniger durch TOS - MOUSESYS:
*
               dc.l 'XBRA',xb_id,0
mouse_sys:
          move.l    mouse_sys+XB_OLDVEC(pc),-(sp) ;RTS Adresse
; 1. Mausknopf-mapping
          move.b    (a0),d0             ;get buttondata
          ext.w     d0                  ;to WORD
          move.b    buttonmap(pc,d0.w),(a0) ;translate!
          movea.l   kbshift(pc),a1
; 2. 'Hauptschalter'
          btst      #0,msc_switches+1   ;on/off switch
          beq.s     mse_inactive
          btst      #3,(a1)             ;ALT gedrÅckt?
          bne.s     mse_inactive        ;ja -> quit
; 3. berechne Speed-vektor                v  = SQRT(x^2+y^2)
;    und hole Speedup-faktor aus Tabelle: a  = P(v)/v
          move.b    MouseX(a0),d0       ;Delta-X info
          ext.w     d0
          mulu      d0,d0               ;x^2
          move.b    MouseY(a0),d2       ;Delta-Y info
          ext.w     d2
          mulu      d2,d2               ;y^2
          add.w     d0,d2               ;x^2+y^2
          beq.s     mse_inactive        ;Null = unzulÑssig!
* isqrt (Integer SQuare RooT)
* Binary search in der SQRT Tabelle
* ---------------------------------
* in:   d2.w: x
* out:  d0.l: SQRT(x), nÑchster Integer Wert
* Regs: d0/d1/a1
*isqrt:
          movem.l   d3-d4,-(sp)
          lea       squaretab(pc),a1
          moveq     #0,d0               ;low
          move.w    #SQUARETABSIZ,d1    ;high
isqloop:  move.w    d0,d3
          add.w     d1,d3
          lsr.w     #1,d3               ;i=(l+r)>>1
          cmp.w     d3,d0               ;if (i==l) break;
          beq.s     isqfound
          move.w    d3,d4               ;else { calc_offset()
          add.w     d4,d4               ;*2 (WORD)
          cmp.w     0(a1,d4.w),d2       ;vergleichen
          beq.s     isqfound            ;gefunden
          bcc.s     isqhigh             ;obere HÑlfte
          move.w    d3,d1               ;r=i
          bra.s     isqloop
isqhigh:  move.w    d3,d0               ;l=i
          bra.s     isqloop
isqfound: move.w    d3,d0               ;d0=index=square root
          movem.l   (sp)+,d3-d4

; 4. Table lookup:
          add.w     d0,d0
          lea       mse_speeduptable(pc),a1
          move.w    0(a1,d0.w),d1       ;der Speedup-Faktor

; 5. Nichts, SeitenverhÑltniskorrektur oder Rotation
          movea.l   speedervec(pc),a2
          jmp       (a2)

* Verschiedene Modi:
*  0. NOP
*  1. Speedup & buttons only
*  2. Speedup, Buttons & correct aspect ratio
*  3. Speedup, Buttons, Rotate & correct aspect ratio

mse_inactive:
          rts

mse_accelerate:
          lea       mse_rest(pc),a1     ;mouse data remainders
          move.b    MouseX(a0),d0       ;Delta-X info
          ext.w     d0
          muls      d1,d0               ;speedup x
          add.w     (a1),d0             ;Rest_X(a1) ;vom letzten Mal
          move.b    d0,Rest_X+1(a1)     ;MOD 256 -> store
          lsr.w     #8,d0               ;DIV 256
          move.b    d0,MouseX(a0)
          move.b    MouseY(a0),d0       ;Delta-Y info
          ext.w     d0
          muls      d1,d0
          add.w     Rest_Y(a1),d0
          move.b    d0,Rest_Y+1(a1)
          lsr.w     #8,d0
          move.b    d0,MouseY(a0)
          rts

mse_ratiocorrection:
          lea       mse_rest(pc),a1     ;mouse data remainders
          move.b    MouseX(a0),d0       ;Delta-X info
          ext.w     d0
          muls      d1,d0
          add.w     (a1),d0
          move.b    d0,Rest_X+1(a1)
          lsr.w     #8,d0
          move.b    d0,MouseX(a0)
          move.b    MouseY(a0),d0       ;Delta-Y info
          ext.w     d0
          muls      d1,d0
          muls      mse_xyratio(pc),d0
          add.l     Rest_Y(a1),d0
          move.w    d0,Rest_Y+2(a1)     ;16-bit Rest (MOD 65536)
          swap      d0
; !note: y can be greater than +-127!! -> check is necesary
;          cmpi.w    #127,d0
;          ble       rtchk
;          move.w    #127,d0
;          bra       rtchk1
;rtchk:    cmpi.w    #-128,d0
;          bgt       rtchk1
;          move.w    #-128,d0
;rtchk1:
          move.b    d0,MouseY(a0)
          rts                           ;bye bye

mse_rotate:
          lea       mse_rest(pc),a1     ;mouse data remainders
          move.b    MouseX(a0),d0       ;Delta-X info
          ext.w     d0
          muls      d1,d0               ;speedup x
          move.b    MouseY(a0),d2       ;Delta-Y info
          ext.w     d2
          muls      d1,d2               ;speedup y
          lea       mse_rmatrix(pc),a2
          move.w    d0,-(sp)            ;store delta_x
          muls      (a2)+,d0            ;Matrixelement a11
          move.w    d2,d1               ;delta_y
          muls      (a2)+,d1            ;Mat. a12
          add.l     d1,d0               ;x" = x'*a11+y'*a12
          add.l     (a1),d0             ;Rest_X(a1) ;letzten Rest holen
          move.w    d0,Rest_X+2(a1)     ;16 bit Rest sichern
          swap      d0                  ;8 bit mouse-x displacement!!!
          move.b    d0,MouseX(a0)
          move.w    (sp)+,d0            ;delta_x holen
          muls      (a2)+,d0            ; Mat. a21
          move.w    d2,d1               ;delta_y
          muls      (a2)+,d1            ; Mat. a22
          add.l     d1,d0               ;y" = x'*a21+y'*a22
          add.l     Rest_Y(a1),d0
          move.w    d0,Rest_Y+2(a1)     ;16 bit Rest
          swap      d0                  ;8 bit mouse-y displacement!!!
          move.b    d0,MouseY(a0)
          rts                           ;back to TOS

               endpart

;********* SETUP CODE / COOKIE FN DISPATCHER ***********************************
               base A5,varbase
               >PART 'VBL: Vertical Blank Activities'
*
* Erster Slot, damit wird festgestellt wann GEM sich installiert...
*
* Funktionsweise: die Variable 'sema_gemslot' fungiert als Schieberegister.
*  VBLSlot0 setzt immer das hîchstwertige Bit auf 1.
*  VBLSlotn schiebt es eine Stelle nach rechts. FÑllt Slot0 weg, so erscheint
*  8 VBL's spÑter ein Nullbit rechts aus dem Schieberegister -> GEM hat
*  zugeschlagen, die 2 Vektoren mÅssen neu initialisiert werden.
*
               dc.l 'XBRA',xb_id,0 ;echt benîtigt
vbl_gemslot:
          tas.b     sema_gemslot+1      ;Set bit 7
          move.l    vbl_gemslot+XB_OLDVEC(pc),d0
          beq.s     vbl_idle
          movea.l   d0,a0               ;Execute original VBL code
          jmp       (a0)

               dc.l 'XBRA',xb_id,0 ;pro forma...
vbl_irq:  lsr.w     sema_gemslot
          bcc.s     re_install_gemvecs  ;es ist mal wieder soweit!
vbl_idle: rts

*
* 'GEM'-Vektoren installieren:
*  - VBL-Slot #0
*  - MouseVec
*
re_install_gemvecs:
          movea.l   _vblqueue.w,a0
          lea       vbl_gemslot(pc),a1
          bsr       Xb_install          ;STUR BLEIBEN!!
          movea.l   sys_kbdvbase(pc),a0
          lea       16(a0),a0           ;+16
          lea       mouse_sys(pc),a1
          bsr       Xb_install
          move.w    #$FFFF,sema_gemslot ;Init Shiftregister!
          rts


               endpart
               >PART 'SYS: CJ-Funktionsdispatcher'
*
* main interface handler:
* (see doc!)
*
_setup:   link      a6,#0               ;klassischer LINK....
          movem.l   d2-d7/a2-a5,-(sp)
          move.w    8(a6),d0            ;OPCODE
          bmi.s     invalid_function
          cmpi.w    #MAXFUNC,d0
          bgt.s     invalid_function
          add.w     d0,d0
          lea       varbase(pc),a5
          lea       _fn_jumptab(pc),a0
          adda.w    0(a0,d0.w),a0
          jsr       (a0)                ;fn aufrufen
_setup1:  movem.l   (sp)+,d2-d7/a2-a5
          unlk      a6
          rts

invalid_function:
          moveq     #E_ILLFUNC,d0
          bra.s     _setup1


* return identifying string.
identify: lea       id_msg(pc),a0
          move.l    a0,d0
          rts

*
* interne Sprungtabelle:
*
_fn_jumptab:   base dc.w,_fn_jumptab
               dc.w identify,extkey ;    0 1
               dc.w compose,alt_nnn ;    2 3
               dc.w ckeytbl,cbioskeys ;  4 5
               dc.w deadkey   ;          6
               dc.w mouse_cfg ;          7

               base dc.w,OFF

               endpart
               PART 'KBD: keyboard Setup'
* 1: EXTKEY       schaltet EXTKEY-Modus ein/aus bzw. fragt akt. Status ab
*   long setup(EXTKEY, int mode);
*   mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*   return:   vorheriger Wert
extkey:   moveq     #0,d0
          move.b    extkeymode(a5),d0
          move.w    10(a6),d1           ;mode
          bmi.s     extkey_return
          andi.w    #%1,d1
          move.b    d1,extkeymode(a5)   ;set new value.
extkey_return:
          rts


* 2: COMPOSE      schaltet COMPOSE-Modus ein/aus bzw fragt akt. Status ab
*   long setup(COMPOSE, int mode);
*   mode:     -1 (INQUIRE)
*              >=0: BITMAPPED:  0/1
*                  bit #0:     OFF/ON
*                  bit #1:     DEC/MULTICHAR MODE
*                  bit #2:     ORDER SENSITIVE NO/YES
*                  bit #3:     EXPLICIT/IMPLICIT COMPOSE
*
*   return:   vorheriger Wert
*
compose:  moveq     #0,d0
          move.b    composemode(a5),d0  ;return old value....
          move.w    10(a6),d1           ;new value
          bmi.s     compose_return
_set_compose:
          andi.w    #%1111,d1           ;mask superfluous bits
          move.b    d1,composemode(a5)  ;store!
          lea       Dead_enabletab(pc),a0 ;trigger table address
          btst      #0,d1               ;Compose ON (main switch)
          beq.s     cmp_cleartrigger    ;OFF -> clear trigger table
          btst      #3,d1               ;IMPLICIT mode on?
          beq.s     cmp_cleartrigger    ;no.

;implicit mode is enabled; scan through compose table and set up trigger table
          move.w    d0,-(sp)            ;save return value
          movea.l   keytbl_compose(pc),a1 ;compose table address
cmp_next: move.b    (a1),d0             ;get first character
          beq.s     cmp_done
          andi.w    #$FF,d0
          addq.l    #4,a1               ;point to next table entry
          cmpi.b    #'a',d0
          blt.s     cmp1
          cmpi.b    #'z',d0
          ble.s     cmp_ok
cmp1:     cmpi.b    #'A',d0
          blt.s     cmp2
          cmpi.b    #'Z',d0
          ble.s     cmp_ok
cmp2:     bclr      #1,0(a0,d0.w)       ;not isalpha() -> disable trigger
          bra.s     cmp_next
cmp_ok:   bset      #1,0(a0,d0.w)
          bra.s     cmp_next
cmp_done: move.w    (sp)+,d0            ;restore return value
compose_return:
          rts

cmp_cleartrigger:
          moveq     #(256/4)-1,d1       ;alle Bit 1 in Tabelle lîschen
cmp3:     andi.l    #$FDFDFDFD,(a0)+
          dbra      d1,cmp3
          rts


* 3: ALT_NNN      verwaltet die MSDOS-ALT-ASCII Funktion.
*   long setup(ALT_NNN, int mode);
*   mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*   return:   vorheriger Wert
alt_nnn:  moveq     #0,d0
          move.b    alt_nnnmode(a5),d0
          move.w    10(a6),d1           ;new value
          bmi.s     alt_nnn_return
          andi.w    #%1,d1              ;mask superfluous bits
          move.b    d1,alt_nnnmode(a5)  ;store!
alt_nnn_return:
          rts


* 4: CKEYTBL      verwaltet die Tastaturtabellen.
*   long setup(CKEYTBL, char *unshift, char *shift, char *caps,
*                                                 char *compose );
*   unshift, shift, caps: Zeiger auf die entsprechenden Tabellen
*             (siehe XBIOS Keytbl !!!!)
*   compose:  Zeiger auf die Compose-Tabelle.
*   return:   Zeiger auf  struct {
*                             char       *unshift;
*                             char       *shift;
*                             char       *caps;
*                             comptab    *compose;
*                             const char *name;
*                         } XKEYTAB;
*         Bemerkung: wenn ein Zeiger den Wert 0 oder -1 besitzt, dann wird
*                   dieser Wert intern nicht verÑndert.
*                   Die vier Tabellen werden in einen internen Puffer kopiert,
*                   der Aufrufer braucht die Tabellen also nicht selbst im
*                   Speicher zu behalten.
ckeytbl:  sf        d7
          move.l    10(a6),d0           ;UNSHIFT -------------
          ble.s     cktbl               ;invalid ptr -> return only.
          movea.l   d0,a0               ;source
          lea       tab_unshift(pc),a1  ;destination
          bsr       copy128             ;128 bytes kopieren.
          move.l    a1,keytbl_unshift(a5)
          st        d7
cktbl:    move.l    14(a6),d0           ;SHIFT ---------------
          ble.s     cktbl1              ;invalid ptr -> return only.
          movea.l   d0,a0               ;source
          lea       tab_shift(pc),a1    ;destination
          bsr       copy128             ;128 bytes kopieren.
          move.l    a1,keytbl_shift(a5)
          st        d7
cktbl1:   move.l    18(a6),d0           ;CAPS ----------------
          ble.s     cktbl2              ;invalid ptr -> return only.
          movea.l   d0,a0               ;source
          lea       tab_caps(pc),a1     ;destination
          bsr.s     copy128             ;128 bytes kopieren.
          move.l    a1,keytbl_caps(a5)
          st        d7
cktbl2:   lea       Xkeytbl(pc),a0      ;neue Tabellen setzen!
          move.l    8(a0),-(sp)
          move.l    4(a0),-(sp)
          move.l    (a0),-(sp)
          move.w    #Keytbl,-(sp)
          trap      #14                 ;XBIOS
          lea       14(sp),sp
          move.l    d0,sys_keytbl(a5)   ;get OS pointer

          move.l    26(a6),d0           ;Name der Tabelle
          ble.s     cktbl4              ;0 od. -1
          movea.l   d0,a0
          lea       namebuffer(pc),a1
          movea.l   a1,a2
          moveq     #11,d1
cktbl3:   move.b    (a0)+,(a1)+         ;name kopieren
          dbeq      d1,cktbl3
          move.l    a2,keytbl_name(a5)

cktbl4:   move.l    22(a6),d0           ;Compose Character Table
          ble.s     cktbl5              ;war nix
          movea.l   d0,a0
          bsr.s     install_user_table
          st        d7
          tst.w     d0
          bmi.s     cktbl6              ;errorcode zurÅck!

cktbl5:   lea       Xkeytbl(pc),a0      ;my struct
          tst.b     d7                  ;was geÑndert?
          beq.s     cktbl7
          movea.l   a0,a1
          lea       Loaded_Xkeytbl(pc),a2
          move.l    (a1)+,(a2)+         ;als geladen Åbernehmen
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.w    tabsize(a5),old_tabsize(a5)
          move.b    d7,Loaded_data(a5)

cktbl7:   move.l    a0,d0
cktbl6:   rts


* kopiert 128 bytes von (a0) nach (a1); nur a0 wird zerstîrt
copy128:  pea       (a1)
          moveq     #128/4-1,d0
cpy1:     move.l    (a0)+,(a1)+         ;020/030 ultrafast copyloop
          dbra      d0,cpy1
          movea.l   (sp)+,a1
          rts

*
* install_user_table: userdef's Tabelle setzen
* in:     a0: ptr to newtab
* out:    d0: ERRORCODE
*
install_user_table:
; 1. Grîûe der Tabelle testen.
          movea.l   a0,a2
          moveq     #-1,d1
          move.w    #MAXTABSIZE,d2
          bra.s     iut1

iut:      addq.w    #1,d1
          tst.l     (a0)+
iut1:     dbeq      d2,iut
          beq.s     iut2                ;Abbruch durch end of tab
          bra.s     ex_iut

iut2:     cmpi.w    #2,d1               ;minitable....?
          blt.s     ex_iut              ;Abbruch wg. zu kleiner Tabelle
          move.w    d1,tabsize(a5)      ;ok, merken

; 2. Tabelle kopieren.
          lea       comptab(pc),a0
          move.l    a0,keytbl_compose(a5) ;temporÑr die alte Tabelle!
          lea       tab_compose(pc),a1  ;Ziel
          movea.l   a2,a0               ;Quelle
cpytab:   move.l    (a0)+,(a1)+
          bne.s     cpytab

; 3. Tabelle sortieren
          move.w    tabsize(pc),d1
          subq.w    #1,d1               ;wg. quicksort :-)   (C-Code!)
          moveq     #0,d0               ;untergrenze = 0
          lea       tab_compose(pc),a0  ;diese Tabelle!
          jsr       sort(pc)            ;Tabelle sortieren

; 4. Zeiger setzen & var update:
          move.l    a0,keytbl_compose(a5) ;neue Tabelle aktiv...
          move.b    composemode(a5),d1  ;perform a compose setup
          bsr       _set_compose        ;to force a trigger table rebuild
          moveq     #OK,d0
          rts

ex_iut:   moveq     #E_TABSIZE,d0
          rts

;----------------------------------

* 5: CBIOSKEYS     setzt die Originaltabellen wieder ein oder schaltet
*                   zwischen den Tabellen hin und her
*   int setup(CBIOSKEYS, switch);
*         switch:   -1  INQUIRE  (returns last switch bitmap)
*                   >=0: bitmapped.
*                   bit #0: keyboard translation table - SET: use loaded ---
*                   bit #1: compose tables             - SET: use loaded ---
*   return:  last setup value.
*
cbioskeys:
          move.w    kbd_setup(pc),d7
          move.w    10(a6),d6           ;get parameter switch
          bmi.s     cbiosk1
          move.w    d6,kbd_setup(a5)    ;remember it
          pea       cbiosk(pc)
          lsr.w     #1,d6               ;test bit #0
          bcs.s     new_keymap
          bra.s     sys_keymap
cbiosk:   pea       cbiosk1(pc)
          lsr.w     #1,d6
          bcs.s     new_compose
          bra.s     sys_compose
cbiosk1:  move.w    d7,d0
          rts

new_keymap:
          tst.b     Loaded_data         ;nichts geladen -> sorry.
          beq.s     sys_keymap1
          lea       Loaded_Xkeytbl(pc),a1
          move.l    8(a1),-(sp)
          move.l    4(a1),-(sp)
          move.l    (a1),-(sp)
          bra.s     put_keymap

new_compose:
          tst.b     Loaded_data         ;nichts geladen -> sorry.
          beq.s     sys_compose1
          lea       Loaded_Xkeytbl+12(pc),a1
          lea       Xkeytbl+12(pc),a2
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.w    old_tabsize(a5),tabsize(a5)
          rts

sys_keymap1:
          clr.w     kbd_setup(a5)
sys_keymap:
          move.w    #Bioskeys,-(sp)
          trap      #14                 ;Bioskeys(): RESET tables
          addq.w    #2,sp
          moveq     #-1,d0              ;get system table addresses
          move.l    d0,-(sp)
          move.l    d0,-(sp)
          move.l    d0,-(sp)
put_keymap:
          move.w    #Keytbl,-(sp)
          trap      #14                 ;XBIOS
          lea       14(sp),sp
          movea.l   d0,a0               ;system keytbl struct
          move.l    d0,sys_keytbl(a5)
          lea       Xkeytbl(pc),a1
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+         ;copy 3 !
          rts

sys_compose1:
          clr.w     kbd_setup(a5)
sys_compose:
          lea       comptab(pc),a0
          move.l    a0,keytbl_compose(a5)
;          lea       sysname(pc),a0
;          move.l    a0,keytbl_name(a5)
          move.w    #COMPTABSIZE,tabsize(a5)
          rts

* 6: DEADKEY       DEADKEY CONTROL function
*   long setup(DEADKEY, short mode, char *keys);
*   mode:     -1 (INQUIRE), 0 (OFF), 1 (ON), 2 (SET)
deadkey:  move.w    10(a6),d1           ;mode
          movea.l   12(a6),a1           ;char *keys
          beq.s     deadoff
          cmpi.w    #1,d1
          beq.s     deadon
          cmpi.w    #2,d1
          beq.s     deadset
; inquire: if ptr is valid then copy your string!!!!
          move.l    12(a6),d1
          beq.s     deadkey_return
          movea.l   d1,a0
          lea       dead_default(pc),a1
dead:     move.b    (a1)+,(a0)+
          bne.s     dead
deadkey_return:
          moveq     #0,d0
          move.b    dead_onoff(a5),d0
          andi.w    #1,d0
          rts

; switch deadkeys off:
deadoff:  lea       Dead_enabletab(pc),a3
          moveq     #(256/4)-1,d3       ;alle Bit 0 in Tabelle lîschen
dead1:    andi.l    #$FEFEFEFE,(a3)+
          dbra      d3,dead1
          sf        dead_onoff(a5)
          bra.s     deadkey_return

; switch deadkeys on:
deadon:   lea       Dead_enabletab(pc),a3
          movea.l   a3,a0
          moveq     #(256/4)-1,d3       ;Tabelle zuerst komplett lîschen
dead2:    andi.l    #$FEFEFEFE,(a0)+    ;nur BIT 0 in jedem Byte!
          dbra      d3,dead2
          moveq     #15-1,d4            ;max. 15 deadkeys
          lea       dead_default(pc),a4 ;String mit Deadkeys
          moveq     #0,d0
dead3:    move.b    (a4)+,d0            ;get char               (CCR set)
          beq.s     dead4
          bset      #0,0(a3,d0.w)       ;set deadkey flag for this char
          dbra      d4,dead3
dead4:    st        dead_onoff(a5)
dead5:    bra.s     deadkey_return

; setup deadkeys:
deadset:  moveq     #15-1,d4            ;max. 15 deadkeys
          lea       dead_default(pc),a4 ;String mit Deadkeys
          move.l    a1,d0               ;USER string
          beq.s     dead5               ;null -> nope!
          moveq     #0,d0
dead6:    move.b    (a1)+,(a4)+         ;copy string
          dbeq      d4,dead6
dead7:    tst.b     dead_onoff(a5)
          beq.s     deadoff
          bra.s     deadon


;INQUIRE        equ -1
;OFF            equ 0
;ON             equ 1

;* bitmapped stuff:
;DEC_MODE       equ 0
;MULTICHAR_MODE equ 2

;ORDER_SENSITIVE equ 4


               endpart
               >PART 'KBD: QuickSort' ;                     Pure C compilat
* Object File "qsort.o" compiled by PURE C
* ----------------------------------------
* sort (long *tab, int l, int r); globale VAR ( long *keytbl_compose)
*        untergr. obergrenze
* !! a0 wird nicht verÑndert
sort:     movem.l   d3-d7,-(sp)
          move.w    d0,d3
          move.w    d1,d5
          move.w    d0,d4
          move.w    d1,d6
          move.w    d3,d0
          add.w     d5,d0
          asr.w     #1,d0
          ext.l     d0
          lsl.l     #2,d0
          move.l    0(a0,d0.l),d0
          bra.s     T000026
T000024:  addq.w    #1,d4
T000026:  move.w    d4,d1
          ext.l     d1
          lsl.l     #2,d1
          cmp.l     0(a0,d1.l),d0       ;1. compare
          bhi.s     T000024             ;bgt.s
          bra.s     T000038
T000036:  subq.w    #1,d6
T000038:  move.w    d6,d1
          ext.l     d1
          lsl.l     #2,d1
          cmp.l     0(a0,d1.l),d0       ;2. compare
          blo.s     T000036             ;blt.s
          cmp.w     d4,d6
          blt.s     T000072
          move.w    d4,d2
          ext.l     d2
          lsl.l     #2,d2
          move.l    0(a0,d2.l),d1
          move.w    d6,d2
          ext.l     d2
          lsl.l     #2,d2
          move.w    d4,d7
          ext.l     d7
          lsl.l     #2,d7
          move.l    0(a0,d2.l),0(a0,d7.l) ;swap
          move.l    d1,0(a0,d2.l)
          addq.w    #1,d4
          subq.w    #1,d6
T000072:  cmp.w     d4,d6
          bge.s     T000026
          cmp.w     d3,d6
          ble.s     T000082
          move.w    d6,d1
          move.w    d3,d0
          jsr       sort(pc)
T000082:  cmp.w     d4,d5
          ble.s     T00008E
          move.w    d5,d1
          move.w    d4,d0
          jsr       sort(pc)
T00008E:  movem.l   (sp)+,d3-d7
          rts

               endpart
               >PART 'MSE: speeder Setup'
*
* Mouse speeder config //
* -----------------------
*
* int setup(MOUSE_CFG, int mode, MSPEEDER_SETUP *mdata);
*   mode: WORD,
*           -1: INQUIRE, fill out MSPEEDER_SETUP structure if ptr set!
*            0: OFF - deactivate Speeder
*            1: ON  - activate Speeder
*            2: SET - install new params
*
*   typedef struct {
*       union {
*          unsigned resvd    :13;
*          unsigned lefthand :1;        /* Button map change!?             */
*          unsigned control  :1;        /* Control Key disables...         */
*          unsigned activity :1;        /* Speeder ON ?                    */
*       } switches;
*       int         polynomial[4];      /* speeder polynomial              */
*       int         rotation;           /* rotation in degrees             */
*       int         ratio;              /* X:Y ratio * 256!                */
*       int         mouse_rez;          /* M.resolution in dpi   (:100)  */
*       int         screen_rez;         /* screen rez in dpi     (  72  )  */
*   } MSPEEDER_SETUP;
*
*+++int         trackingspeed;      /* max.trk.speed in mm/s (:620)  */
*
*  return: always ptr to active setup data
*
*  REM: polynomial & ratio data format is  (int)(real_value*256) !!!
*       -> to get a 1:1.5 speedup use []={0,0,384}
*
*
*
*
*
mouse_cfg:
          move.w    10(a6),d0           ; mode
          movea.l   12(a6),a0           ; Ptr to data
          bmi.s     mcfg_inquire        ; only get data
          beq.s     mcfg_shutoff        ; only deactivate!
          cmpi.w    #1,d0
          beq.s     mcfg_activate
          cmpi.w    #2,d0
          beq.s     mcfg_setparam
          moveq     #ERROR,d0           ;default: return an Errorcode
          rts

; activate speeder:
mcfg_activate:
          bset      #0,msc_switches+1(a5) ;ON/OFF switch
          bra.s     mcfg_inquire
; deactivate:
mcfg_shutoff:
          bclr      #0,msc_switches+1(a5)

mcfg_inquire:
          lea       MouseCntrlStruct(pc),a1
          move.l    a0,d0
          beq.s     mcfg_nope           ;(NULL?)

          move.l    (a1)+,(a0)+         ;copy to user
          move.l    (a1)+,(a0)+
          move.l    (a1)+,(a0)+
          move.l    (a1)+,(a0)+
          move.w    (a1)+,(a0)+         ;9 words
mcfg_nope:
          lea       mse_rest(pc),a0
          clr.l     (a0)+
          clr.l     (a0)+               ;clear any remainders
          lea       MouseCntrlStruct(pc),a0
          move.l    a0,d0
          rts

*
* Evaluate Parameters & memorize new setup
*
mcfg_setparam:
; 0. Vorbereitung: Speeder auf accelerate mode:
          lea       mse_accelerate(pc),a1
          move.l    a1,speedervec(a5)

; 1. Kopiere die Parameter & Range Check:
          lea       MouseCntrlStruct(pc),a1
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.w    (a0)+,(a1)+         ;9 words
; check switches
          andi.w    #%101,msc_switches(a5)
; check screen aspect ratio
          move.w    msc_ratio(a5),d0    ;ratio 1:4 bis 4:1
          bne.s     pchk
          move.w    #256,d0
          bra.s     pchk2
pchk:     cmpi.w    #64,d0
          bgt.s     pchk1
          move.w    #64,d0
          bra.s     pchk2
pchk1:    cmpi.w    #1024,d0
          blt.s     pchk2
          move.w    #1024,d0
pchk2:    move.w    d0,msc_ratio(a5)
; check mouse resolution 50...400
          move.w    msc_resolution(a5),d0
          bne.s     pchk3
          move.w    #MREZ_REFERENCE,d0  ;default
          bra.s     pchk5
pchk3:    cmpi.w    #50,d0
          bgt.s     pchk4
          moveq     #50,d0
          bra.s     pchk5
pchk4:    cmpi.w    #400,d0
          blt.s     pchk5
          move.w    #400,d0
pchk5:    move.w    d0,msc_resolution(a5)
; check screen resolution 20..200
          move.w    msc_screenrez(a5),d0
          bne.s     pchk6
          move.w    #SREZ_REFERENCE,d0  ;default
          bra.s     pchk8
pchk6:    cmpi.w    #20,d0
          bgt.s     pchk7
          moveq     #20,d0
          bra.s     pchk8
pchk7:    cmpi.w    #200,d0
          blt.s     pchk8
          move.w    #200,d0
pchk8:    move.w    d0,msc_screenrez(a5)

; 2. Maustasten vertauscht?
          move.l    #BUTTON_NORMAL,d0
          move.l    #BUTTON_NORMA2,d1
          btst      #2,msc_switches+1(a5) ;lefthand mode?
          beq.s     mcfg_normbutton
          move.l    #BUTTON_REVERSE,d0
          move.l    #BUTTON_REVERS2,d1
mcfg_normbutton:
          move.l    d0,buttonset(a5)    ;Set DATA
          move.l    d1,buttonset+4(a5)

; 4. Anpassung der Polynomfaktoren an die Bildschirmauflîsung:
          move.w    msc_screenrez(a5),d3 ;srez in dpi
          lea       msc_polynomial(a5),a1
          lea       mse_polyfactor(a5),a2
          moveq     #4-1,d4             ;Counter: 4 parameter
mcfg_1:   move.w    (a1)+,d0            ;get polynomial factor
          muls      d3,d0               ; srez*pf
          divs      #SREZ_REFERENCE,d0  ; DIV srez_ref
          move.w    d0,(a2)+            ;save factor...
          dbra      d4,mcfg_1

; 5. Anpassung des SeitenverhÑltnisses:
          move.w    msc_ratio(a5),d1    ;Aspect Ratio??
          move.w    d1,mse_xyratio(a5)  ;save xy ratio
          cmpi.w    #256,d1             ;256 = 1:1.00
          beq.s     mcfg_2
          lea       mse_ratiocorrection(pc),a1
          move.l    a1,speedervec(a5)   ;use ratio correction algorithm
mcfg_2:

; 6. Berechnung der Speedup-tabelle:
          lea       mse_speeduptable(pc),a3
          move.l    #128*MREZ_REFERENCE,d4 ; speed x=1.00*mrez_ref
          divu      msc_resolution(a5),d4 ;  DIV mrez = corrected speed fac 1
          move.w    #SQUARETABSIZ-2,d5
          clr.w     (a3)+               ;first parameter always 0
          move.w    d4,d3               ;speed data input=1

mcfg_3:   move.w    d3,d0               ;Speed data
          bsr.s     polynomial          ;calculate P(x)/x
;limit maximum speedup!
          move.l    #MAXSPEED*128,d2    ;calculate max speedup factor
          divs      d3,d2               ;for this particular speed
          bvs.s     mcfg_4              ;overflow?
          bra.s     mcfg_5
mcfg_4:   move.w    #$7FFF,d2
mcfg_5:   cmp.w     d2,d1               ;positive speeduplimit reached?
          ble.s     mcfg_6
          move.w    d2,d1               ;min(SPEEDUPLIMIT,y)
          bra.s     mcfg_7
mcfg_6:   neg.w     d2
          cmp.w     d2,d1               ;negative limit reached?
          bge.s     mcfg_7
          move.w    d2,d1
mcfg_7:   move.w    d1,(a3)+            ;store value
          add.w     d4,d3               ;next speed value
          dbra      d5,mcfg_3

; 7. Auswertung der Rotationsdaten:
          move.w    msc_rotation(a5),d5 ;speeder rotation?!
          beq.s     mcfg_8              ;don't do it!
          move.w    d5,d0               ;prepare to die!
          bsr.s     cosinus_w           ;cos(‡)
          move.w    d0,mse_rmatrix+0(a5)
          muls      mse_xyratio(a5),d0
          asr.l     #8,d0
          move.w    d0,mse_rmatrix+6(a5)
          move.w    d5,d0
          bsr.s     sinus_w             ;sin(‡)
          neg.w     d0
          move.w    d0,mse_rmatrix+2(a5) ;-sin()
          neg.w     d0
          muls      mse_xyratio(a5),d0
          asr.l     #8,d0
          move.w    d0,mse_rmatrix+4(a5) ;sin(‡)
          lea       mse_rotate(pc),a1
          move.l    a1,speedervec(a5)   ;use ratio correction algorithm
mcfg_8:   bra       mcfg_nope

*****************************************
* polynomial: d0.w = P(d0.w)
* calculates P(x)/x for x>0
*    in:  d0.w: unsigned word corrected speed * 128 (! 7 bit correction)
*    out: d0.w:  id.
*         d1.w: int result (limited)
* regs: d0-d2
polynomial:
          lea       mse_polyfactor(pc),a1
          move.w    (a1)+,d1            ;a
          muls      d0,d1               ;ax
          asr.l     #7,d1               ;               DIV 256
          add.w     (a1)+,d1            ;ax+b
          muls      d0,d1               ;ax^2+bx
          asr.l     #7,d1               ;               DIV 256
          add.w     (a1)+,d1            ;ax^2+bx+c
          muls      d0,d1               ;ax^3+bx^2+cx
          asr.l     #7,d1               ;               DIV 256
          move.w    (a1)+,d2            ; factor d
          ext.l     d2
          add.l     d2,d1               ;ax^3+bx^2+cx+d
          cmpi.l    #$7FFF,d1           ;maxint?
          bgt.s     poly                ;positive overflow
          cmpi.l    #-$7FFF,d1
          blt.s     poly1
          rts
poly:     move.w    #$7FFF,d1
          rts
poly1:    move.w    #-$7FFF,d1
          rts


*****************************************
* Sinus/Cosinus-Berechnung
*  in: d0.w : angle
*  out:d0.w : sin / cos
*
cosinus_w:
          subi.w    #90,d0
          neg.w     d0                  ;≠≠≠≠ cos(‡) = sin(90-‡) !!!!
sinus_w:  move.w    #360,d1
          tst.w     d0
          bpl.s     sin_pos
sin_neg:  add.w     d1,d0               ;einfach ins Positive drehen
          bmi.s     sin_neg
sin_pos:  cmp.w     d1,d0
          blt.s     sin_ok
          sub.w     d1,d0
          bra.s     sin_pos
sin_ok:   lea       sinustab(pc),a1
          cmpi.w    #90,d0              ;sinus jetzt im Bereich 0...359¯
          ble.s     sin_q1              ;Quadrant 1 -> TABELLE
          cmpi.w    #180,d0
          ble.s     sin_q2              ;Quadrant 2 -> sin(180-‡)
          cmpi.w    #270,d0
          ble.s     sin_q3              ;Quadrant 3 -> -sin(‡-180)
sin_q4:   sub.w     d0,d1               ;Quadrant 4 -> -sin(360-‡)
          move.w    d1,d0
          bra.s     sin_q4bis
sin_q3:   subi.w    #180,d0
sin_q4bis:add.w     d0,d0
          move.w    0(a1,d0.w),d0
          neg.w     d0
          rts
sin_q2:   subi.w    #180,d0
          neg.w     d0
sin_q1:   add.w     d0,d0
          move.w    0(a1,d0.w),d0
          rts
               endpart
               >PART 'XBRA vector Install/Remove'
*
* Neue Version 3/92 @pf68030
*

********************************************************************************
* Xb_install: fÅge neuen XBRA Teilnehmer in eine Vektorliste ein               *
* Param:  a0: Vektor (&root, zeiger auf Liste!)                                *
*         a1: Pointer auf zu installierende Routine, Header erforderlich       *
* Ret:    d0: -1 bei Fehler  (bsp: Doppelinstallation)                         *
*             0 wenn OK       + FLAGS!!                                        *
*   Reg's: d0-d2,a0-a2                                                         *
********************************************************************************
Xb_install:
          cmpi.l    #'XBRA',XB_MAGIC(a1) ;Routine braucht einen Header!
          bne.s     Xb_error
          movea.l   a0,a2               ;save vector
          move.l    XB_ID(a1),d0        ;Identifier
          pea       (a1)                ; &routine
          bsr.s     Xb_find             ;Suche ihn
          movea.l   (sp)+,a1
          bpl.s     Xb_error            ;und vermeide Doppelinstallation
          move.l    (a2),XB_OLDVEC(a1)  ;FÅlle Header aus (erst hier!)
          move.l    a1,(a2)             ;insert into list
          moveq     #0,d0               ;OK
          rts

********************************************************************************
* Xb_remove: entferne einen XBRA Teilnehmer aus einer Liste                    *
* Param:  a0: vector (&root)                                                   *
*         d0: XB_ID des Todeskandidaten                                        *
* Ret:    d0: -1 bei Fehler  (nicht gefunden)                                  *
*             >=0 wenn OK (Verschachtelungstiefe)                              *
* Regs:   d0-d2/a0-a1                                                          *
********************************************************************************
Xb_remove:
          bsr.s     Xb_find             ;suchen
          bmi.s     Xb_error            ;nicht vorhanden
          beq.s     Xb_remv             ;Root Level, erstes Listenelement
          move.l    XB_OLDVEC(a0),XB_OLDVEC(a1) ; prev->oldvec=xbra->oldvec
          bra.s     Xb_remv1
Xb_remv:  move.l    XB_OLDVEC(a0),(a1)  ; root=xbra->oldvec
Xb_remv1: clr.l     XB_OLDVEC(a0)
          rts

Xb_error: moveq     #-1,d0
          rts

********************************************************************************
* Xb_find: suche einen XBRA-Teilnehmer                                         *
* Param:  a0: vector (&root der Liste)                                         *
*         d0: XB_ID des Kandidaten                                             *
* Ret:    d0: -1 : Fehler - nichts gefunden                                    *
*            >=0 : Verschachtelungstiefe an der Fundstelle                     *
*         a0: xbra    (Adresse der gefundenen XBRA-Struktur)                   *
*         a1: parent  (Adresse der vorherigen XBRA-Struktur) oder &root        *
*                     &root nur wenn Verschachtelungstiefe==0                  *
* Regs:   d0-d2,a0-a1                                                          *
********************************************************************************
Xb_find:  move.l    d0,d1
          movea.l   a0,a1               ; parent=root;
          movea.l   (a0),a0             ; xbra=*root;
          moveq     #0,d2               ; level=0;
          bra.s     Xb_find2
Xb_find1: addq.w    #1,d2               ; level++;
          movea.l   a0,a1               ; parent=xbra;
          movea.l   XB_OLDVEC(a0),a0    ; xbra=xbra->oldvec;
Xb_find2: bsr.s     Xb_check            ; while ( (check(xbra))
          bne.s     Xb_error            ;         &&
          cmp.l     XB_ID(a0),d1        ;         (xbra->magic!=mymagic)
          bne.s     Xb_find1            ;       );
          move.w    d2,d0               ;gefunden!
          rts

********************************************************************************
* Xb_check: teste die in a0 spezifizierte XBRA Struktur                        *
* Param:  a0: &xbra  (Zeiger auf XBRA Struktur)                                *
* Ret:    d0: 0 = XBRA,  -1: no xbra                                           *
*         Flags: EQ = XBRA                                                     *
* Regs:   d0                                                                   *
********************************************************************************
Xb_check: move.l    a0,d0               ;Teste diese Struktur
          btst      #0,d0               ;Ungerade?
          bne.s     Xb_error
          cmp.l     #$0100,d0           ;NICHT in den Systemvektoren!
          blt.s     Xb_error            ;Sicherheitshalber
          cmpi.l    #'XBRA',XB_MAGIC(a0) ;hoffentlich keine Bomben !
          bne.s     Xb_error
          moveq     #0,d0
          rts

               endpart

;********* RESIDENT VARIABLES **************************************************
               base A5,OFF
varbase:
               PART 'KBD: variables'

sys_keytbl:    dc.l 0         ;Ptr to system KEYTBL

sysname:       dc.b '---system---' ;12 chars
               ds.b 12        ;+12
               dc.b 0         ; = 24 chars total

               even


; DATEN VERéNDERBAR:
Xkeytbl:
; struct {
keytbl_unshift:dc.l 0         ;Ptr to standard translation table
keytbl_shift:  dc.l 0         ;Ptr to shifted  translation table
keytbl_caps:   dc.l 0         ;Ptr to CAPSLOCK translation table
keytbl_compose:dc.l comptab   ;Ptr to compose-tab
keytbl_name:   dc.l sysname   ;Ptr to table name
; } Xkeytbl

Loaded_Xkeytbl:ds.l 5         ;Platz fÅr letzte Struktur beim Laden!

oldvalid:      dc.l 0         ;fÅr reset code

kbd_iorec:     dc.l 0         ;Ptr auf IOREC data
kbshift:       dc.l 0         ;Ptr to kbshift variable

alt_timeout:   dc.l 0         ;intern benutzt
oldsavp:       dc.l 0         ;TOS bug

; KBD irq state machine pointers
nextstate:     dc.l State_Normal_operation
compose_subroutine:
               dc.l Compose_idle

lastc:         dc.l 0         ;last character
tabsize:       dc.w COMPTABSIZE ;size of compose-table (last element!)
old_tabsize:   dc.w 0         ;case of last loaded data
kbd_setup:     dc.w 0         ;which tables are activated?

* ALT-NNN Puffervariablen:
altn_count:    dc.w 0         ;wieviele Tasten gedrÅckt?
altn_char:     dc.w 0         ;welches Zeichen----

lastshift:     dc.b 0         ;letzter gÅltiger SHIFT-Status

* was geladen?
Loaded_data:   dc.b 0

* Einstellungen: *
extkeymode:    dc.b 0
composemode:   dc.b 0
alt_nnnmode:   dc.b 0

namebuffer:    ds.b 16
               dc.b 0

               even
               endpart
               >PART 'MSE: variables'

sys_kbdvbase:  dc.l 0         ;Zeiger auf KBDVectorbase

speedervec:    dc.l mse_inactive ;ptr to corresponding routine

* Mouse speeder control data:
* 1. polynomial factors x^4, x^3, x^2, x^1
* 2. rotation matrix
* 3. x/y ratio (pixel width/pixel height)
mse_polyfactor:dc.w 0,0,0,0   ;(^4, ^3, ^2, ^1) only for polytable build

mse_rmatrix:   dc.w 0,0       ;2*2 rotation matrix:  cos(‡)  -sin(‡)
               dc.w 0,0       ;                      sin(‡)   cos(‡)
mse_xyratio:   dc.w 0         ;speeder x/y ratio

mse_rest:      dc.l 0,0       ; 2 longs

mse_speeduptable:                       ;vorberechnete Polynomwerte
               ds.w SQUARETABSIZ+1


Rest_X         equ 0          ;struct offsets
Rest_Y         equ 4

MouseBut       equ 0          ;mouse packet data
MouseX         equ 1          ;
MouseY         equ 2          ;


;------------------------------------------------------------------------------
               endpart
               >PART 'VBL: variables'

sema_gemslot:  dc.w $FFFF

               endpart
               >PART 'KBD: Tabellen & Daten'
; DATEN FEST
clicksound:    dc.b $00,$3B,$01,$00,$02,$00,$03,$00
               dc.b $04,$00,$05,$00,$06,$00,$09,$00
               dc.b $0A,$00,$07,$FE,$08,$10,$0D,$03
               dc.b $0B,$80,$0C,$01,$FF,$00

bellsound:     dc.b $00,$34,$01,$00,$02,$00,$03,$00
               dc.b $04,$00,$05,$00,$06,$00,$07,$FE
               dc.b $08,$10,$09,$00,$0A,$00,$0B,$00
               dc.b $0C,$10,$0D,$09,$FF,$00

*
* Deadkey: welche Zeichen sind als TOT deklariert?
*
dead_default:                           ;(max 15 chars + 1 Nullterm)
               dc.b """","`","'","^","|","~",0,0
               dc.b 0,0,0,0,0,0,0,0
dead_onoff:    dc.w 1
Dead_enabletab:
               ds.b 256       ;256 bytes

*
* COMPOSED CHARACTERS - TABELLE:
*
* Format ist:
*   typedef struct {
*       char    primary;        /* erster Buchstabe plus... */
*       char    secondary;      /* ...zweiter Buchstabe */
*       char    composed;       /* ergibt _composed_ ! */
*       char    flags;          /* div. Flags, reserved! */
*   } comptab[];
*
*
* FLAGS: damit sind verschiedene Angaben mîglich
*   - order sensitiveness
*
               even
comptab:
               dc.b "++#",0   ;35
               dc.b "aa@",0   ;64
               dc.b "AA@",0
               dc.b "(([",0   ;91
               dc.b "//\",0   ;92
               dc.b "))]",0   ;93
               dc.b "(-{",0   ;123
               dc.b "/^|",0   ;124
               dc.b ")-}",0   ;125
               dc.b "DE",ORDER ;127 DELTA
               dc.b "De",ORDER
               dc.b "C,Ä",0   ;128
               dc.b 'u"Å',0   ;129
               dc.b 'uπÅ',0
               dc.b "e'Ç",0   ;130
               dc.b "a^É",0   ;131
               dc.b 'a"Ñ',0   ;132
               dc.b 'aπÑ',0
               dc.b "a`Ö",0   ;133
               dc.b "a.Ü",0   ;134
               dc.b "a¯Ü",0
               dc.b "c,á",0   ;135
               dc.b "e^à",0   ;136
               dc.b 'e"â',0   ;137
               dc.b 'eπâ',0
               dc.b "e`ä",0   ;138
               dc.b 'i"ã',0   ;139
               dc.b 'iπã',0
               dc.b "i^å",0   ;140
               dc.b "i`ç",0   ;141
               dc.b 'A"é',0   ;142
               dc.b 'Aπé',0
               dc.b "A.è",0   ;143
               dc.b "A¯è",0
               dc.b "E'ê",0   ;144
               dc.b "aeë",ORDER ;145
               dc.b "AEí",ORDER ;146
               dc.b "Aeí",ORDER
               dc.b "o^ì",0   ;147
               dc.b 'o"î',0   ;148
               dc.b 'oπî',0
               dc.b "o`ï",0   ;149
               dc.b "u^ñ",0   ;150
               dc.b "u`ó",0   ;151
               dc.b 'y"ò',0   ;152
               dc.b 'yπò',0
               dc.b 'O"ô',0   ;153
               dc.b 'Oπô',0
               dc.b 'U"ö',0   ;154
               dc.b 'Uπö',0
               dc.b "c/õ",0   ;155
               dc.b "C/õ",0
               dc.b "c|õ",0
               dc.b "C|õ",0
               dc.b "L_ú",0   ;156
               dc.b "L-ú",0
               dc.b "l-ú",0
               dc.b "l_ú",0
               dc.b "Y-ù",0   ;157 Yen
               dc.b "y-ù",0
               dc.b "Y=ù",0
               dc.b "y=ù",0
               dc.b "ssû",0   ;158 German Eszet
               dc.b "f-ü",0   ;159 Florin
               dc.b "a'†",0   ;160
               dc.b "i'°",0   ;161
               dc.b "o'¢",0   ;162
               dc.b "u'£",0   ;163
               dc.b "n~§",0   ;164
               dc.b "N~•",0   ;165
               dc.b "a_¶",0   ;166 a underscore (not NVDI)
               dc.b "a-¶",0
               dc.b "o_ß",0   ;167 o underscore (not NVDI)
               dc.b "o-ß",0
               dc.b "??®",0   ;168
               dc.b "12´",ORDER ;171
               dc.b "14¨",ORDER ;172
               dc.b "!!≠",0   ;173
               dc.b "<<Æ",0   ;174
               dc.b ">>Ø",0   ;175
               dc.b "a~∞",0   ;176
               dc.b "o~±",0   ;177
               dc.b "O/≤",0   ;178
               dc.b "O|≤",0
               dc.b "o/≥",0   ;179
               dc.b "o|≥",0
               dc.b "oe¥",ORDER ;180
               dc.b "OEµ",ORDER ;181
               dc.b "Oeµ",ORDER
               dc.b "A`∂",0   ;182
               dc.b "A~∑",0   ;183
               dc.b "O~∏",0   ;184
               dc.b '" π',0   ;185
               dc.b "` ∫",0   ;186
               dc.b "+ ª",0   ;187
               dc.b "PPº",0   ;188
               dc.b "ppº",0
               dc.b "P|º",0
               dc.b "p|º",0
               dc.b "p/º",0
               dc.b "P/º",0
               dc.b "coΩ",0   ;189
               dc.b "COΩ",0
               dc.b "roæ",0   ;190
               dc.b "ROæ",0
               dc.b "tmø",0   ;191
               dc.b "TMø",0
; dc.b "ij¿",0  ;ij ligature not defined in NVDI 3 mapping
; dc.b "IJ¡",0  ;ij ligature not defined in NVDI 3 mapping
; dc.b "Ij¡",0
;************ NVDI 3 FontMap new chars
               dc.b "A^¿",0   ;192 (NOT ij)
               dc.b "A'¡",0   ;193
               dc.b "E^¬",0   ;194
               dc.b 'E"√',0   ;195
               dc.b 'Eπ√',0   ;195
               dc.b "E`ƒ",0   ;196
               dc.b "I^≈",0   ;197
               dc.b 'I"∆',0   ;198
               dc.b 'Iπ∆',0   ;198
               dc.b "I`«",0   ;199
               dc.b "I'»",0   ;200
               dc.b "O^…",0   ;201
               dc.b "O` ",0   ;202
               dc.b "O'À",0   ;203
               dc.b "U^Ã",0   ;204
               dc.b "U`Õ",0   ;205
               dc.b "U'Œ",0   ;206
               dc.b ",,œ",0   ;207
               dc.b "``–",0   ;208
               dc.b "''—",0   ;209
               dc.b ", “",0   ;210
               dc.b "' ”",0   ;211
               dc.b "< ‘",0   ;212
               dc.b "> ’",0   ;213
               dc.b "- ÷",0   ;214 dash medium
               dc.b "_ ◊",0   ;215 dash long
               dc.b "Ptÿ",ORDER ;216 Peseta sign
               dc.b "PTÿ",ORDER
               dc.b "ptÿ",ORDER
               dc.b "upŸ",ORDER ;217
               dc.b "UPŸ",ORDER
               dc.b "dn⁄",ORDER ;218
               dc.b "DN⁄",ORDER
               dc.b "rt€",ORDER ;219
               dc.b "RT€",ORDER
               dc.b "lt‹",ORDER ;220
               dc.b "LT‹",ORDER
               dc.b "so›",ORDER ;221
               dc.b "SO›",ORDER
               dc.b "%oﬁ",0   ;222
               dc.b "%.ﬁ",0
;************ Normale FontMap
               dc.b "ooﬂ",ORDER ;223
               dc.b "OOﬂ",ORDER
               dc.b "al‡",ORDER ;224 alpha
               dc.b "AL‡",ORDER
               dc.b "be·",ORDER ;225 beta
               dc.b "BE·",ORDER
               dc.b "ga‚",ORDER ;226 GAMMA
               dc.b "GA‚",ORDER
               dc.b "pi„",ORDER ;227 pi
               dc.b "PI„",ORDER
               dc.b "SI‰",ORDER ;228 SIGMA
               dc.b "SS‰",ORDER
               dc.b "siÂ",ORDER ;229 sigma
               dc.b "u/Ê",0   ;230 my
               dc.b "u|Ê",0
               dc.b "myÊ",ORDER
               dc.b "MYÊ",ORDER
               dc.b "taÁ",ORDER ;231 tau
               dc.b "TAÁ",ORDER
               dc.b "phË",ORDER ;232 PHI
               dc.b "PHË",ORDER
               dc.b "O-È",0   ;233 THETA
               dc.b "THÈ",ORDER
               dc.b "thÈ",ORDER
               dc.b "OMÍ",ORDER ;234 OMEGA
               dc.b "omÍ",ORDER
               dc.b "deÎ",ORDER ;235 delta
               dc.b "=-",0   ;240
               dc.b "+-Ò",0   ;241
               dc.b ">-Ú",0   ;242
               dc.b ">_Ú",0
               dc.b ">=Ú",0
               dc.b "<-Û",0   ;243
               dc.b "<_Û",0
               dc.b "<=Û",0
               dc.b ":-ˆ",0   ;246
               dc.b "=~˜",0   ;247
               dc.b "o ¯",0   ;248
               dc.b "* ˘",0   ;249
               dc.b ". ˙",0   ;250
               dc.b "v ˚",0   ;251
               dc.b "n ¸",0   ;252
               dc.b "2 ˝",0   ;253
               dc.b "3 ˛",0   ;254
               dc.b "_ ˇ",0   ;255
               dc.l 0         ;total 193 EintrÑge

COMPTABSIZE    equ (*-comptab)/4-1

MAXTABSIZE     equ 256

               if COMPTABSIZE>MAXTABSIZE
               fail 'Composetab zu lang.'
               endc

*
* Platz fÅr weitere Tastaturtabellen:
*

tab_unshift:   ds.b 128
tab_shift:     ds.b 128
tab_caps:      ds.b 128
tab_compose:   ds.l MAXTABSIZE ;1 KByte sollte reichen ( 256 Kombinationen )
emstop:        dc.l 0

* Saveptr - AREA!
               ds.w 46        ; 2 aufrufe...
newarea:
               endpart
               >PART 'MSE: initialized data'

; Sinustab: tab[index] = (int)(256*sin(index)+0.5)
;---------------------------------------------------------------------
sinustab:      dc.w 0,4,9,13,18,22,27,31,36,40 ;              0..9¯  |
               dc.w 44,49,53,58,62,66,71,75,79,83 ;          10..19¯ |
               dc.w 88,92,96,100,104,108,112,116,120,124 ;   20..29¯ |
               dc.w 128,132,136,139,143,147,150,154,158,161 ;30..39¯ |
               dc.w 165,168,171,175,178,181,184,187,190,193 ;40..49¯ |
               dc.w 196,199,202,204,207,210,212,215,217,219 ;50..59¯ |
               dc.w 222,224,226,228,230,232,234,236,237,239 ;60..69¯ |
               dc.w 241,242,243,245,246,247,248,249,250,251 ;70..79¯ |
               dc.w 252,253,254,254,255,255,255,256,256,256 ;80..89¯ |
               dc.w 256       ;                              90¯     |
;---------------------------------------------------------------------

; Squares-tab: tab[index]=index^2
;---------------------------------------------------------------------

squaretab:
A              set 0
               rept SQUARETABSIZ
               dc.w A*A
A              set A+1
               endr

;---------------------------------------------------------------------


; Kontrollstruktur zum Vorzeigen!
MouseCntrlStruct:
msc_switches:  dc.w %0        ;bitmapped switches -> mspeeder off
msc_polynomial:dc.w 0,29,133,93 ;speeder polynomial (original james 1.6)
msc_rotation:  dc.w 0         ;rotation angle
msc_ratio:     dc.w 256       ;aspect ratio compensation
msc_resolution:dc.w 100       ;mouse resolution in dpi
msc_screenrez: dc.w 72        ;screen resolution in dpi

               endpart

id_msg:        dc.b 'CKBD Deluxe v'
               dc.b VER+'0','.',REV+'0'
               dc.b ' by Pascal Fellerich'
               dc.b 0

               even
;********* ADDITIONAL CODE FOR OLD TOS *****************************************
               >PART 'Zusatz-code fÅr Ñltere TOSse'
eoc:
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* hÑngt im RESET Handler; lîscht die 'neuen' Systemvariablen ($500-$600)
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
               dc.l 'XBRA',xb_id,0
reset:    moveq     #$0100/4-1,d0
          lea       $0500.w,a0
clrsys:   clr.l     (a0)+
          dbra      d0,clrsys
          move.l    reset-XB_OLDVEC(pc),_resvector.w
          move.l    oldvalid(pc),_resvalid.w
          jmp       (a6)                ;return to system

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* substituiert die KLICK & BELL routinen.
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
newbell:  lea       bellsound(pc),a0
          bra.s     dosound
newclick: lea       clicksound(pc),a0
* Wegen TOS 1.4 - crash:
dosound:  move.l    savptr.w,oldsavp
          move.l    #newarea,savptr.w
          pea       (a0)
          move.w    #Dosound,-(sp)      ;Xbios DOSOUND
          trap      #14
          addq.l    #6,sp
          move.l    oldsavp(pc),savptr.w
          rts

eoc_old_tos:
RESIDENTCODE   equ *-start+256

               endpart

;*******************************************************************************

               >PART 'startup & install'
StartUp:  movea.l   4(sp),a6            ;Basepageadresse holen
          movea.w   #$0100+STKSIZE,a5   ;Grîûe der Basepage + Stackgrîûe (1k)
          adda.l    12(a6),a5           ;+ Grîûe des TEXT-Segments
          adda.l    20(a6),a5           ;+ Grîûe des DATA-Segments
          adda.l    28(a6),a5           ;+ Grîûe des BSS-Segments
          move.l    a5,d1               ;= GesamtlÑnge des Programms
          and.w     #$FFFE,d1           ;LÑnge nun gerade
          add.l     a6,d1               ;+ Programmstart (Basepageadresse)
          movea.l   d1,sp               ;Stack endet dort
          move.l    a5,-(sp)            ;ProgrammlÑnge
          move.l    a6,-(sp)            ;Adresse der Basepage
          move.l    #$4A0000,-(sp)      ;Funktionsnummer + Dummyword (0)
          trap      #1                  ;Mshrink(0,Basepageadr,PrglÑnge)
          lea       12(sp),sp           ;Nur noch den Stack korrigieren
;Das war schon alles. In A6 befindet sich noch die Basepageadresse und in a5
;liegt die totale ProgrammlÑnge (TRAP #1 zerstîrt D0-D2 und A0-A2!)
          move.l    a6,basepage
          lea       varbase(pc),a5

          pea       msg_title(pc)
          move.w    #Cconws,-(sp)
          trap      #1                  ;Cconws
          addq.w    #6,sp

;-----------------------------------------------------------------------
; 1. Residente FN's intern initialisieren:
;-----------------------------------------------------------------------

          bsr.s     pre_init_setup      ;do it all

;-----------------------------------------------------------------------
; 2. Vektoren installieren
;-----------------------------------------------------------------------
          move.l    #eoc,code_end       ;bis wohin?

          pea       vectinstall(pc)     ;jetzt die Vektoren init.
          move.w    #Supexec,-(sp)
          trap      #14                 ;Supexec
          addq.w    #6,sp

          tst.l     d0
          bne.s     term

;-----------------------------------------------------------------------
; 3. Residente variablen fertig intialisieren
;-----------------------------------------------------------------------

          bsr       post_init_setup

;-----------------------------------------------------------------------
; 4. Alternative Belegung nachladen (weitere optionale Init.)
;-----------------------------------------------------------------------
;          bsr       do_autoload

          pea       msg_ok(pc)
          move.w    #Cconws,-(sp)
          trap      #1                  ;Cconws
          addq.w    #6,sp

          bsr.s     waitcontrol

          clr.w     -(sp)               ;ret
          movea.l   code_end(pc),a0     ;ende
          suba.l    #start,a0           ;codestart
          lea       256(a0),a0          ;+basepage
          move.l    a0,-(sp)            ;keep
          move.w    #Ptermres,-(sp)
          trap      #1                  ;Ptermres

term:     pea       emergency(pc)       ;NOTFALL -> Installation nicht mîglich
          move.w    #Cconws,-(sp)
          trap      #1
          addq.w    #6,sp

;-----------------------------------------------------------------------
;TERMINIEREN:
;-> warte auch bei CONTROL gedrÅckt!
;-----------------------------------------------------------------------
          bsr.s     waitcontrol
          clr.w     -(sp)
          trap      #1
          illegal

waitcontrol:
          move.l    #$0BFFFF,-(sp)      ;kbshift(-1)
          trap      #13
          addq.w    #4,sp
          andi.w    #$07,d0
          bne.s     waitcontrol
          rts

               endpart
               >PART '---: 1 pre-init setup'
pre_init_setup:
;-----------------------------------------------------------------------
; 1. Keyboard Driver:
;-----------------------------------------------------------------------
          clr.w     -(sp)               ;alles aus & vektoren setzen
          move.w    #CBIOSKEYS,-(sp)
          jsr       _setup(pc)          ;  ckbd(CBIOSKEYS);
          move.w    #ON,-(sp)           ;Extkey einschalten
          move.w    #EXTKEY,-(sp)
          jsr       _setup(pc)
          move.w    #(ON|DEC_MODE),-(sp) ;Compose ein,
          move.w    #COMPOSE,-(sp)      ;Digital Equipment Corporation mode
          jsr       _setup(pc)          ;sonst nix.
          move.w    #ON,-(sp)           ;MS-DOS emulator
          move.w    #ALT_NNN,-(sp)
          jsr       _setup(pc)
          move.w    #ON,-(sp)
          move.w    #DEADKEY,-(sp)
          jsr       _setup(pc)
          lea       20(sp),sp

;-----------------------------------------------------------------------
; 2. Compose-Tabelle sortieren:
;-----------------------------------------------------------------------
          move.w    tabsize(pc),d1
          subq.w    #1,d1               ;wg. quicksort :-)   (C-Code!)
          moveq     #0,d0               ;untergrenze = 0
          movea.l   keytbl_compose(pc),a0 ;diese Tabelle!
          jsr       sort(pc)            ;Tabelle sortieren

;-----------------------------------------------------------------------
; 3. IOREC fÅr Tastatur holen
;-----------------------------------------------------------------------
          move.w    #1,-(sp)            ;Device CON:
          move.w    #Iorec,-(sp)
          trap      #14                 ;Iorec(CON)
          addq.w    #4,sp
          move.l    d0,kbd_iorec        ;merken

;-----------------------------------------------------------------------
; 4. Maustreiber-variablen initialisieren
;-----------------------------------------------------------------------
          pea       MouseCntrlStruct(pc) ;Default Einstellung benutzen
          move.w    #SET,-(sp)
          move.w    #MOUSE_CFG,-(sp)
          jsr       _setup(pc)
          addq.w    #8,sp

;-----------------------------------------------------------------------
          rts

               endpart
               >PART '---: 2 init: Vektor-install' ;              supermode

; cookie *cookie_find(long magic)
;         scans the cookie jar for a given magic.
;         Return (a0): NULL - not found
;                 otherwise ptr to cookie data
cookie_find:
          movea.l   _p_cookies.w,a0     ;get cookie jar ptr
          move.l    a0,d1
          beq.s     ck_end1             ;NULL ptr -> not found
ck_next1: cmp.l     (a0),d0             ;check magic
          beq.s     ck_exit1            ;this is it!
          tst.l     (a0)                ;end marker?
          beq.s     ck_end1
          addq.l    #8,a0               ;next entry
          bra.s     ck_next1
ck_end1:  moveq     #0,d0               ;return null ptr (not found)
          movea.l   d0,a0
ck_exit1: rts

;-----------------------------------------------------------------------
; System analysieren, Cookie Jar auffÅllen / anlegen, resetcode install.
;-----------------------------------------------------------------------
vectinstall:
          moveq     #0,d7
          tst.l     kcl_hook.w          ;ist NULL bei < TOS 1.6
          bne.s     vec1
          move.l    #newclick,kcl_hook.w
          st        d7                  ;Zeigt an, daû nun die Resetroutine benîtigt wird
vec1:     tst.l     bell_hook.w
          bne.s     vec2
          move.l    #newbell,bell_hook.w
          st        d7
vec2:     movea.l   _sysbase.w,a0

;-----------------------------------------------------------------------
; 1. KBSHIFT feststellen
;-----------------------------------------------------------------------
          lea       $0E1B.w,a1          ;kbshift adresse TOS 1.0
          cmpi.w    #$0102,2(a0)        ;os_version
          blo.s     vec3                ;altes TOS
          movea.l   36(a0),a1           ;sonst KBSHIFT richtig holen
vec3:     move.l    a1,kbshift

;-----------------------------------------------------------------------
; 2. Keyboard vectors holen & Tastaturhandler installieren:
;-----------------------------------------------------------------------
          move.w    #Kbdvbase,-(sp)     ;opcode
          trap      #14                 ;KBDVBASE
          addq.w    #2,sp
          move.l    d0,sys_kbdvbase     ;fÅr weitere Verwendung
          movea.l   d0,a4
          lea       32(a4),a4

          move.l    #'MgMc',d0          ;MagicMac Cookie suchen
          bsr.s     cookie_find
          move.l    a0,d0               ;check return ptr
          bne.s     use_MacHandler

          move.l    #'_SND',d0          ;Sound Hardware ?
          bsr.s     cookie_find
          move.l    a0,d0               ;check return ptr
          beq.s     use_MacHandler      ;no _SND cookie -> default
          btst      #1,7(a0)            ;STE/TT DMA sound available?
          beq.s     use_MacHandler      ;no -> Mac KBD handler

          lea       KBDhandler(pc),a1
          bra.s     use_it
use_MacHandler:
          lea       MacKBDhandler(pc),a1
use_it:   movea.l   a4,a0
          bsr       Xb_install
          bne       raus                ;Fehler bei der Installation -> total abbrechen

;-----------------------------------------------------------------------
; 3. normalen VBL-Slot einsetzen:
;-----------------------------------------------------------------------
          movea.l   _vblqueue.w,a0
          move.w    nvbls.w,d0          ;Anzahl Slots
          addq.l    #4,a0
          subq.w    #2,d0
vec:      tst.l     (a0)+
          dbeq      d0,vec
          subq.l    #4,a0
          lea       vbl_irq(pc),a1
          bsr       Xb_install

;-----------------------------------------------------------------------
; 4. Cookie Jar fÅllen / installieren
;-----------------------------------------------------------------------
          move.l    _p_cookies.w,d1     ;Cookie Pointer
          bne.s     jar_present         ;kein Problem, Jar schon da
          movea.l   basepage(pc),a2
          lea       128(a2),a2          ;Start des neuen Jars = commandline!
          movea.l   a2,a0
          move.l    #xb_id,(a0)+        ;erster Eintrag = mein Eintrag!
          move.l    #_setup,(a0)+       ;Zeiger auf meinen Funktionsdispatcher
          clr.l     (a0)+               ;Eintrag #2: ENDEKENNUNG
          moveq     #MAXCKENTRIES,d1
          move.l    d1,(a0)+            ;genau 16 EintrÑge mîglich
          move.l    a2,_p_cookies.w     ;im System vermerken
          st        d7                  ;Reset - clear nîtig!
* Cookie Jar schon vorhanden -> don't need resetcode
jar_present:
          movea.l   d1,a2               ;ptr to cookiejar
          moveq     #0,d3               ;Counter

jar_search:                             ;suche freien Slot
          addq.w    #1,d3               ;Eintrag mitzÑhlen
          tst.l     (a2)
          beq.s     lastentry
          addq.l    #8,a2
          bra.s     jar_search
lastentry:                              ;gefunden - ist noch Platz da?
          move.l    4(a2),d1            ;get Max. entries
          cmpi.w    #MAXCKENTRIES-5,d1  ;cmp jarsize
          ble.s     jar_use_own         ;own jar is >=5 entries bigger -> use it
          cmp.w     d1,d3               ;alles besetzt?
          blt.s     jar_is_ok           ;nein, Platz reicht noch.
jar_use_own:
          cmpi.w    #MAXCKENTRIES-1,d3  ;need at least 1 additional entry!
          bgt.s     jar_bye             ;auch bei mir kein Platz -> sorry, das wars dann!
          movea.l   _p_cookies.w,a0     ;jar duplizieren!
          movea.l   basepage(pc),a2
          lea       128(a2),a2
          pea       (a2)                ;push new address
jar_dupe: move.l    (a0)+,(a2)+         ;einen Eintrag duplizieren
          beq.s     jar_copied
          move.l    (a0)+,(a2)+
          bra.s     jar_dupe
jar_copied:                             ;alles kopiert, neuen Eintrag dazu!
          move.l    (sp)+,_p_cookies.w
          moveq     #MAXCKENTRIES,d0
          move.l    d0,(a2)             ;neue LÑnge
          subq.l    #4,a2               ;vorigen Eintrag!
jar_is_ok:                              ;genug Platz vorhanden!
          move.l    (a2),8(a2)
          move.l    4(a2),12(a2)        ;copy
          move.l    #xb_id,(a2)
          move.l    #_setup,4(a2)       ;Mein Eintrag
;---------
jar_bye:  tst.b     d7
          beq.s     inst_ok
          move.l    #eoc_old_tos,code_end
          move.l    _resvalid.w,oldvalid ;resetroutine ist nun nîtig!
          move.l    #$31415926,_resvalid.w
          move.l    _resvector.w,reset+XB_OLDVEC
          move.l    #reset,_resvector.w
inst_ok:  moveq     #0,d0
raus:     rts

               endpart
               >PART '---: 2 post-init setup'
post_init_setup:

          rts

               endpart


;                    0000000001111111111222222222233333333334
;                    1234567890123456789012345678901234567890
msg_title:     dc.b 13,10,27,'p'
               dc.b ' CKBD Deluxe 1.5           11-MAY-1996 ',27,'q',13,10
               dc.b 'with PAULA/NVDI3 fix',13,10
               dc.b 'by Pascal Fellerich',13,10,0

msg_ok:        dc.b 'Installed.',13,10
               dc.b 0

emergency:     dc.b '*** INSTALLATION CODE FAILED!!!!!!! ***',13,10
;              dc.b '*** try again after a COLD START!!! ***',13,10
               dc.b 7,0

               >PART 'BSS'
               bss
basepage:      ds.l 1
code_end:      ds.l 1
               endpart

               end

; oldstuff
               >PART 'KBD: Auto-Load feature'
* sucht im aktuellen DIR eine Datei namens 'AUTOLOAD.CKB' und lÑdt sie!
do_autoload:
          clr.w     -(sp)               ;readonly
          pea       autofile(pc)
          move.w    #61,-(sp)           ;Fopen
          trap      #1
          addq.l    #8,sp
          move.w    d0,d6               ;Handle
          bmi       af_notfound         ;autofile not found!

          move.w    #2,-(sp)            ; seekmode from end
          move.w    d6,-(sp)            ; handle
          clr.l     -(sp)               ; offset
          move.w    #66,-(sp)           ; Fseek
          trap      #1
          lea       10(sp),sp
          move.l    d0,d5               ;file length!
          clr.w     -(sp)               ; from start
          move.w    d6,-(sp)            ; handle
          clr.l     -(sp)               ; offset
          move.w    #66,-(sp)           ; Fseek
          trap      #1
          lea       10(sp),sp

          move.l    d5,-(sp)            ; amount
          move.w    #72,-(sp)           ; Malloc
          trap      #1
          addq.l    #6,sp

          move.l    d0,d4               ;base address
          beq       af_nomemory         ;sorry out of memory!

          move.l    d4,-(sp)            ; buffer
          move.l    d5,-(sp)            ; count
          move.w    d6,-(sp)            ; handle
          move.w    #63,-(sp)           ; Fread
          trap      #1
          lea       12(sp),sp

          move.w    d6,-(sp)            ; handle
          move.w    #62,-(sp)           ; Fclose
          trap      #1
          addq.l    #4,sp

;---- Datei ist geladen -> jetzt initialisieren!
          movea.l   d4,a0               ;memory base
          cmpi.l    #'CKBD',(a0)
          bne       af_wrongfile        ;das wars nicht!
          lea       16+4*2(a0),a1       ;letzter word eintrag: compose offset

          pea       4(a0)               ;Name!
          moveq     #-1,d1
          moveq     #3,d2
af_l:     move.l    d1,-(sp)            ;-1: nicht Ñndern!
          move.w    -(a1),d0            ;unshift/shift/caps/compose offset
          beq.s     af_l1               ;keine Tabelle da!
          lea       0(a0,d0.w),a2       ;Tabellenstartadresse rechnen
          move.l    a2,(sp)
af_l1:    dbra      d2,af_l
;--- stack ist gefÅllt -> OK, call ckbd
          move.w    #CKEYTBL,-(sp)      ;OpCode
          jsr       _setup(pc)
          lea       22(sp),sp           ;5 Longs & 1 word

;--- Compose MODUS setzen:
          movea.l   d4,a2
          move.w    24(a2),d0           ;Compose Modus
          andi.w    #$FFF0,d0
          cmpi.w    #$BAD0,d0           ;Magic Opcode?
          bne.s     af_oldfile

          move.w    24(a2),-(sp)        ;1 Composemode
          move.w    #COMPOSE,-(sp)      ;1
          jsr       _setup(pc)
          move.w    26(a2),(sp)         ;0 Extkeymode
          move.w    #EXTKEY,-(sp)       ;1
          jsr       _setup(pc)
          move.w    28(a2),(sp)         ;0 AltNNNmode
          move.w    #ALT_NNN,-(sp)      ;1
          jsr       _setup(pc)
          move.w    30(a2),-(sp)        ;1 Deadkeymode
          move.w    #DEADKEY,-(sp)      ;1
          jsr       _setup(pc)
          lea       12(sp),sp

          lea       32(a2),a0
          tst.b     (a0)                ;String dran?
          beq.s     af_wrongfile        ;niet

          pea       (a0)
          move.w    #SET,-(sp)
          move.w    #DEADKEY,-(sp)
          jsr       _setup(pc)
          addq.l    #8,sp

          bra.s     af_wrongfile
;--- alte Tabelle
af_oldfile:
          move.w    24(a2),-(sp)        ;Modus fÅr Compose!
          move.w    #COMPOSE,-(sp)
          jsr       _setup(pc)
          addq.w    #4,sp

af_wrongfile:
          move.l    d4,-(sp)            ; base address
          move.w    #73,-(sp)           ; Mfree
          trap      #1
          addq.l    #6,sp

af_nomemory:
af_notfound:
          rts

autofile:      dc.b 'AUTOLOAD.CKB',0
               ds.b 8         ;fÅr's Patchen!

               endpart
               end
