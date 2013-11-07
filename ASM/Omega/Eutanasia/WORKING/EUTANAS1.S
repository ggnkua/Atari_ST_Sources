                >PART 'Variabler'
GAMESTART:
                path 'D:\LIESEN\EUTANASI\DATA\IBYTES'
CURSOR          equ 1           ; 0=Pl1 usese Joy... 1=Uses Cursor
SPACEQUIT       equ 1           ; 0=No  ; 1=Yes
TRUEVERSION     equ 0           ; 0=No  ; 1=Yes
RAMDISK         equ 1           ; 0=No  ; 1=Yes

SCREEN_DUMP     equ 1           ; 0=No  ; 1=Yes

X               equ 1
REM             equ 0
ES              equ 64          ; Highest Amount Of enemy Shoots Possible
SPRITETAB_SIZE  equ 160
PLAYMUSIC       equ 0           ; 0=No Music  1=Yes, Music
CLIP_Y          equ 167
FAST_B          equ 4
DX_EXPLO        equ -16
DY_EXPLO        equ -12

SCREEN_WIDTH    equ 160
MAX_MEMFRG      equ 48

                output 'D:\LIESEN\EUTANASI\EUTANAS.PRG'

                endpart
                >PART 'BUG REPORT'
* Vid LABEL NORMAL buggar den ut (n„r kartan wrapar?)                     920501
*   la in en BRA NEXTBLOCK innan ILLEGAL
*   och vid NORMAL_CUT (eller CUT_NORMAL ??)

* Ta bort alla *160

* Carsh vid Sl„ndor.. kanske n†tt med EXT_EXPLO?

* JoyStick Fire funkar inte utan att sk„rmen rensas med SETSCREEN
* utan fire skickas d† via musen.
*
* Energi m„tarna fick fick felplacerade linjer vid omstart (d”d, starta igen)
* Flyttade BSR INIT2 (laddar) till under BSR INITLINE (ber„knar m„tarna) och
* d† funkar det.... Slutsats, INIT2 g”r n†t okontrollerat under sitt minne.
                endpart
                >PART 'HiREZ'
                if REM=1
                move.w  #2,-(a7)
                pea     -1
                pea     -1
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7
                rts
                endc
                endpart
                >PART 'Stand Alone Init'
                if TRUEVERSION=0

                lea     SAVETAB(pc),a6  ; Save all data
                move.l  a7,(a6)+

                lea     STACK,a7
                pea     0
                move.w  #$0020,-(a7)
                trap    #1
                addq.l  #6,a7
                lea     STACK,a7

                move.l  $00000070.w,(a6)+
                move.l  $00000120.w,(a6)+
                move.b  $FFFFFA07.w,(a6)+
                move.b  $FFFFFA09.w,(a6)+
                move.b  $FFFFFA0F.w,(a6)+
                move.b  $FFFFFA11.w,(a6)+
                move.b  $FFFFFA13.w,(a6)+
                move.b  $FFFFFA15.w,(a6)+
                move.l  $00000068.w,(a6)+
                move.l  $00000070.w,(a6)+
                move.l  $00000118.w,(a6)+
                move.l  $00000120.w,(a6)+
                move.w  #4,-(a7)
                trap    #14
                move.w  d0,(a6)+
                move.w  #2,-(a7)
                trap    #14
                move.l  d0,(a6)+
                movem.l $FFFF8240.w,d0-d7
                movem.l d0-d7,(a6)
                lea     32(a6),a6

                clr.w   -(a7)
                pea     -1
                pea     -1
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7



                endc
                endpart
                lea     STACK,a7
                lea     MESSAGE,a0
                bra     BEGIN

****************************************


INIT2:          >PART 'INIT2'

******* Load Background

                lea     BACKGR_FILE(pc),a0
                bsr     LOAD_FILE
                movea.l a0,a1

                move.l  #9600*2,d0
                bsr     GET_FRG_MEM

                move.l  a0,BACKGROUNDADDR
                move.l  a0,SCROLLADDR

                move.w  #2399,d0
COPYBCG:        move.l  (a1),9600(a0)
                move.l  (a1)+,(a0)+
                dbra    d0,COPYBCG


******** Explotion
                lea     EXPLO_FILE(pc),a0
                bsr     LOAD_FILE
                moveq   #0,d0
                moveq   #1,d1
                moveq   #2,d2
                moveq   #4,d3
                bsr     ROTATE_FILE

                lea     OBJECTTAB(pc),a5

                movem.l d0/a0,-(a7)
                moveq   #54,d0
                bsr     GET_FRG_MEM
                move.l  a0,(a5)
                movea.l a0,a6
                movem.l (a7)+,d0/a0

                move.l  a1,(a6)
                adda.w  d4,a1
                move.l  a1,4(a6)
                move.w  d6,8(a6)
                move.w  #1,10(a6)
                move.w  d4,12(a6)
                subq.w  #1,d5
                move.w  d5,14(a6)
                move.w  #0,18(a6)
                move.w  d0,20(a6)
                clr.l   22(a6)
                clr.l   26(a6)
                clr.l   32(a6)
                bsr     FIND_ROUT
                move.w  d0,16(a6)
                move.w  d2,d0
                bsr     FIND_LSR
                move.w  d0,30(a6)


**************************
                cmpi.w  #2,PLAYERS
                beq.s   TWOPLAYERGAME

                lea     PL_DATA1(pc),a2
                lea     PLAY11_FILE(pc),a0
                lea     WEAPON_PL11(pc),a1
                bsr     LOAD_PLAYER
                bra.s   SKIT_I_DOM

TWOPLAYERGAME:  lea     PL_DATA1(pc),a2
                tst.w   76(a2)
                beq.s   NOT_THAT_PL1
                lea     PLAY21_FILE(pc),a0
                lea     WEAPON_PL1(pc),a1
                bsr     LOAD_PLAYER

NOT_THAT_PL1:   lea     PL_DATA2(pc),a2
                tst.w   76(a2)
                beq.s   NOT_THAT_PL2
                lea     PLAY22_FILE(pc),a0
                lea     WEAPON_PL2(pc),a1
                bsr     LOAD_PLAYER
NOT_THAT_PL2:

SKIT_I_DOM:
                lea     OBJECTTAB+4(pc),a4
                lea     IMAGEMAKE(pc),a5
                lea     OBJECTMAKE(pc),a6
                bsr     MAKEENEMIES

******** Load Instru

                lea     INSTRU_FILE(pc),a0
                bsr     LOAD_FILE
                movea.l SCREEN1(pc),a1
                lea     $69A0(a1),a1
                movea.l SCREEN2(pc),a2
                lea     $69A0(a2),a2
                move.w  #1199,d0
DRAW_INST:      move.l  (a0),(a1)+
                move.l  (a0)+,(a2)+
                dbra    d0,DRAW_INST
                move.w  #(160/4)-1,d0
RENS:           clr.l   (a1)+
                clr.l   (a2)+
                dbra    d0,RENS

                lea     INIT2(pc),a0    ; //Mem//
                move.l  #End_Init2-INIT2,d0
                bsr     FREE_FRG_MEM

                rts
BACKGR_FILE:
                dc.b "SPRIKOR.BCG",0

MAP_FILE:       dc.b "PREVIEW1.MED",0
INSTRU_FILE:    dc.b "INSTRUME.IMG",0
PLAY11_FILE:    dc.b "1lazer.PLA",0
PLAY21_FILE:    dc.b "2_bouble.PLA",0
PLAY22_FILE:    dc.b "2_three.PLA",0

EXPLO_FILE:     dc.b "DISEL32.EXP",0
                even
End_Init2:
                endpart
Trans_Map:      >PART 'Translate MAP'
* A6=MapCreateTab
                movem.l d0-a5,-(a7)
*** Mark all used blocks

                lea     DUMMYAREA,a0
                movea.l a0,a1
                move.w  #(256*6)/4-1,d0 ; Clear Work
.RENS1:         clr.l   (a1)+
                dbra    d0,.RENS1
                move.w  (a6),d0
                lea     0(a6,d0.w),a1
                move.w  -2(a1),4(a6)    ; Copy Map LINES
                subi.w  #1,4(a6)        ; Minus 1
                move.w  4(a6),d7
.LOOPY:         moveq   #19,d6
.LOOPX:         moveq   #0,d0
                move.b  (a1)+,d0
                lsl.w   #8,d0
                moveq   #0,d1
                move.b  (a1)+,d1
                add.w   d0,d1
                move.b  #-1,0(a0,d1.w)
                dbra    d6,.LOOPX
                dbra    d7,.LOOPY


                move.w  2(a6),d0
                lea     0(a6,d0.w),a1

TAKENEXT:       cmpi.w  #-1,(a1)
                beq.s   TABSLUT

EFFECTLOOP:     moveq   #0,d0
                moveq   #0,d1
                move.b  (a1)+,d0
                move.b  (a1)+,d1
                cmp.b   #-1,d0
                beq.s   CHECKCOM
                lsl.w   #8,d0
                add.w   d0,d1
                move.b  #-1,0(a0,d1.w)
                bra.s   EFFECTLOOP

CHECKCOM:       move.w  (a1)+,d0
                addq.l  #4,a1           ; skip NEW TAB point
                tst.w   d0
                bne.s   .FUCKIT1

                move.w  8(a1),d0        ; Search "Destructable"
                move.w  10(a1),d1
                bmi.s   .X3
                lsl.w   #8,d0
                add.w   d0,d1
                move.b  #-1,0(a0,d1.w)
.X3:            lea     20(a1),a1
                bra.s   TAKENEXT

.FUCKIT1:       cmp.w   #1,d0           ; Search "Animated"
                bne.s   .FUCKIT2
.Z0:            moveq   #0,d0
                moveq   #0,d1
                move.b  (a1)+,d0
                move.b  (a1)+,d1
                tst.b   d0
                bmi.s   TAKENEXT
                lsl.w   #8,d0
                add.w   d0,d1
                move.b  #-1,0(a0,d1.w)
                bra.s   .Z0

.FUCKIT2:       addq.l  #8,a1           ; Search "CanShoot"
                bra.s   TAKENEXT



************************************************ Pass 2
*** Make conversion list

TABSLUT:        movea.l a0,a1
                lea     3*256(a1),a2
                moveq   #2,d2
.ALLTYPES:      moveq   #0,d7
                move.w  #255,d1
.FILTRERA:      move.b  #-1,(a2)+
                tst.b   (a1)+
                beq.s   .NOTUSED
                move.b  d7,-1(a2)
                addq.w  #1,d7
.NOTUSED:       dbra    d1,.FILTRERA
                dbra    d2,.ALLTYPES

************************************************ Pass 3
*** Change all block nummers in listings,map

                lea     DUMMYAREA,a0
                move.w  (a6),d0
                lea     0(a6,d0.w),a1
                lea     3*256(a0),a4

                move.w  4(a6),d7
                subq.w  #1,d7
.LOOPY2:        moveq   #19,d6
.LOOPX2:        moveq   #0,d0
                move.b  (a1)+,d0
                lsl.w   #8,d0
                moveq   #0,d1
                move.b  (a1),d1
                add.w   d0,d1
                move.b  0(a4,d1.w),(a1)+
                dbra    d6,.LOOPX2
                dbra    d7,.LOOPY2

                move.w  2(a6),d0
                lea     0(a6,d0.w),a1

TAKENEXT2:      cmpi.w  #-1,(a1)
                beq.s   TABSLUT2

EFFECTLOOP2:    moveq   #0,d0
                moveq   #0,d1
                move.b  (a1)+,d0
                move.b  (a1)+,d1
                cmp.b   #-1,d0
                beq.s   CHECKCOM2
                lsl.w   #8,d0
                add.w   d0,d1
                move.b  0(a4,d1.w),-1(a1)
                bra.s   EFFECTLOOP2

CHECKCOM2:      move.w  (a1)+,d0
                addq.l  #4,a1           ; skip NEW TAB point
                tst.w   d0
                bne.s   .FUCKIT3

                move.w  8(a1),d0        ; Search "Destructable"
                move.w  10(a1),d1
                bmi.s   .X6
                lsl.w   #8,d0
                add.w   d0,d1
                moveq   #0,d0
                move.b  0(a4,d1.w),d0
                move.w  d0,10(a1)
.X6:            lea     20(a1),a1
                bra.s   TAKENEXT2

.FUCKIT3:       cmp.w   #1,d0           ; Search "Animated"
                bne.s   .FUCKIT4
.Z3:            moveq   #0,d0
                moveq   #0,d1
                move.b  (a1)+,d0
                move.b  (a1)+,d1
                tst.b   d0
                bmi.s   TAKENEXT2
                lsl.w   #8,d0
                add.w   d0,d1
                moveq   #0,d0
                move.b  0(a4,d1.w),d0
                move.b  d0,-1(a1)
                bra.s   .Z3

.FUCKIT4:       addq.l  #8,a1           ; Search "CanShoot"
                bra.s   TAKENEXT2

TABSLUT2:
************************************************ Pass 4

** Load blocks and keep used

                lea     64(a6),a0       ; Fix FAST BLOCKS
                tst.b   (a0)
                beq.s   .NOBLOCKS1
                bsr     LOAD_FILE
                movem.l d0-a6,-(a7)     ; color fixer
                lea     COLFIX_DATA(pc),a2 ;
                bsr     COLORCHANGE     ;
                movem.l (a7)+,d0-a6     ;
                ext.l   d0
                divu    #4*8,d0
                subq.w  #1,d0
                bmi.s   .NOBLOCKS1
                movea.l MEM_END(pc),a2
                move.l  a2,6(a6)
                lea     DUMMYAREA,a4
                moveq   #7,d1
.GNU1:          clr.l   (a2)+           ; noblock
                dbra    d1,.GNU1

.SCANALL1:      tst.b   (a4)+
                beq.s   .NOTUSED1
                moveq   #3,d1
.GNU2:          move.l  (a0)+,(a2)+
                move.l  (a0)+,(a2)+
                dbra    d1,.GNU2
                bra.s   .JOINHIM1
.NOTUSED1:      lea     4*8(a0),a0
.JOINHIM1:      dbra    d0,.SCANALL1
.NOBLOCKS1:     move.l  a2,MEM_END

                lea     78(a6),a0       ; Fix NORMAL BLOCKS
                tst.b   (a0)
                beq.s   .NOBLOCKS2
                bsr     LOAD_FILE
                movem.l d0-a6,-(a7)     ; color fixer
                lea     COLFIX_DATA(pc),a2 ;
                bsr     COLORCHANGE     ;
                movem.l (a7)+,d0-a6     ;
                ext.l   d0
                divu    #16*8,d0
                subq.w  #1,d0
                bmi.s   .NOBLOCKS2
                movea.l MEM_END(pc),a2
                move.l  a2,10(a6)
                lea     DUMMYAREA+256,a4

.SCANALL2:      tst.b   (a4)+
                beq.s   .NOTUSED2
                moveq   #15,d1
.GNU3:          move.l  (a0)+,(a2)+
                move.l  (a0)+,(a2)+
                dbra    d1,.GNU3
                bra.s   .JOINHIM2
.NOTUSED2:      lea     16*8(a0),a0
.JOINHIM2:      dbra    d0,.SCANALL2
.NOBLOCKS2:     move.l  a2,MEM_END


****************** PASS 5, Creating tables

                moveq   #2,d7
                lea     _HoppTab_C_T(pc),a1 ; a1=HoppTaben
.ThreeTabLoop:  move.w  2(a6),d6
                lea     0(a6,d6.w),a2   ; a2=CreationDatan
                move.w  (a1)+,d6

                movea.l MEM_END(pc),a0  ; W A R N I N G  -  MEMORY OPEN!
                move.l  a0,0(a6,d6.w)   ; Save tab addr

.SlutYet:       cmpi.w  #-1,(a2)
                beq.s   .NoMoreDude1
.FindEndTrigg:  cmpi.w  #-1,(a2)+
                bne.s   .FindEndTrigg
                move.w  (a2)+,d0
                add.w   d0,d0
                add.w   d0,d0
                move.l  MEM_END(pc),d6
                sub.l   a0,d6           ; d6=Offset to tab
                movea.l 0(a1,d0.w),a3
                jsr     (a3)
                bra.s   .SlutYet

.NoMoreDude1:   lea     12(a1),a1
                move.l  a0,MEM_END
                dbra    d7,.ThreeTabLoop
                bra     PassSIX

_HoppTab_C_T:   dc.w 18
                dc.l Do_C_Dest_T,Skip_Anim_T,Skip_Shot_T
                dc.w 22
                dc.l Skip_Dest_T,Do_C_Anim_T,Skip_Shot_T
                dc.w 26
                dc.l Skip_Dest_T,Skip_Anim_T,Do_C_Shot_T

Do_C_Dest_T:    move.l  d6,(a2)+
                move.l  4(a2),(a0)+
                move.l  (a2),(a0)+
                move.l  8(a2),(a0)+
                move.l  12(a2),(a0)+
                move.l  16(a2),(a0)+
                move.l  20(a2),(a0)+
                lea     20(a2),a2
                rts
Skip_Dest_T:    lea     24(a2),a2
                rts

Do_C_Anim_T:    move.l  d6,(a2)+
.AnimTabLoop:   move.w  (a2)+,d0
                bmi.s   .AnimBSlut
                move.w  d0,d1
                lsr.w   #8,d1
                move.w  d1,(a0)+
                add.w   d1,d1
                lea     _BlockSizeTab(pc),a3
                move.w  0(a3,d1.w),d1
                and.w   #$00FF,d0
                mulu    d1,d0
                move.w  d0,(a0)+
                bra.s   .AnimTabLoop
.AnimBSlut:     move.w  #-1,(a0)+
                rts
Skip_Anim_T:    addq.l  #4,a2
.AnimBEnd:      tst.w   (a2)+
                bpl.s   .AnimBEnd
                rts

Do_C_Shot_T:    move.l  d6,(a2)+
                move.l  (a2)+,(a0)+
                move.l  (a2)+,(a0)+
                rts
Skip_Shot_T:    lea     12(a2),a2
                rts
****************** PASS 6, Converting to SEQ

PassSIX:        movea.l MEM_END(pc),a0  ; W A R N I N G  -  MEMORY OPEN!
                move.w  (a6),d0
                lea     0(a6,d0.w),a1

                move.l  a0,30(a6)       ; Set sequense address
                move.w  4(a6),d7

.MAP_Y_L:       moveq   #19,d6
                move.w  #152,_Scr_Offset ; d5=Offset on screen
.MAP_X_L:
                move.w  (a1)+,d0
                beq     Block_JoinUp
                move.w  d0,_BlockTyp

                moveq   #0,d2           ; Calculate some data
                moveq   #0,d1
                move.b  _BlockNr(pc),d2
                move.b  _BlockTyp(pc),d1
                add.w   d1,d1
                lea     _BlockSizeTab(pc),a2
                move.w  0(a2,d1.w),d1
                mulu    d1,d2
                move.w  d2,_Block_Offs
                move.w  _Scr_Offset(pc),d1
                add.w   d1,d1
                move.w  d1,_Block_X_Pos
********************************
                move.w  2(a6),d1
                lea     0(a6,d1.w),a2   ; a2=CreationDatan
                clr.l   _Dest_F_Addr
                clr.l   _Anim_F_Addr
                clr.l   _Shot_F_Addr
.NextTyper:     cmpi.w  #-1,(a2)
                beq.s   .NoCooling
                moveq   #0,d3
.CheckMoreBs:   cmp.w   (a2)+,d0
                bne.s   .NotSame
                moveq   #-1,d3
.NotSame:       cmpi.w  #-1,(a2)
                bne.s   .CheckMoreBs

                move.l  (a2)+,d4
                movea.l a2,a3           ; a3=Start of "Datan"
                addq.l  #4,a2           ; skip NEW tab pointer
                tst.w   d4
                bne.s   .NotA_Dest
                lea     20(a2),a2       ; Destructable ********
                tst.w   d3
                beq.s   .NextTyper
                move.l  a3,_Dest_F_Addr
                bra.s   .NextTyper
.NotA_Dest:     cmp.w   #1,d4
                bne.s   .NotA_Anim
                moveq   #0,d2           ; Animation ************
                clr.w   _Ani_Pos
.NextAnim:      move.w  (a2)+,d4
                bmi.s   .StopAnim       ; endmark?
                cmp.w   d4,d0           ; same as trigger?
                bne.s   .NotPosen
                tst.w   _Ani_Pos        ; already found?
                bne.s   .NotPosen
                move.w  d2,_Ani_Pos
.NotPosen:      addq.w  #1,d2
                bra.s   .NextAnim
.StopAnim:      tst.w   d3
                beq.s   .NextTyper
                move.l  a3,_Anim_F_Addr
                bra.s   .NextTyper
.NotA_Anim:     lea     8(a2),a2        ; CanShoot ***************
                tst.w   d3
                beq.s   .NextTyper
                move.l  a3,_Shot_F_Addr
                bra.s   .NextTyper
**********************************
.NoCooling:     moveq   #0,d1
                tst.l   _Dest_F_Addr
                beq.s   .Niled1
                or.w    #4,d1
.Niled1:        tst.l   _Anim_F_Addr
                beq.s   .Niled2
                or.w    #8,d1
.Niled2:        tst.l   _Shot_F_Addr
                beq.s   .Niled3
                or.w    #16,d1
.Niled3:        lea     _TypHoppTab(pc),a2
                movea.l 0(a2,d1.w),a2
                jmp     (a2)
_TypHoppTab:    dc.l Normal_C_Blk,Dest_C_Blk,Anim_C_Blk,Fel,Shot_C_Blk
                dc.l Fel,Fel,Fel

                dc.b "Ej „nnu inlaggt block-typ"
Fel:            illegal
*****************************
Anim_C_Blk:
*                bra.s   Normal_C_Blk
                move.w  #$0200,(a0)+    ; 0.w Animated + Reserved
                move.w  _Scr_Offset(pc),(a0)+ ; 2.w offset on screen
                movea.l _Anim_F_Addr(pc),a2
                move.l  (a2),d0         ; get addr to NEW TAB
                move.w  d0,(a0)+        ; 4.w AniTab Offset
                move.w  _Ani_Pos(pc),d1
                add.w   d1,d1
                add.w   d1,d1
                move.w  d1,(a0)+        ; 6.w AniPos*4
                bra.s   Block_JoinUp

Dest_C_Blk:     bra.s   Normal_C_Blk
                move.b  #$01,(a0)+      ; 0.b Destruct
                move.b  _BlockTyp(pc),(a0)+ ; 1.b BlockTyp
                move.w  _Scr_Offset(pc),(a0)+ ; 2.w Offset on screen
                move.w  _Block_Offs(pc),(a0)+ ; 4.w Offset to block
                move.w  _Block_X_Pos(pc),(a0)+ ; 6.w Coordinate in X
                movea.l _Dest_F_Addr(pc),a2
                move.l  (a2),d0         ; get offset addr to NEW TAB
                move.w  d0,(a0)+        ; 8.w DestTab Offset
                bra.s   Block_JoinUp

Shot_C_Blk:     bra.s   Normal_C_Blk
                move.b  #$04,(a0)+      ; 0.b Destruct
                move.b  _BlockTyp(pc),(a0)+ ; 1.b BlockTyp
                move.w  _Scr_Offset(pc),(a0)+ ; 2.w Offset on screen
                move.w  _Block_Offs(pc),(a0)+ ; 4.w Offset to block
                move.w  _Block_X_Pos(pc),(a0)+ ; 6.w Coordinate in X
                movea.l _Shot_F_Addr(pc),a2
                move.l  (a2),d0         ; get addr to NEW TAB
                move.w  d0,(a0)+        ; 8.w ShotTab Offset
                bra.s   Block_JoinUp

Normal_C_Blk:   clr.b   (a0)+           ; 0.b Normal
                move.b  _BlockTyp(pc),(a0)+ ; 1.b block type
                move.w  _Scr_Offset(pc),(a0)+ ; 2.w offset on screen
                move.w  _Block_Offs(pc),(a0)+ ; 4.w offset to block

Block_JoinUp:   subq.w  #8,_Scr_Offset
                dbra    d6,.MAP_X_L
                move.w  #$FF00,(a0)+    ; end of line
                dbra    d7,.MAP_Y_L
                move.w  #$FE00,(a0)+    ; end of map
                move.l  #0,(a0)+

                move.l  a0,MEM_END
                lea     Trans_Map(pc),a0 ; //Mem//
                move.l  #End_TransMap-Trans_Map,d0
*                illegal
*                bsr     FREE_FRG_MEM
                movem.l (a7)+,d0-a5
                rts
_BlockTyp:      ds.b 1
_BlockNr:       ds.b 1
_Scr_Offset:    ds.w 1
_Block_Offs:    ds.w 1
_Block_X_Pos:   ds.w 1

_Ani_Pos:       ds.w 1

_Dest_F_Addr:   ds.l 1
_Anim_F_Addr:   ds.l 1
_Shot_F_Addr:   ds.l 1
_Dest_Addr:     ds.l 1
_Anim_Addr:     ds.l 1
_Shot_Addr:     ds.l 1

_BlockSizeTab:  dc.w 4*8,16*8,16*12

End_TransMap:
                endpart
LOAD_POD:       >PART 'LOAD POD'
* a5=address to start of pod area (will point to next area afterwards)
                movem.l d0-a4/a6,-(a7)

                lea     PODTAB(pc),a6   ;            POD TAB setup

                move.l  #TEMP+4,TEMP

.PODLOADLOOP:   cmpi.w  #-1,(a5)
                beq     .PODEND
                cmpi.w  #1,PLAYERS
                bne.s   .TWOTEST
                tst.w   2(a5)
                bne     .SKIPTHISPOD
                bra.s   .DOPOD
.TWOTEST:       tst.w   4(a5)
                bne     .SKIPTHISPOD
.DOPOD:         lea     6(a5),a0

                movea.l a0,a1           ; Remove all crap in name!
                moveq   #11,d0          ; to be able to compare!!
.HITTANULL:     tst.b   (a1)+
                beq.s   .NULLFOUND
                dbra    d0,.HITTANULL
                bra.s   .NONULL
.NULLFOUND:     subq.w  #1,d0
                bmi.s   .NONULL
.NULLA:         clr.b   (a1)+
                dbra    d0,.NULLA
.NONULL:

                lea     TEMP+4,a1       ; Already loaded?
.NO_SEX:        cmpa.l  TEMP,a1
                beq.s   .NOTYETLOADED
                move.l  (a1),d0
                cmp.l   (a0),d0
                bne.s   .NOTSAME
                move.l  4(a1),d0
                cmp.l   4(a0),d0
                bne.s   .NOTSAME
                move.l  8(a1),d0
                cmp.l   8(a0),d0
                bne.s   .NOTSAME
                move.w  20(a0),d0
                cmp.w   12(a0),d0
                bne.s   .NOTSAME
                move.w  22(a0),d0
                cmp.w   14(a0),d0
                bne.s   .NOTSAME
                move.w  24(a0),d0
                cmp.w   16(a0),d0
                bne.s   .NOTSAME

                move.w  22(a1),d0
                move.w  24(a1),d1
                move.w  26(a1),d2
                move.w  28(a1),d3
                move.w  30(a1),d4
                move.w  32(a1),d5
                movea.l 18(a1),a1
                bra.s   .HEY_POOR

.NOTSAME:       lea     34(a1),a1
                bra.s   .NO_SEX

.NOTYETLOADED:                          ; ** LOAD POD **

                movea.l TEMP,a1         ; File name to temp!
                move.l  (a0),(a1)+
                move.l  4(a0),(a1)+
                move.l  8(a0),(a1)+

                bsr     LOAD_FILE
                move.w  20(a5),d0
                move.w  22(a5),d1
                move.w  24(a5),d2
                movea.l TEMP,a1         ; Colors to temp!
                move.l  d0,12(a1)
                move.l  d1,14(a1)
                move.l  d2,16(a1)
                moveq   #0,d3

                bsr     ANI_MASKA_FILE

                movea.l TEMP,a3
                move.l  a1,18(a3)
                move.w  d0,22(a3)
                move.w  d1,24(a3)
                move.w  d2,26(a3)
                move.w  d3,28(a3)
                move.w  d4,30(a3)
                move.w  d5,32(a3)
                addi.l  #34,TEMP

.HEY_POOR:      movea.l MEM_END(pc),a3  ; ** DATA TO POD **
                move.l  a3,(a6)+
                addi.l  #32,MEM_END
                move.l  a1,(a3)

                subq.w  #1,d1
                move.w  d5,4(a3)
                move.w  d0,6(a3)
                subq.w  #1,d0
                bsr     FIND_ROUT
                move.w  d0,26(a3)
                move.w  32(a5),8(a3)
                move.w  34(a5),10(a3)
                move.w  36(a5),12(a3)
                move.w  38(a5),14(a3)
                move.w  26(a5),16(a3)
                move.w  28(a5),18(a3)
                move.w  30(a5),20(a3)
                move.w  d2,22(a3)
                move.w  d2,d0
                bsr     FIND_LSR
                move.w  d0,24(a3)
                move.w  d4,28(a3)


.SKIPTHISPOD:   lea     40(a5),a5
                bra     .PODLOADLOOP
.PODEND:        lea     40(a5),a5

                lea     POD_OUT_TAB(pc),a6 ;         POD OUT TAB   setup!
                movea.l MEM_END(pc),a0
                moveq   #7,d0
.NEXTPO:        move.l  a0,(a6)+
                move.l  #-1,(a0)+       ; No active
                rept 7
                clr.l   (a0)+
                endr
                dbra    d0,.NEXTPO
                move.l  a0,MEM_END

                lea     LOAD_POD(pc),a0 ; //Mem//
                move.l  #End_Load_Pod-LOAD_POD,d0
                bsr     FREE_FRG_MEM

                movem.l (a7)+,d0-a4/a6
                rts
End_Load_Pod:
                endpart
LOAD_PLAYER:    >PART 'LOAD PLAYER'
* a0=address till namn
* a1=address till weapon data
* a2=address till player data
                move.l  a1,-(a7)

                bsr     LOAD_FILE
                lea     16000(a0),a1
                movea.l a1,a3
                moveq   #127,d0
GNUS:           move.l  (a0)+,(a1)+
                dbra    d0,GNUS

                movea.l a3,a0
                bsr     LOAD_FILE
*                move.w  16(a3),d0
*                move.w  18(a3),d1
*                move.w  20(a3),d2
                moveq   #0,d0
                moveq   #1,d1
                moveq   #2,d2
                moveq   #16,d3
                bsr     ROTATE_FILE

                move.l  a1,(a2)
                subq.w  #1,d1
                move.w  d1,4(a2)
                move.w  d4,6(a2)
                move.w  44(a3),d0       ; area
                move.w  d0,8(a2)
                move.w  46(a3),d0
                mulu    #160,d0
                move.w  d0,10(a2)
                move.w  48(a3),d0
                move.w  d0,12(a2)
                move.w  50(a3),d0
                move.w  #150,d0         ;##
                mulu    #160,d0
                move.w  d0,14(a2)
                move.w  52(a3),16(a2)   ; mid
                move.w  54(a3),d0
                mulu    #160,d0
                move.w  d0,18(a2)
                move.w  56(a3),d0       ; hit
                add.w   16(a2),d0
                move.w  d0,28(a2)
                move.w  58(a3),d0
                mulu    #160,d0
                add.w   18(a2),d0
                move.w  d0,30(a2)
                move.w  60(a3),d0
                add.w   16(a2),d0
                move.w  d0,32(a2)
                move.w  62(a3),d0
                mulu    #160,d0
                add.w   18(a2),d0
                move.w  d0,34(a2)

                lea     22(a3),a0       ; B O O S T E R
                bsr     LOAD_FILE
*                move.w  38(a3),d0
*                move.w  40(a3),d1
*                move.w  42(a3),d2
                moveq   #0,d0
                moveq   #1,d1
                moveq   #2,d3
                moveq   #16,d3
                bsr     ROTATE_FILE

                move.l  a1,36(a2)       ; Address to Boosters
                subq.w  #1,d5
                move.w  d5,40(a2)       ; hight
                move.w  64(a3),42(a2)   ; Booster Pos
                move.w  66(a3),d0
                mulu    #160,d0
                move.w  d0,44(a2)
                move.w  68(a3),46(a2)
                move.w  70(a3),d0
                mulu    #160,d0
                move.w  d0,48(a2)
                move.w  d4,50(a2)       ; Lenght of Rot
                move.w  d6,52(a2)       ; Lenght of Cell
                move.w  #-1,54(a2)      ; Boosters active
                move.w  #-1,56(a2)
                clr.w   58(a2)          ; Booster ani
                clr.w   60(a2)


**********************************************

                movea.l MEM_END(pc),a6
                move.l  a6,62(a2)       ; Address to WEAPON tab
                move.l  #-1,(a6)
                lea     256(a6),a6
                move.l  a6,MEM_END

                movea.l 62(a2),a3
                movea.l (a7)+,a0
LOOPINGW:       tst.w   (a0)
                bmi.s   NO_MORE_WEAPON
                move.w  (a0),d0
                lsl.w   #5,d0
                lea     WEAPONTAB(pc),a2
                adda.w  d0,a2
                move.l  6(a2),(a3)+
                move.l  10(a2),(a3)+
                move.l  14(a2),(a3)+
                movea.l MEM_END(pc),a6
                movea.l a6,a1
                move.l  a1,(a3)+
                moveq   #63,d0
RENSAREA:       clr.l   (a6)+
                dbra    d0,RENSAREA
                move.l  a6,MEM_END
                movea.l 2(a2),a4
                movem.l d0-a6,-(a7)
                jsr     (a4)
                movem.l (a7)+,d0-a6
                lea     64(a0),a0
                bra.s   LOOPINGW

NO_MORE_WEAPON: move.l  #-1,(a3)+
                move.l  #-1,(a3)+
                move.l  #-1,(a3)+
                move.l  #-1,(a3)+

                lea     LOAD_PLAYER(pc),a0 ; //Mem//
                move.l  #End_Load_Player-LOAD_PLAYER,d0
                bsr     FREE_FRG_MEM

                rts
End_Load_Player:
                endpart
MAKEENEMIES:    >PART 'MAKE ENEMIES'
* a4=address to object tab
* a5=address to make image
* a6=address to make object

                movem.l d0-a6,-(a7)

                movea.l a5,a2           ;  1. Make all ENEMY IMAGE
DO_IMAGE:       cmpi.w  #-1,(a2)
                beq.s   THATS_IT
                lea     4(a2),a0
                bsr     LOAD_FILE
                move.w  24(a2),d0
                move.w  26(a2),d1
                move.w  28(a2),d2
                move.w  2(a2),d3
                bmi.s   .ANIROT         ; -1=Animated rotation!
                bsr     ROTATE_FILE
                bra.s   .JOINAS
.ANIROT:        bsr     ANI_MASKA_FILE
                subq.w  #1,d0
.JOINAS:        move.w  d2,2(a2)        ; rotations (if animated)
                move.l  a1,20(a2)       ; address
                move.w  d1,30(a2)       ; hight
                move.w  d0,32(a2)       ; width
                move.w  d4,34(a2)       ; lenght of rotation
                move.w  d6,36(a2)       ; lenght of cell
                move.w  d7,38(a2)       ; number of cells
                lea     64(a2),a2
                bra.s   DO_IMAGE

THATS_IT:       movea.l a6,a2           ;  2. Make Objects


OBJECT_LOOP:    movea.l MEM_END(pc),a3
                cmpi.w  #-1,(a2)
                beq     OBJECTS_DONE
                move.w  (a2),d0         ; ** find image
                movea.l a5,a1
FIND_HIM:       cmp.w   (a1),d0
                beq.s   RIGHT_ON
                lea     64(a1),a1
                cmpi.w  #-1,(a1)
                bne.s   FIND_HIM
                illegal
RIGHT_ON:       move.l  20(a1),(a3)     ; ani start
                move.w  36(a1),d0
                mulu    38(a1),d0
                movea.l 20(a1),a0
                adda.w  d0,a0
                move.l  a0,4(a3)        ; ani end
                move.w  16(a2),8(a3)    ; ani speed
                cmpi.w  #0,16(a2)
                bne.s   ANI_ON
                move.w  #0,10(a3)       ; ani on/off
                bra.s   ANI_OFF
ANI_ON:         move.w  #1,10(a3)       ; ani on/off
ANI_OFF:        move.w  34(a1),12(a3)   ; add for rotation
                move.w  30(a1),d0
                subq.w  #1,d0
                move.w  d0,14(a3)       ; hight-1

                move.w  32(a1),d0       ; ** find right sprite rout
                bsr     FIND_ROUT

                move.w  d0,16(a3)       ; sprite rout
                move.w  2(a2),d0
                subq.w  #1,d0
                move.w  d0,18(a3)       ; number of crash rectangels
                move.w  32(a1),20(a3)   ; words wide

                move.w  22(a2),22(a3)   ; number of exteneded explotions
                move.w  #0,24(a3)       ; not used


                move.w  8(a2),26(a3)    ; bullet add X
                move.w  10(a2),28(a3)   ; bullet add Y

                move.w  2(a1),d0        ; ** Find right LSL for rotation
                bsr     FIND_LSR

                move.w  d0,30(a3)       ; lsr for rotation !!??

                move.w  12(a2),d0       ; explosion X
                add.w   #DX_EXPLO,d0
                move.w  d0,32(a3)
                move.w  14(a2),d0
                add.w   #DY_EXPLO,d0
                mulu    #160,d0
                move.w  d0,34(a3)       ; explosion Y*160

                move.l  a3,(a4)+        ; save Object address on Tab

                lea     32(a2),a2       ; increas Object Make Pointer
                move.w  18(a3),d0
                move.w  22(a3),d2
                lea     64(a3),a3       ; increas memory
                tst.w   d0
                bmi.s   NONEATALL
COPYCRASH:      move.w  (a2)+,(a3)+     ; Copy Crash and increas that mem too..
                move.w  (a2)+,d1
                muls    #160,d1
                move.w  d1,(a3)+
                move.w  (a2)+,(a3)+
                move.w  (a2)+,d1
                muls    #160,d1
                move.w  d1,(a3)+
                dbra    d0,COPYCRASH
NONEATALL:      tst.w   d2
                bmi.s   .NONEATALL2
.COPY_EXPLO:    move.l  (a2)+,(a3)+
                move.l  (a2)+,(a3)+
                dbra    d2,.COPY_EXPLO
.NONEATALL2:
                move.l  a3,MEM_END

                bra     OBJECT_LOOP
OBJECTS_DONE:
                lea     MAKEENEMIES(pc),a0 ; //Mem//
                move.l  #End_MakeEnemies-MAKEENEMIES,d0
                bsr     FREE_FRG_MEM


                movem.l (a7)+,d0-a6
                rts
End_MakeEnemies:
                endpart
MAKE_SPRITETAB: >PART 'Make SPRITETAB'
                movea.l MEM_END(pc),a6
                lea     SPRITETAB(pc),a1 ; make SPRITETAB
                moveq   #63,d6
                move.l  #SPRITETAB_SIZE-1,d5
                move.l  #SPRITETAB_SIZE,d0
.MakePointers:  bsr     GET_FRG_MEM
                move.l  a0,(a1)+
                move.w  d5,d7
.Tomma:         clr.b   (a6)+
                dbra    d7,.Tomma
                dbra    d6,.MakePointers

                lea     End_Make_SpriteTab(pc),a0 ; //Mem//
                move.l  #End_Make_SpriteTab-MAKE_SPRITETAB,d0
                bsr     FREE_FRG_MEM
                rts
End_Make_SpriteTab:
                endpart
                >PART 'Transfare Data'
** Find right LSR for rotation
* d0=rotations
FIND_LSR:       movem.l d1/a0,-(a7)
                lea     LSR_ROT_CONV(pc),a0
                moveq   #0,d1
FIND_LSREN:     cmp.w   (a0)+,d0
                beq.s   FOUND_LSR
                addq.w  #1,d1
                bra.s   FIND_LSREN
FOUND_LSR:      move.l  d1,d0
                movem.l (a7)+,d1/a0
                rts

** Find right sprite routine
* d0=width/16
FIND_ROUT:      movem.l d1/a0,-(a7)
                moveq   #0,d1
                lea     SPRITEROUTCONV(pc),a0
LOOK_ROUT:      cmp.w   (a0)+,d0
                beq.s   FOUNDROUT
                cmpi.w  #-1,(a0)
                beq.s   FOUNDROUT
                addq.w  #1,d1
                bra.s   LOOK_ROUT
FOUNDROUT:      move.l  d1,d0
                movem.l (a7)+,d1/a0
                rts

SPRITEROUTCONV: dc.w 1,2,3,5,8,9,-1
LSR_ROT_CONV:   dc.w 16,8,4,2,1
                endpart

*******************************************
ONE_OR_TWO:     >PART 'Select One Or Two Players'

                lea     PICTUREFIL(pc),a0
                bsr     LOAD_FILE
                movem.l 4(a0),d0-d7
                movem.l d0-d7,$FFFF8240.w
                lea     128(a0),a0
                movea.l SCREEN2(pc),a1
                move.w  #7999,d0
COPYBILD:       move.l  (a0)+,(a1)+
                dbra    d0,COPYBILD
                move.b  SCREEN2+1(pc),$FFFF8201.w
                move.b  SCREEN2+2(pc),$FFFF8203.w

                move    #$2300,sr
WAITRESPONS:
                move.b  KEY(pc),d0
                cmpi.b  #$3C,d0
                beq.s   TWO_PLAYERS
                cmp.b   #$3B,d0
                bne.s   WAITRESPONS

                move.w  #1,PLAYERS
                bra.s   LEAVE_PROCE
TWO_PLAYERS:    move.w  #2,PLAYERS

LEAVE_PROCE:
                moveq   #7,d0
                lea     $FFFF8240.w,a0
                moveq   #7,d0
BLANK:          move.l  #$08018101,(a0)+
                dbra    d0,BLANK
                movea.l SCREEN1(pc),a0
                movea.l SCREEN2(pc),a1
                move.w  #7999,d0
RENSASCR:       clr.l   (a0)+
                clr.l   (a1)+
                dbra    d0,RENSASCR
                move    #$2500,sr

                lea     ONE_OR_TWO(pc),a0 ; //Mem//
                move.l  #End_One_Or_Two-ONE_OR_TWO,d0
                bsr     FREE_FRG_MEM
                rts

PICTUREFIL:     dc.b "begin.neo",0

End_One_Or_Two:
                endpart

RESTART:        >PART 'Restore Data'
                move.l  #MEMORY,MEM_END
                bsr     INIT_FRG_MEM
                lea     STUPID_FIX(pc),a0 ; //Mem//
                move.l  #END_STUPID_FIX-STUPID_FIX,d0
                bsr     FREE_FRG_MEM
                lea     BEGIN(pc),a0    ; //Mem//
                move.l  #END_BEGIN-BEGIN,d0
                bsr     FREE_FRG_MEM
*                lea     CHEATBOX,a0     ; //Mem//   7 KB!
*                move.l  #END_CHEATBOX-CHEATBOX,d0
*                bsr     FREE_FRG_MEM

                move.w  #0,CHG_ON_TWO
                move.w  #0,INST_RASTER

                move.l  #SCR1,d0
                and.l   #$FFFFFF00,d0
                move.l  d0,SCREEN1
                move.l  #SCR2,d0
                and.l   #$FFFFFF00,d0
                move.l  d0,SCREEN2
                move.l  SCREEN1(pc),SCREEN
                move.b  SCREEN+1(pc),$FFFF8201.w
                move.b  SCREEN+2(pc),$FFFF8203.w
                bsr     VSYNC3
                lea     $FFFF8240.w,a0
                moveq   #7,d0
.BLANKOUT:      move.l  #$08010801,(a0)+
                dbra    d0,.BLANKOUT

                clr.l   BLOCKPOS
                clr.l   BLOCKSTART
                clr.w   BLOCKCOUNT
                clr.l   SCROLLADDR
                clr.l   BACKGROUNDADDR

                lea     PL_DATAN1(pc),a0 ; restore playerdata
                lea     PL_DATA1(pc),a1
                lea     PL_DATAN2(pc),a2
                lea     PL_DATA2(pc),a3
                lea     END_PLDATAN1(pc),a4
.KOPIERAPLAYER: move.w  (a0)+,(a1)+
                move.w  (a2)+,(a3)+
                cmpa.l  a0,a4
                bne.s   .KOPIERAPLAYER

                lea     ESHOOT(pc),a0
                move.w  #ES-1,d0
.RENSASKOTT:    clr.w   (a0)+
                dbra    d0,.RENSASKOTT

                lea     SCORE1(pc),a0   ; Restore Score
                lea     SCORE1(pc),a1
                lea     OLDTAL1(pc),a2
                lea     OLDTAL2(pc),a3
                moveq   #6,d0
.FIXSCORE:      clr.b   (a0)+
                clr.b   (a1)+
                move.b  #11,(a2)+
                move.b  #11,(a2)+
                move.b  #11,(a3)+
                move.b  #11,(a3)+
                dbra    d0,.FIXSCORE

                lea     WEAPONLOOKTAB(pc),a0
                lea     WEAPONLOOKTAB2(pc),a1
                lea     WEAPONLOOKSLUT(pc),a2
.COPYWLT:       move.w  (a1)+,(a0)+
                cmpa.l  a1,a2
                bne.s   .COPYWLT

                move.l  #SEQ,SEQPEK     ; Restore Enemy Sequenser
                clr.w   DOINGFLAG
                clr.w   DOCOUNT
                move.l  #LOOPTAB,LOOPPEK

                move.l  #SEQSTACK,SEQSTACKPEK
                clr.w   IRQ_MODE
                lea     SEQIRQTAB(pc),a0
                moveq   #16*4-1,d0
.RENSAIRQS:     clr.l   (a0)+
                dbra    d0,.RENSAIRQS

                lea     _EXT_EXPLO,a0
                moveq   #55,d0
.NO_EXT:        move.w  #-1,(a0)
                lea     18(a0),a0
                dbra    d0,.NO_EXT

                lea     RESTART(pc),a0  ; //Mem//
                move.l  #End_Restart-RESTART,d0
                bsr     FREE_FRG_MEM
                rts
End_Restart:
                endpart

RESET_PLAYERS:  >PART 'Reset Players'


                cmpi.w  #1,PLAYERS
                bne.s   TWOOFEM

                lea     PL_DATA1(pc),a6
                move.w  #-1,76(a6)      ; 0= Not Active   -1=Active
                lea     PL_DATA2(pc),a6
                move.w  #0,76(a6)       ; 0= Not Active   -1=Active
                bra.s   JOINSIR


TWOOFEM:        lea     PL_DATA1(pc),a6
                move.w  #-1,76(a6)      ; 0= Not Active   -1=Active
                lea     PL_DATA2(pc),a6
                move.w  #-1,76(a6)      ; 0= Not Active   -1=Active

JOINSIR:
                lea     RESET_PLAYERS(pc),a0 ; //mem//
                move.l  #End_Reset_Players-RESET_PLAYERS,d0
                bsr     FREE_FRG_MEM
                rts
End_Reset_Players:
                endpart
********************************************
**      GAME
********************************************
GAME:           >PART 'Init Once'
                move.l  #RASTER,$00000120.w
                bset    #0,$FFFFFA07.w  ; Start Timer B
                bset    #0,$FFFFFA13.w

                move.b  #0,$FFFF8260.w
                bclr    #1,$FFFF820A.w  ; TT!!!

                move    #$2300,sr
                bsr     VSYNC
                bsr     VSYNC
                bsr     VSYNC
                bset    #1,$FFFF820A.w
                endpart
START_GAME:     >PART 'Game Init'
                bsr     RESTART
                bsr     ONE_OR_TWO
                bsr     RESET_PLAYERS

                lea     LEVEL_PODMAKE(pc),a5
                bsr     LOAD_POD

                bsr     INIT2

                lea     _MAPTAB,a6
                bsr     Trans_Map

                move.l  6(a6),F_BLOCK
                move.l  10(a6),N_BLOCK
                move.l  14(a6),S_BLOCK
                move.l  18(a6),_Blk_DestTab
                move.l  22(a6),_Blk_AnimTab
                move.l  26(a6),_Blk_ShotTab
                movea.l 30(a6),a0
                move.l  a0,BLOCKSTART
                move.l  a0,BLOCKPOS

                lea     _MAPTAB,a0      ; //Mem//
                move.l  #_MAPTAB_END-_MAPTAB,d0
                bsr     FREE_FRG_MEM


                lea     MOTSKOTT1(pc),a0 ; Make enemy bullet
                moveq   #0,d0
                moveq   #1,d1
                moveq   #2,d2
                moveq   #16,d3
                bsr     ROTATE_FILE
                move.l  a1,ESHOOTADDR1

                bsr     INITLINE        ; Restore Energy  data
                bsr     DRAWALLENERGY

                bsr     MAKE_SPRITETAB

                move    #$2700,sr
                bsr     START_MUSIC
                move.w  #1,MUSIC_FLAG
                move.w  #$00FF,INST_RASTER ; RASTER UPDATE ON
                move    #$2300,sr

                move.l  SCREEN1(pc),SCREEN
                move.w  #-1,CHG_ON_TWO
                bsr     VSYNC3
                movem.l PAL1(pc),d0-d7
                movem.l d0-d7,$FFFF8240.w

                endpart
                PART 'Game Loop'
GAME_LOOP:      bsr     VSYNC3

                lea     LOWER_ENERGY(pc),a0
                bsr     DO_BOTH_PLAYER

                bsr     SWITCH_SCREEN
                bsr     CHECK_SLUMP_END
                jsr     DRAW_BACK(pc)

                bsr     MOVE_BLOCK
                bsr     SEQUENSER

                bsr     MOVE_SPRITES

                lea     CONTROL(pc),a0
                bsr     BOTH_PLAYER

                move.w  #$0FFF,TIMECOL
                bsr     SHOWTIME

                lea     MOVE_WEAPON(pc),a0
                bsr     DO_PLY_ON_SCR

                move.w  #0,TIMECOL
                bsr     SHOWTIME
                bsr     MOVE_ESHOOT
                bsr     NEW_ESHOOT

                move.w  #$0080,TIMECOL
                bsr     SHOWTIME
                bsr     DRAW_BLOCKS
                move.w  #$0000,TIMECOL
                bsr     SHOWTIME
                bsr     DRAW_BONUS
                bsr     DRAW_ESHOOTS
                move.w  #$0700,TIMECOL
                bsr     SHOWTIME

                lea     DRAW_WEAPON(pc),a0
                bsr.s   DO_PLY_ON_SCR

                move.w  #$0070,TIMECOL
                bsr     SHOWTIME

                lea     DRAWSHIP(pc),a0
                bsr.s   DO_PLY_ON_SCR

*                move.w  #$0700,$FFFF8240.w
                bsr     DRAW_SPRITES
*                move.w  #$0000,$FFFF8240.w
                bsr     DRAW_EXT_EXPLO
                bsr     SHOWTIME
                bsr     SCORE_DRAW
                move.w  #$0111,TIMECOL
                bsr.s   SHOWTIME

                lea     TES_ESHOOT_PL(pc),a0
                bsr.s   BOTH_PLAYER

                lea     TEST_PL_TO_ENE(pc),a0
                bsr.s   BOTH_PLAYER

                lea     TEST_PL_TO_POD(pc),a0
                bsr.s   BOTH_PLAYER

                bra     GAME_LOOP

                endpart

BOTH_PLAYER:    >PART 'Run Routine on Both Player'

                move.l  a0,-(a7)
                lea     PL_DATA1(pc),a6
                tst.w   76(a6)
                beq.s   NOTACTIVE1
                jsr     (a0)
NOTACTIVE1:     movea.l (a7)+,a0
                lea     PL_DATA2(pc),a6
                tst.w   76(a6)
                beq.s   NOTACTIVE2
                jsr     (a0)
NOTACTIVE2:     rts
                endpart
DO_BOTH_PLAYER: >PART 'DO Run Routine on Both Player'

                move.l  a0,-(a7)
                lea     PL_DATA1(pc),a6
                jsr     (a0)
                movea.l (a7)+,a0
                lea     PL_DATA2(pc),a6
                jsr     (a0)
                rts

                endpart
DO_PLY_ON_SCR:  >PART 'Run both if Explo or Alive'

                move.l  a0,-(a7)
                lea     PL_DATA1(pc),a6
                tst.w   76(a6)
                beq.s   NOTACTIVE3
                jsr     (a0)
                bra.s   .GONES
NOTACTIVE3:     tst.l   100(a6)
                beq.s   .GONES
                jsr     (a0)
.GONES:         movea.l (a7)+,a0
                lea     PL_DATA2(pc),a6
                tst.w   76(a6)
                beq.s   NOTACTIVE4
                jsr     (a0)
                bra.s   .GONES2
NOTACTIVE4:     tst.l   100(a6)
                beq.s   .GONES2
                jsr     (a0)
.GONES2:        rts
                endpart

*******************************************
                >PART 'TIME SHOW'
******************************************************
**      SET RASTER TIME COLOR IF ALLOWED
******************************************************
SHOWTIME:       tst.w   TIMESHOW
                beq.s   NOOOO
                move.w  TIMECOL(pc),$FFFF8240.w
NOOOO:          rts
TIMECOL:        dc.w 0
                endpart

MOVE_WEAPON:    >PART 'Move Wepon'
                movea.l 62(a6),a3

TEST_NEXTA2:    tst.l   (a3)
                bmi.s   ALL_DONEA2

                movea.l (a3),a0
                movea.l 12(a3),a5
                movem.l a3/a6,-(a7)
                jsr     (a0)
                movem.l (a7)+,a3/a6
                lea     16(a3),a3
                bra.s   TEST_NEXTA2
ALL_DONEA2:
                rts

                endpart
DRAW_WEAPON:    >PART 'Draw Weapon'
                movea.l 62(a6),a3

TEST_NEXTA:     tst.l   (a3)
                bmi.s   ALL_DONEA

                movea.l 8(a3),a0
                movea.l 12(a3),a5
                movem.l a3/a6,-(a7)
                jsr     (a0)
                movem.l (a7)+,a3/a6
                lea     16(a3),a3
                bra.s   TEST_NEXTA
ALL_DONEA:
                rts
                endpart

DRAW_BONUS:     >PART 'Draw & Move all bonus pods'
                lea     POD_OUT_TAB(pc),a6
                moveq   #7,d7
.TESTALLPODS:   movea.l (a6)+,a5
                tst.w   (a5)
                bne     .NOTACTIVEPOD

                movea.l 2(a5),a4

                move.w  10(a5),d0       ; move pod!
                add.w   d0,6(a5)
                move.w  12(a5),d0
                add.w   d0,8(a5)

                move.w  6(a5),d4        ; d4=x
                asr.w   #4,d4
                move.w  8(a5),d5        ; d5=y
                asr.w   #4,d5

                move.w  d4,d0           ; if pod is outside +16
                cmp.w   #-20,d0         ; before it appears (??!)
                blt.s   .GONE
                move.w  d5,d0
                cmp.w   #-20,d0
                blt.s   .GONE
                cmpi.w  #319+20,d4
                bgt.s   .GONE
                cmpi.w  #CLIP_Y+20,d5
                blt.s   .NOTGONE

.GONE:          move.w  #-1,(a5)        ; Pod out of screen!
                move.w  18(a5),d0
                and.w   d0,PL_DATA1+98
                and.w   d0,PL_DATA2+98
                bra.s   .NOTACTIVEPOD

.NOTGONE:

                move.w  d4,d0
                and.w   #$000F,d0
                move.w  24(a4),d1
                lsr.w   d1,d0
                mulu    28(a4),d0
                movea.l (a4),a1
                adda.l  d0,a1

                moveq   #0,d3
                move.w  6(a4),d3
                moveq   #0,d6
                move.w  26(a4),d6
                move.l  d7,-(a7)

                move.w  4(a4),d7
                subq.w  #1,d7
                bsr     DO_SPRITE
                move.l  (a7)+,d7


.NOTACTIVEPOD:  dbra    d7,.TESTALLPODS

                rts
                endpart
TEST_PL_TO_POD: >PART 'Player to pod'
* a6=player tab
                lea     POD_OUT_TAB(pc),a5
                moveq   #7,d7
.NEXTPOD:       movea.l (a5)+,a4
                tst.w   (a4)
                bne.s   .NOT_ACTIVE
                movem.l d7/a5-a6,-(a7)
                movea.l 2(a4),a3

                move.w  6(a4),d0
                move.w  8(a4),d1
                asr.w   #4,d0
                asr.w   #4,d1
                move.w  d0,d2
                move.w  d1,d3
                add.w   8(a3),d0
                add.w   10(a3),d1
                add.w   12(a3),d2
                add.w   14(a3),d3
                muls    #160,d1
                muls    #160,d3

                move.w  20(a6),d4
                move.w  22(a6),d5
                move.w  d4,d6
                move.w  d5,d7
                add.w   28(a6),d4
                add.w   30(a6),d5
                add.w   32(a6),d6
                add.w   34(a6),d7

                bsr     TEST_POS
                tst.w   d0
                beq.s   .PUST

                move.w  #-1,(a4)
                bsr.s   DOPOD

.PUST:          movem.l (a7)+,d7/a5-a6
.NOT_ACTIVE:    dbra    d7,.NEXTPOD

                rts
                endpart
DOPOD:          >PART 'Handle taken Pod'
* a6=Player
* A4=Pod In Action
* A3=Pod Intern
                move.w  20(a3),d0

                cmp.w   #0,d0
                beq.s   .PODDONE

                cmp.w   #1,d0           ; Energy (add/sub)
                bne.s   .NOT_ENERGY
                move.w  14(a4),d1
                add.w   d1,26(a6)
                cmpi.w  #38,26(a6)
                ble.s   .PODDONE
                move.w  #38,26(a6)
                bra.s   .PODDONE

.NOT_ENERGY:    cmp.w   #2,d0           ; Speedup One Step
                bne.s   .NOT_SPEED
                lea     82(a6),a0
                movea.l (a0),a1
                move.l  (a1),d0
                sub.l   d0,86(a6)
                tst.l   4(a1)
                bmi.s   .NOTINC
                addq.l  #4,a1
.NOTINC:        move.l  (a1),d1
                add.l   d1,86(a6)
                move.l  a1,82(a6)
                bra.s   .PODDONE

.NOT_SPEED:     cmp.w   #3,d0           ; AutoFire
                bne.s   .NOT_AUTO
                move.w  #1,94(a6)
                subq.w  #1,90(a6)
                bpl.s   .PODDONE
                move.w  #0,90(a6)
                bra.s   .PODDONE

.NOT_AUTO:

.PODDONE:       move.w  16(a3),d0
                or.w    d0,98(a6)

                rts

                endpart

CONTROL:        >PART 'STEEARING PLAYER'
********************************************
**      CONTROL SHIP
********************************************
                movea.l 86(a6),a0
                move.w  #-1,54(a6)
                move.w  #-1,56(a6)
                move.w  (a0)+,d6
                cmpi.w  #$00FF,(a0)
                beq.s   DONTSAVEPEK1
                move.l  a0,86(a6)
DONTSAVEPEK1:
                movea.l 78(a6),a1
                move.b  (a1),d0



*                bset    #7,d0
                move.b  d0,d1
                and.w   #$000F,d1
                bne.s   MAKETESTS1
                movea.l 82(a6),a0       ; No Movment
                move.l  (a0),86(a6)     ; Reset SpeedPointer
                bra.s   NOMOVE1

MAKETESTS1:

                btst    #0,d0
                beq.s   NOT_UP
                move.w  #160,d1         ; up
                mulu    d6,d1
                sub.w   d1,22(a6)
                move.w  #0,54(a6)
                move.w  #0,56(a6)
NOT_UP:         btst    #1,d0
                beq.s   NOT_DOWN
                move.w  #160,d1         ; down
                mulu    d6,d1
                add.w   d1,22(a6)
NOT_DOWN:       btst    #2,d0
                beq.s   NOT_LEFT
                sub.w   d6,20(a6)       ; left
                move.w  #0,56(a6)
NOT_LEFT:       btst    #3,d0
                beq.s   NOT_RIGHT
                add.w   d6,20(a6)       ; right
                move.w  #0,54(a6)
NOT_RIGHT:

NOMOVE1:
                tst.w   54(a6)          ; booster ani
                bmi.s   NOT_ACT1
                move.w  58(a6),54(a6)
NOT_ACT1:       tst.w   56(a6)
                bmi.s   NOT_ACT2
                move.w  58(a6),56(a6)
NOT_ACT2:
                subq.w  #1,60(a6)
                bpl.s   NOBOOSTCHG
                move.w  #1,60(a6)
                eori.w  #1,58(a6)
NOBOOSTCHG:


                move.w  10(a6),d1
                cmp.w   22(a6),d1
                ble.s   OKI1
                move.w  d1,22(a6)

OKI1:           move.w  14(a6),d1
                cmp.w   22(a6),d1
                bge.s   OKI2
                move.w  d1,22(a6)

OKI2:
                move.w  8(a6),d1
                cmp.w   20(a6),d1
                ble.s   OKI3
                move.w  d1,20(a6)

OKI3:           move.w  12(a6),d1
                cmp.w   20(a6),d1
                bge.s   OKI4
                move.w  d1,20(a6)

OKI4:           btst    #7,d0           ; FIRE
                beq.s   NOT_FIREA
                tst.w   92(a6)
                beq.s   KAN_SKJUTA1
                bmi.s   KAN_SKJUTA1
                tst.w   94(a6)
                beq.s   NOT_FIRE
                moveq   #1,d0
                sub.w   d0,92(a6)
                bra.s   NOT_FIRE
NOT_FIREA:      clr.w   92(a6)
NOT_FIRE:       rts

KAN_SKJUTA1:    move.w  90(a6),92(a6)

                movea.l 62(a6),a3

TESTHOM:        tst.l   (a3)
                bmi.s   ANTLIGEN_SLUT
                movea.l 12(a3),a5
                movea.l 4(a3),a0
                movem.l a3/a6,-(a7)
                jsr     (a0)
                movem.l (a7)+,a3/a6
                lea     16(a3),a3
                bra.s   TESTHOM
ANTLIGEN_SLUT:
                bra.s   NOT_FIRE

                endpart
DRAWSHIP:       >PART 'DRAW PL SHIPS'
********************************************
**      CALCULATE SHIP SCREEN ADDRESS
********************************************
                tst.w   76(a6)
                bmi.s   .ALIVE
                tst.l   100(a6)
                beq     .VERY_GONE
                bsr     DRAW_PLY_EXPLO
                bra     .VERY_GONE

.ALIVE:         move.w  20(a6),d0
                movea.l SCREEN(pc),a0
                movea.l (a6),a1
                move.w  d0,d1
                and.w   #$000F,d0
                sub.w   d0,d1
                asr.w   #1,d1
                adda.w  d1,a0
                mulu    6(a6),d0
                adda.w  d0,a1
                move.w  4(a6),d7

                move.w  22(a6),d6
                adda.w  d6,a0
                ext.l   d6
                divu    #160,d6

                move.l  a6,-(a7)
                lea     SPRITA64(pc),a2
                bsr     CLIPY
                movea.l (a7)+,a6

                tst.w   54(a6)
                bmi.s   BOOSTOFF1
                move.w  20(a6),d0
                move.w  22(a6),d1
                add.w   42(a6),d0
                add.w   44(a6),d1
                move.w  d1,d6
                ext.l   d6
                divu    #160,d6
                move.w  d0,d2
                and.w   #$000F,d2
                sub.w   d2,d0
                lsr.w   #1,d0
                add.w   d0,d1
                movea.l SCREEN(pc),a0
                adda.w  d1,a0
                movea.l 36(a6),a1
                mulu    50(a6),d2
                adda.w  d2,a1
                move.w  54(a6),d2
                mulu    52(a6),d2
                adda.w  d2,a1
                move.w  40(a6),d7
                move.l  a6,-(a7)
                lea     SPRITA32(pc),a2
                bsr     CLIPY
                movea.l (a7)+,a6

BOOSTOFF1:      tst.w   56(a6)
                bmi.s   BOOSTOFF2
                move.w  20(a6),d0
                move.w  22(a6),d1
                add.w   46(a6),d0
                add.w   48(a6),d1
                move.w  d1,d6
                ext.l   d6
                divu    #160,d6
                move.w  d0,d2
                and.w   #$000F,d2
                sub.w   d2,d0
                lsr.w   #1,d0
                add.w   d0,d1
                movea.l SCREEN(pc),a0
                adda.w  d1,a0
                movea.l 36(a6),a1
                mulu    50(a6),d2
                adda.w  d2,a1
                moveq   #2,d2
                add.w   56(a6),d2
                mulu    52(a6),d2
                adda.w  d2,a1
                move.w  40(a6),d7
                move.l  a6,-(a7)
                lea     SPRITA32(pc),a2
                bsr     CLIPY
                movea.l (a7)+,a6
BOOSTOFF2:

.VERY_GONE:     rts
                endpart
INIT_PLY_EXPLO: >PART 'Player is about to explo'
* a6=Address to player data

                movea.l (a6),a5
                move.l  a5,100(a6)
                moveq   #0,d0
                moveq   #0,d1
                move.w  20(a6),d0
                move.w  22(a6),d1
                add.w   16(a6),d0
                add.w   18(a6),d1
                ext.l   d1
                divu    #160,d1
                swap    d0
                swap    d1

                lea     SIN_WORD_10(pc),a4
                lea     COS_WORD_10(pc),a3

                moveq   #35,d7

.INITALLDOTS:   cmp.w   #12,d3
                beq.s   .GO13
                moveq   #12,d3
                bra.s   .ON12
.GO13:          moveq   #10,d3
.ON12:          move.l  d0,(a5)+
                move.l  d1,(a5)+
                move.w  (a3)+,d2
                muls    d3,d2
                move.l  d2,(a5)+
                move.w  (a4)+,d2
                muls    d3,d2
                move.l  d2,(a5)+
                move.w  #-1,(a5)+
                clr.w   (a5)+

                dbra    d7,.INITALLDOTS

                rts

                endpart
DRAW_PLY_EXPLO: >PART 'Player Explotion Draw'
* a6=Address to player
*   0  ds.l 1   XPos *$10000
*   4  ds.l 1   YPos *$10000
*   8  ds.l 1   XSpeed *$10000
*   12 ds.l 1   XSpeed *$10000
*   16 ds.w 1   0=Not Active
*   18 ds.w 1   ** Reserved **


                movea.l 100(a6),a5
                movea.l SCREEN(pc),a4

                moveq   #35,d7
                moveq   #0,d6

.ALLDOTS:       tst.w   16(a5)
                beq.s   .PROTEST
                move.l  8(a5),d0
                add.l   d0,(a5)
                move.l  12(a5),d0
                add.l   d0,4(a5)

                move.w  (a5),d0
                bmi.s   .OUTSIDE
                move.w  4(a5),d1
                bmi.s   .OUTSIDE

                cmp.w   #318,d0
                bge.s   .OUTSIDE
                cmp.w   #CLIP_Y-1,d1
                bge.s   .OUTSIDE

                mulu    #160,d1
                move.w  d0,d2
                and.w   #$000F,d2
                sub.w   d2,d0
                lsr.w   #1,d0
                add.w   d0,d1
                lea     0(a4,d1.w),a0

                eori.w  #$000F,d2
                moveq   #0,d0
                bset    d2,d0
                add.w   d0,d0           ; Haha, om p† 15 s† blir det en punkt!
                bset    d2,d0

                or.w    d0,(a0)+
                or.w    d0,(a0)+
                or.w    d0,(a0)+
                or.w    d0,(a0)+
                adda.w  #160-8,a0
                or.w    d0,(a0)+
                or.w    d0,(a0)+
                or.w    d0,(a0)+
                or.w    d0,(a0)+

                bra.s   .NOTOUT

.OUTSIDE:       move.w  #0,16(a5)
.PROTEST:       addq.w  #1,d6
.NOTOUT:        lea     20(a5),a5
                dbra    d7,.ALLDOTS

                cmp.w   #36,d6
                bne.s   .HEPHEP
                clr.l   100(a6)
.HEPHEP:        rts
                endpart

TEST_POS:       >PART 'Test if two boxes collidates'
******************************************************
**      TEST D0,D1,D2,D3  TO D4,D5,D6,D7 D0:0=NO COL 1=COL
******************************************************
                cmp.w   d2,d4           ; XX1>X2=SKIP
                bgt.s   NEJ_NEJ_NEJ2
                cmp.w   d0,d6           ; XX2<X1=SKIP
                blt.s   NEJ_NEJ_NEJ2
                cmp.w   d3,d5           ; YY1>Y2=SKIP
                bgt.s   NEJ_NEJ_NEJ2
                cmp.w   d1,d7           ; YY2<Y1=SKIP
                blt.s   NEJ_NEJ_NEJ2
                moveq   #1,d0
                rts
NEJ_NEJ_NEJ2:   moveq   #0,d0
                rts
                endpart
DO_SPRITE:      >PART 'Draw sprite on screen'
***************************************
* draw a sprite on screen, using cliping e.ct

* d3=width in screen-words
* d4=x (only for cliping!, so a "and $FFFF0" wouldn't effect result!)
* d5=y
* d6 =     bit 0-15   sprite rout to use
*          bit 16     1=White
* d7=hight-1
*
* a1=address to image (and that is including rotation!)
*
* change all
* destroys  d0,d1,d2,a0,a2,a5
***************************************
                tst.w   d5              ; Clipping up
                bpl.s   .NOCLIP_UP
                add.w   d5,d7
                bmi     .NOTDRAW
                neg.w   d5
                mulu    d3,d5
                mulu    #12,d5
                adda.w  d5,a1
                moveq   #0,d5

.NOCLIP_UP:     move.w  d5,d0
                add.w   d7,d0
                addq.w  #1,d0
                cmp.w   #CLIP_Y+2,d0    ; Clipping down
                ble.s   .NOCLIP_DOWN
                move.w  #CLIP_Y+2,d0
                sub.w   d5,d0
                move.w  d0,d7
                subq.w  #1,d7
                bmi     .NOTDRAW

.NOCLIP_DOWN:
                and.w   #$FFF0,d4
                movea.l SCREEN(pc),a0
                mulu    #160,d5
                asr.w   #1,d4
                add.w   d4,d5
                asr.w   #3,d4           ; d4=xpos as screen words (!?)
                adda.w  d5,a0           ; a0=Screen address
                move.w  d3,d0
                subq.w  #1,d0           ; d0=width-1
                bmi.s   .NOTDRAW
                moveq   #0,d1           ; d1=add p† source efter varje rad
                move.w  #160,d2         ; d2=add p† dest efter varje rad
                move.w  d3,d5
                lsl.w   #3,d5
                sub.w   d5,d2
                exg     a5,d7           ; Temporary save d7 on a5

                tst.w   d4              ; Clipping left
                bpl.s   .NOCLIP_LEFT
                add.w   d4,d0
                bmi.s   .NOTDRAW
                add.w   d4,d3

                neg.w   d4
                move.w  d4,d1
                mulu    #12,d1
                adda.w  d1,a1
                lsl.w   #3,d4
                adda.w  d4,a0
                add.w   d4,d2

                move.w  #-1,d6
                moveq   #0,d4


.NOCLIP_LEFT:   move.w  d3,d5           ; Clipping right
                add.w   d4,d5
                cmp.w   #20,d5
                blt.s   .NOTCLIP_RIGHT
                moveq   #20-1,d0
                sub.w   d4,d0
                bmi.s   .NOTDRAW        ; d0=mx-x-1
                add.w   d3,d4
                sub.w   #20,d4          ; d4=x+w-mx
                move.w  d4,d5
                mulu    #12,d4
                lsl.w   #3,d5
                add.w   d4,d1
                add.w   d5,d2
                move.w  #-1,d6

.NOTCLIP_RIGHT:
                asl.w   #3,d6
                lea     SPRITATAB(pc),a2
                btst    #16,d6
                beq.s   .NORMAL
                lea     VITTAB(pc),a2
.NORMAL:        movea.l 0(a2,d6.w),a2
                exg     a5,d7
                jsr     (a2)

.NOTDRAW:
                rts
                endpart

DRAW_EXT_EXPLO: >PART 'More Explotions....'
                lea     _EXT_EXPLO,a6
                move.w  _EXPLO_NR(pc),d7
                beq.s   .HEJSVEJS

.FINDALLEXPLO:  tst.w   (a6)
                bmi.s   .NŽACTIVE
                subq.w  #1,d7
                subq.w  #1,6(a6)
                bpl.s   .NOTYET

                move.w  #1,6(a6)
                addq.w  #1,8(a6)
                movea.l 10(a6),a5
                move.w  8(a5),d0
                add.w   d0,16(a6)
                move.l  4(a5),d0
                sub.l   (a5),d0
                cmp.w   16(a6),d0
                bne.s   .NOTYET
                move.w  #-1,(a6)
                subq.w  #1,_EXPLO_NR
                bra.s   .NŽACTIVE
.NOTYET:        tst.w   8(a6)
                bmi.s   .NŽACTIVE

                move.w  2(a6),d4
                move.w  4(a6),d5
                movea.l 10(a6),a5
                movea.l (a5),a1
                adda.w  14(a6),a1
                adda.w  16(a6),a1
                moveq   #0,d6
                move.w  16(a5),d6
                move.w  20(a5),d3
                move.w  d7,-(a7)
                move.w  14(a5),d7
                addq.w  #1,d3
                bsr     DO_SPRITE
                move.w  (a7)+,d7

.NŽACTIVE:      lea     18(a6),a6
                tst.w   d7
                bne.s   .FINDALLEXPLO
.HEJSVEJS:      rts
                endpart
****************************************************************
SEQUENSER:      >PART 'SEQUENSER'
***********************************************
**      SEQUENSER
***********************************************

                tst.w   DOINGFLAG
                beq.s   .DONEWCOM
                cmpi.w  #1,DOINGFLAG
                bne.s   .NOTTWAIT
                subq.w  #3,DOCOUNT
                tst.w   DOCOUNT
                bmi.s   .NULLHIM
                bra     IM_DONE
.NOTTWAIT:      cmpi.w  #2,DOINGFLAG
                bne.s   .NOTSWAIT
                bsr     SPRITEWAIT
                bra     IM_DONE
.NOTSWAIT:      cmpi.w  #3,DOINGFLAG
                bne.s   .NOTPODWAIT
                bsr     PODWAIT
                bra     IM_DONE

.NOTPODWAIT:    bra     IM_DONE

.NULLHIM:       move.w  #0,DOINGFLAG
                move.w  #0,DOCOUNT
                bra     IM_DONE


**************************
.DONEWCOM:      tst.w   IRQ_MODE
                bne     .IRQDONE

                lea     SEQIRQTAB(pc),a0
                moveq   #15,d7
.NEXTIRQ:       tst.l   (a0)
                beq.s   .NOTACTIVE

                move.w  4(a0),d0
                cmp.w   #1,d0
                blo.s   .IRQFLAGBOTH
                beq.s   .IRQFLAG12
                cmp.w   #3,d0
                blo.s   .IRQFLAG22
                beq.s   .IRQFLAG11
                cmp.w   #5,d0
                blo.s   .IRQENE1
                beq.s   .IRQENE2

.NOTACTIVE:     lea     16(a0),a0
                dbra    d7,.NEXTIRQ
                bra.s   .IRQDONE

.IRQFLAGBOTH:   move.l  PL_DATA1+96(pc),d0
                or.l    PL_DATA2+96(pc),d0
                bra.s   .FLAGTESTET
.IRQFLAG12:     cmpi.w  #2,PLAYERS
                bne.s   .NOTACTIVE
                move.l  PL_DATA1+96(pc),d0
                bra.s   .FLAGTESTET
.IRQFLAG22:     cmpi.w  #2,PLAYERS
                bne.s   .NOTACTIVE
                move.l  PL_DATA2+96(pc),d0
                bra.s   .FLAGTESTET
.IRQFLAG11:     cmpi.w  #1,PLAYERS
                bne.s   .NOTACTIVE
                move.l  PL_DATA1+96(pc),d0
.FLAGTESTET:    and.l   6(a0),d0
                cmp.l   10(a0),d0
                bne.s   .NOTACTIVE
                bra.s   .STARTIRQ

.IRQENE1:       tst.w   PL_DATA1+76
                beq.s   .NOTACTIVE
                move.w  PL_DATA1+26(pc),d0
                bra.s   .ENERGYTESTET
.IRQENE2:       tst.w   PL_DATA2+76
                beq.s   .NOTACTIVE
                move.w  PL_DATA2+26(pc),d0
.ENERGYTESTET:  cmp.w   6(a0),d0
                bge.s   .STARTIRQ
                bra.s   .NOTACTIVE

.STARTIRQ:      movea.l SEQSTACKPEK(pc),a1
                move.l  SEQPEK(pc),(a1)+
                move.l  a1,SEQSTACKPEK
                move.l  (a0),SEQPEK
                bra.s   .IRQDONE

.IRQDONE:


GETNEWCOMM:     movea.l SEQPEK(pc),a6
                move.l  a6,OLD_SEQPEK
                move.w  (a6)+,d0

                cmp.w   #"SF",d0        ; SET SPRITE AND GET NEW COMM
                bne.s   .NOT_SETFSP
                jsr     SETSPRITE(pc)
                move.l  a6,SEQPEK
                cmpa.l  OLD_SEQPEK(pc),a6
                beq     COMM_DONE
                bra.s   GETNEWCOMM

.NOT_SETFSP:
                cmp.w   #"->",d0        ; Goto
                bne.s   .NOT_GOTO
                move.w  (a6)+,d0
                bsr     GOTO_LABEL
                move.l  a6,SEQPEK
                bra.s   GETNEWCOMM

.NOT_GOTO:      cmp.w   #">>",d0        ; Gosub
                bne.s   .NOT_GOSUB
                movea.l SEQSTACKPEK(pc),a0
                move.w  (a6)+,d0
                move.l  a6,(a0)+
                move.l  a0,SEQSTACKPEK
                bsr     GOTO_LABEL
                move.l  a6,SEQPEK
                bra.s   GETNEWCOMM

.NOT_GOSUB:     cmp.w   #"::",d0        ; Label
                bne.s   .NOT_LABEL
                addq.l  #2,a6
                move.l  a6,SEQPEK
                bra.s   GETNEWCOMM

.NOT_LABEL:     cmp.w   #"F=",d0        ; Change flags
                bne.s   .NOT_CHGFLAGS
                move.w  (a6)+,d0
                move.w  (a6)+,d1
                move.l  (a6)+,d2
                move.l  a6,SEQPEK
                tst.w   d0
                beq.s   .BOTH
                cmp.w   #3,d0
                beq.s   .PL11
                cmpi.w  #2,PLAYERS
                bne.s   .FUCKIT
                cmp.w   #1,d0
                bne.s   .PL22
                lea     PL_DATA1(pc),a0
                bsr     FLAG_CHG
                bra.s   .FUCKIT
.PL22:          lea     PL_DATA2(pc),a0
                bsr     FLAG_CHG
                bra.s   .FUCKIT
.PL11:          cmpi.w  #1,PLAYERS
                bne.s   .FUCKIT
                lea     PL_DATA1(pc),a0
                bsr     FLAG_CHG
                bra.s   .FUCKIT
.BOTH:          lea     PL_DATA1(pc),a0
                bsr     FLAG_CHG
                lea     PL_DATA2(pc),a0
                bsr     FLAG_CHG
.FUCKIT:        bra     GETNEWCOMM

.NOT_CHGFLAGS:  cmp.w   #"F?",d0        ; Compare flags
                bne.s   .NOT_CMP_FLAG
                move.w  (a6)+,d0
                move.l  (a6)+,d1
                move.l  (a6)+,d2
                bsr     TESTFLAGS
                move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_CMP_FLAG:  cmp.w   #"E?",d0        ; Test Energy
                bne.s   .NOT_CMP_ENG
                move.w  (a6)+,d0
                move.w  (a6)+,d1
                move.l  a6,SEQPEK
                lea     PL_DATA1(pc),a0
                cmp.w   #1,d0
                beq.s   .DOITMAN
                cmpi.w  #1,PLAYERS
                beq.s   .SKIPSOME
                lea     PL_DATA2(pc),a0
.DOITMAN:       tst.w   76(a0)
                beq.s   .SKIPSOME
                cmp.w   26(a0),d1
                bge     GETNEWCOMM
.SKIPSOME:      bsr     SKIP_ONE
                move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_CMP_ENG:   cmp.w   #"P?",d0        ; Compare players
                bne.s   .NOT_CMP_PLAY
                move.w  (a6)+,d0
                cmp.w   PLAYERS(pc),d0
                beq.s   .LUCKYMAN
                bsr     SKIP_ONE
.LUCKYMAN:      move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_CMP_PLAY:  cmp.w   #"SP",d0        ; SET SPRITE
                bne.s   .NOT_SETSP
                jsr     SETSPRITE(pc)
                bra     COMM_DONE

.NOT_SETSP:     cmp.w   #"WS",d0        ; WAIT SPRITES
                bne.s   .NOT_WAITS
                move.w  #2,DOINGFLAG
                move.w  (a6)+,DOCOUNT
                bra     COMM_DONE

.NOT_WAITS:     cmp.w   #"WA",d0        ; WAIT TIME - W ANTAL VBLER
                bne.s   .NOT_WAITT
                move.w  #1,DOINGFLAG
                move.w  (a6)+,DOCOUNT
                bra     COMM_DONE

.NOT_WAITT:     cmp.w   #"LO",d0        ; EXECUTE LOOP
                bne.s   .NOT_LOOPEXE
                subq.l  #6,LOOPPEK
                movea.l LOOPPEK(pc),a0
                subq.w  #1,(a0)
                beq.s   .SLUTET
                movea.l 2(a0),a6
                addq.l  #6,LOOPPEK
.SLUTET:        move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_LOOPEXE:   cmp.w   #"SL",d0        ; SET LOOP - W ANTAL GGR
                bne.s   .NOT_SETLOOP
                movea.l LOOPPEK(pc),a0
                move.w  (a6)+,(a0)+
                move.l  a6,(a0)+
                move.l  a0,LOOPPEK
                move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_SETLOOP:   cmp.w   #"SE",d0        ; SET ENEMIES ON SCREEN
                bne.s   .NOT_SETENE
                move.w  (a6)+,MAX_ENEMY
                subi.w  #1,MAX_ENEMY
                bra     COMM_DONE

.NOT_SETENE:    cmp.w   #"IQ",d0        ; Start A Irq
                bne.s   .NOT_STARTIRQ
                move.w  (a6)+,d1
                move.w  (a6)+,d0
                move.w  (a6)+,d2
                move.l  (a6)+,d3
                move.l  (a6)+,d4
                move.l  a6,SEQPEK

                bsr     GOTO_LABEL
                add.w   d1,d1
                add.w   d1,d1
                lea     SEQIRQTAB(pc),a0
                adda.w  d1,a0
                move.l  a6,(a0)+
                move.w  d2,(a0)+
                move.l  d3,(a0)+
                move.l  d4,(a0)+
                movea.l SEQPEK(pc),a6
                bra     COMM_DONE

.NOT_STARTIRQ:  cmp.w   #"DQ",d0        ; Disable irq's
                bne.s   .NOT_DISABLE
                move.w  #-1,IRQ_MODE
                move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_DISABLE:   cmp.w   #"EQ",d0        ; Enable irq's
                bne.s   .NOT_ENABLE
                move.w  #0,IRQ_MODE
                move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_ENABLE:    cmp.w   #"RQ",d0        ; Remove a IRQ for all times.
                bne.s   .NOT_REMOVEIRQ
                move.w  (a6)+,d0
                move.l  a6,SEQPEK
                add.w   d0,d0
                add.w   d0,d0
                lea     SEQIRQTAB(pc),a0
                clr.l   0(a0,d0.w)
                bra     GETNEWCOMM

.NOT_REMOVEIRQ: cmp.w   #"SS",d0        ; SET ENEMIES SHOOT ON SCREEN
                bne.s   .NOT_SETSH
                move.w  (a6)+,MAX_ESHOOT
                cmpi.w  #ES/2,MAX_ESHOOT
                bls.s   .ESHOKI
                move.w  #ES/2,MAX_ESHOOT
.ESHOKI:        subq.w  #1,MAX_ESHOOT
                bra     COMM_DONE
.NOT_SETSH:     cmp.w   #"CL",d0        ; WAIT UNTIL ALL SPRITES GONE
                bne.s   .NOT_CLR
                move.w  #2,DOINGFLAG
                move.w  MAX_ENEMY(pc),d1
                add.w   #1,d1
                move.w  d1,DOCOUNT
                bra.s   COMM_DONE

.NOT_CLR:       cmp.w   #"PD",d0        ; Start a pod
                bne.s   .NOTBONUS
                bra     SETBONUS

.NOTBONUS:      cmp.w   #"WP",d0        ; Wait pods
                bne.s   .NOTWAITBONUS
                move.w  #3,DOINGFLAG
                move.w  (a6)+,DOCOUNT
                bra.s   COMM_DONE

.NOTWAITBONUS:  cmp.w   #"RT",d0        ; Return from IRQ or Gosub
                bne.s   .NOT_RETURN
                movea.l SEQSTACKPEK(pc),a0
                move.l  -(a0),SEQPEK
                move.l  a0,SEQSTACKPEK
                bra     GETNEWCOMM

.NOT_RETURN:    cmp.w   #"PS",d0        ; Decrease Stackpointer
                bne.s   .NOT_PUSH
                subq.l  #4,SEQSTACKPEK
                move.l  a6,SEQPEK
                bra     GETNEWCOMM

.NOT_PUSH:      cmp.w   #"CB",d0        ; Call CheatMode Box
                bne.s   .NOT_CHEATBOX
                movem.l d0-a6,-(a7)
                jsr     CHEATBOX
                movem.l (a7)+,d0-a6
                bra.s   COMM_DONE
.NOT_CHEATBOX:

COMM_DONE:      move.l  a6,SEQPEK

IM_DONE:        rts


                endpart
                >PART 'Sequenser Data'
SEQSTACK:       ds.l 16         ; Fungerar Upp†t (pekar p† n„sta oanv„nda..)
SEQSTACKPEK:    dc.l SEQSTACK
SEQIRQTAB:      ds.l 16*4       ; (L:Addr,W:Mode:L:Test1,L:Test2,W:Dummy)
IRQ_MODE:       dc.w 0
                endpart

                >PART 'Find a label'
* d0=label to find
* a6=seq pos (at a command!)
GOTO_LABEL:
.NEVERENDING:   cmp.w   2(a6),d0
                bne.s   .NOTYETS
                cmpi.w  #"::",(a6)
                bne.s   .NOTYETS
                lea     4(a6),a6
                rts
.NOTYETS:       bsr.s   SKIP_ONE
                bra.s   .NEVERENDING
                endpart
                >PART 'Skip a command'
SKIP_ONE:       movem.l d0-d2/a0,-(a7)
                move.w  (a6)+,d0
                bmi.s   .WARPTIME
                lea     SEQSIZETAB(pc),a0
.LOOKMORE:      move.w  (a0)+,d1
                move.w  (a0)+,d2
                cmp.w   d0,d1
                bne.s   .LOOKMORE
                tst.w   d2
                bmi.s   .SPECIAL
                adda.w  d2,a6
                bra.s   .HEJHEJ

.WARPTIME:      movea.l SEQSTART(pc),a6 * WARP
                bra.s   .HEJHEJ


.SPECIAL:       lea     6(a6),a6
.FINDNEG:       cmpi.w  #-1,(a6)+
                bne.s   .FINDNEG
*                bra.s   .HEJHEJ

.HEJHEJ:        movem.l (a7)+,d0-d2/a0
                rts
                endpart
                >PART 'Seq com tab lenght'
SEQSIZETAB:
                dc.w "SP",-1    ; Set a sprite
                dc.w "SF",-1    ; Set a sprite and do next command
                dc.w "WA",2     ; Wait
                dc.w "WS",2     ; Wait until a number of sprites (or less)
                dc.w "LO",0     ; Execute a loop
                dc.w "SL",2     ; Start of loop

                dc.w "::",2     ; Label
                dc.w "->",2     ; Goto
                dc.w ">>",2     ; Gosub
                dc.w "RT",0     ; Return
                dc.w "PS",0     ; Push from stack (1 address)
                dc.w "NO",0     ; NOP

                dc.w "F=",8     ; Set player Flags
                dc.w "F?",10    ; Test player Flags

                dc.w "P?",2     ; Test number of players
                dc.w "E?",4     ; Test against player energy

                dc.w "SE",2     ; Set Max amount of enemies
                dc.w "SS",2     ; Set Max amount of enemy bullets
                dc.w "CL",0     ; Wait until all sprites are gone
                dc.w "CB",0     ; Cheat box

                dc.w "IQ",14    ; Set up a IRQ
                dc.w "RQ",2     ; Remove a IRQ
                dc.w "EQ",0     ; Enable irq's
                dc.w "DQ",0     ; Disable irq's

                dc.w "PD",12    ; start a Pod
                dc.w "WP",2     ; Wait for a number of pods (or less)


                dc.w -1
                endpart

SETBONUS:       >PART 'Set a bonus'
                lea     POD_OUT_TAB(pc),a1
                moveq   #7,d0
.LETAPOD:       movea.l (a1)+,a0
                tst.w   (a0)
                bmi.s   .GOTYA
                dbra    d0,.LETAPOD
                movea.l OLD_SEQPEK(pc),a6
                bra     COMM_DONE

.GOTYA:
                clr.w   (a0)
                move.w  (a6)+,d0
                lea     PODTAB(pc),a1
                add.w   d0,d0
                add.w   d0,d0
                movea.l 0(a1,d0.w),a1
                move.l  a1,2(a0)
                move.w  (a6)+,d0
                lsl.w   #4,d0
                move.w  d0,6(a0)
                move.w  (a6)+,d0
                lsl.w   #4,d0
                move.w  d0,8(a0)
                move.w  (a6)+,10(a0)
                move.w  (a6)+,12(a0)
                move.w  (a6)+,14(a0)
                bra     COMM_DONE
                endpart
                >PART 'Test flags'
* d0=mode
* d1=and value
* d2=cmp value
TESTFLAGS:
                move.l  PL_DATA1+96(pc),d3
                move.l  PL_DATA2+96(pc),d4
                tst.w   d0
                beq.s   .YESYES
                cmp.w   #2,d0
                blo.s   .HOHO11
                beq.s   .HOHO12
                cmpi.w  #2,PLAYERS
                beq.s   .JŽTTEFEL
                move.l  d3,d4
                bra.s   .YESYES
.HOHO11:        cmpi.w  #1,PLAYERS
                beq.s   .JŽTTEFEL
                move.l  d3,d4
                bra.s   .YESYES
.HOHO12:        cmpi.w  #1,PLAYERS
                beq.s   .JŽTTEFEL
                move.l  d4,d3
                bra.s   .YESYES

.JŽTTEFEL:      bsr     SKIP_ONE
                rts

.YESYES:        or.l    d4,d3
                and.l   d1,d3
                cmp.l   d3,d2
                bne.s   .JŽTTEFEL
                rts
                endpart
                >PART 'Change flags'
* d1=mode2  (0=move,1=Or,2=And,3=Eor)
* d2=flag to use on player
* a0=address to player tab
FLAG_CHG:
                tst.w   d1
                beq.s   .FLAGMOVE
                cmp.w   #2,d1
                blo.s   .FLAGOR
                beq.s   .FLAGAND
                eor.l   d2,96(a0)
                rts
.FLAGMOVE:      move.l  d2,96(a0)
                rts
.FLAGOR:        or.l    d2,96(a0)
                rts
.FLAGAND:       and.l   d2,96(a0)
                rts
                endpart
                >PART 'SET A NORMAL SPRITE'
**********************************************
**      SET SPRITE
**      A6=SEQ ADDR+2
***********************************************
SETSPRITE:      move.w  (a6)+,d0        ; GET ENEMY ADDR
                lsl.w   #2,d0
                lea     ENEMYTAB(pc),a0
                movea.l 0(a0,d0.w),a0

                tst.w   (a0)
                beq     JOINED_SPRITE

                lea     SPRITETAB(pc),a1
                move.w  MAX_ENEMY(pc),d7
TEST_EM:        movea.l (a1)+,a2
                tst.w   (a2)
                bne     NOT_FREE

                move.w  (a6)+,d1
                move.w  (a6)+,d2

                moveq   #-1,d3
                move.l  a6,Q_ACRADDR
COUNT_ACR2:     cmpi.w  #-1,(a6)+
                beq.s   ALL_ACR2
                addq.w  #1,d3
                addq.w  #4,a6           ; +(push,speed)
                bra.s   COUNT_ACR2
ALL_ACR2:       move.w  d3,Q_ACRNR

                lea     AWTAB(pc),a4
                lsl.w   #3,d1
                lsl.w   #2,d2           ; SPEED *4
                lea     0(a4,d1.w),a4

                move.w  (a0),d0         ; If O-ANI, find first Object
                bpl.s   .NOT_OANI1
                neg.w   d0
                movea.l OANITAB_PEK(pc),a1
                add.w   d0,d0
                adda.w  0(a1,d0.w),a1
                move.w  (a1),d0

.NOT_OANI1:     lea     OBJECTTAB(pc),a1
                add.w   d0,d0
                add.w   d0,d0
                movea.l 0(a1,d0.w),a1

                move.l  (a4),d0         ; ATTACK WAVE + OR -
                move.l  4(a4),d1
                tst.w   d2
                bpl.s   SPEED_POSETI
                exg     d0,d1
                sub.l   #4,d0
SPEED_POSETI:   movea.l a2,a5
                move.w  #1,(a2)+        ; OFF/ON/ERASE ONLY
                move.w  #0,(a2)+        ; X
                move.w  #0,(a2)+        ; Y*160
                move.l  d0,(a2)+        ; AW START
                move.l  d1,(a2)+        ; AW END
                move.w  d2,(a2)+        ; AW ADD (SPEED)
                move.w  (a0),(a2)+      ; OBJ NR
                move.w  4(a0),(a2)+     ; SHOOTING RATE
                move.w  2(a0),(a2)+     ; SKOTT TYP
                move.l  (a1),(a2)+      ; POINTER ADDR BILD DATA
                move.w  #-1,(a2)+       ; VBL COUNT FOR ANI (-1 NO ANI)
                move.w  6(a0),(a2)+     ; TRŽFFAR TILL EXPLOSION
                move.w  #0,(a2)+        ; 0 NORMAL 1=VIT
                move.w  8(a0),(a2)+     ; CENTRERING X
                move.w  10(a0),d0       ; CENTRERING Y*160
                muls    #160,d0
                move.w  d0,(a2)+
                move.l  a5,(a2)+        ; SPRITE ADDR. DŽR SKADA HAMMNAR
                move.l  a1,(a2)+        ; ADDR TO OBJECT DATA
                move.w  38(a0),(a2)+    ; SKADA P PLAYER VID KROCK
                move.w  12(a0),(a2)+    ; SPRITE FLAGOR
                clr.l   (a2)+           ; **Reserved**
                clr.w   (a2)+           ; **Reserved**
                move.l  30(a0),(a2)+    ; 54  Score when shoot down
                move.l  34(a0),(a2)+    ;     Score continue

                move.l  14(a0),(a2)+    ; 62  OR P STATUS NŽR NERSKJUTEN
                move.l  18(a0),(a2)+    ; 66  NOT AND P STATUS NŽR DEN 'UNDKOMMER'
                move.l  22(a0),(a2)+    ; 70  STATUS F™R ATT KUNNA SKJUTA SPRITEN
                move.l  26(a0),(a2)+    ; 74  SelfDestruct

                clr.w   (a2)+           ; 78 **Reserved**
                move.w  #-1,(a2)+       ; 80 O-Ani nr
                clr.l   (a2)+           ; 82 O-Ani Pek
                clr.w   (a2)+           ; 86 O-Ani Count

                clr.l   (a2)+           ; 88 **Reserved**
                clr.l   (a2)+           ; 92 **Reserved**


                move.w  (a0),d0         ; O ANI fixer
                tst.w   d0
                bpl.s   .NOT_OANI2
                neg.w   d0
                move.w  d0,80-96(a2)
                movea.l OANITAB_PEK(pc),a3
                add.w   d0,d0
                adda.w  0(a3,d0.w),a3
                move.l  a3,82-96(a2)
                move.w  (a3)+,16-96(a2)
                move.w  (a3)+,32-96(a2)
                move.w  (a3)+,d0
                muls    #160,d0
                move.w  d0,34-96(a2)
                move.w  (a3)+,86-96(a2)
                move.w  (a3)+,46-96(a2)
                move.w  (a3)+,18-96(a2)
                move.w  (a3)+,20-96(a2)
.NOT_OANI2:

                move.w  Q_ACRNR(pc),d0
                move.w  d0,(a2)+        ; Nr of add curves
                movea.l Q_ACRADDR(pc),a3
                lea     ACRTAB(pc),a5
                tst.w   d3
                bmi.s   NOMOREACR2
LOOPACR2:       move.w  (a3)+,d2
                lsl.w   #3,d2
                movea.l 0(a5,d2.w),a4
                move.l  a4,(a2)+        ; ACR addr start
                adda.w  (a3)+,a4
                move.l  a4,(a2)+        ; ACR addr point
                move.l  4(a5,d2.w),(a2)+ ; ACR addr end
                move.w  (a3)+,d2
                lsl.w   #2,d2
                move.w  d2,(a2)+        ; ACR speed
                dbra    d0,LOOPACR2
NOMOREACR2:

                rts

NOT_FREE:       dbra    d7,TEST_EM
                movea.l SEQPEK(pc),a6   ; TAKE HIM LATER
                rts
                endpart
                >PART 'SET A JOINED SPRITE'
**********************************************
**      SET SPRITES (JOINED)
**      A0=ENEMY ADDR
**      A6=SEQ ADDR+4
***********************************************
JOINED_SPRITE:
                move.w  8(a0),d7        ; Check if starting is possible
                lea     SPRITETAB(pc),a1
                move.w  MAX_ENEMY(pc),d6
TESTEM:         movea.l (a1)+,a2
                tst.w   (a2)
                bne.s   NOTFREE
                subq.w  #1,d7
                beq.s   STARTHIM
NOTFREE:        dbra    d6,TESTEM
                bra     NOT_ENUFF


STARTHIM:       move.l  a2,Q_MAIN       ; a2 was the last one found
                move.w  (a6)+,d0        ; get aw
                lsl.w   #3,d0
                lea     AWTAB(pc),a1
                move.l  0(a1,d0.w),d1
                move.l  4(a1,d0.w),d2
                move.w  10(a0),d3
                lsl.w   #2,d3
                move.w  (a6)+,d0        ; get speed
                tst.w   d0
                bpl.s   NO_PROBBS
                exg     d1,d2
                neg.w   d3
NO_PROBBS:      lsl.w   #2,d0
                move.w  d0,Q_SPD
                move.l  d1,Q_AWB
                move.l  d2,Q_AWE
                ext.l   d3
                move.l  d3,Q_AWA

                moveq   #-1,d3
                move.l  a6,Q_ACRADDR
COUNT_ACR:      cmpi.w  #-1,(a6)+
                beq.s   ALL_ACR
                addq.w  #1,d3
                addq.w  #4,a6           ; +(push,speed)
                bra.s   COUNT_ACR
ALL_ACR:        move.w  d3,Q_ACRNR

                lea     22(a0),a1       ; a1=start of "join loop"

                move.w  8(a0),d7
                subq.w  #1,d7
                lea     SPRITETAB(pc),a2

LOOK_FOR_FREE:  movea.l (a2)+,a3
                tst.w   (a3)
                bne.s   LOOK_FOR_FREE

                movea.l a3,a5

                move.w  (a1),d6         ; D6=obj nr  (neg=OANI)
                bpl.s   .NOT_OANI3
                neg.w   d6
                movea.l OANITAB_PEK(pc),a4
                add.w   d6,d6
                adda.w  0(a4,d6.w),a4
                move.w  (a4),d6
.NOT_OANI3:
                move.w  d6,d0
                add.w   d0,d0
                add.w   d0,d0
                lea     OBJECTTAB(pc),a4 ; A4=Object Addr
                movea.l 0(a4,d0.w),a4

                move.w  #1,(a3)+        ; OFF/ON
                move.w  #0,(a3)+        ; X
                move.w  #0,(a3)+        ; Y*160
                move.l  Q_AWB(pc),(a3)+ ; AW START
                move.l  Q_AWE(pc),(a3)+ ; AW END
                move.w  Q_SPD(pc),(a3)+ ; AW ADD (SPEED)
                move.w  d6,(a3)+        ; OBJ NR
                move.w  #1,(a3)+        ; SHOOTING RATE
                move.w  #0,(a3)+        ; SKOTT TYP
                move.l  (a4),(a3)+      ; POINTER ADDR BILD DATA
                move.w  #-1,(a3)+       ; VBL COUNT FOR ANI (-1 NO ANI)
                move.w  #1,(a3)+        ; TRŽFFAR TILL EXPLOSION
                move.w  #0,(a3)+        ; 0 NORMAL 1=VIT
                move.w  2(a1),(a3)+     ; CENTRERING X
                move.w  4(a1),d0        ; CENTRERING Y*160
                muls    #160,d0
                move.w  d0,(a3)+
                move.l  Q_MAIN(pc),(a3)+ ; SPRITE ADDR. DŽR SKADA HAMMNAR
                move.l  a4,(a3)+        ; ADDR TO OBJECT DATA
                move.w  12(a0),(a3)+    ; Injury on playe if colidate
                move.w  6(a1),(a3)+     ; SPRITE FLAGOR

                clr.l   (a3)+           ; 48 **Reserved**
                clr.w   (a3)+           ; 52 **Reserved**

                clr.l   (a3)+           ; 54  Score
                clr.l   (a3)+           ; 58  Score
                move.l  8(a1),(a3)+     ; 62  OR P STATUS NŽR NERSKJUTEN
                move.l  12(a1),(a3)+    ; 66  NOT AND P STATUS OM DEN 'UNDKOMMER'
                move.l  16(a1),(a3)+    ; 70  STATUS F™R ATT KUNNA TRŽFFA
                move.l  20(a1),(a3)+    ; 74  SelfDestruct

                clr.w   (a3)+           ; 78 **Reserved**

                move.w  #-1,(a3)+       ; 80 O-Ani nr
                clr.l   (a3)+           ; 82 O-Ani Pek
                clr.w   (a3)+           ; 86 O-Ani Count

                clr.l   (a3)+           ; 88 **Reserved**
                clr.l   (a3)+           ; 92 **Reserved**


                move.w  (a1),d0         ; OANI fixer
                bpl.s   .NOT_OANI4
                move.l  a0,-(a7)
                neg.w   d0
                move.w  d0,80-96(a3)
                movea.l OANITAB_PEK(pc),a0
                add.w   d0,d0
                adda.w  0(a0,d0.w),a0
                move.l  a0,82-96(a3)
                move.w  (a0),16-96(a3)
                move.w  2(a0),32-96(a3)
                move.w  4(a0),d0
                muls    #160,d0
                move.w  d0,34-96(a3)
                move.w  6(a0),86-96(a3)
                move.w  8(a0),46-96(a3)
                move.w  10(a0),18-96(a3)
                move.w  12(a0),20-96(a3)
                movea.l (a7)+,a0
.NOT_OANI4:

                movem.l a4-a6,-(a7)
                move.w  Q_ACRNR(pc),d0
                move.w  d0,(a3)+        ; Nr of add curves
                movea.l Q_ACRADDR(pc),a6
                lea     ACRTAB(pc),a5
                tst.w   d3
                bmi.s   NOMOREACR
LOOPACR:        move.w  (a6)+,d2
                lsl.w   #3,d2
                movea.l 0(a5,d2.w),a4
                move.l  a4,(a3)+        ; ACR addr start
                adda.w  (a6)+,a4
                move.l  a4,(a3)+        ; ACR addr point
                move.l  4(a5,d2.w),(a3)+ ; ACR addr end
                move.w  (a6)+,d2
                lsl.w   #2,d2
                move.w  d2,(a3)+        ; ACR speed
                dbra    d0,LOOPACR

NOMOREACR:      movem.l (a7)+,a4-a6

                lea     24(a1),a1       ; Next Join

                move.l  Q_AWA(pc),d0
                add.l   d0,Q_AWB        ; FLYTTA AW START ADDR (MASKAR)
                dbra    d7,LOOK_FOR_FREE

                movea.l a5,a3
                move.w  2(a0),20(a3)    ; SKOTT SKJUTNINGS TYP
                move.w  4(a0),18(a3)    ; SHOOTING RATE
                move.w  6(a0),28(a3)    ; TRŽFFAR TILL EXPLO.
                move.l  14(a0),54(a3)   ; Score if shoot down
                move.l  18(a0),58(a3)

                rts
NOT_ENUFF:      movea.l SEQPEK(pc),a6   ; TAKE HIM LATER
                rts
                endpart
                >PART 'WAIT FOR SPRITES'
**********************************************
**      SPRITE WAIT
***********************************************
SPRITEWAIT:     lea     SPRITETAB(pc),a1
                moveq   #0,d0
                move.w  MAX_ENEMY(pc),d7
TEST_EM3:       movea.l (a1)+,a2
                tst.w   (a2)
                bne.s   NOT_EMPTY
                addq.w  #1,d0
NOT_EMPTY:      dbra    d7,TEST_EM3
                cmp.w   DOCOUNT(pc),d0
                blo.s   NOT_ENUFF2
                move.w  #0,DOINGFLAG
                move.w  #0,DOCOUNT
NOT_ENUFF2:     rts
                endpart
                >PART 'Wait for Pods'
PODWAIT:        lea     POD_OUT_TAB(pc),a0
                moveq   #0,d0
                moveq   #7,d1
.URRK:          movea.l (a0)+,a1
                tst.w   (a1)
                bne.s   .MUPPP
                addq.w  #1,d0
.MUPPP:         dbra    d1,.URRK
                cmp.w   DOCOUNT(pc),d0
                bhi.s   .FITTOR
                clr.w   DOCOUNT
                clr.w   DOINGFLAG
.FITTOR:        rts
                endpart

SEQ:            >PART 'ENEMY MOVING CODE'

                dc.w "PD",0,50,-15,16,22,0
                dc.w "F=",0,0,0,0
*                dc.w "IQ",0,"S2",0,$0000,$0001,$0000,$0001

                dc.w "::","BE"

                dc.w "P?",2
                dc.w "->","HO"

                dc.w "F?",0,0,1,0,1
                dc.w "->","SK"

                dc.w ">>","S3"
                dc.w ">>","S1"

                dc.w "SL",7     ; Trekanter med skalbaggar
                dc.w "WS",3
                dc.w "SF",5,10,1,3,0,3,-1
                dc.w "SF",5,10,1,3,132,3,-1
                dc.w "SP",5,10,1,3,264,3,-1
                dc.w "WA",50
                dc.w "LO"


                dc.w "SE",20
                dc.w "SS",20    ; Lot of fast easy to kill ships
                dc.w "SE",35
                dc.w "SL",12
                dc.w "SP",14,14,1,-1
                dc.w "WA",6
                dc.w "LO"

                dc.w "::","SK"

                dc.w "PD",1,-15,-15,16,16,10
                dc.w "PD",1,319+15,-15,-16,16,10
                dc.w "PD",2,319+15,80,-16,0,0
                dc.w "PD",3,-15,80,16,0,0
                dc.w "WP",2

                dc.w "E?",1,28
                dc.w "->","HO"

                dc.w "CL"
                dc.w "SS",20    ; Sl„dor
                dc.w "SE",10
                dc.w "SP",0,17,5,-1
                dc.w "WA",20
                dc.w "SP",0,15,4,-1
                dc.w "WA",12
                dc.w "SP",0,18,6,-1
                dc.w "WA",14
                dc.w "SP",0,17,5,-1
                dc.w "WA",8
                dc.w "SP",0,16,3,-1
                dc.w "WA",13
                dc.w "SP",0,19,5,-1
                dc.w "WA",9
                dc.w "SP",0,15,5,-1
                dc.w "WA",15
                dc.w "SP",0,18,6,-1

                dc.w "WS",4
                dc.w 'SP',3,0,1,-1 ; Tagg
                dc.w "CL"

                dc.w "WS",6
                dc.w "SS",20    ; Kr„ft som gardiner och baggar som st”r
                dc.w "SP",5,10,2,-1
                dc.w "SP",5,11,2,-1
                dc.w "SP",5,12,2,-1
                dc.w "SP",5,10,1,-1
                dc.w "SP",5,11,1,-1
                dc.w "SP",5,12,1,-1
                dc.w "SL",9
                dc.w "SP",6,13,1,-1
                dc.w "WA",10
                dc.w "SP",6,14,1,-1
                dc.w "WA",9
                dc.w "LO"
                dc.w "WS",4
                dc.w "SP",3,0,1,-1 ; Tagg

                dc.w "::","HO"

                dc.w "CL"
                dc.w "SS",5     ; Skalbaggar i cirklar run skalbagge
                dc.w "SE",33
                dc.w "SL",3
                dc.w "SF",5,11,1,-1
                dc.w "SF",13,11,1,4,0,2,-1
                dc.w "SF",13,11,1,4,40,2,-1
                dc.w "SF",13,11,1,4,80,2,-1
                dc.w "SF",13,11,1,4,120,2,-1
                dc.w "SF",13,11,1,4,160,2,-1
                dc.w "SF",13,11,1,4,200,2,-1
                dc.w "SF",13,11,1,4,240,2,-1
                dc.w "SF",13,11,1,4,280,2,-1
                dc.w "SF",13,11,1,4,320,2,-1
                dc.w "SP",13,11,1,4,360,2,-1
                dc.w "WA",90
                dc.w "LO"

                dc.w "CL"
                dc.w "SS",5
                dc.w "SE",28
                dc.w "SF",4,12,1,2,0,-3,-1 ; Lot of snurring med Blurr, Droid
                dc.w "SF",4,12,1,2,100,-3,-1
                dc.w "SF",4,12,1,2,200,-3,-1
                dc.w "SF",4,12,1,2,300,-3,-1
                dc.w "SF",10,12,1,6,0,1,0,0,4,-1
                dc.w "SF",10,12,1,6,0,1,0,132,4,-1
                dc.w "SF",10,12,1,6,0,1,0,264,4,-1
                dc.w "SF",10,12,1,6,48,1,0,0,4,-1
                dc.w "SF",10,12,1,6,48,1,0,132,4,-1
                dc.w "SF",10,12,1,6,48,1,0,264,4,-1
                dc.w "SF",10,12,1,6,100,1,0,0,4,-1
                dc.w "SF",10,12,1,6,100,1,0,132,4,-1
                dc.w "SF",10,12,1,6,100,1,0,264,4,-1
                dc.w "SF",10,12,1,6,148,1,0,0,4,-1
                dc.w "SF",10,12,1,6,148,1,0,132,4,-1
                dc.w "SF",10,12,1,6,148,1,0,264,4,-1
                dc.w "SF",10,12,1,6,200,1,0,0,4,-1
                dc.w "SF",10,12,1,6,200,1,0,132,4,-1
                dc.w "SF",10,12,1,6,200,1,0,264,4,-1
                dc.w "SF",10,12,1,6,248,1,0,0,4,-1
                dc.w "SF",10,12,1,6,248,1,0,132,4,-1
                dc.w "SF",10,12,1,6,248,1,0,264,4,-1
                dc.w "SF",10,12,1,6,300,1,0,0,4,-1
                dc.w "SF",10,12,1,6,300,1,0,132,4,-1
                dc.w "SF",10,12,1,6,300,1,0,264,4,-1
                dc.w "SF",10,12,1,6,348,1,0,0,4,-1
                dc.w "SF",10,12,1,6,348,1,0,132,4,-1
                dc.w "SF",10,12,1,6,348,1,0,264,4,-1


                dc.w "CL"
                dc.w "SS",10    ; Hornbl„ckisar
                dc.w "SE",15
                dc.w "WS",4
                dc.w "SP",6,12,-1,-1
                dc.w "WA",15
                dc.w "SP",6,12,-1,-1
                dc.w "WA",15
                dc.w "SP",6,12,-1,-1
                dc.w "WA",15
                dc.w "SP",6,12,-1,-1
                dc.w "SP",9,15,-2,-1
                dc.w "WA",70
                dc.w "SP",9,18,-2,-1
                dc.w "WA",90
                dc.w "SP",9,16,-2,-1
                dc.w "WA",120
                dc.w "SP",9,19,-2,-1
                dc.w "WA",70
                dc.w "SP",9,15,-2,-1
                dc.w "WA",100
                dc.w "SP",9,17,-2,-1
                dc.w "WA",30
                dc.w "SP",9,18,-2,-1
                dc.w "WA",90

                dc.w "CL"
                dc.w "SS",10
                dc.w "SE",22    ; Blurrar som v„ller ner uppifr†n.
                dc.w "SL",9
                dc.w "SP",4,2,1,-1
                dc.w "SP",4,3,1,-1
                dc.w "SP",4,4,1,-1
                dc.w "SP",4,5,1,-1
                dc.w "WA",20
                dc.w "LO"

*                dc.w "F=",0,2,$FFFF,$FFFE
                dc.w "WS",20
                dc.w "SF",2,1,1,4,0,2,-1 ; Maskar snurrar in
                dc.w "SF",2,1,1,4,100,2,-1
                dc.w "SF",2,1,1,4,200,2,-1
                dc.w "SP",2,1,1,4,300,2,-1

                dc.w "WS",12
                dc.w 'SP',3,0,1,-1 ; Tagg
                dc.w "CL"
*                dc.w "F=",0,1,0,1

                dc.w "SS",20    ; Lot of fast easy to kill ships
                dc.w "SE",35
                dc.w "SL",12
                dc.w "SF",7,6,1,-1
                dc.w "SF",7,7,1,-1
                dc.w "SF",7,8,1,-1
                dc.w "SF",7,9,1,-1
                dc.w "WA",6
                dc.w "LO"

                dc.w "CL"
                dc.w "SS",15    ; Lot of small ships
                dc.w "SE",35
                dc.w "SL",2
                dc.w "SP",11,1,1,-1
                dc.w "SP",11,2,1,-1
                dc.w "SP",11,3,1,-1
                dc.w "SP",11,4,1,-1
                dc.w "SP",11,5,1,-1
                dc.w "SP",11,10,1,-1
                dc.w "SP",11,11,1,-1
                dc.w "SP",11,12,1,-1
                dc.w "WA",3
                dc.w "SP",12,1,1,-1
                dc.w "SP",12,2,1,-1
                dc.w "SP",12,3,1,-1
                dc.w "SP",12,4,1,-1
                dc.w "SP",12,5,1,-1
                dc.w "SP",12,10,1,-1
                dc.w "SP",12,11,1,-1
                dc.w "SP",12,12,1,-1
                dc.w "WA",3
                dc.w "SP",13,1,1,-1
                dc.w "SP",13,2,1,-1
                dc.w "SP",13,3,1,-1
                dc.w "SP",13,4,1,-1
                dc.w "SP",13,5,1,-1
                dc.w "SP",13,10,1,-1
                dc.w "SP",13,11,1,-1
                dc.w "SP",13,12,1,-1
                dc.w "WA",2
                dc.w "LO"

                dc.w "CL"

                dc.w "->","BE"


                dc.w "::","S1"

                dc.w "SS",10    ; Maskar snabbt flyger f”rbi
                dc.w "SE",25
                dc.w 'SL',6
                dc.w "SP",2,1,1,-1
                dc.w "WA",30
                dc.w "LO"
                dc.w "RT"

                dc.w "::","S2"

                dc.w "DQ"
                dc.w "RQ",0
                dc.w "CB"
                dc.w "EQ"
                dc.w "RT"

                dc.w "::","S3"

                dc.w "SS",15    ; O-Ani Test
                dc.w "SE",25
                dc.w 'SL',15
                dc.w "SP",15,1,1,-1
                dc.w "WA",15
                dc.w "LO"
                dc.w "RT"


                dc.w -1

                endpart
****************************************************************

                >PART 'DRAW BACKGROUND'
*****************************************************
**      DRAW BACKGROUND
*****************************************************
DRAW_BACK:      not.w   BACKFLAG
*               BEQ.S   NENENEJ
                addi.l  #160,SCROLLADDR
                movea.l BACKGROUNDADDR(pc),a0
                lea     9600(a0),a1
                cmpa.l  SCROLLADDR(pc),a1
                bne.s   NENENEJ
                move.l  a0,SCROLLADDR
NENENEJ:

                move.l  a7,SAVEAA7
                movea.l SCREEN(pc),a3
                suba.l  #28800-((CLIP_Y+2)*160),a3
                lea     19200(a3),a4
                lea     28800(a3),a5
                lea     9600(a3),a3
                movea.l SCROLLADDR(pc),a6
                move.w  #23,d7
TOTAL_ERA:
                rept 10
                movem.l (a6)+,d0-d6/a0-a2
                movem.l d0-d6/a0-a2,-(a3)
                movem.l d0-d6/a0-a2,-(a4)
                movem.l d0-d6/a0-a2,-(a5)
                endr
                dbra    d7,TOTAL_ERA
                movea.l SAVEAA7(pc),a7
                rts
SAVEAA7:        dc.l 0
BACKFLAG:       dc.w 0
                endpart

                >PART 'MOVE THE BLOCKS'
**********************************************
**      MOVE BLOCKS
***********************************************
MOVE_BLOCK:     move.w  BLOCKCOUNT(pc),d0
                add.w   #2,d0
TEST_AGAIN:     cmp.w   #16,d0
                blo.s   ANOTHER_DAY
                sub.w   #16,d0
                move.w  d0,BLOCKCOUNT

                lea     _ADD_TAB(pc),a1
                movea.l BLOCKPOS(pc),a0
.YEAH:          move.b  (a0),d1
                move.w  d1,d0
                ext.w   d0
                add.w   d0,d0
                move.w  0(a1,d0.w),d0
                adda.w  d0,a0
                tst.b   d1
                bpl.s   .YEAH
                cmp.b   #$FF,d1
                bne.s   .YEAH

                cmpi.b  #-2,(a0)
                bne.s   .NOTWRAPA
                movea.l BLOCKSTART(pc),a0
.NOTWRAPA:      move.l  a0,BLOCKPOS
                rts

ANOTHER_DAY:    move.w  d0,BLOCKCOUNT
                rts

                dc.w 2
                dc.w 6
                dc.w 2
_ADD_TAB:       dc.w 6,10,8,12
                dc.w 8,12,10,14

                endpart

                >PART 'DRAW BLOCKS ON SCREEN'
***********************************************
**      DRAW BLOCKS
***********************************************
DRAW_BLOCKS:
                movem.l d0-a6,-(a7)

                movea.l SCREEN(pc),a0   ; a0=SCREEN
                movea.l BLOCKPOS(pc),a1 ; a1=SEQUENS

                lea     _COMMANDTAB2(pc),a2 ; a2=HoppTab
                movea.l F_BLOCK(pc),a3
                movea.l N_BLOCK(pc),a4


                lea     ((CLIP_Y-14)*160)(a0),a0 ;STŽLL IN CLIP
                move.w  BLOCKCOUNT(pc),d6
                moveq   #15,d7
                sub.w   d6,d7           ; d7=Hight to Draw
                mulu    #160,d6
                lea     0(a0,d6.w),a0
                moveq   #11,d6          ; D6=Lines left

NEXTBLOCK:      move.b  (a1),d0
                ext.w   d0
*                cmp.w   #7,d0           ; Debug Test
*                bgt     Wrong           ; Debug Test
*                cmp.w   #-3,d0          ; Debug Test
*                blt     Wrong           ; Debug Test
                add.w   d0,d0
                add.w   d0,d0
                movea.l 0(a2,d0.w),a6
                jmp     (a6)

FILLUP:         addq.l  #2,a1
                bra.s   NEXTBLOCK
END_OF_MAP:     movea.l BLOCKSTART(pc),a1
                bra.s   NEXTBLOCK
END_OF_LINE:    lea     _COMMANDTAB1(pc),a2
                lea     -16*160(a0),a0
                addq.l  #2,a1
                dbra    d6,NEXTBLOCK
                movem.l (a7)+,d0-a6
                rts


                dc.l FILLUP     ;  -3
                dc.l END_OF_MAP ;  -2
                dc.l END_OF_LINE ; -1
_COMMANDTAB1:   dc.l Normal     ;   0
                dc.l Wrong      ;   1
                dc.l Animat     ;   2
                dc.l Wrong      ;   3
                dc.l Wrong      ;   4
                dc.l Wrong      ;   5
                dc.l Wrong      ;   6
                dc.l Wrong      ;   7
*                dc.l Nothing

                dc.l FILLUP     ;  -3
                dc.l END_OF_MAP ;  -2
                dc.l END_OF_LINE ; -1
_COMMANDTAB2:   dc.l NORMAL_CUT ;   0
                dc.l Wrong      ;   1
                dc.l Animat_Cut ;   2
                dc.l Wrong      ;   3
                dc.l Wrong      ;   4
                dc.l Wrong      ;   5
                dc.l Wrong      ;   6
                dc.l Wrong      ;   7
*                dc.l Nothing

Nothing:        addq.l  #8,a1
                bra     NEXTBLOCK
                dc.b "Strange Block combination, not yet implanted"
Wrong:          illegal

*****************************

Normal:         move.w  (a1)+,d2
                move.w  (a1)+,d0        ; offset screen
                move.w  (a1)+,d1        ; offset block
                cmpi.b  #1,d2
                beq     .FILLED_B
                blt.s   .FAST_B
                illegal



.FAST_B:        lea     0(a0,d0.w),a5   ; DRAW - FAST
                lea     0(a3,d1.w),a6
                move.l  (a6)+,(a5)
                move.l  (a6)+,4(a5)
                move.l  (a6)+,d0
                move.l  (a6)+,d1
                move.l  d0,160(a5)
                move.l  d1,164(a5)
                move.l  d0,320(a5)
                move.l  d1,324(a5)
                move.l  d0,480(a5)
                move.l  d1,484(a5)
                move.l  d0,640(a5)
                move.l  d1,644(a5)
                move.l  d0,800(a5)
                move.l  d1,804(a5)
                move.l  d0,960(a5)
                move.l  d1,964(a5)
                move.l  d0,1120(a5)
                move.l  d1,1124(a5)
                move.l  d0,1280(a5)
                move.l  d1,1284(a5)
                move.l  d0,1440(a5)
                move.l  d1,1444(a5)
                move.l  d0,1600(a5)
                move.l  d1,1604(a5)
                move.l  d0,1760(a5)
                move.l  d1,1764(a5)
                move.l  d0,1920(a5)
                move.l  d1,1924(a5)
                move.l  d0,2080(a5)
                move.l  d1,2084(a5)
                move.l  d0,2240(a5)
                move.l  d1,2244(a5)
                move.l  (a6)+,2400(a5)
                move.l  (a6)+,2404(a5)
                bra     NEXTBLOCK

.FILLED_B:      lea     0(a0,d0.w),a5   ; DRAW - NORMAL
                lea     0(a4,d1.w),a6
                move.l  (a6)+,(a5)
                move.l  (a6)+,4(a5)
                move.l  (a6)+,160(a5)
                move.l  (a6)+,164(a5)
                move.l  (a6)+,320(a5)
                move.l  (a6)+,324(a5)
                move.l  (a6)+,480(a5)
                move.l  (a6)+,484(a5)
                move.l  (a6)+,640(a5)
                move.l  (a6)+,644(a5)
                move.l  (a6)+,800(a5)
                move.l  (a6)+,804(a5)
                move.l  (a6)+,960(a5)
                move.l  (a6)+,964(a5)
                move.l  (a6)+,1120(a5)
                move.l  (a6)+,1124(a5)
                move.l  (a6)+,1280(a5)
                move.l  (a6)+,1284(a5)
                move.l  (a6)+,1440(a5)
                move.l  (a6)+,1444(a5)
                move.l  (a6)+,1600(a5)
                move.l  (a6)+,1604(a5)
                move.l  (a6)+,1760(a5)
                move.l  (a6)+,1764(a5)
                move.l  (a6)+,1920(a5)
                move.l  (a6)+,1924(a5)
                move.l  (a6)+,2080(a5)
                move.l  (a6)+,2084(a5)
                move.l  (a6)+,2240(a5)
                move.l  (a6)+,2244(a5)
                move.l  (a6)+,2400(a5)
                move.l  (a6)+,2404(a5)
                bra     NEXTBLOCK

********************************
Animat:         move.l  (a1)+,d0        ; skip 2, h„mta offset X
                movea.l _Blk_AnimTab(pc),a5
                move.w  (a1)+,d2        ; Seq Offset
                add.w   (a1),d2         ; Seq Pos
                addq.w  #4,(a1)+        ; Add counter
                adda.w  d2,a5
                move.w  (a5)+,d2        ; H„mta blocktyp
                bpl.s   .NotWrapAnim    ; Oops, slut p† block
                suba.w  -2(a1),a5       ; Minska med counter (hamnar fel)
                clr.w   -2(a1)          ; Nolla counter
                move.l  (a5)+,d2        ; skip 2, h„mta blocktyp
.NotWrapAnim:   move.w  (a5)+,d1
                cmpi.b  #1,d2
                beq     .FILLED_B
                blt     .FAST_B
                illegal
****************************************
Animat_Cut:     move.l  (a1)+,d0        ; skip 2, h„mta offset X
                movea.l _Blk_AnimTab(pc),a5
                move.w  (a1)+,d2        ; Seq Offset
                add.w   (a1),d2         ; Seq Pos
                addq.w  #4,(a1)+        ; Add counter
                adda.w  d2,a5
                move.w  (a5)+,d2        ; H„mta blocktyp
                bpl.s   .NotWrapAnim2   ; Oops, slut p† block
                suba.w  -2(a1),a5       ; Minska med counter (hamnar fel)
                clr.w   -2(a1)          ; Nolla counter
                move.l  (a5)+,d2        ; skip 2, h„mta blocktyp
.NotWrapAnim2:  move.w  (a5)+,d1
                cmpi.b  #1,d2
                beq.s   .FILLED_C_B
                blt.s   .FAST_C_B
                illegal

*****************************

NORMAL_CUT:     addq.w  #2,a1
                move.w  (a1)+,d0        ; offset screen
                move.w  (a1)+,d1        ; offset block

                cmpi.b  #1,-5(a1)
                beq.s   .FILLED_C_B
                blt.s   .FAST_C_B
                bra     NEXTBLOCK
                illegal

.FAST_C_B:      lea     0(a0,d0.w),a5   ; DRAW CUT - FAST
                lea     0(a3,d1.w),a6
                move.w  d7,d0
                move.w  #156,d1
                move.l  (a6)+,(a5)+
                move.l  (a6)+,(a5)
                dbra    d0,.GNUS1
                bra     NEXTBLOCK
.GNUS1:         moveq   #13,d2
                move.l  (a6)+,d3
                move.l  (a6)+,d4
.GNUS_L:        adda.w  d1,a5
                move.l  d3,(a5)+
                move.l  d4,(a5)
                dbra    d0,.GNUS2
                bra     NEXTBLOCK
.GNUS2:         dbra    d2,.GNUS_L
                adda.w  d1,a5
                move.l  (a6)+,(a5)+
                move.l  (a6)+,(a5)
                bra     NEXTBLOCK


.FILLED_C_B:    lea     0(a0,d0.w),a5   ; DRAW CUT - FILLED
                lea     0(a4,d1.w),a6
                move.w  d7,d0
                move.w  #156,d1
.GNUA_L:        move.l  (a6)+,(a5)+
                move.l  (a6)+,(a5)
                adda.w  d1,a5
                dbra    d0,.GNUA_L
                bra     NEXTBLOCK

                endpart

LOWER_ENERGY:   >PART 'LowerEnergy'
***********************************************
**      REDUCE ENERGY
***********************************************
                move.w  26(a6),d0
                bpl.s   NOT_NEG
                move.w  #0,26(a6)
                moveq   #0,d0
NOT_NEG:        cmp.w   24(a6),d0
                beq.s   SKIP_PL
                bhi.s   ADD_PL
                subq.w  #1,24(a6)
                bhi.s   DRAWE_PL
                clr.w   24(a6)
                clr.w   76(a6)          ; D E A D

                bsr     INIT_PLY_EXPLO

*                tst.w   PL_DATA1+76
*                bne.s   SKIP_PL
*                tst.w   PL_DATA2+76
*                bne.s   SKIP_PL

*                bra     START_GAME      ; D E A D
                bra.s   SKIP_PL

ADD_PL:         addi.w  #1,24(a6)
                cmpi.w  #38,24(a6)
                bls.s   DRAWE_PL
                move.w  #38,26(a6)
                move.w  #38,24(a6)

DRAWE_PL:
                bsr.s   DRAWENERGY

SKIP_PL:        rts
                endpart
DRAWENERGY:     >PART 'Draw Player Energy'
***********************************************
**      DRAW ENERGY PLAYER
***********************************************
                movem.l d0-a2,-(a7)
                movea.l SCREEN1(pc),a0
                movea.l SCREEN2(pc),a1
                move.w  70(a6),d0
                adda.w  d0,a0
                adda.w  d0,a1
                movea.l 72(a6),a2

                move.w  (a2)+,d0
                move.w  (a2)+,d1
                move.w  (a2)+,d2
                moveq   #38,d7
                sub.w   24(a6),d7
                muls    #6,d7
                adda.l  d7,a2
                move.w  (a2)+,d3
                move.w  (a2)+,d4
                move.w  (a2)+,d5
                moveq   #9,d7

DRAWIT:         and.w   d0,(a0)
                and.w   d0,(a1)
                or.w    d3,(a0)
                or.w    d3,(a1)
                and.w   d1,8(a0)
                and.w   d1,8(a1)
                or.w    d4,8(a0)
                or.w    d4,8(a1)
                and.w   d2,16(a0)
                and.w   d2,16(a1)
                or.w    d5,16(a0)
                or.w    d5,16(a1)
                lea     160(a0),a0
                lea     160(a1),a1
                dbra    d7,DRAWIT

                movem.l (a7)+,d0-a2
                rts

                endpart
DRAWALLENERGY:  >PART 'Draw All Energy'
***********************************************
**      DRAW ALL ENERGY
***********************************************
                lea     PL_DATA1(pc),a6
                bsr.s   DRAWENERGY
                lea     PL_DATA2(pc),a6
                bsr.s   DRAWENERGY
                rts
                endpart

                >PART 'TEST IF PLAYER IS HIT'
***********************************************
**      TEST ENEMY SHOOTS TO PLAYER
***********************************************
TES_ESHOOT_PL:
                move.w  20(a6),d0
                move.w  d0,d2
                move.w  22(a6),d1
                move.w  d1,d3
                add.w   28(a6),d0
                add.w   32(a6),d2
                add.w   30(a6),d1
                add.w   34(a6),d3
                bsr.s   ESHOOT_TEST
                tst.w   d7
                bmi.s   PUSTA_UT
                move.w  #0,(a0)
                subq.w  #1,26(a6)
PUSTA_UT:       rts
                endpart
                >PART 'TEST AGAINS ENEMY SHOOTS'
***********************************************
**      TEST ENEMY SHOOTS D0=X1,D1=Y1,D2=X2,D3=Y2
***********************************************
ESHOOT_TEST:    lea     ESHOOT(pc),a0
                moveq   #ES/2-1,d7
TESET:          cmpi.w  #1,(a0)
                bne.s   NEJ_NEJ_NEJ

                move.w  6*ES(a0),d4     ; XX1>X2=SKIP
                cmp.w   d2,d4
                bgt.s   NEJ_NEJ_NEJ

                move.w  6*ES(a0),d4     ; XX2<X1=SKIP
                addq.w  #7,d4
                cmp.w   d0,d4
                blt.s   NEJ_NEJ_NEJ

                move.w  7*ES(a0),d4     ; YY1>Y2=SKIP
                cmp.w   d3,d4
                bgt.s   NEJ_NEJ_NEJ

                move.w  7*ES(a0),d4     ; YY2<Y1=SKIP
                addq.w  #7,d4
                cmp.w   d1,d4
                blt.s   NEJ_NEJ_NEJ

                rts
NEJ_NEJ_NEJ:    addq.w  #2,a0
                dbra    d7,TESET
                rts
                endpart

                >PART 'DRAW ENEMY SHOOTS'
***********************************************
**      DRAW ENEMY SHOOTS
***********************************************
DRAW_ESHOOTS:   lea     ESHOOT(pc),a2
                movea.l SCREEN(pc),a3
                movea.l ESHOOTADDR1(pc),a4
                moveq   #ES/2-1,d7
ESHOOT_ACTIVE:  cmpi.w  #1,(a2)
                bne.s   NOT_DIS_ONE
                move.w  1*ES(a2),d0
                move.w  2*ES(a2),d1
                asr.w   #4,d0
                move.w  d0,d5
                move.w  d0,6*ES(a2)     ; COLISION
                asr.w   #4,d1
                move.w  d1,d6
                muls    #160,d1
                move.w  d1,7*ES(a2)     ; COLISION
                lea     0(a3,d1.w),a0
                tst.w   d5              ; X<0
                bmi.s   LEFTOUT
                move.w  d0,d1
                and.w   #$000F,d0
                sub.w   d0,d1
                lsr.w   #1,d1
                adda.w  d1,a0
MEETUP:         mulu    #168,d0
                lea     0(a4,d0.w),a1
                exg     a6,d7
                moveq   #6,d7
                sub.w   #CLIP_Y-5,d6
                bmi.s   DONT_CLIP
                sub.w   d6,d7
DONT_CLIP:
                cmp.w   #319-16,d5      ; CLIP X>304
                ble.s   NOCLIPX
                bsr     SPRITA32CLIP
                bra.s   JOINAGAIN
NOCLIPX:        tst.w   d5
                bge.s   NOCLIPX2
                bsr     SPRITA32CLIP2
                bra.s   JOINAGAIN
NOCLIPX2:       bsr     SPRITA32
JOINAGAIN:      exg     a6,d7

NOT_DIS_ONE:    addq.w  #2,a2
                dbra    d7,ESHOOT_ACTIVE
                rts
LEFTOUT:        subq.l  #8,a0
                and.w   #$000F,d0
                bra.s   MEETUP
                endpart
                >PART 'MOVE ENEMY SHOOTS'
***********************************************
**      MOVE ENEMY SHOOTS
***********************************************
MOVE_ESHOOT:
                moveq   #ES/2-1,d2
                lea     ESHOOT(pc),a0
SCREW_THEM:     cmpi.w  #1,(a0)
                bne.s   NOT_IN_USE
                move.w  4*ES(a0),d1
                add.w   d1,1*ES(a0)
                move.w  5*ES(a0),d1
                add.w   d1,2*ES(a0)

                move.w  1*ES(a0),d1
                asr.w   #4,d1
                cmp.w   #-15,d1
                ble.s   PASTED
                cmp.w   #319,d1
                bge.s   PASTED

                move.w  2*ES(a0),d1
                asr.w   #4,d1
                cmp.w   #-8,d1
                ble.s   PASTED
                cmp.w   #CLIP_Y,d1
                blt.s   NOT_IN_USE
PASTED:         move.w  #0,0*ES(a0)
NOT_IN_USE:     addq.w  #2,a0
                dbra    d2,SCREW_THEM
                rts
                endpart
                >PART 'A NEW ENEMY SHOOT ??'
***********************************************
**      SHALL A NEW ENEMY SHOOT BE RELEASED
***********************************************
NEW_ESHOOT:     tst.w   PL_DATA1+76
                bne.s   .OKEY
                tst.w   PL_DATA2+76
                beq.s   ALL_DONES

.OKEY:          move.w  DELAY(pc),d0
                subq.w  #1,d0
                bpl.s   NOSKUMPAROUND
                move.w  #3,d0
NOSKUMPAROUND:  move.w  d0,DELAY
                move.w  d0,d1
                lsl.w   #2,d1
                lea     SPRITETAB(pc),a0
                adda.w  d1,a0
                move.w  MAX_ENEMY(pc),d1
TEST_ALL_FOR_S: cmp.w   d1,d0
                bhi.s   ALL_DONES
                movem.l d0-d1/a0,-(a7)
                movea.l (a0),a0
                bsr.s   TEST_DIS
                movem.l (a7)+,d0-d1/a0
                adda.l  #4*4,a0
                addq.w  #4,d0
                bra.s   TEST_ALL_FOR_S
ALL_DONES:      rts

TEST_DIS:       tst.w   (a0)            ; SPRITE ACTIVE ??
                beq     NO_NEW_SHOOT    ; NO
                tst.w   16(a0)          ; EXPLOTION
                beq     NO_NEW_SHOOT    ; YES
                cmpi.w  #3*160,4(a0)
                ble     NO_NEW_SHOOT
                cmpi.w  #130*160,4(a0)
                bhi     NO_NEW_SHOOT
                lea     ESHOOT(pc),a1
                move.w  MAX_ESHOOT(pc),d0
FIND_FREE_SHOOT:tst.w   (a1)+
                beq.s   GOT_FREE_SHOOT
                dbra    d0,FIND_FREE_SHOOT
                bra     NO_NEW_SHOOT    ; NO FREE SHOOT FOUND

GOT_FREE_SHOOT: movea.l SLUMPPOINTER(pc),a2
                move.w  4(a2),d0
                eori.w  #$F53C,d0
                add.w   d0,(a2)
                move.w  (a2),d0
                add.w   d0,d0
                move.w  d0,(a2)

                move.w  18(a0),d0
                cmp.w   (a2)+,d0        ; SLUMPA OM SKOTT
                blo     SLUMPEN_NEJ
                subq.l  #2,a1           ; SETUP A NEW SHOOT
                move.w  #1,0*ES(a1)
                move.w  2(a0),d0
                move.w  4(a0),d1
                ext.l   d1
                divs    #160,d1

                move.l  a2,SLUMPPOINTER
                movea.l 40(a0),a2       ; OBJECT ADDRESS

                add.w   26(a2),d0
                add.w   28(a2),d1
                subq.w  #4,d0
                subq.w  #4,d1
                lsl.w   #4,d0
                lsl.w   #4,d1
                move.w  d0,1*ES(a1)
                move.w  d1,2*ES(a1)

************************
                not.w   SHOOTAT
                beq.s   HERO2

HERO1:          lea     PL_DATA1(pc),a6
                tst.w   76(a6)
                beq.s   HERO2
                bra.s   AIM
HERO2:          lea     PL_DATA2(pc),a6
                tst.w   76(a6)
                beq.s   HERO1

AIM:            move.w  20(a6),d0
                move.w  22(a6),d1
                add.w   #16,d0
                divs    #160,d1
                add.w   #12,d1
                asl.w   #4,d0
                asl.w   #4,d1

                move.w  1*ES(a1),d2     ; GET BULLET POS
                move.w  2*ES(a1),d3     ; SET HIGER UP IN ROUT
                add.w   #16,d2          ; CENTER OF BULLET LSL #4
                add.w   #16,d3
*********************************
                move.w  20(a0),d6       ; GET RIGHT AIM TYPE
*                bra.s   E1

                tst.w   d6
                bne.s   E1
                bsr     AIM_SHOOT
                bra     E10
E1:             cmp.w   #1,d6
                bne.s   E2
                move.w  #0,4*ES(a1)
                move.w  #$0020,5*ES(a1)
                cmp.w   d1,d3
                blo     E10
                move.w  #0,4*ES(a1)
                move.w  #-$0020,5*ES(a1)
                bra     E10
E2:             cmp.w   #2,d6
                bne.s   E3
                move.w  #$0020,4*ES(a1)
                move.w  #0,5*ES(a1)
                cmp.w   d0,d2
                blo.s   E10
                move.w  #-$0020,4*ES(a1)
                move.w  #0,5*ES(a1)
                bra.s   E10
E3:             cmp.w   #3,d6
                bne.s   E4

E4:             cmp.w   #4,d6
                bne.s   E5
                move.w  #0,4*ES(a1)
                move.w  #$0020,5*ES(a1)
                bra.s   E10
E5:             cmp.w   #5,d6
                bne.s   E6
                move.w  #$0020,4*ES(a1)
                move.w  #0,5*ES(a1)
                bra.s   E10
E6:             cmp.w   #6,d6
                bne.s   E7
                move.w  #-$0020,4*ES(a1)
                move.w  #0,5*ES(a1)
                bra.s   E10
E7:             cmp.w   #7,d6           ; SHOOT2
                bne.s   E8
                move.w  #$0020,4*ES(a1)
                move.w  #0,5*ES(a1)
                bra.s   E10
E8:             cmp.w   #8,d6           ; SHOOT2
                bne.s   E9
                move.w  #-$0020,4*ES(a1)
                move.w  #0,5*ES(a1)
                bra.s   E10
E9:
E10:
                rts
SLUMPEN_NEJ:    move.l  a2,SLUMPPOINTER

NO_NEW_SHOOT:   rts

DELAY:          dc.w 0
SHOOTAT:        dc.w 0          ; WITCH PLAYER SHALL SHOOT ON (NOTAS)
MAX_ESHOOT:     dc.w 7          ; ANTAL SKOTT P SKŽRMEN TILLTNA
                endpart
                >PART 'AIM ENEMY SHOOT ON PLAYER'
****************************************
**      ENEMY SHOOT AIM ON PLAYER
****************************************
* d0=hit x *16
* d1=hit y *16
* d2=shoot from x (always *16)
* d3=shoot from y (always *16)
AIM_SHOOT:      moveq   #0,d6

                cmp.w   d0,d2
                bhi.s   C1
                move.w  d0,d4
                bset    #1,d6
                sub.w   d2,d4
                bra.s   B1
C1:             move.w  d2,d4
                sub.w   d0,d4
B1:             cmp.w   d1,d3
                bhi.s   C2
                move.w  d1,d5
                sub.w   d3,d5
                bset    #2,d6
                bra.s   B2
C2:             move.w  d3,d5
                sub.w   d1,d5
B2:             cmp.w   d4,d5
                bhi.s   B3
                exg     d4,d5
                bset    #0,d6
B3:             asr.w   #4,d4
                and.l   #$0000FFFF,d5
                and.l   #$0000FFFF,d4
                bne.s   .DIVOK
                move.w  #$7FFF,d5
                bra.s   .DIVDONE
.DIVOK:         divu    d4,d5
.DIVDONE:       move.w  #$0014,d0
                move.w  #$0014,d1
                cmp.w   #$0017,d5
                blo.s   B4
                move.w  #$0012,d0
                move.w  #$0018,d1
                cmp.w   #$0024,d5
                blo.s   B4
                move.w  #$000A,d0
                move.w  #$001C,d1
                cmp.w   #$00A0,d5
                blo.s   B4
                move.w  #$0000,d0
                move.w  #$0020,d1
B4:
                btst    #0,d6
                beq.s   C5
                exg     d0,d1
C5:             btst    #1,d6
                bne.s   C6
                neg.w   d0
C6:             btst    #2,d6
                bne.s   C7
                neg.w   d1
C7:
                move.w  d0,4*ES(a1)
                move.w  d1,5*ES(a1)
                rts
                endpart

HIT_ENEMY:      >PART 'ENEMY IS HIT'
********************************************************
**      HURT ENEMY
**      D0=SKADA (-1 D™DA SPRITEN & NO SCORE)
**               (-2 KROCKAT MED SPRITE KILL IF POSSIBLE, NO SCORE,
**                   CHANGE FLAGGS IF ALOWEED)
**               ANNAT S ANTAS DET VARA SKOTT MOT FIENDE
**      A0=ADDRESS TILL SPRITE SOM ŽR TRŽFFAD
**      A6=Address to Player header (if kill, both will be used anyway..)

********************************************************
                movea.l 36(a0),a4       ; HITS ON SPRITE A4
                move.w  46(a0),d7       ; GET SPRITE FLAGOR
                cmp.w   #-1,d0
                bne.s   .NOT_KILLEM
                bsr     CHANGE_FLAGS
                bra.s   .KILLEM
.NOT_KILLEM:    cmp.w   #-2,d0
                beq.s   .KILLVIDKROCK

                btst    #2,d7           ; Not kill posssible factors
                bne     .CANT_KILL
                move.l  96(a6),d1
                move.l  70(a0),d2
                and.l   d2,d1
                cmp.l   d2,d1
                bne     .CANT_KILL

                btst    #0,d7           ; KAN FIENDE BLI VIT ??
                bne.s   .NOT_WHITE
                move.w  #1,30(a0)       ; MAKE WHITE
.NOT_WHITE:
                sub.w   d0,28(a4)
                tst.w   28(a4)
                bge     .NOT_EXPLO
                btst    #4,d7
                bne.s   .KILLEM
                bsr     CHANGE_FLAGS
                bra.s   .KILLEM
***********************
.KILLVIDKROCK:  btst    #3,d7           ; Flaggs vid krock?
                bne.s   .NOTFLAG
                bsr     CHANGE_FLAGS
.NOTFLAG:       btst    #1,d7           ; D™R FIENDE VID KROCK ??
                bne     .NOT_EXPLO

                btst    #7,d7
                bne.s   .ALWAYSDIE
                move.l  96(a6),d1
                move.l  70(a0),d2
                and.l   d2,d1
                cmp.l   d2,d1
                bne     .NOT_EXPLO
.ALWAYSDIE:


.KILLEM:        move.w  #0,30(a0)       ; EXPLO - MAKE NORMAL
                move.w  MAX_ENEMY(pc),d2
                lea     SPRITETAB(pc),a5
                lea     _EXT_EXPLO,a2   ; A2=Extened Explo tab

.TEST_ALL_OFEM: movea.l (a5)+,a0
                cmpa.l  36(a0),a4
                bne     .NOT_HURT_HIM
                tst.w   (a0)
                beq     .NOT_HURT_HIM

                movea.l 40(a0),a1       ; A1=OBJECT ADDR

                move.w  22(a1),d1
                bmi.s   .NOEXTEND

                move.l  a4,-(a7)
                movea.l OBJECTTAB(pc),a4 ; A4=ExPlo object tab

                move.w  18(a1),d2
                addq.w  #1,d2
                lsl.w   #3,d2
                lea     64(a1,d2.w),a3  ; A3=Explo's
.EXTLOOP:       tst.w   (a2)
                bmi.s   .USEIT
                lea     18(a2),a2
                bra.s   .EXTLOOP
.USEIT:
                clr.w   (a2)            ; Used!
                move.w  2(a0),d2
                add.w   (a3)+,d2
                add.w   #DX_EXPLO,d2
                move.w  d2,2(a2)        ; Xpos

                and.w   #$000F,d2
                move.w  30(a4),d3
                lsr.w   d3,d2
                mulu    12(a4),d2
                move.w  d2,12(a2)       ; Add for rotation

                move.w  4(a0),d2
                ext.l   d2
                divs    #160,d2
                add.w   (a3)+,d2
                add.w   #DY_EXPLO,d2
                move.w  d2,4(a2)        ; Ypos
                move.w  (a3)+,6(a2)     ; Wait
                move.w  #-1,8(a2)       ; Ani Nr (-1)
                move.l  a4,10(a2)       ; Addr To OBJ (explo)
                clr.w   16(a2)          ; Add for Ani

                addq.l  #2,a3

                addq.w  #1,_EXPLO_NR

                dbra    d1,.EXTLOOP

                movea.l (a7)+,a4

.NOEXTEND:

                move.w  32(a1),d1       ; CENTER EXPLO
                add.w   d1,2(a0)
                move.w  34(a1),d1
                add.w   d1,4(a0)
                move.w  #0,16(a0)
                movea.l OBJECTTAB(pc),a3 ; EXPLO ADDR
                move.l  a3,40(a0)
                move.l  (a3),22(a0)
                move.w  10(a3),26(a0)
                move.w  #-1,80(a0)      ; No OANI



                tst.w   d0              ; SCORE
                bmi.s   .NO_SCORE
                lea     54(a0),a1
                movea.l 66(a6),a0
                movem.l d0-a6,-(a7)
                jsr     PLUSA(pc)
                movem.l (a7)+,d0-a6
.NO_SCORE:
.NOT_HURT_HIM:  dbra    d2,.TEST_ALL_OFEM
.NOT_EXPLO:     rts
********************************
.CANT_KILL:     btst    #6,d7
                bne.s   .NOT_EXPLO
                move.w  #1,30(a0)       ; MAKE WHITE
                bra.s   .NOT_EXPLO


CHANGE_FLAGS:   move.l  62(a0),d1
                btst    #5,d7
                bne.s   .ONEONLY
                move.l  a6,-(a7)
                lea     PL_DATA1(pc),a6
                or.l    d1,96(a6)
                lea     PL_DATA2(pc),a6
                or.l    d1,96(a6)
                movea.l (a7)+,a6
                rts
.ONEONLY:       or.l    d1,96(a6)
                rts

                endpart
TEST_PL_TO_ENE: >PART 'TEST IF PLAYER HIT ENEMY SHIP'
********************************************
**      TEST PLAYER TO SHIP
********************************************
* a6=address to player
                move.w  20(a6),d0
                move.w  d0,d2
                move.w  22(a6),d1
                move.w  d1,d3
                add.w   28(a6),d0
                add.w   30(a6),d1
                add.w   32(a6),d2
                add.w   34(a6),d3
                bsr.s   TEST_ENEMIES
                tst.w   d7
                bmi.s   NO_C2

                movem.l a0-a6,-(a7)
                move.w  44(a2),d0       ; HIT
                sub.w   d0,26(a6)
                movea.l a2,a0
                moveq   #-2,d0
                bsr     HIT_ENEMY
                movem.l (a7)+,a0-a6

NO_C2:          rts
                endpart
                >PART 'TEST AGAINST ENEMIES'
********************************************
**      TEST D0,D1,D2,D3 TO ALL ENIMIES
** d4,d5,d7,a0,a1,a2
**   out:  a2=address to hit enemy data
**         d7=-1 no one is hit
********************************************
TEST_ENEMIES:   lea     SPRITETAB(pc),a0
                move.w  MAX_ENEMY(pc),d7
                move.w  d7,d4
                addq.w  #1,d4
                lsl.w   #2,d4
                adda.w  d4,a0

TEST_TEN:       movea.l -(a0),a2
                tst.w   (a2)            ; ACTIVE SPRITE ??
                beq.s   NO_CRASH2
                tst.w   16(a2)          ; EXPLOSION HIT ??
                beq.s   NO_CRASH2

                movea.l 40(a2),a1       ; A1=OBJECT ADDR
                move.w  18(a1),d5
                bmi.s   NO_CRASH2
                lea     64(a1),a1

NEXT_REC:       move.w  2(a2),d4        ; XX1>X2=SKIP
                add.w   (a1),d4
                cmp.w   d2,d4
                bgt.s   NO_CRASH

                move.w  2(a2),d4        ; XX2<X1=SKIP
                add.w   4(a1),d4
                cmp.w   d0,d4
                blt.s   NO_CRASH

                move.w  4(a2),d4        ; YY1>Y2=SKIP
                add.w   2(a1),d4
                cmp.w   d3,d4
                bgt.s   NO_CRASH

                move.w  4(a2),d4        ; YY2<Y1=SKIP
                add.w   6(a1),d4
                cmp.w   d1,d4
                blt.s   NO_CRASH
                rts

NO_CRASH:       addq.l  #8,a1
                dbra    d5,NEXT_REC
NO_CRASH2:      dbra    d7,TEST_TEN
                rts
                endpart

                >PART 'DRAW ENEMIES'
********************************************
**      DRAW    SPRITES
********************************************
DRAW_SPRITES:   lea     SPRITETAB(pc),a6
                move.w  MAX_ENEMY(pc),d7

LOOPENS:
                movea.l (a6)+,a5
                tst.w   (a5)            ; ACTIVE ??
                beq     STRUNT_I_DEN

                move.l  PL_DATA1+96(pc),d0 ; ## Not any player amount comp.
                or.l    PL_DATA2+96(pc),d0
                move.l  74(a5),d1
                and.l   d1,d0
                cmp.l   d1,d0
                bne.s   .NOTKILL
                movem.l d7/a5-a6,-(a7)
                moveq   #-1,d0
                movea.l a5,a0
                lea     PL_DATA1(pc),a6
                bsr     HIT_ENEMY
                movem.l (a7)+,d7/a5-a6
                move.l  #-1,74(a5)
.NOTKILL:

                tst.w   80(a5)          ; O A N I
                bmi.s   .NO_OANI
                subq.w  #1,86(a5)
                bpl.s   .NO_OANI
                movea.l 82(a5),a3
                lea     16(a3),a3
                tst.w   (a3)
                bpl.s   .NO_OANIWRAP
                movea.l OANITAB_PEK(pc),a3
                move.w  80(a5),d0
                add.w   d0,d0
                adda.w  0(a3,d0.w),a3
.NO_OANIWRAP:
                move.l  a3,82(a5)
                move.w  (a3)+,d0
                move.w  d0,16(a5)       ; Obj nr
                lea     OBJECTTAB(pc),a0
                add.w   d0,d0
                add.w   d0,d0
                movea.l 0(a0,d0.w),a0
                move.l  a0,40(a5)       ; Addr to Obj
                move.l  (a0),22(a5)     ; Pointer image
                move.w  (a3)+,32(a5)    ; Center X
                move.w  (a3)+,d0
                muls    #160,d0
                move.w  d0,34(a5)       ; Center Y *160
                move.w  (a3)+,86(a5)    ; O-ANI Count
                move.w  (a3)+,46(a5)    ; SpriteFlags
                move.w  (a3)+,18(a5)    ; Shooting Rate
                move.w  (a3)+,20(a5)    ; Bullet Type


.NO_OANI:       movea.l 40(a5),a3       ; A3=OBJECT ADDRESS

                cmpi.w  #-1,26(a5)      ; I M G   A N I
                beq.s   NO_ANIMATION
                subq.w  #1,26(a5)
                bpl.s   NO_ANIMATION
                move.w  10(a3),26(a5)
                movea.l 22(a5),a0
                adda.w  8(a3),a0
                cmpa.l  4(a3),a0
                bne.s   ANI_QUIT
                movea.l (a3),a0
                tst.w   16(a5)
                bne.s   ANI_QUIT
                move.w  #3,(a5)
                move.w  #-1,26(a5)
                bra.s   STRUNT_I_DEN
ANI_QUIT:       move.l  a0,22(a5)
NO_ANIMATION:
                move.w  2(a5),d0
                and.w   #$000F,d0

                movea.l 22(a5),a1       ; BILD ADDR
                move.w  12(a3),d3
                move.w  30(a3),d2
                lsr.w   d2,d0
                muls    d0,d3
                adda.l  d3,a1           ; A1=SORCE

                moveq   #0,d6

                move.w  20(a3),d3       ; alternativt „r att h„mta bredd fr†n
                addq.w  #1,d3           ; sprite rutin listan.
                move.w  2(a5),d4
                move.w  4(a5),d5
                ext.l   d5
                divs    #SCREEN_WIDTH,d5
                move.w  16(a3),d6
                tst.w   30(a5)          ; VIT ??
                beq.s   .NOTWHITE
                subi.w  #1,30(a5)
                bset    #16,d6
.NOTWHITE:
                move.w  d7,-(a7)
                moveq   #0,d7
                move.w  14(a3),d7
                bsr     DO_SPRITE
                move.w  (a7)+,d7

STRUNT_I_DEN:   dbra    d7,LOOPENS
                rts
***********************************
                dc.l CLIP_SPRITE,-1
SPRITATAB:      dc.l SPRITA32,2,SPRITA48,3,SPRITA64,4,SPRITA96,6,SPRITA144,9,SPRITA160,10
***********************************
                dc.l CLIP_VIT,-1
VITTAB:         dc.l VIT32,2,VIT48,3,VIT64,4,VIT96,6,VIT144,9,VIT160,10
***********************************
                endpart
                >PART 'MOVE SPRITES'
********************************************
**      MOVE    SPRITES
********************************************
MOVE_SPRITES:   lea     SPRITETAB(pc),a0
                move.w  MAX_ENEMY(pc),d0
LOOPAS:         movea.l (a0)+,a1
                tst.w   (a1)            ; ACTIVE
                beq.s   SKIP_THIS_ONE
                cmpi.w  #1,(a1)
                beq.s   FLYTTA
                move.w  #0,(a1)
                bra.s   SKIP_THIS_ONE
FLYTTA:         tst.w   16(a1)          ; EXPLOSION
                beq.s   SKIP_THIS_ONE

                movea.l 6(a1),a2
                move.w  14(a1),d5
                adda.w  d5,a2
                move.l  a2,6(a1)
                tst.w   d5
                bmi.s   MINUSSTEG
                cmpa.l  10(a1),a2
                blo.s   NO_PROBLEM
HERE_I_AM:      move.l  10(a1),6(a1)    ; Remove
                move.w  #0,(a1)
                move.l  66(a1),d1
                lea     PL_DATA1(pc),a3
                and.l   d1,96(a3)
                lea     PL_DATA2(pc),a3
                and.l   d1,96(a3)
                bra.s   SKIP_THIS_ONE

NO_PROBLEM:     move.w  (a2)+,2(a1)     ; AW
                move.w  (a2),4(a1)
                move.w  32(a1),d1       ; Cent.
                add.w   d1,2(a1)
                move.w  34(a1),d1
                add.w   d1,4(a1)

                bsr.s   MOVE_ACR        ; acr


SKIP_THIS_ONE:  dbra    d0,LOOPAS
                rts

MINUSSTEG:      cmpa.l  10(a1),a2
                bhi.s   NO_PROBLEM
                bra.s   HERE_I_AM

MOVE_ACR:       move.w  96(a1),d1
                bmi.s   NOT_MUCH
                lea     98(a1),a2

FLYTTAACR:      movea.l 4(a2),a3
                adda.w  12(a2),a3
                cmpa.l  8(a2),a3
                blo.s   ACROK1

                move.l  8(a2),d2
                sub.l   (a2),d2
                suba.l  d2,a3

ACROK1:         cmpa.l  (a2),a3
                bhs.s   ACROK2

                move.l  8(a2),d2
                sub.l   (a2),d2
                adda.l  d2,a3

ACROK2:         move.l  a3,4(a2)
                move.w  (a3)+,d2
                add.w   d2,2(a1)
                move.w  (a3),d2
                add.w   d2,4(a1)

                adda.w  #14,a2

                dbra    d1,FLYTTAACR


NOT_MUCH:       rts

                endpart

                >PART 'RASTER IRQs'
********************************************
**      RASTER
********************************************
RASTER:
                move.l  #$07400320,$FFFF8242.w
                move.l  #$05300740,$FFFF8246.w
                move.l  #$02100700,$FFFF824A.w
                move.l  #$02100147,$FFFF824E.w
                move.l  #$00120123,$FFFF8252.w
                move.l  #$02340345,$FFFF8256.w
                move.l  #$04670567,$FFFF825A.w

                clr.b   $FFFFFA1B.w
                move.b  #4,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #RASTER2,$00000120.w
                bclr    #0,$FFFFFA0F.w
                rte
RASTER2:        move.w  #$0520,$FFFF8242.w
                move.w  #$0027,$FFFF8250.w
                clr.b   $FFFFFA1B.w
                move.b  #2,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #RASTER3,$00000120.w
                bclr    #0,$FFFFFA0F.w
                rte
RASTER3:        move.w  #$0430,$FFFF8242.w
                move.w  #$0317,$FFFF8250.w
                move.l  #RASTER4,$00000120.w
                bclr    #0,$FFFFFA0F.w
                rte
RASTER4:        move.w  #$0340,$FFFF8242.w
                move.w  #$0427,$FFFF8250.w
                move.l  #RASTER5,$00000120.w
                bclr    #0,$FFFFFA0F.w
                rte
RASTER5:        move.w  #$0150,$FFFF8242.w
                move.w  #$0537,$FFFF8250.w
                move.l  #RASTER6,$00000120.w
                bclr    #0,$FFFFFA0F.w
                rte
RASTER6:
                move.w  #$0073,$FFFF8242.w
                move.l  #$07500760,$FFFF824A.w
                move.w  #$0757,$FFFF8250.w
                move.l  #RASTER,$00000120.w
                clr.b   $FFFFFA1B.w
                bclr    #0,$FFFFFA0F.w
                rte
                endpart

W_DRAW_1:       >PART 'Normal Bullet Draw'
* a5=address to 256 bytes weapon data
* a6=address to player data
                lea     32(a5),a4
                movea.l (a5),a3
                movea.l SCREEN(pc),a2
                moveq   #9,d5
DRAW_LOOPEN1:   tst.w   (a4)
                beq.s   NOT_ACTIVE1
                move.w  4(a4),d0
                asr.w   #4,d0
                muls    #160,d0
                lea     0(a2,d0.w),a0

                move.w  2(a4),d0
                asr.w   #4,d0

                move.w  d0,d1
                and.w   #$000F,d0
                sub.w   d0,d1
                lsr.w   #1,d1
                adda.w  d1,a0
                move.w  8(a3),d1
                lsr.w   d1,d0
                ext.l   d0
                mulu    20(a3),d0
                movea.l (a3),a1

                adda.l  d0,a1
                movem.l d5/a0/a2/a5,-(a7)
                move.w  4(a3),d7

                move.w  2(a4),d4
                move.w  4(a4),d5
                asr.w   #4,d4
                asr.w   #4,d5
                moveq   #0,d6
                move.w  10(a3),d6
                move.w  12(a3),d3

                bsr     DO_SPRITE

                movem.l (a7)+,d5/a0/a2/a5

NOT_ACTIVE1:    lea     8(a4),a4
                dbra    d5,DRAW_LOOPEN1
                rts

                endpart
W_MOVE_1:       >PART 'Normal Bullet Move'
* a5=address to 256 bytes weapon data
* a6=address to player data
                lea     32(a5),a4
                moveq   #9,d7
LOOPEN1:        tst.w   (a4)
                beq.s   NEXTONE1

                move.w  d7,-(a7)

                move.w  4(a4),d0        ; Move Shoot
                move.w  2(a4),d1
                add.w   24(a5),d0
                add.w   22(a5),d1

                cmp.w   #319*16,d1
                bgt.s   .DIESUCKER
                cmp.w   #CLIP_Y*16,d0
                bgt.s   .DIESUCKER

                cmp.w   26(a5),d1
                ble.s   .DIESUCKER
                cmp.w   16(a5),d0
                bgt.s   KEEPGOING1
.DIESUCKER:     move.w  #0,(a4)
                bra.s   NO_HITING1
KEEPGOING1:     move.w  d0,4(a4)
                move.w  d1,2(a4)

                move.w  2(a4),d0        ; Test to Enemies
                move.w  4(a4),d1
                asr.w   #4,d0
                asr.w   #4,d1
                move.w  d0,d2
                move.w  d1,d3
                add.w   8(a5),d0
                add.w   10(a5),d1
                add.w   12(a5),d2
                add.w   14(a5),d3
                muls    #160,d1         ; ##
                muls    #160,d3

                bsr     TEST_ENEMIES
                tst.w   d7
                bmi.s   NO_HITING1

                move.w  #0,(a4)         ; Remove Bullet
                moveq   #2,d0           ; Injury on Enemy
                movea.l a2,a0           ; Address to Sprite Tab in A0
                movem.l a4-a6,-(a7)
                bsr     HIT_ENEMY
                movem.l (a7)+,a4-a6

NO_HITING1:     move.w  (a7)+,d7
NEXTONE1:       lea     8(a4),a4
                dbra    d7,LOOPEN1

                rts
                endpart
W_INIT_1:       >PART 'Normal Bullet Init'
* in   a0=address to weapon specificant 64 byte data   (se below)
* in   a1=address to 256 bytes data (coordinates...)
* in   a2=address to 32 bytes create weapon tab
                move.w  (a2),d0
                bsr     FIX_WEAPON      ; out a2=address to weapon look tab
                move.l  a2,(a1)
                move.w  4(a0),4(a1)
                move.w  6(a0),6(a1)
                move.w  8(a0),8(a1)
                move.w  10(a0),10(a1)
                move.w  12(a0),12(a1)
                move.w  14(a0),14(a1)
                move.l  18(a0),18(a1)
                move.w  22(a0),22(a1)
                move.w  24(a0),24(a1)

                move.w  4(a2),d0        ; Remove at
                lsl.w   #4,d0
                neg.w   d0
                move.w  d0,16(a1)
                move.w  12(a2),d0
                lsl.w   #8,d0
                neg.w   d0
                move.w  d0,26(a1)

                rts

********   Weapon Data Tab  BULLET

*                dc.l 0          ; 0   address to look tab
*                dc.w 0          ; 4   add x start pos
*                dc.w 0          ; 6   add y start pos
*                dc.w 0          ; 8   add x1 hit
*                dc.w 0          ; 10  add y1
*                dc.w 0          ; 12  add x2
*                dc.w 0          ; 14  add y2
*                dc.w 0          ; 16  Low Y to remove at*16
*                dc.l 0          ; 18  And Test
*                dc.w 0          ; 22  Speed X *16
*                dc.w 0          ; 24  Speed Y *16
*                dc.w 0          ; 26  Low X to remove at*16
* repeat
*                dc.w 0          ; 32  0=off   1 =on
*                dc.w 0          ; 34  Xpos*16
*                dc.w 0          ; 36  Ypos*16
*                dc.w 0          ; 38  **Reserved
* 10 times

********   Init tab (64 bytes)

*                dc.w 0          ; 0   Weapon type
*                dc.w 0          ; 2   **Reserved
*                dc.w 0          ; 4   add x for startpos
*                dc.w 0          ; 6   add y for startpos
*                dc.w 0          ; 8   add x1
*                dc.w 0          ; 10  add y1
*                dc.w 0          ; 12  add x2
*                dc.w 0          ; 14  add y2
*                dc.w 0          ; 16  ** Reserved **
*                dc.l 0          ; 18  And Test
*                dc.w 0          ; 22  Speed X
*                dc.w 0          ; 24  Speed Y

                endpart
W_NEW__1:       >PART 'Normal Bullet New'
* a5=address to 256 bytes weapopn data
* a6=address to player data

                move.l  18(a5),d7       ; and test
                move.l  96(a6),d6
                and.l   d7,d6
                cmp.l   d7,d6
                bne.s   BACKA1

                lea     32(a5),a4
                moveq   #9,d7
TESTNEXTA1:     tst.w   (a4)
                beq.s   FOUNDONE1
                lea     8(a4),a4
                dbra    d7,TESTNEXTA1
                bra.s   BACKA1

FOUNDONE1:      move.w  20(a6),d0
                move.w  22(a6),d1
                ext.l   d1
                divu    #160,d1
                add.w   4(a5),d0
                add.w   6(a5),d1
                lsl.w   #4,d0
                lsl.w   #4,d1

                move.w  #1,(a4)
                move.w  d0,2(a4)
                move.w  d1,4(a4)

BACKA1:         rts
                endpart

W_DRAW_2:       >PART 'Normal Laser Draw'
* a5=address to 256 bytes weapon data
* a6=address to player data

                lea     32(a5),a4
                movea.l (a5),a3
                movea.l SCREEN(pc),a2
                moveq   #3,d5
DRAW_LOOPEN2:   tst.w   (a4)
                beq.s   NOT_ACTIVE2
                movea.l a2,a0
                move.w  2(a4),d0

                move.w  4(a4),d1
                cmp.w   #-4*160,d1
                bgt.s   NOCLIPP
                move.w  #-4*160,d1
NOCLIPP:
                adda.w  d1,a0


                move.w  d0,d1
                and.w   #$000F,d0
                sub.w   d0,d1
                lsr.w   #1,d1
                adda.w  d1,a0
                move.w  8(a3),d1
                lsr.w   d1,d0
                ext.l   d0
                mulu    20(a3),d0
                movea.l (a3),a1

                adda.l  d0,a1
                move.w  d7,-(a7)
                move.w  6(a4),d7
                movem.l d0-a6,-(a7)
                bsr     DRAW_LASER32
                movem.l (a7)+,d0-a6

                move.w  (a7)+,d7
NOT_ACTIVE2:    lea     8(a4),a4
                dbra    d5,DRAW_LOOPEN2
                rts

                endpart
W_MOVE_2:       >PART 'Normal Laser Move'
* a5=address to 256 bytes weapon data
* a6=address to player data
                tst.w   16(a5)
                beq.s   NOLLAD
                subq.w  #1,16(a5)
NOLLAD:

                lea     32(a5),a4
                moveq   #3,d7
LOOPEN2:        tst.w   (a4)
                beq     NEXTONE2

                move.w  d7,-(a7)

                move.w  4(a4),d1        ; Move Shoot
                sub.w   18(a5),d1
                move.w  d1,4(a4)

                move.w  d1,d3
                add.w   12(a5),d3

                cmp.w   #-4*160,d1      ; cut y1
                bgt.s   HIGHTOK1
                move.l  #-4*160,d1
HIGHTOK1:

                move.w  20(a6),d0       ; fix x
                add.w   4(a5),d0
                move.w  d0,2(a4)

                move.w  22(a6),d0
                add.w   6(a5),d0


                cmp.w   d0,d3           ; cut y2
                blt.s   ABOVE1

                move.w  d0,d3


ABOVE1:
                move.w  d3,d2
                sub.w   d1,d2
                ext.l   d2
                divs    #160,d2
                sub.w   #6,d2
                tst.w   d2
                bpl.s   OKISS
                moveq   #0,d2
OKISS:          move.w  d2,6(a4)

                tst.w   d3
                bpl.s   NO_WORRY2

                move.w  #0,(a4)
                bra.s   NO_HITING2

NO_WORRY2:

*                bra.s   NO_HITING2




                move.w  2(a4),d0        ; Test to Enemies
                move.w  d0,d2
                add.w   8(a5),d0
                add.w   10(a5),d2
                moveq   #0,d7
                bsr     TEST_ENEMIES
ARGHH:          tst.w   d7
                bmi.s   NO_HIT
                movem.l d0-a6,-(a7)

*                move.w  #0,(a4)         ; Remove Bullet
                moveq   #1,d0           ; Injury on Enemy
                movea.l a2,a0           ; Address to Sprite Tab in A0
                bsr     HIT_ENEMY
                movem.l (a7)+,d0-a6
                bsr     NO_CRASH2
                bra.s   ARGHH

NO_HIT:
NO_HITING2:     move.w  (a7)+,d7
NEXTONE2:       lea     8(a4),a4
                dbra    d7,LOOPEN2

                rts
                endpart
W_INIT_2:       >PART 'Normal Laser Init'
* in   a0=address to weapon specificant 64 byte data   (se below)
* in   a1=address to 256 bytes data (coordinates...)
* in   a2=address to 32 bytes create weapon tab
                move.w  (a2),d0
                bsr     FIX_WEAPON      ; out a2=address to weapon look tab
                move.l  a2,(a1)
                move.w  4(a0),4(a1)
                move.w  6(a0),6(a1)
                move.w  8(a0),8(a1)
                move.w  10(a0),10(a1)
                move.w  12(a0),18(a1)
                move.w  14(a0),12(a1)
                move.w  16(a0),14(a1)
                move.w  16(a0),16(a1)
                move.l  18(a0),20(a1)
                move.w  #0,16(a1)


                rts



********   Weapon Data Tab  LASER

*                dc.l 0          ; 0   address to look tab
*                dc.w 0          ; 4   add x start pos
*                dc.w 0          ; 6   add y*160 start pos
*                dc.w 0          ; 8   add x1 hit
*                dc.w 0          ; 10  add x2
*                dc.w 0          ; 12  Max Height
*                dc.w 0          ; 14  time between shoots
*                dc.w 0          ; 16  Counter 0=shoot possible
*                dc.w 0          ; 18  speed


* repeat
*                dc.w 0          ; 32  0=off   1 =on
*                dc.w 0          ; 34  Xpos
*                dc.w 0          ; 36  Ypos*160
*                dc.w 0          ; 38  times to repeat line 3
* 4 times

********   Init tab (64 bytes)

*                dc.w 0          ; 0   Weapon type
*                dc.w 0          ; 2   **Reserved
*                dc.w 0          ; 4   add x for startpos
*                dc.w 0          ; 6   add y*160 for startpos
*                dc.w 0          ; 8   add x1
*                dc.w 0          ; 10  add x2
*                dc.w 0          ; 12  Speed
*                dc.w 0          ; 14  Max Hight
*                dc.w 0          ; 16  Time bwtween shoots

                endpart
W_NEW__2:       >PART 'Normal Laser New'
* a5=address to 256 bytes weapon data
* a6=address to player data

                tst.w   16(a5)          ; wait test
                beq.s   LASER_OK
                bra.s   BACKA2
LASER_OK:       move.l  20(a5),d7       ; and test
                move.l  96(a6),d6
                and.l   d7,d6
                cmp.l   d6,d7
                bne.s   BACKA2

                move.w  14(a5),16(a5)

                lea     32(a5),a4
                moveq   #3,d7
TESTNEXTA2:     tst.w   (a4)
                beq.s   FOUNDONE2
                lea     8(a4),a4
                dbra    d7,TESTNEXTA2
                bra.s   BACKA2

FOUNDONE2:

                move.w  22(a6),d1
                add.w   6(a5),d1

                move.w  #1,(a4)
                move.w  20(a6),2(a4)
                move.w  d1,4(a4)
                move.w  #1,6(a4)

BACKA2:         rts
                endpart


DRAW_LASER32:   >PART 'Draw Laser 32'
                rept 3
                movem.l (a0),d0-d3      ;xx
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,(a0)
                lea     160(a0),a0
                endr

                movem.l (a1),d0-d5
COPY3AN:        and.l   d0,(a0)
                and.l   d0,4(a0)
                or.l    d1,(a0)+
                or.l    d2,(a0)+
                and.l   d3,(a0)
                and.l   d3,4(a0)
                or.l    d4,(a0)+
                or.l    d5,(a0)+
                lea     160-16(a0),a0
                dbra    d7,COPY3AN

                rept 3
                lea     -24(a1),a1
                movem.l (a0),d0-d3      ;xx
                move.l  (a1),d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    4(a1),d0
                or.l    8(a1),d1
                move.l  12(a1),d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    16(a1),d2
                or.l    20(a1),d3
                movem.l d0-d3,(a0)
                lea     160(a0),a0
                endr


                rts

                endpart

FIX_WEAPON:     >PART 'Fix Weapon'
                movem.l d0-a1/a3-a6,-(a7)
                mulu    #48,d0
                lea     WEAPONLOOKTAB(pc),a2
                adda.w  d0,a2
                tst.l   (a2)
                bne.s   ALREADY_FIXED

                lea     24(a2),a0
                bsr     LOAD_FILE

                move.w  14(a2),d0
                move.w  16(a2),d1
                move.w  18(a2),d2
                move.w  6(a2),d3
                bmi.s   .FUCKING
                bsr     ROTATE_FILE
                bra.s   .WARNING
.FUCKING:       moveq   #0,d3
                bsr     ANI_MASKA_FILE
                subq.w  #1,d0
.WARNING:       move.l  a1,(a2)
                subq.w  #1,d5
                move.w  d5,4(a2)
                move.w  d0,12(a2)
                addq.w  #1,12(a2)
                move.w  d4,20(a2)
                move.w  d6,22(a2)

                bsr     FIND_ROUT
                move.w  d0,10(a2)
                move.w  d2,d0
                bsr     FIND_LSR
                move.w  d0,8(a2)

ALREADY_FIXED:  movem.l (a7)+,d0-a1/a3-a6
                rts
                endpart

CLIPY:          >PART 'CLIP Y'
* d6=ypos
* d7=h”jd
* a0
* a1
* a2=hopp till draw

                move.w  #CLIP_Y+1,d0
                sub.w   d6,d0
                bmi.s   NO_EM
                cmp.w   d7,d0
                bge.s   DRAW_EM
                move.w  d0,d7
DRAW_EM:        jmp     (a2)
NO_EM:          rts
                endpart

                >PART 'CLIP SPRITE ROUTINE'
********************************************
**      CLIP SPRITE ROUT
**      A0=DEST
**      A1=SORCE
**      D0=ANTAL WORDS-1
**      D1=ADD P SORCE EFTER VARJE RAD
**      D2=ADD P DEST EFTER VARJE RAD
**      D7=H™JD-1
********************************************
CLIP_SPRITE:    move.w  d0,d3
CLIP_LOOP1:     move.l  (a1)+,d4
                and.l   d4,(a0)
                and.l   d4,4(a0)
                move.l  (a1)+,d4
                or.l    d4,(a0)+
                move.l  (a1)+,d4
                or.l    d4,(a0)+
                dbra    d3,CLIP_LOOP1
                lea     0(a0,d2.w),a0
                lea     0(a1,d1.w),a1
                dbra    d7,CLIP_SPRITE
                rts

CLIP_VIT:       move.w  d0,d3
CLIP_LOOPV1:    move.l  (a1)+,d4
                addq.l  #8,a1
                not.l   d4
                or.l    d4,(a0)+
                or.l    d4,(a0)+
                dbra    d3,CLIP_LOOPV1
                lea     0(a0,d2.w),a0
                lea     0(a1,d1.w),a1
                dbra    d7,CLIP_VIT
                rts
                endpart
                >PART 'SPRITE 144*D7'
********************************************
**      SPRITERUT 144*D7
********************************************

                movem.l (a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,(a0)

                movem.l 16(a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,16(a0)

                movem.l 32(a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,32(a0)

                movem.l 48(a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,48(a0)
                lea     160(a0),a0
                endpart
                >PART 'SPRITE 32*D7 +CLIP,WHITE'
********************************************
**      SPRITERUT 32*D7
********************************************
SPRITA32:
                movem.l (a0),d0-d3      ;xx
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,(a0)
                lea     160(a0),a0
                dbra    d7,SPRITA32
                rts
****
SPRITA32CLIP:
                movem.l (a0),d0-d3      ;x-
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                movem.l d0-d3,(a0)
                lea     12(a1),a1
                lea     160(a0),a0
                dbra    d7,SPRITA32CLIP
                rts
****
SPRITA32CLIP2:
                movem.l (a0),d0-d3      ;-x
                lea     12(a1),a1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,(a0)
                lea     160(a0),a0
                dbra    d7,SPRITA32CLIP2
                rts
***********************************************
VIT32:          move.l  (a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  12(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                lea     24(a1),a1
                lea     160-16(a0),a0
                dbra    d7,VIT32
                rts
                endpart
                >PART 'SPRITE 48*D7 +WHITE'
********************************************
**      SPRITERUT 48*D7
********************************************
SPRITA48:
                movem.l (a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,(a0)
                lea     160(a0),a0
                dbra    d7,SPRITA48
                rts
***********************************************
VIT48:          move.l  (a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  12(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  24(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                lea     36(a1),a1
                lea     160-24(a0),a0
                dbra    d7,VIT48
                rts
                endpart
                >PART 'SPRITE 96*D7 +WHITE'
********************************************
**      SPRITERUT 96*D7
********************************************
SPRITA96:
                movem.l (a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,(a0)

                movem.l 24(a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,24(a0)


                lea     160(a0),a0
                dbra    d7,SPRITA96
                rts
***********************************************
VIT96:
                move.l  (a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  12(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  24(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  36(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  48(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  60(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                lea     72(a1),a1
                lea     160-48(a0),a0
                dbra    d7,VIT96
                rts
                endpart
                >PART 'SPRITE 144*D7 +WHITE'
********************************************
**      SPRITERUT 144*D7
********************************************
SPRITA144:
                movem.l (a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,(a0)
                movem.l 24(a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,24(a0)
                movem.l 48(a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,48(a0)
                lea     160(a0),a0
                dbra    d7,SPRITA144
                rts
***********************************************
VIT144:         move.l  (a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  12(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  24(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  36(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  48(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  60(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  72(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  84(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  96(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                lea     108(a1),a1
                lea     160-72(a0),a0
                dbra    d7,VIT144
                rts
                endpart
                >PART 'SPRITE 160*D7 +WHITE'
********************************************
**      SPRITERUT 160*D7
********************************************
SPRITA160:
                movem.l (a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,(a0)
                movem.l 24(a0),d0-d5
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                move.l  (a1)+,d6
                and.l   d6,d4
                and.l   d6,d5
                or.l    (a1)+,d4
                or.l    (a1)+,d5
                movem.l d0-d5,24(a0)

                movem.l 48(a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,48(a0)

                movem.l 64(a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,64(a0)


                lea     160(a0),a0
                dbra    d7,SPRITA160
                rts
***********************************************
VIT160:         move.l  (a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  12(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  24(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  36(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  48(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  60(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  72(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  84(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  96(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  108(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                lea     120(a1),a1
                lea     160-80(a0),a0
                dbra    d7,VIT160
                rts
                endpart

                >PART 'SPRITE 64*D7 +WHITE'
********************************************
**      SPRITERUT 64*D7
********************************************
SPRITA64:
                movem.l (a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,(a0)

                movem.l 16(a0),d0-d3
                move.l  (a1)+,d6
                and.l   d6,d0
                and.l   d6,d1
                or.l    (a1)+,d0
                or.l    (a1)+,d1
                move.l  (a1)+,d6
                and.l   d6,d2
                and.l   d6,d3
                or.l    (a1)+,d2
                or.l    (a1)+,d3
                movem.l d0-d3,16(a0)
                lea     160(a0),a0
                dbra    d7,SPRITA64
                rts
***********************************************
VIT64:          move.l  (a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  12(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  24(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                move.l  36(a1),d0
                not.l   d0
                or.l    d0,(a0)+
                or.l    d0,(a0)+
                lea     48(a1),a1
                lea     160-32(a0),a0
                dbra    d7,VIT64
                rts
                endpart

                >PART 'SWITCH SCREEN'
********************************************
**      SWITCH_SCREEN
********************************************
SWITCH_SCREEN:  not.w   SFLAG
                bne.s   OTHER
                move.l  SCREEN1(pc),SCREEN
                move.l  #OLDTAL1,OLDTAL ; SCORE
                bra.s   SDONE
OTHER:          move.l  SCREEN2(pc),SCREEN
                move.l  #OLDTAL2,OLDTAL ; SCORE

SDONE:          move.b  SCREEN+1(pc),NEXTHIGH
                move.b  SCREEN+2(pc),NEXTLOW
                rts
                endpart

                >PART 'CHECK SLUMP WARP'
********************************************
**      TEST IF SLUMP HAS REACHED END
********************************************
CHECK_SLUMP_END:
                addq.l  #2,SLUMPPOINTER
                cmpi.l  #ENDSLUMP,SLUMPPOINTER
                bls.s   NO_END_YET
                move.l  #SLUMP,SLUMPPOINTER
NO_END_YET:     rts
                endpart
                >PART 'CHEAT'
********************************************
**      CHEAT KEY(PC)
********************************************
FUSKA:          move.b  KEY(pc),d7
                tst.w   CHEATFLAG
                beq     NO_CHEAT
                cmpi.b  #$3B,d7
                bne.s   NOTF1
                jsr     F_ENERGY1
                bra     NO_CHEAT
NOTF1:          cmpi.b  #$3C,d7
                bne.s   NOTF2
                jsr     F_ENERGY2
NOTF2:          cmpi.b  #$3D,d7
                bne.s   NOTF3
                jsr     F_KILLONE
NOTF3:          cmpi.b  #$3E,d7
                bne.s   NOTF4
                jsr     F_ESHOOTS_BORT
NOTF4:          cmp.b   #$3F,d7
                bne.s   NOTF5
                jsr     F_ESHOOTS_BORT
                jsr     F_ENEMIES_BORT
NOTF5:          cmpi.b  #$40,d7
                bne.s   NOTF6
                jsr     D_C_TIMER_ON
NOTF6:          cmpi.b  #$41,d7
                bne.s   NOTF7
                jsr     D_P_TIMER_ON
NOTF7:          cmpi.b  #$42,d7
                bne.s   NOTF8
                jsr     D_C_TIMER_OFF
                jsr     D_P_TIMER_OFF
NOTF8:          cmpi.b  #$43,d7
                bne.s   NOTF9
                move.l  #MEMORY,d0      ; Percent of Memory used
                move.l  #END_OF_MEM,d1
                move.l  MEM_END(pc),d2
                sub.l   d0,d1
                sub.l   d0,d2
                lsr.l   #6,d1
                lsr.l   #6,d2
                mulu    #$0064,d2
                divu    d1,d2
                cmp.w   #$0063,d2
                ble.s   OKIG
                moveq   #$63,d2
OKIG:           lea     TALKONV,a0
                move.b  0(a0,d2.w),d1
                move.w  #$0099,d2
                sbcd    d1,d2
                lea     DUMMYAREA,a0
                move.b  d2,d1
                and.b   #$0F,d2
                lsr.w   #4,d1
                and.b   #$0F,d1
                move.b  d1,(a0)
                move.b  d2,1(a0)
                move.b  #-1,2(a0)
                movea.l SCREEN(pc),a1
                lea     9(a1),a1
                bsr     PRINT_A0

NOTF9:          cmpi.b  #$0001+$0080,d7
                blo.s   NOT_SLOWM
                cmpi.b  #$000D+$0080,d7
                bhi.s   NOT_SLOWM
                moveq   #0,d0
                move.b  d7,d0
                sub.w   #1+$0080,d0
                jsr     D_SLOWMOTION
NOT_SLOWM:


NO_CHEAT:       rts
                endpart
VSYNC3:         >PART 'VSYNC -3'
********************************************
**      VSYNC
********************************************
                tst.w   TIMESHOW2       ; write processor time in percent
                beq.s   NOSHOWTIME
                movea.l SCREEN(pc),a1
                move.w  PROCESSORTIME(pc),d0
                lea     DUMMYAREA,a0
                move.w  d0,d1
                and.w   #$000F,d0
                and.w   #$00F0,d1
                lsr.w   #4,d1
                move.b  d1,(a0)
                move.b  d0,1(a0)
                move.b  #-1,2(a0)
                jsr     PRINT_A0(pc)

NOSHOWTIME:     moveq   #0,d0
                moveq   #3,d1
                lea     VBLFLAG(pc),a0
FLAG_VBL:       addq.w  #1,d0           ; 1nop
                cmp.w   (a0),d1         ; 2nop
                bhi.s   FLAG_VBL        ; 3nop   =6nops

                move.w  #(119616/6)/100,d1
                divu    d1,d0           ; mellan 0-$64 (100)
                cmp.w   #99,d0
                ble.s   UPPEROKI
                moveq   #99,d0
UPPEROKI:       tst.w   d0
                bpl.s   LOWEROKI
                moveq   #0,d0
LOWEROKI:
                lea     TALKONV,a0
                and.w   #$007F,d0
                move.b  0(a0,d0.w),d0
                move.w  d0,PROCESSORTIME

                cmpi.b  #$2E,KEY
                bne.s   NOTCHEATBOX
                jsr     CHEATBOX
NOTCHEATBOX:

                bsr     FUSKA
                cmpi.b  #$19,KEY        ; PAUSE
                bne.s   NOT_PAUSE
                jsr     PAUSE(pc)
NOT_PAUSE:      tst.w   CHEATFLAG2      ; OD™DLIG
                beq.s   NO_CHEAT2
                move.w  #1,PL_DATA1+26
                move.w  #1,PL_DATA2+26
NO_CHEAT2:
                lea     VBLFLAG(pc),a0
                move.w  SLOWMOTION(pc),d0 ; SlowMotion
                beq.s   NOMOTION
                clr.w   (a0)
WBL:            tst.w   (a0)
                beq.s   WBL
                clr.w   (a0)
                subq.w  #1,d0
                bne.s   WBL
NOMOTION:       clr.w   VBLFLAG

                rts
NEXTHIGH:       dc.b 0          ; HIGHT BYTE SCREEN ADDRESS(SŽTTS P 2VBLEN)
NEXTLOW:        dc.b 0          ; LOW BYTE SCREEN ADDRESS
                endpart
VSYNC:          >PART 'VSYNC -1"'
                clr.w   VBLFLAG
URKURK:         tst.w   VBLFLAG
                beq.s   URKURK
                rts
                endpart
                >PART 'PAUSE'
********************************************
**      PAUSE
********************************************
PAUSE:
WAITPREL1:      cmpi.b  #$0019+$0080,$FFFFFC02.w
                bne.s   WAITPREL1
NOT_P:          cmpi.b  #$62,$FFFFFC02.w ; HELP
                bne.s   NOT_HELP
                move.w  #1,CHEATFLAG
NOT_HELP:       cmpi.b  #$61,$FFFFFC02.w ; UNDO
                bne.s   NOT_UNDO
                move.w  #0,CHEATFLAG
                move.w  #0,CHEATFLAG2
NOT_UNDO:
                if SCREEN_DUMP=1
                cmpi.b  #$1F,$FFFFFC02.w
                bne.s   NOT_SCREENQUIT
                movea.l SCREEN1(pc),a0
                lea     32000(a0),a1
                illegal
NOT_SCREENQUIT: endc

                cmpi.b  #$60,$FFFFFC02.w ; < JŽTTEFUSK
                bne.s   NOT_GREATER
                move.w  #1,CHEATFLAG2
NOT_GREATER:    cmpi.b  #$19,$FFFFFC02.w
                bne.s   NOT_P
WAITPREL2:      cmpi.b  #$0019+$0080,$FFFFFC02.w
                bne.s   WAITPREL2
                rts
                endpart
                >PART 'VBL'
********************************************
**      VBL
********************************************
VBL:            if SPACEQUIT=1
                tst.w   REFUSESPACEQUIT
                beq.s   NOWAY
                cmpi.b  #$39,KEY
                beq     BACK
NOWAY:          endc
                addq.w  #1,VBLFLAG
                tst.w   CHG_ON_TWO
                beq.s   NOTTVA
                cmpi.w  #2,VBLFLAG
                bne.s   NOTTVA
                move.b  NEXTHIGH(pc),$FFFF8201.w
                move.b  NEXTLOW(pc),$FFFF8203.w
                bra.s   NOTOVER
NOTTVA:         cmpi.w  #4,VBLFLAG
                bne.s   NOTOVER
                move.w  #2,VBLFLAG
NOTOVER:
                tst.w   INST_RASTER
                beq.s   DO_NOT
                movem.l d0-d7,-(a7)
                move.b  #0,$FFFFFA1B.w
                move.b  #169,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                movem.l PAL1+2(pc),d0-d6
                movem.l d0-d6,$FFFF8242.w
                movem.l (a7)+,d0-d7
DO_NOT:         tst.w   MUSIC_FLAG
                beq.s   DONT_PLAY_ARMY
                movem.l d0-a7,-(a7)
                movea.l MUSIC_JUMP(pc),a0
                jsr     (a0)
                movem.l (a7)+,d0-a7
DONT_PLAY_ARMY: rte
                endpart

**********************************
STUPID_FIX:     >PART 'Fix Stupidity'



                lea     LEFTPLACED(pc),a0
                lea     RIGHTPLACED(pc),a2
                lea     ENDLEFTP(pc),a1
FIXFONTMORE:    move.l  (a0),d0
                not.l   d0
                move.l  d0,(a0)+
                lsr.l   #1,d0
                move.l  d0,(a2)+
                cmpa.l  a0,a1
                bne.s   FIXFONTMORE

                lea     TALKONV,a0      ; g”r konvert tab 0-99
                moveq   #$99,d0
                moveq   #99,d1
                moveq   #1,d2
TALLOOP:        move.b  d0,(a0)+
                sbcd    d2,d0
                dbra    d1,TALLOOP

                move.w  #3*16,d0
                lea     AW16(pc),a0
                bsr.s   MAKECURVE
                move.w  #6*16,d0
                lea     AW17(pc),a0
                bsr.s   MAKECURVE
                move.w  #11*16,d0
                lea     AW18(pc),a0
                bsr.s   MAKECURVE
                move.w  #14*16,d0
                lea     AW19(pc),a0
                bsr.s   MAKECURVE
                move.w  #16*16,d0
                lea     AW20(pc),a0
                bsr.s   MAKECURVE


                lea     AWFIXSTART(pc),a0
                lea     AWFIXEND(pc),a1
KEEPDOING:      move.w  (a0),d0
                move.w  2(a0),d1
                muls    #160,d1
*                move.w  #160,d0
                move.w  d0,(a0)+
                move.w  d1,(a0)+
                cmpa.l  a0,a1
                bne.s   KEEPDOING

                rts

MAKECURVE:      move.w  #-50,d1
                move.w  #280-1,d2
HUHU:           move.w  d0,(a0)+
                move.w  d1,(a0)+
                add.w   #1,d1
                dbra    d2,HUHU
                rts
END_STUPID_FIX:
                endpart
BEGIN:          >PART 'Init'
********************************************
**      STARTUP
********************************************

                move    #$2700,sr

                lea     $FFFFFC00.w,a0  ; Fix IKBD For JoyStick
WAITACIA1:
                move.b  (a0),d1
                btst    #1,d1
                beq.s   WAITACIA1
                move.b  #$12,2(a0)
WAITACIA2:      move.b  (a0),d1
                btst    #1,d1
                beq.s   WAITACIA2
                move.b  #$1A,2(a0)
WAITACIA3:      move.b  (a0),d1
                btst    #1,d1
                beq.s   WAITACIA3
                move.b  #$14,2(a0)


                move    #$2700,sr

                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA13.w
                move.b  #%01000000,$FFFFFA09.w ; only IKBD
                move.b  #%01000000,$FFFFFA15.w
                move.l  #VBL,$00000070.w
                move.l  #ACIA,$00000118.w
                move    #$2500,sr


                bsr     STUPID_FIX

                bra     GAME
END_BEGIN:
                endpart
BACK:           >PART 'Back'
********************************************
**      BACK
********************************************
*               moveq   #0,d0
*               JSR     MUSIC

                move    #$2700,sr
                lea     SAVETAB(pc),a6
                movea.l (a6)+,a7
                move.l  (a6)+,$00000070.w
                move.l  (a6)+,$00000120.w
                move.b  (a6)+,$FFFFFA07.w
                move.b  (a6)+,$FFFFFA09.w
                move.b  (a6)+,$FFFFFA0F.w
                move.b  (a6)+,$FFFFFA11.w
                move.b  (a6)+,$FFFFFA13.w
                move.b  (a6)+,$FFFFFA15.w
                move.l  (a6)+,$00000068.w
                move.l  (a6)+,$00000070.w
                move.l  (a6)+,$00000118.w
                move.l  (a6)+,$00000120.w
                move.w  (a6)+,-(a7)
                move.l  (a6),-(a7)
                move.l  (a6)+,-(a7)
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7
                movem.l (a6)+,d0-d7
                movem.l d0-d7,$FFFF8240.w
                move.w  #256,d0
Q0:             move.b  $FFFFFC02.w,d1
                moveq   #127,d1
Q1:             dbra    d1,Q1
                dbra    d0,Q0


                clr.w   -(a7)
                trap    #1
                endpart
***********************************

ROTATE:         >PART 'ROTATING ROUT'
******************************************
**      ROTERINGS RUTIN 4BP 16ST - LSN OF OMEGA 4/6-90
**      D0= ANTAL WORDS BRED (16=1 32=2 OSV.)
**      D1= H™JD
**      D2= ANTAL ROTERINGAR (16,8,4,2,1)
**      A0= SORCE
**      A1= DEST
**      TAR I MINNE ((D0+1)*D1*12) PER ROTERING OCH *16 F™R ALLTIHOP
**      UPPLŽGGNING:    1.W MASK   1.W MASK   4.W DATA   =12 BYTES
**      TŽNK P ATT DEST BLIR (D0+1)*12 BYTES BRED
*******************************************

                move.w  $FFFF8240.w,-(a7)
                move.w  #$0707,$FFFF8240.w
                movem.l d0-a6,-(a7)
                move.w  d2,-(a7)
                movea.l a1,a3

                movea.l a1,a2
                move.l  d1,d3
                subq.l  #1,d3
.X_LINE:        move.w  d0,d2
                subq.w  #1,d2
.X_WORD:        clr.l   (a2)+
                move.l  (a0)+,(a2)+
                move.l  (a0)+,(a2)+
                dbra    d2,.X_WORD
                clr.l   (a2)+
                clr.l   (a2)+
                clr.l   (a2)+
                dbra    d3,.X_LINE

                move.l  d0,d3
                addq.l  #1,d3
                mulu    d1,d3
                move.l  d3,d2
                mulu    #12,d2          ; d2=Antal bytes per bild
                subq.l  #1,d3           ; D3=Antal SEGMENT att kopiera

                move.w  (a7),d7         ; D7=Line counter
                ext.l   d7
                moveq   #16,d6
                divu    d7,d6
                subq.w  #1,d6
                movea.l d6,a6           ; A6=ROXAR PER BILD -1
                subq.l  #2,d7           ; D7=LOOP (BILDER-2)
                bmi.s   AllRot_Done

RotationLoop:   movea.l a1,a0           ; COPY
                adda.l  d2,a1
                movea.l a1,a2
                move.w  d3,d6
.KeepCopying:   move.l  (a0)+,(a2)+
                move.l  (a0)+,(a2)+
                move.l  (a0)+,(a2)+
                dbra    d6,.KeepCopying

                move.w  a6,d6
MultiSteper:    movea.l a1,a0
                addq.l  #4,a0
                swap    d6
                move.w  #3,d6
NextBpl:        move    #0,ccr          ; No X
                movea.l a0,a2
                move.w  d3,d4
.RoxLoop:       move.w  (a2),d5
                roxr.w  #1,d5
                move.w  d5,(a2)
                lea     12(a2),a2
                dbra    d4,.RoxLoop
                addq.l  #2,a0
                dbra    d6,NextBpl
                swap    d6
                dbra    d6,MultiSteper

                dbra    d7,RotationLoop

AllRot_Done:    divs    #12,d2
                subq.l  #1,d2
                move.w  (a7)+,d7
                subq.w  #1,d7
MAKEMASK1:      move.w  d2,d6
MAKEMASK2:      move.w  4(a3),d3
                or.w    6(a3),d3
                or.w    8(a3),d3
                or.w    10(a3),d3
                not.w   d3
                move.w  d3,(a3)+
                move.w  d3,(a3)+
                addq.l  #8,a3           ;(+12)
                dbra    d6,MAKEMASK2
                dbra    d7,MAKEMASK1
                movem.l (a7)+,d0-a6
                move.w  (a7)+,$FFFF8240.w
                rts

_SaveTmp:       ds.l 1
                endpart
ANI_MASKA:      >PART 'ANI ROT. MASK ROUT'
******************************************
**      masking (without rotation)
**      D0= ANTAL WORDS BRED (16=1 32=2 OSV.)
**      D1= H™JD
**      D2= ANTAL ROTERINGAR (16,8,4,2,1) (no fuction!)
**      A0= SORCE
**      A1= DEST
**      TAR I MINNE ((D0)*D1*12)
**      UPPLŽGGNING:    1.W MASK   1.W MASK   4.W DATA   =12 BYTES
**      TŽNK P ATT DEST BLIR (D0)*12 BYTES BRED (ej d0+1 som i rotering)
*******************************************
                movem.l d0-a6,-(a7)
                movea.l a1,a3

                movea.l a1,a2           ; copy
                move.l  d1,d3
                subq.l  #1,d3
X_LINEB:        move.w  d0,d2
                subq.w  #1,d2
X_WORDB:        clr.l   (a2)+
                move.l  (a0)+,(a2)+
                move.l  (a0)+,(a2)+
                dbra    d2,X_WORDB
                dbra    d3,X_LINEB

                move.l  d0,d3
                muls    d1,d3
                muls    #12,d3
                move.l  d3,d2           ; D2=ANTAL BYTES PER BILD

                divs    #12,d2
                subq.l  #1,d2

MAKEMASK2B:     move.w  4(a3),d3        ; mask
                or.w    6(a3),d3
                or.w    8(a3),d3
                or.w    10(a3),d3
                not.w   d3
                move.w  d3,(a3)+
                move.w  d3,(a3)+
                addq.l  #8,a3           ;(+12)
                dbra    d2,MAKEMASK2B
                movem.l (a7)+,d0-a6
                rts
                endpart

                >PART 'COLOR SWAP ROUT'
****************************************************
** Change colors on Image
**
**   d0=New color section (0-2) on section 0
**   d1=New color section (0-2) on section 1
**   d2=New color section (0-2) on section 2
**   a0=start of image data
**   a1=end of image data
****************************************************
COLORSWAP:      movem.l d0-a6,-(a7)
                move.w  $FFFF8240.w,-(a7)
                move.w  #$0770,$FFFF8240.w
                lea     CHANGETAB+1(pc),a3
                lea     SECTIONCOLS(pc),a2
                lsl.w   #2,d0
                lsl.w   #2,d1
                lsl.w   #2,d2
                move.b  0(a2,d0.w),(a3)+
                move.b  1(a2,d0.w),(a3)+
                move.b  2(a2,d0.w),(a3)+
                move.b  3(a2,d0.w),(a3)+
                move.b  0(a2,d1.w),(a3)+
                move.b  1(a2,d1.w),(a3)+
                move.b  2(a2,d1.w),(a3)+
                move.b  3(a2,d1.w),(a3)+
                move.b  0(a2,d2.w),(a3)+
                move.b  1(a2,d2.w),(a3)+
                move.b  2(a2,d2.w),(a3)+
                move.b  3(a2,d2.w),(a3)+
                lea     CHANGETAB(pc),a2
                bsr.s   COLORCHANGE
                move.w  (a7)+,$FFFF8240.w
                movem.l (a7)+,d0-a6
                rts
SECTIONCOLS:    dc.b 1,2,3,4
                dc.b 5,6,7,8
                dc.b 9,10,11,12
CHANGETAB:      dc.b 0
                ds.b 12,-1
                dc.b 13,14,15

*********************************************
** Color Change Rout  (Pc relativ)
**
** a0=address to start of object
** a1=address to end of object
** a2=address to a 16 bytes conversion tab
**     where byte 1 contain what all color 1 will
**     get and so on.....
*********************************************
COLORCHANGE:    movem.l d0-a6,-(a7)
NEWWORD:        movem.w (a0)+,d0-d3
                moveq   #15,d7
BITLOOP:        moveq   #0,d4
                addx.w  d3,d3
                addx.w  d4,d4
                ror.w   #1,d3
                addx.w  d2,d2
                addx.w  d4,d4
                ror.w   #1,d2
                addx.w  d1,d1
                addx.w  d4,d4
                ror.w   #1,d1
                addx.w  d0,d0
                addx.w  d4,d4
                ror.w   #1,d0

                move.b  0(a2,d4.w),d4

                roxr.w  #1,d4
                addx.w  d0,d0
                roxr.w  #1,d4
                addx.w  d1,d1
                roxr.w  #1,d4
                addx.w  d2,d2
                roxr.w  #1,d4
                addx.w  d3,d3
                dbra    d7,BITLOOP
                movem.w d0-d3,-8(a0)
                cmpa.l  a1,a0
                blo.s   NEWWORD
                movem.l (a7)+,d0-a6
                rts
                endpart

LOAD_FILE:      >PART 'LOAD FILE'
* In:
* A0=address to filename
* Out:
* A0=address where it's loaded (screen base)
* A1=End Of Files address
* D0=Lenght of files
                movem.l d1-d7/a2-a6,-(a7)
                lea     FILEN(pc),a1
                moveq   #15,d0
COPY_NAMN:      move.b  (a0)+,(a1)+
                dbra    d0,COPY_NAMN

                pea     DTA(pc)
                move.w  #$001A,-(a7)
                trap    #1
                addq.l  #6,a7

                clr.w   -(a7)
                pea     PATHEN(pc)
                move.w  #$003D,-(a7)
                trap    #1
                addq.l  #8,a7
                tst.l   d0
                bmi.s   FIL_ERROR
                move.l  d0,d7           ; D7=handle

                pea     STARTLOAD
                pea     SCR2-STARTLOAD
                move.w  d7,-(a7)
                move.w  #$003F,-(a7)
                trap    #1
                lea     12(a7),a7
                tst.l   d0
                bmi.s   FIL_ERROR

                move.w  d7,-(a7)
                move.w  #$003E,-(a7)
                trap    #1
                addq.l  #4,a7

                clr.w   -(a7)
                pea     PATHEN(pc)
                move.w  #$004E,-(a7)
                trap    #1
                addq.l  #8,a7
                tst.w   d0
                bmi.s   FIL_ERROR

                move.l  DTA+26(pc),d0
                lea     STARTLOAD,a0
                bsr     ICE_UNPACK

                lea     STARTLOAD,a0
                lea     0(a0,d0.l),a1
                movem.l (a7)+,d1-d7/a2-a6
                rts

FIL_ERROR:      move.w  #$0700,$FFFF8240.w
                illegal

PATHEN:         dc.b "\LIESEN\EUTANASI\VIRTUAL\"
FILEN:          ds.b 16
                even
DTA:            ds.w 32
                endpart
ICE_UNPACK:     >PART 'ICE Packer'

* a0=address to source (and dest)
* out d0=lenght of uncrunched area if crunched... otherwize unchanged

                cmpi.l  #"Ice!",(a0)
                bne.s   NOICEATALL

                movem.l d0/a2-a3,-(a7)

                move.l  8(a0),d0        ; get size of orginal
                movea.l a0,a1
                lea     0(a0,d0.l),a0
                movea.l a0,a3
                movea.l a1,a2
                subq.l  #1,d0

DRAKULA:        move.b  (a2)+,(a3)+
                dbra    d0,DRAKULA

                movem.l (a7)+,d0/a2-a3




                bra.s   STARTICE


NOICEATALL:     rts

STARTICE:
;********************************************* Unpackroutine von ICE-PACK
; assemble with Devpac or any other Assembler
; length of this unpacking routine: 294 bytes
;  a0 = address of packed data
;  a1 = address of unpacked data
;  d0=lenght if crunched; otherwize unchaged
                movem.l d0-a6,-(a7)
                bsr.s   GET_LONG
                cmpi.l  #'Ice!',d0      ; Is file packed?
                bne.s   NOT_PACKED      ; no, leave this routine
                bsr.s   GET_LONG        ; Lenght of crunch (??)
                lea     -8(a0,d0.l),a5
                bsr.s   GET_LONG        ; Lenght of Orginal
                move.l  d0,(a7)
                movea.l a1,a4
                movea.l a1,a6
                adda.l  d0,a6
                movea.l a6,a3
                move.b  -(a5),d7
                bsr.s   ICE06
NOT_PACKED:     movem.l (a7)+,d0-a6
                rts

GET_LONG:       moveq   #3,d1           ; move 4-b to Longword
DUMMYLOOP:      lsl.l   #8,d0
                move.b  (a0)+,d0
                dbra    d1,DUMMYLOOP
                rts

ICE06:          bsr.s   ICE0A
                bcc.s   ICE09
                moveq   #0,d1
                bsr.s   ICE0A
                bcc.s   ICE08
                lea     ICE17(pc),a1
                moveq   #4,d3
ICE07:          move.l  -(a1),d0
                bsr.s   ICE0C
                swap    d0
                cmp.w   d0,d1
                dbne    d3,ICE07
                add.l   20(a1),d1
ICE08:          move.b  -(a5),-(a6)
                dbra    d1,ICE08
ICE09:          cmpa.l  a4,a6
                bgt.s   ICE0F
                rts
ICE0A:          add.b   d7,d7
                bne.s   ICE0B
                move.b  -(a5),d7
                addx.b  d7,d7
ICE0B:          rts
ICE0C:          moveq   #0,d1
ICE0D:          add.b   d7,d7
                bne.s   ICE0E
                move.b  -(a5),d7
                addx.b  d7,d7
ICE0E:          addx.w  d1,d1
                dbra    d0,ICE0D
                rts
ICE0F:          lea     ICE18(pc),a1
                moveq   #3,d2
ICE10:          bsr.s   ICE0A
                dbcc    d2,ICE10
                moveq   #0,d4
                moveq   #0,d1
                move.b  1(a1,d2.w),d0
                ext.w   d0
                bmi.s   ICE11
                bsr.s   ICE0C
ICE11:          move.b  6(a1,d2.w),d4
                add.w   d1,d4
                beq.s   ICE13
                lea     ICE19(pc),a1
                moveq   #1,d2
ICE12:          bsr.s   ICE0A
                dbcc    d2,ICE12
                moveq   #0,d1
                move.b  1(a1,d2.w),d0
                ext.w   d0
                bsr.s   ICE0C
                add.w   d2,d2
                add.w   6(a1,d2.w),d1
                bpl.s   ICE15
                sub.w   d4,d1
                bra.s   ICE15
ICE13:          moveq   #0,d1
                moveq   #5,d0
                moveq   #-1,d2
                bsr.s   ICE0A
                bcc.s   ICE14
                moveq   #8,d0
                moveq   #$3F,d2
ICE14:          bsr.s   ICE0C
                add.w   d2,d1
ICE15:          lea     2(a6,d4.w),a1
                adda.w  d1,a1
                move.b  -(a1),-(a6)
ICE16:          move.b  -(a1),-(a6)
                dbra    d4,ICE16
                bra     ICE06
                dc.b $7F,$FF,$00,$0E,$00,$FF,$00,$07
                dc.b $00,$07,$00,$02,$00,$03,$00,$01
                dc.b $00,$03,$00,$01
ICE17:          dc.b $00,$00,$01,$0D,$00,$00,$00,$0E
                dc.b $00,$00,$00,$07,$00,$00,$00,$04
                dc.b $00,$00,$00,$01
ICE18:          dc.b $09,$01,$00,$FF,$FF,$08,$04,$02
                dc.b $01,$00
ICE19:          dc.b $0B,$04,$07,$00,$01,$1F,$FF,$FF
                dc.b $00,$1F


                endpart
ROTATE_FILE:    >PART 'ROTATE ACCORDING TO THE FILE'
*         Reserves Memory too...
* In:     A0=address where the file is loaded
*         D0=color section 1
*         D1=color section 2
*         D2=color section 3
*         D3=rotations (16,8...)
*
* Out:    A1=address to first rotation
*         d0=words wide (1=16(=32)  2=32(=48)...)
*         d1=hight
*         d2=rotations
*         d3=lenght of all rotation in bytes
*         d4=lenght of one rotation in bytes
*         d5=height of one cell
*         d6=lenght of one animation cell..
*         d7=number of animation cells


                movem.l a0/a2-a6,-(a7)
                movea.l a0,a2
                move.w  (a0),d4
                move.w  2(a0),d5
                addq.w  #1,d4
                addq.w  #1,d5
                lsr.w   #1,d4
                mulu    d5,d4
                lea     6(a0),a0
                lea     0(a0,d4.w),a1
                bsr     COLORSWAP
                movea.l a2,a0

                move.w  d3,d2           ; rotations
                move.w  (a0),d0
                addq.w  #1,d0
                lsr.w   #4,d0
                move.w  2(a0),d1
                addq.w  #1,d1
                lea     6(a0),a0

                movem.l d0/a0,-(a7)
                addq.w  #1,d0
                mulu    d1,d0
                mulu    #12,d0
                mulu    d2,d0
                ext.l   d0
                bsr     GET_FRG_MEM
                movea.l a0,a1
                movem.l (a7)+,d0/a0

                bsr     ROTATE

                move.w  d0,d3           ; get lenght of all and on..
                addq.w  #1,d3
                mulu    d1,d3
                mulu    #12,d3
                move.w  d3,d4           ; d4=lenght of one rotation
                mulu    d2,d3           ; d3=lenght of all rotations

                move.w  d0,d7
                mulu    d1,d7
                mulu    #8,d7
                adda.w  d7,a0
                move.w  (a0),d5         ; d5=height of animation
                move.w  d5,d6
                move.w  d0,d7
                addq.w  #1,d7
                mulu    d7,d6
                mulu    #12,d6          ; d6=lenght of on animation cell

                move.w  d4,d7
                divu    d6,d7           ; d7=number of cells (norm. 1)


                movem.l (a7)+,a0/a2-a6
                rts
                endpart
ANI_MASKA_FILE: >PART 'ANI ROTATE ACCORDING TO FILE'
*         Reserves Memory too...
* In:     A0=address where the file is loaded
*         D0=color section 1
*         D1=color section 2
*         D2=color section 3
*         D3=Rotations (no function!)
*
* Out:    A1=address to first rotation
*         d0=words wide (1=16(=32)  2=32(=48)...)
*         d1=hight
*         d2=rotations
*         d3=lenght of all rotation in bytes
*         d4=lenght of one rotation in bytes
*         d5=height of one cell (same as D1, as no actuall animations..)
*         d6=lenght of one animation cell..    (=0)
*         d7=number of animation cells         (=0)
**  Observe, I refere the animations as rotations!

                movem.l a0/a2-a6,-(a7)

                movea.l a0,a2
                move.w  (a0),d4
                move.w  2(a0),d5
                addq.w  #1,d4
                addq.w  #1,d5
                lsr.w   #1,d4
                mulu    d5,d4
                lea     6(a0),a0
                lea     0(a0,d4.w),a1

                bsr     COLORSWAP
                movea.l a2,a0


                move.w  d3,d2           ; rotations (maska only!)
                move.w  (a0),d0
                addq.w  #1,d0
                move.w  d0,d6
                lsr.w   #1,d6
                lsr.w   #4,d0           ; d0=word wide
                move.w  2(a0),d1
                addq.w  #1,d1           ; d1=hight
                mulu    d1,d6
                move.w  6(a0,d6.w),d5   ; d5=cell hight

                lea     6(a0),a0

                movem.l d0/a0,-(a7)
                mulu    d1,d0
                mulu    #12,d0
                bsr     GET_FRG_MEM
                movea.l a0,a1
                movem.l (a7)+,d0/a0

                bsr     ANI_MASKA

                move.w  d0,d3
                mulu    d1,d3
                mulu    #12,d3
                move.w  d5,d4
                mulu    d0,d4
                mulu    #12,d4

                ext.l   d5
                ext.l   d1
                move.l  d1,d2
                divu    d5,d2

                move.l  d5,d1
                moveq   #0,d6           ; no animations
                moveq   #0,d7           ; no animations

*                subq.w  #1,d0
                movem.l (a7)+,a0/a2-a6
                rts
                endpart

INITLINE:       >PART 'Make Energy line data'
                move.l  #39*6,d0
                bsr     GET_FRG_MEM
                movea.l a0,a6

                moveq   #99-96,d0
                moveq   #136-96,d1
                moveq   #-1,d2
                move.l  a6,PL_DATA1+72
                movem.l d0-d2/a6,-(a7)
                movea.l a6,a0
                bsr.s   LINE
                movem.l (a7)+,d0-d2/a6
                not.l   (a6)
                not.w   4(a6)
                addq.l  #6,a6

MAKELINEMORE:
                movem.l d0-d2/a6,-(a7)
                movea.l a6,a0
                bsr.s   LINE
                movem.l (a7)+,d0-d2/a6
                addq.l  #6,a6
                addq.l  #1,d0
                cmp.w   d0,d1
                bne.s   MAKELINEMORE

                clr.l   (a6)+
                clr.w   (a6)+

********
                move.l  #39*6,d0
                bsr     GET_FRG_MEM
                movea.l a0,a6

                moveq   #183-176,d0
                moveq   #220-176,d1
                moveq   #-1,d2
                move.l  a6,PL_DATA2+72
                movem.l d0-d2/a6,-(a7)
                movea.l a6,a0
                bsr.s   LINE
                movem.l (a7)+,d0-d2/a6
                not.l   (a6)
                not.w   4(a6)
                addq.l  #6,a6


MAKELINEMORE2:  movem.l d0-d2/a6,-(a7)
                movea.l a6,a0
                bsr.s   LINE
                movem.l (a7)+,d0-d2/a6
                addq.l  #6,a6
                subq.w  #1,d1
                cmp.w   d0,d1
                bne.s   MAKELINEMORE2

                clr.l   (a6)+
                clr.w   (a6)+

                lea     INITLINE(pc),a0
                move.l  #End_InitLine-INITLINE,d0
                bsr     FREE_FRG_MEM
                rts
End_InitLine:

                endpart
                >PART 'Draw Line'
*****************************************************
**      LINJE DRAW HORISONTALT D0=START X D1=SLUT X
**      D2=M™NSTER (W)
**      A0=where line will be saved  (as 1bpl starting at d0 and $fff0)
*****************************************************
LINE:           clr.l   (a0)
                clr.w   4(a0)
                move.w  d2,d4
                move.w  #$FFFF,d7
                move.w  d0,d5
                and.w   #$000F,d5
                lsr.w   d5,d7
                and.w   d7,d4

                move.w  d0,d5
                move.w  d1,d6
                and.w   #$FFF0,d0
                and.w   #$FFF0,d6
                cmp.w   d0,d6
                beq.s   FINAL_LINE
                bsr.s   DRAWLINE

LINE_LOOP:      move.w  d2,d4
                add.w   #$0010,d0
                move.w  d1,d7
                and.w   #$FFF0,d7
                cmp.w   d0,d7
                beq.s   FINAL_LINE
                bsr.s   DRAWLINE
                bra.s   LINE_LOOP

FINAL_LINE:     move.w  #$FFFF,d7
                move.w  d1,d5
                not.w   d5
                and.w   #$000F,d5
                lsl.w   d5,d7
                and.w   d7,d4
                bsr.s   DRAWLINE
                rts


DRAWLINE:       move.w  d0,-(a7)
                lsr.w   #3,d0
                move.w  d4,0(a0,d0.w)
                move.w  (a7)+,d0
                rts
                endpart

                >PART 'SCORE CALCULATIONS'
***************************************************
**      SCORE
***************************************************

**************************************************
**      ADDITIONS RUTIN
**      A0=ADDRESS TILL TAL 1 OCH SVAR
**      A1=ADDRESS TILL TAL ATT PLUSA P
****    7 BYTES I VARJE SOM HAR TALEN 0-9
**************************************************
PLUSA:          movem.l d0-a6,-(a7)
                addq.w  #7,a0
                addq.w  #7,a1
                movea.l a0,a2
                moveq   #0,d6
                moveq   #6,d7
P_LOOP:         move.b  -(a0),d0
                add.b   -(a1),d0
                add.b   d6,d0           ; ADD CARRY
                moveq   #0,d6           ; CLEAR CARRY
                cmp.b   #9,d0           ; OVERFLOW
                bls.s   NO_CARRY        ; NO - JUMP
                move.b  #1,d6           ; SET CARRY
                sub.b   #10,d0
NO_CARRY:       move.b  d0,-(a2)        ; SAVE SUMM
                dbra    d7,P_LOOP
                movem.l (a7)+,d0-a6
                rts
                endpart
                >PART 'SCORE DRAW'
*************************************************
**      SCORE DRAW
**      MLAR BARA OM SKILLNAD (SŽTT ALLA TILL 11 OM ALLA UT)
*************************************************
SCORE_DRAW:     movea.l OLDTAL(pc),a0
                lea     SCORE1(pc),a1
                lea     TALXPOS(pc),a2
                lea     FONTTOUSE(pc),a4
                moveq   #0,d0
                moveq   #13,d7
FJORTON:        movea.l (a4)+,a5
                move.b  (a1)+,d0
                cmp.b   (a0)+,d0        ; DIGIT CHANGED ??
                beq.s   HAN_E_KLAR
                move.b  d0,-1(a0)       ; SAVE NEW DIGIT
                mulu    #10,d0          ; *10 FOR OFFSET TO CHAR
                lea     0(a5,d0.w),a5   ; A5=ADDRESS TO CHAR

                move.w  (a2),d0         ; GET X POS

                movea.l SCREEN(pc),a3
                lea     TALYPOS(a3),a3
                adda.w  d0,a3



                move.b  (a5)+,0*160(a3)
                move.b  (a5)+,1*160(a3)
                move.b  (a5)+,2*160(a3)
                move.b  (a5)+,3*160(a3)
                move.b  (a5)+,4*160(a3)
                move.b  (a5)+,5*160(a3)
                move.b  (a5)+,6*160(a3)
                move.b  (a5)+,7*160(a3)
                move.b  (a5)+,8*160(a3)
                move.b  (a5)+,9*160(a3)

HAN_E_KLAR:
                addq.w  #2,a2
                dbra    d7,FJORTON
                rts
                endpart
                >PART 'SCORE DATA'
*************************************************
**      SCORE DRAW DATA
*************************************************
TALYPOS         equ 172*160
TALXPOS:        dc.w 17+6,24+6,25+6,32+6,33+6,40+6,41+6
                dc.w 112,113,120,121,128,129,136
FONTTOUSE:
                dc.l RIGHTPLACED,RIGHTPLACED,RIGHTPLACED
                dc.l RIGHTPLACED,RIGHTPLACED,RIGHTPLACED
                dc.l RIGHTPLACED
                dc.l LEFTPLACED,LEFTPLACED,LEFTPLACED
                dc.l LEFTPLACED,LEFTPLACED,LEFTPLACED
                dc.l LEFTPLACED

OLDTAL:         dc.l OLDTAL1    ; ŽNDRAS MED SKŽRM BYTE
OLDTAL1:        dc.b 11,11,11,11,11,11,11 ; LAST UPDATE SCORE PL 1
                dc.b 11,11,11,11,11,11,11 ; OLDTAL1+7 PL 2
OLDTAL2:        dc.b 11,11,11,11,11,11,11 ; LAST UPDATE SCORE PL 1
                dc.b 11,11,11,11,11,11,11 ; OLDTAL2+7 PL 2
SCORE1:         dc.b 0,0,0,0,0,0,0 ; POŽNG PL 1 TOTALT
SCORE2:         dc.b 0,0,0,0,0,0,0 ; POŽNG PL 2 TOTALT
                even
                dc.l 0
                endpart

                >PART 'PRINT DIGITS'
* A0=address to digits to print
* a1=address to screen to start print at
PRINT_A0:       movem.l d0-a6,-(a7)
                lea     LEFTPLACED(pc),a2
GETNEXT:        moveq   #0,d0
                move.b  (a0)+,d0
                bmi.s   DONE
                mulu    #10,d0
                lea     0(a2,d0.w),a3
                movea.l a1,a4
                moveq   #9,d7
LOOP8:          move.b  (a3)+,d0
                move.b  d0,(a4)
                move.b  d0,2(a4)
                move.b  d0,4(a4)
                move.b  d0,6(a4)

                lea     160(a4),a4
                dbra    d7,LOOP8

                move.l  a1,d1
                btst    #0,d1
                bne.s   ADD7
                addq.l  #1,a1
                bra.s   GETNEXT
ADD7:           addq.l  #7,a1
                bra.s   GETNEXT
DONE:           movem.l (a7)+,d0-a6
                rts
                endpart

                >PART 'NUMBER FONT'
********************************
**      NUMBER FONT
********************************
;       16(8)*10   *10  1 BITPLANE
LEFTPLACED:
                dc.b $01,$39,$39,$39,$39,$39,$39,$39
                dc.b $39,$01,$F9,$F9,$F9,$F9,$F9,$F9
                dc.b $F9,$F9,$F9,$F9,$01,$F9,$F9,$F9
                dc.b $01,$3F,$3F,$3F,$3F,$01,$01,$F9
                dc.b $F9,$F9,$01,$F9,$F9,$F9,$F9,$01
                dc.b $39,$39,$39,$39,$01,$F9,$F9,$F9
                dc.b $F9,$F9,$01,$3F,$3F,$3F,$01,$F9
                dc.b $F9,$F9,$F9,$01,$01,$3F,$3F,$3F
                dc.b $01,$39,$39,$39,$39,$01,$01,$39
                dc.b $39,$39,$39,$F9,$F9,$F9,$F9,$F9
                dc.b $01,$39,$39,$39,$01,$39,$39,$39
                dc.b $39,$01,$01,$39,$39,$39,$01,$F9
                dc.b $F9,$F9,$F9,$01,$80,$9C,$9C,$9C
                dc.b $9C,$9C,$9C,$9C,$9C,$80,$FC,$FC
                dc.b $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
                dc.b $80,$FC,$FC,$FC,$80,$9F,$9F,$9F
                dc.b $9F,$80,$80,$FC,$FC,$FC,$80,$FC
                dc.b $FC,$FC,$FC,$80,$9C,$9C,$9C,$9C
                dc.b $80,$FC,$FC,$FC,$FC,$FC,$80,$9F
                dc.b $9F,$9F,$80,$FC,$FC,$FC,$FC,$80
                dc.b $80,$9F,$9F,$9F,$80,$9C,$9C,$9C
                dc.b $9C,$80,$80,$9C,$9C,$9C,$9C,$FC
                dc.b $FC,$FC,$FC,$FC,$80,$9C,$9C,$9C
                dc.b $80,$9C,$9C,$9C,$9C,$80,$80,$9C
                dc.b $9C,$9C,$80,$FC,$FC,$FC,$FC,$80
ENDLEFTP:

RIGHTPLACED:    ds.b ENDLEFTP-LEFTPLACED

                endpart

                >PART 'MUSIC INITs'
***************************************************
**      MUSIC INIT
***************************************************
START_MUSIC:    if PLAYMUSIC=1
                lea     MUSIC(pc),a0
                bra.s   INIT_MUSIC
INIT_MUSIC:     lea     8(a0),a1
                move.l  a1,MUSIC_JUMP
                moveq   #1,d0
                jsr     (a0)
                rts
                else
                move.l  #ONLY_RTS,MUSIC_JUMP
ONLY_RTS:       rts
                endc
                endpart

                >PART 'ACIA ROUTINE'
************************************************
**              ACIA RUTINE
************************************************
                if CURSOR=0
ACIA:           cmpi.b  #$FE,$FFFFFC02.w
                bne.s   TEST_JOY1
                move.l  #JOYSTICK0,$00000118.w
                bra.s   SKIPKEY
TEST_JOY1:      cmpi.b  #$FF,$FFFFFC02.w
                bne.s   ALL_DONE
                move.l  #JOYSTICK1,$00000118.w
                bra.s   SKIPKEY
ALL_DONE:       move.b  $FFFFFC02,KEY
SKIPKEY:        bclr    #6,$FFFFFA11.w
                rte

                else

ACIA:           cmpi.b  #$FF,$FFFFFC02.w
                bne.s   TEST_CURS
                move.l  #JOYSTICK0,$00000118.w
                bra     HEJSVEJS
TEST_CURS:      move.w  d0,-(a7)
                move.b  $FFFFFC02,d0

                cmp.b   #$4B,d0         ; left
                bne.s   NOT1
                bset    #2,JOY1
                bclr    #3,JOY1
                bra     SKIPKEY2
NOT1:           cmp.b   #$4D,d0         ; right
                bne.s   NOT2
                bset    #3,JOY1
                bclr    #2,JOY1
                bra     SKIPKEY2
NOT2:           cmp.b   #$48,d0         ; Up
                bne.s   NOT3
                bset    #0,JOY1
                bclr    #1,JOY1
                bra.s   SKIPKEY2
NOT3:           cmp.b   #$50,d0         ; Down
                bne.s   NOT4
                bset    #1,JOY1
                bclr    #0,JOY1
                bra.s   SKIPKEY2
NOT4:
                cmp.b   #$52,d0         ; Insert
                bne.s   NOT9
                bset    #7,JOY1
                bra.s   SKIPKEY2
NOT9:


                cmp.b   #$004B+$0080,d0 ; left
                bne.s   NOT5
                bclr    #2,JOY1
                bra.s   SKIPKEY2
NOT5:           cmp.b   #$004D+$0080,d0 ; right
                bne.s   NOT6
                bclr    #3,JOY1
                bra.s   SKIPKEY2
NOT6:           cmp.b   #$0048+$0080,d0 ; Up
                bne.s   NOT7
                bclr    #0,JOY1
                bra.s   SKIPKEY2
NOT7:           cmp.b   #$0050+$0080,d0 ; Down
                bne.s   NOT8
                bclr    #1,JOY1
                bra.s   SKIPKEY2
NOT8:           cmp.b   #$0052+$0080,d0 ; Insert
                bne.s   NOT10
                bclr    #7,JOY1
                bra.s   SKIPKEY2
NOT10:
                move.b  d0,KEY

SKIPKEY2:       move.w  (a7)+,d0


HEJSVEJS:       bclr    #6,$FFFFFA11.w
                rte
                endc

                endpart
                >PART 'JOYSTICK READ 0'
*************************************************
**              JOYSTICK 0
*************************************************
JOYSTICK0:      move.b  $FFFFFC02.w,JOY0
                move.l  #ACIA,$00000118.w
                bclr    #6,$FFFFFA11.w
                rte
                endpart
                >PART 'JOYSTICK READ 1'
*************************************************
**              JOYSTICK 1
*************************************************
JOYSTICK1:      move.b  $FFFFFC02.w,JOY1
                move.l  #ACIA,$00000118.w
                bclr    #6,$FFFFFA11.w
                rte
                endpart
                >PART 'JOYSTICK DATA'
*************************************************
**              DATA
*************************************************
JOY0:           dc.b 0          ; BIT 0-3 JOYSTICK DIRECTION 7 Fire
JOY1:           dc.b 0          ; BIT 0-3 JOYSTICK DIRECTION 7 Fire
                endpart


******************************************
**     MEMORY CONTROLER  (31/10-91)
******************************************

GET_FRG_MEM:    >PART 'Get Mem From Fragment List'
* D0.L   = Amount
* Out A0 =Address to memory
*  NOTE:  * Always ask for even number of bytes
*         * This is a quite time consuming rutin, get from MEM_END if
*           time is a problem.

                movem.l d1/d5-d7/a1/a5-a6,-(a7)
                movea.l MEM_TAB_PEK(pc),a6
                move.w  #MAX_MEMFRG-1,d7

                lea     -1.w,a5         ; Address on MEM_TAB to best found
                move.l  #$7F000000,d6   ; Size of best found

.FINDSUIT:      movea.l (a6)+,a1
                move.l  (a6)+,d1
                bmi.s   .NICHT
                cmp.l   d0,d1           ; Big enough?
                blt.s   .NICHT
                cmp.l   d6,d1           ; Smaller than old best?
                bge.s   .NICHT
                move.l  d1,d6
                lea     -8(a6),a5
.NICHT:         dbra    d7,.FINDSUIT

                cmpa.l  #-1,a5
                beq.s   .NOFRAG_MEM

                movea.l (a5),a0
                move.l  4(a5),d7
                cmp.l   d7,d0
                bne.s   .CHG_FRG
                move.l  #-1,(a5)        ; FRG removed
                move.l  #-1,4(a5)
                bra.s   .MEM_DONE
.CHG_FRG:       move.l  a0,(a5)         ; Fix new FRG
                add.l   d0,(a5)
                sub.l   d0,d7
                move.l  d7,4(a5)
                bra.s   .MEM_DONE

.NOFRAG_MEM:    movea.l MEM_END(pc),a0  ; Get normal mem
                add.l   d0,MEM_END

.MEM_DONE:      movem.l (a7)+,d1/d5-d7/a1/a5-a6
                rts
                endpart
FREE_FRG_MEM:   >PART 'Free Mem and put it on FRG tab'
* A0=Start Address
* D0=Lenght
*     NOTE:  * Only free even number of bytes
*            * This routine eats time!, don't release memory in your IRQ's!

                movem.l d7/a6,-(a7)

                movea.l MEM_TAB_PEK(pc),a6
                move.w  #MAX_MEMFRG-1,d7

.FIND_FREE_FRG: tst.l   4(a6)
                bpl.s   .NOT_FREE_FRG
                move.l  a0,(a6)
                move.l  d0,4(a6)
                bsr.s   CLEAN_FRG_TAB
                bra.s   .FREE_DONE
.NOT_FREE_FRG:  addq.l  #8,a6
                dbra    d7,.FIND_FREE_FRG
                illegal

.FREE_DONE:     movem.l (a7)+,d7/a6
                rts
                endpart
CLEAN_FRG_TAB:  >PART 'Clean up FRG tab'
* This rutines finds different fragmentions that actually is
* one and links them together. It also checks if fragmented memory is
* directly linked to MEM_END and then transfares the memory to free mem.
* (that is memory above MEM_END)
* This routine is called from FREE_FRG_MEM and thereby will the MEM_TAB
* always be clean.

                movem.l d0-d1/d6-a1/a4-a6,-(a7)
                movea.l MEM_TAB_PEK(pc),a4
                movea.l a4,a6

                move.w  #MAX_MEMFRG-1,d7
.LX_1:          movea.l (a6)+,a0
                move.l  (a6)+,d0
                bmi.s   .LY_1

                adda.l  d0,a0

                cmpa.l  MEM_END(pc),a0  ; Memory just below Mem_End
                bne.s   .NOT_MEM_END
                move.l  #-1,-8(a6)
                move.l  #-1,-4(a6)
                sub.l   d0,MEM_END


.NOT_MEM_END:   movea.l a4,a5
                move.w  #MAX_MEMFRG-1,d6
.LX_2:          movea.l (a5)+,a1
                move.l  (a5)+,d1
                bmi.s   .LY_2

                cmpa.l  a1,a0
                bne.s   .LY_2

                move.l  #-1,-(a5)       ; Found a link
                move.l  #-1,-(a5)
                add.l   d1,-(a6)
                subq.l  #4,a6
                bra.s   .LX_1

.LY_2:          dbra    d6,.LX_2
.LY_1:          dbra    d7,.LX_1


                movem.l (a7)+,d0-d1/d6-a1/a4-a6
                rts
                endpart
INIT_FRG_MEM:   >PART 'Init Framgment Mem Tab'
* This Resets the Fragmented memory map

                movem.l d6-d7/a6,-(a7)
                movea.l MEM_TAB_PEK(pc),a6
                move.w  #MAX_MEMFRG-1,d7
                moveq   #-1,d6
.IN_MEM:        move.l  d6,(a6)+
                move.l  d6,(a6)+
                dbra    d7,.IN_MEM

                movem.l (a7)+,d6-d7/a6
                rts
                endpart

*****************************************************
**     D A T A
*****************************************************

                >PART 'TABELLER'

**********************************************
**      OBJECT DATA
**********************************************

*  0       DC.L    ; ANI START ADDR
*  4       DC.L    ; ANI STOP ADDR
*  8       DC.W    ; ANI ADD (SPEED)
*  10      DC.W    ; 0=NO ANI 1=ANI
*  12      DC.W    ; ADD FOR ROTATION
*  14      DC.W    ; HEIGHT -1
*  16      DC.W    ; SPRITE ROUT TO USE 0=16 1=32 2=48 3=128 4=(CALC AFTER 20)
*  18      DC.W    ; NUMBER OF CRASH RECTANGELS -1
*  20      DC.W    ; NUMBER OF WORDS WIDE
*  22      DC.W    ; -- NOT USED --
*  24      DC.W    ; -- NOT USED --
*  26      DC.W    ; SHOOT X ADD
*  28      DC.W    ;       Y ADD
*  30      DC.W    ; ROTATION (0=16,1=8,2=4,3=2,4=0) (LSR TO GET RIGHT NUMBER..)
*  32      DC.W    ; EXPLOSION     X ADD
*  34      DC.W    ;               Y ADD (*160)
*  36              ; ---NOT USED---
*  64

*  REPEAT

*  64(+)   DC.W    ; CRASH X1
*  66(+)   DC.W    ;       Y1*160
*  68(+)   DC.W    ;       X2
*  70(+)   DC.W    ;       Y2*160


*  NUMBER OF CRASH RECTANGELS

*
****************************************************
**      SPRITE DATA
****************************************************

*  0       DC.W    ; OFF/ON/ERASE ONLY
*  2       DC.W    ; X
*  4       DC.W    ; Y*160
*  6       DC.L    ; AW START
*  10      DC.L    ; AW END
*  14      DC.W    ; AW ADD (SPEED)
*  16      DC.W    ; OBJ NR
*  18      DC.W    ; SHOOTING RATE
*  20      DC.W    ; BULLET TYPE
*  22      DC.L    ; POINTER ADDR BILD DATA
*  26      DC.W    ; VBL COUNT FOR ANI (-1 NO ANI)
*  28      DC.W    ; HITS LEFT UNTIL DEATH
*  30      DC.W    ; 0 NORMAL 1=WHITE
*  32      DC.W    ; CENTRERING X
*  34      DC.W    ; CENTRERING Y*160
*  36      DC.L    ; SPRITE ADDR. WHERE INJURY WILL APPEARE
*  40      DC.L    ; ADDR TO OBJECT DATA
*  44      DC.W    ; INJURY ON PLAYER WHEN COLIDATE
*  46      DC.W    ; SPRITE FLAS
*  48      DC.W    ; OR ON STATUS WHEN ENEMY IS SHOOT DOWN
*  50      DC.W    ; NOT AND ON STATUS WHEN ENEMY ESCAPE
*  52      DC.W    ; STATUS NEEDED TO HURT ENEMY
*  54      BLK.B 7 ; SCORE BCD, ONE DIGIT PER BYTE
*  61      DC.B    ; -- NOT USED --
*  62      DC.W    ; Number of add curves (ACR) -1
*   REPEAT
*  64      DC.L    ; ACR start
*  68      DC.L    ; ACR pointer
*  72      DC.L    ; ACR end
*  76      DC.W    ; Speed
*  78
*   nr of add curves

*
***********************************************
**      ENEMY DATA
***********************************************

******* NORMAL SPRITE
*  0       DC.W    ; OBJ NR (-1 JOINED SPRITE SEE SOME FUTHER DOWN)
*  2       DC.W    ; SHOOTING TYPE
*  4       DC.W    ; SHOOTING RATE
*  6       DC.W    ; HITS BEFORE DEATH
*  8       DC.W    ; X OFFSET TO ATTACK WAVE
*  10      DC.W    ; Y OFFSET TO ATTACK WAVE (*160)
*  12      DC.W    ; SPRITE FLAGS
*  14      DC.W    ; STATUS GAINED WHEN ENEMY SHOOT
*  16      DC.W    ; STATUS TAKEN WHEN ENEMY ESCAPES
*  18      DC.W    ; STATUS PLAYER NEED TO SHOOT SPRITE
*  20      BLK.B 7 ; SCORE BCD SYSTEM
*  27      DC.B    ; -- NOT USED --
*  28      DC.w    ; Injury On Player When Colidate



****** JOINED SPRITE
*  0       DC.W    -1              ; JOIN MARK
*  2       DC.W    0               ; SHOOTING TYPE
*  4       DC.W    $8000           ; SHOOTING RATE
*  6       DC.W    30              ; HITS TO KILL
*  8       DC.W    3               ; NUMBER OF JOINED SPRITES
*  10      DC.W    0               ; ADD ON ATTACKWAVE PER SPRITE (FOR MASKS)
*  12      DC.W    20              ; INJURY ON PLAYER WHEN COLIDATE
*  14      BLK.B 7                 ; SCORE BCD SYSTEM
*  21      DC.B                    ; -- NOT USED --
*  22

*** REPEAT
*  0       DC.W    4               ; OBJECT NR
*  2       DC.W    -15             ; X OFFSET TO ATTACK WAVE
*  4       DC.W    -24*160         ; Y OFFSET TO ATTACK WAVE (*160)
*  6       DC.W    %0000000000000000       ; SPRITE FLAGS
*  8       DC.W    0               ; STATUS GAINED WHEN ENEMY SHOOT
*  10      DC.W    0               ; STATUS TAKEN WHEN ENEMY ESCAPES
*  12      DC.W    0               ; STATUS PLAYER NEED TO SHOOT SPRITE
*  14

*** NUMBER OF JOINED SPRITES TIMES

*
**************************************************
**      SPRITE FLAG
**************************************************
*  BIT 0   0= BECOMES WHITE WHEN IT IS HIT
*  BIT 1   0= SPRITE DIES WHEN IT COLIDATES WITH PLAYER
*  BIT 2   0= SPRITE CAN BE SHOOT DOWN
*  BIT 3
*  BIT 4
*  BIT 5
*  BIT 6
*  BIT 7
*  BIT 8
*  BIT 9
*  BIT A
*  BIT B
*  BIT C
*  BIT D
*  BIT E
*  BIT F


****************************************************
**      SEQUENSER COMMANDS
****************************************************
*  "SP",seebelow                   ; START A SPRITE (IF POSSIBLE)
*  "SF",seebelow                   ; START A SPRITE AND DO NEXT COMMAND IMMEDETLY
*  "WS",NR_OFF_FREE_POS            ; WAIT FOR A CERTAIN NUMBERS OF FREE SPRITE POS
*  "SB",X,KIND                     ; START A BONUS AT X*16 KIND 0=ENERGY
;                        1=FIREPOWER
;                        2=SPEED UP
*  "EN"                            ; END OF LEVEL
*  "WA",TIME                       ; WAIT TIME/50 S
*  "WB"                            ; WAIT UNTIL BONUS IS TAKEN
*  "LO"                            ; EXECUTE LOOP (SEE "SL")
*  "SL",TIMES                      ; SET A LOOP (THIS ATT THE TOP AND LO AT BOTTOM)
*  "SE",ENEMIES_ON_SCREEN          ; SET MAX AMOUNT OF ENEMIES ON SCREEN
*  "SS",ENEMY_SHOOTS               ; SET MAX AMOUNT OF ENEMY SHOOTS
*  "RE"                            ; REPEAT SEQUENS
*  "CL"                            ; WAIT UNTIL ALL ENEMIES ARE GONE

* for SP and SF

* ENEMY, ATTACKWAVE, SPPED, [ACR,PUSH,SPEED]..,-1

*
*******************************************
**      LOAD IMAGE MAKE
*******************************************  !
*   0       DC.W                            ; SPRITE IMAGE NR -1 INDICATES END
*   2       DC.W                            ; ROTATIONS (16,8,4,2,1)
*   4       DC.B    "SPRITE01.ENI",0,0,0,0  ; FILE NAME
*   20      DC.L 0       ; > ADDRESS TO SPRITE IMAGE
*   24      DC.W         ; COLOR ON SEKTION 1    -1=ORGINAL COLOR
*   26      DC.W         ; COLOR ON SEKTION 2    -1=ORGINAL COLOR
*   28      DC.W         ; COLOR ON SEKTION 3    -1=ORGINAL COLOR
*   30      DC.W         ; > HIGHT
*   32      DC.W         ; > WIDTH x/16
*   34      DC.W         ; > LENGHT OF ONE ROTATION
*   36      DC.W         ; > LENGHT OF ONE CELL
*   38      DC.W         ; > NUMBER OF CELLS
*   40              ; -- NOT USED --
*   64

********************************************
**      SEQUENSER OBJECT MAKE
********************************************  !
*   0       DC.W    ; SPRITE IMAGE TO USE   -1 INDICATES END OF "OBJECT MAKE"
*   2       DC.W    ; NUMBER OF CRASH RECTANGELS (NORMALY 1)
*   4       DC.W    ; MIDPOINT      ADD X
*   6       DC.W    ;               ADD Y
*   8       DC.W    ; BULLET        ADD X
*   10      DC.W    ;               ADD Y
*   12      DC.W    ; EXPLOSION     ADD X
*   14      DC.W    ;               ADD Y
*   16      DC.W    ; ANI SPEED     (0=NO ANI)
*   18      DC.W    ; ANI TYPE
*   20      DC.W    ; SPRITING TYPE (-1 SET AFTER WIDTH) SEE 16 OBJTAB
*   22              ; -- NOT USED --
*   32

** REPEAT
*   0       DC.W    ; CRASH X1
*   2       DC.W    ;       Y1
*   4       DC.W    ;       X2
*   6       DC.W    ;       Y2
** NR OF CRASH REKTANGELS

*
***********************************************
**      PLAYER DATA
***********************************************

*  0      dc.l 0          ; 0   address to image
*  4      dc.w 0          ; 4   h”jd-1
*  6      dc.w 0          ; 6   lenght of a rotation
*  8      dc.w 0          ; 8   lowest x pos (not inc mid)
*  10     dc.w 0          ; 10  lowest y pos (not inc mid)
*  12     dc.w 0          ; 12  highest x pos (not inc mid)
*  14     dc.w 0          ; 14  highest y pos (not inc mid)
*  16     dc.w 0          ; 16  add mid x
*  18     dc.w 0          ; 18  add mid y

*  20     dc.w 0          ; 20  X-pos (not inc mid)
*  22     dc.w 134*160    ; 22  Y-Pos (not inc mid) *160
*  24     dc.w 82         ; 24  Energy 1  (shown)
*  26     dc.w 82         ; 26  Energy 2  (true)
*  28     dc.w 0          ; 28  Hit low x
*  30     dc.w 0          ; 30  Hit low y
*  32     dc.w 0          ; 32  Hit high x
*  34     dc.w 0          ; 34  Hit high y
*  36     dc.l 0          ; 36  Address to Booster image
*  40     dc.w 0          ; 40  Hight
*  42     dc.w 0          ; 42  Booster Add Left X
*  44     dc.w 0          ; 44  Booster Add Left Y
*  46     dc.w 0          ; 46  Booster Add Right X
*  48     dc.w 0          ; 48  Booster Add Right Y
*  50     dc.w 0          ; 50  Lenght of one rotation
*  52     dc.w 0          ; 52  Lenght of one animation
*  54     dc.w -1         ; 54  animation pos of left booster -1=deactive
*  56     dc.w -1         ; 56  animation pos of righ booster -1=deactive
*  58     dc.w 0          ; 58  booster ani to use if active
*  60     dc.w 0          ; 60  booster ani count

*

***********************************************
**      PLAYER LOAD FILE
***********************************************
*  0      ds.b 16         ; Name of .PLY file
*  16     ds.w 1          ; Color Section #1
*  18     ds.w 1          ; Color Section #2
*  20     ds.w 1          ; Color Section #3
*  22     ds.b 16         ; Name of .BOO file
*  38     ds.w 1          ; Color Section #1
*  40     ds.w 1          ; Color Section #2
*  42     ds.w 1          ; Color Section #3
*  44     ds.w 1          ; Lowest X for player
*  46     ds.w 1          ; Lowest Y for player
*  48     ds.w 1          ; Highest X for player
*  50     ds.w 1          ; Highest Y for player
*  52     ds.w 1          ; Mid X
*  54     ds.w 1          ; Mid Y
*  56     ds.w 1          ; Player crash low X
*  58     ds.w 1          ; Player crash low Y
*  60     ds.w 1          ; Player crash high X
*  62     ds.w 1          ; Player crash high Y
*  64     ds.w 1          ; Boost Pos (down) Left  X
*  66     ds.w 1          ; Boost Pos (down) Left  Y
*  68     ds.w 1          ; Boost Pos (down) right  X
*  70     ds.w 1          ; Boost Pos (down) right  Y

*
***********************************************
**      WEAPON LOOK TAB  (32 Bytes)
**
**      used for knowig what weapons that's
**      already rotated and the data about them
***********************************************
*                dc.l 0          ; 0   Address to image       (comp)
*                dc.w 0          ; 4   Hight                  (comp)
*                dc.w 0          ; 6   Rotations
*                dc.w 0          ; 8   Rotations as LSR       (comp)
*                dc.w 0          ; 10  Sprite rout to use     (comp)
*                dc.w 0          ; 12  width in words         (comp)
*                dc.w 0          ; 14  col section 1
*                dc.w 0          ; 16  col section 2
*                dc.w 0          ; 18  col section 3
*                dc.w 0          ; 20  add for next rotation  (comp)
*                dc.w 0          ; 22  add for next animation (comp)
*                dc.l 0          ; 24  Address to orginal(get)
*
*                ds.b 32-28


***********************************************
**      WEAPON CREATE TAB  (32 Bytes)
**
**      level dependig tabell, says what weapon
**      that's to be used on a specifican player
***********************************************
*                dc.w 0          ; 0   Weapon Look to use
*                dc.l W_INIT_1   ; 2   Init rout
*                dc.l W_MOVE_1   ; 6   Move rout
*                dc.l W_NEW__1   ; 10  New rout
*                dc.l W_DRAW_1   ; 14  Draw rout
*
*                ds.b 32-18


                endpart

                >PART 'SLUMPTAL'
SLUMPPOINTER:   dc.l SLUMP
SLUMP:
                dc.w $F3B4,$EF6B,$D24B,$FE9F,$2BF8,$9FD9,$F967,$9E3E,$A12F,$1F72,$D9B3
                dc.w $97F0,$DE04,$5672,$2DBC,$7E4F,$CFE4,$08D7,$D0CE,$25B8,$72FA,$125B
                dc.w $4AF4,$4046,$3E34,$627B,$1CFC,$B9D7,$4F3C,$B873,$CC70,$D405,$567F
                dc.w $1F3E,$AF9D,$022D,$4329,$299A,$798E,$856A,$AF25,$EE01,$8610,$C89A
                dc.w $0B20,$C2AF,$E5AF,$7C57,$8A86,$B9A2,$29B7,$72FE,$CF83,$DC94,$F034
                dc.w $3CAA,$5702,$2902,$2FF1,$8339,$A4B0,$4C28,$447B,$2645,$2EF9,$1F01
                dc.w $BA1E,$172B,$0B09,$E24A,$D9E6,$F506,$58CB,$3A7F,$F59E,$68B4,$6EEC
                dc.w $EBDC,$73D3,$40CF,$C6D8,$565D,$9BD1,$4DB4,$A8BB,$B1BD,$21A3,$FD7E
                dc.w $9781,$0979,$7217,$B80B,$7CD5,$F8CD,$BEB7,$FAF5,$9524,$26B4,$C9CF
                dc.w $3598,$1B99,$81EB,$726D,$6512,$B622,$3CEE,$005B,$703D,$A169,$89F9
                dc.w $3026,$43B7,$9CDB,$1708,$FF1A,$ADD9,$96A3,$49D6,$3743,$FAC2,$17AF
                dc.w $3BE0,$BB6C,$504C,$6FA9,$7661,$9322,$CA14,$A0FE,$6E57,$B6B1,$5576
                dc.w $0CDA,$C07C,$9B24,$4D8E,$DF28,$2D4D,$7E49,$D737,$3A95,$5506,$72AA
                dc.w $FD0E,$248D,$33A2,$2B93,$8B6F,$313C,$5CDF,$8912,$AC76,$EF8D,$F837
                dc.w $E3F1,$43FE,$152D,$7CE6,$19BD,$0BA4,$6A88,$2DEA,$58C2,$6EC4,$76CA
                dc.w $55FD,$AC0C,$267A,$EBDE,$439C,$4766,$95A1,$D272,$0503,$935D,$E4D6
                dc.w $75F0,$E42D,$F93D,$DE75,$1084,$A2D7,$6F11,$8A9A,$371C,$767D,$C3A7
                dc.w $8B20,$0562,$C45B,$AA89,$37A4,$09C3,$9D6D,$8803,$7982,$F16A,$FA6E
                dc.w $FD23,$67D6,$F445,$B7DB,$33B3,$A37B,$00FE,$51F0,$EA40,$730E,$A902
                dc.w $60A8,$4016,$9EEB,$CC7D,$D3C0,$4141,$0D2E,$065A,$EEB4,$328C,$1DB2
                dc.w $D846,$04C0,$9D84,$C614,$96AD,$F4E0,$1C75,$6DB0,$14BB,$65CF,$E66A
                dc.w $89A2,$105B,$C20A,$1B31,$F8C5,$5E3A,$F3CD,$CF54,$1FB6,$D5C4,$E113
                dc.w $D820,$C4D1,$FD25,$A799,$57A0,$AC32,$7548,$98DB,$08A1,$F3B4,$25DB
                dc.w $F615,$4AAF,$2EF4,$2947,$6C42,$EE16,$434E,$78BB,$5020,$BFE2,$03DD
                dc.w $5822,$9A29,$D5DE,$8D7F,$8227,$A299,$9A97,$62CE,$1437,$9D6E,$9959
                dc.w $4827,$3A7D,$D662,$0A2F,$DFA5,$9BE7,$ACF2,$1DE7,$0526,$861F,$505A
                dc.w $0A0B,$EA44,$D992,$3B95,$D4E8,$F25C,$B56C,$7161,$E189,$4E89,$E398
                dc.w $7838,$3BBB,$59A9
ENDSLUMP:                               ; FOLLOWED BY SAFTY SLUMP NUMBERS
                dc.w $F3B4,$EF6B,$D24B,$FE9F,$2BF8,$9FD9,$F967,$9E3E,$A12F,$1F72,$D9B3
                dc.w $97F0,$DE04,$5672,$2DBC,$7E4F,$CFE4,$08D7,$D0CE,$25B8,$72FA,$125B
                dc.w $4AF4,$4046,$3E34,$627B,$1CFC,$B9D7,$4F3C,$B873,$CC70,$D405,$567F
                dc.w $1F3E,$AF9D,$022D,$4329,$299A,$798E,$856A,$AF25,$EE01,$8610,$C89A
                dc.w $0B20,$C2AF,$E5AF,$7C57,$8A86,$B9A2,$29B7,$72FE,$CF83,$DC94,$F034
                dc.w $3CAA,$5702,$2902,$2FF1,$8339,$A4B0,$4C28,$447B,$2645,$2EF9,$1F01
                dc.w $BA1E,$172B,$0B09,$E24A,$D9E6,$F506,$58CB,$3A7F,$F59E,$68B4,$6EEC
                dc.w $EBDC,$73D3,$40CF,$C6D8,$565D,$9BD1,$4DB4,$A8BB,$B1BD,$21A3,$FD7E
                dc.w $9781,$0979,$7217,$B80B,$7CD5,$F8CD,$BEB7,$FAF5,$9524,$26B4,$C9CF
                endpart

                >PART 'Peletter'

*PAL2:           dc.w $0000,$0700,$0000,$0000,$0000,$0000,$0000,$0000
*                dc.w $0000,$0000,$0000,$0004,$0026,$0237,$0357,$0777

*PAL3:           dc.w $0000,$0345,$0567,$0020,$0030,$0050,$0070,$0210
*                dc.w $0320,$0530,$0750,$0012,$0123,$0234,$0456,$0777

PAL1:           dc.w $0000,$0020,$0030,$0050,$0070,$0210,$0320,$0530
                dc.w $0750,$0012,$0123,$0234,$0345,$0456,$0567,$0777
                endpart


MOTSKOTT1:      ibytes 'BALL7_R.SHO'


*********************************       ENEMY SHOOTS
ESHOOT:         ds.w ES         ; 0  0=OFF 1=ON 2=JUST CLEAR NO DRAW
                ds.w ES         ; 1  BIT 0-3 DECIMAL (LSR.W #4 F™R HELTAL) X
                ds.w ES         ; 2  BIT 0-3 DECIMAL (LSR.W #4 F™R HELTAL) Y
                ds.w ES         ; 3  0-2 NORMAL WITH DIFFERENT COLOR (TYPE)
                ds.w ES         ; 4  BIT 0-3 DECIMAL X ADD
                ds.w ES         ; 5  BIT 0-3 DECIMAL Y ADD
                ds.w ES         ; 6  XPOS  (COLISION)
                ds.w ES         ; 7  Y ADDR (COLISION)
*********************************
OBJECTTAB:      ds.l 64
SPRITETAB:      ds.l 64
PODTAB:         ds.l 16
POD_OUT_TAB:    ds.l 8
*******************************************

                >PART 'AttackWavce Tab'
AWTAB:          dc.l AW1,AW2    ; 0
                dc.l AW2,AW3
                dc.l AW3,AW4
                dc.l AW4,AW5
                dc.l AW5,AW6
                dc.l AW6,AW7
                dc.l AW7,AW8
                dc.l AW8,AW9
                dc.l AW9,AW10
                dc.l AW10,AW11
                dc.l AW11,AW12
                dc.l AW12,AW13
                dc.l AW13,AW14
                dc.l AW14,AW15
                dc.l AW15,AW16
                dc.l AW16,AW17
                dc.l AW17,AW18
                dc.l AW18,AW19
                dc.l AW19,AW20
                dc.l AW20,AW21

ACRTAB:         dc.l ACR1,ACR2
                dc.l ACR2,ACR3
                dc.l ACR3,ACR4
                dc.l ACR4,ACR5
                dc.l ACR5,ACR6
                dc.l ACR6,ACR7
                dc.l ACR7,ACR8
                dc.l ACR8,ACR9
                endpart

*******************************************

                >PART 'Enemy Data'

ENEMYTAB:       dc.l ENEMY0,ENEMY1,ENEMY2,ENEMY3
                dc.l ENEMY4,ENEMY5,ENEMY6,ENEMY7,ENEMY8
                dc.l ENEMY9,ENEMY10,ENEMY11,ENEMY12,ENEMY13,ENEMY14
                dc.l ENEMY15
ENEMY0:
                dc.w 0          ; Enemy 0   Sl„nda
                dc.w 0
                dc.w $2000
                dc.w 5
                dc.w 2
                dc.w 0
                dc.w 20
                dc.b 0,0,0,0,0,4,0
                dc.b 0

                dc.w 1
                dc.w -64
                dc.w -15
                dc.w 0
                dc.l 0
                dc.l $FFFFFFFF
                dc.l 0
                dc.l -1

                dc.w 2
                dc.w -16
                dc.w -53
                dc.w 0
                dc.l 0
                dc.l $FFFFFFFF
                dc.l 0
                dc.l -1

ENEMY1:

ENEMY2:         dc.w 0          ; Enemy 2    mask
                dc.w 0
                dc.w $8000
                dc.w 7
                dc.w 5
                dc.w 1
                dc.w 10
                dc.b 0,0,0,0,0,5,0
                dc.b 0


                dc.w 5
                dc.w -15
                dc.w -25
                dc.w 0
                dc.l 0
                dc.l -1
                dc.l 0
                dc.l -1

                dc.w 4
                dc.w -15
                dc.w -17
                dc.w 0
                dc.l 0
                dc.l -1
                dc.l 0
                dc.l -1

                dc.w 4
                dc.w -15
                dc.w -14
                dc.w 0
                dc.l 0
                dc.l -1
                dc.l 0
                dc.l -1

                dc.w 4
                dc.w -15
                dc.w -11
                dc.w 0
                dc.l 0
                dc.l -1
                dc.l 0
                dc.l -1

                dc.w 3
                dc.w -15
                dc.w -7
                dc.w 0
                dc.l 1
                dc.l -1
                dc.l 0
                dc.l -1


ENEMY3:
                dc.w 0          ; Enemy 0   tagg
                dc.w 0
                dc.w $0000
                dc.w 1
                dc.w 3
                dc.w 0
                dc.w 2
                dc.b 0,0,0,0,0,1,0
                dc.b 0

                dc.w 6
                dc.w 0
                dc.w 0
                dc.w %0000000001000110
                dc.l 0,-1,0,-1

                dc.w 7
                dc.w 32
                dc.w -23
                dc.w %0000000001000110
                dc.l 0,-1,0,-1

                dc.w 8
                dc.w 80
                dc.w -56
                dc.w %0000000001000110
                dc.l 0,-1,0,-1


ENEMY4:         dc.w 9          ; Enemy 4  blurr
                dc.w 0
                dc.w $A000
                dc.w 3
                dc.w -14
                dc.w -15
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,2,0
                dc.b 0
                dc.w 2

ENEMY5:         dc.w 10         ; Enemy 5  skalbagge
                dc.w 0
                dc.w $A000
                dc.w 3
                dc.w -16
                dc.w -10
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,2,0
                dc.b 0
                dc.w 2

ENEMY6:         dc.w 11         ; Enemy 6  Kr„fta
                dc.w 0
                dc.w $2000
                dc.w 6
                dc.w -15
                dc.w -18
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,5,0
                dc.b 0
                dc.w 2

ENEMY7:         dc.w 12         ; Enemy 7  Fast ful
                dc.w 0
                dc.w $A000
                dc.w 2
                dc.w -16
                dc.w -8
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,2,0
                dc.b 0
                dc.w 1

ENEMY8:

ENEMY9:         dc.w 13         ; Horn bl„ckfisk
                dc.w 0
                dc.w $0000
                dc.w 5
                dc.w -7
                dc.w -36
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,2,0
                dc.b 0
                dc.w 2

ENEMY10:        dc.w 14         ;  Droid
                dc.w 0
                dc.w $4000
                dc.w 1
                dc.w -5
                dc.w -5
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,1,0
                dc.b 0
                dc.w 2

ENEMY11:        dc.w 15         ;   Small1
                dc.w 0
                dc.w $4000
                dc.w 1
                dc.w -5
                dc.w -8
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,0,5
                dc.b 0
                dc.w 1

ENEMY12:        dc.w 16         ;   Small2
                dc.w 0
                dc.w $4000
                dc.w 1
                dc.w -8
                dc.w -6
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,0,5
                dc.b 0
                dc.w 1

ENEMY13:        dc.w 17         ;  Small Bagge
                dc.w 0
                dc.w $4000
                dc.w 1
                dc.w -8
                dc.w -5
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,0,5
                dc.b 0
                dc.w 1

ENEMY14:        dc.w 18         ;  Small Bagge
                dc.w 0
                dc.w $4000
                dc.w 1
                dc.w -8
                dc.w -5
                dc.w %0000000000000000
                dc.l 0,-1,0,-1
                dc.b 0,0,0,0,0,1,5
                dc.b 0
                dc.w 1

ENEMY15:        dc.w -1         ; 0  Obejct Nr (0=Joined) <0 O-Ani
                dc.w 0          ; 2  * Bullet Type
                dc.w 0          ; 4  * Shooting Rate
                dc.w 4          ; 6  Hits before Death
                dc.w 0          ; 8  * Center X
                dc.w 0          ; 10 * Center X
                dc.w 0          ; 12 * Sprite Flags
                dc.l 0          ; 14 Or when ShootDown
                dc.l -1         ; 18 And on status if escapes
                dc.l 0          ; 22 And test if can shoot down
                dc.l -1         ; 26 And test if selfdestruct
                dc.b 0,0,0,0,0,0,3 ; 30 Score
                dc.b 0          ; 31 -Reserved-
                dc.w 3          ; 32 Injury on player when colidate

                endpart
                >PART 'Oani Data'
OANITAB:        dc.w 0
                dc.w OANI1-OANITAB
OANI1:
                dc.w 9          ; 0 Obj
                dc.w -16        ; 2 Center X
                dc.w -10        ; 4 Center Y
                dc.w 10         ; 6 Count
                dc.w 0          ; 8 Sprite Flags
                dc.w 0          ; A Shooting Rate
                dc.w 0          ; C Bullet Type
                dc.w 0          ; E -Reserved-

                dc.w 10         ; 0 Obj
                dc.w -16        ; 2 Center X
                dc.w -10        ; 4 Center Y
                dc.w 10         ; 6 Count
                dc.w 0          ; 8 Sprite Flags
                dc.w 0          ; A Shooting Rate
                dc.w 0          ; C Bullet Type
                dc.w 0          ; E -Reserved-

                dc.w -1

                endpart
*******************************************
VBLFLAG:        dc.w 0          ; F™R FLEXIBLE VBL
SFLAG:          dc.w 0          ; HLLER REDA P DOM TV SKŽRMARNA
SCREEN:         dc.l 0          ; ADDRESS TILL SKŽRM SOM UPPDATERAS
SCREEN1:        dc.l 0
SCREEN2:        dc.l 0
*************************************   BONUS SPRITE DATA
BONUSFLAG:      dc.w 0
BONUSADDX:      dc.w 0
BONUSY:         dc.w 0
BONUSADDANI:    dc.w 128
BONUSTURNPOS:   dc.l 0          * DC.L GBONUS
BONUSTURNNEG:   dc.l 0          * DC.L GBONUS+640
BONUSADDR:      dc.l 0          * DC.L GBONUS
BONUSWAIT:      dc.w 0
****************************
SPEEDTAB:       dc.l SPEED1,SPEED2,SPEED3,-1
SPEED1:         dc.w 2,3,4,5,6,8,$00FF
SPEED2:         dc.w 3,4,6,7,9,10,$00FF
SPEED3:         dc.w 4,6,8,9,11,12,$00FF
****************************
SCROLLADDR:     dc.l 0
BACKGROUNDADDR: dc.l 0
****************************
                >PART 'COS & SIN'
SIN_WORD_10:    dc.w 0,5690,11207,16384,21062,25101,28377,30791,32270
COS_WORD_10:    dc.w 32767,32270,30791,28377,25101,21062,16384,11207,5690
                dc.w 0,-5690,-11207,-16384,-21062,-25101,-28377,-30791,-32270
                dc.w -32767,-32270,-30791,-28377,-25101,-21062,-16384,-11207,-5690
                dc.w 0,5690,11207,16384,21062,25101,28377,30791,32270
                endpart

                >PART 'IMAGE MAKE DATA'
IMAGEMAKE:

************  Sl„nda

                dc.w 0          ; image nr
                dc.w 1          ; rotations
                dc.b "SLŽ_BODY.EIM",0,0,0,0 ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30
**
                dc.w 1          ; image nr
                dc.w 1          ; rotations
                dc.b "SLŽ_SVAN.EIM",0,0,0,0 ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30


************ Mask

**
                dc.w 2          ; image nr
                dc.w 16         ; rotations
                dc.b "MASK_HEA.EIM",0,"   " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30
**
                dc.w 3          ; image nr
                dc.w 16         ; rotations
                dc.b "MASK_BOD.EIM",0,"   " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30
**
                dc.w 4          ; image nr
                dc.w 16         ; rotations
                dc.b "MASK_TAI.EIM",0,"   " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30


************ tagg


                dc.w 5          ; image nr
                dc.w 4          ; rotations
                dc.b "TAGG1.EIM",0,"      " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

                dc.w 6          ; image nr
                dc.w 4          ; rotations
                dc.b "TAGG2.EIM",0,"      " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

                dc.w 7          ; image nr
                dc.w 4          ; rotations
                dc.b "TAGG3.EIM",0,"      " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30


************ Blurr ful


                dc.w 8          ; image nr
                dc.w 16         ; rotations
                dc.b "BLURR.EIM",0,"      " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30


************ Skalbagge

                dc.w 9          ; image nr
                dc.w 16         ; rotations
                dc.b "SKALBAGG.EIM",0,"   " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30


************ Kr„fta

                dc.w 10         ; image nr
                dc.w 16         ; rotations
                dc.b "KRŽFTA.EIM",0,"     " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

************ Fast ful

                dc.w 11         ; image nr
                dc.w 16         ; rotations
                dc.b "FAST.EIM",0,"       " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30



************ Hornbl„ckfisk

                dc.w 12         ; image nr
                dc.w 1          ; rotations
                dc.b "HORN.EIM",0,"       " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

************ Small droid

                dc.w 13         ; image nr
                dc.w 16         ; rotations
                dc.b "S_DROID.DRO",0,"    " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

************ Small ship1

                dc.w 14         ; image nr
                dc.w 16         ; rotations
                dc.b "SMALL1.EIM",0,"     " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

************ Small Ship2

                dc.w 15         ; image nr
                dc.w 16         ; rotations
                dc.b "SMALL2.EIM",0,"     " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

************ Small skalbagge

                dc.w 16         ; image nr
                dc.w 16         ; rotations
                dc.b "SMALL3.EIM",0,"     " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

************ Snurrande Animerad roterad


                dc.w 17         ; image nr
                dc.w -1         ; rotations
                dc.b "SNURRIG.EIM",0,"    " ; name of file
                dc.l 0
                dc.w 0          ; color 1
                dc.w 1          ; color 2
                dc.w 2          ; color 3
                ds.b 64-30

                dc.w -1


                endpart
                >PART 'OBJECT MAKE DATA'
OBJECTMAKE:
******** Sl„nda 1->

                dc.w 0          ; image to use
                dc.w 2          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 63         ; bullet point  X
                dc.w 32         ; bullet point  Y
                dc.w 64         ; explo point  X
                dc.w 15         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w 1          ; Ext Explo
                ds.b 32-24
                dc.w 3,3,124,32
                dc.w 60,-36,67,0

                dc.w 32,15,1,0
                dc.w 96,15,1,0

**
                dc.w 1          ; image to use
                dc.w 0          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 0          ; bullet point  X
                dc.w 0          ; bullet point  Y
                dc.w 4          ; explo point  X
                dc.w 21         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24

****** Mask  3->
                dc.w 2          ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 16         ; bullet point  X
                dc.w 12         ; bullet point  Y
                dc.w 16         ; explo point  X
                dc.w 12         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 5,6,26,18  ; crash

**
                dc.w 3          ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 16         ; bullet point  X
                dc.w 12         ; bullet point  Y
                dc.w 16         ; explo point  X
                dc.w 12         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 5,6,24,12  ; crash

**
                dc.w 4          ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 16         ; bullet point  X
                dc.w 12         ; bullet point  Y
                dc.w 16         ; explo point  X
                dc.w 12         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 10,7,18,12 ; crash


********      TAGG   6->

                dc.w 5          ; image to use
                dc.w 7          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 0          ; bullet point  X
                dc.w 0          ; bullet point  Y
                dc.w 0          ; explo point  X
                dc.w 0          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 0,28,8,35
                dc.w 18,0,31,21
                dc.w 34,-4,73,6
                dc.w 61,-15,130,-5
                dc.w 84,-56,116,7
                dc.w 142,-4,164,4
                dc.w 116,-49,223,-15

                dc.w 6          ; image to use
                dc.w 0          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 0          ; bullet point  X
                dc.w 0          ; bullet point  Y
                dc.w 0          ; explo point  X
                dc.w 0          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24

                dc.w 7          ; image to use
                dc.w 0          ; number of crash rectangles
                dc.w 0          ; mid point  X
                dc.w 0          ; mid point  Y
                dc.w 0          ; bullet point  X
                dc.w 0          ; bullet point  Y
                dc.w 0          ; explo point  X
                dc.w 0          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24


**** Blurr ful  9

                dc.w 8          ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 14         ; bullet point  X
                dc.w 19         ; bullet point  Y
                dc.w 14         ; explo point  X
                dc.w 15         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 5          ; crash x1
                dc.w 4          ; crash y1
                dc.w 24         ; crash x2
                dc.w 25         ; crash y2


**** Skalbagge 10

                dc.w 9          ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 15         ; bullet point  X
                dc.w 15         ; bullet point  Y
                dc.w 16         ; explo point  X
                dc.w 16         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 4          ; crash x1
                dc.w 2          ; crash y1
                dc.w 28         ; crash x2
                dc.w 20         ; crash y2

**** Kr„fta  11

                dc.w 10         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 15         ; bullet point  X
                dc.w 25         ; bullet point  Y
                dc.w 15         ; explo point  X
                dc.w 18         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 4          ; crash x1
                dc.w 4          ; crash y1
                dc.w 27         ; crash x2
                dc.w 38         ; crash y2

**** Fast ful  12

                dc.w 11         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 16         ; bullet point  X
                dc.w 8          ; bullet point  Y
                dc.w 16         ; explo point  X
                dc.w 8          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 5          ; crash x1
                dc.w 2          ; crash y1
                dc.w 26         ; crash x2
                dc.w 14         ; crash y2

**** Horn bl„ckfisk  13

                dc.w 12         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 7          ; bullet point  X
                dc.w 63         ; bullet point  Y
                dc.w 7          ; explo point  X
                dc.w 36         ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 1          ; crash x1
                dc.w 3          ; crash y1
                dc.w 14         ; crash x2
                dc.w 73         ; crash y2

**** Droid  14

                dc.w 13         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 5          ; bullet point  X
                dc.w 5          ; bullet point  Y
                dc.w 5          ; explo point  X
                dc.w 5          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 0,0,9,9    ; crash

**** Small ship1 15

                dc.w 14         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 6          ; bullet point  X
                dc.w 10         ; bullet point  Y
                dc.w 8          ; explo point  X
                dc.w 6          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 0          ; crash x1
                dc.w 0          ; crash y1
                dc.w 11         ; crash x2
                dc.w 13         ; crash y2

**** SmallShip2 16

                dc.w 15         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 8          ; bullet point  X
                dc.w 6          ; bullet point  Y
                dc.w 8          ; explo point  X
                dc.w 6          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 0          ; crash x1
                dc.w 0          ; crash y1
                dc.w 15         ; crash x2
                dc.w 11         ; crash y2

**** Small Skalbagge 17

                dc.w 16         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 8          ; bullet point  X
                dc.w 8          ; bullet point  Y
                dc.w 8          ; explo point  X
                dc.w 5          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 1          ; crash x1
                dc.w 1          ; crash y1
                dc.w 14         ; crash x2
                dc.w 11         ; crash y2


**** Snurrig Ani rot. 18

                dc.w 17         ; image to use
                dc.w 1          ; number of crash rectangles
                dc.w 0          ; *
                dc.w 0          ; *
                dc.w 8          ; bullet point  X
                dc.w 8          ; bullet point  Y
                dc.w 8          ; explo point  X
                dc.w 5          ; explo point  Y
                dc.w 0          ; ani speed (0=NONE)
                dc.w 0          ; ani type
                dc.w -1         ; spriting type
                dc.w -1         ; Ext Explo
                ds.b 32-24
                dc.w 1          ; crash x1
                dc.w 1          ; crash y1
                dc.w 14         ; crash x2
                dc.w 13         ; crash y2

                dc.w -1

                endpart

                >PART 'PLAYER DATA'
*************************************   PLAYERS DATA
PL_DATA1:       ds.b 128
PL_DATA2:       ds.b 128

PL_DATAN1:      dc.l 0          ; 0   address to image
                dc.w 0          ; 4   h”jd-1
                dc.w 0          ; 6   lenght of a rotation
                dc.w 0          ; 8   lowest x pos (not inc mid)
                dc.w 0          ; 10  lowest y pos (not inc mid)
                dc.w 0          ; 12  highest x pos (not inc mid)
                dc.w 0          ; 14  highest y pos (not inc mid)
                dc.w 0          ; 16  add mid x
                dc.w 0          ; 18  add mid y
                dc.w 0          ; 20  X-pos (not inc mid)
                dc.w 130*160    ; 22  Y-Pos (not inc mid)
                dc.w 38         ; 24  Energy 1  (shown)
                dc.w 38         ; 26  Energy 2  (true)
                dc.w 0          ; 28  Hit low x
                dc.w 0          ; 30  Hit low y
                dc.w 0          ; 32  Hit high x
                dc.w 0          ; 34  Hit high y
                dc.l 0          ; 36  Address to Booster image
                dc.w 0          ; 40  Hight
                dc.w 0          ; 42  Booster Add Left X
                dc.w 0          ; 44  Booster Add Left Y
                dc.w 0          ; 46  Booster Add Right X
                dc.w 0          ; 48  Booster Add Right Y
                dc.w 0          ; 50  Lenght of one rotation
                dc.w 0          ; 52  Lenght of one animation
                dc.w -1         ; 54  animation pos of left booster -1=deactive
                dc.w -1         ; 56  animation pos of righ booster -1=deactive
                dc.w 0          ; 58  booster ani to use if active
                dc.w 0          ; 60  booster ani count
                dc.l 0          ; 62  Address to "weapon" tabel
                dc.l SCORE1     ; 66  Address to score
                dc.w 172*160+54 ; 70  Add to get to Energy Pos
                dc.l 0          ; 72  Address to line data (3*.w and) 37*(3*.w or)
                dc.w 0          ; 76  -1=Active    0= Dead
                dc.l JOY1       ; 78  Address where JOYstick data can be found
                dc.l SPEEDTAB   ; 82  Ship Speed Curve beeing Used Pointer (?!)
                dc.l SPEED1     ; 86  Pointer on Speed Curve
                dc.w 3          ; 90  AutoMax  H”gre v„rden l„ngre tid mellan..
                dc.w 0          ; 92  AutoCount (0=Fire Possible)
                dc.w -1         ; 94  Auto Fire Possible (0=no  -1=Yes)
                dc.l 0          ; 96  Flags!
                dc.l 0          ; 100 Address to explo tab (0 if not exlo yet)
END_PLDATAN1:

PL_DATAN2:      dc.l 0          ; 0   address to image
                dc.w 0          ; 4   h”jd-1
                dc.w 0          ; 6   lenght of a rotation
                dc.w 0          ; 8   lowest x pos (not inc mid)
                dc.w 0          ; 10  lowest y pos (not inc mid)
                dc.w 0          ; 12  highest x pos (not inc mid)
                dc.w 0          ; 14  highest y pos (not inc mid)
                dc.w 0          ; 16  add mid x
                dc.w 0          ; 18  add mid y
                dc.w 200        ; 20  X-pos (not inc mid)
                dc.w 130*160    ; 22  Y-Pos (not inc mid)
                dc.w 38         ; 24  Energy 1  (shown)
                dc.w 38         ; 26  Energy 2  (true)
                dc.w 0          ; 28  Hit low x
                dc.w 0          ; 30  Hit low y
                dc.w 0          ; 32  Hit high x
                dc.w 0          ; 34  Hit high y
                dc.l 0          ; 36  Address to Booster image
                dc.w 0          ; 40  Hight
                dc.w 0          ; 42  Booster Add Left X
                dc.w 0          ; 44  Booster Add Left Y
                dc.w 0          ; 46  Booster Add Right X
                dc.w 0          ; 48  Booster Add Right Y
                dc.w 0          ; 50  Lenght of one rotation
                dc.w 0          ; 52  Lenght of one animation
                dc.w -1         ; 54  animation pos of left booster -1=deactive
                dc.w -1         ; 56  animation pos of righ booster -1=deactive
                dc.w 0          ; 58  booster ani to use if active
                dc.w 0          ; 60  booster ani count
                dc.l 0          ; 62  Address to "weapon" tabel
                dc.l SCORE2     ; 66  Address to score
                dc.w 172*160+88 ; 70  Add to get to Energy Pos
                dc.l 0          ; 72  Address to line data (3*.w and) 37*(3*.w or)
                dc.w 0          ; 76  -1=Active    0= Dead
                dc.l JOY0       ; 78  Address where JOYstick data can be found
                dc.l SPEEDTAB   ; 82  Ship Speed Curve beeing Used Pointer (?!)
                dc.l SPEED1     ; 86  Pointer on Speed Curve
                dc.w 3          ; 90  AutoMax  H”gre v„rden l„ngre tid mellan..
                dc.w 0          ; 92  AutoCount (0=Fire Possible)
                dc.w -1         ; 94  Auto Fire Possible (0=no  -1=Yes)
                dc.l 0          ; 96  Flags!
                dc.l 0          ; 100 Address to explo tab (0 if not exlo yet)


*                dc.l 0        ; Address for moving all bullets of this kind
*                dc.l 0        ; Address for testing if NEW is to be fired
*                dc.l 0        ; Address for drawing all bullets of this kind
*                dc.l 0        ; Address to data

                endpart

LEVEL_PODMAKE:  >PART 'PodMake'
                dc.w 0          ;0
                dc.w 0          ;2
                dc.w 0          ;4
                dc.b "pod.pod",0,"      "
                dc.w 1          ;20
                dc.w 2          ;22
                dc.w 2          ;24
                dc.w 1          ;26
                dc.w 0          ;28
                dc.w 0          ;30
                dc.w 0          ;32 hit x1
                dc.w 0          ;34     y1
                dc.w 15         ;36     x2
                dc.w 15         ;38     y2


                dc.w 0          ;0
                dc.w 0          ;2
                dc.w 0          ;4
                dc.b "pod.pod",0,"      "
                dc.w 1          ;20
                dc.w 2          ;22
                dc.w 3          ;24
                dc.w 2          ;26
                dc.w 0          ;28
                dc.w 1          ;30
                dc.w 0          ;32 hit x1
                dc.w 0          ;34     y1
                dc.w 15         ;36     x2
                dc.w 15         ;38     y2


                dc.w 0          ;0
                dc.w 0          ;2
                dc.w 0          ;4
                dc.b "pod.pod",0,"      "
                dc.w 0          ;20
                dc.w 0          ;22
                dc.w 0          ;24
                dc.w 2          ;26
                dc.w 0          ;28
                dc.w 2          ;30
                dc.w 0          ;32 hit x1
                dc.w 0          ;34     y1
                dc.w 15         ;36     x2
                dc.w 15         ;38     y2

                dc.w 0          ;0
                dc.w 0          ;2
                dc.w 0          ;4
                dc.b "pod.pod",0,"      "
                dc.w 0          ;20
                dc.w 0          ;22
                dc.w 0          ;24
                dc.w 2          ;26
                dc.w 0          ;28
                dc.w 3          ;30
                dc.w 0          ;32 hit x1
                dc.w 0          ;34     y1
                dc.w 15         ;36     x2
                dc.w 15         ;38     y2

                dc.w -1
                ds.b 38

                endpart

*************************************
                >PART 'Weapon Player 11'

WEAPON_PL11:

******************************


                dc.w 2          ; laser
                dc.w 0
                dc.w 28
                dc.w 17*160
                dc.w 0
                dc.w 16
                dc.w 28*160
                dc.w 55*160
                dc.w 4
                dc.l 1

                ds.b 64-22



                dc.w -1


*************************

                endpart
                >PART 'Weapon Player 21'

WEAPON_PL1:

******************************
                dc.w 1          ; bullet
                dc.w 0          ; ** Reserved **
                dc.w 22         ; Start X
                dc.w 12         ; Start Y
                dc.w 0          ; x1
                dc.w 0          ; y1
                dc.w 15         ; x2
                dc.w 15         ; y2
                dc.w 0          ; ** Reserved **
                dc.l 0          ; And test for shooting
                dc.w $0030      ; Speed X
                dc.w -$0100     ; Speed Y

                ds.b 64-26

                dc.w 1          ; bullet
                dc.w 0          ; ** Reserved **
                dc.w 22         ; Start X
                dc.w 12         ; Start Y
                dc.w 0          ; x1
                dc.w 0          ; y1
                dc.w 15         ; x2
                dc.w 15         ; y2
                dc.w 0          ; ** Reserved **
                dc.l 0          ; And test for shooting
                dc.w -$0030     ; Speed X
                dc.w -$0100     ; Speed Y

                ds.b 64-26

                dc.w -1


*************************

                endpart
                >PART 'Weapon Player 22'

WEAPON_PL2:

******************************


                dc.w 0          ; bullet
                dc.w 0          ; ** Reserved **
                dc.w 16
                dc.w 3
                dc.w 0
                dc.w 0
                dc.w 15
                dc.w 12
                dc.w 0          ; ** Reserved **
                dc.l 0          ; And test
                dc.w -$0060     ; Speed X
                dc.w -$00A0     ; Speed Y

                ds.b 64-26


                dc.w -1


*************************

                endpart

                >PART 'Weapon Tab'
* Here the routines for weapons can be found
* called from level sequenser  (first word *32 +WEAPONTAB) gives the
* address
WEAPONTAB:                              ; each is 32 bytes
                dc.w 0          ; 0   Weapon Look to use
                dc.l W_INIT_1   ; 2   Init rout
                dc.l W_MOVE_1   ; 6   Move rout
                dc.l W_NEW__1   ; 10  New rout
                dc.l W_DRAW_1   ; 14  Draw rout

                ds.b 32-18

                dc.w 1          ; 0   Weapon Look to use
                dc.l W_INIT_1   ; 2   Init rout
                dc.l W_MOVE_1   ; 6   Move rout
                dc.l W_NEW__1   ; 10  New rout
                dc.l W_DRAW_1   ; 14  Draw rout

                ds.b 32-18

                dc.w 2          ; 0   Weapon Look to use
                dc.l W_INIT_2   ; 2   Init rout
                dc.l W_MOVE_2   ; 6   Move rout
                dc.l W_NEW__2   ; 10  New rout
                dc.l W_DRAW_2   ; 14  Draw rout

                ds.b 32-18

                endpart
                >PART 'Weapon Look Tabell'
* Info on each bullet, where to find image, colors an stuff like that
* Calles from the Weapontab, which is called from level sequenser
* each is 32 bytes
WEAPONLOOKTAB:

                ds.w 256

WEAPONLOOKTAB2:
                dc.l 0          ; 0   Address to image       (comp)
                dc.w 0          ; 4   Hight                  (comp)
                dc.w 16         ; 6   Rotations
                dc.w 0          ; 8   Rotations as LSR       (comp)
                dc.w 0          ; 10  Sprite rout to use     (comp)
                dc.w 0          ; 12  width in words         (comp)
                dc.w 0          ; 14  col section 1
                dc.w 1          ; 16  col section 2
                dc.w 2          ; 18  col section 3
                dc.w 0          ; 20  add for next rotation  (comp)
                dc.w 0          ; 22  add for next animation (comp)
                dc.b "THREE.SHO",0,"    "
                ds.b 48-38


                dc.l 0          ; 0   Address to image       (comp)
                dc.w 0          ; 4   Hight                  (comp)
                dc.w 16         ; 6   Rotations
                dc.w 0          ; 8   Rotations as LSR       (comp)
                dc.w 0          ; 10  Sprite rout to use     (comp)
                dc.w 0          ; 12  width in words         (comp)
                dc.w 0          ; 14  col section 1
                dc.w 1          ; 16  col section 2
                dc.w 2          ; 18  col section 3
                dc.w 0          ; 20  add for next rotation  (comp)
                dc.w 0          ; 22  add for next animation (comp)
                dc.b "BOUBLE.SHO",0,"   "
                ds.b 48-38


* 2 laser

                dc.l 0          ; 0   Address to image       (comp)
                dc.w 0          ; 4   Hight                  (comp)
                dc.w 16         ; 6   Rotations
                dc.w 0          ; 8   Rotations as LSR       (comp)
                dc.w 0          ; 10  Sprite rout to use     (comp)
                dc.w 0          ; 12  width in words         (comp)
                dc.w 0          ; 14  col section 1
                dc.w 1          ; 16  col section 2
                dc.w 2          ; 18  col section 3
                dc.w 0          ; 20  add for next rotation  (comp)
                dc.w 0          ; 22  add for next animation (comp)
                dc.b "LASER16.SHO",0,"  "

                ds.b 48-38

                dc.w -1
WEAPONLOOKSLUT:
                endpart


*************************************
SEQSTART:       dc.l SEQ
SEQPEK:         dc.l SEQ        ; Enemy Sequenser data
OLD_SEQPEK:     dc.l 0
DOINGFLAG:      dc.w 0
DOCOUNT:        dc.w 0
LOOPPEK:        dc.l LOOPTAB
LOOPTAB:        ds.w 6*10
*************************************
OANITAB_PEK:    dc.l OANITAB    ; Pointer to O-ANI tab
*************************************
MUSIC_FLAG:     dc.w 0          ; 1=PLAY MUSIC ON VBL 0=DON'T
MUSIC_JUMP:     dc.l 0          ; IRQ HOPP ADDRESS TILL MUSIC
INST_RASTER:    dc.w 0          ; 1=RASTER I SPEL 0=NO RASTER
CHG_ON_TWO:     dc.w 0          ; 0=Don't set screen on Vbl 2   -1 =do it!
CHEATFLAG:      dc.w 1          ; 1=CHEAT ON  0=OFF
CHEATFLAG2:     dc.w 0          ; OD™DLIG 1=ON  0=OFF
TIMESHOW:       dc.w 0          ; 0=DON'T SHOW TIME 1=SHOW TIME (col)
TIMESHOW2:      dc.w 0          ; 0=DON'T SHOW TIME 1=SHOW TIME (percent)
MAX_ENEMY:      dc.w 0
PROCESSORTIME:  dc.w 0          ; Processor Time as BCD 0-$99
SLOWMOTION:     dc.w 0          ; Extra Vbl's to wait
KEY:            dc.w 0          ; Copy of $fffffc02.w but no Joy Commands  (.b)
PLAYERS:        dc.w 0          ; 1=One player game  2=Two player game
MISSION_AND:    dc.l -1         ; And on player flags
MISSION_CMP:    dc.l -1         ; Cmp on the And'ed flags, if true, level over!
*********************************       BLOCK
BLOCKCOUNT:     dc.w 0          ; VILKEN Y POS (BIT 0 DECIMAL)
BLOCKPOS:       dc.l 0
BLOCKSTART:     dc.l 0
F_BLOCK:        dc.l 0          ; Address to Fast Blocks
N_BLOCK:        dc.l 0          ;            Normal
S_BLOCK:        dc.l 0          ;            Sprite
_Blk_DestTab:   ds.l 1
_Blk_AnimTab:   ds.l 1
_Blk_ShotTab:   ds.l 1
*********************************
ESHOOTADDR1:    dc.l 0          ; Address to enemy bullet image
*********************************
_EXPLO_NR:      ds.w 1

                >PART 'SILLY DATA'
Q_MAIN:         ds.l 1
Q_AWB:          ds.l 1
Q_AWE:          ds.l 1
Q_AWA:          ds.l 1
Q_SPD:          ds.l 1
Q_ACRNR:        ds.w 1
Q_ACRADDR:      ds.l 1
                endpart


*************************************
SAVETAB:        ds.l 64
MEM_END:        dc.l MEMORY
MEM_TAB_PEK:    dc.l MEM_TAB


                >PART 'MUSIC'
                if PLAYMUSIC=1
MUSIC:          ibytes 'ARMY.IMG'
                endc
                endpart

COLFIX_DATA:    dc.b 0,12,14,1,2,3,4,5,6,7,8,9,10,11,13,15
                >PART 'Kurvor'

AWFIXSTART:
AW1:            ibytes 'TAGG1.B'
AW2:            ibytes 'MASK1.B'
AW3:            ibytes 'SLING1.B'
AW4:            ibytes 'SLING2.B'
AW5:            ibytes 'SLING3.B'
AW6:            ibytes 'SLING4.B'
AW7:            ibytes 'FAST1.B'
AW8:            ibytes 'FAST2.B'
AW9:            ibytes 'FAST3.B'
AW10:           ibytes 'FAST4.B'
AW11:           ibytes 'KURVA1.B'
AW12:           ibytes 'KURVA2.B'
AW13:           ibytes 'KURVA3.B'
AW14:           ibytes 'KURVA4.B'
AW15:           ibytes 'KURVA5.B'
AW16:           ds.l 140*2      ; Lines
AW17:           ds.l 140*2
AW18:           ds.l 140*2
AW19:           ds.l 140*2
AW20:           ds.l 140*2
AW21:


ACR1:           ibytes 'C_R10.ACR'
ACR2:           ibytes 'C_R15.ACR'
ACR3:           ibytes 'C_R20.ACR'
ACR4:           ibytes 'C_R25.ACR'
ACR5:           ibytes 'C_R30.ACR'
ACR6:           ibytes 'C_R40.ACR'
ACR7:           ibytes 'C_R50.ACR'
ACR8:           ibytes 'C_R60.ACR'
ACR9:

AWFIXEND:
                endpart


_MAPTAB:        >PART 'Map Data Create'
                dc.w _MAPIMAGE+4-_MAPTAB ; 0
                dc.w _MAPCREATE-_MAPTAB ; 2
                dc.w 0          ; 4
                ds.l 1          ; 6
                ds.l 1          ; 10
                ds.l 1          ; 14
                ds.l 1          ; 18
                ds.l 1          ; 22
                ds.l 1          ; 26
                ds.l 1          ; 30
                ds.b 64-34      ; 34
                dc.b "FASTBLK.BLF",0,0,0 ; 64
                dc.b "NORMAL.BLN",0,0,0,0 ; 78
                dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 92
_MAPCREATE:
                if REM=0
                dc.w $0105,$0106,$0107,$0108,-1
                dc.w 1          ; Animated
                dc.l 0
                dc.w $0101
                dc.w $0102
                dc.w $0103
                dc.w $0104
                dc.w $0105
                dc.w $0106
                dc.w $0107
                dc.w $0108
                dc.w $0109
                dc.w $010A
                dc.w $010B
                dc.w $010C
                dc.w $010D
                dc.w $010E
                dc.w $010F
                endc
                dc.w -1         ; AniEnd
                dc.w -1         ; EndMark
_MAPIMAGE:      ibytes 'PREVIEW2.MED'
_MAPIMAGE_END:
_MAPTAB_END:
                endpart
**********************************
CHEATBOX:       >PART 'CheatMode Box'
MID:
                if SPACEQUIT=1
                clr.w   REFUSESPACEQUIT
                endc
                clr.b   KEY
                movem.l d0-a6,-(a7)
                lea     MID(pc),a6

                moveq   #0,d1
                lea     TEXT1(pc),a0
                bsr     PRINTLOT
                lea     STARTMSSG(pc),a0
                bsr     PRINTLOT

CHARLOOP:       jsr     VSYNC
                bsr     PRINTLINE
                bsr     DRAWCURSOR

                moveq   #0,d0
                moveq   #0,d1
                move.b  KEY(pc),d0
                clr.b   KEY
                btst    #7,d0
                bne.s   CHARLOOP

                lea     CONV(pc),a0
                move.b  0(a0,d0.w),d1
                bne.s   TRUECHAR

                cmp.b   #$61,d0
                beq     QUITTHIS

                cmp.b   #$1C,d0
                beq     RETURNKEY
                cmp.b   #$72,d0
                beq     RETURNKEY

                if CURSOR=0
                cmp.b   #$52,d0
                beq     INSERTKEY
                cmp.b   #$48,d0
                beq     CURSUP
                cmp.b   #$50,d0
                beq     CURSDOWN
                cmp.b   #$4B,d0
                beq     CURSLEFT
                cmp.b   #$4D,d0
                beq     CURSRIGHT
                else
                bclr    #7,JOY1
                bne     INSERTKEY
                bclr    #2,JOY1
                bne     CURSLEFT
                bclr    #3,JOY1
                bne     CURSRIGHT
                bclr    #0,JOY1
                bne.s   CURSUP
                bclr    #1,JOY1
                bne.s   CURSDOWN
                endc

                cmp.b   #1,d0
                beq.s   ESCKEY

                cmp.b   #$0E,d0
                beq     BACKSPACE

                cmp.b   #$53,d0
                beq     DELETEKEY

                bra     CHARLOOP

TRUECHAR:       clr.w   CURSCOUNT-MID(a6)
                move.w  CRX(pc),d2
                lea     EDITLINE(pc),a0
                tst.w   CURSMODE-MID(a6)
                bmi.s   OVERW

                moveq   #27,d0
INSERTA:        cmp.w   d2,d0
                beq.s   OVERW
                move.b  -1(a0,d0.w),0(a0,d0.w)
                dbra    d0,INSERTA

OVERW:          move.b  d1,0(a0,d2.w)
                cmpi.w  #27,CRX
                beq.s   NOINC
                addq.w  #1,CRX
NOINC:
                bra     CHARLOOP

**************
ESCKEY:         clr.w   CURSCOUNT-MID(a6)
                clr.w   CRX-MID(a6)
                lea     EDITLINE(pc),a0
                moveq   #27,d0
REN:            move.b  #' ',(a0)+
                dbra    d0,REN
                bra     CHARLOOP


CURSUP:         clr.w   CURSCOUNT-MID(a6) ;        Up
                clr.w   CRX-MID(a6)
                bra     CHARLOOP


CURSDOWN:       clr.w   CURSCOUNT-MID(a6) ;        Down
                moveq   #27,d0
                moveq   #27,d1
                lea     EDITLINE(pc),a0
FINDHIM:        cmpi.b  #' ',0(a0,d0.w)
                bne.s   FOUNDNONES
                move.w  d0,d1
                dbra    d0,FINDHIM
FOUNDNONES:     move.w  d1,CRX-MID(a6)
                bra     CHARLOOP


CURSLEFT:       clr.w   CURSCOUNT-MID(a6) ;        Left
                tst.w   CRX-MID(a6)
                beq     CHARLOOP
                subq.w  #1,CRX-MID(a6)
                bra     CHARLOOP


CURSRIGHT:      clr.w   CURSCOUNT-MID(a6) ;        Right
                cmpi.w  #27,CRX
                beq     CHARLOOP
                addq.w  #1,CRX-MID(a6)
                bra     CHARLOOP


INSERTKEY:      not.w   CURSMODE-MID(a6) ;         Insert
                clr.w   CURSCOUNT-MID(a6)
                bra     CHARLOOP


BACKSPACE:      clr.w   CURSCOUNT-MID(a6) ;        Backspace
                lea     EDITLINE(pc),a0
                move.w  CRX(pc),d6
                beq     CHARLOOP
                subq.w  #1,d6
                move.w  d6,CRX
                lea     0(a0,d6.w),a0
BACKSA:         tst.b   1(a0)
                beq.s   LASTCHAR
                move.b  1(a0),(a0)+
                bra.s   BACKSA
LASTCHAR:       move.b  #" ",(a0)
                bra     CHARLOOP


DELETEKEY:      clr.w   CURSCOUNT-MID(a6) ;         Delete
                lea     EDITLINE(pc),a0
                move.w  CRX(pc),d6
                lea     0(a0,d6.w),a0
BACKSA2:        tst.b   1(a0)
                beq.s   LASTCHAR2
                move.b  1(a0),(a0)+
                bra.s   BACKSA2
LASTCHAR2:      move.b  #" ",(a0)
                bra     CHARLOOP


QUITTHIS:       if SPACEQUIT=1
                move.w  #-1,REFUSESPACEQUIT
                endc
                movem.l (a7)+,d0-a6     ;           Undo
                rts


RETURNKEY:      lea     EDITLINE(pc),a0 ;           Return
                lea     FUSK+2(pc),a1
NEXTSTR:        moveq   #0,d3
                movea.l a0,a2
JEMFOR:         move.b  (a1)+,d0
                beq.s   ENDSTRING
                cmp.b   #-1,d0
                beq.s   WRONGCOM
                cmp.b   (a2)+,d0
                beq.s   JEMFOR
                moveq   #-1,d3
                bra.s   JEMFOR
ENDSTRING:      moveq   #0,d4
                move.b  (a1)+,d4
                tst.w   d3
                bmi.s   NEXTSTR

                add.w   d4,d4
                add.w   d4,d4
                lea     FUSK(pc),a1
                add.w   (a1),d4
                move.w  0(a1,d4.w),d0
                move.w  2(a1,d4.w),d4
                adda.w  d0,a1

                jsr     VSYNC
                lea     CLEAR(pc),a0
                moveq   #0,d1
                bsr     PRINTLOT
                jsr     VSYNC

                movea.l a1,a0
                bsr     PRINTLOT

                lea     CHEETFUNCTAB(pc),a0
FINDSTART:      tst.w   d4
                beq.s   FUSKLOOP
FASTLOOK:       tst.w   (a0)+
                bne.s   FASTLOOK
                subq.w  #1,d4
                bra.s   FINDSTART

FUSKLOOP:       move.w  (a0)+,d0
                beq.s   NOMOREFUSK
                movem.l d0-a6,-(a7)
                jsr     0(a6,d0.w)
                movem.l (a7)+,d0-a6
                bra.s   FUSKLOOP
NOMOREFUSK:
                bra.s   FIN
WRONGCOM:       lea     FAILMSSG(pc),a0
                moveq   #0,d1
                bsr     PRINTLOT

FIN:            clr.w   CURSCOUNT-MID(a6)
                bra     CHARLOOP

***********************
PRINTLINE:      movem.l d1/a0,-(a7)
                move.w  #6,CX-MID(a6)
                move.w  #9,CY-MID(a6)
                lea     EDITLINE(pc),a0
                moveq   #0,d1
                bsr     PRINT
                movem.l (a7)+,d1/a0
                rts
***********************
DRAWCURSOR:     movem.l d0-a6,-(a7)
                move.w  CURSCOUNT(pc),d0
                addq.w  #1,d0
                cmpi.w  #40,d0
                blo.s   NOWORRY
                clr.w   d0
NOWORRY:        move.w  d0,CURSCOUNT-MID(a6)
                cmpi.w  #20,d0
                bhs.s   NOCURS

                movea.l SCREEN(pc),a0
                lea     9*8*160(a0),a0
                move.w  #6,d3

                add.w   CRX(pc),d3
                move.w  d3,d4
                and.w   #$00FE,d3
                sub.w   d3,d4
                lsl.w   #2,d3
                add.w   d4,d3
                adda.w  d3,a0

                tst.w   CURSMODE-MID(a6)
                beq.s   INSERTMODE

                moveq   #%11111110,d3
                move.b  d3,5*160(a0)
                move.b  d3,5*160+2(a0)
                move.b  d3,5*160+4(a0)
                move.b  d3,5*160+6(a0)
                move.b  d3,6*160(a0)
                move.b  d3,6*160+2(a0)
                move.b  d3,6*160+4(a0)
                move.b  d3,6*160+6(a0)
                bra.s   NOCURS
INSERTMODE:     moveq   #7,d3
INVERSA:        not.b   (a0)
                not.b   2(a0)
                not.b   4(a0)
                not.b   6(a0)
                lea     160(a0),a0
                dbra    d3,INVERSA
NOCURS:         movem.l (a7)+,d0-a6
                rts
CURSMODE:       dc.w 0          ; -1=overwrite, 0 =insert
CURSCOUNT:      dc.w 0

CRX:            dc.w 0
EDITLINE:       dc.b "                            ",0
*********************************
TEXT1:          dc.b 4,4
                dc.b "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»",0
                dc.b "º * EUTANASIA CHEAT MODE BOX * º",0
                dc.b "º                              º",0
                dc.b "º    Undo to return to game    º",0
                dc.b "º                              º",0
                dc.b "º>                            <º",0
                dc.b "º                              º",0
                dc.b "º                              º",0
                dc.b "º                              º",0
                dc.b "º                              º",0
                dc.b "º                              º",0
                dc.b "º                              º",0
                dc.b "º                              º",0
                dc.b "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼",0
                dc.b -1

CLEAR:          dc.b 5,11
                rept 6
                dc.b "                              ",0
                endr
                dc.b -1
STARTMSSG:      dc.b 5,11
                dc.b "  Eutanasia is protected by",0
                dc.b "    the laws of copyright.",0
                dc.b " Copyright Martin Liesen 1991",0
                dc.b 0
                dc.b "  A Synchron Assembly Product",0
                dc.b "------------------------------"
                dc.b 0
                dc.b -1
FAILMSSG:       dc.b 5,11
                dc.b "                              ",0
                dc.b "------------------------------",0
                dc.b " Word has no meaning, or you  ",0
                dc.b " don't have enough access to  ",0
                dc.b "    use that very command.    ",0
                dc.b "------------------------------",0,-1


CONV:           dc.b 0,0,"1234567890+",0,0
                dc.b "QWERTYUIOPš",0,0,"AS"
                dc.b "DFGHJKL™Ž'",0,"\ZXCV"
                dc.b "BNM,.-",0,0,0," ",0,0,0,0,0,0
                dc.b 0,0,0,0,0,0,0,0,0,0,"-",0,0,0,"+",0
                dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b "<",0,0,"()/*789456123"
                dc.b "0.",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                even
                endpart
FUSK:           >PART 'CheatText'
********************
                dc.w CHEATTAB-FUSK
CHEETS:         dc.b "INGET",0,0
                dc.b "OMEGA",0,1
                dc.b "MARTIN LIESEN",0,2
                dc.b "JOHANNES S™DERQVIST",0,3
                dc.b "HELP",0,4
                dc.b "HINT",0,4
                dc.b "WHAT",0,4
                dc.b "CLUE",0,4
                dc.b "BLBŽR",0,4

                dc.b "ENERGY1",0,5
                dc.b "ENERGY2",0,6
                dc.b "ENERGYALL",0,7

                dc.b "KILLHIM",0,8
                dc.b "SHOOTLESS",0,9
                dc.b "MEGABLAST",0,10
                dc.b "CLEAN",0,11

                dc.b "TIMER P ON",0,12
                dc.b "TIMER P OFF",0,13
                dc.b "TIMER C ON",0,14
                dc.b "TIMER C OFF",0,15

                dc.b "STATUS",0,16
                dc.b "CONTROL",0,17
                dc.b "MEMORY",0,18

                dc.b "GNU",0,19
                dc.b "SURETHING",0,19
                dc.b "IT'S FULL OF STARS",0,19
                dc.b "I FEEL ONE WITH THE UNIVERSE",0,19

                dc.b "MUSIC",0,20
                dc.b "LIKE",0,20
                dc.b -1
                even
CHEATTAB:       dc.w T_NOTHING-FUSK,0 ;   0
                dc.w T_OMEGA-FUSK,0 ;     1
                dc.w T_LIESEN-FUSK,0 ;    2
                dc.w T_JOHANNES-FUSK,0 ;  3
                dc.w T_HELP-FUSK,0 ;      4
                dc.w T_FUSK-FUSK,1 ;      5
                dc.w T_FUSK-FUSK,2 ;      6
                dc.w T_FUSK-FUSK,3 ;      7
                dc.w T_FUSK-FUSK,4 ;      8
                dc.w T_FUSK-FUSK,5 ;      9
                dc.w T_FUSK-FUSK,6 ;      10
                dc.w T_FUSK-FUSK,7 ;      11

                dc.w T_DEBUG-FUSK,8 ;     12
                dc.w T_DEBUG-FUSK,9 ;     13
                dc.w T_DEBUG-FUSK,10 ;    14
                dc.w T_DEBUG-FUSK,11 ;    15
                dc.w T_ADDRLOOK-FUSK,12 ;   16
                dc.w T_ADDRLOOK-FUSK,13 ;   17
                dc.w T_ADDRLOOK-FUSK,14 ;   18

                dc.w T_KULTUTTRYCK-FUSK,0 ; 19
                dc.w T_MUSIC-FUSK,0 ; 20


T_NOTHING:      dc.b 5,11,0,-1
T_ADDRLOOK:     dc.b 5,11
**********************XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                dc.b "-----Curs Up/Down, Space -----",0,-1

T_FUSK:         dc.b 5,12,"Cheating is good for you!",0
                dc.b ">Terror For You<",0,-1
T_DEBUG:        dc.b 5,12,"A Debug option..",0
                dc.b "Far Too Dark Park..",0,-1
T_OMEGA:        dc.b 5,11
                dc.b "The ruling team! Beats TCB",0
                dc.b "any time (have always done)",0
                dc.b "Famous for never beeing able",0
                dc.b "to release a demo in time",0
                dc.b "(or even release it at all!)",0
                dc.b "MegaSuperJ„tteAlfaM„ktigast!!",0,-1
T_LIESEN:       dc.b 5,11
                dc.b "The Programmer of this game.",0
                dc.b "17 Years old, Omega member.",0
                dc.b "  Martin Liesen",0
                dc.b "  Pl. 6035",0
                dc.b "  44033 Harestad",0
                dc.b "  Sweden (J„ttekallt!)",0,-1
T_JOHANNES:     dc.b 5,11
                dc.b "The man behind the pencil(?).",0
                dc.b "Drawn all grfx in this game.",0
                dc.b "A member of the world wide",0
                dc.b "Omega. A very lazy person",0
                dc.b "(and EGO upon that too!).",0,-1
T_KULTUTTRYCK:  dc.b 17,11
                dc.b "   I",0
                dc.b "  FEEL",0
                dc.b "  ONE",0
                dc.b " WITH",0
                dc.b "  THE",0
                dc.b "UNIVERSE",0,-1
T_MUSIC:        dc.b 5,11
                dc.b "FRONT 242, SKINNY PUPPY",0
                dc.b "SLAYER, SUICIDAL TENDENCES",0
                dc.b "KRAFTWERK, DEPECHE MODE",0
                dc.b "DELERIUM, NITZER EBB",0
                dc.b "THE CURE, METALLICA",0
                dc.b "+ TECHNO",0,-1
**********************XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
T_HELP:         dc.b 5,11
                dc.b "Humm, having problems??",0
                dc.b "Well, this box is just a",0
                dc.b "kind of enter password box.",0
                dc.b "BUT it's also a lotsa stupid",0
                dc.b "greetings/remarks box..",0
                dc.b "-Bl†b„r „r inte gott!",0,-1
                even
                endpart
CHEETFUNCTAB:   >PART 'Fusk funktioner'
* F_  Fusk
* D_  Debugger
                dc.w 0
                dc.w F_ENERGY1-MID,0
                dc.w F_ENERGY2-MID,0
                dc.w F_ENERGY1-MID,F_ENERGY2-MID,0
                dc.w F_KILLONE-MID,0
                dc.w F_ESHOOTS_BORT-MID,0
                dc.w F_ENEMIES_BORT-MID,0
                dc.w F_ENEMIES_BORT-MID,F_ESHOOTS_BORT-MID,0
                dc.w D_P_TIMER_ON-MID,0
                dc.w D_P_TIMER_OFF-MID,0
                dc.w D_C_TIMER_ON-MID,0
                dc.w D_C_TIMER_OFF-MID,0

                dc.w A_STATUS-MID,0
                dc.w A_CONTROL-MID,0
                dc.w A_MEMORY-MID,0

                rts

**************************************************

F_ENERGY1:      move.w  #38,PL_DATA1+26 ;    Full Energy pl2
                rts

**************************************************

F_ENERGY2:      move.w  #38,PL_DATA2+26 ;    Full Energy pl2
                rts

**************************************************

F_KILLONE:      movem.l d0-a6,-(a7)     ;    Kill ONE Enemy
                lea     SPRITETAB,a0
                move.w  MAX_ENEMY(pc),d6
_BOTRR:         movea.l (a0)+,a2
                tst.w   (a2)
                beq.s   _DEADD
                tst.w   16(a2)
                beq.s   _DEADD
                movem.l d0-a6,-(a7)
                movea.l a2,a0
                moveq   #-1,d0
                jsr     HIT_ENEMY
                movem.l (a7)+,d0-a6
                bra.s   _DONE
_DEADD:         dbra    d6,_BOTRR
_DONE:          movem.l (a7)+,d0-a6

**************************************************

F_ESHOOTS_BORT: movem.l d0-a6,-(a7)     ;    Remove all enemy shoots
                lea     ESHOOT,a0
                move.w  MAX_ESHOOT,d0
_ESHOOT_BOTRR:  move.w  #0,(a0)+
                dbra    d0,_ESHOOT_BOTRR
                movem.l (a7)+,d0-a6
                rts

**************************************************

F_ENEMIES_BORT: movem.l d0-a6,-(a7)     ;    Remove all enemies
                move.w  MAX_ENEMY(pc),d0
                lea     SPRITETAB,a0
_SPRITES_BOTRR: movea.l (a0)+,a1
                move.w  #0,(a1)
                dbra    d0,_SPRITES_BOTRR
                movem.l (a7)+,d0-a6
                rts

**************************************************

D_P_TIMER_ON:   move.w  #1,TIMESHOW2    ; SHOW RASTER TIME
                rts

D_P_TIMER_OFF:  move.w  #0,TIMESHOW2    ; Don't SHOW RASTER TIME
                rts

D_C_TIMER_ON:   move.w  #1,TIMESHOW     ; SHOW RASTER TIME
                rts

D_C_TIMER_OFF:  move.w  #0,TIMESHOW     ; Don't SHOW RASTER TIME
                rts

**************************************************

*********************************************

**************************************************

D_SLOWMOTION:   movem.l d0/a0,-(a7)     ;       Slow motion, d0=speed 0-9
                lea     _MOTIONTAB(pc),a0
                move.b  0(a0,d0.w),d0
                move.w  d0,SLOWMOTION
                movem.l (a7)+,d0/a0
                rts
_MOTIONTAB:     dc.b 0,1,2,3,4,6,10,15,20,30,50,100,200
                even

**************************************************

                endpart
ADDRESSLOOK:    >PART 'different address lookers'
A_STATUS:       movem.l a4,-(a7)
                lea     _A_STATUS(pc),a4
                bsr     D_SLIDE
                movem.l (a7)+,a4
                rts
A_CONTROL:      movem.l a4,-(a7)
                lea     _A_CONTROL(pc),a4
                bsr     D_SLIDE
                movem.l (a7)+,a4
                rts
A_MEMORY:       movem.l a4,-(a7)
                lea     _A_MEMORY(pc),a4
                bsr     D_SLIDE
                movem.l (a7)+,a4
                rts


* 12 bytes  decription
* long: to base address
* byte: mode (0=byte,1=word,2=long,3=base address)
*           other modes is special (see ADDRESSMODETAB)
* byte: chars to print


_A_CONTROL:     dc.b "JOY0        " ;
                dc.l JOY0
                dc.b 0,2
                dc.b "JOY1        " ;
                dc.l JOY1
                dc.b 0,2
                dc.b "KEY         " ;
                dc.l KEY
                dc.b 0,2
                dc.l -1

_A_MEMORY:
                dc.b "B MEMORY    " ;
                dc.l MEMORY
                dc.b 3,6
                dc.b "E MEMORY    " ;
                dc.l END_OF_MEM
                dc.b 3,6
                dc.b "MEM_END     " ;
                dc.l MEM_END
                dc.b 2,6
                dc.b "SCREEN1     " ;
                dc.l SCREEN1
                dc.b 2,6
                dc.b "SCREEN2     " ;
                dc.l SCREEN2
                dc.b 2,6
                dc.b "SCREEN      " ;
                dc.l SCREEN
                dc.b 2,6

                dc.b "STACK BASE  " ;
                dc.l STACK
                dc.b 3,6
                dc.b "STACK       " ;
                dc.l STACK
                dc.b 4,6

                dc.b "GAME START  " ;
                dc.l GAMESTART
                dc.b 3,6
                dc.b "GAME END    " ;
                dc.l GAMEEND
                dc.b 3,6


                dc.l -1

_A_STATUS:

                dc.b "Players     " ; Nr of players
                dc.l PLAYERS
                dc.b 1,4

                dc.b "Player 1    " ; Live/Dead
                dc.l PL_DATA1+76
                dc.b 1,4
                dc.b "1 Flag 31-24" ; Flags
                dc.l 96
                dc.b 5,8
                dc.b "1 Flag 23-16" ; Flags
                dc.l 97
                dc.b 5,8
                dc.b "1 Flag 15-08" ; Flags
                dc.l 98
                dc.b 5,8
                dc.b "1 Flag 07-00" ; Flags
                dc.l 99
                dc.b 5,8
                dc.b "Player 2    " ; Live/Dead
                dc.l PL_DATA2+76
                dc.b 1,4
                dc.b "2 Flag 31-24" ; Flags
                dc.l 96
                dc.b 6,8
                dc.b "2 Flag 23-16" ; Flags
                dc.l 97
                dc.b 6,8
                dc.b "2 Flag 15-08" ; Flags
                dc.l 98
                dc.b 6,8
                dc.b "2 Flag 07-00" ; Flags
                dc.l 99
                dc.b 6,8

                dc.b "Ext_Explos  " ; Nr of players
                dc.l _EXPLO_NR
                dc.b 1,4


                dc.b "SLOWMOTION  " ;
                dc.l SLOWMOTION
                dc.b 1,4
                dc.b "MAX_ENEMY   " ;
                dc.l MAX_ENEMY
                dc.b 1,4

                dc.l -1

                endpart
D_SLIDE:        >PART 'Address looker'
* a4=address to address tab

                movem.l d0-a6,-(a7)
                lea     D_SLIDE(pc),a6
                moveq   #0,d7
                clr.b   KEY
_WAITING:       bsr     _UPDATEALL
                if CURSOR=0
                cmpi.b  #$48,KEY
                bne.s   _NOTUP
                else
                bclr    #0,JOY1
                beq.s   _NOTUP
                endc
                clr.b   KEY
                tst.w   d7
                beq.s   _NOTUP
                subq.w  #1,d7

_NOTUP:         if CURSOR=0
                cmpi.b  #$50,KEY
                bne.s   _NOTDOWN
                else
                bclr    #1,JOY1
                beq.s   _NOTDOWN
                endc
                clr.b   KEY
                move.w  d7,d0
                mulu    #18,d0
                cmpi.l  #-1,0(a4,d0.w)
                beq.s   _NOTDOWN
                cmpi.l  #-1,1*18(a4,d0.w)
                beq.s   _NOTDOWN
                cmpi.l  #-1,2*18(a4,d0.w)
                beq.s   _NOTDOWN
                cmpi.l  #-1,3*18(a4,d0.w)
                beq.s   _NOTDOWN
                cmpi.l  #-1,4*18(a4,d0.w)
                beq.s   _NOTDOWN
                cmpi.l  #-1,5*18(a4,d0.w)
                beq.s   _NOTDOWN

                addq.w  #1,d7


_NOTDOWN:       cmpi.b  #$39,KEY
                bne.s   _WAITING

                lea     CLEAR(pc),a0
                bsr     PRINTLOT
                clr.b   KEY
                movem.l (a7)+,d0-a6
                rts


_UPDATEALL:
* d7=pos
* a4=address to tab (NEVER use to large pos, pos should be -5 of max)
* a6=D_SLIDE
                movem.l d0-a6,-(a7)
                jsr     VSYNC

                mulu    #18,d7
                lea     0(a4,d7.w),a4
                move.w  #12,CY
                moveq   #4,d7

_SKRIV6:        movea.l a4,a3
                lea     18(a4),a4
                cmpi.l  #-1,(a3)
                beq.s   _STOPNOW

                move.w  #9,CX
                moveq   #11,d6
_SKRIV12:       moveq   #0,d0
                move.b  (a3)+,d0
                bsr     PRINTC
                dbra    d6,_SKRIV12

                move.w  #23,CX
                movea.l (a3)+,a0
                moveq   #0,d0
                moveq   #0,d4
                moveq   #0,d3
                move.b  (a3)+,d4
                move.b  (a3)+,d3
                add.w   d4,d4
                lea     ADDRMODETAB(pc),a1
                move.w  0(a1,d4.w),d4
                movem.l d0-d1/d3-a6,-(a7)
                jsr     0(a1,d4.w)
                move.l  d0,d2
                movem.l (a7)+,d0-d1/d3-a6

                moveq   #8,d6
                sub.w   d3,d6
                subq.w  #1,d6
                bmi.s   _NOSPACING
                moveq   #'.',d0
_MAKESPACE:     bsr     PRINTC
                dbra    d6,_MAKESPACE
_NOSPACING:
                bsr.s   PRINTHEX

                addq.w  #1,CY
                dbra    d7,_SKRIV6

_STOPNOW:
                movem.l (a7)+,d0-a6
                rts

ADDRMODETAB:
* Where to jump to get the data to print (!?)
* A0 will contain the ADDRESS sent with,
* result shall be returned in D0!
* no data saving neccessary!
                dc.w M_BYTE-ADDRMODETAB ; 0
                dc.w M_WORD-ADDRMODETAB ; 1
                dc.w M_LONG-ADDRMODETAB ; 2
                dc.w M_ADDRESS-ADDRMODETAB ; 3
                dc.w M_STACK-ADDRMODETAB ; 4
                dc.w M_BINPL1-ADDRMODETAB ; 5
                dc.w M_BINPL2-ADDRMODETAB ; 5

M_BYTE:         move.b  (a0),d0
                rts
M_WORD:         move.w  (a0),d0
                rts
M_LONG:         move.l  (a0),d0
                rts
M_ADDRESS:      move.l  a0,d0
                rts
M_STACK:        move.l  a7,d0
                rts
M_BINPL1:       lea     PL_DATA1(pc),a1
                move.b  0(a1,a0.l),d1
                bra.s   .TOBIN
M_BINPL2:       lea     PL_DATA2(pc),a1
                move.b  0(a1,a0.l),d1
                bra.s   .TOBIN


************
.TOBIN:         moveq   #0,d0
                moveq   #7,d2
.ALLBITS:       ror.w   #1,d1
                bcc.s   .NOCARRY
                or.l    #1,d0
.NOCARRY:       ror.l   #4,d0
                dbra    d2,.ALLBITS
                rts
                endpart
**********************************
PRINTHEX:       >PART 'Print Hex'
* d1=inverse mode (-1=inverse)
* d2=hex value to print
* d3=number of digits to include
                movem.l d0-a6,-(a7)
                lea     HEXCONV(pc),a5
                moveq   #32,d7
                sub.w   d3,d7
                sub.w   d3,d7
                sub.w   d3,d7
                sub.w   d3,d7
                lsl.l   d7,d2
                subq.w  #1,d3
                bmi.s   SHITNO
DRAWLOOP:       rol.l   #4,d2
                move.w  d2,d0
                and.w   #$000F,d0
                move.b  0(a5,d0.w),d0
                bsr.s   PRINTC
                dbra    d3,DRAWLOOP

SHITNO:         movem.l (a7)+,d0-a6
                rts

HEXCONV:        dc.b '0123456789ABCDEF'
                endpart
PRINTLOT:       >PART 'Print a lot'
* a0=string (two first bytes is X and Y)
* d1= -1=inverse
* 0=cr/lf
* -1 =end mark (must be 0,-1)
                move.l  d7,-(a7)
                move.b  (a0)+,d7
                and.w   #$00FF,d7
                move.w  d7,CX
                move.b  (a0)+,d7
                and.w   #$00FF,d7
                move.w  d7,CY
                move.w  CX(pc),d7
NEXTSTRING:     cmpi.b  #-1,(a0)
                beq.s   SLUTMARK
                bsr.s   PRINT
                addq.w  #1,CY
                move.w  d7,CX
                bra.s   NEXTSTRING
SLUTMARK:       move.l  (a7)+,d7
                rts
                endpart
PRINT:          >PART 'Print a string'
* a0=address to string
* d1=-1 if inverse
                movem.l d0,-(a7)
PRINTLOOP:      move.b  (a0)+,d0
                beq.s   SLUTANU
                and.w   #$00FF,d0
                bsr.s   PRINTC
                bra.s   PRINTLOOP
SLUTANU:        movem.l (a7)+,d0
                rts

CX:             dc.w 4
CY:             dc.w 6
                endpart
PRINTC:         >PART 'Print ONE character'
* d0=char
* d1=-1 if inverse
                movem.l d0-d4/a0-a1,-(a7)
                movea.l SCREEN,a0
                move.w  CY(pc),d2
                mulu    #8*160,d2
                move.w  CX(pc),d3
                move.w  d3,d4
                and.w   #$00FE,d3
                sub.w   d3,d4
                lsl.w   #2,d3
                add.w   d3,d2
                add.w   d4,d2
                adda.w  d2,a0

                lsl.w   #3,d0
                lea     IBMFONT(pc),a1
                adda.w  d0,a1

                moveq   #7,d3
WRITEC:         move.b  (a1)+,d2
                eor.b   d1,d2
                move.b  d2,(a0)
                move.b  d2,2(a0)
                move.b  d2,4(a0)
                move.b  d2,6(a0)
                lea     160(a0),a0
                dbra    d3,WRITEC

                addi.w  #1,CX
                movem.l (a7)+,d0-d4/a0-a1
                rts
                endpart
IBMFONT:        ibytes 'IBMFNT8.FNT'
END_CHEATBOX:
**********************************

                >PART 'Message'
MESSAGE:        dc.b "Karin"
                dc.b " Sofia,Anna,Sara,Linda"
                even
                if SPACEQUIT=1
REFUSESPACEQUIT:dc.w -1
                endc
                endpart
GAMEEND:

**********************************
                bss
MEM_TAB:        ds.b MAX_MEMFRG*8
_EXT_EXPLO:     ds.b 1008
TALKONV:        ds.b 100
TEMP:           ds.b 100
DUMMYAREA:      ds.b 2048

STARTLOAD:      ds.b $1100
SCR1:           ds.b $8D00
SCR2:           ds.b $7D00
ENDSCR:         ds.b 1024
STACK:          ds.b 16
MEMORY:         ds.l (512-70-80)*256
END_OF_MEM:
********
                end
