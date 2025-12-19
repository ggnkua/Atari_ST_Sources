**********************************************
*                                            *
*  Font ID Editor                            *
*                                            *
*  Copyright 1989 Charles F. Johnson         *
*                                            *
*  Written with the Atari MAD MAC assembler  *
*                                            *
**********************************************

* Last revision: Tuesday, December 27, 1988  1:07:28 pm

        .text

        move.l  4(sp),d1        ; Get address of basepage
        lea     ustack,sp       ; Set up my stack
        move.l  #prgend,d0      ; Address of end of this program
        sub.l   d1,d0           ; Get number of bytes to shrink down to

        move.l  d0,-(sp)
        move.l  d1,-(sp)
        clr.w   -(sp)
        move.w  #$4A,-(sp)      ; Mshrink
        trap    #1
        lea     12(sp),sp

        move.w  #$19,-(sp)      ; Get current drive
        trap    #1
        addq    #2,sp
        add.b   #65,d0          ; Convert to ASCII
        lea     fntdir,a6
        move.b  d0,(a6)+
        move.b  #':',(a6)+

        clr     -(sp)           ; Get path for current drive
        move.l  a6,-(sp)        ; Put it right after the colon
        move    #$47,-(sp)
        trap    #1
        addq    #8,sp

        lea     fntdir,a0
.loop:  tst.b   (a0)+           ; Find the end of the pathname string
        bne     .loop
        subq    #1,a0
        lea     fnttxt(pc),a1
.loop1: move.b  (a1)+,(a0)+     ; Tack the search spec to the end
        bne     .loop1

        lea     title(pc),a5    ; Clear screen and print title
        bsr     print

fsel:   bsr     aes             ; We're already set up to call fsel_input

        lea     clears(pc),a5   ; Clear everything below the first line
        bsr     print

        tst.b   file            ; Is there a filename here?
        beq     ex2             ; No, exit stage right
        cmp.w   #1,intout+2     ; Click on OK?
        bne     ex2             ; No, let's just forget it

        lea     pathnm,a0       ; Construct a full pathname from the output
        lea     fntdir,a1       ; of fsel_input
.loop:  move.b  (a1)+,(a0)+     ; First, move in the path
        bne     .loop
.loop1: cmp.b   #'\\',-(a0)     ; Search backward for the last backslash
        bne     .loop1
        addq    #1,a0
        lea     file,a1
.loop2: move.b  (a1)+,(a0)+     ; Now tack on the file name
        bne     .loop2

        clr     -(sp)           ; Open for read only
        pea     pathnm
        move    #$3D,-(sp)
        trap    #1
        addq    #8,sp
        tst     d0
        bpl.s   read1           ; No error, skip ahead

noopen: lea     cantopen(pc),a5 ; "Can't open" message
outta:  bsr     print
        lea     hitakey(pc),a5  ; "Hit any key."
        bsr     print
        bsr     getkey          ; Wait for a keypress
        lea     cr(pc),a5
        bsr     print
        bsr     print
        bra     another?

read1:  move    d0,handle       ; Save file handle

        pea     header          ; Read in the first 36 bytes of the font
        move.l  #36,-(sp)       ; header
        move    handle,-(sp)    ; (ID, point size, and font name)
        move    #$3F,-(sp)
        trap    #1
        lea     12(sp),sp
        tst.l   d0
        bpl.s   .read2          ; If no error, skip ahead

        bsr     closfl          ; Close the file
        lea     cantread(pc),a5 ; "Can't read" message
        bra     outta

.read2: bsr     closfl          ; Close it

        bsr     print_info      ; Display the font information

askem:  lea     savpos(pc),a5
        bsr     print

        lea     prompt(pc),a5   ; "New font ID?"
        bsr     print

        move.b  #20,keybuf      ; Maximum 20 characters

        lea     keybuf+2,a0
        move    #20,d0
.loop:  clr.b   (a0)+           ; Clear the input buffer
        dbf     d0,.loop

        dc.w    $A00A           ; Hide the mouse

        pea     keybuf          ; Get a line of keyboard input
        move    #$0A,-(sp)
        trap    #1
        addq    #6,sp

        lea     curoff(pc),a5   ; Turn text cursor off again
        bsr     print

        dc.w    $A009           ; Show the mouse

        lea     keybuf,a0       ; Pointer to input buffer

        tst.b   1(a0)           ; Any keys input?
        bne.s   cnv             ; Yes, go see what they were

keep:   lea     kept(pc),a5     ; "The font ID was not changed."
        bsr     print
        bra     another?

cnv:    cmp.b   #1,1(a0)        ; One character?
        bne.s   cnv2

        cmp.b   #'P',2(a0)      ; Print?
        beq.s   hard1
        cmp.b   #'p',2(a0)
        bne.s   cnv2

hard1:  clr     device          ; Set printer device
        bsr     print_info
        move    #2,device

        lea     clprom(pc),a5
        bsr     print
        bra     askem   

cnv2:   moveq   #0,d0
        move.b  1(a0),d0        ; Get number of characters
        lea     2(a0),a0        ; Pointer to input buffer
        clr.b   (a0,d0)         ; Put a zero at the end
        bsr     decbin          ; Convert the ASCII string to binary

        tst     d0              ; Did we type a valid number?
        beq     keep            ; No, keep the current ID

        cmp     #32767,d0       ; If higher than 32767, keep the current ID
        bhi     keep

        and.l   #$FFFF,d0       ; Mask off upper word
        move.b  d0,d1           ; Save low byte
        lsr     #8,d0           ; Shift upper byte to lower byte
        lsl     #8,d1           ; Shift lower byte to upper byte
        or      d1,d0           ; Mix 'em together
        move    d0,header       ; Store byte-swapped value

        move    #2,-(sp)        ; Open the file again for read/write
        pea     pathnm
        move    #$3D,-(sp)
        trap    #1
        addq    #8,sp
        tst     d0
        bmi     noopen

        move    d0,handle       ; Save file handle

        lea     writenew(pc),a5 ; "Writing new font ID ...."
        bsr.s   print

        pea     header          ; Write the new ID value to the font file
        move.l  #2,-(sp)
        move    handle,-(sp)
        move    #$40,-(sp)
        trap    #1
        lea     12(sp),sp
        tst.l   d0              ; Error?
        bpl.s   closit          ; No, skip ahead

        bsr.s   closfl          ; Close it
        lea     cantwrit(pc),a5 ; "Can't write" message
        bra     outta

closit: bsr.s   closfl

another?:
        lea     more(pc),a5     ; "Another font file?"
        bsr.s   print
        bsr.s   getkey          ; Get a keypress
        move.l  d0,d7           ; Save it

        lea     curoff(pc),a5   ; Turn text cursor off
        bsr.s   print
        lea     clears(pc),a5   ; Clear screen below title line
        bsr.s   print

        swap    d7              ; Get scan code to low word
        cmp     #$15,d7         ; 'Y'?
        beq     fsel            ; Yep, go do it again

ex2:    clr.w   -(a7)           ; Pterm0
        trap    #$1             ; So long, folks

* Subroutines

* Print a line of text
*
* Enter with:
* a5 -> text to print
* device = device number
*
* Preserves a5
* Clobbers a0-a4/d0-d2

print:  dc.w    $A00A           ; Hide mouse
        moveq   #0,d0           ; Make sure this is zero
        move.l  a5,a4
print2: move.b  (a4)+,d0        ; Get character
        beq.s   p_x             ; If zero, exit
        move    d0,-(sp)        ; Print it with bconout
        move    device,-(sp)
        move    #3,-(sp)
        trap    #13
        addq    #6,sp
        bra     print2          ; Keep looping til done
p_x:    dc.w    $A009           ; Show the mouse
        rts

getkey: dc.w    $A00A           ; Hide mouse
        move    #2,-(sp)        ; Get a key with bconin
        move    #2,-(sp)
        trap    #13
        addq    #4,sp
        move.l  d0,-(sp)        ; Save it
        dc.w    $A009           ; Show mouse
        move.l  (sp)+,d0        ; Get the character back
        rts

closfl: move    handle,-(sp)    ; Close a file
        move    #$3E,-(sp)
        trap    #1
        addq    #4,sp
        rts

print_info:
        lea     fntext(pc),a5   ; "Font file:"
        bsr     print
        lea     pathnm,a5       ; Print the full pathname
        bsr     print
        lea     cr(pc),a5       ; A couple of carriage return/line feeds
        bsr     print

        lea     fname(pc),a5    ; "Font name:"
        bsr     print
        lea     header+4,a5     ; Print the font name
        bsr     print
        lea     cr(pc),a5
        bsr     print
        lea     psize(pc),a5    ; "Point size:"
        bsr     print

        move.b  header+3,d0     ; All values in GEM fonts are stored in 8088
        lsl     #8,d0           ; format (low/high) so we have to switch
        move.b  header+2,d0     ; the bytes around
        bsr.s   bindec          ; Convert the point size to decimal ASCII

        bsr     non_zero        ; Advance the pointer past any leading zeros
        bsr     print           ; Print the point size

        lea     cr(pc),a5       ; Carriage return/line feed
        bsr     print

        lea     idtext(pc),a5   ; "Font ID #:"
        bsr     print

        move.b  header+1,d0     ; Now swap the font ID number
        lsl     #8,d0
        move.b  header,d0
        bsr.s   bindec          ; Convert ID # to decimal ASCII

        bsr.s   non_zero        ; Move past leading zeros
        bsr     print           ; Print the font ID number

        lea     cr(pc),a5
        bsr     print
        bsr     print

        rts

* Convert decimal ASCII to longword binary
*
* Enter with:
* a0 -> ASCII string
*
* Exit with:
* d0 = converted binary number
*
* Clobbers a0/d1

decbin: moveq   #0,d0
.loop:  cmp.b   #'9',(a0)       ; Decimal number?
        bhi.s   notdec          ; No, exit
        cmp.b   #'0',(a0)
        blo.s   notdec
        lsl     #1,d0           ; *2
        move.l  d0,d1           ; Save result
        lsl     #2,d0           ; *8
        add.l   d1,d0           ; *10
        move.b  (a0)+,d1        ; Get character
        and.l   #$0F,d1         ; Make it a number 0-9
        add.l   d1,d0           ; Add to accumulator
        bra     .loop           ; Loop til done
notdec: rts

* Convert binary word to decimal ASCII
*
* Enter with:
* d0.w = binary number to be converted
*
* Exit with:
* decimal ASCII string in 'deciml'
*
* Clobbers a0/d0-d1

bindec: lea     deciml,a0
        move    #4,d1
.zero:  move.b  #'0',(a0)+      ; Initialize string to "0"s
        dbf     d1,.zero
        clr.b   (a0)            ; Set null at end
        move    #4,d1           ; Five digits
        and.l   #$FFFF,d0       ; Just in case
.loop:  ext.l   d0              ; Extend to longword
        divs    #10,d0          ; Divide by 10
        swap    d0              ; Get remainder to low word
        move.b  d0,-(a0)        ; Move it to string
        add.b   #'0',(a0)       ; Make it ASCII
        swap    d0              ; Swap it back
        dbra    d1,.loop        ; Do 'em all
        rts

non_zero:
        lea     deciml,a5
.zero:  cmp.b   #'0',(a5)+      ; Advance a5 to first non "0" character
        beq     .zero
        subq    #1,a5
        rts

aes:    move.l  #aespb,d1       ; Call the AES
        move.l  #$c8,d0
        trap    #2
        rts

* Note that this is still the .text segment.  We don't define
* a .data area, allowing us to use PC relative addressing for
* all these text strings.

fnttxt: dc.b    '\\*.FNT',0

title:  dc.b    '\eE\ef\ep'
        dc.b    '                      '
        dc.b    'Font ID Editor by Charles F. Johnson'
        dc.b    '                      '
        dc.b    '\eq\r\n\n',0

cantopen:
        dc.b    7,' Cannot open file!\r\n\n',0

cantread:
        dc.b    7,' Cannot read file!\r\n\n',0

cantwrit:
        dc.b    7,' Cannot write file!\r\n\n',0

hitakey:
        dc.b    ' Hit any key.',0

fntext:
        dc.b    '  Font file: ',0

fname:
        dc.b    '  Font name: ',0

psize:
        dc.b    ' Point size: ',0

idtext:
        dc.b    '  Font ID #: ',0

prompt:
        dc.b    ' New ID number? (\epReturn\eq=keep, \epP\eq=Print) >\ee',0

kept:
        dc.b    '\r\n\n The font ID was not changed.\r\n\n',0

writenew:
        dc.b    '\r\n\n Writing new font ID .....\r\n\n',0

more:
        dc.b    ' Another font? (\epY\eq/\epN\eq) >\ee',0

clears: dc.b    '\eH\n\eJ\n',0

clprom: dc.b    '\ek\eJ',0

curoff: dc.b    '\ef',0

savpos: dc.b    '\ej',0

cr:     dc.b    '\r\n',0

count1: dc.b    'Choose a',0
count2: dc.b    'font file:',0

        .even

f_sel:  dc.w    90,0,2,4,0

aespb:  dc.l    f_sel,global,intin,intout,addrin,addrout

addrin: dc.l    fntdir,file,count1,count2

device: dc.w    2

        .bss
        .even

handle: ds.w    1

intin:  ds.w    16
intout: ds.w    16
global:
apvrsn: ds.w    1
apcont: ds.w    1
apid:   ds.w    1
apprvt: ds.l    1
apptre: ds.l    1
ap1rsv: ds.l    1
ap2rsv: ds.l    1
ap3rsv: ds.l    1
ap4rsv: ds.l    1
addrout:ds.l    4

file:   ds.b    16

pathnm: ds.b    128

fntdir: ds.b    80

deciml: ds.b    12

header: ds.b    64

keybuf: ds.b    32

        ds.l    300
ustack: ds.l    1
        ds.w    10

prgend: ds.w    0

        .end
