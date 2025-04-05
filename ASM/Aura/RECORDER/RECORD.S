**********************************************************************
*
*  RECORD:  Converter for synthsongs (NO digidrums): YM3 format.
*  VERSION: 0.92
*  DATE:    1.5.97
*  CODE:    BDCannibal / AURA (spended few less moments of my life)
*           contact:  knaus@ruf.uni-freiburg.de
*
*  Convert synth tunes running in 50Hz using no IRQs (digidrums or
*  SID voices). Calling format is standart MadMax (3 branches).
*  By the way: In mostly all songs my register 13 presetting trick 
*  works (I only found one where it didnt: convert it by hand then).
*
* ATTENTION: - The code is VERY (VERY) cruel. Don't look further.
*            - The commandline is very sensible to different strings,
*              only use the normal format (I wasnt motivated to do
*              a better rout.
*
* CALL IT:  record [-txxyy] [-nzz] [-Nrr]   sndfile ymfile
* where xx are minutes and yy seconds (0312 are 3 mins, 12 secs)
*       zz is Number of the Tune
*       rr is the used register for non-check call.b 
**********************************************************************

                MC68000         ; This is for EasyAss.
                MODUL "f:\sources.030\recorder\record.ttp"
                OPT D+,O+

_NOT_USED       EQU 0           ; Def. Waveform fr Reg.13 Trick
_SEARCH_HUE     EQU 0           ; Waveform fr Reg.13 Trick suchen.
_PLAY_FILE      EQU 0           ; YM File spielen.
_PLAY_AT_REC    EQU 0           ; Beim Record spielen ?
_NO_WRITE       EQU 0           ; Nach Record nicht schreiben.
_TUNE           EQU 0           ; Def. Tune

_MINUTES        EQU 03          ; Default L„nge
_SECONDS        EQU 00

VERSION_a       EQU     '0'     ; Versionsnummer.
VERSION_b       EQU     '9'
VERSION_subb	EQU		'2'

MAX_STRING      EQU     127     ; Max. L„nge Filenamen auf Cmd-line.
MAX_SND_SIZE    EQU     50000   ; Max. Gr”že des .SND Files (entpackt)

                TEXT
                bra.w   main
                
                dc.b    '.SND --> .YM3 (nonDigi) Konverter'
                dc.b    ' by BDC / AURA. Cruel code. Bye  '
                dc.b    'Remeber Oyster and Mathematica 3D screen ?'
                dc.b    ' Search the Illusion code for jokes....'
                even
                
main:           move.l  4(sp),a5
                move.l  $c(a5),d0
                add.l   $14(a5),d0
                add.l   $1c(a5),d0
                add.l   #$400,d0
                move.l  d0,d1
                add.l   a5,d1
                and.l   #-2,d1
                move.l  d1,a7
                move.l  d0,-(sp)
                pea     (a5)
                clr.w   -(sp)
                move.w  #$4a,-(sp)
                trap    #1
                lea     12(sp),sp

                lea     copyright(pc),a0
                bsr.w   put

                pea     0.w         ; Scotty Supervisor !
                move.w  #32,-(sp)   ; Schon hier wegen eve. Ladefehlern
                trap    #1          ; und allg. Errorhandler
                addq.l  #6,sp
                move.l  d0,old_sp

                lea     $80(a5),a6  ; Kommandozeile.
                move.b  (a6)+,d7    ; Anzahl Zeichen.
                ext.w   d7
                clr.b   1(a6,d7.w)  ; Schlužbyte zur Sicherheit.
                pea     (a6)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp
                
                subq.w  #1,d7
                bmi.s   error_cmdline

                bsr.w   chk_options     ; Optionen in Kommandozeile ?
                
                lea     src_file,a0
                bsr.w   get_string
                bmi.s   error_cmdline

                lea     src_name(pc),a0     ; Welche Files werden
                bsr.w   put                 ; geshreddert ???
                lea     src_file,a0
                bsr.w   puts
                
                lea     dest_file,a0
                bsr.w   get_string
                bmi.s   error_cmdline

                lea     dest_name(pc),a0
                bsr.w   put
                lea     dest_file,a0
                bsr.w   puts

                bra.s   cmd_line_right

error_cmdline:  pea     cmd_error(pc)
                bra     ende

cmd_line_right: move.w  minuten(pc),d0
                ext.l   d0
                divu.w  #10,d0
                addi.b  #'0',d0
                move.b  d0,filler_min
                swap    d0
                addi.b  #'0',d0
                move.b  d0,filler_min+1

                move.w  seconds(pc),d0
                ext.l   d0
                divu.w  #10,d0
                addi.b  #'0',d0
                move.b  d0,filler_sek
                swap    d0
                addi.b  #'0',d0
                move.b  d0,filler_sek+1
                
                lea     filelen_name(pc),a0
                bsr.w   puts

                moveq   #0,d0
                move.b  tune(pc),d0
                divu.w  #10,d0
                addi.b  #'0',d0
                move.b  d0,filler_tune
                swap    d0
                addi.b  #'0',d0
                move.b  d0,filler_tune+1
                
                lea     play_tune(pc),a0
                bsr.w   puts

; Sourcefile laden.
                clr.w   -(sp)
                pea     src_file(pc)
                move.w  #$3d,-(sp)
                trap    #1
                addq.l  #8,sp
                
                tst.l   d0
                bmi.s   read_error
                
                move.w  d0,d7
                
                pea     sound
                move.l  #MAX_SND_SIZE,-(sp)
                move.w  d0,-(sp)
                move.w  #$3f,-(sp)
                trap    #1
                lea     12(sp),sp

                cmp.l   #MAX_SND_SIZE,d0
                beq.s   read_error
                tst.l   d0
                bmi.s   read_error
                
                move.w  d7,-(sp)
                move.w  #$3e,-(sp)
                trap    #1
                addq.l  #4,sp
                
                tst.l   d0
                bpl.s   load_succ

read_error:     pea     load_error(pc)
                bra.w   ende

load_succ:      lea		sound,a0		; Eventuell entpacken.
				bsr.w	ice_decrunch_2

				tst.b   play_file       ; File nur abspielen ?
                bne.w   play_only

; Bufferallokierung und andere Spaesse.
                move.w  minuten(pc),d0
                mulu.w  #60,d0
                add.w   seconds(pc),d0  ; d0.w MUSS noch Wort sein.
                move.l  d0,d1
                mulu.w  #50,d0
                move.l  d0,count
                mulu.w  #50*14,d1
                move.l  d1,size

                addq.l  #4,d1           ; + Header
                move.l  d1,-(sp)        ; Speicher fr Konvertierung
                move.w  #$48,-(sp)      ; reservieren.
                trap    #1
                addq.l  #6,sp
                
                tst.l   d0
                bgt.s   alloc_right
                
                pea     alloc_err(pc)   ; Malloc-Error.
                bra.w   ende

alloc_right:    move.l  d0,buffer

                move.b  $484.w,old484
                move.b  #0,$0484.w

************
* Unbenutzte Waveform suchen ?
************

                tst.b   search_hue      ; Passend Waves fr Reg13 check
                bne.w   no_search_huell ; suchen ? (Def.: ja!)

				lea		sear_wave(pc),a0
				bsr.w	puts

                move.b  tune(pc),d0     ; Sound initialisieren.
                ext.w   d0
                movea.l sound_adr(pc),a0
                jsr     (a0)

                move.l  count(pc),D7
test_loop:      movem.l D0-A6,-(SP)
                movea.l sound_adr(pc),a0
                jsr     8(a0)
                movem.l (SP)+,D0-A6

                lea     test14,A0
                move.b  #13,$FFFF8800.w
                moveq   #$0F,D0
                and.b   $FFFF8800.w,D0  ; only lowest 4 bits.
                st      0(A0,D0.w)

                subq.l  #1,D7
                bgt.s   test_loop

                moveq   #13,D7
                lea     test14,A0
get_reg_nr:     tst.b   (A0)+
                beq.s   found_reg
                dbra    D7,get_reg_nr

                pea     noregfound(pc)
                bra.w   ende

found_reg:      moveq   #13,D0
                sub.w   D7,D0           ; REGNR in d0.
                move.b  d0,not_used

***********
* Zeichnet File auf.
***********

no_search_huell:
                moveq   #0,d0
                move.b  not_used(pc),d0		; Waveform, die fr Reg. 13
                divu.w  #10,d0				; benutzt wird, ausgeben.
                addi.b  #'0',d0
                move.b  d0,filler_wave
                swap    d0
                addi.b  #'0',d0
                move.b  d0,filler_wave+1
                
                lea     used_wave(pc),a0
                bsr.w   puts

                move.b  tune(pc),d0			; Song initialisieren: Nr. in d0.w
                ext.w   d0
                movea.l sound_adr(pc),a0
                jsr     (a0)

                movea.l buffer(pc),A6
                move.l  #'YM3!',(A6)+   ; ID

                move.l  count(pc),D7
loop:           tst.b   play_at_rec		; In "Echtzeit" aufnehmen ?
                beq.s   no_wait_vbl

                movem.l d0-a6,-(sp)
                move.w  #37,-(SP)
                trap    #14
                addq.w  #2,SP
                movem.l (sp)+,d0-a6

no_wait_vbl:    move.b  #13,$FFFF8800.w ; Unmoeglichen Wert in Reg.13
                move.b  not_used,$FFFF8802.w

                movem.l D0-A6,-(SP)     ; Sound abspielen.
                movea.l sound_adr(pc),a0
                jsr     8(a0)
                movem.l (SP)+,D0-A6

***
* Register 0-12 normal auslesen.
***
                moveq   #12,D6
                moveq   #0,D5
                movea.l A6,A5
get_regs:       move.b  D5,$FFFF8800.w
                move.b  $FFFF8800.w,(A5)
                adda.l  count(pc),a5    ; count = size / 14
;                lea     size/14(A5),A5
                addq.b  #1,D5
                dbra    D6,get_regs

; Register 13 besonderst behandeln.
                move.b  #$FF,(A5)       ; Reg. 13 nicht veraendert.

                move.b  #13,$FFFF8800.w
                move.b  $FFFF8800.w,D1

                cmp.b   not_used,D1    ; Veraendert ?
                beq.s   not_set_13

                move.b  D1,(A5)

not_set_13:     addq.l  #1,A6

                subq.l  #1,D7
                bgt.s   loop

                clr.w   -(sp)
                pea     dest_file
                move.w  #$3c,-(sp)
                trap    #1
                addq.l  #8,sp
                
                tst.l   d0
                bmi.s   file_error

                move.w  d0,d7
                
                move.l  buffer(pc),-(sp)
                move.l  size(pc),d0
                addq.l  #4,d0           ; Header YM3!
                move.l  d0,-(sp)
                move.w  d7,-(sp)
                move.w  #$40,-(sp)
                trap    #1
                lea     12(sp),sp
                
                sub.l   size(pc),d0
                subq.l  #4,d0
                bne.s   file_error

                move.w  d7,-(sp)
                move.w  #$3e,-(sp)
                trap    #1
                addq.l  #4,sp

                tst.l   d0
                bmi.s   file_error

                pea     all_right(pc)   ; File erfolgreich aufgenommen (WOW!)
                bra.s   ende
                
file_error:     pea     file_err(pc)    ; Sounddaten von a0.l -> a1.l

ende:           move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                move.b  old484,$484.w

                move.l  old_sp,-(sp)
                move.w  #32,-(sp)
                trap    #1
                addq.l  #6,sp

                move.l  buffer(pc),d0       ; Allocierter Speicher
                beq.s   no_free_needed      ; wieder freigeben.

                move.l  d0,-(sp)
                move.w  #$49,-(sp)
                trap    #1
                addq.l  #6,sp

no_free_needed:
				pea		pling(pc)
				bsr.w	put

                clr.w   -(sp)
                trap    #1

copyright:      dc.b    13,10,'ReCORD ver. ',VERSION_a,'.',VERSION_b
				dc.b	VERSION_subb
                dc.b    13,10,'==> Deadly freeware <==',13,10,13,10,0
all_right:      dc.b    27,7,13,10,"Recorded succesfully.",13,10,0
noregfound:     dc.b    13,10,'All waves used. Need to convert by '
                dc.b    '"hand"'                        ; {
played:         dc.b    13,10,'Press key.',13,10,0      ; }
sear_wave:		dc.b	'Searching unused waveform.',13,10,0
file_err:       dc.b    27,7,13,10,'Fileerror. Not saved.',13,10
                dc.b    'Press key.',13,10,0
alloc_err:      dc.b    13,10,'Allocation Error. Not saved.',13,10
                dc.b    'Press key.',13,10,0
load_error:     dc.b    'Loading error.',13,10
                dc.b    'Probably file not existing or too big.',13,10,0
cmd_error:      dc.b    13,10,'Error with commandline.',13,10,0
return:         dc.b    13,10,0,0
src_name:       dc.b    13,10,'SND-File: ',0
dest_name:      dc.b          ' YM-File: ',0
filelen_name:   dc.b          '  Length: '  ; {
filler_min:     dc.b    '00:'               ; |
filler_sek:     dc.b    '00',0              ; }
play_tune:      dc.b          '    Tune: '  ; {
filler_tune:    dc.b    '00',0              ; }
used_wave:		dc.b          'us. Wave: '           ;{
filler_wave:	dc.b 	'00',13,10					 ;|
				dc.b	'Recording tune.',13,10,0	 ;}


pling:			dc.b	7,0
                even

*************************
* Testet File !
*************************

play_only:      lea     data+4(PC),A6
                lea     (data_end-data-4)/14(A6),A5
loopy:          move.w  #37,-(SP)
                trap    #14
                addq.l  #2,SP

                moveq   #12,D7
                moveq   #0,D0
                movea.l A6,A4
set:            move.b  D0,$FFFF8800.w
                move.b  (A4),$FFFF8802.w
                lea     (data_end-data-4)/14(A4),A4
                addq.b  #1,D0
                dbra    D7,set

                move.b  (A4),D0
                bmi.s   no_set

                move.b  #13,$FFFF8800.w
                move.b  D0,$FFFF8802.w

no_set:         addq.l  #1,A6

                cmpa.l  A5,A6
                bne.s   loopy

                pea     played(pc)
                bra.w   ende

; Unterrouts, die irgendwie irgendwo v”llig brauchbar sein k”nnten, wenn
; ich sie nicht geschrieben h„tte, sondern jemand anderes. Peace.

; a0 - Ziel.
; a5 - Kommandozeile Nullterminiert
get_string:     movem.l d0-a5,-(sp)
    
                move.w  #MAX_STRING-1,d7
copy_str:       move.b  (a6)+,d0
                beq.s   end_dest
                cmp.b   #13,d0
                beq.s   end_dest
                cmp.b   #' ',d0
                beq.s   end_dest
                move.b  d0,(a0)+
                dbra    d7,copy_str
ende_str:       moveq   #-1,d0
                movem.l (sp)+,d0-a5
                rts

end_dest:       clr.b   (a0)+
                moveq   #1,d0
                movem.l (sp)+,d0-a5
                rts             

; Optionen auf Kommandozeile auslesen: ABSOLUT BUGGY (ich habe keinen Bockk
; mehr auf eine schoene Abfrage... (wo ist mein C???)).
; Ich k”nnte ohne nachdenken 415 Arten sagen, das Ding abstrzen zu
; lassen...
chk_options:    movem.l d0-a5,-(sp)

                move.b  (a6),d0
                cmp.b   #'-',d0
                bne.s   no_opt_bye

                move.w  (a6)+,d0
                cmp.b   #'t',d0         ; Laufzeit: Form: 0312
                bne.s   no_time_opt     ; fr 3 min, 12 seks.
                
                move.w  (a6)+,d0        ; Minuten
                bsr.w   get_byte
                move.w  d0,d5
                move.w  (a6)+,d0        ; Sekunden
                bsr.w   get_byte
                move.w  d0,d6
                
                tst.w   d5
                bmi.s   no_time_opt
                tst.w   d6
                bmi.s   no_time_opt
                
                move.w  d5,minuten
                move.w  d6,seconds

                addq.l  #1,a6
                move.b  (a6),d0
                cmp.b   #'-',d0
                bne.s   no_opt_bye
                move.w  (a6)+,d0

no_time_opt:    cmpi.b  #'n',d0         ; Song: Form: 07
                bne.s   no_anz_opt      ; fr Startwert 7

                move.w  (a6)+,d0        ; SNDH wird nicht beachtet!
                bsr.w   get_byte
                tst.b   d0
                bmi.s   no_opt_bye
                move.b  d0,tune             

                addq.l  #1,a6
                move.b  (a6),d0
                cmpi.b  #'-',d0
                bne.s   no_opt_bye
                move.w  (a6)+,d0

no_anz_opt:		cmpi.b	#'N',d0			; Soll freie Waveform gesucht werden ?
				beq.s	get_wavenr

				illegal

get_wavenr:		move.w	(a6)+,d0
                bsr.w   get_byte
				move.b	d0,not_used

				st		search_hue
				addq.l	#1,a6

no_opt_bye:     movem.l (sp)+,d0-a5
                rts
                
get_byte:       movem.l d1-a6,-(sp)

                moveq   #0,d1
                move.b  d0,d1
                lsr.w   #8,d0

                sub.b   #'0',d1
                bmi.s   error_opt
                cmp.b   #9,d1
                bgt.s   error_opt

                sub.b   #'0',d0
                bmi.s   error_opt
                cmp.b   #9,d0
                bgt.s   error_opt

                mulu.w  #10,d0
                add.w   d1,d0

                movem.l (sp)+,d1-a6
                rts

error_opt:      moveq   #-1,d0
                movem.l (sp)+,d1-a6
                rts             

; a0 : String
puts:           movem.l d0-d2/a0-a2,-(sp)
                bsr.s   put

                pea     return(pc)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                movem.l (sp)+,d0-d2/a0-a2
                rts

put:            movem.l d0-d2/a0-a2,-(sp)
                pea     (a0)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp
                movem.l (sp)+,d0-d2/a0-a2
                rts

;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
	bne	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_ber
.get_ber:
	bsr.s	.get_d0_bits
.no_ber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,15-1,8-1,5-1,2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,4,7,0	; Bits lesen
	dc.w	$11f,-1,$1f	; Standard Offset

ende_ice_decrunch_2:
;************************************************** end of unpacking routine


                DATA
test14:         DS.B 14             ; Muss gel”scht sein
old484:         DS.B 1
not_used:       DC.B _NOT_USED      ; Default Reg. 13
search_hue:     DC.B _SEARCH_HUE    ; Reg. 13 Einstellung suchen ?
play_file:      DC.B _PLAY_FILE     ; File nur Spielen ?
play_at_rec:    DC.B _PLAY_AT_REC   ; Tune beim Recorden spielen ?
tune:           DC.B _TUNE          ; Tune, die gespielt wird.
                EVEN
size:           DC.L    0           ;_SIZE
count:          DC.L    0           ;_COUNT
minuten:        DC.W    _MINUTES
seconds:        DC.W    _SECONDS

sound_adr:      DC.L    sound       ; Adresse des Soundfiles.
buffer:         DC.L    0           ; Bufferadresse YM File.

                PATH 'e:\'
data:           nop ;INLINE 'comic.bin'     ; File zum testen
data_end:

                BSS
                EVEN
old_sp:         DS.L 1
dest_file:      DS.B    MAX_STRING+1    ; Filenamen fuer Files.
src_file:       DS.B    MAX_STRING+1
sound:          DS.B    MAX_SND_SIZE
                END