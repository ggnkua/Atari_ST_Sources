 ; PROGRAM NAME: PRG_6KC.S
 ;      VERSION: 1.001

 ; The function of this program is identical to that of PRG_6JC.S.  I am
 ; including it because, in PRG_6JC's trap handler, I used an algorithm to
 ; access stack data which you are most likely to see in references.  In this
 ; program I show you another method, the method that I prefer. 

program_start:                  ; Compute program size and retain result.
 lea        program_end(pc), a3 ; Fetch program end address.
 movea.l    4(a7), a4           ; Fetch basepage address.
 suba.l     a4, a3              ; Yields size of memory that must remain
                                ; resident.
load_stack_address:
 lea        stack(pc), a7

install_new_trap_13_vector:
 pea       custom_trap_handler(pc)
 move.w    #$2D, -(sp)          ; Trap 13 vector number.
 move.w    #5, -(sp)            ; Function = setexec = BIOS $5.
 trap      #13                  ; Current trap handler vector returned in D0.
 addq.l    #8, sp
 move.l    d0, preempted_handler_address

relinquish_processor_control:   ; Maintain memory residency.
 move.w    #0, -(sp)            ; See page 121 of Internals book.
 move.l    a3, -(sp)            ; Size of memory to remain resident.
 move.w    #$31, -(sp)          ; Function = ptermres = GEMDOS $31.
 trap      #1

 ; Here I illustrate another way to adjust one of the stack reference pointers
 ; so that common offset values may be used to access stack data.  In this
 ; program the value six is added to the register that is used to access the
 ; data if the processor was in supervisor mode before the invocation.

custom_trap_handler:
 tst.b     initialization_flag
 bne       skip_initialization
 move.l    usp, a0              ; Load address of current top of user stack.

get_processor_status:
 btst      #5, (sp)             ; User mode test.
 beq.s     was_user_mode        ; No adjustment is necessary if the
                                ; processor was in user mode.
 movea.l   sp, a0               ; Load current top of supervisor stack.
 addq.l    #6, a0               ; Adjust SSP for user mode type data access.

was_supervisor_mode:
was_user_mode:                  ; Processing for either mode follows.
 cmpi.w    #3, (a0)             ; Writing a character to a device?
 bne.s     not_bconout_call
 cmpi.w    #2, 2(a0)            ; Is device the screen?
 bne.s     not_screen

esc_sequence_test:
 tst.b     esc_sequence_flag
 bne.s     reset_esc_sequence_flag
 cmpi.w    #$1B, 4(a0)           
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
 move.w    4(a0), character     ; Store character for printer.
write_character_to_screen:
 move.w    4(a0), -(sp)         ; Push character onto stack.
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
 jmp       (a0)                 ; JUMP TO PREEMPTED TRAP #13 HANDLER

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
