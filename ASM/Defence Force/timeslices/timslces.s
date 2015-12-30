;
;                Time Slices
;
;      Dbug's STE/Monochrom only demo
;     for the STNICCC 2015 demo party
;          2015, 20th of December
;
;
; In 1990 we had the "3,5 Kb Commodore VIC 20 Times Revisited" competition where people could make anything using no more than 3.5 Kb (Atari ST only). 
; In 2000 we had the "64 Kb Commodore 64 Times Revisited" competition where people could make anything using no more than 64 Kb (any system allowed). 
; Now we have the "128 Kb Commodore 128 Times Revisited" competition where people can make anything using no more than 128 Kb (any system allowed). 
; (Jury members: Tim "Manikin of TLB" Moss, Stefan "Digital Insanity of TLB" Posthuma, Patrick "Mr Bee of OVL" Bricout, others TBA)
;
; max 131,072 bytes storage allowed
; Current usage. 126488 bytes compressed
;
; History:
; - v1.0 released at STNICCC
; - v1.1 with STe detection fix for non standard cookies and monochrome screen detection
;



enable_keep_going     equ 0
enable_start_fast     equ 0
enable_colorhelpers		equ 0

enable_intro_c128       equ 1    ; The C128 boot screen with the easter eggs
enable_intro_logo       equ 1    ; Display the full logo animation
enable_main_part        equ 1    ; The appearance effect of the Defence Force logo
enable_end_sequence     equ 1    ; The final texts


stack_size				set 1500

shift_table_size  		equ 8192*4


KEY_SPACE	 			equ $39 
KEY_ARROW_LEFT	equ $4b
KEY_ARROW_RIGHT equ $4d

LMC_MIXER		  equ %10000000000
LMC_BASS		  equ %10001000000
LMC_TREBLE		equ %10010000000
LMC_MASTERVOL	equ %10011000000
LMC_RIGHTVOL	equ %10100000000
LMC_LEFTVOL		equ %10101000000

 rsreset
blitter_halftone  rs.w 16   ; $ffff8a00 16 words defining a display mask (see blitter_hop)  
blitter_src_xinc  rs.w 1    ; $ffff8a20 offset in bytes to the next source word
blitter_src_yinc  rs.w 1      ; $ffff8a22 offset in bytes to the next source line
blitter_src_addr  rs.l 1      ; $ffff8a24 source adress
blitter_endmask1  rs.w 1      ; $ffff8a28 
blitter_endmask2  rs.w 1      ; $ffff8a2a 
blitter_endmask3  rs.w 1      ; $ffff8a2c 
blitter_dst_xinc  rs.w 1    ; $ffff8a2e destination offset between words
blitter_dst_yinc  rs.w 1      ; $ffff8a30 destination offset between lines
blitter_dst_addr  rs.l 1      ; $ffff8a32 destination adress
blitter_xcount    rs.w 1      ; $ffff8a36 numbers of words
blitter_ycount    rs.w 1      ; $ffff8a38 number of lines
blitter_hop     rs.b 1      ; $ffff8a3a halftone operation (0=all ones, 1=halftone, 2=source, 3=source AND halftone)
blitter_operation rs.b 1      ; $ffff8a3b logical operation (0-15, see BITBLT)
blitter_control   rs.b 1    ; $ffff8a3c 0-3=LineNum (define halftone offset), 5=Smudge, 6=Hog (1=exclusive,0=50/50) 7=Busy(set to start the blitter)
blitter_skew    rs.b 1    ; $ffff8a3d 0-3=shift of data, 6=NoFinalSourceRead, 7=ForceExtraSourceRead

mlinebusy=128+64



; ================================
;         Utility macros
; ================================

SCANLINECHANGE macro
 move.b \1,$ffff8265.w                ; 12/3 shifter pixel scroll
 movep.l \1,-2099(a0)                 ; 24/6 $ffff8205/07/09/0B
 endm

SYNCMARKER_test macro 
 pause \1
 move.w #$0,$ffff8240.w                           ; 16/4
 move.w #$1,$ffff8240.w                           ; 16/4
 endm

SYNCMARKER macro 
 pause \1
 ifne enable_colorhelpers
 move.w #$0,$ffff8240.w                           ; 16/4
 move.w #$1,$ffff8240.w                           ; 16/4
 else
 pause 8
 endc
 endm


SYNCMARKER_REVERSE macro
 ifne enable_colorhelpers
 move.w #$1,$ffff8240.w                           ; 16/4
 move.w #$0,$ffff8240.w                           ; 16/4
 else
 pause 8
 endc
 endm



;  SYNCMARKER_BLITTER 4                             ; 32/8
; 8+3 nop on MSTE
; 8+4 nops on STE
SYNCMARKER_BLITTER macro
 REPT 0
 pause \1
 ifne enable_colorhelpers
 move.w #$1,$ffff8240.w                           ; 16/4
 move.w #$0,$ffff8240.w                           ; 16/4
 else
 pause 8
 endc
 ENDR
 jsr BlitterSteMegaStePause
 endm


pause macro		; Fast mode 
delay set \1
 ifne delay<9
   ifne delay<0
     fail Negative delay in pause macro
   endc
t4 set (delay)/5
t3 set (delay-t4*5)/3
t2 set (delay-t4*5-t3*3)/2
t1 set (delay-t4*5-t3*3-t2*2)
  dcb.w t4,$2e97  ; move.l (a7),(a7)  20/5
  dcb.w t3,$1e97  ; move.b (a7),(a7)  12/3
  dcb.w t2,$8080  ; move.b d0,d0       8/2 (or.l d0,d0)
  dcb.w t1,$4e71  ; nop                4/1
 else 
  ifne delay>100*60
   fail delay
  else
   jsr EndNopTable-2*(delay-9)
  endc
 endc
 endm

pausesafe macro		; Fast mode 
t4 set (\1)/5
t3 set (\1-t4*5)/3
t2 set (\1-t4*5-t3*3)/2
t1 set (\1-t4*5-t3*3-t2*2)
  dcb.w t4,$2e97  ; move.l (a7),(a7)  20/5
  dcb.w t3,$1e97  ; move.b (a7),(a7)  12/3
  dcb.w t2,$8080  ; move.b d0,d0       8/2
  dcb.w t1,$4e71  ; nop                4/1
 endm
  


NOP_TABLE_JMP macro
delay set \1
 jsr EndNopTable-(delay*2)        ; 9 nops just for the jsr/rts doing nothing (jsr=20/5    rts=16/4)
 endm

; 1=filename
; 2=start label
; 3=end label (optional)
FILE macro
 even
\2
 incbin \1
 ifne NARG-3
\3
 endc
 even
 endm
 

PRNLOOP macro 
 add.l d0,d0      ; shift left 1 bit
 bcc.s .\@        ; branch if bit 32 not set
 eor.b d1,d0      ; do galois LFSR feedback
.\@
 endm


 opt o+,w-
  
 SECTION TEXT
   
; ------------------
;   Program start
; ------------------
ProgStart 
 ; Call the main routine in supervisor mode
 move.l #SupervisorMain,-(sp)
 move.w #$26,-(sp)
 trap #14
 addq.w #6,sp

 ; Quit
 clr.w -(sp)
 trap #1
 

;
; This machine is not a STE/MSTE (Should check monochrome as well)
;
UnsupportedMachine
 pea NotASteMessage
 move #9,-(sp)
 trap #1
 addq #6,sp
 
 ; wait key
 move #7,-(sp)
 trap #1
 addq #2,sp
 rts



SupervisorMain
 ;
 ; This has to be done first, else we will lose data
 ; We need to start by clearing the BSS in case of some packer let some crap
 ;
 lea bss_start,a0					
 lea bss_end,a1 
 moveq #0,d0
.loop_clear_bss
 move.l d0,(a0)+
 cmp.l a1,a0
 ble.s .loop_clear_bss

 ;
 ; We need to know on which machine we are running the intro.
 ; We accept STE and MegaSTE as valid machines.
 ; Anything else will have a nice message telling them to "upgrade" or use an emulator :)
 ;
 move.l	$5a0.w,d0
 beq.s UnsupportedMachine		; No cookie, this is definitely not a STe or MegaSTe

 sf machine_is_ste
 sf machine_is_megaste

 move.l	d0,a0
.loop_cookie	
 move.l (a0)+,d0			; Cookie descriptor
 beq.s UnsupportedMachine
 move.l (a0)+,d1			; Cookie value
 
 cmp.l #"CT60",d0
 beq.s UnsupportedMachine	; We do not run on Falcon, accelerated or not
 cmp.l #"_MCH",d0
 bne.s .loop_cookie
 
.found_machine	
 cmp.l #$00010010,d1
 beq.s .found_mste
 sf.b d1
 cmp.l #$00010000,d1
 beq.s .found_ste
 bra.s UnsupportedMachine	; We do not run on TT

.found_mste
 st machine_is_megaste 
.found_ste 
 st machine_is_ste
  
 cmp.b #2,$ffff8260.w
 bne UnsupportedMachine                 ; We only run in high resolution
 
 ;
 ; Save all the hardware addresses we are going to modify
 ; 
 move #$2700,sr
 
 ;
 ; Can now safely save the stack pointer and allocate our own stack.
 ;
 move.l sp,save_ssp
 lea my_stack,sp          

 move.l usp,a0							; Need to save USP in case of a not totaly regular usage ;)
 move.l a0,save_usp

 move.b $fffffa07.w,save_iera
 sf $fffffa07.w	; iera

 move.b $fffffa09.w,save_ierb
 sf $fffffa09.w	; ierb

 move.b $fffffa13.w,save_imra
 sf $fffffa13.w ; imra

 move.b $fffffa15.w,save_imrb
 sf $fffffa15.w ; imrb

 move.b $ffff820a.w,save_freq
 move.b $ffff8260.w,save_rez
 move.b $ffff8265.w,save_pixl

 move.b $ffff8201.w,save_screen_addr_1	; Screen base pointeur (STF/E)
 move.b $ffff8203.w,save_screen_addr_2	; Screen base pointeur (STF/E)
 move.b $ffff820d.w,save_vbaselo		    ; Save low byte (STE only)
 
 move.b $ffff820f.w,save_linewidth
 
 movem.l $ffff8240.w,d0-d7				      ; STF/STE Palette
 movem.l d0-d7,save_palette
 move.w #1,$ffff8240.w

 lea $ffff8a00.w,a5                     ; Constant blitter parameters
 move #$ffff,blitter_endmask1(a5)
 move #$ffff,blitter_endmask2(a5)
 move #$ffff,blitter_endmask3(a5)
 move.b #0,blitter_skew(a5)
 move.b #3,blitter_operation(a5)        ; Use source
 move #2,blitter_src_xinc(a5)           ; Number of bytes to move to the next word of each line

 move.l $70.w,save_70					          ; Save original VBL handler
 move.l #VblFlipFlop,$70.w      		    ; New VBL handler
 
 tst.b machine_is_megaste
 beq.s .end_specific 
 move.b $ffff8e21.w,save_mste_cache 	; On mste we need to save the cache value and force to 8mhz
 move.b #%00,$ffff8e21.w	            ; 8mhz without cache
 move.w #$4e75,_SteDelayPatch           ; Replace a NOP by a RTS to be one nop faster
.end_specific

 ;
 ; Set the screen at the right adress
 ;
 lea $ffff8201.w,a0               ; Screen base pointeur (STF/E)
 move.l #screen_buffer+256,d0
 clr.b d0
 move.l d0,ScreenBufferBase      ; Save the aligned screen address
 move.l d0,d1
 lsr.l #8,d0					           ; Allign adress on a byte boudary for STF compatibility
 sf.b 12(a0)					           ; For STE low byte to 0

 move.b #80/2,$ffff820f.w       ; Line width (number of words to skip)
 move.l d1,ScreenPointerByte
 move.w #0,ScreenPositionX
 move.w #0,ScreenPositionY
 bsr ComputeVideoParameters
    
 ; Initialize the audio output mixing to known values (need to run with IRQs off)
Mixer 
 lea MixerTable,a0
 moveq #(MixerTableEnd-MixerTable)/2-1,d7
 opt o-
.loop_set_mixer 
 move.w (a0)+,d0            ; d0=data to send
 move.w #%11111111111,$ffff8924.w           ;set microwiremask
 move.w d0,$ffff8922.w
.waitstart
 cmpi.w #%11111111111,$ffff8924.w           ;wait formicrowire write to start
 beq.s .waitstart
.waitend
 cmpi.w #%11111111111,$ffff8924.w           ;wait for microwire write to finish
 bne.s .waitend
 dbra d7,.loop_set_mixer 
 opt o+

 bsr KeyboardFlushBuffer
 move #$2300,sr

 ; -----------------------------------------
 ;
 ; Show the Commodore 128 picture on the screen while we decompress stuff
 ;
 ; -----------------------------------------
 move.l #$ffffffff,d0
 move.l ScreenBufferBase,a0
 bsr FillScreenBuffer

 lea picture_c128_flip,a0
 move.l ScreenBufferBase,a1
 add.l #80*2*26+10,a1
 move.w #348,d0
 move.w #60/2,d1
 move.w #2+60,d2
 move.w #2+80*2-60,d3
 bsr BlitFlipPictureToLargeScreen

 ;
 ; Decompress the chunks of music (takes quite some time)
 ;
 ; Depack audio 
 lea dmaplay_addresstable,a2

 lea UnpackedMusicBuffer,a1

 ; The uncompressed snippets (vocals)
 move.l #unpacked_music_sample_1,(a2)+
 move.l #unpacked_music_sample_2,(a2)+

 move.l #unpacked_music_sample_2,(a2)+
 move.l #unpacked_music_sample_3,(a2)+

 move.l #unpacked_music_sample_3,(a2)+
 move.l #unpacked_music_sample_4,(a2)+

 ; Then the compressed data
 move.l a1,(a2)+
 lea packed_music_sample_1,a0
 move.l #packed_music_sample_2-packed_music_sample_1,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_2,a0
 move.l #packed_music_sample_3-packed_music_sample_2,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_3,a0
 move.l #packed_music_sample_4-packed_music_sample_3,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_4,a0
 move.l #packed_music_sample_5-packed_music_sample_4,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_5,a0
 move.l #packed_music_sample_6-packed_music_sample_5,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_6,a0
 move.l #packed_music_sample_7-packed_music_sample_6,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_7,a0
 move.l #packed_music_sample_8-packed_music_sample_7,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_8,a0
 move.l #packed_music_sample_9-packed_music_sample_8,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_9,a0
 move.l #packed_music_sample_10-packed_music_sample_9,d0
 bsr DepackDelta
 move.l a1,(a2)+

 move.l a1,(a2)+
 lea packed_music_sample_10,a0
 move.l #packed_music_sample_11-packed_music_sample_10,d0
 bsr DepackDelta
 move.l a1,(a2)+

 ; Keyclick
 lea packed_chatroom_sample_start,a0
 lea chatroom_sample_start,a1
 move.l #packed_chatroom_sample_end-packed_chatroom_sample_start,d0
 bsr DepackDelta

 ;
 ; Convert the STNICCC logo to blitter compatible format
 ;
 ; picture_stniccc_logo -> expanded_stnicccc_logo
 lea picture_stniccc_logo,a0				; Source
 lea expanded_stnicccc_logo,a1			; Target

 move.w #225-1,d0
.loop_scanline
 ; Fetch the two unaligned bytes (thanks pbm format)
 move.b (a0)+,d7
 rol.w #8,d7
 move.b (a0)+,d7

 ; Convert the 16 pixels to 16 word values
 moveq #16-1,d1
.loop_shift 
 moveq.l #0,d6
 roxl.w #1,d7
 roxl.w #1,d6
 move.w d6,(a1)+

 dbra d1,.loop_shift
 move.w #1,-2(a1)       ; No matter what, we need some clearing pixel at the end

 dbra d0,.loop_scanline


 ; -----------------------------------------
 ;
 ;    C128 boot/loading intro sequence
 ; 
 ; -----------------------------------------
 ifne enable_intro_c128

 ; Wait one second
 move.w #70,d0
 bsr WaitDelay

 move.l #80*2,message_screen_width
 move.l #0,message_screen_offset
 move.l #VblDoNothing,$70.w

 ; Garbage Petscii
 ; c64_charset_128x128 (8x8 characters, 16 rows and 16 columns)
 ; 640x400 resolution = 80 characters wide and 50 lines
 ; screen_buffer -> ScreenPointerByte
 move.l ScreenPointerByte,a0
 moveq #$AF-$100,d1		; set EOR value

 move #50-1,d6
.loop_line 
 move.l a0,a1
 lea 80*2*8(a0),a0

 move #80-1,d7
.loop_row
 PRNLOOP
 move.l d0,d2
 lea c64_charset_128x128,a2
 and #15,d2
 add d2,a2

 move.l d0,d2
 lsr #4,d2
 and #15,d2
 mulu #16*8,d2
 add d2,a2

 move.l d0,d2
 lsr #5,d2
 and #1,d2
 moveq #0,d4
 sub d2,d4

var set 0
 rept 8
 move.b var*16(a2),d3
 eor.b d4,d3
 move.b d3,var*80*2(a1)
var set var+1  
 endr 
 addq #1,a1
 dbra d7,.loop_row
 dbra d6,.loop_line

 ; Wait one second
 move.w #70,d0
 bsr WaitDelay

 ;
 ; Copyright message sequence
 ;
 bsr EraseScreenC128

 lea MessageBoot1,a0

 moveq #21,d0
 bsr PrintMessage2   ; COMMODORE BASIC V7.0 122365 BYTES FREE

 moveq #23,d0
 bsr PrintMessage2   ;  (C) 1985 COMMODORE ELECTRONICS, LTD.

 moveq #29,d0
 bsr PrintMessage2   ;        (C) 1977 MICROSOFT CORP.

 moveq #31,d0
 bsr PrintMessage2   ;          ALL RIGHTS RESERVED

 moveq #3-1,d7
 bsr ShowReadyMessageC128

 ;
 ; Now we enter the command to enter the easter egg screen
 ;
 move.l #SlowClick,PrintMessageCallback+2

 lea MessageStartEaster,a0
 moveq #0,d0
 bsr PrintMessage2

 move.l #DoNothing,PrintMessageCallback+2

 move #70,d0
 bsr WaitDelay

 bsr PlayRandomClickSound

 ;
 ; Name credits page
 ;
 bsr EraseScreenC128

 lea MessageEaster1,a0

 moveq #0,d0
 bsr PrintMessage2 	 ; Brought to you by...

 moveq #0,d0
 bsr PrintMessage2   ; Software:

 moveq #1,d0
 bsr PrintMessage2   ;  Fred Bowen

 moveq #1,d0
 bsr PrintMessage2   ;  Terry Ryan

 moveq #1,d0
 bsr PrintMessage2   ;  Von Ertwine

 moveq #0,d0
 bsr PrintMessage2   ; Herdware:

 moveq #1,d0
 bsr PrintMessage2   ;  Bill Herd

 moveq #1,d0
 bsr PrintMessage2   ;  Dave Haynie

 moveq #1,d0
 bsr PrintMessage2   ;  Frank Palaia

 moveq #0,d0
 bsr PrintMessage2   ; Link arms, don't make them

 moveq #0,d0
 bsr PrintMessage2   ; ready.

 ; Wait three seconds
 move #70*4,d0
 bsr WaitDelay

 bsr PlayRandomClickSound

 bsr EraseScreenC128

 ; Show Floppy Message C128
 move.l ScreenPointerByte,message_screen_ptr

 lea MessageDirectory1,a0

 move.l #SlowClick,PrintMessageCallback+2
 moveq #0,d0
 bsr PrintMessage2   ; LOAD
 move.l #DoNothing,PrintMessageCallback+2

 moveq #0,d0
 bsr PrintMessage2   ; SEARCHING

 move #70*2,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; LOADING

 move #70*2,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; READY

 move.l #SlowClick,PrintMessageCallback+2
 moveq #0,d0
 bsr PrintMessage2   ; LIST
 move.l #DoNothing,PrintMessageCallback+2

 ; Show the directory content
 lea MessageFloppy1,a0

 moveq #0,d0
 bsr PrintMessage2   ; Title

 move #10,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; Disk entry

 move #10,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; Disk entry

 move #10,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; Disk entry

 move #10,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; Disk entry

 move #10,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; Disk entry

 move #10,d0
 bsr WaitDelay

 moveq #3-1,d7
 bsr ShowReadyMessageC128

 lea MessageLoad,a0
 move.l #SlowClick,PrintMessageCallback+2
 moveq #0,d0
 bsr PrintMessage2   ; LOAD
 move.l #DoNothing,PrintMessageCallback+2

 move #70,d0
 bsr WaitDelay

 moveq #0,d0
 bsr PrintMessage2   ; Searching for...

 move #70*2,d0
 bsr WaitDelay

 lea MessageDirectory3,a0
 moveq #0,d0
 bsr PrintMessage2   ; Loading

 move #70*5,d0
 bsr WaitDelay

 moveq #3-1,d7
 bsr ShowReadyMessageC128

 lea MessageRun,a0
 move.l #SlowClick,PrintMessageCallback+2
 moveq #0,d0
 bsr PrintMessage2   ; RUN
 move.l #DoNothing,PrintMessageCallback+2

 endc

 ; -----------------------------------------
 ;
 ;                 Main part
 ;
 ; -----------------------------------------
 ifne enable_main_part
 ; Generate pixel shifting/address table
 lea TableValueToShift,a0
 moveq #0,d1
 move.w #shift_table_size-1,d0           ; 4096
.loop_shift_table
 move.l d1,d2
 and.l #15,d2
 move.l d1,d3   ; fedcba9876543210
 and.b #$F0,d3  ; fedcba987654----
 lsl.l #5,d3    ; a987654---------
 move.b d2,d3 
 move.l d3,(a0)+
 addq.l #1,d1
 dbra d0,.loop_shift_table 

 
 ; Generate scroll text
 moveq #0,d0
 move.l #MessageScrollerSize+80,message_screen_width
 move.l #ScrollerBuffer+80,message_screen_ptr
 lea MessageScroller,a0
 bsr PrintMessage2

 ; Generate scroll text (Greetings)
 moveq #0,d0
 move.l #MessageScrollerGreetingSize+80,message_screen_width
 move.l #ScrollerGreetingBuffer+80,message_screen_ptr
 lea MessageScrollerGreeting,a0
 bsr PrintMessage2

 ; Generate scroll text (Design)
 moveq #0,d0
 move.l #MessageScrollerDesignSize+80,message_screen_width
 move.l #ScrollerDesignBuffer+80,message_screen_ptr
 lea MessageScrollerDesign,a0
 bsr PrintMessage2

 ; Generate scroll text (Credits)
 moveq #0,d0
 move.l #MessageScrollerCreditsSize+80,message_screen_width
 move.l #ScrollerCreditsBuffer+80,message_screen_ptr
 lea MessageScrollerCredits,a0
 bsr PrintMessage2

 ; GenerateBigScrollPicture
 ;
 ; The picture is 2x2 screens  in size.
 ; There are two of these so we can flicker between to create grey colors.
 ; Each of the buffer is 32*4=128kb
 ; C128 on the bottom right
 move.l #$ffffffff,d0
 move.l ScreenBufferBase,a0
 add.l #32000*2+80,a0
 bsr FillScreenBuffer

 lea picture_c128_flip,a0
 move.l ScreenBufferBase,a1
 add.l #80*2*26+10+32000*2+80,a1
 move.w #348,d0
 move.w #60/2,d1
 move.w #2+60,d2
 move.w #2+80*2-60,d3
 bsr BlitFlipPictureToLargeScreen

 ; Beats on the top right
 move.l #$ffffffff,d0
 move.l ScreenBufferBase,a0
 add.l #80,a0
 bsr FillScreenBuffer

 lea picture_logo_bslappaz,a0
 move.l ScreenBufferBase,a1
 add.l #80*2*50+80+6,a1
 move.w #299,d0
 move.w #68/2,d1
 move.w #2,d2
 move.w #2+80*2-68,d3
 bsr BlitPictureToLargeScreen
 add.l #32000*4,a1
 bsr BlitPictureToLargeScreen

 ; Punks on the bottom left
 move.l #$ffffffff,d0
 move.l ScreenBufferBase,a0
 add.l #32000*2,a0
 bsr FillScreenBuffer

 lea picture_logo_punks,a0
 move.l ScreenBufferBase,a1
 add.l #80*2*103+32000*2+6,a1
 move.w #194,d0
 move.w #68/2,d1
 move.w #2,d2
 move.w #2+80*2-68,d3
 bsr BlitPictureToLargeScreen
 add.l #32000*4,a1
 bsr BlitPictureToLargeScreen


 ; Fill the screen in white
 ifne enable_intro_logo
 bsr EraseScreenTopBottom
 endc

 lea dmaplay_sequence,a0
 move.l a0,_AdrDmaPlayPosition
 move.l a0,_AdrDmaPlayStart
 move.l #dmaplay_addresstable,_AdrDmaAddressTable
 move.w #1,dmaplay_waitcounter
 move.w #0,DmaPlayPosition

 move.l #VblFlipFlopWithAudio,$70.w


 ifne enable_intro_logo
 ; Fade in with dithering
 move #150-1,d0
.loop_logo
 bsr WaitVbl
 bsr DisplayDefenceForceLogo
 add #1,fading_pos
 dbra d0,.loop_logo
 bsr WaitVbl
 bsr DisplayDefenceForceLogo

 ; Show Beats logo
 bsr WaitNextSample
 move.w #640,ScreenPositionX
 bsr WaitNextSample

 ; Show Punks logo
 bsr WaitNextSample
 move.w #0,ScreenPositionX
 move.w #400,ScreenPositionY
 bsr WaitNextSample

 ;bsr WaitSpace

 else
 ; Just show the logo
 move.l #$0,d0
 move.l ScreenBufferBase,a0
 bsr FillScreenBuffer

 move.w #149,fading_pos
 bsr WaitVbl
 bsr DisplayDefenceForceLogo
 bsr WaitVbl
 bsr DisplayDefenceForceLogo
 endc

 ;
 ; The main effect with the bouncing picture
 ;
 bsr MainEffect

 ; Show the final picture with the impact logo
 move.w #0,ScreenPositionX
 move.w #0,ScreenPositionY
 move.b #80/2,$ffff820f.w       ; Line width (number of words to skip)
 move.l ScreenBufferBase,ScreenPointerByte
 move.l ScreenBufferBase,message_screen_ptr
 bsr ComputeVideoParameters 

 ifne enable_end_sequence

 bsr WaitNextSample

 ; Display the messages
 ; Time Slices
 ; by
 ; Defence Force
 ; at
 ; ST News International Christmas Coding Competition 2015
 ; Commodore 128 Revisited
 move.l #80*2,message_screen_width
 move.l #32000*4,message_screen_offset

 lea MessageCredits1,a0

 moveq #1,d0
 add.l #10*(80*2),message_screen_ptr
 bsr PrintMessage2 	 ; "Time Slices"

 moveq #1,d0
 add.l #30*(80*2),message_screen_ptr
 bsr PrintMessage2 	 ; contribution

 bsr WaitNextSample

 moveq #34,d0
 add.l #300*(80*2),message_screen_ptr
 bsr PrintMessage2 	 ; C128 revisited

 moveq #24,d0
 add.l #30*(80*2),message_screen_ptr
 bsr PrintMessage2 	 ; stniccc

 bsr WaitNextSample

 bsr DisplayImpact

 move.w #70*6,d0
 bsr WaitDelay

 ; Temp
 ;bsr WaitSpace
 endc

 ; Wait one second
 ;move.w #70*3,d0
 ;bsr WaitDelay
 ;bsr WaitSpace

 move.l #VblDoNothing,$70.w
 endc

 ;
 ; Restore everything
 ;
 move #$2700,sr

 move.l save_usp,a0
 move.l a0,usp

 clr.b $ffff8901.w   				; Stop DMA audio replay

 move.b save_iera,$fffffa07.w
 move.b save_ierb,$fffffa09.w
 move.b save_imra,$fffffa13.w
 move.b save_imrb,$fffffa15.w

 move.b save_freq,$ffff820a.w
 move.b save_rez,$ffff8260.w
 move.b save_pixl,$ffff8265.w

 move.b save_screen_addr_1,$ffff8201.w
 move.b save_screen_addr_2,$ffff8203.w
 move.b save_vbaselo,$ffff820d.w
 
 move.b save_linewidth,$ffff820f.w
 
 movem.l save_palette,d0-d7
 movem.l d0-d7,$ffff8240.w

 move.l save_70,$70.w

 ;
 ; System specific load
 ;
 tst.b machine_is_megaste
 beq.s .end_specific 
 move.b save_mste_cache,$ffff8e21.w
.end_specific
 
 bsr KeyboardFlushBuffer

 move #$2300,sr
  
 move.l save_ssp,sp
 rts  



VblFlipFlopWithAudio
 opt o-

 ; DmaSequencePlayerVbl 
 subq.w #1,dmaplay_waitcounter
 bne.s VblFlipFlop
 
;.next_sequence
 move.l a6,-(sp)
 move.l d0,-(sp)
 move.l d1,-(sp)
 
_AdrDmaPlayPosition=*+2 
 lea $123456,a6
 moveq.l #0,d0 ; maybe this could be removed for optimization?
 move.b (a6),d0
 bpl.s .continue

.loop
 ; Stop the song
 move.l #VblFlipFlop,$70.w
 bra.s continue_audio_vbl

 ;loop the song
_AdrDmaPlayStart=*+2 
 lea $123456,a6
 move.l a6,_AdrDmaPlayPosition
 move.b (a6),d0

.continue
 lsl.w #3,d0
_AdrDmaAddressTable=*+2 
 lea $123456,a6
 move.l 4(a6,d0.l),d1       ; End address
 move.l (a6,d0.l),d0        ; Start address
 
 ; Stop the sample
 lea $ffff8901.w,a6
 sf.b (a6)					; $ffff8901.w DMA control (0=stop, 1=play once, 2=loop)

 ; Set the new adress
 movep.l d0,(a6)            ; Start address
 movep.l d1,$0d-1(a6)       ; End address
 move.b #128,$21-1(a6)	    ; $ffff8921.w DMA mode (128=mono) (0=6258,1=12517,2=25033,3=50066)
 move.b #1,(a6)				      ; $ffff8901.w DMA control (0=stop, 1=play once, 2=loop)

 sub.l d0,d1                ; Number of bytes in this block
 divu #88,d1
 move.w d1,dmaplay_waitcounter
 add.w #1,DmaPlayPosition

 addq.l #1,_AdrDmaPlayPosition
continue_audio_vbl
 move.l (sp)+,d1
 move.l (sp)+,d0
 move.l (sp)+,a6
 opt o+

VblFlipFlop
 eor.b #1,flip_flop
 bsr ComputeVideoParameters
VblDoNothing
 st flag_vbl
 rte

WaitNextSample
 move.w DmaPlayPosition,d0
.loop
 bsr WaitVbl
 cmp.w DmaPlayPosition,d0
 beq.s .loop
 rts
       
WaitDelay 
 bsr WaitVbl
 dbra d0,WaitDelay
DoNothing
 rts

 
WaitVbl
 sf flag_vbl
SyncVbl
.loop
 tst.b flag_vbl
 beq.s .loop
 sf flag_vbl
 rts

 
 ; Flip flop between two buffers, with eventual x/y offset
ComputeVideoParameters
 movem.l d0-a6,-(sp)

 move.l ScreenBufferBase,d0

 ; Add the Y offset
 moveq #0,d1
 move.w ScreenPositionY,d1
 mulu #80*2,d1
 add.l d1,d0

 tst.b flip_flop
 beq .skip_flip
 add.l #32000*4,d0
.skip_flip

 lsl.l #8,d0

 lea TableValueToShift,a3                         ; 12/3
 moveq #0,d1
 move.w ScreenPositionX,d1
 add.w d1,d1
 add.w d1,d1
 add.l (a3,d1),d0     

 move.l d0,ScreenPointerPixel
 move.b d0,d1
 lsr.l #8,d0
 move.l d0,ScreenPointerByte

 tst.b flag_skip_shifter
 bne .skip_shifter_update
 move.b d1,$ffff8265.w          ; STE - Shifter pixel scroll
 move.b d0,d1
 lsr.l #8,d0
 move.b d0,$ffff8203.w			; STF - Screen base adress (mid byte)
 lsr.w #8,d0
 move.b d0,$ffff8201.w			; STF - Screen base adress (high byte)
 move.b d1,$ffff820d.w			; STE - Screen base adress (low byte)
.skip_shifter_update  
 movem.l (sp)+,d0-a6
 rts
 

; d0=fillvalue
; a0=base pointer
FillScreenBuffer
 move.l a0,a1
 add.l #32000*4,a1
 move.w #400-1,d6
.loop_fill_buffer_outer
 moveq #80/4-1,d7
.loop_fill_buffer_inner
 move.l d0,(a0)+
 move.l d0,(a1)+
 dbra d7,.loop_fill_buffer_inner
 lea 80(a0),a0
 lea 80(a1),a1
 dbra d6,.loop_fill_buffer_outer
 rts


EraseScreenC128
 move.l ScreenPointerByte,a0
 move.l a0,message_screen_ptr

 move #400/8-1,d0
.loop_y
 move #80*8*2-1,d1 
.loop_x
 move.b #255,(a0)+
 dbra d1,.loop_x

 bsr WaitVbl

 dbra d0,.loop_y

 rts


EraseScreenTopBottom
 move.l ScreenBufferBase,a0
 move.l a0,a2
 add.l #32000*4,a2

 move.l a0,a1
 add.l #64000,a1

 move.l a2,a3
 add.l #64000,a3

 move #200-1,d0
.loop_y
 lea -80(a1),a1
 lea -80(a3),a3

 move #80-1,d1 
.loop_x
 move.b #0,(a2)+
 move.b #0,(a0)+
 move.b #0,-(a1)
 move.b #0,-(a3)

 dbra d1,.loop_x

 bsr WaitVbl

 lea 80(a0),a0
 lea 80(a2),a2

 dbra d0,.loop_y

 rts

  
; jsr abs.l => 20/5 cycles 
; jsr EndNopTable + rts = 5+4=9 nops
NopTable
 dcb.w 100*60,$4e71    ; 4/1   x100
EndNopTable 
 rts				; 16/4
   

  
; a0 = message
; d0 = x coordinate
; message_screen_ptr=scanline screen location
PrintMessage2
 movem.l d1/d2/d3/d4/d5/a1/a2/a3,-(sp)

 move.l message_screen_offset,d5
 move.l message_screen_ptr,a1
 add d0,a1

 moveq #0,d4
print_message_loop
 moveq #0,d1
 move.b (a0)+,d1
 beq print_message_end

 cmp #1,d1
 bne .no_carriage_return
 add.l #160*8*2,message_screen_ptr
 add.l #160*8*2,a1 
 bra print_message_loop
.no_carriage_return

 cmp #255,d1
 bne .no_invert
 eor #255,d4
 bra print_message_loop
.no_invert

 sub #32,d1

 move.l d1,d2
 lea c64_charset_128x128,a2
 and #15,d2
 add d2,a2

 move.l d1,d2
 lsr #4,d2
 and #15,d2
 mulu #16*8,d2
 add d2,a2

 move.l a1,a3
var set 0
 rept 8
 move.b var*16(a2),d3
 eor.b d4,d3
 move.b d3,(a3)
 move.b d3,(a3,d5.l)
 add.l message_screen_width,a3
 move.b d3,(a3)
 move.b d3,(a3,d5.l)
 add.l message_screen_width,a3
var set var+1  
 endr 
 addq #1,a1
 addq #1,d0

 opt o-
PrintMessageCallback
 jsr DoNothing
 opt o+

 bra print_message_loop

print_message_end
 movem.l (sp)+,d1/d2/d3/d4/d5/a1/a2/a3
 rts


; a0=Source (compressed) data
; a1=Destination buffer 
; d0.l=source sample size
DepackDelta
 movem.l d0/d1/d2/a2,-(sp)

 subq.l #1,d0

 lea DepackDeltaTable,a2
 move.b (a0)+,d1	; Start value
 eor.b #$80,d1		; Sign change
 move.b d1,(a1)+

 moveq #0,d2
.loop 
 REPT 4
 move.b (a0)+,d2	; Fetch two nibbles
 
 add.b (a2,d2),d1
 move.b d1,(a1)+

 lsr #4,d2
 add.b (a2,d2),d1
 move.b d1,(a1)+
 ENDR
 
 subq.l #4,d0
 bpl.s .loop
   
 movem.l (sp)+,d0/d1/d2/a2
 rts
 
 
KeyboardFlushBuffer
 btst.b #0,$fffffc00.w			; Have we some keys to wait for ?
 beq.s .exit
 tst.b $fffffc02.w
 bra.s KeyboardFlushBuffer
.exit
 rts
  

WaitSpace
 bsr KeyboardFlushBuffer
.loop_wait
 btst #0,$fffffc00.w
 beq .loop_wait
 cmp.b #KEY_SPACE,$fffffc02.w
 beq .loop_wait 
 rts



; a0 - source picture (either simple or double flip)
; a1 - target location (big screen)
; d0 - number of scanlines
; d1 - width of the graphics in words
; d2 - Source line skip
; d3 - Target line skip
BlitFlipPictureToLargeScreen
 bsr BlitPictureToLargeScreen
 add d1,a0
 add d1,a0
 add.l #32000*4,a1
BlitPictureToLargeScreen
 lea $ffff8a00.w,a5
 move.w d0,blitter_ycount(a5)        ; Number of lines to draw
 move.w d1,blitter_xcount(a5)        ; Number of words to copy each line

 move.l a0,blitter_src_addr(a5)      ; Source data
 move.l a1,blitter_dst_addr(a5)      ; Target

 move.w d2,blitter_src_yinc(a5)      ; Number of bytes to move to the next line of the source
 move.w d3,blitter_dst_yinc(a5)      ; Number of bytes to move to the next line of the target

 move.w #2,blitter_dst_xinc(a5)

 move.b #2,blitter_hop(a5)

 move.b #mlinebusy,blitter_control(a5)
 rts




; COMMODORE BASIC V7.0 122365 BYTES FREE
;  (C) 1985 COMMODORE ELECTRONICS, LTD.
;        (C) 1977 MICROSOFT CORP.
;          ALL RIGHTS RESERVED
;
; READY.
; []

; d7=blink count
ShowReadyMessageC128
 lea MessageReady,a0

 moveq #0,d0
 bsr PrintMessage2   ; READY.

 moveq #0,d0
 bsr PrintMessage2   ; []

 ;
 ; Wait a bit
 ;
.loop_wait 
 lea MessageBootCursorOn,a0
 moveq #0,d0
 bsr PrintMessage2

 move #70,d0
 bsr WaitDelay

 lea MessageBootCursorOff,a0
 moveq #0,d0
 bsr PrintMessage2

 move #70,d0
 bsr WaitDelay

 dbra d7,.loop_wait
 rts



; RND(n), 32 bit Galois version. make n=0 for 19th next number in
; sequence or n<>0 to get 19th next number in sequence after seed n.  
; This version of the PRNG uses the Galois method and a sample of
; 65536 bytes produced gives the following values.
;
; Entropy = 7.997442 bits per byte
; Optimum compression would reduce these 65536 bytes by 0 percent
;
; Chi square distribution for 65536 samples is 232.01, and
; randomly would exceed this value 75.00 percent of the time
;
; Arithmetic mean value of data bytes is 127.6724, 127.5 = random
; Monte Carlo value for Pi is 3.122871269, error 0.60 percent
; Serial correlation coefficient is -0.000370, uncorrelated = 0.0
;
; Uses d0/d1/d2
NextPRN
 moveq #$AF-$100,d1   ; set EOR value
 moveq #18,d2     ; do this 19 times
 move.l Prng32,d0   ; get current 
.ninc0
 add.l d0,d0      ; shift left 1 bit
 bcc.s .ninc1     ; branch if bit 32 not set

 eor.b d1,d0      ; do galois LFSR feedback
.ninc1
 dbra d2,.ninc0     ; loop

 move.l d0,Prng32   ; save back to seed word
 RTS



IRC_MASK_RANDOM_INPUT	equ 7		; Power of two-1
IRC_MIN_DELAY_INPUT		equ 4

SlowClick
 movem.l d0-a6,-(sp)

 bsr PlayRandomClickSound

 bsr NextPRN
 and #IRC_MASK_RANDOM_INPUT,d0
 add #IRC_MIN_DELAY_INPUT,d0
 bsr WaitDelay

 movem.l (sp)+,d0-a6
 rts


PlayRandomClickSound
 movem.l d0-a6,-(sp)
 
 bsr NextPRN
 and #3,d0
 add d0,d0
 add d0,d0
 lea TableKeyboardSounds,a2
 add d0,a2
 
 lea chatroom_sample_start,a0
 move.l a0,a1
 add (a2)+,a0
 add (a2)+,a1
 
; StartReplay 
; Audio DMA issues here:
; http://atari-ste.anvil-soft.com/html/devdocu4.htm 
; a0=sample start
; a1=sample end
; return d0=approximate duration in VBLs
 move.l a1,d0
 sub.l a0,d0        ; Size in bytes
 lsr.l #8,d0        ; /256 (12517 khz=12517 bytes per second=250.34 bytes per VBL)
 
 move.l a0,d1       ; Start adress
 
 lea $ffff8900.w,a0
 
 move.b d1,$7(a0)     ; $ffff8907.w Dma start adress (low)
 lsr.l #8,d1
 move.b d1,$5(a0)     ; $ffff8905.w Dma start adress (mid)
 lsr.l #8,d1
 move.b d1,$3(a0)     ; $ffff8903.w Dma start adress (high)

 move.l a1,d1       ; End adress
 move.b d1,$13(a0)      ; $ffff8913.w Dma end adress (low)
 lsr.l #8,d1
 move.b d1,$11(a0)      ; $ffff8911.w Dma end adress (mid)
 lsr.l #8,d1
 move.b d1,$f(a0)     ; $ffff890f.w Dma end adress (high)
   
 move.b #1+128,$21(a0)    ; $ffff8921.w DMA mode (128=mono) (0=6258,1=12517,2=25033,3=50066)
 move.b #1,$1(a0)     ; $ffff8901.w DMA control (0=stop, 1=play once, 2=loop)
 
 movem.l (sp)+,d0-a6
 rts 
 

 

 


; 160x186=20*186
; 20 bytes per line=5 registers
DisplayImpact
 lea picture_impact,a0          ; First picture
 move.l ScreenBufferBase,a1
 add.l #80*2*(400-186),a1
 move.w #186,d0
 move.w #20/2,d1
 move.w #2+20,d2
 move.w #2+80*2-20,d3
 bra BlitFlipPictureToLargeScreen


DisplayDefenceForceLogo
 movem.l d0-a6,-(sp)
 ; initialise_blitter_logo
 lea $ffff8a00.w,a5
 move #72/2,blitter_xcount(a5)       ; Number of words to copy each line
 move #246,blitter_ycount(a5)	     ; Number of lines

 move #2+72,blitter_src_yinc(a5)	 ; Number of bytes to move to the next line

 move #2,blitter_dst_xinc(a5)
 move #2+80*2-72,blitter_dst_yinc(a5)

 move.l #picture_logo_defenceforce,d0
 tst.b flip_flop
 beq .skip_flip
 add.l #72,d0
.skip_flip 
 move.l d0,blitter_src_addr(a5)

 move.l ScreenPointerByte,d0
 add.l #2*80*76+4,d0
 move.l d0,blitter_dst_addr(a5)

 move.b #3,blitter_hop(a5)  **

 lea dithering_animation,a0        150 phases de 32 octets
 move fading_pos,d0
 lsl #5,d0
 add.w d0,a0
 movem.l (a0),d0-d7    En une seule passe, le buffer de motifs est recopi‚.
 movem.l d0-d7,(a5)

 move.b #mlinebusy,blitter_control(a5)
 movem.l (sp)+,d0-a6
 rts



;
; Big picture move
;
MoveBigPicture
 move.w ScreenPositionX,d0
 move.w BigScrollingPictureIncX,d1
 move.w #640,d2
 bsr BigPictureHandleMovement
 move.w d0,ScreenPositionX
 move.w d1,BigScrollingPictureIncX

 move.w ScreenPositionY,d0
 move.w BigScrollingPictureIncY,d1
 move.w #400,d2
 bsr BigPictureHandleMovement
 move.w d0,ScreenPositionY
 move.w d1,BigScrollingPictureIncY
 rts

BigPictureHandleMovement 
 add.w d1,d0
 bmi.s .overflow
 cmp.w d2,d0
 bpl.s .overflow
 rts
.overflow
 neg.w d1
 add.w d1,d0
 rts 


 opt o-

;
; STNICCC 2016 BLitter overlay
;
MoveSTNICCLogo
 sub.w #1,StnicccLogoDelay                ; Waiting until it's time to enable the STNICCC logo
 bne.s .continue 
 move.l #MoveSTNICCLogoUp,_HandleStnicccLogo+2
.continue 
 rts

MoveSTNICCLogoUp
 add.l #8,expanded_stnicccc_logo_ptr
 add.w #8,BlitterOffset
 cmp #200*16*2,BlitterOffset
 bne .end
 move.l #MoveSTNICCLogoDown,_HandleStnicccLogo+2 
.end 
 rts

MoveSTNICCLogoDown
 sub.l #8,expanded_stnicccc_logo_ptr
 sub.w #8,BlitterOffset
 cmp #25*16*2,BlitterOffset
 bne .end
 move.l #MoveSTNICCLogoUp,_HandleStnicccLogo+2 
.end 
 rts


;
; Make the effect appear after some delay, so we can see the blitter overlay
;
MoveEffects
 sub.w #1,EffectAppearDelay                ; Waiting until it's time to enable the STNICCC logo
 bne.s .continue 
 move.l #MakeEffectsAppear,_HandleEffectMovement+2
 move.l #StartEffect,_StartEffectPatch+2
 move.w #360-1,BigPictureCountLines1
.continue 
 rts

; Get the scrollers to expand an move up a bit
MakeEffectsAppear
 sub.w #4,BigPictureCountLines1
 add.w #1,ScrollerHeight            ; We have 4 scrollers
 cmp.w #16-3,ScrollerHeight
 bne.s .continue
 move.l #MakeEffectsAppear2,_HandleEffectMovement+2
 move.l #UpdateScrollers,_HandleScrollers+2
 add.w #10+2+1,BigPictureCountLines4
.continue 
 rts

; Show bottom
MakeEffectsAppearBottom
 add.w #1,BigPictureCountLines4
 cmp.w #20,BigPictureCountLines4
 bne.s .continue
 move.l #MakeEffectsAppear2,_HandleEffectMovement+2
.continue 
 rts

; Get the whole stuff to move up
MakeEffectsAppear2
 sub.w #6,BigPictureCountLines1
 add.w #2,BigPictureCountLines2
 add.w #2,BigPictureCountLines3
 add.w #2,BigPictureCountLines4
 cmp.w #16,BigPictureCountLines1
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear3,_EffectWait+2  
.continue 
 rts

; Get the last scroller to move down
MakeEffectsAppear3
 add.w #2,BigPictureCountLines3
 sub.w #2,BigPictureCountLines4
 cmp.w #16,BigPictureCountLines4
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear4,_EffectWait+2   
.continue 
 rts

; Make the Kefrens bars appear
MakeEffectsAppear4
 add.w #1,KefrensCountLines
 sub.w #1,BigPictureCountLines2
 sub.w #1,BigPictureCountLines3
 cmp.w #100,KefrensCountLines
 bmi.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear5,_EffectWait+2   
 ;move.l #MakeEffectsAppear5,_HandleEffectMovement+2
.continue 
 rts

; Move the bars down
MakeEffectsAppear5
 add.w #1,BigPictureCountLines2
 sub.w #1,BigPictureCountLines3
 cmp.w #10,BigPictureCountLines3
 bpl.s .continue
 move.l #MakeEffectsAppear6,_HandleEffectMovement+2
.continue 
 rts

; Move the bars up
MakeEffectsAppear6
 sub.w #1,BigPictureCountLines2
 add.w #1,BigPictureCountLines3
 cmp.w #10,BigPictureCountLines2
 bpl.s .continue
 move.l #MakeEffectsAppear7,_HandleEffectMovement+2
.continue 
 rts

; Extend Kefren bars
MakeEffectsAppear7
 add.w #1,KefrensCountLines
 sub.w #1,BigPictureCountLines2
 sub.w #1,BigPictureCountLines3
 cmp.w #10,BigPictureCountLines2
 bpl.s .continue
 move.l #MakeEffectsAppear8,_HandleEffectMovement+2
.continue 
 rts

; Extend Kefren bars - bottom
MakeEffectsAppear8
 add.w #1,KefrensCountLines
 sub.w #2,BigPictureCountLines3
 cmp.w #10,BigPictureCountLines3
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear9,_EffectWait+2 
.continue 
 rts

; Contract bars
MakeEffectsAppear9
 sub.w #1,KefrensCountLines
 add.w #1,BigPictureCountLines2
 add.w #1,BigPictureCountLines3
 cmp.w #1,KefrensCountLines
 bpl.s .continue
 move.l #MakeEffectsAppear10,_HandleEffectMovement+2
.continue 
 rts

; Move the top and bottom scroller toward the center
MakeEffectsAppear10
 add.w #1,BigPictureCountLines1
 sub.w #1,BigPictureCountLines2
 sub.w #1,BigPictureCountLines3
 add.w #1,BigPictureCountLines4
 cmp.w #1,BigPictureCountLines2
 bpl.s .continue
 move.l #MakeEffectsAppear11,_HandleEffectMovement+2
.continue 
 rts

; Show the kefrens bars again
MakeEffectsAppear11
 sub.w #1,BigPictureCountLines1
 add.w #1,KefrensCountLines
 sub.w #1,BigPictureCountLines4
 cmp.w #5,BigPictureCountLines1
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear12,_EffectWait+2
.continue 
 rts

; Move the two top scrollers at the bottom
MakeEffectsAppear12
 add.w #2,BigPictureCountLines1
 sub.w #1,KefrensCountLines
 cmp.w #1,KefrensCountLines
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear13,_EffectWait+2
.continue 
 rts

; Move the 4 scrollers to the top of the screen
MakeEffectsAppear13
 sub.w #1,BigPictureCountLines1
 add.w #1,BigPictureCountLines4
 cmp.w #5,BigPictureCountLines1
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear14,_EffectWait+2
.continue 
 rts

; Move the 4 scrollers at the bottom of the screen
MakeEffectsAppear14
 add.w #1,BigPictureCountLines1
 sub.w #1,BigPictureCountLines4
 cmp.w #5,BigPictureCountLines4
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear15,_EffectWait+2
.continue 
 rts

; Make the kefrens bars appear again
MakeEffectsAppear15
 sub.w #2,BigPictureCountLines1
 add.w #1,KefrensCountLines
 cmp.w #5,BigPictureCountLines1
 bpl.s .continue
 ; Wait a bit before the next effect
 move.w #70*2,DelayNextEffect
 move.l #EffectWait,_HandleEffectMovement+2
 move.l #MakeEffectsAppear12,_EffectWait+2
.continue 
 rts

MakeEffectsAppear16
 rts

EffectWait
 sub.w #1,DelayNextEffect
 bne ContinueEffect
_EffectWait 
 move.l #MakeEffectsAppear13,_HandleEffectMovement+2
ContinueEffect 
 rts


EndScroller
 move.l #DoNothing,2(a0)
 rts

UpdateScrollers
 bsr UpdateScrollerGeneral
 bsr UpdateScrollerGreetings
 bsr UpdateScrollerDesign
 bra UpdateScrollerCredits


UpdateScrollerGeneral
 jmp UpdateScrollerGeneralPosition
UpdateScrollerGeneralPosition 
 lea UpdateScrollerGeneral,a0
 ; Update the General scrolling position/speed/reset
 move.l ScrollerGeneralPosition,d6
 cmp.l #(80+MessageScrollerSize)*8*4,d6
 bcc EndScroller
 add.l #4,d6
 move.l d6,ScrollerGeneralPosition
 rts


UpdateScrollerGreetings
 jmp UpdateScrollerGreetingsPosition
UpdateScrollerGreetingsPosition 
 lea UpdateScrollerGreetings,a0
 ; Update the Greetings scrolling position/speed/reset
 move.l ScrollerGreetingPosition,d6
 cmp.l #(80+MessageScrollerGreetingSize)*8*4,d6
 bcc EndScroller
 add.l #4*8,d6
 move.l d6,ScrollerGreetingPosition
 rts


UpdateScrollerDesign
 jmp UpdateScrollerDesignPosition
UpdateScrollerDesignPosition 
 lea UpdateScrollerDesign,a0
 ; Update the Design scrolling position/speed/reset
 move.l ScrollerDesignPosition,d6
 cmp.l #(80+MessageScrollerDesignSize)*8*4,d6
 bcc EndScroller
 add.l #8,d6
 move.l d6,ScrollerDesignPosition
 rts


UpdateScrollerCredits
 jmp UpdateScrollerCreditsPosition
UpdateScrollerCreditsPosition 
 lea UpdateScrollerCredits,a0
 ; Update the Credits scrolling position/speed/reset
 move.l ScrollerCreditsPosition,d6
 cmp.l #(80+MessageScrollerCreditsSize)*8*4,d6
 bcc EndScroller
 add.l #4,d6
 move.l d6,ScrollerCreditsPosition
 rts


; 9 nops just for the jsr/rts doing nothing (jsr=20/5    rts=16/4)
BlitterSteMegaStePause
 nop
 nop
_SteDelayPatch
 nop                      ; Becomes RTS on Mste
 rts


 opt o+



MainEffect
 neg.w $ffff8240.w
 bsr WaitVbl

 ; Initialise blitter to use halftone registers to draw the stniccc logo
 lea $ffff8a00.w,a5
 move #2,blitter_src_yinc(a5)         ; Number of bytes to move to the next line
 move #0,blitter_dst_xinc(a5)         ; Don't move...
 move #0,blitter_dst_yinc(a5)         ; ...stay on the same address
 move.l #$ff8240,blitter_dst_addr(a5) ; Point to the first color register
 move.b #1,blitter_hop(a5)            ; Use Halftone
 move #1,blitter_xcount(a5)           ; Width of the transfer

 move.l #expanded_stnicccc_logo,expanded_stnicccc_logo_ptr

 move.w #0,ScreenPositionX
 move.w #400,ScreenPositionY
 move.w #2,BigScrollingPictureIncX
 move.w #-2,BigScrollingPictureIncY

 ; Picture setup
 move.w #398-1,BigPictureCountLines1
 move.w #0,BigPictureCountLines2
 move.w #0,BigPictureCountLines3
 move.w #0,BigPictureCountLines4
 move.w #0,KefrensCountLines             ; x2 because Kefrens bars are displayed two by two


 ; move.w #16-2,d7                           ; 12/3 ---- scroller count
 move.w #1,ScrollerHeight
 move.w #1,ScrollerHeightDelay

 bsr WaitVbl
 neg.w $ffff8240.w

 st.b flag_skip_shifter

 ;bsr WaitSpace

 ;
 ; The big loop
 ;
MainEffectLoop
 bsr MoveBigPicture

 opt o-

_HandleStnicccLogo 
 jsr MoveSTNICCLogo

_HandleEffectMovement
 jsr MoveEffects

_HandleScrollers
 jsr DoNothing

 opt o+

 ; Clean up the kefrens bars buffer
 moveq.l #0,d0 		; 4/1 * 8 -> 32/8
 moveq.l #0,d1
 moveq.l #0,d2
 moveq.l #0,d3
 moveq.l #0,d4
 moveq.l #0,d5
 moveq.l #0,d6
 moveq.l #0,d7

 move.l d0,a1 		; 4/1 * 6 -> 24/6
 move.l d0,a2
 move.l d0,a3
 move.l d0,a4
 move.l d0,a5
 move.l d0,a6
 ; total -> 8+6=14 nops

 movem.l d0-d7/a1-a6,kefrens_line+0     ; 56 bytes = 16+8n = 16+8*(8+6) = 128/32 
 movem.l d0-d7/a1-a6,kefrens_line+56    ; 56 bytes = 16+8n = 16+8*(8+6) = 128/32 
 movem.l d0-d7/a1-a4,kefrens_line+112   ; 48 bytes = 16+8n = 16+8*(8+4) = 112/28
 ; total -> 32+32+28=92 nops

 bsr WaitVbl

 move #$2700,sr
 ;move.w #0,$ffff8240.w 			; Force the screen to black

 move.l #16,d6
 move.l #mlinebusy,d7
 lea $ffff8a38.w,a0    				; Blitter Y Count
 lea $ffff8a3c.w,a1    				; Blitter control

 move.l expanded_stnicccc_logo_ptr,a3	    ; Source scroller font
 move.w BlitterOffset,d4            ; Halftone offset

 ; Preload halftone ram
 moveq #16-1,d0
.loop_preload_halftone 
 and.w #31,d4                                     ; 8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ; 4/1
 dbra d0,.loop_preload_halftone

 move.w #$0,$ffff8240.w                           ; 16/4

 moveq.l #0,d1


; -------
 ; Big Picture Scroll Setup
 ; -------
 move.w BigPictureCountLines1,d7                  ; 16/4 ---- picture count
 moveq #16,d6                                     ; 4/1
 moveq #mlinebusy,d5                        ; 4/1

 ;
 ; STE hardware compatible synchronization code
 ; 
 opt o-
 move.b #0,$ffff8265.w
 move.b #0,$ffff8209.w
 moveq #16,d0
.wait_sync
 move.b $ffff8209.w,d1
 beq.s .wait_sync
 sub.b d1,d0
 lsl.b d0,d1

 ; Reserved registers:
 ; a0 - Scanline information
 ; a1 - Blitter base
 ; a2 - Blitter base #2
 ; a3 - Blitter buffer source
 ;
 ; d6 - 16 (line count)
 ; d7 - mline busy (start blitter)

 ;
 ; First line temporisation
 ;
start_syncfirst_line        equ 5+2+1
JmpStartSyncLine
 NOP_TABLE_JMP start_syncfirst_line

dbra_time        equ 4
dbra_time_loop   equ 3

 ; Run the generated code
 lea $ffff8a38.w,a0    						; 8/2 Blitter Y Count

 ; -------------------------> Test
 ; Possible register allocations:
 ;
 ; d0 -> Big scrolling picture address (shifted)
 ; d1 -> Big scrolling picture increment (shifted)
 ;
 ; d2 -> Text scrollers picture address (shifted)
 ; d3 -> Text scrollers picture increment (shifted)
 ;
 ; d4 -> Halftone register offset
 ; d5 -> mlinebusy
 ; d6 -> #16
 ;
 ; a0 -> Blitter/Shifter base register (ffff8a38 - blitter Y count)
 ; a1 -> Blitter/Shifter base register (ffff8a3c - control)
 ; a2 -> Blitter/Shifter half tone (ffff8a00 - halftone)
 ; a3 -> Blitter font pointer


 ; -------
 ; Big Picture Scroll Setup
 ; -------
 move.l ScreenPointerPixel,d0                     ; 12/3
 move.l #(80*2)<<8,d1                             ; 12/3
 SCANLINECHANGE d0                                ; 36/9

 ; -------
 ; Scanline display for the big moving picture
 ; -------
.loop_scanline_big_picture_top 
 and.w #31,d4                                     ; 8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ; 4/1
 move.b d5,(a1)	  	        					  ; 88/22 Start blitter
 move.w d6,(a0)		                			  ; 8/2 Copy 16 lines
 add.l d1,d0									  ; 8/2
 SYNCMARKER_BLITTER 4                             ; 32/8
 SCANLINECHANGE d0                                ; 36/9
 dbra d7,.loop_scanline_big_picture_top           ; 12/3

 ; --------------------------------------------------------------------------
 ; Separator line
 ; --------------------------------------------------------------------------
_StartEffectPatch 
 jmp EndMainEffect                                ; 12/3
StartEffect 
 move.l #white_palette,d6                 	  	  ; 12/3
 lsl.l #8,d6                                      ; 12/3
 add.l d1,d0									  ; 8/2
 SYNCMARKER 24-3                                  ; 32/8
 SCANLINECHANGE d6                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Greetings scroller setup
 ; -------
 move.l ScrollerGreetingPosition,d6               ; 16/4
 lea TableValueToShift,a4                         ; 12/3
 move.l #ScrollerGreetingBuffer,d2                ; 12/3
 lsl.l #8,d2                                      ; 8+2n=8+16=24/6
 add.l (a4,d6.l),d2                               ; 
 move.l #(80+MessageScrollerGreetingSize)<<8,d3   ; 12/3 
 ;move.w #16-2,d7                  				  ; 8/2 ---- scroller count
 move.w ScrollerHeight,d7                         ; 16/4 ---- scroller count
 add.l d1,d0									  ; 8/2
 SYNCMARKER 6-2                                     ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Greetings scroller display
 ; -------
.loop_scanline_greetings 
 and.w #31,d4                                     ;  8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ;  4/1
 ;---------------
 add.l d3,d2									  ; 4/1
 add.l d1,d0									  ; 8/2
 SYNCMARKER 24                                    ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 dbra d7,.loop_scanline_greetings                 ; 12/3


 ; --------------------------------------------------------------------------
 ; Separator line
 ; --------------------------------------------------------------------------
 move.w BigPictureCountLines2,d7                  ; 16/4 ---- picture count
 moveq #16,d6                                     ; 4/1
 moveq #mlinebusy,d5                 			  ; 4/1
 move.l #white_palette,d2                 	  	  ; 12/3
 lsl.l #8,d2                                      ; 12/3
 add.l d1,d0									  ; 8/2
 SYNCMARKER 18                                    ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Scanline display for the big moving picture (bottom part)
 ; -------
.loop_scanline_big_picture_bottom
 and.w #31,d4                                     ; 8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ; 4/1
 move.b d5,(a1)	  	        					  ; 88/22 Start blitter
 move.w d6,(a0)		                			  ; 8/2 Copy 16 lines
 add.l d1,d0									  ; 8/2
 SYNCMARKER_BLITTER 4                             ; 32/8
 SCANLINECHANGE d0                                ; 36/9
 dbra d7,.loop_scanline_big_picture_bottom        ; 12/3

 ; --------------------------------------------------------------------------
 ; Separator line
 ; --------------------------------------------------------------------------
 move.l #white_palette,d6                 	  	  ; 12/3
 lsl.l #8,d6                                      ; 12/3
 add.l d1,d0									  ; 8/2
 SYNCMARKER 24                                    ; 32/8
 SCANLINECHANGE d6                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Credits scroller setup
 ; -------
 move.l ScrollerCreditsPosition,d6                ; 16/4
 lea TableValueToShift,a4                         ; 12/3
 move.l #ScrollerCreditsBuffer,d2                 ; 12/3
 lsl.l #8,d2                                      ; 8+2n=8+16=24/6
 add.l (a4,d6.l),d2                               ; 
 move.l #(80+MessageScrollerCreditsSize)<<8,d3    ; 12/3 
 ;move.w #16-2,d7                  				  ; 8/2 ---- scroller count
 move.w ScrollerHeight,d7                         ; 16/4 ---- scroller count
 add.l d1,d0									  ; 8/2
 SYNCMARKER 6-2                                     ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Credits scroller display
 ; -------
.loop_scanline_credits
 and.w #31,d4                                     ;  8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ;  4/1
 ;---------------
 add.l d3,d2									  ; 8/2
 add.l d1,d0									  ; 8/2
 SYNCMARKER 32-8                                  ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 dbra d7,.loop_scanline_credits                   ; 12/3


 ; --------------------------------------------------------------------------
 ; Separator line
 ; --------------------------------------------------------------------------
 move.l a3,temp_blitter_address                   ; 20/5

 move.l #white_palette,d2                 	  	  ; 12/3
 lsl.l #8,d2                                      ; 12/3
 add.l d1,d0									  ; 8/2
 SYNCMARKER 19                                    ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause 1

 ; -------
 ; Kefrens Bars setup
 ; - kefrens_line - 160 bytes to erase
 ; - a4 - Angle 1
 ; - a5 - Angle 2
 ; - a6 - Angle 3
 ; -------
 lea sine_255,a1				; 256*2 -> -32767,+32767 range
 move KefrensAngle,d2           ; Angle
 add #2,d2
 and #510,d2                    ; Angle - wraps around
 move d2,KefrensAngle
 lea (a1,d2),a6

 move KefrensAngle2,d2          ; Angle
 add #4,d2
 and #510,d2                    ; Angle - wraps around
 move d2,KefrensAngle2
 lea (a1,d2),a5

 move KefrensAngle3,d2          ; Angle
 add #6,d2
 and #510,d2                    ; Angle - wraps around
 move d2,KefrensAngle3
 lea (a1,d2),a4

 lea kefrens_line,a1        	; Final line position
 move.w KefrensCountLines,d7    ; 16/4 ---- picture count


; -------
 ; Greetings scroller display
 ; -------
.loop_scanline_kefrens
 move.w #$0,$ffff8240.w                           ; 16/4
 move (a6)+,d6					;  8/2 - 0,127
 add (a5),d6					; 12/3 - 0,127
 add (a5)+,d6					; 12/3 - 0,127
 add #2*4,a5                    ; 12/3
 add (a4)+,d6					; 12/3 - 0,127
 add #2,a5                      ; 12/3
 ; total -> 17

 ; Pattern table
 move d6,d2
 lsr #3,d2                      ; /8
 and #$FFFE,d2
 lea 0(a1,d2),a3                ; Location in the scanline

 lea KefrensPatterns,a2
 
 and #15,d6                     ; modulo 16
 lsl #4,d6                      ; *16
 add d6,a2
 move.l (a2)+,d5                ; Shifted Mask

 ; First line
 move.l (a3),d3                 ; Current value in the scanline
 and.l d5,d3                    ; Mask out the value
 or.l (a2)+,d3                  ; Mask in the top pattern
 move.l d3,(a3)                 ; Update the scanline

 ; Second line
 and.l 80(a3),d5                ; Combine the mask with the second scanline value
 or.l (a2)+,d5                  ; Mask in the bottom pattern
 move.l d5,80(a3)               ; Update the scanline

 pause 14

 move.l a1,d2
 lsl.l #8,d2

 add.l d1,d0									  ; 8/2
 add.l d1,d0									  ; 8/2
 SYNCMARKER_REVERSE                               ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 dbra d7,.loop_scanline_kefrens 	              ; 12/3

 ; -------------------
 ;jmp .skipittotewr ; -----------------------------------------------------------------------

 ; --------------------------------------------------------------------------
 ; Separator line
 ; --------------------------------------------------------------------------
 move.l #white_palette,d6                 	  	  ; 12/3
 lsl.l #8,d6                                      ; 12/3
 move.l temp_blitter_address,a3                   ;
 add.l d1,d0									  ; 8/2
 SYNCMARKER 24-5                                  ; 32/8
 SCANLINECHANGE d6                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Design scroller setup
 ; -------
 move.l ScrollerDesignPosition,d6                 ; 16/4
 lea TableValueToShift,a4                         ; 12/3
 move.l #ScrollerDesignBuffer,d2                  ; 12/3
 lsl.l #8,d2                                      ; 8+2n=8+16=24/6
 add.l (a4,d6.l),d2                               ; 
 move.l #(80+MessageScrollerDesignSize)<<8,d3     ; 12/3 
 ;move.w #16-2,d7                  				  ; 8/2 ---- scroller count
 move.w ScrollerHeight,d7                         ; 16/4 ---- scroller count
 add.l d1,d0									  ; 8/2
 SYNCMARKER 6-2                                     ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Design scroller display
 ; -------
.loop_scanline_design
 and.w #31,d4                                     ;  8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ;  4/1
 ;---------------
 add.l d3,d2									  ; 8/2
 add.l d1,d0									  ; 8/2
 SYNCMARKER 32-8                                  ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 dbra d7,.loop_scanline_design                    ; 12/3

 ; --------------------------------------------------------------------------
 ; Separator line
 ; --------------------------------------------------------------------------
 move.w #$1,$ffff8240.w                           ; 16/4

 move.l #white_palette,d2                 	  	  ; 12/3
 lsl.l #8,d2                                      ; 12/3
 move.l #(80*2)<<8,d1                             ; 12/3
 move.w BigPictureCountLines3,d7                  ; 16/4 ---- picture count
 moveq #16,d6                                     ; 4/1
 moveq #mlinebusy,d5                 			  ; 4/1
 lea $ffff8a3c.w,a1    							  ; Blitter control
 add.l d1,d0									  ; 8/2
 SYNCMARKER 8+5-4                                   ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Scanline display for the big moving picture (bottom part)
 ; -------
.loop_scanline_big_picture_3
 and.w #31,d4                                     ; 8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ; 4/1
 move.b d5,(a1)	  	        					  ; 88/22 Start blitter
 move.w d6,(a0)		                			  ; 8/2 Copy 16 lines
 add.l d1,d0									  ; 8/2
 SYNCMARKER_BLITTER 4                             ; 32/8
 SCANLINECHANGE d0                                ; 36/9
 dbra d7,.loop_scanline_big_picture_3             ; 12/3

 ; -------
 ; General scroller setup
 ; -------
 move.l ScrollerGeneralPosition,d6                 	  ; 16/4
 lea TableValueToShift,a4                         ; 12/3
 move.l #ScrollerBuffer,d2                        ; 12/3
 lsl.l #8,d2                                      ; 8+2n=8+16=24/6
 add.l (a4,d6.l),d2                               ; 
 move.l #(80+MessageScrollerSize)<<8,d3           ; 12/3 
 ;move.w #16-2,d7                  				  ; 8/2 ---- scroller count
 move.w ScrollerHeight,d7                         ; 16/4 ---- scroller count
 add.l d1,d0									  ; 8/2
 SYNCMARKER 5-2                                     ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; General scroller display
 ; -------
.loop_scanline_general
 and.w #31,d4                                     ;  8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ;  4/1
 ;---------------
 add.l d3,d2									  ; 8/2
 add.l d1,d0									  ; 8/2
 SYNCMARKER 32-8                                  ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 dbra d7,.loop_scanline_general                   ; 12/3

 ; --------------------------------------------------------------------------
 ; Separator line
 ; --------------------------------------------------------------------------
 move.l #white_palette,d2                 	  	  ; 12/3
 lsl.l #8,d2                                      ; 12/3
 move.l #(80*2)<<8,d1                             ; 12/3
 move.w BigPictureCountLines4,d7                  ; 16/4 ---- picture count
 moveq #16,d6                                     ; 4/1
 moveq #mlinebusy,d5                 			  ; 4/1
 lea $ffff8a3c.w,a1    				; Blitter control
 add.l d1,d0									  ; 8/2
 SYNCMARKER 8+5                                   ; 32/8
 SCANLINECHANGE d2                                ; 36/9
 pause dbra_time_loop

 ; -------
 ; Scanline display for the big moving picture (bottom part)
 ; -------
.loop_scanline_big_picture_4
 and.w #31,d4                                     ; 8/2
 move.w (a3)+,-$38(a0,d4)                         ; 20/5 Half-tone loading ($ffff8a00.w)
 addq.w #2,d4                                     ; 4/1
 move.b d5,(a1)	  	        					  ; 88/22 Start blitter
 move.w d6,(a0)		                			  ; 8/2 Copy 16 lines
 add.l d1,d0									  ; 8/2
 SYNCMARKER_BLITTER 4                             ; 32/8
 SCANLINECHANGE d0                                ; 36/9
 dbra d7,.loop_scanline_big_picture_4             ; 12/3

EndMainEffect
 ; -------------------------< Test

 ; Clean the rest of the display
 lea $ffff8a38.w,a0    				; Blitter Y Count
 ;pause 34
 pause 5+5+5+2+2+2+2+2+2+2+2
 move.l #black_screen+256,d0                 	  ; 12/3
 move.l d0,d1
 sf.b d0
 lsl.l #8,d0
 SCANLINECHANGE d0                                ; 36/9

 lsr.l #8,d1
 move.b d1,$ffff8201.w
 lsr.l #8,d1
 move.b d1,$ffff8203.w
 move.b #0,$ffff820d.w
 move.b #0,$ffff820f.w                            ; Line width
 move.b #0,$ffff8265.w                ; 12/3 shifter pixel scroll


 opt o+
 move #$2300,sr

 ifeq enable_keep_going
 cmp.w #dmaplay_sequence_end-dmaplay_sequence,DmaPlayPosition
 bgt.s .exit_loop   ; -------------- TEMP TEST
 endc

 ; Checked if a key is pressed
 btst #0,$fffffc00.w
 beq MainEffectLoop

 move.b $fffffc02.w,d0

 cmp.b #KEY_ARROW_LEFT,d0
 beq .ShorterFirstLineWait2

 cmp.b #KEY_ARROW_RIGHT,d0
 beq .LongerFirstLineWait2

 cmp.b #KEY_SPACE,d0
 bne MainEffectLoop

.exit_loop
 move.b #0,$ffff820a.w          ; 50hz
 move.b #2,$ffff8260.w          ; HIGH RES
 sf.b flag_skip_shifter

 rts

.LongerFirstLineWait2
 add.l #1,FirstLineStart
 sub.l #2,JmpStartSyncLine+2
 jmp MainEffectLoop

.ShorterFirstLineWait2
 tst.l FirstLineStart
 beq .skip
 sub.l #1,FirstLineStart
 add.l #2,JmpStartSyncLine+2
.skip 
 jmp MainEffectLoop


FirstLineStart		dc.l start_syncfirst_line


 SECTION DATA

 even

; ===========================================================================
;
;					Tables, palettes, and other dc.x thingies
;
; ===========================================================================

Prng32	        				dc.l $12345678			; random number store

 ifeq enable_start_fast
StnicccLogoDelay        dc.w 70*3    				; Number of frames before starting the STNICCC logo overlay
EffectAppearDelay       dc.w 70*15          ; Number of frames before starting to make things appear
 else
StnicccLogoDelay        dc.w 1    				; Number of frames before starting the STNICCC logo overlay
EffectAppearDelay       dc.w 1          ; Number of frames before starting to make things appear
 endc


MixerTable
 dc.w %100110+LMC_MASTERVOL ; -4db master volume
 dc.w %010100+LMC_RIGHTVOL	; -0db right
 dc.w %010100+LMC_LEFTVOL	; -0db left
 dc.w %000001+LMC_MIXER		; mix DMA+YM equally
 dc.w %000110+LMC_BASS		; +0db bass
 dc.w %000110+LMC_TREBLE	; +0db treble
MixerTableEnd 


KefrensPatterns
	dc.l %00000000000000001111111111111111  ; Each pattern is 4*4=16 bytes long
	dc.l %01001011110100100000000000000000
	dc.l %00010111111010000000000000000000
	dc.l 0
	dc.l %10000000000000000111111111111111
	dc.l %00100101111010010000000000000000
	dc.l %00001011111101000000000000000000
	dc.l 0
	dc.l %11000000000000000011111111111111
	dc.l %00010010111101001000000000000000
	dc.l %00000101111110100000000000000000
	dc.l 0
	dc.l %11100000000000000001111111111111
	dc.l %00001001011110100100000000000000
	dc.l %00000010111111010000000000000000
	dc.l 0
	dc.l %11110000000000000000111111111111
	dc.l %00000100101111010010000000000000
	dc.l %00000001011111101000000000000000
	dc.l 0
	dc.l %11111000000000000000011111111111
	dc.l %00000010010111101001000000000000
	dc.l %00000000101111110100000000000000
	dc.l 0
	dc.l %11111100000000000000001111111111
	dc.l %00000001001011110100100000000000
	dc.l %00000000010111111010000000000000
	dc.l 0
	dc.l %11111110000000000000000111111111
	dc.l %00000000100101111010010000000000
	dc.l %00000000001011111101000000000000
	dc.l 0
	dc.l %11111111000000000000000011111111
	dc.l %00000000010010111101001000000000
	dc.l %00000000000101111110100000000000
	dc.l 0
	dc.l %11111111100000000000000001111111
	dc.l %00000000001001011110100100000000
	dc.l %00000000000010111111010000000000
	dc.l 0
	dc.l %11111111110000000000000000111111
	dc.l %00000000000100101111010010000000
	dc.l %00000000000001011111101000000000
	dc.l 0
	dc.l %11111111111000000000000000011111
	dc.l %00000000000010010111101001000000
	dc.l %00000000000000101111110100000000
	dc.l 0
	dc.l %11111111111100000000000000001111
	dc.l %00000000000001001011110100100000
	dc.l %00000000000000010111111010000000
	dc.l 0
	dc.l %11111111111110000000000000000111
	dc.l %00000000000000100101111010010000
	dc.l %00000000000000001011111101000000
	dc.l 0
	dc.l %11111111111111000000000000000011
	dc.l %00000000000000010010111101001000
	dc.l %00000000000000000101111110100000
	dc.l 0
	dc.l %11111111111111100000000000000001
	dc.l %00000000000000001001011110100100
	dc.l %00000000000000000010111111010000
	dc.l 0
	dc.l %11111111111111110000000000000000  
	dc.l %00000000000000000100101111010010
	dc.l %00000000000000000001011111101000
	dc.l 0


white_palette   dcb.b 80,255	; 80 bytes with ones
black_palette   dcb.b 80*10,0  	; 80 bytes with zero (10 lines long)

NotASteMessage
 dc.b "This demo works only on STE or MegaSTE,",10,13,"with a 640x400 monochrome screen",0


MessageBoot1  dc.b 1,"COMMODORE BASIC V7.0 122365 BYTES FREE",0   ; 38 characters
MessageBoot2  dc.b 1,"(C)1985 COMMODORE ELECTRONICS, LTD.",0
MessageBoot3  dc.b 1,"(C)1977 MICROSOFT CORP.",0
MessageBoot4  dc.b 1,1,"ALL RIGHTS RESERVED",0
MessageReady  dc.b 1,"READY.",1,0
MessageBootCursorOn  dc.b 255,131,0
MessageBootCursorOff dc.b " ",0

MessageStartEaster  dc.b 1,"SYS 32800,123,45,6",0

MessageEaster1  dc.b 255,"   Brought to you by...   ",0
MessageEaster2  dc.b 1,1,"Software:",0
MessageEaster3  dc.b 1,"Fred Bowen",0
MessageEaster4  dc.b 1,"Terry Ryan",0
MessageEaster5  dc.b 1,"Von Ertwine",0
MessageEaster6  dc.b 1,1,"Herdware:",0
MessageEaster7  dc.b 1,"Bill Herd",0
MessageEaster8  dc.b 1,"Dave Haynie",0
MessageEaster9  dc.b 1,"Frank Palaia",0
MessageEaster10  dc.b 1,1,255,"Link arms, don't make them.",0
MessageEaster11  dc.b 1,1,"ready.",0

; http://www.oldsoftware.com/Commtips.html "How to Load Programs on a Commodore 64 or 128"
; https://www.youtube.com/watch?v=DVEQua5bADs  "How to run load games on the commodore 64 C64"
; http://www.pagetable.com/?p=273 "How load works"
MessageDirectory1 dc.b 1,"LOAD",34,"$",34,",8",0
MessageDirectory2 dc.b 1,1,"SEARCHING FOR $",0
MessageDirectory3 dc.b 1,"LOADING",0
MessageDirectory4 dc.b 1,"READY.",0
MessageDirectory5 dc.b 1,"LIST",0

MessageFloppy1 dc.b 1,1,"0 ",255,34,"DEFENCE-FORCE     ",34," 23 2A",0
MessageFloppy2 dc.b 1,"239  ",34,"STNICCC 2015",34,"     PRG",0
MessageFloppy3 dc.b 1,"0    ",34,"----------------",34," DEL",0
MessageFloppy4 dc.b 1,"3    ",34,"READ ME",34,"          PRG",0
MessageFloppy5 dc.b 1,"0    ",34,"----------------",34," DEL",0
MessageFloppy6 dc.b 1,"641 BLOCKS FREE.",0

MessageLoad dc.b "LOAD",34,"STNICCC 2015",34,",8,1",0

MessageSearching dc.b 1,1,"SEARCHING FOR STNICCC 2015",0
MessageRun       dc.b "RUN",0

MessageCredits1  dc.b 255,34,"Time Slices",34,0
MessageCredits2  dc.b 255,"A small contribution from",0
MessageCredits3  dc.b 255,"to the ",34,"Commodore 128 revisited",34," compo at the",0
MessageCredits4  dc.b 255,"ST News International Christmas Coding Competition 2015",0


MessageScrollerGreeting
 ;dc.b 255,"Hello everybody!    "
 ;dc.b "Greetings to all of you who pushed the enveloppe (in good or bad directions...) on the Atari computers: "
 dc.b 255," 1984 "
 dc.b 255," 2 Life Crew "
 dc.b 255," 42 Crew "
 dc.b 255," A-Team "
 dc.b 255," Absence "
 dc.b 255," Abstract "
 dc.b 255," Admirables  "
 dc.b 255," Aenigmatica "
 dc.b 255," Aggression "
 dc.b 255," Albedo 0.12 "
 dc.b 255," Alien Cracking Formation "
 dc.b 255," Alive Team "
 dc.b 255," Alpha Flight "
 dc.b 255," Animal Mine "
 dc.b 255," Atari Legend "
 dc.b 255," Aura "
 dc.b 255," Avena "
 dc.b 255," Awesome "
 dc.b 255," B.O.S.S. "
 dc.b 255," Bits "
 dc.b 255," Blabla "
 dc.b 255," Black Monolith Team "
 dc.b 255," Blue Adept "
 dc.b 255," Blue System "
 dc.b 255," Brainless Institute "
 dc.b 255," Capital Design Team "
 dc.b 255," Cerebral Vortex "
 dc.b 255," Chaos "
 dc.b 255," Chaotic Motion "
 dc.b 255," Checkpoint "
 dc.b 255," Climactics "
 dc.b 255," Cobra "
 dc.b 255," Cocoon "
 dc.b 255," Condense "
 dc.b 255," Cream "
 dc.b 255," Creators "
 dc.b 255," D-Bug "
 dc.b 255," DBA "
 dc.b 255," Dead Hackers Society "
 dc.b 255," Dekadence "
 dc.b 255," Delta Force "
 dc.b 255," Demografica "
 dc.b 255," Diamond Design "
 dc.b 255," Digital Chaos "
 dc.b 255," Double Dutch Crew "
 dc.b 255," Dragons Neomey Talik Crew "
 dc.b 255," Dune "
 dc.b 255," Dynamic Duo "
 dc.b 255," Eckard Kruse "
 dc.b 255," Effect "
 dc.b 255," Electra "
 dc.b 255," Electronic Images "
 dc.b 255," Elite "
 dc.b 255," Ephidrena "
 dc.b 255," Equinox "
 dc.b 255," Escape "
 dc.b 255," Evolution "
 dc.b 255," Exa "
 dc.b 255," Excellence in art "
 dc.b 255," Exo7 "
 dc.b 255," Extremly Kriminal Organisation "
 dc.b 255," Factory "
 dc.b 255," Fashion "
 dc.b 255," Fit "
 dc.b 255," Flexible Front "
 dc.b 255," Ford Perfect "
 dc.b 255," Foxx "
 dc.b 255," Fraggle's "
 dc.b 255," Full Metal Computers Connexion "
 dc.b 255," FUN Industries "
 dc.b 255," Future Minds "
 dc.b 255," Fuzion "
 dc.b 255," Galtan 6 "
 dc.b 255," Genesis "
 dc.b 255," Genesis Project "
 dc.b 255," Ghost "
 dc.b 255," Gigabyte Crew "
 dc.b 255," Gudul "
 dc.b 255," gwEm "
 dc.b 255," Hackers Of The Arena "
 dc.b 255," Heaven "
 dc.b 255," Hemoroids "
 dc.b 255," Holocaust "
 dc.b 255," Hotline "
 dc.b 255," Howdy "
 dc.b 255," Hydroxid "
 dc.b 255," Hylst "
 dc.b 255," Hysteria "
 dc.b 255," Icaruz "
 dc.b 255," Imagina "
 dc.b 255," Imponance "
 dc.b 255," Inner Circuit Explorers "
 dc.b 255," Inter Development "
 dc.b 255," Invizibles "
 dc.b 255," Jac! "
 dc.b 255," Kruz "
 dc.b 255," KUA Software Productions "
 dc.b 255," Lamers "
 dc.b 255," Lazer "
 dc.b 255," Legacy "
 dc.b 255," Les Nuls "
 dc.b 255," Level 16 "
 dc.b 255," Light "
 dc.b 255," Lineout "
 dc.b 255," Live! "
 dc.b 255," LJBK "
 dc.b 255," LoUD "
 dc.b 255," Lynx "
 dc.b 255," M-Coder "
 dc.b 255," Mad Vision "
 dc.b 255," Maggie "
 dc.b 255," Mandarine "
 dc.b 255," Masters of Electric City "
 dc.b 255," MCS "
 dc.b 255," Megabusters "
 dc.b 255," Mind Design "
 dc.b 255," MJJ Prod "
 dc.b 255," Moving Pixels "
 dc.b 255," Mystic "
 dc.b 255," Mystic Bytes "
 dc.b 255," Naos "
 dc.b 255," New Beat "
 dc.b 255," New Computer Concept "
 dc.b 255," New Core "
 dc.b 255," New Power Generation "
 dc.b 255," New System "
 dc.b 255," Newline "
 dc.b 255," Night Force "
 dc.b 255," No Extra "
 dc.b 255," NoCrew "
 dc.b 255," Noice "
 dc.b 255," Nordik Coders "
 dc.b 255," Odyssey "
 dc.b 255," Omega "
 dc.b 255," Orion "
 dc.b 255," Overlanders "
 dc.b 255," Oxygene "
 dc.b 255," Paradize "
 dc.b 255," Paradox "
 dc.b 255," Paranoia "
 dc.b 255," Pendragons "
 dc.b 255," Phalanx "
 dc.b 255," Phantom "
 dc.b 255," Pompey Pirates "
 dc.b 255," Positivity  "
 dc.b 255," Psycho Hacking Force "
 dc.b 255," Pyjama "
 dc.b 255," Quartermass Xperiment "
 dc.b 255," Radical Systems "
 dc.b 255," Rave Network Overscan "
 dc.b 255," Reboot "
 dc.b 255," Reservoir Gods "
 dc.b 255," RGCD "
 dc.b 255," Sage "
 dc.b 255," Sanity "
 dc.b 255," Satantronic "
 dc.b 255," Scum Of The Earth "
 dc.b 255," Sector One "
 dc.b 255," Sedma "
 dc.b 255," Shadows "
 dc.b 255," Shogun "
 dc.b 255," Silvers "
 dc.b 255," Slight "
 dc.b 255," Spice Boys "
 dc.b 255," Spirits of Doom "
 dc.b 255," Spkr "
 dc.b 255," ST Amigos "
 dc.b 255," ST Connexion "
 dc.b 255," ST Force "
 dc.b 255," ST Knights "
 dc.b 255," ST Squad "
 dc.b 255," Stax "
 dc.b 255," STCS "
 dc.b 255," Supremacy "
 dc.b 255," Sync "
 dc.b 255," Synergy "
 dc.b 255," Syntax "
 dc.b 255," Teenage "
 dc.b 255," The Bits Club "
 dc.b 255," The Black Lotus "
 dc.b 255," The Bladerunners "
 dc.b 255," The Carebears "
 dc.b 255," The Corporation "
 dc.b 255," The East Cracking Group "
 dc.b 255," The Estate "
 dc.b 255," The Exceptions "
 dc.b 255," The Fingerbobs "
 dc.b 255," The Firehawks "
 dc.b 255," The Garlic Eaters "
 dc.b 255," The Giants "
 dc.b 255," The Independent "
 dc.b 255," The Invisibles "
 dc.b 255," The Light Team "
 dc.b 255," The Lost Boys "
 dc.b 255," The Masters "
 dc.b 255," The Misfits "
 dc.b 255," The Mugwumps "
 dc.b 255," The Naughty Bytes "
 dc.b 255," The Nerve Center "
 dc.b 255," The Pixel Twins "
 dc.b 255," The Raiders Brothers "
 dc.b 255," The Red Herrings "
 dc.b 255," The Replicants "
 dc.b 255," The Resistance "
 dc.b 255," The Respectables "
 dc.b 255," The Silents "
 dc.b 255," The Sirius Cybernetics Corporation "
 dc.b 255," The Source "
 dc.b 255," The Storm Brothers "
 dc.b 255," The Syndicate "
 dc.b 255," The Voyager "
 dc.b 255," The Watchmen "
 dc.b 255," The X'Press Crew "
 dc.b 255," Therapy "
 dc.b 255," Those Up Fucked Sceners "
 dc.b 255," Titan "
 dc.b 255," TNT Crew "
 dc.b 255," Torment "
 dc.b 255," Total Vision Inc "
 dc.b 255," Toys "
 dc.b 255," Trilobit "
 dc.b 255," Trio "
 dc.b 255," Tsunoo Rhilty "
 dc.b 255," Typhoon "
 dc.b 255," Unlimited Matricks "
 dc.b 255," Vector "
 dc.b 255," Vectronix "
 dc.b 255," Visualizers "
 dc.b 255," Vital motion "
 dc.b 255," Vulkteamet "
 dc.b 255," Wildfire "
 dc.b 255," X-Factor "
 dc.b 255," Xtream "
 dc.b 255," XXX International "
 dc.b 255," YM Rockerz "
 dc.b 255," Zeal "
 dc.b 255," Zuul "

 ;dc.b 255,"      If you happen to not be in the list but think you should have, just imagine you were there :)       Let's wrappppp..... "
 dc.b 0
 even
MessageScrollerGreetingEnd
MessageScrollerGreetingSize equ MessageScrollerGreetingEnd-MessageScrollerGreeting



MessageScrollerDesign
 dc.b 255,"So, I had this idea about making a monochrom demo...    "
 dc.b "It's not really my first monochrom demo, I already had support for it in my 1992's Caledonia PDL catalog intro, but that did not really exploit any of it.     "
 dc.b "I spent few weeks playing with timings counting and brainstorming about what could be done...     but I ran out of time!     "
 dc.b "So here we are, it's 2015, and this is my STNICCC 2015 monochrom demo, featuring sync code, on the fly data generation, sample sound, and eventually some more stuff if I manage to get it done in what remains of available disk space. "
 dc.b "  Regarding the sound quality, I had to use 4bit compressed 6khz samples in order to fit in the 128k size restrictions :(" 
 dc.b 0
 even
MessageScrollerDesignEnd
MessageScrollerDesignSize equ MessageScrollerDesignEnd-MessageScrollerDesign




MessageScrollerCredits
 dc.b 255,"Hello everybody!    "
 dc.b "Credits for this demo go to...    " 
 dc.b "Music by ",255," Beatslappaz ",255," (http://www.beatslappaz.com) / ",255," Punks Music ",255," (http://www.punksmusic.com) - thanks for giving me permission to use this awesome track!      "
 dc.b "Rest of the stuff (code, coder art, ...) by ",255," Dbug ",255, "...    "
 dc.b 0
 even
MessageScrollerCreditsEnd
MessageScrollerCreditsSize equ MessageScrollerCreditsEnd-MessageScrollerCredits


MessageScroller
 dc.b 255,"Hello everybody!    "
 dc.b "Here is Defence-Force' entry to the ",255," Commodore 128 Times Revisited ",255," competition!   "
 dc.b "Defence-Force is proud to be present at STNICCC 2015 with this modest contribution. "
 dc.b "If you happen to not be in the greetings list but think you should have, just imagine you were there :) "
 dc.b 0
 even
MessageScrollerEnd
MessageScrollerSize equ MessageScrollerEnd-MessageScroller



 even	
 
sine_255				; 16 bits, unsigned between 00 and 127
 incbin "exported\sine_255.bin"
 incbin "exported\sine_255.bin"
 incbin "exported\sine_255.bin"
 incbin "exported\sine_255.bin"
 
 even

 ; 480x348 (60 bytes)
 FILE "exported\c128.pi3",picture_c128_flip

 ; Logo: 576x246 (72 bytes)
 FILE "exported\logo_defence-force.pi3",picture_logo_defenceforce

 ; 544x194 (68 bytes)
 FILE "exported\logo_punks.pi3",picture_logo_punks

 ; 544x299 (68 bytes)
 FILE "exported\logo_beat-slappaz.pi3",picture_logo_bslappaz

 ; Impact: 160x186
 FILE "exported\impact.pi3",picture_impact

 ; C64 character set
 FILE "exported\c64_charset_converted.pi3",c64_charset_128x128

 ; 150 phases, 32 bytes each
 FILE "exported\dithering.ani",dithering_animation
 dcb.w 16,-1

; Font is 16x1536 in size, each letter is to bytes wide, 16 lines tall
; 3083 bytes - 11 bytes header = 3072 bytes
; FILE "exported\16x16_ANSI.pi3",picture_stniccc_logo  
; STNICCC logo is 16x225
 even	
 FILE "exported\stniccc.pi3",picture_stniccc_logo  

 even

TableKeyboardSounds
 dc.w 0,1598
 dc.w 1598,2696
 dc.w 2696,3922
 dc.w 3922,5221
 dc.w 5001,5889
 dc.w 5861,7041
 dc.w 6989,8293
 dc.w 8281,9533


DepackDeltaTable
 REPT 16
 dc.b -64
 dc.b -32
 dc.b -16
 dc.b -8
 dc.b -4
 dc.b -2
 dc.b -1
 dc.b 0
 dc.b 1
 dc.b 2
 dc.b 4
 dc.b 8
 dc.b 16
 dc.b 32
 dc.b 64
 dc.b 127
 ENDR

 even


unpacked_music_sample_start
unpacked_music_sample_1
 incbin "exported\kickthat.raw"        ; 0
unpacked_music_sample_2
 incbin "exported\flipthis.raw"        ; 1
unpacked_music_sample_3
 incbin "exported\bulletholes.raw"     ; 2
unpacked_music_sample_4
unpacked_music_sample_start_end

  
packed_music_sample_start
packed_music_sample_1
 incbin "exported\duumduum.dlt"        ; 3
packed_music_sample_2
 incbin "exported\a_1.dlt"             ; 4
packed_music_sample_3
 incbin "exported\a_2.dlt"             ; 5
packed_music_sample_4
 incbin "exported\b_1.dlt"             ; 6
packed_music_sample_5
 incbin "exported\b_2.dlt"             ; 7
packed_music_sample_6
 incbin "exported\c_1.dlt"             ; 8
packed_music_sample_7
 incbin "exported\c_2.dlt"             ; 9
packed_music_sample_8
 incbin "exported\c_3.dlt"             ; 10
packed_music_sample_9
 incbin "exported\ping_ah.dlt"         ; 11
packed_music_sample_10
 incbin "exported\gunshot.dlt"         ; 12
packed_music_sample_11
packed_music_sample_start_end

; Unpacked:  9536  Packed:    4769
packed_chatroom_sample_start 
 incbin "exported\keyboard.dlt"
packed_chatroom_sample_end

sample_kickthat    equ 0
sample_flipthis    equ 1
sample_bulletholes equ 2
sample_duumduum    equ 3
;
sample_a_start     equ 4
sample_a_end       equ 5
;
sample_b_start     equ 6
sample_b_end       equ 7
;
sample_c_start     equ 8
sample_c_end_1     equ 9
sample_c_end_2     equ 10
;
sample_ping        equ 11
;
sample_gunshot     equ 12

dmaplay_sequence
 dc.b sample_kickthat,sample_duumduum
 dc.b sample_flipthis,sample_duumduum
 dc.b sample_bulletholes,sample_duumduum
 dc.b sample_duumduum,sample_duumduum
 dc.b sample_ping
dmaplay_sequence_end_test

 dc.b sample_a_start,sample_a_end
 dc.b sample_b_start,sample_b_end

 dc.b sample_c_start,sample_c_end_1,sample_c_start,sample_c_end_2
 dc.b sample_c_start,sample_c_end_1,sample_c_start,sample_c_end_2

 dc.b sample_kickthat
 dc.b sample_flipthis
 dc.b sample_bulletholes

 dc.b sample_a_start,sample_a_end
 dc.b sample_b_start,sample_b_end

 dc.b sample_duumduum
 dc.b sample_ping

 dc.b sample_c_start,sample_c_end_1,sample_c_start,sample_c_end_2
 dc.b sample_c_start,sample_c_end_1,sample_c_start,sample_c_end_2

 ; The end
dmaplay_sequence_end 
 dc.b sample_bulletholes
 dc.b sample_gunshot
 dc.b sample_gunshot
 dc.b sample_gunshot
 dc.b -1
    
 SECTION BSS
 
bss_start

 even 

machine_is_ste			ds.b 1 		; We only run on STe type machines
machine_is_megaste 		ds.b 1 		; MegaSTe is possibly supported, with Blitter timing fixes

save_iera			ds.b 1	; Interrupt enable register A
save_ierb			ds.b 1	; Interrupt enable register B
save_imra			ds.b 1	; Interrupt mask register A
save_imrb			ds.b 1  ; Interrupt mask register B

save_freq    		ds.b 1
save_rez     		ds.b 1
save_pixl    		ds.b 1

save_screen_addr_1 	ds.b 1
save_screen_addr_2 	ds.b 1
save_vbaselo 		ds.b 1

save_linewidth		ds.b 1

save_mste_cache		ds.b 1

flag_skip_shifter   ds.b 1  ; Set to true if should not update shifter registers
flag_vbl	 		ds.b 1	; Set to true at the end of the main screen handling interupt
flip_flop           ds.b 1

 even
   
save_ssp     		ds.l 1	; Supervisor Stack Pointer
save_usp     		ds.l 1  ; User Stack Pointer

save_70      		ds.l 1	; VBL handler

ScreenBufferBase   	ds.l 1  ; Aligned address of the screen 
ScreenPointerByte   		    	ds.l 1	; Physical screen adress 
ScreenPointerPixel    ds.l 1
ScreenPositionX            ds.w 1
ScreenPositionY            ds.w 1

BigScrollingPictureIncX         ds.w 1
BigScrollingPictureIncY         ds.w 1

save_palette	 	ds.w 16


			  		ds.l stack_size
my_stack      		ds.l 1


BigPictureCountLines1 ds.w 1      ; Number of lines on the top of the screen
BigPictureCountLines2 ds.w 1      ; Number of lines at the bottom of the screen
BigPictureCountLines3 ds.w 1      ; Number of lines at the bottom of the screen
BigPictureCountLines4 ds.w 1      ; Number of lines at the bottom of the screen
KefrensCountLines     ds.w 1      ; Number of lines for the Kefrens bars effect



 even
  
DelayNextEffect       ds.w 1

temp_blitter_address    ds.l 1     ; a3

message_screen_offset ds.l 1
message_screen_width	ds.l 1  
message_screen_ptr		ds.l 1

 even
	
empty_line	  		ds.b 256+230	; Some empty bytes to have something "clean" to display during the sync line

 even
   
fading_pos    					ds.w 1

DmaPlayPosition                 ds.w 1
dmaplay_waitcounter				ds.w 1 ; set this to 1 to make the music start playing immediately on execution


ScrollerHeightDelay         ds.w 1
ScrollerHeight              ds.w 1      ; Number of scanlines in the scroller
ScrollerGeneralPosition 		ds.l 1      ; Pixel position inside the scroll buffer
ScrollerGreetingPosition 		ds.l 1      ; Pixel position inside the scroll buffer
ScrollerDesignPosition 			ds.l 1      ; Pixel position inside the scroll buffer
ScrollerCreditsPosition 		ds.l 1      ; Pixel position inside the scroll buffer

BlitterOffset         			ds.w 1
expanded_stnicccc_logo_ptr  ds.l 1
expanded_stnicccc_logo			ds.l (16*225*2)/4              ; 7200 bytes

 even

KefrensAngle		ds.w 1
KefrensAngle2		ds.w 1
KefrensAngle3		ds.w 1
KefrensAngle4		ds.w 1

TableValueToShift		ds.l  shift_table_size 

dmaplay_addresstable	ds.l 2*20

UnpackedMusicBuffer		ds.l ((packed_music_sample_start_end-packed_music_sample_start)*2)/4
	ds.l 1000 ; patch...

; Large enough for the complete scroller message + 80 blank characters  
ScrollerGreetingBuffer		ds.l ((MessageScrollerGreetingSize+80)*17+80)/4
ScrollerCreditsBuffer			ds.l ((MessageScrollerCreditsSize+80)*17+80)/4
ScrollerDesignBuffer			ds.l ((MessageScrollerDesignSize+80)*17+80)/4
ScrollerBuffer						ds.l ((MessageScrollerSize+80)*17+80)/4

chatroom_sample_start			ds.b 9536
chatroom_sample_end				ds.b 16				; Some padding to handle the alignment issues


screen_buffer       ds.l (256+32000*4*2)/4

kefrens_line        ds.b 80*2*10       ; Two lines of kefrens type rasters	
	ds.l 1000 ; patch...

black_screen        ds.l (256+32000)/4
black_screen_end
 

 
bss_end       		ds.l 1 						; One final long so we can clear stuff without checking for overflows



 end

