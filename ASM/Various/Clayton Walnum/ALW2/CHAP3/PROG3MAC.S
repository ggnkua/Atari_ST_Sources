;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP, VOLUME 2
; PROGRAM 3
;
; COPYRIGHT 1992 BY CLAYTON WALNUM
;---------------------------------------------------------------------

.include "MENU.H"

R_TREE          equ     0
ARROW           equ     0
NORMAL          equ     1
MN_SELECTED     equ     10
NUM_MENUS       equ     11

PTERM0          equ     0
APPL_INIT       equ     10
APPL_EXIT       equ     19
EVNT_MESAG      equ     23
MENU_BAR        equ     30
MENU_ICHECK     equ     31
MENU_IENABLE    equ     32
MENU_TNORMAL    equ     33
MENU_TEXT       equ     34
FORM_ALERT      equ     52
MSHRINK         equ     74
GRAF_MOUSE      equ     78
RSRC_LOAD       equ     110
RSRC_FREE       equ     111
RSRC_GADDR      equ     112
AES_OPCODE      equ     200

;--------------------------------------------------------------------
; MACROS
;--------------------------------------------------------------------

;--------------------------------------------------------------------
; This macro calls up a simple, one-button GEM alert box, using the
; form_alert AES function. It requires two parameters: the default
; button number and the address of the alert-box string. Because this
; alert box will have only one button, the value for the default
; button must be 0 for no default or 1 for button 1.
;-------------------------------------------------------------------- 
.macro alert
        move    #FORM_ALERT,control0
        move    #1,control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move    #\1,int_in0
        move.l  #\2,addr_in0
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

        move    #APPL_INIT,control0     ; Place opcode in control array.
        clr     control1                ; Load length of init_in. 
        move    #1,control2             ; Load length of int_out.
        clr     control3                ; Load length of addr_in.
        clr     control4                ; Load length of addr_out.
        bsr     aes                     ; Call the AES.
        cmpi    #$FFFF,ap_id            ; Error?
        beq     end                     ; Yep.  Outta here.

; Change mouse pointer back to arrow.

        move    #GRAF_MOUSE,control0
        move    #1,control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move    #ARROW,int_in0          ; Mouse form number.
        clr.l   addr_in0                ; Use 0 for address of form.
        bsr     aes     

; Load resource file.

        move    #RSRC_LOAD,control0
        clr     control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move.l  #rsrc_file,addr_in0     ; Addr of resource file name.
        bsr     aes
        tst     int_out0                ; Did the resource load okay?
        bne     rsrc_okay               ; Yep.
        alert   1,alert5                ; "Resource load error!"
        bra     exit

; Get resource address.
        
rsrc_okay:
        move    #RSRC_GADDR,control0
        move    #2,control1
        move    #1,control2
        clr     control3
        move    #1,control4
        move    #R_TREE,int_in0         ; Type number of data.
        move    #TREE00,int_in1         ; Array index of data.
        bsr     aes
        tst     int_out0                ; Was there an error?
        bne     addr_okay               ; Nope.
        alert   1,alert6                ; "Resource address error!"
        bra     exit

; Show menu bar.

addr_okay:
        move.l  addr_out,menu_adr       ; Save addr of menu resource.
        move    #MENU_BAR,control0
        move    #1,control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move    #1,int_in0              ; Set flag to show menu.
        move.l  menu_adr,addr_in0       ; Address of menu resource.
        bsr     aes

; Event loop.

event_loop:
        move    #EVNT_MESAG,control0
        clr     control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move.l  #msgbuf,addr_in0        ; Address of message buffer.
        bsr     aes

; Decipher message.

        cmpi    #MN_SELECTED,msgbuf0
        bne     event_loop
        move    #NUM_MENUS-1,d5         ; Init loop counter.
        move    d5,d6                   ; Init the...
        add     d6,d6                   ; index register.
        lea     menu_ids,a5             ; Get addr of ID table.
        move    msgbuf4,d4              ; Get menu ID.
find_id:
        cmp     0(a5,d6),d4             ; Is this the ID?
        beq     found_id                ; Yep.
        subi    #2,d6                   ; No, so calculate new index...
        dbra    d5,find_id              ; and loop back for another try.
        bra     event_loop              ; ID not in table. Whoops!

found_id:
        lea     menu_vecs,a5            ; Get addr of vector table.
        add     d6,d6                   ; Calculate index.
        move.l  0(a5,d6),a6             ; Get vector.
        jmp     (a6)                    ; Jump to proper routine.

; Respond to menu item chosen.
        
info:
        alert   1,alert1
        bsr     menu_normal
        bra     event_loop

load:
        alert   1,alert2
        bsr     menu_normal
        bra     event_loop

save:
        alert   1,alert3
        bsr     menu_normal
        bra     event_loop

option1:
        tst     optn1                   ; Is Option1 checked?
        beq     setcheck1               ; No. Go add checkmark.
        clr     optn1                   ; Yes. Clear checkmark.
        clr     check_flag
        bra     check
setcheck1:
        move    #1,optn1                ; Set option1 checkmark.
        move    #1,check_flag
        bra     check

option2:
        tst     optn2                   ; Is option2 checked?
        beq     setcheck2               ; No. Go add checkmark.
        clr     optn2                   ; Yes. Clear checkmark.
        clr     check_flag
        bra     check
setcheck2:
        move    #1,optn2                ; Set option2 checkmark
        move    #1,check_flag
        bra     check
        
option3:
        tst     optn3                   ; Is option3 checked?
        beq     setcheck3               ; No. Go add checkmark.
        clr     optn3                   ; Yes. Clear checkmark.
        clr     check_flag
        bra     check
setcheck3:
        move    #1,optn3                ; Set option3 checkmark.
        move    #1,check_flag

check:
        move    #MENU_ICHECK,control0
        move    #2,control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move    msgbuf4,int_in0         ; Menu item number.
        move    check_flag,int_in1      ; Checkmark flag.
        move.l  menu_adr,addr_in0       ; Address of resource tree.
        bsr     aes
        bsr     menu_normal
        bra     event_loop

onoff:
        tst     on                      ; Are selections on?
        beq     turn_on                 ; No, so turn them on.
        lea     on_str,a5               ; Yes. Get address of "On."
        clr     on                      ; Clear flag.
        bra     enable0
turn_on:
        lea     off_str,a5              ; Get address of "Off."
        move    #1,on                   ; Set flag.

enable0:
        move    #2,d5                   ; Init loop counter.
        move    #SELECT1,d6             ; Get menu item number.
enable1:
        move    #MENU_IENABLE,control0
        move    #2,control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move    d6,int_in0              ; Menu item number.
        move    on,int_in1              ; On/Off flag.
        move.l  menu_adr,addr_in0       ; Address of resource tree.
        bsr     aes
        addi    #1,d6                   ; Next menu item number.
        dbra    d5,enable1

; Change text in menu.

        move    #MENU_TEXT,control0
        move    #1,control1
        move    #1,control2
        move    #2,control3
        clr     control4
        move    #ONOFF,int_in0          ; Menu item number.
        move.l  menu_adr,addr_in0       ; Address of resource tree.
        move.l  a5,addr_in1             ; Address of new menu string.
        bsr     aes
        bsr     menu_normal
        bra     event_loop

select1:
        move.b  #'1',alert4+30          ; Add '1' to alert string.
        alert   1,alert4
        bsr     menu_normal
        bra     event_loop

select2:
        move.b  #'2',alert4+30          ; Add '2' to alert string.
        alert   1,alert4
        bsr     menu_normal
        bra     event_loop

select3:
        move.b  #'3',alert4+30          ; Add '3' to alert string.
        alert   1,alert4
        bsr     menu_normal
        bra     event_loop

; Remove menu bar.

quit:
        move    #MENU_BAR,control0
        move    #1,control1
        move    #1,control2
        move    #1,control3
        clr     control4
        clr     int_in0                 ; Menu display flag.
        move.l  menu_adr,addr_in0       ; Address of resource tree.
        bsr     aes
        
; Release resource space.

        move    #RSRC_FREE,control0
        clr     control1
        move    #1,control2
        clr     control3
        clr     control4
        bsr     aes
        
; Close down application.

exit:
        move    #APPL_EXIT,control0
        move    #0,control1
        move    #1,control2
        move    #0,control3
        move    #0,control4
        bsr     aes
        
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

;--------------------------------------------------------------------
; This subroutine unhighlights a menu title.
;
; Input:        Menu object # in msgbuf3.
;               Address of resource tree in menu_adr.
; Output:       Appropriate values in the int_out and global arrays.
; Regs changed: NONE
; Uses:         control, int_in, int_out, addr_in, msgbuf3, menu_adr
; Calls:        aes
;--------------------------------------------------------------------
menu_normal:
        move    #MENU_TNORMAL,control0
        move    #2,control1
        move    #1,control2
        move    #1,control3
        clr     control4
        move    msgbuf3,int_in0         ; Object number of menu title.
        move    #NORMAL,int_in1         ; Highlight flag.
        move.l  menu_adr,addr_in0       ; Address of resource tree.
        bsr     aes
        rts
        
        data
        
        even
optn1:          dc.w    1
optn2:          dc.w    0
optn3:          dc.w    0
on:             dc.w    1

menu_ids:       dc.w    INFO,LOAD,SAVE,QUIT,OPTION1,OPTION2
                dc.w    OPTION3,ONOFF,SELECT1,SELECT2,SELECT3
menu_vecs:      dc.l    info,load,save,quit,option1,option2
                dc.l    option3,onoff,select1,select2,select3
        
apb:            dc.l    control,global,int_in,int_out,addr_in,addr_out

rsrc_file:      dc.b    "MENU.RSC",0
alert1:         dc.b    "[0][Assembly Language Workshop  |"
                dc.b    "      Demo program.| |     Copyright 1992|"
                dc.b    "    by Clayton Walnum][  OK  ]",0
alert2:         dc.b    "[0][You clicked on  |    LOAD][  OK  ]",0
alert3:         dc.b    "[0][You clicked on  |    SAVE][  OK  ]",0
alert4:         dc.b    "[0][You clicked on  |   Select ][  OK  ]",0
alert5:         dc.b    "[0][Resource load error!  ][  OK  ]",0
alert6:         dc.b    "[0][Resource address error!][  OK  ]",0
off_str:        dc.b    "    Off",0
on_str:         dc.b    "    On",0

        bss

        even
        
menu_adr:       ds.l    1
check_flag:     ds.w    1

msgbuf:
msgbuf0:        ds.w    1
msgbuf1:        ds.w    1
msgbuf2:        ds.w    1
msgbuf3:        ds.w    1
msgbuf4:        ds.w    1
msgbuf5:        ds.w    1
msgbuf6:        ds.w    1
msgbuf7:        ds.w    1

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

int_in:
int_in0:        ds.w    1
int_in1:        ds.w    1
int_out:
int_out0:       ds.w    1
int_out1:       ds.w    1
addr_in:
addr_in0:       ds.l    1
addr_in1:       ds.l    1
addr_out:       ds.l    1

                ds.l    255
stack:          ds.l    1

