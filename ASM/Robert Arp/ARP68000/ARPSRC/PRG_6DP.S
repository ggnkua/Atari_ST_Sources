 ; Program Name: PRG_6DP.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;     Assemble in PC-relative mode and save with a PRG extension.

 ; Execution Instructions:

 ;     Execute from the desktop.

 ; Program Function:

 ; Turns off keyclick sound.  Refer to page 254 of the Internals book.  The
 ; system variable at address $484 is a byte length variable.  The bits of
 ; this variable have the meanings as indicated in the Internals book.  The
 ; bit of interest is #0.  When this bit is a one, the computer emits a
 ; click each time a key is pressed.  When the bit is a zero, these clicks
 ; are not emitted.  A zero is placed in this bit by replacing the content
 ; of the byte at $484 (which is 7 before the replacement, if key click is
 ; enabled) with $6.

 ; If the object code for this program has a PRG extension, it may be placed
 ; in the AUTO folder of a boot disk or hard disk partition so that it will
 ; be executed during power up.  The reason for doing this would be to 
 ; disable the key click without the presence of the desk accessory CONTROL,
 ; thereby conserving the memory required by CONTROL.ACC.

 ; Of course, the program need not be executed at power up.  It may be
 ; executed from the desktop whenever you wish to do so.

 ; Program Purpose:

 ; 1. Illustrate the use of GEMDOS function $20.

 ; 2. Illustrate the manner in which a system variable may be altered.

 ; 3. Show how the key click may be disabled without the presence of
 ;    CONTROL.ACC as a desk accessory.

 ; 4. Show how to save a few lines of code by not repositioning the stack
 ;    pointer after the first GEMDOS $20 call, then by using address register
 ;    indirect with displacement addressing to store the SSP within the stack.

mainline:
 lea        stack, a7           ; Point A7 to this program's stack.

 ; NOTE: For many programs, an extensive initialization routine is not
 ;       necessary nor desirable.  Here, for instance, since this program
 ;       will simply execute, remaining in memory for a very brief period,
 ;       and since no other program will be executed in the mean time, there
 ;       is no reason to calculate the program's size and return excess
 ;       memory to the operating system.

enter_supervisor_mode:
 move.l     #0, -(sp)           ; The zero turns on supervisor mode.
 move.w     #$20, -(sp)         ; Function = super = GEMDOS $20.
 trap       #1                  ; Content of SSP returned in D0.
 move.l     d0, 2(sp)           ; Store returned value in stack.
                                ; Do not reposition stack pointer.

disable_key_click:
 move.b     #6, $484            ; Refer to page 254 of the Internals book.

return_to_user_mode:            ; Stack is already setup.
 trap       #1                 
 addq.l     #6, sp              ; Now reposition stack pointer to top.

terminate:
 move.w     #0, -(sp)           ; Function = p_term_old = GEMDOS $0.
 trap       #1                  ; GEMDOS call.
 
             ds.l    24         ; Stack.
stack:       ds.l     0         ; Address of stack.
program_end: ds.l     0
 end
