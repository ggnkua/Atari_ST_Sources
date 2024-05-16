; install music

start	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.b	#1,d7
	
	move.b	d7,tune_number
	
.loop	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	move.w	d7,-(sp)
	bsr	play_music
	move.w	(sp)+,d7
	
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.b	d0
	beq	.loop
	
	cmpi.w	#27,d0
	beq	.exit
	
	cmpi.w	#'z',d0
	bne	.1

	subi.b	#1,d7
	move.b	d7,tune_number
	
.1	cmpi.w	#'x',d0
	bne	.2

	addi.b	#1,d7
	move.b	d7,tune_number
	bra	.loop
	
.2	cmpi.w	#' ',d0
	bne	.loop
	
	move.b	d7,tune_number
	bra	.loop

.exit	bsr	stop_music
	
	clr.w	-(sp)
	trap	#1
	
;Sorry didnt have time to tell about the rest
;i will tell you on thursday

;**************************************************************************
;To use this driver call play_music on vbl
;Move tune number into tune_number (1-???)
;Call stop_music to stop it

;Tune tables have three pointers to three pieces of music



;**************************************************************************

numtunes equ 5

;play_music,init_music,tune_num

stop_music:
 lea     $ff8800,a0
 move.b  #7,(a0)
 move.b  (a0),d0
 and.b   #$c0,d0
 or.b    #$3f,d0
 move.b  #7,(a0)
 move.b  d0,2(a0)
 move.b	#-1,tune_num
 bsr	play_music
 rts

;**************************************************************************
;**************************************************************************

no_tune:
 addq.b  #1,d0
 beq.s   minus1
 rts
minus1
 lea     $ff8800,a0
 move.b  #7,(a0)
 move.b  (a0),d0
 or.b    #$3f,d0
 move.b  #7,(a0)
 move.b  d0,2(a0)
 move.b  #$fe,tune_number
 rts

tune_num
tune_number       dc.b 4,0          ;$ff for to turn tune off
                                    ;tune numbers (1 to 127)
play_music:
 move.b  tune_number(pc),d0
 beq     play_current               ;play the current tune
 bmi.s   no_tune                    ;turn tune off / silent chip
set_up_new_tune
 and.w   #$ff,d0
 cmp.w   #numtunes,d0
 bgt.s   error
 add.w   d0,d0
 add.w   d0,d0                      ;*4
 move.w  d0,d1
 add.w   d0,d1
 add.w   d0,d1                      ;*12
 move.l  tuneaddr-12(pc,d1.w),chan1_pointer  ;-12 bec al 1
 move.l  tuneaddr-08(pc,d1.w),chan2_pointer  ;set three channel pointers
 move.l  tuneaddr-04(pc,d1.w),chan3_pointer
 clr.l   chan1_off                  ;clear level one offsets
 clr.l   chan3_off                  ;and
 clr.l   chan2_sub                  ;clear level two offsets
 clr.b   tune_number
 clr.l   tnote1_len
 clr.w   tnote3_len
 move.w  #15*16,max_vol
 rts

 xdef    max_vol
max_vol  ds.w 1

error:
 moveq   #24,d0
 lea     $ff8240,a0
errolp
 not.w   (a0)
 not.w   (a0)
 not.w   (a0)
 not.w   (a0)
 dbf     d0,errolp
 rts

;**************************************************************************
;**************************************************************************
;**************************************************************************
tuneaddr                            ;tune table (different pieces of music)
 dc.l    chan1,chan2,chan3          ;tune 1
 dc.l    w1,w2,w3			;tune 2
 dc.l    c1,c2,c3			;tune 3
 dc.l    lev21,lev22,lev23		;tune 4
 dc.l    mon1,mon2,mon3		;tune 5
;**************************************************************************
;**************************************************************************
;**************************************************************************

tune_names			;for get about this part carl
 dc.l    one,two,three,four,cinq

one
 dc.b    'Gemini wings Lvl 1',0
two
 dc.b    'Mr Megafuckinwalruseffort',0
three
 dc.b    'Well Done you killed it',0
four
 dc.b    'Level (notsogood) two',0
cinq
 dc.b    'Yet another Motherfuckin big alien',0
 even

chan1_pointer     ds.l 1
chan2_pointer     ds.l 1
chan3_pointer     ds.l 1
chan1_off         ds.w 1
chan2_off         ds.w 1
chan3_off         ds.w 1
chan1_sub         ds.w 1
chan2_sub         ds.w 1
chan3_sub         ds.w 1

note1_len         dc.w 1   ;work from this one
note2_len         dc.w 1
note3_len         dc.w 1
tnote1_len        dc.w 1   ;this dec's
tnote2_len        dc.w 1
tnote3_len        dc.w 1

dum               dc.b -1,0

ntr_poins         ds.l 3
ntr_off           ds.w 3

noise_pitch       ds.w 3
noise_else        ds.w 3
vib_vals          ds.w 3            ;max difference
vib_pos           ds.w 3            ;off pos
vib_adds          ds.w 3            ;vib adder
vib_dels          ds.w 3            ;frame delay counter
vib_delt          ds.w 3            ;this one changes

whitecs           ds.w 3
tabby             dc.l dum,dum,dum
volume1           ds.w 3            ;max volumes
volumeup1         ds.w 3            ;update by envelopes
count1            ds.w 3
env_phase1        ds.w 3            ;what part of env
attack1           ds.w 3            ;attack rate
decay1            ds.w 3            ;decay rate
decay_dest1       ds.w 3            ;decay dest
sustain1          ds.w 3            ;sustain length
releas1           ds.w 3            ;release rate
att_adder1        ds.w 3
dec_adder1        ds.w 3
rel_adder1        ds.w 3

white1            ds.w 3
whitef            ds.w 3

trpointers        ds.w 3            ;trill pointers
troffs            ds.w 3
remeres           ds.w 3

pitch1            ds.w 1
pitch2            ds.w 1
pitch3            ds.w 1

put_notes         ds.w 3

padder            ds.l 3            ;pointed adder
pnotes            ds.l 3            ;pointed note value
delays            ds.w 3            ;amount of frames before start bend
pdest             ds.w 3            ;note dest

rem_tabs          ds.w 3

bend_on           ds.w 3

tempo    dc.w $2  ;speed every thing updates
ttempo   dc.w $2  ;same thing (this one counts down and restored by above)

play_current:
 subq.w  #1,ttempo
 bmi.s   update
 bra     do_rest_of_fx

update
 lea     tnote1_len(pc),a6
 lea     get_it_again(pc),a5
 moveq   #4,d7
new_note_loop
 subq.w  #1,(a6)+
 bmi.s   new_note
back_from_new_note
 subq.w  #2,d7
 bpl.s   new_note_loop

 move.w  tempo(pc),ttempo
; move.w  #$f8,ttempo
 bra     do_rest_of_fx

new_note
 lea     chan1_pointer(pc),a0       ;the three pointers for each channel
 lea     chan1_off(pc),a1           ;level one offsets
 lea     chan1_sub(pc),a2           ;and level two offsets

 move.w  d7,d0
 add.w   d0,d0
 move.l  (a0,d0.w),a0
 adda.w  d7,a1
 adda.w  d7,a2

get_data
 move.w  (a1),d0                    ;get tab pointer (level 1)
 move.l  (a0,d0.w),d0
 bne.s   not_end_of_tune
 clr.w   (a1)                       ;for now reset tab pointers
 clr.w   (a2)
 move.l  (a0),d0
not_end_of_tune
 move.l  d0,a3
get_it_again
 move.w  (a2),d4
 move.b  (a3,d4.w),d0
 cmp.b   #$ff,d0
 bne.s   not_end_of_sub
 addq.w  #4,(a1)
 clr.w   (a2)
 move.w  (a1),d0
 move.l  (a0,d0.w),d0
 bne.s   not_end_of_tune
 clr.w   (a1)                       ;for now reset tab pointers
 clr.w   (a2)
 move.l  (a0),d0
 bra.s   not_end_of_tune
not_end_of_sub
 addq.w  #1,(a2)

 move.b  d0,d1
 and.w   #$f0,d1
 lsr.w   #2,d1
 jmp     jump_tab(pc,d1.w)

jump_tab:
 jmp     must_be_note_pitch(pc)         ;0
 jmp     must_be_note_pitch(pc)         ;1
 jmp     must_be_note_pitch(pc)         ;2
 jmp     must_be_note_pitch(pc)         ;3
 jmp     must_be_note_pitch(pc)         ;4
 jmp     must_be_note_pitch(pc)         ;5
 jmp     must_be_note_pitch(pc)         ;6
 jmp     must_be_note_pitch(pc)         ;7       ;0-7e = set note pitch

 jmp     set_note_length(pc)            ;8
 jmp     set_note_length(pc)            ;9
 jmp     set_note_length(pc)            ;10
 jmp     set_note_length(pc)            ;11
 jmp     set_waveform(pc)               ;12
 jmp     set_waveform(pc)               ;13
 jmp     set_volume(pc)                 ;14

set_speed
 and.w   #$f,d0
 move.w  d0,tempo
 jmp     (a5)
set_volume
 and.w   #$f,d0
 lea     volume1(pc),a4
 move.w  d0,(a4,d7.w)
 jmp     (a5)
set_waveform
 and.w   #$1f,d0
 add.w   d0,d0
 add.w   d0,d0
 lea     volumeup1(pc),a4
 move.l  a5,-(sp)
 move.l  wave_tab(pc,d0.w),a5

 move.w  d7,d6
 add.w   d6,d6

 move.l  a0,-(sp)
 lea     (a4,d7.w),a0
 move.b  (a5)+,noise_else-volumeup1+1(a0)
 ble.s   feet
 clr.w   ntr_off-volumeup1(a0)
 lea     noise_trills-4(pc),a4
 moveq   #0,d0
 move.b  -1(a5),d0
 move.l  (a4,d0.w),ntr_poins-volumeup1(a0)
 lea     volumeup1(pc),a4
feet
 move.l  (sp)+,a0

 move.b  (a5)+,90+1(a4,d7.w)        ;trill control

 move.b  (a5)+,66+1(a4,d7.w)        ;noise control
 move.b  (a5)+,72+1(a4,d7.w)

 move.b  (a5)+,-54+1(a4,d7.w)       ;set vib control
 move.b  (a5)+,-36+1(a4,d7.w)

;fast

 move.l  a5,-18(a4,d6.w)            ;set pointer

 move.l  (sp)+,a5
 jmp     (a5)
;**************************************************************************
;.............................................................
;                 Waveform tables

wave_tab:
 dc.l    vc0,vc1,vc2,vc3,vc4,vc5,vc6,vc7

trill_pointers
 dc.l    0,trl1,trl2,trl3,trl4,trl5

trl1
 dc.w    2,1,0,$8001
trl2
 dc.w    0,$10,-$10,$8000
trl3
 dc.w    0,-$10,$10,$8000
trl4 
 dc.w    -$05,$8002
trl5
 dc.w    $10,1,$00,$8001

noise_trills:
 dc.l    ntr_one

ntr_one  dc.b 1,30,2,25,$80

 even             ;GOT TO HAVE THIS EVEN HERE
;$8000 repeat the trill
;$8001 stop at end of trill
;$8002 add trill


;byte 1  attack adder
;byte 2  attack rate
;byte 3  decay adder
;byte 4  decay rate
;byte 5  decay dest
;byte 6  sustain delay
;byte 7  release adder
;byte 8  release rate
;byte 9  if not 0 then number selects trill
;byte 10 if not 0 then its delay that stays on for
;byte 11 noise frequency


vc0
 dc.b    0 ;0=note 1=noise
 dc.b    2*4                                  ;trill info
 dc.b    0,0                                ;noise info amntfrms,noise freq 0-31 0=high
 dc.b    0,0                               ;vibrato info adder,delay
 dcb.b   15,10
 dcb.b   14,10
 dcb.b   13,10
 dcb.b   12,10
 dcb.b   11,10
 dcb.b   10,10
 dcb.b   9,10
 dcb.b   8,10
 dcb.b   7,10
 dcb.b   6,10
 dcb.b   5,10
 dcb.b   4,10
 dcb.b   3,10
 dcb.b   2,10
 dcb.b   1,10
 dc.b    0,-1    

vc1
 dc.b    0 ;0=note 1=noise
 dc.b    1*4                                   ;trill info
 dc.b    1,20                              ;noise info amntfrms,noise freq 0-31 0=high
 dc.b    2,1
 dcb.b   15,10
 dcb.b   14,10
 dcb.b   13,10
 dcb.b   12,10
 dcb.b   11,10                              ;vibrato info adder,delay
 dcb.b   10,10
 dcb.b   9,10
 dcb.b   8,10
 dcb.b   7,10
 dcb.b   6,10
 dcb.b   5,10
 dcb.b   4,10
 dcb.b   3,10
 dcb.b   2,10
 dcb.b   1,10
 dc.b    0,-1    

vc2
 dc.b    0 ;0=note 1=noise
 dc.b    3*4                                    ;trill info
 dc.b    0,0                                ;noise info amntfrms,noise freq 0-31 0=high
 dc.b    0,0
 dcb.b   15,10
 dcb.b   14,10
 dcb.b   13,10
 dcb.b   12,10
 dcb.b   11,10                               ;vibrato info adder,delay
 dcb.b   10,10
 dcb.b   9,10
 dcb.b   8,10
 dcb.b   7,10
 dcb.b   6,10
 dcb.b   5,10
 dcb.b   4,10
 dcb.b   3,10
 dcb.b   2,10
 dcb.b   1,10
 dc.b    0,-1    

vc3
 dc.b    0
 dc.b    4*4
 dc.b    1,20
 dc.b    0,0
 dc.b    15,15,15,15,15,0,-1

vc4
 dc.b    4
 dc.b    0
 dc.b    0,0
 dc.b    0,0
 dc.b    15,12,9,6,3,0,-1

vc5
 dc.b    0 
 dc.b    0
 dc.b    0,0
 dc.b    0,0
 dcb.b   15,255
 dcb.b   15,255
 dcb.b   15,255
vc6
 dc.b    0 
 dc.b    5*4
 dc.b    0,0
 dc.b    0,0
 dcb.b   15,255
 dcb.b   15,255
 dcb.b   15,255


vc7
 dc.b    0 ;0=note 1=noise
 dc.b    5*4                                    ;trill info
 dc.b    0,0                                ;noise info amntfrms,noise freq 0-31 0=high
 dc.b    2,0
 dcb.b   15,1
 dcb.b   14,10
 dcb.b   13,10
 dcb.b   12,10
 dcb.b   11,10                               ;vibrato info adder,delay
 dcb.b   10,10
 dcb.b   9,10
 dcb.b   8,10
 dcb.b   7,10
 dcb.b   6,10
 dcb.b   5,10
 dcb.b   4,10
 dcb.b   3,10
 dcb.b   2,10
 dcb.b   1,10
 dc.b    0,-1    



 even
;.............................................................
;**************************************************************************
set_note_length
 and.w   #$3f,d0
 move.w  d0,-8(a6)
 jmp     (a5)
set_transpose
 addq.w  #3,(a2)                             ;inc the pointer
 lea     bend_on(pc),a4                      ;set the bend flag
 move.w  #-1,(a4,d7.w)                       ;set trill to minus

 lea     volumeup1(pc),a4                    ;set the env off
 clr.w   6(a4,d7.w)
 move.w  90(a4,d7.w),78(a4,d7.w)
 move.w  66(a4,d7.w),-24(a4,d7.w)
 clr.w   -48(a4,d7.w)
 move.w  #1,-42(a4,d7.w)
 move.w  -36(a4,d7.w),-30(a4,d7.w)

; clr.w   tount

 lea     padder(pc),a4              ;pitch adder
 move.w  d7,d6
 add.w   d6,d6                      ;d6 for longs

 moveq   #0,d0
 move.b  1(a3,d4.w),d0
 move.w  tempo(pc),d1
 addq.w  #1,d1
 mulu    d1,d0
; subq.w  #1,d0
 move.w  d0,24(a4,d7.w)   ;set the delay

 moveq   #0,d0                      ;clear top bits
 moveq   #0,d1
 moveq   #0,d2
 move.b  2(a3,d4.w),d0              ;get source note
 move.b  3(a3,d4.w),d1              ;get dest note

 move.w  -8(a6),d2                  ;get note len
 addq.w  #1,d2
 sub.b   1(a3,d4.w),d2
 move.w  tempo(pc),d3
 addq.w  #1,d3
 mulu    d3,d2
; move.w  -8(a6),d3
; addq.w  #1,d3
; mulu    d3,d2                      ;got new dist

 move.w  -8(a6),-2(a6)              ;set new note length

 move.w  d0,d3
 and.w   #$f,d3
 add.w   d3,d3
 and.w   #$f0,d0
 add.w   d0,d3
 add.w   d0,d3
 move.w  d1,d4
 and.w   #$f,d4
 add.w   d4,d4
 and.w   #$f0,d1
 add.w   d1,d4
 add.w   d1,d4
 clr.w   14(a4,d6.w)                         ;clear the bottom word
 moveq   #1,d5
 move.w  note_tab2-2(pc,d3.w),12(a4,d6.w)     ;set the source note
 move.w  note_tab2-2(pc,d3.w),d0              ;got source freq val
 move.w  note_tab2-2(pc,d4.w),30(a4,d7.w)     ;set the dest note
 move.w  note_tab2-2(pc,d4.w),d1              ;got dest freq val

 sub.w   d0,d1                               ;d-s
 bpl.s   stpo
 subq.w  #1,14(a4,d6.w)
 moveq   #-1,d5
 neg.w   d1
stpo

 ext.l   d1
 divu    d2,d1
 move.w  d1,(a4,d6.w)
 clr.w   d1
 divu    d2,d1
 move.w  d1,2(a4,d6.w)

 tst.w   d5
 bpl.s   stpl
 neg.l   (a4,d6.w)
stpl

 bra     back_from_new_note

;**************************************************************************
;                 Frequency table
note_tab2:                 ;octave 0 note 0 never used
 dc.w    3608,3405,3214,3034,2863,2703,2551,2408,2273,2145,2025,0,0,0,0
 dc.w    1911,1804,1703,1607,1517,1432,1351,1276,1204,1136,1073,1012,0,0,0,0
 dc.w    956,902,851,804,758,716,676,638,602,568,536,506,0,0,0,0
 dc.w    478,451,426,402,379,358,338,319,301,284,268,253,0,0,0,0
 dc.w    239,225,213,201,190,179,169,159,150,142,134,127,0,0,0,0
 dc.w    119,113,106,100,95,89,84,80,75,71,67,63,0,0,0,0
 dc.w    60,56,53,50,47,45,42,40,38,36,34,32,0,0,0,0
 dc.w    30,28,27,25,24,22,21,20,19,18,17,16

;.............................................................
must_be_note_pitch
 cmp.b   #$7f,d0
 beq     set_transpose

 tst.b   d0
 beq     back_from_new_note

 lea     volumeup1(pc),a4
 adda.w  d7,a4
 tst.w   noise_else-volumeup1(a4)
 beq.s   st_pitch
 move.b  d0,noise_pitch-volumeup1+1(a4)
 clr.w   ntr_off-volumeup1(a4)
 bra.s   set_eny

st_pitch
 lea     pitch1(pc),a4
 move.w  d0,d1
 move.w  d1,rem_tabs-pitch1(a4,d7.w)
 and.w   #$f,d1
 add.w   d1,d1
 and.w   #$f0,d0
 add.w   d0,d1
 add.w   d0,d1
 move.w  note_tab-2(pc,d1.w),(a4,d7.w)

set_eny
 lea     volumeup1(pc),a4
 clr.w   6(a4,d7.w)
 clr.w   84(a4,d7.w)
 move.w  90(a4,d7.w),78(a4,d7.w)
 move.w  66(a4,d7.w),-24(a4,d7.w)
 clr.w   -48(a4,d7.w)
 move.w  #1,-42(a4,d7.w)
 move.w  -36(a4,d7.w),-30(a4,d7.w)

 move.w  -8(a6),-2(a6)
 bra     back_from_new_note

;.............................................................
;                 Frequency table
note_tab:                  ;octave 0 note 0 never used
 dc.w    3608,3405,3214,3034,2863,2703,2551,2408,2273,2145,2025,0,0,0,0
 dc.w    1911,1804,1703,1607,1517,1432,1351,1276,1204,1136,1073,1012,0,0,0,0
 dc.w    956,902,851,804,758,716,676,638,602,568,536,506,0,0,0,0
 dc.w    478,451,426,402,379,358,338,319,301,284,268,253,0,0,0,0
 dc.w    239,225,213,201,190,179,169,159,150,142,134,127,0,0,0,0
 dc.w    119,113,106,100,95,89,84,80,75,71,67,63,0,0,0,0
 dc.w    60,56,53,50,47,45,42,40,38,36,34,32,0,0,0,0
 dc.w    30,28,27,25,24,22,21,20,19,18,17,16

;**************************************************************************
chan_cont         ds.w 1
do_rest_of_fx
 lea     $ff8800,a1

 move.b  #7,(a1)
 move.b  (a1),chan_cont
 or.b    #$38,chan_cont         ;no noise
 and.b   #$f8,chan_cont

 lea     volumeup1+4(pc),a0
 lea     tabby+12(pc),a3
 moveq   #2,d7
env_loop
 move.l  -(a3),a2
 move.w  6(a0),d0
 moveq   #0,d1
 move.b  (a2,d0.w),d1
 bmi.s   nend
 addq.w  #1,6(a0)
 bra.s   cunt
nend
 move.b  -1(a2,d0.w),d1
cunt
 cmp.w   -6(a0),d1
 ble.s   no_round
 move.w  -6(a0),d1
no_round
 move.w  d1,(a0)           ;and set volume

env_done
 tst.w   -24(a0)
 beq.s   no_noise

 subq.w  #1,-24(a0)
 move.w  d7,d0
 addq.w  #3,d0
 bclr    d0,chan_cont

 move.b  #6,(a1)           ;set noise pitch
 move.b  72+1(a0),2(a1)

no_noise

 subq.l  #2,a0
 dbf     d7,env_loop

 move.w  max_vol(pc),d0
 lsr.w   #4,d0
 lea     volumeup1+1(pc),a0

 move.b  #8,(a1)
 cmp.b   (a0),d0
 bge.s   mak1
 move.b  d0,(a0)
mak1
 move.b  (a0),2(a1)

 move.b  #9,(a1)
 cmp.b   2(a0),d0
 bge.s   mak2
 move.b  d0,2(a0)
mak2
 move.b  2(a0),2(a1)

 move.b  #$a,(a1)
 cmp.b   4(a0),d0
 bge.s   mak3
 move.b  d0,4(a0)
mak3
 move.b  4(a0),2(a1)

;**************************************************************************
 lea     pitch1(pc),a2
 lea     put_notes(pc),a0
 lea     trpointers(pc),a3
 lea     trill_pointers(pc),a4
 lea     padder(pc),a6
 move.l  (a2)+,(a0)
 move.w  (a2),4(a0)
 moveq   #0,d7
 moveq   #1,d5
 moveq   #0,d6
house                               ;loop here
 tst.w   noise_else-trpointers(a3)
 beq.s   st_min
 bmi.s   no_noise_trill

 move.l  ntr_poins-trpointers(a3),a5
 move.w  ntr_off-trpointers(a3),d0
 move.b  (a5,d0.w),d0
 cmp.b   #$80,d0
 bne.s   nnnn
 clr.w   ntr_off-trpointers(a3)
 move.b  (a5),d0
nnnn
 addq.w  #1,ntr_off-trpointers(a3)

; move.l  d0,-(sp)
; move.w  #160*130,-(sp)
; bsr     hex_show
 add.b   noise_pitch-trpointers+1(a3),d0       ;set noise freq
 move.b  #6,(a1)
 move.b  d0,2(a1)
 bra.s   mean

no_noise_trill
 move.b  #6,(a1)
 move.b  noise_pitch-trpointers+1(a3),2(a1)    ;set noise freq

mean
 bset    d7,chan_cont
 move.w  d7,d0
 addq.w  #3,d0
 bclr    d0,chan_cont

 addq.l  #2,a3
 bra     down_here

st_min
 tst.w   (a3)+
 beq     no_trill

update_trill
 move.w  -2(a3),d0
 move.l  (a4,d0.w),a5               ;got pointer

 move.w  4(a3),d0
 move.w  (a5,d0.w),d1
 cmp.w   #$8002,d1
 bgt     no_soul
 beq.s   from_same
 cmp.w   #$8000,d1
 beq     wrap
 move.w  rem_tabs-trpointers-2(a3),d3
 move.w  -2(a5,d0.w),d1
 bmi.s   qqminu
qqposo
 add.w   d1,d3
 move.w  d3,d1
 and.w   #15,d1
 cmp.w   #12,d1
 blt.s   qqra
 addq.w  #3,d3
 bra.s   qqra
qqminu
 neg.w   d1
 sub.w   d1,d3
 move.w  d3,d1
 and.w   #15,d1
 cmp.w   #12,d1
 blt.s   qqra
 subq.w  #3,d3
qqra
 and.w   #$7f,d3
 move.w  d3,d2
 and.w   #15,d3
 add.w   d3,d3
 and.w   #$f0,d2
 add.w   d2,d3
 add.w   d2,d3

 lea     note_tab-2(pc),a5
 move.w  (a5,d3.w),(a0)
 move.w  (a0),-6(a0)
 clr.w   -2(a3)
 bra     no_trill
from_same
 clr.w   4(a3)
 move.w  rem_tabs-trpointers-2(a3),d3
 move.w  -2(a5,d0.w),d1
 bmi.s   qminu
qposo
 add.w   d1,d3
 move.w  d3,d1
 and.w   #15,d1
 cmp.w   #12,d1
 blt.s   qra
 addq.w  #3,d3
 bra.s   qra
qminu
 neg.w   d1
 sub.w   d1,d3
 move.w  d3,d1
 and.w   #15,d1
 cmp.w   #12,d1
 blt.s   qra
 subq.w  #3,d3
qra
 move.w  d3,rem_tabs-trpointers-2(a3)

 move.w  (a5),d1
 move.w  (a0),-6(a0)
 bra.s   no_soul
wrap
 clr.w   4(a3)
 move.w  (a5),d1
no_soul
 lea     note_tab-2(pc),a5
 move.w  rem_tabs-trpointers-2(a3),d0
 move.w  d1,d2
 bmi.s   minu
poso
 add.w   d1,d0
 move.w  d0,d1
 and.w   #15,d1
 cmp.w   #12,d1
 blt.s   ra
 addq.w  #3,d0
 bra.s   ra
minu
 neg.w   d1
 sub.w   d1,d0
 move.w  d0,d1
 and.w   #15,d1
 cmp.w   #12,d1
 blt.s   ra
 subq.w  #3,d0
ra

 and.w   #$7f,d0
 move.w  d0,d2
 and.w   #15,d0
 add.w   d0,d0
 and.w   #$f0,d2
 add.w   d2,d0
 add.w   d2,d0

 move.w  (a5,d0.w),(a0)

 addq.w  #2,4(a3)

no_trill

 tst.w   bend_on-trpointers-2(a3)
 beq.s   no_bend

update_transpose
 tst.w   delays-trpointers-2(a3)
 beq     nagafetty
 subq.w  #1,delays-trpointers-2(a3)
 bra     no_bend
nagafetty

; addq.w  #1,tount
 move.l  (a6),d0
 add.l   d0,12(a6)
 move.w  pdest-trpointers-2(a3),d1
 tst.l   d0
 bpl.s   go_up
go_down
 cmp.w   12(a6),d1
 blt.s   no_endy
 move.w  d1,12(a6)
 clr.w   bend_on-trpointers-2(a3)
 move.w  12(a6),(a0)
 move.w  (a0),-6(a0)
 bra.s   no_endy

go_up
 cmp.w   12(a6),d1
 bgt.s   no_endy
 move.w  d1,12(a6)
 clr.w   bend_on-trpointers-2(a3)
 move.w  12(a6),(a0)
 move.w  (a0),-6(a0)

no_endy
 move.w  12(a6),(a0)

no_bend
 tst.w   -54-2-(trpointers-volumeup1)(a3)
 beq.s   no_vib
 subq.w  #1,-30-2-(trpointers-volumeup1)(a3)
 bpl.s   not_bot
 move.w  -36-2-(trpointers-volumeup1)(a3),-30-2-(trpointers-volumeup1)(a3)
 move.w  -42-2-(trpointers-volumeup1)(a3),d0
 add.w   d0,-48-2-(trpointers-volumeup1)(a3)
 move.w  -54-2-(trpointers-volumeup1)(a3),d0
 cmp.w   -48-2-(trpointers-volumeup1)(a3),d0
 bne.s    not_top
 neg.w   -42-2-(trpointers-volumeup1)(a3)
not_top
 neg.w   d0
 cmp.w   -48-2-(trpointers-volumeup1)(a3),d0
 bne.s   not_bot
 neg.w   -42-2-(trpointers-volumeup1)(a3)
not_bot

 move.w  -48-2-(trpointers-volumeup1)(a3),d0
 add.w   d0,(a0)
no_vib
 move.b  d5,(a1)                    ;just set freq
 move.b  (a0),2(a1)
 move.b  d6,(a1)
 move.b  1(a0),2(a1)

down_here
 addq.b  #2,d5
 addq.b  #2,d6
 addq.l  #4,a6
 addq.l  #2,a0
 addq.w  #1,d7
 cmp.w   #3,d7
 bne     house

 move.b  #7,(a1)
 move.b  chan_cont,2(a1)          ;turn noise on

 rts

;*************************************************************************
;music tables
even
chan1				;tune number 1, chan one table
 dc.l    set1  			;of subpointers
 dc.l    s0c1
 dc.l    s1c1
 dc.l    s2c1
 dc.l    s4c1
 dc.l    s4c1
 dc.l    s5c1
 dc.l    s6c1,0
chan2                               ;tune number 1, chan two table
 dc.l    set2			;of subpointers
 dc.l    s0c2			;etc (try to work it out)
 dc.l    s1c2
 dc.l    s1c2
 dc.l    s4c2
 dc.l    s4c2
 dc.l    s5c2
 dc.l    s6c2,0
chan3
 dc.l    set3
 dc.l    s0c3
 dc.l    s1c3
 dc.l    s2c3
 dc.l    s4c3
 dc.l    s4c3
 dc.l    s5c3
 dc.l    s6c3,0

w1
 dc.l set1
 dc.l wrus1,0 
w2 
 dc.l set2
 dc.l wrus2,0
w3 
 dc.l set3
 dc.l wrus3,0

c1
 dc.l set1
 dc.l con1,0
c2
 dc.l set2
 dc.l con2,0
c3
 dc.l set3
 dc.l con3,0

lev21
 dc.l set1
 dc.l blnk4,c1c1,c1c1,c2c1,c3c1,0
lev22
 dc.l set2
 dc.l drm,0
lev23
 dc.l set3
 dc.l bass1,bass1,bass2,bass2,bass3,bass4,0

mon1
 dc.l set1
 dc.l m1,0
mon2
 dc.l set2,m2,0
mon3
 dc.l set3,m3,0

;**************************************************************
;**************************************************************
;**************************************************************
;Below is the table of control bytes
;High nibble determines what the byte is
;$f=set tempo low nibble sets the tempo (delay in frames)
;$e=set volume set volume for apropriate channels low nibble
;$c0-$df=what waveform to use
;$80-$bf=low nibbles sets note length for apropriate channel
;	(delay inbetween updating notes=tempo*note_len (in frames))
;$00-$7e=high nibble=octave
;	low nibble=note
;$7f transpose inbetween two notes

;byte 1  $80-?? first set desired note length 
;byte 2  $7f
;byte 3  the delay before starting transpose	(delay*tempo=am*frames)
;byte 4  source note	(normal note format)
;byte 5  dest note

;**************************************************************
;**************************************************************
;**************************************************************
wrus1
 dc.b $f5
 dc.b $c6,$ef,$80,$42,$39,$35,$42,$39,$35,$42,$39
 dc.b $80,$42,$39,$35,$42,$39,$35,$42,$39
 dc.b $40,$37,$34,$40,$37,$34,$40,$37
 dc.b $40,$37,$34,$40,$37,$34,$40,$37
 dc.b $80,$42,$39,$35,$42,$39,$35,$42,$39
 dc.b $80,$42,$39,$35,$42,$39,$35,$42,$39
 dc.b $40,$37,$34,$40,$37,$34,$40,$37
 dc.b $40,$37,$34,$40,$37,$34,$40,$37
 dc.b $42,$3a,$35,$42,$3a,$35,$42,$3a,$44,$40,$37,$44,$40,$37,$44,$40
 dc.b $42,$39,$35,$42,$39,$35,$42,$39
 dc.b $40,$37,$34,$40,$37,$34,$40,$37,$ff
wrus2
 dc.b $c3,$81,$30,$c4,$02,$c3,$30,$c4,$02,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$c3,$30
 dc.b $c3,$81,$30,$c4,$02,$c3,$30,$c4,$02,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$c3,$30
 dc.b $c3,$81,$30,$c4,$02,$c3,$30,$c4,$02,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$c3,$30
 dc.b $c3,$81,$30,$c4,$02,$c3,$30,$c4,$02,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$c3,$30
 dc.b $81,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$c3,$30
 dc.b $81,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$c3,$30
 dc.b $81,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$c3,$30
 dc.b $81,$c3,$30,$80,$c4,$02,$c3,$81,$30,$80,$30,$c4,$02,$02,$ff
wrus3
 dc.b $c1,$81,$22,$22,$22,$22,$22,$80,$22,$22,$81,$20,$22
 dc.b $c1,$81,$20,$20,$20,$20,$20,$80,$20,$20,$81,$1a,$20
 dc.b $c1,$81,$22,$22,$22,$22,$22,$80,$22,$22,$81,$20,$22
 dc.b $c1,$81,$20,$20,$20,$20,$20,$80,$20,$20,$81,$1a,$20
 dc.b $81,$1a,$1a,$1a,$1a,$20,$20,$20,$80,$20,$21,$81,$22,$22,$22,$80,$22,$21,$81,$20,$20,$20,$80
 dc.b $20,$21,$ff
con1
 dc.b $87,$4b,$4a,$81,$4b,$4a,$87,$48,$81,$4b,$4a,$4b,$4a,$8b,$48,$87,$48,$83,$46,$81,$4b,$4a,$4b
 dc.b $bd,$51,$ff
con2
 dc.b $87,$46,$46,$81,$46,$46,$87,$45,$81,$46,$46,$46,$46,$8b,$45,$87,$43,$83,$43,$81,$46,$46,$46
 dc.b $bd,$48,$ff
con3
 dc.b $c1,$81,$21,$21,$82,$21,$81,$21,$21,$80,$21,$81,$18,$21
 dc.b $c1,$81,$21,$21,$82,$21,$81,$21,$21,$80,$21,$81,$18,$21
 dc.b $c1,$81,$21,$21,$82,$21,$81,$21,$21,$80,$21,$81,$18,$21
 dc.b $c1,$81,$1b,$1b,$82,$1b,$81,$1b,$1b,$80,$1b,$81,$16,$1b
 dc.b $c1,$81,$21,$21,$82,$21,$81,$21,$21,$80,$21,$81,$18,$21
 dc.b $af,$7f,16,$21,$01,$ff
blnk4
 dc.b $f6,$bf,$e0,$20,$ff
drm
 dc.b $c3,$81,$30,$c4,$80,$02,$02,$83,$02,$81,$c3,$30,$80,$c4,$02,$02,$81,$02,$02,$ff
bass1
 dc.b $c1,$82,$10,$17,$83,$20,$81,$10,$17,$20,$82,$10,$17,$85,$20,$80,$22,$20,$1b,$20,$ff
c1c1
 dc.b $c7,$ef,$85,$40,$81,$39,$80,$40,$81,$39,$40,$45,$80,$42,$86,$44,$80,$40,$47,$81,$44,$40,$3b,$80
 dc.b $42,$85,$3a,$81,$39,$80,$3a,$82,$42,$81,$3a,$39,$87,$35,$83,$37,$3a,$ff
bass2
 dc.b $82,$15,$80,$25,$83,$25,$81,$15,$80,$25,$25,$81,$20,$15,$82,$10,$80,$20,$83,$20,$83,$20,$1b
 dc.b $82,$1a,$80,$2a,$83,$2a,$81,$1a,$2a,$1a,$22,$82,$21,$80,$28,$83,$28,$82,$27,$23,$81,$1a,$ff
c2c1
 dc.b $85,$40,$81,$39,$80,$40,$81,$39,$40,$82,$45,$85,$43,$81,$3a,$80,$43,$81,$3a,$82,$43,$81,$4a
 dc.b $85,$48,$80,$48,$47,$81,$48,$47,$45,$47,$87,$45,$44,$85,$45,$81,$40,$80,$45,$82,$40,$81,$38
 dc.b $37,$81,$35,$37,$38,$80,$37,$88,$35,$82,$38,$37,$81,$38,$82,$3a,$38,$81,$37
 dc.b   $80,$3a,$38,$37,$3a,$38,$37,$3a,$38,$3a,$38,$37,$3a,$38,$37,$3a,$38,$85
 dc.b   $37,$81,$35,$8f,$35,$83,$38,$3a,$85,$38,$81,$31,$87,$31,$41,$40,$ff
bass3
 dc.b   $82,$15,$80,$25,$83,$25,$81,$15,$80,$25,$25,$81,$20,$15
 dc.b   $82,$13,$80,$23,$83,$23,$81,$13,$80,$23,$23,$81,$1a,$13
 dc.b   $82,$11,$80,$21,$83,$21,$81,$11,$80,$21,$21,$81,$18,$11
 dc.b   $82,$10,$17,$83,$20,$81,$10,$17,$20,$82,$15,$20,$83,$25,$81,$15,$20,$25
 dc.b   $82,$13,$1a,$83,$23,$81,$13,$1a,$23,$82,$11,$18,$83,$21,$81,$11,$18,$21
 dc.b   $82,$10,$17,$83,$20,$81,$10,$17,$20,$85,$15,$81,$15,$85,$15,$80,$15,$15
 dc.b   $85,$13,$81,$13,$83,$13,$81,$13,$23,$85,$11,$81,$11,$85,$11,$81,$11
 dc.b   $80,$10,$17,$27,$10,$17,$20,$10,$17,$10,$17,$20,$10,$17,$20,$10,$17,$ff
c3c1
 dc.b   $87,$40,$38,$37,$38,$3a,$83,$41,$3a,$85,$38,$80,$38,$37,$83,$34,$37,$87,$37
 dc.b   $83,$35,$81,$37,$38,$87,$37,$33,$82,$38,$37,$81,$38,$82,$3a,$38,$81,$37,$87
 dc.b   $40,$44,$bf,$45,$ff
bass4
 dc.b   $82,$15,$80,$25,$83,$25,$80,$25,$15,$15,$25,$15,$15,$25,$15,$82,$13,$80
 dc.b   $23,$83,$23,$80,$23,$13,$13,$23,$13,$13,$23,$13,$82,$11,$80,$21,$83,$21
 dc.b   $80,$21,$11,$11,$21,$11,$11,$21,$11,$20,$10,$10,$20,$10,$10,$81,$20,$80
 dc.b   $20,$10,$10,$20,$10,$10,$81,$20,$82,$15,$80,$25,$83,$25,$81,$15,$80,$25
 dc.b   $25,$81,$20,$15,$82,$13,$80,$23,$83,$23,$81,$13,$80,$23,$23,$81,$1a,$13
 dc.b   $82,$11,$80,$21,$83,$21,$81,$11,$80,$21,$21,$81,$18,$11,$82,$10,$80,$20
 dc.b   $83,$20,$80,$20,$10,$10,$20,$10,$10,$20,$10,$bf,$15,$ff
m1
 dc.b   $c7,$f8,$83,$42,$45,$43,$46,$8f,$47,$ff
m2
 dc.b   $c7,$83,$39,$40,$3a,$41,$8f,$42,$ff
m3
 dc.b   $c7,$83,$22,$25,$23,$26,$8f,$27,$ff

 dc.b   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 dc.b   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 dc.b   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 dc.b   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


set1
 dc.b    $ef,$f4,$c0,$85,$ff
set2 
 dc.b    $ef,$c0,$85,$ff
set3 
 dc.b    $ef,$c1,$81,$ff

s0c1
 dc.b   $40,$89,$42,$85,$43,$89,$45,$ff
s0c2
 dc.b   $37,$89,$39,$85,$3a,$89,$40,$ff
s0c3
 dc.b   $20,$20,$20,$22,$22,$22,$22,$22,$23,$23,$23,$25,$25,$25,$22,$20,$ff
s1c1
 dc.b   $ef
 dc.b   $c2,$85,$45,$81,$44,$87,$44,$83,$37,$40,$47,$45,$85,$44,$81,$42,$8f,$42
 dc.b   $83,$45,$44,$85,$42,$81,$40,$87,$40,$83,$39,$40,$42,$44,$85,$42,$81,$37,$97,$37,$ff
s1c2
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$83,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10,$ff


s1c3
 dc.b   $ef,$c1
 dc.b   $20,$20,$20,$20,$20,$20,$20,$20
 dc.b   $20,$20,$20,$20,$20,$20,$20,$20
 dc.b   $1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a
 dc.b   $1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a
 dc.b   $15,$15,$15,$15,$15,$15,$15,$15
 dc.b   $15,$15,$15,$15,$15,$15,$15,$15
 dc.b   $17,$17,$17,$17,$17,$17,$17,$17
 dc.b   $17,$17,$17,$17,$17,$18,$19,$1a,$ff
s2c1
 dc.b   $c2,$85,$45,$81,$44,$87,$44,$83,$37,$40,$47,$49,$85,$4a,$80,$49,$4a,$85
 dc.b   $49,$80,$47,$49,$85,$47,$80,$45,$47,$83,$45,$81,$44,$42,$85,$44,$81,$40
 dc.b   $89,$40,$81,$45,$44,$42,$44,$42,$40,$44,$85,$47,$80,$47,$48,$85,$49,$80
 dc.b   $49,$47,$83,$4b,$50,$87,$52,$ff                                        
s2c3
 dc.b   $c1,$81,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
 dc.b   $1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a
 dc.b   $15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15
 dc.b   $17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$19,$1b,$22,$ff
s4c1
 dc.b   $c2,$81,$35,$35,$85,$34,$81,$35,$35,$83,$34,$81,$45,$44,$42,$40,$83,$42
 dc.b   $81,$3b,$81,$35,$35,$85,$34,$81,$35,$35,$83,$34,$81,$45,$44,$42,$40,$83
 dc.b   $42,$81,$3b,$35,$35,$85,$34,$81,$35,$35,$83,$34,$81,$45,$44,$42,$40,$83,$42
 dc.b   $81,$3b,$87,$40,$3b,$39,$37,$ff     
s4c2
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$80,$c4,10,10,10,10
 dc.b   $c3,$83,$30,$30,$30,$30,$81,$30,$30,$30,$30,$80,$32,$31,$30,$32,$31,$30
 dc.b   $32,$31,$ff               
s4c3
 dc.b   $c1,$81,$20,$20,$17,$20,$20,$20,$80,$17,$20,$17,$20
 dc.b   $81,$20,$20,$17,$20,$20,$20,$80,$17,$20,$17,$20

 dc.b   $81,$1a,$1a,$15,$1a,$1a,$1a,$80,$15,$1a,$15,$1a 
 dc.b   $81,$1a,$1a,$15,$1a,$1a,$1a,$80,$15,$1a,$15,$1a 

 dc.b   $81,$15,$15,$10,$15,$15,$15,$80,$10,$15,$10,$15
 dc.b   $81,$15,$15,$10,$15,$15,$15,$80,$10,$15,$10,$15

 dc.b   $81,$17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$17,$18,$19,$1a,$ff
s5c1
 dc.b   $83,$e0,$20,$ef,$83,$39,$81,$34,$8b,$39,$81,$39,$34,$85,$39,$83,$3b,$81
 dc.b   $37,$87,$37,$80,$32,$34,$83,$35,$34,$32,$87,$34,$83,$39,$81,$34,$8b,$39
 dc.b   $81,$39,$34,$85,$34,$87,$3b,$40,$83,$42,$32,$34,$32,$ff
s5c2
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10,$ff
s5c3
 dc.b   $c1,$81,$19,$19,$19,$19,$19,$80,$19,$19,$29,$19,$81,$29
 dc.b   $81,$19,$19,$19,$19,$19,$80,$19,$19,$29,$19,$81,$29

 dc.b   $81,$17,$17,$17,$17,$17,$80,$17,$17,$27,$17,$81,$27
 dc.b   $81,$17,$17,$17,$17,$17,$80,$17,$17,$27,$17,$81,$27
 dc.b   $c1,$81,$19,$19,$19,$19,$19,$80,$19,$19,$29,$19,$81,$29
 dc.b   $81,$19,$19,$19,$19,$19,$80,$19,$19,$29,$19,$81,$29
 dc.b   $81,$17,$17,$17,$17,$17,$80,$17,$17,$27,$17,$81,$27
 dc.b   $81,$17,$17,$17,$17,$17,$80,$17,$17,$27,$17,$81,$27,$ff
s6c1
 dc.b   $c2,$81,$35,$30,$35,$37,$39,$37,$35,$37,$83,$3b,$80,$39,$3b,$39,$88,$37
 dc.b   $81,$39,$35,$39,$3b,$40,$3b,$40,$42,$83,$45,$80,$44,$45,$44,$88,$42,$c5,$af
 dc.b   $7f,0,$30,$47,$82,$47,$42,$81,$3b,$82,$42,$3b,$81,$37,$c2   
 dc.b   $81,$47,$47,$85,$45,$81,$47,$47,$87,$45,$81,$47,$47,$47,$83,$45,$81,$47
 dc.b   $47,$85,$45,$81,$47,$47,$a1,$45,$ff
s6c2
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10

 dc.b   $c3,$81,$30,$30,$85,$30,$81,$30,$30,$87,$30,$81,$30,$30,$30,$83,$30,$81
 dc.b   $30,$30,$85,$30,$81,$30,$30,$30
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$83,$c4,10
 dc.b   $ef,$c3,$81,$30,$30,$c4,$83,10,$c3,$81,$30,$30,$81,$c4,10,$80,10,10,$ff
s6c3
 dc.b   $c1,$81,$15,$15,$15,$15,$15,$15,$15,$15,$17,$17,$17,$17,$17,$17,$17,$17
 dc.b   $15,$15,$15,$15,$15,$15,$15,$15,$17,$17,$17,$17,$17,$17,$17,$17
 dc.b   $15,$15,$15,$15,$15,$15,$15,$15,$17,$17,$17,$17,$17,$17,$17,$17
 dc.b   $15,$15,$15,$15,$15,$15,$15,$15,$17,$17,$17,$17,$17,$17,$17,$17

 dc.b   $81,$17,$17,$85,$15,$81,$17,$17,$87,$15,$81,$17,$17,$17,$83,$15,$81,$17
 dc.b   $17,$85,$15,$81,$17,$17,$a1,$15,$ff

 dc.b   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00



 even

