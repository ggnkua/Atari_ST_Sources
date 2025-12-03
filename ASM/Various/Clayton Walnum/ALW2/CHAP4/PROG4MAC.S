;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP, VOLUME 2
; PROGRAM 4
;
; COPYRIGHT 1992 BY CLAYTON WALNUM
;---------------------------------------------------------------------

.include "SAMPLE.H"

FINGER          equ     3

PTERM0          equ     0
MSHRINK         equ     74
AES_OPCODE      equ     200

FMD_START       equ     0
FMD_GROW        equ     1
FMD_SHRINK      equ     2
FMD_FINISH      equ     3

;--------------------------------------------------------------------
; MACROS
;--------------------------------------------------------------------

;--------------------------------------------------------------------
; This macro gets the address of an object's string. It requires two 
; parameters: the address of the resource tree and the object's
; number. The string address is returned in a5.
;-------------------------------------------------------------------- 
.macro tedinfo_str
        move.l  \1,a5                   ; Get address of dialog.
        add.l   #(\2*24)+12,a5          ; Calc. addr of ob_spec.
        move.l  (a5),a5                 ; Get address of tedinfo.
.endm

;--------------------------------------------------------------------
; This macro calls up a simple, one-button GEM alert box, using the
; form_alert AES function. It requires two parameters: the default
; button number and the address of the alert-box string. Because this
; alert box will have only one button, the value for the default
; button must be 0 for no default or 1 for button 1.
;-------------------------------------------------------------------- 
.macro alert
        move.l  #form_alert,apb
        move    #\1,int_in
        move.l  #\2,addr_in
        bsr     aes
.endm

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

        move.l  #appl_init,apb
        bsr     aes
        cmpi    #$FFFF,ap_id            ; Error?
        beq     end                     ; Yep.  Outta here.

; Load resource file.

        move.l  #rsrc_load,apb
        move.l  #rsrc_file,addr_in      ; Addr of resource file name.
        bsr     aes
        tst     int_out                 ; Did the resource load okay?
        bne     rsrc_okay               ; Yep.
        alert   1,alert1                ; "Resource load error!"
        bra     exit

; Get resource address.
        
rsrc_okay:
        move.l  #rsrc_gaddr,apb
        move    #R_TREE,int_in          ; Type number of data.
        move    #SAMPLE,int_in+2        ; Array index of data.
        bsr     aes
        tst     int_out                 ; Was there an error?
        bne     addr_okay               ; Nope.
        alert   1,alert2                ; "Resource address error!"
        bra     exit

addr_okay:
        move.l  addr_out,dialog_addr    ; Save dialog's address.

; Center dialog for screen.

        move.l  #form_center,apb        ; form_center control array.
        move.l  dialog_addr,addr_in     ; Dialog's address.
        bsr     aes     
        move    int_out+2,dial_x        ; Save dialog's X coordinate.
        move    int_out+4,dial_y        ; Save dialog's Y coordinate.
        move    int_out+6,dial_w        ; Save dialog's width.
        move    int_out+8,dial_h        ; Save dialog's height.

; Get coordinates of the NUMBERS object.

        move.l  #objc_offset,apb        ; objc_offset control array.
        move    #NUMBERS,int_in         ; Object to find.
        move.l  dialog_addr,addr_in     ; Dialog's address.
        bsr     aes     
        move    int_out+2,num_x         ; Save object's X coordinate.
        move    int_out+4,num_y         ; Save object's Y coordinate.

; Replace old dialog string with new dialog string.

        tedinfo_str dialog_addr,NUMBERS ; Get pointer to dialog string.
        move.l  #number_str,(a5)        ; Point tedinfo to new string.

; Reserve screen space for dialog box.

        move.l  #form_dial,apb          ; form_dial control array.
        move    #FMD_START,int_in       ; Operation type.
        move    #0,int_in+2             ; Small rectangle X.
        move    #0,int_in+4             ; Small rectangle Y.
        move    #10,int_in+6            ; Small rectangle width.
        move    #10,int_in+8            ; Small rectangle height.
        move    dial_x,int_in+10        ; Dialog's X.
        move    dial_y,int_in+12        ; Dialog's Y.
        move    dial_w,int_in+14        ; Dialog's width.
        move    dial_h,int_in+16        ; Dialog's height.
        bsr     aes

; Animate expanding rectangle.

        move    #FMD_GROW,int_in        ; Operation type.
        bsr     aes

; Draw dialog box on screen.
        
        move.l  #objc_draw,apb          ; objc_draw control array.
        move    #0,int_in               ; First object to draw.
        move    #2,int_in+2             ; Depth of draw.
        move    dial_x,int_in+4         ; Clipping rectangle X.
        move    dial_y,int_in+6         ; Clipping rectangle Y.
        move    dial_w,int_in+8         ; Clipping rectangle width.
        move    dial_h,int_in+10        ; Clipping rectangle height.
        move.l  dialog_addr,addr_in     ; Dialog's address.
        bsr     aes

; Change mouse to finger pointer.
        
        move.l  #graf_mouse,apb         ; graf_mouse control array.
        move    #FINGER,int_in          ; Pointer type.
        clr.l   addr_in                 ; Dummy mouse address.
        bsr     aes

; Activate dialog to accept user input.

do_dialog:      
        move.l  #form_do,apb            ; form_do control array.
        move    #NAME,int_in            ; First edit field.
        move.l  dialog_addr,addr_in     ; Dialog's address.
        bsr     aes

; Determine which exit button clicked.

        cmpi    #RADIO1,int_out         ; Was RADIO1 clicked?
        bne     chk_but1                ; Nope.
        move.b  #'1',alert3+9           ; Yes. Prepare alert string.
        alert   1,alert3                ; Show alert.
chk_but1:
        cmpi    #RADIO2,int_out         ; Was RADIO2 clicked?
        bne     chk_but2                ; No.
        move.b  #'2',alert3+9           ; Yes. Prepare alert string.
        alert   1,alert3                ; Show alert.
chk_but2:
        cmpi    #RADIO3,int_out         ; Was RADIO3 clicked?
        bne     chk_but3                ; Nope.
        move.b  #'3',alert3+9           ; Yep. Prepare alert string.
        alert   1,alert3                ; Show alert.
chk_but3:
        cmpi    #RADIO4,int_out         ; Was RADIO4 clicked?
        bne     chk_but4                ; No.
        move.b  #'4',alert3+9           ; Yes, Prepare alert string.
        alert   1,alert3                ; Show alert.
chk_but4:
        cmpi    #RADIO5,int_out         ; Was RADIO5 clicked?
        bne     chk_but5                ; No.
        move.b  #'5',alert3+9           ; Yes, Prepare alert string.
        alert   1,alert3                ; Show alert.
chk_but5:
        cmpi    #RADIO6,int_out         ; Was RADIO6 clicked?
        bne     chk_but6                ; Nope.
        move.b  #'6',alert3+9           ; Yes. Prepare alert string.
        alert   1,alert3                ; Show alert.
chk_but6:
        cmpi    #OPTION1,int_out        ; Was OPTION1 clicked?
        bne     chk_but7                ; No.
        move.b  #'1',alert4+10          ; Yes. Prepare alert string.
        alert   1,alert4                ; Show alert.
chk_but7:
        cmpi    #OPTION2,int_out        ; Was OPTION2 clicked?
        bne     chk_but8                ; No.
        move.b  #'2',alert4+10          ; Yes. Prepare alert string.
        alert   1,alert4                ; Show alert.
chk_but8:
        cmpi    #UPARROW,int_out        ; Was UPARROW clicked?
        bne     chk_but9                ; No.
        cmpi    #9999,num               ; Yes. Check if num maxed.
        beq     num_at_max              ; Num at max value. Skip add.
        addi    #1,num                  ; Increment num.
num_at_max:
        bsr     change_number           ; Change number in dialog.
chk_but9:
        cmpi    #DWNARROW,int_out       ; Was DWNARROW clicked?
        bne     chk_but10               ; No.
        tst     num                     ; Yes. Is num already 0?
        beq     num_at_min              ; If 0, skip decrement.
        subi    #1,num                  ; Decrement num.
num_at_min:
        bsr     change_number           ; Change number in dialog.
chk_but10:
        cmpi    #CANCEL,int_out         ; Was CANCEL clicked?
        bne     chk_but11               ; No.
        bra     dialog_done             ; Yes. Close dialog.
chk_but11:
        cmpi    #OK,int_out             ; Was OK clicked?
        bne     do_dialog               ; No. Reactivate dialog.

dialog_done:
        move.l  #form_dial,apb          ; form_dial control array.
        move    #FMD_SHRINK,int_in      ; Operation code.
        move    #0,int_in+2             ; Small rectangle X.
        move    #0,int_in+4             ; Small rectangle Y.
        move    #10,int_in+6            ; Small rectangle width.
        move    #10,int_in+8            ; Small rectangle height.
        move    dial_x,int_in+10        ; Dialog's X.
        move    dial_y,int_in+12        ; Dialog's Y.
        move    dial_w,int_in+14        ; Dialog's width.
        move    dial_h,int_in+16        ; Dialog's height.
        bsr     aes
        
        move    #FMD_FINISH,int_in      ; Operation Code.
        bsr     aes
quit:
        
; Release resource space.

        move.l  #rsrc_free,apb          ; rsrc_free control array.
        bsr     aes
        
; Close down application.

exit:
        move.l  #appl_exit,apb          ; appl_exit control array.
        bsr     aes
        
end:
        move.w  #PTERM0,-(sp)           ; Back to desktop.
        trap    #1

;--------------------------------------------------------------------
; This subroutine changes the NUMBER object in the dialog box to a 
; new value.
;--------------------------------------------------------------------
change_number:

; Restore dialog number string to '0000'.

        lea     number_str+4,a3         ; Get addr of 1st number character.
        move.l  #3,d3                   ; Init loop counter.
place_zero:
        move.b  #'0',(a3)+              ; Put '0' in string.
        dbra    d3,place_zero           ; Go place next '0'.

; Convert new value for dialog to ASCII string.
        
        move    num,d0                  ; Get new value into work reg.
        lea     strg,a3                 ; Get addr of string buffer.
        bsr     int2ascii16             ; Convert value to ASCII string.

; Count number of chars in new number string.

        clr     d3                      ; Init counter.
.check_char:
        tst.b   (a3)+                   ; Check for end of string.
        beq     .found_null             ; if found null, branch.
        addq    #1,d3                   ; Increment counter.
        bra     .check_char             ; Go check next char.
        
.found_null:

; Move new number string into new dialog string.

        subi    #1,d3                   ; Init loop counter.
        sub.l   #1,a3                   ; Init string address.
        lea     number_str,a4           ; Get addr of new dialog string.
        move    #3,d4                   ; Init addr index.
.move_char:
        move.b  -(a3),4(a4,d4)          ; Move character into dialog string.
        subi    #1,d4                   ; Decrement addr index.
        dbra    d3,.move_char           ; Go move next character.

; Draw NUMBERS object so new string is displayed.
        
        move.l  #objc_draw,apb          ; objc_draw control array.
        move    #NUMBERS,int_in         ; First object to draw.
        move    #1,int_in+2             ; Depth of draw.
        move    num_x,int_in+4          ; Clipping rectangle X.
        move    num_y,int_in+6          ; Clipping rectangle Y.
        move    #96,int_in+8            ; Clipping rectangle width.
        move    #32,int_in+10           ; Clipping rectangle height.
        move.l  dialog_addr,addr_in     ; Address of dialog.
        bsr     aes
        rts
end_change_number:

;--------------------------------------------------------------------
; This subroutine converts a 16-bit unsigned integer into a 
; null-terminated string.
;
; Input: Address of buffer in a3.
;        Integer to convert in d0.
; Output: The buffer will contain the resultant null-terminated string.
; Registers changed: NONE.
;--------------------------------------------------------------------
int2ascii16:
        movem.l a0-a7/d0-d7,-(sp)       ; save registers.
        clr.l   d3                      ; init leading-zero flag.
        move.l  #10000,d1               ; init divisor.
.convrt:
        divu    d1,d0                   ; calculate place value.
        cmpi.l  #1,d1                   ; are we at the one's place?
        beq     .zero_ok                ; if so, "0" always ok.
        tst.w   d3                      ; already have a non-zero char?
        bne     .zero_ok                ; yes, so zeroes okay.
        tst.w   d0                      ; is result zero?
        beq     .next_digit             ; yes.
        moveq   #1,d3                   ; set leading-zero flag.
.zero_ok:
        move.b  d0,(a3)                 ; move result to buffer.
        add.b   #'0',(a3)+              ; change digit to ascii.
.next_digit:
        divu    #10,d1                  ; calculate next divisor.
        tst.w   d1                      ; are we done yet?
        beq     .add_null               ; sure are.
        move.w  #0,d0                   ; clear result from low word.
        swap    d0                      ; put remainder in low word.
        bra     .convrt                 ; convert next digit.
.add_null:
        move.b  #0,(a3)+                ; add null to string.
        movem.l (sp)+,a0-a7/d0-d7       ; restore registers.
        rts
end_int2ascii16:

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

.data
        
.even

num:            dc.w    0
        
apb:            dc.l    0,global,int_in,int_out,addr_in,addr_out

appl_init:      dc.w    10,0,1,0,0
appl_exit:      dc.w    19,0,1,0,0
form_alert:     dc.w    52,1,1,1,0
form_center:    dc.w    54,0,5,1,0
form_dial:      dc.w    51,9,1,0,0
form_do:        dc.w    50,1,1,1,0
graf_mouse:     dc.w    78,1,1,1,0
objc_draw:      dc.w    42,6,1,1,0
objc_offset:    dc.w    44,1,3,1,0
rsrc_free:      dc.w    111,0,1,0,0
rsrc_gaddr:     dc.w    112,2,1,0,1
rsrc_load:      dc.w    110,0,1,1,0

rsrc_file:      dc.b    "SAMPLE.RSC",0
number_str:     dc.b    "    0000    ",0
alert1:         dc.b    "[0][Resource load error!  ][  OK  ]",0
alert2:         dc.b    "[0][Resource address error!][  OK  ]",0
alert3:         dc.b    "[0][RADIO ][  OK  ]",0
alert4:         dc.b    "[0][OPTION   ][  OK  ]",0
alert5:         dc.b    "[0][UP ARROW  ][  OK  ]",0
alert6:         dc.b    "[0][DOWN ARROW  ][  OK  ]",0

                bss

                even

dialog_addr:    ds.l    1
num_x:          ds.w    1
num_y:          ds.w    1
dial_x:         ds.w    1
dial_y:         ds.w    1
dial_w:         ds.w    1
dial_h:         ds.w    1
strg:           ds.w    10
        
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

int_in:         ds.w    9
int_out:        ds.w    5
addr_in:        ds.l    2
addr_out:       ds.l    1

                ds.l    255
stack:          ds.l    1

