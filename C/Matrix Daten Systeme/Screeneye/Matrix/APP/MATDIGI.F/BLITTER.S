; For further information contact:
; Barry Comer
; 2 Cleveland Crescent
; Dartmouth, Nova Scotia
; Canada
; B3A-2L6
; 1-(902)-466-5345
; CIS 71521,607
;
; This program was written in such a way that it makes no special calls
; to any assembler library, it should be quite portable.
; I used the MOON.S listing as a guide for the line-a parameter block.
; This demo will allow people to see what a difference the blitter
; can make when writting games. If you run the demo with the blitter
; off it looks like shit. But with the blitter on the saucers are
; flicker free. I stopped at 13 saucers, you can add more if you so
; wish to. Also please note that this demo is done without the use
; of page flipping(the blitter truly is fast).

                data           ; data section

; trap vectors
gemdos          equ    1       ; gemdos trap number
bios            equ    13      ; bios trap number
xbios           equ    14      ; xbios trap number

; bios functions
bconstat        equ    $01     ; bconstat call

; xbios functions
initmouse       equ    $00     ; init mouse call
physbase        equ    $02     ; screen location call
getrez          equ    $04     ; get rez. call
setscreen       equ    $05     ; set screen call
setpalette      equ    $06     ; set palette call
setcolour       equ    $07     ; set colour call
kbdvbase        equ    $22     ; keyboard vector call
vsync           equ    $25     ; vert. sync call

; gemdos functions
pterm           equ    $00     ; pterm call

; line-a functions
init            equ    $a000   ; location of line-a stuff
bitblt          equ    $a007   ; blit command
show_mouse      equ    $a009   ; show mouse command
hide_mouse      equ    $a00a   ; hide mouse command

; line-a offsets               ; normal line-a variables
fg_bp1          equ    24      ; bit plane colour values
fg_bp2          equ    26
fg_bp3          equ    28
fg_bp4          equ    30
lstlin          equ    32
ln_mask         equ    34      ; mask for line style
wrt_mod         equ    36      ; writing mode
x1              equ    38      ; x and y values for various calls
y1              equ    40
x2              equ    42
y2              equ    44

; bitblit parameter block
bltparm:
b_wd:           dc.w   29      ; width of saucer is 29 pixels
b_ht:           dc.w   11      ; height of saucer is 11 pixels
plane_ct:       ds.w   1       ; number of bit planes
fg_col:         ds.w   1       ; Foreground color - (not used)
bk_col:         ds.w   1       ; Background color - (not used)
op_tab:         ds.l   1       ; logic operations for BLT
s_xmin:         dc.w   0       ; source x coordinate
s_ymin:         dc.w   0       ; source y coordinate
s_form:         ds.l   1       ; base address of source form
s_nxwd:         dc.w   8       ; offset to next word in source form in bytes
s_nxln:         dc.w   16      ; offset to next line in source form (29/2)
s_nxpl:         dc.w   2       ; offset to next plane (always 2)
d_xmin:         ds.w   1       ; destination x coordinate
d_ymin:         ds.w   1       ; destination y coordinate
d_form:         ds.l   1       ; base address of destination form
d_nxwd:         dc.w   8       ; offset to next word in destination form
d_nxln:         dc.w   160     ; offset to next line (320/2 pixels per bytes)
d_nxpl:         dc.w   2       ; offset to next plane (always 2)
p_addr:         dc.l   0       ; address of pattern buffer (0=no pattern)
p_nxln:         dc.w   0       ; offset to next line in pattern (not used)
p_nxpl:         dc.w   0       ; offset to next plane in pattern (not used)
p_mask:         dc.w   0       ; pattern index mask (not used)
filler:         ds.b   24      ; usused portion of parameter block

; saucer image
; remember this saucer from Astro Panic

image:          dc.w   0,7,0,7,0,$8000,0,$8000
                dc.w   1,$1e,0,$1e,$8000,$6000,0,$6000
                dc.w   0,$3f,0,$3f,$4000,$b000,0,$b000
                dc.w   0,$7f,0,$7f,0,$f800,0,$f800
                dc.w   $1ff,0,0,0,$fc00,0,0,0
                dc.w   0,$1e49,$1b6,$1b6,0,$27c0,$d800,$d800
                dc.w   0,$7fff,$7fff,$7fff,0,$fff0,$fff0,$fff0
                dc.w   $8000,0,$ffff,0,8,0,$fff8,0
                dc.w   $6aaa,$1555,$7fff,0,$aab0,$5540,$fff0,0
                dc.w   $1d55,$1d55,$1d55,$1d55,$55c0,$55c0,$55c0,$55c0
                dc.w   $3ff,$3ff,0,0,$fe00,$fe00,0,0

; rest of data variables
linapntr:       ds.l   1       ; address of line-a stuff
scr_pntr:       ds.l   1       ; address of screen
old_rez:        ds.w   1       ; old screen rez.
old_pal:        ds.w   16      ; old colour palette
col:            ds.w   1       ; column location
row:            ds.w   9       ; row location for saucer 1
row_off:        ds.w   1       ; offset for saucers 2-9
key_wait:       ds.w   1       ; flag for key press
delay_count:    ds.w   1       ; delay counter
mousevec:       ds.l   1       ; mouse vector
param:          dc.b   0,0,1,1 ; parameter constant for keyboard
blt_loop:       ds.w   1       ; loop counter for blit routine

         text                            ; text section

mainline:                                ; main program control
         jsr        set_up               ; set up the pointers
         move.w     #0,key_wait          ; zero key_wait
         move.w     #0,delay_count       ; zero delay_count
outer:                                   ; outer loop
         move.w     #0,col               ; zero col
         move.w     #0,row               ; load row
inner:                                   ; inner loop
         jsr        vblank               ; sync prg. to screen
         jsr        linea_blt            ; jump bit_blit(eor)
         jsr        delay                ; small delay for screen
         jsr        linea_blt            ; jump bit_blit(eor)
         addq.w     #1,col               ; add 1 from col
         cmpi.w     #285,col             ; see if 285 columns
         blt        inner                ; again if need so
         jsr        get_key              ; jump get_key
         cmpi.w     #-1,key_wait         ; see if key pressed
         bne        outer                ; if not loop again
         jsr        reset_sys            ; reset system
         move.w     #pterm,-(sp)         ; function num. to stack
         trap       #gemdos              ; trap call number

set_up:                                  ; set up pointers, etc.
         dc.w       init                 ; init line-a
         move.l     a0,linapntr          ; save the address of line-a
         dc.w       hide_mouse           ; line-a hide mouse

                                         ; save screen rez
         move.w     #getrez,-(sp)        ; function num. on stack
         trap       #xbios               ; make trap call
         addq.l     #2,sp                ; adjust stack
         move.w     d0,old_rez           ; save result

                                         ; save screen location
         move.w     #physbase,-(sp)      ; function num. to stack
         trap       #xbios               ; make trap call
         addq.l     #2,sp                ; adjust stack
         move.l     d0,scr_pntr          ; save result

                                         ; save palette
         lea        old_pal,a6           ; old_pal > a6
         move.w     #0,d7                ; zero d7
paloop:  move.w     #-1,-(sp)            ; -1 means get colour
         move.w     d7,-(sp)             ; colour num. to get
         move.w     #setcolour,-(sp)     ; function number
         trap       #xbios               ; make trap call
         addq.l     #6,sp                ; adjust stack
         move.w     d0,(a6)+             ; save result
         addi.w     #1,d7                ; adjust loop counter
         cmpi.w     #16,d7               ; how many times
         bne        paloop               ; loop if needed

                                         ; set background to black
         move.w     #$000,-(sp)          ; -1 means get colour
         move.w     #0,-(sp)             ; colour num. to set
         move.w     #setcolour,-(sp)     ; function number
         trap       #xbios               ; make trap call
         addq.l     #6,sp                ; adjust stack

                                         ; switch to low rez.
         move.w     #0,-(sp)             ; low rez. value
         move.l     #-1,-(sp)            ; physical location
         move.l     #-1,-(sp)            ; logical location
         move.w     #setscreen,-(sp)     ; function number
         trap       #xbios               ; trap call number
         add.l      #12,sp               ; adjust stack

                                         ; kill mouse vector
         move.w     #kbdvbase,-(sp)      ; function to stack
         trap       #xbios               ; trap call number
         addq.l     #2,sp                ; adjust stack
         move.l     d0,a0                ; d0 > a0
         add.l      #16,a0               ; add displacment
         move.l     (a0),mousevec        ; reset vector
         move.l     mousevec,-(sp)       ; load stack
         move.l     #param,-(sp)         ; load stack
         move.w     #0,-(sp)             ; load stack
         move.w     #initmouse,-(sp)     ; function number to stack
         trap       #xbios               ; trap call number
         add.l      #12,sp               ; adjust stack
         rts                             ; return to calling routine

linea_blt:                               ; line-a bit_blit call
         move.w     row,row_off          ; load row offset
         move.w     #0,blt_loop          ; zero loop counter
loop:                                    ; loop for blitter
         move.l     linapntr,a0          ; restore line-a pointer
         move.w     #4,plane_ct          ; init plane count
         move.l     #$06060606,op_tab    ; xor logic opcode
         move.l     #image,s_form        ; get address of image
         move.l     scr_pntr,d_form      ; screen address
         lea        bltparm,a6           ; point to blit parmeter block
         move.w     col,d_xmin           ; x position on screen
         move.w     row_off,d_ymin       ; y position on screen
         dc.w       bitblt               ; do bit_blit
         add.w      #15,row_off          ; add 15 to row offset
         add.w      #1,blt_loop          ; add 1 to blit loop
         cmpi.w     #13,blt_loop         ; see if loop again
         bne        loop                 ; loop if need so
         rts                             ; return to calling routine

vblank:                                  ; sync prg to screen
         move.w     #vsync,-(sp)         ; function number to stack
         trap       #xbios               ; trap call number
         addq.l     #2,sp                ; adjust stack
         rts                             ; return to calling routine

reset_sys:                               ; switch back rez.
         move.w     old_rez,-(sp)        ; low rez. value
         move.l     #-1,-(sp)            ; physical location
         move.l     #-1,-(sp)            ; logical location
         move.w     #setscreen,-(sp)     ; function number
         trap       #xbios               ; trap call number
         add.l      #12,sp               ; adjust stack
         lea        old_pal,a0           ; old_pal > a0
         move.l     a0,-(sp)             ; old palette to stack
         move.w     #setpalette,-(sp)    ; function number to stack
         trap       #xbios               ; trap call number
         addq.l     #6,sp                ; adjust stack
         move.l     mousevec,-(sp)       ; load stack
         move.l     #param,-(sp)         ; load stack
         move.w     #1,-(sp)             ; load stack
         move.w     #initmouse,-(sp)     ; function number to stack
         trap       #xbios               ; trap call number
         add.l      #12,sp               ; adjust stack
         move.l     linapntr,a0          ; restore line-a pointer
         dc.w       show_mouse           ; call show_mouse
         rts                             ; return to calling routine

get_key:                                 ; see if key is waiting
         move.w     #2,-(sp)             ; 2=con:
         move.w     #bconstat,-(sp)      ; function number to stack
         trap       #bios                ; trap call number
         addq.l     #4,sp                ; adjust stack
         move.w     d0,key_wait          ; store results
         rts                             ; return to calling routine

delay:                                   ; delay counter
         addq.w     #1,delay_count       ; add 1 to counter
         cmpi.w     #325,delay_count     ; 325 yet
         bne        delay                ; equal yet
         move.w     #0,delay_count       ; re-zero counter
         rts                             ; return to calling routine

         end                             ; end of source code

 