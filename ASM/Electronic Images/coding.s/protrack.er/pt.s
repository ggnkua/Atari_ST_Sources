;**********************************************************
;*                                                        *
;*  Protracker Version 2.0 - Release A                    *
;*  STE Conversion by Martin Griffiths                    *
;*    (aka Griff of Electronic Images)                    *
;*  Amiga Version Coded by Lars Hamre                     *
;*  with some "Resource" help from Anders Hamre           *
;*                                                        *
;* V2.00Beta STE : 09/01-1993 : Started STE conv!!        *
;* v0.1 STE      : 10/01-1993 : Draws screen/move mouse!  *
;*                                and displays pattern    *
;*               : 11/01-1993 : Memory alloc converted    *
;*                               (seems to work)          *
;*                              UpDown Gadgets and all    *
;*                              Text output done!         *
;* v0.2 STE      : 12/01-1993 : Disk read/write converted *
;*                              tempo/vbl/load module etc *
;*                              and numerous other bits.  *
;*                (replay rout to convert and will have)  *
;*                  a working version of PROTRACKER!!!!!) *
;*                  (disk-op and Keyboard handling are    *
;*                  the only real hard bits, but the key  *
;*                  rout will just convert st scancodes to*
;*                  the amiga scancode!!! save lots of    *
;*                  arseing about!                        *
;* v0.3 STE     : 13/01-1993  : Replay routine converted! *                       *
;*                (this was easier that i had thought...) *
;*                (lots of probs with interrupt clashes.. *
;*                 - a real bastard to solve.. rethink!!) *
;* v0.4 STE     : 14/01-1993  : Spectrum Analyzer conved  *
;*                              Quadrascope optimised too!*
;*                (keyboard scancode table convertor!!!!!)*
;*                 it works a treat..........             *
;*                 (Perhaps I might make this VBL only... *
;*                  since cia emulation is arseing up the *
;*                  other interrupts hmmmmmmmm.......)    *
;* v0.5 STE     : 15/01-1993  : Cursor Routine done!!     *
;*                pattern copy now done with blitter in   *
;*                share mode! (faster)... not many int    *
;*                clashes left, but low tempo is a prob.  *
;*                Corrections in keyboard scancodes done! *
;*                Vu-meters done,but not centered or fast!*
;*                Next version will fix all dff016/bfe001 *
;*                mouse button checks left to change!!!   *
;*                Using ring buffer system instead!       *
;*                TEMPO IS OUT FOR NOW!!!! ITS A BUGGER!  *
;*                Play single note works on the keyboard! *
;* v0.6 STE     : 19/01-1993 : Top border remover removed!*
;*                It doesn't really need it.......        *
;*                Setup/sampler screen draw routines convd*
;*                Most dff016/bfe001 are now converted too*
;*                Far less crashy in general!             *
;*                Vu-meters centered/off for sampler scrn *
;* v0.7 STE     : 21/01-1993 : Disk readdir converted     *
;*                Disk routines work, amigaish tho......  *
;*                A bit of a rewrite needed for path stuff*
;*                Mouse pointer is now "hardware"!!!!!!!  *
;*                Mouse pointer preshifted - saves cpu tme*
;*                Sample RETRIG (E9) now implemented..... *
;*                Vbl keyboard handler written, works!    *
;*                interrupts sorted out, no timing probs  *
;*                fixed tab and backspace scancodes!      *
;* v0.8 STE     : 28/01-1993 :                            *
;*                Converted lots of gfx to faster ST form *
;*                More tidying done,setup colour sliders. *
;*                keyboard handler fixed a little......   *
;*                Disk-op Tidyed up a lot... works ok...  *
;*                Tuning tone done!(hehe)                 *
;*                Forced play mode to vblank only on setup*
;*                Finally stretched screen properly,yeah! *
;*                Fixed lots of little things, timing etc *
;*                Save mod,sample and song now implemented*
;*                      - 3.disk delete,format,rename     *
;*                      - > v0.9                          *
;* v0.88 FALCON : 01/08-1993 Yes its I haven't touched    *
;*               this for over 6 months!! But I've some   *
;*               time free now...Just fixed all setup bits*
;*               Falcon version in 8 bplane mode to avoid *
;*               mouse h/ware sprite problems etc etc     *
;*               Falcon version is much cleaner now...    *
;* v0.89 FALCON : 31/08-1993 Beta version Nearly finished!*
;*                just sampler and tidying to finish...   *
;**********************************************************

                TEXT

beta            EQU 1
circbufsize     EQU $1400
dmamask         EQU %11         ; STE dmamask for 50khz
dirnamelength   EQU 30
configfilesize  EQU 1024
keybufsize      EQU 20

                >PART 'falcon video equates'

; SetVideo() equates.

vertflag        EQU $0100       ; double-line on VGA, interlace on ST/TV ;
stmodes         EQU $80         ; ST compatible ;
overscan        EQU $40         ; Multiply X&Y rez by 1.2, ignored on VGA ;
pal             EQU $20         ; PAL if set, else NTSC ;
vga             EQU $10         ; VGA if set, else TV mode ;
col80           EQU $08         ; 80 column if set, else 40 column ;
bps16           EQU $04
bps8            EQU $03
bps4            EQU $02
bps2            EQU $01
bps1            EQU $00

; Falcon video register equates

vwrap           EQU $FFFF8210
_spshift        EQU $FFFF8266
hht             EQU $FFFF8282
hbb             EQU $FFFF8284
hbe             EQU $FFFF8286
hdb             EQU $FFFF8288
hde             EQU $FFFF828A
hss             EQU $FFFF828C
hfs             EQU $FFFF828E
hee             EQU $FFFF8290
vft             EQU $FFFF82A2
vbb             EQU $FFFF82A4
vbe             EQU $FFFF82A6
vdb             EQU $FFFF82A8
vde             EQU $FFFF82AA
vss             EQU $FFFF82AC
vco             EQU $FFFF82C2

                ENDPART

                >PART 'fileformat'
; FileFormat

sd_songname     EQU 0
sd_sampleinfo   EQU 20
sd_numofpatt    EQU 950
sd_pattpos      EQU 952
sd_mahokakt     EQU 1080
sd_patterndata  EQU 1084
                ENDPART

                >PART 'audxtemp offsets'

; audXtemp offsets

n_note          EQU 0           ; W
n_cmd           EQU 2           ; W
n_cmdlo         EQU 3           ; low B of cmd
n_start         EQU 4           ; L
n_length        EQU 8           ; W
n_loopstart     EQU 10          ; L
n_replen        EQU 14          ; W
n_period        EQU 16          ; W
n_finetune      EQU 18          ; B
n_volume        EQU 19          ; B
n_dmabit        EQU 20          ; W
n_toneportdirec EQU 22          ; B
n_toneportspeed EQU 23          ; B
n_wantedperiod  EQU 24          ; W
n_vibratocmd    EQU 26          ; B
n_vibratopos    EQU 27          ; B
n_tremolocmd    EQU 28          ; B
n_tremolopos    EQU 29          ; B
n_wavecontrol   EQU 30          ; B
n_glissfunk     EQU 31          ; B
n_sampleoffset  EQU 32          ; B
n_pattpos       EQU 33          ; B
n_loopcount     EQU 34          ; B
n_funkoffset    EQU 35          ; B
n_wavestart     EQU 36          ; L
n_reallength    EQU 40          ; W
n_trigger       EQU 42          ; B
n_samplenum     EQU 43          ; B
                ENDPART

                >PART 'amiga os equates'

; DOS Library Offsets

lvodeletefile   EQU -72
lvorename       EQU -78
lvolock         EQU -84
lvounlock       EQU -90
lvoexamine      EQU -102
lvoexnext       EQU -108
lvoinfo         EQU -114
;lvoseek         EQU -0
lvocreatedir    EQU -120
lvodatestamp    EQU -192
lvodelay        EQU -198
lvoexecute      EQU -222
lvounloadseg    EQU -156

; DateStamp
ofib_datestamp  EQU $84
ds_days         EQU $00
ds_minute       EQU $04
ds_tick         EQU $08

; Memory Alloc Flags
memf_public     EQU $01
memf_chip       EQU $02
memf_fast       EQU $04
memf_clear      EQU $010000
memf_largest    EQU $020000

; IO Block Offsets
io_command      EQU $1C
io_actual       EQU $20
io_length       EQU $24
io_data         EQU $28
io_offset       EQU $2C

                ENDPART

                >PART 'st blitter equates'

; Blitter Equates

halftone        EQU 0
src_xinc        EQU $20
src_yinc        EQU $22
src_addr        EQU $24
endmask1        EQU $28
endmask2        EQU $2A
endmask3        EQU $2C
dst_xinc        EQU $2E
dst_yinc        EQU $30
dst_addr        EQU $32
x_count         EQU $36
y_count         EQU $38
hop             EQU $3A
op              EQU $3B
line_num        EQU $3C
skew            EQU $3D

                ENDPART

                PART 'startup,call,exit'

letsgo:         movea.l SP,A5
                movea.l 4(A5),A5        ; base page addr
                move.l  $0C(A5),D0      ; prog length
                add.l   $14(A5),D0      ; BSS length
                add.l   $1C(A5),D0      ; DATA length
                add.l   #$0100,D0       ; skip base page
                move.l  D0,-(SP)        ; stack length
                move.l  A5,-(SP)        ; prog start
                clr.w   -(SP)           ; dummy word
                move.w  #$4A,-(SP)      ; memory shrink
                trap    #1
                lea     12(SP),SP
                DC.W $A00A
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,oldsp
                lea     my_stack,SP

                move.w  #-1,-(SP)
                move.w  #$58,-(SP)
                trap    #14
                addq.l  #4,SP
                move.w  D0,oldvideo
                move.w  #2,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,oldbase
                bsr     save_pal
                bsr     init_screen     ;;
                movea.w #$9800,A0
                movea.w #$8240,A1
                moveq   #16-1,D7
clpal:          clr.l   (A0)+
                clr.w   (A1)+
                dbra    D7,clpal
                jsr     makevoltab

;;;;
                jsr     load_sam_dspprog ;;;;
;;;;

                move    #$2700,SR
                move.w  #320/2,(vwrap).w
                move.w  #$10,(_spshift).w
                move.w  #$00,(vco).w
                move.w  #$FE,(hht).w
                move.w  #$CB-58,(hbb).w
                move.w  #$27+38,(hbe).w
                move.w  #$0C,(hdb).w
                move.w  #$7D,(hde).w
                move.w  #$D8,(hss).w
                move.w  #$00,(hfs).w
                move.w  #$00,(hee).w
                move.w  #$0271,(vft).w
                move.w  #$0265,(vbb).w
                move.w  #$2F,(vbe).w
                move.w  #$45,(vdb).w
                move.w  #$45+(256*2),(vde).w
                move.w  #$026B,(vss).w
                move    #$2300,SR
                move.w  #37,-(SP)
                trap    #14
                addq.l  #2,SP
                bsr     main

                jsr     stop_music
                bsr     restore_ints
                bsr     rest_pal
                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #-1,-(SP)
                move.l  oldbase(PC),-(SP)
                move.l  oldbase(PC),-(SP)
                move.w  #5,-(SP)
                trap    #14
                lea     12(SP),SP
                move.w  oldvideo(PC),-(SP)
                move.w  #$58,-(SP)
                trap    #14
                addq.l  #4,SP
                DC.W $A009
                clr.w   -(SP)
                trap    #1

oldvideo:       DS.W 1
oldbase:        DS.L 1

                ENDPART

                PART 'int setup,restore,handlers'

;-------------------------------------------------------------------------
; Interrupt setup routines

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints:      moveq   #$13,D0         ; pause keyboard
                bsr     writeikbd       ; (stop from sending)
                move.w  #37,-(SP)
                trap    #14
                addq.l  #2,SP
                move    #$2700,SR
                lea     old_stuff(PC),A0
                move    USP,A1
                move.l  A1,(A0)+
                move.l  $68.w,(A0)+
                move.l  $70.w,(A0)+
                move.l  $B0.w,(A0)+
                move.l  $010C.w,(A0)+
                move.l  $0110.w,(A0)+
                move.l  $0114.w,(A0)+
                move.l  $0118.w,(A0)+
                move.l  $0120.w,(A0)+
                move.l  $0134.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA09.w,(A0)+
                move.b  $FFFFFA0B.w,(A0)+
                move.b  $FFFFFA0D.w,(A0)+
                move.b  $FFFFFA0F.w,(A0)+
                move.b  $FFFFFA11.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA15.w,(A0)+ ; restore mfp
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.b  $FFFFFA1B.w,(A0)+
                move.b  $FFFFFA1D.w,(A0)+
                move.b  $FFFFFA1F.w,(A0)+
                move.b  $FFFFFA21.w,(A0)+
                move.b  $FFFFFA25.w,(A0)+
                move.b  #$01,$FFFFFA07.w
                move.b  #$78,$FFFFFA09.w
                move.b  #$01,$FFFFFA13.w
                move.b  #$78,$FFFFFA15.w
                bclr    #3,$FFFFFA17.w  ; software end of int.
                bclr    #3,$FFFFFA03.w
                move.l  $70.w,oldvb+2
                lea     first_vbl(PC),A0
                move.l  A0,$70.w        ; set our vbl
                lea     key_rout(PC),A0
                move.l  A0,$0118.w      ; and our keyrout.
                move.l  #timerc,$0114.w
                move.l  #phbl,$68.w     ;
                move.l  #phbl,$010C.w   ;
                move.l  #phbl,$0110.w   ; -> rte
                move.l  #phbl,$0120.w   ;
                clr.b   $FFFFFA1B.w     ; ensure timer b is off
                andi.b  #%11111000,$FFFFFA1D.w
                move    #$2300,SR
mouse_wind:     moveq   #$15,D0
                bsr     writeikbd
                moveq   #9,D0
                bsr     writeikbd
                moveq   #1,D0
                bsr     writeikbd
                move.w  #$3F,D0
                bsr     writeikbd
                moveq   #0,D0
                bsr     writeikbd
                move.w  #$FF,D0
                bsr     writeikbd
set_mouse:      moveq   #$0E,D0
                bsr     writeikbd
                moveq   #0,D0
                bsr     writeikbd
                moveq   #0,D0
                bsr     writeikbd
                move.w  #160,D0
                bsr     writeikbd
                moveq   #0,D0
                bsr     writeikbd
                moveq   #100,D0
                bsr     writeikbd
                moveq   #$11,D0         ; resume sending
                bsr     writeikbd
                bra     flush

; Restore mfp vectors and ints.

restore_ints:   moveq   #$13,D0         ; pause keyboard
                bsr     writeikbd       ; (stop from sending)
                move    #$2700,SR
                lea     old_stuff(PC),A0
                movea.l (A0)+,A1
                move    A1,USP
                move.l  (A0)+,$68.w
                move.l  (A0)+,$70.w
                move.l  (A0)+,$B0.w
                move.l  (A0)+,$010C.w
                move.l  (A0)+,$0110.w
                move.l  (A0)+,$0114.w
                move.l  (A0)+,$0118.w
                move.l  (A0)+,$0120.w
                move.l  (A0)+,$0134.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA09.w
                move.b  (A0)+,$FFFFFA0B.w
                move.b  (A0)+,$FFFFFA0D.w
                move.b  (A0)+,$FFFFFA0F.w
                move.b  (A0)+,$FFFFFA11.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA15.w ; restore mfp
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA19.w
                move.b  (A0)+,$FFFFFA1B.w
                move.b  (A0)+,$FFFFFA1D.w
                move.b  (A0)+,$FFFFFA1F.w
                move.b  (A0)+,$FFFFFA21.w
                move.b  (A0)+,$FFFFFA25.w
                move    #$2300,SR
                moveq   #$11,D0         ; resume
                bsr     writeikbd
                moveq   #$08,D0         ; restore mouse.
                bsr     writeikbd
                bra     flush

save_pal:       movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,old_pal
                lea     $FFFF9800.w,A0
                lea     old_falcpal,A1
                move.w  #256-1,D0
.save_pallp:    move.l  (A0)+,(A1)+
                dbra    D0,.save_pallp
                rts

rest_pal:       movem.l old_pal,D0-D7
                movem.l D0-D7,$FFFF8240.w
                lea     old_falcpal,A0
                lea     $FFFF9800.w,A1
                move.w  #256-1,D0
.rest_pallp:    move.l  (A0)+,(A1)+
                dbra    D0,.rest_pallp
                rts

; Convert RGB word in the form 0000rrrrggggbbbb to falcon colour format!

convcol:        move.w  D0,D1
                moveq   #0,D0

.do_r:          moveq   #0,D2
                move.w  D1,D2
                and.w   #$0F00,D2
                swap    D2
                lsl.l   #4,D2
                or.l    D2,D0
.do_g:          moveq   #0,D2
                move.w  D1,D2
                and.w   #$F0,D2
                swap    D2
                or.l    D2,D0
.do_b:          and.w   #$0F,D1
                lsl.w   #4,D1
                or.w    D1,D0
                rts

old_pal:        DS.W 16
old_falcpal:    DS.L 256
old_stuff:      DS.L 32
oldsp:          DS.L 1

; Allocate and Initialise(clear) screen memory.

init_screen:    lea     log_base(PC),A1
                lea     screen,A0
                move.l  A0,(A1)+
                move.l  log_base(PC),D0
                move.w  #-1,-(SP)
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.w  #5,-(SP)
                trap    #14
                lea     12(SP),SP
                rts

; Clear a 256 line screen. a0 -> screen.

;-----------------------------------------------------------------------------
; Vbls...

first_vbl:      move.l  #vbl,$70.w
                addq.w  #1,vbl_timer
                rte

vbl:            clr.b   $FFFFFA1B.w
                andi.b  #%11111000,$FFFFFA1D.w
                tas.b   vblsem
                bne.s   .vblout
                tst.b   samplingflag
                bne     samplingvbl
                tst.b   showrainbowflag
                beq.s   .notrainbow
                move.b  #37,$FFFFFA21.w
                move.l  #setup_hbls,$0120.w
                bra.s   .gohbl
.notrainbow:    move.b  #60,$FFFFFA21.w
                move.l  #anal_hbls,$0120.w
.gohbl:         move.b  #8,$FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                movem.l D0-A6,-(SP)
                jsr     setcolours
                moveq   #$0D,D0
                bsr     writeikbd
                bsr     pointer_restoreback
                bsr     pointer_draw
                bsr     plotlinecursor
                move.l  vbintjmpthru(PC),D0
                beq.s   .nonetoday
                movea.l D0,A0
                jsr     (A0)
.nonetoday:
                bsr     plotcursor
                bsr     plotlp1
                bsr     copypatts
                jsr     do_music
                movem.l (SP)+,D0-A6
;                move.l  #$30,$FFFF9800.w
                addq.w  #1,vbl_timer
.vblout:        sf      vblsem
                rte
oldvb:          jmp     $12345678
vblsem:         DC.W 0

timerc:
phbl:
                rte

samplingvbl:    move.l  D0,-(SP)
                moveq   #$0D,D0
                bsr     writeikbd
                move.l  (SP)+,D0
                addq.w  #1,vbl_timer
                rte
; Hbls...

i               SET 0
anal_hbls:
                REPT 40
                move.l  coplistanalyzer+(i*4),($FFFF9800+40).w
i               SET i+1
                move.l  #anal_hbls+(i*18),$0120.w
                rte
                ENDR
                clr.b   $FFFFFA1B.w
                move.l  #vu_hbl1st,$0120.w
                move.b  #79-40,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                rte
mynotecol:      DC.L 0
editcurscol:    DC.L 0

vu_hbl1st:
                move.l  mynotecol(PC),($FFFF9800+16).w
                clr.l   ($FFFF9800+24).w
                move.l  #vu_hbl2nd,$0120.w
                rte
vu_hbl2nd:
                move.l  editcurscol(PC),($FFFF9800+36).w
                move.l  editcurscol(PC),($FFFF9800+40).w
                move.l  editcurscol(PC),($FFFF9800+44).w
                move.l  #vu_hbl3rd,$0120.w
                rte
vu_hbl3rd:      move.l  #vu_hbls,$0120.w
                rte

i               SET 0
vu_hbls:
                REPT 48
                move.l  vumetercols+(i*12),($FFFF9800+32).w
                move.l  vumetercols+(i*12),($FFFF9800+48).w
i               SET i+1
                move.l  #vu_hbls+(i*26),$0120.w
                rte
                ENDR
                clr.b   $FFFFFA1B.w
                rte

i               SET 0
setup_hbls:
                REPT 48
                move.l  coplistanalyzer+(i*4),($FFFF9800+28).w
i               SET i+1
                move.l  #setup_hbls+(i*18),$0120.w
                rte
                ENDR
                clr.b   $FFFFFA1B.w
                move.l  #vu_hbl1st,$0120.w
                move.b  #79-48+(60-37),$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                rte

setcolours:     movea.w #$9800,A0
                lea     convcol(PC),A1
                lea     copcol0-2,A2
                moveq   #8-1,D7
.col1_lp:       move.l  (A2)+,D0
                jsr     (A1)            ; convert colour
                move.l  D0,(A0)+
                dbra    D7,.col1_lp
                move.l  -3*4(A0),editcurscol
                move.l  D0,mynotecol
                moveq   #8-1,D7
.col2_lp:       move.l  #$FCFC00FC,(A0)+
                dbra    D7,.col2_lp
                movea.l coplistcolorptr,A6
                move.w  2(A6),D0
                jsr     (A1)
                moveq   #16-1,D7
.col3_lp:       move.l  D0,(A0)+
                dbra    D7,.col3_lp
                move.w  6(A6),D0
                jsr     (A1)
                moveq   #16-1,D7
.col4_lp:       move.l  D0,(A0)+
                dbra    D7,.col4_lp
                move.w  10(A6),D0
                jsr     (A1)
                moveq   #16-1,D7
.col5_lp:       move.l  D0,(A0)+
                dbra    D7,.col5_lp
                rts

; Wait for a vbl....
; D0/A0 trashed.

wait_vbl:       movem.l D0/A0,-(SP)
                lea     vbl_timer(PC),A0
                move.w  (A0),D0
.wait_vbl:      cmp.w   (A0),D0
                beq.s   .wait_vbl
                movem.l (SP)+,D0/A0
                rts

; Wait for D7 vbls.
; D7/D0/A0 trashed

waitd7vbls:     lea     vbl_timer(PC),A0
                subq.w  #1,D7
.wait_lp:       move.w  (A0),D0
.waitvbl:       cmp.w   (A0),D0
                beq.s   .waitvbl
                dbra    D7,.wait_lp
                rts

vbl_timer:      DC.W 0
log_base:       DC.L 0
phy_base:       DC.L 0
frame_switch:   DC.W 0

; Flush IKBD

flush:          btst    #0,$FFFFFC00.w  ; any waiting?
                beq.s   .flok           ; exit if none waiting.
                move.b  $FFFFFC02.w,D0  ; get next in queue
                bra.s   flush           ; and continue
.flok:          rts

; Write d0 to IKBD

writeikbd:      btst    #1,$FFFFFC00.w
                beq.s   writeikbd       ; wait for ready
                move.b  D0,$FFFFFC02.w  ; and send...
                rts

; Keyboard/Mouse handler interrupt routine...

key_rout:       move    #$2500,SR
                move.l  D0,-(SP)
                move.b  $FFFFFC00.w,D0
                btst    #7,D0
                beq.s   kend
                btst    #0,D0
                beq.s   kend
key_read:       move.b  $FFFFFC02.w,D0
                cmp.b   #$F7,D0
                beq.s   start_mouse
handleakey:
                movem.l D1/A0-A4,-(SP)
                lea     convtab(PC),A3
                move.w  D0,D1
                and.w   #$7F,D0
                sub.w   D0,D1
                move.b  0(A3,D0.w),D0   ; convert scancode
                or.w    D1,D0
                bsr     processrawkey
                movem.l (SP)+,D1/A0-A4
kend:           move.l  (SP)+,D0
endi:           rte

start_mouse:    move.l  #mouseb1,$0118.w
                bra.s   kend

mouseb1:        move    #$2500,SR
                movem.l D0-D1,-(SP)
                move.l  #mouseb2,$0118.w
                move.b  $FFFFFC02.w,D0
.mse1:          tst.b   D0
                beq.s   .notah
                move.b  D0,D1
                lsr.b   #1,D1
                or.b    D1,D0
                eor.b   D0,mousebut
.notah:         movem.l (SP)+,D0-D1
                rte

mouseb2:        move    #$2500,SR
                move.l  #mouseb3,$0118.w
                move.b  $FFFFFC02.w,mousex
                rte
mouseb3:        move    #$2500,SR
                move.l  #mouseb4,$0118.w
                move.b  $FFFFFC02.w,mousex+1
                rte
mouseb4:        move    #$2500,SR
                move.l  #mouseb5,$0118.w
                move.b  $FFFFFC02.w,mousey
                rte
mouseb5:        move    #$2500,SR
                move.l  #key_rout,$0118.w
                move.b  $FFFFFC02.w,mousey+1
                rte

;               DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

; ST -> AMIGA SCANCODE CONVERTOR!!

convtab:        DC.B $00,$45,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$41,$42
                DC.B $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$44,$63,$20,$21
                DC.B $22,$23,$24,$25,$26,$27,$28,$29,$2A,$0D,$60,$2B,$31,$32,$33,$34
                DC.B $35,$36,$37,$38,$39,$3A,$61,-11,$64,$40,$62,$50,$51,$52,$53,$54
                DC.B $55,$56,$57,$58,$59,-11,-11,$67,$4C,-11,$4A,$4F,-11,$4E,$5E,-11
                DC.B $4D,-11,$66,$46,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11
                DC.B $30,-13,$5F,$5A,$5B,$5C,$5D,$3D,$3E,$3F,$2D,$2E,$2F,$1D,$1E,$1F
                DC.B $0F,$3C,$43,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11

; -12 = ISO=?
; -13 = UNDO

inmouse:        DC.B 0
                EVEN
inmousecnt:     DC.W 0
mousebut:       DC.W 0

;---- Process rawkey code from the keyboard ----

processrawkey:
                cmp.b   lastrawkey,D0
                beq     return1
                move.b  D0,lastrawkey
                cmp.b   #67+128,D0
                beq     lowerinstr2
                cmp.b   #96,D0
                beq     shifton
                cmp.b   #97,D0
                beq     shifton2
                cmp.b   #100,D0
                beq     alton
                cmp.b   #101,D0
                beq     alton2
                cmp.b   #99,D0
                beq     ctrlon
                cmp.b   #102,D0
                beq     leftamigaon
                cmp.b   #99+128,D0
                beq     ctrloff
                cmp.b   #100+128,D0
                beq     altoff
                cmp.b   #96+128,D0
                beq.s   shiftoff
                cmp.b   #101+128,D0
                beq     altoff
                cmp.b   #97+128,D0
                beq.s   shiftoff
                cmp.b   #102+128,D0
                beq     leftamigaoff
                cmp.b   #98,D0
                beq.s   keyrepon
                cmp.b   #98+128,D0
                beq.s   keyrepoff
kbintsetkey:
                tst.b   D0
                bne.s   kbintdoset
                move.b  #127,D0
kbintdoset:
                move.w  keybufpos(PC),D1
                cmp.w   #keybufsize,D1
                bhs     return1
                lea     keybuffer(PC),A3
                move.b  D0,0(A3,D1.w)
                addq.w  #1,keybufpos
                rts

lowerinstr2:
                clr.w   hilowinstr
                bra.s   kbintsetkey

keyrepon:
                st      keyrepeat
                rts
keyrepoff:
                sf      keyrepeat
                rts

shifton:        move.w  #1,shiftkeystatus
                rts
shifton2:
                move.w  #1,shiftkeystatus
                bra.s   kbintsetkey
shiftoff:
                clr.w   shiftkeystatus
                rts

alton:          move.w  #1,altkeystatus
                rts
alton2:         move.w  #1,altkeystatus
                bra.s   kbintsetkey
altoff:         clr.w   altkeystatus
                rts

ctrlon:         move.w  #1,ctrlkeystatus
                rts
ctrloff:        clr.w   ctrlkeystatus
                rts

leftamigaon:
                move.w  #1,leftamigastatus
                rts
leftamigaoff:
                clr.w   leftamigastatus
                rts

dokeybuffer:
                move.w  keybufpos(PC),D0
                beq     return1
                subq.w  #1,D0
                lea     keybuffer(PC),A0
                move.b  0(A0,D0.w),D1
                move.w  D0,keybufpos
                move.b  D1,rawkeycode
                move.b  D1,savekey
                move.w  keyrepdelay,keyrepcounter
                btst    #7,D1
                beq.s   dkbend
                clr.w   keyrepcounter
dkbend:         rts

keybufpos:      DC.W 0
keybuffer:      DCB.B keybufsize
shiftkeystatus: DC.W 0
altkeystatus:   DC.W 0
ctrlkeystatus:  DC.W 0
leftamigastatus:DC.W 0
lastrawkey:     DC.B 255,0
savekey:        DC.B 0
keyrepeat:      DC.B 0
keyrepcounter:  DC.W 0

;---- Key repeat ----

checkkeyrepeat:
                tst.b   keyrepeat
                beq     return1
                move.w  keyrepcounter(PC),D0
                beq     return1
                subq.w  #1,D0
                beq.s   repdown
                move.w  D0,keyrepcounter
                rts

repdown:        move.b  savekey(PC),rawkeycode
                move.w  keyrepspeed,keyrepcounter
                rts

                ENDPART

                >PART 'mouse pointer routs'

;----------------------------------------------
; 16*16 Sprite Rout and associated stuff.

pointer_restoreback:
                lea     pointer_saveback(PC),A0
                movea.l log_base(PC),A1
                moveq   #0,D1
                move.w  (A0)+,D0
                bmi     .noback
                beq     .clippedrest
.notclippedrest:
                adda.l  (A0)+,A1
                move.w  (A0)+,D7
pnt_cl1:        move.l  D1,(A1)
                move.l  D1,16(A1)
                lea     320(A1),A1
                dbra    D7,pnt_cl1
.noback:        rts
.clippedrest:
                adda.l  (A0)+,A1
                move.w  (A0)+,D7
pnt_cl2:        move.l  D1,(A1)
                lea     320(A1),A1
                dbra    D7,pnt_cl2
                rts

; Draw pointer routine
; at mousex,mousey

pointer_draw:
                lea     pointer_saveback(PC),A2
                move.w  mousex,D0
                move.w  mousey,D1
                moveq   #16-1,D7
                cmp.w   #319,D0
                bcs     .no1
                move.w  #319,D0
.no1:           cmp.w   #255-16,D1
                bls     .no2
                move.w  #255,D7
                sub.w   D1,D7
.no2:
                lea     pointerspritedata+4,A0
                movea.l log_base(PC),A1
                move.w  D0,D2
                mulu    #320,D1
                and.w   #$FFF0,D0
                ext.l   D0
                add.l   D0,D1
                addq.l  #8,D1
                adda.l  D1,A1
                cmp.w   #319-16,D2
                bhi     .clip_sprite
                and.w   #15,D2
                move.w  #1,(A2)+
                move.l  D1,(A2)+
                move.w  D7,(A2)+
.lp2:           moveq   #0,D0
                moveq   #0,D1
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                ror.l   D2,D0
                ror.l   D2,D1
                move.w  D0,(A1)
                move.w  D1,2(A1)
                swap    D0
                swap    D1
                move.w  D0,16(A1)
                move.w  D1,16+2(A1)
                lea     320(A1),A1
                dbra    D7,.lp2
                rts

.clip_sprite:
                and.w   #15,D2
                clr.w   (A2)+
                move.l  D1,(A2)+
                move.w  D7,(A2)+
.lp3:
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                lsr.w   D2,D0
                lsr.w   D2,D1
                move.w  D0,(A1)
                move.w  D1,2(A1)
                lea     320(A1),A1
                dbra    D7,.lp3
                rts
pointer_saveback:
                DC.W -1
                DC.L 0
                DC.W 0

                ENDPART

                >PART 'copy patts,sprites etc'

;-------------------------------------------------

; Copy patterns onto interleaved bitmap!

copypatts:
                movea.l pattbplptr,A0
                movea.l log_base(PC),A1
                adda.l  #(141*320)+4,A1
                tst.w   samscrenable
                bne     samscrcopy
                moveq   #48-1,D7
samcopy1_lp:
i               SET 0
                REPT 20
                move.w  (A0)+,i(A1)
i               SET i+16
                ENDR
                lea     320(A1),A1
                dbra    D7,samcopy1_lp
                moveq   #8-1,D7
samcopy2_lp:
i               SET 0
                REPT 20
                move.w  (A0),i(A1)
                move.w  (A0)+,i+320(A1)
i               SET i+16
                ENDR
                lea     640(A1),A1
                dbra    D7,samcopy2_lp
                moveq   #48-1,D7
samcopy3_lp:
i               SET 0
                REPT 20
                move.w  (A0)+,i(A1)
i               SET i+16
                ENDR
                lea     320(A1),A1
                dbra    D7,samcopy3_lp
                rts

;

samscrcopy:
                lea     -2*320(A1),A1
                movea.l textbplptr,A0
                lea     $15B8(A0),A0

                moveq   #64+8-1,D7
samcopy4_lp:
i               SET 0
                REPT 20
                move.w  (A0)+,i(A1)
i               SET i+16
                ENDR
                lea     320(A1),A1
                dbra    D7,samcopy4_lp
                rts

; Plot that there cursor

plotcursor:
                movea.l log_base(PC),A0
                movea.l A0,A1
                adda.l  xoldoff(PC),A1
                moveq   #0,D0
i               SET 6
                REPT 14
                move.b  D0,i(A1)
i               SET i+320
                ENDR
                tst.w   samscrenable
                bne.s   nocurs
                move.w  cursxy(PC),D0
                move.w  D0,D1
                and.l   #$FFF0,D0
                btst    #3,D1
                beq.s   .oknadd
                addq.w  #1,D0
.oknadd:
                move.w  cursxy+2(PC),D1
                mulu    #320,D1
                add.l   D1,D0
                adda.l  D0,A0
                move.l  D0,xoldoff
                moveq   #-1,D2
                move.b  #%10000001,D3
i               SET 6
                REPT 2
                move.b  D2,i(A0)
i               SET i+320
                ENDR
                REPT 10
                move.b  D3,i(A0)
i               SET i+320
                ENDR
                REPT 2
                move.b  D2,i(A0)
i               SET i+320
                ENDR
nocurs:         rts

cursxy:         DC.W 0,$BD
xoldoff:        DC.L 0

plotlinecursor:
                movea.l log_base(PC),A0
                movea.l A0,A1
                adda.l  lxoldoff(PC),A1
                moveq   #0,D0
i               SET 6
                REPT 2
                move.b  D0,i(A1)
i               SET i+320
                ENDR
                lea     linecurspritedata,A2
                moveq   #0,D0
                move.w  (A2)+,D0
                move.w  D0,D1
                and.w   #$FFF0,D0
                btst    #3,D1
                beq.s   .loknadd
                addq.w  #1,D0
.loknadd:
                move.w  (A2)+,D1
                cmp.w   #255,D1
                bge.s   nolinecurs
                mulu    #320,D1
                add.l   D1,D0
                adda.l  D0,A0
                move.l  D0,lxoldoff
                moveq   #-2,D2
i               SET 6
                REPT 2
                move.b  D2,i(A0)
i               SET i+320
                ENDR
nolinecurs:     rts

lxoldoff:       DC.L 14

plotlp1:
                tst.w   samscrenable
                beq.s   .nosamspr
                bsr     deleteold
                lea     playposspritedata,A2
                lea     lp3xoldoff(PC),A3
                bsr     plotshowposspr
                lea     loopspritedata1,A2
                lea     lp1xoldoff(PC),A3
                move.l  #$F000,D4
                move.l  #$1000,D5
                move.l  #$7000,D6
                bsr     plotlpspr
                lea     loopspritedata2,A2
                lea     lp2xoldoff(PC),A3
                move.l  #$F000,D4
                move.l  #$8000,D5
                move.l  #$E000,D6
                bsr     plotlpspr
.nosamspr:      rts

deleteold:      lea     lp1xoldoff(PC),A3
                movea.l log_base(PC),A0
                movea.l A0,A1
                movea.l A0,A2
                adda.l  (A3)+,A0
                moveq   #0,D0

i               SET 6
                REPT 64
                move.w  D0,i(A0)
                move.w  D0,i+16(A0)
i               SET i+320
                ENDR
                adda.l  (A3)+,A1

i               SET 6
                REPT 64
                move.w  D0,i(A1)
                move.w  D0,i+16(A1)
i               SET i+320
                ENDR

                adda.l  (A3)+,A2
i               SET 6

                REPT 64
                move.w  D0,i(A2)
i               SET i+320
                ENDR
                rts

plotlpspr:      movea.l log_base(PC),A0
                movem.w (A2)+,D0-D1
                subq.w  #3,D0
                cmp.w   #316,D0
                bls.s   okplotlpspr
                move.w  #316,D0
okplotlpspr:    moveq   #15,D2
                and.w   D0,D2
                sub.w   D2,D0
                cmp.w   #255,D1
                bhi     .nodlp1
                mulu    #320,D1
                ext.l   D0
                add.l   D1,D0
                adda.l  D0,A0
                move.l  D0,(A3)
                ror.l   D2,D4
                ror.l   D2,D5
                ror.l   D2,D6
                move.l  D4,D7
                swap    D7
i               SET 6
                REPT 4
                or.w    D4,i(A0)
                or.w    D7,i+16(A0)
i               SET i+320
                ENDR
                move.l  D5,D7
                swap    D7
                REPT 27
                or.w    D5,i(A0)
                or.w    D7,i+16(A0)
i               SET i+320
                ENDR
                or.w    D6,i(A0)
                swap    D6
                or.w    D6,i+16(A0)
                REPT 33
                or.w    D5,i(A0)
                or.w    D7,i+16(A0)
i               SET i+320
                ENDR
.nodlp1:        rts

plotshowposspr: movea.l log_base(PC),A0
                movem.w (A2)+,D0-D1
                moveq   #15,D2
                and.w   D0,D2
                sub.w   D2,D0
                cmp.w   #255,D1
                bhi     .nodlp1
                mulu    #320,D1
                ext.l   D0
                add.l   D1,D0
                adda.l  D0,A0
                move.l  D0,(A3)
                move.w  #$8000,D3
                lsr.w   D2,D3
i               SET 6
                REPT 64
                or.w    D3,i(A0)
i               SET i+320
                ENDR
                rts

lp1xoldoff:     DC.L 8
lp2xoldoff:     DC.L 8
lp3xoldoff:     DC.L 8

; Copy main twoplane screen.

copymainscreen: lea     bitplanedata,A0
                movea.l log_base,A2
                moveq   #0,D1
                move.w  #189-1,D0
                bsr     twoplanecopy
                REPT 7
                bsr     dplanecopy
                ENDR
                moveq   #53-1,D0
                bsr     twoplanecopy

                rts

twoplanecopy:
.lp1:           moveq   #20-1,D2
.lp12:          move.l  (A0)+,(A2)+
                move.l  D1,(A2)+
                move.l  D1,(A2)+
                move.l  D1,(A2)+
                dbra    D2,.lp12
                dbra    D0,.lp1
                rts

dplanecopy:
.lp1a:          moveq   #20-1,D2
.lp1a2:         move.l  (A0),(A2)+
                move.l  D1,(A2)+
                move.l  D1,(A2)+
                move.l  D1,(A2)+
                move.l  (A0)+,320-16(A2)
                move.l  D1,324-16(A2)
                move.l  D1,328-16(A2)
                move.l  D1,332-16(A2)
                dbra    D2,.lp1a2
                lea     320(A2),A2

                rts

; Draw spectrum analyser or quadrascope window
; a1-> graphic data

drawspec_or_scope:
                lea     spectrumanapos,A0 ;;
                moveq   #1,D7           ;;
cgloop1:        moveq   #54,D6          ;; 55 lines in picture.
cgloop2:
i               SET 0
                REPT 12
                move.b  (A1)+,i(A0)     ;;
i               SET i+15
                move.b  (A1)+,i(A0)
i               SET i+1
                ENDR
                move.b  (A1)+,i(A0)
                addq.l  #1,A1           ;;
                lea     320(A0),A0      ;;
                dbra    D6,cgloop2      ;;
                lea     2-(55*320)(A0),A0 ;;
                dbra    D7,cgloop1      ;;
                rts

                ENDPART

                >PART 'memory allocation(amiga emu!)'

; Allocate memory
; On Entry:
; d0 = length to allocate
; d1 = bit flag for CLEAR memory etc
; Return: d0 -> Allocated memory OR 0 if alloc failed!

lvoallocmem:    movem.l D1-D7/A1-A6,-(SP)
                btst    #0,D0
                beq.s   .iseven
                addq.l  #1,D0
.iseven:        movem.l D0-D1,-(SP)
                move.l  D0,-(SP)        ;; push amount to allocate
                move.w  #$48,-(SP)      ;; Malloc
                trap    #1
                addq.l  #6,SP           ;; d0 = pointer to block OR 0 if fail!
                movem.l (SP)+,D2-D3
                tst.l   D0              ;; alloc failed?
                beq.s   .failedalloc    ;; yes then skip clear mem check
                and.l   #memf_clear,D3  ;; alloc OK so check needs clearing
                beq.s   .noclearalloced ;; needs clearing?
                moveq   #0,D3           ; yup! clear d3
                movea.l D0,A0           ;; a0-> alloced block
                lsr.l   #1,D2
                beq.s   .noclearalloced
.calloclp1:
                move.w  D3,(A0)+
.jmpcalloc:     subq.l  #1,D2           ;; and clear allocated block
                bne.s   .calloclp1
.noclearalloced:
.failedalloc:   movem.l (SP)+,D1-D7/A1-A6
                rts

; Free Memory!!!
; On Entry
; A1 = ptr to memory to free

lvofreemem:     movem.l D1-D7/A1-A6,-(SP)
                pea     (A1)
                move.w  #$49,-(SP)
                trap    #1
                addq.l  #6,SP
                movem.l (SP)+,D1-D7/A1-A6
                rts

; Find out available memory
; Return: D0.L available memory!

lvoavailmem:    movem.l D1-D7/A1-A6,-(SP)
                move.l  #-1,-(SP)
                move.w  #$48,-(SP)
                trap    #1
                addq.l  #6,SP
                movem.l (SP)+,D1-D7/A1-A6
                rts

                ENDPART

                >PART 'file loading/save(amiga emu!)'

; Open file
; d1 -> filename string
; d2 -> 1005 for read, 1006 for write

lvoopen:        movem.l D1-A6,-(SP)
                moveq   #2,D3           ; assume read and write
                cmp.l   #1005,D2        ; open for read?
                bne.s   .notread
                moveq   #0,D3           ;; read only
                bra.s   .notwrite       ;; and skip write check
.notread:       cmp.l   #1006,D2        ;; open for write?
                bne.s   .notwrite
; open a file for read
                move.l  D1,-(SP)        ; first check to see if the
                clr.w   -(SP)           ; file exists
                move.l  D1,-(SP)
                move.w  #$4E,-(SP)      ;; f_sfirst
                trap    #1
                addq.l  #8,SP
                move.l  (SP)+,D1
                tst.l   D0              ;; file was found?
                beq.s   .oknocreate     ;; then no need to create
                cmp.l   #-33,D0         ;; was file found?
                bne.s   .erroropen      ;; other error than file not found?
                clr.w   -(SP)
                move.l  D1,-(SP)
                move.w  #$3C,-(SP)      ;; f_create
                trap    #1
                addq.l  #8,SP
                bra.s   .checkopenerr
.oknocreate:    moveq   #1,D3           ;; write only
.notwrite:      move.w  D3,-(SP)
                move.l  D1,-(SP)
                move.w  #$3D,-(SP)      ;; fopen
                trap    #1
                addq.l  #8,SP
.checkopenerr:  tst.l   D0
                bge.s   .opened
.erroropen:     moveq   #0,D0
.opened:
                movem.l (SP)+,D1-A6
                rts

; Seek
; d1 = handle
; d2 = no of bytes
; d3 = -1 (means seek from start of file)

lvoseek:        movem.l D1-A6,-(SP)
                move.w  #0,-(SP)        ;; seek from current position
                move.w  D1,-(SP)        ;; file handle
                move.l  D2,-(SP)        ;; signed length
                move.w  #$42,-(SP)      ;; f_seek
                trap    #1
                lea     10(SP),SP
                movem.l (SP)+,D1-A6
                rts

; Close file
; d1 = file handle

lvoclose:       movem.l D1-A6,-(SP)
                move.w  D1,-(SP)        ; file handle
                move.w  #$3E,-(SP)      ; f_close
                trap    #1
                addq.l  #4,SP
                movem.l (SP)+,D1-A6
                rts

; Read file
; d2 -> Address to read into.
; d3 = no. of bytes to read.
; d1 = file handle

lvoread:        movem.l D1-A6,-(SP)
                move.l  D2,-(SP)        ; ptr to place to read into
                move.l  D3,-(SP)        ; no. bytes to read
                move.w  D1,-(SP)        ; handle
                move.w  #$3F,-(SP)      ; f_read
                trap    #1
                lea     12(SP),SP
                movem.l (SP)+,D1-A6
                rts

; Write file
; d2 -> Address to write from
; d3 = no. of bytes to write.
; d1 = file handle

lvowrite:       movem.l D1-D7/A1-A6,-(SP)
                move.l  D2,-(SP)        ; ptr to place to read into
                move.l  D3,-(SP)        ; no. bytes to read
                move.w  D1,-(SP)        ; handle
                move.w  #$40,-(SP)      ; f_write
                trap    #1
                lea     12(SP),SP
                tst.l   D0
                bpl     .writeok
                moveq   #0,D0
.writeok:
                movem.l (SP)+,D1-D7/A1-A6

                rts

; Get Disk transfer address

getdta:         move.w  #47,-(SP)
                trap    #1              ; get dta
                addq.l  #2,SP
                move.l  D0,dtabuf_ptr
                rts

dtabuf_ptr:     DC.L 0

                ENDPART

; Amiga stuff.

main:           move.l  SP,stacksave
                bsr     getdta          ;;
                bsr     copymainscreen  ;;
                bsr     openlotsofthings ;;
                bsr     init_ints       ;;
                bsr     setvbint        ;; works fine
                bsr     setmusicint     ;;
                jsr     setpatternpos   ;;
                bsr     setnormalptrcol ;;
                bsr     storeptrcol     ;;
                bsr     redrawtoggles   ;;
                bsr     doshowfreemem   ;;
                bsr     settempo        ;;
                bsr     checkiniterror  ;; hoho
                lea     versiontext(PC),A0
                jsr     showstatustext

; Here we have the main program loop

mainloop:
                bsr     dokeybuffer
                bsr     checktranskeys
                bsr     checkctrlkeys
                bsr     checkaltkeys
                bsr     checkkeyboard
                bsr     checkf1_f2
                bsr     checkf3_f5
                bsr     checkf6_f10
                bsr     checkplaykeys
                bsr     checkhelpkey
                bsr     arrowkeys2
                bsr     showtimer
                bsr     showfreemem
                bsr     checkblockpos
                jsr     checksamplelength
                bsr     checkredraw
                bsr     wait_vbl
                btst    #2,mousebut
                beq.s   mainloop        ; Loop if not pressed

                tst.w   currscreen
                bne.s   mainskip
                move.w  #1,notogfl
                bsr     displaymainscreen

                jsr     showallright
                bsr     waitforbuttonup
mainskip:
                bsr     arrowkeys
                bra     checkgadgets

notogfl:        DC.W 0
ptprocess:      DC.L 0
versiontext:    DC.B 'F-030 V0.89 Beta',0
                EVEN

; Sort out the current path.

makepath:       lea     getgemcurrpath,A5
                movea.l pathptr,A6
                move.w  #$19,-(SP)
                trap    #1              ;; get drive
                addq.l  #2,SP
                add.b   #'A',D0
                move.b  D0,(A6)+
                move.b  #":",(A6)+
                clr.w   -(SP)           ;;
                pea     (A5)
                move.w  #$47,-(SP)      ;; get path
                trap    #1              ;;
                addq.l  #8,SP           ;;
                cmpi.b  #":",1(A5)
                bne.s   nodriveinpath
                addq.l  #2,A5
nodriveinpath:  cmpi.b  #'\',(A5)
                beq.s   nobackslash
                move.b  #"\",(A6)+
nobackslash:    move.b  (A5)+,(A6)+
                bne.s   nobackslash
                rts
initerror:      DC.B 0,0

checkiniterror:
                move.b  initerror,D0
                beq     return1
                btst    #0,D0
                beq.s   cieskp1
;                jsr     plstmemerr
cieskp1:        move.b  initerror,D0
                btst    #1,D0
                beq.s   cieskp2
;               jsr     plstopenerr
;                jsr     freeplst
cieskp2:        move.b  initerror,D0
                btst    #2,D0
                beq.s   cieskp3
                bsr     configerr
cieskp3:        move.b  initerror,D0
                btst    #3,D0
                beq     return1
                bsr     configerr2
                bsr     setnormalptrcol
                bra     storeptrcol

checkredraw:
                tst.b   updatetempo
                beq.s   chkredr
                clr.b   updatetempo
                bsr     settempo
chkredr:        cmpi.l  #'patp',runmode
                bne     return1
                jsr     showposition
                tst.b   pattrfsh
                beq     return1
                move.l  pattrfshnum,patternnumber
                jmp     redrawpattern

;---- Cleanup upon exit from PT ----

exitcleanup:
                jsr     stopit
                sf      edenable
                bsr     escpressed
                bsr     escpressed
                bsr     resetvbint
                bsr     resetmusicint
                jsr     freecopybuf
errorexit1:
errorexit2:
                movea.l stacksave,SP
                bsr     freedirmem
                bsr     givebackinstrmem
;               jsr     freeplst
                jsr     turnoffvoices
exex2:
return1:        rts

;---- Open Lots Of Things ----

openlotsofthings:
                move.l  #txtbpl,D0      ;;
                move.l  D0,textbplptr   ;;

                move.l  #pattern_mem,D0 ;;
                move.l  D0,songdataptr  ;;

                movea.l D0,A0
                lea     $14(A0),A0
                moveq   #30,D0
alotloop1:
                move.w  #1,$1C(A0)
                lea     $1E(A0),A0
                dbra    D0,alotloop1
                movea.l songdataptr,A0
                move.w  #$017F,sd_numofpatt(A0)
                move.l  #'M.K.',sd_mahokakt(A0) ; M.K. again...

                moveq   #6,D0
                move.l  D0,currspeed
                move.w  #1,pedpos
                move.l  #modulespath2,pathptr
                move.l  #coplistcolors,coplistcolorptr
                move.l  #kbdtranstable2,keytranstabptr
                move.l  #notenames1,notenamesptr
                move.l  #vumetercolors,therightcolors

                bsr     setdefspriteptrs
                bsr     updatecursorpos
                jsr     redrawpattern
                jsr     showposition
                jsr     showsonglength
                move.w  #1,insnum
                jsr     showsampleinfo

                bsr     doresetall

                bsr     makepath
                bsr     doloadconfig

;               JSR     DoLoadPLST
changecoplist:
                tst.w   samscrenable
                bne     return1
                bsr     setupanacols
setupvucols:
                tst.w   samscrenable
                bne     return1
                lea     vumetercols,A0
                lea     vumetercolors,A5
                moveq   #48-1,D7        ; Change 48 lines
alotlp4:
                move.w  (A5)+,D4
                move.w  #3,fadex
                move.w  D4,D0
                bsr     fadecol
                jsr     convcol
                move.l  D0,(A0)+
                move.w  D4,D0
                jsr     convcol
                move.l  D0,(A0)+
                move.w  #-3,fadex
                move.w  D4,D0
                bsr     fadecol
                jsr     convcol
                move.l  D0,(A0)+
                dbra    D7,alotlp4
                rts
clrvucols:
                lea     vumetercols,A0
                moveq   #48-1,D7
.clrvulp:
                REPT 3
                move.l  #$FCFC00FC,(A0)+
                ENDR
                dbra    D7,.clrvulp
                rts


pattbplptr:     DC.L 0
coplistcolorptr:DC.L 0

setupanacols:
                tst.b   disableanalyzer
                bne.s   clearanalyzercolors
setanalyzercolors:
                lea     coplistanalyzer,A1
                lea     analyzercolors,A0
                moveq   #39,D3          ; 40 lines
sanclop:        move.w  (A0)+,D0
                jsr     convcol
                move.l  D0,(A1)+
                dbra    D3,sanclop
                rts

clearanalyzercolors:
                lea     coplistanalyzer,A0
                move.w  colortable+12,D0
                jsr     convcol
                moveq   #39,D1          ; 40 lines.
cacloop:        move.l  D0,(A0)+
                lea     16(A0),A0
                dbra    D1,cacloop
                rts

setsamspriteptrs:
                move.l  #loopspritedata1,ch1spriteptr
                move.l  #loopspritedata2,ch2spriteptr
                move.l  #playposspritedata,ch3spriteptr
                move.l  #nospritedata,ch4spriteptr
                bra.s   sdsp2
setdefspriteptrs:
                move.l  #vuspritedata1,ch1spriteptr
                move.l  #vuspritedata2,ch2spriteptr
                move.l  #vuspritedata3,ch3spriteptr
                move.l  #vuspritedata4,ch4spriteptr
sdsp2:          move.l  #cursorspritedata,cursorposptr
                move.l  #pointerspritedata,pointerspriteptr
                move.l  #linecurspritedata,linecurposptr
                move.l  #nospritedata,nospriteptr
                move.l  pointerspriteptr,spriteptrsptr
                rts

pointerspriteptr:
                DC.L 0

;---- Vertical Blank Interrupt (installs in my vector!)----

setvbint:
                move.l  #vbint,vbintjmpthru
                rts
vbintjmpthru:   DC.L 0

resetvbint:
                clr.l   vbintjmpthru
                rts

vbint:
                bsr     vumeters
                bsr     scope
                bsr     specanaint
                bsr     arrowkeys
                bsr     checkkeyrepeat
                bra     updateticks

;---- Music Interrupt ----

setmusicint:
                tst.b   intmode
                bne.s   setciaint
                jmp     start_music


resetmusicint:
                tst.b   intmode
                bne     resetciaint
                jmp     stop_music

setciaint:
                clr.l   ciaabase
                rts

resetciaint:
                clr.l   ciaabase
                rts

ciaabase:       DC.L 0
timerflag:      DC.L 0
timervalue:     DC.L 0

                PART 'quadscope'

;---- Scope ----

ns_sampleptr    EQU 0
ns_endptr       EQU 4
ns_repeatptr    EQU 8
ns_rependptr    EQU 12
ns_period       EQU 16
ns_volume       EQU 18

scope:          lea     audchan1temp,A0
                lea     scopeinfo,A2
                lea     scopesaminfo,A1
                lea     blanksample,A3
                moveq   #3,D6
scoloop:        move.w  (A0),D0
                and.w   #$0FFF,D0
                or.w    n_period(A0),D0
                beq     scosampleend    ; end if no note & no period

                move.w  n_period(A0),ns_period(A2)
                move.b  n_volume(A0),ns_volume(A2)


                tst.b   n_trigger(A0)
                beq     scocontinue
scoretrig:
                sf      n_trigger(A0)
                bsr     setscope
                moveq   #0,D0
                move.b  n_samplenum(A0),D0
                subq.w  #1,D0
                lsl.w   #4,D0
                move.l  ns_sampleptr(A1,D0.w),ns_sampleptr(A2)
                move.l  ns_endptr(A1,D0.w),ns_endptr(A2)
                move.l  ns_repeatptr(A1,D0.w),ns_repeatptr(A2)
                move.l  ns_rependptr(A1,D0.w),ns_rependptr(A2)
                move.l  ns_sampleptr(A2),D0
                cmp.l   A3,D0           ; at end of sample...
                beq.s   sconextchan
                bra     scochk
scocontinue:
                move.l  ns_sampleptr(A2),D0
                cmp.l   A3,D0           ; at end of sample...
                beq.s   sconextchan
                moveq   #0,D1
                move.w  ns_period(A2),D1
                lsr.w   #1,D1
                beq.s   sconextchan
                move.l  #35469,D2
                divu    D1,D2
                ext.l   D2
                add.l   D2,D0
scochk:         cmp.l   ns_endptr(A2),D0
                blo.s   scoupdateptr
                tst.l   ns_repeatptr(A2)
                bne.s   scosamloop
scosampleend:
                move.l  A3,D0
                bra.s   scoupdateptr

scosamloop:
                sub.l   ns_endptr(A2),D0
                add.l   ns_repeatptr(A2),D0
                move.l  ns_rependptr(A2),ns_endptr(A2)
                cmp.l   ns_endptr(A2),D0
                bhs     scosamloop
scoupdateptr:
                move.l  D0,ns_sampleptr(A2)
sconextchan:
                adda.l  #20,A2
                adda.l  #44,A0
                dbra    D6,scoloop

; now draw channels
                tst.b   scopeenable
                beq     clsnot
                cmpi.w  #1,currscreen
                bne     clsnot
                tst.b   edenable
                bne     clsnot
                moveq   #0,D0
deletescopes:
.d1:            movea.l log_base(PC),A0
                lea     (72*320)+4+(16*4*2)(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 8
                move.w  D0,8(A0)
                ENDR

.d2:            movea.l log_base(PC),A0
                lea     (72*320)+4+(22*4*2)(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 8
                move.w  D0,8(A0)
                ENDR

.d3:            movea.l log_base(PC),A0
                lea     (72*320)+4+(28*4*2)(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 8
                move.w  D0,8(A0)
                ENDR

.d4:            movea.l log_base(PC),A0
                lea     (72*320)+4+(34*4*2)(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 16
                move.w  D0,8(A0)
                ENDR
                lea     16(A0),A0
                REPT 8
                move.w  D0,8(A0)
                ENDR


clsnot:         moveq   #-1,D4
                tst.w   samscrenable
                beq.s   sconclr
                moveq   #0,D4
sconclr:        moveq   #0,D7
                lea     deletescopes,A4
                move.w  shadow_dmacon,D6
                lea     mul160(PC),A5
                moveq   #0,D5
                movea.w #(72*320)+(16*4*2),A1
                lea     xblanksample(PC),A2
                btst    #0,D6
                beq.s   scoskp1
                lea     scopeinfo,A2
                move.b  ns_volume(A2),D5
scoskp1:        bsr.s   scodraw

                moveq   #0,D5
                movea.w #(72*320)+(22*4*2),A1
                lea     xblanksample(PC),A2
                btst    #1,D6
                beq.s   scoskp2
                lea     scopeinfo+20,A2
                move.b  ns_volume(A2),D5
scoskp2:        bsr.s   scodraw

                moveq   #0,D5
                movea.w #(72*320)+(28*4*2),A1
                lea     xblanksample(PC),A2
                btst    #2,D6
                beq.s   scoskp3
                lea     scopeinfo+40,A2
                move.b  ns_volume(A2),D5
scoskp3:        bsr.s   scodraw

                moveq   #0,D5
                movea.w #(72*320)+(34*4*2),A1
                lea     xblanksample(PC),A2
                btst    #3,D6
                beq.s   scoskp4
                lea     scopeinfo+60,A2
                move.b  ns_volume(A2),D5
scoskp4:        bsr     scodraw
                tst.l   D7
                beq     sdloscr
scorts:         rts

scodraw:        tst.b   scopeenable
                beq     sdlpos
                cmpi.w  #1,currscreen
                bne     sdlpos
                tst.b   edenable
                bne     sdlpos
;                lsr.w   #1,D5
                cmp.w   #64,D5
                bls.s   sdsk1
                moveq   #64,D5
sdsk1:          movea.l (A2),A0
                adda.l  log_base,A1
                lea     vols,A6
                asl.w   #8,D5
                adda.w  D5,A6
                adda.w  D5,A6
                move.l  A6,D1
                move.w  #$FE,D3
                addq.l  #8,A4
                move.l  (A4),D0
                move.w  #$8000,D2
scpdr_lp1:      clr.w   D1
                move.b  (A0)+,D1        ; get byte
                add.w   D1,D1
                move.w  0(A6,D1.w),D0   ; VOLUME IT
                asr.w   #8,D0
                and.w   D3,D0
                move.w  0(A5,D0.w),D0
                move.l  D0,(A4)+
                or.w    D2,4(A1,D0.w)   ; set a bit
                lsr.w   #1,D2
                bne.s   scpdr_lp1
                addq.l  #4,A4
                move.w  #$8000,D2
scpdr_lp2:      clr.w   D1
                move.b  (A0)+,D1        ; get byte
                add.w   D1,D1
                move.w  0(A6,D1.w),D0   ; VOLUME IT
                asr.w   #8,D0
                and.w   D3,D0
                move.w  0(A5,D0.w),D0
                move.l  D0,(A4)+
                or.w    D2,4+16(A1,D0.w) ; set a bit
                lsr.w   #1,D2
                bne.s   scpdr_lp2
                addq.l  #4,A4
                move.b  #$80,D2
scpdr_lp3:      clr.w   D1
                move.b  (A0)+,D1        ; get byte
                add.w   D1,D1
                move.w  0(A6,D1.w),D0   ; VOLUME IT
                asr.w   #8,D0
                and.w   D3,D0
                move.w  0(A5,D0.w),D0
                move.l  D0,(A4)+
                or.b    D2,4+32(A1,D0.w) ; set a bit
                lsr.b   #1,D2
                bne.s   scpdr_lp3
sdlpos:         tst.b   D4
                bne     scorts
                lea     xblanksample(PC),A0
                cmpa.l  A0,A2
                beq.s   sdloscr
                move.l  (A2),D1
                move.l  samdrawstart(PC),D0
                cmp.l   D0,D1
                bls     scorts
                cmp.l   samdrawend(PC),D1
                bhs     scorts
                sub.l   D0,D1
                mulu    #314,D1
                move.l  samdisplay,D0
                beq     scorts
                divu    D0,D1
                st      D4
                st      D7
                move.l  D1,D0
                addq.w  #6,D0
                move.w  #139,D1
sdlpspr:        moveq   #64,D2
                lea     playposspritedata,A0
                jmp     setspritepos

sdloscr:        moveq   #0,D0
                move.w  #270,D1
                bra.s   sdlpspr

setscope:
                moveq   #0,D1
                move.b  n_samplenum(A0),D1
                subq.w  #1,D1
                lsl.w   #4,D1
                lea     scopesaminfo,A4
                lea     0(A4,D1.w),A4

                move.l  n_start(A0),D0
                move.l  D0,ns_sampleptr(A4)
                moveq   #0,D1
                move.w  n_length(A0),D1
                add.l   D1,D0
                add.l   D1,D0
                move.l  D0,ns_endptr(A4)

                move.l  n_loopstart(A0),D0
                move.l  D0,ns_repeatptr(A4)
                moveq   #0,D1
                move.w  n_replen(A0),D1
                cmp.w   #1,D1
                beq.s   sconorep
                add.l   D1,D0
                add.l   D1,D0
                move.l  D0,ns_rependptr(A4)
                bra     return1
sconorep:
                clr.l   ns_repeatptr(A4)
                rts

toggleanascope:
                tst.w   notogfl
                bne     return1
                bsr     waitforbuttonup
                moveq   #0,D4
                tst.b   anascopflag
                bne.s   tasana
                st      anascopflag
                bra     redrawanascope
tasana:         sf      anascopflag
                bra     redrawanascope

scopeenable:    DC.B 0
anascopflag:    DC.B 1
xblanksample:   DC.L blanksample
samdrawstart:   DC.L 0
samdrawend:     DC.L 0
i               SET 0
mul160:         REPT 16
                DC.W i
i               SET i+320
                ENDR
                DS.W 128-32
i               SET -16*320
                REPT 16
                DC.W i
i               SET i+320
                ENDR

                ENDPART

                PART 'vumetters'


;---- VU Meters ----

vumeters:
                tst.w   samscrenable
                bne.s   nallvusdown
                moveq   #0,D0
                lea     audchan1temp,A1
                lea     vuspritedata1,A2
                move.w  audchan1toggle(PC),D0
                moveq   #%11111,D3      ;;
                move.w  #%1111100000000000,D4 ;;
                moveq   #24*2,D1        ;;
                bsr.s   onevumeter
                lea     audchan2temp,A1
                lea     vuspritedata2,A2
                move.w  audchan2toggle(PC),D0
                moveq   #56*2,D1        ;;
                moveq   #%0,D3          ;;
                move.w  #%1111111111000,D4 ;;
                bsr.s   onevumeter
                lea     audchan3temp,A1
                lea     vuspritedata3,A2
                move.w  audchan3toggle(PC),D0
                move.w  #96*2,D1        ;;
                moveq   #%11111,D3      ;;
                move.w  #%1111100000000000,D4 ;;

                bsr.s   onevumeter
                lea     audchan4temp,A1
                lea     vuspritedata4,A2
                move.w  audchan4toggle(PC),D0
                move.w  #128*2,D1       ;;
                moveq   #%0,D3          ;;
                move.w  #%1111111111000,D4 ;;
                bra.s   onevumeter
nallvusdown:    rts

; fall thru

onevumeter:
                tst.l   runmode
                beq.s   vumeterdown
                tst.w   (A1)
                beq.s   vumeterdown
                tst.w   D0
                beq.s   vumeterdown
                tst.l   counter
                bne.s   vumeterdown
                moveq   #0,D0           ; New note
                move.b  n_volume(A1),D0 ; Get volume
                cmp.w   #$40,D0         ; Higher than $40 ?
                bls.s   iccskip         ; No, skip
                moveq   #$40,D0         ; Yes, set to $40
iccskip:        lea     vumeterheights(PC),A3
                move.b  #233,D7         ; Set to 233
                sub.b   0(A3,D0.w),D7   ; Subtract to get new height
                move.b  D7,(A2)
                bra.s   dostvu

vumeterdown:
                cmpi.b  #233,(A2)
                beq     return1
                addq.b  #1,(A2)
; fall thru

dostvu:         movea.l log_base(PC),A0
                adda.l  #(231-89)*320,A0
                adda.w  D1,A0
                clr.w   D0
                move.b  (A2),D0
                neg.w   D0
                add.w   #233,D0
                moveq   #47,D1
                sub.w   D0,D1
                lsl.w   #3,D0
                lsl.w   #3,D1
                moveq   #0,D2
                jmp     .vcljmp(PC,D0.w)

i               SET 6+((46)*320)

.vcljmp:
                REPT 47
                move.w  D2,i(A0)
                move.w  D2,i+16(A0)
i               SET i-320
                ENDR
                jmp     .vdrjmp(PC,D1.w)
i               SET 6
.vdrjmp:
                REPT 47
                move.w  D3,i(A0)
                move.w  D4,i+16(A0)
i               SET i+320
                ENDR
                rts

audchan1toggle: DC.W 1,78,0
chan1volume:    DC.W 0
audchan2toggle: DC.W 1,518,$16
chan2volume:    DC.W 0
audchan3toggle: DC.W 1,958,$2C
chan3volume:    DC.W 0
audchan4toggle: DC.W 1,1398,$42
chan4volume:    DC.W 0
activechannels: DC.W 15

vumeterheights:
                DC.B 0,0,1,2,2,3,4,5,5,6,7,8,8,9,10,11
                DC.B 11,12,13,14,14,15,16,17,17,18,19,20,20,21,22,23
                DC.B 23,24,25,26,26,27,28,29,29,30,31,32,32,33,34,35
                DC.B 35,36,37,38,38,39,40,41,41,42,43,44,44,45,46,47
                DC.B 47,0

                ENDPART

                PART 'spectrum analyser'

;---- Spectrum Analyzer ----

specanaint:
                cmpi.w  #1,currscreen
                bne     return1
                tst.b   disableanalyzer
                bne     return1
                tst.b   anadrawflag
                bne     return1
                move.w  #320,D5
                moveq   #126,D6
                lea     analyzerheights,A0
                lea     analyzeropplegg,A1
                lea     analyzeroffsets(PC),A2
                movea.l log_base,A3
                lea     (1960*4*2)+(64*2)+6(A3),A3
                moveq   #1,D4
                moveq   #$16,D7
spanlab1:
                move.w  (A0)+,D0
                cmp.w   #36,D0
                blo.s   spanskip2
                move.w  #36,D0
spanskip2:
                move.w  (A1)+,D1
                cmp.w   D0,D1
                beq.s   spanskip3
                blo.s   span_r2
                sub.w   D0,D1
                subq.w  #1,D1
                add.w   D0,D0
                move.w  0(A2,D0.w),D0
                add.w   D0,D0           ;;
                add.w   D0,D0           ;;
                add.w   D0,D0
spanloop:
                clr.b   0(A3,D0.w)
                sub.w   D5,D0
                dbra    D1,spanloop
                bra.s   spanskip3

span_r2:        sub.w   D1,D0
                subq.w  #1,D0
                add.w   D1,D1           ;;
                move.w  0(A2,D1.w),D1
                add.w   D1,D1           ;;
                add.w   D1,D1           ;;
                add.w   D1,D1           ;;
spanloop2:      move.b  D6,0(A3,D1.w)
                sub.w   D5,D1
                dbra    D0,spanloop2
spanskip3:
                adda.w  D4,A3
                eori.w  #14,D4
                dbra    D7,spanlab1
                lea     analyzerheights,A0
                lea     analyzeropplegg,A1
                moveq   #22,D7
spanloop3:      move.w  (A0),D0
                move.w  D0,(A1)+
                beq.s   spanskip4
                subq.w  #1,D0
spanskip4:      move.w  D0,(A0)+
                dbra    D7,spanloop3
                rts

clearanaheights:
                lea     analyzeropplegg,A0
                lea     analyzerheights,A1
                moveq   #22,D7
                moveq   #0,D0
cahloop:        move.w  D0,(A0)+
                move.w  D0,(A1)+
                dbra    D7,cahloop
                rts

playnoteanalyze:
                movem.l D0-D3/A0,-(SP)
                moveq   #0,D2
                move.w  2(A6),D2
                bra.s   specana2

spectrumanalyzer:
                tst.w   (A4)
                beq     return1
                movem.l D0-D3/A0,-(SP)
                moveq   #0,D2
                move.b  n_volume(A6),D2 ; Get channel volume
specana2:
                st      anadrawflag
                bsr     setanalyzervolumes
                beq.s   saend
                lsl.w   #8,D2
                divu    #682,D2
                move.w  D2,D3
                lsr.w   #1,D3
                lea     analyzerheights,A0
                sub.w   #113,D0         ; Subtract 113 (highest rate)
                move.w  #743,D1
                sub.w   D0,D1           ; Invert range 0-743
                mulu    D1,D1           ; 0 - 743^2
                divu    #25093,D1
                move.w  D1,D0
                cmp.w   #46,D0
                blo.s   saskip
                moveq   #45,D0
saskip:         add.w   D0,D0
                add.w   D2,0(A0,D0.w)
                cmpi.w  #36,0(A0,D0.w)
                blo.s   saskip2
                move.w  #36,0(A0,D0.w)
saskip2:        tst.w   D0
                beq.s   saskip3
                add.w   D3,-2(A0,D0.w)
                cmpi.w  #36,-2(A0,D0.w)
                blo.s   saskip3
                move.w  #36,-2(A0,D0.w)
saskip3:        cmp.w   #44,D0
                beq.s   saend
                add.w   D3,2(A0,D0.w)
                cmpi.w  #36,2(A0,D0.w)
                blo.s   saend
                move.w  #36,2(A0,D0.w)
saend:          sf      anadrawflag
                movem.l (SP)+,D0-D3/A0
                rts

analyzeroffsets:
                DC.W $0730,$0708,$06E0,$06B8,$0690,$0668,$0640,$0618
                DC.W $05F0,$05C8,$05A0,$0578,$0550,$0528,$0500,$04D8
                DC.W $04B0,$0488,$0460,$0438,$0410,$03E8,$03C0,$0398
                DC.W $0370,$0348,$0320,$02F8,$02D0,$02A8,$0280,$0258
                DC.W $0230,$0208,$01E0,$01B8,$0190,$0168,$0140,$0118
                DC.W $F0

anadrawflag:    DC.B 0,0

setanalyzervolumes:
                movem.l D0-D3/A0,-(SP)
                lsl.w   #8,D2
                divu    #640,D2
                cmpa.l  #ch1s,A5
                bne.s   savch2
                tst.w   audchan1toggle
                beq.s   savch2
                cmp.w   chan1volume,D2  ; volume
                blo.s   savch2
                move.w  D2,chan1volume
savch2:         cmpa.l  #ch2s,A5
                bne.s   savch3
                tst.w   audchan2toggle
                beq.s   savch3
                cmp.w   chan2volume,D2
                blo.s   savch3
                move.w  D2,chan2volume
savch3:         cmpa.l  #ch3s,A5
                bne.s   savch4
                tst.w   audchan3toggle
                beq.s   savch4
                cmp.w   chan3volume,D2
                blo.s   savch4
                move.w  D2,chan3volume
savch4:         cmpa.l  #ch4s,A5
                bne.s   savnone
                tst.w   audchan4toggle
                beq.s   savnone
                cmp.w   chan4volume,D2
                blo.s   savnone
                move.w  D2,chan4volume
savnone:        movem.l (SP)+,D0-D3/A0
                moveq   #1,D4
                rts

                ENDPART

; bit 2 of dff016 = bit 0 of mousebut
; bit 6 of dff002 = bit 2 of mousebut
;---- Tempo ----

tempogadg:
                cmp.w   #60,D0
                bhs     return1
                cmp.w   #44,D0
                bhs.s   temdown
temup:          move.w  realtempo(PC),D0
                addq.w  #1,D0
                btst    #0,mousebut
                beq.s   teupsk

                addq.w  #8,D0
                addq.w  #1,D0
teupsk:         cmp.w   #255,D0
                bls.s   teposk
                move.w  #255,D0
teposk:         move.w  D0,realtempo
                bsr     settempo
                jmp     wait_4000

temdown:        move.w  realtempo(PC),D0
                subq.w  #1,D0
                btst    #0,mousebut
                beq.s   tednsk

                subq.w  #8,D0
                subq.w  #1,D0
tednsk:         cmp.w   #32,D0
                bhs.s   teposk
                move.w  #32,D0
                bra.s   teposk


changetempo:
                bra     shownotimpl

                cmp.w   #94,D0
                bhs.s   tempodown
                cmp.w   #80,D0
                bhs.s   tempoup
                rts

tempoup:        move.w  tempo,D0
                addq.w  #1,D0
                btst    #0,mousebut
                beq.s   temupsk

                addq.w  #8,D0
                addq.w  #1,D0
temupsk:        cmp.w   #255,D0
                bls.s   temposk
                move.w  #255,D0
temposk:        move.w  D0,tempo
                move.w  D0,realtempo
                bsr.s   showtempo
                bsr.s   settempo
                jmp     wait_4000

tempodown:
                move.w  tempo,D0
                subq.w  #1,D0
                btst    #0,mousebut
                beq.s   temdnsk
                subq.w  #8,D0
                subq.w  #1,D0
temdnsk:        cmp.w   #32,D0

                bhs.s   temposk
                move.w  #32,D0
                bra.s   temposk

showtempo:
                move.w  #607,textoffset
                move.w  realtempo(PC),wordnumber
                jmp     print3decdigits

settempo:
                moveq   #125,D0
                move.l  ciaabase(PC),D1
                beq.s   setesk3
                move.w  realtempo(PC),D0
                cmp.w   #32,D0
                bhs.s   setemsk
                moveq   #32,D0
setemsk:        move.w  D0,realtempo
setesk3:        tst.w   samscrenable
                bne.s   setesk2
                move.w  #4964,textoffset
                move.w  D0,wordnumber
                jsr     print3decdigits
setesk2:
                rts

realtempo:      DC.W 125
ciaaaddr:       DC.L 0

;---- Timer ----

updateticks:
                cmpi.l  #'patp',runmode
                bne.s   noupdateticks
                addq.w  #1,patternticks
                move.w  patternticks(PC),D0
                cmp.w   #50,D0
                bne.s   noupdateticks
                clr.w   patternticks
                addq.l  #1,timerticks
noupdateticks:  rts

showtimer:
                cmpi.w  #4,currscreen
                beq     return1
                move.l  timerticks(PC),D0
                divu    #60,D0
                move.w  D0,wordnumber
                swap    D0
                move.w  D0,D7
                move.w  #4154,textoffset
                jsr     print2decdigits
                move.w  D7,wordnumber
                addq.w  #1,textoffset
                jmp     print2decdigits

patternticks:   DC.W 0
timerticks:     DC.L 0

;---- Show Free/Tune Memory ----

doshowfreemem:
                move.w  #1,updatefreemem
showfreemem:
                movem.l D0-A6,-(SP)
                tst.w   updatefreemem
                beq.s   sfmskp
                clr.w   updatefreemem
                clr.l   freememory
                clr.l   tunememory
sfmskp:         bsr     showtunemem
                moveq   #memf_chip,D1
                tst.b   showpublicflag
                beq     sfmskp2
                moveq   #memf_public,D1
sfmskp2:        movea.l 4.w,A6
                jsr     lvoavailmem
                cmp.l   freememory(PC),D0
                beq.s   fremend
                move.l  D0,freememory
                tst.b   showdecflag
                bne.s   shfrdec
                move.l  D0,D6
                move.w  #5273,textoffset
                swap    D0
                and.w   #$FF,D0
                move.w  D0,wordnumber
                jsr     printhexbyte
                move.w  D6,wordnumber
                jsr     printhexword
fremend:        movem.l (SP)+,D0-A6
                rts

shfrdec:        move.l  freememory(PC),D0
                move.w  #5273,textoffset
                jsr     print6decdigits
                bra.s   fremend

showtunemem:
                movea.l songdataptr,A0
                lea     42(A0),A0
                move.w  tuneup(PC),D7
                subq.w  #1,D7
                move.w  #31,tuneup
                moveq   #0,D0           ; Zero length
stumeloop:
                moveq   #0,D1
                move.w  (A0),D1
                add.w   D1,D1
                add.l   D1,D0           ; Add samplelength
                adda.l  #30,A0
                dbra    D7,stumeloop
                add.l   #1084,D0        ; Add 1084 to length
                movea.l songdataptr,A0
                moveq   #127,D7
                adda.l  #952,A0
                moveq   #0,D6
stumeloop2:
                move.b  (A0)+,D5
                cmp.b   D5,D6
                bhi.s   stumeskip
                move.b  D5,D6
stumeskip:
                dbra    D7,stumeloop2
                addq.w  #1,D6
                asl.l   #8,D6
                asl.l   #2,D6
                add.l   D6,D0           ; Add 1024 x Number of patterns
                cmp.l   tunememory(PC),D0
                beq     return1
                move.l  D0,tunememory
                tst.b   showdecflag
                bne.s   shtudec
                move.l  D0,D6
                move.w  #4993,textoffset
                swap    D0
                and.w   #$FF,D0
                move.w  D0,wordnumber
                jsr     printhexbyte
                move.w  D6,wordnumber
                jmp     printhexword

shtudec:        move.l  tunememory(PC),D0
                move.w  #4993,textoffset
                jmp     print6decdigits

updatefreemem:  DC.W 0
freememory:     DC.L 0
tunememory:     DC.L 0
tuneup:         DC.W 31

;---- Audio Channel Toggles ----

checktoggle:
                move.w  mousey2,D0
                cmpi.w  #1,currscreen
                bne     return1
                cmp.w   #44,D0
                bhs     return1
dotogglemute:
                cmp.w   #34,D0
                bhs.s   togglech4
                cmp.w   #23,D0
                bhs.s   togglech3
                cmp.w   #12,D0
                bhs.s   togglech2
togglech1:
                lea     audchan1toggle(PC),A0
                bra.s   togch
togglech2:
                lea     audchan2toggle(PC),A0
                bra.s   togch
togglech3:
                lea     audchan3toggle(PC),A0
                bra.s   togch
togglech4:
                lea     audchan4toggle(PC),A0
togch:          clr.b   rawkeycode
                eori.w  #1,(A0)
                bsr     waitforbuttonup
                clr.w   D0
                move.w  audchan4toggle(PC),D0
                add.b   D0,D0
                or.w    audchan3toggle(PC),D0
                add.b   D0,D0
                or.w    audchan2toggle(PC),D0
                add.b   D0,D0
                or.w    audchan1toggle(PC),D0
                move.w  D0,activechannels
                bsr.s   redrawtoggles
                bsr     wait_4000
                bra     wait_4000

redrawtoggles:
                cmpi.w  #1,currscreen
                bne     return1
                lea     audchan1toggle(PC),A0
                bsr.s   redrawsingletogg
                lea     audchan2toggle(PC),A0
                bsr.s   redrawsingletogg
                lea     audchan3toggle(PC),A0
                bsr.s   redrawsingletogg
                lea     audchan4toggle(PC),A0
                bsr.s   redrawsingletogg
                rts

redrawsingletogg:
                movea.l log_base(PC),A1
                moveq   #0,D0
                move.w  2(A0),D0
                lsl.l   #3,D0
                adda.l  D0,A1
                moveq   #0,D0
                move.w  4(A0),D0
                lea     toggleondata,A2
                tst.w   (A0)
                bne.s   rtskip
                lea     toggleoffdata,A2
rtskip:         adda.l  D0,A2
                moveq   #10,D4
rtloop2:
                move.w  (A2)+,(A1)+
                move.w  88-2(A2),(A1)+
                lea     320-4(A1),A1
                dbra    D4,rtloop2
                rts

rtdoit:
                movem.l D2-D3/A1,-(SP)
;                not.l   $FFFF9800
;                jsr     wait_vbl

                suba.l  #bitplanedata,A1
                move.l  A1,D2
                divu    #40,D2
                move.l  D2,D3
                mulu    #320,D2
                swap    D3
                lsl.w   #3,D3
                movea.l log_base,A1
                adda.l  D2,A1
                adda.w  D3,A1
                moveq   #10,D4
rtloop:         move.w  132(A2),2(A1)
                move.w  (A2)+,(A1)
                lea     320(A1),A1
                dbra    D4,rtloop
                movem.l (SP)+,D2-D3/A1
                rts


                PART 'disk op'

;---- Disk Op. ----

diskop:         clr.b   rawkeycode
                move.w  currscreen,D0
                cmp.w   #3,D0
                beq     exitfromdir
                cmp.w   #1,D0
                bne     return1
showdirscreen:
                bsr     waitforbuttonup
                move.w  #3,currscreen
                st      disableanalyzer
                st      nosampleinfo
                jsr     clearanalyzercolors
                bsr     clear100lines
                bsr.s   swapdirscreen
                beq     displaymainall
                bsr     showdiskspace
                bsr     showmodpackmode
                bsr     showpackmode
                bsr     showrawiffmode
doautodir:
                tst.b   autodirflag
                beq     selectpath
                move.w  dirpathnum,D0
                beq     loadmodulegadg
                cmp.w   #1,D0
                beq     loadsonggadg
                cmp.w   #2,D0
                beq     loadsamplegadg
                bra     selectmodules
selectpath:
                move.w  dirpathnum,D0
                beq     selectmodules
                cmp.w   #1,D0
                beq     selectsongs
                bra     selectsamples

swapdirscreen:
                lea     dirscreendata,A1
                movea.l log_base(PC),A0 ;;
                moveq   #99,D0          ;;
                moveq   #16,D2
sxloop2:
                REPT 20
                move.l  (A0),D1
                move.l  (A1),(A0)
                move.l  D1,(A1)+
                adda.w  D2,A0
                ENDR
                dbra    D0,sxloop2      ;;
                rts

ssets3:         movea.l log_base,A0     ;;
                move.w  #999,D0         ;;
.sxloop2:
                REPT 2
                move.l  (A0),D1
                move.w  (A1),(A0)+
                move.w  1000*4(A1),(A0)+
                move.w  D1,1000*4(A1)   ;;
                swap    D1
                move.w  D1,(A1)+
                lea     12(A0),A0       ;;
                ENDR
                dbra    D0,.sxloop2     ;;
                rts


checkdirgadgets:
                movem.w mousex2,D0-D1
                cmp.w   #44,D1
                bhi     checkdirgadgets2
                cmp.w   #33,D1
                bls.s   extrasmenu
                cmp.w   #11,D0
                blo     dirbrowsegadg
                cmp.w   #187,D0
                blo     dirpathgadg
                cmp.w   #216,D0
                blo     parentdirgadg
                cmp.w   #307,D0
                blo     showfreediskgadg
                bra     checkdirgadgets2

extrasmenu:
                cmp.w   #94,D0
                bhs     togglemenu
                cmp.w   #22,D1
                bhi.s   deletefilegadg
                cmp.w   #11,D1
                bhi.s   renamefilegadg
                bra     diskformatgadg

renamefilegadg:
                bra     shownotimpl
                bsr     storeptrcol
                bsr     waitforbuttonup
                bsr     clearfilenames
                movea.l pathptr,A4
                bsr     showdirpath
                lea     filenamesptr(PC),A5
                bsr     hasdiskchanged
                beq.s   renamefiledirok
                bsr     cleardirtotal
                bsr     dirdisk
                bne     restoreptrcol

renamefiledirok:
                move.w  filenamescrollpos,D0
                bsr     redrawfilenames
                move.w  #10,action
                lea     selectfiletext,A0
                jsr     showstatustext
                bra     restoreptrcol

deletefilegadg:
                bra     shownotimpl
                move.w  dirpathnum,D0
                beq     deletemodulegadg
                cmp.w   #1,D0
                beq     deletesonggadg
                cmp.w   #2,D0
                beq     deletesamplegadg
                rts

togglemenu:
                cmp.w   #146,D0
                bhs     selectmenu
                cmp.w   #22,D1
                bhi     toggleiffsave
                cmp.w   #11,D1
                bhi.s   togglesongpack
togglemodpack:
                clr.b   modpackmode
                bsr     shownotimpl
showmodpackmode:
                lea     toggleofftext(PC),A0
                tst.b   modpackmode
                beq.s   smpmskp
                lea     toggleontext2(PC),A0
smpmskp:        moveq   #3,D0
                move.w  #175,D1
                jsr     showtext3
                bra     waitforbuttonup

shownotimpl:
                bsr     storeptrcol
                lea     notimpltext(PC),A0
                jsr     showstatustext
                bsr     seterrorptrcol
                bra     restoreptrcol

notimpltext:    DC.B 'Not implemented',0
                EVEN

togglesongpack:
                eori.b  #1,packmode
showpackmode:
                lea     toggleofftext(PC),A0
                tst.b   packmode
                beq.s   spsskip
                lea     toggleontext2(PC),A0
spsskip:        moveq   #3,D0
                move.w  #615,D1
                jsr     showtext3
                bra     waitforbuttonup

toggleiffsave:
                eori.b  #1,rawiffmode
showrawiffmode:
                lea     rawtext(PC),A0
                tst.b   rawiffmode
                beq.s   sraffu
                lea     ifftext(PC),A0
sraffu:         moveq   #3,D0
                move.w  #1055,D1
                jsr     showtext3
                bra     waitforbuttonup

rawtext:        DC.B "RAW",0
ifftext:        DC.B "IFF",0

selectmenu:
                cmp.w   #156,D0
                bhs     loadmenu
                cmp.w   #22,D1
                bhi     selectsamples
                cmp.w   #11,D1
                bhi     selectsongs
                bra     selectmodules

loadmenu:
                cmp.w   #238,D0
                bhs.s   savemenu
                cmp.w   #22,D1
                bhi     loadsamplegadg
                cmp.w   #11,D1
                bhi     loadsonggadg
                bra     loadmodulegadg

savemenu:
                cmp.w   #22,D1
                bhi     savesamplegadg
                cmp.w   #11,D1
                bhi     savesonggadg
                bra     savemodulegadg

checkdirgadgets2:
                movem.w mousex2,D0-D1
                cmpi.w  #3,currscreen
                bne     return1
                cmp.w   #307,D0
                blo     filenamepressed
                cmp.w   #44,D1
                bls     filenameoneup
                cmp.w   #89,D1
                blo.s   exitfromdir
                bra     filenameonedown

exitfromdir:
                bsr     waitforbuttonup
                clr.b   rawkeycode
                bsr     clear100lines
                bsr     swapdirscreen
displaymainall:
                bsr     displaymainscreen
                jsr     showsonglength
                jsr     showsampleinfo
                jsr     showsongname
                jsr     show_ms
                tst.w   loadinprogress
                bne.s   dimaskp
                jsr     showallright
dimaskp:        jsr     showposition
                rts

dirbrowsegadg:
                moveq   #0,D3
                move.w  dirpathnum,D3
                lea     dpnum(PC),A0
                adda.l  D3,A0
                moveq   #0,D0
                move.b  (A0),D0
                addq.b  #1,D0
                cmp.b   #7,D0
                blo.s   dbgskip
                moveq   #0,D0
dbgskip:        move.b  D0,(A0)
                mulu    #4,D0
                movea.l pathptr,A0
                moveq   #63,D1
                moveq   #0,D2
dbglop1:        move.b  D2,(A0)+
                dbra    D1,dbglop1
                lea     dirpaths(PC),A0
                lea     -4(A0,D0.w),A0
                tst.w   D0
                bne.s   dbgskp2
                lea     modulespath,A0
                tst.w   D3
                beq.s   dbgskp2
                lea     songspath,A0
                cmp.w   #1,D3
                beq.s   dbgskp2
                lea     samplepath,A0
dbgskp2:        movea.l pathptr,A1
dbglop2:        move.b  (A0)+,(A1)+
                bne.s   dbglop2
                bsr     showdirpath
                move.w  #3,waittime
                bra     waitalittle

dirpaths:
                DC.B "A:\",0,"B:\",0,"C:\",0,"D:\",0,"E:\",0,"F:\",0
dpnum:          DC.B 0,0,0,0
dirpathnum:
                DC.W 3

selectmodules:
                moveq   #0,D0
                bra.s   changepath
selectsongs:
                moveq   #1,D0
                bra.s   changepath
selectsamples:
                moveq   #2,D0
changepath:
                movea.l log_base,A0
                lea     (320*4)+(9*16)+4(A0),A0
;                movea.l textbplptr,A0
;                lea     178(A0),A0
                moveq   #0,D2
                moveq   #26,D1
chpalop:        move.w  D2,(A0)
                lea     320(A0),A0
                dbra    D1,chpalop
                lea     modulespath2,A4
                move.w  #178*8,D1
                move.w  D0,dirpathnum
                beq.s   chpaski
                lea     songspath2,A4
                move.w  #618*8,D1
                cmp.w   #1,D0
                beq.s   chpaski
                lea     samplepath2,A4
                move.w  #1058*8,D1
chpaski:                                ;movea.l textbplptr,A0
;lea     0(A0,D1.w),A0
                movea.l log_base,A0
                adda.w  D1,A0
                move.w  #$0100,4(A0)
                move.w  #$0F80,4+(40*8)(A0)
                move.w  #$0FC0,4+(80*8)(A0)
                move.w  #$0F80,4+(120*8)(A0)
                move.w  #$0100,4+(160*8)(A0)
                move.l  A4,pathptr
                bsr     showdirpath
                bra     waitforbuttonup

;---- Song Gadgets ----

loadsonggadg:
                bsr     storeptrcol
                bsr     waitforbuttonup
                bsr     clearfilenames
                bsr     selectsongs
                lea     filenamesptr(PC),A5
                bsr     hasdiskchanged
                beq     loadsongdirok
                bsr     cleardirtotal
                bsr     dirdisk
                bne     restoreptrcol
loadsongdirok:
                move.w  filenamescrollpos,D0
                bsr     redrawfilenames
                move.w  #1,action
                lea     selectsongtext,A0
                jsr     showstatustext
                bra     restoreptrcol

savesonggadg:
                bsr     selectsongs
                lea     savesongtext,A0
                bsr     areyousure
                bne     return1
                bsr     restoreptrcol
                bsr     clearfilenames
                jsr     stopit
                jsr     savesong
                move.w  #1,action
                rts

deletesonggadg:
                bsr     waitforbuttonup
                bsr     clearfilenames
                bsr     selectsongs
                lea     filenamesptr(PC),A5
                bsr     hasdiskchanged
                beq.s   deletesongdirok
                bsr     cleardirtotal
                bsr     dirdisk
                beq.s   deletesongdirok
                bra     restoreptrcol

deletesongdirok:
                move.w  filenamescrollpos,D0
                bsr     redrawfilenames
                move.w  #2,action
                lea     selectsongtext,A0
                jsr     showstatustext
                bra     setdeleteptrcol

;---- Module Gadgets ----

loadmodulegadg:
                bsr     storeptrcol
                bsr     waitforbuttonup
                bsr     clearfilenames
                bsr     selectmodules
                lea     filenamesptr(PC),A5
                bsr     hasdiskchanged
                beq.s   loadmoddirok
                bsr     cleardirtotal
                bsr     dirdisk
                beq.s   loadmoddirok
                bra     restoreptrcol

loadmoddirok:
                move.w  filenamescrollpos,D0
                bsr     redrawfilenames
                move.w  #3,action
                lea     selectmoduletext,A0
                jsr     showstatustext
                bra     restoreptrcol

savemodulegadg:
                bsr     selectmodules
                lea     savemoduletext,A0
                bsr     areyousure
                bne     return1
                jsr     savemodule
                move.w  #3,action
                jmp     showallright

deletemodulegadg:
                bsr     waitforbuttonup
                bsr     clearfilenames
                bsr     selectmodules
                lea     filenamesptr(PC),A5
                bsr     hasdiskchanged
                beq.s   deletemoddirok
                bsr     cleardirtotal
                bsr     dirdisk
                beq.s   deletemoddirok
                bra     restoreptrcol

deletemoddirok:
                move.w  filenamescrollpos(PC),D0
                bsr     redrawfilenames
                move.w  #4,action
                lea     selectmoduletext,A0
                jsr     showstatustext
                bra     setdeleteptrcol

;---- Sample Gadgets ----

loadsamplegadg:
                bsr     storeptrcol
                bsr     waitforbuttonup
                bsr     clearfilenames
                bsr     selectsamples
                lea     filenamesptr(PC),A5
                bsr     hasdiskchanged
                beq.s   loadsampledirok
                bsr     cleardirtotal
                bsr     dirdisk
                beq.s   loadsampledirok
                bra     restoreptrcol

loadsampledirok:
                move.w  filenamescrollpos,D0
                bsr     redrawfilenames
                move.w  #5,action
                lea     selectsampletext,A0
                jsr     showstatustext
                bra     restoreptrcol

savesamplegadg:
                bsr     selectsamples
                clr.b   rawkeycode
                move.w  insnum,D0
                beq     notsamplenull
                lea     savesampletext,A0
                bsr     areyousure
                bne     return1
                bsr     storeptrcol
                bsr     createsamplename
                moveq   #0,D1
                move.w  insnum,D1
                lsl.l   #2,D1
                lea     sampleptrs,A0
                move.l  0(A0,D1.w),diskdataptr

                bsr     setdiskptrcol
                movea.l dosbase,A6
                move.l  filenameptr,D1
                move.l  #1006,D2
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                bne     savesample
                jsr     cantopenfile
                bra     errorrestorecol

savesample:
                lea     savingsampletext,A0
                jsr     showstatustext
                tst.b   rawiffmode
                beq     savesam
                move.l  filehandle,D1
                move.l  #iffform,D2
                moveq   #iffend-iffform,D3
                jsr     lvowrite        ;;
savesam:        move.l  filehandle,D1
                move.l  diskdataptr,D2
                move.l  diskdatalength,D3
                jsr     lvowrite        ;;

                move.l  filehandle,D1
                jsr     lvoclose        ;;
                clr.l   filehandle
                move.w  #5,action
                jsr     showallright
                bra     restoreptrcol

iffform:        DC.B "FORM"
                DC.L 0
                DC.B "8SVX"
iffvhdr:        DC.B "VHDR"
                DC.L 20
                DC.L 0,0,32     ; oneshot, repeat, hisamples
                DC.W 16726      ; This is really NTSC (16574 for PAL!!!)
                DC.B 1,0        ; octaves, compression
                DC.L $010000    ; volume
iffname:        DC.B "NAME"
                DC.L 24
                DCB.B 24
                DC.B "ANNO"
                DC.L 16
                DC.B "Protracker 2.0A",0
iffbody:        DC.B "BODY"
                DC.L 0
iffend:


;---- Delete Sample ----

deletesamplegadg:
                bsr     storeptrcol
                bsr     waitforbuttonup
                bsr     clearfilenames
                bsr     selectsamples
                lea     filenamesptr(PC),A5
                bsr     hasdiskchanged
                beq.s   deletesamdirok
                bsr     cleardirtotal
                bsr     dirdisk
                beq.s   deletesamdirok
                bra     restoreptrcol

deletesamdirok:
                move.w  filenamescrollpos(PC),D0
                bsr     redrawfilenames
                move.w  #6,action
                lea     selectsampletext,A0
                jsr     showstatustext
                bra     setdeleteptrcol

;---- Directory Path Gadget ----

dirpathgadg:
                bsr     storeptrcol
                bsr     setwaitptrcol
                movea.l pathptr,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #63,textendptr
                move.w  #19,textlength
                movea.w #1484,A4
                bsr     gettextline
                bra     restoreptrcol


copypath:
                lea     filename,A1
                tst.b   (A0)            ; If no path
                beq     return1
cploop:         move.b  (A0)+,(A1)+     ; Copy path to filename
                bne.s   cploop
                cmpi.b  #'\',-2(A1)     ;; If ending with '\' it's ok
                beq.s   pathcharback
                move.b  #'\',-1(A1)     ;; Add '\' to end path
                rts

pathcharback:
                subq.l  #1,A1
                rts

showdirpath:
                cmpi.w  #3,currscreen
                bne     return1
                movem.l D0-A6,-(SP)
                movea.l pathptr,A0
                moveq   #19,D0
                move.w  #1484,D1
                jsr     showtext3
                movem.l (SP)+,D0-A6
                rts

;---- File List Gadgets ----

filenameoneup:
                tst.w   action
                beq     return1
                lea     filenamesptr(PC),A5
                move.w  filenamescrollpos(PC),D0
                beq     return1
                subq.w  #1,D0
;                btst    #2,$DFF016
;                bne     redrawfilenames
                btst    #0,mousebut
                beq     redrawfilenames

                subq.w  #3,D0
                bpl     redrawfilenames
                moveq   #0,D0
                bra     redrawfilenames

filenameonedown:
                tst.w   action
                beq     return1
                lea     filenamesptr(PC),A5
                move.w  filenamescrollpos(PC),D0
                addq.w  #1,D0
;                btst    #2,$DFF016
;                bne.s   fnod2
                btst    #0,mousebut
                beq.s   fnod2

                addq.w  #3,D0
fnod2:          move.w  16(A5),D1
                subq.w  #8,D1
                bmi     return1
                cmp.w   D1,D0
                bls     redrawfilenames
                move.w  D1,D0
                bra     redrawfilenames

;---- Clicked on a filename ----

filenamepressed:
                sub.w   #44,D1
                move.w  #1,updatefreemem
                tst.w   action
                beq     return1
                cmp.w   #3,D1
                blo     return1
                cmp.w   #50,D1
                bhi     return1
                subq.w  #3,D1
                and.l   #$FFFF,D1
                divu    #6,D1
                move.w  D1,filenamescrollpos+2
                lea     filenamesptr(PC),A5
                move.w  filenamescrollpos(PC),D0
                add.w   D1,D0
                cmp.w   16(A5),D0
                bhs     return1
                mulu    #36,D0
                add.l   (A5),D0
                movea.l D0,A0
                tst.l   32(A0)
                bmi.s   adddirectory
                moveq   #dirnamelength-1,D0
                lea     dirinputname,A1
fnploop:        move.b  (A0)+,(A1)+
                dbra    D0,fnploop
                move.w  action,D6
                cmp.w   #1,D6
                beq     loadsong
                cmp.w   #2,D6
                beq     deletesong
                cmp.w   #3,D6
                beq     xloadmodule
                cmp.w   #4,D6
                beq     deletemodule
                cmp.w   #5,D6
                beq     loadsample
                cmp.w   #6,D6
                beq     deletesample
                cmp.w   #10,D6
                beq     renamefile
                rts

xloadmodule:    jmp     loadmodule

adddirectory:
                move.l  A0,-(SP)
                movea.l pathptr,A0
                bsr     copypath
                movea.l (SP)+,A0
                moveq   #dirnamelength-1,D0
addplop:        move.b  (A0)+,(A1)+
                dbra    D0,addplop

                lea     filename,A0
                movea.l pathptr,A1
                moveq   #62,D0
addplp2:        move.b  (A0)+,(A1)+
                dbra    D0,addplp2

addpdir:        bsr     showdirpath
                move.w  action,D6
                cmp.w   #1,D6
                beq     loadsonggadg
                cmp.w   #2,D6
                beq     deletesonggadg
                cmp.w   #3,D6
                beq     loadmodulegadg
                cmp.w   #4,D6
                beq     deletemodulegadg
                cmp.w   #5,D6
                beq     loadsamplegadg
                cmp.w   #6,D6
                beq     deletesamplegadg
                cmp.w   #10,D6
                beq     renamefilegadg
                rts

parentdirgadg:
                bsr     waitforbuttonup

                movea.l pathptr,A0
                movea.l A0,A1
pdgloop:        tst.b   (A1)+
                bne.s   pdgloop
                subq.l  #1,A1
                cmpa.l  A0,A1
                bls     return1
                subq.l  #1,A1
                cmpi.b  #'\',(A1)       ;;
                bne.s   pdgskp1
                clr.b   (A1)
pdgskp1:        cmpi.b  #':',(A1)
                beq.s   addpdir
                cmpi.b  #'\',(A1)       ;;
                beq     pdgslsh
                clr.b   (A1)
                cmpa.l  A0,A1
                bls.s   addpdir
                subq.l  #1,A1
                bra.s   pdgskp1

pdgslsh:        clr.b   (A1)
                bra     addpdir

filenamesptr:
                DC.L 0          ; A5+ 0
                DC.L 0          ;   + 4
                DC.L 0          ;   + 8
                DC.L 0          ;   +12
                DC.W 0          ;   +16
                DC.W 24         ;   +18
filenamescrollpos:
                DC.W 0
                DC.W 0

;---- Has Disk Changed ----

hasdiskchanged:
                moveq   #-1,D0
                rts

diskchanged:
                moveq   #-1,D0
                rts

examineerror:
                clr.l   4(A5)
                moveq   #-1,D0
                rts

showfreediskgadg:
                bsr     waitforbuttonup
                bsr.s   lockandgetinfo
                bsr     dirdiskunlock
                jmp     showallright

lockandgetinfo:
                bsr     storeptrcol
                bsr     setdiskptrcol

                clr.w   filenamescrollpos
                clr.w   -(SP)           ;; current drive
                pea     d_freebuf(PC)   ;;
                move.w  #54,-(SP)       ;;
                trap    #1              ;; dfree
                addq.l  #8,SP           ;;


                tst.l   D0              ;;
                bne     dirdiskerror    ;;

                lea     d_freebuf(PC),A0 ;;
                move.l  (A0),D0         ;; free clusters
                move.l  8(A0),D1        ;; bytes per sector
                move.l  12(A0),D2       ;; sectors per cluster
                mulu    D2,D1           ;; sectors per cluster*bytes per sector
                mulu    D1,D0           ;; * free clushers
                move.l  D0,freediskspace ;;

showdiskspace:
                move.w  #1510,textoffset
                move.l  freediskspace,D7
                tst.b   showdecflag
                bne.s   sdsdec
                swap    D7
                move.w  D7,wordnumber
                jsr     printhexword
                swap    D7
                move.w  D7,wordnumber
                jsr     printhexword
                moveq   #0,D0
                rts
d_freebuf:      DS.L 4

sdsdec:         divu    #10000,D7
                move.w  D7,wordnumber
                jsr     print4decdigits
                swap    D7
                move.w  D7,wordnumber
                jsr     print4decdigits
                moveq   #0,D0
                rts

;---- Get Disk Directory ----

allocdirmem:
                addi.w  #50,direntries
                move.w  direntries,D0
                mulu    #36,D0
                move.l  dirallocsize(PC),D6
                move.l  D0,dirallocsize
                move.l  #memf_public+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,D7
                beq.s   baehsj

                move.l  filenamesptr(PC),D1
                move.l  D7,filenamesptr
                tst.l   D1
                beq     return1
                tst.l   D6
                beq     return1
                movea.l D1,A0
                movea.l D7,A1
                move.l  D6,D0
admloop:        move.b  (A0)+,(A1)+
                subq.l  #1,D6
                bne.s   admloop
                movea.l D1,A1
                movea.l 4.w,A6
                jsr     lvofreemem
                rts

freedirmem:
                move.l  filenamesptr(PC),D1
                beq     return1
                movea.l D1,A1
                move.l  dirallocsize(PC),D0
                movea.l 4.w,A6
                jsr     lvofreemem
                clr.l   filenamesptr
                clr.w   dirallocsize
                clr.w   direntries
                rts

baehsj:         jsr     outofmemerr
                moveq   #-1,D0
                rts

dirallocsize:   DC.L 0
direntries:     DC.W 0

; Get directory!

dirdisk:        bsr     freedirmem
                bsr     allocdirmem
                bsr     lockandgetinfo
                bne     return1

; First search for directories

searchdir:      movea.l pathptr,A0
                lea     gempath,A1
.cpp:           move.b  (A0)+,(A1)+
                bne.s   .cpp
                subq.l  #1,A1
                cmpi.b  #'\',-1(A1)
                beq.s   .okhasback
                move.b  #'\',(A1)+
.okhasback:     move.b  #"*",(A1)+
                move.b  #".",(A1)+
                move.b  #"*",(A1)+
                clr.b   (A1)+

                move.w  #$10,-(SP)      ;; subdirectories
                pea     gempath
                move.w  #$4E,-(SP)      ;; search first
                trap    #1
                addq.l  #8,SP
                bra.s   contdirectdir
ddloop1:        bsr     newdirentry
                move.w  #$4F,-(SP)
                trap    #1              ;; search next
                addq.l  #2,SP
contdirectdir:  tst.l   D0
                beq.s   ddloop1
                moveq   #0,D0
donedir:        rts

abortdir:
                clr.l   4(A5)
                lea     dirabortedtext(PC),A0
                jsr     showstatustext
                bsr.s   dirdiskunlock
                bsr     waitalittle
                jsr     showallright
                moveq   #0,D0
                rts

dirdiskunlock:
                bsr     restoreptrcol
                moveq   #0,D0
                rts

dirabortedtext: DC.B 'dir aborted !',0
                EVEN

dirdiskerror:
                tst.l   filelock
                beq.s   ddeskip
                move.l  filelock,D1
                jsr     lvounlock(A6)
ddeskip:        bsr     restoreptrcol
                lea     cantfinddirtext,A0
                jsr     showstatustext
                bsr     seterrorptrcol
                moveq   #-1,D0
                rts

cleardirtotal:
                clr.w   16(A5)
                rts

cantfinddirtext:DC.B "can't find dir !",0,0


newdirentry:
                movea.l dtabuf_ptr,A0
                move.l  26(A0),fib_filesize
                move.l  #-1,fib_entrytype
                btst    #4,21(A0)
                beq.s   .isfile
                move.l  #0,fib_entrytype
.isfile:
                move.w  24(A0),fib_datestamp+ds_days+2

                lea     30(A0),A0
                lea     fib_filename,A1
                REPT 13
                move.b  (A0)+,(A1)+
                ENDR
                clr.b   (A1)+

                lea     fib_filename,A0
                tst.b   showdirsflag
                bne.s   ndeok1
                tst.l   fib_entrytype
                bpl     return1
ndeok1:         tst.l   fib_entrytype
                bpl     ndeok2
                tst.b   modonlyflag
                beq.s   ndeok2
                tst.w   dirpathnum
                bne.s   ndeok2
                pea     (A0)
.finddot:       cmpi.b  #".",(A0)+
                bne.s   .finddot
                cmpi.b  #'M',(A0)
                bne     return4
                cmpi.b  #"O",1(A0)
                bne     return4
                cmpi.b  #"D",2(A0)
                beq.s   fndmod
return4:        movea.l (SP)+,A0
                rts
fndmod:         movea.l (SP)+,A0

ndeok2:
                move.w  16(A5),D0
                cmp.w   direntries,D0
                blo.s   ndeok3
                move.l  A0,-(SP)
                bsr     allocdirmem
                movea.l (SP)+,A0
ndeok3:         move.w  16(A5),D6
                beq.s   ndeadd1         ; If first entry
                subq.w  #1,D6
                movea.l (A5),A1
ndeloopname:
                moveq   #0,D2
                move.l  fib_entrytype,D0
                move.l  32(A1),D1
                tst.l   D0
                bpl.s   ndesfil         ; if directory, all is well
                tst.l   D1
                bmi.s   ndenext         ; was file, so skip if directory
                bra.s   ndelopc
ndesfil:        tst.l   D1              ; if file
                bpl.s   ndeinse
ndelopc:        move.b  0(A0,D2.w),D0   ; Get a character
                beq.s   ndeinse
                cmp.b   #96,D0          ; Lowercase?
                blo.s   ndeskp1
                sub.b   #32,D0          ; Switch to upper
ndeskp1:        move.b  0(A1,D2.w),D1
                beq.s   ndenext
                cmp.b   #96,D1
                blo.s   ndeskp2
                sub.b   #32,D1
ndeskp2:        cmp.b   D0,D1
                bhi.s   ndeinse
                bne.s   ndenext
                addq.w  #1,D2
                bra.s   ndelopc
ndenext:        lea     36(A1),A1       ; next entry
                dbra    D6,ndeloopname  ; loop entries

                movea.l (A5),A1
                move.w  16(A5),D0
                mulu    #36,D0
                adda.w  D0,A1
                bra.s   ndeadd2

ndeinse:        movea.l (A5),A2
                move.w  16(A5),D0
                mulu    #36,D0
                adda.w  D0,A2
                movea.l A2,A3
                lea     36(A3),A3
nde3loop:
                move.w  -(A2),-(A3)
                cmpa.l  A2,A1
                bne.s   nde3loop
                bra.s   ndeadd2

ndeadd1:        movea.l (A5),A1         ; Put new filename into list
ndeadd2:        lea     fib_filename,A0
                movea.l A1,A3
                moveq   #35,D0          ; Clear old filename
nde4loop:
                clr.b   (A3)+
                dbra    D0,nde4loop
                move.w  fib_datestamp+ds_days+2,30(A1)
                moveq   #-1,D0
                tst.l   fib_entrytype
                bpl     ndefskp
                move.l  fib_filesize,D0
ndefskp:        move.l  D0,32(A1)
                moveq   #29,D0          ; Copy new filename
nde4loop2:
                move.b  (A0)+,D1
                move.b  D1,(A1)+
                tst.b   D1
                beq.s   nde4skip
                dbra    D0,nde4loop2
nde4skip:
                addq.w  #1,16(A5)       ; Files + 1
                rts

redrawfilenames:
                move.w  D0,-(SP)
                bsr     showdirpath
                move.w  (SP)+,D0
                move.w  D0,filenamescrollpos
                tst.w   16(A5)
                beq     return1
                movea.l #1881,A6
                move.w  A6,textoffset
                move.l  (A5),D6
                mulu    #36,D0
                add.l   D0,D6
                move.w  16(A5),D0
                sub.w   filenamescrollpos,D0
                cmp.w   #8,D0
                bhs.s   showfilenames
                subq.w  #1,D0
                move.w  D0,D7
                bra.s   sfnloop

showfilenames:
                move.w  #$91,D0
                bsr     waitforvblank
                moveq   #7,D7
sfnloop:        move.w  A6,textoffset
                movea.l D6,A0
                moveq   #0,D0
                move.w  30(A0),D0
                and.w   #%11111,D0
                move.w  D0,theday
                move.w  30(A0),D0
                lsr.w   #5,D0
                and.w   #%1111,D0
                move.w  D0,themonth
                move.w  30(A0),D0
                lsr.w   #8,D0
                lsr.w   #1,D0
                add.w   #80,D0
                move.w  D0,theyear
                move.w  theday(PC),wordnumber
                jsr     print2decdigits
                move.w  themonth(PC),wordnumber
                jsr     print2decdigits
                move.w  theyear(PC),wordnumber
                jsr     print2decdigits
                addq.w  #1,textoffset
                move.l  D6,showtextptr
                move.w  #24,textlength
                tst.w   dirpathnum
                bne.s   sfnskip
                tst.b   modonlyflag
                beq.s   sfnskip
                movea.l D6,A0
                cmpi.l  #"mod.",(A0)
                bne.s   sfnskip
                addq.l  #4,showtextptr
sfnskip:        jsr     spaceshowtext
                lea     32(A6),A6
                move.w  A6,textoffset
                movea.l D6,A0
                move.l  32(A0),D1
                bmi.s   sfndir
                tst.b   showdecflag
                bne.s   sfndec
                swap    D1
                and.w   #$0F,D1
                bsr     showonedigit
                movea.l D6,A0
                move.w  34(A0),wordnumber
                jsr     printhexword
sfnend:         add.l   #36,D6
                lea     208(A6),A6
                dbra    D7,sfnloop
                rts
theday:         DC.W 0
themonth:       DC.W 0
theyear:        DC.W 0

sfndec:         move.l  D1,D0
                subq.w  #1,textoffset
                jsr     print6decdigits
                bra.s   sfnend

sfndir:         move.l  #dirtext,showtextptr
                subq.w  #1,textoffset
                move.w  #6,textlength
                jsr     showtext
                bra.s   sfnend

clrfiletext:    DC.B "    "
                EVEN

dirtext:        DC.B " (DIR)"
                EVEN

;---- DoLoad / DoSave Data ----

doloaddata:
                tst.l   diskdatalength
                beq.s   dlsend
                tst.l   diskdataptr
                beq.s   dlsend
                jsr     setdiskptrcol
                lea     loadingtext,A0
                jsr     showstatustext
                movea.l dosbase,A6
                move.l  filenameptr,D1
                move.l  #1005,D2
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq.s   cantopenfile
                move.l  filehandle,D1
                move.l  diskdataptr,D2
                move.l  diskdatalength,D3
                jsr     lvoread         ;;
                move.l  filehandle,D1
                jsr     lvoclose        ;;
dlsend:         clr.l   filehandle
                jsr     setnormalptrcol
                moveq   #-1,D0
                rts

cantopenfile:
                lea     cantopenfiletext(PC),A0
caopfil:        jsr     showstatustext
                jsr     seterrorptrcol
                moveq   #0,D0
                rts

cantsavefile:
                lea     cantsavefiletext(PC),A0
                bra.s   caopfil
cantexamfile:
                lea     cantexamfiletext(PC),A0
                bra.s   caopfil
cantfindfile:
                lea     cantfindfiletext(PC),A0
                bra.s   caopfil
fileisempty:
                lea     fileisemptytext(PC),A0
                bra.s   caopfil

cantopenfiletext:DC.B "can't open file !",0
cantsavefiletext:DC.B "can't save file !",0
cantexamfiletext:DC.B "examine error !",0
cantfindfiletext:DC.B "can't find file !",0
fileisemptytext:DC.B "file is empty !",0
                EVEN

dosavedata:
                jsr     setdiskptrcol
                lea     savingtext,A0
                jsr     showstatustext
                movea.l dosbase,A6
                move.l  filenameptr,D1
                move.l  #1006,D2
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq     cantopenfile
                move.l  filehandle,D1
                move.l  diskdataptr,D2
                move.l  diskdatalength,D3
                jsr     lvowrite        ;;
                move.l  filehandle,D1
                jsr     lvoclose        ;;
                clr.l   filehandle
                jmp     setnormalptrcol

; Load module!

loadmodule:
                move.w  #1,loadinprogress
                bsr     doclearsong
                bsr     clrsampleinfo
                jsr     setdiskptrcol
                lea     modulespath2,A0
                jsr     copypath
                lea     dirinputname,A0
                moveq   #dirnamelength-1,D0
lmloop2:        move.b  (A0)+,(A1)+
                dbra    D0,lmloop2
                lea     loadingmoduletext,A0
                jsr     showstatustext
                movea.l dosbase,A6
                move.l  #filename,D1
                move.l  #1005,D2
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                bne.s   okopened
                jmp     cantopenfile
okopened:       move.l  D0,D1
                move.l  songdataptr,D2
                move.l  #1084,D3
                jsr     lvoread         ;;
                movea.l songdataptr,A0
                cmpi.l  #'PP20',(A0)
                beq     powerpacked
                move.b  #127,sd_numofpatt+1(A0) ; Set maxpatt to 127
                cmpi.l  #'M.K.',sd_mahokakt(A0) ; M.K. again...
                beq     lmskip
                bsr     mahoneyandkaktus
                bne     lmskip
                move.l  filehandle,D1
                move.l  #600,D2
                moveq   #-1,D3
                jsr     lvoseek
lmskip:         lea     loadingmoduletext,A0
                jsr     showstatustext
                movea.l songdataptr,A0
                lea     sd_pattpos(A0),A0
                moveq   #0,D0
                move.b  -1(A0),D0
                moveq   #0,D3
lmloop3:        cmp.b   (A0)+,D3
                bhi     lmskip2
                move.b  -1(A0),D3
lmskip2:        dbra    D0,lmloop3
                addq.w  #1,D3
                mulu    #1024,D3
                move.l  filehandle,D1
                move.l  songdataptr,D2
                add.l   #1084,D2
                movea.l dosbase,A6
                jsr     lvoread
                clr.l   patternnumber
                clr.l   currpos
                jsr     redrawpattern
                clr.w   scrpattpos
                bsr     setscrpatternpos
                move.w  #1,insnum
                bsr     checkabort
                beq     rmiend
                tst.b   autoexitflag
                beq     readinstrloop
                jsr     exitfromdir
readinstrloop:
                tst.b   nosamplesflag
                bne     rmiend
                bsr     checkabort
                beq     rmiend
                jsr     showsampleinfo
                move.w  insnum,tuneup
                jsr     doshowfreemem
                movea.l songdataptr,A0
                move.w  insnum,D7
                mulu    #30,D7
                moveq   #0,D0
                move.w  12(A0,D7.w),D0
                beq     rminext
                add.l   D0,D0
                movea.l 4.w,A6
                move.l  #memf_chip+memf_clear,D1
                move.l  D0,-(SP)
                jsr     lvoallocmem
                move.l  (SP)+,D6
                tst.l   D0
                bne     readmodinstrument
                bsr     outofmemerr
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  D6,D2
                moveq   #0,D3
                bra     rminext

readmodinstrument:
                move.w  insnum,D7
                lsl.w   #2,D7
                lea     sampleptrs,A0
                move.l  D0,0(A0,D7.w)
                move.l  D6,124(A0,D7.w)
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  D0,D2
                move.l  D6,D3
                jsr     lvoread
                jsr     redrawsample
rminext:        addq.w  #1,insnum
                cmpi.w  #32,insnum
                bne     readinstrloop
rmiend:         move.l  filehandle,D1
                movea.l dosbase,A6
                jsr     lvoclose
                move.w  #1,insnum
                move.l  #6,currspeed
                clr.w   loadinprogress
                jsr     showallright
                jsr     setnormalptrcol
                bsr     checkinstrlengths
                jsr     showsampleinfo
                jsr     redrawsample
                jsr     doshowfreemem
                rts

powerpacked:
                lea     powerpackedtext,A0
                jsr     showstatustext
                jsr     seterrorptrcol
                bsr     doclearsong
                bsr     clrsampleinfo
                bra     rmiend

powerpackedtext:DC.B "Powerpacker mod.!",0

                EVEN

savemodule:
                jsr     storeptrcol
                jsr     setdiskptrcol
                movea.l songdataptr,A0
                lea     sd_pattpos(A0),A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                clr.w   highpattnum
smloop:         move.b  0(A0,D0.w),D1
                addq.w  #1,D0
                cmp.w   #128,D0
                bhi     dosavemodule
                move.w  highpattnum,D2
                cmp.w   D2,D1
                bls     smloop
                move.w  D1,highpattnum
                bra     smloop

dosavemodule:
                lea     modulespath2,A0
                jsr     copypath
                movea.l songdataptr,A0
                moveq   #19,D0
dsmloop2:       move.b  (A0)+,(A1)+
                dbra    D0,dsmloop2
                movea.l songdataptr,A0
                move.l  A0,diskdataptr
                move.l  #1084,diskdatalength
                moveq   #0,D0
                move.w  highpattnum,D0
                addq.l  #1,D0
                lsl.l   #8,D0
                lsl.l   #2,D0
                add.l   D0,diskdatalength ; Add 1024 x NumOfPatt
                move.b  #127,sd_numofpatt+1(A0) ; Set maxpatt to 127
                move.l  #'M.K.',sd_mahokakt(A0) ; M.K. again...
                lea     savingmoduletext,A0
                jsr     showstatustext
                bsr     openmodforwrite
                bne     cantopenfile
                bsr     writemoduledata
                bne     writemoderror
                move.w  insnum,saveinstrnum
                moveq   #1,D6
saveinstrloop:
                move.w  D6,insnum
                jsr     showsampleinfo
                bsr     writeinstrument
                bne     writemoderror
                addq.b  #1,D6
                cmp.b   #32,D6
                bne     saveinstrloop
                bsr     closewritemod
                move.w  saveinstrnum(PC),insnum
                jsr     showsampleinfo
                jsr     showallright
                jmp     restoreptrcol

saveinstrnum:   DC.W 0

writemoderror:
                bsr     closewritemod
                bra     cantsavefile

writeinstrument:
                move.w  D6,D0
                lsl.w   #2,D0
                lea     sampleptrs,A0
                move.l  0(A0,D0.w),D1
                beq     return1
                move.l  124(A0,D0.w),D0
                beq     return1
                move.l  D1,diskdataptr
                movea.l songdataptr,A0
                lea     12(A0),A0
                move.w  D6,D0
                mulu    #30,D0
                adda.l  D0,A0
                moveq   #0,D0
                move.w  (A0),D0
                add.l   D0,D0
                move.l  D0,diskdatalength
                bne     writemoduledata
                rts

openmodforwrite:
                movea.l dosbase,A6
                move.l  #filename,D1
                move.l  #1006,D2
                jsr     lvoopen         ;;
                move.l  D0,D7
                beq     wmfailed
                moveq   #0,D0
                rts

writemoduledata:
                movea.l dosbase,A6
                move.l  D7,D1
                move.l  diskdataptr,D2
                move.l  diskdatalength,D3
                jsr     lvowrite        ;;
                tst.l   D0
                beq     wmfailed
                moveq   #0,D0
                rts

wmfailed:
                moveq   #-1,D0
                rts

closewritemod:
                movea.l dosbase,A6
                move.l  D7,D1
                jmp     lvoclose        ;;

;---- Save Song ----

savesong:
                bsr     stopit
                clr.b   rawkeycode
                movea.l songdataptr,A0
                lea     samplelengthadd(PC),A1
                moveq   #0,D0
                moveq   #2,D1
sadloop:        move.w  0(A1,D1.w),D2
                add.w   D2,42(A0,D0.w)
                add.w   #30,D0
                addq.w  #2,D1
                cmp.w   #62,D1
                bne     sadloop

                lea     sd_pattpos(A0),A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                clr.w   highpattnum
ssloop:         move.b  0(A0,D0.w),D1
                addq.w  #1,D0
                cmp.w   #128,D0
                bhi     dosavesong
                move.w  highpattnum,D2
                cmp.w   D2,D1
                bls     ssloop
                move.w  D1,highpattnum
                bra     ssloop

dosavesong:
                lea     songspath2,A0
                jsr     copypath
                movea.l songdataptr,A0
                moveq   #19,D0
dssloop:        move.b  (A0)+,(A1)+
                dbra    D0,dssloop
                move.l  #filename,filenameptr
                move.l  songdataptr,diskdataptr
                move.l  #1084,diskdatalength
                moveq   #0,D0
                move.w  highpattnum,D0
                addq.l  #1,D0
                lsl.l   #8,D0
                lsl.l   #2,D0
                add.l   D0,diskdatalength
                move.b  packmode,D0
                btst    #0,D0
                beq     dssnocr
                lea     crunchingtext,A0
                bsr     showstatustext
                bsr     cruncher
dssnocr:        jsr     dosavedata
                move.b  packmode,D0
                btst    #0,D0
                beq     dssnoc2
                lea     decrunchingtext,A0
                bsr     showstatustext
                bsr     decruncher
dssnoc2:        movea.l songdataptr,A0
                lea     samplelengthadd(PC),A1
                moveq   #0,D0
                moveq   #2,D1
ssuloop:        move.w  0(A1,D1.w),D2
                sub.w   D2,42(A0,D0.w)
                add.w   #30,D0
                add.w   #2,D1
                cmp.w   #62,D1
                bne     ssuloop
                bsr     showallright
                bra     setnormalptrcol

cruncher:
                bsr     setnormalptrcol
                movea.l songdataptr,A0
                movea.l A0,A1
                lea     12(A1),A1
                move.l  A1,songplus12ptr
                movea.l A0,A1
                adda.l  #70716,A1       ; hoeh...
                move.l  A1,songplus70kptr
                movea.l A0,A1
                adda.l  #70716,A1
                suba.l  diskdatalength,A1
                move.l  A1,endofsongptr
                move.l  diskdatalength,realsonglength
                movea.l songdataptr,A0
                adda.l  diskdatalength,A0
                movea.l songdataptr,A1
                adda.l  #70716,A1
                move.l  diskdatalength,D0
cloop:          move.b  -(A0),-(A1)
                subq.l  #1,D0
                bne     cloop
                bsr     docrunch
                suba.l  songplus12ptr(PC),A2
                move.l  A2,D0
                move.l  D0,crunchedsonglength
                move.l  D0,D1
                add.l   songplus12ptr(PC),D1
                move.l  D1,dontknowwhat
                movea.l songdataptr,A0
                move.l  #'PACK',(A0)
                move.l  crunchedsonglength,4(A0)
                move.l  realsonglength(PC),8(A0)
                move.l  songdataptr,diskdataptr
                move.l  crunchedsonglength(PC),D0
                add.l   #12,D0
                move.l  D0,diskdatalength
                rts

endofsongptr:   DC.L 0
songplus70kptr: DC.L 0
realsonglength: DC.L 0
songplus12ptr:  DC.L 0
dontknowwhat:   DC.L 0
crunchedsonglength:DC.L 0

docrunch:
                movea.l endofsongptr(PC),A0
                movea.l songplus70kptr(PC),A1
                movea.l songplus12ptr(PC),A2
                moveq   #1,D2
                clr.w   D1
dcloop:         bsr     docrunch2
                tst.b   D0
                beq     dcskip
                addq.w  #1,D1
                cmp.w   #$0108,D1
                bne     dcskip
                bsr     docrunch6
dcskip:         cmpa.l  A0,A1
                bgt     dcloop
                bsr     docrunch6
                bra     docrunch8

docrunch2:
                movea.l A0,A3
                lea     127(A3),A3
                cmpa.l  A1,A3
                ble     dc2skip
                movea.l A1,A3
dc2skip:        moveq   #1,D5
                movea.l A0,A5
                addq.l  #1,A5
dc2_1:          move.b  (A0),D3
                move.b  1(A0),D4
;                move.w  D3,$FFFF8240.w
dc2loop:        cmp.b   (A5)+,D3
                bne     dc2skip2
                cmp.b   (A5),D4
                beq     docrunch3
dc2skip2:
                cmpa.l  A5,A3
                bgt     dc2loop
                bra     dc4_3

docrunch3:
                subq.l  #1,A5
                movea.l A0,A4
dc3loop:        move.b  (A4)+,D3
                cmp.b   (A5)+,D3
                bne     dc3skip
                cmpa.l  A5,A3
                bgt     dc3loop
dc3skip:        move.l  A4,D3
                sub.l   A0,D3
                subq.l  #1,D3
                cmp.l   D3,D5
                bge     dc4_2
                move.l  A5,D4
                sub.l   A0,D4
                sub.l   D3,D4
                subq.l  #1,D4
                cmp.l   #4,D3
                ble     docrunch4
                moveq   #6,D6
                cmp.l   #$0101,D3
                blt     dc3skip2
                move.w  #$0100,D3
dc3skip2:
                bra     dc4_1

docrunch4:
                move.w  D3,D6
                subq.w  #2,D6
                add.w   D6,D6
dc4_1:          lea     crunchdata3(PC),A6
                cmp.w   0(A6,D6.w),D4
                bge     dc4_2
                move.l  D3,D5
                move.l  D4,crunchdata1
                move.b  D6,crunchdata2
dc4_2:          cmpa.l  A5,A3
                bgt     dc2_1
dc4_3:          cmp.l   #1,D5
                beq     docrunch5
                bsr     docrunch6
                move.b  crunchdata2(PC),D6
                move.l  crunchdata1(PC),D3
                move.w  8(A6,D6.w),D0
                bsr     docrunch7
                move.w  $10(A6,D6.w),D0
                beq     dc4skip
                move.l  D5,D3
                subq.w  #1,D3
                bsr     docrunch7
dc4skip:        move.w  $18(A6,D6.w),D0
                move.w  $20(A6,D6.w),D3
                bsr     docrunch7
                addq.w  #1,$28(A6,D6.w)
                adda.l  D5,A0
                clr.b   D0
                rts

docrunch5:
                move.b  (A0)+,D3
                moveq   #8,D0
                bsr     docrunch7
                moveq   #1,D0
                rts

crunchdata1:    DC.L 0
crunchdata2:    DC.B 0,0
crunchdata3:    DC.W $0100,$0200,$0400,$1000,8,9,10,8
                DC.W 0,0,0,8,2,3,3,3,1,4,5,6,0,0,0,0
crunchdata4:    DC.W 0
crunchdata5:    DC.W 0

docrunch6:
                tst.w   D1
                beq     return1
                move.w  D1,D3
                clr.w   D1
                cmp.w   #9,D3
                bge     dc6_2
                addq.w  #1,crunchdata4
                subq.w  #1,D3
                moveq   #5,D0
                bra     docrunch7

dc6_2:          addq.w  #1,crunchdata5
                sub.w   #9,D3
                or.w    #$0700,D3
                moveq   #11,D0
docrunch7:
                subq.w  #1,D0
dc7loop:        lsr.l   #1,D3
                addx.l  D2,D2
                bcs     dc8_2
                dbra    D0,dc7loop
                rts

docrunch8:
                clr.w   D0
dc8_2:          move.l  D2,(A2)+
                moveq   #1,D2
                dbra    D0,dc7loop
                rts


decruncher:
                movea.l songdataptr,A0
                lea     12(A0),A0
                movea.l endofsongptr(PC),A1
                move.l  crunchedsonglength(PC),D0
                move.l  realsonglength(PC),D1
                bsr     dodecrunch
                movea.l endofsongptr(PC),A0
                movea.l songdataptr,A1
                move.l  realsonglength(PC),D0
ddcloop:        move.b  (A0)+,(A1)+
                subq.l  #1,D0
                bne     ddcloop
                movea.l songdataptr,A0
                adda.l  #$01143C,A0
                movea.l songdataptr,A1
                adda.l  realsonglength(PC),A1
                suba.l  A1,A0
                move.l  A0,D0
ddcloop2:
                clr.b   (A1)+
                subq.l  #1,D0
                bne     ddcloop2
                rts

dodecrunch:
                adda.l  D0,A0
                movea.l D1,A2
                adda.l  A1,A2
                move.l  -(A0),D0
dec_1:          lsr.l   #1,D0
                bne.s   decskip
                bsr.s   dec5
decskip:        bcs.s   dec3
                moveq   #8,D1
                moveq   #1,D3
                lsr.l   #1,D0
                bne.s   decskip2
                bsr.s   dec5
decskip2:
                bcs.s   dec4_1
                moveq   #3,D1
                clr.w   D4
dec_2:          bsr.s   dec6
                move.w  D2,D3
                add.w   D4,D3
decloop1:
                moveq   #7,D1
decloop2:
                lsr.l   #1,D0
                bne.s   decskip3
                bsr.s   dec5
decskip3:
                addx.l  D2,D2
                dbra    D1,decloop2
                move.b  D2,-(A2)
                dbra    D3,decloop1
                bra.s   dec4_3

dec2:           moveq   #8,D1
                moveq   #8,D4
                bra.s   dec_2

dec3:           moveq   #2,D1
                bsr.s   dec6
                cmp.b   #2,D2
                blt.s   dec4
                cmp.b   #3,D2
                beq.s   dec2
                moveq   #8,D1
                bsr.s   dec6
                move.w  D2,D3
                move.w  #8,D1
                bra.s   dec4_1

dec4:           move.w  #9,D1
                add.w   D2,D1
                addq.w  #2,D2
                move.w  D2,D3
dec4_1:         bsr.s   dec6
dec4_2:         subq.w  #1,A2
                move.b  0(A2,D2.w),(A2)
                dbra    D3,dec4_2
dec4_3:         cmpa.l  A2,A1
                blt.s   dec_1
                rts

dec5:           move.l  -(A0),D0
                move.w  D0,$FFFF8240.w
                move    #$10,CCR
                roxr.l  #1,D0
                rts

dec6:           subq.w  #1,D1
                clr.w   D2
dec6loop:
                lsr.l   #1,D0
                bne.s   dec6skip
                move.l  -(A0),D0
                move.w  D0,$FFFF8240.w
                move    #$10,CCR
                roxr.l  #1,D0
dec6skip:
                addx.l  D2,D2
                dbra    D1,dec6loop
                rts

loadsample:
                tst.w   insnum
                beq     notsamplenull
                bsr     storeptrcol
                lea     samplepath2,A0
                bsr     copypath
                lea     dirinputname,A0
                moveq   #dirnamelength-1,D0
lsloop:         move.b  (A0)+,(A1)+
                dbra    D0,lsloop
                movea.l songdataptr,A0
                move.w  insnum,D0
                mulu    #30,D0
                lea     -10(A0),A0
                adda.l  D0,A0
                lea     dirinputname,A1
                moveq   #21,D0
lsloop2:        move.b  (A1)+,(A0)+
                dbra    D0,lsloop2
                bsr     setdiskptrcol
                move.l  #filename,D1
                bsr     examineandalloc
                beq     errorrestorecol
                move.l  #filename,D1
                bra     lnssec2

checkforiff2:                           ; load loop
                moveq   #-1,D2
                bra.s   ciff2
checkforiff:
                moveq   #0,D2
ciff2:          moveq   #0,D1
                cmpi.l  #'FORM',(A0)
                bne.s   wiskip
                cmpi.l  #'8SVX',8(A0)
                bne.s   wiskip
                movea.l A0,A2
                move.l  A1,D0
                adda.l  A0,A1
                tst.l   D2
                beq.s   cfiloop
                bsr.s   checkiffloop
cfiloop:        cmpi.l  #'BODY',(A0)
                beq.s   wasiff
                addq.l  #2,A0
                cmpa.l  A1,A0
                bls.s   cfiloop
                rts

wasiff:         addq.l  #8,A0
                add.l   A2,D0
                sub.l   A0,D0
wiloop:         move.b  (A0)+,(A2)+
                cmpa.l  A1,A0
                bls.s   wiloop
                movea.l sampleinstrsave(PC),A3
                lsr.w   #1,D0
                move.w  22(A3),D1
                sub.w   D0,D1
                move.w  D0,22(A3)
wiskip:         lea     samplelengthadd(PC),A3
                move.w  insnum,D0
                add.w   D0,D0
                move.w  D1,0(A3,D0.w)
                rts

checkiffloop:
                tst.b   iffloopflag
                beq     return1
                movem.l D0/A0,-(SP)
cilloop:        cmpi.l  #'VHDR',(A0)
                beq.s   wasvhdr
                addq.l  #2,A0
                cmpa.l  A1,A0
                bls.s   cilloop
cilend:         movem.l (SP)+,D0/A0
                rts

wasvhdr:        movea.l sampleinstrsave(PC),A3
                move.l  12(A0),D0
                beq.s   cilend
                lsr.w   #1,D0
                move.w  D0,28(A3)
                move.l  8(A0),D0
                bne.s   wsvhdr2
                moveq   #2,D0
wsvhdr2:        lsr.w   #1,D0
                move.w  D0,26(A3)
                bra.s   cilend


sampleinstrsave:DC.L 0
samplelengthadd:DCB.W 32

examineandalloc:
                clr.w   -(SP)
                move.l  D1,-(SP)
                move.w  #$4E,-(SP)
                trap    #1
                addq.l  #8,SP
                movea.l dtabuf_ptr,A0
                move.l  26(A0),fib_filesize
                move.l  fib_filesize,D0
                beq     fileisempty
                bsr     turnoffvoices
                bsr     freesample
                move.l  fib_filesize,D0
                cmp.l   #$FFFE,D0
                bls.s   exalloc
                move.l  #$FFFE,D0
exalloc:        lea     sampleptrs,A4
                move.w  insnum,D1
                lsl.w   #2,D1
                adda.w  D1,A4
                move.l  D0,124(A4)
                move.l  D0,diskdatalength
                movea.l 4.w,A6
                move.l  #memf_chip+memf_clear,D1
                jsr     lvoallocmem
                move.l  D0,diskdataptr
                move.l  D0,(A4)
                beq     outofmemerr
                lea     loadingsampletext,A0
                bsr     showstatustext
                movea.l songdataptr,A0
                move.w  insnum,D0
                mulu    #30,D0
                lea     -10(A0),A0
                adda.l  D0,A0
                move.l  A0,sampleinstrsave
                move.l  diskdatalength,D0
                lsr.l   #1,D0
                move.w  D0,22(A0)
                move.l  #$400000,24(A0)
                move.w  #1,28(A0)
                bsr     showsampleinfo
                moveq   #-1,D0
                rts

loadnamedsample:
                tst.w   insnum
                beq     notsamplenull
                bsr     storeptrcol
                bsr     createsamplename
                bsr     setdiskptrcol
                move.l  filenameptr,D1
                bsr     examineandalloc
                beq     return1
                move.l  filenameptr,D1
lnssec2:        movea.l dosbase,A6
                move.l  #1005,D2
                jsr     lvoopen         ;;
                move.l  D0,D7
                beq     cantopenfile
                move.l  D0,D1
                move.l  diskdataptr,D2
                move.l  diskdatalength,D3
                jsr     lvoread         ;;
                move.l  D7,D1
                jsr     lvoclose        ;;
                movea.l diskdataptr,A0
                movea.l diskdatalength,A1
                bsr     checkforiff2
                bsr     validateloops
                bsr     showsampleinfo
                movea.l diskdataptr,A0
                clr.w   (A0)
                jsr     redrawsample
                bsr     showallright
                bra     restoreptrcol

createsamplename:
                lea     samplefilename,A0
                moveq   #27,D0
csnloop:        clr.b   (A0)+
                dbra    D0,csnloop
                movea.l songdataptr,A0
                move.w  insnum,D0
                mulu    #30,D0
                lea     -10(A0),A0
                adda.l  D0,A0
                move.l  A0,sampleinstrsave
                moveq   #0,D0
                move.w  22(A0),D0
                add.l   D0,D0
                move.l  D0,diskdatalength
                move.l  D0,iffbody+4
                add.l   #iffend-iffform-8,D0
                move.l  D0,iffform+4

                moveq   #0,D0
                move.w  22(A0),D0
                add.l   D0,D0
                moveq   #0,D1
                move.w  28(A0),D1
                cmp.w   #1,D1
                bls.s   csnskp2
                add.l   D1,D1
                moveq   #0,D0
                move.w  26(A0),D0
                add.l   D0,D0
                bra.s   csnskp3
csnskp2:        moveq   #0,D1
csnskp3:        move.l  D0,iffvhdr+8
                move.l  D1,iffvhdr+12

                lea     samplefilename,A1
                lea     iffname+8,A2
                moveq   #21,D0
csnloop2:
                move.b  (A0),(A1)+
                move.b  (A0)+,(A2)+
                dbra    D0,csnloop2
                move.l  #samplefilename,D1
                move.l  D1,filenameptr
                bsr.s   findcolon
                beq.s   checkoverride
                lea     samplepath2,A0
                bsr     copypath
                movea.l #samplefilename,A0
csnloop3:
                move.b  (A0)+,(A1)+
                bne.s   csnloop3
                move.l  #filename,filenameptr
                rts

findcolon:
                movea.l D1,A0
fcloop:         move.b  (A0)+,D0
                beq.s   findcolonfail
                cmp.b   #':',D0
                beq.s   findcolonsuccess
                bra.s   fcloop

findcolonfail:
                moveq   #-1,D0
                rts

findcolonsuccess:
                moveq   #0,D0
                rts

checkoverride:
                tst.b   overrideflag
                beq     return1
                movea.l #samplefilename,A0
                movea.l A0,A1
                lea     21(A1),A1
                movea.l A1,A2
chkovlp:        move.b  -(A1),D0
                cmp.b   #':',D0
                beq.s   chkovok
                cmp.b   #'/',D0
                beq.s   chkovok
                movea.l A1,A2
                cmpa.l  A0,A1
                bhi.s   chkovlp
chkovok:        lea     samplepath2,A0
                bsr     copypath
chkovl2:        move.b  (A2)+,(A1)+
                bne.s   chkovl2
                move.l  #filename,filenameptr
                rts

validateloops:
                movea.l songdataptr,A0
                lea     20(A0),A0
                moveq   #30,D0
valolop:        move.w  22(A0),D1
                move.w  26(A0),D2
                move.w  28(A0),D3
                cmp.w   D1,D2
                bhs.s   valosk1
                add.w   D2,D3
                cmp.w   D1,D3
                bhi.s   valosk2
valoque:        tst.w   28(A0)
                bne.s   valosk3
                move.w  #1,28(A0)
valosk3:        lea     30(A0),A0
                dbra    D0,valolop
                rts
valosk2:        sub.w   D2,D1
                move.w  D1,28(A0)
                bra.s   valoque
valosk1:        moveq   #1,D1
                move.l  D1,26(A0)
                bra.s   valoque

loadpreset:
                clr.b   rawkeycode
                tst.w   insnum
                beq     notsamplenull
                bsr     turnoffvoices
                bsr     freesample
                bsr     createsamplename
                movea.l filenameptr,A0
                tst.b   (A0)
                beq     return1
                move.l  diskdatalength,D0
                beq     return1
                move.l  diskdatalength,D0
                bsr     allocsample
                move.l  diskdataptr,D0
                beq.s   loprerr
                bsr     showsampleinfo
                bsr     doloaddata
                bsr     showallright
                movea.l diskdataptr,A0
                movea.l diskdatalength,A1
                bsr     checkforiff
                bsr     validateloops
                bsr     showsampleinfo
                movea.l diskdataptr,A0
                clr.w   (A0)
                jsr     redrawsample
                move.w  #1,updatefreemem
                rts

loprerr:        bsr     storeptrcol
                bsr     outofmemerr
                bsr     restoreptrcol
                jmp     redrawsample

allocsample:
                move.l  D0,-(SP)
                move.l  #memf_chip+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,diskdataptr
                lea     sampleptrs,A0
                move.w  insnum,D1
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0
                move.l  diskdataptr,(A0)
                move.l  (SP)+,124(A0)
                rts

freesample:
                lea     sampleptrs,A0
                move.w  insnum,D0
                beq     return1
                lsl.w   #2,D0
                lea     0(A0,D0.w),A0
                move.l  (A0),D1
                beq     return1
                clr.l   (A0)
                move.l  124(A0),D0
                clr.l   124(A0)
                movea.l D1,A1
                movea.l 4.w,A6
                jsr     lvofreemem
                rts

notsamplenull:
                lea     notsample0text(PC),A0
                bsr     showstatustext
                bra     seterrorptrcol

notsample0text: DC.B 'not sample 0 !',0,0

;----

deletesong:
                lea     deletesongtext,A0
                bsr     areyousure
                bne     return1
                lea     deletingsongtext,A0
                bsr     showstatustext
                lea     songspath2,A0
                bsr     copypath
                lea     dirinputname,A0
                moveq   #dirnamelength-1,D0
dsloop:         move.b  (A0)+,(A1)+
                dbra    D0,dsloop
                move.w  #1,action
delete3:        move.l  #filename,filenameptr
                movea.l dosbase,A6
                move.l  filenameptr,D1
                movea.l D1,A0
                jsr     lvodeletefile(A6)
                bsr     clearfilenames
                bsr     showallright
                bsr     setnormalptrcol
                bsr     storeptrcol
                bra     doautodir

deletemodule:
                lea     deletemoduletext,A0
                bsr     areyousure
                bne     return1
                lea     deletingmoduletext,A0
                bsr     showstatustext
                lea     modulespath2,A0
                bsr     copypath
                lea     dirinputname,A0
                moveq   #dirnamelength-1,D0
dmdloop:        move.b  (A0)+,(A1)+
                dbra    D0,dmdloop
                move.w  #3,action
                bra.s   delete3

deletesample:
                lea     deletesampletext,A0
                bsr     areyousure
                bne     return1
                lea     deletingsampletext,A0
                bsr     showstatustext
                lea     samplepath2,A0
                bsr     copypath
                lea     dirinputname,A0
                moveq   #dirnamelength-1,D0
dsaloop:        move.b  (A0)+,(A1)+
                dbra    D0,dsaloop
                move.w  #5,action
                bra     delete3

renamefile:
                lea     renamingfiletext,A0
                bsr     showstatustext
                lea     dirinputname,A0
                lea     newinputname,A1
                moveq   #23,D0
rnfloop:        move.b  (A0)+,(A1)+
                bne.s   rnfskip
                subq.l  #1,A0
rnfskip:        dbra    D0,rnfloop
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     newinputname,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #23,textendptr
                move.w  #24,textlength
                move.w  filenamescrollpos+2,D0
                mulu    #240,D0
                movea.w #1888,A4
                adda.w  D0,A4
                bsr     gettextline
                tst.b   newinputname
                beq.s   rnfend
                cmpi.b  #69,mixchar
                beq.s   rnfend

                movea.l pathptr,A0
                bsr     copypath
                lea     newinputname,A0
                moveq   #23,D0
rnfloop2:
                move.b  (A0)+,(A1)+
                dbra    D0,rnfloop2

                lea     filename,A0
                lea     newfilename,A1
rnfloop3:
                move.b  (A0)+,(A1)+
                bne.s   rnfloop3

                movea.l pathptr,A0
                bsr     copypath
                lea     dirinputname,A0
                moveq   #dirnamelength-1,D0
rnfloop4:
                move.b  (A0)+,(A1)+
                dbra    D0,rnfloop4

                move.l  #filename,D1
                move.l  #newfilename,D2
                movea.l dosbase,A6
                jsr     lvorename(A6)

rnfend:         bsr     clearfilenames
                clr.w   action
                bsr     restoreptrcol
                bra     showallright

loadsong:
                move.w  #1,loadinprogress
                bsr     doclearsong
                bsr     clrsampleinfo
                lea     songspath2,A0
                bsr     copypath
                lea     dirinputname,A0
                moveq   #dirnamelength-1,D0
losoloop2:
                move.b  (A0)+,(A1)+
                dbra    D0,losoloop2
                move.l  songdataptr,diskdataptr
                move.l  #filename,filenameptr
                move.l  #70716,diskdatalength
                lea     loadingsongtext,A0
                bsr     showstatustext
                bsr     doloaddata
                beq     lososkip3
                movea.l songdataptr,A0
                cmpi.l  #'PACK',(A0)
                bne.s   lososkip
                move.l  4(A0),crunchedsonglength
                move.l  8(A0),realsonglength
                move.l  songdataptr,D0
                add.l   #70716,D0
                sub.l   realsonglength(PC),D0
                move.l  D0,endofsongptr
                lea     decrunchingtext,A0
                bsr     showstatustext
                bsr     decruncher
                bsr     showallright
lososkip:
                movea.l songdataptr,A0
                cmpi.l  #'M.K.',sd_mahokakt(A0) ;  M.K. again...
                beq.s   lososkip2
                bsr     mahoneyandkaktus ; Was 16 instr, so move up...
lososkip2:
                lea     loadingsongtext,A0
                bsr     showstatustext
                bsr     checkabort
                beq.s   lososkip3
                tst.b   autoexitflag
                beq.s   nosongautoexit
                bsr     exitfromdir
nosongautoexit:
                clr.l   patternnumber
                clr.l   currpos
                bsr     redrawpattern
                clr.w   scrpattpos
                bsr     setscrpatternpos
                bsr     sortdisks
                lea     samplesortlist,A0
                moveq   #30,D0
losoloop3:
                tst.b   nosamplesflag
                bne.s   lososkip3
                bsr     checkabort
                beq.s   lososkip3
                move.w  insnum,tuneup
                bsr     doshowfreemem
                move.l  (A0)+,D1
                move.w  D1,insnum
                movem.l D0-D1/A0,-(SP)
                bsr     loadpreset
                bsr     showsampleinfo
                movem.l (SP)+,D0-D1/A0
                dbra    D0,losoloop3
lososkip3:
                move.w  #1,insnum
                move.l  #6,currspeed
                clr.w   loadinprogress
                bsr     showallright
                bsr     setnormalptrcol
                bsr     doshowfreemem
                bsr     checkinstrlengths
                bsr     showsampleinfo
                jmp     redrawsample

sortdisks:
                movem.l D0-D4/A0-A1,-(SP)
                movea.l songdataptr,A0
                lea     23(A0),A0
                lea     samplesortlist,A1
                moveq   #1,D0
losoloop4:
                move.b  (A0)+,(A1)+     ; ST-(0)1
                move.b  (A0),(A1)+      ; ST-0(1)
                move.w  D0,(A1)+        ; insnum
                lea     29(A0),A0
                addq.l  #1,D0
                cmp.l   #32,D0
                blo.s   losoloop4
losoloop5:
                clr.w   moreinstrflag
                lea     samplesortlist,A0
                moveq   #29,D2
losoloop6:
                move.w  (A0),D0
                move.w  4(A0),D1
                cmp.w   D0,D1           ; if next disk greater
                bhs.s   loso2_2
                move.w  #1,moreinstrflag
                move.l  (A0),D3         ; swap disks
                move.l  4(A0),D4
                move.l  D4,(A0)
                move.l  D3,4(A0)
loso2_2:        addq.l  #4,A0
                dbra    D2,losoloop6
                tst.w   moreinstrflag
                bne.s   losoloop5
                lea     samplesortlist,A0
                moveq   #30,D0
losoloop7:
                clr.w   (A0)
                addq.l  #4,A0
                dbra    D0,losoloop7
                movem.l (SP)+,D0-D4/A0-A1
                rts

mahoneyandkaktus:
                lea     loadas31text(PC),A0
                bsr     areyousure
                beq.s   putmk
                movea.l songdataptr,A0  ; M.K. 32 samples format!
                lea     466(A0),A1
                adda.l  #66006,A0
makloop:        move.l  (A0),484(A0)
                clr.l   (A0)
                subq.l  #4,A0
                cmpa.l  A0,A1
                bne.s   makloop
                movea.l songdataptr,A0
                lea     sd_mahokakt(A0),A1
                lea     sd_numofpatt(A0),A0
makloop2:
                move.w  4(A0),(A0)+
                cmpa.l  A0,A1
                bne.s   makloop2
                move.l  #'M.K.',(A0)    ; M.K. again!
                moveq   #0,D0
                rts

putmk:          movea.l songdataptr,A0
                move.l  #'M.K.',sd_mahokakt(A0) ;  put M.K.
                moveq   #-1,D0
                rts

loadas31text:   DC.B "Load as 31 instr?",0
                EVEN

checkinstrlengths:
                movea.l songdataptr,A0
                adda.l  #20,A0
                moveq   #30,D1
xilloop:        move.w  26(A0),D0
                add.w   28(A0),D0
                cmp.w   22(A0),D0
                bls.s   xilskip
                move.w  26(A0),D0
                lsr.w   #1,D0
                move.w  D0,26(A0)
xilskip:        adda.l  #30,A0
                dbra    D1,xilloop
                rts

checkabort:
                btst    #0,mousebut
                beq     notabort
;               btst    #2,$DFF016
;               bne     return2
                movem.l D0-A6,-(SP)
                lea     abortloadtext,A0
                bsr     areyousure
                bne.s   chabno
                movem.l (SP)+,D0-A6
                moveq   #0,D7
                rts
notabort:       moveq   #-1,D7
                rts

chabno:         movem.l (SP)+,D0-A6
                moveq   #-1,D7
                rts

                ENDPART


;---- Play Song ----

playsong:
                moveq   #0,D0
songfrom:
                bsr     stopit
;                btst    #2,$DFF016
;                bne.s   sofr1
                btst    #0,mousebut
                beq.s   sofr1

                move.w  playfrompos,D0
sofr1:          move.w  D0,scrpattpos
                lsl.w   #4,D0
                and.l   #$FFFF,D0
                move.l  D0,patternposition
wfbu1:
;       BTST    #6,$BFE001
;       BEQ.S   wfbu1
                btst    #2,mousebut
                bne.s   wfbu1

                clr.b   rawkeycode
                clr.b   savekey
                bsr     setplayptrcol
                clr.w   patternticks
                clr.l   timerticks
                move.l  #'patp',runmode
                clr.w   didquantize
                move.l  #-1,longffff
                bsr     setscrpatternpos
setplayposition:
                move.l  currpos,D0
                movea.l songdataptr,A0
                cmp.b   sd_numofpatt(A0),D0
                bhs.s   songpostozero
                move.l  currpos,songposition
                rts

songpostozero:
                clr.l   songposition
                clr.l   currpos
                rts

;---- Play Pattern ----

playpattern:
                moveq   #0,D0
pattfrom:
                bsr     stopit
;                btst    #2,$DFF016
;                bne.s   pafr1
                btst    #0,mousebut
                beq.s   pafr1

                move.w  playfrompos,D0
pafr1:          move.w  D0,scrpattpos
                lsl.w   #4,D0
                and.l   #$0FFF,D0
                move.l  D0,patternposition
wfbu2:
;       BTST    #6,$BFE001
;       BEQ.S   wfbu2
                btst    #2,mousebut
                bne.s   wfbu2

                clr.b   rawkeycode
                clr.b   savekey
                move.l  #'patt',runmode
                bsr     setplayptrcol
resetposition:
                move.l  patternnumber,songposition
                rts

;---- Record Pattern/Song ----

recordpattern:
                moveq   #0,D0
recordfrom:
                tst.w   samscrenable
                bne     return1
                bsr     stopit
                btst    #0,mousebut
                beq.s   refr1

                move.w  playfrompos,D0
refr1:          move.w  D0,scrpattpos
                lsl.w   #4,D0
                and.l   #$0FFF,D0
                move.l  D0,patternposition
wfbu3:
                btst    #2,mousebut
                bne.s   wfbu3

                bsr     seteditptrcol
                clr.b   rawkeycode
                clr.b   savekey
                bsr     saveundo
                move.l  #'edit',editmode
                move.l  #'patt',runmode
                tst.b   recordmode
                beq.s   resetposition
                move.l  #'patp',runmode
                bra     setplayposition

;---- Show Main Screen ----

displaymainscreen:
                clr.w   blockmarkflag
                move.w  #1,currscreen
                sf      nosampleinfo
                tst.w   loadinprogress
                bne.s   dmsskp3
                bsr     setnormalptrcol
                tst.w   runmode
                beq.s   dmsskip
                bsr     setplayptrcol
dmsskip:        tst.l   editmode
                beq.s   dmsskp2
                bsr     seteditptrcol
dmsskp2:        bsr     storeptrcol
dmsskp3:        st      disableanalyzer
                bsr     clearanaheights
                bsr     clearrightarea

                bsr     redrawtoggles
                tst.b   edenable
                bne     editop
                moveq   #0,D4
redrawanascope:
                bsr     waitforvblank
                sf      scopeenable
                st      disableanalyzer
                bsr     clearrightarea
                lea     spectrumanadata,A0
                move.l  #spectrumanasize,D0
                tst.b   anascopflag
                beq.s   cgjojo
                lea     scopedata,A0
                move.l  #scopesize,D0

cgjojo:         bsr     decompact
                beq     cgjaja

                bsr     drawspec_or_scope ;; draw spectrum ana or quadscope

                bsr     freedecompmem
cgjaja:
                tst.l   D4
                bne     return1
                tst.b   anascopflag
                bne     cgscope
                bsr     clearanaheights
                bsr     clearrightarea
                sf      disableanalyzer
                bra     setanalyzercolors
cgscope:        st      scopeenable
                bra     clearanalyzercolors

                PART 'clear areas'

;---- Clear Areas ----

clearfilenames: move.w  #145,D0
                bsr     waitforvblank
                movea.l log_base(PC),A1
                lea     (45*320)+4(A1),A1
                move.w  #274,D0
                moveq   #0,D1
cfnloop:        move.w  D1,(A1)
                move.w  D1,16(A1)
                move.w  D1,32(A1)
                move.w  D1,48(A1)
                lea     64(A1),A1
                dbra    D0,cfnloop
                rts

clearrightarea:
                movea.l log_base(PC),A0
                lea     320+(7*16)+4(A0),A0
                moveq   #0,D2
                moveq   #98,D0
cnblloop1:
i               SET 1
                move.b  D2,i(A0)
                move.b  D2,i+2(A0)
i               SET i+15
                REPT 12
                move.l  D2,i(A0)
i               SET i+16
                ENDR
                lea     320(A0),A0
                dbra    D0,cnblloop1
                rts

clear100lines:
                movea.l log_base(PC),A0
                moveq   #99,D0
                moveq   #0,D1
chlloop:
i               SET 4
                REPT 20
                move.l  D1,i(A0)
i               SET i+16
                ENDR
                lea     320(A0),A0
                dbra    D0,chlloop
                rts

                ENDPART

                PART 'are you sure requester'

;---- Are You Sure Requester ----

areyousure:
                move.b  disableanalyzer,saveda
                move.b  scopeenable,savescope
                sf      scopeenable
                jsr     showstatustext
                bsr     storeptrcol
                bsr     setwaitptrcol
                bsr     wait_4000
                cmpi.w  #1,currscreen
                bne.s   aysskip
                tst.b   disableanalyzer
                bne.s   aysskip
                st      disableanalyzer
                bsr     clearanaheights
                bsr     clearrightarea
aysskip:        lea     sureboxdata,A1
                bsr     swapboxmem
                bsr     waitforbuttonup
                bsr     wait_4000
                clr.b   rawkeycode
surebuttoncheck:
                btst    #0,mousebut
                bne.s   sureanswerno

                bsr     dokeybuffer
                move.b  rawkeycode,D0
                cmp.b   #21,D0          ; Pressed Y
                beq     sureansweryes
                cmp.b   #68,D0          ; Pressed Return
                beq     sureansweryes
                cmp.b   #54,D0          ; Pressed N
                beq     sureanswerno
                cmp.b   #69,D0          ; Pressed Esc
                beq     sureanswerno

                btst    #2,mousebut
                beq.s   surebuttoncheck
                movem.w mousex,D0-D1
                cmp.w   #$AB,D0
                blo.s   surebuttoncheck
                cmp.w   #$FC,D0
                bhi.s   surebuttoncheck
                cmp.w   #$48,D1
                blo.s   surebuttoncheck
                cmp.w   #$52,D1
                bhi.s   surebuttoncheck
                cmp.w   #$C5,D0
                blo.s   sureansweryes
                cmp.w   #$EA,D0
                blo.s   surebuttoncheck
sureanswerno:
                lea     sureboxdata,A1
                bsr     swapboxmem
                jsr     showallright
                bsr     clearanaheights
                move.b  saveda,disableanalyzer
                move.b  savescope,scopeenable
                bsr     errorrestorecol
                bsr     waitforbuttonup
                bsr     wait_4000
                clr.b   rawkeycode
                moveq   #-1,D0
                rts

sureansweryes:
                lea     sureboxdata,A1
                bsr.s   swapboxmem
                jsr     showallright
                bsr     clearanaheights
                move.b  saveda,disableanalyzer
                move.b  savescope,scopeenable
                bsr     restoreptrcol
                bsr     waitforbuttonup
                bsr     wait_4000
                clr.b   rawkeycode
                moveq   #0,D0
                rts

; Swap sure box on screen!

swapboxmem:
                lea     sureboxpos,A0

                moveq   #38,D0
ssbmloop1:
                moveq   #12,D1
                moveq   #1,D3
ssbmloop2:
                move.b  2(A0),D2
                move.b  546(A1),2(A0)
                move.b  D2,546(A1)
                move.b  (A0),D2
                move.b  (A1),(A0)
                move.b  D2,(A1)+
                adda.w  D3,A0
                eori.w  #14,D3
                dbra    D1,ssbmloop2
                lea     320-97(A0),A0
                addq.l  #1,A1
                dbra    D0,ssbmloop1
                lea     sureboxpos+4,A0 ;; text bitplane!
                lea     textdatabuffer,A1
                moveq   #38,D0
ssbmloop3:
                moveq   #12,D1
                moveq   #1,D3
ssbmloop4:
                move.b  (A0),D2
                move.b  (A1),(A0)
                move.b  D2,(A1)+
                move.b  2(A0),D2
                move.b  (A1),2(A0)
                move.b  D2,(A1)+
                adda.w  D3,A0
                eori.w  #14,D3
                dbra    D1,ssbmloop4
                lea     320-97(A0),A0
                addq.l  #1,A1
                dbra    D0,ssbmloop3
                rts


                ENDPART

                PART 'pointer colours'

;---- Set Pointercolors ----

setdeleteptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  #$AA,2(A6)
                move.w  #$77,6(A6)
                move.w  #$44,10(A6)
                movea.l (SP)+,A6
                rts

setnormalptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  #$0AAA,2(A6)
                move.w  #$0777,6(A6)
                move.w  #$0444,10(A6)
                movea.l (SP)+,A6
                rts

setdiskptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  #$A0,2(A6)
                move.w  #$70,6(A6)
                move.w  #$40,10(A6)
                movea.l (SP)+,A6
                rts

setplayptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  #$0AA0,2(A6)
                move.w  #$0770,6(A6)
                move.w  #$0440,10(A6)
                movea.l (SP)+,A6
                rts

seteditptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  #$5B,2(A6)
                move.w  #$49,6(A6)
                move.w  #$06,10(A6)
                movea.l (SP)+,A6
                rts

setwaitptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  #$0A5A,2(A6)
                move.w  #$0727,6(A6)
                move.w  #$0404,10(A6)
                movea.l (SP)+,A6
                rts

seterrorptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  #$0C00,2(A6)
                move.w  #$0900,6(A6)
                move.w  #$0700,10(A6)
                movea.l (SP)+,A6
                move.w  #1,updatefreemem
                bsr     waitalittle
                jsr     showallright
                bsr     setnormalptrcol
                moveq   #0,D0
                rts

waitalittle:
                move.w  waittime(PC),D1
errorwaitloop:
                bsr     wait_4000
                dbra    D1,errorwaitloop
                move.w  #23,waittime
                rts

waittime:       DC.W 23

storeptrcol:
                move.l  A6,-(SP)
                movea.l coplistcolorptr,A6
                move.w  2(A6),pointercol1save
                move.w  6(A6),pointercol2save
                move.w  10(A6),pointercol3save
                movea.l (SP)+,A6
                rts

errorrestorecol:
                bsr     seterrorptrcol
restoreptrcol:
                move.l  A6,-(SP)
                move.w  #1,updatefreemem
                movea.l coplistcolorptr,A6
                move.w  pointercol1save,2(A6)
                move.w  pointercol2save,6(A6)
                move.w  pointercol3save,10(A6)
                movea.l (SP)+,A6
                rts

                ENDPART

waitforbuttonup:
                btst    #2,mousebut
                bne.s   waitforbuttonup ; Check Left MouseButton
                btst    #0,mousebut
                bne.s   waitforbuttonup ; CHECK RIGHT MOUSEBUTTON
waitforvblank:
                bra     wait_vbl



;---- Check special keys ----



checkplaykeys:
                move.b  rawkeycode,D0
                cmp.b   #101,D0
                beq     playsong
                cmp.b   #103,D0
                beq     playpattern
                cmp.b   #64,D0
                bne.s   cpkskip
                tst.l   runmode
                bne     stopit
                tst.l   editmode
                bne     stopit
                bra     edit
cpkskip:        cmp.b   #97,D0
                beq     recordpattern
                cmp.b   #69,D0
                beq     escpressed
                cmp.b   #66,D0
                beq     tabulatecursor
                cmp.b   #127,D0
                beq     gotocli
                cmp.b   #48,D0
                beq     turnoffvoices
                cmp.b   #60,D0
                beq     killsample
                cmp.b   #13,D0
                beq     togglepnote

                cmp.b   #67,D0
                beq.s   higherinstr
                cmp.b   #67+128,D0
                beq.s   lowerinstr
                move.w  hilowinstr,D1
                lea     kpinstable(PC),A0
                moveq   #0,D2
kpinsloop:
                cmp.b   0(A0,D2.w),D0
                beq.s   kpinsfound
                addq.w  #1,D2
                cmp.w   #16,D2
                blo.s   kpinsloop
                rts

kpinsfound:
                add.w   D2,D1
                beq.s   insnull
                bra.s   redrsa2

lowerinstr:
                clr.w   hilowinstr
                rts
higherinstr:
                move.w  #16,hilowinstr
                move.w  #16,D1
                bra.s   redrsa2

redrsa3:        move.w  D1,insnum
redrsam:        clr.b   rawkeycode
                clr.l   savsaminf
                jsr     showsampleinfo
                jmp     redrawsample

insnull:        tst.w   insnum
                beq.s   insnul2
                move.w  insnum,lastinsnum
                clr.w   insnum
                moveq   #0,D1
                bra.s   redrsa2

insnul2:        jmp     showsampleinfo

kpinstable:
                DC.B 15,90,91,92
                DC.B 93,61,62,63,74
                DC.B 45,46,47,94,29,30
                DC.B 31

redrsa2:        tst.b   pnoteflag
                beq.s   redrsa3
                clr.b   rawkeycode
                tst.w   altkeystatus
                bne.s   setpnote
                move.w  D1,insnum
                jsr     showsampleinfo
                move.w  insnum,D0
                add.w   D0,D0
                move.w  pnotetable(PC,D0.w),D0
                moveq   #-1,D2
                bsr     playtheinstr
                jmp     redrawsample

pnotetable:
                DC.W 24,24,24,24,24,24,24,24,24,24
                DC.W 24,24,24,24,24,24,24,24,24,24
                DC.W 24,24,24,24,24,24,24,24,24,24
                DC.W 24,24

setpnote:
                add.w   D1,D1
                lea     pnotetable(PC,D1.w),A0
                move.l  A0,splitaddress
                move.w  #4,samnotetype
                lea     selnotetext(PC),A0
                jmp     showstatustext

selnotetext:    DC.B "select note",0

togglepnote:
                clr.b   rawkeycode
                moveq   #0,D0
                move.b  pnoteflag,D0
                addq.b  #1,D0
                cmp.b   #3,D0
                blo.s   tpnskp
                moveq   #0,D0
tpnskp:         move.b  D0,pnoteflag
                lea     pnotechar(PC,D0.w),A0
                moveq   #1,D0
                move.w  #5159,D1
                jmp     showtext3

pnotechar:      DC.B 32,128,129
pnoteflag:      DC.B 0

;---- Check transpose keys ----

checktranskeys:
                tst.w   leftamigastatus
                beq     return1
                move.w  pattcurpos,D0
                bsr     getpositionptr
                move.b  rawkeycode,D1
                clr.b   rawkeycode
                move.b  sampleallflag,-(SP)
                bsr.s   ctksub
                move.b  (SP)+,sampleallflag
                rts

ctksub:         moveq   #0,D0
                clr.b   sampleallflag
                cmp.b   #1,D1
                beq     noteup
                cmp.b   #16,D1
                beq     notedown
                cmp.b   #32,D1
                beq     octaveup
                cmp.b   #49,D1
                beq     octavedown

                move.w  #300,D0
                cmp.b   #2,D1
                beq     noteup
                cmp.b   #17,D1
                beq     notedown
                cmp.b   #33,D1
                beq     octaveup
                cmp.b   #50,D1
                beq     octavedown

                moveq   #0,D0
                move.b  #1,sampleallflag
                cmp.b   #3,D1
                beq     noteup
                cmp.b   #18,D1
                beq     notedown
                cmp.b   #34,D1
                beq     octaveup
                cmp.b   #51,D1
                beq     octavedown

                move.w  #300,D0
                cmp.b   #4,D1
                beq     noteup
                cmp.b   #19,D1
                beq     notedown
                cmp.b   #35,D1
                beq     octaveup
                cmp.b   #52,D1
                beq     octavedown
                rts

;---- Check control keys ----

checkctrlkeys:
                tst.w   ctrlkeystatus
                beq     return1
                moveq   #0,D0
                move.b  rawkeycode,D0
                cmp.b   #35,D0          ; F
                beq     togglefilter
                cmp.b   #33,D0          ; S
                beq     togglesplit
                cmp.b   #55,D0          ; M
                beq     togglemultimode
                cmp.b   #16,D0          ; Q
                beq     unmuteall
                cmp.b   #32,D0          ; A
                beq     togglemute
                cmp.b   #49,D0          ; Z
                beq     restoreeffects
                cmp.b   #19,D0          ; R
                beq     restorefkeypos
                cmp.b   #20,D0          ; T
                beq     swaptrack

                cmp.b   #53,D0          ; B
                beq     beginblock
                cmp.b   #51,D0          ; C
                beq     copyblock
                cmp.b   #50,D0          ; X
                beq     cutblock
                cmp.b   #34,D0          ; D
                beq     deleteblock
                cmp.b   #25,D0          ; P
                beq     pasteblock
                cmp.b   #23,D0          ; I
                beq     insertblock
                cmp.b   #38,D0          ; J
                beq     joinpasteblock
                cmp.b   #54,D0          ; N
                beq     re_markblock
                cmp.b   #21,D0          ; Y
                beq     backwardsblock
                cmp.b   #17,D0          ; W
                beq     polyphonizeblock

                cmp.b   #18,D0          ; E
                beq     expandtrack
                cmp.b   #24,D0          ; O
                beq     contracttrack
                cmp.b   #37,D0          ; H
                beq     transblockup
                cmp.b   #40,D0          ; L
                beq     transblockdown
                cmp.b   #39,D0          ; K
                beq     killtoendoftrack
                cmp.b   #22,D0          ; U
                beq     undolastchange

                cmp.b   #68,D0          ; CR
                beq     inscmdtrack
                cmp.b   #65,D0          ; Del
                beq     delcmdtrack
                cmp.b   #36,D0          ; G
                beq     boostall
                cmp.b   #52,D0          ; V
                beq     filterall

                cmp.b   #1,D0
                blo     return1
                cmp.b   #10,D0
                bhi     return1
                bne.s   cckskip
                moveq   #0,D0
cckskip:        move.w  D0,editmoveadd
                clr.b   rawkeycode
                add.b   #'0',D0
                lea     ematext(PC),A0
                move.b  D0,11(A0)
                jsr     showstatustext
                move.w  #10,waittime
                bsr     waitalittle
                jmp     showallright


ematext:        DC.B "editskip = 0",0,0

;---- Check alt keys ----

checkaltkeys:
                tst.w   altkeystatus
                beq     return1
                moveq   #0,D0
                move.b  rawkeycode,D0
                cmp.b   #49,D0          ; Z
                beq     togglech1
                cmp.b   #50,D0          ; X
                beq     togglech2
                cmp.b   #51,D0          ; C
                beq     togglech3
                cmp.b   #52,D0          ; V
                beq     togglech4
                cmp.b   #53,D0          ; B
                beq     boost
                cmp.b   #35,D0          ; F
                beq     filter
                cmp.b   #20,D0          ; T
                beq.s   xtuningtone
                cmp.b   #33,D0          ; S
                beq.s   xsamplerscreen
                cmp.b   #19,D0          ; R
                beq.s   xresample
                cmp.b   #18,D0          ; E
                beq     doeditop
                cmp.b   #23,D0          ; I
                beq.s   autoinsert
                cmp.b   #34,D0          ; D
                beq     diskop
                cmp.b   #39,D0          ; K
                beq     killinstrtrack
;       CMP.B   #17,D0 ; W
;       BEQ.S   WaitForNote
                cmp.b   #32,D0          ; A
                beq.s   xsampler
                cmp.b   #16,D0          ; Q
                beq     chkquit

;       CMP.B   #55,D0 ; M
;       CMP.B   #25,D0 ; P
;       CMP.B   #38,D0 ; J
;       CMP.B   #54,D0 ; N
;       CMP.B   #21,D0 ; Y
;       CMP.B   #24,D0 ; O
;       CMP.B   #37,D0 ; H
;       CMP.B   #40,D0 ; L
;       CMP.B   #22,D0 ; U
;       CMP.B   #36,D0 ; G
                rts

xtuningtone:    jmp     tuningtone
xsamplerscreen: jmp     samplerscreen
xresample:      jmp     resample
xsampler:       jmp     sampler

autoinsert:
                clr.b   rawkeycode
                eori.b  #1,autoinsflag
showautoinsert:
                cmpi.w  #4,currscreen
                beq     return1
                move.b  #' ',D0
                tst.b   autoinsflag
                beq.s   auins2
                move.b  #'I',D0
auins2:         move.b  D0,autoinstext
                move.w  #4561,D1
                moveq   #1,D0
                lea     autoinstext(PC),A0
                jmp     showtext3

autoinstext:    DC.B 0
autoinsflag:    DC.B 0

;---- Jump between channels ----

tabulatecursor:
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                bne.s   tabcurright
                move.w  pattcurpos,D0
                divu    #6,D0
                addq.w  #1,D0
                cmp.w   #4,D0
                bne.s   tacskip
                moveq   #0,D0
tacskip:        mulu    #6,D0
                move.w  D0,pattcurpos
                bra     updatecursorpos

tabcurright:
                move.w  pattcurpos,D0
                addq.w  #5,D0
                divu    #6,D0
                subq.w  #1,D0
                bpl.s   tacskip
                moveq   #3,D0
                bra.s   tacskip

;---- Escape was pressed ----

escpressed:
                clr.b   rawkeycode
                clr.b   savekey
                move.w  currscreen,D0
                cmp.w   #2,D0
                blo.s   botexit
topexit:        move.w  currscreen,D0
                cmp.w   #2,D0
                beq     exithelpscreen
                cmp.w   #3,D0
                beq     exitfromdir
                cmp.w   #4,D0
                beq.s   pedexit
                cmp.w   #5,D0
                beq     exitsetup
                cmp.w   #6,D0
                beq.s   plstexit
                cmp.w   #7,D0
                beq     exitsetup
                rts

botexit:        tst.w   samscrenable
                bne.s   samplerexit
                tst.w   blockmarkflag
                bne     blkunma
                cmpi.w  #1,currscreen
                bne     return1
                tst.b   edenable
                bne     exiteditop
                rts

samplerexit:
                jmp     exitfromsam
pedexit:                                ;jmp     ped_exit
plstexit:                               ;jmp     exitplst

gotocli:        rts

okgadgettext:
                DC.B 0,1,1,0
                DC.W 6,3
                DC.L 0,okgtext,0
okgtext:        DC.B 'OK',0,0


                PART 'help'

;---- Check Help Key ----

helpselecttext: DC.B '* help selected *',0
plstselecttext: DC.B '* plst selected *',0
plsthelpflag:   DC.B 0,0        ; free 0
                EVEN

checkhelpkey:
                cmpi.b  #95,rawkeycode  ; Help Key pressed ?
                bne     return1
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                beq.s   realhlp
                lea     helpselecttext,A0
                eori.b  #1,plsthelpflag
                beq.s   chksel
                lea     plstselecttext,A0
chksel:         jsr     showstatustext
                bsr     waitalittle
                jmp     showallright

gtoplst:        jmp     plst

realhlp:        tst.b   plsthelpflag
                bne.s   gtoplst
                cmpi.w  #2,currscreen
                beq     exithelpscreen
                bsr     topexit
                move.w  currscreen,savecurrscreen
                sf      scopeenable
                st      disableanalyzer
                st      nosampleinfo
                bsr     clearanalyzercolors
                bsr     swaphelpscreen
                beq     exithlp
                bsr     clear100lines
                tst.l   helptextindex+4
                bne.s   chkskip
                bsr     gethelpindex
chkskip:        move.l  #helpfilename,D1
                move.l  #1005,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                bne     showhelppage
                lea     ptpath,A0
                bsr     copypath
                lea     helpfilename(PC),A0
                moveq   #7,D0
hefilop:        move.b  (A0)+,(A1)+
                dbra    D0,hefilop
                move.l  #filename,D1
                move.l  #1005,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq     helpfileerror
                bra.s   showhelppage

exithelpscreen:
                move.l  filehandle,D1
                beq.s   ehsskip
                movea.l dosbase,A6
                jsr     lvoclose        ;;
ehsskip:        bsr     clear100lines
                bsr.s   swaphelpscreen
exithlp:        move.w  savecurrscreen,currscreen
                bra     displaymainall

swaphelpscreen:
                move.l  decompmemptr,D0
                beq.s   shelps2
                movea.l D0,A1
                bsr     ssets3
                bra     freedecompmem
shelps2:        lea     helpscreendata,A0
                move.l  #helpscreensize,D0
                bsr     decompact
                beq     return1
                bra     ssets3

showhelppage:
                move.w  #2,currscreen
                move.w  helppage,D0
                and.w   #$FF,D0
                lsl.w   #2,D0
                lea     helptextindex,A0
                move.l  filehandle,D1
                beq     return1
                move.l  0(A0,D0.w),D2
                add.l   #1024,D2
                moveq   #-1,D3
                movea.l dosbase,A6
                jsr     lvoseek
                move.l  filehandle,D1
                move.l  #helptextdata,D2
                move.l  #656,D3
                jsr     lvoread         ;;
                bsr     clear100lines
                lea     helptextdata+16,A6
                moveq   #120,D6
                moveq   #15,D7
shploop:        moveq   #0,D0
                movea.l A6,A1
shplop2:        cmpi.b  #10,(A1)+
                beq.s   showhelpline
                tst.b   -1(A1)
                beq.s   showhelpline
                addq.w  #1,D0
                bra.s   shplop2
showhelpline:
                move.l  A6,showtextptr
                movea.l A1,A6
                move.w  D6,textoffset
                move.w  D0,textlength
                beq.s   shlskip
                jsr     showtext
shlskip:        add.w   #240,D6
                dbra    D7,shploop
                bsr     wait_4000
                bra     wait_4000

helppage:       DC.W 1

helpup:         lea     helptextdata+7,A0
                bra.s   helpmove
helpdown:
                lea     helptextdata+10,A0
                bra.s   helpmove
helpleft:
                lea     helptextdata+4,A0
                bra.s   helpmove
helpright:
                lea     helptextdata+13,A0
helpmove:
                clr.b   rawkeycode
                moveq   #0,D0
                jsr     hextointeger2
                tst.w   D0
                beq     return1
                and.w   #$FF,D0
                move.w  D0,helppage
                bra     showhelppage

gethelpindex:
                move.l  lahetx,D0
                cmp.l   helptextindex,D0
                beq     return1
                move.l  #helpfilename,D1
                move.l  #1005,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                bne.s   gehein
                lea     ptpath,A0
                bsr     copypath
                lea     helpfilename(PC),A0
                moveq   #7,D0
hefilp2:        move.b  (A0)+,(A1)+
                dbra    D0,hefilp2
                move.l  #filename,D1
                move.l  #1005,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq.s   helpfileerror
gehein:         move.l  D0,D1
                move.l  #helptextindex,D2
                move.l  #256*4,D3
                jsr     lvoread         ;;
                move.l  filehandle,D1
                jsr     lvoclose        ;;
                move.l  helptextindex,lahetx
                rts

helpfileerror:
                move.w  #2,currscreen
                lea     nohelptext(PC),A0
                move.w  #1887,D1
                moveq   #24,D0
                jmp     showtext3

nohelptext:     DC.B 'Unable to open helpfile!'
helpfilename:   DC.B 'ptste200.hlp',0
                EVEN


                ENDPART


;---- Check Function Keys F6-F10 ----

checkf6_f10:
                cmpi.b  #85,rawkeycode
                bne.s   checkf7
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                beq.s   cf6skip
                move.w  scrpattpos,f6pos
showpossettext:
                lea     possettext,A0
                jsr     showstatustext
                moveq   #8,D2
spsloop:        bsr     wait_4000
                dbra    D2,spsloop
                jmp     showallright
cf6skip:        move.w  f6pos,D0
chkalt:         tst.w   altkeystatus
                bne     pattfrom
                tst.w   ctrlkeystatus
                bne     recordfrom
                tst.w   leftamigastatus
                bne     songfrom
                tst.w   runmode
                bne     return1
                move.w  D0,scrpattpos
                bra     setscrpatternpos

checkf7:        cmpi.b  #86,rawkeycode
                bne.s   checkf8
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                beq.s   cf7skip
                move.w  scrpattpos,f7pos
                bra.s   showpossettext
cf7skip:        move.w  f7pos,D0
                bra.s   chkalt

checkf8:        cmpi.b  #87,rawkeycode
                bne.s   checkf9
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                beq.s   cf8skip
                move.w  scrpattpos,f8pos
                bra     showpossettext
cf8skip:        move.w  f8pos,D0
                bra     chkalt

checkf9:        cmpi.b  #88,rawkeycode
                bne.s   checkf10
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                beq.s   cf9skip
                move.w  scrpattpos,f9pos
                bra     showpossettext
cf9skip:        move.w  f9pos,D0
                bra     chkalt

checkf10:
                cmpi.b  #89,rawkeycode
                bne     return1
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                beq.s   cf10skip
                move.w  scrpattpos,f10pos
                bra     showpossettext
cf10skip:
                move.w  f10pos,D0
                bra     chkalt

f6pos:          DC.W 0
f7pos:          DC.W 16
f8pos:          DC.W 32
f9pos:          DC.W 48
f10pos:         DC.W 63

;---- Check Function Keys F3-F5 ----

checkf3_f5:
                moveq   #0,D0
                movea.l D0,A0
                tst.w   shiftkeystatus
                bne     ccp4
                tst.w   ctrlkeystatus
                bne     ccp4
                tst.w   altkeystatus
                bne     cutcoppas
                cmpi.b  #68,rawkeycode
                beq.s   stepplayforward
                cmpi.b  #65,rawkeycode
                beq.s   stepplaybackward
                tst.w   samscrenable
                beq     return1
                cmpi.b  #82,rawkeycode
                beq.s   xsamcut
                cmpi.b  #83,rawkeycode
                beq.s   xsamcop
                cmpi.b  #84,rawkeycode
                beq.s   xsampas
                rts

xsamcut:        jmp     samcut
xsamcop:        jmp     samcopy
xsampas:        jmp     sampaste

stepplayforward:
                move.w  #1,stepplayenable
                bsr     dostopit
                move.w  scrpattpos,D0
                bra     pafr1

stepplaybackward:
                move.w  #1,stepplayenable
                bsr     dostopit
                move.w  scrpattpos,D0
                subq.w  #1,D0
                and.w   #63,D0
                bra     pafr1

stepplayenable: DC.W 0

ccp4:           moveq   #0,D0
                move.w  pattcurpos,D0
                divu    #6,D0
                and.l   #3,D0
                lsl.l   #2,D0
                movea.l D0,A0
cutcoppas:
                adda.l  songdataptr,A0
                lea     sd_patterndata(A0),A0
                move.l  patternnumber,D0
                lsl.l   #8,D0
                lsl.l   #2,D0
                adda.l  D0,A0
                tst.w   altkeystatus
                bne.s   cutcoppaspatt
                tst.w   ctrlkeystatus
                bne.s   cutcoppascmds
cutcoppastrack:
                cmpi.b  #82,rawkeycode
                beq     cuttrack
                cmpi.b  #83,rawkeycode
                beq     copytrack
                cmpi.b  #84,rawkeycode
                beq     pastetrack
                cmpi.b  #68,rawkeycode
                beq     insnotetrack
                cmpi.b  #65,rawkeycode
                beq     delnotetrack
                rts

cutcoppaspatt:
                cmpi.b  #82,rawkeycode
                beq.s   cutpattern
                cmpi.b  #83,rawkeycode
                beq.s   copypattern
                cmpi.b  #84,rawkeycode
                beq     pastepattern
                cmpi.b  #68,rawkeycode
                beq     insnotepattern
                cmpi.b  #65,rawkeycode
                beq     delnotepattern
                rts

cutcoppascmds:
                cmpi.b  #82,rawkeycode
                beq     cutcmds
                cmpi.b  #83,rawkeycode
                beq     copycmds
                cmpi.b  #84,rawkeycode
                beq     pastecmds
                rts

cutpattern:
                bsr     saveundo
                lea     patternbuffer,A1
                move.w  #255,D0
                moveq   #0,D1
cupaloop:
                move.l  (A0),(A1)+
                move.l  D1,(A0)+
                dbra    D0,cupaloop
                clr.b   rawkeycode
                jmp     redrawpattern

copypattern:
                lea     patternbuffer,A1
                move.w  #255,D0
copaloop:
                move.l  (A0)+,(A1)+
                dbra    D0,copaloop
                clr.b   rawkeycode
                rts

pastepattern:
                bsr     saveundo
                lea     patternbuffer,A1
                move.w  #255,D0
papaloop:
                move.l  (A1)+,(A0)+
                dbra    D0,papaloop
                clr.b   rawkeycode
                jmp     redrawpattern


cuttrack:
                bsr     saveundo
                lea     trackbuffer,A1
                moveq   #63,D0
                moveq   #0,D1
cutrloop:
                move.l  (A0),(A1)+
                move.l  D1,(A0)
                lea     16(A0),A0
                dbra    D0,cutrloop
                clr.b   rawkeycode
                jmp     redrawpattern

copytrack:
                lea     trackbuffer,A1
                moveq   #63,D0
cotrloop:
                move.l  (A0),(A1)+
                lea     16(A0),A0
                dbra    D0,cotrloop
                clr.b   rawkeycode
                rts

pastetrack:
                bsr     saveundo
                lea     trackbuffer,A1
                moveq   #63,D0
patrloop:
                move.l  (A1)+,(A0)
                lea     16(A0),A0
                dbra    D0,patrloop
                clr.b   rawkeycode
                jmp     redrawpattern

insnotepattern:
                bsr     saveundo
                moveq   #0,D0
                bsr     getpositionptr
                bsr.s   inotr
                moveq   #6,D0
                bsr     getpositionptr
                bsr.s   inotr
                moveq   #12,D0
                bsr     getpositionptr
                bsr.s   inotr
                moveq   #18,D0
                bsr     getpositionptr
                bsr.s   inotr
                bra.s   intskip
insnotetrack:
                bsr     saveundo
                bsr.s   inotr
intskip:        clr.b   rawkeycode
                add.w   D2,scrpattpos
                andi.w  #$3F,scrpattpos
                bsr     setscrpatternpos
                jmp     redrawpattern

inotr:          move.w  scrpattpos,D1
                lsl.w   #4,D1
                cmp.w   #63*16,D1
                beq.s   inoskip
                move.w  #992,D0
intloop:        move.l  0(A0,D0.w),16(A0,D0.w)
                sub.w   #16,D0
                cmp.w   D1,D0
                bge.s   intloop
inoskip:        moveq   #1,D2
                clr.l   0(A0,D1.w)
                rts

inscmdtrack:
                bsr     saveundo
                move.w  pattcurpos,D0
                bsr     getpositionptr
                bsr.s   icmtr
                bra.s   intskip
icmtr:          move.w  scrpattpos,D1
                lsl.w   #4,D1
                cmp.w   #63*16,D1
                beq.s   icmskip
                move.w  #992,D0
icmloop:        move.w  2(A0,D0.w),D2
                and.w   #$0FFF,D2
                andi.w  #$F000,18(A0,D0.w)
                or.w    D2,18(A0,D0.w)
                sub.w   #16,D0
                cmp.w   D1,D0
                bge.s   icmloop
icmskip:        moveq   #1,D2
                andi.w  #$F000,2(A0,D1.w)
                rts

delnotepattern:
                bsr     saveundo
                moveq   #0,D0
                bsr     getpositionptr
                bsr.s   dnt
                moveq   #6,D0
                bsr     getpositionptr
                bsr.s   dnt
                moveq   #12,D0
                bsr     getpositionptr
                bsr.s   dnt
                moveq   #18,D0
                bsr     getpositionptr
                bsr.s   dnt
                bra     intskip
delnotetrack:
                bsr     saveundo
                bsr.s   dnt
                bra     intskip

dnt:            move.w  scrpattpos,D0
                beq     return1
                subq.w  #1,D0
                lsl.w   #4,D0
dntloop:        move.l  16(A0,D0.w),0(A0,D0.w)
                add.w   #16,D0
                cmp.w   #1024,D0
                blo.s   dntloop
                move.w  #1008,D1
                moveq   #-1,D2
                clr.l   0(A0,D1.w)
                rts

delcmdtrack:
                bsr     saveundo
                move.w  pattcurpos,D0
                bsr     getpositionptr
                bsr.s   dct
                bra     intskip
dct:            move.w  scrpattpos,D0
                beq     return1
                subq.w  #1,D0
                lsl.w   #4,D0
dctloop:        move.w  18(A0,D0.w),D2
                and.w   #$0FFF,D2
                andi.w  #$F000,2(A0,D0.w)
                or.w    D2,2(A0,D0.w)
                add.w   #16,D0
                cmp.w   #1024,D0
                blo.s   dctloop
                move.w  #1008,D1
                moveq   #-1,D2
                andi.w  #$F000,2(A0,D1.w)
                rts

cutcmds:        bsr     saveundo
                lea     cmdsbuffer,A1
                clr.w   D0
cucmloop:
                move.l  0(A0,D0.w),(A1)+
                andi.l  #$FFFFF000,0(A0,D0.w)
                add.w   #16,D0
                cmp.w   #1024,D0
                bne.s   cucmloop
                clr.b   rawkeycode
                jmp     redrawpattern

copycmds:
                lea     cmdsbuffer,A1
                clr.w   D0
cocmloop:
                move.l  0(A0,D0.w),(A1)+
                add.w   #16,D0
                cmp.w   #1024,D0
                bne.s   cocmloop
                clr.b   rawkeycode
                rts

pastecmds:
                bsr     saveundo
                lea     cmdsbuffer,A1
                clr.w   D0
pacmloop:
                move.l  0(A0,D0.w),D1
                and.l   #$FFFFF000,D1
                move.l  (A1)+,D2
                and.l   #$0FFF,D2
                or.l    D2,D1
                move.l  D1,0(A0,D0.w)
                add.w   #16,D0
                cmp.w   #1024,D0
                bne.s   pacmloop
                clr.b   rawkeycode
                jmp     redrawpattern

;---- Swap Tracks ----

swaptrack:
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     swaptracktext,A0
                jsr     showstatustext
swtloop:        bsr     gethexkey
                tst.b   D1
                beq.s   swtabor
                cmp.b   #4,D1
                bhi.s   swtloop
                bsr     saveundo
                subq.l  #1,D1
                lsl.l   #2,D1
                move.l  D1,D0
                movea.l songdataptr,A0
                lea     sd_patterndata(A0),A0
                move.l  patternnumber,D1
                lsl.l   #8,D1
                lsl.l   #2,D1
                adda.l  D1,A0
                movea.l A0,A1
                adda.l  D0,A0
                move.w  pattcurpos,D0
                divu    #6,D0
                and.l   #$0F,D0
                lsl.l   #2,D0
                adda.l  D0,A1
                moveq   #63,D1
swtloop2:
                move.l  (A0),D0
                move.l  (A1),(A0)
                move.l  D0,(A1)
                lea     16(A0),A0
                lea     16(A1),A1
                dbra    D1,swtloop2
                jsr     redrawpattern
swtabor:        jsr     showallright
                bra     restoreptrcol

swaptracktext:  DC.B 'Swap (1/2/3/4) ?',0,0

;---- Block Commands ----

blockmarktext:  DC.B 'mark block 00-00',0,0
blockerrortext: DC.B 'no block marked !',0
bufemptytext:   DC.B 'buffer is empty !',0
blockfrompos:   DC.W 0
blocktopos:     DC.W 0
blockmarkflag:  DC.W 0
blockbufferflag:DC.W 0
joinpasteflag:  DC.W 0
polypasteflag:  DC.W 0
bufffrompos:    DC.W 0
bufftopos:      DC.W 0

beginblock:
                clr.b   rawkeycode
                tst.w   blockmarkflag
                beq.s   beblskp
blkunma:        clr.w   blockmarkflag
                jmp     showallright
beblskp:        move.w  #1,blockmarkflag
                move.w  scrpattpos,blockfrompos
                move.w  scrpattpos,blocktopos
showblockpos:
                move.w  blockfrompos,D0
                move.w  blocktopos,D1
                cmp.w   D0,D1
                bhs.s   sbpskip
                exg     D0,D1
sbpskip:        lea     blockmarktext+12(PC),A0
                bsr     intto2decascii
                lea     blockmarktext+15(PC),A0
                move.w  D1,D0
                bsr     intto2decascii
                lea     blockmarktext(PC),A0
                jmp     showstatustext

re_markblock:
                clr.b   rawkeycode
                move.w  #1,blockmarkflag
                move.w  blocktopos,scrpattpos
                bsr     setscrpatternpos
                bra.s   showblockpos

checkblockpos:
                tst.w   blockmarkflag
                beq     return1
                move.w  scrpattpos,D0
                cmp.w   blocktopos,D0
                beq     return1
                move.w  D0,blocktopos
                bra.s   showblockpos

intto2decascii:
                and.l   #$FF,D0
                divu    #10,D0
                add.b   #'0',D0
                move.b  D0,-1(A0)
                swap    D0
                add.b   #'0',D0
                move.b  D0,(A0)
                rts

cutblock:
                clr.b   rawkeycode
                tst.w   blockmarkflag
                beq     blockerror
                bsr.s   cobldo
                move.w  #1,blockmarkflag
                bra     clearblock

copyblock:
                clr.b   rawkeycode
                tst.w   blockmarkflag
                beq     blockerror
cobldo:         clr.w   blockmarkflag
                move.w  #1,blockbufferflag
                move.w  pattcurpos,D0
                bsr     getpositionptr
                lea     blockbuffer,A1
                moveq   #63,D0
cobllop:        move.l  (A0),(A1)
                lea     16(A0),A0
                lea     16(A1),A1
                dbra    D0,cobllop
                move.w  blockfrompos,D0
                move.w  blocktopos,D1
                cmp.w   D0,D1
                bhs.s   coblskp
                exg     D0,D1
coblskp:        move.w  D0,bufffrompos
                move.w  D1,bufftopos
                jmp     showallright


pasteblock:
                clr.b   rawkeycode
                tst.w   blockbufferflag
                beq     buffererror
                bsr     saveundo
                move.w  pattcurpos,D0
                bsr     getpositionptr
                lea     blockbuffer,A1
                move.w  bufffrompos,D0
                move.w  bufftopos,D1
                move.w  scrpattpos,D2
                lsl.w   #4,D0
                lsl.w   #4,D1
                lsl.w   #4,D2
pabllop:        move.l  0(A1,D0.w),D3
                tst.w   joinpasteflag
                beq.s   pablskp
                move.l  D3,D4
                and.l   #$FFFFF000,D4
                bne.s   pablskp
                move.l  0(A0,D2.w),D4
                and.l   #$FFFFF000,D4
                and.l   #$0FFF,D3
                or.l    D4,D3
pablskp:        move.l  D3,0(A0,D2.w)
                cmp.w   D0,D1
                beq.s   pablend
                cmp.w   #63*16,D0
                beq.s   pablend
                cmp.w   #63*16,D2
                beq.s   pablend
                add.w   #16,D0
                add.w   #16,D2
                tst.w   polypasteflag
                beq.s   pabllop
                movem.l D0-D2/A1,-(SP)
                bsr     gotonextmulti
                move.w  pattcurpos,D0
                bsr     getpositionptr
                movem.l (SP)+,D0-D2/A1
                bra.s   pabllop
pablend:        clr.w   joinpasteflag
                clr.w   polypasteflag
                bsr     showallright
                bsr     redrawpattern
                tst.w   shiftkeystatus
                bne     return1
                move.w  bufftopos,D0
                sub.w   bufffrompos,D0
                addq.w  #1,D0
                add.w   scrpattpos,D0
                cmp.w   #63,D0
                bls.s   pablset
                moveq   #0,D0
pablset:        move.w  D0,scrpattpos
                bra     setscrpatternpos

polyphonizeblock:
                move.w  #1,polypasteflag
joinpasteblock:
                move.w  #1,joinpasteflag
                bra     pasteblock

insertblock:
                clr.b   rawkeycode
                tst.w   blockbufferflag
                beq     buffererror
                cmpi.w  #63,scrpattpos
                beq     pasteblock
                move.w  bufftopos,D0
                sub.w   bufffrompos,D0
inbllop:        move.l  D0,-(SP)
                move.w  pattcurpos,D0
                bsr     getpositionptr
                bsr     inotr
                move.l  (SP)+,D0
                dbra    D0,inbllop
                bra     pasteblock

deleteblock:
                clr.b   rawkeycode
                tst.w   blockmarkflag
                beq     blockerror
                bsr     saveundo
                move.w  blockfrompos,D0
                move.w  blocktopos,D1
                cmp.w   D0,D1
                bhs.s   deblskp
                exg     D0,D1
deblskp:        cmp.w   #63,D1
                beq.s   clearblock
                clr.w   blockmarkflag
                move.w  D0,scrpattpos
                addq.w  #1,scrpattpos
                sub.w   D0,D1
                move.w  D1,D0
debllop:        move.l  D0,-(SP)
                move.w  pattcurpos,D0
                bsr     getpositionptr
                bsr     dnt
                move.l  (SP)+,D0
                dbra    D0,debllop
                subq.w  #1,scrpattpos
                bsr     showallright
                bra     redrawpattern

clearblock:
                tst.w   blockmarkflag
                beq     blockerror
                bsr     saveundo
                clr.w   blockmarkflag
                move.w  pattcurpos,D0
                bsr     getpositionptr
                move.w  blockfrompos,D0
                move.w  blocktopos,D1
                cmp.w   D0,D1
                bhs.s   clblskp
                exg     D0,D1
clblskp:        lsl.w   #4,D0
                lsl.w   #4,D1
                moveq   #0,D2
clbllop:        move.l  D2,0(A0,D0.w)
                cmp.w   D0,D1
                beq.s   clblend
                add.w   #16,D0
                bra.s   clbllop
clblend:        bsr     showallright
                bra     redrawpattern

backwardsblock:
                clr.b   rawkeycode
                tst.w   blockmarkflag
                beq     blockerror
                bsr     saveundo
                clr.w   blockmarkflag
                move.w  pattcurpos,D0
                bsr     getpositionptr
                move.w  blockfrompos,D0
                move.w  blocktopos,D1
                cmp.w   D0,D1
                bhs.s   bablskp
                exg     D0,D1
bablskp:        lsl.w   #4,D0
                lsl.w   #4,D1
babllop:        move.l  0(A0,D0.w),D2
                move.l  0(A0,D1.w),0(A0,D0.w)
                move.l  D2,0(A0,D1.w)
                cmp.w   D1,D0
                bhs.s   bablend
                add.w   #16,D0
                sub.w   #16,D1
                cmp.w   D1,D0
                bhs.s   bablend
                bra.s   babllop
bablend:        bsr     showallright
                bra     redrawpattern

transblockup:
                sf      trblflag
                bra.s   trbldo
transblockdown:
                st      trblflag
trbldo:         clr.b   rawkeycode
                tst.w   blockmarkflag
                beq.s   blockerror
                bsr     saveundo
                move.w  #2,noteshift
                move.w  blockfrompos,D0
                move.w  blocktopos,D1
                cmp.w   D0,D1
                bhs.s   trblskp
                exg     D0,D1
trblskp:        move.w  D0,D5
                lsl.w   #4,D5
                sub.w   D0,D1
                move.w  D1,D6
                move.w  pattcurpos,D0
                bsr     getpositionptr
                lea     0(A0,D5.w),A3
                moveq   #0,D3
                move.b  sampleallflag,sampallsave
                st      sampleallflag
                tst.b   trblflag
                beq.s   trblup
                bsr     sandlo2
                move.b  sampallsave,sampleallflag
                bra     redrawpattern
trblup:         bsr     sanulo2
                move.b  sampallsave,sampleallflag
                bra     redrawpattern

trblflag:       DC.B 0
sampallsave:    DC.B 0

blockerror:
                lea     blockerrortext,A0
                bsr     showstatustext
                bra     seterrorptrcol

buffererror:
                lea     bufemptytext,A0
                bsr     showstatustext
                bra     seterrorptrcol

expandtrack:
                clr.b   rawkeycode
                bsr     saveundo
                move.w  scrpattpos,possave
                addq.w  #1,scrpattpos
                cmpi.w  #64,scrpattpos
                bhs.s   extrend
extrlop:        move.w  pattcurpos,D0
                bsr     getpositionptr
                bsr     inotr
                addq.w  #2,scrpattpos
                cmpi.w  #64,scrpattpos
                blo.s   extrlop
extrend:        move.w  possave,scrpattpos
                bra     redrawpattern

contracttrack:
                clr.b   rawkeycode
                bsr     saveundo
                move.w  scrpattpos,possave
                addq.w  #1,scrpattpos
                cmpi.w  #64,scrpattpos
                bhs.s   cotrend
cotrlop:        move.w  pattcurpos,D0
                bsr     getpositionptr
                bsr     dnt
                addq.w  #1,scrpattpos
                cmpi.w  #64,scrpattpos
                blo.s   cotrlop
cotrend:        move.w  possave,scrpattpos
                bra     redrawpattern

possave:        DC.W 0


killtoendoftrack:
                clr.b   rawkeycode
                bsr     saveundo
                move.w  pattcurpos,D0
                bsr     getpositionptr
                move.w  scrpattpos,D0
                move.w  D0,D1
                mulu    #16,D1
                lea     0(A0,D1.w),A0
                tst.w   shiftkeystatus
                bne.s   killtostart
kteot:          clr.l   (A0)
                lea     16(A0),A0
                addq.w  #1,D0
                cmp.w   #64,D0
                blo.s   kteot
                bra     redrawpattern

killtostart:
                clr.l   (A0)
                lea     -16(A0),A0
                tst.w   D0
                beq     redrawpattern
                subq.w  #1,D0
                bra.s   killtostart

undolastchange:
                clr.b   rawkeycode
                moveq   #0,D0
                bsr     getpositionptr
                lea     undobuffer,A1
                move.w  #255,D0
unlalop:        move.l  (A1),D1
                move.l  (A0),(A1)+
                move.l  D1,(A0)+
                dbra    D0,unlalop
                bra     redrawpattern

saveundo:
                movem.l D0/A0-A1,-(SP)
                moveq   #0,D0
                bsr     getpositionptr
                lea     undobuffer,A1
                move.w  #255,D0
saunlop:        move.l  (A0)+,(A1)+
                dbra    D0,saunlop
                movem.l (SP)+,D0/A0-A1
                rts

boostall:
                lea     boostalltext,A0
                bsr     areyousure
                bne     seterrorptrcol
                move.w  insnum,saveinstr
                move.w  #1,insnum
boallop:        bsr     showsampleinfo
                bsr     boost2
                addq.w  #1,insnum
                cmpi.w  #32,insnum
                blo.s   boallop
                move.w  saveinstr,insnum
                bra     showsampleinfo

filterall:
                lea     filteralltext,A0
                bsr     areyousure
                bne     seterrorptrcol
                move.w  insnum,saveinstr
                move.w  #1,insnum
fiallop:        bsr     showsampleinfo
                bsr     filter2
                addq.w  #1,insnum
                cmpi.w  #32,insnum
                blo.s   fiallop
                move.w  saveinstr,insnum
                bra     showsampleinfo

boostalltext:   DC.B 'boost all samples',0
filteralltext:  DC.B 'filter all sampls',0
saveinstr:      DC.W 0

;---- Check Function Keys F1-F2 ----

checkf1_f2:
                cmpi.b  #80,rawkeycode
                beq.s   setoctavelow
                cmpi.b  #81,rawkeycode
                beq.s   setoctavehigh
                rts

setoctavelow:
                move.l  #kbdtranstable1,keytranstabptr
                clr.b   rawkeycode
                rts

setoctavehigh:
                move.l  #kbdtranstable2,keytranstabptr
                clr.b   rawkeycode
                rts


;---- Get Hex Key ----

gethexbyte:
                bsr     storeptrcol
                bsr     setwaitptrcol
                clr.b   rawkeycode
                moveq   #0,D0
                move.w  textoffset,D0
                divu    #40,D0
                addq.w  #6,D0
                move.w  D0,linecury
                swap    D0
                lsl.w   #3,D0
                addq.w  #4,D0
                move.w  D0,linecurx
                bsr     updatelinecurpos
                bsr.s   gethexkey
                move.l  D1,D0
                move.b  D1,D6
                lsl.b   #4,D6
                bsr     printhexdigit
                addi.w  #8,linecurx
                bsr     updatelinecurpos
                bsr.s   gethexkey
                move.l  D1,D0
                or.b    D1,D6
                bsr     printhexdigit
                clr.w   linecurx
                move.w  #270,linecury
                bsr     updatelinecurpos
                bsr     restoreptrcol
                moveq   #0,D0
                move.b  D6,D0
                rts

gethexkey:
                clr.b   mixchar
                moveq   #0,D0
                moveq   #0,D1
;                btst    #2,$DFF016
;                beq.s   ghkreturn

                btst    #0,mousebut
                bne.s   ghkreturn

                bsr     dokeybuffer
                move.b  rawkeycode,D0
                move.b  D0,mixchar
                beq.s   gethexkey
                cmp.b   #68,D0          ; CR
                beq.s   ghkreturn
                cmp.b   #69,D0          ; Esc
                beq.s   ghkreturn
                cmp.b   #79,D0          ; <--
                beq.s   ghkleft
                cmp.b   #78,D0          ; -->
                beq.s   ghkright
                bsr.s   checkhexkey
                cmp.b   #16,D1
                beq.s   gethexkey
                clr.b   rawkeycode
ghkreturn:
                moveq   #0,D0
                rts

ghkleft:        moveq   #-1,D0
                rts

ghkright:
                moveq   #1,D0
                rts

checkhexkey:
                lea     rawkeyhextable,A0
                moveq   #0,D1
chxloop:        cmp.b   (A0)+,D0
                beq     return1
                addq.b  #1,D1
                cmp.b   #16,D1
                bne.s   chxloop
                rts

;---- Enter Edit Commands (effects) ----

editcommand:
                tst.l   editmode
                beq     return1
                moveq   #0,D0
                move.b  rawkeycode,D0
                bsr.s   checkhexkey
                cmp.b   #16,D1
                bne.s   doeditcommand
                rts

doeditcommand:
                cmpi.w  #1,pattcurpos
                bne.s   chkpos2
                cmp.w   #1,D1
                bhi     return1
                move.l  #$0FFF,D2
                clr.w   cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra     updatecommand

chkpos2:        cmpi.w  #2,pattcurpos
                bne.s   chkpos3
                move.l  #$0FFF,D2
                move.w  #2,cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra     updatecommand

chkpos3:        cmpi.w  #3,pattcurpos
                bne.s   chkpos4
                move.l  #$F0FF,D2
                move.w  #2,cmdoffset
                lsl.w   #8,D1
                bra     updatecommand

chkpos4:        cmpi.w  #4,pattcurpos
                bne.s   chkpos5
                move.l  #$FF0F,D2
                move.w  #2,cmdoffset
                lsl.w   #4,D1
                bra     updatecommand

chkpos5:        cmpi.w  #5,pattcurpos
                bne.s   chkpos7
                move.l  #$FFF0,D2
                move.w  #2,cmdoffset
                bra     updatecommand

chkpos7:        cmpi.w  #7,pattcurpos
                bne.s   chkpos8
                cmp.w   #1,D1
                bhi     return1
                move.l  #$0FFF,D2
                move.w  #4,cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra     updatecommand

chkpos8:        cmpi.w  #8,pattcurpos
                bne.s   chkpos9
                move.l  #$0FFF,D2
                move.w  #6,cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra     updatecommand

chkpos9:        cmpi.w  #9,pattcurpos
                bne.s   chkpos10
                move.l  #$F0FF,D2
                move.w  #6,cmdoffset
                lsl.w   #8,D1
                bra     updatecommand

chkpos10:
                cmpi.w  #10,pattcurpos
                bne.s   chkpos11
                move.l  #$FF0F,D2
                move.w  #6,cmdoffset
                lsl.w   #4,D1
                bra     updatecommand

chkpos11:
                cmpi.w  #11,pattcurpos
                bne.s   chkpos13
                move.l  #$FFF0,D2
                move.w  #6,cmdoffset
                bra     updatecommand

chkpos13:
                cmpi.w  #13,pattcurpos
                bne.s   chkpos14
                cmp.w   #1,D1
                bhi     return1
                move.l  #$0FFF,D2
                move.w  #8,cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra     updatecommand

chkpos14:
                cmpi.w  #14,pattcurpos
                bne.s   chkpos15
                move.l  #$0FFF,D2
                move.w  #10,cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra     updatecommand

chkpos15:
                cmpi.w  #15,pattcurpos
                bne.s   chkpos16
                move.l  #$F0FF,D2
                move.w  #10,cmdoffset
                lsl.w   #8,D1
                bra     updatecommand

chkpos16:
                cmpi.w  #16,pattcurpos
                bne.s   chkpos17
                move.l  #$FF0F,D2
                move.w  #10,cmdoffset
                lsl.w   #4,D1
                bra     updatecommand

chkpos17:
                cmpi.w  #17,pattcurpos
                bne.s   chkpos19
                move.l  #$FFF0,D2
                move.w  #10,cmdoffset
                bra     updatecommand

chkpos19:
                cmpi.w  #19,pattcurpos
                bne.s   chkpos20
                cmp.w   #1,D1
                bhi     return1
                move.l  #$0FFF,D2
                move.w  #12,cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra.s   updatecommand

chkpos20:
                cmpi.w  #20,pattcurpos
                bne.s   chkpos21
                move.l  #$0FFF,D2
                move.w  #14,cmdoffset
                lsl.w   #4,D1
                lsl.w   #8,D1
                bra.s   updatecommand

chkpos21:
                cmpi.w  #21,pattcurpos
                bne.s   chkpos22
                move.l  #$F0FF,D2
                move.w  #14,cmdoffset
                lsl.w   #8,D1
                bra.s   updatecommand

chkpos22:
                cmpi.w  #22,pattcurpos
                bne.s   mustbepos23
                move.l  #$FF0F,D2
                move.w  #14,cmdoffset
                lsl.w   #4,D1
                bra.s   updatecommand

mustbepos23:
                move.l  #$FFF0,D2
                move.w  #14,cmdoffset
updatecommand:
                movea.l songdataptr,A0
                lea     sd_patterndata(A0),A0
                move.l  patternnumber,D0
                lsl.l   #8,D0
                lsl.l   #2,D0
                adda.l  D0,A0
                moveq   #0,D0
                move.w  scrpattpos,D0
                lsl.w   #4,D0
                ext.l   D0
                adda.l  D0,A0
                adda.w  cmdoffset,A0
                and.w   D2,(A0)
                add.w   D1,(A0)
                move.w  (A0),wordnumber
                moveq   #0,D0
                move.w  scrpattpos,D0
                mulu    #7*40,D0
                move.w  pattcurpos,D1
                divu    #6,D1
                mulu    #9,D1
                add.l   D1,D0
                add.w   #1968,D0
                move.w  D0,textoffset
                cmpi.w  #0,cmdoffset
                beq.s   showinstrnibble
                cmpi.w  #4,cmdoffset
                beq.s   showinstrnibble
                cmpi.w  #8,cmdoffset
                beq.s   showinstrnibble
                cmpi.w  #12,cmdoffset
                beq.s   showinstrnibble
                bsr     printhexwordp
dscend:         bsr     editmovedown
                clr.b   rawkeycode
                rts

showinstrnibble:
                subq.w  #1,textoffset
                move.w  #1,textlength
                moveq   #0,D0
                move.w  (A0),D0
                and.w   #$F000,D0
                bne.s   sinokok
                tst.b   blankzeroflag
                beq.s   sinokok
                move.l  #blankinstext,D0
                bra.s   sinprt
sinokok:        lsr.w   #4,D0
                lsr.w   #7,D0
                add.l   #fasthextable+1,D0
sinprt:         move.l  D0,showtextptr
                bsr     showtextp
                bra.s   dscend

;---- Store/Insert Effect Commands ----

checkstoreeffect:
                moveq   #0,D0
                move.b  rawkeycode,D0
                beq     return1
                cmp.b   #70,D0          ; Del
                beq     checkkeyboard2
                cmp.b   #10,D0
                bhi     return1
                subq.b  #1,D0
                add.b   D0,D0
                move.l  D0,D7
                move.w  pattcurpos,D0
                bsr     getpositionptr
                move.w  scrpattpos,D0
                lsl.w   #4,D0
                lea     0(A0,D0.w),A0
                move.w  2(A0),D0
                and.w   #$0FFF,D0
                lea     effectmacros,A0
                move.w  D0,0(A0,D7.w)
                lea     commandstoredtext,A0
                bsr     showstatustext
                bsr     waitalittle
                bra     showallright

commandstoredtext:DC.B 'command stored!',0

checkinserteffect:
                clr.w   insefx
                moveq   #0,D0
                move.b  rawkeycode,D0
                beq     return1
                cmp.b   #70,D0          ; Del
                beq     checkkeyboard2
                cmp.b   #11,D0          ; -
                beq     decreaseeffect
                cmp.b   #12,D0          ; = (+)
                beq.s   increaseeffect
                cmp.b   #13,D0          ; \
                beq.s   copyeffect
                cmp.b   #10,D0
                bhi     return1
                subq.b  #1,D0
                add.b   D0,D0
                lea     effectmacros,A0
                move.w  0(A0,D0.w),insefx
doinseffect:
                move.b  #70,rawkeycode
                bra     checknotekeys

getlasteffect:
                move.w  pattcurpos,D0
                bsr     getpositionptr
                move.w  scrpattpos,D0
                subq.w  #1,D0
                and.w   #$3F,D0
                lsl.w   #4,D0
                lea     0(A0,D0.w),A0
                move.w  2(A0),D0
                and.w   #$0FFF,D0
                rts

copyeffect:
                bsr.s   getlasteffect
                move.w  D0,insefx
                bra.s   doinseffect

increaseeffect:
                bsr.s   getlasteffect
                move.w  D0,D1
                and.w   #$0F00,D1
                cmp.w   #$0E00,D1
                beq.s   incecom
                addq.b  #1,D0
                move.w  D0,insefx
                bra.s   doinseffect

incecom:        move.w  D0,D1
                addq.b  #1,D1
                and.b   #$0F,D1
                and.w   #$0FF0,D0
                or.b    D1,D0
                move.w  D0,insefx
                bra.s   doinseffect

decreaseeffect:
                bsr.s   getlasteffect
                move.w  D0,D1
                and.w   #$0F00,D1
                cmp.w   #$0E00,D1
                beq.s   dececom
                subq.b  #1,D0
                move.w  D0,insefx
                bra     doinseffect

dececom:        move.w  D0,D1
                subq.b  #1,D1
                and.b   #$0F,D1
                and.w   #$0FF0,D0
                or.b    D1,D0
                move.w  D0,insefx
                bra     doinseffect

insefx:         DC.W 0

;---- Check Keyboard for notekeys ----

checkkeyboard:
                tst.b   rawkeycode
                beq     return1
                tst.w   leftamigastatus
                bne     return1
                tst.w   ctrlkeystatus
                bne     return1
                tst.w   shiftkeystatus
                bne     checkstoreeffect
                tst.w   altkeystatus
                bne     checkinserteffect
checkkeyboard2:
                move.w  pattcurpos,D0
                beq.s   checknotekeys
                cmp.w   #6,D0
                beq.s   checknotekeys
                cmp.w   #12,D0
                beq.s   checknotekeys
                cmp.w   #18,D0
                beq.s   checknotekeys
                tst.l   editmode
                bne     editcommand
                rts

checknotekeys:
                lea     rawkeyscaletable,A0
                move.b  rawkeycode,D1
                moveq   #38,D0
cnkloop:        cmp.b   0(A0,D0.w),D1
                beq.s   notekeypressed
                dbra    D0,cnkloop
                rts

notekeypressed:
                clr.b   rawkeycode
                movea.l keytranstabptr,A1
                move.b  0(A1,D0.w),D0
                cmp.w   #36,D0
                bhs.s   nkpskip
                move.l  splitaddress,D1
                beq.s   nkpskip
                clr.l   splitaddress
                movea.l D1,A0
                move.b  D0,(A0)
                move.w  samnotetype,D1
                beq     showsplit
                clr.w   samnotetype
                and.w   #$FF,D0
                move.w  D0,(A0)
                cmp.w   #1,D1
                beq.s   loclab1
                cmp.w   #3,D1
                beq     shows2tunenote
                cmp.w   #4,D1
                beq     showallright
                jmp     showresamnote
loclab1:        jmp     showsamnote
nkpskip:        move.w  insnum,playinsnum
                tst.b   splitflag
                beq.s   nkpskip2
                lea     splitinstrtable,A1
                move.b  0(A1,D0.w),D1
                beq.s   nkpskip3
                move.b  D1,playinsnum+1
nkpskip3:
                lea     splittranstable,A1
                move.b  0(A1,D0.w),D0
nkpskip2:
                moveq   #0,D2
playtheinstr:
                lea     periodtable,A1  ; note in d0 here
                move.l  D0,D4
                add.w   D0,D0
                moveq   #0,D3
                move.w  0(A1,D0.w),D3

                movea.l songdataptr,A0  ; This fixes finetune...
                lea     14(A0),A0
                move.w  insnum,D1
                bne.s   nkpskipit
                move.w  lastinsnum,D1
nkpskipit:
                mulu    #30,D1
                adda.l  D1,A0
                moveq   #0,D1
                move.b  (A0),D1         ; get finetune
                mulu    #37*2,D1
                adda.l  D1,A1
                move.w  0(A1,D0.w),currentplaynote
                tst.l   D2
                beq.s   nkpnrml
                cmpi.b  #2,pnoteflag
                bne     antpskip

nkpnrml:        tst.l   editmode
                beq     antpskip
addnotetopattern:
                movea.l songdataptr,A0
                lea     sd_patterndata(A0),A0 ; Find first pattern
                move.l  patternnumber,D0
                lsl.l   #8,D0
                lsl.l   #2,D0
                adda.l  D0,A0           ; Find current pattern
                moveq   #0,D0
                move.w  scrpattpos,D0
                bsr     quantizecheck
                lsl.w   #4,D0
                ext.l   D0
                adda.l  D0,A0           ; Find current pos
                move.w  pattcurpos,D0
                divu    #6,D0
                lsl.w   #2,D0
                ext.l   D0
                adda.l  D0,A0           ; Find current channel
                tst.w   altkeystatus
                beq.s   antpsks
                andi.l  #$FFFFF000,(A0)
                move.w  insefx,D0
                or.w    D0,2(A0)
                bra.s   antp3
antpsks:        tst.w   shiftkeystatus
                beq.s   antpskip2
                clr.l   (A0)
antpskip2:
                move.w  D3,(A0)         ; Put note into pattern
                beq.s   antp2
                tst.b   autoinsflag
                beq.s   antp4
                move.w  volumeefx,2(A0)
antp4:          moveq   #0,D0
                move.w  playinsnum,D0
                lsl.w   #4,D0
                andi.b  #$0F,2(A0)
                add.b   D0,2(A0)
                lsl.w   #4,D0
                and.w   #$F000,D0
                or.w    D0,(A0)
                bra.s   antp3

antp2:          andi.w  #$0FFF,2(A0)
antp3:          move.w  2(A0),currcmds
                movea.l notenamesptr,A0
                lsl.w   #2,D4
                ext.l   D4
                adda.l  D4,A0
                move.l  A0,showtextptr
                move.w  #3,textlength
                moveq   #0,D0
                move.w  scrpattpos,D0
                bsr     quantizecheck
                mulu    #7*40,D0
                moveq   #0,D1
                move.w  pattcurpos,D1
                divu    #6,D1
                mulu    #9,D1
                add.l   D1,D0
                add.w   #1964,D0
                move.w  D0,textoffset
                tst.w   altkeystatus
                beq.s   antpnot
                addq.w  #4,D0
                move.w  D0,textoffset
                bra.s   antpalt
antpnot:        bsr     showtextp       ; Show notename

                bsr     printhiinstrnum

antpalt:
                move.w  currcmds,wordnumber
                bsr     printhexwordp
                bsr     editmovedown
antpskip:
                tst.w   didquantize
                bne.s   testmul
                tst.w   currentplaynote
                bne     playnote
testmul:        tst.b   multiflag
                beq     return1
gotonextmulti:
                moveq   #0,D0
                move.w  pattcurpos,D0
                divu    #6,D0
                lea     multimodenext,A0
                move.b  0(A0,D0.w),D0
                subq.w  #1,D0
                and.w   #3,D0
                mulu    #6,D0
                move.w  D0,pattcurpos
                bra     updatecursorpos

quantizecheck:
                tst.l   runmode
                beq.s   qcend
                moveq   #0,D1
                move.b  quantizevalue,D1
                beq.s   qcend
                cmp.w   #1,D1
                beq.s   quanone
                move.w  #1,didquantize
                move.l  D1,D2
                lsr.w   #1,D2
                add.w   D0,D2
                and.w   #$3F,D2
                divu    D1,D2
                mulu    D1,D2
                cmp.w   D0,D2
                bhi.s   qcskip
                clr.w   didquantize
qcskip:         move.w  D2,D0
                rts

quanone:        move.l  currspeed,D1
                lsr.l   #1,D1
                cmp.l   counter,D1
                bls.s   quanttonextnote
qcend:          clr.w   didquantize
                rts

quanttonextnote:
                addq.w  #1,D0
                and.w   #$3F,D0
                move.w  #1,didquantize
                rts

playnote:
                cmpi.w  #18,pattcurpos
                bne.s   chkchan3
;lea     $DFF0D0,A5
                lea     ch4s,A5
                lea     audchan4temp,A4
                bra.s   doplaynote

chkchan3:
                cmpi.w  #12,pattcurpos
                bne.s   chkchan2
                lea     ch3s,A5
;                lea     $DFF0C0,A5
                lea     audchan3temp,A4
                bra.s   doplaynote

chkchan2:
                cmpi.w  #6,pattcurpos
                bne.s   chkchan1
                lea     ch2s,A5
;                lea     $DFF0B0,A5
                lea     audchan2temp,A4
                bra.s   doplaynote

chkchan1:
                tst.w   pattcurpos
                bne     return1
                lea     ch1s,A5
;                lea     $DFF0A0,A5
                lea     audchan1temp,A4
doplaynote:
;                move.l  A5,noteaddr
                lea     sampleinfo,A6
                move.w  playinsnum,D0
                beq.s   dpnplay
                lsl.l   #2,D0
                lea     sampleptrs,A0
                lea     sampleinfo2,A6
                move.l  0(A0,D0.w),si_pointer2
                movea.l songdataptr,A0
                lea     -10(A0),A0
                move.w  playinsnum,D0
                move.b  D0,playinsnum2
                mulu    #30,D0
                adda.l  D0,A0
                move.l  22(A0),sampleinfo2
                move.l  26(A0),si_long2
dpnplay:        move.b  playinsnum2,n_samplenum(A4)
                move.w  4(A6),D0        ; repeat
                bne.s   dpn2
                move.w  (A6),D0         ; length
                bra.s   dpn3
dpn2:           add.w   6(A6),D0        ; add replen
dpn3:           moveq   #0,D1
                move.b  3(A6),D1
;                move.w  D1,8(A5)        ; Set volume
                move.w  D1,sam_vol(A5)
                move.b  D1,n_volume(A4)
;                move.w  currentplaynote,6(A5) ; Set period
                move.w  currentplaynote,sam_period(A5)

                move.w  currentplaynote,n_period(A4)

;                move.w  n_dmabit(A4),$DFF096 ; Channel DMA off
                move.w  D0,-(SP)        ;;
                move.w  n_dmabit(A4),D0 ;;
                jsr     move_dmacon
                move.w  (SP)+,D0        ;;

                move.l  8(A6),D1
                add.l   startofs,D1
;                move.l  D1,(A5)         ; Set sampledata pointer
                move.l  D1,sam_start(A5)

                clr.l   startofs
                move.l  D1,n_start(A4)
                move.l  D0,-(SP)        ;;
                and.l   #$FFFF,D0       ;;
;                move.w  D0,4(A5)        ; Set length
                add.l   D0,D0           ;;
                move.l  D0,sam_length(A5) ;;
                add.l   D0,sam_start(A5) ;;
                move.l  (SP)+,D0        ;;

                move.w  D0,n_length(A4)
                bne.s   dpnnz
                move.l  D0,-(SP)
                moveq   #1,D0
                and.l   #$FFFF,D0
;                move.w  D0,4(A5)
                add.l   D0,D0           ;;
                move.l  D0,sam_length(A5) ;;
                add.l   D0,sam_start(A5) ;;
                move.l  (SP)+,D0        ;;

                move.w  D0,n_length(A4)
dpnnz:          move.w  currentplaynote,D0
                bsr     playnoteanalyze

;                move.w  dmawait,D0
;dpnolp1:        dbra    D0,dpnolp1

                move.w  n_dmabit(A4),D0
                and.w   activechannels,D0
                or.w    #$8000,D0
;                move.w  D0,$DFF096      ; Turn DMA back on
                jsr     move_dmacon     ;;

;                move.w  dmawait,D0
;dpnolp2:        dbra    D0,dpnolp2

                moveq   #0,D1
                move.w  4(A6),D1        ; repeat*2
                add.l   D1,D1
                add.l   8(A6),D1        ; + startptr

;               move.l  D1,(A5)         ; Set loop pointer
                move.l  D1,sam_lpstart(A5) ;;
                move.l  D1,n_loopstart(A4)
                move.l  D0,-(SP)        ;;
                moveq   #0,D0           ;;
                move.w  6(A6),D0        ;;
                add.l   D0,D0           ;;
                add.l   D0,sam_lpstart(A5) ;;
                move.l  D0,sam_lplength(A5) ;;
                move.l  (SP)+,D0        ;;
;               move.w  6(A6),4(A5)     ; Set loop length

                move.w  6(A6),n_replen(A4)
                st      n_trigger(A4)
                bra     testmul

playinsnum2:    DC.B 0,0

;---- Check Cursor Arrow Keys ----

arrowkeys:
                cmpi.b  #4,entertextflag
                beq     return1
                move.b  rawkeycode,D0
                tst.w   getlineflag
                bne.s   arkeskip
                tst.w   shiftkeystatus
                bne.s   arkeskip
                tst.w   altkeystatus
                bne.s   arkeskip
                cmpi.w  #2,currscreen
                beq.s   arkeskip
                cmp.b   #78,D0
                beq     rightarrow
                cmp.b   #79,D0
                beq     leftarrow
arkeskip:
                cmp.b   #76,D0
                beq.s   uparrow
                cmp.b   #77,D0
                beq     downarrow
                clr.w   arrowpressed
                rts

arrowpressed:   DC.W 0
arrowrepcounter:DC.W 0

uparrow:        tst.l   runmode
                bne     return1
                cmpi.w  #2,currscreen
                beq     return1
                cmpi.w  #3,currscreen
                beq     return1
                cmpi.w  #4,currscreen
                beq     return1
                cmpi.w  #6,currscreen
                beq     return1
                tst.w   arrowpressed
                beq.s   moveoneup
                addq.w  #1,arrowrepcounter
                tst.w   altkeystatus
                bne.s   altuparrow
                tst.w   shiftkeystatus
                bne.s   shiftuparrow
                cmpi.w  #6,arrowrepcounter
                bpl.s   moveoneup
                rts

shiftuparrow:
                cmpi.w  #3,arrowrepcounter
                bpl.s   moveoneup
                rts

altuparrow:
                cmpi.w  #1,arrowrepcounter
                bpl.s   moveoneup
                rts

moveoneup:
                clr.w   arrowrepcounter
                move.w  #$FFFF,arrowpressed
                cmpi.l  #'patt',runmode
                beq     return1
                subq.w  #1,scrpattpos
                andi.w  #$3F,scrpattpos
                bra     setscrpatternpos

downarrow:
                tst.l   runmode
                bne     return1
                cmpi.w  #2,currscreen
                beq     return1
                cmpi.w  #3,currscreen
                beq     return1
                cmpi.w  #4,currscreen
                beq     return1
                cmpi.w  #6,currscreen
                beq     return1
                tst.w   arrowpressed
                beq.s   moveonedown
                addq.w  #1,arrowrepcounter
                tst.w   altkeystatus
                bne.s   altdownarrow
                tst.w   shiftkeystatus
                bne.s   shiftdownarrow
                cmpi.w  #6,arrowrepcounter
                bpl.s   moveonedown
                rts

shiftdownarrow:
                cmpi.w  #3,arrowrepcounter
                bpl.s   moveonedown
                rts

altdownarrow:
                cmpi.w  #1,arrowrepcounter
                bpl.s   moveonedown
                rts

moveonedown:
                clr.w   arrowrepcounter
                move.w  #$FFFF,arrowpressed
                tst.l   runmode
                bne     return1
                addq.w  #1,scrpattpos
                andi.w  #$3F,scrpattpos
                bra     setscrpatternpos

editmovedown:
                tst.l   runmode
                bne     return1
                move.w  editmoveadd,D0
                add.w   D0,scrpattpos
                andi.w  #$3F,scrpattpos
                bra     setscrpatternpos

editmoveadd:    DC.W 1

rightarrow:
                tst.w   arrowpressed
                beq.s   moveoneright
                addq.w  #1,arrowrepcounter
                cmpi.w  #6,arrowrepcounter
                bpl.s   moveoneright
                rts

patternoneup:
                addq.l  #1,patternnumber
                andi.l  #$3F,patternnumber
                bsr     wait_4000
                bra     redrawpattern

moveoneright:
                clr.w   arrowrepcounter
                move.w  #$FFFF,arrowpressed
                addq.w  #1,pattcurpos
                cmpi.w  #24,pattcurpos
                bmi.s   morskip
                clr.w   pattcurpos
morskip:        bra.s   updatecursorpos

leftarrow:
                tst.w   arrowpressed
                beq.s   moveoneleft
                addq.w  #1,arrowrepcounter
                cmpi.w  #6,arrowrepcounter
                bpl.s   moveoneleft
                rts

patternonedown:
                subq.l  #1,patternnumber
                andi.l  #$3F,patternnumber
                bsr     wait_4000
                bra     redrawpattern

moveoneleft:
                clr.w   arrowrepcounter
                move.w  #$FFFF,arrowpressed
                subq.w  #1,pattcurpos
                tst.w   pattcurpos
                bpl     updatecursorpos
                move.w  #23,pattcurpos
updatecursorpos:
                tst.w   samscrenable
                bne     return1
                move.w  pattcurpos,D0
                lea     cursorpostable,A0
                move.b  0(A0,D0.w),D0
                lsl.w   #3,D0
                add.w   #9,D0
                move.w  #$BD,D1
                movem.w D0-D1,cursxy    ;;
                moveq   #14,D2          ; 14 lines
                lea     cursorspritedata,A0
                bra     setspritepos

arrowkeys2:
                move.b  rawkeycode,D0
                cmp.b   #76,D0
                beq.s   uparrow2
                cmp.b   #77,D0
                beq.s   downarrow2
                cmp.b   #79,D0
                beq.s   leftarrow2
                cmp.b   #78,D0
                beq     rightarrow2
                rts

uparrow2:
                cmpi.w  #2,currscreen
                beq     helpup
                cmpi.w  #3,currscreen
                beq     filenameoneup
;                cmpi.w  #4,currscreen
;                beq     ped_oneup
;                cmpi.w  #6,currscreen
;                beq     plstoneup
                rts

downarrow2:
                cmpi.w  #2,currscreen
                beq     helpdown
                cmpi.w  #3,currscreen
                beq     filenameonedown
;                cmpi.w  #4,currscreen
;                beq     ped_onedown
;                cmpi.w  #6,currscreen
;                beq     plstonedown
                rts

leftarrow2:
                tst.w   shiftkeystatus
                bne     positiondown
                tst.w   altkeystatus
                bne     patternonedown
                tst.w   ctrlkeystatus
                bne     samplenumdown
                cmpi.w  #2,currscreen
                beq     helpleft
                rts

rightarrow2:
                tst.w   shiftkeystatus
                bne     positionup
                tst.w   altkeystatus
                bne     patternoneup
                tst.w   ctrlkeystatus
                bne     samplenumup
                cmpi.w  #2,currscreen
                beq     helpright
                rts

;---- Update Line Cursor Position ----

updatelinecurpos:
                move.w  linecurx,D0
                move.w  linecury,D1
                subq.w  #1,D0
                moveq   #2,D2
                lea     linecurspritedata,A0
                bra     setspritepos

;---- Check Gadgets ----

checkgadgets:
                bsr.s   checkgadgets2
                clr.w   notogfl
                cmpi.w  #$FFFF,gadgrepeat
                beq.s   cgrepeat
                moveq   #0,D0
cgloop:         addq.l  #1,D0
                tst.b   hhflag
                beq.s   cgnorma
                cmp.l   #40000*5/4,D0
                beq.s   cgrepeat
                bra.s   cgnorm2
cgnorma:        cmp.l   #40000/4,D0
                beq.s   cgrepeat
cgnorm2:
;               BTST    #6,$BFE001
;               BEQ.S   cgloop
                btst    #2,mousebut     ;;
                bne.s   cgloop          ;;

                clr.w   upordown
                bra     mainloop

cgrepeat:
                tst.b   hhflag
                beq.s   cgrepe2
                bsr     wait_4000
cgrepe2:        move.w  #$FFFF,gadgrepeat
;               BTST    #6,$BFE001
;               BEQ.S   CheckGadgets
                btst    #2,mousebut     ;;
                bne.s   checkgadgets    ;;

                clr.w   gadgrepeat
                clr.w   upordown
                bra     mainloop

checkgadgets2:
                move.w  mousex,mousex2
                bne.s   cgskip
                tst.w   mousey
                bne.s   cgskip
chkquit:        lea     quitpttext,A0
                bsr     areyousure
                beq     exitcleanup     ; Quit PT!
                rts
cgskip:         move.w  mousey,mousey2
;                cmpi.w  #4,currscreen
;                beq     checkpresedgadgs
                move.w  mousex2,D0
                move.w  mousey2,D1
                cmp.w   #122,D1
                bhs     wantedpattgadg
                cmp.w   #111,D1
                bhs     checksmplnamorload
                cmp.w   #100,D1
                bhs     typeinsongname
                cmp.w   #120,D0
                blo.s   cgskip2
;                cmpi.w  #6,currscreen
;                beq     checkplstgadgs
cgskip2:        cmpi.w  #2,currscreen
                beq     return1
                cmpi.w  #3,currscreen   ; Screen 3 is DirScreen...
                beq     checkdirgadgets
                cmpi.w  #5,currscreen
                beq     checksetupgadgs
                cmpi.w  #7,currscreen
                beq     checksetup2gadgs
                cmp.w   #45,D1
                bhs.s   cgskip3
                cmp.w   #306,D0
                bhs     checktoggle
                cmp.w   #244,D0
                bhs.s   mainmenu3
                cmp.w   #181,D0
                bhs.s   mainmenu2
                cmp.w   #120,D0
                bhs     mainmenu1
cgskip3:        cmp.w   #120,D0
                bhs.s   cgskip4
                cmp.w   #109,D0
                bhs     downgadgets
                cmp.w   #98,D0
                bhs     upgadgets
                cmp.w   #62,D0
                bhs     enternumgadg
                bra     posinsdelgadgs
cgskip4:        tst.b   edenable
                bne     checkeditopgadgs
                bra     toggleanascope

mainmenu3:
                move.w  mousey2,D0
                cmp.w   #34,D0
                bhs     dpmgfih
                cmp.w   #23,D0
                bhs     setup
                cmp.w   #12,D0
                bhs     preseteditor
                tst.w   D0
                bhs     plst
                rts

dpmgfih:        jmp     samplerscreen

mainmenu2:
                move.w  mousey2,D0
                cmpi.w  #3,currscreen
                bne     mm2skip
                cmp.w   #44,D0
                bhs     checkdirgadgets2
mm2skip:        cmp.w   #44,D0
                bhs     return1
                cmp.w   #34,D0
                bhs     showdirscreen
                cmp.w   #23,D0
                bhs     doeditop
                cmp.w   #12,D0
                bhs     clearall
                tst.w   D0
                bhs     stopit
                rts

mainmenu1:
                move.w  mousey2,D0
                cmpi.w  #3,currscreen
                bne.s   mm1skip
                cmp.w   #44,D0
                bhs     checkdirgadgets2
mm1skip:        cmp.w   #44,D0
                bhs     return1
                cmp.w   #34,D0
                bhs     recordpattern
                cmp.w   #23,D0
                bhs     edit
                cmp.w   #12,D0
                bhs     playpattern
                tst.w   D0
                bhs     playsong
                rts

;---- Disk Format ----

diskformatgadg:
                bra     shownotimpl

;---- Clear All Data ----

clearall:
                addi.l  #1,lahetx
                move.b  disableanalyzer,saveda
                move.b  scopeenable,savescope
                sf      scopeenable
                lea     pleaseselecttext,A0
                bsr     showstatustext
                bsr     storeptrcol
                bsr     setwaitptrcol
                bsr     wait_4000
                cmpi.w  #1,currscreen
                bne.s   clbskip
                tst.b   disableanalyzer
                bne.s   clbskip
                st      disableanalyzer
                bsr     clearanaheights
                bsr     clearrightarea
clbskip:        lea     clearboxdata,A1
                bsr     swapboxmem
                bsr     waitforbuttonup
                bsr     wait_4000
clearbuttoncheck:
;                btst    #2,$DFF016
;                beq     clrcancel
                btst    #0,mousebut
                bne     clrcancel
;                bsr     dokeybuffer
                move.b  rawkeycode,D0
                cmp.b   #33,D0          ; Pressed S
                beq     clrsamples
                cmp.b   #24,D0          ; Pressed O
                beq     clrsong
                cmp.b   #32,D0          ; Pressed A
                beq     clrall
                cmp.b   #51,D0          ; Pressed C
                beq     clrcancel
                cmp.b   #69,D0          ; Pressed Esc
                beq     clrcancel
;                btst    #6,$BFE001      ; Left Mousebutton
;                bne.s   clearbuttoncheck
                btst    #2,mousebut
                beq     clearbuttoncheck

                movem.w mousex,D0-D1
                cmp.w   #166,D0
                blo.s   clearbuttoncheck
                cmp.w   #257,D0
                bhi.s   clearbuttoncheck
                cmp.w   #58,D1
                blo.s   clearbuttoncheck
                cmp.w   #84,D1
                bhi.s   clearbuttoncheck
                cmp.w   #204,D0
                bhs.s   samporcancel
                cmp.w   #198,D0
                bls.s   songorall
                bra.s   clearbuttoncheck

songorall:
                cmp.w   #74,D1
                bhs.s   clrall
                cmp.w   #68,D1
                bls     clrsong
                bra     clearbuttoncheck

samporcancel:
                cmp.w   #74,D1
                bhs.s   clrcancel
                cmp.w   #68,D1
                bls.s   clrsamples
                bra     clearbuttoncheck

removeclearbox:
                lea     clearboxdata,A1
                bsr     swapboxmem
                bsr     showallright
                bsr     clearanaheights
                move.b  saveda,disableanalyzer
                move.b  savescope,scopeenable
                bsr     restoreptrcol
                clr.b   rawkeycode
                rts

clrcancel:
                bsr.s   removeclearbox
                bra     seterrorptrcol

clrall:         bsr     doclearsong
                bsr     clrsampleinfo
                bsr     setnormalptrcol
                bsr.s   removeclearbox
                bra     displaymainall

clrsamples:
                bsr.s   removeclearbox
                bsr     stopit
                bsr     clrsampleinfo
                bsr     setnormalptrcol
                sf      edenable
                move.w  #1,insnum
                bra     displaymainall

clrsong:        bsr.s   removeclearbox
                bsr     doclearsong
                bsr     setnormalptrcol
                bra     displaymainall

clrsampleinfo:
                bsr     givebackinstrmem
                movea.l songdataptr,A0
                lea     sd_sampleinfo(A0),A0
                move.w  #31*30-1,D0
csiloop:        clr.b   (A0)+
                dbra    D0,csiloop
                movea.l songdataptr,A1
                lea     sd_sampleinfo(A1),A1
                moveq   #30,D0
caloop2:        move.w  #1,28(A1)
                lea     30(A1),A1
                dbra    D0,caloop2
                lea     samplelengthadd(PC),A3
                moveq   #31,D0
csilop2:        clr.w   (A3)+
                dbra    D0,csilop2
                jmp     redrawsample

doclearsong:
                bsr     stopit
                clr.b   rawkeycode
                movea.l songdataptr,A0
                movea.l A0,A1
                moveq   #19,D0
docla2x:        clr.b   (A0)+
                dbra    D0,docla2x
                movea.l A1,A2
                adda.l  #70716,A2
                adda.l  #950,A1
                moveq   #0,D0
caloop:         move.w  D0,(A1)+
                cmpa.l  A1,A2
                bne.s   caloop
                movea.l songdataptr,A0
                move.w  #$017F,sd_numofpatt(A0)
                move.l  #'M.K.',sd_mahokakt(A0) ; M.K. all the way...
                sf      edenable
                clr.l   currpos
                clr.l   songposition
                clr.l   patternposition
                clr.l   patternptr
                clr.l   timerticks
                clr.w   blockmarkflag
                clr.b   metrochannel
                move.w  #1,editmoveadd
                moveq   #0,D0
                move.w  defaultspeed,D0
                move.l  D0,currspeed
                move.w  tempo,realtempo
                bsr     settempo
                bsr     restoreeffects2
                bsr     restorefkeypos2
                bsr     unmuteall
                move.w  #1,insnum
                move.l  #6,currspeed
                clr.l   patternnumber
                clr.w   scrpattpos
                bsr     setscrpatternpos
                bra     redrawpattern

unmuteall:
                move.w  #1,audchan1toggle
                move.w  #1,audchan2toggle
                move.w  #1,audchan3toggle
                move.w  #1,audchan4toggle
                move.w  #$0F,activechannels
                bra     redrawtoggles

togglemute:
                clr.b   rawkeycode
                tst.w   shiftkeystatus
                beq     tomuskp
                clr.w   audchan1toggle
                clr.w   audchan2toggle
                clr.w   audchan3toggle
                clr.w   audchan4toggle
tomuskp:        moveq   #0,D0
                move.w  pattcurpos,D0
                divu    #6,D0
                mulu    #11,D0
                addq.w  #4,D0
                bra     dotogglemute

restoreeffects:
                moveq   #0,D0
                move.w  defaultspeed,D0
                move.l  D0,currspeed
                move.w  tempo,realtempo
                bsr     settempo
                bsr.s   restoreeffects2
                clr.b   rawkeycode
                lea     efxrestoredtext(PC),A0
                bsr     showstatustext
                bsr     waitalittle
                bra     showallright

restoreeffects2:
                lea     audchan1temp,A0
                bsr.s   reefsub
                lea     audchan2temp,A0
                bsr.s   reefsub
                lea     audchan3temp,A0
                bsr.s   reefsub
                lea     audchan4temp,A0
reefsub:        clr.b   n_wavecontrol(A0)
                clr.b   n_glissfunk(A0)
                clr.b   n_finetune(A0)
                clr.b   n_loopcount(A0)
                rts

restorefkeypos:
                clr.b   rawkeycode
                lea     posrestoredtext(PC),A0
                bsr     showstatustext
                bsr     waitalittle
                bsr     showallright
restorefkeypos2:
                move.w  #0,f6pos
                move.w  #16,f7pos
                move.w  #32,f8pos
                move.w  #48,f9pos
                move.w  #63,f10pos
                rts

efxrestoredtext:DC.B 'efx restored !',0
posrestoredtext:DC.B 'pos restored !',0


givebackinstrmem:
                moveq   #1,D7
                movea.l 4.w,A6
gbimloop:
                move.w  D7,D2
                lsl.w   #2,D2
                lea     sampleptrs,A0
                move.l  0(A0,D2.w),D1
                beq.s   gbimskip
                move.l  124(A0,D2.w),D0
                clr.l   0(A0,D2.w)
                clr.l   124(A0,D2.w)
                movea.l D1,A1
                jsr     lvofreemem
gbimskip:
                addq.w  #1,D7
                cmp.w   #32,D7
                bne.s   gbimloop
                move.w  #1,updatefreemem
                jmp     freecopybuf


                PART 'setup'



;---- Setup ----



setup:          cmpi.w  #7,lastsetupscreen
                beq     setup2
                clr.w   lastsetupscreen
                bsr     waitforbuttonup
                move.w  #5,currscreen
                sf      showrainbowflag
                st      disableanalyzer
                st      nosampleinfo
                bsr     clear100lines
                bsr     showsetupscreen
;               beq     exitsetup       ;; hide pointer prob
refreshsetup:
                bsr     setscreencolors
                bsr     show_ms
                cmpi.w  #5,currscreen
                bne     return1
                bsr     markcolor
                bsr     showsetuptoggles
                bsr     showsplit
                bsr     showprintpath
                bsr     showkeyrepeat
                bsr     showextcommand
                bsr     showmultisetup
                bsr     showconfignumber
                bsr     showaccidental  ; Always last (redraws pattern) !
                rts

showsetupscreen:
                move.l  setupmemptr,D0
                bne     decompactsetup
                bsr.s   savemainpic
                tst.l   setupmemptr
                beq     return1
                bra     decompactsetup

savemainpic:
                move.l  #8000,D0
                moveq   #memf_public,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,setupmemptr
                beq     outofmemerr
                movea.l D0,A1
                movea.l log_base,A0
                moveq   #99,D0
sssloop2:
i               SET 0
                REPT 20
                move.l  i(A0),(A1)+
i               SET i+16
                ENDR
                lea     320(A0),A0
                dbra    D0,sssloop2
                rts

restoremainpic:
                move.l  setupmemptr,D0
                beq     return1
                movea.l D0,A1
                movea.l log_base,A0
                moveq   #99,D0
ssxloop2:
i               SET 0
                REPT 20
                move.l  (A1)+,i(A0)
i               SET i+16
                ENDR
                lea     320(A0),A0
                dbra    D0,ssxloop2
                movea.l setupmemptr,A1
                clr.l   setupmemptr
                move.l  #8000,D0
                movea.l 4.w,A6
                jmp     lvofreemem

setupmemptr:    DC.L 0

decompactsetup2:
                lea     setup2data,A0
                bra.s   decoset

decompactsetup:
                lea     setupscreendata,A0
decoset:
                movea.l log_base,A1     ;;
                moveq   #99,D1
i               SET 0
.decsetlp:
                REPT 20
                move.l  (A0)+,i(A1)
i               SET i+16
                ENDR
                lea     320(A1),A1
                dbra    D1,.decsetlp
                moveq   #-1,D0
                rts

; Gadgets

checksetupgadgs:
                tst.l   splitaddress
                beq.s   csgskip
                clr.l   splitaddress
                bsr     showsplit
csgskip:        movem.w mousex2,D0-D1
                cmp.w   #210,D0
                bhs     setupmenu3
                cmp.w   #108,D0
                bhs.s   setupmenu2
;---- Menu 1 ----
                cmp.w   #11,D1
                bls     loadconfig
                cmp.w   #22,D1
                bls     saveconfig
                cmp.w   #33,D1
                bls     resetall
                cmp.w   #44,D1
                bls     extcommand
                cmp.w   #55,D1
                bls     multisetup
                cmp.w   #66,D1
                bls     setred
                cmp.w   #77,D1
                bls     setgreen
                cmp.w   #88,D1
                bls     setblue
                cmp.w   #99,D1
                bls     colorgadgets
                rts

setupmenu2:
                cmp.w   #11,D1
                bls     return1
                cmp.w   #55,D1
                bls     setsplit
                cmp.w   #66,D1
                bls     setkeyrepeat
                cmp.w   #77,D1
                bls     toggleaccidental
                cmp.w   #88,D1
                bls     printsong
                cmp.w   #99,D1
                bls     enterprintpath
                rts

setupmenu3:
                cmp.w   #11,D1
                bls.s   exitorclear
                cmp.w   #22,D1
                bls     togglesplit
                cmp.w   #33,D1
                bls     togglefilter
                cmp.w   #44,D1
                bls     toggletransdel
                cmp.w   #55,D1
                bls     toggleshowdec
                cmp.w   #66,D1
                bls     toggleautodir
                cmp.w   #77,D1
                bls     toggleautoexit
                cmp.w   #88,D1
                bls     togglemodonly
                cmp.w   #99,D1
                bls     togglemidi
                rts

exitorclear:
                cmp.w   #265,D0
                bls     clearsplit
                cmp.w   #306,D0
                bhs     setup2
exitsetup:
                bsr     waitforbuttonup
                move.w  currscreen,lastsetupscreen
                clr.b   rawkeycode
                clr.l   splitaddress
                bsr     clear100lines
                bsr     restoremainpic
                sf      nosampleinfo
                sf      showrainbowflag
                bsr     setupvucols
                bsr     setupanacols
                bra     displaymainall

lastsetupscreen:DC.W 0

togglesplit:
                eori.b  #1,splitflag
                bra     showsetuptoggles

togglefilter:
                bra     shownotimpl

;                bchg    #1,$BFE001
                bra     showsetuptoggles

toggletransdel:
                eori.b  #1,transdelflag
                bra.s   showsetuptoggles

toggleshowdec:
                eori.b  #1,showdecflag
                move.w  #1,updatefreemem
                bra.s   showsetuptoggles

toggleautodir:
                eori.b  #1,autodirflag
                bra.s   showsetuptoggles

toggleautoexit:
                eori.b  #1,autoexitflag
                bra.s   showsetuptoggles

togglemodonly:
                eori.b  #1,modonlyflag
                lea     filenamesptr(PC),A0
                clr.l   4(A0)
                bra.s   showsetuptoggles

togglemidi:
                bra     shownotimpl

clearsplit:
                bsr     waitforbuttonup
                lea     clearsplittext,A0
                bsr     areyousure
                bne     return1
                lea     splitdata,A0
                moveq   #15,D0
clsploop:
                clr.b   (A0)+
                dbra    D0,clsploop
                bra     showsplit

showsetuptoggles:
                clr.b   rawkeycode
                bsr     show_ms
                cmpi.w  #5,currscreen
                bne     return1
;                move.b  $BFE001,D0
                lsr.b   #1,D0
                and.b   #1,D0
                eori.b  #1,D0
                move.b  D0,filterflag
                lea     splitflag,A4
                move.w  #3,textlength
                moveq   #7,D7
                move.w  #636,D6
sstloop:
                move.w  D6,textoffset
                lea     toggleofftext(PC),A0
                tst.b   (A4)+
                beq.s   sstskip
                lea     toggleontext(PC),A0
sstskip:
                bsr     showtext2
                add.w   #440,D6
                dbra    D7,sstloop
                bra     waitforbuttonup

toggleontext2:  DC.B ' '
toggleontext:   DC.B 'on '
toggleofftext:  DC.B 'off '

showsplit:
                bsr     calculatesplit
                cmpi.w  #5,currscreen
                bne     return1
                lea     splitdata,A3
                movea.l notenamesptr,A4
                moveq   #0,D5
                move.w  #614,D6
                clr.w   wordnumber
shsploop:
                move.w  D6,textoffset
                move.b  0(A3,D5.w),wordnumber+1 ; instr
                bsr     printhexbyte
                addq.w  #4,D6
                move.w  D6,D1
                moveq   #0,D0
                move.b  1(A3,D5.w),D0   ; note
                lsl.w   #2,D0
                lea     0(A4,D0.w),A0
                moveq   #4,D0
                bsr     showtext3
                addq.l  #5,D6
                move.w  D6,D1
                moveq   #0,D0
                move.b  2(A3,D5.w),D0   ; trans
                lsl.w   #2,D0
                lea     0(A4,D0.w),A0
                moveq   #4,D0
                bsr     showtext3
                add.w   #431,D6
                addq.w  #4,D5
                cmp.w   #16,D5
                bne.s   shsploop
                rts

calculatesplit:
                lea     splittranstable,A0
                lea     splitinstrtable,A1
                lea     splitdata,A2
                moveq   #0,D0
casploop:
                move.b  D0,0(A0,D0.w)
                clr.b   0(A1,D0.w)
                addq.w  #1,D0
                cmp.w   #37,D0
                bls.s   casploop

                move.b  1(A2),-(SP)
                move.b  1+4(A2),-(SP)
                move.b  1+8(A2),-(SP)
                move.b  1+12(A2),-(SP)  ; note

                moveq   #3,D4
caspbigloop:
                moveq   #127,D0
                moveq   #0,D1
                moveq   #0,D2
casploop2:
                cmp.b   1(A2,D1.w),D0   ; note
                bls.s   caspskip
                move.l  D1,D2
                move.b  1(A2,D1.w),D0   ; note
caspskip:
                addq.w  #4,D1
                cmp.w   #16,D1
                bne.s   casploop2

                moveq   #0,D0
                move.b  1(A2,D2.w),D0   ; note
                move.b  #127,1(A2,D2.w) ; note
                move.b  2(A2,D2.w),D1   ; trans
casploop3:
                move.b  D1,0(A0,D0.w)
                move.b  0(A2,D2.w),0(A1,D0.w) ; instr
                addq.w  #1,D1
                cmp.w   #36,D1
                blo.s   caspskip2
                moveq   #35,D1
caspskip2:
                addq.w  #1,D0
                cmp.w   #36,D0
                blo.s   casploop3
                dbra    D4,caspbigloop

                move.b  (SP)+,1+12(A2)
                move.b  (SP)+,1+8(A2)
                move.b  (SP)+,1+4(A2)
                move.b  (SP)+,1(A2)     ; note
                rts

setsplit:
                lea     splitdata,A2
                subq.w  #1,D1
                divu    #11,D1
                subq.w  #1,D1
                move.w  D1,D7
                lsl.w   #2,D7
                mulu    #440,D1
                add.w   #600,D1
                cmp.w   #176,D0
                bhs.s   setsplittranspose
                cmp.w   #136,D0
                bhs.s   setsplitnote
                add.w   #14,D1
                move.w  D1,textoffset
                bsr     gethexbyte
                cmp.b   #$1F,D0
                bls.s   setskip
                move.b  #$1F,D0
setskip:        move.b  D0,0(A2,D7.w)   ; instr
                bra     showsplit

setsplitnote:
                move.l  D1,-(SP)
                bsr     showsplit
                move.l  (SP)+,D1
                add.w   #18,D1
                moveq   #3,D0
                lea     spcnotetext,A0
                bsr     showtext3
                lea     1(A2,D7.w),A0   ; note
                move.l  A0,splitaddress
                bra     waitforbuttonup

setsplittranspose:
                move.l  D1,-(SP)
                bsr     showsplit
                move.l  (SP)+,D1
                add.w   #23,D1
                moveq   #3,D0
                lea     spcnotetext,A0
                bsr     showtext3
                lea     2(A2,D7.w),A0   ; trans
                move.l  A0,splitaddress
                bra     waitforbuttonup

setkeyrepeat:
                cmp.w   #188,D0
                bhs.s   skrep2
                move.w  #2381,textoffset
                bsr     gethexbyte
                move.b  D0,keyrepdelay+1
                bra.s   showkeyrepeat
skrep2:         move.w  #2384,textoffset
                bsr     gethexbyte
                move.b  D0,keyrepspeed+1
showkeyrepeat:
                move.w  #2381,textoffset
                move.w  keyrepdelay,wordnumber
                bsr     printhexbyte
                addq.w  #1,textoffset
                move.w  keyrepspeed,wordnumber
                bra     printhexbyte

toggleaccidental:
                move.l  #notenames1,notenamesptr
                eori.b  #1,accidental
                beq.s   showaccidental
                move.l  #notenames2,notenamesptr
showaccidental:
                lea     accidentaltext(PC),A0
                tst.b   accidental
                beq.s   shacskp
                lea     accidentaltext+1(PC),A0
shacskp:        moveq   #1,D0
                move.w  #2824,D1
                bsr     showtext3
                bra     redrawpattern

accidentaltext: DC.B '#¡'

loadconfig:
                cmp.w   #84,D0
                bhs     setconfignumber
                lea     loadconfigtext,A0
                bsr     areyousure
                bne     return1
                bsr     waitforbuttonup
                lea     loadingcfgtext(PC),A0
                bsr     showstatustext
doloadconfig:
                bsr     storeptrcol
                bsr     putconfignumber
                move.l  #configname,D1
                move.l  #1005,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,D7
                bne.s   cfgopok
                lea     ptpath,A0
                bsr     copypath
                lea     configname(PC),A0
                moveq   #12,D0
cfgnlop:        move.b  (A0)+,(A1)+
                dbra    D0,cfgnlop
                move.l  #filename,D1
                move.l  #1005,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,D7
                beq.s   configerr
cfgopok:        bsr     setdiskptrcol
                move.l  D7,D1
                clr.l   configid
                move.l  #configid,D2
                move.l  #4,D3
                jsr     lvoread         ;;
                cmpi.l  #"PT2.",configid
                bne.s   cfgerr2
                lea     setupdata+4,A0
                move.l  D7,D1
                move.l  A0,D2
                move.l  #configfilesize-4,D3
                jsr     lvoread         ;;
lcfgend:        move.l  D7,D1
                jsr     lvoclose        ;;
                bsr     showallright
                bsr     restoreptrcol
                bsr     copycfgdata
                bsr     changecoplist
                bra     refreshsetup

configerr:
                bset    #2,initerror
                lea     filenotfoundtext(PC),A0
cferr:          bsr     showstatustext
                move.w  #50,waittime
                bra     errorrestorecol

cfgerr2:        bsr.s   configerr2
                bra.s   lcfgend

configerr2:
                bset    #3,initerror
                lea     notaconffiletext(PC),A0
                bra.s   cferr

configerr3:
                lea     cantcreatefitext(PC),A0
                bra.s   cferr

filenotfoundtext:DC.B "config not found!",0
notaconffiletext:DC.B "not a config file",0
cantcreatefitext:DC.B "can't create file",0

saveconfig:
                cmp.w   #84,D0
                bhs     setconfignumber
                lea     saveconfigtext,A0
                bsr     areyousure
                bne     return1
                bsr     storeptrcol
                bsr     setdiskptrcol
                bsr     putconfignumber
                lea     savingcfgtext(PC),A0
                bsr     showstatustext
                movea.l dosbase,A6
                lea     ptpath,A0
                bsr     copypath
                lea     configname(PC),A0
                moveq   #12,D0
cfgllop:        move.b  (A0)+,(A1)+
                dbra    D0,cfgllop
                move.l  #filename,D1
                move.l  #1006,D2
                jsr     lvoopen         ;;
                move.l  D0,D7
                beq     configerr3
                move.l  D0,D1
                move.l  #setupdata,D2
                move.w  #configfilesize,D3
                jsr     lvowrite        ;;
                move.l  D7,D1
                jsr     lvoclose        ;;
                bsr     showallright
                bra     restoreptrcol

setconfignumber:
                move.w  #611,textoffset
                bsr     gethexbyte
                move.w  D0,confignumber
showconfignumber:
                move.w  #611,textoffset
                move.w  confignumber(PC),wordnumber
                bra     printhexbyte

putconfignumber:
                move.w  confignumber(PC),D0
                lea     configname+8(PC),A0
                bra     inttohex2

configname:     DC.B 'ptf30---.cfg',0,0,0,0,0
                EVEN
confignumber:   DC.W 0
loadingcfgtext: DC.B 'loading config',0
savingcfgtext:  DC.B 'saving config',0,0
                EVEN
configid:       DC.L 0

resetall:
                lea     resetalltext,A0
                bsr     areyousure
                bne     return1
doresetall:
                lea     defaultsetupdata,A0
                lea     setupdata,A1
                move.w  #configfilesize-1,D0
rsaloop:        move.b  (A0)+,(A1)+
                dbra    D0,rsaloop
                bra     refreshsetup

extcommand:
                bra     shownotimpl

                rts

showextcommand:
                rts

excolab:
                rts

excorun:
                rts

winderr:
                rts

multisetup:
                cmp.w   #44,D0
                blo     return1
                bsr     storeptrcol
                bsr     setwaitptrcol
                move.w  #1,getlineflag
                sub.w   #44,D0
                lsr.w   #4,D0
                move.b  D0,musepos
museset:        moveq   #0,D0
                move.b  musepos,D0
                move.l  D0,D1
                lsl.w   #4,D1
                move.w  #52,linecurx
                move.w  #53,linecury
                add.w   D1,linecurx
                lea     multimodenext,A1
                lea     0(A1,D0.w),A1
                bsr     updatelinecurpos
muselop:        bsr     gethexkey
                tst.b   D1
                beq.s   musenul
                cmp.b   #4,D1
                bhi.s   muselop
                move.b  D1,(A1)
                bsr     showmultisetup
                moveq   #1,D0
musenul:        tst.b   D0
                beq.s   museabo
                add.b   D0,musepos
                andi.b  #3,musepos
                bsr     wait_4000
                bsr     wait_4000
                bsr     wait_4000
                bra.s   museset

museabo:        bsr     restoreptrcol
                clr.w   getlineflag
                move.w  #0,linecurx
                move.w  #270,linecury
                bsr     updatelinecurpos
showmultisetup:
                move.w  #1926,textoffset
                move.b  multimodenext,D0
                bsr     printhexdigit
                move.w  #1928,textoffset
                move.b  multimodenext+1,D0
                bsr     printhexdigit
                move.w  #1930,textoffset
                move.b  multimodenext+2,D0
                bsr     printhexdigit
                move.w  #1932,textoffset
                move.b  multimodenext+3,D0
                bra     printhexdigit

musepos:        DC.B 0,0

setred:         cmp.w   #82,D0
                bhs     selectcolor
setr2:          bsr     getcolpos
                and.w   #$0F00,D2
                lsr.w   #8,D2
                cmp.b   D2,D0
                beq.s   setrskp
                and.w   #$FF,D1
                lsl.w   #8,D0
                or.w    D0,D1
                move.w  D1,(A0)
                bsr     showcolsliders
                bsr     setscreencolors
setrskp:
                btst    #2,mousebut
                bne.s   setr2
                rts

setgreen:
                cmp.w   #82,D0
                bhs     selectcolor
setg2:          bsr.s   getcolpos
                and.w   #$F0,D2
                lsr.w   #4,D2
                cmp.b   D2,D0
                beq.s   setgskp
                and.w   #$0F0F,D1
                lsl.w   #4,D0
                or.w    D0,D1
                move.w  D1,(A0)
                bsr     showcolsliders
                bsr     setscreencolors
setgskp:
                btst    #2,mousebut
                bne.s   setg2

                rts

setblue:        cmp.w   #82,D0
                bhs     selectcolor
setb2:          bsr.s   getcolpos
                and.w   #$0F,D2
                cmp.b   D2,D0
                beq.s   setbskp
                and.w   #$0FF0,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bsr     showcolsliders
                bsr     setscreencolors
setbskp:
                btst    #2,mousebut
                bne.s   setb2

                rts

getcolpos:
                moveq   #0,D0
                move.w  mousex,D0
                cmp.w   #26,D0
                bhs.s   gcpskp2
                moveq   #0,D0
                bra.s   gcpskip
gcpskp2:        sub.w   #26,D0
                divu    #3,D0
                and.l   #$FF,D0
                cmp.w   #15,D0
                bls.s   gcpskip
                moveq   #15,D0
gcpskip:        cmpi.w  #7,currscreen
                beq     getcoladdr
                lea     colortable,A0
                move.w  currcolor,D1
                add.w   D1,D1
                lea     0(A0,D1.w),A0
                move.w  (A0),D1
                move.w  D1,D2
                rts

showcolsliders:
                lea     colsliders(PC),A2
                movea.l log_base,A1
                lea     (82*320)+16(A1),A1
                bsr.s   gcpskip
                and.w   #$0F,D1
                bsr.s   showoneslider
                movea.l log_base,A1
                lea     (71*320)+16(A1),A1
                bsr.s   gcpskip
                and.w   #$F0,D1
                lsr.w   #4,D1
                bsr.s   showoneslider
                movea.l log_base,A1
                lea     (60*320)+16(A1),A1
                bsr.s   gcpskip
                and.w   #$0F00,D1
                lsr.w   #8,D1
showoneslider:
                clr.w   D3
i               SET 4
                REPT 3
                move.w  D3,i(A1)
                move.w  D3,i+16(A1)
                move.w  D3,i+32(A1)
                move.w  D3,i+48(A1)
i               SET i+320
                ENDR
                move.w  D1,D3
                lsl.w   #2,D3
                move.w  2(A2,D3.w),D4
                move.b  0(A2,D3.w),D2
                move.b  1(A2,D3.w),D3
                add.w   D4,D4
                movem.w cconvtab(PC,D4.w),D4-D5

                REPT 3
                move.b  D2,4(A1,D4.w)
                move.b  D3,4(A1,D5.w)
                lea     320(A1),A1
                ENDR
                rts

cconvtab:       DC.W 0,1,16,17,32,33,48,49,64,65

colsliders:
                DC.W %1111100,0
                DC.W %111110000000,1
                DC.W %111110000,1
                DC.W %111110,1
                DC.W %11111000000,2
                DC.W %11111000,2
                DC.W %11111,2
                DC.W %1111100000,3
                DC.W %1111100,3
                DC.W %111110000000,4
                DC.W %111110000,4
                DC.W %111110,4
                DC.W %11111000000,5
                DC.W %11111000,5
                DC.W %11111,5
                DC.W %1111100000,6

selectcolor:
                cmp.w   #84,D1
                bhs     return1
                movea.l log_base,A0
                lea     (60*320)+(5*16)+4(A0),A0
                moveq   #24,D2
slcloop:        clr.w   (A0)
                clr.w   16(A0)
                lea     320(A0),A0
                dbra    D2,slcloop

                sub.w   #82,D0
                divu    #13,D0
                sub.w   #60,D1
                divu    #6,D1
                move.w  D0,D2
                lsl.w   #2,D2
                add.w   D1,D2
                move.w  D2,currcolor
markcolor:
                bsr     gcpskip
                move.l  A0,undocoladdr
                move.w  D1,undocol
                bsr     showcolsliders
                bsr.s   blockcolors
                move.w  currcolor,D0
                move.w  D0,D1
                and.w   #$03,D1
                movea.l log_base,A0
                mulu    #6*320,D1
                adda.l  D1,A0
                lea     (60*320)+(5*16)+4(A0),A0
                btst    #2,D0
                bne.s   slcskip
                move.w  #$3FF0,(A0)
                move.w  #$3FF0,6*320(A0)
                moveq   #4,D0
slclop2:        lea     320(A0),A0
                move.w  #$2010,(A0)
                dbra    D0,slclop2
                bra     waitforbuttonup

slcskip:        move.w  #1,(A0)
                move.w  #$FF80,16(A0)
                move.w  #1,6*320(A0)
                move.w  #$FF80,16+(6*320)(A0)
                moveq   #4,D0
slclop3:        lea     320(A0),A0
                move.w  #1,(A0)
                move.w  #$FF80,16(A0)
                dbra    D0,slclop3
                bra     waitforbuttonup

blockcolors:
                movea.l log_base,A0
                lea     (61*320)+(6*16)+4(A0),A0
                moveq   #3,D1
suploop2:
                moveq   #4,D0
suploop3:
                move.b  #$FF,(A0)
                lea     320(A0),A0
                dbra    D0,suploop3
                lea     320(A0),A0
                dbra    D1,suploop2
                rts

colorgadgets:
                cmp.w   #79,D0
                bhs     setdefaultcol
                cmp.w   #33,D0
                bhs.s   cancelcol
                movea.l undocoladdr,A0
                move.w  undocol,D0
                move.w  (A0),undocol
                move.w  D0,(A0)
                bsr     showcolsliders
                bra     setscreencolors

cancelcol:
                lea     cancols(PC),A0
                lea     colortable,A1
                moveq   #7,D0
cacolop:        move.w  (A0)+,(A1)+
                dbra    D0,cacolop
                bsr     showcolsliders
                bra     setscreencolors

copycfgdata:
                lea     colortable,A0
                lea     cancols(PC),A1
                moveq   #7,D0
cocclop:        move.w  (A0)+,(A1)+
                dbra    D0,cocclop
                lea     modulespath2,A0
                move.w  #195,D0
cocclp2:        clr.b   (A0)+
                dbra    D0,cocclp2
                lea     modulespath,A0
                lea     modulespath2,A1
                bsr.s   cocclp3
                lea     songspath,A0
                lea     songspath2,A1
                bsr.s   cocclp3
                lea     samplepath,A0
                lea     samplepath2,A1
cocclp3:        move.b  (A0)+,(A1)+
                bne.s   cocclp3
                lea     vumetercolors,A0
                lea     savecolors,A1
                moveq   #40+48-1,D0
cocclp4:        move.w  (A0)+,(A1)+
                dbra    D0,cocclp4
                rts

undocol:        DC.W 0
undocoladdr:    DC.L 0
cancols:        DC.W 0,0,0,0,0,0,0,0

setdefaultcol:
                lea     defcol,A0
                lea     colortable,A1
                moveq   #7,D0
sdcloop:        move.w  (A0)+,(A1)+
                dbra    D0,sdcloop
                bsr     showcolsliders
setscreencolors:
                bsr     setupanacols
setscreencolors2:
                lea     colortable,A0
                lea     copcol0,A1
                move.w  (A0),(A1)
                move.w  2(A0),4(A1)
                move.w  4(A0),8(A1)
                move.w  6(A0),12(A1)
                move.w  8(A0),16(A1)
                move.w  10(A0),20(A1)
                move.w  12(A0),24(A1)
                move.w  14(A0),28(A1)
                move.w  14(A0),D0
                tst.w   samscrenable
                beq.s   sscnosc
                move.w  8(A0),D0
sscnosc:        move.w  D0,notecol
                move.w  10(A0),D0
                move.w  D0,D4
                move.w  #3,fadex
                bsr.s   fadecol
                move.w  D0,32(A1)
                move.w  D4,36(A1)
                move.w  D4,D0
                move.w  #-3,fadex
                bsr.s   fadecol
                move.w  D0,40(A1)
                rts

fadecol:        move.w  D0,D1
                move.w  D0,D2
                move.w  D0,D3
                lsr.w   #8,D1
                add.w   fadex(PC),D1
                bpl.s   redskp
                moveq   #0,D1
redskp:         cmp.w   #15,D1
                bls.s   redskp2
                moveq   #15,D1
redskp2:        and.w   #$F0,D2
                lsr.w   #4,D2
                add.w   fadex(PC),D2
                bpl.s   grnskp
                moveq   #0,D2
grnskp:         cmp.w   #15,D2
                bls.s   grnskp2
                moveq   #15,D2
grnskp2:        and.w   #$0F,D3
                add.w   fadex(PC),D3
                bpl.s   bluskp
                moveq   #0,D3
bluskp:         cmp.w   #15,D3
                bls.s   bluskp2
                moveq   #15,D3
bluskp2:        move.w  D3,D0
                lsl.w   #4,D2
                or.w    D2,D0
                lsl.w   #8,D1
                or.w    D1,D0
                rts

currcolor:      DC.W 0
fadex:          DC.W -3

enterprintpath:
                bra     shownotimpl

                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     printpath,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #31,textendptr
                move.w  #12,textlength
                movea.w #3694,A4
                bsr     gettextline
                bra     restoreptrcol

showprintpath:
                lea     printpath,A0
                move.w  #3694,D1
                moveq   #12,D0
                bra     showtext3

; Print Song

printsong:
                bra     shownotimpl

                lea     printsongtext,A0
                bsr     areyousure
                bne     return1
                bsr     storeptrcol
                move.l  #printpath,D1
                move.l  #1006,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq     cantopenfile
                bsr     setdiskptrcol
                lea     printingsongtext,A0
                bsr     showstatustext
                move.l  filehandle,D1
                move.l  #songdumptext,D2
                moveq   #68,D3
                movea.l dosbase,A6
                jsr     lvowrite        ;;
                move.l  filehandle,D1
                move.l  songdataptr,D2
                moveq   #20,D3
                jsr     lvowrite        ;;
                bsr     printcrlf
                bsr     printcrlf
                bsr     printsong2
                bsr     printcrlf
                bsr     printsong4
                bsr     printformfeed
                movea.l songdataptr,A0
                moveq   #0,D0
                move.b  sd_numofpatt(A0),D0
                lea     sd_pattpos(A0),A0
                moveq   #0,D7
ps_loop:        cmp.b   0(A0,D0.w),D7
                bgt.s   ps_skip
                move.b  0(A0,D0.w),D7
ps_skip:        subq.w  #1,D0
                bpl.s   ps_loop
                moveq   #0,D1
ps_loop2:
                movem.l D1-A6,-(SP)
                bsr     printpattern
                movem.l (SP)+,D1-A6
                tst.l   D0
                bne.s   ps_skip2
                movem.l D1/D7,-(SP)
                bsr     printformfeed
                movem.l (SP)+,D1/D7
                addq.w  #1,D1
                cmp.w   D7,D1
                blo.s   ps_loop2
ps_skip2:
                movea.l dosbase,A6
                move.l  filehandle,D1
                jsr     lvoclose        ;;
                bsr     showallright
                bra     restoreptrcol

printsong2:
                moveq   #1,D7
ps2_2:          move.l  D7,D0
                lsr.b   #4,D0
                cmp.b   #9,D0
                bls.s   spujk
                addq.b  #7,D0
spujk:          add.b   #'0',D0
                move.b  D0,pattxtext1
                move.b  D7,D0
                and.b   #$0F,D0
                cmp.b   #9,D0
                bls.s   spujk2
                addq.b  #7,D0
spujk2:         add.b   #'0',D0
                move.b  D0,pattxtext2

                movea.l songdataptr,A0
                move.w  D7,D0
                mulu    #30,D0
                lea     -10(A0,D0.w),A0
                lea     pptext,A1
                moveq   #21,D0
ps2_loop:
                move.b  #' ',(A1)+
                dbra    D0,ps2_loop
                lea     pptext,A1

                move.l  A0,savit
ps2_loop2:
                move.b  (A0)+,D0
                beq     printsong3
                move.b  D0,(A1)+
                bra.s   ps2_loop2

savit:          DC.L 0

printsong3:
                move.l  D7,-(SP)        ; pattnum
                movea.l savit(PC),A0
                move.w  22(A0),D0
                add.w   D0,D0
                lea     prafs+2+4,A0
                bsr     inttohexascii
                movea.l savit(PC),A0
                move.w  26(A0),D0
                add.w   D0,D0
                lea     prafs+8+4,A0
                bsr     inttohexascii
                movea.l savit(PC),A0
                move.w  28(A0),D0
                add.w   D0,D0
                lea     prafs+14+4,A0
                bsr     inttohexascii
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #ptottext,D2
                moveq   #52,D3
                jsr     lvowrite        ;;
                move.l  (SP)+,D7
                addq.w  #1,D7
                cmp.w   #$20,D7
                bne     ps2_2
                rts

printsong4:
                movea.l songdataptr,A0
                moveq   #0,D7
                move.b  sd_numofpatt(A0),D7
                lea     sd_pattpos(A0),A0
                moveq   #0,D5
ps4_loop1:
                moveq   #0,D6
ps4_loop2:
                moveq   #0,D0
                move.b  (A0)+,D0
                move.w  D0,D1
                lsr.w   #4,D1
                add.b   #$30,D1
                cmp.b   #$39,D1
                bls.s   ps4_skip
                addq.b  #7,D1
ps4_skip:
                and.b   #15,D0
                add.b   #$30,D0
                cmp.b   #$39,D0
                bls.s   ps4_skip2
                addq.b  #7,D0
ps4_skip2:
                lea     pntext,A1
                move.b  D1,(A1)+
                move.b  D0,(A1)
                movem.l D5-A0,-(SP)
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #pntext,D2
                moveq   #4,D3
                jsr     lvowrite        ;;
                movem.l (SP)+,D5-A0
                addq.w  #1,D5
                cmp.w   D5,D7
                beq     return1
                addq.w  #1,D6
                cmp.w   #$10,D6
                bne.s   ps4_loop2
                movem.l D5-A0,-(SP)
                bsr.s   printcrlf
                movem.l (SP)+,D5-A0
                bra.s   ps4_loop1

printcrlf:
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #crlf_text,D2
                moveq   #2,D3
                jsr     lvowrite        ;;
                rts

printformfeed:
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #ff_text,D2
                moveq   #1,D3
                jsr     lvowrite        ;;
                rts

printpattern:
                move.l  D1,D6           ; D1=pattern number
                divu    #10,D6
                add.b   #'0',D6
                move.b  D6,pattnumtext1
                swap    D6
                add.b   #'0',D6
                move.b  D6,pattnumtext2
                movem.l D0-A6,-(SP)
                move.l  filehandle,D1
                move.l  #patternnumtext,D2
                moveq   #18,D3
                movea.l dosbase,A6
                jsr     lvowrite        ;;
                movem.l (SP)+,D0-A6

                move.l  D1,D6
                movea.l songdataptr,A6
                lea     sd_patterndata(A6),A6
                lsl.l   #8,D6
                lsl.l   #2,D6
                adda.l  D6,A6
                clr.l   ppattpos
                moveq   #0,D6
pp_posloop:
                moveq   #0,D7
                move.w  #2,textlength
                move.l  ppattpos,D1
                lea     pattpostext,A5
                divu    #10,D1
                add.b   #'0',D1
                move.b  D1,(A5)+
                clr.w   D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,(A5)+
                addq.l  #5,A5
pp_noteloop:
                moveq   #0,D0
                moveq   #0,D1
                move.w  #3,textlength
                move.w  (A6),D1
                and.w   #$0FFF,D1
                lea     periodtable,A0
pp_findloop:
                cmp.w   0(A0,D0.l),D1
                beq     printnote
                addq.l  #2,D0
                bra.s   pp_findloop

printnote:
                add.l   D0,D0
                add.l   notenamesptr,D0
                movea.l D0,A0
                move.l  (A0),(A5)+
                cmpi.b  #'¡',-3(A5)
                bne.s   prnoxyz
                move.b  #'b',-3(A5)
prnoxyz:        addq.l  #1,A5
                moveq   #0,D0
                move.w  (A6),D0
                and.w   #$F000,D0
                lsr.w   #8,D0
                add.l   D0,D0
                lea     fasthextable,A0
                adda.l  D0,A0
                move.b  (A0),(A5)+
                moveq   #0,D0
                move.b  2(A6),D0
                add.l   D0,D0
                lea     fasthextable,A0
                adda.l  D0,A0
                move.w  (A0),(A5)+
                moveq   #0,D0
                move.b  3(A6),D0
                add.l   D0,D0
                lea     fasthextable,A0
                adda.l  D0,A0
                move.w  (A0),(A5)+
                addq.l  #4,A5
                addq.l  #4,A6
                addq.l  #1,D7
                cmp.l   #4,D7
                bne     pp_noteloop
                addq.l  #1,ppattpos
                movem.l D0-A6,-(SP)
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #pntext2,D2
                moveq   #68,D3
                jsr     lvowrite        ;;
                bsr     printcrlf
                movem.l (SP)+,D0-A6
;                btst    #2,$DFF016
;                beq.s   negativereturn

                addq.l  #1,D6
                cmp.l   #64,D6
                bne     pp_posloop
                moveq   #0,D0
                rts

negativereturn:
                moveq   #-1,D0
                rts

positivereturn:
                moveq   #0,D0
                rts


;---- Setup2 ----


setup2:         bsr     waitforbuttonup
                move.w  #7,currscreen
                clr.w   lastsetupscreen
                sf      showrainbowflag
                st      disableanalyzer
                st      nosampleinfo
                bsr     clear100lines
                move.l  setupmemptr,D0
                bne     set2skp
                bsr     savemainpic
                beq     exitsetup
set2skp:        bsr     decompactsetup2
                bsr     setscreencolors
refrsh2:        bsr     showintmode
                bsr     showtempo
                bsr     showspeed
                bsr     showcoledit
                bsr     showrainbow
                bsr     getcolpos
                bsr     showcolsliders
                bsr     shows2modules
                bsr     shows2songs
                bsr     shows2samples
                bsr     shows2ptpath
                bsr     shows2maxplst
                bsr     shows2dmawait
                bsr     shows2tunenote
                bsr     shows2salvaddr
                bra     shows2t

checksetup2gadgs:
                movem.w mousex2,D0-D1
                cmp.w   #210,D0
                bhs     setup2menu3
                cmp.w   #108,D0
                bhs.s   setup2menu2
;---- Menu 1 ----
                cmp.w   #11,D1
                bls     toggleintmode
                cmp.w   #22,D1
                bls     changetempo
                cmp.w   #33,D1
                bls     changespeed
                cmp.w   #44,D1
                bls     togglecoledit
                cmp.w   #55,D1
                bls     rotorspread
                cmp.w   #66,D1
                bls     setred2
                cmp.w   #77,D1
                bls     setgreen2
                cmp.w   #88,D1
                bls     setblue2
                cmp.w   #99,D1
                bls     colorgadgets2
                rts

setup2menu2:
                cmp.w   #11,D1
                bls     set2modpath
                cmp.w   #22,D1
                bls     set2songpath
                cmp.w   #33,D1
                bls     set2sampath
                cmp.w   #44,D1
                bls     set2ptpath
                cmp.w   #55,D1
                bls     sets2maxplst
                cmp.w   #66,D1
                bls     sets2dmawait
                cmp.w   #77,D1
                bls     sets2tunenote
                cmp.w   #88,D1
                bls     sets2salvaddr
                cmp.w   #99,D1
                bls     recoversong
                rts

setup2menu3:
                cmp.w   #11,D1
                bls     exitordefault
                cmp.w   #22,D1
                bls     toggleoverride
                cmp.w   #33,D1
                bls     togglenosamples
                cmp.w   #44,D1
                bls     toggleblankzero
                cmp.w   #55,D1
                bls     toggleshowdirs
                cmp.w   #66,D1
                bls     toggleshowpublic
                cmp.w   #77,D1
                bls     togglecuttobuf
                cmp.w   #88,D1
                bls     toggleiffloop
                cmp.w   #99,D1
                bls     togglehh
                rts

exitordefault:
                cmp.w   #265,D0
                bls.s   sets2default
                cmp.w   #306,D0
                bhs     setup
                bra     exitsetup

sets2default:
                lea     setdefaultstext(PC),A0
                bsr     areyousure
                bne     return1
                lea     defaultsetupdata,A0
                lea     songspath-setupdata(A0),A2
                lea     songspath,A1
                moveq   #95,D0
ss2dela:        move.b  (A2)+,(A1)+
                dbra    D0,ss2dela
                lea     ptpath-setupdata(A0),A2
                lea     ptpath,A1
                moveq   #31,D0
ss2delb:        move.b  (A2)+,(A1)+
                dbra    D0,ss2delb
                lea     maxplstentries-setupdata(A0),A2
                move.w  (A2),maxplstentries
                lea     dmawait-setupdata(A0),A2
                move.w  (A2),dmawait
                lea     tunenote-setupdata(A0),A2
                move.l  (A2),tunenote
                lea     salvageaddress-setupdata(A0),A2
                lea     salvageaddress,A1
                move.l  (A2)+,(A1)+
                move.l  (A2),(A1)
                bra     refrsh2

setdefaultstext:DC.B "Set defaults?",0

toggleintmode:
                bra     shownotimpl

;                bsr     resetmusicint
;                eori.b  #1,intmode
;                bsr     setmusicint
                bsr     settempo
                bsr     waitforbuttonup
showintmode:
                lea     vblanktext(PC),A0
                tst.b   intmode
                beq.s   simskip
                lea     ciatext(PC),A0
simskip:        moveq   #6,D0
                move.w  #167,D1
                bra     showtext3

vblanktext:     DC.B "VBLANK"
ciatext:        DC.B " CIA  "
                EVEN

changespeed:
                moveq   #0,D1
                cmp.w   #94,D0
                bhs.s   speeddown
                cmp.w   #80,D0
                bhs.s   speedup
                rts

speedup:        move.w  defaultspeed,D1
                addq.b  #1,D1
                cmp.b   #$FF,D1
                bls.s   spedup2
                move.w  #$FF,D1
spedup2:        move.w  D1,defaultspeed
                move.l  D1,currspeed
                bsr.s   showspeed
                bsr     wait_4000
                bra     wait_4000
showspeed:
                move.w  #608+440,textoffset
                move.w  defaultspeed,wordnumber
                jmp     printhexbyte

speeddown:
                move.w  defaultspeed,D1
                sub.b   #1,D1
                cmp.b   #1,D1
                bhs.s   spedup2
                moveq   #1,D1
                bra.s   spedup2


toggleoverride:
                eori.b  #1,overrideflag
                bra.s   shows2t
togglenosamples:
                eori.b  #1,nosamplesflag
                bra.s   shows2t
toggleblankzero:
                eori.b  #1,blankzeroflag
                bsr.s   shows2t
                bra     redrawpattern
toggleshowdirs:
                eori.b  #1,showdirsflag
                bra.s   shows2t
toggleshowpublic:
                eori.b  #1,showpublicflag
                move.w  #1,updatefreemem
                bra.s   shows2t
togglecuttobuf:
                eori.b  #1,cuttobufflag
                bra.s   shows2t
toggleiffloop:
                eori.b  #1,iffloopflag
                bra.s   shows2t
togglehh:
                eori.b  #1,hhflag

shows2t:        clr.b   rawkeycode
                cmpi.w  #7,currscreen
                bne     return1
                lea     overrideflag,A4
                move.w  #3,textlength
                moveq   #7,D7
                move.w  #636,D6
sstloop2:
                move.w  D6,textoffset
                lea     toggleofftext,A0
                tst.b   (A4)+
                beq.s   sstskip2
                lea     toggleontext,A0
sstskip2:
                bsr     showtext2
                add.w   #440,D6
                dbra    D7,sstloop2
                bra     waitforbuttonup

shows2modules:
                move.w  #177,D1
                lea     modulespath,A0
s2path:         moveq   #9,D0
                bra     showtext3

shows2songs:
                move.w  #177+440,D1
                lea     songspath,A0
                bra.s   s2path

shows2samples:
                move.w  #177+880,D1
                lea     samplepath,A0
                bra.s   s2path

shows2ptpath:
                move.w  #177+1320,D1
                lea     ptpath,A0
                bra.s   s2path


set2modpath:
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     modulespath,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #31,textendptr
                move.w  #9,textlength
                movea.w #177,A4
                bsr     gettextline
                bra     restoreptrcol

set2songpath:
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     songspath,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #31,textendptr
                move.w  #9,textlength
                movea.w #177+440,A4
                bsr     gettextline
                bra     restoreptrcol

set2sampath:
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     samplepath,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #31,textendptr
                move.w  #9,textlength
                movea.w #177+880,A4
                bsr     gettextline
                bra     restoreptrcol

set2ptpath:
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     ptpath,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #31,textendptr
                move.w  #9,textlength
                movea.w #177+1320,A4
                bsr     gettextline
                bra     restoreptrcol

sets2maxplst:
                bra     shownotimpl

                cmp.w   #199,D0
                bhs.s   s2plstd
                cmp.w   #188,D0
                bhs.s   s2plstu
                rts
s2plstu:        move.w  maxplstentries,D0
                add.w   #100,D0
                cmp.w   #9999,D0
                bls.s   s2pu
                move.w  #9999,D0
s2pu:           move.w  D0,maxplstentries
                bsr.s   shows2maxplst
                bra     wait_4000

s2plstd:        moveq   #0,D0
                move.w  maxplstentries,D0
                addq.w  #1,D0
                divu    #100,D0
                subq.w  #1,D0
                bpl.s   s2pd
                moveq   #0,D0
                bra.s   s2pu
s2pd:           mulu    #100,D0
                bra.s   s2pu

shows2maxplst:
                move.w  maxplstentries,wordnumber
                move.w  #1939,textoffset
                bra     print4decdigits

sets2dmawait:
                bra     shownotimpl

                cmp.w   #199,D0
                bhs.s   s2dwd
                cmp.w   #188,D0
                bhs.s   s2dwu
                rts
s2dwu:          move.w  dmawait,D0
                addq.w  #1,D0
;                btst    #2,$DFF016
;                bne.s   s2npu
                add.w   #9,D0
s2npu:          cmp.w   #9999,D0
                bls.s   s2du
                move.w  #9999,D0
s2du:           move.w  D0,dmawait
                bsr.s   shows2dmawait
                bra     wait_4000

s2dwd:          move.w  dmawait,D0
                subq.w  #1,D0
;                btst    #2,$DFF016
;                bne.s   s2npd
                sub.w   #9,D0
s2npd:          tst.w   D0
                bpl.s   s2du
                moveq   #0,D0
                bra.s   s2du

shows2dmawait:
                move.w  dmawait,wordnumber
                move.w  #2379,textoffset
                bra     print4decdigits

sets2tunenote:
                cmp.w   #187,D0
                bhs.s   ss2tvol
                move.w  #2820,D1
                moveq   #3,D0
                lea     spcnotetext,A0
                bsr     showtext3
                move.w  #3,samnotetype
                move.l  #tunenote,splitaddress
                bra     waitforbuttonup

shows2tunenote:
                cmpi.w  #7,currscreen
                bne     return2
                movea.l notenamesptr,A4
                move.w  tunenote,D0
                lsl.w   #2,D0
                lea     0(A4,D0.w),A0
                moveq   #4,D0
                move.w  #2820,D1
                bsr     showtext3
                move.w  ttonevol,wordnumber
                move.w  #2824,textoffset
                bra     printhexbyte

ss2tvol:        move.w  #2824,textoffset
                bsr     gethexbyte
                move.w  D0,ttonevol
                bra.s   shows2tunenote

sets2salvaddr:
                bra     shownotimpl
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     salvageaddress,A6
                move.l  A6,showtextptr
                move.l  A6,textendptr
                addi.l  #6,textendptr
                move.w  #6,textlength
                movea.w #3260,A4
                move.b  #5,entertextflag
                bsr     gettextline
                clr.b   entertextflag
                bsr     restoreptrcol
shows2salvaddr:
                lea     salvageaddress,A0
                moveq   #6,D0
                move.w  #3260,D1
                bra     showtext3

recoversong:
                bra     shownotimpl
                lea     recoversongtext(PC),A0
                bsr     areyousure
                bne     return2
                bsr     doclearsong
                bsr     clrsampleinfo
                bsr.s   findadr
                movea.l D0,A0
                movea.l songdataptr,A1
                move.l  #70716,D0
recloop:        move.b  (A0)+,(A1)+
                subq.l  #1,D0
                bne.s   recloop
                bra     redrawpattern

findadr:        lea     salvageaddress+6,A0
                bsr     hextointeger
                move.w  D0,D3
                moveq   #0,D0
                bsr     hextointeger2
                swap    D0
                or.w    D3,D0
                rts

recoversongtext:DC.B "Recover Song?",0

togglecoledit:
                cmp.w   #79,D0
                bhs     selectcolor2
                clr.w   spreadflag
                lea     vumetercolors,A0
                moveq   #48,D0
                cmpa.l  therightcolors(PC),A0
                bne.s   tced2
                lea     analyzercolors,A0
                moveq   #36,D0
tced2:          move.l  A0,therightcolors
                move.w  D0,colorsmax
                cmp.w   rainbowpos(PC),D0
                bhi.s   tced3
                clr.w   rainbowpos
tced3:          bsr     showrainbow
                bsr.s   showcoledit
                bra     waitforbuttonup
showcoledit:
                lea     cedtxt1(PC),A0
                lea     vumetercolors,A1
                cmpa.l  therightcolors(PC),A1
                beq.s   shcoed
                lea     cedtxt2(PC),A0
shcoed:         moveq   #6,D0
                move.w  #1483,D1
                bra     showtext3

cedtxt1:        DC.B "VU-MTR"
cedtxt2:        DC.B "ANALYZ"

rotorspread:
                cmp.w   #16,D0
                blo.s   rotcolup
                cmp.w   #32,D0
                blo.s   rotcoldown
                cmp.w   #79,D0
                bhs     selectcolor2
                bra     spreadcolors

rotcolup:
                clr.w   spreadflag
                movea.l therightcolors(PC),A0
                move.w  (A0),D0
                move.w  colorsmax(PC),D1
                subq.w  #2,D1
rocoup1:        move.w  2(A0),(A0)+
                dbra    D1,rocoup1
                move.w  D0,(A0)
rocoup2:        bsr     getcolpos
                bsr     showcolsliders
                bsr     showrainbow
                jmp     setupvucols

rotcoldown:
                clr.w   spreadflag
                movea.l therightcolors(PC),A0
                move.w  colorsmax(PC),D1
                adda.w  D1,A0
                adda.w  D1,A0
                move.w  -(A0),D0
                subq.w  #2,D1
rocodn1:        move.w  -2(A0),(A0)
                subq.l  #2,A0
                dbra    D1,rocodn1
                move.w  D0,(A0)
                bra.s   rocoup2

spreadcolors:
                move.w  rainbowpos,spreadfrom
                move.w  #1,spreadflag
                rts

spreadfrom:     DC.W 0
spreadflag:     DC.W 0

colorgadgets2:
                clr.w   spreadflag
                cmp.w   #79,D0
                bhs.s   setdefaultcol2
                cmp.w   #33,D0
                bhs.s   cancelcol2
                movea.l undocoladdr,A0
                move.w  undocol,D1
                move.w  (A0),undocol
                move.w  D1,(A0)
                bra     rocoup2

setdefaultcol2:
                movea.l therightcolors(PC),A0
                movea.l A0,A1
                suba.l  #setupdata,A1
                adda.l  #defaultsetupdata,A1
sedeco4:        move.w  colorsmax,D0
                bra.s   sedeco3
sedeco2:        move.w  (A1)+,(A0)+
sedeco3:        dbra    D0,sedeco2
                bra     rocoup2

cancelcol2:
                movea.l therightcolors(PC),A0
                movea.l A0,A1
                suba.l  #vumetercolors,A1
                adda.l  #savecolors,A1
                bra.s   sedeco4

getcoladdr:
                movea.l therightcolors(PC),A0
                move.w  rainbowpos,D1
                add.w   D1,D1
                lea     0(A0,D1.w),A0
                move.w  (A0),D1
                move.w  D1,D2
                rts

setred2:        cmp.w   #79,D0
                bhs     selectcolor2
set2r2:         bsr     getcolpos
                and.w   #$0F00,D2
                lsr.w   #8,D2
                cmp.b   D2,D0
                beq.s   setrsk2
                and.w   #$FF,D1
                lsl.w   #8,D0
                or.w    D0,D1
                move.w  D1,(A0)
                bsr     showcolsliders
                bsr     showrainbow
                jsr     setupvucols
setrsk2:
;                btst    #6,$BFE001
;                beq.s   set2r2
                btst    #2,mousebut
                bne.s   set2r2

                rts

setgreen2:
                cmp.w   #79,D0
                bhs     selectcolor2
set2g2:         bsr     getcolpos
                and.w   #$F0,D2
                lsr.w   #4,D2
                cmp.b   D2,D0
                beq.s   setgsk2
                and.w   #$0F0F,D1
                lsl.w   #4,D0
                or.w    D0,D1
                move.w  D1,(A0)
                bsr     showcolsliders
                bsr     showrainbow
                jsr     setupvucols
setgsk2:
;                btst    #6,$BFE001
;                beq.s   set2g2
                btst    #2,mousebut
                bne.s   set2g2

                rts

setblue2:
                cmp.w   #79,D0
                bhs.s   selectcolor2
set2b2:         bsr     getcolpos
                and.w   #$0F,D2
                cmp.b   D2,D0
                beq.s   setbsk2
                and.w   #$0FF0,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bsr     showcolsliders
                bsr     showrainbow
                jsr     setupvucols
setbsk2:
;                btst    #6,$BFE001
;                beq.s   set2b2

                btst    #2,mousebut
                bne.s   set2b2

                rts

selectcolor2:
                moveq   #0,D7
setcolp:
;                btst    #6,$BFE001
;                bne.s   chkspread
                btst    #2,mousebut
                beq.s   chkspread

                move.w  colorsmax(PC),D0
                move.w  mousey,D1
                cmp.w   D7,D1
                beq.s   setcolp
                move.w  D1,D7
                cmp.w   #37,D1
                bhs.s   setcoly
                moveq   #37,D1
setcoly:        sub.w   #37,D1
                cmp.w   D0,D1
                blt.s   setcol2
                move.w  D0,D1
                subq.w  #1,D1
setcol2:        move.w  D1,rainbowpos
                bsr     showrainbow
                bsr     getcolpos
                move.l  A0,undocoladdr
                move.w  D1,undocol
                bsr     showcolsliders
                bra     setcolp

chkspread:
                tst.w   spreadflag
                beq     return2
                clr.w   spreadflag
                bsr     getcolpos
                move.w  spreadfrom,D0
                move.w  rainbowpos,D1
                cmp.w   D1,D0
                blo.s   chkspr2
                exg     D0,D1
chkspr2:        move.w  D1,D4
                sub.w   D0,D4
                cmp.w   #1,D4
                bls     return2
                movea.l D4,A2
                add.w   D4,D4
                movea.l therightcolors(PC),A0
                movea.l A0,A1
                add.w   D0,D0
                add.w   D1,D1
                lea     0(A0,D0.w),A0   ; 1st col
                move.w  (A0),D2
                lea     0(A1,D1.w),A1
                move.w  (A1),D3         ; 2nd col
                moveq   #0,D5

sprdlop:        move.w  D2,D0           ; red
                lsr.w   #8,D0
                move.w  D3,D1
                lsr.w   #8,D1
                bsr     colcrossfade
                lsl.w   #8,D0
                move.w  D0,D7
                move.w  D2,D0           ; green
                lsr.w   #4,D0
                and.w   #$0F,D0
                move.w  D3,D1
                lsr.w   #4,D1
                and.w   #$0F,D1
                bsr     colcrossfade
                lsl.w   #4,D0
                or.w    D0,D7
                move.w  D2,D0           ; blue
                and.w   #$0F,D0
                move.w  D3,D1
                and.w   #$0F,D1
                bsr     colcrossfade
                or.w    D0,D7
                addq.w  #2,D5
                move.w  D7,(A0)+
                cmpa.l  A1,A0
                blo     sprdlop
                bra     rocoup2

colcrossfade:
                move.w  D4,D6
                sub.w   D5,D6
                mulu    D6,D0
                add.l   A2,D0
                mulu    D5,D1
                add.w   D1,D0
                divu    D4,D0
                cmp.w   #15,D0
                bls     return2
                moveq   #15,D0
                rts

showrainbow:
                movea.l log_base,A0
                lea     (37*320)+(5*16)+4(A0),A0
                moveq   #0,D1
                move.l  #$FFE000,D2
                move.w  rainbowpos,D3
rainlop:        move.l  D2,D0
                cmp.w   D3,D1
                bne.s   rainsk1

                move.l  #$1EFFEF00,D0
rainsk1:        move.w  D0,16(A0)
                swap    D0
                move.w  D0,(A0)
                swap    D0
                lea     320(A0),A0
                addq.w  #1,D1
                cmp.w   #48,D1
                blo.s   rainlop
                lea     coplistanalyzer,A0
                movea.l therightcolors(PC),A1
                move.w  #$5107,D0
                moveq   #47,D5
                moveq   #0,D4
rainlp2:
                cmp.w   colorsmax(PC),D4
                blo.s   rainsk2
                clr.l   (A0)+
                bra.s   rainsk3
rainsk2:        move.w  (A1)+,D0
                jsr     convcol
                move.l  D0,(A0)+
rainsk3:
                addq.w  #1,D4
                dbra    D5,rainlp2
                st      showrainbowflag
                rts
showrainbowflag:DC.W 0
rainbowpos:     DC.W 0
therightcolors: DC.L 0
colorsmax:      DC.W 48

                ENDPART

;---- PT Decompacter ----

decompact:
                move.l  A0,compptr
                move.l  D0,complen
                bsr.s   freedecompmem
                movea.l compptr(PC),A0
                move.l  (A0),D0
                move.l  D0,decompmemsize

;                move.l  #decmem,D0
                moveq   #memf_public,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,decompmemptr
                beq     outofmemerr
                movea.l D0,A1
                movea.l compptr(PC),A0
                move.l  complen(PC),D0
                addq.l  #4,A0
                subq.l  #4,D0
dcmloop:        move.b  (A0)+,D1
                cmp.b   #181,D1
                beq.s   decodeit
                move.b  D1,(A1)+
decom2:         subq.l  #1,D0
                cmp.l   #0,D0
                bgt.s   dcmloop
                movea.l decompmemptr,A1
                moveq   #-1,D0
                rts

decodeit:
                moveq   #0,D1
                move.b  (A0)+,D1
                move.b  (A0)+,D2
dcdloop:        move.b  D2,(A1)+
                dbra    D1,dcdloop
                subq.l  #2,D0
                bra.s   decom2

freedecompmem:
                move.l  decompmemptr,D0
                beq     return2
                movea.l D0,A1
                move.l  decompmemsize,D0
                movea.l 4.w,A6
                jsr     lvofreemem
                clr.l   decompmemptr
                rts

compptr:        DC.L 0
complen:        DC.L 0

;---- Position Insert/Delete Gadgets ----

posinsdelgadgs:
                move.w  mousey2,D0
                cmp.w   #11,D0
                bhs     return2
                move.w  mousex2,D0
                cmp.w   #62,D0
                bhs     return2
                cmp.w   #51,D0
                bhs.s   posdelete
                cmp.w   #40,D0
                bhs.s   posinsert
                rts

posinsert:
                movea.l songdataptr,A0
                lea     sd_pattpos(A0),A0
                adda.l  #126,A0
                moveq   #127,D0
                move.l  currpos,D1
                and.l   #127,D1
posinloop:
                move.b  (A0),1(A0)
                subq.l  #1,A0
                subq.l  #1,D0
                cmp.l   D1,D0
                bhi.s   posinloop
                clr.b   1(A0)
                bsr     showposition
                clr.w   upordown
                bsr     songlengthgadg
                bra     waitforbuttonup

posdelete:
                movea.l songdataptr,A0
                lea     sd_pattpos(A0),A0
                move.l  currpos,D0
                and.l   #127,D0
                adda.l  D0,A0
posdeloop:
                move.b  1(A0),(A0)
                addq.l  #1,A0
                addq.l  #1,D0
                cmp.l   #127,D0
                bls.s   posdeloop
                clr.b   -1(A0)
                bsr     showposition
                move.w  #-1,upordown
                bsr     songlengthgadg
                bra     waitforbuttonup

;---- Enter number gadg ----

enternumgadg:
                move.w  mousey2,D1
                cmp.w   #11,D1
                blo     enterposgadg
                cmp.w   #22,D1
                blo     enterpattgadg
                cmp.w   #33,D1
                blo     enterlengadg
                rts

enterposgadg:
                clr.b   rawkeycode
                move.w  #76,linecurx
                move.w  #10,linecury
                move.w  #169,textoffset
                bsr     getdec3dig
                tst.w   abortdecflag
                bne     pogskip
                cmp.w   #127,D0
                bls.s   eposgok
                moveq   #127,D0
eposgok:        move.l  D0,currpos
                bra     pogskip

enterpattgadg:
                clr.b   rawkeycode
                move.w  #84,linecurx
                move.w  #21,linecury
                move.w  #610,textoffset
                bsr     getdecbyte
                tst.w   abortdecflag
                bne     pogskip
                cmp.b   #63,D0
                bls.s   epgok
                moveq   #63,D0
epgok:          movea.l songdataptr,A0
                lea     sd_pattpos(A0),A0
                adda.l  currpos,A0
                move.b  D0,(A0)
                bra     pogskip

enterlengadg:
                clr.b   rawkeycode
                move.w  #76,linecurx
                move.w  #32,linecury
                move.w  #1049,textoffset
                bsr     getdec3dig
                tst.w   abortdecflag
                bne     showsonglength
                cmp.w   #128,D0
                bls.s   elengok
                move.b  #128,D0
elengok:        movea.l songdataptr,A0
                lea     sd_numofpatt(A0),A0
                move.b  D0,(A0)
                bra     showsonglength

getdec3dig:
                move.w  #1,abortdecflag
                bsr     storeptrcol
                bsr     setwaitptrcol
                bsr     updatelinecurpos
gd3loop:        bsr     getkey0_9
                cmp.w   #68,D1
                beq.s   gd3exit
                cmp.w   #2,D1
                bhi.s   gd3loop
                move.w  D1,D0
                mulu    #100,D0
                move.w  D0,gd3temp
                bsr     showonedigit
                addq.w  #8,linecurx
                bsr     updatelinecurpos
                bsr     getkey0_9
                cmp.b   #68,D1
                beq.s   gd3exit
                move.w  D1,D0
                mulu    #10,D0
                add.w   D0,gd3temp
                bsr     showonedigit
                addq.w  #8,linecurx
                bsr     updatelinecurpos
                bsr     getkey0_9
                cmp.b   #68,D1
                beq.s   gd3exit
                add.w   D1,gd3temp
                clr.w   abortdecflag
gd3exit:        clr.w   linecurx
                move.w  #270,linecury
                bsr     updatelinecurpos
                bsr     restoreptrcol
                moveq   #0,D0
                move.w  gd3temp(PC),D0
return3:        rts

gd3temp:        DC.W 0

;--------------------------------------------------------------------------

                PART 'up and down gadgets'

;----  Up/Down Gadgets ----

downgadgets:
                move.w  #1,updatefreemem
                move.w  #-1,upordown
                bra.s   ug2

upgadgets:
                move.w  #1,updatefreemem
                clr.w   upordown
ug2:            move.w  mousey2,D0
                cmp.w   #100,D0
                bhs     return2
                cmp.w   #89,D0
                bhs     replengadg
                cmp.w   #78,D0
                bhs     repeatgadg
                cmp.w   #67,D0
                bhs     samplelengthgadg
                cmp.w   #56,D0
                bhs     volumegadg
                cmp.w   #45,D0
                bhs     samplenumgadg
                cmp.w   #34,D0
                bhs     finetunegadg
                cmp.w   #23,D0
                bhs     songlengthgadg
                cmp.w   #12,D0
                bhs     patterngadg
                tst.w   mousey2
                bhs.s   positiongadg
                rts

positiongadg:
                tst.w   upordown
                bmi.s   positiondown
positionup:
                addq.l  #1,currpos
                btst    #0,mousebut
                beq.s   pogskp2
;                btst    #2,$DFF016
;                bne.s   pogskp2

                addi.l  #9,currpos
pogskp2:        cmpi.l  #127,currpos
                bls.s   pogskip
                move.l  #127,currpos
pogskip:        move.l  currpos,songposition
                bsr     showposition
                bsr     wait_4000
                bsr     wait_4000
                bra     wait_4000
positiondown:
                subq.l  #1,currpos
                btst    #0,mousebut     ;;
                beq.s   pogskp3         ;;
;                btst    #2,$DFF016
;                bne.s   pogskp3
                subi.l  #9,currpos
pogskp3:        tst.l   currpos
                bpl.s   pogskip
                clr.l   currpos
                bra.s   pogskip

patterngadg:
                movea.l songdataptr,A0
                lea     sd_pattpos(A0),A0
                tst.w   upordown
                bmi.s   patterndown
patternup:
                adda.l  currpos,A0
                addq.b  #1,(A0)
;                btst    #2,$DFF016
;                bne.s   pagaskp
                btst    #0,mousebut
                beq.s   pagaskp

                addi.b  #9,(A0)
pagaskp:        cmpi.b  #63,(A0)
                bls.s   pogskip
                move.b  #63,(A0)
                bra.s   pogskip

patterndown:
                adda.l  currpos,A0
                subq.b  #1,(A0)
;                btst    #2,$DFF016
;                bne.s   padoskp
                btst    #0,mousebut
                beq.s   padoskp

                subi.b  #9,(A0)
padoskp:        tst.b   (A0)
                bpl     pogskip
                clr.b   (A0)
                bra     pogskip


songlengthgadg:
                movea.l songdataptr,A0
                lea     sd_numofpatt(A0),A0
                tst.w   upordown
                bmi.s   songlengthdown
songlengthup:
                addq.b  #1,(A0)
;                btst    #2,$DFF016
;                bne.s   slupskp
                btst    #0,mousebut
                beq.s   slupskp

                addi.b  #9,(A0)
slupskp:        cmpi.b  #127,(A0)
                bmi.s   solgskip
                move.b  #127,(A0)
solgskip:
                bsr     showsonglength
                bsr     wait_4000
                bsr     wait_4000
                bra     wait_4000

songlengthdown:
                subq.b  #1,(A0)
;                btst    #2,$DFF016
;                bne.s   sldoskp
                btst    #0,mousebut
                beq.s   sldoskp

                subi.b  #9,(A0)
sldoskp:        cmpi.b  #1,(A0)
                bge.s   solgskip
                move.b  #1,(A0)
                bra.s   solgskip


samplenumgadg:
;               btst    #2,$DFF016      ; Check Right Mousebutton
;                bne.s   samplenum2
                btst    #0,mousebut
                beq.s   samplenum2

                tst.w   insnum
                beq     showsampleinfo
                move.w  insnum,lastinsnum
                clr.w   insnum
                bra     showsampleinfo

samplenum2:
                tst.w   upordown
                bmi.s   samplenumdown
samplenumup:
                addq.w  #1,insnum
                cmpi.w  #31,insnum
                bmi.s   snuskip
                move.w  #31,insnum
snuskip:        bsr     redrsam
                bsr     wait_4000
                bra     wait_4000

samplenumdown:
                tst.w   insnum
                beq.s   snuskip
                subq.w  #1,insnum
                cmpi.w  #1,insnum
                bpl.s   snuskip
                move.w  #1,insnum
                bra.s   snuskip

finetunegadg:
                movea.l songdataptr,A0
                lea     12(A0),A0
                move.w  insnum,D0
                beq     return3
                mulu    #30,D0
                adda.l  D0,A0
                btst    #0,mousebut
                beq.s   ftgskip
;                btst    #2,$DFF016
;                bne.s   ftgskip
                clr.b   2(A0)
                bra.s   ftuskip
ftgskip:        tst.w   upordown
                bmi.s   finetunedown
finetuneup:
                andi.b  #$0F,2(A0)
                cmpi.b  #7,2(A0)
                beq.s   ftuskip
                addq.b  #1,2(A0)
                andi.b  #$0F,2(A0)
ftuskip:        bsr     showsampleinfo
                bsr     wait_4000
                bra     wait_4000

finetunedown:
                andi.b  #$0F,2(A0)
                cmpi.b  #8,2(A0)
                beq.s   ftuskip
                subq.b  #1,2(A0)
                andi.b  #$0F,2(A0)
                bra.s   ftuskip


volumegadg:
                movea.l songdataptr,A0
                lea     12(A0),A0
                move.w  insnum,D0
                beq     return3
                mulu    #30,D0
                adda.l  D0,A0
                tst.w   upordown
                bmi.s   volumedown
volumeup:
                addq.b  #1,3(A0)
                btst    #0,mousebut
                beq.s   voupskp
;                btst    #2,$DFF016
;                bne.s   voupskp
                addi.b  #15,3(A0)
voupskp:        cmpi.b  #$40,3(A0)
                bls.s   ftuskip
                move.b  #$40,3(A0)
                bra.s   ftuskip

volumedown:
                subq.b  #1,3(A0)
;                btst    #2,$DFF016
;                bne.s   vodoskp
                btst    #0,mousebut
                beq.s   vodoskp

                subi.b  #15,3(A0)
vodoskp:        tst.b   3(A0)
                bpl     ftuskip
                clr.b   3(A0)
                bra     ftuskip

samplelengthgadg:
                move.w  #1,samplelengthflag
                movea.l songdataptr,A0
                lea     12(A0),A0
                moveq   #0,D0
                move.w  insnum,D0
                beq     showsampleinfo
                mulu    #30,D0
                adda.l  D0,A0
                tst.w   upordown
                bmi.s   samplelengthdown
samplelengthup:
                addq.w  #1,(A0)
;                btst    #2,$DFF016
;                bne.s   sluskip
                btst    #0,mousebut
                beq.s   sluskip

                cmpi.w  #$7FF0,(A0)
                bhs.s   sluskip
                addq.w  #7,(A0)
sluskip:        cmpi.w  #$7FFF,(A0)
                blo     showsampleinfo
                move.w  #$7FFF,(A0)
                bra     showsampleinfo

samplelengthdown:
                move.w  4(A0),D0
                add.w   6(A0),D0
                subq.w  #1,(A0)
;                btst    #2,$DFF016
;                bne.s   sldskip
                btst    #0,mousebut
                beq.s   sldskip

                subq.w  #7,(A0)
sldskip:        bmi.s   sldskip2
                cmp.w   (A0),D0
                bls     showsampleinfo
                move.w  D0,(A0)
                bra     showsampleinfo
sldskip2:
                clr.w   (A0)
                bra     showsampleinfo

samplelengthflag:DC.W 0

checksamplelength:
                tst.w   samplelengthflag
                beq     return2
                clr.w   samplelengthflag
                moveq   #0,D0
                move.w  insnum,D0
                beq     return2
                movea.l songdataptr,A0
                lea     12(A0),A0
                move.l  D0,D1
                lsl.w   #2,D1
                mulu    #30,D0
                adda.l  D0,A0
                lea     sampleptrs,A1
                lea     0(A1,D1.w),A1
                move.l  A0,playsamptr
                move.l  A1,realsamptr
                move.l  124(A1),D0
                lsr.l   #1,D0
                move.w  (A0),D1
                cmp.w   D0,D1
                bhi.s   itstoomuch
                rts

itstoomuch:
                lea     addworkspacetext(PC),A0
                bsr     areyousure
                bne.s   restorelength
                bsr     turnoffvoices
                movea.l playsamptr,A0
                moveq   #0,D0
                move.w  (A0),D0
                add.l   D0,D0
                move.l  D0,samalloclen
                move.l  #memf_chip+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,samallocptr
                beq.s   restorelength
                movea.l D0,A1
                movea.l realsamptr,A0
                move.l  (A0),D0
                beq.s   nosamth
                movea.l D0,A2
                move.l  124(A0),D1
                beq.s   nosamth
                subq.l  #1,D1
cpsalop:        move.b  (A2)+,(A1)+
                dbra    D1,cpsalop
                movea.l (A0),A1
                move.l  124(A0),D0
                movea.l 4.w,A6
                jsr     lvofreemem
nosamth:        movea.l realsamptr,A0
                move.l  samallocptr,(A0)
                move.l  samalloclen,124(A0)
                bsr     showsampleinfo
                bsr     redrawsample
                bra     waitforbuttonup

restorelength:
                movea.l playsamptr,A0
                movea.l realsamptr,A1
                move.l  124(A1),D0
                lsr.l   #1,D0
                move.w  D0,(A0)
                bra     showsampleinfo

addworkspacetext:DC.B 'add workspace ?',0
playsamptr:     DC.L 0
realsamptr:     DC.L 0
samallocptr:    DC.L 0
samalloclen:    DC.L 0

repeatgadg:
                movea.l songdataptr,A0
                lea     12(A0),A0
                moveq   #0,D0
                move.w  insnum,D0
                beq     showsampleinfo
                mulu    #30,D0
                adda.l  D0,A0
                tst.w   upordown
                bmi.s   repeatdown
repeatup:
                addq.w  #1,4(A0)
;                btst    #2,$DFF016
;                bne.s   ruskip
                btst    #0,mousebut
                beq.s   ruskip

                addq.w  #7,4(A0)
ruskip:         move.w  (A0),D0         ;   Length
                beq.s   ruskip2
                sub.w   6(A0),D0        ; - RepLen
                cmp.w   4(A0),D0
                bhi.s   ruskip2
                move.w  D0,4(A0)
ruskip2:        bsr     showsampleinfo
                bsr     updaterepeats
                bra     setloopsprites2

repeatdown:
                subq.w  #1,4(A0)
;                btst    #2,$DFF016
;                bne.s   rdskip
                btst    #0,mousebut
                beq.s   rdskip

                subq.w  #7,4(A0)
rdskip:         tst.w   4(A0)
                bpl.s   ruskip2
                clr.w   4(A0)
                bra.s   ruskip2


replengadg:
                movea.l songdataptr,A0
                lea     12(A0),A0
                moveq   #0,D0
                move.w  insnum,D0
                beq     showsampleinfo
                mulu    #30,D0
                adda.l  D0,A0
                tst.w   upordown
                bmi.s   replendown
replenup:
                addq.w  #1,6(A0)
                btst    #0,mousebut
                beq.s   rluskip
;                btst    #2,$DFF016      ; Check Right Mousebutton
;                bne.s   rluskip
                addq.w  #7,6(A0)
rluskip:        move.w  (A0),D0
                beq.s   ruskip2
                sub.w   4(A0),D0
                cmp.w   6(A0),D0
                bhi.s   ruskip2
                bra.s   rldskip

replendown:
                moveq   #0,D0
                move.w  6(A0),D0
                subq.l  #1,D0
;                btst    #2,$DFF016
;                bne.s   rldskip
                btst    #0,mousebut
                beq.s   rldskip

                subq.l  #7,D0
rldskip:        cmp.l   #1,D0
                bge.s   rldskp2
                moveq   #1,D0
rldskp2:        move.w  D0,6(A0)
                bra     ruskip2

                ENDPART

wait_4000:
                move.w  #$4000/4,D0
                tst.b   hhflag
                beq.s   wl_loop
                move.w  #$FFFF/4,D0
wl_lop1:        dbra    D0,wl_lop1
                move.w  #$A000/4,D0
wl_loop:        dbra    D0,wl_loop
                rts

updaterepeats:
                lea     audchan1temp,A1
                lea     ch1s,A2
                lea     scopeinfo,A3
                bsr.s   upre2
                lea     audchan2temp,A1
                lea     ch2s,A2
                lea     scopeinfo+20,A3
                bsr.s   upre2
                lea     audchan3temp,A1
                lea     ch3s,A2
                lea     scopeinfo+40,A3
                bsr.s   upre2
                lea     audchan4temp,A1
                lea     ch4s,A2
                lea     scopeinfo+60,A3
upre2:          move.w  insnum,D0
                cmp.b   n_samplenum(A1),D0
                bne     return2
                movea.l n_start(A1),A1
                moveq   #0,D0
                move.w  4(A0),D0        ; repeat
                adda.l  D0,A1
                adda.l  D0,A1

;               move.l  A1,(A2)
;               move.w  6(A0),D0
;               move.w  D0,4(A2)        ; replen

                moveq   #0,D0
                move.w  6(A0),D0
                move.l  A1,sam_lpstart(A2)
                add.l   D0,D0
                add.l   D0,sam_lpstart(A2)
                move.l  D0,sam_lplength(A2)

                moveq   #0,D0
                move.w  6(A0),D0
                move.l  A1,ns_repeatptr(A3)
                adda.l  D0,A1
                adda.l  D0,A1
                move.l  A1,ns_rependptr(A3)
                rts

setpatternpos:
                move.l  patternposition,D0
                lsr.l   #4,D0
                bra.s   ssppskip

setscrpatternpos:
                move.w  scrpattpos,D0
ssppskip:
                tst.w   samscrenable
                bne     return2
                move.w  D0,playfrompos
                mulu    #7*40,D0
                movea.l textbplptr,A0
                add.l   A0,D0
                move.l  D0,pattbplptr
                rts

playfrompos:    DC.W 0

wantedpattgadg:
                tst.w   samscrenable
                bne     checksamgadgets
typeinwantedpatt:
                cmp.w   #138,D1
                bhi.s   tiwp2
                cmp.w   #25,D0
                bhi     tempogadg
tiwp2:          cmpi.l  #'patp',runmode ; not if a song is playing...
                beq     return2
                clr.b   rawkeycode
                move.w  #12,linecurx
                move.w  #$86,linecury
                move.w  #5121,textoffset
                bsr     getdecbyte
                tst.w   abortdecflag
                bne.s   twexit
                move.b  D0,patternnumber+3
                cmpi.l  #63,patternnumber
                bls.s   twexit
                move.l  #63,patternnumber
twexit:         bra     redrawpattern

getkey0_9:
                btst    #0,mousebut
                bne.s   gk_ret
;               btst    #2,$DFF016
;               beq.s   gk_ret
                moveq   #0,D0
                jsr     dokeybuffer
                move.b  rawkeycode,D0
                beq.s   getkey0_9
                clr.b   rawkeycode
                cmp.b   #68,D0
                beq.s   gk_ret
                cmp.b   #69,D0
                beq.s   gk_ret
                cmp.b   #10,D0
                beq.s   gk_end
                bhi.s   getkey0_9
                cmp.b   #1,D0
                blo.s   getkey0_9
                move.l  D0,D1
                rts

gk_end:         moveq   #0,D1
                rts

gk_ret:         moveq   #68,D1
                rts

showonedigit:
                add.b   #'0',D1
                move.b  D1,numbertext
                clr.w   D1
                swap    D1
                move.w  #1,textlength
                move.l  #numbertext,showtextptr
                bsr     showtext
                clr.l   numbertext
                clr.w   wordnumber
                rts

;---- Get Text Line ----

gettextline:
                moveq   #0,D0
                move.w  A4,D0
                divu    #40,D0
                addq.w  #5,D0
                move.w  D0,linecury
                swap    D0
                lsl.w   #3,D0
                addq.w  #4,D0
                move.w  D0,linecurx
                bsr     updatelinecurpos
                move.l  showtextptr,dstptr
                clr.l   dstoffset
                clr.l   dstpos
                move.w  #1,getlineflag
                movea.l A4,A5
                move.w  linecurx,D5
                clr.b   rawkeycode
                bsr     updatetext
waitforkey:
;               btst    #2,$DFF016
;               beq     abortgetline
                btst    #0,mousebut
                bne     abortgetline
;               btst    #6,$BFE001
;               beq     lineclicked

                btst    #2,mousebut
                bne     lineclicked

                jsr     dokeybuffer
                moveq   #0,D1
                move.b  rawkeycode,D1
                beq.s   waitforkey
                cmp.b   #78,D1
                beq     movecharright
                cmp.b   #79,D1
                beq     movecharleft
                cmp.b   #70,D1
                beq     deletechar
                cmp.b   #65,D1
                beq     backspacechar
                cmp.b   #68,D1
                beq     getlinereturn
                cmp.b   #69,D1
                beq     getlinereturn
                btst    #7,D1
                bne.s   waitforkey
                lea     unshiftedkeymap,A4
                tst.w   shiftkeystatus
                beq.s   gtlskip
                lea     shiftedkeymap,A4
gtlskip:        and.w   #$7F,D1
                cmp.b   #64,D1
                bhi.s   waitforkey
                move.b  0(A4,D1.w),D1
                beq     waitforkey
                tst.b   entertextflag
                beq.s   textlinekey
                cmp.b   #'0',D1
                blo     waitforkey
                cmp.b   #'f',D1
                bhi     waitforkey
                cmp.b   #'a',D1
                bhs.s   textlinekey
                cmp.b   #'9',D1
                bhi     waitforkey
textlinekey:
                cmpa.l  textendptr,A6
                beq     waitforkey
                movea.l textendptr,A4
tlkloop:        move.b  -(A4),1(A4)
                cmpa.l  A4,A6
                bne.s   tlkloop
                movea.l textendptr,A4
                clr.b   (A4)
                move.b  D1,(A6)+
                bsr     posmoveright
                bsr     updatetext
                clr.b   rawkeycode
                bra     waitforkey

lineclicked:
                move.w  mousey,D1
                sub.w   linecury,D1
                cmp.w   #2,D1
                bgt     getlinereturn
                cmp.w   #-8,D1
                blt     getlinereturn
                move.w  mousex,D1
                sub.w   linecurx,D1
                addq.w  #4,D1
                asr.w   #3,D1
                beq     waitforkey
                bpl.s   linclri

                cmpa.l  dstptr(PC),A6
                beq     waitforkey
                subq.l  #1,A6
                bsr     posmoveleft
upwake2:        bsr     updatetext
                bra     waitforkey

linclri:        cmpa.l  textendptr,A6
                beq     waitforkey
                tst.b   (A6)
                beq     waitforkey
                addq.l  #1,A6
                bsr     posmoveright
                bra.s   upwake2

posmoveright:
                move.l  dstpos,D0
                moveq   #0,D1
                move.w  textlength,D1
                tst.b   entertextflag
                bne.s   pmrskip
                subq.w  #1,D1
pmrskip:        cmp.l   D1,D0
                blo.s   posrok
                addq.l  #1,dstoffset
                bra     updatelinecurpos
posrok:         addq.l  #1,dstpos
                addq.w  #8,linecurx
                bra     updatelinecurpos

posmoveleft:
                tst.l   dstpos
                bne.s   poslok
                subq.l  #1,dstoffset
                bra     updatelinecurpos
poslok:         subq.l  #1,dstpos
                subq.w  #8,linecurx
                bra     updatelinecurpos

backspacechar:
                cmpa.l  dstptr(PC),A6
                beq     waitforkey
                subq.l  #1,A6
                movea.l A6,A4
dobaloop:
                move.b  1(A4),(A4)+
                cmpa.l  textendptr,A4
                bne.s   dobaloop
                bsr     posmoveleft
upwake:         bsr     updatetext
                bsr     wait_4000
                bsr     wait_4000
                bsr     wait_4000
                bra     waitforkey

deletechar:
                movea.l A6,A4
dechloop:
                move.b  1(A4),(A4)+
                cmpa.l  textendptr,A4
                blo.s   dechloop
                bra.s   upwake

movecharright:
                cmpa.l  textendptr,A6
                beq     waitforkey
                tst.b   (A6)
                beq     waitforkey
                addq.l  #1,A6
                bsr     posmoveright
                bra.s   upwake

movecharleft:
                cmpa.l  dstptr(PC),A6
                beq     waitforkey
                subq.l  #1,A6
                bsr     posmoveleft
                bra.s   upwake

getlinereturn:
                movea.l dstptr,A6
                cmpi.b  #1,entertextflag
                bne.s   gtl_rskip
                tst.b   disknumtext2
                beq     waitforkey
gtl_rskip:
                cmpi.b  #3,entertextflag
                bne.s   gtl_rskip2
                tst.b   snddisknum1
                beq     waitforkey
gtl_rskip2:
                movea.l A6,A4
dlrloop:        tst.b   (A4)+
                bne.s   dlrloop
                subq.l  #1,A4
dlrloop2:
                cmpa.l  textendptr,A4
                bhs.s   dlrexit
                clr.b   (A4)+
                bra.s   dlrloop2

dlrexit:        clr.w   linecurx
                move.w  #270,linecury
                bsr     updatelinecurpos
                clr.w   getlineflag
                move.b  rawkeycode,mixchar
                clr.b   rawkeycode
                clr.l   dstoffset
                bsr.s   updatetext
                bra     waitforbuttonup

abortgetline:
                movea.l dstptr,A6
                movea.l A6,A4
clliloop:
                clr.b   (A4)+
                cmpa.l  textendptr,A4
                bne.s   clliloop
                bsr.s   updatetext
                bra     getlinereturn

updatetext:
                move.w  A5,textoffset
                movea.l dstptr,A0
                adda.l  dstoffset,A0
                bra     showtext2

dstptr:         DC.L 0
dstpos:         DC.L 0
dstoffset:      DC.L 0

;----

typeinsongname:
                bsr     storeptrcol
                bsr     setwaitptrcol
                clr.l   editmode
                movea.l songdataptr,A6
                move.l  A6,textendptr
                move.l  A6,showtextptr
                addi.l  #19,textendptr
                move.w  #20,textlength
                movea.w #4133,A4
                bsr     gettextline
                clr.l   textendptr
                bra     restoreptrcol

checksmplnamorload:
                cmpi.w  #287,mousex2
                bhs     loadnamedsample
typeinsamplename:
                bsr     storeptrcol
                bsr     setwaitptrcol
                clr.l   editmode
                movea.l songdataptr,A6
                lea     -10(A6),A6
                move.w  insnum,D7
                bne.s   tisnskip
                move.w  lastinsnum,D7
tisnskip:
                mulu    #30,D7
                adda.l  D7,A6
                move.l  A6,textendptr
                move.l  A6,showtextptr
                addi.l  #21,textendptr
                move.w  #22,textlength
                movea.w #4573,A4
                bsr     gettextline
                clr.l   textendptr
                bra     restoreptrcol



stopit:         bsr.s   dostopit
turnoffvoices:
                movem.l D0/A0-A1,-(SP)
;                move.w  #$0F,$DFF096
;                clr.w   $DFF0A8
;                clr.w   $DFF0B8
;                clr.w   $DFF0C8
;                clr.w   $DFF0D8
                moveq   #$0F,D0
                jsr     move_dmacon
                clr.w   ch1s+sam_vol
                clr.w   ch2s+sam_vol
                clr.w   ch3s+sam_vol
                clr.w   ch4s+sam_vol

                clr.b   rawkeycode
                lea     scopeinfo,A0
                lea     blanksample,A1
                move.l  A1,(A0)
                move.l  A1,20(A0)
                move.l  A1,40(A0)
                move.l  A1,60(A0)
                movem.l (SP)+,D0/A0-A1
                rts

dostopit:
                bsr     setnormalptrcol
                clr.l   editmode
                clr.l   runmode
                clr.b   pattdelaytime
                clr.b   pattdelaytime2
                bra     restoreeffects2

usepreset:
                bsr     storeptrcol
                tst.l   plstmem
                beq.s   upend
                tst.w   insnum
                beq.s   upend
                clr.b   rawkeycode
                move.w  currentpreset,D0
                subq.w  #1,D0
                mulu    #30,D0
                movea.l plstmem,A0
                adda.l  D0,A0
                move.w  insnum,D0
                mulu    #30,D0
                movea.l songdataptr,A1
                lea     -10(A1,D0.w),A1
                movea.l A1,A2
                moveq   #29,D0
uploop:         move.b  (A0)+,(A1)+
                dbra    D0,uploop
                move.l  (A2),D0
                and.l   #$DFDFFFFF,D0
                cmp.l   #$53540000,D0   ;ST__
                bne.s   upok
                clr.w   (A2)
                clr.l   22(A2)
                move.l  #$01,26(A2)
upok:           bsr     loadpreset
upend:          bsr     showsampleinfo
                bra     restoreptrcol

;---- Edit ----

edit:           tst.w   samscrenable
                bne     return2
                bsr     stopit
                clr.b   rawkeycode
                bsr     seteditptrcol
                bsr     setscrpatternpos
                move.l  #'edit',editmode
                bra     waitforbuttonup

                PART 'EDITOP 1 and 2'

;---- Edit Op. ----

doeditop:
                clr.b   rawkeycode
                cmpi.w  #1,currscreen
                bne     return2
                tst.b   edenable
                beq.s   editop
                addq.b  #1,edscreen
                cmpi.b  #4,edscreen
                blo.s   editop
                move.b  #1,edscreen
editop:         bsr     waitforbuttonup
                st      edenable
                st      disableanalyzer
                jsr     clearanalyzercolors
                bsr     clearrightarea
                bra     draweditmenu

edenable:       DC.B 0
edscreen:       DC.B 1

draweditmenu:
                cmpi.b  #1,edscreen
                bne.s   demskip
                move.l  #editoptext1,showtextptr
                lea     edit1data,A0
                move.l  #edit1size,D0
                bra.s   demit
demskip:
                cmpi.b  #2,edscreen
                bne.s   demskip2
                move.l  #editoptext2,showtextptr
                lea     edit2data,A0
                move.l  #edit2size,D0
                bra.s   demit
demskip2:
                cmpi.b  #3,edscreen
                bne     return2
                move.l  #editoptext3,showtextptr
                lea     edit3data,A0
                move.l  #edit3size,D0
demit:          bsr     decompact
;                beq     exiteditop ;; memory alloc failed
                lea     spectrumanapos,A0 ;;
                moveq   #54,D0          ;;
demloop1:                               ;;
                moveq   #24,D1          ;;
                moveq   #14,D2          ;;
                moveq   #15,D3          ;;
demloop2:
                move.b  1430(A1),2(A0)  ;;
                move.b  (A1)+,(A0)      ;;
                adda.w  D3,A0           ;;
                eor.w   D2,D3           ;;
                dbra    D1,demloop2     ;;
                lea     320-207(A0),A0  ;;
                addq.l  #1,A1           ;;
                dbra    D0,demloop1     ;;
                bsr     freedecompmem   ;;
                move.w  #1936,textoffset
                move.w  #22,textlength
                bsr     showtext
                cmpi.b  #1,edscreen
                beq     showsampleall
                cmpi.b  #2,edscreen
                bne.s   demskip3
                bsr     showtrackpatt
                bsr     showfrom
                bsr     showto
                bsr     showrecordmode
                bsr     showquantize
                bsr     showmetronome
                bsr     showmultimode
                rts
demskip3:
                cmpi.b  #3,edscreen
                bne     return2
                bsr     showhalfclip
                bsr     showpos
                bsr     showmod
                bsr     showvol
                rts

editoptext1:    DC.B '  track      pattern  '
editoptext2:    DC.B '  record     samples  '
editoptext3:    DC.B '    sample editor     '

checkeditopgadgs:
                move.w  pattcurpos,D0
                bsr.s   getpositionptr
                movem.w mousex2,D0-D1
                cmp.w   #306,D0
                bhs.s   checkedswap
                cmpi.b  #1,edscreen
                beq     checkedgadg1
                cmpi.b  #2,edscreen
                beq     checkedgadg2
                cmpi.b  #3,edscreen
                beq     checkedgadg3
                rts

getpositionptr:
                movea.l songdataptr,A0
                lea     sd_patterndata(A0),A0
                move.l  patternnumber,D2
                lsl.l   #8,D2
                lsl.l   #2,D2
                adda.l  D2,A0
                moveq   #0,D2
                move.w  D0,D2
                divu    #6,D2
                lsl.w   #2,D2
                adda.w  D2,A0
                rts

checkedswap:
                cmp.w   #55,D1
                bls     return2
                moveq   #1,D2
                cmp.w   #66,D1
                bls.s   seteditopscreen
                moveq   #2,D2
                cmp.w   #77,D1
                bls.s   seteditopscreen
                moveq   #3,D2
                cmp.w   #88,D1
                bls.s   seteditopscreen
                cmp.w   #99,D1
                bls.s   exiteditop
                rts

seteditopscreen:
                move.b  D2,edscreen
                bra     editop

exiteditop:
                sf      edenable
                clr.b   rawkeycode
                bra     displaymainscreen

checkedgadg1:
                cmp.w   #55,D1
                bls     togglesampleall
                cmp.w   #66,D1
                bls     noteup
                cmp.w   #77,D1
                bls     notedown
                cmp.w   #88,D1
                bls     octaveup
                cmp.w   #99,D1
                bls     octavedown
                rts

checkedgadg2:
                cmp.w   #55,D1
                bls     toggletrackpatt
                cmp.w   #213,D0
                bls.s   ceg2left
                cmp.w   #66,D1
                bls     deleteorkill
                cmp.w   #77,D1
                bls     exchangeorcopy
                cmp.w   #88,D1
                bls     setsamplefrom
                cmp.w   #99,D1
                bls     setsampleto
                rts

ceg2left:
                cmp.w   #66,D1
                bls     togglerecordmode
                cmp.w   #77,D1
                bls     setquantize
                cmp.w   #88,D1
                bls     setmetronome
                cmp.w   #99,D1
                bls     togglemultimode
                rts

checkedgadg3:
                movea.l songdataptr,A5
                lea     -10(A5),A5
                move.w  insnum,D2
                bne.s   ceg3skip
                move.w  lastinsnum,D2
ceg3skip:
                mulu    #30,D2
                adda.l  D2,A5
                cmp.w   #55,D1
                bls     togglehalfclip
                cmp.w   #213,D0
                bls.s   ceg3mid
                cmp.w   #66,D1
                bls     setsamplepos
                cmp.w   #77,D1
                bls     setmodspeed
                cmp.w   #88,D1
                bls     cutbeg
                cmp.w   #99,D1
                bls     changevolume
                rts

ceg3mid:        cmp.w   #165,D0
                bls.s   ceg3left
                cmp.w   #66,D1
                bls     echo
                cmp.w   #77,D1
                bls     filter
                cmp.w   #88,D1
                bls     backwards
                cmp.w   #99,D1
                bls     downsample
                rts

ceg3left:
                cmp.w   #66,D1
                bls     mix
                cmp.w   #77,D1
                bls     boost
                cmp.w   #88,D1
                bls     xfade
                cmp.w   #99,D1
                bls     upsample
                rts

togglesampleall:
                bsr     waitforbuttonup
                eori.b  #1,sampleallflag
showsampleall:
                lea     bitplanedata+1838,A1
                lea     s_boxdata,A2
                tst.b   sampleallflag
                beq     xrtdoit
                lea     a_boxdata,A2
xrtdoit:        jmp     rtdoit

octaveup:
                move.w  #24,noteshift
                bra.s   nup2

noteup:         move.w  #2,noteshift
nup2:           bsr     saveundo
                cmp.w   #214,D0
                bls.s   nup3
                moveq   #0,D0
                bsr     getpositionptr
                bsr.s   samplenoteup
                moveq   #6,D0
                bsr     getpositionptr
                bsr.s   samplenoteup
                moveq   #12,D0
                bsr     getpositionptr
                bsr.s   samplenoteup
                moveq   #18,D0
                bsr     getpositionptr
nup3:           bsr.s   samplenoteup
                bra     redrawpattern

samplenoteup:
                moveq   #63,D6
                movea.l A0,A3
                move.w  insnum,D3
                tst.b   sampleallflag
                beq.s   sanulo2
                moveq   #0,D3
sanulo2:        move.l  D6,D0
                movea.l A3,A0
sanuloop:
                move.b  2(A0),D1
                lsr.b   #4,D1
                move.b  (A0),D2
                and.b   #$F0,D2
                or.b    D2,D1
                cmp.b   D3,D1
                bne.s   sanuskip
                move.w  (A0),D1
                move.w  D1,D2
                and.w   #$F000,D2
                and.w   #$0FFF,D1
                beq.s   sanuskip
                bsr     checkperiod
                bne.s   sanuskip
                add.w   noteshift(PC),D5
                cmp.w   #$48,D5
                blo.s   sanuok
                tst.b   transdelflag
                beq.s   sanuskip
                andi.l  #$0FFF,(A0)
                bra.s   sanuskip
sanuok:         move.w  0(A2,D5.w),D1
                or.w    D2,D1
                move.w  D1,(A0)
sanuskip:
                lea     16(A0),A0
                dbra    D0,sanuloop
                tst.b   sampleallflag
                beq     return2
                addq.w  #1,D3
                cmp.w   #32,D3
                blo.s   sanulo2
                rts

octavedown:
                move.w  #24,noteshift
                bra.s   ndown2

notedown:
                move.w  #2,noteshift
ndown2:         bsr     saveundo
                cmp.w   #214,D0
                bls.s   ndown3
                moveq   #0,D0
                bsr     getpositionptr
                bsr.s   samplenotedown
                moveq   #6,D0
                bsr     getpositionptr
                bsr.s   samplenotedown
                moveq   #12,D0
                bsr     getpositionptr
                bsr.s   samplenotedown
                moveq   #18,D0
                bsr     getpositionptr
ndown3:         bsr.s   samplenotedown
                bra     redrawpattern

samplenotedown:
                moveq   #63,D6
                movea.l A0,A3
                move.w  insnum,D3
                tst.b   sampleallflag
                beq.s   sandlo2
                moveq   #0,D3
sandlo2:        move.w  D6,D0
                movea.l A3,A0
sandloop:
                move.b  2(A0),D1
                lsr.b   #4,D1
                move.b  (A0),D2
                and.b   #$F0,D2
                or.b    D2,D1
                cmp.b   D1,D3
                bne.s   sandskip
                move.w  (A0),D1
                move.w  D1,D2
                and.w   #$F000,D2
                and.w   #$0FFF,D1
                beq.s   sandskip
                bsr.s   checkperiod
                bne.s   sandskip
                sub.w   noteshift(PC),D5
                bpl.s   sandok
                tst.b   transdelflag
                beq.s   sandskip
                andi.l  #$0FFF,(A0)
                bra.s   sandskip
sandok:         move.w  0(A2,D5.w),D1
                or.w    D2,D1
                move.w  D1,(A0)
sandskip:
                lea     16(A0),A0
                dbra    D0,sandloop
                tst.b   sampleallflag
                beq     return2
                addq.w  #1,D3
                cmp.w   #$20,D3
                blo.s   sandlo2
                rts

noteshift:
                DC.W 0

checkperiod:
                lea     periodtable(PC),A2
                moveq   #-2,D5
chpeloop:
                addq.l  #2,D5
                move.w  0(A2,D5.w),D4
                beq.s   periodnotok
                cmp.w   D4,D1
                beq.s   periodok
                bra.s   chpeloop

periodok:
                moveq   #0,D4
                rts

periodnotok:
                moveq   #-1,D4
                rts

toggletrackpatt:
                bsr     waitforbuttonup
                addq.b  #1,trackpattflag
                cmpi.b  #3,trackpattflag
                blo.s   showtrackpatt
                clr.b   trackpattflag
showtrackpatt:
                lea     bitplanedata+1838,A1
                lea     t_boxdata,A2
                tst.b   trackpattflag
                beq     xrtdoit
                lea     p_boxdata,A2
                cmpi.b  #1,trackpattflag
                beq     xrtdoit
                lea     s_boxdata,A2
                jmp     rtdoit

killinstrtrack:
                bsr     saveundo
                move.w  pattcurpos,D0
                bsr     getpositionptr
                bra.s   dst2

deleteorkill:
                cmp.w   #260,D0
                bhs     killsample
delsampletrack:
                bsr     saveundo
                tst.b   trackpattflag
                beq.s   dst2
                moveq   #0,D0
                bsr     getpositionptr
                bsr.s   dstdoit
                moveq   #6,D0
                bsr     getpositionptr
                bsr.s   dstdoit
                moveq   #12,D0
                bsr     getpositionptr
                bsr.s   dstdoit
                moveq   #18,D0
                bsr     getpositionptr
dst2:           bsr.s   dstdoit
                bra     redrawpattern

dstdoit:        clr.b   rawkeycode
                moveq   #63,D0
                move.w  insnum,D3
                beq     notsamplenull
ksloop:         move.b  2(A0),D1
                lsr.b   #4,D1
                move.b  (A0),D2
                and.b   #$F0,D2
                or.b    D2,D1
                cmp.b   D1,D3
                bne.s   ksskip
                clr.l   (A0)
ksskip:         lea     16(A0),A0
                dbra    D0,ksloop
                rts

killsample:
                lea     killsampletext,A0
                bsr     areyousure
                bne     return2
destroy:        bsr     storeptrcol
                move.w  insnum,D0
                beq     errorrestorecol
                bsr     turnoffvoices
                bsr     freesample
                movea.l songdataptr,A0
                move.w  insnum,D0
                mulu    #30,D0
                lea     -10(A0),A0
                adda.l  D0,A0
                movea.l A0,A1
                moveq   #29,D0
kisalop:        clr.b   (A0)+
                dbra    D0,kisalop
                move.w  #1,28(A1)
                bsr     showsampleinfo
                bsr     redrawsample
                bra     restoreptrcol

exchangeorcopy:
                moveq   #-1,D4
                cmp.w   #260,D0
                bhs.s   copysampletrack
exchsampletrack:
                cmpi.b  #2,trackpattflag
                beq     exchsamples
                moveq   #0,D4
                bra.s   mstskip
copysampletrack:
                cmpi.b  #2,trackpattflag
                beq     copysamples
mstskip:        tst.b   trackpattflag
                beq.s   mst2
                moveq   #0,D0
                bsr     getpositionptr
                bsr.s   mstdoit
                moveq   #6,D0
                bsr     getpositionptr
                bsr.s   mstdoit
                moveq   #12,D0
                bsr     getpositionptr
                bsr.s   mstdoit
                moveq   #18,D0
                bsr     getpositionptr
mst2:           bsr.s   mstdoit
                bra     redrawpattern

mstdoit:        moveq   #63,D0
esloop:         move.b  2(A0),D1
                lsr.b   #4,D1
                move.b  (A0),D2
                and.b   #$F0,D2
                or.b    D2,D1
                cmp.b   samplefrom(PC),D1
                bne.s   esskip2
                andi.l  #$0FFF0FFF,(A0)
                move.b  sampleto(PC),D2
                move.b  D2,D3
                and.b   #$F0,D2
                or.b    D2,(A0)
                lsl.b   #4,D3
                or.b    D3,2(A0)
                bra.s   esskip3
esskip2:        tst.b   D4
                bne.s   esskip3
                cmp.b   sampleto(PC),D1
                bne.s   esskip3
                andi.l  #$0FFF0FFF,(A0)
                move.b  samplefrom(PC),D2
                move.b  D2,D3
                and.b   #$F0,D2
                or.b    D2,(A0)
                lsl.b   #4,D3
                or.b    D3,2(A0)
esskip3:        lea     16(A0),A0
                dbra    D0,esloop
                rts

exchsamples:
                bsr     storeptrcol
                moveq   #0,D0
                move.b  samplefrom(PC),D0
                beq     errorrestorecol
                moveq   #0,D1
                move.b  sampleto(PC),D1
                beq     errorrestorecol
                move.w  D0,D2
                move.w  D1,D3
                lea     samplelengthadd+2,A2
                add.w   D2,D2
                add.w   D3,D3
                lea     0(A2,D2.w),A0
                lea     0(A2,D3.w),A1
                move.w  (A0),D4
                move.w  (A1),(A0)
                move.w  D4,(A1)
                lea     sampleptrs,A2
                add.w   D2,D2
                add.w   D3,D3
                lea     0(A2,D2.w),A0
                lea     0(A2,D3.w),A1
                move.l  (A0),D4
                move.l  (A1),(A0)
                move.l  D4,(A1)
                move.l  124(A0),D4
                move.l  124(A1),124(A0)
                move.l  D4,124(A1)
                subq.w  #1,D0
                subq.w  #1,D1
                mulu    #30,D0
                mulu    #30,D1
                movea.l songdataptr,A2
                lea     20(A2),A2
                lea     0(A2,D0.w),A0
                lea     0(A2,D1.w),A1
                moveq   #29,D0
exsalop:        move.b  (A0),D1
                move.b  (A1),(A0)+
                move.b  D1,(A1)+
                dbra    D0,exsalop
                bsr     showsampleinfo
                bsr     redrawsample
                bra     restoreptrcol

copysamples:
                bsr     storeptrcol
                moveq   #0,D0
                move.b  samplefrom(PC),D0
                beq     errorrestorecol
                moveq   #0,D1
                move.b  sampleto(PC),D1
                beq     errorrestorecol
                lea     sampleptrs,A2
                lsl.w   #2,D0
                lsl.w   #2,D1
                lea     0(A2,D0.w),A3
                lea     0(A2,D1.w),A4
                move.l  (A3),D0
                beq     errorrestorecol
                move.l  124(A3),D0
                moveq   #memf_chip,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                tst.l   D0
                beq     outofmemerr
                movea.l D0,A5
                moveq   #0,D0
                move.b  sampleto(PC),D0
                move.w  D0,insnum
                bsr     destroy
                move.l  A5,(A4)
                move.l  124(A3),D0
                move.l  D0,124(A4)
                movea.l (A3),A0
cosalp2:        move.b  (A0)+,(A5)+
                subq.l  #1,D0
                bne.s   cosalp2
                moveq   #0,D0
                moveq   #0,D1
                move.b  samplefrom(PC),D0
                move.b  sampleto(PC),D1
                move.w  D1,insnum
                mulu    #30,D0
                mulu    #30,D1
                movea.l songdataptr(PC),A2
                lea     -10(A2),A2
                lea     0(A2,D0.w),A0
                lea     0(A2,D1.w),A1
                moveq   #29,D0
cosalop:        move.b  (A0)+,(A1)+
                dbra    D0,cosalop
                bsr     showsampleinfo
                bsr     redrawsample
                bra     restoreptrcol

setsamplefrom:
                move.w  insnum(PC),D2
                cmp.w   #283,D0
                bls.s   sesfskip
                move.b  samplefrom(PC),D2
                cmp.w   #295,D0
                bls.s   sesfup
                subq.b  #1,D2
                bpl.s   sesfskip
                moveq   #0,D2
sesfskip:
                move.b  D2,samplefrom
                bsr     wait_4000
                bra.s   showfrom
sesfup:         addq.b  #1,D2
                cmp.b   #$1F,D2
                bls.s   sesfskip
                move.b  #$1F,samplefrom
showfrom:
                move.w  #3273,textoffset
                clr.w   wordnumber
                move.b  samplefrom(PC),wordnumber+1
                bra     printhexbyte

setsampleto:
                move.w  insnum(PC),D2
                cmp.w   #283,D0
                bls.s   sestskip
                move.b  sampleto(PC),D2
                cmp.w   #295,D0
                bls.s   sestup
                subq.b  #1,D2
                bpl.s   sestskip
                moveq   #0,D2
sestskip:
                move.b  D2,sampleto
                bsr     wait_4000
                bra.s   showto
sestup:         addq.b  #1,D2
                cmp.b   #$1F,D2
                bls.s   sestskip
                move.b  #$1F,sampleto
showto:         move.w  #3713,textoffset
                clr.w   wordnumber
                move.b  sampleto(PC),wordnumber+1
                bra     printhexbyte

samplefrom:     DC.B 0
sampleto:       DC.B 0

togglerecordmode:
                bsr     waitforbuttonup
                eori.b  #1,recordmode
showrecordmode:
                move.w  #2382,D1
                lea     patttext,A0
                tst.b   recordmode
                beq.s   srmskip
                lea     songtext,A0
srmskip:        moveq   #4,D0
                bra     showtext3

patttext:       DC.B 'patt'
songtext:       DC.B 'song'
recordmode:     DC.B 0
quantizevalue:  DC.B 1
metrospeed:     DC.B 4
metrochannel:   DC.B 0
multiflag:      DC.B 0
sampleallflag:  DC.B 0
trackpattflag:  DC.B 0
cliphalveflag:  DC.B 0
abortdecflag:   DC.W 0

getdecbyte:
                move.w  #1,abortdecflag
                bsr     storeptrcol
                bsr     setwaitptrcol
                bsr     updatelinecurpos
                bsr     getkey0_9
                cmp.b   #68,D1
                beq.s   gdbexit
                move.b  D1,D0
                mulu    #10,D0
                move.b  D0,getdectemp
                bsr     showonedigit
                addq.w  #8,linecurx
                bsr     updatelinecurpos
                bsr     getkey0_9
                cmp.b   #68,D1
                beq.s   gdbexit
                add.b   D1,getdectemp
                clr.w   abortdecflag
gdbexit:        clr.w   linecurx
                move.w  #270,linecury
                bsr     updatelinecurpos
                bsr     restoreptrcol
                move.b  getdectemp,D0
                rts

setquantize:
                clr.b   rawkeycode
                move.w  #196,linecurx
                move.w  #76,linecury
                move.w  #2824,textoffset
                bsr     getdecbyte
                tst.w   abortdecflag
                bne     showquantize
                cmp.b   #63,D0
                bls.s   tqskip
                moveq   #63,D0
tqskip:         move.b  D0,quantizevalue
showquantize:
                move.w  #2824,textoffset
                clr.w   wordnumber
                move.b  quantizevalue,wordnumber+1
                bra     print2decdigits

setmetronome:
                clr.b   rawkeycode
                cmp.w   #188,D0
                bhs.s   smchan
                move.w  #3261,textoffset
                move.w  #172,linecurx
                move.w  #87,linecury
                bsr     getdecbyte
                tst.w   abortdecflag
                bne     showmetronome
                cmp.b   #64,D0
                bls.s   smexit
                moveq   #64,D0
smexit:         move.b  D0,metrospeed
                bra.s   showmetronome

smchan:         move.w  #3264,textoffset
                bsr     gethexbyte
                cmp.w   #4,D0
                bls.s   smexit2
                moveq   #4,D0
smexit2:        move.b  D0,metrochannel
showmetronome:
                move.w  #3261,textoffset
                clr.w   wordnumber
                move.b  metrospeed,wordnumber+1
                bsr     print2decdigits
                move.w  #3264,textoffset
                clr.w   wordnumber
                move.b  metrochannel,wordnumber+1
                bra     print2decdigits

togglemultimode:
                bsr     waitforbuttonup
                clr.b   rawkeycode
                eori.b  #1,multiflag
showmultimode:
                bsr.s   show_ms
                cmpi.w  #1,currscreen
                bne     return2
                cmpi.b  #2,edscreen
                bne     return2
                tst.b   edenable
                beq     return2
                move.w  #3700,D1
                lea     singletext(PC),A0
                tst.b   multiflag
                beq.s   smmskip
                lea     multitext(PC),A0
smmskip:        moveq   #6,D0
                bra     showtext3

singletext:     DC.B 'single'
multitext:      DC.B ' multi'

show_ms:        cmpi.w  #4,currscreen
                beq     return2
                move.b  #' ',D0
                tst.b   multiflag
                beq.s   smsskp1
                move.b  #'M',D0
smsskp1:        move.b  #' ',D1
                tst.b   splitflag
                beq.s   smsskp2
                move.b  #'S',D1
smsskp2:        move.b  D0,mstext
                move.b  D1,mstext+1
                move.w  #4121,D1
                moveq   #2,D0
                lea     mstext(PC),A0
                bsr     showtext3
                bra     showautoinsert

mstext:         DC.B '__'

                ENDPART

                PART 'editop3'
;---- Edit Op. 3 ----

togglehalfclip:
                bsr     waitforbuttonup
                eori.b  #1,halfclipflag
showhalfclip:
                lea     bitplanedata+1838,A1
                lea     h_boxdata,A2
                tst.b   halfclipflag
                beq.s   ogaoga
                lea     c_boxdata,A2
ogaoga:         jmp     rtdoit

setsamplepos:
                move.l  samplepos(PC),D2
                cmp.w   #283,D0
                bls     return2
                cmp.w   #295,D0
                bls.s   shpoup
                subq.l  #1,D2
;                btst    #2,$DFF016
;                bne.s   shposkip
                btst    #0,mousebut
                beq.s   shposkip

                sub.l   #15,D2
shposkip:
                bpl.s   shposkip2
                moveq   #0,D2
shposkip2:
                move.l  D2,samplepos
                bra.s   showpos
shpoup:         addq.l  #1,D2
;                btst    #2,$DFF016
;                bne.s   shposkip3
                btst    #0,mousebut
                beq.s   shposkip3

                add.l   #15,D2
shposkip3:
                moveq   #0,D3
                move.w  22(A5),D3
                add.l   D3,D3
                cmp.l   D3,D2
                bls.s   shposkip2
                move.l  D3,samplepos
showpos:        cmpi.w  #1,currscreen
                bne     return2
                tst.b   edenable
                beq     return2
                cmpi.b  #3,edscreen
                bne     return2
                move.w  #2391,textoffset
                move.w  samplepos+2(PC),wordnumber
                bra     printhexword

setmodspeed:
                cmp.w   #243,D0
                bls     domod
                moveq   #0,D2
;                btst    #2,$DFF016
;                beq.s   semoskp
                btst    #0,mousebut
                bne.s   semoskp

                move.b  modspeed,D2
                cmp.w   #283,D0
                bls     return2
                cmp.w   #295,D0
                bls.s   semoup
                sub.b   #1,D2
                cmp.b   #127,D2
                bne.s   semoskp
                move.b  #128,D2
                bra.s   semoskp
semoup:         add.b   #1,D2
                cmp.b   #128,D2
                bne.s   semoskp
                moveq   #127,D2
semoskp:        move.b  D2,modspeed
                bsr     wait_4000
showmod:        lea     plusminustext(PC),A0
                moveq   #0,D6
                move.b  modspeed,D6
                bpl.s   shmoskp
                neg.b   D6
                addq.l  #1,A0
shmoskp:        moveq   #1,D0
                move.w  #2831,D1
                bsr     showtext3
                move.w  D6,wordnumber
                bra     print3decdigits

plusminustext:  DC.B ' -'

domod:          bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D2
                move.w  sampleinfo(PC),D2
                beq     errorrestorecol
                add.w   D2,D2
                subq.w  #1,D2
                move.l  si_pointer,D0
                beq     errorrestorecol
                bsr     allocbuffer
                movea.l D0,A2
                movea.l D0,A3
                movea.l A1,A4
                adda.l  D2,A3
                clr.l   modoffset
                clr.l   modpos
dmoloop:        cmpa.l  A3,A2
                bhs.s   dmoskip
                move.b  (A1),(A2)+
                bsr.s   updatemod
                bra.s   dmoloop
dmoskip:        movea.l si_pointer(PC),A1
                clr.w   (A1)
                bsr     freebuffer
                bsr     restoreptrcol
                bra     displaysample

updatemod:
                move.b  modspeed(PC),D0
                beq.s   upmplus
                ext.w   D0
                ext.l   D0
                move.l  modpos(PC),D1
                add.l   D0,D1
                move.l  D1,modpos
                asr.l   #8,D1
                asr.l   #4,D1
                move.l  D1,D3
                and.w   #$1F,D1
                lea     vibratotable,A0
                moveq   #0,D0
                move.b  0(A0,D1.w),D0
                lsr.b   #2,D0
                move.l  modoffset(PC),D1
                btst    #5,D3
                beq.s   upmskip
                sub.l   D0,D1
                bra.s   upmskp2
upmskip:        add.l   D0,D1
upmskp2:        add.l   #$0800,D1
                move.l  D1,modoffset
                asr.l   #8,D1
                asr.l   #3,D1
                bpl.s   upmskp3
                moveq   #0,D1
upmskp3:        cmp.l   D2,D1
                blo.s   upmskp4
                move.l  D2,D1
upmskp4:        movea.l A4,A1
                adda.l  D1,A1
                rts
upmplus:        addq.l  #1,A1
                rts

cutbeg:         cmp.w   #283,D0
                bhi     fadedown
                cmp.w   #259,D0
                bhi     fadeup
                bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D3
                move.w  sampleinfo(PC),D3
                beq     errorrestorecol
                add.w   D3,D3
                subq.w  #1,D3
                move.l  si_pointer,D0
                beq     errorrestorecol
                movea.l D0,A1
                movea.l D0,A2
                movea.l D0,A3
                adda.l  samplepos(PC),A2
                adda.l  D3,A3
cbeloop:        cmpa.l  A3,A2
                bhs.s   cbeskip
                move.b  (A2),D0
                clr.b   (A2)+
                move.b  D0,(A1)+
                bra.s   cbeloop
cbeskip:        movea.l si_pointer(PC),A2
                clr.w   (A2)
                suba.l  A2,A1
                move.l  A1,D0
                lsr.l   #1,D0
                addq.l  #1,D0
                and.w   #$7FFF,D0
                move.w  D0,22(A5)
                bsr     showsampleinfo
                bsr     restoreptrcol
                bra     displaysample

fadeup:         bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D3
                move.w  sampleinfo(PC),D3
                beq     errorrestorecol
                moveq   #0,D1
                move.l  samplepos(PC),D2
                beq     errorrestorecol
                move.l  si_pointer,D0
                beq     errorrestorecol
                movea.l D0,A0
                lsr.w   #1,D2
                beq     errorrestorecol
                moveq   #0,D4
fuloop:         move.b  (A0),D0
                ext.w   D0
                muls    D1,D0
                divs    D2,D0
                move.b  D0,(A0)+
                addq.w  #1,D4
                move.w  D4,D1
                lsr.w   #1,D1
                cmp.w   D2,D1
                blo.s   fuloop
                bsr     restoreptrcol
                bra     displaysample

fadedown:
                bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D3
                move.w  sampleinfo(PC),D3
                beq     errorrestorecol
                add.l   D3,D3
                subq.l  #1,D3           ;Length-1
                move.l  samplepos(PC),D2
                cmp.l   D3,D2
                bhs     errorrestorecol
                move.l  D3,D4           ; Copy length to D4
                sub.l   D2,D3           ; Length-pos
                move.l  D3,D2           ; Copy offset to D2
                move.l  si_pointer,D0
                beq     errorrestorecol
                movea.l D0,A0
                lea     0(A0,D4.l),A0   ;Start at end of sample
                lsr.w   #1,D2
                beq     errorrestorecol
                moveq   #0,D1
                moveq   #0,D4
fdloop:         move.b  (A0),D0
                ext.w   D0
                muls    D1,D0
                divs    D2,D0
                move.b  D0,(A0)
                subq.l  #1,A0
                addq.w  #1,D4
                move.w  D4,D1
                lsr.w   #1,D1
                cmp.w   D2,D1
                blo.s   fdloop
                bsr     restoreptrcol
                bra     displaysample

changevolume:
                move.w  samplevol(PC),D2
                cmp.w   #243,D0
                bls     dochangevol
                cmp.w   #283,D0
                bls     return2
                cmp.w   #295,D0
                bls     shvoup
                subq.w  #1,D2
;                btst    #2,$DFF016
;                bne.s   shvoskip
                btst    #0,mousebut
                beq.s   shvoskip

                sub.w   #9,D2
shvoskip:
                bpl.s   shvoskip2
                moveq   #0,D2
shvoskip2:
                move.w  D2,samplevol
                bsr     wait_4000
                bra.s   showvol
shvoup:         addq.l  #1,D2
;               btst    #2,$DFF016
;               bne.s   shvoskip3
                btst    #0,mousebut
                beq.s   shvoskip3

                add.w   #9,D2
shvoskip3:
                cmp.w   #999,D2
                bls.s   shvoskip2
                move.w  #999,samplevol
                bsr     wait_4000
showvol:        move.w  #3711,textoffset
                move.w  samplevol(PC),wordnumber
                bsr     print3decdigits
                lea     percenttext(PC),A0
                move.w  #1,textlength
                bra     showtext2

percenttext:    DC.B '%',0

dochangevol:
                bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D3
                move.w  sampleinfo(PC),D3
                beq     errorrestorecol
                add.w   D3,D3
                subq.w  #1,D3
                move.l  si_pointer,D0
                beq     errorrestorecol
                movea.l D0,A1
                move.w  samplevol(PC),D0
dcvloop:        move.b  (A1),D1
                ext.w   D1
                muls    D0,D1
                divs    #100,D1
                cmp.w   #127,D1
                ble.s   dcvskip
                moveq   #127,D1
dcvskip:        cmp.w   #-128,D1
                bge.s   dcvskp2
                moveq   #-128,D1
dcvskp2:        move.b  D1,(A1)+
                dbra    D3,dcvloop
                movea.l si_pointer(PC),A1
                clr.w   (A1)
                bsr     restoreptrcol
                bra     displaysample

mix:
;                btst    #2,$DFF016
;                beq     oldmix
                btst    #0,mousebut
                bne     oldmix

                bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                move.w  #1,getlineflag
                move.w  #4,mixcurpos
mixlopx:        bsr     displaymix
                bsr     gethexkey
                tst.b   D0
                bne.s   mixnzro
                cmpi.b  #68,mixchar
                beq     mix2
                cmpi.b  #69,mixchar
                beq     endmix
;               btst    #2,$DFF016
;               beq     endmix
                btst    #0,mousebut
                bne     endmix

mixpchr:        lea     mixtext(PC),A0
                lea     fasthextable+1,A1
                add.w   D1,D1
                move.w  mixcurpos(PC),D0
                move.b  0(A1,D1.w),0(A0,D0.w)
mixmoveright:
                move.w  mixcurpos,D0
                addq.w  #1,D0
                cmp.w   #6,D0
                beq.s   mmrp1
                cmp.w   #9,D0
                beq.s   mmrp2
                cmp.w   #15,D0
                bhs.s   mmrp3
mmrok:          move.w  D0,mixcurpos
                bra     mixlopx
mmrp1:          moveq   #7,D0
                bra.s   mmrok
mmrp2:          moveq   #13,D0
                bra.s   mmrok
mmrp3:          moveq   #14,D0
                bra.s   mmrok

mixnzro:        cmp.b   #1,D0
                beq.s   mixmoveright
mixmoveleft:
                move.w  mixcurpos,D0
                subq.w  #1,D0
                cmp.w   #4,D0
                blo.s   mmlp1
                cmp.w   #6,D0
                beq.s   mmlp2
                cmp.w   #12,D0
                beq.s   mmlp3
                bra.s   mmrok
mmlp1:          moveq   #4,D0
                bra.s   mmrok
mmlp2:          moveq   #5,D0
                bra.s   mmrok
mmlp3:          moveq   #8,D0
                bra.s   mmrok

displaymix:
                move.w  #53,linecury
                move.w  mixcurpos,D0
                lsl.w   #3,D0
                add.w   #132,D0
                move.w  D0,linecurx
                bsr     updatelinecurpos
                lea     mixtext(PC),A0
                move.w  #1936,D1
                moveq   #22,D0
                bsr     showtext3
                bsr     wait_4000
                bsr     wait_4000
                bra     wait_4000

mixtext:        DC.B 'mix 01+02 to 03       '
mixchar:        DC.B 0,0
mixcurpos:      DC.W 0
tosam:          DC.W 0
fromptr1:       DC.L 0
fromptr2:       DC.L 0
toptr:          DC.L 0
mixptr:         DC.L 0
mixlength:      DC.L 0

endmix:         clr.b   rawkeycode
                bsr     restoremix
                bra     restoreptrcol

restoremix:
                clr.w   getlineflag
                move.w  #270,linecury
                clr.w   linecurx
                bsr     updatelinecurpos
                lea     editoptext3(PC),A0
                move.w  #1936,D1
                moveq   #22,D0
                bra     showtext3

mix2:           bsr     restoremix
                bsr     turnoffvoices
                lea     sampleptrs,A2
                moveq   #0,D0
                lea     mixtext+4(PC),A0
                bsr     hextointeger2
                tst.w   D0
                beq     samoutofrange
                cmp.w   #$1F,D0
                bhi     samoutofrange
                lsl.w   #2,D0
                lea     0(A2,D0.w),A3
                move.l  A3,fromptr1

                moveq   #0,D0
                lea     mixtext+7(PC),A0
                bsr     hextointeger2
                tst.w   D0
                beq     samoutofrange
                cmp.w   #$1F,D0
                bhi     samoutofrange
                lsl.w   #2,D0
                lea     0(A2,D0.w),A3
                move.l  A3,fromptr2

                moveq   #0,D0
                lea     mixtext+13(PC),A0
                bsr     hextointeger2
                move.w  D0,tosam
                beq     samoutofrange
                cmp.w   #$1F,D0
                bhi     samoutofrange
                lsl.w   #2,D0
                lea     0(A2,D0.w),A3
                move.l  A3,toptr

                movea.l fromptr1,A1
                movea.l fromptr2,A2
                move.l  124(A1),D1
                move.l  124(A2),D2
                cmp.l   D1,D2
                blo.s   mixnswp
                exg     D1,D2
mixnswp:        tst.l   D1
                beq     samemptyerror   ; Both samples had length=0
                move.l  D1,D0
                and.l   #$FFFF,D0
                move.l  D0,mixlength
                move.l  #memf_chip+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,mixptr
                beq     sammemerror     ; No memory for new sample...

                lea     mixingtext(PC),A0
                bsr     showstatustext
                movea.l fromptr1(PC),A1
                move.l  124(A1),D1
                movea.l (A1),A1
                movea.l fromptr2(PC),A2
                move.l  124(A2),D2
                movea.l (A2),A2
                movea.l mixptr(PC),A3
                move.l  mixlength,D3
                tst.w   D1
                beq.s   mixnd1
                subq.w  #1,D1
mixnd1:         tst.w   D2
                beq.s   mixnd2
                subq.w  #1,D2
mixnd2:         subq.w  #1,D3

mixlop2:        move.b  (A1),D4
                ext.w   D4
                move.b  (A2),D0
                ext.w   D0
                add.w   D4,D0
                tst.b   halfclipflag
                beq     mixhalf
                cmp.w   #127,D0
                ble.s   mixnbig
                moveq   #127,D0
mixnbig:        cmp.w   #-128,D0
                bge     mixokok
                moveq   #-128,D0
                bra     mixokok
mixhalf:        asr.w   #1,D0
mixokok:        move.b  D0,(A3)+

                tst.w   D1
                beq.s   zerd1
                addq.l  #1,A1
                subq.w  #1,D1
                bne.s   zerd1
                suba.l  A1,A1

zerd1:          tst.w   D2
                beq.s   zerd2
                addq.l  #1,A2
                subq.w  #1,D2
                bne.s   zerd2
                suba.l  A2,A2

zerd2:          dbra    D3,mixlop2
                move.w  tosam(PC),insnum
                bsr     freesample
                movea.l toptr(PC),A0
                movea.l mixptr(PC),A1
                clr.w   (A1)
                move.l  A1,(A0)
                move.l  mixlength(PC),124(A0)
                movea.l songdataptr(PC),A0
                move.w  tosam(PC),D0
                subq.w  #1,D0
                mulu    #30,D0
                lea     20(A0,D0.w),A0
                move.l  mixlength(PC),D0
                lsr.w   #1,D0
                move.w  D0,22(A0)
                move.w  #$40,24(A0)
                move.w  #$00,26(A0)
                move.w  #$01,28(A0)
                bsr     restoreptrcol
                bsr     showallright
                bsr     showsampleinfo
                bra     displaysample

samoutofrange:
                lea     mixerrtext1(PC),A0
                bsr     showstatustext
                bra     errorrestorecol
samemptyerror:
                lea     mixerrtext2(PC),A0
                bsr     showstatustext
                bra     errorrestorecol
sammemerror:
                lea     mixerrtext3(PC),A0
                bsr     showstatustext
                bra     errorrestorecol
outofmemerr:
                lea     mixerrtext3(PC),A0
                bsr     showstatustext
                bsr     seterrorptrcol
                moveq   #0,D0
                rts

mixerrtext1:    DC.B 'not range 01-1F !',0
mixerrtext2:    DC.B 'empty samples !!!',0
mixerrtext3:    DC.B 'out of memory !!!',0
mixingtext:     DC.B 'mixing samples...',0

oldmix:         move.l  samplepos(PC),flangepos
domix:          bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D2
                move.w  sampleinfo(PC),D2 ; 22(A0)
                beq     return2
                add.w   D2,D2
                move.l  si_pointer(PC),D0
                beq     errorrestorecol
                bsr     allocbuffer
                movea.l D0,A2
                movea.l D0,A3
                movea.l A1,A4
                adda.l  D2,A3
                adda.l  flangepos(PC),A2
                clr.l   modoffset
                clr.l   modpos
                moveq   #-1,D7
mixloop:        addq.l  #1,D7
                cmpa.l  A3,A2
                bhs     mixskip
                move.l  markstartofs(PC),D0
                bmi.s   omxget
                move.l  markendofs(PC),D1
                cmp.l   D0,D1
                beq.s   omxget
                cmp.l   D0,D7
                blo.s   omxok2
                cmp.l   D1,D7
                bhi.s   omxok2
omxget:         move.b  (A2),D0
                ext.w   D0
                move.b  (A1),D1
                ext.w   D1
                add.w   D1,D0
                tst.b   halfclipflag
                beq.s   omxhalf
                cmp.w   #127,D0
                ble.s   omxnbig
                moveq   #127,D0
omxnbig:        cmp.w   #-128,D0
                bge.s   omxokok
                moveq   #-128,D0
                bra.s   omxokok
omxhalf:        asr.w   #1,D0
omxokok:        move.b  D0,(A2)+
                bsr     updatemod
                bra.s   mixloop
omxok2:         addq.l  #1,A2
                bsr     updatemod
                bra.s   mixloop

mixskip:        movea.l si_pointer(PC),A1
                clr.w   (A1)
                bsr     freebuffer
                bsr     restoreptrcol
                bsr     waitforbuttonup
                tst.w   disporredraw
                beq     displaysample
                clr.w   disporredraw
                bra     redrawsample

disporredraw:   DC.W 0

allocbuffer:
                move.l  D0,D7
                move.l  D2,D0
                move.l  D2,bufmemsize
                move.l  #memf_public+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,bufmemptr
                beq     outofmemerr
                movea.l D7,A0
                movea.l D0,A1
                move.l  bufmemsize(PC),D0
                subq.l  #1,D0
albloop:        move.b  (A0)+,(A1)+
                dbra    D0,albloop
                movea.l bufmemptr(PC),A1
                move.l  D7,D0
                rts

freebuffer:
                move.l  bufmemptr(PC),D0
                beq     return2
                movea.l D0,A1
                move.l  bufmemsize(PC),D0
                movea.l 4.w,A6
                jsr     lvofreemem
                clr.l   bufmemptr
                rts

echo:           move.l  samplepos(PC),flangepos
                bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D2
                move.w  sampleinfo(PC),D2 ; 22(A0)
                beq     errorrestorecol
                add.w   D2,D2
                move.l  si_pointer(PC),D0
                beq     errorrestorecol
                movea.l D0,A1
                movea.l D0,A2
                movea.l D0,A3
                movea.l D0,A4
                adda.l  D2,A3
                adda.l  flangepos(PC),A2
                clr.l   modoffset
                clr.l   modpos
flaloop:        cmpa.l  A3,A2
                bhs     flaskip
                move.b  (A2),D0
                ext.w   D0
                move.b  (A1),D1
                ext.w   D1
                add.w   D1,D0
                asr.w   #1,D0
                move.b  D0,(A2)+
                bsr     updatemod
                bra     flaloop
flaskip:        movea.l si_pointer(PC),A1
                clr.w   (A1)
                bsr     restoreptrcol
                tst.b   halfclipflag
                beq     displaysample
                move.w  samplevol,-(SP)
                move.w  #200,samplevol
                bsr     dochangevol
                move.w  (SP)+,samplevol
                bra     displaysample

filter2:        move.w  #1,disporredraw
filter:         clr.b   rawkeycode
                lea     filteringtext,A0
                bsr     showstatustext
                move.l  #1,flangepos
                move.b  modspeed(PC),-(SP)
                move.b  halfclipflag,-(SP)
                clr.b   modspeed
                clr.b   halfclipflag
                bsr     domix
                move.b  (SP)+,halfclipflag
                move.b  (SP)+,modspeed
                bra     showallright

filteringtext:  DC.B 'filtering',0

boost:          bsr.s   boost3
                bra     displaysample
boost2:         bsr.s   boost3
                bra     redrawsample
boost3:         clr.b   rawkeycode
                bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                lea     boostingtext,A0
                bsr     showstatustext
                moveq   #0,D3
                move.w  sampleinfo(PC),D3
                beq     booend
                add.w   D3,D3
                subq.w  #1,D3
                move.l  si_pointer(PC),D0
                beq     booend
                movea.l D0,A1
                move.l  markstartofs(PC),D0
                bmi.s   booskp1
                move.l  markendofs(PC),D1
                sub.l   D0,D1
                beq.s   booskp1
                move.l  D1,D3
                movea.l samstart(PC),A1
                adda.l  D0,A1
booskp1:        moveq   #0,D0
booloop:        move.b  (A1),D1
                ext.w   D1
                move.w  D1,D2
                sub.w   D0,D1
                move.w  D2,D0
                tst.w   D1
                bmi     booneg
                asr.w   #2,D1
                add.w   D1,D2
                bra     booskip
booneg:         neg.w   D1
                asr.w   #2,D1
                sub.w   D1,D2
booskip:        cmp.w   #127,D2
                ble     booskp2
                moveq   #127,D2
booskp2:        cmp.w   #-128,D2
                bge     booskp3
                moveq   #-128,D2
booskp3:        move.b  D2,(A1)+
                dbra    D3,booloop
                movea.l si_pointer(PC),A1
                clr.w   (A1)
booend:         bsr     showallright
                bra     restoreptrcol

boostingtext:   DC.B 'boosting',0,0

xfade:          bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D2
                move.w  sampleinfo(PC),D2 ; 22(A0)
                beq     errorrestorecol
                add.w   D2,D2
                move.l  si_pointer(PC),D0
                beq     errorrestorecol
                movea.l D0,A1
                movea.l D0,A2
                adda.l  D2,A2
xfaloop:        move.b  (A1),D0
                ext.w   D0
                move.b  -(A2),D1
                ext.w   D1
                add.w   D1,D0
                tst.b   halfclipflag
                beq     xfahalf
                cmp.w   #127,D0
                ble     xfanbig
                moveq   #127,D0
xfanbig:        cmp.w   #-128,D0
                bge     xfaokok
                moveq   #-128,D0
                bra     xfaokok
xfahalf:        asr.w   #1,D0
xfaokok:        move.b  D0,(A1)+
                move.b  D0,(A2)
                cmpa.l  A2,A1
                blo.s   xfaloop
                movea.l si_pointer(PC),A1
                clr.w   (A1)
                bsr     restoreptrcol
                bra     displaysample

backwards:
                bsr     waitforbuttonup
                bsr     storeptrcol
                bsr     setwaitptrcol
                moveq   #0,D2
                move.w  22(A5),D2
                beq     errorrestorecol
                move.l  si_pointer(PC),D0
                beq     errorrestorecol
                movea.l D0,A1
                movea.l D0,A2
                add.l   D2,D2
                adda.l  D2,A2
                move.l  markstartofs(PC),D0
                bmi.s   bacloop
                move.l  markendofs(PC),D1
                sub.l   D0,D1
                beq.s   bacloop
                movea.l samstart(PC),A1
                adda.l  D0,A1
                movea.l A1,A2
                adda.l  D1,A2
bacloop:        move.b  (A1),D0
                move.b  -(A2),(A1)+
                move.b  D0,(A2)
                cmpa.l  A2,A1
                blo.s   bacloop
                movea.l si_pointer(PC),A1
                clr.w   (A1)
                bsr     restoreptrcol
                bra     displaysample

upsample:
                bsr     waitforbuttonup
                lea     upsampletext,A0
                bsr     areyousure
                bne     return2
                bsr     turnoffvoices
                bsr     storeptrcol
                bsr     setwaitptrcol
                move.w  insnum(PC),D0
                lsl.w   #2,D0
                lea     sampleptrs(PC),A0
                lea     0(A0,D0.w),A0
                move.l  124(A0),D3
                cmp.l   #2,D3
                bls     errorrestorecol
                move.l  (A0),D0
                beq     errorrestorecol
                movea.l D0,A2
                movea.l D0,A4
                move.l  D3,D4
                lsr.l   #1,D3
                bclr    #0,D3
                move.l  D3,D0
                moveq   #memf_chip,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                tst.l   D0
                beq.s   upserro
                movea.l D0,A3
                move.l  D0,D2
                move.l  D3,D5
                subq.l  #1,D3
upsloop:        move.b  (A2)+,(A3)+
                addq.l  #1,A2
                dbra    D3,upsloop
                movea.l A4,A1
                move.l  D4,D0
                movea.l 4.w,A6
                jsr     lvofreemem
                move.w  insnum(PC),D0
                lsl.w   #2,D0
                lea     sampleptrs(PC),A0
                lea     0(A0,D0.w),A0
                move.l  D2,(A0)
                move.l  D5,124(A0)
                movea.l D2,A0
                clr.w   (A0)
                move.w  22(A5),D0
                lsr.w   #1,D0
                move.w  D0,22(A5)
                move.w  26(A5),D0
                lsr.w   #1,D0
                move.w  D0,26(A5)
                move.w  28(A5),D0
                lsr.w   #1,D0
                bne     upsskip2
                moveq   #1,D0
upsskip2:
                move.w  D0,28(A5)
                bsr     showsampleinfo
                bsr     waitforbuttonup
                bsr     restoreptrcol
                bra     redrawsample

upserro:        bsr     restoreptrcol
                bra     outofmemerr

downsample:
                bsr     waitforbuttonup
                tst.w   insnum
                beq     notsamplenull
                lea     downsampletext,A0
                bsr     areyousure
                bne     return2
                bsr     turnoffvoices
                bsr     storeptrcol
                bsr     setwaitptrcol
                move.l  si_pointer(PC),D0
                beq     errorrestorecol
                moveq   #0,D0
                move.w  sampleinfo(PC),D0
                beq     errorrestorecol
                add.l   D0,D0
                cmp.l   #$FFFE,D0
                bhi     errorrestorecol
                add.l   D0,D0
                cmp.l   #$FFFE,D0
                bls     dnsskip
                move.l  #$FFFE,D0
dnsskip:        move.l  D0,bufmemsize
                moveq   #memf_chip,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,bufmemptr
                beq     sammemerror
                movea.l si_pointer(PC),A1
                movea.l D0,A2
                move.l  bufmemsize,D3
                lsr.l   #1,D3
                subq.l  #1,D3
dnsloop:        move.b  (A1)+,D0
                move.b  D0,(A2)+
                move.b  D0,(A2)+
                dbra    D3,dnsloop
                bsr     freesample
                lea     sampleptrs,A0
                move.w  insnum(PC),D0
                lsl.w   #2,D0
                move.l  bufmemptr,0(A0,D0.w)
                move.l  bufmemsize,124(A0,D0.w)
                move.w  22(A5),D0
                add.w   D0,D0
                cmp.w   #$7FFF,D0
                bls     dnsok1
                move.w  #$7FFF,D0
dnsok1:         move.w  D0,22(A5)
                move.w  26(A5),D0
                add.w   D0,D0
                cmp.w   #$7FFF,D0
                bls     dnsok2
                move.w  #$7FFF,D0
dnsok2:         move.w  D0,26(A5)
                move.w  28(A5),D0
                cmp.w   #1,D0
                beq     dnsok3
                add.w   D0,D0
                cmp.w   #$7FFF,D0
                bls     dnsok3
                move.w  #$7FFF,D0
dnsok3:         move.w  D0,28(A5)
                bsr     showsampleinfo
                bsr     waitforbuttonup
                bsr     restoreptrcol
                bra     redrawsample

samplepos:      DC.L 0
samplevol:      DC.W 100
flangepos:      DC.L 0
modspeed:       DC.B 0
halfclipflag:   DC.B 0
modpos:         DC.L 0
modoffset:      DC.L 0
bufmemptr:      DC.L 0
bufmemsize:     DC.L 0
                ENDPART

                PART 'display/convert routs '

showallright:
                movem.l D0-A6,-(SP)
                lea     allrighttext(PC),A0
                bsr.s   showstatustext
                movem.l (SP)+,D0-A6
                rts

showstatustext:
                movea.l log_base,A1
                adda.l  #81+(128*320)+4,A1
                moveq   #4,D0
stloop1:        moveq   #16,D1
                moveq   #15,D3
stloop2:        clr.b   (A1)
                adda.w  D3,A1
                eori.w  #14,D3
                dbra    D1,stloop2
                lea     320-143(A1),A1
                dbra    D0,stloop1
                movea.l A0,A1
                move.w  #5131,D1
                moveq   #-1,D0
stloop3:        addq.w  #1,D0
                tst.b   (A1)+
                bne.s   stloop3
                bra     showtext3

;---- Redraw Pattern ----

redrawpattern:
                tst.w   samscrenable
                bne     return2
                sf      pattrfsh
                move.w  #5121,textoffset
                move.w  patternnumber+2(PC),wordnumber
                bsr     print2decdigits ; Print PatternNumber
                movea.l songdataptr(PC),A6
                lea     $043C(A6),A6
                move.l  patternnumber,D6
                lsl.l   #8,D6
                lsl.l   #2,D6
                adda.l  D6,A6
                move.w  #1961,textoffset
                clr.l   ppattpos
                lea     periodtable(PC),A2
                lea     redrawbuffer(PC),A3
                lea     fasthextable(PC),A4
                moveq   #'0',D4
                move.b  blankzeroflag,D5
                moveq   #63,D6
rpnxpos:        moveq   #3,D7
                move.w  ppattpos+2(PC),wordnumber
                bsr     print2decdigitsp ; Print PatternPosition
                addq.w  #1,textoffset
                addq.l  #1,ppattpos
rploop:         moveq   #0,D0
                moveq   #0,D1
                move.w  (A6),D1
                and.w   #$0FFF,D1
                bne.s   rpfind
                move.l  #'--- ',(A3)
                bra.s   rpskip
rpfind:         moveq   #36,D2
rpfindloop:
                cmp.w   0(A2,D0.w),D1
                beq.s   rpfound
                addq.l  #2,D0
                dbra    D2,rpfindloop
                move.l  #'??? ',(A3)
                bra.s   rpskip
rpfound:        add.l   D0,D0
                add.l   notenamesptr(PC),D0
                movea.l D0,A0
                move.l  (A0),(A3)
rpskip:         move.b  (A6)+,D0
                lsr.b   #4,D0
                add.b   #'0',D0
                move.b  D0,3(A3)
                move.b  (A6)+,D0
                moveq   #0,D0
                move.b  (A6)+,D0
                add.w   D0,D0
                move.w  0(A4,D0.w),4(A3)
                moveq   #0,D0
                move.b  (A6)+,D0
                add.w   D0,D0
                move.w  0(A4,D0.w),6(A3)

                tst.b   D5
                beq.s   rpskp3
                cmp.b   3(A3),D4
                bne.s   rpskp3
                move.b  #' ',3(A3)
rpskp3:         move.w  #9,textlength
                move.l  A3,showtextptr
                bsr     showtextp
                dbra    D7,rploop       ; Next Channel
                addi.w  #241,textoffset
                dbra    D6,rpnxpos      ; Next PattPos
                rts

redrawbuffer:   DC.B '---00000 ',0
                EVEN

showposition:
                movea.l songdataptr(PC),A0
                lea     952(A0),A0
                adda.l  currpos(PC),A0
                move.b  (A0),wordnumber+1
                move.b  (A0),pattrfshnum+3
                moveq   #0,D1
                move.b  (A0),D1
                cmp.b   longffff+3(PC),D1
                beq.s   spskip2
                st      pattrfsh
spskip2:        move.w  #608,textoffset
                move.b  (A0),longffff+3
                cmpi.w  #0,currscreen
                beq.s   spokok
                cmpi.w  #1,currscreen
                beq.s   spokok
                cmpi.w  #6,currscreen
                beq.s   spokok
                rts
spokok:         bsr     print4decdigits
                move.w  currpos+2,wordnumber
                move.w  #168,textoffset
                bra     print4decdigits


showsonglength:
                cmpi.w  #2,currscreen
                beq.s   showsongname
                cmpi.w  #3,currscreen
                beq.s   showsongname
                cmpi.w  #4,currscreen
                beq     return2
                cmpi.w  #5,currscreen
                beq.s   showsongname
                movea.l songdataptr(PC),A0
                lea     sd_numofpatt(A0),A0
                move.l  A0,currcmds
                clr.w   wordnumber
                move.b  (A0),wordnumber+1
                move.w  #1048,textoffset
                bsr     print4decdigits
                movea.l currcmds(PC),A0
showsongname:
                movea.l songdataptr(PC),A0
                move.w  #4133,D1
                moveq   #20,D0
                bra     showtext3


showsampleinfo:
                moveq   #0,D0
                move.w  insnum(PC),D0
                move.w  D0,playinsnum
                bne.s   ssiskipit
                move.w  lastinsnum(PC),D0
ssiskipit:
                move.w  D0,D1
                lsl.l   #2,D0
                lea     sampleptrs(PC),A0
                move.l  0(A0,D0.w),si_pointer
                movea.l songdataptr(PC),A0
                lea     -10(A0),A0
                move.w  D1,D0
                mulu    #30,D0
                adda.l  D0,A0
                move.l  A0,currcmds
                move.l  22(A0),sampleinfo
                move.l  26(A0),si_long
                tst.b   nosampleinfo
                bne     ssiskip

                move.l  A0,-(SP)
                move.b  #' ',finetunesign
                move.b  24(A0),D0
                beq.s   dopfitu
                move.b  #'+',finetunesign
                btst    #3,D0
                beq.s   dopfitu
                move.b  #'-',finetunesign
                moveq   #16,D1
                sub.b   D0,D1
                move.b  D1,D0
dopfitu:        move.w  #1491,textoffset
                bsr     printhexdigit   ; FineTune
                lea     finetunesign(PC),A0
                move.w  #1490,D1
                moveq   #1,D0
                bsr     showtext3       ; FineTuneSign
                movea.l (SP)+,A0

                clr.w   wordnumber
                move.b  25(A0),wordnumber+1
                move.w  wordnumber,volumeefx
                ori.w   #$0C00,volumeefx
                move.w  #2368,textoffset
                bsr     printhexword    ; Volume

                moveq   #0,D0
                move.w  sampleinfo(PC),D0
                add.l   D0,D0
                move.w  D0,wordnumber
                move.l  samplepos,D2
                cmp.l   D0,D2
                bls.s   showlen
                move.l  D0,samplepos
                bsr     showpos
                moveq   #0,D0
                move.w  sampleinfo(PC),D0
                add.l   D0,D0
                move.w  D0,wordnumber
showlen:        move.w  #2808,textoffset
                bsr     printhexword    ; Length

                move.w  si_long,D0
                add.w   D0,D0
                move.w  D0,wordnumber
                move.w  #3248,textoffset
                bsr     printhexword    ; Repeat

                move.w  si_long+2,D0
                add.w   D0,D0
                move.w  D0,wordnumber
                move.w  #3688,textoffset
                bsr     printhexword    ; RepLen

                bsr.s   ssiinst

ssiskip:        tst.b   nosampleinfo
                beq.s   ssiskp2
                cmpi.w  #5,currscreen
                beq.s   ssiskp2
                cmpi.w  #3,currscreen
                bne     return2
ssiskp2:        movea.l currcmds(PC),A0
                move.w  #4573,D1
                moveq   #22,D0
                bra     showtext3       ; SampleName

ssiinst:        tst.b   nosampleinfo
                bne     return2
                move.w  insnum(PC),wordnumber
                move.w  #1928,textoffset
                bra     printhexword    ; SampleNumber

finetunesign:   DC.B ' ',0
volumeefx:      DC.W 0

;---- Print Decimal Digits ----

print2decdigits:
                move.w  #2,textlength
                moveq   #0,D1
                move.w  wordnumber(PC),D1
                lea     numbertext(PC),A0
                bra.s   pdig

print2decdigitsp:
                move.w  #2,textlength
                moveq   #0,D1
                move.w  wordnumber(PC),D1
                lea     numbertext(PC),A0
                divu    #10,D1
                bsr.s   doonedigit
                bsr.s   doonedigit
                movea.l #numbertext,A0
                bra     showtext2p


print3decdigits:
                move.w  #3,textlength
                moveq   #0,D1
                move.w  wordnumber(PC),D1
                lea     numbertext(PC),A0
                bra.s   pdig100

print4decdigits:
                move.w  #4,textlength
                moveq   #0,D1
                move.w  wordnumber(PC),D1
                lea     numbertext(PC),A0
                divu    #1000,D1
                bsr.s   doonedigit
pdig100:        divu    #100,D1
                bsr.s   doonedigit
pdig:           divu    #10,D1
                bsr.s   doonedigit
                bsr.s   doonedigit
                movea.l #numbertext,A0
                bra     showtext2

doonedigit:
                add.b   #'0',D1
                move.b  D1,(A0)+
                clr.w   D1
                swap    D1
                rts

print6decdigits:
                lea     numbertext,A0
                move.l  D0,D1
                cmp.l   #1000000,D1
                bhs     toobig

                swap    D1
                clr.w   D1
                swap    D1
                divu    #10,D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,5(A0)
                cmp.l   #10,D0
                blo.s   p6zero1

                divu    #100,D0
                move.l  D0,D1
                clr.w   D0
                swap    D0
                divu    #10,D0
                add.b   #'0',D0
                move.b  D0,4(A0)
                and.l   #$FFFF,D1
                beq.s   p6zero2
                divu    #10,D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,3(A0)
                clr.w   D1
                swap    D1
                tst.w   D1
                beq.s   p6zero3
                divu    #10,D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,2(A0)
                clr.w   D1
                swap    D1
                tst.w   D1
                beq.s   p6zero4
                divu    #10,D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,1(A0)
                clr.w   D1
                swap    D1
                tst.w   D1
                beq.s   p6zero5
                divu    #10,D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,(A0)
                bra.s   p6end

p6zero1:        move.b  #' ',4(A0)
p6zero2:        move.b  #' ',3(A0)
p6zero3:        move.b  #' ',2(A0)
p6zero4:        move.b  #' ',1(A0)
p6zero5:        move.b  #' ',0(A0)
p6end:          move.w  #6,textlength
                bra     showtext2

toobig:         move.b  #' ',D0
                bsr.s   toobig2
                divu    #1000,D0
                move.w  D0,wordnumber
                bsr     print4decdigits
                move.b  #'K',D0
toobig2:        lea     numbertext(PC),A0
                move.b  D0,(A0)
                move.w  #1,textlength
                bra     showtext2

numbertext:     DCB.B 6

;---- Print Hex Digits ----

printhiinstrnum:
                moveq   #0,D0
                tst.w   currentplaynote
                beq.s   phin2
                move.w  insnum(PC),D0
                lsr.w   #4,D0
                bne.s   printhexdigitp
phin2:          tst.b   blankzeroflag
                beq.s   printhexdigitp
                lea     blankinstext(PC),A0
                move.w  #1,textlength
                bra     showtext2p

printhexdigit:
                and.l   #$0F,D0
                add.l   D0,D0
                lea     fasthextable+1(PC),A0
                adda.l  D0,A0
phd2:           move.w  #1,textlength
                bra     showtext2

printhexdigitp:
                and.l   #$0F,D0
                add.l   D0,D0
                lea     fasthextable+1(PC),A0
                adda.l  D0,A0
                move.w  #1,textlength
                bra     showtext2p

blankinstext:   DC.B " ",0

printhexwordp:
                lea     wordnumber(PC),A0
                moveq   #0,D0
                move.b  (A0),D0
                add.l   D0,D0
                lea     fasthextable(PC),A0
                adda.l  D0,A0
                move.w  #2,textlength
                bsr     showtext2p
printhexbytep:
                lea     wordnumber(PC),A0
                moveq   #0,D0
                move.b  1(A0),D0
                add.l   D0,D0
                movea.l #fasthextable,A0
                adda.l  D0,A0
                move.w  #2,textlength
                bsr     showtext2p
                clr.w   wordnumber
                rts

printhexword:
                lea     wordnumber(PC),A0
                moveq   #0,D0
                move.b  (A0),D0
                add.l   D0,D0
                lea     fasthextable(PC),A0
                adda.l  D0,A0
                move.w  #2,textlength
                bsr     showtext2


printhexbyte:
                lea     wordnumber(PC),A0
                moveq   #0,D0
                move.b  1(A0),D0
                add.l   D0,D0
                movea.l #fasthextable,A0
                adda.l  D0,A0
                move.w  #2,textlength
                bsr     showtext2
                clr.w   wordnumber
                rts


showtext3p:
                move.w  D0,textlength
                move.w  D1,textoffset
showtext2p:
                move.l  A0,showtextptr
showtextp:
                movem.l A2-A3,-(SP)
                lea     texttable(PC),A3
                move.w  textlength(PC),D0
                movea.l textbplptr(PC),A1
                adda.w  textoffset(PC),A1
                add.w   D0,textoffset
                movea.l showtextptr(PC),A0
                bra.s   dstlope
dstloop:        moveq   #0,D1
                move.b  (A0)+,D1
                bne.s   dstskip
                move.b  showzeroflag(PC),D1
dstskip:        move.b  0(A3,D1.w),D1
                lsl.w   #3,D1
                lea     fontdata(PC,D1.l),A2
                move.b  (A2)+,(A1)+
                move.b  (A2)+,40-1(A1)
                move.b  (A2)+,80-1(A1)
                move.b  (A2)+,120-1(A1)
                move.b  (A2),160-1(A1)
dstlope:        dbra    D0,dstloop
                movem.l (SP)+,A2-A3
                rts
fontdata:       IBYTES 'RAW\PTFONT.RAW'
                EVEN

;---- Text Output Routines ----

showtext3:
                move.w  D0,textlength
                move.w  D1,textoffset
showtext2:
                move.l  A0,showtextptr
showtext:
                movem.l A2-A4,-(SP)
                lea     texttable(PC),A3
                move.w  textlength(PC),D0
                movea.l log_base,A1
                moveq   #0,D1
                move.w  textoffset(PC),D1
                lea     interaddtab(PC),A4
                lsl.l   #3,D1
                btst    #3,D1
                beq.s   .notonodd
                addq.l  #1,A1
                addq.l  #2,A4
.notonodd:      and.w   #$FFF0,D1
                lea     4(A1,D1.l),A1   ;;
                add.w   D0,textoffset
                movea.l showtextptr(PC),A0
                bra.s   .dstlope
.dstloop:
                moveq   #0,D1
                move.b  (A0)+,D1
                bne.s   .dstskip
                move.b  showzeroflag(PC),D1
.dstskip:
                move.b  0(A3,D1.w),D1
                lsl.w   #3,D1
                lea     fontdata2(PC,D1.l),A2
                move.b  (A2)+,(A1)
                move.b  (A2)+,160*2(A1)
                move.b  (A2)+,320*2(A1)
                move.b  (A2)+,480*2(A1)
                move.b  (A2),640*2(A1)
                adda.w  (A4)+,A1
.dstlope:
                dbra    D0,.dstloop
                movem.l (SP)+,A2-A4
                rts
fontdata2:      IBYTES 'RAW\PTFONT.RAW'
                EVEN

interaddtab:
                REPT 20
                DC.W 1,15
                ENDR

spaceshowtext:
                move.w  showzeroflag(PC),-(SP)
                move.b  #' ',showzeroflag
                bsr     showtext
                move.w  (SP)+,showzeroflag
                rts

showzeroflag:   DC.B 95,0


texttable:
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ; 32
                DC.B 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
                DC.B 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47 ; 64
                DC.B 48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
                DC.B 69,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47 ; 96
                DC.B 48,49,50,51,52,53,54,55,56,57,58,65,66,67,68,63
                DC.B 69,70,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 128
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 160
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 192
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 224
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


;---- Set Sprite Position ----

setspritepos:
                movem.w D0-D1,(A0)
                rts

                add.w   #$2C,D1
                add.w   D1,D2
                rol.w   #7,D2
                add.w   D2,D2
                bcc.s   sppskip
                or.w    #2,D2
sppskip:        rol.w   #7,D1
                add.w   D1,D1
                bcc.s   sppskip2
                or.w    #4,D2
sppskip2:
                add.w   #$7D,D0
                asr.w   #1,D0
                bcc.s   sppskip3
                or.w    #1,D2
sppskip3:
                or.w    D0,D1
                move.w  D1,(A0)
                move.w  D2,2(A0)
                rts


hextointeger:
                moveq   #0,D0
                bsr     single_hti
                lsl.w   #8,D1
                lsl.w   #4,D1
                or.w    D1,D0
                bsr     single_hti
                lsl.w   #8,D1
                or.w    D1,D0
hextointeger2:
                bsr     single_hti
                lsl.w   #4,D1
                or.w    D1,D0
                bsr     single_hti
                or.w    D1,D0
                rts
inttohex2:
                moveq   #1,D2
                bra     ithaloop

inttohexascii:
                moveq   #3,D2
ithaloop:
                move.w  D0,D1
                and.b   #15,D1
                cmp.b   #10,D1
                blo     ithaskip
                addq.b  #7,D1
ithaskip:
                add.b   #'0',D1
                move.b  D1,-(A0)
                ror.w   #4,D0
                dbra    D2,ithaloop
                rts

single_hti:
                moveq   #0,D1
                move.b  (A0)+,D1
                cmp.b   #$60,D1
                blo     shtiskip
                sub.b   #$20,D1
shtiskip:
                sub.b   #$30,D1
                cmp.b   #9,D1
                bls     return2
                subq.b  #7,D1
                rts
                ENDPART

plst:           jmp     shownotimpl
preseteditor:   jmp     shownotimpl

                PART 'SAMPLER SCREEN'

;---- Sampler Screen ----

samplerscreen:
                clr.b   rawkeycode
                jsr     waitforbuttonup
                tst.w   samscrenable
                bne     exitfromsam
                move.l  editmode(PC),saveeditmode
                clr.l   editmode

                movea.l textbplptr(PC),A0
;                lea     $15B8(A0),A0
                move.l  A0,D0
;                lea     coplist2bpl4ptr,A1
;                move.w  D0,6(A1)
;                swap    D0
;                move.w  D0,2(A1)

                moveq   #0,D0
                move.w  #270,D1
                moveq   #14,D2
                lea     cursorspritedata,A0
                bsr     setspritepos
                jsr     setsamspriteptrs
;               move.w  copcol0+16,coplist2+18
                jsr     clrvucols
                jsr     wait_vbl
                bsr     clearsamscr
                move.w  #1,samscrenable
                jsr     wait_vbl
                bsr     swapsamscreen

                jsr     doshowfreemem
                bsr     showsamnote
                bsr     showresamnote
                bra     redrawsample

exitfromsam:
                jsr     waitforbuttonup
                clr.w   samscrenable
                jsr     wait_vbl
                bsr     swapsamscreen
exisam2:        jsr     setdefspriteptrs
                clr.b   rawkeycode
                clr.w   samscrenable
                moveq   #-1,D0
                move.l  D0,markstartofs
                move.l  saveeditmode(PC),editmode
                bsr     setscreencolors2
                jsr     setupvucols
                bsr     setscrpatternpos
                bsr     clearsamscr
                jsr     updatecursorpos
                jsr     settempo
                move.w  #1,updatefreemem
                bra     redrawpattern

swapsamscreen:
                lea     sampscreendata,A1
                lea     samscrpos,A0
                move.w  #(134*2)-1,D1   ; 134
                moveq   #0,D2
bjalop2:
                REPT 10
                move.l  (A0),D0
                move.l  (A1),(A0)+
                move.l  D0,(A1)+
                move.l  D2,(A0)+
                addq.l  #8,A0
                ENDR
                dbra    D1,bjalop2

                moveq   #-1,D0
                rts

clearsamscr:
                move.w  #5121,textoffset
                move.w  #2,textlength
                move.l  #blnktxt,showtextptr
                bsr     showtext
                move.w  #4964,textoffset
                move.w  #3,textlength
                bsr     showtext
                move.w  #130-1,D0

                movea.l textbplptr,A0
                lea     $15B8(A0),A0
                move.l  A0,linescreen
                moveq   #0,D1
clrsslp:
                REPT 10
                move.l  D1,(A0)+
                ENDR
                dbra    D0,clrsslp
                rts

blnktxt:        DC.B "    "

clearsamarea:
                moveq   #64-1,D0
                movea.l textbplptr,A0
                lea     $15B8(A0),A0
                move.l  A0,linescreen
                moveq   #0,D1
clrsare:
                REPT 10
                move.l  D1,(A0)+
                ENDR
                dbra    D0,clrsare
                rts

checksamgadgets:
                movem.w mousex2,D0-D1
                cmp.w   #139,D1
                blo     samtopbar
                cmp.w   #139+64,D1
                blo     samplepressed
                cmp.w   #201+11,D1
                blo     samdragbar
                cmp.w   #201+22,D1
                blo     sammenu1
                cmp.w   #201+33,D1
                blo     sammenu2
                cmp.w   #201+44,D1
                blo     sammenu3
                cmp.w   #201+66,D1
                blo     sammenu4
                rts

samtopbar:
                cmp.w   #32,D0
                blo     exitfromsam
                rts

sammenu1:
                cmp.w   #32,D0
                blo     return2
                cmp.w   #96,D0
                blo     playwaveform
                cmp.w   #176,D0
                blo     showrange
                cmp.w   #246,D0
                blo     zoomout
                bra     dispbox

sammenu2:
                cmp.w   #32,D0
                blo     stopplaying
                cmp.w   #96,D0
                blo     playdisplay
                cmp.w   #176,D0
                blo     showall
                cmp.w   #246,D0
                blo     rangeall
                bra     looptoggle

sammenu3:
                cmp.w   #32,D0
                blo     stopplaying
                cmp.w   #96,D0
                blo     playrange
                cmp.w   #116,D0
                blo     curtostart
                cmp.w   #136,D0
                blo     curtoend
                cmp.w   #176,D0
                blo     swapbuffer
                cmp.w   #246,D0
                blo     sampler
                bra     setsamnote

sammenu4:
                cmp.w   #32,D0
                blo     samcut
                cmp.w   #64,D0
                blo     samcopy
                cmp.w   #96,D0
                blo     sampaste
                cmp.w   #136,D0
                blo     rampvolume
                cmp.w   #176,D0
                blo     tuningtone
                cmp.w   #246,D0
                blo     resample
                bra     setresamnote


playwaveform:
                jsr     playnote
                jmp     waitforbuttonup
playdisplay:
                lea     sampleinfo,A0
                move.l  samoffset(PC),startofs
                move.l  samdisplay(PC),D0
                lsr.l   #1,D0
                move.w  D0,(A0)
                clr.w   4(A0)
                move.w  #1,6(A0)
                move.w  playinsnum,-(SP)
                clr.w   playinsnum
                jsr     playnote
                move.w  (SP)+,playinsnum
                bsr     showsampleinfo
                jmp     waitforbuttonup
playrange:
                move.l  markstartofs(PC),D1
                bmi     norangeerror
                move.l  markendofs(PC),D0
                cmp.l   D0,D1
                beq     largerrangeerror
                lea     sampleinfo,A0
                move.l  D1,startofs
                sub.l   D1,D0
                lsr.l   #1,D0
                move.w  D0,(A0)
                clr.w   4(A0)
                move.w  #1,6(A0)
                move.w  playinsnum,-(SP)
                clr.w   playinsnum
                jsr     playnote
                move.w  (SP)+,playinsnum
                bsr     showsampleinfo
                jmp     waitforbuttonup
stopplaying:
                bra     turnoffvoices

startofs:
                DC.L 0

;----

showrange:
                move.l  markstartofs(PC),D0
                bmi     norangeerror
                move.l  markendofs(PC),D1
                cmp.l   D1,D0
                beq     largerrangeerror
                sub.l   D0,D1
                bne     shorano
                moveq   #1,D1
shorano:        move.l  D1,samdisplay
                move.l  D0,samoffset
                moveq   #-1,D0
                move.l  D0,markstartofs
                clr.w   markstart
                bsr     displaysample
                jmp     waitforbuttonup

zoomout:        move.l  samdisplay(PC),D0
                move.l  samlength(PC),D1
                move.l  samoffset(PC),D2
                move.l  D0,D3
                add.l   D3,D3
                cmp.l   D1,D3
                bhi     showall
                lsr.l   #1,D0
                cmp.l   D2,D0
                blo     zoomou2
                moveq   #0,D0
zoomou2:        sub.l   D0,D2
                move.l  D2,D0
                add.l   D3,D0
                cmp.l   D1,D0
                bls     zoomou3
                sub.l   D3,D1
                move.l  D1,D2
zoomou3:        move.l  D2,samoffset
                move.l  D3,samdisplay
                bsr     offsettomark
                move.l  markstartofs(PC),D0
                cmp.l   markendofs(PC),D0
                bne     zoomouo
                moveq   #-1,D0
                move.l  D0,markstartofs
zoomouo:        bsr     displaysample
                jmp     waitforbuttonup

showall:        clr.l   samoffset
                move.l  samlength(PC),samdisplay
                bsr     offsettomark
                move.l  markstartofs(PC),D0
                cmp.l   markendofs(PC),D0
                bne     shoallo
                moveq   #-1,D0
                move.l  D0,markstartofs
                clr.w   markstart
shoallo:        bsr     displaysample
                jmp     waitforbuttonup

rangeall:
                bsr     invertrange
                move.w  #3,markstart
                move.w  #316,markend
                bsr     marktooffset
ranall2:        bsr     invertrange
                jmp     waitforbuttonup


curtostart:
                bsr     invertrange
                moveq   #3,D0
                move.w  D0,markstart
                move.w  D0,markend
                move.l  samoffset(PC),D0
                move.l  D0,markstartofs
                move.l  D0,markendofs
                bra.s   ranall2

curtoend:
                bsr     invertrange
                move.w  #316,D0
                move.w  D0,markstart
                move.w  D0,markend
                move.l  samoffset(PC),D0
                add.l   samdisplay(PC),D0
                move.l  D0,markstartofs
                move.l  D0,markendofs
                bra.s   ranall2

swapbuffer:
                move.w  insnum(PC),D1
                bne     notsamplenullm1
                jmp     notsamplenull
notsamplenullm1:lsl.w   #2,D1
                lea     sampleptrs,A0
                lea     0(A0,D1.w),A0

                move.l  copybufptr(PC),D0
                move.l  (A0),copybufptr
                move.l  D0,(A0)
                movea.l D0,A1
                clr.w   (A1)

                move.l  copybufsize(PC),D0
                move.l  124(A0),copybufsize
                move.l  D0,124(A0)

                movea.l songdataptr(PC),A0
                move.w  insnum(PC),D1
                mulu    #30,D1
                lea     12(A0,D1.w),A0
                lsr.l   #1,D0
                move.w  D0,(A0)
                move.l  repbuf(PC),D0
                move.l  4(A0),repbuf
                move.l  D0,4(A0)

                move.w  repbuf2(PC),D0
                move.w  2(A0),repbuf2
                tst.b   D0
                bne.s   swabuf2
                move.b  #$40,D0
swabuf2:        move.w  D0,2(A0)
                jsr     turnoffvoices
                jsr     validateloops
                bsr     showsampleinfo
                bsr     updaterepeats
                bsr     redrawsample
                jmp     waitforbuttonup

repbuf:         DC.L 1
repbuf2:        DC.W $40

;----

norangeerror:
                lea     norangetext(PC),A0
nres2:          bsr     showstatustext
                jmp     seterrorptrcol

largerrangeerror:
                lea     largerrangetext(PC),A0
                bra.s   nres2

setcursorerror:
                lea     setcursortext(PC),A0
                bra.s   nres2

bufisemptyerror:
                lea     bufisemptytext(PC),A0
                bra.s   nres2

emptysampleerror:
                lea     emptysampletext(PC),A0
                bra.s   nres2

norangetext:    DC.B "no range selected",0
largerrangetext:DC.B "set larger range",0
setcursortext:  DC.B "set cursor pos",0
bufisemptytext: DC.B "buffer is empty",0
emptysampletext:DC.B "sample is empty",0

;----

dispbox:
                rts

notsamplenull2:
                lea     notsample0text,A0
                bsr     showstatustext
                bra     seterrorptrcol

looptoggle:
                jsr     waitforbuttonup
                move.w  insnum(PC),D1
                beq     notsamplenull2
                movea.l songdataptr(PC),A0
                mulu    #30,D1
                lea     12(A0,D1.w),A0
                tst.w   looponoffflag
                beq.s   loopton
                move.l  4(A0),savsaminf
                moveq   #1,D0
                move.l  D0,4(A0)
                jsr     turnoffvoices
looptlo:        bsr     showsampleinfo
                bsr     updaterepeats
                bra     displaysample
loopton:        move.l  savsaminf(PC),D0
                bne.s   loopto2
                move.w  (A0),D0
loopto2:        move.l  D0,4(A0)
                bra     looptlo

showlooptoggle:
                lea     toggleofftext(PC),A0
                tst.w   looponoffflag
                beq.s   sltskip
                lea     toggleontext(PC),A0
sltskip:        moveq   #3,D0
                move.w  #9076,D1
                bra     showtext3

looponoffflag:  DC.W 0
savsaminf:      DC.L 0

setsamnote:
                bsr     showresamnote
                move.w  #9516,textoffset
                move.w  #3,textlength
                move.l  #spcnotetext,showtextptr
                bsr     showtext
                move.w  #1,samnotetype
                move.l  #samplenote,splitaddress
                jmp     waitforbuttonup

setresamnote:
                bsr     showsamnote
                move.w  #9956,textoffset
                move.w  #3,textlength
                move.l  #spcnotetext,showtextptr
                bsr     showtext
                move.w  #2,samnotetype
                move.l  #resamplenote,splitaddress
                jmp     waitforbuttonup

resampletext:   DC.B "Resample?",0
resamplingtext: DC.B "Resampling...",0

resample:
                lea     resampletext(PC),A0
                jsr     areyousure
                bne     return2
                jsr     storeptrcol
                jsr     setwaitptrcol
                lea     resamplingtext(PC),A0
                bsr     showstatustext
                lea     sampleptrs,A0
                move.w  insnum(PC),D1
                beq     notsamplenull2
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0
                move.l  (A0),D0
                beq     erc2
                movea.l D0,A2
                move.l  124(A0),D6
                cmp.l   #2,D6
                bls     erc2

                movea.l songdataptr(PC),A0
                move.w  insnum(PC),D1
                mulu    #30,D1
                moveq   #0,D0
                move.b  12+2(A0,D1.w),D0 ; finetune
                mulu    #37*2,D0
                lea     periodtable(PC),A0
                adda.l  D0,A0
                moveq   #0,D1
                move.w  resamplenote(PC),D1
                add.w   D1,D1
                move.w  0(A0,D1.w),D1
                beq     erc2

                lea     periodtable,A0
                moveq   #0,D5
                move.w  tunenote,D5
                add.w   D5,D5
                move.w  0(A0,D5.w),D5
                beq     erc2

; D1=resamperiod, D5=tuneperiod

                move.l  D5,D0           ; tune
                lsl.l   #8,D0
                lsl.l   #4,D0           ; * 4096
                divu    D1,D0           ; / resample
                moveq   #0,D4
                move.w  D0,D4
                lsl.l   #4,D4           ; hi-word=add value, lo-word=fraction

                move.w  D6,D7
                lsr.w   #1,D7
                mulu    D1,D7
                divu    D5,D7
                and.l   #$FFFF,D7
                cmp.w   #2,D7
                blo     erc2
                cmp.w   #$7FFF,D7
                blo     resamlo
                move.w  #$7FFF,D7
resamlo:        add.l   D7,D7
                move.l  D7,D0
                move.l  #memf_chip+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                tst.l   D0
                beq     sammemerror
                movea.l D0,A1
                movea.l D0,A3
                jsr     turnoffvoices
                movea.l A2,A0
; D4=resample value, D6=old length, D7=new length
; A0/A2=old sample, A1/A3=new sample

                move.w  #32767,D1
                moveq   #0,D3
                moveq   #0,D5
resampleloop:
                move.b  1(A0),D0
                ext.w   D0
                muls    D1,D0
                move.b  (A0),D2
                ext.w   D2
                muls    D3,D2
                add.l   D2,D0
                asr.l   #8,D0
                asr.l   #7,D0
                move.b  D0,(A1)+

                add.l   D4,D5
                swap    D5
                movea.l A2,A0
                moveq   #0,D0
                move.w  D5,D0
                adda.l  D0,A0
                swap    D5
                move.w  D5,D1
                lsr.w   #1,D1
                move.w  #32767,D3
                sub.w   D1,D3

                movea.l A1,A4
                suba.l  A3,A4
                cmpa.l  D7,A4
                bhs.s   resamskip
                movea.l A0,A4
                suba.l  A2,A4
                cmpa.l  D6,A4
                blo.s   resampleloop

resamskip:
                movea.l A2,A1
                move.l  D6,D0
                movea.l 4.w,A6
                jsr     lvofreemem
                move.w  insnum(PC),D1
                lsl.w   #2,D1
                lea     sampleptrs,A0
                lea     0(A0,D1.w),A0
                move.l  A3,(A0)
                move.l  D7,124(A0)

                movea.l songdataptr(PC),A0
                move.w  insnum(PC),D1
                mulu    #30,D1
                lea     12(A0,D1.w),A0
                lsr.l   #1,D7
                move.w  D7,(A0)
                clr.b   2(A0)
                clr.w   4(A0)
                move.w  #1,6(A0)
                jsr     restoreptrcol
                bsr     clearsamstarts
                bsr     showsampleinfo
                bsr     showallright
                bra     redrawsample

erc2:           jmp     errorrestorecol

samcut:         clr.b   rawkeycode
                move.l  markstartofs(PC),D0
                bmi     norangeerror
                cmp.l   markendofs(PC),D0
                beq     largerrangeerror
                tst.b   cuttobufflag
                beq.s   samcut2
                bsr     samcopy
samcut2:        bsr     turnoffvoices
                lea     sampleptrs(PC),A0
                move.w  insnum(PC),D1
                beq     notsamplenull2
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0
                move.l  (A0),D0
                beq     emptysampleerror
                move.l  124(A0),D2
                cmp.l   #2,D2
                blo     emptysampleerror

                movea.l D0,A1
                movea.l D0,A2           ; sample start
                movea.l D0,A3
                movea.l D0,A4
                movea.l D0,A5
                adda.l  markstartofs(PC),A3 ; mark start
                move.l  markendofs(PC),D0
                sub.l   markstartofs(PC),D0
                cmp.l   D2,D0
                bhs     destroy
                move.l  markendofs(PC),D0
                cmp.l   D2,D0
                blo.s   samsome
                move.l  D2,D0
                subq.l  #1,D0
samsome:        adda.l  D0,A4           ; mark end
                adda.l  D2,A5           ; sample end

                move.l  A3,D0
                sub.l   A2,D0
                add.l   A5,D0
                sub.l   A4,D0
                bne     sacoklen
                moveq   #0,D3
                moveq   #0,D4
                bra     sacfree

sacoklen:
                move.l  D0,D3
                moveq   #memf_chip,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,D4
                beq     outofmemerr     ; No memory

                movea.l D0,A0
                movea.l A2,A1
                move.l  A3,D0
                sub.l   A2,D0
                bra.s   sacskp1
saclop1:        move.b  (A2)+,(A0)+
sacskp1:        dbra    D0,saclop1

                move.l  A5,D0
                sub.l   A4,D0
                bra.s   sacskp2
smclop2:        move.b  (A4)+,(A0)+
sacskp2:        dbra    D0,smclop2

sacfree:        move.l  D2,D0
                movea.l 4.w,A6
                jsr     lvofreemem

                move.w  insnum(PC),D1
                lsl.w   #2,D1
                lea     sampleptrs(PC),A0
                lea     0(A0,D1.w),A0
                move.l  D4,(A0)
                move.l  D3,124(A0)

                move.l  D4,samstart
                move.l  D3,samlength
                move.l  samoffset(PC),D4
                add.l   samdisplay(PC),D4
                cmp.l   D3,D4
                blo     samcuto         ; display ok
                move.l  samdisplay(PC),D4
                cmp.l   D3,D4
                blo     samnils         ; if display < length, move offset
samsall:        clr.l   samoffset       ; else show all
                move.l  D3,samdisplay
                bra     samcuto
samnils:        move.l  D3,D4
                sub.l   samdisplay(PC),D4
                bmi.s   samsall         ; if offset < 0, show all
                move.l  D4,samoffset
samcuto:        movea.l songdataptr(PC),A0
                move.w  insnum(PC),D1
                mulu    #30,D1
                lea     12(A0,D1.w),A0

                lsr.l   #1,D3
                move.w  D3,(A0)
                move.w  4(A0),D0
                cmp.w   D3,D0
                bls.s   samcuxx
                moveq   #1,D0
                move.l  D0,4(A0)
                bra.s   samcuex
samcuxx:        add.w   6(A0),D0
                cmp.w   D3,D0
                bls.s   samcuex
                sub.w   4(A0),D3
                move.w  D3,6(A0)

samcuex:        move.l  markstartofs(PC),markendofs
                bsr     clearsamstarts
                jsr     validateloops
                bsr     showsampleinfo
                bra     displaysample


samcopy:        clr.b   rawkeycode
                move.l  markstartofs(PC),D0
                bmi     norangeerror
                cmp.l   markendofs(PC),D0
                beq     largerrangeerror
                lea     sampleptrs(PC),A0
                move.w  insnum(PC),D1
                beq     notsamplenull2
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0
                move.l  (A0),D0
                beq     emptysampleerror
                move.l  124(A0),D2
                beq     emptysampleerror
                movea.l D0,A3
                movea.l D0,A4
                adda.l  markstartofs(PC),A3 ; mark start
                move.l  markendofs(PC),D0 ; mark end
                cmp.l   D2,D0
                blo.s   csamsom
                move.l  D2,D0
                subq.l  #1,D0
csamsom:        adda.l  D0,A4
                bsr.s   freecopybuf
                move.l  A4,D0
                sub.l   A3,D0
                addq.l  #1,D0
                move.l  D0,copybufsize
                moveq   #memf_chip,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,copybufptr
                beq     outofmemerr     ; No memory
                movea.l D0,A5
csamlop:        move.b  (A3)+,(A5)+
                cmpa.l  A4,A3
                bls.s   csamlop
                bsr     invertrange
                bsr     invertrange
                jmp     waitforbuttonup

freecopybuf:
                move.l  copybufptr(PC),D0
                beq     return2
                movea.l D0,A1
                move.l  copybufsize(PC),D0
                movea.l 4.w,A6
                jsr     lvofreemem
                clr.l   copybufptr
                rts

copybufptr:     DC.L 0
copybufsize:    DC.L 0

sampaste:
                clr.b   rawkeycode
                move.l  markstartofs(PC),D0
                bmi     setcursorerror
                lea     sampleptrs(PC),A0
                move.w  insnum(PC),D1
                beq     notsamplenull2
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0
                moveq   #0,D2
                move.l  (A0),D0
                beq.s   sapanul
                move.l  124(A0),D2
sapanul:        movea.l D0,A2
                move.l  copybufptr(PC),D3
                beq     bufisemptyerror
                movea.l D3,A3
                move.l  copybufsize(PC),D3
                beq     bufisemptyerror

                move.l  D3,D4           ; copysize
                add.l   D2,D4           ; + origsize
                cmp.l   #$FFFE,D4
                blo.s   sapaok
                move.l  #$FFFE,D4
sapaok:         move.l  D4,D0
                move.l  #memf_chip+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                tst.l   D0
                beq     outofmemerr
                movea.l D0,A4
                moveq   #0,D0
                tst.l   D2
                beq.s   sapask1
                move.l  markstartofs(PC),D0
sapask1:        move.l  D0,markstartofs
                movea.l A2,A1
                move.l  D2,D1
                movea.l A4,A5
                movea.l A4,A0
                adda.l  D4,A0
; D0    = paste position
; A0    = end of new sample
; A1/D1 = copy of A2/D2
; A2/D2 = original sample
; A3/D3 = copy buffer
; A4/D4 = new sample
; A5    = copy of A4
                bra.s   sapask2
sapalp1:        move.b  (A2)+,(A4)+     ; copy first part
                cmpa.l  A0,A4
                bhs.s   sapaski
                subq.l  #1,D2
sapask2:        dbra    D0,sapalp1
                bra.s   sapask3
sapalp2:        move.b  (A3)+,(A4)+     ; copy from buffer
                cmpa.l  A0,A4
                bhs.s   sapaski
sapask3:        dbra    D3,sapalp2
                tst.l   D2
                beq.s   sapaski
                bmi.s   sapaski
sapalp3:        move.b  (A2)+,(A4)+     ; copy last part
                cmpa.l  A0,A4
                bhs.s   sapaski
                subq.l  #1,D2
                bne.s   sapalp3

sapaski:        move.l  D1,D0
                movea.l 4.w,A6
                jsr     lvofreemem

                move.w  insnum(PC),D1
                lsl.w   #2,D1
                lea     sampleptrs(PC),A0
                lea     0(A0,D1.w),A0
                move.l  A5,(A0)
                move.l  D4,124(A0)

                movea.l songdataptr(PC),A0
                move.w  insnum(PC),D1
                mulu    #30,D1
                lea     12(A0,D1.w),A0
                lsr.l   #1,D4
                move.w  D4,(A0)

                move.l  markstartofs(PC),markendofs
                bsr     offsettomark
                bsr     clearsamstarts
                bsr     showsampleinfo
                bra     redrawsample

rampvolume:
                movea.l textbplptr(PC),A0
                lea     6209(A0),A0
                moveq   #32,D3
ravlap2:        moveq   #16,D2
                moveq   #15,D5
ravlap1:        clr.b   (A0)+
                dbra    D2,ravlap1
                lea     23(A0),A0
                dbra    D3,ravlap2
                lea     volboxpos,A0
                lea     volboxdata,A1
                moveq   #1,D4
ravlop3:        moveq   #32,D3
ravlop2:        moveq   #16,D2
                moveq   #15,D5
ravlop1:        move.b  (A1)+,(A0)
                adda.w  D5,A0
                eori.w  #14,D5
                dbra    D2,ravlop1
                addq.l  #1,A1
                lea     320-143(A0),A0
                dbra    D3,ravlop2
                adda.l  #-(33*320)-2,A0
                dbra    D4,ravlop3
                bsr     showvolsliders
                jsr     waitforbuttonup
ravloop:

                btst    #0,mousebut
                bne.s   exitvolbox

                jsr     dokeybuffer
                move.b  rawkeycode(PC),D2
                cmp.b   #68,D2
                beq.s   exitvolbox
                btst    #2,mousebut
                beq.s   ravloop


                movem.w mousex,D0-D1
                cmp.w   #72,D0
                blo.s   ravloop
                cmp.w   #72+136,D0
                bhs.s   ravloop
                cmp.w   #155,D1
                blo.s   ravloop
                cmp.w   #166,D1
                blo.s   vol1slider
                cmp.w   #177,D1
                blo     vol2slider
                cmp.w   #188,D1
                blo     volgadgs
                bra.s   ravloop

exitvolbox:
                lea     volboxpos,A0
                moveq   #1,D2
revlap3:        moveq   #32,D1
revlap2:        moveq   #16,D0
                moveq   #15,D5
revlap1:        clr.b   (A0)
                adda.w  D5,A0
                eori.w  #14,D5
                dbra    D0,revlap1
                lea     320-143(A0),A0
                dbra    D1,revlap2
                adda.l  #-(33*320)-2,A0
                dbra    D2,revlap3
                bra     displaysample

vol1slider:
                cmp.w   #167,D0
                bhi.s   v1skip
                lea     vol1(PC),A4
                moveq   #0,D7
v1loop1:
                btst    #2,mousebut
                beq     ravloop

                move.w  mousex(PC),D0
                cmp.w   D7,D0
                beq.s   v1loop1
                move.w  D0,D7
                sub.w   #107,D0
                bpl.s   v1skp2
                moveq   #0,D0
v1skp2:         cmp.w   #60,D0
                bls.s   v1skp3
                moveq   #60,D0
v1skp3:         mulu    #200,D0
                divu    #60,D0
                move.w  D0,(A4)
shvosl:         bsr     showvolsliders
                bra.s   v1loop1

v1skip:         move.w  #180,linecurx
                move.w  #164,linecury
                move.w  #6342,textoffset
                bsr     getdec3dig
                tst.w   abortdecflag
                bne     shvosl
                cmp.w   #200,D0
                bls.s   v1sk2
                move.w  #200,D0
v1sk2:          move.w  D0,vol1
                bra.s   shvosl

vol2slider:
                cmp.w   #167,D0
                bhi.s   v2skip
                lea     vol2(PC),A4
                moveq   #0,D7
                bra     v1loop1
v2skip:         move.w  #180,linecurx
                move.w  #175,linecury
                move.w  #6782,textoffset
                bsr     getdec3dig
                tst.w   abortdecflag
                bne     shvosl
                cmp.w   #200,D0
                bls.s   v2sk2
                move.w  #200,D0
v2sk2:          move.w  D0,vol2
                bra     shvosl


volgadgs:
                cmp.w   #100,D0
                blo     dorampvol
                cmp.w   #144,D0
                blo     normalize
                cmp.w   #154,D0
                blo.s   setrampdown
                cmp.w   #164,D0
                blo.s   setrampup
                cmp.w   #174,D0
                blo.s   setrampunity
                bra     exitvolbox

setrampdown:
                move.w  #100,vol1
                clr.w   vol2
                bra.s   sru2
setrampup:
                clr.w   vol1
                move.w  #100,vol2
                bra.s   sru2
setrampunity:
                move.w  #100,vol1
                move.w  #100,vol2
sru2:           bsr.s   showvolsliders
                jsr     waitforbuttonup
                bra     ravloop

showvolsliders:
                movea.l textbplptr(PC),A0
                lea     6209(A0),A0
                moveq   #21,D3
ravlip2:        moveq   #12,D2
ravlip1:        clr.b   (A0)+
                dbra    D2,ravlip1
                lea     27(A0),A0
                dbra    D3,ravlip2
                moveq   #0,D4
                move.w  vol1(PC),D4
                moveq   #20,D5
                bsr     oneslider
                moveq   #0,D4
                move.w  vol2(PC),D4
                moveq   #31,D5
                bsr     oneslider
                move.w  vol1(PC),wordnumber
                move.w  #6342,textoffset
                bsr     print3decdigits
                move.w  vol2(PC),wordnumber
                move.w  #6782,textoffset
                bra     print3decdigits

oneslider:
                move.w  D4,D6
                add.w   D4,D4
                add.w   D6,D4
                divu    #10,D4
                add.w   #105,D4
                moveq   #2,D6
oneslop:        move.w  D4,D0
                move.w  D4,D2
                addq.w  #5,D2
                move.w  D5,D1
                move.w  D5,D3
                bsr     drawline
                addq.w  #1,D5
                dbra    D6,oneslop
                rts

dorampvol:
                clr.b   rawkeycode
                lea     sampleptrs(PC),A0
                move.w  insnum(PC),D1
                beq     nozerr1
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0
                moveq   #0,D2
                move.l  (A0),D0
                beq     nozerr2
                movea.l D0,A2
                move.l  124(A0),D2
                beq     nozerr2
                move.l  markstartofs(PC),D0
                bmi     drvskip
                move.l  markendofs(PC),D1
                sub.l   D0,D1
                beq.s   drvskip
                adda.l  D0,A2
                move.l  D1,D2
                addq.l  #1,D2
drvskip:        jsr     storeptrcol
                jsr     setwaitptrcol
                move.l  D2,D5
                moveq   #0,D3
drvloop:        move.w  D3,D1
                mulu    vol2(PC),D1
                divu    D2,D1
                move.w  D2,D4
                sub.w   D3,D4
                mulu    vol1(PC),D4
                divu    D2,D4
                add.w   D4,D1
                addq.w  #1,D3
                move.b  (A2),D0
                ext.w   D0
                muls    D1,D0
                divs    #100,D0
                cmp.w   #127,D0
                blt.s   drvskp2
                moveq   #127,D0
drvskp2:        cmp.w   #-128,D0
                bgt.s   drvskp3
                moveq   #-128,D0
drvskp3:        move.b  D0,(A2)+
                subq.l  #1,D5
                bne     drvloop
                jsr     restoreptrcol
                bra     exitvolbox

nozerr1:        bsr     notsamplenull2
                bra     ravloop
nozerr2:        bsr     emptysampleerror
                bra     ravloop

normalize:
                clr.b   rawkeycode
                lea     sampleptrs(PC),A0
                move.w  insnum(PC),D1
                beq     nozerr1
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0
                moveq   #0,D2
                move.l  (A0),D0
                beq     nozerr2
                movea.l D0,A2
                move.l  124(A0),D2
                beq     nozerr2
                move.l  markstartofs(PC),D0
                bmi     nozskip
                move.l  markendofs(PC),D1
                sub.l   D0,D1
                beq.s   nozskip
                adda.l  D0,A2
                move.l  D1,D2
                addq.l  #1,D2
nozskip:        jsr     storeptrcol
                jsr     setwaitptrcol
                moveq   #0,D0
nozloop:        move.b  (A2)+,D1
                ext.w   D1
                bpl.s   nozskp2
                neg.w   D1
nozskp2:        cmp.w   D0,D1
                blo.s   nozskp3
                move.w  D1,D0
nozskp3:        subq.l  #1,D2
                bne     nozloop
                jsr     restoreptrcol
                tst.w   D0
                beq     setrampunity
                cmp.w   #127,D0
                bhi     setrampunity
                cmp.w   #64,D0
                blo.s   nozmax
                move.l  #12700,D1
                divu    D0,D1
                move.w  D1,vol1
                move.w  D1,vol2
                bra     sru2
nozmax:         move.w  #200,vol1
                move.w  #200,vol2
                bra     sru2

vol1:           DC.W 100
vol2:           DC.W 100

tuningtone:
                jsr     waitforbuttonup
                clr.b   rawkeycode
                tst.w   ttoneflag
                bne     ttoneoff
                move.w  #1,ttoneflag
                move.w  pattcurpos,D2
                divu    #6,D2
                addq.w  #1,D2
                and.w   #3,D2
                moveq   #1,D0
                lsl.w   D2,D0
                move.w  D0,ttonebit
;              lea     $DFF0A0,A0
                lea     ch1s,A0         ;
;                lsl.w   #4,D2
                mulu    #sam_vcsize,D2
                lea     0(A0,D2.l),A0
                lea     periodtable(PC),A1
                move.w  tunenote,D1
                add.w   D1,D1
                move.w  0(A1,D1.w),D1
                lea     ttonedata,A2
;                move.w  D0,$DFF096      ; DMACON
                jsr     move_dmacon
;                move.l  A2,(A0)

                move.l  A2,sam_start(A0) ;;
                move.w  D1,sam_period(A0) ;;
                move.l  #16*2,sam_length(A0) ;;
                addi.l  #16*2,sam_start(A0) ;;
                move.l  A2,sam_lpstart(A0)
                move.l  #16*2,sam_lplength(A0)
                addi.l  #16*2,sam_lpstart(A0)

;                move.w  #16,4(A0)       ; 32 bytes
;                move.w  D1,6(A0)
;                move.w  ttonevol,8(A0)
                move.w  ttonevol,sam_vol(A0)

;                move.w  dmawait,D2
;ttowait:        dbra    D2,ttowait

                bset    #15,D0
                jsr     move_dmacon     ;;
;                move.w  D0,$DFF096
                rts

ttoneoff:
                clr.w   ttoneflag
                move.l  D0,-(SP)
;                move.w  ttonebit(PC),$DFF096
                move.w  ttonebit(PC),D0
                jsr     move_dmacon
                move.l  (SP)+,D0
                rts

ttoneflag:      DC.W 0
ttonebit:       DC.W 0

samplepressed:
                cmp.w   #144,D1
                bhs.s   spruskp
                move.w  loopstartpos(PC),D2
                beq.s   sprusk5
                subq.w  #3,D2
                cmp.w   D2,D0
                blt.s   sprusk5
                addq.w  #4,D2
                cmp.w   D2,D0
                blo     loopstartdrag
sprusk5:        move.w  loopendpos(PC),D2
                beq.s   spruskp
                subq.w  #3,D2
                cmp.w   D2,D0
                blt.s   spruskp
                addq.w  #4,D2
                cmp.w   D2,D0
                blo     loopenddrag
spruskp:        cmp.w   #3,D0
                blo     return2
                cmp.w   #317,D0
                bhs     return2
                move.w  D0,lastsampos
                bsr     invertrange
                move.w  lastsampos(PC),D0
                move.w  D0,markstart
                move.w  D0,markend
                bsr     invertrange
                bsr     marktooffset
                move.l  markendofs(PC),samplepos
                bsr     showpos
sprulop:
;                btst    #6,$BFE001
;                bne     spruend
                btst    #2,mousebut
                beq     spruend

                move.w  mousex(PC),D0
                cmp.w   #3,D0
                blo     sprusk3
                cmp.w   #317,D0
                bhs     sprusk2
                bra     sprusk4
sprusk2:        move.w  #316,D0
                bra     sprusk4
sprusk3:        moveq   #3,D0
sprusk4:        cmp.w   lastsampos(PC),D0
                beq     sprulop
                move.w  D0,lastsampos
                bsr     invertrange
                move.w  lastsampos(PC),markend
                bsr     invertrange
                bsr     marktooffset
                move.l  markendofs(PC),samplepos
                bsr     showpos
                bra     sprulop
spruend:        move.w  markstart(PC),D0
                move.w  markend(PC),D1
                cmp.w   D0,D1
                bhs     marktooffset
                move.w  D0,markend
                move.w  D1,markstart
                bra     marktooffset

invertrange:
                move.w  markstart(PC),D4
                beq     return2
                move.w  markend(PC),D5
                moveq   #63,D7
invran3:        move.w  D4,D0
                move.w  D7,D1
                move.w  D5,D2
                move.w  D7,D3
                bsr     eorhline
                dbra    D7,invran3

invranx:
                rts

loopstartpos:   DC.W 0
loopendpos:     DC.W 0

loopstartdrag:
                clr.w   dragtype
lopdrglop:
                movea.l songdataptr(PC),A0
                move.w  insnum(PC),D0
                beq     return2
                mulu    #30,D0
                lea     12(A0,D0.w),A0
                move.w  mousex(PC),D0
lsdlop1:
;                btst    #6,$BFE001
;                bne     lsdexit
                btst    #2,mousebut
                beq.s   lsdexit

                move.w  mousex(PC),D1
                cmp.w   D0,D1
                beq.s   lsdlop1
                sub.w   dragtype,D1
                bpl.s   lsdmsk1
                moveq   #0,D1
lsdmsk1:        cmp.w   #314,D1
                blo.s   lsdmsk2
                move.w  #314,D1
lsdmsk2:        move.l  samdisplay(PC),D0
                mulu    D0,D1
                divu    #314,D1
                move.l  samoffset(PC),D0
                add.w   D1,D0           ; new repeat
                bclr    #0,D0
                moveq   #0,D1
                move.w  4(A0),D1        ; old repeat
                add.w   D1,D1
                tst.w   dragtype
                bne.s   drgrepl
                move.w  D1,D3
                sub.w   D1,D0           ; offset
                add.w   D0,D1
                move.w  6(A0),D2
                add.w   D2,D2
                add.w   D2,D3
                subq.w  #2,D3
                sub.w   D0,D2
                cmp.w   D3,D1
                bls.s   lsdok
                move.w  D3,D1
                moveq   #2,D2
lsdok:          lsr.w   #1,D1
                move.w  D1,4(A0)
                lsr.w   #1,D2
                move.w  D2,6(A0)
                bsr.s   lsdexit
                bra     lopdrglop
lsdexit:        bsr     showsampleinfo
                bsr     updaterepeats
                bra     setloopsprites2

loopenddrag:
                move.w  #3,dragtype
                bra     lopdrglop

drgrepl:        move.l  D0,D2           ; repend
                sub.l   D1,D2           ; subtract repstart
                cmp.l   #2,D2
                bgt.s   ledskp1
                moveq   #2,D2
                bra.s   lsdok

ledskp1:        move.w  D1,D0           ; repeat
                add.w   D2,D0           ; + replen
                move.w  (A0),D3
                add.w   D3,D3
                cmp.w   D3,D0
                bls.s   lsdok
                sub.w   D1,D3
                move.w  D3,D2
                bra.s   lsdok

dragtype:       DC.W 0

samdragbar:
                cmp.w   #4,D0
                blo     return2
                cmp.w   #316,D0
                bhs     return2
                cmp.w   dragstart(PC),D0
                blo.s   draglo
                cmp.w   dragend(PC),D0
                bhi.s   draghi
                move.w  mousex(PC),D0
                move.w  D0,D1
                sub.w   dragstart(PC),D1
                move.w  D1,savemx
sdrlop1:
;                btst    #6,$BFE001
;                bne     return2
                btst    #2,mousebut
                beq     return2

                move.w  mousex(PC),D1
                cmp.w   D0,D1
                beq.s   sdrlop1
                sub.w   savemx(PC),D0
                subq.w  #4,D0
                bpl.s   sdrskp1
                moveq   #0,D0
sdrskp1:        move.l  samlength(PC),D1
                beq     return2
                mulu    D1,D0
                divu    #311,D0
                and.l   #$FFFF,D0
                bsr     dragchk
                move.w  mousex(PC),D0
                bra.s   sdrlop1

draglo:         move.l  samoffset(PC),D0
                sub.l   samdisplay(PC),D0
                bpl.s   draglo2
                moveq   #0,D0
draglo2:        cmp.l   samoffset(PC),D0
                beq     return2
                move.l  D0,samoffset
                bra     displaysample

draghi:         move.l  samoffset(PC),D0
                add.l   samdisplay(PC),D0
dragchk:        move.l  D0,D1
                add.l   samdisplay(PC),D1
                cmp.l   samlength(PC),D1
                bls.s   draglo2
                move.l  samlength(PC),D0
                sub.l   samdisplay(PC),D0
                bra.s   draglo2

savemx:         DC.W 0

;----

marktooffset:
                move.l  samdisplay(PC),D0
                move.w  markstart(PC),D1
                beq     return2
                subq.w  #3,D1
                mulu    D0,D1
                divu    #314,D1
                and.l   #$FFFF,D1
                add.l   samoffset(PC),D1
                move.l  D1,markstartofs
                move.w  markend(PC),D1
                cmp.w   #316,D1
                blo.s   mtosome
                move.l  samoffset(PC),D1
                add.l   D0,D1
                bra.s   mtoexit
mtosome:        subq.w  #3,D1
                mulu    D0,D1
                divu    #314,D1
                and.l   #$FFFF,D1
                add.l   samoffset(PC),D1
mtoexit:        move.l  D1,markendofs
                rts

offsettomark:
                move.l  markstartofs(PC),D0
                bmi.s   otmout
                move.w  #3,markstart
                sub.l   samoffset(PC),D0
                bmi.s   otmskip         ; set to start if before offset
                mulu    #314,D0
                move.l  samdisplay(PC),D1
                beq.s   otmskip
                divu    D1,D0
                cmp.w   #314,D0
                bhi.s   otmout          ; if start after display
                add.w   D0,markstart
otmskip:        move.w  #3,markend
                move.l  markendofs(PC),D0
                sub.l   samoffset(PC),D0
                bmi.s   otmout          ; if end before offset
                mulu    #314,D0
                move.l  samdisplay(PC),D1
                beq     return2
                divu    D1,D0
                cmp.w   #313,D0
                bls.s   otmok
                move.w  #313,D0         ; set to end if after display
otmok:          add.w   D0,markend
                rts

otmout:         clr.w   markstart
                rts

samscrenable:   DC.W 0
sammemptr:      DC.L 0
sammemsize:     DC.L 0
lastsampos:     DC.W 0
markstart:      DC.W 0
markend:        DC.W 0
markstartofs:   DC.L 0
markendofs:     DC.L 0

;---- Sample graphing stuff ----

displaysample:
                tst.w   samscrenable
                beq     return2
                bsr     rdsdoit
                tst.l   markstartofs
                bmi     return2
                bsr     offsettomark
                bra     invertrange

redrawsample:
                tst.w   samscrenable
                beq     return2
                moveq   #-1,D0
                move.l  D0,markstartofs
                clr.w   markstart
                move.w  insnum(PC),D0
                beq     rdsblnk
                lea     samplestarts(PC),A1
                subq.w  #1,D0
                lsl.w   #2,D0
                move.l  0(A1,D0.w),samstart
                beq     rdsblnk
                move.l  124(A1,D0.w),D1
                beq     rdsblnk
                move.l  D1,samlength
                clr.l   samoffset
                move.l  D1,samdisplay
                bra     rdsdoit
rdsblnk:        lea     blanksample,A0
                move.l  A0,samstart
                move.l  #314,samlength
                clr.l   samoffset
                move.l  #314,samdisplay
rdsdoit:
                bsr     clearsamarea
                movea.l samstart(PC),A0
                moveq   #0,D4
                move.l  samoffset(PC),D5
                move.l  samdisplay(PC),D6
                move.l  D5,D7
                move.l  A0,D0
                add.l   D5,D0
                move.l  D0,samdrawstart
                add.l   D6,D0
                move.l  D0,samdrawend
rdsloop:        move.w  D4,D0
                addq.w  #3,D0
                moveq   #127,D1
                sub.b   0(A0,D7.l),D1
                lsr.w   #2,D1
                tst.w   D4
                bne     rdsdraw
                bsr     moveto
                bra     rdsupdt
rdsdraw:        bsr     drawto
rdsupdt:        addq.w  #1,D4
                move.l  D4,D7
                mulu    D6,D7
                divu    #314,D7
                and.l   #$FFFF,D7
                add.l   D5,D7
                cmp.w   #314,D4
                blo     rdsloop

                bsr.s   setdragbar
                move.l  samdisplay(PC),D0
                lea     blanksample,A0
                cmpa.l  samstart,A0
                bne.s   rdsslwo
                moveq   #0,D0
rdsslwo:        move.w  #215*40+33,textoffset
                bsr     print6decdigits
                bra     setloopsprites

samstart:       DC.L 0
samlength:      DC.L 0
samoffset:      DC.L 0
samdisplay:     DC.L 0
savsamins:      DC.W 0

setdragbar:
                move.w  #4*10-1,D0
                movea.l textbplptr,A0
                lea     $15B8+2720(A0),A0
                moveq   #0,D1
sdblop2:        move.l  D1,(A0)+
                dbra    D0,sdblop2
                move.l  samlength(PC),D0
                beq     return2
                move.l  samoffset(PC),D4
                move.l  samdisplay(PC),D5
                cmp.l   D0,D5
                beq     return2
                add.l   D4,D5
                mulu    #311,D4
                divu    D0,D4
                addq.w  #4,D4
                move.w  D4,dragstart
                mulu    #311,D5
                divu    D0,D5
                addq.w  #5,D5
                move.w  D5,dragend
                moveq   #68,D6
                moveq   #3,D7
sdbloop:        move.w  D4,D0
                move.l  D6,D1
                move.w  D5,D2
                move.l  D6,D3
                bsr     drawline
                addq.l  #1,D6
                dbra    D7,sdbloop
                rts

dragstart:      DC.W 0
dragend:        DC.W 0
;---- Sampler routines ----

_custom         EQU $DFF000
intreq          EQU $9C
intreqr         EQU $1E
intena          EQU $9A
joy0dat         EQU $0A
vhposr          EQU $06
dmacon          EQU $96
dmaconr         EQU $02

saminfoptr:     DC.L 0
saminfolen:     DC.L 0
samplenote:     DC.W 24         ; C-3
resamplenote:   DC.W 24         ; C-3
samintsave:     DC.W 0
samdmasave:     DC.W 0

cleartempsamparea:
                lea     tempsamparea,A0
                move.w  #379,D0
                moveq   #0,D1
ctsalop:        move.w  D1,(A0)+
                dbra    D0,ctsalop
                rts

sampler:        clr.b   rawkeycode
                jsr     stopit
                jsr     topexit
                jsr     waitforbuttonup
                jsr     setwaitptrcol
                bsr     showmon
                jsr     wait_4000
                jsr     clearrightarea
                jsr     clearanalyzercolors
                bsr     cleartempsamparea
                jsr     turnoffvoices

                jsr     wait_vbl
                st      samplingflag
                jsr     stop_dma
                jsr     wait_vbl

                move.b  #1,$FFFF8935.w  ;49.2khz
                move.b  #0,$FFFF8936.w
                move.b  #2,$FFFF8937.w
                move.b  #0,$FFFF8938.w

                move.w  $FFFF8930.w,D0
                and.w   #%1111111111110000,D0
                or.w    #%1000000000001001,D0 ; dma output 25mhz clock,no handshake
                move.w  D0,$FFFF8930.w

                move.w  $FFFF8932.w,D0
                and.w   #%1100011111111111,D0
                or.w    #%1000100000000000,D0 ; Dma output -> DAC(no handshake)
                move.w  D0,$FFFF8932.w

                move.w  $FFFF8932.w,D0
                and.w   #%1111111100001111,D0
                or.w    #%1000000011110000,D0 ; Adc  -> dsp in
                move.w  D0,$FFFF8932.w

                bclr    #7,$FFFF8901.w  ; select playback register
                move.w  #64,$FFFF8920.w ; 8 bit stereo,50khz,play 1 track,dac to track 1
                lea     playbuf(PC),A1
                lea     4(A1),A2
                jsr     set_dmaaddr

                jsr     wait_vbl

                move.w  #3,$FFFF8900.w  ; start dma.

;               jsr     load_sam_dspprog
;               move    #$2700,SR

                move.w  samplenote,D0
                add.w   D0,D0
                lea     periodtable,A0
                moveq   #0,D1
                move.w  0(A0,D0.w),D1
                move.l  freqconst,D3
                DC.L $4C413003  ; divu.l d1,d3

                lea     graphoffsets(PC),A0
                lea     tempsamparea,A1
                movea.l log_base,A2
                lea     (62*320)+(8*16)+4(A2),A2
                moveq   #0,D2
monilop2:
                moveq   #22,D5
                moveq   #1,D6
monilop4:
                moveq   #7,D4
monilop3:
.mwaitleft:     btst    #0,$FFFFA202.w
                beq.s   .mwaitleft
                move.l  $FFFFA204.w,D0
                lsr.l   #8,D0
                swap    D0
                clr.w   D0              ;;;
.mwaitright:    btst    #0,$FFFFA202.w
                beq.s   .mwaitright
                move.l  $FFFFA204.w,D1
                lsr.l   #8,D1
                move.w  D1,D0

                add.w   D3,D2
                bcc.s   .mwaitleft

                move.l  D0,playbuf
                lsr.w   #8,D0
                eori.b  #$80,D0
                move.w  D0,D1
                lsr.w   #3,D1
                add.w   D1,D1
                move.w  0(A0,D1.w),D0
                lsl.w   #3,D0
                move.w  (A1),D1
                move.w  D0,(A1)+
                bclr    D4,0(A2,D1.w)
                bset    D4,0(A2,D0.w)
                dbra    D4,monilop3
                adda.w  D6,A2
                eori.w  #14,D6
                dbra    D5,monilop4
                lea     ((-11*16)-1)(A2),A2
                lea     -368(A1),A1
                btst    #2,mousebut
                bne     sampexit
                btst    #0,mousebut
                beq     monilop2
                move.w  D3,samfreq
;-- start sampling --

                move.w  insnum(PC),D1
                beq     sampexit
                lsl.w   #2,D1
                lea     sampleptrs,A0
                move.l  0(A0,D1.w),D0
                beq.s   samaok
                clr.l   0(A0,D1.w)
                movea.l D0,A1
                move.l  124(A0,D1.w),D0
                beq.s   samaok
                clr.l   124(A0,D1.w)
                movea.l 4.w,A6
                jsr     lvofreemem
samaok:         move.l  #$FFFE,D6       ; try 64k
samalclop:
                move.l  D6,D0
                move.l  #memf_chip+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                tst.l   D0
                bne.s   samalcok
                sub.l   #2048,D6        ; try 2k less
                bpl.s   samalclop
                bsr     outofmemerr
                bra     sampexit

samalcok:
                move.w  insnum(PC),D1
                lsl.w   #2,D1
                lea     sampleptrs(PC),A0
                move.l  D0,0(A0,D1.w)
                move.l  D6,124(A0,D1.w)

                bsr     getsampleinfo
                move.l  saminfolen,D4
                movea.l saminfoptr,A1

                move.w  #$0180,D7
                move.w  samfreq,D3
                moveq   #0,D2
                moveq   #0,D5
samploop:
.swaitleft:     btst    #0,$FFFFA202.w
                beq.s   .swaitleft
                move.l  $FFFFA204.w,D0
                lsr.l   #8,D0
                swap    D0
                clr.w   D0              ;;;
.swaitright:    btst    #0,$FFFFA202.w
                beq.s   .swaitright
                move.l  $FFFFA204.w,D1
                lsr.l   #8,D1
                move.w  D1,D0

                add.w   D3,D2
                bcc.s   .swaitleft

                move.l  D0,playbuf
                lsr.w   #8,D0

                move.b  D0,(A1)+
                addq.w  #1,D5
                cmp.w   D4,D5
                beq.s   sampend
                bra.s   samploop
;                btst    D6,-$0100(A3)
;                bne.s   samploop
sampend:

                move.l  A1,D0
                sub.l   saminfoptr(PC),D0
                move.l  D0,saminfolen

                movea.l songdataptr(PC),A0
                move.w  insnum(PC),D1
                mulu    #30,D1
                lea     12(A0,D1.w),A0
                move.l  saminfolen(PC),D0
                lsr.l   #1,D0
                move.w  D0,(A0)+
                move.w  #$40,(A0)+
                clr.w   (A0)+
                move.w  #1,(A0)

                move.l  saminfolen(PC),D1
                neg.l   D1
                and.l   #$FFFFFFF8,D1
                neg.l   D1
                move.w  insnum(PC),D0
                asl.w   #2,D0
                lea     sampleptrs,A0
                cmp.l   124(A0,D0.w),D1
                bge.s   sampexit
                move.l  124(A0,D0.w),D2
                move.l  D1,124(A0,D0.w)
                sub.l   D1,D2
                movea.l 0(A0,D0.w),A1
                move.l  124(A0,D0.w),D0
                adda.l  D0,A1
                move.l  D2,D0
                movea.l 4.w,A6
                jsr     lvofreemem
sampexit:       jsr     stop_dma
                jsr     wait_vbl
                sf      samplingflag
                jsr     turnoffvoices
                jsr     startints
                jsr     displaymainscreen
                bsr     clearsamstarts
;               bsr     bufsize
                bsr     redrawsample
                jsr     waitforbuttonup
                clr.w   keybufpos
                clr.b   rawkeycode
                clr.w   shiftkeystatus
                jmp     wait_4000

set_dmaaddr:    lea     temp,A0
                move.l  A1,(A0)
                move.l  A2,4(A0)
                move.b  1(A0),$FFFF8903.w
                move.b  2(A0),$FFFF8905.w ; set start of buffer
                move.b  3(A0),$FFFF8907.w
                move.b  1+4(A0),$FFFF890F.w
                move.b  2+4(A0),$FFFF8911.w ; set end of buffer
                move.b  3+4(A0),$FFFF8913.w
                rts

; Dsp loader

load_sam_dspprog:
                move.w  #1,-(SP)        ; ability
                move.l  #((samdspprogend-samdspprog)/3),-(SP) ; no. of dsp words
                pea     samdspprog(PC)  ; buf
                move.w  #$6E,-(SP)      ; dsp_execboot
                trap    #14
                lea     12(SP),SP
                rts

samdspprog:     IBYTES 'SAMPLE.BIN'
samdspprogend:
                EVEN

samfreq:        DS.W 1
playbuf:        DS.L 1



samplenullinfo:
                clr.l   saminfoptr
                clr.l   saminfolen
                moveq   #-1,D0
                rts

getsampleinfo:
                move.w  insnum(PC),D0
                beq.s   samplenullinfo
                lsl.w   #2,D0
                lea     sampleptrs(PC),A0
                move.l  0(A0,D0.w),saminfoptr
                move.l  124(A0,D0.w),saminfolen
                moveq   #0,D0
                rts

showmon:        sf      scopeenable
                st      disableanalyzer
                jsr     clearrightarea
                lea     monitordata,A0
                move.l  #monitorsize,D0
                moveq   #-1,D4
                jmp     cgjojo

clearsamstarts:
                lea     sampleptrs+4,A0
                moveq   #30,D0
cssloop:        move.l  (A0)+,D1
                beq     cssskip
                movea.l D1,A1
                clr.w   (A1)
cssskip:        dbra    D0,cssloop
                rts
samplingflag:   DC.W 0

graphoffsets:
                DC.W 31*40,30*40,29*40,28*40,27*40,26*40,25*40,24*40
                DC.W 23*40,22*40,21*40,20*40,19*40,18*40,17*40,16*40
                DC.W 15*40,14*40,13*40,12*40,11*40,10*40,9*40,8*40
                DC.W 7*40,6*40,5*40,4*40,3*40,2*40,1*40,0*40

samnotetype:    DC.W 0

showsamnote:
                tst.w   samscrenable
                beq     return2
                movea.l notenamesptr,A4
                move.w  #237*40+36,textoffset
                move.w  samplenote,D0
                lsl.w   #2,D0
                lea     0(A4,D0.w),A0
                move.l  A0,showtextptr
                move.w  #4,textlength
                bra     showtext

showresamnote:
                tst.w   samscrenable
                beq     return2
                movea.l notenamesptr,A4
                move.w  #248*40+36,textoffset
                move.w  resamplenote,D0
                lsl.w   #2,D0
                lea     0(A4,D0.w),A0
                move.l  A0,showtextptr
                move.w  #4,textlength
                bra     showtext

;---- Loop Sprites ----

setloopsprites:
                moveq   #-1,D6
                moveq   #-1,D7
                move.w  insnum(PC),D0
                beq     slsset
                mulu    #30,D0
                movea.l songdataptr(PC),A0
                lea     12(A0,D0.w),A0
setloopsprites2:
                tst.w   samscrenable
                beq     return2
                clr.w   looponoffflag
                moveq   #-1,D6
                moveq   #-1,D7
                moveq   #0,D0
                move.w  4(A0),D0
                add.l   D0,D0
                moveq   #0,D1
                move.w  6(A0),D1
                add.l   D1,D1
                move.l  D0,D5
                add.l   D1,D5
                cmp.w   #2,D5
                bls.s   slsset
                move.w  #1,looponoffflag
                move.l  samoffset(PC),D2
                move.l  samdisplay(PC),D3
                move.l  D2,D4
                add.l   D3,D4
                cmp.l   D2,D0
                blo.s   lpa1
                cmp.l   D4,D0
                bhi.s   lpa1
                sub.l   D2,D0
                mulu    #314,D0
                divu    D3,D0
                addq.w  #3,D0
                move.w  D0,D6
lpa1:           cmp.l   D2,D5
                blo.s   slsset
                cmp.l   D4,D5
                bhi.s   slsset
                sub.l   D2,D5
                mulu    #314,D5
                divu    D3,D5
                addq.w  #6,D5
                move.w  D5,D7
slsset:         move.w  #139,D1
                move.w  D6,D0
                bpl.s   lp2a
                moveq   #0,D0
                move.w  #270,D1
lp2a:           moveq   #64,D2
                lea     loopspritedata1,A0
                move.w  D0,loopstartpos
                bsr     setspritepos
                move.w  #139,D1
                move.w  D7,D0
                bpl.s   lp3a
                moveq   #0,D0
                move.w  #270,D1
lp3a:           moveq   #64,D2
                lea     loopspritedata2,A0
                move.w  D0,loopendpos
                bsr     setspritepos
                bra     showlooptoggle

                ENDPART

                PART 'line routines'

; End masks and screen offset tables for normal fill.

i               SET 0
ch_vectl:       REPT 20
                DC.W %1111111111111111,i
                DC.W %111111111111111,i
                DC.W %11111111111111,i
                DC.W %1111111111111,i
                DC.W %111111111111,i
                DC.W %11111111111,i
                DC.W %1111111111,i
                DC.W %111111111,i
                DC.W %11111111,i
                DC.W %1111111,i
                DC.W %111111,i
                DC.W %11111,i
                DC.W %1111,i
                DC.W %111,i
                DC.W %11,i
                DC.W %1,i
i               SET i+2
                ENDR

i               SET 0
ch_vectr:       REPT 20
                DC.W %1000000000000000,i
                DC.W %1100000000000000,i
                DC.W %1110000000000000,i
                DC.W %1111000000000000,i
                DC.W %1111100000000000,i
                DC.W %1111110000000000,i
                DC.W %1111111000000000,i
                DC.W %1111111100000000,i
                DC.W %1111111110000000,i
                DC.W %1111111111000000,i
                DC.W %1111111111100000,i
                DC.W %1111111111110000,i
                DC.W %1111111111111000,i
                DC.W %1111111111111100,i
                DC.W %1111111111111110,i
                DC.W %1111111111111111,i
i               SET i+2
                ENDR

; d0/d2 x1,x2

eorhline:       cmp.w   D0,D2
                bge.s   .okya
                exg     D0,D2
.okya:
                add.w   D0,D0
                add.w   D0,D0
                add.w   D2,D2
                add.w   D2,D2
                lea     ch_vectl(PC),A0
                move.l  0(A0,D0.w),D0   ; left mask\offset
                lea     ch_vectr(PC),A0
                move.l  0(A0,D2.w),D1   ; right mask\offset
                movea.l linescreen(PC),A0
                muls    #scrwidth,D3
                adda.w  D3,A0
                sub.w   D0,D1           ; -ve difference!
                bgt.s   bigcase         ; same chunk?
; Hline over one chunk case
                and.l   D0,D1
                swap    D1
                eor.w   D1,0(A0,D0.w)   ; write 1 chunk
                rts
bigcase:
                adda.w  D0,A0
                swap    D0
                eor.w   D0,(A0)+        ; write left edge
                moveq   #-1,D2
                neg.w   D1
                jmp     miss_main+2(PC,D1.w) ; jump back thru list
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+        ; solid colour
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
                eor.w   D2,(A0)+
miss_main:      swap    D1              ; right mask
                eor.w   D1,(A0)         ; and write right mask!!
next_line:      rts



;---- Line Routine ----

moveto:         move.w  D0,penx
                move.w  D1,peny
                rts

drawto:         move.w  penx(PC),D2
                move.w  peny(PC),D3
                move.w  D0,penx
                move.w  D1,peny

;-----------------------------------------------------------------------;
; Routine to draw a 1 plane line,the line is clipped if necessary.      ;
; D0-D3 holds x1,y1/x2,y2       D0-D6/A0 smashed.                       ;
;-----------------------------------------------------------------------;

drawline:
                movem.l D4-D6/A0,-(SP)
                movea.l linescreen(PC),A0
cliponx:        cmp.w   D0,D2
                bge.s   x2big
                exg     D0,D2           ; reorder
                exg     D1,D3
x2big:
.gofordraw:     move.w  D2,D4
                sub.w   D0,D4           ; dx
                move.w  D3,D5
                sub.w   D1,D5           ; dy
                move.w  D2,D6
                lsr.w   #4,D6           ; /16
                add.w   D6,D6           ; *2
                lsl.w   #3,D3           ; *8
                add.w   D3,D6           ; screen line
                add.w   D3,D3
                add.w   D3,D3           ; *40
                add.w   D3,D6
                adda.w  D6,A0           ; a0 -> first chunk of line

                not.w   D2
                and.w   #15,D2
                clr.w   D6
                bset    D2,D6

                moveq   #-scrwidth,D3

                tst.w   D5              ; draw from top to bottom?
                bge.s   bottotop
                neg.w   D5              ; no so negate vals
                neg.w   D3
bottotop:
                cmp.w   D4,D5           ; dy>dx?
                blt.s   dxbiggerdy

; DY>DX Line drawing case

dybiggerdx:     move.w  D5,D1           ; yes!
                beq.s   nodraw          ; dy=0 nothing to draw(!)
                asr.w   #1,D1           ; e=dy/2
                move.w  D5,D2
                subq.w  #1,D2           ; lines to draw-1(dbf)
.dydxlp:        or.w    D6,(A0)
                adda.w  D3,A0
                sub.w   D4,D1
                bgt.s   .nostep
                add.w   D5,D1
                add.w   D6,D6
                dbcs    D2,.dydxlp
                bcc.s   .drawn
                subq.w  #2,A0
                moveq   #1,D6
.nostep:        dbra    D2,.dydxlp
.drawn:         or.w    D6,(A0)
nodraw:
enddraw:        movem.l (SP)+,D4-D6/A0
                rts

; DX>DY Line drawing case

dxbiggerdy:     clr.w   D2
                move.w  D4,D1
                asr.w   #1,D1           ; e=dx/2
                move.w  D4,D0
                subq.w  #1,D0
.dxdylp:        or.w    D6,D2
                sub.w   D5,D1
                bge.s   .nostepdxdy
                or.w    D2,(A0)
                adda.w  D3,A0
                add.w   D4,D1
                clr.w   D2
.nostepdxdy:    add.w   D6,D6
                dbcs    D0,.dxdylp
                bcc.s   .drawndxdy
.wrchnk:        or.w    D2,(A0)
                subq.w  #2,A0
                clr.w   D2
                moveq   #1,D6
                dbra    D0,.dxdylp
.drawndxdy:     or.w    D6,D2
                or.w    D2,(A0)
                bra.s   enddraw

scrwidth        EQU 40

penx:           DC.W 0
peny:           DC.W 0
linescreen:     DC.L 0

                ENDPART

                PART 'play routine!!!'

;---- Playroutine ----

audchan1temp:   DC.L 0,0,0,0,0,$010000,0,0,0,0,0
audchan2temp:   DC.L 0,0,0,0,0,$020000,0,0,0,0,0
audchan3temp:   DC.L 0,0,0,0,0,$040000,0,0,0,0,0
audchan4temp:   DC.L 0,0,0,0,0,$080000,0,0,0,0,0

intmusic:
                movem.l D0-A6,-(SP)
                move.l  runmode(PC),D0
                beq     nonewpositionyet
                cmp.l   #'patt',D0
                beq.s   a1
                move.l  songposition(PC),currpos
a1:             movea.l songdataptr(PC),A0
                move.b  sd_numofpatt(A0),songnumofpatt+1
                tst.w   stepplayenable
                bne.s   a2
                addq.l  #1,counter
                move.l  counter(PC),D0
                cmp.l   currspeed(PC),D0
                blo.s   nonewnote
a2:             clr.l   counter
                tst.b   pattdelaytime2
                beq.s   getnewnote
                bsr.s   nonewallchannels
                bra     dskip

nonewnote:
                bsr.s   nonewallchannels
                bra     nonewpositionyet

nonewallchannels:
                lea     audchan1toggle,A4
                lea     audchan1temp(PC),A6
;                lea     $DFF0A0,A5
                lea     ch1s,A5
                bsr     checkeffects
                lea     audchan2toggle,A4
                lea     audchan2temp(PC),A6
;                lea     $DFF0B0,A5
                lea     ch2s,A5
                bsr     checkeffects
                lea     audchan3toggle,A4
                lea     audchan3temp(PC),A6
;                lea     $DFF0C0,A5
                lea     ch3s,A5
                bsr     checkeffects
                lea     audchan4toggle,A4
                lea     audchan4temp(PC),A6
;                lea     $DFF0D0,A5
                lea     ch4s,A5
                bra     checkeffects


getnewnote:
                lea     12(A0),A3
                lea     sd_pattpos(A0),A2
                lea     sd_patterndata(A0),A0
                moveq   #0,D1
                move.l  songposition(PC),D0
                move.b  0(A2,D0.w),D1
;       CMP.L   #'patt',PunMode
;       BNE.S   .a
;       MOVE.L  PatterlLumber(PC),D1

.a:
                asl.l   #8,D1

                asl.l   #2,D1
                add.l   patternposition(PC),D1
                move.l  D1,patternptr
                clr.w   dmacontemp
                lea     audchan1toggle,A4
;                lea     $DFF0A0,A5
                lea     ch1s,A5
                lea     audchan1temp(PC),A6
                moveq   #1,D2
                bsr     playvoice
                moveq   #0,D0
                move.b  n_volume(A6),D0
;                move.w  D0,8(A5)
                move.w  D0,sam_vol(A5)
                lea     audchan2toggle,A4
;                lea     $DFF0B0,A5
                lea     ch2s,A5
                lea     audchan2temp(PC),A6
                moveq   #2,D2
                bsr.s   playvoice
                moveq   #0,D0
                move.b  n_volume(A6),D0
;                move.w  D0,8(A5)
                move.w  D0,sam_vol(A5)

                lea     audchan3toggle,A4
;                lea     $DFF0C0,A5
                lea     ch3s,A5
                lea     audchan3temp(PC),A6
                moveq   #3,D2
                bsr.s   playvoice
                moveq   #0,D0
                move.b  n_volume(A6),D0
;                move.w  D0,8(A5)
                move.w  D0,sam_vol(A5)

                lea     audchan4toggle,A4
;                lea     $DFF0D0,A5
                lea     ch4s,A5
                lea     audchan4temp(PC),A6
                moveq   #4,D2
                bsr.s   playvoice
                moveq   #0,D0
                move.b  n_volume(A6),D0
;                move.w  D0,8(A5)
                move.w  D0,sam_vol(A5)
                bra     setdma

checkmetronome:
                cmp.b   metrochannel,D2
                bne     return2
                move.b  metrospeed,D2
                beq     return2
                move.l  patternposition,D3
                lsr.l   #4,D3
                divu    D2,D3
                swap    D3
                tst.w   D3
                bne     return2
                andi.l  #$0FFF,(A6)
                ori.l   #$10D6F000,(A6) ; Play sample $1F at period $0D6 (214)
                rts

playvoice:
                tst.l   (A6)
                bne.s   plvskip
                bsr     pernop
plvskip:        move.l  0(A0,D1.l),(A6) ; Read note from pattern
                bsr.s   checkmetronome
                addq.l  #4,D1
                moveq   #0,D2
                move.b  n_cmd(A6),D2    ; Get lower 4 bits of instrument
                and.b   #$F0,D2
                lsr.b   #4,D2
                move.b  (A6),D0         ; Get higher 4 bits of instrument
                and.b   #$F0,D0
                or.b    D0,D2
                tst.b   D2
                beq     setregisters    ; Instrument was zero
                moveq   #0,D3
                lea     samplestarts(PC),A1
                move.w  D2,D4
                move.b  D2,n_samplenum(A6)
                subq.l  #1,D2
                lsl.l   #2,D2
                mulu    #30,D4
                move.l  0(A1,D2.l),n_start(A6)
                move.w  0(A3,D4.l),n_length(A6)
                move.w  0(A3,D4.l),n_reallength(A6)
                move.b  2(A3,D4.l),n_finetune(A6)
                move.b  3(A3,D4.l),n_volume(A6)
                move.w  4(A3,D4.l),D3   ; Get repeat
                tst.w   D3
                beq.s   noloop
                move.l  n_start(A6),D2  ; Get start
                add.w   D3,D3
                add.l   D3,D2           ; Add repeat
                move.l  D2,n_loopstart(A6)
                move.l  D2,n_wavestart(A6)
                move.w  4(A3,D4.l),D0   ; Get repeat
                add.w   6(A3,D4.l),D0   ; Add replen
                move.w  D0,n_length(A6)
                move.w  6(A3,D4.l),n_replen(A6) ; Save replen
                bra.s   setregisters

noloop:         move.l  n_start(A6),D2
                add.l   D3,D2
                move.l  D2,n_loopstart(A6)
                move.l  D2,n_wavestart(A6)
                move.w  6(A3,D4.l),n_replen(A6) ; Save replen
setregisters:
                move.w  (A6),D0
                and.w   #$0FFF,D0
                beq     checkmoreeffects ; If no note
                move.w  2(A6),D0
                and.w   #$0FF0,D0
                cmp.w   #$0E50,D0       ; finetune
                beq.s   dosetfinetune
                move.b  2(A6),D0
                and.b   #$0F,D0
                cmp.b   #3,D0           ; TonePortamento
                beq.s   chktoneporta
                cmp.b   #5,D0           ; TonePortamento + VolSlide
                beq.s   chktoneporta
                cmp.b   #9,D0           ; Sample Offset
                bne.s   setperiod
                bsr     checkmoreeffects
                bra.s   setperiod

dosetfinetune:
                bsr     setfinetune
                bra.s   setperiod

chktoneporta:
                bsr     settoneporta
                bra     checkmoreeffects

setperiod:
                movem.l D0-D1/A0-A1,-(SP)
                move.w  (A6),D1
                and.w   #$0FFF,D1
                lea     periodtable(PC),A1
                moveq   #0,D0
                moveq   #$24,D7
ftuloop:        cmp.w   0(A1,D0.w),D1
                bhs     ftufound
                addq.l  #2,D0
                dbra    D7,ftuloop
ftufound:
                moveq   #0,D1
                move.b  n_finetune(A6),D1
                mulu    #37*2,D1
                adda.l  D1,A1
                move.w  0(A1,D0.w),n_period(A6)
                movem.l (SP)+,D0-D1/A0-A1

                move.w  2(A6),D0
                and.w   #$0FF0,D0
                cmp.w   #$0ED0,D0
                beq     checkmoreeffects

;                move.w  n_dmabit(A6),$DFF096

                move.w  D0,-(SP)        ;;
                move.w  n_dmabit(A6),D0 ;;
                jsr     move_dmacon     ;;
                move.w  (SP)+,D0        ;;

                btst    #2,n_wavecontrol(A6)
                bne     vibnoc
                clr.b   n_vibratopos(A6)
vibnoc:         btst    #6,n_wavecontrol(A6)
                bne     trenoc
                clr.b   n_tremolopos(A6)
trenoc:
;                move.w  n_length(A6),4(A5) ; Set length
;                move.l  n_start(A6),(A5) ; Set start
;                bne     sdmaskp
;                clr.l   n_loopstart(A6)
;                moveq   #1,D0
;                move.w  D0,4(A5)
;                move.w  D0,n_replen(A6)
;sdmaskp:

                move.w  n_length(A6),sam_length(A5) ; Set length
                move.l  n_start(A6),sam_start(A5) ; Set start
                bne     sdmaskp
                clr.l   n_loopstart(A6)
                moveq   #1,D0
                move.w  D0,sam_length(A5)
                move.w  D0,n_replen(A6)
sdmaskp:        moveq   #0,D0
                move.w  sam_length(A5),D0
                add.l   D0,D0
                move.l  D0,sam_length(A5)
                add.l   D0,sam_start(A5)

                move.w  n_period(A6),D0
;               move.w  D0,6(A5)        ; Set period
                move.w  D0,sam_period(A5)
                jsr     spectrumanalyzer ; Do the analyzer
                st      n_trigger(A6)
                move.w  n_dmabit(A6),D0
                or.w    D0,dmacontemp
                bra     checkmoreeffects

setdma:
;                move.w  dmawait,D0
;waitdma:        dbra    D0,waitdma
                move.w  dmacontemp,D0
                and.w   activechannels,D0
                or.w    #$8000,D0
;                move.w  D0,$DFF096
                jsr     move_dmacon     ;;

;                move.w  dmawait,D0
;waitdma2:
;                dbra    D0,waitdma2

;                lea     $DFF000,A5
;                lea     audchan4temp(PC),A6
;                move.l  n_loopstart(A6),$D0(A5)
;                move.w  n_replen(A6),$D4(A5)
;                lea     audchan3temp(PC),A6
;                move.l  n_loopstart(A6),$C0(A5)
;                move.w  n_replen(A6),$C4(A5)
;                lea     audchan2temp(PC),A6
;                move.l  n_loopstart(A6),$B0(A5)
;                move.w  n_replen(A6),$B4(A5)
;                lea     audchan1temp(PC),A6
;                move.l  n_loopstart(A6),$A0(A5)
;                move.w  n_replen(A6),$A4(A5)

                move.l  D0,-(SP)
                lea     ch4s,A5
                lea     audchan4temp(PC),A6
                move.l  n_loopstart(A6),sam_lpstart(A5)
                moveq   #0,D0
                move.w  n_replen(A6),D0
                add.l   D0,D0
                move.l  D0,sam_lplength(A5)
                add.l   D0,sam_lpstart(A5)
                lea     ch3s,A5
                lea     audchan3temp(PC),A6
                move.l  n_loopstart(A6),sam_lpstart(A5)
                moveq   #0,D0
                move.w  n_replen(A6),D0
                add.l   D0,D0
                move.l  D0,sam_lplength(A5)
                add.l   D0,sam_lpstart(A5)
                lea     ch2s,A5
                lea     audchan2temp(PC),A6
                move.l  n_loopstart(A6),sam_lpstart(A5)
                moveq   #0,D0
                move.w  n_replen(A6),D0
                add.l   D0,D0
                move.l  D0,sam_lplength(A5)
                add.l   D0,sam_lpstart(A5)
                lea     ch1s,A5
                lea     audchan1temp(PC),A6
                move.l  n_loopstart(A6),sam_lpstart(A5)
                moveq   #0,D0
                move.w  n_replen(A6),D0
                add.l   D0,D0
                move.l  D0,sam_lplength(A5)
                add.l   D0,sam_lpstart(A5)
                move.l  (SP)+,D0


dskip:          tst.l   runmode
                beq     dskipx
                bsr     setpatternpos
dskipx:         move.l  patternposition(PC),D0
                lsr.l   #4,D0
                move.w  D0,scrpattpos
                addi.l  #16,patternposition
                move.b  pattdelaytime,D0
                beq     dskpc
                move.b  D0,pattdelaytime2
                clr.b   pattdelaytime
dskpc:          tst.b   pattdelaytime2
                beq     dskpa
                subq.b  #1,pattdelaytime2
                beq     dskpa
                subi.l  #16,patternposition
dskpa:          tst.b   pbreakflag
                beq     nnpysk
                sf      pbreakflag
                moveq   #0,D0
                move.b  pbreakposition(PC),D0
                lsl.w   #4,D0
                move.l  D0,patternposition
                clr.b   pbreakposition
nnpysk:         tst.w   stepplayenable
                beq     nnpysk2
                bsr     dostopit
                clr.w   stepplayenable
                move.l  patternposition(PC),D0
                lsr.l   #4,D0
                and.w   #63,D0
                move.w  D0,scrpattpos
nnpysk2:        cmpi.l  #1024,patternposition
                bne     nonewpositionyet
nextposition:
                moveq   #0,D0
                move.b  pbreakposition(PC),D0
                lsl.w   #4,D0
                move.l  D0,patternposition
                clr.b   pbreakposition
                clr.b   posjumpassert
                cmpi.l  #'patp',runmode
                bne     nonewpositionyet
                addq.l  #1,songposition
                andi.l  #$7F,songposition
                move.l  songposition(PC),D1
                movea.l songdataptr(PC),A0
                cmp.b   sd_numofpatt(A0),D1
                blo     nonewpositionyet
                clr.l   songposition

                tst.w   stepplayenable
                beq     nonewpositionyet
                bsr     dostopit
                clr.w   stepplayenable
                move.l  patternposition(PC),D0
                lsr.l   #4,D0
                move.w  D0,scrpattpos

nonewpositionyet:
                tst.b   posjumpassert
                bne     nextposition
                movem.l (SP)+,D0-A6
                rts

checkeffects:
                tst.w   (A4)
                beq     return2
                bsr     chkefx2
                moveq   #0,D0
                move.b  n_volume(A6),D0
;               move.w  D0,8(A5)
                move.w  D0,sam_vol(A5)
                rts

chkefx2:        bsr     updatefunk
                move.w  n_cmd(A6),D0
                and.w   #$0FFF,D0
                beq     return2
                move.b  n_cmd(A6),D0
                and.b   #$0F,D0
                tst.b   D0
                beq     arpeggio
                cmp.b   #1,D0
                beq     portaup
                cmp.b   #2,D0
                beq     portadown
                cmp.b   #3,D0
                beq     toneportamento
                cmp.b   #4,D0
                beq     vibrato
                cmp.b   #5,D0
                beq     toneplusvolslide
                cmp.b   #6,D0
                beq     vibratoplusvolslide
                cmp.b   #$0E,D0
                beq     e_commands
setback:
;               move.w  n_period(A6),6(A5)
                move.w  n_period(A6),sam_period(A5)
                cmp.b   #7,D0
                beq     tremolo
                cmp.b   #$0A,D0
                beq     volumeslide
return2:        rts

pernop:
;               move.w  n_period(A6),6(A5)
                move.w  n_period(A6),sam_period(A5)
                rts

arpeggio:
                moveq   #0,D0
                move.l  counter(PC),D0
                divs    #3,D0
                swap    D0
                cmp.w   #1,D0
                beq     arpeggio1
                cmp.w   #2,D0
                beq     arpeggio2
arpeggio0:
                move.w  n_period(A6),D2
                bra     arpeggioset

arpeggio1:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                lsr.b   #4,D0
                bra     arpeggiofind

arpeggio2:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #15,D0
arpeggiofind:
                add.w   D0,D0
                moveq   #0,D1
                move.b  n_finetune(A6),D1
                mulu    #37*2,D1
                lea     periodtable(PC),A0
                adda.l  D1,A0
                moveq   #0,D1
                move.w  n_period(A6),D1
                moveq   #$24,D7
arploop:        move.w  0(A0,D0.w),D2
                cmp.w   (A0),D1
                bhs     arpeggioset
                addq.l  #2,A0
                dbra    D7,arploop
                rts

arpeggioset:
;               move.w  D2,6(A5)
                move.w  D2,sam_period(A5)
                rts

fineportaup:
                tst.l   counter
                bne     return2
                move.b  #$0F,lowmask
portaup:        moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   lowmask,D0
                move.b  #$FF,lowmask
                sub.w   D0,n_period(A6)
                move.w  n_period(A6),D0
                and.w   #$0FFF,D0
                cmp.w   #$71,D0
                bpl     portauskip
                andi.w  #$F000,n_period(A6)
                ori.w   #$71,n_period(A6)
portauskip:     move.w  n_period(A6),D0
                and.w   #$0FFF,D0
;               move.w  D0,6(A5)
                move.w  D0,sam_period(A5)
                rts

fineportadown:
                tst.l   counter
                bne     return2
                move.b  #$0F,lowmask
portadown:
                clr.w   D0
                move.b  n_cmdlo(A6),D0
                and.b   lowmask,D0
                move.b  #$FF,lowmask
                add.w   D0,n_period(A6)
                move.w  n_period(A6),D0
                and.w   #$0FFF,D0
                cmp.w   #$0358,D0
                bmi     portadskip
                andi.w  #$F000,n_period(A6)
                ori.w   #$0358,n_period(A6)
portadskip:     move.w  n_period(A6),D0
                and.w   #$0FFF,D0
;               move.w  D0,6(A5)
                move.w  D0,sam_period(A5)
                rts

settoneporta:
                move.l  A0,-(SP)
                move.w  (A6),D2
                and.w   #$0FFF,D2
                moveq   #0,D0
                move.b  n_finetune(A6),D0
                mulu    #37*2,D0
                lea     periodtable(PC),A0
                adda.l  D0,A0
                moveq   #0,D0
stploop:        cmp.w   0(A0,D0.w),D2
                bhs     stpfound
                addq.w  #2,D0
                cmp.w   #37*2,D0
                blo     stploop
                moveq   #35*2,D0
stpfound:
                move.b  n_finetune(A6),D2
                and.b   #8,D2
                beq     stpgoss
                tst.w   D0
                beq     stpgoss
                subq.w  #2,D0
stpgoss:        move.w  0(A0,D0.w),D2
                movea.l (SP)+,A0
                move.w  D2,n_wantedperiod(A6)
                move.w  n_period(A6),D0
                clr.b   n_toneportdirec(A6)
                cmp.w   D0,D2
                beq     cleartoneporta
                bge     return2
                move.b  #1,n_toneportdirec(A6)
                rts

cleartoneporta:
                clr.w   n_wantedperiod(A6)
                rts


toneportamento:
                move.b  n_cmdlo(A6),D0
                beq     toneportnochange
                move.b  D0,n_toneportspeed(A6)
                clr.b   n_cmdlo(A6)
toneportnochange:
                tst.w   n_wantedperiod(A6)
                beq     return2
                moveq   #0,D0
                move.b  n_toneportspeed(A6),D0
                tst.b   n_toneportdirec(A6)
                bne     toneportaup
toneportadown:
                add.w   D0,n_period(A6)
                move.w  n_wantedperiod(A6),D0
                cmp.w   n_period(A6),D0
                bgt     toneportasetper
                move.w  n_wantedperiod(A6),n_period(A6)
                clr.w   n_wantedperiod(A6)
                bra     toneportasetper

toneportaup:
                sub.w   D0,n_period(A6)
                move.w  n_wantedperiod(A6),D0
                cmp.w   n_period(A6),D0
                blt     toneportasetper
                move.w  n_wantedperiod(A6),n_period(A6)
                clr.w   n_wantedperiod(A6)

toneportasetper:
                move.w  n_period(A6),D2
                move.b  n_glissfunk(A6),D0
                and.b   #$0F,D0
                beq     glissskip
                moveq   #0,D0
                move.b  n_finetune(A6),D0
                mulu    #37*2,D0
                lea     periodtable(PC),A0
                adda.l  D0,A0
                moveq   #0,D0
glissloop:
                cmp.w   0(A0,D0.w),D2
                bhs     glissfound
                addq.w  #2,D0
                cmp.w   #37*2,D0
                blo     glissloop
                moveq   #35*2,D0
glissfound:
                move.w  0(A0,D0.w),D2
glissskip:
;               move.w  D2,6(A5)        ; Set period
                move.w  D2,sam_period(A5)
                rts

vibrato:        move.b  n_cmdlo(A6),D0
                beq     vibrato2
                move.b  n_vibratocmd(A6),D2
                and.b   #$0F,D0
                beq     vibskip
                and.b   #$F0,D2
                or.b    D0,D2
vibskip:        move.b  n_cmdlo(A6),D0
                and.b   #$F0,D0
                beq     vibskip2
                and.b   #$0F,D2
                or.b    D0,D2
vibskip2:
                move.b  D2,n_vibratocmd(A6)
vibrato2:
                move.l  A4,-(SP)
                move.b  n_vibratopos(A6),D0
                lea     vibratotable(PC),A4
                lsr.w   #2,D0
                and.w   #$1F,D0
                moveq   #0,D2
                move.b  n_wavecontrol(A6),D2
                and.b   #$03,D2
                beq     vib_sine
                lsl.b   #3,D0
                cmp.b   #1,D2
                beq     vib_rampdown
                move.b  #255,D2
                bra     vib_set
vib_rampdown:
                tst.b   n_vibratopos(A6)
                bpl     vib_rampdown2
                move.b  #255,D2
                sub.b   D0,D2
                bra     vib_set
vib_rampdown2:
                move.b  D0,D2
                bra     vib_set
vib_sine:
                move.b  0(A4,D0.w),D2
vib_set:
                move.b  n_vibratocmd(A6),D0
                and.w   #15,D0
                mulu    D0,D2
                lsr.w   #7,D2
                move.w  n_period(A6),D0
                tst.b   n_vibratopos(A6)
                bmi     vibratoneg
                add.w   D2,D0
                bra     vibrato3
vibratoneg:
                sub.w   D2,D0
vibrato3:
;               move.w  D0,6(A5)
                move.w  D0,sam_period(A5)
                move.b  n_vibratocmd(A6),D0
                lsr.w   #2,D0
                and.w   #$3C,D0
                add.b   D0,n_vibratopos(A6)
                movea.l (SP)+,A4
                rts

toneplusvolslide:
                bsr     toneportnochange
                bra     volumeslide

vibratoplusvolslide:
                bsr     vibrato2
                bra     volumeslide

tremolo:        move.l  A4,-(SP)
                move.b  n_cmdlo(A6),D0
                beq     tremolo2
                move.b  n_tremolocmd(A6),D2
                and.b   #$0F,D0
                beq     treskip
                and.b   #$F0,D2
                or.b    D0,D2
treskip:        move.b  n_cmdlo(A6),D0
                and.b   #$F0,D0
                beq     treskip2
                and.b   #$0F,D2
                or.b    D0,D2
treskip2:
                move.b  D2,n_tremolocmd(A6)
tremolo2:
                move.b  n_tremolopos(A6),D0
                lea     vibratotable(PC),A4
                lsr.w   #2,D0
                and.w   #$1F,D0
                moveq   #0,D2
                move.b  n_wavecontrol(A6),D2
                lsr.b   #4,D2
                and.b   #$03,D2
                beq     tre_sine
                lsl.b   #3,D0
                cmp.b   #1,D2
                beq     tre_rampdown
                move.b  #255,D2
                bra     tre_set
tre_rampdown:
                tst.b   n_vibratopos(A6)
                bpl     tre_rampdown2
                move.b  #255,D2
                sub.b   D0,D2
                bra     tre_set
tre_rampdown2:
                move.b  D0,D2
                bra     tre_set
tre_sine:
                move.b  0(A4,D0.w),D2
tre_set:
                move.b  n_tremolocmd(A6),D0
                and.w   #15,D0
                mulu    D0,D2
                lsr.w   #6,D2
                moveq   #0,D0
                move.b  n_volume(A6),D0
                tst.b   n_tremolopos(A6)
                bmi     tremoloneg
                add.w   D2,D0
                bra     tremolo3
tremoloneg:
                sub.w   D2,D0
tremolo3:
                bpl     tremoloskip
                clr.w   D0
tremoloskip:
                cmp.w   #$40,D0
                bls     tremolook
                move.w  #$40,D0
tremolook:
;               move.w  D0,8(A5)
                move.w  D0,sam_vol(A5)
                move.b  n_tremolocmd(A6),D0
                lsr.w   #2,D0
                and.w   #$3C,D0
                add.b   D0,n_tremolopos(A6)
                movea.l (SP)+,A4
                addq.l  #4,SP
                rts

sampleoffset:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                beq     sononew
                move.b  D0,n_sampleoffset(A6)
sononew:        move.b  n_sampleoffset(A6),D0
                lsl.w   #7,D0
                cmp.w   n_length(A6),D0
                bge     sofskip
                sub.w   D0,n_length(A6)
                add.w   D0,D0
                add.l   D0,n_start(A6)
                rts
sofskip:        move.w  #$01,n_length(A6)
                rts

volumeslide:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                lsr.b   #4,D0
                tst.b   D0
                beq     volslidedown
volslideup:
                add.b   D0,n_volume(A6)
                cmpi.b  #$40,n_volume(A6)
                bmi     vsuskip
                move.b  #$40,n_volume(A6)
vsuskip:        move.b  n_volume(A6),D0
;       MOVE.W  D0,8(A5)
                rts

volslidedown:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
volslidedown2:
                sub.b   D0,n_volume(A6)
                bpl     vsdskip
                clr.b   n_volume(A6)
vsdskip:        move.b  n_volume(A6),D0
;       MOVE.W  D0,8(A5)
                rts

positionjump:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                subq.b  #1,D0
                move.l  D0,songposition
pj2:            clr.b   pbreakposition
                st      posjumpassert
                rts

volumechange:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                cmp.b   #$40,D0
                bls     volumeok
                moveq   #$40,D0
volumeok:
                move.b  D0,n_volume(A6)
;       MOVE.W  D0,8(A5)
                rts

patternbreak:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                move.l  D0,D2
                lsr.b   #4,D0
                mulu    #10,D0
                and.b   #$0F,D2
                add.b   D2,D0
                cmp.b   #63,D0
                bhi     pj2
                move.b  D0,pbreakposition
                st      posjumpassert
                rts

setspeed:
                move.b  3(A6),D0
                and.w   #$FF,D0
                beq.s   speednull
                tst.b   intmode
                beq.s   normspd
                cmp.w   #32,D0
                blo.s   normspd
                move.w  D0,realtempo
                movem.l D0-A6,-(SP)
                move.w  samscrenable,-(SP)
                st      samscrenable
                st      updatetempo
                jsr     settempo
                move.w  (SP)+,samscrenable
                movem.l (SP)+,D0-A6
                rts
normspd:        clr.l   counter
                move.w  D0,currspeed+2
                rts
speednull:
                clr.l   runmode
                jsr     setnormalptrcol
                rts


checkmoreeffects:
                move.b  2(A6),D0
                and.b   #$0F,D0
                cmp.b   #$09,D0
                beq     sampleoffset
                cmp.b   #$0B,D0
                beq     positionjump
                cmp.b   #$0D,D0
                beq     patternbreak
                cmp.b   #$0E,D0
                beq     e_commands
                cmp.b   #$0F,D0
                beq     setspeed
                tst.w   (A4)
                beq     return2
                cmp.b   #$0C,D0
                beq     volumechange
                bra     pernop

e_commands:
                move.b  n_cmdlo(A6),D0
                and.b   #$F0,D0
                lsr.b   #4,D0
                beq     filteronoff
                cmp.b   #1,D0
                beq     fineportaup
                cmp.b   #2,D0
                beq     fineportadown
                cmp.b   #3,D0
                beq     setglisscontrol
                cmp.b   #4,D0
                beq     setvibratocontrol
                cmp.b   #5,D0
                beq     setfinetune
                cmp.b   #6,D0
                beq     jumploop
                cmp.b   #7,D0
                beq     settremolocontrol
                cmp.b   #8,D0
                beq     karplusstrong
                cmp.b   #$0E,D0
                beq     patterndelay
                tst.w   (A4)
                beq     return2
                cmp.b   #9,D0
                beq     retrignote
                cmp.b   #$0A,D0
                beq     volumefineup
                cmp.b   #$0B,D0
                beq     volumefinedown
                cmp.b   #$0C,D0
                beq     notecut
                cmp.b   #$0D,D0
                beq     notedelay
                cmp.b   #$0F,D0
                beq     funkit
                rts

filteronoff:
                move.b  n_cmdlo(A6),D0
                and.b   #1,D0
                add.b   D0,D0
;                andi.b  #$FD,$BFE001
;                or.b    D0,$BFE001
                rts

setglisscontrol:
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                andi.b  #$F0,n_glissfunk(A6)
                or.b    D0,n_glissfunk(A6)
                rts

setvibratocontrol:
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                andi.b  #$F0,n_wavecontrol(A6)
                or.b    D0,n_wavecontrol(A6)
                rts

setfinetune:
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                move.b  D0,n_finetune(A6)
                rts

jumploop:
                tst.l   counter
                bne     return2
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                beq     setloop
                tst.b   n_loopcount(A6)
                beq     jumpcnt
                subi.b  #1,n_loopcount(A6)
                beq     return2
jmploop:        move.b  n_pattpos(A6),pbreakposition
                st      pbreakflag
                rts

jumpcnt:        move.b  D0,n_loopcount(A6)
                bra     jmploop

setloop:        move.l  patternposition,D0
                lsr.l   #4,D0
                and.b   #63,D0
                move.b  D0,n_pattpos(A6)
                rts

settremolocontrol:
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,n_wavecontrol(A6)
                or.b    D0,n_wavecontrol(A6)
                rts

karplusstrong:
                movem.l D1-D2/A0-A1,-(SP)
                movea.l n_loopstart(A6),A0
                movea.l A0,A1
                move.w  n_replen(A6),D0
                add.w   D0,D0
                subq.w  #2,D0
karplop:        move.b  (A0),D1
                ext.w   D1
                move.b  1(A0),D2
                ext.w   D2
                add.w   D1,D2
                asr.w   #1,D2
                move.b  D2,(A0)+
                dbra    D0,karplop
                move.b  (A0),D1
                ext.w   D1
                move.b  (A1),D2
                ext.w   D2
                add.w   D1,D2
                asr.w   #1,D2
                move.b  D2,(A0)
                movem.l (SP)+,D1-D2/A0-A1
                rts

retrignote:
                move.l  D1,-(SP)
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                beq     rtnend
                move.l  counter,D1
                bne     rtnskp
                move.w  n_note(A6),D1
                and.w   #$0FFF,D1
                bne     rtnend
                move.l  counter,D1
rtnskp:         divu    D0,D1
                swap    D1
                tst.w   D1
                bne     rtnend
doretrg:
                move.l  D0,-(SP)        ;;
;               move.w  n_dmabit(A6),$DFF096 ; Channel DMA off
;                move.w  n_dmabit(A6),D0 ;;
;                jsr     move_dmacon     ;;
;                move.l  n_start(A6),(A5) ; Set sampledata pointer
;                move.w  n_length(A6),4(A5) ; Set length

                move.l  n_start(A6),sam_start(A5)
                moveq   #0,D0
                move.w  n_length(A6),D0
                add.l   D0,D0
                add.l   D0,sam_start(A5)
                move.l  D0,sam_length(A5)
                move.w  n_period(A6),sam_period(A5)

;                moveq   #0,D0
;                move.b  n_volume(A6),D0
;               MOVE.W  D0,8(A5)
;                move.w  dmawait,D0
;rtnloop1:
;                dbra    D0,rtnloop1

                move.w  n_dmabit(A6),D0
                bset    #15,D0
                jsr     move_dmacon

;                move.w  D0,$DFF096
;                move.w  dmawait,D0
;rtnloop2:
;                dbra    D0,rtnloop2
;                move.l  n_loopstart(A6),(A5)
;                move.l  n_replen(A6),4(A5)

                move.l  n_loopstart(A6),sam_lpstart(A5) ;;
                moveq   #0,D0           ;;
                move.w  n_replen(A6),D0 ;;
                add.l   D0,D0           ;;
                add.l   D0,sam_lpstart(A5) ;;
                move.l  D0,sam_lplength(A5) ;;

                move.l  (SP)+,D0
rtnend:         move.l  (SP)+,D1
                rts

volumefineup:
                tst.l   counter
                bne     return2
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                bra     volslideup

volumefinedown:
                tst.l   counter
                bne     return2
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                bra     volslidedown2

notecut:        moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                cmp.l   counter,D0
                bne     return2
                clr.b   n_volume(A6)
;       MOVE.W  #0,8(A5)
                rts

notedelay:
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                cmp.l   counter,D0
                bne     return2
                move.w  (A6),D0
                and.w   #$0FFF,D0
                beq     return2
                move.l  D1,-(SP)
                bra     doretrg

patterndelay:
                tst.l   counter
                bne     return2
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                tst.b   pattdelaytime2
                bne     return2
                addq.b  #1,D0
                move.b  D0,pattdelaytime
                rts

funkit:         tst.l   counter
                bne     return2
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,n_glissfunk(A6)
                or.b    D0,n_glissfunk(A6)
                tst.b   D0
                beq     return2
updatefunk:
                movem.l D1/A0,-(SP)
                moveq   #0,D0
                move.b  n_glissfunk(A6),D0
                lsr.b   #4,D0
                beq     funkend
                lea     funktable(PC),A0
                move.b  0(A0,D0.w),D0
                add.b   D0,n_funkoffset(A6)
                btst    #7,n_funkoffset(A6)
                beq     funkend
                clr.b   n_funkoffset(A6)
                move.l  n_loopstart(A6),D0
                moveq   #0,D1
                move.w  n_replen(A6),D1
                add.l   D1,D0
                add.l   D1,D0
                movea.l n_wavestart(A6),A0
                addq.l  #1,A0
                cmpa.l  D0,A0
                blo.s   funkok
                movea.l n_loopstart(A6),A0
funkok:         move.l  A0,n_wavestart(A6)
                moveq   #-1,D0
                sub.b   (A0),D0
                move.b  D0,(A0)
funkend:        movem.l (SP)+,D1/A0
                rts

                ENDPART

                PART 'paula emu!!'

; Here we have the replay rout.

; Paula emulation storage structure.

                RSRESET
sam_start:      RS.L 1          ; sample start
sam_length:     RS.L 1          ; sample length
sam_period:     RS.W 1          ; sample period(freq)
sam_vol:        RS.W 1          ; sample volume
sam_lpstart:    RS.L 1          ; sample loop start
sam_lplength:   RS.L 1          ; sample loop length
sam_vcsize:     RS.B 1          ; structure size.

ch1s:           DS.B sam_vcsize
ch2s:           DS.B sam_vcsize ; shadow channel regs
ch3s:           DS.B sam_vcsize
ch4s:           DS.B sam_vcsize
shadow_dmacon:  DS.W 1
shadow_filter:  DS.W 1

; Macro to move d0 into the shadow dma register...
; (Remember - bit 15 of 'dmacon' determines clearing or setting of bits!)

move_dmacon:
                move.w  D0,-(SP)        ; save D0
                btst    #15,D0          ; set or clear?
                bne.s   .setbits
.clearbits:     not.w   D0              ; zero so clear
                and.w   D0,shadow_dmacon ; mask bits in dmacon
                bra.s   .dmacon_set     ; and exit...
.setbits:       or.w    D0,shadow_dmacon ; not zero so set 'em
.dmacon_set:    move.w  (SP)+,D0        ; restore D0
                rts

buff_ptr:       DC.L circbuf
lastwrt_ptr:    DC.L circbuf

; Player - This is THE 'Paula' Emulator.

do_music:
                tst.b   music_on        ; music on?
                beq     skipit          ; if not skip all!
                lea     $FFFF8909.w,A0
.read:          movep.l 0(A0),D0
                lsr.l   #8,D0
                REPT 12
                nop
                ENDR
                movep.l 0(A0),D1        ; read frame address twice
                lsr.l   #8,D1           ; midway thru a read!
                cmp.l   D0,D1           ; so we read twice and
                bne.s   .read           ; check the reads are
                sub.l   #circbuf,D1
                and.w   #3,D1
                tst.w   D1
                bne.s   .read
                movea.l buff_ptr(PC),A4
                move.l  A4,lastwrt_ptr
.okb:           move.l  D0,buff_ptr
                cmpa.l  D0,A4
                beq.s   skipit
                tst.w   loadinprogress
                bne.s   fillclearbuf
                lea     voice1set(PC),A0 ; Setup Chan 1
                lea     ch1s(PC),A5
                moveq   #0,D4
                bsr     setupvoice
                lea     voice2set(PC),A0 ;      "     2
                lea     ch2s(PC),A5
                moveq   #1,D4
                bsr     setupvoice
                lea     voice3set(PC),A0 ;      "     3
                lea     ch3s(PC),A5
                moveq   #2,D4
                bsr     setupvoice
                lea     voice4set(PC),A0 ;      "     4
                lea     ch4s(PC),A5
                moveq   #3,D4
                bsr     setupvoice
                bsr     goforit
contmus:        jmp     intmusic
skipit:         rts

; Fill buffer with 0.

fillclearbuf:   moveq   #0,D0
                movea.l lastwrt_ptr(PC),A4
                movea.l buff_ptr(PC),A5
                suba.l  A4,A5
                move.w  A5,D6
                tst.w   D6
                bgt.s   .ccse1
.ccse2:         lea     circbuf+circbufsize,A5
                suba.l  A4,A5
                move.w  A5,D6
                bsr     clear2
                movea.l buff_ptr(PC),A5
                lea     circbuf,A4
                suba.l  A4,A5
                move.w  A5,D6
.ccse1:         bsr     clear2
                bra.s   contmus

clear2:         asr.w   #2,D6
                bra.s   .cbcont
.cblp:          move.l  D0,(A4)+
.cbcont:        dbra    D6,.cblp
.noclb:         rts

                RSRESET
vaddr:          RS.L 1
voffy:          RS.L 1
vfrac:          RS.L 1
vfreqint:       RS.W 1          ; structure produced
vfreqfrac:      RS.L 1
vvoltab:        RS.W 1          ; from 'paula' data
vlpaddr:        RS.L 1
vlpoffy:        RS.L 1
vlpfreqint:     RS.W 1
vlpfreqfrac:    RS.L 1

; Routine to add/move one voice to buffer. The real Paula emulation part!!

setupvoice:     movea.l sam_start(A5),A2 ; current sample end address(shadow amiga!)
                move.l  sam_length(A5),D0
                moveq   #0,D1
                move.w  sam_period(A5),D1 ;period
                move.w  sam_vol(A5),D2
                cmp.w   #$40,D2
                bls.s   .volisok
                moveq   #$40,D2
.volisok:
                moveq   #0,D3
                tst.w   D1
                beq.s   .zero
                move.l  freqconst(PC),D3
                DC.L $4C413003  ; divu.l d1,d3
                move.l  D3,D1
                swap    D1
.zero:          neg.l   D0              ; negate sample offset
                move.w  shadow_dmacon(PC),D7
                btst    D4,D7
                bne.s   .vcon2
                moveq   #0,D1           ; clear freq if off.
                moveq   #0,D3           ; clear freq if off.
                moveq   #0,D2           ; volume off for safety!!
.vcon2:
                cmpa.l  #8000,A2        ;;
                bge.s   .okisok         ;;
                lea     nulsamp+2(PC),A2 ;;
                moveq   #-2,D0          ;;
                moveq   #0,D1           ;;
                moveq   #0,D3           ;;
.okisok:        lea     nulsamp+2(PC),A6
                cmpa.l  A6,A2
                bne.s   .vcon
                moveq   #0,D1           ; clear freq if off.
                moveq   #0,D3           ; clear freq if off.
                moveq   #0,D2           ; volume off for safety!!
.vcon:          movea.l sam_lpstart(A5),A6 ; loop addr
                move.l  sam_lplength(A5),D5 ; loop length
                neg.l   D5              ; negate it.
                move.w  D1,D6           ; freq on loop
                move.l  D3,D7           ;
                cmp.l   #-2,D5
                bne.s   .isloop
.noloop:        moveq   #0,D6
                moveq   #0,D7           ; no loop-no frequency
                lea     nulsamp+2(PC),A6 ; no loop-point to nul
.isloop:        move.l  A2,(A0)+        ; store address
                move.l  D0,(A0)+        ; store offset int.L
                addq.l  #4,A0           ; skip current frac.l
                move.w  D1,(A0)+        ; store freq int.w
                move.l  D3,(A0)+        ; store freq 32bit fraction
                move.w  D2,(A0)+        ; address of volume tab.
                move.l  A6,(A0)+        ; store loop addr
                move.l  D5,(A0)+        ; store loop offset.L
                move.w  D6,(A0)+        ; store loop freq int.w
                move.l  D7,(A0)+        ; store loop freq frac.L
                rts

; Make that buffer! (channels are paired together!)

goforit:        lea     ch1s(PC),A2
                lea     ch4s(PC),A3
                lea     voice1set(PC),A5
                lea     voice4set(PC),A6
                move.w  #0,bufoff
                bsr     do2chans
                lea     ch2s(PC),A2
                lea     ch3s(PC),A3
                lea     voice2set(PC),A5
                lea     voice3set(PC),A6
                move.w  #2,bufoff
                bsr     do2chans
                rts

; Create 2 channels in the buffer.

do2chans:       movem.l A2-A3/A5-A6,-(SP)

                movea.l vaddr(A5),A0    ; ptr to end of each sample!
                move.l  voffy(A5),D0    ; int.w offset
                move.l  vfrac(A5),D4    ; frac.w offset
                move.w  vfreqint(A5),D6
                movea.l vfreqfrac(A5),A2 ; frac.w/int.w freq

                move.l  vlpaddr(A5),lpvc1a ; loop for voice 1
                move.l  vlpoffy(A5),lpvc1b
                move.l  vlpfreqfrac(A5),lpvc1c
                move.w  vvoltab(A5),D2

                movea.l vaddr(A6),A1
                move.l  voffy(A6),D1
                move.l  vfrac(A6),D5
                move.w  vfreqint(A6),D7
                movea.l vfreqfrac(A6),A3
                move.l  vlpaddr(A6),lpvc2a ; loop for voice 1
                move.l  vlpoffy(A6),lpvc2b
                move.l  vlpfreqfrac(A6),lpvc2c
                move.w  vvoltab(A6),D3

                lsl.w   #8,D2
                lsl.w   #8,D3
                lea     vols,A5
                lea     (A5),A6
                adda.w  D2,A5
                adda.w  D2,A5
                adda.w  D3,A6
                adda.w  D3,A6
                moveq   #0,D2
                moveq   #0,D3

                movea.l lastwrt_ptr(PC),A4
                move.l  buff_ptr(PC),D7
                sub.l   A4,D7
                bgt.s   .cse1
.cse2:          move.l  #circbuf+circbufsize,D7
                sub.l   A4,D7
                bsr     add2
                move.l  buff_ptr(PC),D7
                lea     circbuf,A4
                sub.l   A4,D7
.cse1:          bsr     add2
                movem.l (SP)+,A2-A3/A5-A6
                neg.l   D0              ; +ve offset(as original!)
                neg.l   D1
                move.l  A0,sam_start(A2) ; store voice address
                move.l  D0,sam_length(A2) ; store offset for next time
                move.l  D4,vfrac(A5)    ; store frac part
                move.l  A1,sam_start(A3) ; same for chan 2
                move.l  D1,sam_length(A3)
                move.l  D5,vfrac(A6)
                rts
bufoff:         DC.W 0

add2:           adda.w  bufoff(PC),A4
                asr.w   #2,D7
                subq.w  #1,D7
                bmi.s   exitadd12
make12_stelp:
                move.b  0(A0,D0.l),D2
                DC.L $3C352200  ;       move.w  0(A5,D2.w*2),D6
                move.b  0(A1,D1.l),D2
                DC.L $DC762200  ;       add.w   0(A6,D2.w*2),D6
                move.w  D6,(A4)
                add.w   A2,D4           ; 32 bit fraction
                addx.w  D3,D0
                bcs.s   lpvc1ste
contlp1ste:     addq.l  #4,A4
                add.w   A3,D5           ;
                addx.w  D3,D1
contlp2ste:     dbcs    D7,make12_stelp
                bcs.s   lpvc2ste
exitadd12:
                rts

lpvc1ste:       ext.l   D0
                movea.l lpvc1a(PC),A0   ; 0+2
                add.l   lpvc1b(PC),D0   ; 6+4
                movea.l lpvc1c(PC),A2   ; 12+2
                bra.s   contlp1ste
lpvc1a:         DC.L 0
lpvc1b:         DC.L 0
lpvc1c:         DC.L 0

lpvc2ste:       ext.l   D1
                movea.l lpvc2a(PC),A1   ; 0+2
                add.l   lpvc2b(PC),D1   ; 6+2
                movea.l lpvc2c(PC),A3   ; 12+2
                dbra    D7,make12_stelp
                bra.s   exitadd12
lpvc2a:         DC.L 0
lpvc2b:         DC.L 0
lpvc2c:         DC.L 0

voice1set:      DS.L 10
voice2set:      DS.L 10         ; voice data (setup from 'paula' data)
voice3set:      DS.L 10
voice4set:      DS.L 10

                DS.L 16         ; (in case!!)
nulsamp:        DS.L 16         ; nul sample
music_on:       DC.W 0          ; music on flag
voltab_ptr:     DC.L 0          ; ptr to volume table

; Start music

start_music:
                lea     nulsamp+2(PC),A2
                moveq   #0,D0
                lea     ch1s(PC),A0
                bsr     initvoice
                lea     ch2s(PC),A0
                bsr     initvoice
                lea     ch3s(PC),A0
                bsr     initvoice
                lea     ch4s(PC),A0
                bsr     initvoice
                bra     startints

stop_music:     move    #$2700,SR
                bsr     stop_dma        ; stop STE dma.
                lea     music_on(PC),A0
                sf      (A0)
                move    #$2300,SR
                rts

; A0-> voice data (paula voice) to initialise.

initvoice:      move.l  A2,sam_start(A0) ; point voice to nul sample
                move.l  #2,sam_length(A0)
                move.w  D0,sam_period(A0) ; period=0
                move.w  D0,sam_vol(A0)  ; volume=0
                move.l  A2,sam_lpstart(A0) ; and loop point to nul sample
                move.l  #2,sam_lplength(A0)
                rts

startints:      bsr     stop_dma
                move    #$2700,SR
                move.w  $FFFF8930.w,D0
                and.w   #%1111111111110000,D0
                or.w    #%1001,D0       ; dma output 25mhz clock,no handshake
                move.w  D0,$FFFF8930.w
                move.w  $FFFF8932.w,D0
                and.w   #%1100011111111111,D0
                or.w    #%1000100000000000,D0 ; Dma output -> DAC(no handshake)
                move.w  D0,$FFFF8932.w
                move.b  #2,$FFFF8935.w  ; ste compatible freq divider
                bclr    #7,$FFFF8901.w  ; select playback register
                bsr     vbset_dma
                bsr     start_dma
                lea     music_on(PC),A0
                st      (A0)
                move    #$2300,SR
                rts

; Set dma for vbl player

vbset_dma:      lea     temp(PC),A1
                lea     circbuf,A0
                move.l  A0,(A1)
                lea     circbuf+circbufsize,A0
                move.l  A0,4(A1)
                move.b  3(A1),$FFFF8907.w
                move.b  2(A1),$FFFF8905.w ; set start of buffer
                move.b  1(A1),$FFFF8903.w
                move.b  3+4(A1),$FFFF8913.w
                move.b  2+4(A1),$FFFF8911.w ; set end of buffer
                move.b  1+4(A1),$FFFF890F.w
                rts
temp:           DC.L 0,0

start_dma:      move.b  #64+dmamask,$FFFF8921.w ; set khz
                move.b  #3,$FFFF8901.w  ; start STE dma.
                rts
stop_dma:       clr.b   $FFFF8901.w
                rts


; Create the 65 volume lookup tables

makevoltab:     movea.l #vols+(16640*2),A0
                moveq   #$40,D0
.vllp1:         move.w  #$FF,D1
.vllp2:         move.w  D1,D2
                ext.w   D2
                muls    D0,D2
                move.w  D2,-(A0)
                dbra    D1,.vllp2
                dbra    D0,.vllp1
                lea     circbuf,A0
                move.w  #(circbufsize/4)-1,D0
                moveq   #0,D2
.clstelp:
                move.l  D2,(A0)+
                dbra    D0,.clstelp
                rts

freqconst:      DC.L $6C3404    ;32khz

                ENDPART



;************************* End of Code ******************************



                DATA



funktable:      DC.B 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

vibratotable:
                DC.B 0,24,49,74,97,120,141,161
                DC.B 180,197,212,224,235,244,250,253
                DC.B 255,253,250,244,235,224,212,197
                DC.B 180,161,141,120,97,74,49,24

allrighttext:   DC.B 'All right',0
plstfulltext:   DC.B 'Plst is full!',0
areyousuretext: DC.B 'Are you sure?',0
nodiskindrivetext:
                DC.B 'No disk in df0!',0
writeprotectedtext:
                DC.B 'Write protected',0
oprabortedtext: DC.B 'Print aborted!',0
enterdatatext:  DC.B 'Enter data',0
addingpathtext: DC.B 'Adding path...',0
diskerrortext:  DC.B 'Disk error !!',0
loadingtext:    DC.B 'Loading...',0
loadingsongtext:DC.B 'Loading song',0
loadingmoduletext:
                DC.B 'Loading module',0
loadingsampletext:
                DC.B 'Loading sample',0
savingtext:     DC.B 'Saving...',0
;SaveSongText   dc.b    'Save song ?',0
savingsongtext: DC.B 'Saving song',0
;SaveModuleText dc.b    'Save module ?',0
savingmoduletext:
                DC.B 'Saving module',0
;SaveSampleText dc.b    'Save sample ?',0
savingsampletext:
                DC.B 'Saving sample',0
loadingplsttext:DC.B 'Loading plst',0
savingplsttext: DC.B 'Saving plst',0
deletingsongtext:
                DC.B 'Deleting song',0
deletingmoduletext:
                DC.B 'Deleting module',0
deletingsampletext:
                DC.B 'Deleting sample',0
renamingfiletext:
                DC.B 'Renaming file',0
decrunchingtext:DC.B 'Decrunching...',0
crunchingtext:  DC.B 'Crunching...',0
selectentrytext:DC.B 'Select entry',0
selectsongtext: DC.B 'Select song',0
selectmoduletext:
                DC.B 'Select module',0
selectsampletext:
                DC.B 'Select sample',0
selectfiletext: DC.B 'Select file',0
readingdirtext: DC.B 'Reading dir...',0
possettext:     DC.B 'Position set',0
printingsongtext:
                DC.B 'Printing song',0
printingplsttext:
                DC.B 'Printing plst',0

savesongtext:   DC.B 'Save song ?',0
deletesongtext: DC.B 'Delete song ?',0
savemoduletext: DC.B 'Save module ?',0
deletemoduletext:DC.B 'Delete module ?',0
savesampletext: DC.B 'Save sample ?',0
deletesampletext:DC.B 'Delete sample ?',0
printplsttext:  DC.B 'Print plst ?',0
printsongtext:  DC.B 'Print song ?',0
quitpttext:     DC.B 'Really quit ?',0
upsampletext:   DC.B 'Upsample ?',0
downsampletext: DC.B 'Downsample ?',0
pleaseselecttext:DC.B 'Please select',0
clearsplittext: DC.B 'Clear split ?',0
resetalltext:   DC.B 'Reset config ?',0
deletepresettext:DC.B 'Delete preset ?',0
loadplsttext:   DC.B 'Load presetlist?',0
saveplsttext:   DC.B 'Save presetlist?',0
killsampletext: DC.B 'Kill sample ?',0
abortloadtext:  DC.B 'Abort loading ?',0
loadconfigtext: DC.B 'Load config ?',0
saveconfigtext: DC.B 'Save config ?',0

inprogresstext: DC.B 'in progress'
plsentnamtext:  DC.B 'Please enter name'
ofvolumetext:   DC.B 'of volume:  ST-__',0,0
                CNOP 0,2
disknumtext1:   DC.B '0'
disknumtext2:   DC.B '0  '
peddefaultpath: DC.B 'df0:',0
                DCB.B 47

peddefaultvol:  DC.B 'st-'
snddisknum0:    DC.B '0'
snddisknum1:    DC.B '1:'

presetname:     DC.B '      '
psetnametext:   DC.B '                '
                DC.B ' '
psetvoltext:    DC.B '  '
                DC.B ' '
psetlentext:    DC.B '    '
                DC.B ' '
psetrepeattext: DC.B '    '
                DC.B ' '
psetreplentext: DC.B '    '

insertpsettext: DC.B 'ST-01:                  0 0000 0000 0002'
psetplsttext:   DC.B 'No.    Samplename               '
                DC.B 'Length  Repeat  RepLen',$0A,$0A
psetprtnumtext: DC.B '    :  '
psetprtnametext:DC.B '                             '
psetprtlentext: DC.B '        '
psetprtrepeattext:DC.B '        '
psetprtreplentext:DC.B 10
                DC.B 0
songdumptext:
                DC.B 9
                DC.B 'Protracker Song-Dump -- Made with '
                DC.B 'Protracker V2.0A  ',$0D,$0A,$0A
                DC.B 9
                DC.B 'Songname:  '
crlf_text:      DC.B 13,10
ff_text:        DC.B 12,0
                EVEN

                CNOP 0,2

patternnumtext: DC.B 9,9,9,'Pattern: '
pattnumtext1:   DC.B '0'
pattnumtext2:   DC.B '0',$0D,$0A,$0D,$0A

ptottext:       DC.B 9
pattxtext1:     DC.B "0"
pattxtext2:     DC.B "0 : "
pptext:         DC.B "                      "
prafs:          DC.B "  0000  0000  0000    ",$0D,$0A
pntext2:        DC.B "        "
                CNOP 0,2
                DC.B 0
pattpostext:    DC.B '00  :                                                       '
pntext:         DC.B '    ',0
                EVEN

                CNOP 0,2
sttext1:        DC.B 'ST'
sttext1num:     DC.B '-'
sttext1number:  DC.B 0,0,':'
sttext2:        DC.B 'ST'
sttext2num:     DC.B '-'
sttext2number:  DC.B 0,0,':'
sttext3:        DC.B 'ST'
sttext3num:     DC.B '-'
sttext3number:  DC.B 0,0,':'

emptylinetext:  DC.B '                       ',0

                CNOP 0,4

fasthextable:   DC.B '000102030405060708090A0B0C0D0E0F'
                DC.B '101112131415161718191A1B1C1D1E1F'
                DC.B '202122232425262728292A2B2C2D2E2F'
                DC.B '303132333435363738393A3B3C3D3E3F'
                DC.B '404142434445464748494A4B4C4D4E4F'
                DC.B '505152535455565758595A5B5C5D5E5F'
                DC.B '606162636465666768696A6B6C6D6E6F'
                DC.B '707172737475767778797A7B7C7D7E7F'
                DC.B '808182838485868788898A8B8C8D8E8F'
                DC.B '909192939495969798999A9B9C9D9E9F'
                DC.B 'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF'
                DC.B 'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF'
                DC.B 'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF'
                DC.B 'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'
                DC.B 'E0E1E2E3E4E5E6E7E8E9EAEBECEdEEEF'
                DC.B 'F0F1F2F3F4F5F6F7F8F9FAFBFCFdFEFF'

dosbase:        DC.L 0
intuitionbase:  DC.L 0
gfxbase:        DC.L 0

rawkeyhextable:
                DC.B 10,1,2,3,4,5,6,7
                DC.B 8,9,32,53,51,34,18,35
rawkeyscaletable:
                DC.B 49,33,50,34,51,52,36,53,37,54,38,55,56,40,57
                DC.B 41,58,16,2,17,3,18,19,5,20,6,21,7,22,23,9,24,10
                DC.B 25,26,12,27,70,70,0

kbdtranstable1:
                DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
                DC.B 12,13,14,15,16,17,18,19,20,21,22,23
                DC.B 24,25,26,27,28,29,30,31,36,36
kbdtranstable2:
                DC.B 12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28
                DC.B 24,25,26,27,28,29,30,31,32,33,34,35
                DC.B 36,36,36,36,36,36,36,36,36,36
notenames1:
                DC.B 'C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1 '
                DC.B 'C-2 C#2 D-2 D#2 E-2 F-2 F#2 G-2 G#2 A-2 A#2 B-2 '
                DC.B 'C-3 C#3 D-3 D#3 E-3 F-3 F#3 G-3 G#3 A-3 A#3 B-3 '
spcnotetext:
                DC.B '--- '
notenames2:
                DC.B 'C-1 D¡1 D-1 ÿÿÿÿE-1 F-1 G¡1 G-1 A¡1 A-1 B¡1 B-1 '
                DC.B 'C-2 D¡2 D-2 E¡2 E-2 F-ÿÿG¡2 G-2 ÿÿ2 A-2 B¡2 B-2 '
                DC.B 'C-3 D¡3 D-3 E¡3 E-3 F-3 G¡3 G-3 A¡3 A-3 B¡3 B-3 '
                DC.B '--- '

periodtable:
; Tuning 0
                DC.W 856,808,762,720,678,640,604,570,538,508,480,453
                DC.W 428,404,381,360,339,320,302,285,269,254,240,226
                DC.W 214,202,190,180,170,160,151,143,135,127,120,113,0
; Tuning 1
                DC.W 850,802,757,715,674,637,601,567,535,505,477,450
                DC.W 425,401,379,357,337,318,300,284,268,253,239,225
                DC.W 213,201,189,179,169,159,150,142,134,126,119,113,0
; Tuning 2
                DC.W 844,796,752,709,670,632,597,563,532,502,474,447
                DC.W 422,398,376,355,335,316,298,282,266,251,237,224
                DC.W 211,199,188,177,167,158,149,141,133,125,118,112,0
; Tuning 3
                DC.W 838,791,746,704,665,628,592,559,528,498,470,444
                DC.W 419,395,373,352,332,314,296,280,264,249,235,222
                DC.W 209,198,187,176,166,157,148,140,132,125,118,111,0
; Tuning 4
                DC.W 832,785,741,699,660,623,588,555,524,495,467,441
                DC.W 416,392,370,350,330,312,294,278,262,247,233,220
                DC.W 208,196,185,175,165,156,147,139,131,124,117,110,0
; Tuning 5
                DC.W 826,779,736,694,655,619,584,551,520,491,463,437
                DC.W 413,390,368,347,328,309,292,276,260,245,232,219
                DC.W 206,195,184,174,164,155,146,138,130,123,116,109,0
; Tuning 6
                DC.W 820,774,730,689,651,614,580,547,516,487,460,434
                DC.W 410,387,365,345,325,307,290,274,258,244,230,217
                DC.W 205,193,183,172,163,154,145,137,129,122,115,109,0
; Tuning 7
                DC.W 814,768,725,684,646,610,575,543,513,484,457,431
                DC.W 407,384,363,342,323,305,288,272,256,242,228,216
                DC.W 204,192,181,171,161,152,144,136,128,121,114,108,0
; Tuning -8
                DC.W 907,856,808,762,720,678,640,604,570,538,508,480
                DC.W 453,428,404,381,360,339,320,302,285,269,254,240
                DC.W 226,214,202,190,180,170,160,151,143,135,127,120,0
; Tuning -7
                DC.W 900,850,802,757,715,675,636,601,567,535,505,477
                DC.W 450,425,401,379,357,337,318,300,284,268,253,238
                DC.W 225,212,200,189,179,169,159,150,142,134,126,119,0
; Tuning -6
                DC.W 894,844,796,752,709,670,632,597,563,532,502,474
                DC.W 447,422,398,376,355,335,316,298,282,266,251,237
                DC.W 223,211,199,188,177,167,158,149,141,133,125,118,0
; Tuning -5
                DC.W 887,838,791,746,704,665,628,592,559,528,498,470
                DC.W 444,419,395,373,352,332,314,296,280,264,249,235
                DC.W 222,209,198,187,176,166,157,148,140,132,125,118,0
; Tuning -4
                DC.W 881,832,785,741,699,660,623,588,555,524,494,467
                DC.W 441,416,392,370,350,330,312,294,278,262,247,233
                DC.W 220,208,196,185,175,165,156,147,139,131,123,117,0
; Tuning -3
                DC.W 875,826,779,736,694,655,619,584,551,520,491,463
                DC.W 437,413,390,368,347,328,309,292,276,260,245,232
                DC.W 219,206,195,184,174,164,155,146,138,130,123,116,0
; Tuning -2
                DC.W 868,820,774,730,689,651,614,580,547,516,487,460
                DC.W 434,410,387,365,345,325,307,290,274,258,244,230
                DC.W 217,205,193,183,172,163,154,145,137,129,122,115,0
; Tuning -1
                DC.W 862,814,768,725,684,646,610,575,543,513,484,457
                DC.W 431,407,384,363,342,323,305,288,272,256,242,228
                DC.W 216,203,192,181,171,161,152,144,136,128,121,114,0

cursorpostable:
                DC.B 3,6,7,8,9,10,12
                DC.B 15,16,17,18,19,21
                DC.B 24,25,26,27,28,30
                DC.B 33,34,35,36,37
unshiftedkeymap:
                DC.B '`1234567890-=\*0'
                DC.B 'qwertyuiop[]*123'
                DC.B 'asdfghjkl;',39,'#',0,'456'
                DC.B '<zxcvbnm,./',0,'.','789 '
shiftedkeymap:
                DC.B '~!@#$%^&*()_+|*0'
                DC.B 'qwertyuiop{}*123'
                DC.B 'asdfghjkl:',34,'^',0,'456'
                DC.B '>zxcvbnm<>?',0,'.','789 '

songnumofpatt:  DC.W 1
notenamesptr:   DC.L 0
spriteptrsptr:  DC.L 0
linecurposptr:  DC.L 0
nospriteptr:    DC.L 0
cursorposptr:   DC.L 0
ch1spriteptr:   DC.L 0
ch2spriteptr:   DC.L 0
ch3spriteptr:   DC.L 0
ch4spriteptr:   DC.L 0
ppattpos:       DC.L 0
saveeditmode:   DC.L 0
editmode:       DC.L 0
runmode:        DC.L 0
currcmds:       DC.L 0
textbplptr:     DC.L 0
textoffset:     DC.W 0
textlength:     DC.W 0
textlentemp:    DC.L 0
showtextptr:    DC.L 0
patternnumber:  DC.L 0
currpos:        DC.L 0
currspeed:      DC.L 0
keytranstabptr: DC.L 0
cmdoffset:      DC.W 0
rawkeycode:     DC.B 0
pattrfsh:       DC.B 0
mountflag:      DC.W 0
getlineflag:    DC.W 0
loadinprogress: DC.W 0
currentplaynote:DC.W 214
linecurx:       DC.W 0
linecury:       DC.W 270
textendptr:     DC.L 0
scrpattpos:     DC.W 0
pattcurpos:     DC.W 0
gadgrepeat:     DC.W 0
wordnumber:     DC.W 0
highpattnum:    DC.W 0
insnum:         DC.W 0
lastinsnum:     DC.W 1
playinsnum:     DC.W 1
hilowinstr:     DC.W 0
pedpos:         DC.W 0
plstpos:        DC.W 0
maxplstoffset:  DC.L 0
presetmarktotal:DC.W 0
plstoffset:     DCB.B 14*4
currentpreset:  DC.W 1
upordown:       DC.W 0
joy0low:        DC.W 0
joy0high:       DC.W 0
mousex:         DC.W 0
mousey:         DC.W 0
mousex2:        DC.W 0
mousey2:        DC.W 0
mousex3:        DC.W 0
mousey3:        DC.W 0
decompmemptr:   DC.L 0
decompmemsize:  DC.L 0

sampleinfo:     DC.W 0
si_volume:      DC.W 0
si_long:        DC.L 0
si_pointer:     DC.L 0,0,0,0,0
sampleinfo2:    DC.W 0
si_volume2:     DC.W 0
si_long2:       DC.L 0
si_pointer2:    DC.L 0,0,0,0,0

longffff:       DC.L 0
posjumpassert:  DC.B 0
pbreakposition: DC.B 0
pbreakflag:     DC.B 0
ledstatus:      DC.B 0
pattdelaytime:  DC.B 0
pattdelaytime2: DC.B 0
                EVEN
pattrfshnum:    DC.L 0
didquantize:    DC.W 0
messageptr:     DC.L 0
filenameptr:    DC.L 0
diskdataptr:    DC.L 0
filehandle:     DC.L 0
diskdatalength: DC.L 0
lowmask:        DC.B $FF
                EVEN

patternposition:DC.L 0
songposition:   DC.L 0
counter:        DC.L 0
patternptr:     DC.L 0
songdataptr:    DC.L 0
samplestarts:   DCB.L 31
sampleptrs      EQU samplestarts-4
samplelengths:  DCB.L 32
dmacontemp:     DC.W 0
stacksave:      DC.L 0
inputdevmouse:  DC.L 0,0,0
analyzerheights:DCB.W 23
analyzeropplegg:DCB.W 23
action:         DC.W 0
pathptr:        DC.L 0
filelock:       DC.L 0
currscreen:     DC.W 0
savecurrscreen: DC.W 0
pointercol1save:DC.W 0
pointercol2save:DC.W 0
pointercol3save:DC.W 0
getdectemp:     DC.B 0
updatetempo:    DC.B 0
moreinstrflag:  DC.W 0
samplesortlist: DCB.L 32
plstmem:        DC.L 0
presettotal:    DC.W 0
savescope:      DC.B 0
                DC.B 0          ;free 0
disableanalyzer:DC.B 0
saveda:         DC.B 0
autoreqrunning: DC.B 0
nosampleinfo:   DC.B 0
formatdataptr:  DC.L 0
cylindernumber: DC.W 0
trackdiskport:  DC.L 0,0,0,0
processptr:     DC.L 0,0,0,0
datestamp:      DC.L 0,0,0,0
entertextflag:  DC.W 0
presetlength:   DC.W 0
presetfinetune: DC.W 0
presetrepeat:   DC.W 0
presetreplen:   DC.W 0
ped_action:     DC.W 0
psetnumtemp:    DC.W 0
psetptrtemp:    DC.L 0
freediskspace:  DC.L 0
splitaddress:   DC.L 0
lahetx:         DC.L $12345678
plstallocsize:  DC.L 0
maxplstentries2:DC.W 0

;---- Setup Data ----

defaultsetupdata:
                DC.B 'PT2.0 Configuration File',$0A,0
                DC.B 'A:\SONGS\'
                DCB.B 32-9
                DC.B 'A:\MODS\'
                DCB.B 32-8
                DC.B 'A:\SAMPLES\'
                DCB.B 32-11
                DC.B 'PRT:'
                DCB.B 28
defcol:         DC.W $00,$0BBB,$0888,$0555,$0FD0,$0D04,$00,$034F
                DC.B 1          ; Song Pack Mode
                DC.B 0          ; Module Pack Mode
                DC.B 0          ; Split  0=off, 1=on
                DC.B 0          ; Filter
                DC.B 0          ; TransDel
                DC.B 1          ; ShowDec
                DC.B 1          ; AutoDir
                DC.B 1          ; AutoExit
                DC.B 1          ; ModOnly
                DC.B 0          ; MIDI
                DC.B 1,$18,$18,0 ; SplitData
                DC.B 2,$1A,$18,0
                DC.B 3,$1C,$18,0
                DC.B 4,$1D,$18,0
                DC.W 20,2       ; KeyRepDelay/Speed
                DC.B 0          ; Accidental
                DC.B 0          ; not in use
                DC.B 'newshell',0 ; ExtCmd 0
                DCB.B 23
                DC.B 'add21k',0 ; ExtCmd 1
                DCB.B 25
                DC.B 'info',0   ; ExtCmd 2
                DCB.B 27
                DC.B 'list',0   ; ExtCmd 3
                DCB.B 27
                DC.B 'loadwb -debug',0 ; ExtCmd 4
                DCB.B 18
                DC.B 'diskmaster1.3',0 ; ExtCmd 5
                DCB.B 18
                DC.B 'run AudioMasterIII',0 ; ExtCmd 6
                DCB.B 13
                DC.B 'ced',0    ; ExtCmd 7
                DCB.B 28
                DC.W 0          ; Not in use
                DC.W 2500       ; Max PLST Entries
                DC.B 2,3,4,1    ; Multi Mode Next
                DC.W $0102,$0202,$37,$47,$0304,$0F06,$0C10,$0C20,$0E93,$0A0F
                DC.B 0          ; RAW/IFF Save, 0=RAW, 1=IFF
                DC.B 0          ; IntMode, 0=VBLANK, 1=CIA
                DC.B 0          ; Override
                DC.B 0          ; Nosamples
                DC.B 0          ; BlankZero
                DC.B 1          ; ShowDirs
                DC.B 0          ; CutToBuf
                DC.B 0          ; ShowPublic
                DC.B 1          ; IFFLoop
                DC.B 1          ; HHFlag SLOWMODE
                DC.W 125        ; Tempo
                DC.W 300        ; DMAWait
                DC.W 24         ; TuneNote (C-3)
                DC.W $20        ; TToneVol
                DC.B 0,0,0,0,0,0,0,0 ; (Pad to 512 bytes)
                DC.B "ST-00:"   ; Protracker Path
                DS.B 26
                DC.W 6          ; DefaultSpeed
                DC.W $0F00,$0F00,$0F10,$0F10,$0F20,$0F20,$0F30,$0F30 ; VU-Meter
                DC.W $0F40,$0F50,$0F60,$0F70,$0F80,$0F90,$0FA0,$0FB0 ; colors
                DC.W $0FC0,$0FD0,$0FE0,$0FF0,$0FF0,$0EF0,$0EF0,$0DF0
                DC.W $0DF0,$0CF0,$0CF0,$0BF0,$0BF0,$0AF0,$09F0,$09F0
                DC.W $08F0,$08F0,$07F0,$07F0,$06F0,$06F0,$05F0,$05F0
                DC.W $04F0,$04F0,$03F0,$03F0,$02F0,$01F0,$F0,$E0

                DC.W $0F00,$0F10,$0F20,$0F30,$0F40,$0F50,$0F60,$0F70 ; Analyzer
                DC.W $0F80,$0F90,$0FA0,$0FB0,$0FC0,$0FD0,$0FE0,$0FF0 ; colors
                DC.W $0EF0,$0DF0,$0CF0,$0BF0,$0AF0,$09F0,$08F0,$07F0
                DC.W $06F0,$05F0,$04F0,$03F0,$02F0,$01F0,$F0,$E0
                DC.W $D0,$C0,$B0,$A0,$90,$80,$70,$60
                DS.B 302        ; Pad to 1024 bytes

;---- Graphics Data ----

fontsize        EQU 568
spectrumanasize EQU 808
scopesize       EQU 1814
sureboxsize     EQU 1100
clearboxsize    EQU 1100
formatboxsize   EQU 1412
dirscreensize   EQU 2861
edit1size       EQU 1748
edit2size       EQU 1902
edit3size       EQU 2145
setupscreensize EQU 5468
setup2size      EQU 5074
sampscreensize  EQU 3843
monitorsize     EQU 817
helpscreensize  EQU 900

spectrumanadata:IBYTES 'PAK\PTSPECTR.PAK'
                CNOP 0,2
scopedata:      IBYTES 'PAK\PTSCOPE.PAK'
                CNOP 0,2
sureboxdata:    IBYTES 'RAW\PTSUREBO.RAW'
                CNOP 0,2
clearboxdata:   IBYTES 'RAW\PTCLEARB.RAW'
                CNOP 0,2
;formatboxdata:  IBYTES 'RAW\PTFORMAT.RAW'
;                CNOP 0, 2
dirscreendata:  IBYTES 'STE\FILEREQ.RAW'
                CNOP 0,2
;plstdata:       IBYTES 'PAK\PTPLST.PAK'
;                CNOP 0, 2
edit1data:      IBYTES 'PAK\PTEDIT1.PAK'
                CNOP 0,2
edit2data:      IBYTES 'PAK\PTEDIT2.PAK'
                CNOP 0,2
edit3data:      IBYTES 'PAK\PTEDIT3.PAK'
                CNOP 0,2
setupscreendata:IBYTES 'STE\SETUP1.RAW'
                CNOP 0,2
setup2data:     IBYTES 'STE\SETUP2.RAW'
                CNOP 0,2
;preseteddata:   IBYTES 'STE\PSETED.RAW'
;                CNOP 0, 2
sampscreendata: IBYTES 'STE\SAMPLER.RAW'
                CNOP 0,2
monitordata:    IBYTES 'PAK\PTMONITO.PAK'
                CNOP 0,2
helpscreendata: IBYTES 'PAK\PTHELPSC.PAK'
                CNOP 0,2
volboxdata:     IBYTES 'RAW\PTVOLBOX.RAW'
                CNOP 0,2
toggleondata:   IBYTES 'RAW\PTTOGGON.RAW'
                CNOP 0,2
toggleoffdata:  IBYTES 'RAW\PTTOGOFF.RAW'
                CNOP 0,2
s_boxdata:      IBYTES 'RAW\PTLETTER.RAW'

a_boxdata       EQU s_boxdata+22
t_boxdata       EQU s_boxdata+44
p_boxdata       EQU s_boxdata+66
h_boxdata       EQU s_boxdata+88
c_boxdata       EQU s_boxdata+110


;************************** CHIP DATA HUNK **************************

bitplanedata:   IBYTES 'STE\MAINSCRN.RAW'

ttonedata:                              ; Tuning Tone (Sine Wave)
                DC.B 0,25,49,71,91,106,118,126
                DC.B 127,126,118,106,91,71,49,25
                DC.B 0,-25,-49,-71,-91,-106,-118,-126
                DC.B -127,-126,-118,-106,-91,-71,-49,-25

coplistcolors:
                DC.W $01A2      ; Color 17
                DC.W $0AAA
                DC.W $01A4      ; Color 18
                DC.W $0888
                DC.W $01A6      ; Color 19
                DC.W $0666
                DC.W $01A0      ; Color 16
                DC.W 0
                DC.W $0180      ; Color 0
copcol0:        DC.W 0
                DC.W $0182      ; Color 1
                DC.W $0AAA
                DC.W $0184      ; Color 2
                DC.W $0777
                DC.W $0186      ; Color 3
                DC.W $0444
                DC.W $0188      ; Color 4
                DC.W $0CCC
                DC.W $018A      ; Color 5
                DC.W $0A00
                DC.W $018C      ; Color 6
                DC.W $00
                DC.W $018E      ; Color 7
                DC.W $4D
                DC.W $01AE      ; Color 23
                DC.W $0A00
                DC.W $01AA      ; Color 21
                DC.W $0700
                DC.W $01AC      ; Color 22
                DC.W $0400


notecol:        DC.W $4D

pointerspritedata:
                DC.W 0,0
                DC.W $FFFF,$FFFF,$8002,$FFFE,$BFF4,$C00C,$BFE8,$C018
                DC.W $BFD0,$C030,$BFE8,$C018,$BFF4,$C00C,$BFFA,$C006
                DC.W $BFFD,$C003,$BFFA,$C006,$B7F4,$C80C,$ABE8,$DC18
                DC.W $95D0,$F630,$A2A0,$E360,$C140,$C1C0,$8080,$8080
nospritedata:
                DC.W 0,0,0,0

cursorspritedata:
                DC.W 0,0
                DC.W $FFE0,$FFE0,$FFE0,$FFE0,$8020,$00,$8020,$00
                DC.W $8020,$00,$8020,$00,$8020,$00,$8020,$00
                DC.W $8020,$00,$8020,$00,$8020,$00,$8020,$00
                DC.W $00,$FFE0,$00,$FFE0
                DC.W 0,0
linecurspritedata:
                DC.W 0,270,$00,$FE00,$00,$FE00,$00,$00,0,0
vuspritedata1:
                DC.W $E95B,$EA01
                DC.W $C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0
                DC.W 0,0
vuspritedata2:
                DC.W $E97F,$EA01
                DC.W $C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0
                DC.W 0,0
vuspritedata3:
                DC.W $E9A3,$EA01
                DC.W $C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0
                DC.W 0,0
vuspritedata4:
                DC.W $E9C7,$EA01
                DC.W $C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0,$C0C0,$3FC0
                DC.W 0,0

loopspritedata1:
                DC.W 0,270
                DC.W 0,0
loopspritedata2:
                DC.W 0,270
                DC.W 0,0

playposspritedata:
                DC.W 0,270
                DC.W $8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0,$8000,0
                DC.W 0,0


;******** BSS ********

                BSS

vumetercols:    DS.L 48*3
coplistanalyzer:
                DS.L 64

fileinfoblock:  DS.B 256        ;,0
fib_entrytype   EQU fileinfoblock+4
fib_filename    EQU fileinfoblock+8
fib_filesize    EQU fileinfoblock+124
fib_datestamp   EQU fileinfoblock+132

infodata:       DS.B 36
textdatabuffer: DS.B 546*2
trackbuffer:    DS.B 256
cmdsbuffer:     DS.B 256
blockbuffer:    DS.B 256
patternbuffer:  DS.B 1024
undobuffer:     DS.B 1024

splittranstable:DS.B 38
splitinstrtable:DS.B 38

modulespath2:   DS.B 64
songspath2:     DS.B 64
samplepath2:    DS.B 64

                DS.L 1

setupdata:      DS.B 26
songspath:      DS.B 32
modulespath:    DS.B 32
samplepath:     DS.B 32
printpath:      DS.B 32
colortable:     DS.W 8
packmode:       DS.B 1
modpackmode:    DS.B 1
splitflag:      DS.B 1
filterflag:     DS.B 1
transdelflag:   DS.B 1
showdecflag:    DS.B 1
autodirflag:    DS.B 1
autoexitflag:   DS.B 1
modonlyflag:    DS.B 1
midiflag:       DS.B 1
splitdata:      DS.B 4
                DS.B 4
                DS.B 4
                DS.B 4
keyrepdelay:    DS.W 1
keyrepspeed:    DS.W 1
accidental:     DS.B 1
                DS.B 1
extcommands:    DS.B 32*8       ; 256 bytes
maxdirentries:  DS.W 1
maxplstentries: DS.W 1
multimodenext:  DS.B 4
effectmacros:   DS.W 10
rawiffmode:     DS.B 1
intmode:        DS.B 1
overrideflag:   DS.B 1
nosamplesflag:  DS.B 1
blankzeroflag:  DS.B 1
showdirsflag:   DS.B 1
showpublicflag: DS.B 1
cuttobufflag:   DS.B 1
iffloopflag:    DS.B 1
hhflag:         DS.B 1
tempo:          DS.W 1
dmawait:        DS.W 1
tunenote:       DS.W 1
ttonevol:       DS.W 1
salvageaddress: DS.B 8
ptpath:         DS.B 32         ; 512 bytes
defaultspeed:   DS.W 1
vumetercolors:  DS.W 48
analyzercolors: DS.W 40
                DS.B 302        ; Pad to 1024 bytes

helptextindex:  DS.L 256
helptextdata:   DS.B 656

inpevport:      DS.B 34
inpevioreq:     DS.B 48

scopeinfo:      DS.B 20*4
scopesaminfo:   DS.B 16*31
blanksample:    DS.B 320
filename:       DS.B 96
newfilename:    DS.B 96
samplefilename: DS.B 28
presetnametext: DS.B 22
dirinputname:   DS.B 30
newinputname:   DS.B 30
tempsamparea:   DS.W 380
savecolors:     DS.W 40+48

pattern_mem:    DS.W 70716/2    ; pattern memory

txtbpl:         DS.B (1960*2)+(40*7*64) ; textbpl
                CNOP 0,16
vols:
                DS.W 16640

getgemcurrpath: DS.B 128
gempath:        DS.B 128

circbuf:        DS.B circbufsize

                DS.L 499
my_stack:       DS.L 2
screen:
                DS.B 256*320

spectrumanapos  EQU screen+(45*320)+(7*16)+1

sureboxpos      EQU screen+(52*320)+(80*2)

samscrpos       EQU screen+(122*320)

volboxpos       EQU screen+(155*320)+(4*16)+1

                END
