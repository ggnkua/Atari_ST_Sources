 ; PROGRAM NAME: PRG_6JC.S
 ;      VERSION: 1.001

 ; Assembly Instructions:

 ;    Assemble in Relocatable mode and save with a TOS suffix.

 ; Execution Instructions:

 ;    Execute from the desktop.  Some versions of the ST operating system
 ; may require the printer to be turned on for proper operation of this
 ; trap handler.

 ; Program Function:

 ;    This program establishes itself in memory as a trap #13 handler.  While
 ; the program is resident, it intercepts all trap #13 calls.  If an
 ; intercepted call's function is $3, and if the device involved is the video
 ; screen, then the custom trap handler redirects the call to include output
 ; to the printer as well as to the video screen.  In this manner all text
 ; output to the screen, which is accomplished by BIOS function $3 calls
 ; (GEMDOS calls $2 and $9 are included because these functions rely on
 ; BIOS function $3.) is sent to both the printer and the video screen.
 
 ;    All redirected ASCII codes below $1B, except those for a carriage
 ; return and a linefeed, are filtered out of the data sent to the printer.
 ; This prevents certain ASCII codes that are suitable for the screen but
 ; which are undesirable for the printer from reaching the printer.

 ; MAJOR NOTE:

 ;    If this program is to be used when a software print buffer is to be
 ; simultaneously resident, then the software print buffer program MUST be
 ; executed first.  That is, the software print buffer must already be
 ; resident when this program is executed.

 ; Program Features:

 ; 1. Produces a hardcopy of program input and output that is sent to the  
 ;    screen.  This program eliminates the necessity of providing statements
 ;    in the program to accomplish that task.  It permits the printer listing
 ;    of a program to be followed by a printer listing of user/program
 ;    interaction.  Especially useful for providing the results of an 
 ;    execution for homework problems, or for programs under development.

 ; 2. When compiling, compiler output to the screen will be sent to the
 ;    printer.   Especially useful when debugging the error messages
 ;    that appear on the screen.  The printer output lets you go back to
 ;    the editor with the error list hardcopy.  

 ; 3. If the Show button is selected from the Show/Print/Cancel Desktop
 ;    dialog box, when this program is resident, the data which appears
 ;    on the video screen will also be sent to the printer.

program_start:                     ; Calculate program size and retain result.
 lea        program_end(pc), a3    ; Fetch program end address.
 movea.l    4(a7), a4              ; Fetch basepage address.
 suba.l     a4, a3                 ; Program size is in A3.
 lea        stack(pc), a7          ; Provide a user stack.

install_new_trap_13_vector:
 pea       custom_trap_handler(pc) ; Push new trap handler address onto stack.
 move.w    #$2D, -(sp)             ; Push trap 13 vector number.
 move.w    #5, -(sp)               ; Function = setexec = BIOS $5.
 trap      #13                     ; Current trap handler vector returned in D0.
 addq.l    #8, sp
 move.l    d0, preempted_handler_address

relinquish_processor_control:      ; Maintain memory residency.
 move.w    #0, -(sp)               ; See page 121 of Internals book.
 move.l    a3, -(sp)               ; Program size.
 move.w    #$31, -(sp)             ; Function = ptermres = GEMDOS $31.
 trap      #1

 ; NOTE:

 ;      The custom trap #13 handler is entered each time an application invokes
 ; the trap #13 call.  If the call does not involve printing a character to the
 ; screen, then a jump is performed to the preempted trap #13 handler.
 
 ;      If the call involves printing an escape sequence (An escape sequence
 ; is a two-character code, the first of which is $1B or 27 decimal.  Escape
 ; sequences provide screen control--see section 3.6 "The Atari VT52 Emulator",
 ; pages 245-249 of the Internals book.) for screen control, then the sequence
 ; is sent to the screen via the preempted trap #13 handler.

 ;      Otherwise, for each trap #13 call that is also a bconout invocation
 ; with device code #2, the custom_trap_13 routine is entered three times.
 ; The first time that the handler is entered, a variable is initialized, then,
 ; when it is entered subsequently, a jump, over the initialization sequence,
 ; to the preempted trap handler is performed.  The custom trap handler is
 ; entered three times because the custom handler prints to both the screen
 ; and the printer by invoking its own trap #13 calls; those calls are also
 ; intercepted by the custom handler.

 ;      The custom handler must be able to handle trap #13 calls made while
 ; the processor is in supervisor mode or user mode.

custom_trap_handler:
 tst.b     initialization_flag
 bne       skip_initialization
 
 ; Processing the stack data:

 ;      The location of the stack data that must be processed by this subroutine
 ; depends on the state of the processor when the exception occurs.  If it was
 ; in the supervisor state, then the data will be stacked, as indicated, at the
 ; following relative locations:

 ;                    location - 11 = character to be printed, byte length
 ; Old Top of Stack:  location - 10 = character to be printed, word length
 ;                    location -  8 = device to which character is to sent
 ;                    location -  6 = bios command to be executed
 ;                    location -  4 = program counter low word
 ;                    location -  2 = program counter high word
 ; SSP ->             location -  0 = invoking program's status register content

 ; In each case, above, the location listed is the location of the most
 ; significant byte of the data listed.  For example, relative location 10
 ; contains the most significant byte of the word which specifies the
 ; character to be printed.  Relative location 11 contains the least
 ; significant byte of that word.  Actually, relative location 11 is
 ; "the least significant byte" in computer vernacular, but, in fact, it
 ; is that byte which contains the character code.  The byte at relative
 ; location 10 contains only zeroes.

 ; The supervisor stack pointer (SSP) will be pointing to the new top of
 ; stack; the data there will be the content of the most significant byte
 ; of the status register, as it was when the exception occurred.  Now, as
 ; it turns out, this byte will be the one of significance, as far as the
 ; trap handler is concerned.
 
 ; If the processor was in the user state, then the data will be stacked,
 ; as indicated, at the following relative locations:

 ; Old Top of Stack:  location -  4 = character to be printed
 ;                    location -  2 = device to which character is to sent
 ; USP ->             location -  0 = bios command to be executed

 ; The user stack pointer (USP) will be pointing to the top of the stack;
 ; the data there will be the bios command to be executed.

 ; In order to process the stack data without regard to the processor state
 ; before invocation, if the processor was in user mode, then the offsets used
 ; to access the stack data with the USP as reference must be adjusted so that
 ; they match the offsets used to access the stack data with the SSP as
 ; reference.  Therefore, if the processor was in user mode when the trap #13
 ; call was made, the value six is subtracted from the register that is used
 ; to access the data.

 ; Then, common offset values, which will access the data correctly regardless
 ; of the stack pointer used as reference can be used.

 ; When we begin, we know that the processor is now is supervisor mode,
 ; however, we must determine its state at the time of the exception.  That
 ; processor state must be checked by testing bit 13 of the status register.
 ; We know that the SSP is now pointing to the content of the status register
 ; as it was at exception time.  In fact, it is pointing to the most significant
 ; byte of the status register word.

 ; There are two ways a bit can be tested with the 68000 BTST instruction.

 ; 1 - If the destination operand is a data register, then any of 32 bits
 ;     may be tested.

 ; 2 - If the destination operand is not a data register, then only 1 of
 ;     8 bits may be tested.

 ; In either case, the bit to be tested may be specified in a source data
 ; register or as immediate data.

 ; Since the bit we want to test is on the stack, we can only test a bit
 ; of a single memory byte.  The bit we must test (status register bit 13) is
 ; bit 5 of the byte that is being addressed by the SSP.

get_processor_status:
 movea.l   sp, a0               ; Fetch address of current top of stack.
 btst      #5, (sp)             ; Supervisor mode test.
 bne.s     supervisor_mode      ; No adjustment is necessary if the
                                ; processor was in supervisor mode.
 move.l    usp, a0              ; Fetch address of current top of user stack.
 subq.l    #6, a0               ; Adjust user data access address.

user_mode:
supervisor_mode:                ; Processing for either mode follows.
 cmpi.w    #3, 6(a0)            ; Writing a character to a device?
 bne       not_bconout_call
 cmpi.w    #2, 8(a0)            ; Is device the screen?
 bne.s     not_screen

 ; NOTE:

 ;      The information desired, at this point, is the ON/OFF status of the
 ; printer.  My printer, the star NX-10 provides this information on pin 13
 ; of its parallel interface.  Unfortunately, the ST does not permit the
 ; utilization of this data.  This is an example of hardware/hardware
 ; incompatibility.

 ;      Because of this ST deficiency, the printers BUSY/NOT BUSY signal,
 ; on pin 11 of the interface is forced into double duty.  In addition to its
 ; normal function, this signal is used by the ST to determine if the printer
 ; is ON or OFF.

 ;      We would like to be able to direct output to the printer, at will,
 ; simply by manually turning the printer ON or OFF.

 ;      The problem here is this: because the response of the printer interface
 ; is so much slower than the video screen interface, we can't use the bcostat
 ; function (BIOS #8) to determine the printer status (before attempting to
 ; write to the printer) in between outputs to the screen.  When we attempt to
 ; do that, we find that pin 11 indicates that the printer is busy (same as OFF
 ; signal) most of the time, even when the printer is turned on.  Thus, the
 ; printer receives only some of the data sent to the screen.
 
 ;      Therefore, the trap handler must just assume that the printer is on.
 ; This is no problem with some versions of the ST operating system.  If the
 ; printer is off, nothing will be sent to it.  But some versions of the 
 ; operating system will wait (forever, it seems) for someone to turn on the
 ; printer.  If this happens, then you must turn on the printer while this
 ; trap handler is resident.

esc_sequence_test:
 tst.b     esc_sequence_flag
 bne.s     reset_esc_sequence_flag
 cmpi.w    #$1B, 10(a0)           
 bne.s     not_esc_sequence
 move.b    #1, esc_sequence_flag
 bra.s     use_preempted_handler
reset_esc_sequence_flag:
 move.b    #0, esc_sequence_flag
use_preempted_handler:
 movea.l   preempted_handler_address(pc), a0
 jmp       (a0)                 ; JUMP TO PREEMPTED TRAP #13 HANDLER.
 
not_esc_sequence:
 move.b    #1, initialization_flag
 move.w    10(a0), character    ; Store character for printer.
write_character_to_screen:
 move.w    10(a0), -(sp)        ; Push character onto stack.
 move.w    #2, -(sp)            ; Device = screen.
 move.w    #3, -(sp)            ; Function = bconout = BIOS $3.
 trap      #13
 addq.l    #6, sp

ascii_code_test:                ; Filter out undesirable codes.
 move.w    character(pc), d0
 cmpi.w    #$1B, d0
 bgt.s     write_character_to_printer
 cmpi.w    #$A, d0
 beq.s     write_character_to_printer
 cmpi.w    #$D, d0
 bne.s     undesirable_ascii
write_character_to_printer:
 move.w    d0, -(sp)            ; Push character onto stack.
 move.w    #0, -(sp)            ; Device = printer.
 move.w    #3, -(sp)
 trap      #13
 addq.l    #6, sp
undesirable_ascii:
 move.b    #0, initialization_flag
 rte

not_screen:
not_bconout_call:
skip_initialization:
 movea.l   preempted_handler_address(pc), a0
 jmp       (a0)                 ; JUMP TO PREEMPTED TRAP #13 HANDLER.

 bss
character:                  ds.w    1
preempted_handler_address:  ds.l    1
esc_sequence_flag:          ds.b    1
initialization_flag:        ds.b    1
 align
                            ds.l   48    ; Stack
stack:                      ds.l    1    ; Address of stack.
program_end:                ds.l    0
 end
