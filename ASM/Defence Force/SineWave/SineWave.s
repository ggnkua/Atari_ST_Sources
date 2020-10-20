;
;                Horizontal Sine Shifting
;                    on the Atari STE
;
; Inspired by the blog article from Mark Wrobel who explained how to do it 
; on the Amiga using the Copper, and apparently people on Twitter were interested
; to know how I did that in my old Atari STe demos, so there it is.
;
; The original blog post is https://www.markwrobel.dk/post/amiga-machine-code-letter12-wave/
; Twitter thread: https://twitter.com/mark_wrobel/status/1316338201452257280
;
; System requirements: Half meg Atari STE or Mega STe
;
 
 .macro pause delay
  dcb.w \delay,$4e71
 .endm

	.text

ProgStart: 
 ; Call the main routine in supervisor mode
 move.l #SupervisorMain,-(sp)
 move.w #$26,-(sp)
 trap #14
 addq.w #6,sp

 ; Quit
 clr.w -(sp)
 trap #1

 
SupervisorMain:
 ; We need to start by clearing the BSS in case of some packer let some crap
 ; (This has to be done first, else we will lose data)
 lea bss_start,a0         
 lea bss_end,a1 
 moveq #0,d0
.loop_clear_bss:
 move.l d0,(a0)+
 cmp.l a1,a0
 ble.s .loop_clear_bss

 ;
 ; We need to know on which machine we are running the intro.
 ; We accept STE and MegaSTE as valid machines.
 ; Anything else will have a nice message telling them to "upgrade" or use an emulator :)
 ;
 bsr DetectMachine
 tst d0
 bne.s setup_system

 ; This machine is not a STE/MSTE, print a message and quit
 pea NotASteMessage
 move #9,-(sp)
 trap #1
 addq #6,sp
 
 ; wait key
 move #7,-(sp)
 trap #1
 addq #2,sp
 rts

NotASteMessage:  dc.b "This demo works only on STE or MegaSTE",0
  .even

 ;
 ; Setup: Save all the system parameters we are going to modify
 ;
setup_system: 
 move.w #$2700,sr
 bsr KeyboardFlushBuffer

 move.b $fffffa07.w,save_iera
 sf $fffffa07.w                         ; Disable iera
 move.b $fffffa09.w,save_ierb
 sf $fffffa09.w                         ; Disable ierb

 move.b $ffff820a.w,save_freq
 move.b $ffff8260.w,save_rez
 move.b #0,$ffff8260.w                  ; Force to 320x200x16 graphic mode
 move.b $ffff8265.w,save_pixl

 move.b $ffff8201.w,save_screen_addr_1  ; Screen base pointeur (STF/E)
 move.b $ffff8203.w,save_screen_addr_2  ; Screen base pointeur (STF/E)
 move.b $ffff820d.w,save_vbaselo        ; Save low byte (STE only)
 
 move.l #empty_line+256,d0              ; Change the screen address to point on some empty data
 lsr.l #8,d0
 move.b d0,$ffff8203.w                  ; STF - Screen base adress (mid byte)
 lsr.w #8,d0
 move.b d0,$ffff8201.w                  ; STF - Screen base adress (high byte)
 move.b #0,$ffff820d.w                  ; STE - Screen base adress (low byte)
 
 move.b $ffff820f.w,save_linewidth
 
 movem.l $ffff8240.w,d0-d7              ; STF/STE Palette
 movem.l d0-d7,save_palette
 movem.l king_tut_picture,d0-d7         ; Replace the palette with our picture's 
 movem.l d0-d7,$ffff8240.w

 move.l $70.w,save_70                   ; VBL
 move.l #FullTimerVbl,$70.w        
 
 tst.b machine_is_megaste
 beq.s .end_megaste
.megaste: 
 move.b $ffff8e21.w,save_mste_cache
 move.b #%00,$ffff8e21.w                ; 8mhz without cache
.end_megaste:
 move.w #$2300,sr

demo_loop:
 ; Wait a bit and then quit
 move #50*300,d0
.wait_loop:

 ; Synchronize with the VBL
 sf flag_vbl
.waive_vbl_loop:
 tst.b flag_vbl
 beq.s .waive_vbl_loop
 sf flag_vbl

 ; Test the keyboard
 btst #0,$fffffc00.w           ; Is a key pressed?
 beq.s .no_key_pressed
 cmp.b #$39,$fffffc02.w        ; $39 is the key code for the SPACE bar
 beq.s .exit_loop
.no_key_pressed:
 dbra d0,.wait_loop
.exit_loop:

 ; Restore all the system parameters we saved earlier
restore_system: 
 move.w #$2700,sr
 bsr KeyboardFlushBuffer
 move.b save_iera,$fffffa07.w
 move.b save_ierb,$fffffa09.w

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
 beq.s .end_megaste 
.megaste: 
 move.b save_mste_cache,$ffff8e21.w
.end_megaste:
 move.w #$2300,sr
 rts

 
; 0-200 
; 245/7 for 50hz interrupt (7=prediv 200) 
; 150/5 for normal screen sync
;  99/4 for top border (4=prediv 50)
FullTimerVbl:
 movem.l d0-a6,-(sp)
 
 st flag_vbl

 ; Move stuff around
 move.w king_tut_sinus_offset,d3
 add.w #2,d3
 move.w d3,king_tut_sinus_offset

 move.l #empty_line+32,d4
 lsl.l #8,d4

 move.l #king_tut_picture+32,d5
 lsl.l #8,d5
 move.l #208<<8,d6                    ; 12/3
 
 lea $ffff8260.w,a0       ; 8/2 resolution 
 lea $ffff820a.w,a1       ; 8/2 frequence
 lea sine_255,a2
  
 .opt "~oall"
  
 ; STE hardware compatible synchronization code
synchronize: 
 move.b #0,$ffff8209.w 
 moveq #16,d2
.wait_sync:
 move.b $ffff8209.w,d0
 beq.s .wait_sync
 sub.b d0,d2
 lsl.b d2,d0
 
synchronization_done:
 pause 85

 move.w #199-1,d7       ; 8/2
king_tut_picture_loop: 
 movep.l d4,-5(a1)      ; 24/6 - SCREEN ADDRESS ($ffff8205/07/09/0B)
 move.b d4,91(a1)       ; 12/3 - PIXEL SHIFT ($ffff8265)

 move.w a0,(a0)         ; 8/2 - LEFT BORDER OPENING
 move.b d0,(a0)         ; 8/2 - LEFT BORDER OPENING

 pause 62
 moveq.l #0,d1          ; 1
 moveq.l #0,d2          ; 1
 and.w #510,d3          ; 2 
 move.w (a2,d3),d1      ; 4
 addq.w #2,d3           ; 1 

 move.l d5,d4           ; 1
  
 move.w d1,d2           ; 1
 and.w #15,d1           ; 2 
 move.b d1,d4           ; 1 Pixel shift

 lsr #4,d2              ; 4
 lsl #3,d2              ; 3
 lsl #8,d2              ; 6
 add.l d2,d4            ; 2 Final offset

 move.b d0,(a1)         ; 8/2 - RIGHT BORDER OPENING
 move.w a0,(a1)         ; 8/2 - RIGHT BORDER OPENING

 add.l d6,d5            ; 2
 pause 15
 dbra d7,king_tut_picture_loop     ; 12/3 taken, 16/4 not-taken

 .opt "+o"

 sf.b $ffff8265.w       ; End of Screen stabilizer (reset the pixel offset)
   
 movem.l (sp)+,d0-a6
 rte 
 


;
; The Cookie Jar can be used to detect the type of machine.
; This feature was first implemented on the STE.
; So if the Cookie Jar is missing we can safely assume we are running on a STF machine.
; 
; http://leonard.oxg.free.fr/articles/multi_atari/multi_atari.html
;
DetectMachine: 
 sf machine_is_ste
 sf machine_is_megaste
 
 move.l	$5a0.w,d0
 bne.s .found_cookie
 ; No cookie, this is a ST
.detection_refused:
 moveq #0,d0 
 rts 
   
.found_cookie:
 ; We found a cookie pointer, this is not a ST for sure
 move.l	d0,a0
.loop_cookie:	
 move.l (a0)+,d0			; Cookie descriptor
 beq.s .detection_refused
 move.l (a0)+,d1			; Cookie value
 
 cmp.l #"CT60",d0
 beq.s .detection_refused	; We do not run on Falcon, accelerated or not
 cmp.l #"_MCH",d0
 bne.s .loop_cookie
 
.found_machine:
 cmp.l #$00010000,d1
 beq.s .found_ste
 cmp.l #$00010010,d1
 beq.s .found_mste
 bra.s .detection_refused	; We do not run on TT

.found_mste:
 st machine_is_megaste 
.found_ste: 
 st machine_is_ste
.found_st: 
 moveq #-1,d0 
 rts


KeyboardFlushBuffer:
 btst.b #0,$fffffc00.w			; Have we some keys to wait for ?
 beq.s .exit
 tst.b $fffffc02.w
 bra.s KeyboardFlushBuffer
.exit:
 rts
 

	.data

king_tut_picture:   incbin "exported\\tutankhamun.pi1"  ; 32 bytes of palette, then 200 lines of 408 pixels (overscan)
sine_255:           incbin "exported\\sine_255.bin"     ; 16 bits, unsigned between 00 and 127

	.bss	

bss_start:
	.even

save_70:      			     ds.l 1	   ; VBL handler
save_palette:	 		       ds.w 16

king_tut_sinus_offset:   ds.w 1    ; Position in the sinus table

empty_line:              ds.b 256+230  ; Some empty bytes to have something "clean" to display during the sync line

machine_is_ste:			  ds.b 1
machine_is_megaste:	  ds.b 1
save_mste_cache:		  ds.b 1

save_iera:			      ds.b 1	; Interrupt enable register A
save_ierb:			      ds.b 1	; Interrupt enable register B

save_freq:    		    ds.b 1
save_rez:     		    ds.b 1
save_pixl:    		    ds.b 1

save_screen_addr_1: 	ds.b 1
save_screen_addr_2: 	ds.b 1
save_vbaselo:    		  ds.b 1
save_linewidth:			  ds.b 1

flag_vbl:		 		      ds.b 1	; Set to true at the end of the main screen handling interupt

	.even
bss_end:
	.end
