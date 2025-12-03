;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP, VOLUME 2
; PROGRAM 5
;
; COPYRIGHT 1992 BY CLAYTON WALNUM
;---------------------------------------------------------------------

CCONIN          equ     1
PTERM0          equ     0
MSHRINK         equ     74

V_CLRWK         equ     3
V_PLINE         equ     6
VSL_TYPE        equ     15
VSL_WIDTH       equ     16
VSL_COLOR       equ     17
V_OPNVWK        equ     100
V_CLSVWK        equ     101
VSL_ENDS        equ     108

AES_OPCODE      equ     200
VDI_OPCODE      equ     115

;--------------------------------------------------------------------
; MACROS
;--------------------------------------------------------------------

;--------------------------------------------------------------------
; This macro gets a single character from the keyboard, using the
; Cconin GEMDOS function.
;--------------------------------------------------------------------
.macro get_char
        move    #CCONIN,-(sp)
        trap    #1
        addq.l  #2,sp
        .endm
        
;--------------------------------------------------------------------
; MAIN PROGRAM
;--------------------------------------------------------------------
        .text

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

; Get handle to screen device.

        move.l  #graf_handle,apb
        jsr     aes
        move    int_out,gr_handle       ; Save screen device handle.

; Open virtual workstation.

        move    #V_OPNVWK,contrl        ; v_opnvwk opcode.
        clr     contrl+2                ; # of points in pts_in.
        move    #11,contrl+6            ; # of ints in int_in.
        move    gr_handle,contrl+12     ; Screen device handle. 
        movea.l #int_in,a5              ; Get address of int_in.
        move    #9,d5                   ; Init loop counter.
loop:
        move    #1,(a5)+                ; Place 1 in element of int_in.
        dbra    d5,loop                 ; Go init next element of int_in.
        move    #2,int_in+20            ; Set for raster coordinates.
        jsr     vdi
        move    contrl+12,vws_handle    ; Save virtual workstation handle.

; Clear workstation.

        move    #V_CLRWK,contrl         ; v_clrwk opcode.
        clr     contrl+2                ; # of points in pts_in.
        clr     contrl+6                ; # of ints in int_in.
        jsr     vdi

        move    #3,d5                   ; Init loop counter.
polyline:

; Set line color.

        move    #VSL_COLOR,contrl       ; vsl_color opcode.
        clr     contrl+2                ; # of points in pts_in.
        move    #1,contrl+6             ; # of ints in int_in.
        move    color,int_in            ; New line color.
        jsr     vdi
        addq    #1,color

; Set line ends.

        move    #VSL_ENDS,contrl        ; vsl_ends opcode.
        clr     contrl+2                ; # points in pts_in.
        move    #2,contrl+6             ; # ints in int_in.
        move    ends,int_in             ; End style for start of line.
        move    ends,int_in+2           ; End style for end of line.
        jsr     vdi
        addq    #1,ends

; Set line width.

        move    #VSL_WIDTH,contrl       ; vsl_width opcode.
        move    #1,contrl+2             ; # points in pts_in.
        clr     contrl+6                ; # of ints in int_in.
        move    width,pts_in            ; New line width.
        clr     pts_in+2
        jsr     vdi
        addq    #2,width                ; calculate next line width.

; Draw polyline.

        move    #V_PLINE,contrl         ; v_pline opcode.
        move    #2,contrl+2             ; # of points in pts_in.
        clr     contrl+6                ; # of ints in int_in.
        move    #30,pts_in              ; X coord of first point.
        move    y1,pts_in+2             ; Y coord of first point.
        move    #280,pts_in+4           ; X coord of second point.
        move    y2,pts_in+6             ; Y coord of second point.
        jsr     vdi
        add     #10,y1                  ; Calculate next Y coords.
        add     #10,y2
        dbra    d5,polyline             ; Go draw next line.

; Reset line widths.

        move    #VSL_WIDTH,contrl       ; vsl_width opcode.
        move    #1,contrl+2             ; # of points in pts_in.
        clr     contrl+6                ; # of ints in int_in.
        move    #1,pts_in               ; New line width.
        clr     pts_in+2
        jsr     vdi

; Reset line ends.

        move    #VSL_ENDS,contrl        ; vsl_ends opcode.
        clr     contrl+2                ; # of points in pts_in.
        move    #2,contrl+6             ; # of ints in int_in.
        move    #0,int_in               ; End style for start of line.
        move    #0,int_in+2             ; End style for end of line.
        jsr     vdi

        move    #5,d5                   ; Init loop counter.
polyline2:

; Set line type.

        move    #VSL_TYPE,contrl        ; vsl_type opcode.
        clr     contrl+2                ; # of points in pts_in.
        move    #1,contrl+6             ; # of ints in int_in.
        move    type,int_in             ; Line pattern type.
        jsr     vdi
        addq    #1,type                 ; Calculate next line type.

; Draw polyline.

        move    #V_PLINE,contrl         ; v_pline opcode.
        move    #2,contrl+2             ; # of points in pts_in.
        clr     contrl+6                ; # of ints in int_in.
        move    #30,pts_in              ; X coord of first point.
        move    y1,pts_in+2             ; Y coord of first point.
        move    #280,pts_in+4           ; X coord of second point.
        move    y2,pts_in+6             ; Y coord of second point.
        jsr     vdi
        add     #10,y1                  ; Calculate next Y coords.
        add     #10,y2
        dbra    d5,polyline2            ; Go draw another line.

        get_char        

; Close the virtual workstation.

        move    #V_CLSVWK,contrl        ; v_clsvwk opcode.
        clr     contrl+2                ; # of points in pts_in.
        clr     contrl+6                ; # of ints in int_in.
        jsr     vdi
                
; Close down application.

exit:
        move.l  #appl_exit,apb          ; appl_exit control array.
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
        move.w  #AES_OPCODE,d0          ; Load AES opcode.
        trap    #2                      ; Call AES.
        movem.l (sp)+,a0-a7/d0-d7       ; Restore registers.
        rts

;--------------------------------------------------------------------
; This subroutine calls the VDI. Before calling this subroutine, the
; program must have correctly initialized the VDI contrl, intin,
; and ptsin arrays.
;
; Input:        Appropriate values in the intin, ptsin, and
;               contrl arrays.
; Output:       Appropriate values in the intout and ptsout arrays.
; Regs changed: NONE
; Uses: vpb, intin, intout, ptsin, ptsout
;--------------------------------------------------------------------
vdi:
        movem.l a0-a7/d0-d7,-(sp)       ; Save registers.
        move.l  #vpb,d1                 ; Load addr of vpb.
        move.w  #VDI_OPCODE,d0          ; Load VDI opcode.
        trap    #2                      ; Call VDI.
        movem.l (sp)+,a0-a7/d0-d7       ; Restore registers.
        rts

        data
        
        even

y1:             dc.w    20
y2:             dc.w    20
color:          dc.w    1
type:           dc.w    1
width:          dc.w    1
ends:           dc.w    0

apb:            dc.l    0,global,int_in,int_out,addr_in,addr_out
vpb:            dc.l    contrl,int_in,pts_in,int_out,pts_out

appl_init:      dc.w    10,0,1,0,0
appl_exit:      dc.w    19,0,1,0,0
graf_handle:    dc.w    77,0,5,0,0

        .bss

        .even

gr_handle:      ds.w    1
vws_handle:     ds.w    1
        
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

contrl:         ds.w    12
int_in:         ds.w    128
int_out:        ds.w    128
addr_in:        ds.l    64
addr_out:       ds.l    64
pts_in:         ds.w    128
pts_out:        ds.w    128

                ds.l    255
stack:          ds.l    1

