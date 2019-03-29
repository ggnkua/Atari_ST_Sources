; Coded by the AB Crew, code by JD, grafix by Lemmy and musix by ????
; Hint, press space to change the musix
; Free code, do what you want with it!

BUFFER_SIZE:equ48*44
SPEED:equ2
go:
move.lsp,A5
move.l#save_stk,sp
move.l4(A5),A5;get basepage
move.l$C(A5),D0;text segment
add.l$14(A5),D0;data segment
add.l$1C(A5),D0;unitialized
add.l#$100,D0;basepage size
move.lD0,-(sp)
move.lA5,-(sp)
move.wd0,-(sp)
move.w#$4A,-(sp)
trap#1
add.l#12,sp;okay that's it memory free & allocated

bsrsuper_mode
bsrhide_cursor
bsrget_scr_base
bsrsave_palette
bsrlow_res
bsrset_palette
or.b#$2,$ff820a;go into 50Hz

wait_for_drive:
tst.w$43e
bne.swait_for_drive

move.w#$2700,sr
; Store original vector slots
move.l$120,hbc;horiz blank counter timing vector
move.l$70,v_blank
move.b$FFFa09,a09
move.b$FFFa07,a07
move.b$FFFa13,a13
and.b#$DF,$FFFA09
and.b#$FE,$FFFA07
move.l#isr1,$120
move.l#isr2,$70
or.b#1,$FFFA07;EI
or.b#1,$FFFA13;EI
move.w#$2300,sr

clr.l$24
;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION disc 85
; 1=AUTOMATION disc 80
; 2=Jingle
move.l#0,D0
jsrTUNE

bsrsetup_screen
bsrreset_buffer
main_loop:
bsrvsync
;move.w#$123,$ff8240
move.w#$060,$ff8242
bsrshow_buffer
bsrreset_buffer
bsrscroll
;clr.w$ff8240
bsrcheck_key
beq.smain_loop

move.w#$ff,-(sp)
move.w#6,-(sp)
trap#1
addq.l#4,sp
tst.ld0
beq.smain_loop

cmp.b#$30,d0;0 key
bne.snot_zero
eor.b#$2,$ff820a
bra.smain_loop
not_zero:
cmp.b#$20,d0;space key
beqtoggle_tune
cmp.b#$1b,d0;ESCape key
beqex
cmp.b#$31,d0;1 key
blt.smain_loop
cmp.b#$37,d0;7 key
bge.smain_loop
bsrisr_off

;a valid key has been pressed so clear screen and palette.
bp:move.ld0,-(sp)
bsrcls
move.l(sp)+,d0
sub.w#49,d0
and.l#$ffff,d0
mulu#14,d0
move.lscreen_base,a0
add.w#199*160,a0
leafilenames,a1
add.wd0,a1
move.l(a1)+,(a0)+
move.l(a1)+,(a0)+
move.l(a1)+,(a0)+
move.l(a1)+,(a0)+
clr.w-(sp)
trap#1
addq.l#2,sp

ex:
bsrisr_off
bsrmed_res
bsrrestore_palette
bsrshow_cursor
bsruser_mode
move.w#0,-(sp)
trap#1
addq.l#2,sp


toggle_tune:
eor.w#1,tune_no
move.wtune_no,d0
jsrTUNE
bramain_loop

***************
* Subroutines *
***************
isr_off:
move.w#$2700,sr
move.lv_blank,$70
and.b#$DF,$FFFA09
and.b#$FE,$FFFA07
move.lhbc,$120
move.ba07,$FFFa07
move.ba09,$FFFa09
move.ba13,$fffa13
move.w#$2300,sr
lea$ff8800,a0
move.l#$8080000,(a0)
move.l#$9090000,(a0)
move.l#$a0a0000,(a0)
rts

scroll:
leabuffer,a0
move.la0,a3
move.lline_ptr,a1
leaoffset_table,a2
move.woffset_ptr,temp_offset
moveq#20,d0
loop1:sub.ld2,d2
move.wtemp_offset,d2
move.la3,a0
add.w0(a2,d2),a0
moveq#0,d6
move.b(a1)+,d6
sub.b#32,d6
lsl.w#5,d6
leafont,a6
add.ld6,a6
moveq#3,d7
loop2:move.wshift_size,d1
sub.ld2,d2
move.ld2,d3
move.ld2,d4
move.ld2,d5
move.w (a6)+,d2
move.w (a6)+,d3
move.w (a6)+,d4
move.w (a6)+,d5
lsl.ld1,d2
lsl.ld1,d3
lsl.ld1,d4
lsl.ld1,d5
move.l(a0),d1; Write d2.
or.ld2,d1
move.ld1,(a0)
move.l44(a0),d1; Write d3.
or.ld3,d1
move.ld1,44(a0)
move.l88(a0),d1; Write d4.
or.ld4,d1
move.ld1,88(a0)
move.l132(a0),d1; Write d5.
or.ld5,d1
move.ld1,132(a0)
add.w#176,a0
dbfd7,loop2
addq.w#2,a3
move.wtemp_offset,d2
addq.w#2,d2
cmp.w#38*2,d2
bne.sloop6
moveq#0,d2
loop6:move.wd2,temp_offset
dbfd0,loop1
add.w#SPEED,shift_size
cmp.w#16,shift_size
bne.sloop3
move.w#0,shift_size
add.l#1,line_ptr
cmp.l#end_line-22,line_ptr
bne.sloop3
move.l#scroll_line,line_ptr
loop3:subq.w#2,offset_ptr
bpl.sloop4
move.w#37*2,offset_ptr
loop4:move.lback_pattern,d0
lsr.l#1,d0
bcc.sloop5
bset#31,d0
loop5:move.ld0,back_pattern
rts


show_buffer:
move.lscreen_base,a0
add.w#$5f00,a0
move.l#buffer+2,a1
moveq#47,d0
sho_buff_loop:
movem.w(a1)+,d2-d6/a2-a6
move.wd2,(a0)
move.wd3,8(a0)
move.wd4,16(a0)
move.wd5,24(a0)
move.wd6,32(a0)
move.wa2,40(a0)
move.wa3,48(a0)
move.wa4,56(a0)
move.wa5,64(a0)
move.wa6,72(a0)
movem.w(a1)+,d2-d6/a2-a6
move.wd2,80(a0)
move.wd3,88(a0)
move.wd4,96(a0)
move.wd5,104(a0)
move.wd6,112(a0)
move.wa2,120(a0)
move.wa3,128(a0)
move.wa4,136(a0)
move.wa5,144(a0)
move.wa6,152(a0)
add.w#160,a0
addq.w#4,a1
dbfd0,sho_buff_loop
rts


reset_buffer:
leabuffer,a0
move.lback_pattern,d2
move.ld2,d3
move.ld2,d4
move.ld2,d5
move.ld2,a2
move.ld2,a3
move.ld2,a4
move.ld2,a5
move.w#BUFFER_SIZE/64-1,d0
wipe:movem.ld2-d5/a2-a5,(a0)
add.w#32,a0
movem.ld2-d5/a2-a5,(a0)
add.w#32,a0
dbfd0,wipe
rts

vsync:move.w#1,vsync_flag
vsyn:tst.wvsync_flag
bne.svsyn
rts

check_key:
move.w#11,-(sp)
trap#1
addq.w#2,sp
tst.wd0
rts

setup_screen:
move.lscreen_base,a1
leapic+34,a0
move.w#32000/4-1,d0
setup:move.l(a0)+,(a1)+
dbfd0,setup
rts

wait_for_key:
move.w#7,-(sp)
trap#1
addq.w#2,sp
rts

get_scr_base:
move.w#3,-(sp)
trap#14
addq.w#2,sp
move.ld0,screen_base
rts

super_mode:
clr.l-(sp)
move.w#32,-(sp)
trap#1
addq.w#6,sp
move.ld0,save_stk
rts

user_mode:
move.lsave_stk,-(sp)
move.w#32,-(sp)
trap#1
addq.w#6,sp
rts

save_palette:
lea$ff8240,a0
leaold_palette,a1
bra.schange_palette

restore_palette:
leaold_palette,a0
lea$ff8240,a1
bra.schange_palette

set_palette:
leapic+2,a0
lea$ff8240,a1

change_palette:
moveq#15,d0
change_pal:
move.w(a0)+,(a1)+
dbfd0,change_pal
rts

low_res:
clr.wd0
bra.schange_res

med_res:
moveq#1,d0
change_res:
move.wd0,-(sp)
move.l#-1,-(sp)
move.l#-1,-(sp)
move.w#5,-(sp)
trap#14
add.w#12,sp
rts

hide_cursor:
move.w#-1,-(sp)
move.w#0,-(sp)
move.w#21,-(sp)
trap#14
addq.w#6,sp
peadi_mouse
move.w#$2-1,-(sp)
move.w#$19,-(sp)
trap#14
addq.l#8,sp
rts

show_cursor:
peaei_mouse
move.w#$2-1,-(sp)
move.w#$19,-(sp)
trap#14
addq.l#8,sp
rts

isr1:
add.w#1,line_count
cmp.w#151,line_count
bgt.salt_isr1
bclr#0,$fffa0f;EI
rte
alt_isr1:
move.la0,-(sp)
move.lisr_data,a0
move.w(a0)+,$ff8242
move.la0,isr_data
move.l(sp)+,A0
move.b#0,$FFFA1B
move.b#1,$FFFa21;1 line of each colour.....
move.b#8,$FFFA1B;HBC timer
bclr#0,$FFFA0F;EI
rte

isr2:;$70
move.la0,-(sp)
leaisr_data,a0
move.l#b_line,(a0)
move.l(sp)+,a0
clr.wline_count
jsrTUNE+$e

bsr.sVU
tst.wvsync_flag
beq.sflag_notset
sub.w#1,vsync_flag
flag_notset:
move.b#0,$FFFA1B;reset timer B
move.b#1,$FFFA21
move.b#8,$FFFA1B
rte

; ISR to animate the VU METER
VU:movem.ld3-d7/a4-a6,-(sp)
move.b#$8,$ff8800;chan A
move.b$ff8800,d7
move.lscreen_base,a6;screen always in A6
add.w#104,a6
bsr.sMETER
move.b#$9,$ff8800;chan B
move.b$ff8800,d7
add.w#16,a6
bsr.sMETER
move.b#$a,$ff8800;chan C
move.b$ff8800,d7
add.w#16,a6
bsr.sMETER
movem.l(sp)+,d3-d7/a4-a6
rts
;This part fills the VU meter with lines then clears the lines
;from top to bottom depending on the volume level of the sound channel.
METER:tst.bd7
blt.sexisr;less than no volume!
and.w#$FF,d7
move.la6,a4;screen base
;----------------------FILL VU METER WITH GREEN---------------
add.l#160*85+8,a4;bottom of VU meter
move.w#13-1,d3
FILL:or.w#$3ffc,(a4);fill the VU meter
or.w#$3ffc,320(a4)
sub.w#640,a4
dbrad3,FILL
;-------------------------------------------------------------
move.wd7,d5;invert chan amp by SUB from max volume.
move.w#15,d6
sub.wd5,d6
move.wa6,a4;put screen addr into a4
add.w#160*85+8,a4;make a4 point to bottom of VU
move.la6,a5;get screen start.
add.l#160*29+8,a5;top of VU meter.
cmp.w#1,d6;is second to top ready to be filled
beq.snot_top
blt.sfill_top
and.l#$80018001,(a5)
and.l#$80018001,320(a5)
and.l#$80018001,640(a5)
and.l#$80018001,960(a5)
subq.w#1,d6
;----------------------CLEAR VU METER FROM TOP----------------
CLEAR:and.w#$8001,(a5)
and.w#$8001,320(a5)
add.w#640,a5
dbrad6,CLEAR
exisr:rts
;----------------------TOP IS ACTIVE SO MAKE RED--------------
fill_top:
or.w#$3FFc,2(a5);fill with red
or.w#$3FFc,322(a5);fill with red
not_top:
or.w#$3FFc,642(a5);fill with red
or.w#$3FFc,962(a5);fill with red
rts
cls:peacls_mess
move.w#9,-(sp)
trap#1
addq.l#6,sp
rts
cls_mess:
dc.b27,'E',0,0

********
* Data *
********
back_pattern:
dc.l$01800180

temp_offset:
dc.w0

offset_ptr:
dc.w0

offset_table:
dc.w1408,1276,1144,1056,924,836,704,616
dc.w528,440,352,264,220,132,88,44
dc.w0,0,0,0,0,0,0,44
dc.w88,132,220,264,352,440,528,616
dc.w704,836,924,1056,1144,1276

shift_size:
dc.w0
di_mouse:
dc.b$12,$1a
even
ei_mouse:
dc.b$14,$08
even
hbc:dc.l0
v_blank:dc.l0
a09:dc.l0
a07:dc.l0
a13:dc.l0
even
tune_no:
dc.w0
vsync_flag:
dc.w0
line_count:
dc.w0;count of horizontal line down screen for ISR1
isr_data:
dc.l0
b_line:
DC.W$070,$170,$270
dc.w$370,$470,$570,$670,$770,$760,$750,$740
dc.w$730,$720,$710,$700,$701,$702,$703,$704
dc.w$705,$706,$707,$607,$507,$407,$307,$207
dc.w$107,$007,$017,$027,$037,$047,$057,$067
dc.w$077,$076,$075,$074,$073,$072,$071,$070
dc.w$060,$050,$040,$030,$020
even
old_palette:
ds.b32

buffer:
ds.wBUFFER_SIZE

screen_base:
dc.l0

ds.l100
save_stk:
dc.l0
even
line_ptr:dc.lscroll_line
scroll_line:
 dc.b "   WELCOME TO THE VERY FIRST ISSUE OF THE B.O.S. DISKMAG    "
 dc.b "             THIS IS A RE-WORKED AND RE-RELEASED ISSUE, AS "
 DC.B "I HAD RELEASED IT EARLIER IN JUNE, BUT IT WAS BASICALLY CRAP"
 dc.b " SO I HAD TO RE-CODE THE INTRO AND MENUS TO MAKE IT LOOK PRESENTABLE"
 dc.b " AND SOME OF THE ARTICLES WERE ADDED TO AND UPDATED.       "
 dc.b "                  THIS IS JD AT THE KEYBOARD INTRODUCING A FIRST FOR "
 dc.b "THE AB CREW, A PIECE OF CODE IN ASSEMBLER.      AS YOU CAN SEE IT BEATS"
 dc.b " THE PANTS OFF STOS, BUT IT TOOK ABOUT FOUR TIMES AS LONG AS IT WOULD"
 DC.B " HAVE TAKEN TO CODE A STOS INTRO                    "
 DC.B "   WELL, CHECK OUT THIS ISSUE, THERE ARE ABOUT SEVENTY ARTICLES ABOUT"
 dc.b " ANYTHING REALLY, SO HIT ONE TO LOAD UP THE MAIN MENU           "
 DC.B "         THE AB CREW STANDS FOR ABSOLUTELY BRILLIANT CREW  "
 dc.b "        MEMBES ARE       JD - CODING AND GRAFIX          LEMMY - GRAFIX "
 dc.b "        AND TAP - MUSIX                  "
 dc.b "   HIT THE SPACE BAR TO TOGGLE THE MUSIX             "
 dc.b "MUSIX RIPPED FROM ZOMBI BY MAC SYS DATA          THANX!        "
 DC.B "       WELL, IT'S TIME TO GET THOSE PRESENTS OUT AND DO SOME WRAPPING
            "
end_line:
even
pic:incbin"intro.pi1"
even
fontdc.w0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
set:incbin"big_set.img"
EVEN
TUNEincbin"was85i.img"
even

filenames:
