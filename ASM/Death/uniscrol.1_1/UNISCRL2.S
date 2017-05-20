*******************************************************************************
**                         UNIVERSAL-SCROLL-ROUTINE                          **
**                      ------------------------------                       **
**                     Coded by TPD of Death on 11.02.91                     **
**                     Last changes: 15.5.91
*******************************************************************************
** Contact us:  DEATH, Postfach 73,6370 Stans, Switzerland                   **
*******************************************************************************
line            EQU 100         * Here you can set the upper line, in which
*                               * the scroll shall begin

                pea     init            * Execute a Supervisor
                move.w  #$26,-(SP)      * routine
                trap    #14
                addq.l  #6,SP

                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP

ende:           pea     exit
                move.w  #$26,-(SP)      * routine
                trap    #14
                addq.l  #6,SP


                clr.w   -(SP)           * Terminate
                trap    #1
***********************************************************************************
***********************************************************************************
scrolling:
                movem.l D0-A6,-(SP)

                move.l  logram,D0       * change logical and
                move.l  vidram,logram   * physical videoram
                move.l  D0,vidram       *
                move.l  D0,$045E        *
*****************************************
* Verschieben um 16 Pixel               *
*****************************************
                move.w  heigth(PC),D0   * Heigth of the Scroller
                movea.l logram,A6       * Write to the invisible Videoram
                lea     160*line(A6),A6
moveloop:
                movem.l 8(A6),D1-A5     * Get data
                movem.l D1-A5,(A6)      * write Data

                movem.l 60(A6),D1-A5
                movem.l D1-A5,52(A6)

                movem.l 112(A6),D1-A5
                movem.l D1-A5,104(A6)

                lea     156(A6),A6      * Set A6
                move.l  8(A6),(A6)+     * onto next line

                dbra    D0,moveloop


                movea.l char_1(PC),A0
                adda.w  width_counter(PC),A0 *
*****************************************
* shifting                              *
*****************************************
                move.w  width(PC),D7
                addq.w  #1,D7           * Add 1 for upper byte
                movea.l logram,A1
                lea     160*line(A1),A1
                move.w  heigth(PC),D0

                not.w   n_ev_count      * It either starts the first
                tst.w   n_ev_count      * or the second shifting-routine.
                beq.s   not_even        * Depends from the position of the scroller
even:
shift_loop_even:
                move.w  (A0),152(A1)    * Insert new data
                move.w  2(A0),154(A1)
                move.w  4(A0),156(A1)
                move.w  6(A0),158(A1)

                adda.w  D7,A0           * offset to next word of used data

                lea     160(A1),A1      * Set onto next line

                dbra    D0,shift_loop_even

                bra.s   end_shift       * Don't execute the other Shift-rout
***********************************************
not_even:
                addq.w  #8,width_counter * Add
                lea     8(A0),A3


                cmp.w   width_counter(PC),D7 * Is offset > width of char+1  ???
                bgt.s   not_end_of_the_char
                movea.l char_2(PC),A3   * Adress of new char if at the end
not_end_of_the_char:
shift_loop_not_even:
                move.b  1(A0),152(A1)   * insert new data at the right border
                move.b  3(A0),154(A1)
                move.b  5(A0),156(A1)
                move.b  7(A0),158(A1)

                move.b  (A3),153(A1)
                move.b  2(A3),155(A1)
                move.b  4(A3),157(A1)
                move.b  6(A3),159(A1)

                adda.w  D7,A0           * offset to next word of used data
                adda.w  D7,A3

                lea     160(A1),A1      * Next line
                dbra    D0,shift_loop_not_even


*****************************************
end_shift:

                move.w  width(PC),D7
                cmp.w   width_counter(PC),D7

                bge.s   no_inc          * Is the End of the character reached

                move.w  #0,width_counter * Clear width-counter
                addq.w  #1,char_counter * Add 1 to the Char-counter

                bsr.s   get_2_chars     * Get the next character

no_inc:                                 * No increment
no_move:
                movem.l (SP)+,D0-A6
                rts
************************************************
* Neues Zeichen zum Einshiften lesen
************************************************
get_2_chars:    move.l  char_2(PC),char_1
                lea     stext(PC),A0    * Get character
                adda.w  char_counter(PC),A0
                move.b  (A0),D0
                cmpi.b  #0,D0           * Is it the end of the text ???

                bne.s   not_the_end_of_the_scro

                move.w  #-1,char_counter * clear Char-counter
                clr.w   width_counter   * clear Width-counter
                rts                     * Restart everything

not_the_end_of_the_scro:
                moveq   #0,D0           * get next char
                move.b  (A0)+,D0        * out of the text

******* new data=font+(ASC("CHAR")-32)*(width+1)*heigth+1)

                sub.w   #32,D0          * Get the beginning of the
                move.w  width(PC),D1    * Char in the Font
                addq.w  #1,D1
                mulu    D1,D0           *
                move.w  heigth(PC),D1
                add.w   #1,D1
                mulu    D1,D0
                lea     font+42(PC),A0
                adda.l  D0,A0
                move.l  A0,char_2
                rts
************************************************************************
************************************************************************
init:
                move.l  #puffers+256,D0 * reserved memory of the Videoram
                clr.b   D0              * Clear low byte
*                                       * = andi.w #$FFFFFF00,d0
                move.l  D0,logram
                add.l   #200*160,D0
                move.l  D0,vidram

                lea     font(PC),A0     * Get information about font
                cmpi.l  #"F32+",(A0)+   * Is it a DEATH-Font ?????

                bne     ende            * No it isn't !!!!!!!!!!!!!!!

                move.w  (A0)+,heigth    * Get heigth of scroller
                move.w  (A0)+,width     * Get width of one char
                move.w  (A0)+,anz_planes * get amount of planes (Not used up to now)

                movem.l $FFFF8240.w,D0-D7 * save colors
                movem.l D0-D7,oldpal

                movem.l (A0)+,D0-D7     * Get colors
                movem.l D0-D7,$FF8240   * Set colors

                move.l  #scrolling,$04DA.w * Set the VBL-interrupt

                rts
************************************************************************
do_text:


                rts
************************************************************************
exit:
                move.l  #0,$04DA.w      * erase VBL-routine

                movem.l oldpal(PC),D0-D7 * restore colors
                movem.l D0-D7,$FFFF8240.w
                rts

************************************************************************
oldpal:         DS.W 16
stext:          DC.B "HELLO DEAR DEMOFREAK !!!!!! LET US TRY ALL CHARS:"
                DC.B 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51
                DC.B 52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71
                DC.B 72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90
                DC.B "                         "
                DC.B 0
stextend:       EVEN
char_1:         DC.L font+42
char_2:         DC.L font+42
n_ev_count:     DC.W 0
char_counter:   DC.W -1
width_counter:  DC.W 0
heigth:         DC.W 0
width:          DC.W 0
anz_planes:     DC.W 0
font:           INCBIN 'GOLD.F40'
vidram:         DC.L 0
logram:         DC.L 0

                BSS
puffers:        DS.B 160*200*2
                END
