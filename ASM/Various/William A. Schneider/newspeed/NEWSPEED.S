;*************************************************
;* NEWSPEED  by  William A. Schneider            *
;* Copyright 1989 Antic Publishing               *
;*                                               *
;*                                               *
;* This program is a terminate-&-stay-resident   *
;* utility -- place it in the AUTO folder and    *
;* it will be installed at boot-up or run it     *
;* from the desktop.  It will not survive a      *
;* warm boot.                                    *
;*************************************************

resetsp equ      $0    ;4 byte value for Stack Pointer after reset
resetpc equ      $4    ;4 byte value for Program Counter after reset
timerc equ     $114    ;timer C (system clock) interrupt vector
                       ;   executed 200 times per second
memvalid equ   $420    ;4 byte value for valid memory configuration
flock equ      $43e    ;2 byte value = 0 if no disk access in progress
sysbase equ    $4f2    ;4 byte pointer to start of operating system
hz_200 equ     $4ba    ;4 byte value that is incremented by 1 with
                       ;   each clock cycle (200 times per sec)

begin:

message:
; Send installation message to screen
 move.l  #installmessage,-(sp)     ;point to installation message
 move.w  #$09,-(sp)                ;GEMDOS PRINT LINE command
 trap    #1                        ;print the message on the screen
 addq.l  #6,sp                     ;restore stack

 bsr     sound

; Send blank lines to screen
 move.l  #blanklines,-(sp)     
 move.w  #$09,-(sp)            
 trap    #1                    
 addq.l  #6,sp                 

; Call code that installs hooks in SUPVR mode
 move.l  #hook,-(sp)               ;point to code at hooks
 move.w  #38,-(sp)                 ;XBIOS SUPER mode command
 trap    #14                       ;execute code at hooks in supvr mode
 addq.l  #6,sp                     ;restore stack

; Terminate program and protect memory for TSR code
 clr.w   -(sp)                     ;termination code of 0
 move.l  #(finish-begin+256),-(sp) ;bytes to protect at program start
 move.w  #$31,-(sp)                ;GEMDOS KEEP PROCESS command
 trap    #1                        ;terminate and protect memory

; Subroutine to install hook
hook:
; Install hook to delay routine
 move.l  timerc,oldtimer   ;save timer C vector
 move.l  #tsrcode,timerc   ;redirect timer C to delay routine
											
; Determine memory location for keyboard shift status.
 move.l  #$e1b,d0          ;location for pre-1987 ROMs
 movea.l $4f2,a0           ;pointer to start of operating system
 cmpi.w  #$1988,$1a(a0)    ;check for ROM creation year
 bne.s   tstfor1987
 move.l  #$e63,D0          ;location for 1988 ROMs
 bra.s   dateset
tstfor1987:
 cmpi.w  #$1987,$1a(a0)
 bne.s   dateset
 move.l  #$e61,d0          ;location for 1987 ROMs
dateset:
 move.l  d0,key            ;save location of keyboard shift status

; Pause 2 sec to read installation message
; (Is in hook routine because next instruction must execute in supvr mode)
 move.l  hz_200,d0         ;get current clock count
 add.l   pausesec,d0       ;change to what clock count will be after pause
messagepause:
 cmp.l   hz_200,d0              ;pause for 2 sec after key was selected
 bne     messagepause

 rts

;-----------------------------------------------------------------------
; TSR code that executes 200 times per second

tsrcode:

 tst.w   flock             ;test for disk access
 bne     return            ;return if access in progress (<>0)

 move.w  sr,-(sp)          ;save status register to restore
                	   ;   when we exit

;set the interrupt to 5 so the MFP interrupts (which includes timer C)
;will be disabled.  If left active, our routine would be interrupted
;200 times per second by itself and lock up.

 move.w  #$2500,sr         ;supvr mode, set interrupt at 5
 
 movem.l d0/a0,-(sp)       ;save to restore when we exit
 movea.l key,a0            ;load location of keyboard shift status byte
 move.b  (a0),d0           ;move keyboard shift status byte to d0
 andi.b  #$f,d0		   ;strip bits 4 thru 7 to strip caps lock bit
 cmp.b   hotkey,d0         ;check for Ctl+Alt
 bne     delaycode         ;branch if not Ctl+Alt

 movem.l d6/a1/a6,-(sp)    ;save registers to restore when we exit

;Stop all sound by writing $FF into sound register 7, the 
;noise/tone/port enable register.  To place a value into a sound
;register, you must:
;   - put the selected register number (0-15) into $FF8800
;   - write the byte to be placed in the selected register into $FF8802
;The XBIOS 28 Giaccess routine could also be used.
 move.l  #$ff8800,a0
 move.b  #7,(a0)	
 move.l  #$ff8802,a1	
 move.b  #$ff,(a1)

; Get screen address
 move.w  #2,-(sp)          ;XBIOS PHYSBASE command
 trap    #14               ;get screen base address
 addq.l  #2,sp             ;restore stack
 move.l  d0,scrnadrs       ;save scrnadrs

; Save top line of screen for later restore
 movea.l  d0,a0            ;screen start address
 movea.l  #scrnstorage,a1  ;temp buffer to hold top line
 move.l   #1440,d0         ;number of bytes to save
scrnsave:
 move.b  (a0)+,(a1)+       ;copy 1st 1440 bytes of screen
 dbra    d0,scrnsave       ;   to scrnstorage

; I cannot be sure what color combinations may be in place during
; the program in progress.  Therefore, to be sure that our prompt
; will be visible, we will need to set our own colors.  First we
; will save the current colors for later restoration.

; Save the original palette
 move.l  #15,d6            ;set up counter and color number
 movea.l #origpalette,a6   ;area to save colors
savecolors:
 move.w  #-1,-(sp)         ;-1 returns current color value
 move.w  d6,-(sp)          ;color number
 move.w  #7,-(sp)          ;XBIOS SET COLOR command
 trap    #14               ;get color value
 addq.l  #6,sp             ;restore stack
 move.w  d0,(a6)+          ;save color value
 dbra    d6,savecolors     ;do for 16 colors

; In order to make our colors effective in all resolutions, I will
; set colors 1 thru 15 to black and color 0 to white.  This will
; also make it very evident when the screen changes that our hook
; is waiting for keyboard input.

; Set colors 0 thru 15 to black
 move.l  #15,d6            ;set up counter and color number
setcolors:
 move.w  #$777,-(sp)       ;value for black
 move.w  d6,-(sp)          ;color number
 move.w  #7,-(sp)          ;XBIOS SET COLOR command
 trap    #14               ;change color value
 addq.l  #6,sp             ;restore stack
 dbra    d6,setcolors      ;do for 16 colors

; Set color 0 to white
 move.w  #0,-(sp)          ;value for white
 move.w  #0,-(sp)          ;color number
 move.w  #7,-(sp)          ;XBIOS SET COLOR command
 trap    #14               ;change color value
 addq.l  #6,sp             ;restore stack

; Send choose message to screen
 move.l  #choosemessage,-(sp)      ;point to choose message
 move.w  #$09,-(sp)                ;GEMDOS PRINT LINE command
 trap    #1                        ;print the message on the screen
 addq.l  #6,sp                     ;restore stack

select_key:
; Get next key selected from keyboard
 move.w  #2,-(sp)          ;read from console
 move.w  #2,-(sp)          ;BIOS BCONIN command
 trap    #13               ;get key code
 addq.l  #4,sp             ;restore stack

; After BCONIN, the ASCII code of the character selected is in the 
; lower byte of d0

chkforwarmboot:
 cmpi.b  #$08,d0           ;check for backspace key
 bne     chkforcoldboot    ;if no, check for cold boot
; Do a warmboot
 move.w  resetsp,sp        ;set supvr stack pointer
 move.l  resetpc,a0        ;load program counter
 jmp     (a0)              ;jump to reset program counter

chkforcoldboot:
 cmp.b   #$7f,d0           ;check for delete key
 bne     chkforspeedchg    ;if no, check for speed change

; Do a cold boot
coldboot:
 clr.l   memvalid          ;force a coldstart
 move.l  sysbase,a0        ;find system base address
 jmp     (a0)              ;jump to start of operating system

chkforspeedchg:
; Look for keys 0-9

 subi.b  #$30,d0           ;convert ASCII code to number 0-9
 cmpi.b  #0,d0
 blt     select_key        ;code out of range (below 0), try again
 cmpi.b  #$9,d0
 bgt     select_key        ;code out of range (above 9), try again
 and.l   #255,d0           ;clear all but low byte

; Calculate the delay loop counter value.
 mulu    factor,d0         ;calc delay
 move.l  d0,delay          ;save delay

; Send pause message to screen
 move.l  #pausemessage,-(sp)    ;point to pause message
 move.w  #$09,-(sp)             ;GEMDOS PRINT LINE command
 trap    #1                     ;print the message on the screen
 addq.l  #6,sp                  ;restore stack

;pause loop
 move.l  #15,d0                
pause1:
 move.l  #$ffffff,d6
pause2:
 dbra    d6,pause2
 dbra    d0,pause1

; Restore original palette
 move.l  #15,d6            ;set up counter and color number
 movea.l #origpalette,a6   ;area where original colors are saved
restorecolors:
 move.w  (a6)+,-(sp)       ;color value
 move.w  d6,-(sp)          ;color number
 move.w  #7,-(sp)          ;XBIOS SET COLOR command
 trap    #14               ;set color value
 addq.l  #6,sp             ;restore stack
 dbra    d6,restorecolors  ;do for 16 colors

; Restore top screen line where message was written
 movea.l scrnadrs,a0
 movea.l #scrnstorage,a1
 move.l  #1440,d0
scrnrestore:
 move.b  (a1)+,(a0)+
 dbra    d0,scrnrestore

 movem.l (sp)+,d6/a1/a6

;-----------------------------------------------------------------------
; Actual TSR slowdowm code

delaycode:

 cmpi.l  #0,delay
 beq     enddelay          ;no slowdown if delay = 0
 move.l  delay,d0          ;load delay counter

loop:                      ;actual delay loop
 dbra    d0,loop

enddelay:
 movem.l  (sp)+,d0/a0      ;restore registers
 move.w  (sp)+,sr          ;restore status register

return:
 move.l oldtimer,-(sp)
 rts                       ;jump to old timer c vector

; Sound subroutine
sound:
 move.l  #bell,-(sp)            
 move.w  #$09,-(sp)        ;GEMDOS PRINT LINE command
 trap    #1                ;sound bell
 addq.l  #6,sp             ;restore stack
 rts


; Working data area

 dc.b   " Next byte is hotkey"    ;marker to find patch byte position
hotkey:                    ;special key combination to initiate
 dc.b	$c	           ;keyboard shift status for CTL + ALT
                           ;If another combination is desired, 
                           ;replace with one of the following
                           ;   dc.b  $6      for CTL + LSHIFT
                           ;   dc.b  $e      for CTL + LSHIFT + ALT
                           ;   dc.b  $a      for LSHIFT + ALT
 dc.b   0,0,0
key:
 dc.l   0                  ;keyboard code

 dc.b   "Next 4 bytes are message pause count"   ;marker to find patch byte
pausesec:
 dc.l   400                ;message pause count  400 = 2 seconds
oldtimer:
 dc.l   0                  ;original timer c vector
factor:
 dc.w   $0140              ;speed factor
delay:
 dc.l   0                  ;delay count
scrndump:               
 dc.l   0                  ;original screen dump vector
scrnadrs:
 dc.l   0                  ;screen start address
scrnstorage:
 ds.b    1440              ;storage space for 1 line of screen
origpalette:
 ds.w    16

; Installation announcement string
installmessage:
 dc.b    27,"E"
 dc.b    '**************************************',13,10
 dc.b    '*  NEWSPEED by William A. Schneider  *',13,10
 dc.b    '*  Copyright 1989 Antic Publishing   *',13,10
 dc.b    '*                                    *',13,10
 dc.b    '*      HOT KEY = CTL + ALT           *',13,10
 dc.b    '*                                    *',13,10
 dc.b    '*    After initiation:               *',13,10
 dc.b    '*                                    *',13,10
 dc.b    '*      Bksp for warm boot            *',13,10
 dc.b    '*      Del for cold boot             *',13,10
 dc.b    '*      # for new speed               *',13,10
 dc.b    '*      Where #=0 for normal speed    *',13,10
 dc.b    '*          1 is slower               *',13,10
 dc.b    '*            - etc -                 *',13,10
 dc.b    '*          9 is slowest              *',13,10
 dc.b    '**************************************',13,10,10

blanklines:
 dc.b    13,10,10,0

bell:
 dc.b    7,0               ;bell code (7)

choosemessage:
 dc.b    27,'H',27,'K'     ;VT52 codes to home
                           ;  cursor then erase line
 dc.b    'Select: Del (CBoot), Bksp (WBoot), 0-9',0    ;text to display

pausemessage:
 dc.b    27,'H',27,'K'
 dc.b    'Pausing - get ready to continue',0

finish:
 end
 