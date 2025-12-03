;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP, VOLUME 2
; PROGRAM 2
;
; COPYRIGHT 1992 BY CLAYTON WALNUM
;---------------------------------------------------------------------

PTERM0          equ     0
CCONIN          equ     1
CCONWS          equ     9
APPL_INIT       equ     10
APPL_EXIT       equ     19
DGETDRV         equ     25
DGETPATH        equ     71
MSHRINK         equ     74
FSEL_INPUT      equ     90
AES_OPCODE      equ     200

;--------------------------------------------------------------------
; MACROS
;--------------------------------------------------------------------

;--------------------------------------------------------------------
; This macro gets a single character from the keyboard, using the
; Cconin GEMDOS function.
;--------------------------------------------------------------------
get_char macro
        move    #CCONIN,-(sp)
        trap    #1
        addq.l  #2,sp
        endm

;--------------------------------------------------------------------
; MAIN PROGRAM
;--------------------------------------------------------------------
        text

; Calculate the size of the program area.

        move.l  a7,a5                   ; Save addr of TPA.
        lea     stack,sp                ; Load addr of our stack.
        
        move.l  4(a5),a5                ; Get addr of TPA.              
        move.l  12(a5),d0               ; Get len of text segment.
        add.l   20(a5),d0               ; Add len of data segment.
        add.l   28(a5),d0               ; Add len of BSS segment.
        add.l   #$100,d0                ; Add len of TPA. 

; Release unused memory back to the system.
        
        move.l  d0,-(sp)                ; Push size of program on stack.
        move.l  a5,-(sp)                ; Push program addr on stack.
        clr     -(sp)                   ; Clear dummy word on stack.    
        move    #MSHRINK,-(sp)          ; Push Mshrink opcode.
        trap    #1                      ; Call GEMDOS.
        add.l   #12,sp                  ; Reset stack pointer.

; Clear some fields of the global array.

        clr.l   ap_ptree        
        clr.l   ap_1resv
        clr.l   ap_2resv
        clr.l   ap_3resv
        clr.l   ap_4resv

; Call appl_init to initialize application.

        move    #APPL_INIT,control0     ; Place opcode in control array.
        clr     control1                ; Load length of init_in. 
        move    #1,control2             ; Load length of int_out.
        clr     control3                ; Load length of addr_in.
        clr     control4                ; Load length of addr_out.
        jsr     aes                     ; Call the AES.
        cmpi    #$FFFF,ap_id            ; Error?
        beq     end                     ; Yep.  Outta here.

; Get current drive letter.

        move    #DGETDRV,-(sp)          ; Call Dgetdrv function.
        trap    #1
        addq.l  #2,sp
        add     #'A',d0                 ; Convert drive to ASCII.
        move.b  d0,pathname             ; Move drive letter to pathname.
        move.b  #':',pathname+1         ; Add colon to pathname.

; Get current path.

        move    #0,-(sp)                ; Call Dgetpath function.
        move.l  #pathname+2,-(sp)
        move    #DGETPATH,-(sp)
        trap    #1
        addq.l  #8,sp

; Add *.* to end of pathname.

        move    #127,d5                 ; Init loop counter.
        lea     pathname,a5             ; Get address of pathname.
loop1:
        tst.b   (a5)+                   ; Is character a null?
        beq     add_filespec            ; Yep. Found end of pathname.
        dbra    d5,loop1                ; Nope. Try next character.
add_filespec:
        subq.l  #1,a5                   ; Set addr to proper byte.
        move.b  #'\',(a5)+              ; Add \*.* to path.
        move.b  #'*',(a5)+
        move.b  #'.',(a5)+
        move.b  #'*',(a5)
        
; Bring up the file selector.

        move    #FSEL_INPUT,control0    ; Load fsel_input opcode.
        move    #0,control1             ; Load length of int_in.
        move    #2,control2             ; Load length of int_out.
        move    #2,control3             ; Load length of addr_in.
        move    #0,control4             ; Load length of addr_out.
        move.l  #pathname,addr_in       ; Load addr of path string.
        move.l  #filename,addr_in+4     ; Load addr of filename string.
        jsr     aes                     ; Call the AES.

        cmpi    #1,int_out+2            ; Chose OK button?
        bne     exit                    ; No, exit program.
        tst.b   filename                ; Do we have a filename?
        beq     exit                    ; No, exit program.

; Construct final pathname.

        move    #127,d5                 ; Init loop counter.
        lea     pathname,a5             ; Get addr of pathname.
loop2:
        tst.b   (a5)+                   ; Is character a null?
        beq     found_null              ; Yep.
        dbra    d5,loop2                ; Nope. Try next character.

found_null:
        move    #14,d5                  ; Init loop counter.
loop3:
        cmpi.b  #'\',-(a5)              ; Found backslash?
        beq     add_filename            ; Yes. Go tack on filename.
        dbra    d5,loop3                ; No. Try next character.

add_filename:
        addq.l  #1,a5                   ; Set addr to char after \.
        move    #14,d5                  ; Init loop counter.
        lea filename,a6                 ; Get addr of filename.
loop4:
        move.b  (a6),(a5)+              ; Add character to path.
        tst.b   (a6)+                   ; Test for null.
        beq     got_filename            ; If null, all done.
        dbra    d5,loop4                ; Copy next character.

; Show final pathname.

got_filename:
        move.l  #pathname,-(sp)         ; call Cconws to show...
        move    #CCONWS,-(sp)           ; the final pathname.
        trap    #1
        addq.l  #6,sp
        get_char                        ; Wait for keypress.
        
; Close down application.

exit:
        move    #APPL_EXIT,control0     ; Load appl_exit opcode.
        move    #0,control1             ; Load length of int_in.
        move    #1,control2             ; Load length of int_out.
        move    #0,control3             ; Load length of addr_in.
        move    #0,control4             ; Load length of addr_out.
        jsr     aes                     ; Call the AES.
        
end:
        move.w  #PTERM0,-(sp)           ; Back to desktop.
        trap    #1

;--------------------------------------------------------------------
; This subroutine calls the AES.  Before calling this subroutine, the
; program must have correctly initialized the AES control, int_in,
; and addr_in arrays.
;
; Input:        Appropriate values in the int_in, addr_in, and
;               control arrays.
; Output:       Appropriate values in the int_out, addr_out, and
;               global arrays.
; Regs changed: NONE
; Uses: apb, global, int_in, int_out, addr_in, addr_out
;--------------------------------------------------------------------
aes:
        movem.l a0-a7/d0-d7,-(sp)       ; Save registers.
        move.l  #apb,d1                 ; Load addr of apb.
        move.l  #AES_OPCODE,d0          ; Load AES opcode.
        trap    #2                      ; Call AES.
        movem.l (sp)+,a0-a7/d0-d7       ; Restore registers.
        rts

        data
        
apb:            dc.l    control,global,int_in,int_out,addr_in,addr_out

        bss

        even

global:
ap_version:     ds.w    1
ap_count:       ds.w    1
ap_id:          ds.w    1
ap_private:     ds.l    1
ap_ptree:       ds.l    1
ap_1resv:       ds.l    1
ap_2resv:       ds.l    1
ap_3resv:       ds.l    1
ap_4resv:       ds.l    1

control:
control0:       ds.w    1
control1:       ds.w    1
control2:       ds.w    1
control3:       ds.w    1
control4:       ds.w    1

int_in:         ds.w    1
int_out:        ds.w    2
addr_in:        ds.l    2
addr_out:       ds.l    1

pathname:       ds.b    128
filename:       ds.b    13

                ds.l    255
stack:          ds.l    1

