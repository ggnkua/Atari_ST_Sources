
;
; Screen Display
; $FFFF8201  r/w  |xxxxxxxx|          Video base high
; $FFFF8203  r/w  |xxxxxxxx|          Video base medium
; $FFFF8205  r    |..xxxxxx|          Video address counter high (r/w on STe)
; $FFFF8207  r    |xxxxxxxx|          Video address counter med (r/w on STe)
; $FFFF8209  r    |xxxxxxx.|          Video address counter low (r/w on STe)
; $FFFF820A  r/w  |......xx|          Sync mode
;                        ||__________ External/Internal sync
;                        |___________ 50/60Hz
; 
; $FFFF820D  r/w  |xxxxxxx.|          STe video base low
; $FFFF820F  r/w  |xxxxxxxx|          STe over-length line width
; $FFFF8240  r/w  |....xxxxxxxxxxxx|  Palette colour (1 word each, first of 16)
;                      ||  ||  ||____ Blue intensity (0-7)
;                      ||  ||  |_____ STe blue LSB
;                      ||  ||________ Green intensity (0-7)
;                      ||  |_________ STe green LSB
;                      ||____________ Red intensity (0-7)
;                      |_____________ STe red LSB
; 
; $FFFF8260  r/w  |......xx|          Screen resolution
;                        |___________ 0 - 320x200x4
;                                     1 - 640x200x2
;                                     2 - 640x400x1
; 
; $FFFF8264  r/w  |....xxxx|          Undocumented STE pixel hard scroll
; $FFFF8265  r/w  |....xxxx|          STE pixel hard scroll
; 
; MEGA STE
; ========
; The Mega STE has a register to control speed and cach status:
;  $FFFF8E21  - - - -  - - X X
; Bit 0 controls the clockspeed (0 = 8 MHz, 1 = 16 MHz), the upper bit controls the cache (0 = Cache off, 1 = cache on). 
; Some docs say that all upper 15 bits of $FFFF8E20 need to be set to "1" to turn the cache on. 
; Writing to this register in anything but a Mega STE will most probably lead to a crash, so be sure to check the Cookie Jar for _MCH 
; to estimate wether this is a Mega STE or not (Upper word is 1 for STE, lower word is 0x0010 for Mega STE, 0x0000 for anything else).


; ST Overscan    =416*276
; Falcon Overscan=384*240


; ================================
;         Machine detected
; ================================

MACHINE_ST 		equ 0
MACHINE_TT		equ 1
MACHINE_FALCON	equ 2
MACHINE_WEIRD	equ 3


; ================================
;         Utility macros
; ================================


update_buffer_size macro
 iflt big_buffer_size-__RS	
big_buffer_size set __RS
 endc
 endm


pause macro		; Fast mode 
delay set \1
 ifne delay<9
t4 set (delay)/5
t3 set (delay-t4*5)/3
t2 set (delay-t4*5-t3*3)/2
t1 set (delay-t4*5-t3*3-t2*2)
  dcb.w t4,$2e97  ; move.l (a7),(a7)  20/5
  dcb.w t3,$1e97  ; move.b (a7),(a7)  12/3
  dcb.w t2,$8080  ; move.b d0,d0       8/2 (or.l d0,d0)
  dcb.w t1,$4e71  ; nop                4/1
 else 
  ifne delay>100
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
  
BREAK macro
 movem.l d0-a6,-(sp)
 bsr RestoreSystem
 movem.l (sp)+,d0-a6
 illegal
 endm

STEEMBREAK macro
 ifne enable_steembreak
 move.b #1,$FFC123
 endc
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
 
  
COLORHELP macro
 ifne enable_colorhelpers
 move.w \1,$ffff8240.w
 endc
 endm

COLORSWAP macro
 ifne enable_colorhelpers
 neg.w $ffff8240.w
 endc
 endm

;
; Check if an adress register is between adequate boundaries
;
BOUNDCHECK macro
 ifne enable_boundschecker
 move.l \1,BCValue
 move.l \2,BCLow
 move.l \3,BCHigh
 bsr BoundChecks
 endc
 endm
 
 ifne enable_boundschecker
 
BCValue	ds.l 1
BCLow	ds.l 1
BCHigh	ds.l 1

;
; d1<=d0<=d2
BoundChecks
 movem.l d0-d2,-(sp)
 movem.l BCValue,d0-d2 
 cmp.l d0,d1
 beq.s .exit
 bcc.s .crash
 cmp.l d0,d2
 bcc.s .exit

.crash
 move.w #$700,$ffff8240.w
 move.l a0,d1
 move.l #1,a0
 move.l #0,(a0)				; Provoke some error :)
 move.l d1,a0
 
.exit
 movem.l (sp)+,d0-d2
 rts

 endc
 
 
 
 

DEBUG_START macro
 ifne enable_debug_text
 move.l character_buffer_base,saved_character_buffer_base
 move.l character_xpos,saved_character_xpos		; xpos & ypos
 clr.l character_xpos							; xpos & ypos
 endc
 endm

DEBUG_FINISH macro
 ifne enable_debug_text
 move.l saved_character_buffer_base,character_buffer_base
 move.l saved_character_xpos,character_xpos		; xpos & ypos
 endc
 endm
   
DEBUG_PRINT_STRING macro
 ifne enable_debug_text
 movem.l d0-a6,-(sp)
 lea string\@,a0
 bra.s jmp\@
string\@ 
 dc.b \1,0
 even
jmp\@  
 bsr DebugPrintString
 movem.l (sp)+,d0-a6
 endc
 endm
  
DEBUG_PRINT_VALUE macro
 ifne enable_debug_text
 movem.l d0-a6,-(sp)
 move \1,d0
 and.l #$ffff,d0
 bsr DebugPrintValue
 movem.l (sp)+,d0-a6
 endc
 endm

   SECTION BSS
  
 even

saved_character_buffer_base 		ds.l 1
saved_character_xpos				ds.w 1
saved_character_ypos				ds.w 1
 
 
;
; MonST commands:
; - O = Evaluate expression
;
; - CTRL-Z = Trace
; - CTRL-A = 
; - CTRL-R = Run
; - CTRL-B = Set Breakpoint
; - ALT-B = Set Breakpoint
; - ALT-R = Set register value
;
; - ALT-A or M = Change window adress
; - ALT-L = Lock to expression
; - ALT-G = Goto source line
;
; - ALT-E = Edit View
; - ALT-F = Font size
; - ALT-S = Split window
; - ALT-T = Change window type
; - ALT-W = Widen window
; - ALT-Z = Zoom window



