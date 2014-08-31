; **************************************************************************
; This is the source of DESKTOP.PRG, a program that changes the normal gray
; background with a Degas PI3 file. This source is public domain, but I
; would appreciate it very much if a program that uses (part) of this
; source respects the name of the author!
; **************************************************************************
; This specific version (1.1) returns the picture adress in intout[2]
; when vs_clip() is called. "N_DP" is returned in intout[0] to
; be able to check whether this adress is valid.
; **************************************************************************
; Noud van Kruysbergen
; N.I.C.I.
; P.O. Box 9104
; 6500 HE Nijmegen
; The Netherlands
; email: kruysbergen@hnykun53.bitnet
; **************************************************************************

          text

          move.l    4(A7),A0            ; these lines are the normal
          move.l    #$100,D4            ; ones for a TSR program
          add.l     12(A0),D4           ; there's nothing interesting
          add.l     20(A0),D4           ; here.
          add.l     28(A0),D4           ; You only have to add 32000 bytes
          add.l     #32000,D4           ; for the (PI3) picture.

          lea       noudtext,A0         ; show the copyright lines
          bsr       cconws              ; to the screen

          clr.w     -(A7)               ; try to open the file
          pea       file1               ; "DESKTOP.PI3" in the AUTO
          move.w    #$3d,-(A7)          ; folder.
          trap      #1                  ; D3 = Fopen("AUTO\DESKTOP.PI3",0);
          addq.l    #8,A7
          move.w    D0,D3
          bpl       ok1                 ; File exists: goto ok1

          clr.w     -(A7)               ; If the file does not exist:
          pea       file2               ; try to open "DESKTOP.PI3" in the
          move.w    #$3d,-(A7)          ; root directory.
          trap      #1                  ; D3 = Fopen("DESKTOP.PI3",0);
          addq.l    #8,A7
          move.w    D0,D3
          bpl       ok1                 ; File exist: goto ok1

          lea       error1,A0           ; No "DESKTOP.PI3" exists
          bsr       cconws              ; print this to screen
          move.w    #7,-(A7)            ; let the bell ring
          move.w    #2,-(A7)
          trap      #1                  ; Cconout(7);
          addq.l    #4,A7
          bsr       wait                ; wait for a moment to be able to
          clr.w     -(A7)               ; read the message and
          trap      #1                  ; Pterm0();

ok1:      clr.w     -(A7)               ; The file exists. Skip the
          move.w    D3,-(A7)            ; PI3 header info (34 bytes).
          move.l    #34,-(A7)
          move.w    #$42,-(A7)
          trap      #1                  ; Fseek(34L,D3,0);
          adda.l    #10,A7

          pea       picbuffer           ; Read the picture in the
          move.l    #32000,-(A7)        ; buffer (which begins at
          move.w    D3,-(A7)            ; 'picbuffer'.
          move.w    #$3f,-(A7)
          trap      #1                  ; Fread(D3,32000L,picbuffer);
          adda.l    #12,A7
          cmpi.l    #32000,D0           ; 32000 bytes read?
          beq       ok2                 ; goto ok2
          lea       error2,A0           ; else print warning to screen
          bsr       cconws
          bsr       wait                ; wait, but do install!

ok2:      pea       gemnew              ; the new gem vector
          move.w    #34,-(A7)
          move.w    #5,-(A7)
          trap      #13                 ; gemold=Setexc(34,gemnew);
          addq.l    #8,A7
          move.l    D0,gemold
          lea       gemnew,A0
          move.l    D0,-4(A0)           ; return adress for XBRA protocol

          move.w    D3,-(A7)            ; close the file
          move.w    #$3e,-(A7)
          trap      #1                  ; Fclose(D3);
          addq.l    #4,A7

          clr.w     -(A7)               ; terminate and stay resident
          move.l    D4,-(A7)            ; with no errorcode
          move.w    #$31,-(A7)
          trap      #1                  ; Pterm(D4,0);

; --------------------------------------------------------------------------

cconws:   move.l    A0,-(A7)            ; routine to print line to screen
          move.w    #9,-(A7)
          trap      #1                  ; Cconws(A0);
          addq.l    #6,A7
          rts

wait:     move.w    #1000,D1            ; routine that eats up CPU time
wait1:    move.w    #1000,D0            ; simply to wait
wait2:    dbf       D0,wait2
          dbf       D1,wait1
          rts

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; this is where it all is about. The new gemvector starts here.
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

          dc.b      "XBRAN_DP"
          dc.l      0
gemnew:   cmpi.w    #115,D0             ; test whether it is a VDI call
          bne       gemquit

; *************************************************************************
; It is a VDI call!

          movem.l   D0-A3,-(A7)         ; save registers

          move.l    D1,A0
          move.l    (A0),A0             ; D0 = control[0];
          move.w    (A0),D0             ; what VDI call is it?

; **************************************************************************
; Is the VDI call vr_recfl()?

          cmpi.w    #114,D0
          bne       nofill
          cmpi.w    #2,interior         ; Has vsf_interior(handle,2);
          bne       gemrest             ; been called?
          cmpi.w    #4,style            ; Has vsf_style(handle,4);
          bne       gemrest             ; been called?

          tst.w     mode                ; Is it in the clipping mode?
          beq       gemrest
          move.l    D1,A0
          move.l    8(A0),A0            ; D0 = intin[0] etc..
          move.w    (A0)+,D0            ; x0==0
          bne       gemrest
          move.w    (A0)+,D0            ; y0==0 || y0==19
          cmpi.w    #19,D0
          beq       menu
          tst.w     D0
          bne       gemrest
menu:     move.w    (A0)+,D0            ; x1==639
          cmpi.w    #639,D0
          bne       gemrest
          move.w    (A0),D0             ; y1==399
          cmpi.w    #399,D0
          bne       gemrest

; All the conditions are true. They mean that a gray background should
; be drawn. The exact size is set in the clipping variables. They are
; used to draw the background.

          move.l    $44e,A1             ; A1 = *(long *)0x44e;
          move.w    clipy0,D0
          move.w    D0,D2               ; D0 = D2 = clipy0;
          muls      #80,D0              ; D0 *= 80 /* 80 characters per line */
          adda.l    D0,A1               ; A1 = screenadres + clipy0 offset;
          lea       picbuffer,A0        ; A0 = pictureadres;
          adda.l    D0,A0               ; A0 = pictureadres + clipy0 offset;
          move.w    clipy1,D0           ; D0 = clipy1;
          sub.w     D2,D0               ; D0 = clipy1 - clipy0;
          move.w    D0,D2               ; D2 = total number of lines;
          move      clipx0,D3           ; D3 = x0;
          move.w    D3,D7
          ext.l     D7
          divs      #8,D7
          move.w    D7,D3
          adda.l    D3,A0
          adda.l    D3,A1               ; D3 = clipx0/8;
          swap      D7
          move.w    D7,D4               ; D4 = clipx0%8;
          move.w    clipx1,D5
          addq.w    #1,D5
          move.w    D5,D7
          ext.l     D7
          divs      #8,D7
          move.w    D7,D5               ; D5 = clipx1/8;
          swap      D7
          move.w    D7,D6               ; D6 = clipx1%8;
          move.l    D5,D0
          sub.l     D3,D0
          bne       label3              ; if (D3>D5) goto label3;

; --------------------------------------------------------------------------
; This routine takes care of the times when the desktop has to be redrawn
; within one character (for instance from bit 2 to bit 5).
; --------------------------------------------------------------------------

          move.w    D6,D7               ; D7 = D6; /* D6=5+1 */
          subi.w    #8,D7
          neg.w     D7                  ; D7 = -(D6-8); /* D7=2 */
          move.b    #-1,D3              ; D3 = 11111111 /* in binary mode */
          lsr.b     D7,D3               ; D3 = 00111111
          lsl.b     D7,D3               ; D3 = 11111100
          lsl.b     D4,D3               ; D3 = 11110000 /* D4=2 */
          lsr.b     D4,D3               ; D3 = 00111100

; This is a very elegant way to make a byte that has the bits set that
; should contain the background information. A zero in this byte means that
; what is on screen at that location should stay there. In this case only
; the bits 5,4,3 and 2 (numbers 2,3,4 and 5 from the left) have to be updated.

byteloop: move.b    D3,D0               ; D0 = 00111100
          move.b    (A0),D7             ; D7 = picturebyte
          and.b     D0,D7               ; D7 &= 00111100
          not.b     D0                  ; D0 = 11000011
          and.b     (A1),D0             ; screenbyte &= 11000011
          add.b     D0,D7               ; D7 = picturebyte + screenbyte
          move.b    D7,(A1)             ; screenbyte = D7
          adda.l    #80,A0              ; next pictureline
          adda.l    #80,A1              ; next screenline
          dbf       D2,byteloop         ; do this for all # lines
          bra       selfok              ; quit the GEM call

; --------------------------------------------------------------------------
; More than one byte have to be redrawn.
; --------------------------------------------------------------------------

label3:   subq.w    #1,D0               ; # bytes -= 1 for 'dbf' sake.
          tst.w     D4                  ; xclip0 on a byte-boundairy?
          seq       D5                  ; yes : set D5
          beq       yloop               ;     : goto yloop
          tst.w     D0                  ; D0==0? /* only 1 byte? */
          sne       D5                  ; no  : set D5
          beq       yloop               ; yes : goto yloop
          subq.w    #1,D0               ; more than one byte: D0 -= 1;

; --------------------------------------------------------------------------
; Start of the actual updating routine.
; --------------------------------------------------------------------------

; We first have to draw the remainder of the first byte. If there is no
; remainder (D4=0) we don't have to do this. Suppose we have to redraw
; from bit 4 (from the left, so actually bit 5): D4=3.

yloop:    move.l    A0,A2               ; A2 = pictureadres
          move.l    A1,A3               ; A3 = screenadres
          tst.w     D4                  ; if no remainder has to be drawn
          beq       nostart             ; then don't do this
          move.b    (A2)+,D3            ; D3 = picturebyte
          move.b    #-1,D7              ; D7 = 11111111
          lsr.b     D4,D7               ; D7 = 00011111
          and.b     D7,D3               ; D3 &= 00011111 /* picturebits */
          not.b     D7                  ; D7 = 11100000
          and.b     (A3),D7             ; D7 &= screenbyte /* screenbits */
          add.b     D3,D7               ; D7 += D3 /* picture+screen */

; D7 contains the high bits from the old background and the low bits from
; the redrawn background.

          move.b    D7,(A3)+            ; screenbyte = D7

; When we arrived here, we are at a byte boundary. We are going to copy
; bytes from the picture to the screen if necessary (D5 was set)

nostart:  move.w    D0,D7               ; D7 = # bytes
          tst.w     D5
          beq       endbyte             ; D5 not set: goto endbyte
xloop:    move.b    (A2)+,(A3)+         ; screenbyte = picturebyte
          dbf       D7,xloop            ; do this # bytes times

; We still are at a byte boundary. Are there any bits to draw any further?

endbyte:  tst.w     D6                  
          beq       no_end

; If not, skip this part. D6 contains the number of bits to update, say 3.

          move.b    (A2)+,D3            ; D3 = picturebyte
          move.b    #-1,D7              ; D7 = 11111111
          lsr.b     D6,D7               ; D7 = 00011111
          not.b     D7                  ; D7 = 11100000
          and.b     D7,D3               ; D3 &= 11100000 /* picturebits */
          not.b     D7                  ; D7 = 00011111
          and.b     (A3),D7             ; D7 &= screenbyte
          add.b     D3,D7               ; D7 = screenbits + picturebits
          move.b    D7,(A3)             ; screenbyte = D7

no_end:   adda.l    #80,A0              ; next picture line
          adda.l    #80,A1              ; next screen line
label1:   dbf       D2,yloop            ; do this # lines times

selfok:   movem.l   (A7)+,D0-A3         ; quit the GEM call
          rte

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; This is were the redrawing of the background ends. It all is in fact
; nothing more than shifting a proper amount of bits at a proper time!
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; **************************************************************************
; Is the VDI call vst_interior()?

nofill:   move.l    D1,A0
          move.l    4(A0),A0
          move.w    (A0),D2             ; D2 = intin[0];

          cmpi.w    #23,D0
          bne       nointerior
          move.w    D2,interior         ; interior = intin[0];
          bra       gemrest

; **************************************************************************
; Is the VDI call vst_style()?

nointerior:cmpi.w   #24,D0
          bne       nostyle
          move.w    D2,style            ; style = intin[0];
          bra       gemrest

; **************************************************************************
; Is the VDI call vs_clip()?

nostyle:  cmpi.w    #129,D0
          bne       gemrest
          move.w    D2,mode             ; mode = intin[0];
          beq       gemrest             ; if (mode==0) no clipping;

          cmpi.w    #-1,D2
          bne       normal

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; for version 1.0 exclude the part between the ...++++++... lines !!!
;
; We return the picture adress in intout[2] when vs_clip(x,-1,x) is called.
; This is an illegal not documented feature! When DESKTOP.PRG is not
; installed the content of intout[2] is NOT the picture adress!
; This can be controlled by intout[0]: if *(long *)intout==$4e5f4450
; ("N_DP") the value *(long *)(intout+4) is a valid picture adress.

          move.l    D1,A0
          move.l    12(A0),A0
          move.l    #$4e5f4450,(A0)+    ; *(ong *)intout=0x4e5f4450
          clr.l     (A0)+
          lea       picbuffer,A1
          move.l    A1,(A0)             ; *(long *)(intout+4)=picbuffer;
          bra       selfok

; This is the normal clipping procedure
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

normal:   move.l    D1,A0
          move.l    8(A0),A0
          move.w    (A0)+,clipx0        ; clipx0 = intin[0];
          move.w    (A0)+,clipy0        ; clipy0 = intin[1];
          move.w    (A0)+,clipx1        ; clipx1 = intin[2];
          move.w    (A0),clipy1         ; clipy1 = intin[3];

gemrest:  movem.l   (A7)+,D0-A3         ; restore registers
gemquit:  move.l    gemold,-(A7)        ; put old GEM vector on the stack
          rts                           ; and jump to it...

          data

noudtext: dc.b      27,'E',13,10,10,"    ",27,'p',"     Desktop Picture V1.1     "
          dc.b      27,'q',13,10,"    ",27,'p',"     Noud van Kruysbergen     ",27,'q',13,10,10,0
error1:   dc.b      "    **** Error: DESKTOP.PI3 ? ****",13,10,0
error2:   dc.b      "     Warning: DESKTOP.PI3 < 32034",13,10,0
file1:    dc.b      "AUTO\DESKTOP.PI3",0
file2:    dc.b      "DESKTOP.PI3",0
          even

          bss

style:    ds.w      1
interior: ds.w      1
mode:     ds.w      1
clipx0:   ds.w      1
clipy0:   ds.w      1
clipx1:   ds.w      1
clipy1:   ds.w      1
gemold:   ds.l      1
picbuffer:ds.l      1                   ; 32000 bytes are reserved from here.

          end

