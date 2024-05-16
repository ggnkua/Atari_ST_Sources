;Listing

;68000 Syntesizer
;for the K-SEKA Assembler
;
;Written by Mad Max from TEX
;
;update :09.06.88

geschwindigkeit=3       ;Speed
;---------------------------------------------
;initializes the program
;---------------------------------------------
init:
move.w  #geschwindigkeit,speed
move.w  speed,speed+2
move.w  #1,sy           ;stop synti
moveq   #2,d0           ;3 voices (dbf-counter)
lea     stimme1(pc),a0  ;voice 1 start
lea     stimme2,a1      ;voice 2 start
move.l  a1,a2           ;mark again
sub.l   a0,a2           ;voice 2 minus voice 1
move.l  a2,d1           ;a2 -> lenght
lea     pointer(pc),a1  ;pointer to three longword that point to the
                        ;three sequence tables
initloop:               ;
moveq   #1,d3           ;offset
clr.l   4(a0)           ;
move.l  (A1),(a0)       ;mark address
clr.l   $8(a0)          ;clears speeds and stuff
clr.l   $c(a0)          ;
clr.l   $14(a0)         ;
clr.l   $18(a0)         ;
clr.w   $1c(a0)         ;
move.l  (A1)+,a2        ;get address
get_next_byte:          ;
move.b  (a2)+,d2        ;get first sequence
btst    #$7,d2          ;tr-bit set
beq.s   ino_transpose   ;no
and.b   #$7f,d2         ;mask out tr
move.b  d2,$1d(a0)      ;mark tr
addq.l  #1,d3           ;offset plus 1
bra.s   get_next_byte   ;next byte, please...
ino_transpose:          ;
and.l   #$7f,d2         ;only sequence numbers 0-127 allowed
add.l   d2,d2           ;time 4 !
add.l   d2,d2           ; ""
lea     seqtab(pc),a2   ;base of sequence table
move.l  0(a2,d2.w),a2   ;get base
move.l  a2,$10(a0)      ;mark
move.l  d3,$04(a0)      ;mark offset
add.l   d1,a0           ;add difference between voices 1 and 2
dbf     d0,initloop     ;next voice
move.b  #2,$484         ;switch off keyboard click
move.l  #syn,$4d2       ;add to vbl-list
clr.w   sy              ;start syn.
rts
;---------------------------------------------
;turns off program
;---------------------------------------------
cut:
clr.l   $4d2            ;disable vbl
move.w  #1,sy           ;set on/off flag
bra     syn             ;go to main routine again
;---------------------------------------------
syn:
tst.w   sy              ;on/off flag
beq.s   synein
lea     ym2149(pc),a0
moveq   #9,d0
regloeschloop:
clr.b   (a0)+           ;clear register
dbf     d0,regloeschloop
move.b  #%11111000,ym2149+7
bra.l   write_soundchip
synein:
subq.w  #1,speed
bpl.s   soundwork
lea     stimme1(pc),a0
bsr.l   bearbeiten

lea     stimme2(pc),a0
bsr.l   bearbeiten

lea     stimme3(pc),a0
bsr.l   bearbeiten

move.w  speed+2(pc),speed       ;write old value on current again

soundwork:
lea     stimme1(pc),a0
bsr.l   soundbearbeiten
move.w  d0,dummy
move.b  d0,ym2149
move.b  dummy,ym2149+1
move.b  d1,ym2149+8

lea     stimme2(pc),a0
bsr.l   soundbearbeiten
move.w  d0,dummy
move.b  d0,ym2149+2
move.b  dummy,ym2149+3
move.b  d1,ym2149+9

lea     stimme3(pc),a0
bsr.l   soundbearbeiten
move.w  d0,dummy
move.b  d0,ym2149+4
move.b  dummy,ym2149+5
move.b  d1,ym2149+10

;to get the sounddata as fast as possible on the soundchip, one
;should do it in one blow.
;otherwise, noises or other sounds may appear

write_soundchip:
moveq   #$a,d0
lea     ym2149+11(pc),a0
writeloop:
move.b  d0,$ffff8800.w    ;register number
move.b  -(a0),$ffff8802.w ;write data
dbf     d0,writeloop
rts                       ;bye!!!
;---------------------------------------------
bearbeiten:
subq.b  #1,$0f(a0)      ;length minus 1
bpl.l   return 
bearbeiten2:
clr.b   $24(a0)
move.l  $10(a0),a1
move.b  (a1)+,d0
cmp.b   #$ff,d0         ;end of sequence?
bne.l   noend
move.l  (a0),a2
add.l   4(a0),a2
addq.l  #1,$4(a0)
move.b  (a2)+,d0
cmp.b   #$ff,d0         
bne.s   noend2
move.l  #1,$4(a0)
move.l  (A0),a2
btst    #$7,(A2)
beq.s   notran2
move.b  (a2)+,d0
and.b   #$7f,d0
move.b  d0,$1d(a0)
move.l  #2,$4(A0)
notran2:
move.b  (a2),d0
noend2:
btst    #$7,d0
beq.s   notran
and.b   #$7f,d0
move.b  d0,$1d(a0)
move.b  (A2)+,d0
addq.l  #1,$4(a0)
notran:
and.l   #$7f,d0
add.l   d0,d0
add.l   d0,d0
lea     seqtab(pc),a2
add.l   d0,a2
move.l  (a2),$10(A0)
bra.l   bearbeiten2
noend:
btst    #$5,d0
beq     kein_anhaengen
bset    #$1,$28(a0)     ;set append-bit
kein_anhaengen:
btst    #$7,d0
beq.l   nowave
and.b   #$1f,d0
move.b  d0,$f(a0)
move.b  (a1)+,d0
and.l   #$1f,d0
add.l   d0,d0
add.l   d0,d0
lea     wavetab(pc),a2
move.l  0(A2,d0.w),a2
move.b  (a2)+,d0        ;arpeggio-byte
move.b  (a2),$c(a0)
move.b  (a2)+,$d(a0)
move.b  (a2)+,$26(a0)
move.b  (a2),$25(a0)
move.b  (a2)+,$27(a0)
move.l  a2,$8(A0)
move.l  a2,$1e(a0)      ;mark address
and.l   #$7f,d0         ;only 0 to 127 allowed
add.l   d0,d0           
add.l   d0,d0           
lea     arpeggiotab(pc),a2
move.l  0(a2,d0.w),a2
move.b  (a2),$1c(A0)
move.b  (a2)+,$22(A0)
move.l  a2,$14(a0)
move.l  a2,$18(a0)
move.b  (a1)+,$23(a0)   ;mark note
bra.s   init_sounds
nowave:
btst    #$6,d0
beq.s   nopause
and.b   #$1f,d0
move.b  d0,$0f(a0)
clr.b   $23(a0)
move.b  #$1,$24(a0)
bra.s   init_sounds
nopause:
and.b   #$1f,d0
move.b  d0,$0f(a0)
move.b  (a1)+,$23(A0)
init_sounds:
bset    #6,$28(a0)      ;initialize vibrato
move.l  a1,$10(a0)      ;mark current address again
btst    #1,$28(a0)      ;append-bit?
bne.s   return          ;yes
move.b  $d(a0),$c(A0)   ;adsr-speed init
move.b  $22(A0),$1c(a0) ;arp-speed init
move.l  $14(a0),$18(a0) ;arp-tab init
move.l  $1e(a0),$08(a0) ;adsr-tab init
return:
bclr    #1,$28(a0)      ;clear append-bit
rts
;---------------------------------------------
soundbearbeiten:
clr.l   d0
subq.b  #1,$1c(A0)
bne.s   noendarp
move.b  $22(a0),$1c(a0)
nochmalarp:
move.l  $18(a0),a2
addq.l  #1,$18(a0)
cmp.b   #$ff,(a2)
bne.s   noendarp2
move.l  $14(a0),$18(A0)
bra.s   nochmalarp
noendarp:
move.l  $18(a0),a2
noendarp2:
move.b  (a2),d0

add.b   $23(a0),d0              ;add current note
add.b   $1d(a0),d0              ;transpose
sub.b   #$c,d0                  ;and substract one octave again
bpl.s   noteok
clr.l   d0
noteok:
lea     frequenztab(pc),a1
and.l   #$7f,d0
add.l   d0,d0
add.l   d0,a1
move.w  (a1),d0
and.l   #$ffff,d0
;----------------------------
moveq   #0,d1
move.b  $28(a0),d6
btst    #6,d6
beq     novibrato
move.b  d1,d5
move.b  $25(a0),d4
move.b  $27(a0),d1
btst    #7,d6
bne.s   vibrato
btst    #0,d6           ;Already the second time?
beq.s   second_time     ;No
vibrato:         
btst    #5,d6           ;Add?
bne.s   hochvib         ;Yes
sub.b   $26(a0),d1      ;Otherwise substract
bcc.s   write_back      ;Smaller than zero
bset    #5,$28(a0)      ;Then add to next time
moveq   #0,d1           ;and zero to the counter
bra.s    write_back      
hochvib:                ;
add.b   $26(a0),d1      ;add
cmp.b   d4,d1           ;limit reached
bcs.s   write_back      ;no
bclr    #5,$28(a0)      ;otherwise substract from next time
move.b  d4,d1           ;and take over upper limit
write_back:
move.b  d1,$27(a0)      ;mark value
second_time:            
lsr.b   #1,d4           ;halve value
sub.b   d4,d1           ;substract value for calculated value
bcc.s   gnull           ;Bigger than zero?
sub.w   #$100,d1        ;        
gnull:
add.b   #$a0,d5
bcc.s   addiere         ;Now finally add value
nochmal:
add.w   d1,d1           ;time two
add.b   #$18,d5         
bcc.s   nochmal
addiere:        
add.w   d1,d0
novibrato:
bchg    #0,$28(a0)      ;invert second_flag
;----------------------------------
clr.l   d1
tst.b   $24(a0)
bne.s   pauseok
subq.b  #1,$c(a0)
bne.s   endadsr
move.b  $d(a0),$c(a0)
move.l  8(a0),a1
cmp.b   #$ff,1(a1)
beq.s   endadsr
addq.l  #1,$8(A0)
endadsr:
move.l  8(A0),a1
move.b  (A1),d1
pauseok:



;*** output ***
;d0.w -> frequenz
;d1.b -> volume
rts

;---------------------------------------------
;the eleven sound registers that are important to us
ym2149:
        dc.b 0,0,0,0,0,0,0,%11111000,0,0,0
even
;---------------------------------------------
stimme1:
        dc.l 0          ;$00 base of tab x
        dc.l 0          ;$04 offset of tab x
        dc.l 0          ;$08 address adsrtab
        dc.b 0          ;$0c speed adsr_tab
        dc.b 0          ;$0d   ""   ""
        dc.b 0          ;$0e current volume
        dc.b 0          ;$0f current length
        dc.l 0          ;$10 current position of sequence
        dc.l 0          ;$14 arpeggio base
        dc.l 0          ;$18 arpeggio offset
        dc.b 0          ;$1c arpeggio speed
        dc.b 0          ;$1d transpose voice x
        dc.l 0          ;$1e address adsrtab (must be marked!!)
        dc.b 0          ;$22 arpeggio speed
        dc.b 0          ;$23 current note
        dc.b 0          ;$24 pauseflag
        dc.b 0          ;$25 vibrato-speed
        dc.b 0          ;$26 vibrato-strength
        dc.b 0          ;$27 vibrato-data
        dc.b 0          ;$28 vibrato data2
 
even
;---------------------------------------------
stimme2:
        dc.l 0          ;$00 base of tab x
        dc.l 0          ;$04 offset of tab x
        dc.l 0          ;$08 address of adsrtab
        dc.b 0          ;$0c speed adsr_tab
        dc.b 0          ;$0d   ""   ""
        dc.b 0          ;$0e current volume
        dc.b 0          ;$0f current length
        dc.l 0          ;$10 current position of sequence
        dc.l 0          ;$14 arpeggio base
        dc.l 0          ;$18 arpeggio offset
        dc.b 0          ;$1c arpeggio speed
        dc.b 0          ;$1d transpose voice x
        dc.l 0          ;$1e address adsrtab (must be marked!!)
        dc.b 0          ;$22 arpeggio speed
        dc.b 0          ;$23 current note
        dc.b 0          ;$24 pauseflag
        dc.b 0          ;$25 vibrato-speed
        dc.b 0          ;$26 vibrato-strength
        dc.b 0          ;$27 vibrato-data
        dc.b 0          ;$28 vibrato data2
 even
;---------------------------------------------
stimme3:
        dc.l 0          ;$00 base of tab x
        dc.l 0          ;$04 offset of tab x
        dc.l 0          ;$08 address of adsrtab
        dc.b 0          ;$0c speed adsr_tab
        dc.b 0          ;$0d   ""   ""
        dc.b 0          ;$0e current volume
        dc.b 0          ;$0f current length
        dc.l 0          ;$10 current position of sequence
        dc.l 0          ;$14 arpeggio base
        dc.l 0          ;$18 arpeggio offset
        dc.b 0          ;$1c arpeggio speed
        dc.b 0          ;$1d transpose voice x
        dc.l 0          ;$1e address of adsrtab (must be marked!!)
        dc.b 0          ;$22 arpeggio speed
        dc.b 0          ;$23 current note
        dc.b 0          ;$24 pauseflag
        dc.b 0          ;$25 vibrato-speed
        dc.b 0          ;$26 vibrato-strength
        dc.b 0          ;$27 vibrato-data
        dc.b 0          ;$28 vibrato data2
 even
;---------------------------------------------
;on/off flag
;0 ->  ON
;1 ->  OFF
;---------------------------------------------
sy:    
        dc.w 1  
dummy:  
        dc.w 0
speed:
        dc.w 0,0
;---------------------------------------------
;the frequency table
frequenztab:
dc.b 014,238,014,023,013,077,012,142,011,217,011,047,010,142,009,247
dc.b 009,103,008,224,008,097,007,232,007,119,007,011,006,166,006,071
dc.b 005,236,005,151,005,071,004,251,004,179,004,112,004,048,003,244
dc.b 003,187,003,133,003,083,003,035,002,246,002,203,002,163,002,125
dc.b 002,089,002,056,002,024,001,250,001,221,001,194,001,169,001,145
dc.b 001,123,001,101,001,081,001,062,001,044,001,028,001,012,000,253
dc.b 000,238,000,225,000,212,000,200,000,189,000,178,000,168,000,159
dc.b 000,150,000,142,000,134,000,126,000,119,000,112,000,106,000,100
dc.b 000,094,000,089,000,084,000,079,000,075,000,071,000,067,000,063
dc.b 000,059,000,056,000,053,000,050,000,047,000,044,000,042,000,039
dc.b 000,037,000,035,000,033,000,031,000,029,000,028,000,026,000,025
dc.b 000,023,000,022,000,021,000,019,000,018,000,017,000,016,000,015

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;from here, important data for the user are present!
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;
;---------------------------------------------
;arpeggiotab-buildup
;1st byte -> speed
;2nd byte -> byte = $ff (arpeggio-table)
;---------------------------------------------
;(pointers to the arpeggio-tables)
arpeggiotab:
        dc.l arp0,arp1,arp2,arp3
;
;---------------------------------------------
;the arpeggio-tables
;---------------------------------------------
arp0:   dc.b 1,$0,$0,$0,$0,$ff  ;no arpeggio
arp1:   dc.b 1,$c,$7,$4,$0,$ff
arp2:   dc.b 1,$c,$7,$3,$0,$ff
arp3:   dc.b 1,$c,$9,$5,$0,$ff
;---------------------------------------------
;the waveform table buildup!
;1st byte -> arpeggio-table (0 = no arpeggio)
;2nd byte -> speed that is used to handle ADSR-table
;3rd byte -> vibrato-speed
;4th byte -> vibrato-strength
;5th byte to byte = $ff -> adsr-waveform
;---------------------------------------------
even
wavetab:
        dc.l wave0,wave1,wave2,wave3
wave0:  dc.b 1,4,0,0,$f,$e,$d,$c,$b,$a,$9,$8,$7,$6,$5,$4,$3,$2,$1,$0,$ff
wave1:  dc.b 2,4,0,0,$f,$e,$d,$c,$b,$a,$9,$8,$7,$6,$5,$4,$3,$2,$1,$0,$ff
wave2:  dc.b 0,4,16,8,$f,$e,$d,$c,$b,$a,$9,$8,$7,$6,$5,$4,$3,$2,$1,$0,$ff
wave3:  dc.b 0,4,8,10,$f,$e,$d,$ff
even
;---------------------------------------------
;pointer to the sequence tables
;---------------------------------------------
pointer:
        dc.l seqst1,seqst2,seqst3
;---------------------------------------------
;the sequence tables
;---------------------------------------------
seqst1:
        dc.b $80,$04,$04
        dc.b $85,6,6,$80,6,6,$85,6,6,$87,6,6
        DC.B $80,$4
        dc.b $ff
;---------------------------------------------
seqst2:
        dc.b $80,01,1,$85,1,1,$87,1,$85,1,$80,1,1
        dc.b $80,01,1,$85,1,1,$87,1,$85,1,$80,1,1
        dc.b $85,1,1,$80,1,1,$85,1,1,$87,$1,1
        dc.b $80,01,1,$85,1,1,$87,1,$85,1,$80,1,1
        dc.b $ff
;---------------------------------------------
seqst3:
        dc.b $80,0,0,$02,$85,$03,$87,2,$80,$03
        dc.b $85,5,5,$80,5,5,$85,$5,5,$87,$5,5
        DC.B $80,2,$85,3,$87,$2,$80,$3
        dc.b $FF
even
;---------------------------------------------
;pointers to the seperate sequences
;---------------------------------------------
seqtab:
        dc.l pause,bass0,arpt0,arpt1,haupt0,hall0,haupt1
;---------------------------------------------
;the sequences
;---------------------------------------------
pause:
        dc.b $5f,$ff
bass0:
        dc.b $81,$02,$18,$01,$18,$01,$24,$01,$18
        dc.b $ff
arpt0:
        dc.b $83,$00,$3c,$03,$3c,$01,$3c,$05,$3c,$ff
arpt1:
        dc.b $83,$00,$3c,$01,$3c,$03,$3c,$01,$3c,$01,$3c,$01,$3c,$ff
haupt0:
        dc.b $83,$03,$34,$03,$30,$01,$34,$05,$30
        dc.b $03,$35,$01,$32,$03,$35,$01,$32,$01,$35,$01,$32
        dc.b $03,$37,$03,$32,$01,$35,$05,$32,$03,$34,$01,$30
        dc.b $03,$34,$01,$30,$01,$34,$01,$30,$ff

hall0:
        dc.b $80,$02,$30,$20,$34,$20,$37,$20,$3c
        dc.b $20,$30,$20,$34,$20,$37,$20,$3c
        dc.b $ff
haupt1:
        dc.b $81,$00,$3c,$01,$3c,$01,$48
        dc.b $01,$3c,$ff
even

