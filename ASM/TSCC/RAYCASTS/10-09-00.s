*****************************************************
* wolf3d beta - engine            10-09-00 rev 0.01 *
*                                                   *
* coded by ray                                      *
*****************************************************
* so guys, here you are.                            *
* it's pretty slow but it runs. i hope to get the   *
* time to optimize it the next weeks...thinking of  *
* doing some chunk 2 planar graphics code           *
* by now it's really crappy and i had to cheat alot *
* cause somehow the engine fucks up at certain      *
* angles.                                           *
* and don't even get the idea that this stuff is    *
* bugfixed or anything.it's just a beta, ok ?       *
* so keep looking further revs.                     *
*****************************************************
* send stuff to           reimund.dratwa@freenet.de *
* and don't forget to visit                         *
*                      http://rd-developments.de.gs *
* see ya                                            *
*****************************************************

                OPT F+

* set up some constants...

FINEANGLES      EQU 1920
DEG90           EQU 480
DEG180          EQU 960
DEG270          EQU 1440
DEG360          EQU 1920

ROUNDCONST      EQU $7FFF       * 0.5 - for fixedpoint roundings




                TEXT
                clr.l   -(SP)           * enter supervisor-mode
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,OLD_STACK    * don't forget :)

                move.l  $044E,PHYBASE   * save some stuff...
                moveq   #0,D0
                move.b  $FFFF8260,D0
                move.w  D0,REZ

                lea     SYSPAL,A0
                lea     $FFFF8240,A1
                moveq   #16-1,D0
SAVEPAL:        move.w  (A1)+,(A0)+
                dbra    D0,SAVEPAL


                move.l  #SCRNSPACE,D0   * screenspace into D0
                move.b  #$00,D0         * align to 256
                move.l  D0,DBLBUFFER
		add.l   #32000,D0       * skip to the next screen
		move.l  D0,ACTIVE     

                move.b  #0,$FFFF8260    * low rez

                lsr.l   #8,D0           * set new phybase
                move.b  D0,$FFFF8203.w
                lsr.l   #8,D0
                move.b  D0,$FFFF8201.w

                lea     PALETTE,A0      * set the new palette
                lea     $FFFF8240,A1
                moveq   #16-1,D0
SETPAL:         move.w  (A0)+,(A1)+
                dbra    D0,SETPAL



* here comes the interesting part...

                move.w  #DEG180,D2      * set up a viewangle
TURNPLAYER:

                cmp.w   #DEG360,D2      * keep angle between
                blt     KEEPANGLE       * 0..360 degrees
                sub.w   #DEG360,D2

KEEPANGLE:      move.w  #160-1,D7       * doing 160 screen-
                move.w  D2,D4           * columns

RENDERVIEW:     move.l  #416,D0         * set up some player-
                move.l  #752,D1         * coords

                movem.l D0-D7,-(SP)     * now push important stuff

                cmp.w   #DEG90,D2       * at these angles
                beq.s   NOHIT           * we won't hit a wall
                cmp.w   #DEG270,D2      * since we're just looking
                beq.s   NOHIT           * for x-walls by now


                bsr     initvars        * now start intersection-
*                                         testing
*
* that's what raycaster returns:
*   D0 : xtile
*   D1 : xtile - texturesliver
*   D2 : vertXhit
*   D3 : vertYhit

                tst.w   D0              * did the Raycaster hit a wall
                beq     NOHIT           * no, then do next wallsliver

* now calculate the distance to wallsliver using pythagoras

                sub.w   2(SP),D2        * vertXhit - PlayerX
                sub.w   6(SP),D3        * vertYhit - PlayerY

                muls    D2,D2           * sqr(D2)
                muls    D3,D3           * sqr(D3)

                add.l   D2,D3
                move.l  D3,D7

                bsr     SQRT            * extract the squareroot (hyp=distance)

* D7 now holds the distance to the next wallsliver

* and now map em...
                move.w  D7,D3           * distance
                move.w  D0,D2           * xtile
                move.w  30(SP),D0       * screencolumn
                add.w   #80,D0          * center it horizontally

                bsr     texturemap

NOHIT:
                movem.l (SP)+,D0-D7     * pop some things
                addq.w  #2,D2           * inc rayangle by TWO (doublepixels !)
                subq.w  #1,D7           * next screencolumn


                cmp.w   #DEG360,D2      * same as above
                blt.s   NEXTSLICE
                sub.w   #DEG360,D2

NEXTSLICE:      dbra    D7,RENDERVIEW   * do next wallsliver

                move.w  D4,D2           * get angle back into D2


                move.l  ACTIVE,A0	* swap the two screens
		move.l  DBLBUFFER,ACTIVE
		move.l  A0,DBLBUFFER

                move.l  ACTIVE,D0	* set the address of the
		lsr.w   #8,D0           * new active screen
		move.l  D0,$FFFF8200

                move.w  #7999,D7        * clear the hidden screen
                movea.l DBLBUFFER,A0
CLRSCR:         clr.l   (A0)+
                dbra    D7,CLRSCR

                add.w   #33,D2          * increment angle by 32 (D2 gets decrementet by
*                                         dbra again so 33) that turns the player

                move.b  $0FFFFC02,D0	
                cmpi.b  #$39,D0         * someone pressed space
                dbeq    D2,TURNPLAYER   * no then keep going






                move.l  OLD_STACK,-(SP) * switch back into user-mode
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                move.w  REZ,-(SP)       * restore the old screen properties
                move.l  PHYBASE,-(SP)
                move.l  #-1,-(SP)       * keep LOGBASE
                move.w  #5,-(SP)
                trap    #14
                lea     12(SP),SP

                pea     SYSPAL          * restore palette
                move.w  #6,-(SP)
                trap    #14
                addq.l  #6,SP

                clr.w   -(SP)           * ...and go back to the desktop
                trap    #1






**********************************************************
* the following procedures actually do the 3D stuff      *
*                                                        *
* is't just a standartd raycasting-algo like the one	 *
* used for wolf3d                                        *
* at the moment it only scanns through the map looking   *
* for 'vertical' walls.                                  *
* and it's also one of the slowest parts (doing planar-  *
* graphics, 32bit raycasting etc.)                       *
* so that's the part which has to be optimized and maybe *
* i'll even replace the whole stuff whith a simple 16bit *
* raycaster like the one of 'destruction imminent'       *
* (don't be afraid, i'll use my own texturemapper so     *
* don't be scared of getting that crappy line-graphics   *
* of destruction imminent, which does no real texture-   *
* mapping. belive me i've seen the source)               *
* if you're interested in raycasting-routs, though just  *
* send some feedback. then maybe i'll sometime write a   *
* tutorial about raycasting (raycasting is really quite  *
* simple  ;)  )                                          *
**********************************************************





*--------------------------------------------------------
*
* texturemap - scales a wall sliver to
*              a certain height
*
*  D0 : xposition on screen
*  D1 : texture-column
*  D2 : number of wall
*  D3 : distance to player
*
*--------------------------------------------------------

texturemap:     movea.l DBLBUFFER,A1    * address of inactive-screen
                lea     WALLS,A2        * address of walls
                lea     PUTPIXTABLE,A3  * address of '160x200.tbl'
                lea     HEIGHTTABLE,A0  * get height (D3) of the wallsliver


                add.w   D3,D3
                move.w  0(A0,D3.w),D3   * based on its distance
                move.l  #16384,D4       * calc the y-step (D4) in texture
                divu    D3,D4           * y-step = 64 / height (8.8 fp)
                move.w  #100,D5         * calculate the y-startpoint (D5)
                move.w  D3,D6           * on the screen
                lsr.w   #1,D6
                sub.w   D6,D5           * startpoint = horizon - height/2
                moveq   #0,D6           * texture-y (D6) = 0

*       d3 : height
*       d4 : texture-y-step in 8.8 fixedpoint
*       d5 : y-startpoint on screen
*       d6 : texture-y-pos  in 8.8 fixedpoint
*
*       a1 : address of Wall-textures
*       a2 : address of the SCRNSPACE-screen

                cmp.w   #0,D5
                bge     StartpointOK

*                       clip 'em

                moveq   #0,D5           * y-startpoint = 0
                lsr.w   #1,D3           * height / 2
                sub.w   #100,D3         * height / 2 - horizon
                move.w  D4,D6
                mulu    D3,D6           * texture-y-pos=(height/2-horizon)*y-step
                move.w  #200,D3         * set to max. height = 200

StartpointOK:   lsl.w   #6,D2           * calculate offset in wall-array...
                lsl.w   #6,D2
                lsl.w   #6,D1
                add.w   D2,D1
                subq.w  #1,D3           * dbra-loop counts downto -1 !
                mulu    #160,D5         * calculate offset in video-ram...
* (every scanline has 80 words)
                andi.b  #$FE,D0         * make d0 even
                move.w  D0,D7
                lsr.w   #1,D7           * bitplane 0
                and.b   #$F8,D7         * d3 = d0 div 16 * 8
                move.w  D7,-(SP)        * push result
                andi.w  #$0F,D0         * keep ScreenX between 0..15
                add.w   D0,D0
                add.w   D0,D0

MapTextureStrip:move.w  D6,D7
                add.w   #$7F,D7
                lsr.w   #8,D7
                add.w   D1,D7
                move.b  0(A2,D7.w),D7   * color to draw on the screen
                movem.w D0/D3,-(SP)
                move.w  4(SP),D3        * pop bitplane-offset
                add.w   D5,D3           * get right scanline
                andi.w  #$0F,D7
                lsl.w   #6,D7
                add.w   D0,D7
                move.l  0(A3,D7.w),D0   * set the pixel
                or.l    D0,0(A1,D3.w)
                move.l  4(A3,D7.w),D0
                or.l    D0,4(A1,D3.w)
                movem.w (SP)+,D0/D3
                add.w   #160,D5         * go down one scanline
                add.w   D4,D6           * go one down "y-step times" in texture
                dbra    D3,MapTextureStrip * next pixel...
                addq.w  #2,SP
                rts



*------------------------------------------------------
*
* this one calcs the squareroot of a longinteger.
* it's used to calculate the distance between the
* player and a wallsliver using pythagoras.
*
* in- & output in D7
*
*------------------------------------------------------

SQRT:
                movem.l D1-D3,-(SP)
                move.l  #$40000000,D2

root_loop:
                move.l  D1,D3
                add.l   D2,D3

                lsr.l   #1,D1
                cmp.l   D3,D7
                ble.s   boing
                sub.l   D3,D7
                or.l    D2,D1

boing:
                lsr.l   #2,D2
                bne.s   root_loop

                cmp.l   D1,D7
                blt.s   no_round_up
                addq.l  #1,D1

no_round_up:
                move.l  D1,D7
                movem.l (SP)+,D1-D3
                rts







*---------------------------------------------------------------------------
* wolf3d raycaster  -  ported to ATARI ST / M68000 by ray        09-05-2000
*---------------------------------------------------------------------------



*---------------------------------------------------------------------------
*
* initialise variables for intersection testing
*
*---------------------------------------------------------------------------
* D0 : PlayerX
* D1 : PlayerY
* D2 : Rayangle


initvars:       lea     YNEXTTAB,A5
                lea     TANGENTS,A6
                clr.w   -(SP)           * lookingright := false
*  (sp) points to lookingright
                move.w  D0,D3           * D3 : Xbeg
                andi.w  #$FFC0,D3       * Xbeg := x and $FFC0 (align to 64)
                move.w  D2,D4

                add.w   D4,D4           * D4 * 4
                add.w   D4,D4
                move.l  0(A5,D4.w),D4
                cmp.w   #DEG270,D2      * looking to right ?
                bgt.s   lookingright
                cmp.w   #DEG90,D2       * looking to right ?
                blt.s   lookingright
                bra.s   notlookingright
lookingright:   addq.w  #1,(SP)         * lookingright := true
notlookingright:tst.w   (SP)            * looking to right ?
                beq.s   XposEQUXbeg
                add.w   #64,D3          * D3 is now Xpos !!
                move.w  #64,D5          * D5 : Xnext
                bra.s   EndXposBlock
XposEQUXbeg:                            * else...
*                                         don't change D3 , D3 is now Xnext !
                move.w  #-64,D5         * D5 : Xnext
                neg.l   D4              * Ynext := -Ynext
EndXposBlock:   swap    D1              * PlayerY := fixedpoint(PlayerY)
                clr.w   D1              * quicker than "asl.l #16,D1 !
                cmp.w   #0,D2
                beq.s   YposEQUY
                cmp.w   #DEG180,D2
                beq.s   YposEQUY
                bra.s   CalcYpos
YposEQUY:       move.w  D1,D6
                bra.s   EnyYposBlock
CalcYpos:       move.w  D2,D7
                add.w   D7,D7           * D7 * 4
                add.w   D7,D7
                move.l  0(A6,D7.w),-(SP) * get Tangens
                move.w  D3,D6
                sub.w   D0,D6           * D6 := Xpos - PlayerX
                move.w  D6,D2
                muls    (SP),D6         * higher fraction
                muls    2(SP),D2        * lower  fraction
                swap    D6
                clr.w   D6
                add.l   D2,D6
                add.l   D1,D6           * D6.l := (Xpos - PlayerX) * fineTan[angle] + PlayerY
                addq.w  #4,SP
EnyYposBlock:
* keep ray inside map....
                tst.l   D6              * Ypos outside map ?
                bgt.s   YposGt0
                moveq   #0,D6
YposGt0:        cmp.l   #$0FFFF000,D6   * Ypos outside map ?
                blt.s   YposLt4096
                move.l  #$0FFFF000,D6
YposLt4096:

* that's it
*
* D3  : Xpos
* D5  : Xnext  (64*-64)
* D6.l: Ypos   16.16 fixedpoint
* D4.l: Ynext    "     "     "



*---------------------------------------------------------------------------
*
* trace along this angle until we hit a wall
*
* CORE LOOP!
*
* All variables are killed when a wall is hit
*
* D0 : number of xtile - clear if no vertical wall was hit
* D1 : xtile - texturesliver
* D2 : vertXhit
* D3 : vertYhit
* D4 : number of ytile - clear if no horizontal wall was hit
* D5 : ytile - texturesliver
* D6 : horizXhit
* D7 : horizYhit
*
*---------------------------------------------------------------------------

vertcheck:      move.w  D3,D0
                lsr.w   #6,D0           * XmapPos (D0) := Xpos DIV 64

                tst.w   (SP)            * looking to the right ?
                beq     dontincXmap
                addq.w  #1,D0           * inc(XmapPos)
dontincXmap:
                move.l  D6,D1
                add.l   #ROUNDCONST,D1
                clr.w   D1
                swap    D1              * RoundYpos (D1) := (YPos + $7FFF [0.5 fp]) shr 16

                move.w  D1,D2
                lsr.w   #6,D2
                addq.w  #1,D2           * YmapPos (D2) := RoundYpos DIV 64 + 1

                lea     WORLDMAP,A4
                move.w  D0,D7           * calculate the offset in world-data
                lsl.w   #6,D7
                add.w   D2,D7
                move.b  0(A4,D7.w),D7   * D7 := ytile

                tst.b   D7              * did we hit a vertical wall ?
                bne     hitvert         * yes, then exit trace loop

                add.w   D5,D3           * no, then go on tracing
                add.l   D4,D6           * Xpos += Xnext , Ypos += Ynext

                tst.w   D3              * Xpos < 0 ?
                blt     exittraceloop   * yes, then stop tracing
                cmp.w   #4096,D3        * Xpos > 4096 ?
                bgt     exittraceloop   * yes, then stop tracing

                tst.l   D6              * Ypos < 0 ?
                blt     exittraceloop   * yes, then stop tracing
                cmp.l   #$0FFFF000,D3   * Ypos > 4096 [fp] ?
                bgt     exittraceloop   * yes, then stop tracing

                bra     vertcheck       * one more trace-loop

hitvert:        clr.w   D0              * make sure that high-byte is clear
                move.b  D7,D0           * D0 : xtile    = WORLDMAP [xmap,ymap]
                move.w  D3,D2           * D2 : vertXhit = Xpos
                move.w  D1,D3           * D3 : vertYhit = RoundYpos
                move.w  D3,D7
                and.w   #63,D7
                move.w  D7,D1

                bra.s   donevert

exittraceloop:  clr.w   D0              * xtile (D0) := 0 - we haven´t hit a wall

donevert:
                addq.w  #2,SP           * correct stackpointer
                rts



**********************************************
*                DATA STUFF                  *
**********************************************


                EVEN
YNEXTTAB:       IBYTES 'INCLUDE\YNEXT.TBL'
TANGENTS:       IBYTES 'INCLUDE\TAN.TBL'
WORLDMAP:       IBYTES 'INCLUDE\WORLD.MAP'
HEIGHTTABLE:    IBYTES 'INCLUDE\HEIGHT.TBL'
PUTPIXTABLE:    IBYTES 'INCLUDE\160X200.S'
WALLS:          IBYTES 'INCLUDE\1.RAW'
                IBYTES 'INCLUDE\2.RAW'
                IBYTES 'INCLUDE\3.RAW'
                IBYTES 'INCLUDE\4.RAW'
                IBYTES 'INCLUDE\5.RAW'
PALETTE:        DC.W $00,$0764,$0266,$0555,$0607,$0337,$05,$0770
                DC.W $0260,$0630,$0420,$0700,$0222,$33,$03,$0777

                EVEN
OLD_STACK:      DS.L 1          * to save the old stuff
PHYBASE:        DS.L 1
REZ:            DS.W 1

SYSPAL:         DS.W 16

                DS.B 256
SCRNSPACE:      DS.B 64000      * reserve 2 screens
                DS.B 256
DBLBUFFER:      DS.L 1          * address of the hidden screen
ACTIVE:         DS.L 1          * address of active screen
                END
