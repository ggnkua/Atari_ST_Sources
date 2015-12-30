 
 SECTION TEXT
 
 even
  
SaveSystem 
 move #$2700,sr
 
 move.l usp,a0							; Need to save USP in case of a not totaly regular usage ;)
 move.l a0,save_usp

 move.b $fffffa07.w,save_iera
 move.b $fffffa09.w,save_ierb
 move.b $fffffa13.w,save_imra
 move.b $fffffa15.w,save_imrb
 move.b $fffffa17.w,save_vr
 move.b $fffffa19.w,save_tacr
 move.b $fffffa1b.w,save_tbcr
 move.b $fffffa1f.w,save_tadr
 move.b $fffffa21.w,save_tbdr

 move.b $ffff820a.w,save_freq
 move.b $ffff8260.w,save_rez
 move.b $ffff8265.w,save_pixl

 move.b $ffff8201.w,save_screen_addr_1	; Screen base pointeur (STF/E)
 move.b $ffff8203.w,save_screen_addr_2	; Screen base pointeur (STF/E)
 move.b $ffff820d.w,save_vbaselo		; Save low byte (STE only)
 
 move.b $ffff820f.w,save_linewidth
 
 movem.l $ffff8240.w,d0-d7				; STF/STE Palette
 movem.l d0-d7,save_palette

 move.l	$68.w,save_68					; HBL
 move.l $70.w,save_70					; VBL
 move.l $120.w,save_120					; MFP Timer B (aka HBL)
 move.l $134.w,save_134					; timer A
 
 ;
 ; System specific saves
 ;
 tst.b machine_is_megaste
 beq.s .end_specific 
.megaste 
 move.b $ffff8e21.w,save_mste_cache
.end_specific
 
 move #$2300,sr
 
 bsr TimeInit
 rts

 
 
RestoreSystem 
 move #$2700,sr

 move.l save_usp,a0
 move.l a0,usp

 move.b save_iera,$fffffa07.w
 move.b save_ierb,$fffffa09.w
 move.b save_imra,$fffffa13.w
 move.b save_imrb,$fffffa15.w
 move.b save_vr,$fffffa17.w
 move.b save_tacr,$fffffa19.w
 move.b save_tbcr,$fffffa1b.w
 move.b save_tadr,$fffffa1f.w
 move.b save_tbdr,$fffffa21.w

 move.b save_freq,$ffff820a.w
 move.b save_rez,$ffff8260.w
 move.b save_pixl,$ffff8265.w

 move.b save_screen_addr_1,$ffff8201.w
 move.b save_screen_addr_2,$ffff8203.w
 move.b save_vbaselo,$ffff820d.w
 
 move.b save_linewidth,$ffff820f.w
 
 movem.l save_palette,d0-d7
 movem.l d0-d7,$ffff8240.w

 move.l	save_68,$68.w
 move.l save_70,$70.w
 move.l save_120,$120.w
 move.l save_134,$134.w

 ;
 ; System specific load
 ;
 tst.b machine_is_megaste
 beq.s .end_specific 
.megaste 
 move.b save_mste_cache,$ffff8e21.w
.end_specific
 
 move #$2300,sr
 rts
 

SetSystemParameters
 ;
 ; Disable every MFP interruption
 ;
 sf $fffffa07.w	; iera
 sf $fffffa09.w	; ierb
 sf $fffffa13.w ; imra
 sf $fffffa15.w ; imrb
 
 ;
 ; Set the screen at the right adress
 ;
 lea $ffff8201.w,a0				; Screen base pointeur (STF/E)
 move.l #empty_line+256,d0
 clr.b d0
 move.l d0,d1
 lsr.l #8,d0					; Allign adress on a byte boudary for STF compatibility
 movep.w (a0),d2				; Save old screen adress
 sf.b 12(a0)					; For STE low byte to 0

 move.l d1,ptr_scr_1
 
 move #0,pos_scr_x
 move #0,pos_scr_y
 move #160,screen_stride		; Default in 320x200 is 160 bytes 
 
 ;
 ; System specific setup
 ;
 tst.b machine_is_megaste
 beq.s .end_specific 
.megaste 
 move.b #%00,$ffff8e21.w	; 8mhz without cache
.end_specific
 
 ;
 ; Initialize the audio output to known values
 ;
 bsr InitMixer

 ;
 ; Depack the 8x8 system font
 ; 
 lea PackInfoFontSystem,a0
 bra DepackBlock
 
  
  
;
; The Cookie Jar can be used to detect the type of machine.
; This feature was first implemented on the STE.
; So if the Cookie Jar is missing we can safely assume we are
; running on a STF machine.
; 
; http://leonard.oxg.free.fr/articles/multi_atari/multi_atari.html
; Cookie Value     Description 
; _MCH   $0000xxxx STf 
; _MCH   $00010000 STe 
; _MCH   $00010010 Mega-STe ( only bit 2 of the 32bits value tells it's a Mega-STE ) 
; _MCH   $0002xxxx TT 
; _MCH   $0003xxxx Falcon 
; CT60   $xxxxxxxx CT60 
;
; Returns z=false if the hardware is not correct...
DetectMachine 
 sf machine_is_ste
 sf machine_is_megaste
 
 move.l	$5a0.w,d0
 bne.s .found_cookie
 ; No cookie, this is a ST
.detection_refused
 moveq #0,d0 
 rts 
   
.found_cookie
 ; We found a cookie pointer, this is not a ST for sure
 move.l	d0,a0
.loop_cookie	
 move.l (a0)+,d0			; Cookie descriptor
 beq.s .detection_refused
 move.l (a0)+,d1			; Cookie value
 
 cmp.l #"CT60",d0
 beq.s .detection_refused	; We do not run on Falcon, accelerated or not
 cmp.l #"_MCH",d0
 bne.s .loop_cookie
 
.found_machine	
 cmp.l #$00010000,d1
 beq.s .found_ste
 cmp.l #$00010010,d1
 beq.s .found_mste
 bra.s .detection_refused	; We do not run on TT

.found_mste
 st machine_is_megaste 
.found_ste 
 st machine_is_ste
.found_st 
 moveq #-1,d0 
 rts
 
  
WaitDelay 
 bsr WaitVbl
 dbra d0,WaitDelay
 rts

 
WaitVbl
 sf flag_vbl
SyncVbl
.loop
 tst.b flag_vbl
 beq.s .loop
 sf flag_vbl
 rts

 
ComputeVideoParameters
 move.l d0,-(sp)
 move.l d1,-(sp)
 move.l a0,-(sp)
 
 lea shifter_data,a0
 
 move.l ptr_scr_1,d0

 ; Handle hardscrolling
 ; Vertical offset
 moveq #0,d1
 move.w screen_stride,d1
 lsl.l #8,d1
 move.l d1,shifter_stride(a0)
 
 moveq #0,d1
 move pos_scr_x,d1
 lsr #4,d1
 lsl #3,d1
 add.l d1,d0
 lsl.l #8,d0   
 move.l d0,shifter_adr_high(a0)
 
 ; Horizontal offset
 moveq #0,d1
 move pos_scr_x,d1
 and #15,d1
 move.b d1,shifter_pixel_skip(a0)
 
 move.l #empty_line+256,d0
 move.b d0,d1
 lsr.l #8,d0
 move.b d0,$ffff8203.w			; STF - Screen base adress (mid byte)
 lsr.w #8,d0
 move.b d0,$ffff8201.w			; STF - Screen base adress (high byte)
 move.b #0,$ffff820d.w			; STE - Screen base adress (low byte)
  
 move.l (sp)+,a0
 move.l (sp)+,d1
 move.l (sp)+,d0
 rts
 
 
; This routine is not pretty, but it guarantee that you will
; not have shifted bitplans when you come back to Gem after
; the intro is done :)
screen_choc
 bsr WaitVbl
 sf $ffff8260.w
 sf $ffff820a.w
 bsr WaitVbl
 bsr WaitVbl
 move.b #2,$ffff820a.w
 bsr WaitVbl
 bsr WaitVbl
 bsr WaitVbl
 sf $ffff820a.w
 bsr WaitVbl
 bsr WaitVbl
 bsr WaitVbl
 move.b #2,$ffff820a.w
 rts 
    
 
; a0=buffer start
; a1=buffer end 
MemoryClear
 movem.l d0-a6,-(sp)
 
 ; 'Fast' copy by blocks of 256 bytes (8 times 32 bytes (8 registers))
 ; d0/a0/a1 are used
 ; d1/d2/d3/d4/d5/d6/d7/a2 for clearing
 move.l a1,d0
 sub.l a0,d0
 lsr.l #8,d0
 beq.s .end_clear_256
 subq #1,d0
 movem.l black_palette,d1/d2/d3/d4/d5/d6/d7/a2
.loop_clear_256
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 dbra d0,.loop_clear_256
.end_clear_256

 ; Semi fast routine that copy by blocks of 32 bytes
 move.l a1,d0
 sub.l a0,d0
 lsr.l #5,d0
 beq.s .end_clear_32
 subq #1,d0
 movem.l black_palette,d1/d2/d3/d4/d5/d6/d7/a2
.loop_clear_32
 movem.l d1/d2/d3/d4/d5/d6/d7/a2,-(a1)	; 32 bytes
 dbra d0,.loop_clear_32
.end_clear_32

 ; Slow copy by 2 bytes blocks
 move.l a1,d0
 sub.l a0,d0
 lsr.l #1,d0
 beq.s .end_clear_2
 subq #1,d0
.loop_clear_2
 move.w d1,-(a1)
 dbra d0,.loop_clear_2
.end_clear_2
 
.done  
 movem.l (sp)+,d0-a6
 rts 
 
   
 
; jsr abs.l => 20/5 cycles 
; jsr EndNopTable + rts = 5+4=9 nops
NopTable
 dcb.w 100,$4e71    ; 4/1   x100
EndNopTable 
 rts				; 16/4
  
 
 
TimeInit
 move #$2c,-(sp)	; Gemdos: TGetTime
 trap #1
 addq #2,sp
 ;  0 à 4    contiennent les secondes divisées par 2 (0 à 28)
 ;  5 à 10   contiennent les minutes  (0 à 59)
 ; 11 à 15  contiennent les heures   (0 à 23)
 lea DecimalToBcd,a0
 move d0,d1
 and #%11111,d1
 add d1,d1
 move.b (a0,d1),time_seconds
 
 lsr #5,d0
 move d0,d1
 and #%111111,d1
 move.b (a0,d1),time_minutes

 lsr #6,d0
 move.b (a0,d0),time_hours
 rts
  
 
TimeUpdate
 addq.b #1,time_frame
 cmp.b #50,time_frame
 bne.s .end_update_time 
 sf.b time_frame

 moveq #1,d0
 
 ; seconds
 move.b time_seconds,d1
 abcd.b d0,d1 
 move.b d1,time_seconds
 cmp.b #$60,d1
 bne.s .end_update_time
 sf.b time_seconds

 ; minutes
 move.b time_minutes,d2
 abcd.b d0,d2
 move.b d2,time_minutes
 cmp.b #$60,d2
 bne.s .end_update_time
 sf.b time_minutes

 ; hours
 move.b time_hours,d3
 abcd.b d0,d3
 move.b d3,time_hours
 cmp.b #$24,d3
 bne.s .end_update_time
 sf.b time_hours
     
.end_update_time 
 rts 

 
 
 section DATA
  
 even
 
HexDigits		dc.b "0123456789ABCDEF"
 
DecimalToBcd
 dc.b $00,$01,$02,$03,$04,$05,$06,$07,$08,$09
 dc.b $10,$11,$12,$13,$14,$15,$16,$17,$18,$19
 dc.b $20,$21,$22,$23,$24,$25,$26,$27,$28,$29
 dc.b $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
 dc.b $40,$41,$42,$43,$44,$45,$46,$47,$48,$49
 dc.b $50,$51,$52,$53,$54,$55,$56,$57,$58,$59
 
 
 
 SECTION BSS

 even
 
save_iera			ds.b 1	; Interrupt enable register A
save_ierb			ds.b 1	; Interrupt enable register B
save_imra			ds.b 1	; Interrupt mask register A
save_imrb			ds.b 1  ; Interrupt mask register B
save_vr				ds.b 1	; Vector register
save_tacr			ds.b 1	; Timer A control register
save_tbcr			ds.b 1	; Timer B control register
save_tadr			ds.b 1  ; Timer A data register
save_tbdr			ds.b 1  ; Timer B data register

save_freq    		ds.b 1
save_rez     		ds.b 1
save_pixl    		ds.b 1

save_screen_addr_1 	ds.b 1
save_screen_addr_2 	ds.b 1
save_vbaselo 		ds.b 1

save_linewidth		ds.b 1

save_mste_cache		ds.b 1

machine_is_ste		ds.b 1
machine_is_megaste 	ds.b 1

flag_vbl	 		ds.b 1	; Set to true at the end of the main screen handling interupt
flag_end_part		ds.b 1	; Can be set to true if a part want to finish
flag_end_program	ds.b 1	; When set to true, will quit the program as soon as possible

 even
   
save_ssp     		ds.l 1	; Supervisor Stack Pointer
save_usp     		ds.l 1  ; User Stack Pointer

save_68				ds.l 1  ; HBL handler
save_70      		ds.l 1	; VBL handler
save_120	 		ds.l 1	; HBL handler
save_134	 		ds.l 1	; Timer A

ptr_scr_1   		ds.l 1	; Physical screen
pos_scr_x			ds.w 1  ; STE X offset (relative to ptr_scr_1)
pos_scr_y			ds.w 1  ; STE Y offset (relative to ptr_scr_1)
screen_stride		ds.w 1  ; Complete width of the screen, including extended STE linewidth. Should be used by display code only.
blit_stride			ds.w 1  ; Generally equal to 'screen_stride', but not often. Should be used by drawing routines.

save_palette	 	ds.w 16

 rsreset
_shifter_begin      rs.b 0
shifter_adr_high	rs.b 1
shifter_adr_mid		rs.b 1
shifter_adr_low		rs.b 1
shifter_pixel_skip	rs.b 1
shifter_stride		rs.l 1
_shifter_end		rs.b 0

shifter_data		ds.b (_shifter_end-_shifter_begin)

time_frame			ds.b 1
time_seconds		ds.b 1
time_minutes		ds.b 1
time_hours			ds.b 1

 even
  
 