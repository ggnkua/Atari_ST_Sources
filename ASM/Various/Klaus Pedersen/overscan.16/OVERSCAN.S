;----------------------------------------------------;
;      OVERSCAN.S       Version 1.6                  ;
;      Bernd Gebauer   ,Berlin 31.05.89              ;
;      Karsten Isakovic,Berlin 07.07.89              ;
;                    ---                             ;
;                                                    ;
;      OVERSCAN.S       Version 1.61                 ;
;    * Slightly changed (shrinked)                   ;
;   Klaus Pedersen, Odense 15.05.91                  ;
;                    ---                             ;
;                                                    ;
;      OVERSCAN.S       Version 1.62                 ;
;    * a bug that made Overscan overwrite other      ;
;      programs stack in colour mode is fixed!       ;
;    * works in 60Hz mode!                           ;
;    * Saving fixed. (now seperate file!)            ;
;    * Changing of phys-base isn't legal any more.   ;
;      - this should force programs to use the VDI.  ;
;    * code is even smaller!                         ;
;    * changing of rez. in overscan config works     ;
;      - also with NVDI? and GDOS!                   ;
;   Klaus Pedersen, Odense 03.04.93                  ;
;                   ---                              ;
;                                                    ;
; ROMTOS 1.4 and about, TurboAss 1.26                ;
;----------------------------------------------------;


; ------------ NEGATIVE LINE-A VARIABLEN -------------

*M_POS_HX        EQU -$0358
DEV_TAB         EQU -$02B4
WKXRez          EQU DEV_TAB+0
WKYRez          EQU DEV_TAB+1*2

v_cel_ht        EQU -$2E
v_cel_mx        EQU -$2C
v_cel_my        EQU -$2A
v_cel_wr        EQU -$28
v_cur_add       EQU -$22
v_cur_of        EQU -$1E
v_cur_x         EQU -$1C
v_cur_y         EQU -$1A
v_rez_hz        EQU -$0C
v_rez_vt        EQU -4
bytes_lin       EQU -2
; ---------- LINE-A VARIABLEN ------------------------

v_planes        EQU 0
width           EQU 2
col_bit0        EQU $18
col_bit1        EQU $1A
col_bit2        EQU $1C
col_bit3        EQU $1E
lstlin          EQU $20
lnmask          EQU $22
wmode           EQU $24
x1              EQU $26
y1              EQU $28
x2              EQU $2A
y2              EQU $2C

; ----------------- HARDWARE + TOS -------------------

gemdos          EQU 1
xbios           EQU 14
Pterm0          EQU 0                   ; Gemdos
Cnecin          EQU 8                   ; Gemdos
Cconws          EQU 9                   ; Gemdos
Dgetdrv         EQU 25                  ; Gemdos
Ptermres        EQU 49                  ; Gemdos
Fcreate         EQU 60                  ; Gemdos
Fopen           EQU 61                  ; Gemdos
Fclose          EQU 62                  ; Gemdos
Fread           EQU 63                  ; Gemdos
Fwrite          EQU 64                  ; Gemdos
Fseek           EQU 66                  ; Gemdos
Pterm           EQU 76                  ; Gemdos
Malloc          EQU 72                  ; Gemdos
Mshrink         EQU 74                  ; Gemdos
Pexec           EQU 75                  ; Gemdos
Physbase        EQU 2                   ; xbios
Setscreen       EQU 5                   ; xbios
Supexec         EQU 38                  ; xbios
SetColor        EQU 7                   ; xbios

dostrap         EQU $84
gemtrap         EQU $88
xbiostrap       EQU $B8
memtop          EQU $0436
palmode         EQU $0448
sshiftmd        EQU $044C
v_bas_add       EQU $044E
dumpflag        EQU $04EE
sysbase         EQU $04F2
hardcopy        EQU $0502
longframe       EQU $059E

vid_bashigh     EQU $FFFF8201
vid_basmid      EQU $FFFF8203
vid_ismid       EQU $FFFF8207
add_len         EQU $9000

                TEXT

first:          bra     main            ; jump to non resident code !

*#####################################################################
** The tabel for screen sizes.
** Size : ScreenTabEnd-ScreenTab
*#####################################################################
ScreenTab:
                DC.W 400,832,672        ; X-Auflîsung Low,Mid,High
                DC.W 280,280,480        ; Y-Auflîsung
                DC.W 236,236,100        ; Bytes pro Zeile
                DC.L -$1600,-$1600,$2000 ; VideoAdd  <> Memtop Offset (+18)
                DC.L 252,248,9800       ; v_bas_add <> Memtop Offset (+30)
screen60:
                DC.W 400,832,672        ; X-Auflîsung Low,Mid,High
                DC.W 280,280,480        ; Y-Auflîsung
                DC.W 234,234,100        ; Bytes pro Zeile
                DC.L -$1600,-$1600,$2000 ; VideoAdd  <> Memtop Offset (+18)
                DC.L 254,246,9800       ; v_bas_add <> Memtop Offset (+30)

Palmode:        DC.W $FF
ActivateKey:    DC.B 9,0                ; Hardcopy Taste
ScreenTabEnd:   DS.W 0

OrigScreens:    DC.W 320,640,640        ; Alte X-Auflîsung
                DC.W 201,201,401        ; Alte Y-Auflîsung
                DC.W 160,160,80         ; Bytes pro Zeile
                DC.L 0,0,0              ; VideoAdd  <> Memtop Offset
                DC.L 0,0,0              ; v_bas_add <> Memtop Offset

                EVEN


;#########################################################
;# Used Traps and vectors
;# ----------------------
;#        MyGem      AES/VDI Trap
;#        MyDos      GEMDOS  Trap
;#        MyXbios    XBIOS   TRAP
;#        MyHard     Hardcopy-Vektor
;################################################ GEM-TRAP

                DC.B "XBRAOVER"
OldVec:         DC.L 0
MyGem:          cmpi.w  #$73,D0         ; Is it a VDI-call ?
                bne.s   NotMyGem1       ;   no -> continue
                movem.l A0-A1,-(SP)     ; it's documented, VDI preserve all regs
                movea.l D1,A1           ; Address of VDI-Parameters
                movea.l (A1)+,A0        ; VDI-Control[0] = VDI-function
                cmpi.w  #1,(A0)         ; is it a Open-WorkStation ?
                bne.s   NotMyGem        ;    no -> continue
                movea.l (A1)+,A0        ; WorkIn-pointer
                cmpi.w  #9,(A0)         ;    WorkIn[0] equal Screen ?
                bge.s   NotMyGem        ;    no -> continue

;-------> AFTER!!! 'v_opnwk()' call Patch-routine

                move.l  4(A1),WorkOut   ; save WorkOut-pointer
                move.l  8+2(SP),Back    ; save orginal return address
                move.l  #PatchIt,8+2(SP)

                movea.l p_kbshift(PC),A1 ; test shift keys.
                tst.b   (A1)
                beq.s   NotMyGem

                movem.l D0-D2/A2-A3,-(SP)
                movea.l A0,A3
                bsr     UserInstall
                move.w  Reso(PC),D0
                addq.w  #2,D0
                move.w  D0,(A3)         ; patch workin(0)
                movem.l (SP)+,D0-D2/A2-A3

NotMyGem:       movem.l (SP)+,A0-A1
NotMyGem1:      move.l  OldVec(PC),-(SP) ; call Orginal GEM-dispatcher
                rts                     ; ... call


PatchIt:        st      WorkOutValid
                movem.l D0-D2/A0-A2,-(SP)
                bsr     SetOverscan     ; write LineA values again
                bsr.s   PatchCont       ; write values in WorkOut array
                pea     msg_erase(PC)   ; and screen to white.
                move.w  #Cconws,-(SP)
                trap    #gemdos
                addq.l  #6,SP
                movem.l (SP)+,D0-D2/A0-A2
                move.l  Back(PC),-(SP)  ; Return to 'v_opnwk()' caller
                rts


PatchCont:      bsr     ClearScreen     ; Clear Border (black)
                tst.w   WorkOutValid
                beq.s   PatchEnd
                movea.l WorkOut(PC),A0  ; Address of Workout-array
                movea.l LineA(PC),A1
                move.w  WKXRez(A1),0(A0) ; WorkOut[0] = Width-1 !!!
                move.w  WKYRez(A1),2(A0) ; WorkOut[1] = Height-1 !!!!
                move.w  DEV_TAB+78(A1),78(A0) ; Number of colors in palette
                move.w  DEV_TAB+26(A1),26(A0) ; Number of colors on screen
PatchEnd:       rts


;********************* GEMDOS-Trap **********************
                DC.B "XBRAOVER"
OldDos:         DC.L 0
MyDos:          move    USP,A0
                btst    #5,(SP)         ; called from Supervisor- or User-mode?
                beq.s   tst_funcs       ; Parameter is on USER stack
sm_longframe1:  lea     6(SP),A0        ; small stack frame- patched to long.

tst_funcs:      cmpi.w  #Pterm0,(A0)    ; The Overscan-Mode is reinstalled
                beq.s   TermFound       ; AFTER all programs!
                cmpi.w  #Pterm,(A0)
                beq.s   TermFound
                tst.w   WorkOutValid    ; Don't intersept PtermRes
                beq.s   NoTerm          ; before the GEM have been initized.
                cmpi.w  #Ptermres,(A0)
                bne.s   NoTerm

TermFound:      move.l  A2,-(SP)
                bsr     SetOverscan
                bsr     ClearScreen
                movea.l (SP)+,A2
NoTerm:         movea.l OldDos(PC),A0
                jmp     (A0)



;********************* XBIOS-Trap **********************
                DC.B "XBRAOVER"
OldXbios:       DC.L 0
MyXbios:        move    USP,A0
                btst    #5,(SP)         ; called from Supervisor- or User-mode?
                beq.s   tst_phys        ; Parameter is on USER stack
sm_longframe2:  lea     6(SP),A0        ; small stack frame- patched to long.

tst_phys:       cmpi.w  #Physbase,(A0)  ; Beim Physbase-Aufruf wird
                beq.s   PhysFound       ;
                cmpi.w  #Setscreen,(A0)
                bne.s   No_Xbios
                moveq   #-1,D0
                move.l  D0,6(A0)        ; and physbase is not legal

No_Xbios:       movea.l OldXbios(PC),A0
                jmp     (A0)

PhysFound:      move.l  BasAdd(PC),D0   ; v_bas_add zurÅckgegeben
                rte


;********************* HARDCOPY-Vector ********************
                DC.B "XBRAOVER"
OldHard:        DC.L 0
MyHard:         movea.l p_kbshift(PC),A0 ; test for Shift ALT/HELP testen
                move.b  (A0),D0
                cmp.b   ActivateKey(PC),D0 ; pressed -> call overscan
                beq.s   NewHard
                movea.l OldHard(PC),A0  ; no -> call old Routine
                jmp     (A0)

NewHard:        movem.l D1-D2/A1-A2,-(SP)
                lea     NormalVideo(PC),A1
                tst.w   (A1)
                bne.s   NoOverscan      ; Normal Video?
                bsr     TestSwitch      ;    Yes, check switch...
                bne.s   NoSwitchChange  ; NO CHANGE...
                st      (A1)
                bra.s   HardChange
NoOverscan:     bsr     TestSwitch      ;    No, check Switch...
                beq.s   NoSwitchChange  ; NO CHANGE...
                clr.w   (A1)
HardChange:     bsr.s   SetOverscan
                bsr     PatchCont
                bra.s   HardRts
NoSwitchChange: bsr.s   SetOverscan
                bsr     ClearScreen
HardRts:        movem.l (SP)+,D1-D2/A1-A2
                move.w  #-1,dumpflag.w  ; clear hardcopy dump-flag
                rts


;#############################################################
;# Die wichtigsten Unterprogramme
;# ------------------------------
;#     SetOverscan       LineA und Auflîsung initialisieren
;#     ClearScreen       Nur BildschirmRÑnder auf Schwarz
;#     ClearFullScreen   Ganzen Bildschirmspeicher lîschen
;#############################################################

CallSetOverscan:pea     SetOverscan(PC)
                move.w  #Supexec,-(SP)  ; call in supervisor-mode
                trap    #xbios
                addq.l  #6,SP
                rts

; uses A0,D0-D2
SetOverscan:    bsr     supsetfreq

                lea     ScreenTab(PC),A0 ; Get Screen table pointer
                moveq   #0,D2
                move.b  sshiftmd.w,D2   ; Save resolution
                move.w  D2,Reso-ScreenTab(A0)
                add.w   D2,D2           ; times 2 to get word offset

                tst.w   Palmode         ; if Palmode then use the rigth table
                bne.s   SOver1
                lea     screen60(PC),A0

SOver1:         tst.w   NormalVideo
                beq.s   SOover
                lea     OrigScreens(PC),A0

SOover:         move.w  0(A0,D2.w),RezX
                move.w  6(A0,D2.w),RezY
                move.w  12(A0,D2.w),BpL ; Bytes per Line

                add.w   D2,D2           ; times 4 to get Long offset
                move.l  18(A0,D2.w),D0  ; Offset  MEMTOP <> VIDEO_ADD
                move.l  30(A0,D2.w),D1  ; Offset  MEMTOP <> V_BAS_ADD
                move.w  D1,Offset       ; save

;--------- Set Videoaddress to 'memtop + D0'
                add.l   MyMemtop(PC),D0
                lsr.w   #8,D0
                move.b  D0,vid_basmid.w
                swap    D0
                move.b  D0,vid_bashigh.w

;-------- Set v_bas_ad to 'memtop + D1'
                add.l   MyMemtop(PC),D1
                move.l  D1,v_bas_add.w  ; calculate v_bas_add
                move.l  D1,BasAdd       ; and save it

;-------- Werte in den negativen LineA Variablen anpassen
                movea.l LineA(PC),A0    ; Get LineA Pointer

                move.w  RezY(PC),D0     ; get Height
                move.w  D0,v_rez_vt(A0) ;
                subq.w  #1,D0
                move.w  D0,WKYRez(A0)   ; Height-1

                move.w  BpL(PC),D0      ; Bytes per Line
                move.w  D0,bytes_lin(A0) ;
                move.w  D0,width(A0)    ;

                move.w  RezX(PC),D0     ; get Width
                move.w  D0,v_rez_hz(A0) ;
                move.w  D0,WKXRez(A0)   ;
                subq.w  #1,WKXRez(A0)   ; Width-1

                asr.w   #3,D0           ;
                subq.w  #1,D0           ; Width/8-1
                move.w  D0,v_cel_mx(A0) ; -> chars per line

                moveq   #0,D0           ;
                move.w  RezY(PC),D0     ;
                divu    v_cel_ht(A0),D0 ;
                subq.w  #1,D0           ; Height/char_height - 1
                move.w  D0,v_cel_my(A0) ; -> Number of char rows

                move.w  v_cel_ht(A0),D0 ;
                mulu    BpL(PC),D0      ; CharCellHeight*BytesPerLine
                move.w  D0,v_cel_wr(A0) ; -> Blocklength for Scrolling

; flow through to ResetCursor...


;#####################################################################
; Calculate New Cursor Address
;
ResetCursor:    movea.l LineA(PC),A0

                move.l  BasAdd(PC),D1   ; New Address

                move.w  v_cur_y(A0),D0  ; = V_bas_add
                mulu    v_cel_wr(A0),D0 ;
                add.l   D0,D1           ;      + y * cel_wr

                move.w  v_cur_x(A0),D0  ;
                bclr    #0,D0           ;      + x^1 * v_planes
                mulu    v_planes(A0),D0 ;
                add.l   D0,D1           ;      + x^1 * planes

                move.w  v_cur_x(A0),D0  ;
                andi.l  #$FFFE,D0       ;
                add.l   D0,D1           ;      + x&~1

                moveq   #0,D0           ;
                move.w  v_cur_of(A0),D0 ;
                add.l   D0,D1           ;      + cursor_offset

                move.l  D1,v_cur_add(A0) ; Write new Address
                rts


****************************************************************
; uses A0,A1,D0-D5 (a0,a1,d0-d2).
ClearScreen:    movem.l D3-D5,-(SP)     ; save some regs

                tst.w   NormalVideo
                bne.s   DontClrBorder   ; Normal video -> can't clear border

                bsr     BlackColor      ; Lîschfarbe holen in D0
                move.l  D0,D4           ;

                movea.l MyMemtop(PC),A1
                movea.l BasAdd(PC),A0   ;
                subq.l  #2,A0           ; Falls HIGH_OFF nicht /4 teilbar
Hflp:           move.l  D4,(A1)+        ; Vor dem Bildschirm RÅcklauf
                cmpa.l  A0,A1           ; Pixel auf Schwarz setzen
                blt.s   Hflp            ;

                movea.l BasAdd(PC),A0   ; Links & Rechts im RÅcklauf lîschen
                move.w  BpL(PC),D0      ; Bytes pro Zeile - Pixel/xxx
                move.w  RezX(PC),D1     ;

                move.w  Reso(PC),D5     ;
                addq.w  #1,D5
                asr.w   D5,D1           ;   >>3:High  >>2:Mid  >>1:Low
                sub.w   D1,D0
                subq.w  #1,D0           ;
; D1 : size of active region. D0 unused memory in border.

                move.w  RezY(PC),D2     ; Hîhe des Bereichs
                subq.w  #1,D2           ;
Hlp1:           adda.w  D1,A0           ; Normalen Bildbereich Åberspringen

                move.w  D0,D3           ;
Hlp2:           move.b  D4,(A0)+        ; Bereich lîschen
                dbra    D3,Hlp2         ;

                dbra    D2,Hlp1         ;

                move.l  A0,D0           ; Unteren Bildrand lîschen
                bclr    #0,D0           ; Zeiger auf gerade Addresse
                movea.l D0,A0           ; bringen
                move.l  MemEnd(PC),D1   ; Anzahl der zulîschenden Blîcke
                sub.l   D0,D1           ; Speicherende minus ZeigerAddr
                asr.l   #4,D1           ; durch 16 (BlocklÑnge)
                subq.l  #1,D1           ; minus 1 (wegen dbf)

Hlp3:           move.l  D4,(A0)+        ; auf Schwarz lîschen
                move.l  D4,(A0)+        ;
                move.l  D4,(A0)+        ;
                move.l  D4,(A0)+        ;
                dbra    D1,Hlp3         ;

DontClrBorder:  movem.l (SP)+,D3-D5     ; restore the regs
                rts



;#############################################################
; Gesamten Bildspeicher lîschen (auf schwarz)
; Lîschfarbe bestimmen

CallClearFull:  pea     ClearFullScreen(PC)
                move.w  #Supexec,-(SP)  ; call in supervisor mode
                trap    #xbios
                addq.l  #6,SP
                rts


ClearFullScreen:bsr.s   BlackColor      ; get clear value in D0
                move.l  #($8000+add_len)/16-1,D1 ; Length of the new screen
                movea.l MyMemtop(PC),A0 ; Clear from MEMTOP

sc_clp:         move.l  D0,(A0)+        ;
                move.l  D0,(A0)+        ;
                move.l  D0,(A0)+        ;
                move.l  D0,(A0)+        ;
                dbra    D1,sc_clp       ; clear the next 16 Bytes
                bra     ResetCursor


BlackColor:     moveq   #-1,D0          ; erstmal FÅllwert $FFFFFFFF
                move.w  Reso(PC),D1     ; Bildschirmmodus ...
                subq.w  #2,D1           ; ... Monochrom ?
                bne.s   NotWhite        ; nein, weiter
                btst    #0,$FFFF8241.w  ; Inverse Monochrome ?
                bne.s   NotWhite        ; nein, Farbe richtig
                not.l   D0              ; sonst FÅllwert $0
NotWhite:       rts



set_color:      movea.l LineA(PC),A0    ; Set draw color
                move.w  D0,col_bit0(A0) ;
                move.w  D0,col_bit1(A0) ;
                move.w  D0,col_bit2(A0) ;
                move.w  D0,col_bit3(A0) ;
                rts


;#############################################################
;# OVERSCAN - User Installation
;#############################################################
CallClearPal:   clr.w   Pal3Save        ; Clear Color reg. 3 and 15
                clr.w   PalFSave

CallRestorePal: move.w  Pal3Save(PC),-(SP)
                move.l  #SetColor<<16+3,-(SP) ; push color 3 and 'SetColor'
                trap    #xbios
                move.w  D0,Pal3Save

                move.w  PalFSave(PC),-(SP)
                move.l  #SetColor<<16+15,-(SP) ; push color 15 and 'SetColor'
                trap    #xbios
                move.w  D0,PalFSave
                lea     12(SP),SP
                rts


UserInstall:    bsr     CallClearFull   ; Clear screen (black)
                bsr.s   CallClearPal    ; Clear color register 3
                move.w  Reso(PC),ResoSave ; Save initial Resolution
                bsr     InitReso
                clr.w   UserSave
                bsr     Do_Help         ; Help Text
                bsr     CallClearFull   ; clear screen again.

UserLoop:       moveq   #0,D0           ; LOOP
                bsr     DrawSetup       ;
                bsr     WriteSetup      ;     Draw cross and values
                bsr.s   ChangeSetup     ;     execute keyboard command
                tst.w   UserSave        ;
                beq.s   UserLoop        ; Until EndFlag is set.

                pea     msg_eraseinvoff(PC)
                move.w  #Cconws,-(SP)   ;
                trap    #gemdos         ;
                addq.l  #6,SP           ;

UserContinue:   move.w  Reso(PC),D0
                cmp.w   ResoSave(PC),D0
                beq.s   CallRestorePal
                rts



ChangeSetup:    move.w  #Cnecin,-(SP)   ; Get Key...
                trap    #gemdos
                addq.l  #2,SP
                move.l  D0,-(SP)
                moveq   #1,D0           ;
                bsr     DrawSetup       ;     Clear cross

                move.l  (SP)+,D0
                cmpi.w  #'s',D0         ; S
                beq     Do_Save

                moveq   #2,D1           ; high rez
                cmpi.w  #'h',D0         ; H change to high rez.
                beq     SetScreenReso

                moveq   #1,D1           ; med. rez
                cmpi.w  #'m',D0         ; M change to med. rez.
                beq     SetScreenReso

                moveq   #0,D1           ; low rez
                cmpi.w  #'l',D0         ; L change to low rez.
                beq     SetScreenReso

NoL:            cmpi.w  #'f',D0         ; f change 50/60Hz
                beq     changefreq

NoF:            move.w  #1,UserSave
                cmpi.w  #'q',D0         ; Q
                beq     CallClearFull

                pea     CallClearFull(PC) ; Force call of this after branch
                pea     CallSetOverscan(PC) ; Force call of SetOverscan...
                swap    D0              ; Test on ScanCode for fixed keys!
                cmpi.w  #97,D0          ; UNDO
                beq     Do_Disable
                clr.w   UserSave

                cmp.w   #99,D0          ; (
                beq     Do_lessbpl
                cmp.w   #100,D0         ; )
                beq     Do_morebpl

                cmpi.w  #101,D0         ; /
                beq     Do_Div
                cmpi.w  #102,D0         ; *
                beq     Do_Mul
                cmpi.w  #74,D0          ; -
                beq     Do_Sub
                cmpi.w  #78,D0          ; +
                beq     Do_Add
                addq.w  #4,SP           ; Forced call to ClearFullScreen

                cmpi.w  #98,D0          ; Help --->
                beq     Do_Help
                swap    D0              ; test p and c on ascii code
                cmpi.w  #'c',D0         ; C
                beq     Do_Activ
                addq.w  #4,SP           ; remove forced rutine and return

                pea     CallSetOverscan(PC) ; Force call of SetOverscan...
                swap    D0              ; Cursor Keys only have Scancode
                cmpi.w  #75,D0          ; Arrow left
                beq     Do_Left
                cmpi.w  #77,D0          ; Arrow right
                beq     Do_Right
                cmpi.w  #72,D0          ; Arrow up
                beq     Do_Up
                cmpi.w  #80,D0          ; Arrow down
                beq     Do_Down
                addq.w  #4,SP
                rts

changefreq:     not.w   Palmode
                bsr.s   SetFreq
                bra     new_parameters

SetFreq:        pea     supsetfreq(PC)
                move.w  #Supexec,-(SP)
                trap    #xbios
                addq.w  #6,SP
                rts

supsetfreq:     move.w  Palmode(PC),palmode.w
                bne.s   setflag
                move.b  #252,$FFFF820A.w
                rts
setflag:        move.b  #254,$FFFF820A.w
                rts

Do_lessbpl:     moveq   #-2,D0
                bra.s   fun
Do_morebpl:     moveq   #2,D0
fun:            move.w  Reso(PC),D1
                add.w   D1,D1
                lea     12+screen60(PC),A0
                add.w   D0,0(A0,D1.w)
                rts



Do_Disable:     pea     msg_disable(PC)
                move.w  #Cconws,-(SP)
                trap    #gemdos
                addq.w  #6,SP
                lea     NormalVideo(PC),A0
                tst.w   (A0)
                bne.s   NotOverscan
dis_lop:        bsr     TestSwitch
                bne.s   dis_lop
                st      (A0)
                rts
NotOverscan:    bsr     TestSwitch
                beq.s   NotOverscan
                clr.w   (A0)
                rts


Do_Save:        move.l  D3,-(SP)

                bsr     CallClearFull   ; Schirm lîschen
                move.w  #2,UserSave     ; Nicht gefunden Flag setzen

                clr.w   -(SP)           ; Fcreate('x:\OVERSCAN.INF',0)
                pea     save_name(PC)   ;
                move.w  #Fcreate,-(SP)
                trap    #gemdos         ;
                addq.l  #8,SP           ;

                move.w  D0,D3           ; error? &save file handle
                bmi.s   EndSave         ; no -> End

                addq.w  #1,UserSave     ; (3)Flag setzen...

                pea     ScreenTab(PC)   ; Save ScreenTab
                moveq   #ScreenTabEnd-ScreenTab,D0
                move.l  D0,-(SP)        ;
                move.w  D3,-(SP)        ;
                move.w  #Fwrite,-(SP)   ; Fwrite(Handle,configSize,ScreenTab)
                trap    #gemdos         ;

                move.w  #Fclose,(SP)    ; Fclose(Handle)
                trap    #gemdos         ;
                lea     12(SP),SP       ;

EndSave:        move.l  (SP)+,D3
                rts


Do_Help:        pea     msg_help(PC)    ; Write HelpText
                move.w  #Cconws,-(SP)
                trap    #gemdos
                move.w  #Cnecin,(SP)
                trap    #gemdos
                addq.l  #6,SP           ; Wait until a Key have been pressed
End_LR:         rts


Do_Left:        cmpi.w  #320,RezX       ; decrease width
                blt.s   End_LR
                movea.l X_Add(PC),A0
                subi.w  #16,(A0)
                rts
Do_Right:       move.w  X_Max(PC),D0    ; increase width
                cmp.w   RezX(PC),D0
                ble.s   End_LR
                movea.l X_Add(PC),A0
                addi.w  #16,(A0)
                rts
Do_Up:          move.w  Y_Min(PC),D0    ; Hîhe vermindern
                cmp.w   RezY(PC),D0
                bge.s   End_LR
                movea.l Y_Add(PC),A0
                move.w  Y_Inc(PC),D0
                sub.w   D0,(A0)
                rts
Do_Down:        move.w  Y_Max(PC),D0    ; Hîhe erhîhen
                cmp.w   RezY(PC),D0
                ble.s   End_LR
                movea.l Y_Add(PC),A0
                move.w  Y_Inc(PC),D0
                add.w   D0,(A0)
                rts
Do_Div:         movea.l Off_Add(PC),A0  ; Offset vermindern
                subq.l  #2,(A0)
                rts
Do_Mul:         movea.l Off_Add(PC),A0  ; Offset erhîhen
                addq.l  #2,(A0)
                rts
Do_Sub:         movea.l Off_Add(PC),A0  ; Offset erhîhen
                moveq   #0,D0
                move.w  BpL(PC),D0      ; Linke obere Ecke nach oben
                sub.l   D0,(A0)
                rts
Do_Add:         movea.l Off_Add(PC),A0  ; Offset erhîhen
                moveq   #0,D0
                move.w  BpL(PC),D0      ; Linke obere Ecke nach unten
                add.l   D0,(A0)
                rts



Do_Activ:       pea     msg_shift_on(PC)
                moveq   #9,D0
                cmp.b   ActivateKey(PC),D0 ; Write the previous state...
                beq.s   Write_Shift
                move.l  #msg_shift_off,(SP)
Write_Shift:    move.w  #Cconws,-(SP)
                trap    #gemdos
                move.w  #Cnecin,(SP)
                trap    #gemdos
                addq.l  #6,SP
                cmpi.b  #'n',D0         ; Nur bei 'N'
                bne.s   EndShift
                bchg    #0,ActivateKey  ; Zustand Ñndern
EndShift:       rts


; new rez in D1!!
SetScreenReso:  move.w  D1,-(SP)        ; Neue Auflîsung mit Setscreen
                moveq   #-1,D0
                move.l  D0,-(SP)        ; setzen
                move.l  D0,-(SP)        ;
                move.w  #Setscreen,-(SP) ;
                trap    #xbios          ;
                lea     12(SP),SP

new_parameters: bsr     CallSetOverscan ; Overscan neu installieren
                bsr     CallClearFull   ;

; Flow through to InitResolution...


InitReso:       lea     ScreenTab(PC),A0 ; Get Screen table pointer
                move.w  #8,Y_Inc-ScreenTab(A0)
                move.w  #160,Y_Min-ScreenTab(A0) ;

                move.w  Reso(PC),D0     ; Current resolution
                cmpi.w  #2,D0           ;
                bne.s   NoHighReso      ;
                move.w  #16,Y_Inc-ScreenTab(A0) ; Find Y-Increment
                move.w  #320,Y_Min-ScreenTab(A0) ;  min screen height = 320

NoHighReso:     moveq   #2,D2           ; Find Max X/Y
                lsl.w   D0,D2           ; 2 << Reso
                mulu    BpL(PC),D2      ;
                move.w  D2,X_Max        ; MaxX = Bpl * 2<<Reso

                move.l  MemEnd(PC),D1   ;
                sub.l   MyMemtop(PC),D1 ;
                divu    BpL(PC),D1      ; MaxY = SpeicherlÑnge/BytePerLine
                move.w  D1,Y_Max-ScreenTab(A0) ;

                tst.w   Palmode
                bne.s   SOver2
                lea     screen60(PC),A0

SOver2:         add.w   D0,D0           ; Words
                lea     0(A0,D0.w),A1
                move.l  A1,X_Add
                lea     6(A0,D0.w),A1
                move.l  A1,Y_Add
                add.w   D0,D0           ; Longs
                lea     30(A0,D0.w),A1
                move.l  A1,Off_Add
                rts



DrawSetup:      move.l  D3,-(SP)
                bsr     set_color       ;  Box mit Diagonalen zeichnen
                moveq   #0,D0
                moveq   #0,D1
                move.w  RezX(PC),D2
                subq.w  #1,D2
                move.w  RezY(PC),D3
                subq.w  #1,D3
                bsr.s   draw_box
                move.l  (SP)+,D3
                rts

draw_box:       movea.l LineA(PC),A0    ; Ein Rechteck aus Linien zeichnen
                clr.w   wmode(A0)       ; d0/d1 linke  obere  Ecke
                move.w  #$FFFF,lnmask(A0) ; d2/d3 rechte untere Ecke
                move.w  #1,lstlin(A0)

                move.w  D0,x1(A0)
                move.w  D1,y1(A0)
                move.w  D2,x2(A0)
                move.w  D1,y2(A0)
                bsr.s   draw_line       ; Oben

                move.w  D2,x1(A0)
                move.w  D1,y1(A0)
                move.w  D2,x2(A0)
                move.w  D3,y2(A0)
                bsr.s   draw_line       ; Rechts

                move.w  D2,x1(A0)
                move.w  D3,y1(A0)
                move.w  D0,x2(A0)
                move.w  D3,y2(A0)
                bsr.s   draw_line       ; Unten

                move.w  D0,x1(A0)
                move.w  D1,y1(A0)
                move.w  D0,x2(A0)
                move.w  D3,y2(A0)
                bsr.s   draw_line       ; Links

                move.w  D0,x1(A0)       ; Draw DIAGONAL line
                move.w  D1,y1(A0)       ; Parameter wie oben
                move.w  D2,x2(A0)       ;
                move.w  D3,y2(A0)
                bsr.s   draw_line       ; Diagonale links

                move.w  D2,x1(A0)
                move.w  D1,y1(A0)
                move.w  D0,x2(A0)
                move.w  D3,y2(A0)       ; Diagonale rechts

draw_line:      movem.l D0-D3/A0,-(SP)  ; Einzelne Linie Ziehen
                linea   #$03 [ Line ]
                movem.l (SP)+,D0-D3/A0
                rts



WriteSetup:     lea     user_x(PC),A1   ; Write Numbers
                move.w  RezX(PC),D0
                bsr.s   WriteDec

                lea     user_y(PC),A1
                move.w  RezY(PC),D0
                bsr.s   WriteDec

                lea     user_off(PC),A1
                move.w  Offset(PC),D0

; flow through to WriteHex


WriteHex:       lea     user_number(PC),A0 ; Write numbers in Hexadecimal
                move.l  #'0000',(A0)+   ; Clear old string
WriteHlp:       move.b  D0,D1
                andi.w  #$0F,D1
                cmpi.w  #9,D1
                ble.s   NotAtoF
                add.w   #'A'-'0'-10,D1
NotAtoF:        add.b   D1,-(A0)
                lsr.w   #4,D0
                bne.s   WriteHlp
                pea     (A0)            ; Push number on stack
                pea     (A1)            ; Write Text
                move.w  #Cconws,-(SP)
                trap    #gemdos
                addq.l  #6,SP
                move.w  #Cconws,-(SP)
                trap    #gemdos
                addq.l  #6,SP
                rts


WriteDec:       lea     user_number(PC),A0 ; Write numbers in decimal
                move.l  #'0000',(A0)+   ; Clear old string
                ext.l   D0
WriteLp:        divu    #10,D0
                swap    D0
                add.b   D0,-(A0)
                clr.w   D0              ; Clear Rest
                swap    D0              ; d0.l == 0?
                bne.s   WriteLp         ; no --> more to convert
                pea     (A0)            ; Push address of number
                pea     (A1)            ; Write Text
                move.w  #Cconws,-(SP)
                trap    #gemdos
                addq.l  #6,SP
                move.w  #Cconws,-(SP)   ; write number (only decs)
                trap    #gemdos
                addq.l  #6,SP
                rts


;---------------------------------------------
; Is OVERSCAN activ ? (the switch)
; Es wird gewartet, bis der VideoadresszÑhler bis zum Ende
; der normalen Bildschirmseite hochgezÑhlt hat.
; Dann wird getestet, ob er auf den Anfang zurÅckspringt.
; Tut er das nicht, ist OVERSCAN aktiv.
TestSwitch:     clr.w   D0
                move.b  vid_basmid.w,D0
                move.w  D0,D1
                addi.w  #$7D,D1
Wait1:          cmp.b   vid_ismid.w,D1
                bne.s   Wait1
Wait2:          cmp.b   vid_ismid.w,D1
                beq.s   Wait2
                cmp.b   vid_ismid.w,D0
                rts                     ; if EQ then is Switch not activ

                EVEN

user_number:    DC.B '     ',0
msg_eraseinvoff:DC.B 27,'q'
msg_erase:      DC.B 27,'E',0
user_x:         DC.B 27,'Y',33,40,'X: ',0
user_y:         DC.B 'Y: ',0
user_off:       DC.B 'Off:',0

msg_help:       DC.B 27,'H',27,'pHELP:',13,10
                DC.B 'Cursor : Width & Heigth',13,10
                DC.B '  / *  : Edge left/right',13,10
                DC.B '  - +  : Edge up/down',13,10
                DC.B '  ( )  : Bytes per line up/down',13,10
                DC.B '   C   : Clear screen key',13,10
                DC.B '   F   : Frequency 60/50Hz',13,10
                DC.B ' L M H : Low-Middle-High Res.',13,10
                DC.B ' Undo  : Disable Overscan',13,10
                DC.B '  S Q  : Save or Quit',13,10
                DC.B ' Help  : This page',13,10,0

msg_disable:    DC.B 10,10,13,10,'Flip the Overscan Switch!',0
msg_shift_on:   DC.B 10,10,13,10,'Clear-screen with RIGHT-SHIFT/ALT/HELP (y/n)',0
msg_shift_off:  DC.B 10,10,13,10,'Clear-screen with ALT/HELP  (y/n)',0

save_name:      DC.B 'A:\OVERSCAN.INF',0


                EVEN
Offset:         DS.W 1                  ; Offset VideoAdd <> MyMemtop
RezX:           DS.W 1                  ; Breite des Bildschirms
RezY:           DS.W 1                  ; Hîhe   des Bildschirms
BpL:            DS.W 1                  ; BytesPerLine , also Bytes pro Bildschirmzeile
Reso:           DS.W 1                  ; Aktuelle Auflîsung
LineA:          DS.L 1                  ; Zeiger auf LineA Variablen
WorkOut:        DS.L 1                  ; Zeiger auf das WorkOut-Feld der 'v_opnwk()'-
WorkOutValid:   DS.W 1                  ; this word vaidates the workout array
Back:           DS.L 1                  ; RÅcksprungAddresse zu dieser Funktion

MyMemtop:       DS.L 1                  ; Zwischenspeicher zur Restauration des Desktops nach
BasAdd:         DS.L 1
MemEnd:         DS.L 1                  ; Letzte beschreibbare Speicheraddresse

X_Add:          DS.L 1                  ; Zeiger auf die aktuellen Bildschirmwerte
Y_Add:          DS.L 1                  ;
Off_Add:        DS.L 1                  ;
Y_Inc:          DS.W 1                  ; Inkrement der Bildschirmwerte
X_Max:          DS.W 1                  ;
Y_Min:          DS.W 1                  ;
Y_Max:          DS.W 1                  ;

Pal3Save:       DS.W 1                  ; Farbpalette 3
PalFSave:       DS.W 1                  ; Farbpalette 15
ResoSave:       DS.W 1                  ; Start-Auflîsung
UserSave:       DS.W 1                  ; EndeFlag fÅr UserSetup

inst_ok:        DS.W 1                  ; Installation status

NormalVideo:    DS.W 1                  ; Switch - false if Overscan is active
p_kbshift:      DS.L 1                  ; pointer to keyboard shifts

nonresident:    DS.B 0                  ; The last byte of the program..


;##############################################################
;# The main program (this part of the program is not resident!)
;##############################################################

                EVEN


main:           movea.l 4(SP),A5        ; Get Base page pointer
                lea     $0100(A5),SP    ; make stack in basepage!

                move.l  4(A5),D0        ; calculate size of tpa-'add_len'
                sub.l   A5,D0
                sub.l   #add_len,D0

                move.l  D0,-(SP)        ; release 'add_len' in top of tpa
                pea     (A5)            ; --> hopefully below the new screen!
                move.l  #Mshrink<<16,-(SP) ; put $00 and #Mshrink on stack.
                trap    #gemdos
                lea     12(SP),SP

                move.w  #Dgetdrv,-(SP)  ; get default drive
                trap    #gemdos
                addq.l  #2,SP

                lea     save_name(PC),A0 ; fix the path
                add.b   D0,(A0)

                bsr     Do_loadsetup    ; overwrite setup if there is a inf file

                pea     do_setup(PC)    ; Test and Installation in
                move.w  #Supexec,-(SP)  ; Supervisormode.
                trap    #xbios          ; result in inst_ok
                addq.l  #6,SP

                pea     msg_title(PC)   ; print Overscan Header
                move.w  #Cconws,-(SP)
                trap    #gemdos
                addq.l  #6,SP

                move.w  inst_ok(PC),D0  ; Was the installation error free?
                bne.s   not_ok          ; No, exit.

                clr.w   NormalVideo     ; Overscan is now active.
                clr.w   WorkOutValid    ; anti-validate workout array

                movea.l p_kbshift(PC),A0
                tst.b   (A0)
                beq.s   DoTitle         ; some 'shift' key was pressed

                bsr     UserInstall     ; now let the user adjust overscan.

DoTitle:        pea     msg_title(PC)   ; print Overscan Header
                move.w  #Cconws,-(SP)
                trap    #gemdos

                pea     msg_installed(PC)
                move.w  #Cconws,-(SP)
                trap    #gemdos
                lea     12(SP),SP

                clr.w   -(SP)           ; Resident terminate
                lea     nonresident(PC),A0 ;   End of Program
                suba.l  A5,A0           ; - start of program
                move.l  A0,-(SP)        ; = Program length
                move.w  #Ptermres,-(SP)
                trap    #gemdos


not_ok:         pea     msg_notactive(PC) ; 'Not installed' message
                move.w  #Cconws,-(SP)
                trap    #gemdos
                addq.w  #6,SP

                move.w  inst_ok(PC),D0
                subq.w  #1,D0           ; (1)was overscan not active (switch)?
                beq.s   Goodbye

                lea     msg_noTos(PC),A0 ; (2)'unsupported TOS' message
                subq.w  #1,D0
                beq.s   printAndWait

                lea     msg_already(PC),A0 ; (3)'allready installed.' message
                subq.w  #1,D0
                beq.s   printAndWait

                lea     msg_nomem(PC),A0
printAndWait:   move.l  A0,-(SP)
                move.w  #Cconws,-(SP)   ; print...
                trap    #gemdos
                move.w  #Cnecin,(SP)    ; wait for keypress
                trap    #gemdos
Goodbye:        clr.w   (SP)            ; terminate program (Returncode 0)
                trap    #gemdos

* load the overscan info file... *
Do_loadsetup:   clr.w   -(SP)           ; Fopen('x:\OVERSCAN.INF',0)
                pea     save_name(PC)   ;
                move.w  #Fopen,-(SP)
                trap    #gemdos         ;
                addq.l  #8,SP           ;

                tst.w   D0              ; error?
                bmi.s   EndLoad         ; no -> End

                pea     ScreenTab(PC)   ; Save ScreenTab
                moveq   #ScreenTabEnd-ScreenTab,D1
                move.l  D1,-(SP)        ;
                move.w  D0,-(SP)        ;
                move.w  #Fread,-(SP)    ; Fread(Handle,configSize,ScreenTab)
                trap    #gemdos         ;

                move.w  #Fclose,(SP)    ; Fclose(Handle)
                trap    #gemdos         ;
                lea     12(SP),SP       ;

EndLoad:        rts

;###########################################################
;# The Installation Routine
;###########################################################
;uses A0,A1,A2,D0,D1,D2 (without subroutines, with gemdos)
do_setup:       movem.l D0-D2/A0-A2,-(SP)

; patch the interupt handlers
                tst.w   longframe.w
                beq.s   no_patch
                addq.w  #2,sm_longframe1+2
                addq.w  #2,sm_longframe2+2

no_patch:       move.w  #3,inst_ok      ; Status : allready installed

                movea.l dostrap.w,A0    ; search GemDos-Trap after OVERSCAN
tstXBRA:        cmpi.l  #'XBRA',-12(A0) ; XBRA ?
                bne.s   noXBRA          ; no -> End of vector chain
                cmpi.l  #'OVER',-8(A0)  ; OVER[scan] ?
                beq     EndSetup        ; yes   -> allready installed!
                movea.l -4(A0),A0       ;
                bra.s   tstXBRA         ; get next routine in chain..

noXBRA:         move.w  #2,inst_ok      ; Status : wrong TOS

                movea.l sysbase.w,A1    ; Is it > TOS 1.4 ?
                cmpi.w  #$0104,2(A1)
                bmi     EndSetup        ; NO -> End

                movea.l $24(A1),A0      ; get pointer to keyboard shift var
                move.l  A0,p_kbshift

                move.w  #1,inst_ok      ; Status : Not in OVERSCAN-mode

                bsr     TestSwitch
                beq     EndSetup

                move.w  #4,inst_ok      ; Status : NO MEMORY

                move.l  memtop.w,MemEnd ; Remember 'memtop'

                move.l  #add_len,-(SP)  ; allocate just released memory
                move.w  #Malloc,-(SP)
                trap    #gemdos
                addq.w  #6,SP

                move.l  D0,MyMemtop
                ble.s   EndSetup        ; if not enough memory end...

                add.l   #add_len,D0     ; Check if it is in the top of memory
                cmp.l   MemEnd(PC),D0   ; (just below the real screen)
                bne.s   EndSetup        ; No not in the top --> End

                addi.l  #$8000,MemEnd   ; Calculate last address in RAM

                clr.w   inst_ok         ; Status : OVERSCAN aktiv

                move.l  MyMemtop(PC),memtop.w
                linea   #$00 [ Init ]   ; LineA init
                move.l  D0,LineA        ; pointer to LineA Variables

                bsr     SetOverscan     ; Set Overscan regs.
                bsr     ClearScreen     ; Clear screen border


; The values written by Overscan, will be overwritten when
; the AES is initiated. We will therefor have to write the
; values shortly after v_opnwk !
;
;--------> Therefor link into GEM-trap (AES/VDI)
                move.l  gemtrap.w,OldVec
                move.l  #MyGem,gemtrap.w ; insert new Vector

;--------> Gemdos
                lea     MyDos-4(PC),A0
                move.l  dostrap.w,(A0)+
                move.l  A0,dostrap.w

;--------> Xbios
                lea     MyXbios-4(PC),A0
                move.l  xbiostrap.w,(A0)+
                move.l  A0,xbiostrap.w

;--------> Hardcopy-Routine
                lea     MyHard-4(PC),A0
                move.l  hardcopy.w,(A0)+
                move.l  A0,hardcopy.w

EndSetup:       movem.l (SP)+,D0-D2/A0-A2
                rts

                EVEN

msg_title:      DC.B 27,'E',27,'pOverscan v1.62',27,'q',13,10
                DC.B ' Orig. by K.Isakovic and B.Gebauer',13,10
                DC.B ' Fixed by Klaus Pedersen (micro@imada.ou.dk)',13,10,0

msg_installed:  DC.B 'Now Installed. ',13,10
                DC.B '- Hold Shift-Key for Setup!',13,10,0

msg_notactive:  DC.B 'NOT Installed.',13,10,0

msg_noTos:      DC.B '- Only with TOS 1.4 or later!',13,10,0

msg_nomem:      DC.B '- Could not allocate memory...',13,10,0

msg_already:    DC.B '- Already installed...',13,10,0


                END
