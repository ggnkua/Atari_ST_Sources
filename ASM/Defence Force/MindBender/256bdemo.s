;
;      Dbug's 256 bytes intro for Sommarhack 2020
;                    2020, 28th of May
;
; Inspired by Patapom Facebook post with this brainteaser picture
;
; https://www.facebook.com/Patapom/posts/10158451888604846
;
; Size evolution over time:
; -- 2020-05-28:
; 1207 bytes - first working version of the effect with the visible distortion
; 1051 bytes - removed setup and debug infos
;  930 bytes - can't quit anymore, no restore, no keypress
;  482 bytes - not sure what I changed...
;  478 bytes - replaced supexec by super
;  463 bytes - not clearing IMRA and IMRB anymore
;  331 bytes - Replaced the nops by a dbra
;  325 bytes - Removed one useless color change
;  296 bytes - Replaced the color mapping table by a rotated bitfield
;
; -- 2020-05-29:
;  284 bytes - Replaced the blocks 2 and 5 nops by single instructions taking the same time
;  282 bytes - Replaced a move.b #0 by a sf
;  265 bytes - Changed the generation of the bitmap pattern
;  260 bytes - Replaced a few move.w #0, by clr.w
;  258 bytes - Accessed $ff8240 through an address register
;  256 bytes - Played with the initial temporisation code
;
; -- 2020-05-30:
;  244 bytes - Used the default screen instead of setting up mine
;  240 bytes - Changed the pattern generation to use bitplans offsets
;  238 bytes - Optimize the color setting for the bitmaps
;  254 bytes - Added a text and some fancy colors on the top
;  252 bytes - Reduced a constant value from .l to .w
;  250 bytes - Removed a sf $ffff8209.w which I did not need anymore
;  240 bytes - Reorganized the post video sync delay loop
;


enable_proper_setup		equ 0     ; Enables the tabbed out code

 opt o+,w+



;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;% Macro qui fait une attente soit avec une succession de NOPs %
;% (FAST=1), soit en optimisant avec des instructions neutres  %
;% prenant plus de temps machine avec la mˆme taille	       %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause macro
t6 set (\1)/6
t5 set (\1-t6*6)/5
t4 set (\1-t6*6-t5*5)/4
t3 set (\1-t6*6-t5*5-t4*4)/3
t2 set (\1-t6*6-t5*5-t4*4-t3*3)/2
t1 set (\1-t6*6-t5*5-t4*4-t3*3-t2*2)
 dcb.w t6,$e188  ; lsl.l #8,d0        6
 dcb.w t5,$ed88  ; lsl.l #6,d0        5
 dcb.w t4,$e988  ; lsl.l #4,d0        4
 dcb.w t3,$1090  ; move.b (a0),(a0)   3
 dcb.w t2,$8080  ; or.l d0,d0         2
 dcb.w t1,$4e71  ; nop                1
 endm
   
 SECTION TEXT
  
; ------------------
;   Program start
; ------------------
ProgStart 
 ifne enable_proper_setup

			 ; We call the main routine in supervisor mode
			 ; and when we come back, we return to the caller 
			 move.l #super_main,-(sp)
			 move.w #$26,-(sp)         ; XBIOS: SUPEXEC
			 trap #14
			 addq.w #6,sp

			 clr.w -(sp)               ; GEMDOS: PTERM(0)
			 trap #1

 else

 ; We switch to supervisor, but never come back
 ; so no need to correct the stack pointer
 clr.l -(sp)
 move.w #$20,-(sp)  ; GEMDOS: SUPER
 trap #1

 endc
	
super_main
 lea $ffff8240.w,a6
 move.l #$07770727,$ffff8242.w  ; The White and Purple crosses [Could be 2(a6) but same size]

 ifne enable_proper_setup
			 ;
			 ; Save context
			 ;
			 move.b $fffffa07.w,save_iera
			 move.b $fffffa09.w,save_ierb
			 move.b $ffff8260.w,save_resol

			 clr.w -(sp)
			 pea -1.w
			 pea -1.w
			 move.w #5,-(sp)
			 trap #14
			 lea 12(sp),sp
 endc

 ;
 ; Print the Dbug title
 ;
 pea Message(pc)
 move.w #9,-(sp)
 trap #1
 ifne enable_proper_setup
 			addq.l #6,sp
 endc

 ;
 ; Draw the cross patterns
 ;
 move.l $44e.w,a0            ; screenpt
 lea 160*5(a0),a0 

 move.w #%0110100101101001,d3

 moveq #7-1,d1
loop_y 
 move.l a0,a1

 move.l d3,d4
 lsr.l #1,d3

 moveq #10-1,d0
loop_x 
 ;moveq #0,d2
 ;addx d2,d2
 ;add d2,d2
 move.w d4,d2
 lsr.l #1,d4
 and #2,d2

 lea 0(a1,d2.w),a2

 lea Patterns(pc),a3
 moveq #10-1,d5
loop_pattern 
 move.w (a3)+,(a2)
 lea 160(a2),a2
 dbra d5,loop_pattern

 lea 16(a1),a1

 dbra d0,loop_x 
 lea 160*30(a0),a0
 dbra d1,loop_y

 ;
 ; VSync and disable interrupts
 ;
 move.w #37,-(sp)       ; VSYNC
 trap #14
 ifne enable_proper_setup
 			addq.l #2,sp
 endc

 ;
 ; Main loop
 ;
 move.w #$2700,sr
loop
 move.w #$345,(a6)          ; Light blue-gray background
 
 ; We do the key check before the synchronisation to avoid wobbly rasters
 ifne enable_proper_setup
			 cmp.b #$39,$fffffc02.w
			 beq.s exit
 endc

 move.w #$370,d6        ; Color of first tile
 move.w #$263,d7        ; Color of second tile
 move.w #$fff,8(a6)


 ; Line zero synchronisation
 moveq #14,d2
.wait_sync
 move.b $ffff8209.w,d0
 beq.s .wait_sync
 sub.b d0,d2
 lsl.b d2,d0

 ; 366*3=1098
 ; 274*4=1098

 ; To leave room for the "Dbug" line
 ; 64 nops*8 = 
 ;move.w #138-1,d0
 move.w #157-1,d0
delay
 subq.w #1,8(a6)
 dbra d0,delay    ; 3

 ; The alternated color grid
 moveq #10-1,d1 
loop_lines

 ; 247
 move.w #242-1,d0
loop_squares
 move.w d6,(a6)                ; 8/2   background color change

 lsl.l #8,d3        		   ; 24/6 (DELAY)

 move.w d7,(a6)                ; 8/2    background color change

 move.w (a6),(a6) ;pause 3                      ; (DELAY)

 dbra d0,loop_squares         ; 12/3 if branches / 16/4 if not taken

 ;pause 2                      ; (DELAY)
 addq #1,d6
 ;addq #1,d7
 nop

 dbra d1,loop_lines 
 bra.s loop
exit

 ;
 ; Restore system
 ;
 ifne enable_proper_setup
			 move.w #$2700,sr

			 moveq #0,d0
			 move.b save_resol,d0
			 move.w d0,-(sp)
			 pea -1.w
			 pea -1.w
			 move.w #5,-(sp)
			 trap #14
			 lea 12(sp),sp

			 move.b save_iera,$fffffa07.w
			 move.b save_ierb,$fffffa09.w
			 move.b save_resol,$ffff8260.w
			 
			 move.w #$700,$ffff8242.w
			 move.w #$000,$ffff8244.w
			 move.w #$000,$ffff8246.w

			 move.w #$777,$ffff8240.w

			 move.w #$2300,sr
			 rts
 endc


Patterns
 dc.w %0000000001100000
 dc.w %0000000001100000
 dc.w %0000000011110000
 dc.w %0000001111111100
 dc.w %0000111111111111
 dc.w %0000111111111111
 dc.w %0000001111111100
 dc.w %0000000011110000
 dc.w %0000000001100000
 dc.w %0000000001100000

Message
 dc.b 27,"b",4     ; Set 1 as Ink color
 dc.b 27,"E"        ; Erase Screen
 ;dc.b "Dbug's ",174,"OverBender",175," at Sommarhack",191," 2020 "
 ;dc.b "Dbug's ",174,"OverBender",175
 ;dc.b "Dbug's ",240,240,27,"p"," MindBender ",27,"q",240,240
 ;dc.b "Dbug ",27,"p",242,"MindBender",243,27,"q"
 ;dc.b "Dbug ",27,"p",248,"MindBender",248,27,"q"
 ;dc.b "Dbug ",247,32,"MindBender",191
 dc.b "Dbug @ Sommarhack 2020"
 dc.b 0
 
 ifne enable_proper_setup
 SECTION BSS

save_iera			ds.b 1	; Interrupt enable register A
save_ierb			ds.b 1	; Interrupt enable register B
save_resol			ds.b 1	; Screen resolution
 endc

 end

<_Dbug_> I don't remember the PRG format, is it normal there are 4 bytes at zero at the end ?
<ggn> yes
<ggn> relocation table
<_Dbug_> So I guess that means I successfully manage to be all pcrelative?
<ggn> ABSFLAG   
<ggn> 0x1A 
<ggn>   This WORD flag should be non-zero to indicate that the program has no fixups or 0 to indicate it does.Since some versions of TOS handle files with this value being non-zero incorrectly, it is better to represent a program having no fixups with 0 here and placing a 0 longword as the fixup offset.  
<ggn> so in in theory you can remove that 0.l and fix ABSFLAG to non-zero
<ggn> in practice however.... go and read the pack-fire page on pouet
<_Dbug_> I'll keep that in mind for if I need these 4 more bytes
<ggn> yeah also if you want your thing to crash on startup randomly
<_Dbug_> Ha, yeah no, that stinks :p

