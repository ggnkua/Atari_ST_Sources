;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP, VOLUME 2
; PROGRAM 1
;
; COPYRIGHT 1992 BY CLAYTON WALNUM
;---------------------------------------------------------------------

PTERM0          equ     0
APPL_INIT       equ     10
APPL_EXIT       equ     19
FORM_ALERT      equ     52
MSHRINK         equ     74
AES_OPCODE      equ     200

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
        clr.w   -(sp)                   ; Clear dummy word on stack.    
        move.w  #MSHRINK,-(sp)          ; Push Mshrink opcode.
        trap    #1                      ; Call GEMDOS.
        add.l   #12,sp                  ; Reset stack pointer.

; Clear some fields of the global array.

        clr.l   ap_ptree        
        clr.l   ap_1resv
        clr.l   ap_2resv
        clr.l   ap_3resv
        clr.l   ap_4resv

; Call appl_init to initialize application.

        move.w  #APPL_INIT,control0     ; Place opcode in control array.
        clr.w   control1                ; Load length of init_in. 
        move.w  #1,control2             ; Load length of int_out.
        clr.w   control3                ; Load length of addr_in.
        clr.w   control4                ; Load length of addr_out.
        jsr     aes                     ; Call the AES.
        cmpi    #$FFFF,ap_id            ; Error?
        beq     end                     ; Yep.  Outta here.

; Bring up the alert box.

        move.w  #FORM_ALERT,control0    ; Load form_alert opcode.
        move.w  #1,control1             ; Load length of int_in.
        move.w  #1,control2             ; Load length of int_out.
        move.w  #1,control3             ; Load length of addr_in.
        move.w  #0,control4             ; Load length of addr_out.
        move.w  #1,int_in               ; Default exit button.
        move.l  #string,addr_in         ; Addr of alert string.
        jsr     aes                     ; Call the AES.

; Close down application.

        move.w  #APPL_EXIT,control0     ; Load appl_exit opcode.
        move.w  #0,control1             ; Load length of int_in.
        move.w  #1,control2             ; Load length of int_out.
        move.w  #0,control3             ; Load length of addr_in.
        move.w  #0,control4             ; Load length of addr_out.
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
        
string:         dc.b    "[1][My first alert box!][Cool!]",0
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
int_out:        ds.w    1
addr_in:        ds.l    1
addr_out:       ds.l    1

                ds.l    255
stack:          ds.l    1

