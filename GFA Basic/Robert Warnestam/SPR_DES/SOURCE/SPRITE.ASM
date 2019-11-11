* Robert Warnestam, 3 May 1990
* Source code to GFA basic, DEMOSPR (or your own programs)
* Source File: SPRITE.ASM
* Compile to File: SPRITE.MC


* -----------------------------------------------------------------------------
* How to use from GFA BASIC:
*
* mc$=STRING$(2000,0)         ;resreve space for this assembler program
* mc%=VARPTR(mc$)             ;address to start of program
* BLOAD "SPRITE.MC",mc%       ;load program
* mc%=mc%+28                  ;skip file header
* mcstart%=mc%+30             ;first 30 bytes is data
*
* POKE mc%,MODE               ;select MODE
* -----------------------------------------------------------------------------
* MODE=1 =>                   'Set Palette'
*                             Set palette to a specified image bank.
* POKE mc%+1,bank%            bank number, 0-15
* -----------------------------------------------------------------------------
* MODE=2 =>                   'Screen Changed'
*                             If you had made changes on the screen,
*                              you have to call this routine.
* -----------------------------------------------------------------------------
* MODE=3 =>                   'All Sprite Off'
*                             Turn all sprites off,remove from screen
* -----------------------------------------------------------------------------
* MODE=4 =>                   'Sprite Off'
*                             Turn off a single sprite, you will see the effect
*                              after next 'Update' or 'Screen Changed'
* POKE mc%+2,sprite           sprite number, 0-15
* -----------------------------------------------------------------------------
* MODE=5 =>                   'Set Sprite'
*                             Set position and image to a sprite, you will see
*                              the effect after next 'Update' or
*                              'Screen Changed'
* POKE mc%+2,sprite           sprite number, 0-15
* DPOKE mc%+4,x               x position, 0-350
* DPOKE mc%+6,y               y position, 0-230
* POKE mc%+1,bank             in which image bank are the image, 0-15
* POKE mc%+3,image            image, 0-15
* -----------------------------------------------------------------------------
* MODE=6 =>                   'Update'
*                             Update sprite position & image
*                             This routine first, draws the new sprite on the
*                              log screen, then it swaps the log & phys
*                              screens and makes a VSYNC.
*                             At last it removes the old sprites (now in
*                              the log screen)
* -----------------------------------------------------------------------------
* MODE=7 =>                   'Begin It'
*                             Set screen ptr's.
* LPOKE mc%+8,logscreen       This is a second screen, used in screen flipping
*                              it have to be at 256 boundrary and 32000bytes
* LPOKE mc%+12,physscreen     This is the original screen, used in screen
*                              flipping. Get the address with XBIOS(2)
* LPOKE mc%+16,spritescreen   This is a screen used when the program erases
*                              the sprite, it is a copy of the original
*                              screen with no sprites. It does't have to be
*                              at 256 boundary. 32000 bytes long
* -----------------------------------------------------------------------------
* MODE=8 =>                   'End It'
*                             You have to enter this routine before your
*                              program finish. It set the screen pointers
*                              to the original screen (Phys)
* -----------------------------------------------------------------------------
* MODE=9 =>                   'Set Bank'
*                             When you have loaded a '*.SPR' file (sprite file
*                              created with 'SPR_DES.PRG' then you enter
*                              this rountine with the address of the loaded
*                              file, so the program nows where it get it's
*                              graphic from.
* POKE mc%+1,bank             bank number to be set, 0-15
* LPOKE mc%+20,bank_ptr       ptr to image bank
* -----------------------------------------------------------------------------
* At last....
* CALL mcstart%
* -----------------------------------------------------------------------------

*
* EQU's for variables from user to program
MODE           EQU  0
BANK_NR        EQU  1
SPRITE_NR      EQU  2
IMAGE_NR       EQU  3
X              EQU  4
Y              EQU  6
LOG_SCR        EQU  8
PHYS_SCR       EQU  12
SPR_SCR        EQU  16
BANK_PTR       EQU  20

* EQU's for sprite drawing/undrawing
SPR_X          EQU  0
SPR_Y          EQU  2
SPR_IMG_PTR    EQU  4
SPR_ON_FLAG    EQU  8
SPR_OFFSET_OLD EQU  10
SPR_WIDTH_OLD  EQU  12
SPR_HEIGHT_OLD EQU  14
SPR_OFFSET_NEW EQU  16
SPR_WIDTH_NEW  EQU  18
SPR_HEIGHT_NEW EQU  20

var            DS.B 30                            ;program starts after this

*
* start of code...
*

* Check what user want to do...
                    lea       var(pc),a6
                    clr       d0
                    move.b    MODE(a6),d0
                    cmp       #1,d0
                    beq       Set_Palette
                    cmp       #2,d0
                    beq       Screen_Changed
                    cmp       #3,d0
                    beq       All_Sprite_Off
                    cmp       #4,d0
                    beq       Sprite_Off
                    cmp       #5,d0
                    beq       Set_Sprite
                    cmp       #6,d0
                    beq       Update
                    cmp       #7,d0
                    beq       Begin_It
                    cmp       #8,d0
                    beq       End_It
                    cmp       #9,d0
                    beq       Set_Bank
                    rts

*******************************************************************************
* Mode 1: Set Palette
*         Set palette, get color from a image bank
*         In: bank_nr
*******************************************************************************
Set_Palette         clr       d0
                    move.b    BANK_NR(a6),d0
                    lsl       #2,d0               ;each 1 longword
                    lea       bank_ptrs(pc),a0    ;ptr list (16 ptr's)
                    lea       0(a0,d0.w),a0       ;ptr in list
                    move.l    (a0),d0             ;get ptr
                    move.l    d0,-(sp)            ;first 32 byte is palette
                    move      #6,-(sp)            ;SETPALETTE
                    trap      #14                 ;XBIOS
                    addq.l    #6,sp
                    rts
*******************************************************************************
* Mode 2: Screen Changed
*         Screen (LOG) has changed...
*              1- Copy LOG screen to SPR screen
*              2- Call 'Update'
*              3- Copy SPR screen to LOG screen
*******************************************************************************
Screen_Changed      move.l    log_screen(pc),a0
                    move.l    sprite_screen(pc),a1
                    move      #999,d0
scr_change_loop1    move.l    (a0)+,(a1)+         ;copy 8 longwords
                    move.l    (a0)+,(a1)+         ;1000 times
                    move.l    (a0)+,(a1)+         ;=>32000 bytes
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    dbra      d0,scr_change_loop1
                    bsr       Update
                    move.l    log_screen(pc),a1
                    move.l    sprite_screen(pc),a0
                    move      #99,d0
                    move      #999,d0
scr_change_loop2    move.l    (a0)+,(a1)+         ;copy 8 longwords
                    move.l    (a0)+,(a1)+         ;1000 times
                    move.l    (a0)+,(a1)+         ;=>32000 bytes
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    move.l    (a0)+,(a1)+
                    dbra      d0,scr_change_loop2
                    rts
*******************************************************************************
* Mode 3: All Sprites Off
*         Remove all sprites
*******************************************************************************
All_Sprite_Off      lea       sprite_data(pc),a0
                    move      #15,d0
all_off_loop        sf        SPR_ON_FLAG(a0)
                    add.l     #22,a0              ;next sprite
                    dbra      d0,all_off_loop
                    bsr       Update              ;remove from screen
                    rts
*******************************************************************************
* Mode 4: Sprite Off
*         Remove one sprite (just in memory, remove from screen with 'Update')
*         In: sprite_nr
*******************************************************************************
Sprite_Off          lea       sprite_data(pc),a0
                    clr       d0
                    move.b    SPRITE_NR(a6),d0
                    mulu      #22,d0              ;each sprite data,22 bytes
                    lea       0(a0,d0.w),a0       ;ptr to sprite data
                    sf        SPR_ON_FLAG(a0)     ;remove
                    rts
*******************************************************************************
* Mode 5: Set Sprite
*         Derfine a sprite, position and image (draw in next 'Update')
*         In: x, y, sprite_nr, bank_nr, image_nr
*******************************************************************************
Set_Sprite          lea       sprite_data(pc),a0
                    clr       d0
                    move.b    SPRITE_NR(a6),d0
                    mulu      #22,d0              ;each sprite data 22 bytes
                    lea       0(a0,d0.w),a0       ;ptr to sprite data
                    lea       bank_ptrs(pc),a1
                    clr       d0
                    move.b    BANK_NR(a6),d0
                    lsl       #2,d0               ;each 1 longword
                    lea       0(a1,d0.w),a1       ;ptr to ptr
                    move.l    (a1),a1             ;ptr to start of a bank
                    add.l     #36,a1              ;skip palette (+4bytes)
                    clr       d0
                    move.b    IMAGE_NR(a6),d0
                    move      #9,d1
                    lsl       d1,d0               ;each image 512 bytes
                    lea       0(a1,d0.w),a1       ;ptr to image in a bank
                    st        SPR_ON_FLAG(a0)     ;sprite on
                    move.l    a1,SPR_IMG_PTR(a0)  ;save image ptr
                    move      X(a6),SPR_X(a0)
                    move      Y(a6),SPR_Y(a0)
                    rts
*******************************************************************************
* Mode 6: Update
*         Draw new sprites, swap screens, undraw old sprites
*******************************************************************************
Update              lea       sprite_data(pc),a5
                    move      #15,d0              ;16 sprites
update_loop1        tst.b     SPR_ON_FLAG(a5)     ;draw this sprite?
                    beq       update_next1        ;no
                    bsr       draw_sprite
update_next1        move      SPR_OFFSET_OLD(a5),d1    ;swap _OLD & _NEW
                    move      SPR_OFFSET_NEW(a5),d2    ;vars set in
                    move      d2,SPR_OFFSET_OLD(a5)    ;'draw_sprite'
                    move      d1,SPR_OFFSET_NEW(a5)    ;and used in
                    move      SPR_WIDTH_OLD(a5),d1     ;'undraw_sprite'
                    move      SPR_WIDTH_NEW(a5),d2
                    move      d2,SPR_WIDTH_OLD(a5)
                    move      d1,SPR_WIDTH_NEW(a5)
                    move      SPR_HEIGHT_OLD(a5),d1
                    move      SPR_HEIGHT_NEW(a5),d2
                    move      d2,SPR_HEIGHT_OLD(a5)
                    move      d1,SPR_HEIGHT_NEW(a5)
                    add.l     #22,a5              ;next sprite
                    dbra      d0,update_loop1
                    lea       phys_screen(pc),a0
                    lea       log_screen(pc),a1
                    move.l    (a0),d1             ;swap phys & log screens
                    move.l    (a1),d2
                    move.l    d2,(a0)
                    move.l    d1,(a1)
                    move      #-1,-(sp)           ;res.
                    move.l    d2,-(sp)            ;phys
                    move.l    d1,-(sp)            ;log
                    move      #5,-(sp)            ;SETSCREEN
                    trap      #14                 ;XBIOS
                    add.l     #12,sp              ;tidy
                    move      #37,-(sp)           ;VSYNC
                    trap      #14                 ;XBIOS
                    add.l     #2,sp               ;tidy
                    lea       sprite_data(pc),a5
                    move      #15,d0                   ;16 sprites
update_loop2        cmp       #-1,SPR_OFFSET_OLD(a5)   ;undraw sprite?
                    beq       update_next2             ;no
                    bsr       undraw_sprite
                    move      #-1,SPR_OFFSET_OLD(a5)   ;ok with undrawing
update_next2        add.l     #22,a5              ;next sprite
                    dbra      d0,update_loop2
                    rts
*******************************************************************************
* Mode 7: Begin It
*         Init screens
*         In: log_scr, phys_scr, spr_scr
*******************************************************************************
Begin_It
                    move.l    LOG_SCR(a6),a0
                    move.l    PHYS_SCR(a6),a1
                    move.l    SPR_SCR(a6),a2
                    lea       log_screen(pc),a3
                    move.l    a0,(a3)
                    lea       phys_screen(pc),a3
                    move.l    a1,(a3)
                    lea       old_phys_screen(pc),a3
                    move.l    a1,(a3)
                    lea       sprite_screen(pc),a3
                    move.l    a2,(a3)
                    move      #7999,d0            ;8000 long words
begin_loop1         clr.l     (a0)+               ;clear screens...
                    clr.l     (a1)+
                    clr.l     (a2)+
                    dbra      d0,begin_loop1
                    lea       sprite_data(pc),a0
                    move      #15,d0
begin_loop2         sf        SPR_ON_FLAG(a0)          ;sprite off
                    move      #-1,SPR_OFFSET_OLD(a0)   ;don't undraw
                    move      #-1,SPR_OFFSET_NEW(a0)   ;don't undraw
                    add.l     #22,a0                   ;next sprite
                    dbra      d0,begin_loop2
                    bsr       Update                   ;set screens
                    rts
*******************************************************************************
* Mode 8: End It
*         Set original screens
*******************************************************************************
End_It              move.l    old_phys_screen(pc),d0
                    move      #-1,-(sp)                ;res.
                    move.l    d0,-(sp)                 ;phys
                    move.l    d0,-(sp)                 ;log
                    move      #5,-(sp)                 ;SETSCREEN
                    trap      #14                      ;XBIOS
                    add.l     #12,sp                   ;tidy
                    rts
*******************************************************************************
* Mode 9: Set Bank
*         Set address to an image bank (created with SPR_DES)
*         In: bank_nr, bank_ptr
*******************************************************************************
Set_Bank            clr       d0
                    move.b    BANK_NR(a6),d0
                    lsl       #2,d0               ;each 1 longword
                    lea       bank_ptrs(pc),a0
                    lea       0(a0,d0.w),a0       ;ptr to ptr in list
                    move.l    BANK_PTR(a6),(a0)   ;set address
                    rts
*******************************************************************************
* Routines used from this program
* Erase sprite
* In: A5.L ptr to sprite data area
undraw_sprite       movem.l   d0-d1/a0-a2,-(sp)
                    move.l    SPR_OFFSET_OLD(a5),d0    ;offset on screen
                    move.l    log_screen(pc),a2        ;undraw screen
                    move.l    sprite_screen(pc),a1     ;get data from this scr
                    add.l     d0,a2                    ;add offset
                    add.l     d0,a1
                    move      SPR_HEIGHT_OLD(a5),d1    ;visible sprite height-1
                    move      SPR_WIDTH_OLD(a5),d0     ;x-words saved
                    cmp       #1,d0               ;16 pixel saved?
                    beq       un16
                    cmp       #2,d0               ;32 pixel saved?
                    beq       un32                ;else 48 pixel saved!
un48                move.l    (a1)+,(a2)+         ;copy 48pixel*4planes=24bytes
                    move.l    (a1)+,(a2)+
                    move.l    (a1)+,(a2)+
                    move.l    (a1)+,(a2)+
                    move.l    (a1)+,(a2)+
                    move.l    (a1)+,(a2)+
                    add.l     #136,a2             ;next line
                    add.l     #136,a1
                    dbf       d1,un48
                    movem.l   (sp)+,d0-d1/a0-a2
                    rts
un32                move.l    (a1)+,(a2)+         ;copy 32pixel*4planes=16bytes
                    move.l    (a1)+,(a2)+
                    move.l    (a1)+,(a2)+
                    move.l    (a1)+,(a2)+
                    add.l     #144,a2             ;next line
                    add.l     #144,a1
                    dbf       d1,un32
                    movem.l   (sp)+,d0-d1/a0-a2
                    rts
un16                move.l    (a1)+,(a2)+         ;copy 16pixel*4planes=8bytes
                    move.l    (a1)+,(a2)+
                    add.l     #152,a2             ;next line
                    add.l     #152,a1
                    dbf       d1,un16
                    movem.l   (sp)+,d0-d1/a0-a2
                    rts
*******************************************************************************
* Draw sprite
* In: A5.L ptr to sprite data area
draw_sprite         movem.l   d0-d7/a0-a1,-(sp)
                    move.l    SPR_IMG_PTR(a5),a1  ;ptr to image
                    move      SPR_X(a5),d0        ;x
                    move      SPR_Y(a5),d1        ;y
                    cmp       #350,d0             ;inside x boundaries?
                    bhi       doexit
                    cmp       #230,d1
                    bhi       doexit
                    move.l    #0,a0               ;offset on screen(inc.later)
                    cmp       #30,d1              ;sprite at top?
                    bhi       donotop
                    move      d1,d2               ;#lines-1=y0
                    eor       #31,d1              ;start=31-y0
                    bra       doyok
donotop             cmp       #199,d1             ;sprite in middle?
                    bhi       donomiddle
                    move      d1,d7               ;screen=y0-31
                    sub       #31,d7
                    mulu      #160,d7
                    add.w     d7,a0               ;inc. screen offset
                    clr       d1                  ;start=0
                    move      #31,d2              ;#lines-1=31
                    bra       doyok
donomiddle          move      d1,d7               ;screen=y0-31
                    sub       #31,d7
                    mulu      #160,d7
                    add.w     d7,a0               ;inc. screen offset
                    move      d1,d2               ;#lines-1=31-(y0-199)
                    sub       #199,d2
                    eor       #31,d2
                    clr       d1                  ;start=0
doyok               move      d2,SPR_HEIGHT_OLD(a5)    ;save height-1
                    lsl       #4,d1               ;adjust image ptr
                    lea       0(a1,d1.w),a1       ; to current sprite height
                    cmp       #14,d0              ;sprite on left side?
                    bhi       nol1
*Sprite on the left side (0-50%)
                    move      #1,SPR_WIDTH_OLD(a5)     ;save x-words (16 pixel)
                    move.l    a0,SPR_OFFSET_OLD(a5)    ;save screen offset
                    add.l     log_screen(pc),a0        ;screen+offset
                    and       #15,d0                   ;x MOD 15=rotations
                    addq      #1,d0               ;at least one pixel visible
                    addq.l    #8,a1                  ;skip left side of sprite
dloop1              bsr       pixleft
                    add.l     #160,a0                  ;next line
                    add.l     #8,a1                    ;skip left side
                    dbf       d2,dloop1
                    bra       doexit
nol1                cmp       #30,d0                   ;sprite on left side?
                    bhi       nol2
*Sprite on the left side (50-100%)
                    move      #2,SPR_WIDTH_OLD(a5)     ;save x-words (32 pixel)
                    move.l    a0,SPR_OFFSET_OLD(a5)    ;save screen offset
                    add.l     log_screen(pc),a0        ;screen+offset
                    sub       #15,d0                   ;begin x=0
                    and       #15,d0                   ;rotations
dloop2              bsr       pixleft
                    bsr       pix16
                    add.l     #160,a0                  ;next line
                    dbf       d2,dloop2
                    bra       doexit
nol2                cmp       #319,d0                  ;sprite in the middle
                    bhi       nocenter
*Sprite in the middle
                    move      #3,SPR_WIDTH_OLD(a5)     ;save x-words (48 pixel)
                    sub       #31,d0                   ;begin x=0
                    move      d0,d3
                    and       #15,d0                   ;rotations
                    lsr       #4,d3                    ;x-byte=4*(x DIV 16)
                    lsl       #3,d3
                    lea       0(a0,d3.w),a0            ;inc. screen offset
                    move.l    a0,SPR_OFFSET_OLD(a5)    ;save screen offset
                    add.l     log_screen(pc),a0        ;screen+offset
dloop3              bsr       pix16
                    add.l     #8,a0                    ;next 16 pixel
                    bsr       pix16
                    add.l     #152,a0                  ;next line
                    dbf       d2,dloop3
                    bra       doexit
nocenter            cmp       #335,d0                  ;sprite on right side?
                    bhi       doright2
*Sprite on the right side (50-100%)
                    move      #2,SPR_WIDTH_OLD(a5)     ;save x-words (32 pixel)
                    add.l     #144,a0                  ;inc. screen offset
                    move.l    a0,SPR_OFFSET_OLD(a5)    ;save screen offset
                    add.l     log_screen(pc),a0        ;screen+offset
                    sub       #320,d0                  ;begin x=0
                    and       #15,d0                   ;rotations
                    addq      #1,d0               ;at least one pixel visible
dloop4              bsr       pix16
                    add.l     #8,a0                    ;next 16 pixel
                    bsr       pixright
                    add.l     #152,a0                  ;next line
                    dbf       d2,dloop4
                    bra       doexit
*Sprite on the right side (0-50%)
doright2            move      #1,SPR_WIDTH_OLD(a5)     ;save x-words (16 pixel)
                    add.l     #152,a0             ;inc. screen offset
                    move.l    a0,SPR_OFFSET_OLD(a5)    ;save screen offset
                    add.l     log_screen(pc),a0        ;screen+offset
                    sub       #336,d0             ;begin x=0
                    and       #15,d0              ;rotations
                    addq      #1,d0               ;at least one pixel visib
dloop5              bsr       pixright
                    add.l     #8,a1               ;skip right side on sprite
                    add.l     #160,a0             ;next line
                    dbf       d2,dloop5
doexit              movem.l   (sp)+,d0-d7/a0-a1
                    rts
*
pix16               move      (a1)+,d4            ;get sprite data
                    move      (a1)+,d5            ;4 planes a 16 pixel
                    move      (a1)+,d6
                    move      (a1)+,d7
                    swap      d4                  ;sprite in high words
                    swap      d5
                    swap      d6
                    swap      d7
                    clr       d4                  ;clear low word
                    clr       d5
                    clr       d6
                    clr       d7
                    lsr.l     d0,d4               ;rotate
                    lsr.l     d0,d5
                    lsr.l     d0,d6
                    lsr.l     d0,d7
                    move.l    d4,d3               ;make mask
                    or.l      d5,d3               ;color 0 = transparent
                    or.l      d6,d3
                    or.l      d7,d3
                    and.l     d3,d4               ;mask sprite data
                    and.l     d3,d5
                    and.l     d3,d6
                    and.l     d3,d7
                    not.l     d3                  ;mask screen
                    and       d3,$8(a0)
                    and       d3,$a(a0)
                    and       d3,$c(a0)
                    and       d3,$e(a0)
                    swap      d3
                    and       d3,$0(a0)
                    and       d3,$2(a0)
                    and       d3,$4(a0)
                    and       d3,$6(a0)
                    swap      d3
                    add       d4,$8(a0)           ;add screen with sprite
                    add       d5,$a(a0)
                    add       d6,$c(a0)
                    add       d7,$e(a0)
                    swap      d4
                    swap      d5
                    swap      d6
                    swap      d7
                    add       d4,$0(a0)
                    add       d5,$2(a0)
                    add       d6,$4(a0)
                    add       d7,$6(a0)
                    rts
pixleft             move      (a1)+,d4            ;get sprite data
                    move      (a1)+,d5
                    move      (a1)+,d6
                    move      (a1)+,d7
                    swap      d4                  ;sprite in high word
                    swap      d5
                    swap      d6
                    swap      d7
                    clr       d4                  ;clear low word
                    clr       d5
                    clr       d6
                    clr       d7
                    lsr.l     d0,d4               ;rotate
                    lsr.l     d0,d5
                    lsr.l     d0,d6
                    lsr.l     d0,d7
                    move      d4,d3               ;make mask
                    or        d5,d3
                    or        d6,d3
                    or        d7,d3
                    and       d3,d4               ;mask sprite data(bit0-15)
                    and       d3,d5
                    and       d3,d6
                    and       d3,d7
                    not       d3                  ;mask screen
                    and       d3,$0(a0)
                    and       d3,$2(a0)
                    and       d3,$4(a0)
                    and       d3,$6(a0)
                    add       d4,$0(a0)           ;add screen with sprite
                    add       d5,$2(a0)
                    add       d6,$4(a0)
                    add       d7,$6(a0)
                    rts
pixright            move      (a1)+,d4            ;get sprite data
                    move      (a1)+,d5
                    move      (a1)+,d6
                    move      (a1)+,d7
                    swap      d4                  ;sprite in high word
                    swap      d5
                    swap      d6
                    swap      d7
                    lsr.l     d0,d4               ;rotate
                    lsr.l     d0,d5
                    lsr.l     d0,d6
                    lsr.l     d0,d7
                    swap      d4                  ;sprite in low word
                    swap      d5
                    swap      d6
                    swap      d7
                    move      d4,d3               ;make mask
                    or        d5,d3
                    or        d6,d3
                    or        d7,d3
                    and       d3,d4               ;mask sprite data
                    and       d3,d5
                    and       d3,d6
                    and       d3,d7
                    not       d3                  ;mask screen
                    and       d3,$0(a0)
                    and       d3,$2(a0)
                    and       d3,$4(a0)
                    and       d3,$6(a0)
                    add       d4,$0(a0)           ;add screen with sprite
                    add       d5,$2(a0)
                    add       d6,$4(a0)
                    add       d7,$6(a0)
                    rts
* Pointers to 16 image banks, 16 longword
bank_ptrs           ds.l      16

* Sprite data, 22 bytes each
sprite_data         ds.b      16*22

* Screen pointers
log_screen          ds.l      1
phys_screen         ds.l      1
sprite_screen       ds.l      1
old_phys_screen     ds.l      1


                    END
