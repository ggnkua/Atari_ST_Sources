* The 8 Queens Problem
* An example GEM program for Ringpull's GEM course in ST-NEWS
* ½ Ciaran Wills 1994

* The equates for the names of the object in the RSC file
* First the pull down menu tree
MENU            EQU 0           ; ID of the tree itself
ABOUT           EQU 8           ; 'About Queens...' menu item
SOLVE           EQU 17          ; 'Solve...'
SOLVEALL        EQU 18          ; 'Solve all'
QUIT            EQU 20          ; 'Quit'
OUTPUT          EQU 22          ; 'Output...'
* The Info box tree
ABOUTBOX        EQU 1           ; ID of the tree itself
ABOUTOK         EQU 5           ; The OK button
* The output options dialogue box
OPTIONS         EQU 2           ; ID of the tree itself
PRINTER         EQU 2           ; Printer output
FILE            EQU 3           ; File output
PARALLEL        EQU 5           ; Parallel printer
SERIAL          EQU 6           ; Serial printer
NAME            EQU 8           ; Editable file name
OPTOK           EQU 9           ; OK button
OPTCAN          EQU 10          ; Cancel button
* The dialogue box where all the action takes place...
QUEENS          EQU 3           ; ID of the tree itself
Q11             EQU 3           ; IDs for each of the 64 boxes...
Q12             EQU 4
Q13             EQU 5
Q14             EQU 6
Q15             EQU 7
Q16             EQU 8
Q17             EQU 9
Q18             EQU 10
Q21             EQU 11
Q22             EQU 12
Q23             EQU 13
Q24             EQU 14
Q25             EQU 15
Q26             EQU 16
Q27             EQU 17
Q28             EQU 18
Q31             EQU 19
Q32             EQU 20
Q33             EQU 21
Q34             EQU 22
Q35             EQU 23
Q36             EQU 24
Q37             EQU 25
Q38             EQU 26
Q41             EQU 27
Q42             EQU 28
Q43             EQU 29
Q44             EQU 30
Q45             EQU 31
Q46             EQU 32
Q47             EQU 33
Q48             EQU 34
Q51             EQU 35
Q52             EQU 36
Q53             EQU 37
Q54             EQU 38
Q55             EQU 39
Q56             EQU 40
Q57             EQU 41
Q58             EQU 42
Q61             EQU 43
Q62             EQU 44
Q63             EQU 45
Q64             EQU 46
Q65             EQU 47
Q66             EQU 48
Q67             EQU 49
Q68             EQU 50
Q71             EQU 51
Q72             EQU 52
Q73             EQU 53
Q74             EQU 54
Q75             EQU 55
Q76             EQU 56
Q77             EQU 57
Q78             EQU 58
Q81             EQU 59
Q82             EQU 60
Q83             EQU 61
Q84             EQU 62
Q85             EQU 63
Q86             EQU 64
Q87             EQU 65
Q88             EQU 66
TOTAL           EQU 83          ; Running total of solutions found
NEXT            EQU 84          ; Next solution button
DONE            EQU 85          ; 'Done' button
* The 'solving' box with running total
SOLVING         EQU 4           ; ID of the tree itself
SOFAR           EQU 3           ; Running total


* As always we start off with the GEM header
                movea.l sp,a5
                lea     stack(pc),sp    ; Point to our stack
                movea.l 4(a5),a5
                move.l  12(a5),d0
                add.l   20(a5),d0
                add.l   28(a5),d0
                add.l   #256,d0
                move.l  d0,-(sp)
                move.l  a5,-(sp)
                clr.w   -(sp)
                move.w  #$4A,-(sp)
                trap    #1
                lea     12(sp),sp
                bsr     initialise      ; Sort out all the resource stuff
loop:           lea     message(pc),a0  ; Get address of message buffer
                move.l  a0,addrin       ; And stick it in addrin
                move.l  #evnt_mesag,aespb ; evnt_mesag call
                bsr     aes             ; Do it
                cmpi.w  #10,(a0)        ; Is it a menu event
                bne.s   loop            ; If not, ignore it
                move.w  8(a0),d0        ; Get Id of menu item
                cmpi.w  #ABOUT,d0
                beq     about
                cmp.w   #QUIT,d0
                bne.s   noquit
                moveq   #1,d0           ; 'Do tou want to quit?'
                bsr     alert
                cmp.w   #1,d0           ; 1 for yes
                beq     quit            ; Exit routine
                move.w  6(a0),intin     ; If not then fix menu
                move.w  #1,intin+2      ; Show in normal video
                move.l  #menu_tnormal,aespb ; menu_tnormal call
                move.l  menuaddr(pc),addrin ; Address of menu tree
                bsr     aes
                bra.s   loop            ; Wait for another menu selection
noquit:         cmp.w   #OUTPUT,d0      ; Continue checking items
                beq     options
                cmp.w   #SOLVE,d0
                beq     solve
                cmp.w   #SOLVEALL,d0
                bne.s   loop

* The solve all... routine
                bsr     open            ; Open file or printer channel
                tst.w   d0              ; Successful?
                bmi     loop            ; No
                bsr     start           ; Find first solution
                movea.l solvingaddr(pc),a0 ; Address of dialoge box tree
                bsr     counter         ; Turn counter value into a string
                move.l  d0,countstr     ; Stick it in the right place
                lea     aespb(pc),a1    ; Keep these addresses handy
                lea     intin(pc),a2
                move.l  a0,addrin       ; Address of tree for all calls
                move.l  #form_center,(a1)
                bsr     aes             ; Centre the dialogue box
                movem.l intout+2(pc),d0-d1 ; 8 bytes of coords
                clr.w   (a2)            ; Save screen area
                movem.l d0-d1,10(a2)    ; Coords of box
                move.l  #form_dial,(a1)
                bsr     aes
                movem.l d0-d1,-(sp)     ; Stash these for later
cont2:          clr.w   (a2)            ; Draw whole tree
                move.w  #8,2(a2)        ; 8 levels of children (max)
                move.l  #obj_draw,(a1)
                bsr     aes             ; Draw the dialogue box
                bsr     output          ; Save/print the current solution
                tst.w   d0              ; Any errors?
                beq.s   done2           ; Yes
                bsr     nextpos         ; Find next solution
                tst.w   d0              ; All solutions found?
                bne.s   done2           ; Yes
                bsr     counter         ; Generate counter string
                move.l  d0,countstr     ; Put it in box
                lea     aespb(pc),a1    ; Restore these addresses
                lea     intin(pc),a2
                bra.s   cont2           ; Round and round and round...
done2:          bsr     close           ; Close file/printer channel
                movem.l (sp)+,d0-d1     ; Retrieve box coords
                lea     aespb(pc),a1    ; These addresses again
                lea     intin(pc),a2
                move.w  #3,(a2)         ; Replace screen area
                movem.l d0-d1,10(a2)    ; Coords of box
                move.l  #form_dial,(a1)
                bsr     aes
                move.w  message+6(pc),(a2) ; Which menu was used
                move.w  #1,2(a2)        ; Restore to normal video
                move.l  menuaddr(pc),addrin ; Address of menu tree
                move.l  #menu_tnormal,(a1)
                bsr     aes
                bra     loop            ; And back to the menu

* The solve... routine
solve:          bsr     start           ; Find the first solution
                bsr     plotgrid        ; Fill in the squares
                bsr     counter         ; Get counter string
                move.l  d0,countstr     ; Put it in the box
                movea.l solveaddr(pc),a0 ; Get address of tree
                lea     aespb(pc),a1    ; Keep these handy
                lea     intin(pc),a2
                move.l  a0,addrin       ; Tree address in addrin
                move.l  #form_center,(a1)
                bsr     aes             ; Center the box
                movem.l intout+2(pc),d0-d1 ; Get the coords
                clr.w   (a2)            ; Save screen area
                movem.l d0-d1,10(a2)    ; Coords of area to save
                movem.l d0-d1,-(sp)     ; Save them for later
                move.l  #form_dial,(a1)
                bsr     aes
solvecont:      clr.w   (a2)            ; Draw object tree
                move.w  #8,2(a2)        ; Draw all levels
                move.l  #obj_draw,(a1)
                bsr     aes
                clr.w   (a2)            ; No editable text
                move.l  #form_do,(a1)
                bsr     aes             ; Wait for user to do something
                bsr     cleargrid       ; Clear the little boxes
                cmpi.w  #NEXT,intout    ; Find next solution?
                beq.s   next            ; Yes
done:           movea.l solveaddr(pc),a0 ; Address of tree
                clr.w   DONE*24+10(a0)  ; Unselect the 'Done' button
                lea     aespb(pc),a1    ; Restore these addresses
                lea     intin(pc),a2
                movem.l (sp)+,d0-d1     ; Retrieve the box coords
                move.w  #3,(a2)         ; Restore screen area
                movem.l d0-d1,10(a2)    ; Coords
                move.l  #form_dial,(a1)
                bsr     aes
                move.w  message+6(pc),(a2) ; Fix menu
                move.w  #1,2(a2)
                move.l  menuaddr(pc),addrin
                move.l  #menu_tnormal,(a1)
                bsr     aes
                bra     loop            ; Back to the menu
next:           movea.l solveaddr(pc),a0
                clr.w   NEXT*24+10(a0)  ; Unselect the 'Next' button
                bsr.s   nextpos         ; Find the next solution
                tst.w   d0              ; Have we run out of solutions
                beq.s   more            ; No
                moveq   #2,d0           ; 'No more solutions'
                bsr     alert
                bra.s   done            ; Remove dialogue box and return
more:           bsr.s   plotgrid        ; Fill in the little boxes
                bsr     counter         ; Get counter string
                move.l  d0,countstr     ; Put it where it belongs
                lea     intin(pc),a2
                lea     aespb(pc),a1
                bra     solvecont       ; Loop...

plotgrid:       moveq   #1,d1           ; Bit 0 set: selected
contgrid:       lea     grid(pc),a1     ; Table of object IDs
                lea     curpos(pc),a2   ; The solution
                movea.l solveaddr(pc),a0 ; Address of tree
                moveq   #8-1,d0         ; Loop 8 times
plotloop:       move.w  (a2)+,d2        ; Get box number
                add.w   d2,d2           ; *2
                move.w  0(a1,d2.w),d2   ; Look up object ID
                mulu    #24,d2          ; 24 bytes for each object
                move.w  d1,10(a0,d2.w)  ; Set box to selected
                lea     16(a1),a1       ; Next row of table (+16 bytes)
                dbra    d0,plotloop     ; Do it for each row
                rts
cleargrid:      moveq   #0,d1           ; Same as above but boxes get zeros
                bra.s   contgrid

* The start and nextpos routines generate solutions to the 8 queens problem
* and place them in the curpos array (1 word per row)
* This routine makes no GEM calls so it does not really concern us
nextpos:        addq.w  #1,count
                lea     curpos(pc),a0   ; Set up loop counters with
                movem.w (a0),d0-d7      ; previous values
                suba.w  a5,a5           ; Clear a5
                bra.s   r7

start:          move.w  #1,count        ; First solution
                lea     curpos(pc),a0
                suba.w  a5,a5           ; Clear a5
                moveq   #7,d0           ; 8 squares on each row
row0:           moveq   #7,d1
row1:           movea.w #1,a6           ; 2 queens on board
                bsr.s   check           ; Are they safe?
                cmpa.w  a5,a6
                beq.s   r1              ; No
                moveq   #7,d2
row2:           movea.w #2,a6           ; 3 queens on board
                bsr.s   check           ; Are they safe?
                cmpa.w  a5,a6
                beq.s   r2              ; No
                moveq   #7,d3
row3:           movea.w #3,a6           ; And so on...
                bsr.s   check
                cmpa.w  a5,a6
                beq.s   r3
                moveq   #7,d4
row4:           movea.w #4,a6
                bsr.s   check
                cmpa.w  a5,a6
                beq.s   r4
                moveq   #7,d5
row5:           movea.w #5,a6
                bsr.s   check
                cmpa.w  a5,a6
                beq.s   r5
                moveq   #7,d6
row6:           movea.w #6,a6
                bsr.s   check
                cmpa.w  a5,a6
                beq.s   r6
                moveq   #7,d7
row7:           movea.w #7,a6           ; 8 queens on board
                bsr.s   check           ; Are they all safe?
                cmpa.w  a5,a6
                beq.s   r7              ; No
                movem.w d0-d7,(a0)      ; Yes, so save their positions
                clr.w   d0
                rts                     ; And return
r7:             dbra    d7,row7
r6:             dbra    d6,row6
r5:             dbra    d5,row5
r4:             dbra    d4,row4
r3:             dbra    d3,row3
r2:             dbra    d2,row2
r1:             dbra    d1,row1
                dbra    d0,row0
                st      d0              ; Indicate that all solutions are found
                rts
* This routine checks if the queens on the board threaten each other
check:          movem.w d0-d7,-(sp)
                move.w  a6,d7
                move.w  d7,d1
                add.w   d1,d1
                move.w  0(sp,d1.w),d1
                subq.w  #1,d7
                move.w  d1,d2
                add.w   a6,d2
                move.w  d1,d0
                sub.w   a6,d0
                movea.l sp,a4
                moveq   #0,d6
chklp:          move.w  (a4)+,d4
                cmp.w   d4,d1
                beq.s   fail
                move.w  d4,d3
                add.w   d6,d3
                cmp.w   d3,d2
                beq.s   fail
                move.w  d6,d3
                sub.w   d3,d4
                cmp.w   d4,d0
                beq.s   fail
                addq.w  #1,d6
                dbra    d7,chklp
                movem.w (sp)+,d0-d7
                rts
fail:           suba.w  a6,a6
                movem.w (sp)+,d0-d7
                rts
* Here we take the vlue of the counter and convert it into a 4 byte string
* in d0 (terminated with a zero byte)
counter:        moveq   #0,d1           ; Clear d1
                move.w  count(pc),d1    ; Get counter valu
                move.l  #$2000,d0       ; The preceding space
                divu    #10,d1          ; How many tens?
                move.b  d1,d0           ; Put them in d0
                bne.s   *+4             ; If nonzero then skip next instruction
                move.b  #' '-'0',d0     ; Make byte a space
                add.b   #'0',d0         ; Convert to ASCII
                rol.l   #8,d0           ; Rotate d0 for next byte
                swap    d1              ; Get remainder from division
                move.b  d1,d0           ; Get units
                add.b   #'0',d0         ; Convert to ASCII
                rol.l   #8,d0           ; Rotate so zero byte is last
                rts

* Display the info box
about:          movea.l aboutaddr(pc),a0 ; Address of info box tree
                lea     aespb(pc),a1
                lea     intin(pc),a2
                move.l  a0,addrin       ; Place tree address in addrin
                move.l  #form_center,(a1)
                bsr     aes             ; Centre box
                movem.l intout+2(pc),d0-d1
                clr.w   (a2)
                movem.l d0-d1,10(a2)
                move.l  #form_dial,(a1)
                bsr     aes             ; Reserve screen area
                clr.w   (a2)
                move.w  #8,2(a2)
                move.l  #obj_draw,(a1)
                bsr     aes             ; Draw box
                clr.w   (a2)
                move.l  #form_do,(a1)
                bsr     aes             ; Wait for user to hit OK
                move.w  #3,(a2)
                movem.l d0-d1,10(a2)
                move.l  #form_dial,(a1)
                bsr     aes             ; Restore screen
                clr.w   ABOUTOK*24+10(a0) ; Unselect OK button
                move.w  message+6(pc),(a2) ; Fix the menu
                move.w  #1,2(a2)
                move.l  #menu_tnormal,(a1)
                move.l  menuaddr(pc),addrin
                bsr     aes
                bra     loop            ; Return to menu

* Display the options box
options:        movea.l optionaddr(pc),a0 ; Address of the object tree
                lea     aespb(pc),a1
                lea     intin(pc),a2
                move.l  a0,addrin       ; Put tree address in addrin
                move.l  #form_center,(a1)
                bsr     aes             ; Centre the box
                movem.l intout+2(pc),d0-d1
                clr.w   (a2)
                movem.l d0-d1,10(a2)
                move.l  #form_dial,(a1)
                bsr     aes             ; Save the screen area
                clr.w   (a2)
                move.w  #8,2(a2)
                move.l  #obj_draw,(a1)
                bsr     aes             ; Draw the box
                move.w  #NAME,(a2)      ; ID of editable text object
                move.l  #form_do,(a1)
                bsr     aes             ; Do the dialogue box...
                move.w  intout(pc),d2   ; Save the exiting button
                move.w  #3,(a2)         ; Restore the screen
                movem.l d0-d1,10(a2)
                move.l  #form_dial,(a1)
                bsr     aes
                lea     printeropt(pc),a3 ; Address of the variables in memory
                cmp.w   #OPTCAN,d2      ; Was cancel selected
                beq.s   cancel          ; Yes
                move.w  FILE*24+10(a0),(a3)+ ; Save new options
                move.w  SERIAL*24+10(a0),(a3)+
                movea.l NAME*24+12(a0),a3 ; Get address of the editable
                movea.l (a3),a3         ; text string
                lea     filename(pc),a4
copyloop2:      move.b  (a3)+,(a4)+     ; And copy it to our file name
                bne.s   copyloop2       ; Until zero byte
                clr.w   OPTOK*24+10(a0) ; Unselect OK button
                bra.s   optdone         ; Tidy up and return
* The cancel routine must return the dialogue box to its original state
cancel:         moveq   #1,d0           ; Bit 0 set (selected)
                tst.w   (a3)            ; Printer or file?
                beq.s   printer
                clr.w   PRINTER*24+10(a0) ; Clear printer button
                move.w  d0,FILE*24+10(a0) ; Set file button
                bra.s   prndone
printer:        clr.w   FILE*24+10(a0)  ; Clear file button
                move.w  d0,PRINTER*24+10(a0) ; Set printer button
prndone:        tst.w   2(a3)
                beq.s   parallel
                clr.w   PARALLEL*24+10(a0) ; Same for the printer port
                move.w  d0,SERIAL*24+10(a0)
                bra.s   prndone2
parallel:       clr.w   SERIAL*24+10(a0)
                move.w  d0,PARALLEL*24+10(a0)
prndone2:       movea.l NAME*24+12(a0),a3 ; Get address of editable text
                movea.l (a3),a3
                lea     filename(pc),a4
copyloop:       move.b  (a4)+,(a3)+     ; Copy back old filename
                bne.s   copyloop
                clr.w   OPTCAN*24+10(a0)
optdone:        move.w  message+6(pc),(a2) ; Fix menu
                move.w  #1,2(a2)
                move.l  menuaddr(pc),addrin
                move.l  #menu_tnormal,(a1)
                bsr     aes
                bra     loop

* Open a file or printer channel depending on options
open:           movem.w printeropt(pc),d0-d1
                tst.w   d0
                bne.s   file
                tst.w   d1
                beq.s   par
                moveq   #-1,d0          ; Configure RS-232 port for printer
                move.l  d0,-(sp)
                move.l  d0,-(sp)
                moveq   #1,d0
                move.w  d1,-(sp)        ; 9600 baud
                move.w  d1,-(sp)        ; XON/XOFF
                move.w  #15,-(sp)
                trap    #14
                lea     14(sp),sp
                move.w  #2,-(sp)        ; Get a file handle for the RS-232 port
                move.w  #$45,-(sp)
                trap    #1
                addq.l  #4,sp
                move.w  d0,handle       ; Did we get a valid handle?
                bmi.s   outputfail      ; No
                rts
par:            move.w  #3,-(sp)        ; Get a handle for the parallel port
                move.w  #$45,-(sp)
                trap    #1
                addq.l  #4,sp
                move.w  d0,handle       ; Error?
                bmi.s   *+2             ; Yes, skip next instruction (2 bytes)
                rts
outputfail:     moveq   #3,d0           ; 'Could not open file'
                bsr     alert
                moveq   #-1,d0
                rts
file:           clr.w   -(sp)           ; Create file with our filename
                pea     filename(pc)
                move.w  #$3C,-(sp)
                trap    #1
                addq.l  #8,sp
                move.w  d0,handle
                bmi.s   outputfail      ; Error?
                rts

* This routine generates an ASCII grid showing the positions of the
* queens and sends it to the output device
output:         bsr     counter         ; Get counter string
                move.b  #$0D,d0         ; Replace end 0 with a $d
                move.l  d0,countout     ; Put it in the output buffer
                lea     curpos(pc),a0
                lea     gridout(pc),a1
                moveq   #8-1,d0
                moveq   #'Q',d2         ; Place 'Q's on the grid
outloop:        move.w  (a0)+,d1
                add.w   d1,d1
                move.b  d2,1(a1,d1.w)
                lea     18(a1),a1
                dbra    d0,outloop
                pea     outbuf(pc)      ; Send the output buffer
                move.l  #165,-(sp)      ; 165 bytes
                move.w  handle(pc),-(sp)
                move.w  #$40,-(sp)
                trap    #1              ; Fwrite
                lea     12(sp),sp
                tst.w   d0              ; Error?
                bmi.s   error
                lea     curpos(pc),a0
                lea     gridout(pc),a1
                moveq   #8-1,d0
                moveq   #'.',d2         ; Replace 'Q's with dots
outloop2:       move.w  (a0)+,d1
                add.w   d1,d1
                move.b  d2,1(a1,d1.w)
                lea     18(a1),a1
                dbra    d0,outloop2
                rts
error:          moveq   #4,d0           ; 'An error occured during output'
                bsr     alert
                moveq   #0,d0
                rts
* Finally close the file/printer channel
close:          move.w  handle(pc),-(sp)
                move.w  #$3E,-(sp)
                trap    #1
                addq.l  #4,sp
                rts


* The initialisation routines
initialise:     lea     aespb(pc),a0
                move.l  #appl_init,(a0)
                bsr     aes             ; The appl_init call
                move.l  #rsc_file,addrin ; Address of filename
                move.l  #rsc_load,(a0)
                bsr     aes             ; Load the resource file
                tst.w   intout          ; File loaded?
                bne.s   rsc_ok          ; Yes
                moveq   #0,d0           ; 'Could not load RSC file'
                bsr     alert
                bra.s   quit            ; Can't live without it
rsc_ok:         lea     menuaddr(pc),a2 ; Storage space for tree addresses
                lea     intin(pc),a1
                lea     addrout(pc),a3
                clr.w   (a1)
                move.l  #rsc_gaddr,(a0)
                moveq   #0,d0
                move.w  #5-1,d1
gaddrlp:        move.w  d0,2(a1)
                bsr     aes             ; Get address of each tree
                move.l  (a3),(a2)+      ; And save it for later
                addq.w  #1,d0           ; Next tree ID
                dbra    d1,gaddrlp
                move.w  #1,(a1)         ; Display the menu bar
                move.l  menuaddr(pc),addrin
                move.l  #menu_bar,(a0)
                bsr.s   aes
                movea.l optionaddr(pc),a2
                moveq   #1,d0
                move.w  d0,PRINTER*24+10(a2) ; Set the initial options
                move.w  d0,PARALLEL*24+10(a2)
                movea.l NAME*24+12(a2),a2
                movea.l (a2),a2
                clr.b   (a2)            ; Zero first byte of editable text
                lea     countstr(pc),a3
                movea.l solveaddr(pc),a2
                move.l  a3,TOTAL*24+12(a2) ; Redirect these objects to use
                movea.l solvingaddr(pc),a2 ; Our own counter string
                move.l  a3,SOFAR*24+12(a2)
                clr.w   (a1)
                move.l  #graf_mouse,(a0) ; Change mouse from 'busy bee'
                bsr.s   aes             ; to 'Percy pointer'
                rts

* Quit cleanly
quit:           move.l  #appl_exit,aespb ; Tell aes we're leaving
                bsr.s   aes
                clr.w   -(sp)
                trap    #1              ; Goodbye cruel world

* Alert box subroutine
alert:          lsl.w   #2,d0           ; *4
                movea.l alerttab(pc,d0.w),a6 ; Get address of slert string
                move.w  (a6)+,intin     ; Default button
                move.l  a6,addrin       ; String
                move.l  #form_alert,aespb
                bsr.s   aes             ; Display alert box
                move.w  intout(pc),d0   ; Selected button
                rts


* The AES call routine
aes:            movem.l d0-a6,-(sp)
                lea     aespb(pc),a0
                move.l  a0,d1
                move.l  #$C8,d0
                trap    #2
                movem.l (sp)+,d0-a6
                rts

                DATA
alerttab:       DC.L al_norsc,al_quit,al_done,al_output,al_output2

* Data for all the AES calls used
appl_init:      DC.W 10,0,1,0,0
appl_exit:      DC.W 19,0,1,0,0
evnt_mesag:     DC.W 23,0,1,1,0
menu_bar:       DC.W 30,1,1,1,0
menu_tnormal:   DC.W 33,2,1,1,0
obj_draw:       DC.W 42,6,1,1,0
form_do:        DC.W 50,1,2,1,0
form_dial:      DC.W 51,9,1,0,0
form_alert:     DC.W 52,1,1,1,0
form_center:    DC.W 54,0,5,1,0
graf_mouse:     DC.W 78,1,1,1,0
rsc_load:       DC.W 110,0,1,1,0
rsc_gaddr:      DC.W 112,2,1,0,1

aespb:          DC.L contrl,global,intin,intout,addrin,addrout

rsc_file:       DC.B 'queens.rsc',0
                EVEN
countstr:       DC.B '  0',0

al_norsc:       DC.W 1
                DC.B '[1][| Cannot find resource file ][ Quit ]',0
                EVEN
al_quit:        DC.W 1
                DC.B '[2][| Do you really want to quit? ][ Yes | No ]',0
                EVEN
al_done:        DC.W 1
                DC.B '[3][| No more solutions! ][ Done! ]',0
                EVEN
al_output:      DC.W 1
                DC.B '[1][| Error opening output file |    or device][ Abort 
]',0
                EVEN
al_output2:     DC.W 1
                DC.B '[1][| Error sending output ][ Abort ]',0
                EVEN

grid:           DC.W Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18
                DC.W Q21,Q22,Q23,Q24,Q25,Q26,Q27,Q28
                DC.W Q31,Q32,Q33,Q34,Q35,Q36,Q37,Q38
                DC.W Q41,Q42,Q43,Q44,Q45,Q46,Q47,Q48
                DC.W Q51,Q52,Q53,Q54,Q55,Q56,Q57,Q58
                DC.W Q61,Q62,Q63,Q64,Q65,Q66,Q67,Q68
                DC.W Q71,Q72,Q73,Q74,Q75,Q76,Q77,Q78
                DC.W Q81,Q82,Q83,Q84,Q85,Q86,Q87,Q88

outbuf:         DC.B 'Solution number '
countout:       DC.B '  0',$0D,$0A
gridout:        DC.B ' . . . . . . . .',$0D,$0A
                DC.B ' . . . . . . . .',$0D,$0A
                DC.B ' . . . . . . . .',$0D,$0A
                DC.B ' . . . . . . . .',$0D,$0A
                DC.B ' . . . . . . . .',$0D,$0A
                DC.B ' . . . . . . . .',$0D,$0A
                DC.B ' . . . . . . . .',$0D,$0A
                DC.B ' . . . . . . . .',$0D,$0A

                BSS
curpos:         DS.W 8
count:          DS.W 1
countaddr:      DS.L 1

menuaddr:       DS.L 1
aboutaddr:      DS.L 1
optionaddr:     DS.L 1
solveaddr:      DS.L 1
solvingaddr:    DS.L 1

printeropt:     DS.W 2
filename:       DS.B 64
handle:         DS.W 1

message:        DS.W 8
contrl:         DS.W 12
global:         DS.W 16
intin:          DS.W 128
intout:         DS.W 128
addrin:         DS.W 128
addrout:        DS.W 128

                DS.B 1024
stack:
                END
