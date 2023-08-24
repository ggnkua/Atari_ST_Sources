*****************************************************************************
**************** Blipblop-Part of Chronicle Musics Demo *********************
********************** 18 Pieces of cool musaxxs ****************************
******* Ripped by M.C. (the fuckin' best Musaxxs Ripper (Penguin)) **********
*****************************************************************************

                clr.l   -(SP)
                move.w  #32,-(SP)
                trap    #1
                addq.l  #6,SP

                lea     SONG(PC),A6
                bsr     PLAYER
                move.l  A6,PLAY_ADR

                movea.w #$8240,A6
                clr.w   (A6)
                clr.l   2(A6)

                pea     DASISSES(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                move.l  #$07770777,4(A6)
                move.l  $70,old_vbl
                move.l  #VBL,$70.w

W:              cmpi.b  #$39,$FFFFFC02.w
                bne.s   W

                move.l  old_vbl,$70.w

                move   #$8800,a0
	      move.l #$08000000,(a0)
	      move.l #$09000000,(a0)
	      move.l #$0a000000,(a0)
 
                clr.l   -(SP)
                trap    #1

VBL:            movem.l D0-A6,-(SP)
                movea.l PLAY_ADR(PC),A0
                jsr     (A0)
                movem.l (SP)+,D0-A6
                rte

                DATA

old_vbl:        DC.L 1

DASISSES:       DC.B 27,"E"
                DC.B 10,13,10,13,10,13,10,13,10,13,10,13
                DC.B "   Here is the list of which file belongs to which Songname ",10,13
                DC.B "---------------------------------------------------------------------------",10,13
                DC.B 10,13
                DC.B "     SONG1       -----     ENIGMA FORCE ",10,13
                DC.B "     SONG2       -----     TOUGH GUYS IN SWEDEN ",10,13
                DC.B "     SONG3       -----     FUCK WHATTA BIG RAT ",10,13
                DC.B "     SONG4       -----     THE VILLAGE ",10,13
                DC.B "     SONG5       -----     WALKMAN ",10,13
                DC.B "     SONG6       -----     NINJA SPIRIT ",10,13
                DC.B "     SONG7       -----     CHINESE HEROES ",10,13
                DC.B "     SONG8       -----     DETONATION ",10,13
                DC.B "     SONG9       -----     PARTY MUZ ",10,13
                DC.B "     SONG10      -----     JAPAN ",10,13
                DC.B "     SONG11      -----     KRUZ THEME ",10,13
                DC.B "     SONG12      -----     WHATTA NERD ",10,13
                DC.B "     SONG13      -----     NINJA ",10,13
                DC.B "     SONG14      -----     MY MASTER ",10,13
                DC.B "  *  SONG15      -----     XTREAM DENTRO MUSIC ",10,13
                DC.B "     SONG16      -----     PLAZMA ",10,13
                DC.B "     SONG17      -----     RINGS OF MEDUSA MIX ",10,13
                DC.B "     SONG18      -----     STREET KIDS ",10,13
                DC.B "* used already",10,13
                DC.B "----------------------------------------------------------------------------",10,13
                DC.B " THESE TUNES WERE RIPPED BY M.C. OF ANIMAL MINE ON THE 18TH OF SEPTEMBER '92 ",0
                EVEN
PLAY_ADR:       DS.L 1
                EVEN
PLAYER:         INCBIN 'BLIPBLOP.ROT'
                EVEN
SONG:           INCBIN 'SONG18'
                END

