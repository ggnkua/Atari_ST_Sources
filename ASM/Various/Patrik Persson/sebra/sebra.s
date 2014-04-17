                OUTPUT 'A:\AUTO\SEBRA.PRG'
                >PART 'Konstanter'

ID              EQU "CBra"

VERSION         EQU $0133

cookie_jar_size EQU 40          ; 40 kakor i burken

* TRAP-konstanter

GEMDOS          EQU 1
XGEMDOS         EQU 2
BIOS            EQU 13
XBIOS           EQU 14

* GEMDOS-konstanter

cconin          EQU 1
cconws          EQU 9
super           EQU 32
ptermres        EQU 49
fopen           EQU 61
fclose          EQU 62
fread           EQU 63
fwrite          EQU 64

* XGEMDOS-konstant

aes             EQU 200

* XBIOS-konstanter

physbase        EQU 2
getrez          EQU 4
setscreen       EQU 5
kbdvbase        EQU 34
supexec         EQU 38
blitmode        EQU 64

* Line-A-konstanter

M_POS_HX        EQU -$0358
M_POS_HY        EQU -$0356
GCURX           EQU -$025A
GCURY           EQU -$0258
CUR_FLAG        EQU -$0154
V_CEL_HT        EQU -$2E
V_FNT_AD        EQU -$16
V_REZ_VT        EQU -$04
DESTY           EQU $4E

* AES-konstanter

appl_exit       EQU $13000100
form_alert      EQU $34010101
form_center     EQU $36000501
form_dial       EQU $33090100
form_do         EQU $32010101
form_error      EQU $35010100
graf_mouse      EQU $4E010101
objc_change     EQU $2F080101
objc_draw       EQU $2A060101
shel_read       EQU $78000102
rsrc_obfix      EQU $72010101

* Systemvariabler

flock           EQU $043E
sshiftmd        EQU $044C
_v_bas_ad       EQU $044E
screenpt        EQU $045E
conterm         EQU $0484
_sysbase        EQU $04F2
_longframe      EQU $059E
p_cookies       EQU $05A0

* I/O

dbaseh          EQU $FFFF8201
dbasel          EQU $FFFF8203
dbaselow        EQU $FFFF820D
color0          EQU $FFFF8240
syncmode        EQU $FFFF820A

halftone        EQU $FFFF8A00

* Diverse

reset_pc        EQU $04
buserror        EQU $08
LineAvec        EQU $28
VBIvec          EQU $70
XBIOSvec        EQU $B8
timervec        EQU $0114

                ENDPART
                TEXT
                >PART 'Header med variabler'

basepage        EQU *-$0100

start:          bra     uppstart

varbase:                                ; Variabler

sebraid:        DC.L ID
sebraver:       DC.W VERSION
lineno:         DC.W 8000
svep:           DC.W 3
nowline:        DC.W 8000
nowsvep:        DC.W 0
mode:           DC.B 0
palno:          DC.B 0
improve_mouse:  DC.B $FF
freq:           DC.B 2
autobootflag:   DC.B 0
disable:        DC.B 0

                ENDPART
                >PART 'Installera'

install:        lea     hello(PC),A5
                move.w  #physbase,-(SP)
                trap    #XBIOS
                addq.l  #2,SP
                move.l  D0,hires_screen-hello(A5)

                pea     install_smode(PC)
                move.w  #supexec,-(SP)
                trap    #XBIOS
                addq.l  #6,SP

; Skriver ut ”ver BIOS. GEMDOS' stdout kan breakas -> knas

writeln:        moveq   #0,D0
                move.b  (A5)+,D0
                beq.s   writelnend
                move.w  D0,-(SP)
                pea     $030002
                trap    #BIOS
                addq.l  #6,SP
                bra.s   writeln

writelnend:     movea.l medres_screen(PC),A0
                lea     basepage-32000(PC),A1
                suba.l  A1,A0

                clr.w   -(SP)
                pea     (A0)
                move.w  #ptermres,-(SP)
                trap    #GEMDOS

install_smode:  bsr     super2          ; Beh”ver inte vara h„r

; D0=extra offset till bildstart

; Ber„kna bildminnesadress
                lea     medres_screen(PC),A6

                lea     picstart+1(PC),A0
                adda.w  D0,A0
                moveq   #-2,D1          ; STE-mask
                move.b  steflag(PC),D2
                bne.s   is_ste1
                sf      D1              ; ST-mask
                lea     $FE(A0),A0
is_ste1:        move.l  A0,D0
                and.l   D1,D0
                move.l  D0,(A6)

; Patcha vektorer

                move.l  XBIOSvec.w,old_xbios-medres_screen(A6)
                move.l  VBIvec.w,old_vbi-medres_screen(A6)
                move.l  timervec.w,old_timer-medres_screen(A6)
                lea     xbios(PC),A0
                move.l  A0,XBIOSvec.w
                lea     vbi(PC),A0
                move.l  A0,VBIvec.w
                lea     timer(PC),A0
                move.l  A0,timervec.w
                rts

                ENDPART
                >PART 'XBIOS'

                DC.L 'XBRA',ID
old_xbios:      DS.L 1

xbios:          lea     6(SP),A0
                tst.w   _longframe.w
                beq.s   xbios_68000
                addq.l  #2,A0
xbios_68000:    btst    #5,(SP)
                bne.s   is_super
                move    USP,A0
is_super:       cmpi.w  #physbase,(A0)
                bne.s   no2
                move.l  hires_screen(PC),D0
                rte
no2:            cmpi.w  #getrez,(A0)
                bne.s   no4
                moveq   #2,D0
                rte
no4:            cmpi.w  #setscreen,(A0)
                bne.s   no5
                move.l  2(A0),D0
                bmi.s   nolog
                move.l  D0,_v_bas_ad.w
nolog:          move.l  6(A0),D0
                bmi.s   nophys
                lea     hires_screen(PC),A0
                move.l  D0,(A0)
nophys:         rte
no5:            cmpi.w  #blitmode,(A0)
                bne.s   xbend
                move.b  has_blitter(PC),D1
                beq.s   xbend
                move.w  2(A0),D1
                bmi.s   xbend
                btst    #0,D1
                seq     use_blitter
xbend:          move.l  old_xbios(PC),-(SP)
                rts

                ENDPART
                >PART 'Timer C'

                DC.L 'XBRA',ID
old_timer:      DS.L 1

timer:          move.l  A0,-(SP)
                movea.l kbd_buffer(PC),A0
                move.l  6(A0),ikbd_lastpos
                movea.l (SP)+,A0
                pea     timercont(PC)
                move    SR,-(SP)
                move.l  old_timer(PC),-(SP)
                rts
timercont:      tst.b   ikbd_flag
                beq.s   timerend
                movem.l D0-D1/A0-A1,-(SP)
                movea.l kbd_buffer(PC),A0
                movea.l (A0),A1
                move.w  8(A0),D0
                cmp.w   6(A0),D0
                beq.s   timerend2
                move.w  0(A1,D0.w),D0
                lea     mode(PC),A1
                bsr     timersub
timerend2:      movem.l (SP)+,D0-D1/A0-A1
timerend:       rte

                ENDPART
                >PART 'IKBD'

                DC.L 'XBRA',ID
old_ikbd:       DS.L 1

kbd:            btst    #0,$FFFFFC00.w
                beq     kbdend
                movem.l D0/A0,-(SP)
                movea.l kbd_buffer(PC),A0
                move.l  6(A0),ikbd_lastpos
                movea.l _sysbase.w,A0
                cmpi.w  #$0200,2(A0)
                bmi.s   kbd_tos1
                movea.l $24(A0),A0
                move.b  (A0),D0
                move.b  D0,saveshift
                and.b   #$0F,D0         ; Ctrl+Alt
                cmp.b   #%1100,D0
                seq     tos2kbdflag
                bne.s   kbd_tos1
                bclr    #3,(A0)
kbd_tos1:       movem.l (SP)+,D0/A0
                move.w  conterm.w,-(SP)
                bset    #3,conterm.w
                pea     ikbdcont(PC)
                move.l  old_ikbd(PC),-(SP)
                rts
ikbdcont:       move.w  (SP)+,conterm.w
                movea.l _sysbase.w,A0
                cmpi.w  #$0200,2(A0)
                bmi.s   kbd_stilltos1
                movea.l $24(A0),A0
                move.b  (A0),D0
                move.b  tos2kbdflag(PC),D1
                beq.s   kbd_stilltos1
                bset    #3,D0
                cmp.b   saveshift(PC),D0
                beq.s   kbd_same
                move.b  D0,(A0)
                bra     kbdend
kbd_same:       move.b  tos2kbdflag(PC),D1
                beq     kbdend
                movea.l kbd_buffer(PC),A0
                movea.l (A0),A1
                move.w  8(A0),D0
                move.w  0(A1,D0.w),D1
                or.w    #$0800,D1
                move.b  D1,D0
                bra.s   conterm_ok
kbd_stilltos1:  movea.l kbd_buffer(PC),A0
                movea.l (A0),A1
                move.w  8(A0),D0
                move.w  0(A1,D0.w),D1
                btst    #3,conterm.w
                bne.s   conterm_ok
                sf      0(A1,D0.w)
conterm_ok:     move.b  D1,D0
                lsr.w   #8,D1
                lea     mode(PC),A1
                move.b  D1,ikbd_temp-mode(A1)
                and.b   #$0F,D1         ; Ctrl + Alt
                cmp.b   #%1100,D1
                seq     ikbd_flag-mode(A1)
                bne     kbdend
timersub:       cmp.b   #$70,D0         ; Num 0
                beq     invert
                cmp.b   #$53,D0         ; Delete
                beq     reset
                tst.b   disable-mode(A1) ; Menyn ig†ng?
                bne     kbdend
                cmp.b   #$66,D0         ; Num *
                beq     hz
                cmp.b   #$72,D0         ; Num Enter
                beq     chgpal
                cmp.b   #$4E,D0         ; Num +
                beq     ikbd_m_on
                cmp.b   #$4A,D0         ; Num -
                beq     ikbd_m_off
                cmp.b   #$63,D0         ; Num (
                bmi.s   nomode
                cmp.b   #$65,D0         ; Num /
                bgt.s   nomode
                clr.w   nowsvep-mode(A1)
                sub.b   #$63,D0
                move.b  D0,(A1)
                bra.s   clrbuf
nomode:         cmp.b   #$6F,D0         ; Num 3
                bgt.s   kbdend
                cmp.b   #$6D,D0
                blt.s   kbdend
                sub.b   #$6D,D0
setspeed:       lea     speedtab(PC),A1
                and.w   #3,D0
                lsl.w   #2,D0
                move.l  0(A1,D0.w),D0
                move.l  D0,lineno-speedtab(A1)
                move.l  D0,nowline-speedtab(A1)
                clr.w   nowsvep-speedtab(A1)
clrbuf:         move.l  ikbd_lastpos(PC),6(A0) ; terst„ll bufferten
                movea.l _sysbase.w,A0
                cmpi.w  #$0200,2(A0)
                bmi.s   kbdend
                movea.l $24(A0),A0
                andi.b  #$F3,(A0)
                sf      ikbd_flag
kbdend:         rts
reset:          movea.l reset_pc.w,A0
                move.b  ikbd_temp(PC),D0
                and.b   #3,D0
                beq.s   reset_warm
                sf      $0420.w         ; memvalid
reset_warm:     jmp     (A0)
hz:             bchg    #1,syncmode.w   ; 50/60 Hz
                bra.s   clrbuf
chgpal:         lea     palno(PC),A1
                addq.b  #1,(A1)
                andi.b  #3,(A1)
                bra.s   clrbuf
invert:         not.w   color0.w        ; Invertera
                bra.s   clrbuf
ikbd_m_on:      st      improve_mouse-mode(A1)
                bra.s   clrbuf
ikbd_m_off:     sf      improve_mouse-mode(A1)
                bra.s   clrbuf

                ENDPART
                >PART 'VBI (Klet)'

                DC.L 'XBRA',ID
old_vbi:        DS.L 1

vbi:            movem.l D0-A6,-(SP)
                move.l  screenpt.w,D0
                beq.s   nonewphys
                lea     hires_screen(PC),A0
                move.l  D0,(A0)
nonewphys:      move.b  medres_screen+1(PC),dbaseh.w
                move.b  medres_screen+2(PC),dbasel.w
                move.b  steflag(PC),D0
                beq.s   noste
                move.b  medres_screen+3(PC),dbaselow.w
noste:          movea.l hires_screen(PC),A0
                lea     diskcount(PC),A1
                movea.l medres_screen(PC),A2
                tst.w   (A1)
                beq.s   nodec
                subq.w  #1,(A1)
                bra     vbiend
nodec:          tst.w   flock.w
                beq.s   nodisk
                move.w  #19,(A1)
nodisk:         moveq   #0,D0
                move.w  lineno(PC),D0
                move.w  D0,D1
                muls    nowsvep(PC),D1
                divs    #4000,D0
                subq.w  #1,D0
                move.b  mode(PC),D2
                cmp.b   #2,D2
                beq     split
                tst.b   D2
                bne     fast
                move.b  palno(PC),D4
                ext.w   D4
                add.w   D4,D4
                lea     palettes(PC),A6
                move.w  0(A6,D4.w),D4
                move.w  D4,D5
                move.w  D4,D6
                sub.w   #$0AAA,D5
                sub.w   #$0BBB,D6
                move.w  D5,D6
                moveq   #0,D7
                btst    #0,color0+1.w
                bne.s   no_invert1
                exg     D4,D7
no_invert1:     movem.w D4-D7,color0.w
                adda.w  D1,A0
                lea     80(A0),A1
                adda.w  D1,A2
                move.b  use_blitter(PC),D2
                bne     blitklet
vbiloop1:       move.w  D0,-(SP)
i               SET 0
                REPT 25
                movem.w (A0)+,D0/D2/D4/D6/A3/A5
                movem.w (A1)+,D1/D3/D5/D7/A4/A6
                movem.w D0-D7/A3-A6,i(A2)
                movem.w (A0)+,D0/D2/D4/D6/A3/A5
                movem.w (A1)+,D1/D3/D5/D7/A4/A6
                movem.w D0-D7/A3-A6,i+24(A2)
                movem.w (A0)+,D0/D2/D4/D6/A3/A5
                movem.w (A1)+,D1/D3/D5/D7/A4/A6
                movem.w D0-D7/A3-A6,i+48(A2)
                movem.w (A0)+,D0/D2/D4/D6/A3/A5
                movem.w (A1)+,D1/D3/D5/D7/A4/A6
                movem.w D0-D7/A3-A6,i+72(A2)
                movem.w (A0)+,D0/D2/D4/D6/A3/A5
                movem.w (A1)+,D1/D3/D5/D7/A4/A6
                movem.w D0-D7/A3-A6,i+96(A2)
                movem.w (A0)+,D0/D2/D4/D6/A3/A5
                movem.w (A1)+,D1/D3/D5/D7/A4/A6
                movem.w D0-D7/A3-A6,i+120(A2)
                movem.w (A0)+,D0/D2/D4/D6
                movem.w (A1)+,D1/D3/D5/D7
                movem.w D0-D7,i+144(A2)
                lea     80(A0),A0
                lea     80(A1),A1
i               SET i+160
                ENDR
                lea     4000(A2),A2
                move.w  (SP)+,D0
                dbra    D0,vbiloop1
                move.w  nowsvep(PC),D0
                addq.w  #1,D0
                cmp.w   svep(PC),D0
                ble.s   nomaxsvep1
                moveq   #0,D0
nomaxsvep1:     move.w  D0,nowsvep
                move.b  improve_mouse(PC),D0
                beq     vbiend
                movea.l mouseptr(PC),A2
                tst.b   CUR_FLAG-GCURY(A2)
                beq     vbiend
                movea.l hires_screen(PC),A0
                movea.l medres_screen(PC),A1
                move.w  (A2),D0
                sub.w   M_POS_HX-GCURY(A2),D0
                sub.w   #16,D0
                bpl.s   censury2
                moveq   #0,D0
censury2:       cmp.w   #352,D0
                ble.s   censury
                move.w  #352,D0
censury:        and.b   #$FE,D0
                muls    #80,D0
                adda.w  D0,A0
                adda.w  D0,A1
                move.w  -(A2),D0        ; A2 pekar nu p† gcurx
                sub.w   M_POS_HY-GCURX(A2),D0
                sub.w   #16,D0
                bpl.s   censurx2
                moveq   #0,D0
censurx2:       cmp.w   #576,D0
                ble.s   censurx
                move.w  #576,D0
censurx:        lsr.w   #3,D0
                and.b   #$FE,D0
                adda.w  D0,A0
                lsl.w   #1,D0
                and.b   #$FC,D0
                adda.w  D0,A1
                lea     80(A0),A2
i               SET 0
                REPT 24
                movem.w i(A0),D0/D2/D4/D6
                movem.w i(A2),D1/D3/D5/D7
                movem.w D0-D7,i(A1)
i               SET i+160
                ENDR
vbiend:         movem.l (SP)+,D0-A6
                move.l  old_vbi(PC),-(SP)
                rts

                ENDPART
                >PART 'Klet med blitter'

blitklet:       lea     halftone+$20.w,A3
                adda.w  D1,A2
                not.b   blittoggle
                bne.s   blitklet2
                adda.w  D1,A0
                move.l  #$020052,(A3)+
                move.l  A0,(A3)+
                moveq   #-1,D1
                move.l  D1,(A3)+
                move.w  D1,(A3)+
                move.l  #$040004,(A3)+
                move.l  A2,(A3)+
                move.w  #40,(A3)+
                addq.w  #1,D0
                muls    #50,D0
                move.w  D0,(A3)+
                move.w  #$0203,(A3)+
                clr.w   (A3)
                moveq   #7,D2
blitklet_loop1: bset    D2,(A3)
                nop
                btst    D2,(A3)
                bne.s   blitklet_loop1
                bra.s   blitgetout
blitklet2:      move.l  #$020052,(A3)+
                adda.w  D1,A1
                move.l  A1,(A3)+
                moveq   #-1,D1
                move.l  D1,(A3)+
                move.w  D1,(A3)+
                move.l  #$040004,(A3)+
                addq.l  #2,A2
                move.l  A2,(A3)+
                move.w  #40,(A3)+
                addq.w  #1,D0
                muls    #50,D0
                move.w  D0,(A3)+
                move.w  #$0203,(A3)+
                clr.w   (A3)
                moveq   #7,D2
blitklet_loop2: bset    D2,(A3)
                nop
                btst    D2,(A3)
                bne.s   blitklet_loop2
                move.w  nowsvep(PC),D0
                addq.w  #1,D0
                move.w  svep(PC),D1
                addq.w  #1,D1
                lsr.w   #1,D1
                subq.w  #1,D1
                cmp.w   D1,D0
                ble.s   nomaxsvep1b
                moveq   #0,D0
nomaxsvep1b:    move.w  D0,nowsvep
blitgetout:     move.b  improve_mouse(PC),D0
                beq     blitklet_nomouse
                movea.l mouseptr(PC),A2
                tst.b   CUR_FLAG-GCURY(A2)
                beq     blitklet_nomouse
                movea.l hires_screen(PC),A0
                movea.l medres_screen(PC),A1
                move.w  (A2),D0
                sub.w   M_POS_HY-GCURY(A2),D0
                sub.w   #16,D0
                bpl.s   blitklet_censy2
                moveq   #0,D0
blitklet_censy2:cmp.w   #352,D0
                ble.s   blitklet_censy
                move.w  #352,D0
blitklet_censy: and.b   #$FE,D0
                muls    #80,D0
                adda.w  D0,A0
                adda.w  D0,A1
                move.w  -(A2),D0
                sub.w   M_POS_HX-GCURX(A2),D0
                sub.w   #16,D0
                bpl.s   blitklet_censx2
                moveq   #0,D0
blitklet_censx2:cmp.w   #576,D0
                ble.s   blitklet_censx
                move.w  #576,D0
blitklet_censx: and.b   #$FE,D0
                lsr.w   #3,D0
                adda.w  D0,A0
                lsl.w   #1,D0
                and.b   #$FC,D0
                adda.w  D0,A1
                lea     halftone+$20.w,A3
                movea.l A3,A4
                move.l  #$02009A,(A3)+
                move.l  A0,(A3)+
                addq.l  #6,A3
                move.l  #$040094,(A3)+
                move.l  A1,(A3)+
                move.l  #$040018,(A3)+
                move.w  #$0203,(A3)+
                clr.w   (A3)
                moveq   #7,D0
blitklet_loop3: bset    D0,(A3)
                nop
                btst    D0,(A3)
                bne.s   blitklet_loop3
                move.l  #$02009A,(A4)+
                lea     80(A0),A0
                move.l  A0,(A4)+
                addq.l  #6,A4
                move.l  #$040094,(A4)+
                addq.l  #2,A1
                move.l  A1,(A4)+
                move.l  #$040018,(A4)+
                move.w  #$0203,(A4)+
                clr.w   (A4)
                moveq   #7,D0
blitklet_loop4: bset    D0,(A4)
                nop
                btst    D0,(A4)
                bne.s   blitklet_loop4
blitklet_nomouse:movem.l (SP)+,D0-A6
                move.l  old_vbi(PC),-(SP)
                rts

                ENDPART
                >PART 'Snabb'

fast:           move.b  palno(PC),D6
                ext.w   D6
                add.w   D6,D6
                lea     palettes(PC),A6
                move.w  0(A6,D6.w),D6
                move.w  D6,D7
                swap    D7
                move.w  D6,D7
                moveq   #0,D6
                btst    #0,color0+1.w
                beq.s   no_invert2
                exg     D6,D7
no_invert2:     movem.l D6-D7,color0.w
                adda.w  D1,A0
                adda.w  D1,A2
                move.b  use_blitter(PC),D1
                bne     fastblit
vbiloop2:       move.w  D0,-(SP)
i               SET 0
                REPT 25
                movem.w (A0)+,D0-D7/A1/A3-A6
                movem.l D0-D7/A1/A3-A6,i(A2)
                movem.w (A0)+,D0-D7/A1/A3-A6
                movem.l D0-D7/A1/A3-A6,i+52(A2)
                movem.w (A0)+,D0-D7/A1/A3-A6
                movem.l D0-D7/A1/A3-A6,i+104(A2)
                move.w  (A0)+,i+158(A2)
                lea     80(A0),A0
i               SET i+160
                ENDR
                lea     4000(A2),A2
                move.w  (SP)+,D0
                dbra    D0,vbiloop2
                move.w  nowsvep(PC),D0
                addq.w  #1,D0
                cmp.w   svep(PC),D0
                ble.s   nomaxsvep3
                moveq   #0,D0
nomaxsvep3:     move.w  D0,nowsvep
                move.b  improve_mouse(PC),D0
                beq     fast_nomouse
                movea.l mouseptr(PC),A2
                tst.b   CUR_FLAG-GCURY(A2)
                beq     fast_nomouse
                movea.l hires_screen(PC),A0
                movea.l medres_screen(PC),A1
                move.w  (A2),D0
                sub.w   M_POS_HY-GCURY(A2),D0
                sub.w   #16,D0
                bpl.s   fast_censury2
                moveq   #0,D0
fast_censury2:  cmp.w   #352,D0
                ble.s   fast_censury
                move.w  #352,D0
fast_censury:   and.b   #$FE,D0
                muls    #80,D0
                adda.w  D0,A0
                adda.w  D0,A1
                move.w  -(A2),D0
                sub.w   M_POS_HX-GCURX(A2),D0
                sub.w   #16,D0
                bpl.s   fast_censurx2
                moveq   #0,D0
fast_censurx2:  cmp.w   #576,D0
                ble.s   fast_censurx
                move.w  #576,D0
fast_censurx:   lsr.w   #3,D0
                and.b   #$FE,D0
                adda.w  D0,A0
                lsl.w   #1,D0
                and.b   #$FC,D0
                adda.w  D0,A1
i               SET 0
                REPT 24
                movem.w i(A0),D0-D3
                movem.l D0-D3,i(A1)
i               SET i+160
                ENDR
fast_nomouse:   movem.l (SP)+,D0-A6
                move.l  old_vbi(PC),-(SP)
                rts

                ENDPART
                >PART 'Snabb med blitter'

fastblit:       lea     halftone+$20.w,A3
                move.l  #$020052,(A3)+
                move.l  A0,(A3)+
                moveq   #-1,D1
                move.l  D1,(A3)+
                move.w  D1,(A3)+
                move.l  #$040004,(A3)+
                addq.l  #2,A2
                move.l  A2,(A3)+
                move.w  #40,(A3)+
                addq.w  #1,D0
                muls    #25,D0
                move.w  D0,(A3)+
                move.w  #$0203,(A3)+
                clr.w   (A3)
                moveq   #7,D2
fastblit_loop:  bset    D2,(A3)
                nop
                btst    D2,(A3)
                bne.s   fastblit_loop
                move.w  nowsvep(PC),D0
                addq.w  #1,D0
                cmp.w   svep(PC),D0
                ble.s   nomaxsvep3b
                moveq   #0,D0
nomaxsvep3b:    move.w  D0,nowsvep
                move.b  improve_mouse(PC),D0
                beq     fastblit_nomouse
                movea.l mouseptr(PC),A2
                tst.b   CUR_FLAG-GCURY(A2)
                beq     fastblit_nomouse
                movea.l hires_screen(PC),A0
                movea.l medres_screen(PC),A1
                move.w  (A2),D0
                sub.w   M_POS_HY-GCURY(A2),D0
                sub.w   #16,D0
                bpl.s   fastblit_censury2
                moveq   #0,D0
fastblit_censury2:cmp.w #352,D0
                ble.s   fastblit_censury
                move.w  #352,D0
fastblit_censury:and.b  #$FE,D0
                muls    #80,D0
                adda.w  D0,A0
                adda.w  D0,A1
                move.w  -(A2),D0
                sub.w   M_POS_HX-GCURX(A2),D0
                sub.w   #16,D0
                bpl.s   fastblit_censurx2
                moveq   #0,D0
fastblit_censurx2:cmp.w #576,D0
                ble.s   fastblit_censurx
                move.w  #576,D0
fastblit_censurx:lsr.w  #3,D0
                and.b   #$FE,D0
                adda.w  D0,A0
                lsl.w   #1,D0
                and.b   #$FC,D0
                adda.w  D0,A1
                lea     halftone+$20.w,A3
                move.l  #$02009A,(A3)+
                move.l  A0,(A3)+
                addq.l  #6,A3
                move.l  #$040094,(A3)+
                addq.l  #2,A1
                move.l  A1,(A3)+
                move.l  #$040018,(A3)+
                move.w  #$0203,(A3)+
                clr.w   (A3)
                moveq   #7,D0
fastblit_loop4: bset    D0,(A3)
                nop
                btst    D0,(A3)
                bne.s   fastblit_loop4
fastblit_nomouse:movem.l (SP)+,D0-A6
                move.l  old_vbi(PC),-(SP)
                rts

                ENDPART
                >PART 'Zoom'

split:          adda.w  D1,A2
                lsr.w   #1,D1
                adda.w  D1,A0
                movea.l mouseptr(PC),A3
                move.w  (A3),D1
                lea     savemousey(PC),A3
                move.w  D1,(A3)
                move.w  yoffset(PC),D2
                sub.w   #32,D1
                bpl.s   no20
                moveq   #0,D1
no20:           cmp.w   D1,D2
                blt.s   notop
                move.w  D1,D2
                bra.s   calc
notop:          sub.w   #136,D1
                cmp.w   D1,D2
                bgt.s   calc
                move.w  D1,D2
calc:           cmp.w   #200,D2
                ble.s   nobot
                move.w  #200,D2
nobot:          lea     yoffset(PC),A3
                move.w  D2,(A3)
                move.w  D2,D1
                lsl.w   #6,D1
                lsl.w   #4,D2
                add.w   D1,D2
                adda.w  D2,A0
                move.b  palno(PC),D6
                ext.w   D6
                add.w   D6,D6
                lea     palettes(PC),A6
                adda.w  D6,A6
                move.w  (A6),D7
                swap    D7
                move.w  (A6),D7
                moveq   #0,D6
                btst    #0,color0+1.w
                beq.s   no_invert3
                exg     D6,D7
no_invert3:     movem.l D6-D7,color0.w
                move.b  use_blitter(PC),D1
                bne     blitsplit
vbiloop3:       move.w  D0,-(SP)
i               SET 0
                REPT 76
                movem.w (A0)+,D0-D7/A1/A3-A6
                movem.l D0-D7/A1/A3-A6,i(A2)
i               SET i+52
                ENDR
                movem.w (A0)+,D0-D7/A3-A6
                movem.l D0-D7/A3-A6,3952(A2)
                move.w  (SP)+,D0
                lea     4000(A2),A2
                dbra    D0,vbiloop3
                lea     nowsvep(PC),A0
                move.w  (A0),D0
                addq.w  #1,D0
                cmp.w   svep(PC),D0
                ble.s   nomaxsvep2
                moveq   #0,D0
nomaxsvep2:     move.w  D0,(A0)
                move.b  improve_mouse(PC),D0
                beq     split_nomouse
                movea.l mouseptr(PC),A2
                tst.b   CUR_FLAG-GCURY(A2)
                beq     split_nomouse
                movea.l hires_screen(PC),A0
                movea.l medres_screen(PC),A1
                move.w  savemousey(PC),D0
                sub.w   M_POS_HY-GCURY(A2),D0
                sub.w   #16,D0
                bpl.s   split_censuryb
                moveq   #0,D0
split_censuryb: cmp.w   #352,D0
                ble.s   split_censury
                move.w  #352,D0
split_censury:  move.w  D0,D1
                sub.w   yoffset(PC),D1
                muls    #80,D0
                adda.w  D0,A0
                muls    #160,D1
                adda.w  D1,A1
                move.w  -(A2),D0        ; A2 pekar nu p† GCURX
                sub.w   M_POS_HX-GCURX(A2),D0
                sub.w   #16,D0
                bpl.s   split_censurxb
                moveq   #0,D0
split_censurxb: cmp.w   #576,D0
                ble.s   split_censurx
                move.w  #576,D0
split_censurx:  lsr.w   #3,D0
                and.b   #$FE,D0
                adda.w  D0,A0
                add.w   D0,D0
                adda.w  D0,A1
i               SET 0
                REPT 48
                movem.w i(A0),D0-D3
                movem.l D0-D3,2*i(A1)
i               SET i+80
                ENDR
split_nomouse:  movem.l (SP)+,D0-A6
vbiend2:        move.l  old_vbi(PC),-(SP)
                rts

                ENDPART
                >PART 'Zoom med blitter'

blitsplit:      lea     halftone+$20.w,A3
                move.l  #$020000,(A3)+
                move.l  A0,(A3)+
                moveq   #-1,D1
                move.l  D1,(A3)+
                move.w  D1,(A3)+
                move.l  #$040000,(A3)+
                addq.l  #2,A2
                move.l  A2,(A3)+
                addq.w  #1,D0
                muls    #1000,D0
                move.w  D0,(A3)+
                move.w  #1,(A3)+
                move.w  #$0203,(A3)+
                clr.w   (A3)
                moveq   #7,D0
blitwait:       bset    D0,(A3)
                nop
                btst    D0,(A3)
                bne.s   blitwait
                lea     nowsvep(PC),A0
                move.w  (A0),D0
                addq.w  #1,D0
                cmp.w   svep(PC),D0
                ble.s   nomaxsvep2b
                moveq   #0,D0
nomaxsvep2b:    move.w  D0,(A0)
                move.b  improve_mouse(PC),D0
                beq     split_nomouse2
                movea.l mouseptr(PC),A2
                tst.b   CUR_FLAG-GCURY(A2)
                beq     split_nomouse2
                movea.l hires_screen(PC),A0
                movea.l medres_screen(PC),A1
                move.w  savemousey(PC),D0
                sub.w   M_POS_HY-GCURY(A2),D0
                sub.w   #16,D0
                bpl.s   split_censury2b
                moveq   #0,D0
split_censury2b:cmp.w   #352,D0
                ble.s   split_censury2
                move.w  #352,D0
split_censury2: move.w  D0,D1
                sub.w   yoffset(PC),D1
                muls    #80,D0
                adda.w  D0,A0
                muls    #160,D1
                adda.w  D1,A1
                move.w  -(A2),D0        ; A2 pekar nu p† GCURX
                sub.w   M_POS_HX-GCURX(A2),D0
                sub.w   #16,D0
                bpl.s   split_censurx2b
                moveq   #0,D0
split_censurx2b:cmp.w   #576,D0
                ble.s   split_censurx2
                move.w  #576,D0
split_censurx2: lsr.w   #3,D0
                and.b   #$FE,D0
                adda.w  D0,A0
                add.w   D0,D0
                adda.w  D0,A1
                lea     halftone+$20.w,A3
                move.l  #$02004A,(A3)+
                move.l  A0,(A3)+
                addq.l  #6,A3
                move.l  #$040094,(A3)+
                addq.l  #2,A1
                move.l  A1,(A3)+
                move.l  #$040030,(A3)+
                move.w  #$0203,(A3)+
                clr.w   (A3)
                moveq   #7,D0
blitsplit_loop: bset    D0,(A3)
                nop
                btst    D0,(A3)
                bne.s   blitsplit_loop
split_nomouse2: movem.l (SP)+,D0-A6
                move.l  old_vbi(PC),-(SP)
                rts

                ENDPART
                >PART 'Residenta Data & BSS'

hires_screen:   DS.L 1
medres_screen:  DS.L 1
mouseptr:       DS.L 1
kbd_buffer:     DS.L 1
yoffset:        DS.W 1
savemousey:     DS.W 1
diskcount:      DC.W 0
palettes:       DC.W $0FFF,$0DFD,$0FED,$0DFF
speedtab:       DC.W 4000,7     ; Format: bytes/svep, svep/sk„rm-1
                DC.W 8000,3
                DC.W 16000,1
ikbd_lastpos:   DC.L 0
has_blitter:    DC.B 0
use_blitter:    DC.B 0
steflag:        DC.B 0
blittoggle:     DC.B 0
ikbd_temp:      DC.B 0
ikbd_flag:      DC.B 0
tos2kbdflag:    DC.B 0
saveshift:      DC.B 0
hello:          DC.B 27,'E',27,'Y',33,55,27,"p SeBra 1.33 - Patrik Persson 1992 ",27,'q',13,10,10,0

                EVEN

cookie_jar:     DS.L 2*cookie_jar_size

picstart:
                ENDPART
; F”ljande skrivs ”ver och blir nytt fysiskt bildminne
                >PART 'Supervisorrutin 2 mm'

mysuper:        move.l  A0,-(SP)
                move.w  #supexec,-(SP)
                trap    #XBIOS
                addq.l  #6,SP
                rts

super2:

; Kolla om det „r en STE

                move.l  p_cookies.w,D0
                beq.s   check_end
                movea.l D0,A0
check_loop:     movem.l (A0)+,D0-D1
                tst.l   D0
                beq.s   check_end
                cmp.l   #"_VDO",D0
                bne.s   check_loop
                swap    D1
                tst.w   D1
                beq.s   check_end
                lea     steflag(PC),A0
                st      (A0)
check_end:      bsr     set_freq

; Initiera Line-A-variablerna

                linea   #0 [ Init ]
                movea.l 8(A1),A1
                move.w  82(A1),V_CEL_HT(A0)
                lea     V_FNT_AD(A0),A0
                move.l  76(A1),(A0)+
                move.w  38(A1),(A0)+
                move.w  36(A1),(A0)+
                move.w  80(A1),(A0)
                addq.l  #4,A0
                move.l  72(A1),(A0)+
                move.w  #$0100,(A0)+
                move.l  #$01900050,(A0)+
                move.l  #$010050,(A0)
                lea     GCURY(A0),A0
                lea     mouseptr(PC),A1
                move.l  A0,(A1)

; B”ka systemvariabel

                move.b  #2,sshiftmd.w   ; H”guppl”sning!

; Dona och trixa med cookie-jar

                lea     p_cookies.w,A0
                move.l  (A0),D0
                beq.s   bakakaka
                movea.l D0,A1
                moveq   #0,D0
cookie_loop:    addq.l  #1,D0
                tst.l   (A1)
                beq.s   cookie_end
                addq.l  #8,A1
                bra.s   cookie_loop
cookie_end:     move.l  4(A1),D1
                cmp.l   D1,D0
                bpl.s   cookie_full
                move.l  sebraid(PC),(A1)+
                lea     varbase(PC),A0
                move.l  A0,(A1)+
                clr.l   (A1)+
                move.l  D1,(A1)
                move.w  #cookie_jar-picstart,D0
                rts
cookie_full:    movea.l (A0),A1
                lea     cookie_jar(PC),A0
cookie_loop3:   movem.l (A1)+,D0-D1
                tst.l   D0
                beq.s   stoppa_i_kaka
                movem.l D0-D1,(A0)
                addq.l  #8,A0
                bra.s   cookie_loop3
bakakaka:       lea     cookie_jar(PC),A0
                move.l  A0,p_cookies.w
stoppa_i_kaka:  move.l  sebraid(PC),(A0)+
                lea     varbase(PC),A1
                move.l  A1,(A0)+
                clr.l   (A0)+
                move.l  #cookie_jar_size,(A0)
                moveq   #0,D0
                rts

; Rutin f”r att finna giltig CBra-cookie. Supervisormode.
; Retur 0 (fel) eller cookie-v„rde i variabeln cookie_jar

findme:         lea     cookie_jar(PC),A0
                clr.l   (A0)
                move.l  p_cookies.w,D0
                beq.s   foundme
                movea.l D0,A1
                move.l  sebraid(PC),D0
findme_loop:    movem.l (A1)+,D1/A2
                tst.l   D1
                beq.s   foundme
                cmp.l   D0,D1
                bne.s   findme_loop
                movea.l A2,A1
                lea     varbase(PC),A3
                cmpm.l  (A1)+,(A3)+
                bne.s   foundme
                cmpm.w  (A1)+,(A3)+
                bne.s   foundme
                move.l  A2,(A0)
foundme:        rts

; Ta hand om 50/60 Hz

set_freq:       move.b  freq(PC),D0
                subq.b  #1,D0
                bgt.s   skiphz
                bmi.s   hz50jump
                bclr    #1,syncmode.w
                bra.s   skiphz
hz50jump:       bset    #1,syncmode.w
skiphz:         rts

; Kollar TOS-version

checktos:       movea.l _sysbase.w,A0
                lea     int_out(PC),A1
                move.w  2(A0),(A1)
                rts

                ENDPART
                >PART 'Om GEM finns, k”r meny'

uppstart:       lea     doaes(PC),A6

noclear:        bsr     doaes2          * Appl_init redan inlagd!
                tst.w   global-doaes(A6) * AES versionsnummer
                beq     noaes           * Om 0, inget AES

                moveq   #31,D7
obfix_loop:     lea     objekt(PC),A0
                move.l  A0,addr_in-doaes(A6)
                move.w  D7,int_in-doaes(A6)
                move.l  #rsrc_obfix,D0
                jsr     (A6)
                dbra    D7,obfix_loop

                lea     space(PC),A0
                move.l  A0,addr_in-doaes(A6)
                lea     128(A0),A0
                move.l  A0,addr_in+4-doaes(A6)
                move.l  #shel_read,D0
                jsr     (A6)

                lea     findme(PC),A0
                bsr     mysuper
                move.l  cookie_jar(PC),D0
                beq.s   nocookie
                movea.l D0,A0
                st      disable-varbase(A0)
                lea     varbase(PC),A1
                cmpm.l  (A1)+,(A0)+
                bne.s   nocookie
                cmpm.w  (A1)+,(A0)+
                moveq   #6,D0
cookie_loop2:   move.w  (A0)+,(A1)+
                dbra    D0,cookie_loop2
                move.b  (A0),(A1)
                move.b  #2,-(A1)

nocookie:       moveq   #0,D0
                move.w  lineno(PC),D1
                cmp.w   #8000,D1
                bne.s   no_50
                moveq   #24,D0
no_50:          cmp.w   #16000,D1
                bne.s   no_100
                moveq   #48,D0
no_100:         lea     speed1(PC),A0
                bset    #0,11(A0,D0.w)

                moveq   #0,D0
                move.b  mode(PC),D1
                beq.s   nomode_b
                moveq   #24,D0
                cmp.b   #1,D1
                beq.s   nomode_b
                moveq   #48,D0
nomode_b:       lea     mode1(PC),A0
                bset    #0,11(A0,D0.w)

                move.b  palno(PC),D0
                ext.w   D0
                muls    #24,D0
                lea     vit(PC),A0
                bset    #0,11(A0,D0.w)

                moveq   #0,D2
                move.b  freq(PC),D2
                cmpi.b  #2,D2
                beq.s   setfreqbit

                clr.l   -(SP)
                move.w  #super,-(SP)
                trap    #GEMDOS
                move.b  $FFFF820A.w,int_out+1-doaes(A6)
                move.l  D0,2(SP)
                trap    #GEMDOS
                addq.l  #6,SP

                move.w  int_out(PC),D2
                lsr.w   #1,D2
                not.w   D2
                and.w   #1,D2

setfreqbit:     muls    #24,D2
                lea     hz50(PC),A0
                bset    #0,11(A0,D2.w)

                move.b  improve_mouse(PC),D0
                beq.s   nogoodmouse
                lea     goodmouse+12(PC),A0
                move.b  #8,(A0)

nogoodmouse:    move.b  autobootflag(PC),D0
                beq.s   noautoboot
                lea     autoboot+12(PC),A0
                move.b  #8,(A0)

noautoboot:     clr.w   int_in-doaes(A6)
                move.l  #graf_mouse,D0
                jsr     (A6)

                lea     objekt(PC),A0
                move.l  A0,addr_in-doaes(A6)
                move.l  #form_center,D0
                jsr     (A6)

                moveq   #0,D0
                bsr     do_formdial

                moveq   #2,D0
                move.l  D0,int_in-doaes(A6)
                move.l  int_out+2(PC),int_in+4-doaes(A6)
                move.l  int_out+6(PC),int_in+8-doaes(A6)
                move.l  #objc_draw,D0
                jsr     (A6)

menu_loop:      clr.w   int_in-doaes(A6)
                move.l  #form_do,D0
                jsr     (A6)

                move.w  int_out(PC),D0
                cmpi.w  #avbryt,D0
                beq     donesave

                muls    #24,D0
                lea     objekt(PC),A0
                cmpi.w  #g_boxchar,6(A0,D0.w)
                bne.s   no_boxtext

                eori.b  #8,12(A0,D0.w)
                move.w  int_out(PC),int_in-doaes(A6)
                clr.w   int_in+2-doaes(A6)
                move.l  #objc_draw,D0
                jsr     (A6)

no_boxtext:     moveq   #0,D0
                moveq   #2,D1
                lea     speed1+11-24(PC),A0
gemloop2:       lea     24(A0),A0
                addq.w  #1,D0
                btst    #0,(A0)
                dbne    D1,gemloop2
                lea     speedtab-4(PC),A0
                lsl.w   #2,D0
                move.l  0(A0,D0.w),D0
                move.l  D0,lineno-doaes(A6)
                sf      D0
                move.l  D0,nowline-doaes(A6)

                moveq   #0,D0
                btst    #0,mode1+11(PC)
                bne.s   gotmode
                moveq   #1,D0
                btst    #0,mode2+11(PC)
                bne.s   gotmode
                moveq   #2,D0
gotmode:        move.b  D0,mode-doaes(A6)

                moveq   #-1,D0
                moveq   #3,D1
                lea     vit+11-24(PC),A0
gemloop4:       lea     24(A0),A0
                addq.b  #1,D0
                btst    #0,(A0)
                dbne    D1,gemloop4
                move.b  D0,palno-doaes(A6)

                moveq   #-1,D0
                moveq   #2,D1
                lea     hz50+11-24(PC),A0
gemloop5:       lea     24(A0),A0
                addq.b  #1,D0
                btst    #0,(A0)
                dbne    D1,gemloop5
                move.b  D0,freq-doaes(A6)

                btst    #3,goodmouse+12(PC)
                sne     improve_mouse-doaes(A6)

                btst    #3,autoboot+12(PC)
                sne     autobootflag-doaes(A6)

                lea     findme(PC),A0
                bsr     mysuper
                move.l  cookie_jar(PC),D0
                beq.s   nocookie2
                lea     varbase+6(PC),A0
                movea.l D0,A1
                addq.l  #6,A1
                moveq   #5,D0
use_loop:       move.w  (A0)+,(A1)+
                dbra    D0,use_loop
                move.b  (A0),(A1)
                lea     set_freq(PC),A0
                bsr     mysuper
nocookie2:      cmpi.w  #spara,int_out-doaes(A6)
                bne     menu_loop

save_settings:  move.w  #2,int_in-doaes(A6)
                move.l  #graf_mouse,D0
                jsr     (A6)

                move.w  #2,-(SP)        * L„s & skriv
                pea     space(PC)
                move.w  #fopen,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                move.w  D0,D7
                bmi.s   nosave

                moveq   #38,D6
                pea     space(PC)
                move.l  D6,-(SP)
                move.w  D7,-(SP)
                move.w  #fread,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                cmp.l   D0,D6
                bne.s   nosave

                moveq   #-33,D0
                lea     sebraid(PC),A0
                move.l  (A0)+,D1
                cmp.l   space+32(PC),D1
                bne.s   nosave
                move.w  (A0)+,D1
                cmp.w   space+36(PC),D1
                bne.s   nosave

                move.l  A0,-(SP)
                pea     13.w
                move.w  D7,-(SP)
                move.w  #fwrite,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                moveq   #13,D1
                cmp.l   D0,D1
                bne.s   nosave

                move.w  D7,-(SP)
                move.w  #fclose,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP
                tst.w   D0
                bne.s   nosave

                lea     alert(PC),A0
                move.l  A0,addr_in-doaes(A6)
                move.w  #1,int_in-doaes(A6)
                move.l  #form_alert,D0
                jsr     (A6)
                bra.s   donesave

nosave:         not.w   D0
                sub.w   #30,D0
                move.w  D0,int_in-doaes(A6)
                move.l  #form_error,D0
                jsr     (A6)

donesave:       lea     findme(PC),A0
                bsr     mysuper
                move.l  cookie_jar(PC),D0
                beq.s   donesave_nocookie
                movea.l D0,A0
                sf      disable-varbase(A0)
donesave_nocookie:moveq #3,D0
                bsr.s   do_formdial
                move.l  #appl_exit,D0
                jsr     (A6)
                move.l  #$4C0000,-(SP)  * Pterm(0)
                trap    #GEMDOS

; R„knar med att XYWH finns i int_out+2..int_out+8

do_formdial:    move.w  D0,int_in-doaes(A6)
                movem.w int_out+2(PC),D0-D3
                movem.w D0-D3,int_in+10-doaes(A6)
                lsr.w   #1,D2
                add.w   D2,D0
                subq.w  #5,D0
                lsr.w   #1,D3
                add.w   D3,D1
                subq.w  #5,D1
                moveq   #10,D2
                moveq   #10,D3
                movem.w D0-D3,int_in+2-doaes(A6)
                move.l  #form_dial,D0

doaes:          lea     control(PC),A0
                movep.l D0,1(A0)
doaes2:         lea     aespb(PC),A0
                move.l  A0,D1
                move.w  #aes,D0
                trap    #XGEMDOS
                rts

                ENDPART
                >PART 'Inget GEM, installera'

* Kolla om datorn redan „r i monol„ge

noaes:          move.w  #getrez,-(SP)
                trap    #XBIOS
                addq.l  #2,SP
                lea     monobyebye(PC),A0
                subq.w  #2,D0
                beq.s   end

                linea   #0 [ Init ]
                movea.l A0,A1
                lea     rezerror_str(PC),A0
                cmpi.w  #200,V_REZ_VT(A1)
                bgt.s   end

                move.b  autobootflag(PC),D0
                bne.s   fejka

                lea     hellostr(PC),A0
                bsr.s   sendlin
                move.w  #cconin,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                cmp.w   #27,D0
                bne.s   fejka

                lea     byebye(PC),A0
end:            bsr.s   sendlin

                pea     $4C0000         * Pterm(0)
                trap    #GEMDOS

sendlin:        move.l  A0,-(SP)
                move.w  #cconws,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                rts

* B”rja installera - kolla blittern

fejka:          lea     checktos(PC),A0
                bsr     mysuper
                cmpi.w  #$0100,int_out-doaes(A6)
                beq.s   no_blitter
                move.l  #$40FFFF,-(SP)  * blitmode(-1)
                trap    #XBIOS
                addq.l  #6,SP
                btst    #1,D0
                beq.s   no_blitter
                st      has_blitter
                lsr.w   #1,D0
                scc     use_blitter-doaes(A6)

no_blitter:     move.w  #1,-(SP)        * Mediumuppl”sning i h†rdvaran
                pea     -1.w
                move.l  (SP),-(SP)
                move.w  #setscreen,-(SP)
                trap    #XBIOS
                lea     12(SP),SP

                move.l  #$0E0001,-(SP)  * _iorec(1)
                trap    #XBIOS
                addq.l  #4,SP
                move.l  D0,kbd_buffer-doaes(A6)

                move.w  #kbdvbase,-(SP)
                trap    #XBIOS
                addq.l  #2,SP
                movea.l D0,A0
                lea     $20(A0),A0
                move.l  (A0),old_ikbd-doaes(A6)
                lea     kbd(PC),A1
                move.l  A1,(A0)

                bra     install

                ENDPART
                DATA
                >PART 'Objekttr„d'

g_box           EQU 20
g_text          EQU 21
g_boxtext       EQU 22
g_ibox          EQU 25
g_button        EQU 26
g_boxchar       EQU 27

spara           EQU 30
avbryt          EQU 31

* Objekttr„d:
* 0
objekt:         DC.W -1,1,31,g_box,0,16,2,$1012,0,0,39,23
* 1
boxminus1:      DC.W 4,2,3,g_box,0,16
                DC.W $FF,$8000,2,$0200,35,$0201
* 2
rubrik0:        DC.W 3,-1,-1,g_text,0,0
                DC.L tedinfo6
                DC.W 0,$0100,35,1
* 3
name:           DC.W 1,-1,-1,g_text,0,0
                DC.L tedinfo5
                DC.W 0,4711,35,$0201
* 4
box0:           DC.W 9,5,8,g_box,0,16
                DC.W $00,$8000,2,$0402,35,3
* 5
rubrik1:        DC.W 6,-1,-1,g_text,0,0
                DC.L tedinfo1
                DC.W 0,0,35,1
* 6
speed1:         DC.W 7,-1,-1,g_button,64+16+1,32+16
                DC.L spptr1
                DC.W 1,$0401,10,1
* 7
speed2:         DC.W 8,-1,-1,g_button,64+16+1,32+16
                DC.L spptr2
                DC.W $040C,$0401,10,1
* 8
speed3:         DC.W 4,-1,-1,g_button,64+16+1,32+16
                DC.L spptr3
                DC.W 24,$0401,10,1
* 9
box1:           DC.W 14,10,13,g_box,0,16
                DC.W 0,$8000,2,$0406,35,3
* 10
rubrik2:        DC.W 11,-1,-1,g_text,0,0
                DC.L tedinfo2
                DC.W 0,0,35,1
* 11
mode1:          DC.W 12,-1,-1,g_button,64+16+1,32+16
                DC.L mode1ptr
                DC.W 1,$0401,10,1
* 12
mode2:          DC.W 13,-1,-1,g_button,64+16+1,32+16
                DC.L mode2ptr
                DC.W $040C,$0401,10,1
* 13
mode3:          DC.W 9,-1,-1,g_button,64+16+1,32+16
                DC.L mode3ptr
                DC.W 24,$0401,10,1
* 14
box2:           DC.W 19,15,18,g_box,0,16
                DC.W 0,$8000,2,$040A,35,3
* 15
rubrik3:        DC.W 16,-1,-1,g_text,0,0
                DC.L tedinfo3
                DC.W 0,0,35,1
* 16
hz50:           DC.W 17,-1,-1,g_button,64+16+1,32+16
                DC.L h50ptr
                DC.W 1,$0401,10,1
* 17
hz60:           DC.W 18,-1,-1,g_button,64+16+1,32+16
                DC.L h60ptr
                DC.W $040C,$0401,10,1
* 18
hzno:           DC.W 14,-1,-1,g_button,64+16+1,32+16
                DC.L hznoptr
                DC.W 24,$0401,10,1
* 19
box3:           DC.W 25,20,24,g_box,0,16
                DC.W 0,$8000,2,$040E,35,3
* 20
rubrik4:        DC.W 21,-1,-1,g_text,0,0
                DC.L tedinfo4
                DC.W 1,0,33,1
* 21
vit:            DC.W 22,-1,-1,g_button,64+16+1,32+16
                DC.L vitptr
                DC.W 1,$0401,7,1
* 22
gron:           DC.W 23,-1,-1,g_button,64+16+1,32+16
                DC.L gronptr
                DC.W $0509,$0401,7,1
* 23
brun:           DC.W 24,-1,-1,g_button,64+16+1,32+16
                DC.L brunptr
                DC.W $0212,$0401,7,1
* 24
bla:            DC.W 19,-1,-1,g_button,64+16+1,32+16
                DC.L blaptr
                DC.W $071A,$0401,7,1
* 25
box4:           DC.W 30,26,29,g_box,0,16
                DC.W 0,$8000,2,$0412,35,$0202
* 26
rubrik5:        DC.W 27,-1,-1,g_text,0,0
                DC.L tedinfo7
                DC.W 6,0,22,1
* 27
rubrik6:        DC.W 28,-1,-1,g_text,0,0
                DC.L tedinfo8
                DC.W 6,$0201,22,1
* 28
goodmouse:      DC.W 29,-1,-1,g_boxchar,64,0
                DC.L $FF1100
                DC.W 2,0,2,1
* 29
autoboot:       DC.W 25,-1,-1,g_boxchar,64,0
                DC.L $FF1100
                DC.W 2,$0201,2,1
* 30
_spara:         DC.W 31,-1,-1,g_button,1+2+4,0
                DC.L sparaptr
                DC.W 8,$0415,10,1
* 31
_avbryt:        DC.W 0,-1,-1,g_button,1+4+32,0
                DC.L avbptr
                DC.W 21,$0415,10,1

                ENDPART
                >PART 'Data'

tedinfo1:       DC.L te_ptext1,0,0
                DC.W 3,0,2,$0400,0,0,17,0
tedinfo2:       DC.L te_ptext2,0,0
                DC.W 3,0,2,$0400,0,0,16,0
tedinfo3:       DC.L te_ptext3,0,0
                DC.W 3,0,2,$0400,0,0,26,0
tedinfo4:       DC.L te_ptext4,0,0
                DC.W 3,0,2,$0400,0,0,9,0
tedinfo5:       DC.L te_ptext5,0,0
                DC.W 5,0,2,$0900,0,0,20,0
tedinfo6:       DC.L te_ptext6,0,0
                DC.W 3,0,2,$0A00,0,0,30,0
tedinfo7:       DC.L te_ptext7,0,0
                DC.W 3,0,0,$0400,0,0,23,0
tedinfo8:       DC.L te_ptext8,0,0
                DC.W 3,0,0,$0400,0,0,22,0

aespb:          DC.L control,global,int_in,int_out,addr_in,addr_out

control:        DC.W 10,0,1,0,0 ; Default=appl_init

avbptr:         DC.B "End",0
sparaptr:       DC.B "Save",0
spptr1:         DC.B "Low",0
spptr2:         DC.B "Normal",0
spptr3:         DC.B "High",0
mode1ptr:       DC.B "Shaded",0
mode2ptr:       DC.B "Fast",0
mode3ptr:       DC.B "Magnified",0
vitptr:         DC.B "White",0
gronptr:        DC.B "Green",0
brunptr:        DC.B "Brown",0
blaptr:         DC.B "Blue",0
h50ptr:         DC.B "50 Hz",0
h60ptr:         DC.B "60 Hz",0
hznoptr:        DC.B "No change",0
te_ptext1:      DC.B "Emulation speed:",0
te_ptext2:      DC.B "Emulation mode:",0
te_ptext3:      DC.B "Vertical blank frequency:",0
te_ptext4:      DC.B "Palette:",0
te_ptext5:      DC.B "PATRIK PERSSON 1993",0
te_ptext6:      DC.B "SeBra 1.33 - DEFAULT SETTINGS",0
te_ptext7:      DC.B "Enhanced mouse pointer",0
te_ptext8:      DC.B "Install automatically",0
alert:          DC.B "[1][Your settings have been saved|and will be used the next|time you boot SeBra from the|AUTO folder.][ OK ]",0
hellostr:       DC.B "
b"
                DC.B " øøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøø
"
                DC.B " ø          bc ¯ SeBra 1.33 ® bc0          ø
"
                DC.B " ø                                    ø
"
                DC.B " ø     bThe Hi-Res Screen Emulatorb     ø
"
                DC.B " ø                                    ø
"
                DC.B " ø        bPatrik Persson 1993b         ø
"
                DC.B " ø                                    ø
"
                DC.B " ø bAny key to install - Esc to cancel bø
"
                DC.B " øøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøø",13,0
byebye:         DC.B "A ø   bßb  Installation cancelled.   bßb   øb


",0
monobyebye:     DC.B 13,10,"The computer is already in high resolution mode. SeBra NOT installed.",13,10,10,0

rezerror_str:   DC.B "SeBra requires a standard sized
(320x200 or 640x200) colour screen.
",0

                ENDPART
                BSS
                >PART 'Balsamera SkinnSkallarna'

global:         DS.W 15
int_in:         DS.W 30
int_out:        DS.W 45
addr_in:        DS.L 3
addr_out:       DS.L 1
space:          DS.L 8000       ; Marginaler - o”nskat minne dumpas

                ENDPART
                END
