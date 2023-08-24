/ 11/11/89
/
/            TOS 1.4-specific AES calls for Mark Williams C
/                             by Dan Wilga
/
/
/  Assemble with the line:  cc new_aes.s -c
/  Add to libaes.a:         ar rs libaes.a new_aes.o
/
/
/  Function wind_new():  Close and delete all windows, reset wind_update()
/                        count, flush all window buffers, restore mouse
/                        ownership to the system, and reset the mouse
/                        on/off count.
/
.globl  wind_new_
wind_new_:
        move.l  d1, -(sp)
        move.w  $109, control_          / opcode in control[0]
        clr.l   control_+2              / and zero-out the rest
        clr.l   control_+6              / ...
        pea     aespb(pc)
        jsr     crystal_                / go do trap
        addq    $4, sp
        move.l  (sp)+, d1
        rts

/
/ Function fsel_exinput():  Just like fsel_input() except that you can have
/                           a title string in place of ITEM SELECTOR.
/
/ Parameters:  fsel_exinput( path, filename, &button, title );
/              char *path, *filename, *title; int *button;
/
/ "title" is the only different parameter. It points to a string of no more
/ than 30 characters to be displayed.
/
.globl  fsel_exinput_
fsel_exinput_:
        move.l  d1, -(sp)               / save for later
        lea     control_, a0
        move.w  $91, (a0)+              / opcode in control[0]
        clr     (a0)+                   / control[1]
        move    $2, (a0)+               / control[2]
        move    $3, (a0)+               / control[3]
        clr     (a0)                    / control[4]
        lea     addr_in_, a0
        move.l  8(sp), (a0)+            / path in addr_in[0]
        move.l  12(sp), (a0)+           / filename in addr_in[1]
        move.l  20(sp), (a0)            / title in addr_in[2]
        pea     aespb(pc)
        jsr     crystal_                / crystal moves aespb into d1 and 
        addq    $4, sp                  /   does trap 2
        move    int_out_, d0            / get return value
        movea.l 16(sp), a0
        move    int_out_+2, (a0)        / set new value for "button"
        move.l  (sp)+, d1               / restore d1
        rts
        
aespb:  .long control_, global_, int_in_, int_out_, addr_in_, addr_out_

/ This code could be optimized a bit (by using longword moves for the
/ control_ data, more pc-relative references) but the former can be
/ confusing, and the latter only works if the labels are within 32k, sooo...
