;2010/04
;Muzizik by DMA-SC/sector 1
;Grafifik by Ukko
;Kokode by baah/Arm's Tech + positivity + ST Ghost/Sector One

;A FAIRE:
;- ENLEVER LES ROUTINES DE CLR REDONDANTES POUR GAGNER DE LA MEMOIRE
;- AFFICHAGE SOLEIL EN 1 BPL: 320*73*1
;- ROUTINE RASTER A LA 73 LIGNE DONC
;- RASTERS POUR LE FADE DU SOLEIL
;- PASSER EN TRIPLE BUFFERING SI ON EST A LA LIMITE
;- REDUIRE LE NB DE SPRITES?
;- BUG ON WINGLEADER'S NAME
;- VERIFIER QUE LA MUSIQUE EST BIEN STF

  opt o+

NBSPRITES=4   ;Nb of sprites (kiki, kikijump, kiki*2, kikijump*2)
NBNAMES=145
NBKIKIS=20

;IN   \1.l=random number
;OUT  \1.l=new random number
;     \2.l killed
RANDOM MACRO
  move.l    \1,\2
  ror.l     #7,\1
  ror.l     #4,\1
  sub.l     \2,\1
 ENDM
 
;*******************************
;****    INITIALISATIONS    ****
;*******************************
RandomNb
  clr.l     -(sp)
  move.w    #32,-(sp)           ;Switch to supervisor
  trap      #1
  addq.l    #2,sp
  lea       OldConfig(pc),a6
;SAVE PALETTE
  lea       $ffff8240.w,a0
  moveq.l   #8-1,d0
BL_SaveOneColor  
  move.l    (a0)+,(a6)+
 dbra d0,BL_SaveOneColor 
;SAVE @VRAM AND CLEAR SCREEN  
  move.w    #3,-(sp)            ;Get LogBase in d0.l 
  trap      #14
  addq.l    #2,sp
  move.l    d0,(a6)+
  move.l    d0,a5               ;a5=@videoram
;SAVE RESOLUTION AND CHANGE IT  
  move.b    $ffff8260.w,(a6)+   ;Resolution
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  move.b    #0,$ffff8260.w      ;Switch to 320*200*4bpp
;STOP MOUSE  
  dc.w      $a00a
  move.b    #18,$fffffc02.w
;SAVE MFP DATA
  move.b    $fffffa07.w,(a6)+   ;IERA=Interrupt Enable A
  move.b    $fffffa09.w,(a6)+   ;IERB
  move.b    $fffffa13.w,(a6)+   ;IMRA=Interrupt Mask A
  move.l    $70.w,(a6)+         ;Save Old_VBl
  move.l    $120.w,(a6)+        ;Save Old_HBl (Timer B)
;INIT MUSIC
  jsr       Music
  move.l    #Dumb_VBl,$70.w

;*********************************
;****    SHOW TITLE SCREEN    ****
;*********************************

;FADE TO WHITE
  lea       $ffff8240.w,a0
  lea       BlackPalette,a1
  lea       FadePalette,a2
  move.l    a2,a6
  bsr       MKFADE
  moveq.l   #33-1,d7
Fade1
  move.w    #37,-(sp)
  trap      #14
  addq.l    #2,sp
  lea       $ffff8240.w,a0
  moveq.l   #8-1,d0
Fade1_TwoCols
  move.l    (a6)+,(a0)+
  dbra      d0,Fade1_TwoCols
  dbra      d7,Fade1

;COPY "title.pi1" TO VIDEORAM
  move.l    VideoRamAdress,a5
  lea       Title+34,a6
  move.w    #8000-1,d0
CopyTitleToVideoRam
  move.l    (a6)+,(a5)+
  dbra      d0,CopyTitleToVideoRam
  
;FADE TO COLORS
  lea       $ffff8240.w,a0
  lea       Title+2,a1
  lea       FadePalette,a2
  move.l    a2,a6
  bsr       MKFADE
  moveq.l   #33-1,d7
Fade2
  move.w    #37,-(sp)
  trap      #14
  addq.l    #2,sp
  lea       $ffff8240.w,a0
  moveq.l   #8-1,d0
Fade2_TwoCols
  move.l    (a6)+,(a0)+
  dbra      d0,Fade2_TwoCols
  dbra      d7,Fade2
  
;***************************************
;****    PREPARE SPRITE ROUTINES    ****
;***************************************
  lea       AdressesSpritesRoutines,a6
  lea       Title,a5
  lea       SpritesRoutines,a0

;Sprite1, normal  
  move.l    a5,a1
  lea       Sprite1,a2
  moveq.l   #32,d0
  moveq.l   #0,d1
  jsr       COPYSPR
  moveq.l   #12,d0
  jsr       SHRSPR
  moveq.l   #16-1,d7
PREPARE_GenSprite1  
;!!!unmodified by SHRSPR  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENCLR
  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENSPR
  move.l    a5,a1
  moveq.l   #1,d0
  jsr       SHRSPR
  dbra      d7,PREPARE_GenSprite1

;Sprite2, normal  
  move.l    a5,a1
  lea       Sprite2,a2
  moveq.l   #32,d0
  moveq.l   #0,d1
  jsr       COPYSPR
  moveq.l   #12,d0
  jsr       SHRSPR
  moveq.l   #16-1,d7
PREPARE_GenSprite2
;  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENCLR
  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENSPR
  move.l    a5,a1
  moveq.l   #1,d0
  jsr       SHRSPR
  dbra      d7,PREPARE_GenSprite2

;Sprite1, X*2, Y*2  
  move.l    a5,a1
  lea       Sprite1,a2
  moveq.l   #64,d0
  moveq.l   #-1,d1
  jsr       COPYSPR
  jsr       DBLXSPR
  moveq.l   #16-1,d7
PREPARE_GenSprite3
;  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENCLR
  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENSPR
  move.l    a5,a1
  moveq.l   #1,d0
  jsr       SHRSPR
  dbra      d7,PREPARE_GenSprite3

;Sprite2, X*2, Y*2  
  move.l    a5,a1
  lea       Sprite2,a2
  moveq.l   #64,d0
  moveq.l   #-1,d1
  jsr       COPYSPR
  jsr       DBLXSPR
  moveq.l   #16-1,d7
PREPARE_GenSprite4
;  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENCLR
  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENSPR
  move.l    a5,a1
  moveq.l   #1,d0
  jsr       SHRSPR
  dbra      d7,PREPARE_GenSprite4

;PREPARE NAMES AND ASSOCIATED SPRITE ROUTINES
;a6=@AdressesSpritesRoutines,  a5=@VideoRamAdress, a0=@SpritesRoutines
  move.l    #$00400005,(a5)    ;NameWidth=64, NameHeight=5
PREPARE_OneName
;clear memory
  move.l    a5,a4
  addq.w    #4,a4
  moveq.l   #4*5-1,d0
  moveq.l   #0,d1
PREPARE_OneName_Clear
  move.l    d1,(a4)+
  dbra      d0,PREPARE_OneName_Clear
  
  move.l    NamePointer,a4
PREPARE_OneName_OneLetter
  moveq.l   #0,d0
  move.b    (a4)+,d0      ;d0=LetterNb*6
  cmpi.b    #255,d0       ;Last letter of the name?
  beq.s     PREPARE_OneName_NoMoreLetter
  lea       Fonts,a3
  add.w     d0,a3
  move.b    (a3)+,d0      ;d0=shift
  move.l    a5,a1
  jsr       SHLSPR
  move.b    (a3)+,d0
  or.b      d0,4+9(a5)    ;print letter on the right of the 48 pixels
  or.b      d0,6+9(a5)
  move.b    (a3)+,d0
  or.b      d0,4+9+16(a5)
  or.b      d0,6+9+16(a5)
  move.b    (a3)+,d0
  or.b      d0,4+9+32(a5)
  or.b      d0,6+9+32(a5)
  move.b    (a3)+,d0
  or.b      d0,4+9+48(a5)
  or.b      d0,6+9+48(a5)
  move.b    (a3)+,d0
  or.b      d0,4+9+64(a5)
  or.b      d0,6+9+64(a5)
  bra.s     PREPARE_OneName_OneLetter
  
PREPARE_OneName_NoMoreLetter
  move.l    a4,NamePointer
;!!!unmodified by SHRSPR  move.l    a5,a1
  moveq.l   #16-1,d7
PREPARE_GenName
  move.l    a5,a1
;  moveq.l   #1,d0
;  jsr       SHRSPR
  move.l    a0,(a6)+
  jsr       GENCLR
  move.l    a5,a1
  move.l    a0,(a6)+
  jsr       GENSPR
  move.l    a5,a1
  moveq.l   #1,d0
  jsr       SHRSPR
  dbra      d7,PREPARE_GenName
  subq.w    #1,NumberOfNamesLeft
  bne       PREPARE_OneName

;*************************************
;****    CREATE ADRESSES TABLE    ****
;*************************************
  lea       WorkAdressesTable,a4
  move.l    VideoRamAdress,a5
  move.l    #Title+34,d0
  move.b    #0,d0               ;Align Screen1 on a multiple of 256
  move.l    d0,a6
  lea       KikiClearData1,a3
  move.l    a5,(a4)+            ;@ShowScreen=@logbase (Screen0)
  move.l    a6,(a4)+            ;@WorkScreen=@Screen1
  move.l    a3,(a4)+            ;@ClearData=@KikiClearData1
  lea       KikiClearData0,a3
  move.l    a6,(a4)+            ;@ShowScreen=@Screen1
  move.l    a5,(a4)+            ;@WorkScreen=@logbase (Screen0)
  move.l    a3,(a4)+            ;@ClearData=@KikiClearData0

;*******************************
;****    PREPARE SCREENS    ****
;*******************************

;FADE TO WHITE
  lea       $ffff8240.w,a0
  lea       WhitePalette,a1
  lea       FadePalette,a2
  bsr       MKFADE
  moveq.l   #33-1,d7
  lea       FadePalette,a4
Fade3
  move.w    #37,-(sp)
  trap      #14
  addq.l    #2,sp
  lea       $ffff8240.w,a0
  moveq.l   #8-1,d0
Fade3_TwoCols
  move.l    (a4)+,(a0)+
  dbra      d0,Fade3_TwoCols
  dbra      d7,Fade3

;COPY BACKGROUND TO SCREENS
  lea       BackGround,a4
  move.w    #4000-1,d0
CopyBackground
  move.l    (a4)+,d1
  move.l    (a4)+,d2
  move.l    d2,(a5)+
  move.l    d2,(a6)+
  move.l    d1,(a5)+
  move.l    d1,(a6)+
 dbra d0,CopyBackground


;*******************************
;****    PREPARE TIMER B    ****
;*******************************
;  and.b     #$40,$fffffa09.w    ;Disable most interrupts ???
  bclr.b    #3,$fffffa17.w      ;Software end of interrupt
;!!!SAVE $fffffa17 ?
  clr.b  $fffffa1b.w
  move.l    #HBl_Routine1,$120.w
  or.b      #1,$fffffa07.w      ;Enable Timer B (in IERA)
  or.b      #1,$fffffa13.w      ;Unmask it (in IMRA)
  move.l    #FranKIKI_VBl,$70.w
 
;********************
;****    MAIN    ****
;********************

;a6=@WorkAdressesTable (contains @ShowScreen.l, @WorkScreen.l, @ClearData.l)
OneVBl
  move.l    WorkAdressesPointer,a4
  move.l    (a4)+,d0            ;d0=@ShowScreen
  bne.s     SetShowScreen
  sub.w     #2*3*4+4,a4         ;Back to first screen
  move.l    (a4)+,d0
SetShowScreen
  lsr.w     #8,d0               ;Set video shifter
  move.b    d0,$ffff8203.w
  swap.w    d0
  move.b    d0,$ffff8201.w
  move.l    (a4)+,a6            ;a6=@WorkScreen
  move.l    (a4)+,a5            ;a5=@ClearData
  move.l    a4,WorkAdressesPointer
  
;  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
;  trap      #14
;  addq.l    #2,sp

VBl_SYNC
  tst.b     VBl_Flag
  beq.s     VBl_SYNC
  move.b  #0,VBl_Flag

  
;Set colors and HBl routine
  lea       $ffff8240.w,a0
  lea       KikiPalette,a1
  movem.l   (a1),d0-d7
  movem.l   d0-d7,(a0)
  
;  jsr       Music+8

;  move.w    #$666,$ffff8240.w ;!!!

;;!!!TEST VITESSE AFFICHAGE D'UN BLOC 320*73
;  move.l    a5,a0       ;a0=@background un plan
;  move.l    a6,a1
;  moveq.l   #73-1,d6
;  moveq.l   #160-40+4,d5
;CopySun
;  movem.l   (a0)+,d0-d4
;  move.l    d0,(a1)+
;  addq.l    #4,a1
;  move.l    d1,(a1)+
;  addq.l    #4,a1
;  move.l    d2,(a1)+
;  addq.l    #4,a1
;  move.l    d3,(a1)+
;  addq.l    #4,a1
;  move.l    d4,(a1)+
;  add.l     d5,a1
;  dbra      d6,CopySun  

;!!!TEST EN UN PLAN
; REPT 91
;  movem.l   (a0)+,d0-d7
;  move.w    d0,(a1)+
;  addq.l    #6,a1
;  swap.w    d0
;  move.w    d0,(a1)+
;  addq.l    #6,a1
;  move.w    d1,(a1)+
;  addq.l    #6,a1
;  swap.w    d1
;  move.w    d1,(a1)+
;  addq.l    #6,a1
;  move.w    d2,(a1)+
;  addq.l    #6,a1
;  swap.w    d2
;  move.w    d2,(a1)+
;  addq.l    #6,a1
;  move.w    d3,(a1)+
;  addq.l    #6,a1
;  swap.w    d3
;  move.w    d3,(a1)+
;  addq.l    #6,a1
;  move.w    d4,(a1)+
;  addq.l    #6,a1
;  swap.w    d4
;  move.w    d4,(a1)+
;  addq.l    #6,a1
;  move.w    d5,(a1)+
;  addq.l    #6,a1
;  swap.w    d5
;  move.w    d5,(a1)+
;  addq.l    #6,a1
;  move.w    d6,(a1)+
;  addq.l    #6,a1
;  swap.w    d6
;  move.w    d6,(a1)+
;  addq.l    #6,a1
;  move.w    d7,(a1)+
;  addq.l    #6,a1
;  swap.w    d7
;  move.w    d7,(a1)+
;  addq.l    #6,a1
; ENDR    
;IL FAUT ENCORE 
  


;Clear KIKIs
  move.l    a5,a4
  lea       KikiClearReturn,a1
  moveq.l   #0,d0
  moveq.l   #NBKIKIS*2-1,d7
ClearOneKiki  
  move.l    (a4)+,a0
  move.l    (a4)+,a2
  jmp       (a2)
KikiClearReturn
  dbra      d7,ClearOneKiki

  add.w     #32000-160-32,a6    ;bottom of screen, 64 pixels on left
  lea       AdressesSpritesRoutines,a4
  lea       KikiData,a3
  
;**** PROCESS ONE KIKI
;a6=@WorkScreen+32000-160-32, a5=@ClearData, a4=@SpriteRoutines, a3=@KikiData, a1=@Return
;KikiData contains
;tireness, x, y*128, vx, vy*128, sprite_nb*2*16*8,name_nb, tireness_reinit,

  
  moveq.l   #NBKIKIS-1,d7
ProcessOneKiki
  movem.w   (a3),d0-d6 ;x,y*128,vy*128,tireness,vx,sprite_nb*2*16*8,(name_nb+NBSPRITES)*16*8,tireness_reinit
  tst.w     d3
  bne.s     KikiStillTired
  add.w     d4,d0               ;x+=vx
  add.w     d2,d1               ;y+=vy
  ble.s     KikiHasFinishedJump
  sub.w     #48,d2              ;vy-=gravity
  movem.w   d0-d2,(a3)
  bra.s     KikiDraw  
  
KikiHasFinishedJump  
  moveq.l   #0,d1
  movem.w   d0-d1,(a3)
  move.w    14(a3),6(a3)        ;tireness=tireness_reinit
  bra.s     KikiDraw
  
KikiStillTired
  subq.w    #1,d3               ;tireness-=1
  move.w    d3,6(a3)            ;Save tireness
  bne.s     KikiDraw
  move.l    RandomNb,d2
  RANDOM    d2,d3
  move.l    d2,RandomNb  
  and.w     #%111111111,d2      ;vy in [0;4[ *128
  add.w     #%110000000,d2      ;vy in [3;7[ *128
  move.w    d2,4(a3)
  
;d0=x , d1=y*128
KikiDraw
  cmp.w     #14,d0
  blt       KikiNext
  cmp.w     #320+14,d0
  bge.s     KikiGotToOutline

  move.l    a6,a0             ;a0=@workscreen
  and.w     #$ff80,d1         ;d1=int(y)*128
  move.w    d1,d2
  lsr.w     #2,d2             ;d2=int(y)*32
  add.w     d1,d2             ;d2=int(y)*160
  sub.w     d2,a0             ;a0=@workscreen-int(y)*160
  move.w    d0,d2
  moveq.l   #15,d3
  and.w     d3,d2             ;d2=shift=x mod(16)
  sub.w     d2,d0             ;d0=x-x mod(16)
  lsr.w     #1,d0             ;d0=(x-x mod(16))/2
  add.w     d0,a0             ;a0=@workscreen-int(y)*160+(x-x mod(16))/2
  
  move.l    a4,a2
  add.w     d5,a2             ;a2=AdressesSpritesRoutines+sprite_nb*2*16*8
  lsl.w     #3,d2             ;d2=shift*8
  add.w     d2,a2             ;a2=AdressesSpritesRoutines+sprite_nb*2*16*8+shift*8

  cmp.w     #2*16*8,d5
  beq.s     KikiBigDraw
KikiSmallDraw
  sub.w     #19*160,a0        ;height is 19
  cmp.w     #5*128,d1         ;y<5?
  blt.s     KikiSaveAndDraw
  sub.w     #7*160,a0         ;height is 19+7=26
  add.w     #16*8,a2          ;and second Kiki sprite
  bra.s     KikiSaveAndDraw
  
KikiBigDraw
  sub.w     #19*2*160,a0      ;height is 19*2
  cmp.w     #10*128,d1        ;y<10?
  blt.s     KikiSaveAndDraw
  sub.w     #7*2*160,a0       ;height is (19+7)*2=26*2
  add.w     #16*8,a2          ;and second Kiki sprite
  
KikiSaveAndDraw
  lea       KikiDrawName,a1
  move.l    a0,(a5)+          ;Save @drawing as ClearData
  move.l    (a2)+,(a5)+       ;  and also @SpriteRoutine
  move.l    (a2),a2
  jmp       (a2)
 
KikiDrawName
  lea       KikiNext,a1
  move.l    -8(a5),a0
  sub.w     #160*6,a0
  move.l    a4,a2
  add.w     d6,a2             ;a2=AdressesSpritesRoutines+(name_nb+NBSPRITES)*16*8
;  lsl.w     #3,d2             ;d2=shift*8
  add.w     d2,a2             ;a2=AdressesSpritesRoutines+(name_nb+NBSPRITES)*16*8+shift*8
  move.l    a0,(a5)+          ;Save @drawing as ClearData
  move.l    (a2)+,(a5)+       ;  and also @SpriteRoutine
  move.l    (a2),a2
  jmp       (a2)
  
;Reinitialise to a new Kiki
KikiGotToOutline
  ;x,y*128,vy*128,tireness,vx,sprite_nb*2*16*8,(name_nb+NBSPRITES)*16*8,tireness_reinit
  move.l    RandomNb,d2
  RANDOM    d2,d0
  moveq.l   #15,d0
  and.l     d2,d0       ;d0=x=rnd[0;15]
  RANDOM    d2,d4
  moveq.l   #1,d4
  and.l     d2,d4
  addq.l    #1,d4       ;d4=vx=1+rnd[0;1]
  RANDOM    d2,d3
  moveq.l   #15,d3
  and.l     d2,d3
  addq.l    #5,d3       ;d3=tireness=tireness_reinit=5+rnd[0;15]
  moveq.l   #0,d5       ;d5=sprite_nb=0
  RANDOM    d2,d1
  moveq.l   #3,d1       
  and.l     d2,d1       ;d1=rnd[0;3]
  bne.s     KikiReinitSmall
  move.w    #2*16*8,d5  ;d5=sprite_nb (0 with probability 3/4)
KikiReinitSmall
  RANDOM    d2,d6
  move.l    d2,RandomNb
  moveq.l   #0,d6
  move.w    d2,d6
  divu.w    #NBNAMES,d6
  swap.w    d6          ;d6=rnd mod NBNAMES
  addq.w    #4,d6       ;skip KIKIs' sprites
  lsl.w     #7,d6       ;d6=name_nb
  moveq.l   #0,d1       ;y=0
  moveq.l   #0,d2       ;vy=0
  movem.w   d0-d6,(a3)
  move.w    d3,14(a3)

KikiNext
  add.w     #16,a3
  dbra      d7,ProcessOneKiki
  
  
;  move.w    #$000,$ffff8240.w ;!!!
    
  cmpi.b    #$39,$fffffc02.w  ;Wait for any key
  bne       OneVBl
    
;****************************
;****    RESTORATIONS    ****
;****************************  
  
;THIS LINE BY ST GHOST ;)
  move.b    #0,$fffffa1b.w      ;Stop timer B
  
;RESTORE MOUSE
  move.b    #8,$fffffc02.w
  dc.w      $a009
;RESTORE PALETTE
  lea       OldConfig(pc),a6
  lea       $ffff8240.w,a0
  moveq.w   #16-1,d0
BL_RestoreOneColor  
  move.w    (a6)+,(a0)+
 dbra d0,BL_RestoreOneColor 
;RESTORE RESOLUTION AND @VRAM  
  move.l    (a6)+,d0
  lsr.w     #8,d0               ;Set video shifter
  move.b    d0,$ffff8203.w
  swap.w    d0
  move.b    d0,$ffff8201.w
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  move.b    (a6)+,$ffff8260.w   ;Resolution
;RESTORE MFP
  move.b    (a6)+,$fffffa07.w
  move.b    (a6)+,$fffffa09.w
  move.b    (a6)+,$fffffa13.w

  move.l    (a6)+,$70.w
;KILL MUSIC
  jsr       Music+4
;  move.l    #$08080000,$ffff8800.w
;  move.l    #$09090000,$ffff8800.w
;  move.l    #$0a0a0000,$ffff8800.w

  move.l    (a6)+,$120.w
;TERMINATE
  clr.w     -(sp)
  trap      #1

  

Dumb_VBl
  addq.l  #$1,$466.w  ; Increase _frclock.
  move.b  #1,VBl_Flag
  jsr    Music+8
  rte
  
FranKIKI_VBl
  addq.l  #$1,$466.w  ; Increase _frclock.
  move.b  #1,VBl_Flag
  jsr    Music+8

  move.b    #0,$fffffa1b.w      ;IPRA=Interrupt Pending A, stop timer B
  or.b      #1,$fffffa07.w      ;Enable Timer B (in IERA)
  or.b      #1,$fffffa13.w      ;Unmask it (in IMRA)
  move.b    #151,$fffffa21.w    ;Timer B Data (nb of lines to wait before interrupting)
  move.l    #HBl_Routine1,$120.w
  move.b    #8,$fffffa1b.w      ;allow timer B
  rte

VBl_Flag
  dc.w    0

;***************************
;****    HBL ROUTINE    ****
;***************************
HBl_Routine1
  move.b    #0,$fffffa1b.w      ;Stop timer B
  move.l    #$7410741,$ffff8250.w
  move.l    #$7410741,$ffff8254.w
  move.b    #30,$fffffa21.w     ;Timer B Data (nb of lines to wait before interrupting)
  move.l    #HBl_Routine2,$120.w
  move.b    #8,$fffffa1b.w      ;allow timer B
  bclr.b    #0,$fffffa0f.w
  rte

HBl_Routine2
  move.b    #0,$fffffa1b.w      ;Stop timer B
  move.l    #$2520252,$ffff8250.w
  move.l    #$2520252,$ffff8254.w
  bclr.b    #0,$fffffa0f.w      ;ISRA=Interrupt In Service A (timer B finished)
  rte
  
;KikiPalette  
;  dc.w $777,$553,$421,$000
;  dc.w $333,$553,$421,$000
;  dc.w $777,$777,$777,$777
;  dc.w $333,$333,$333,$333
  
;***********************
;****    MK FADE    ****
;***********************
;a0=@src palette
;a1=@dest palette
;a2=@storage for 33 palettes (33*16*2 bytes)
;KILLS d0-d7,a0-a4
  include 'MKFADE.S'
  
;!!!CURRENTLY MASK=(BPL0 OR BPL1) BUT THAT CAN/SHALL BE MODIFIED
;**********************
;****    GENSPR    ****
;**********************
;IN   a0=@WhereToGenerateRoutine
;     a1=@Sprite, 2bpl (starting with SpriteWidth.w , SpriteHeight.w)
;     SpriteWidth must be a multiple of 16
;OUT  a0 points after generated routine
;     KILLS d0-d6/a0-a4
;Generated routine is called with a0=@drawing, a1=@return, d0 will be killed
  include 'GENSPR.S'

;**********************
;****    GENCLR    ****
;**********************
;IN   a0=@WhereToGenerateRoutine
;     a1=@Sprite, 2bpl (starting with SpriteWidth.w , SpriteHeight.w)
;     SpriteWidth must be a multiple of 16
;OUT  a0 points after generated routine
;     KILLS d0-d6/a0-a1
;Generated routine is called with a0=@drawing, a1=@return, d0=0
  include 'GENCLR.S'

  
;*********************************
;****    SHIFT RIGHT SPRITE   ****
;*********************************
;IN   d0=shift in [1;15]
;     a1=@Sprite, 2bpl (starting with SpriteWidth.w , SpriteHeight.w)
;     SpriteWidth must be a multiple of 16
;OUT  KILLS d1-d5/a2
SHRSPR
  move.l      a1,a2
  move.w      (a2)+,d5      ;d5=SpriteWidth (must be a multiple of 16)
  lsr.w       #2,d5         ;d5=nb of bytes per line
  move.w      (a2)+,d1      ;d1=SpriteHeight
SHRSPR_Line
  add.w       d5,a2         ;Start from right
  move.w      d5,d2
  subq.w      #4,d2         ;The last 16 pixels are shifted differently
SHRSPR_Word
  move.w      -6(a2),d3     ;SHR d0 on bpl1
  swap.w      d3
  move.w      -(a2),d3
  lsr.l       d0,d3
  move.w      d3,(a2)
  move.w      -6(a2),d4     ;SHR d0 on bpl0
  swap.w      d4
  move.w      -(a2),d4
  lsr.l       d0,d4
  move.w      d4,(a2)
  subq.w      #4,d2         ;16 pixels rotated
  bne.s       SHRSPR_Word
  swap.w      d3            ;Last block of 16 pixels has 0 coming in
  move.w      d3,-(a2)
  swap.w      d4
  move.w      d4,-(a2)
  add.w       d5,a2         ;Beginning of next line
  subq.w      #1,d1
  bne.s       SHRSPR_Line
  rts

;********************************
;****    SHIFT LEFT SPRITE   ****
;********************************
;IN   d0=shift in [1;15]
;     a1=@Sprite, 2bpl (starting with SpriteWidth.w , SpriteHeight.w)
;     SpriteWidth must be a multiple of 16
;OUT  KILLS d1-d5/a2
SHLSPR
  move.l      a1,a2
  move.w      (a2)+,d5      ;d5=SpriteWidth (must be a multiple of 16)
  lsr.w       #2,d5         ;d5=nb of bytes per line
  move.w      (a2)+,d1      ;d1=SpriteHeight
SHLSPR_Line
  move.w      d5,d2
  subq.w      #4,d2         ;The last 16 pixels are shifted differently
SHLSPR_Word
  move.w      (a2),d3       ;SHL d0 on bpl0
  swap.w      d3
  move.w      4(a2),d3
  lsl.l       d0,d3
  swap.w      d3
  move.w      d3,(a2)+
  move.w      (a2),d4       ;SHL d0 on bpl1
  swap.w      d4
  move.w      4(a2),d4
  lsl.l       d0,d4
  swap.w      d4
  move.w      d4,(a2)+
  subq.w      #4,d2         ;16 pixels rotated
  bne.s       SHLSPR_Word
  swap.w      d3            ;Last block of 16 pixels has 0 coming in
  move.w      d3,(a2)+
  swap.w      d4
  move.w      d4,(a2)+
;  add.w       d5,a2         ;Beginning of next line
  subq.w      #1,d1
  bne.s       SHLSPR_Line
  rts
   
;******************************
;****    DOUBLE X SPRITE   ****
;******************************
;IN   a1=@Sprite, 2bpl (starting with SpriteWidth.w , SpriteHeight.w)
;     SpriteWidth must be a multiple of 32
;OUT  KILLS d0-d4/a2
DBLXSPR
  move.l      a1,a2
  move.w      (a2)+,d0      ;d0=SpriteWidth (must be a multiple of 16)
  lsr.w       #3,d0         ;d0=nb of bytes per line/2
  move.w      (a2)+,d1      ;d1=SpriteHeight
DBLXSPR_Line
  move.l      a2,a3
  add.w       d0,a3
  add.w       d0,a2         ;Start from right
  add.w       d0,a2
  move.w      d0,d2
DBLXSPR_Word
  move.l      -(a3),d3
  move.l      d3,d4
 REPT 16 
  add.l       d3,d3
  addx.l      d5,d5
  add.l       d4,d4
  addx.l      d5,d5
 ENDR
 REPT 16 
  add.l       d3,d3
  addx.l      d6,d6
  add.l       d4,d4
  addx.l      d6,d6
 ENDR
  move.w      d6,-(a2)      ;bpl1, lowerword
  move.w      d5,-(a2)      ;bpl0, lowerword
  swap.w      d6
  move.w      d6,-(a2)      ;bpl1, upperword
  swap.w      d5
  move.w      d5,-(a2)      ;bpl0, upperword
  subq.w      #4,d2         ;32 pixels written
  bne         DBLXSPR_Word
  add.w       d0,a3         ;Beginning of next line
  add.w       d0,a3
  add.w       d0,a2
  add.w       d0,a2
  subq.w      #1,d1
  bne         DBLXSPR_Line
  rts
  
;***********************
;****    COPYSPR    ****
;***********************
;IN   a2=@src
;     a1=@dest
;     d0.w=nb of pixels to append at the end of lines (filled with 0s)
;     d1.l<0 then SPRY is doubled
;OUT  KILLS d0-d5/a3-a4
COPYSPR
  move.l      a1,a4
  move.w      (a2)+,d2
  move.w      (a2)+,d3
  move.w      d2,(a4)
  add.w       d0,(a4)+
  move.w      d3,(a4)+
  tst.l       d1
  bge.s       COPYSPR_Line
  add.w       d3,-2(a4)     ;Double the nb of lines
COPYSPR_Line
  move.w      d2,d4
COPYSPR_Word  
  move.l      (a2)+,(a4)+
  sub.w       #16,d4
  bne.s       COPYSPR_Word
  moveq.l     #0,d5
  move.w      d0,d4
COPYSPR_AppendWords
  sub.w       #16,d4
  blt.s       COPYSPR_NoMoreWordsToAppend
  move.l      d5,(a4)+
  bra.s       COPYSPR_AppendWords
COPYSPR_NoMoreWordsToAppend  
  tst.l       d1
  bge.s       COPYSPR_DonTCopyLine
  
  move.w      d2,d4
  add.w       d0,d4
  lsr.w       #2,d4
  move.l      a4,a3
  sub.w       d4,a3
COPYSPR_CopyLine
  move.l      (a3)+,(a4)+
  subq.w      #4,d4
  bne.s       COPYSPR_CopyLine  
  
COPYSPR_DonTCopyLine  
  subq.w      #1,d3
  bne.s       COPYSPR_Line
  rts
 
;********************
;****    DATA    ****
;********************
    
KikiPalette  
  dc.w $777,$553,$421,$000
  dc.w $333,$553,$421,$000
  dc.w $777,$777,$777,$777
  dc.w $333,$333,$333,$333

  
BlackPalette
 REPT 16
  dc.w  0
 ENDR
  
WhitePalette
  dc.w  $777,$777,$777,$777
  dc.w  $777,$777,$777,$777
  dc.w  $777,$777,$777,$777
  dc.w  $777,$777,$777,$777

WorkAdressesTable
 REPT 2
  dc.l 0      ;@showscreen
  dc.l 0      ;@workscreen
  dc.l 0      ;@ClearData
 ENDR
  dc.l 0 ;Finished by 0 to know we must go back to first screen
  
WorkAdressesPointer
  dc.l    WorkAdressesTable

;25*19
Sprite1
 dc.w 32,19
 dc.w %0000000000010000,%0000000000010000,%0000000000000000,%0000000000000000
 dc.w %0000000000110111,%0000000000110111,%1111000000000000,%1111000000000000
 dc.w %0000000000001000,%0000000000001111,%0000110000000000,%1111110000000000
 dc.w %0000000000010001,%0000000000011110,%1100110000000000,%0011010000000000
 dc.w %0011100000110011,%0011100000111100,%1111111000000000,%0000001000000000
 dc.w %0100010001111011,%0100010001001100,%1111111000000000,%0100101000000000
 dc.w %1000001001100011,%1000001001011100,%1111111000000000,%0100101000000000
 dc.w %1001001001110001,%1001001001011110,%1111111100000000,%0000000100000000
 dc.w %1000110001110011,%1000110001011110,%1111111110000000,%0000000010000000
 dc.w %0100000000110100,%0100000000101111,%1111111110000000,%0000000010000000
 dc.w %0011000001010100,%0011000001111111,%0111111100000000,%1011000100000000
 dc.w %0000111110001111,%0000111111111111,%1111111000000000,%1100111000000000
 dc.w %0000000100010011,%0000000111101110,%1111110000000000,%0000010000000000
 dc.w %0000000100111001,%0000000111001111,%1111100000000000,%1111100000000000
 dc.w %0000001110111100,%0000001111000111,%1001000000000000,%1111000000000000
 dc.w %0000011111111111,%0000010001100100,%1111100000000000,%0100100000000000
 dc.w %0000011111111111,%0000010000011000,%1111100000000000,%0100100000000000
 dc.w %0000001111111111,%0000001000011000,%1111000000000000,%1001000000000000
 dc.w %0000000111110111,%0000000111110111,%1110000000000000,%1110000000000000

;25*26, but in fact 24*26 (left pixels empty)
Sprite2
 dc.w 32,26
 dc.w %0000000000010000,%0000000000010000,%0000000000000000,%0000000000000000
 dc.w %0000000000110111,%0000000000110111,%1111000000000000,%1111000000000000
 dc.w %0000000000001000,%0000000000001111,%0000110000000000,%1111110000000000
 dc.w %0000000000010001,%0000000000011110,%1100110000000000,%0011010000000000
 dc.w %0001110000110011,%0001110000111100,%1111111000000000,%0000001000000000
 dc.w %0010001001111011,%0010001001001100,%1111111000000000,%0100101000000000
 dc.w %0100000101100011,%0100000101011100,%1111111000000000,%0100101000000000
 dc.w %0100100101110001,%0100100101011110,%1111111100000000,%0000000100000000
 dc.w %0100011001110011,%0100011001011110,%1111111110000000,%0000000010000000
 dc.w %0010000000110100,%0010000000101111,%1111111110000000,%0000000010000000
 dc.w %0001100000110100,%0001100000111111,%0111111100000000,%1011000100000000
 dc.w %0000011111001011,%0000011111111111,%1111111000000000,%1100111000000000
 dc.w %0000000010001101,%0000000011111110,%1111110000000000,%0000010000000000
 dc.w %0000000100010011,%0000000111101111,%1111100000000000,%1111100000000000
 dc.w %0000000100111000,%0000000111000111,%0100000000000000,%1100000000000000
 dc.w %0000000100111011,%0000000111001100,%0100000000000000,%1100000000000000
 dc.w %0000000010111011,%0000000011001101,%0100000000000000,%1100000000000000
 dc.w %0000000001111011,%0000000001111111,%0100000000000000,%1100000000000000
 dc.w %0000001101101011,%0000001101101111,%0100000000000000,%1100000000000000
 dc.w %0000011111111011,%0000010010011111,%0100000000000000,%1100000000000000
 dc.w %0000011111111011,%0000010010011111,%0100000000000000,%1100000000000000
 dc.w %0000011111111111,%0000010001110010,%1100000000000000,%0100000000000000
 dc.w %0000011111111111,%0000010001000010,%1100000000000000,%0100000000000000
 dc.w %0000001111111111,%0000001001000010,%1100000000000000,%0100000000000000
 dc.w %0000000110111111,%0000000110100100,%1000000000000000,%1000000000000000
 dc.w %0000000000011011,%0000000000011011,%0000000000000000,%0000000000000000
 
NamePointer
 dc.l Names

NumberOfNamesLeft
  dc.w NBNAMES

;Names are drawn/shifted from right to left and are finished by 255 
Names
;ORGANISERS
 dc.b 114,66,108,30,12,12,30,72,255 ;SKREBBEL  (main orgo)
 dc.b 48,6,132,90,18,0,0,255 ;HAVOC (main orgo)
 dc.b 30,6,108,144,0,0,0,255 ;EARX (compoteam)
 dc.b 90,66,66,54,30,0,0,255 ;OKKIE (bar & breakfast manager)
 dc.b 24,0,36,90,108,18,30,0,255 ;D FORCE (compoteam)
 dc.b 78,6,6,72,54,0,0,255 ;MAALI (compoteam)
 dc.b 120,48,30,0,12,6,120,0,255 ;THE BAT (bar)
 dc.b 84,126,78,120,30,66,0,255 ;NUMTEK  (bar)
 dc.b 120,48,30,0,78,6,120,18,48,255 ;THE MATCH (bar)
 dc.b 78,90,24,0,0,0,0,255 ;MOD (network)
 dc.b 114,54,72,132,30,108,72,6,18,30,255 ;SILVERLA(N)CE (cleaning)
 dc.b 120,54,84,66,30,108,0,255 ;TINKER (bar)
 dc.b 48,6,90,48,78,6,108,126,255 ;HAOHMARU (bar)
 dc.b 36,54,144,6,120,90,0,255 ;FIXATO (cleaning)
 dc.b 156,6,144,30,0,0,0,255 ;ZAXE (bar)
 dc.b 114,48,54,36,120,30,108,0,255 ;SHIFTER (website)
;TICKET
 dc.b 120,138,90,90,84,30,114,54,144,255 ;TWOONESIX
 dc.b 78,30,132,108,90,126,138,255 ;MEVROUW
 dc.b 6,0,120,126,54,84,0,0,255 ;A TUIN
 dc.b 6,72,96,48,6,0,18,0,255 ;ALPHA C
 dc.b 6,78,132,0,0,0,0,255 ;AMV
 dc.b 6,84,24,30,108,30,108,255 ;ANDERER
 dc.b 6,84,60,54,0,0,0,255 ;ANJI
 dc.b 12,6,6,48,0,0,0,255 ;BAAH
 dc.b 12,6,42,42,54,90,0,0,255 ;BAGGIO
 dc.b 12,6,114,114,54,30,0,0,255 ;BASSIE
 dc.b 12,30,30,120,72,30,0,255 ;BEETLE
 dc.b 12,30,120,6,0,0,0,255 ;BETA
 dc.b 12,54,6,84,18,30,0,255 ;BIANCE
 dc.b 12,90,12,0,84,54,78,12,30,255 ;BOB NIMBE
 dc.b 12,90,84,126,114,0,0,255 ;BONUS
 dc.b 12,108,126,18,30,0,0,255 ;BRUCE
 dc.b 12,126,24,0,0,0,0,255 ;BUD
 dc.b 18,6,72,0,0,0,0,255 ;CAL
 dc.b 18,48,30,30,114,150,0,255 ;CHEESY
 dc.b 18,48,30,78,78,6,24,255 ;CHEMMAD
 dc.b 18,48,108,54,114,0,0,255 ;CHRIS
 dc.b 18,48,126,18,66,0,0,255 ;CHUCK
 dc.b 18,54,48,0,0,0,0,255 ;CIH
 dc.b 18,54,84,24,30,108,0,255 ;CINDER
 dc.b 18,90,114,78,54,102,0,255 ;COSMIQ
 dc.b 18,150,18,72,90,84,30,255 ;CYCLONE
 dc.b 18,150,108,30,144,0,0,255 ;CYREX
 dc.b 24,6,6,84,0,0,0,255 ;DAAN
 dc.b 24,6,84,0,0,0,0,255 ;DAN
 dc.b 24,30,30,156,0,0,0,255 ;DEEZ
 dc.b 24,30,72,120,6,36,54,108,30,255 ;DELTAFIRE
 dc.b 24,30,150,120,6,0,0,255 ;DEYTA
 dc.b 24,54,96,114,138,54,120,18,48,255 ;DIPSWITCH
 dc.b 24,54,144,6,84,0,0,255 ;DIXAN
 dc.b 24,60,30,36,66,30,0,255 ;DJEFKE
 dc.b 24,78,6,0,114,18,0,0,255 ;DMA SC
 dc.b 24,138,6,108,36,0,0,255 ;DWARF
 dc.b 30,72,36,6,84,0,0,255 ;ELFAN
 dc.b 36,6,108,36,6,108,0,255 ;FARFAR
 dc.b 36,6,144,30,0,0,0,255 ;FAXE
 dc.b 36,30,72,54,18,30,0,0,255 ;FELICE
 dc.b 36,108,6,84,66,150,0,255 ;FRANKY
 dc.b 42,6,114,78,6,84,0,255 ;GASMAN
 dc.b 42,30,108,6,108,24,0,255 ;GERARD
 dc.b 42,42,84,0,0,0,0,255 ;GGN
 dc.b 42,72,90,138,0,0,0,255 ;GLOW
 dc.b 42,108,6,156,30,150,0,255 ;GRAZEY
 dc.b 42,138,30,78,0,0,0,255 ;GWEM
 dc.b 48,120,138,90,90,0,0,255 ;HTWOO
 dc.b 48,12,0,0,0,0,0,255 ;HB
 dc.b 48,30,84,18,90,144,0,255 ;HENCOX
 dc.b 48,90,84,66,30,150,0,255 ;HONKEY
 dc.b 54,72,72,78,0,0,0,255 ;ILLM
 dc.b 54,84,114,6,84,30,0,255 ;INSANE
 dc.b 54,84,114,120,108,30,6,78,255 ;INSTREAM
 dc.b 54,156,6,108,24,0,0,255 ;IZARD
 dc.b 60,6,150,0,0,0,0,255 ;JAY
 dc.b 60,126,54,18,30,0,0,255 ;JUICE
 dc.b 60,126,84,42,72,6,48,0,255 ;JUNGLAH
 dc.b 66,72,6,126,24,54,6,72,30,90,255 ;KLAUDIALEO
 dc.b 66,90,66,66,54,30,0,0,255 ;KOKKIE
 dc.b 66,108,54,78,12,72,30,0,255 ;KRIMBLE
 dc.b 66,108,126,96,66,6,60,0,255 ;KRUPKAJ
 dc.b 66,126,108,72,54,0,0,0,255 ;KURLI
 dc.b 66,126,108,90,120,90,0,255 ;KUROTO
 dc.b 66,126,114,78,6,0,0,255 ;KUSMA
 dc.b 72,18,36,0,0,0,0,255 ;LCF
 dc.b 72,54,84,18,90,72,84,0,255 ;LINCOLN
 dc.b 72,90,6,24,30,108,108,90,108,255 ;LOADERROR
 dc.b 72,90,120,30,66,0,0,255 ;LOTEK
 dc.b 78,6,24,30,84,78,6,84,84,255 ;MADENMANN
 dc.b 78,6,108,6,66,6,78,6,84,255 ;MARAKAMAN
 dc.b 78,30,72,0,0,0,0,255 ;MEL
 dc.b 78,30,72,138,150,84,0,255 ;MELWYN
 dc.b 78,54,18,66,108,90,0,255 ;MICKRO
 dc.b 78,72,30,54,84,0,0,255 ;MLEIN
 dc.b 84,6,78,30,0,0,0,255 ;NAME
 dc.b 84,30,78,30,114,54,114,255 ;NEMESIS
 dc.b 84,30,90,0,0,0,0,255 ;NEO
 dc.b 84,30,108,132,30,0,0,255 ;NERVE
 dc.b 84,54,18,90,0,0,0,255 ;NICO
 dc.b 84,120,0,0,0,0,255 ;NT
 dc.b 96,6,84,0,0,0,0,255 ;PAN
 dc.b 96,6,84,24,126,108,0,255 ;PANDUR
 dc.b 96,6,108,6,84,90,54,24,255 ;PARANOID
 dc.b 96,6,108,120,150,18,72,30,255 ;PARTYCLE
 dc.b 96,12,114,0,0,0,0,255 ;PBS
 dc.b 96,30,96,0,0,0,0,255 ;PEP
 dc.b 108,6,0,0,0,0,0,255 ;RA
 dc.b 108,6,114,96,126,120,54,84,6,255 ;RASPUTINA
 dc.b 108,30,84,48,90,30,66,255 ;RENHOEK
 dc.b 108,54,18,48,6,108,24,0,255 ;RICHARD
 dc.b 108,90,12,30,108,120,0,255 ;ROBERT
 dc.b 114,6,84,24,30,108,0,255 ;SANDER
 dc.b 114,6,84,120,6,0,0,255 ;SANTA
 dc.b 114,6,120,126,0,0,0,255 ;SATU
 dc.b 114,30,24,78,6,0,0,255 ;SEDMA
 dc.b 114,48,120,48,108,30,30,255 ;SHTHREE
 dc.b 114,48,6,108,66,150,0,255 ;SHARKY
 dc.b 114,54,54,138,0,0,0,255 ;SIIW
 dc.b 114,54,108,54,126,114,0,0,255 ;SIRIUS
 dc.b 114,60,90,84,84,150,0,255 ;SJONNY
 dc.b 114,78,90,90,120,48,114,162,255 ;SMOOTHS[
 dc.b 114,90,72,30,84,90,54,24,255 ;SOLENOID
 dc.b 114,96,6,108,66,72,30,0,255 ;SPARKLE
 dc.b 114,102,138,6,108,24,0,255 ;SQWARD
 dc.b 114,120,30,6,78,0,0,255 ;STEAM
 dc.b 114,120,0,42,48,90,114,120,255 ;ST GHOST
 dc.b 114,120,126,0,0,0,0,255 ;STU
 dc.b 114,150,84,120,30,30,114,54,255 ;SYNTEESI
 dc.b 120,48,30,18,0,0,0,255 ;THEC
 dc.b 120,48,90,108,84,0,0,255 ;THORN
 dc.b 120,54,78,0,0,0,0,255 ;TIM
 dc.b 120,54,78,12,108,6,72,0,255 ;TIMBRAL
 dc.b 120,66,0,0,0,0,0,255 ;TK
 dc.b 120,78,18,0,0,0,0,255 ;TMC
 dc.b 120,90,6,24,0,0,0,255 ;TOAD
 dc.b 120,90,78,0,0,0,0,255 ;TOM
 dc.b 120,90,96,150,0,0,0,255 ;TOPY
 dc.b 120,150,96,48,90,90,84,255 ;TYPHOON
 dc.b 126,66,66,90,0,0,0,255 ;UKKO
 dc.b 132,54,114,126,6,72,54,18,30,255 ;VISUALICE
 dc.b 138,6,36,36,72,30,0,255 ;WAFFLE
 dc.b 138,6,108,48,30,6,24,255 ;WARHEAD
 dc.b 138,54,156,120,90,78,0,255 ;WIZTOM
 dc.b 144,54,0,0,0,0,0,255 ;XI
 dc.b 150,30,120,54,0,0,0,255 ;YETI
 dc.b 156,30,108,66,78,6,84,255 ;ZERKMAN
 dc.b 90,156,114,48,6,24,90,138,255 ;OZSHADOW
 
 even
  
;for each char: width, then 5*line data
Fonts
 dc.b 3,%00000000,%00000000,%00000000,%00000000,%00000000 ; =0*6
 dc.b 5,%00000110,%00001001,%00001001,%00001111,%00001001 ;A=1*6
 dc.b 5,%00001110,%00001001,%00001110,%00001001,%00001110 ;B=2*6
 dc.b 5,%00000111,%00001000,%00001000,%00001000,%00000111 ;C=3*6
 dc.b 5,%00001110,%00001001,%00001001,%00001001,%00001110 ;D=4*6
 dc.b 5,%00001111,%00001000,%00001100,%00001000,%00001111 ;E=5*6
 dc.b 5,%00001111,%00001000,%00001100,%00001000,%00001000 ;F=6*6
 dc.b 5,%00000111,%00001000,%00001011,%00001001,%00000111 ;G=7*6
 dc.b 5,%00001001,%00001001,%00001111,%00001001,%00001001 ;H=8*6
 dc.b 4,%00000111,%00000010,%00000010,%00000010,%00000111 ;I=9*6
 dc.b 5,%00000111,%00000001,%00000001,%00001001,%00000110 ;J=10*6
 dc.b 5,%00001001,%00001010,%00001100,%00001010,%00001001 ;K=11*6
 dc.b 4,%00000100,%00000100,%00000100,%00000100,%00000111 ;L=12*6
 dc.b 6,%00010001,%00011011,%00010101,%00010001,%00010001 ;M=13*6
 dc.b 6,%00010001,%00011001,%00010101,%00010011,%00010001 ;N=14*6
 dc.b 5,%00000110,%00001001,%00001001,%00001001,%00000110 ;O=15*6
 dc.b 5,%00001110,%00001001,%00001110,%00001000,%00001000 ;P=16*6
 dc.b 6,%00001110,%00010001,%00010101,%00010011,%00001111 ;Q=17*6
 dc.b 5,%00001110,%00001001,%00001110,%00001001,%00001001 ;R=18*6
 dc.b 5,%00000111,%00001000,%00000110,%00000001,%00001110 ;S=19*6
 dc.b 6,%00011111,%00000100,%00000100,%00000100,%00000100 ;T=20*6
 dc.b 5,%00001001,%00001001,%00001001,%00001001,%00000110 ;U=21*6
 dc.b 6,%00010001,%00010001,%00001010,%00001010,%00000100 ;V=22*6
 dc.b 6,%00010001,%00010001,%00010101,%00011011,%00010001 ;W=23*6
 dc.b 6,%00010001,%00001010,%00000100,%00001010,%00010001 ;X=24*6
 dc.b 6,%00010001,%00001010,%00000100,%00000100,%00000100 ;Y=25*6
 dc.b 6,%00011111,%00000010,%00000100,%00001000,%00011111 ;Z=26*6=156
 dc.b 2,%00000000,%00000000,%00000000,%00000000,%00000001 ;.=27*6=162
    
;x,y*128,vy*128,tireness,vx,sprite_nb*2*16*8,(name_nb+NBSPRITES)*16*8,tireness_reinit
KikiData
  dc.w -290,0,0, 5,1,2*16*8, (0+4)*16*8, 5 ;main orgo
  dc.w -280,0,0, 5,1,2*16*8, (1+4)*16*8, 7 ;main orgo
  dc.w    0,0,0, 5,1,     0, (2+4)*16*8,20
  dc.w  -10,0,0, 7,1,     0, (3+4)*16*8,10
  dc.w  -20,0,0, 6,1,     0, (4+4)*16*8,15
  dc.w  -30,0,0,10,1,     0, (5+4)*16*8,20
  dc.w  -40,0,0, 9,1,     0, (6+4)*16*8,20
  dc.w  -50,0,0, 8,1,     0, (7+4)*16*8,10
  dc.w  -60,0,0, 7,1,     0, (8+4)*16*8,15
  dc.w  -70,0,0, 6,1,     0, (9+4)*16*8,20
  dc.w  -80,0,0,10,1,     0,(10+4)*16*8,20
  dc.w  -90,0,0, 9,1,     0,(11+4)*16*8,10
  dc.w -100,0,0, 8,1,     0,(12+4)*16*8,15
  dc.w -110,0,0, 7,1,     0,(13+4)*16*8,20
  dc.w -120,0,0, 6,1,     0,(14+4)*16*8,20
  dc.w -130,0,0,10,1,     0,(15+4)*16*8,10 ;last orgo
  
  dc.w -500,0,0, 9,1,     0,(16+4)*16*8,15
  dc.w -500,0,0, 9,1,     0,(17+4)*16*8,15
  dc.w -500,0,0, 9,1,     0,(18+4)*16*8,12
  dc.w -500,0,0, 9,1,     0,(19+4)*16*8,20
  dc.w -700,0,0, 9,2,     0,(20+4)*16*8,13
  dc.w -700,0,0, 9,2,     0,(21+4)*16*8,14
  dc.w -700,0,0, 9,2,     0,(22+4)*16*8,16
  
  dc.w  -16,0,0,7,1,0,(23+4)*16*8,7
  dc.w  -21,0,0,6,1,0,(24+4)*16*8,6
  dc.w  -3,0,0,10,1,0,(25+4)*16*8,10
  dc.w  -8,0,0,9,2,0,(26+4)*16*8,9
  dc.w  -13,0,0,8,1,0,(27+4)*16*8,8
  dc.w  -18,0,0,7,2,0,(28+4)*16*8,7
  dc.w  -23,0,0,6,1,0,(29+4)*16*8,6

;**** EMPTY CLR ROUTINE ****  
EmptyClearRoutine
  jmp (a1)  

OldConfig   
colors: ds.w 16
VideoRamAdress: ds.l  1
ResAndMFP: ds.b 4
HBlVector: ds.l 1
  
KikiClearData0
 REPT NBKIKIS*2
  dc.l  0
  dc.l  EmptyClearRoutine
 ENDR
  
KikiClearData1
 REPT NBKIKIS*2
  dc.l  0
  dc.l  EmptyClearRoutine
 ENDR

Music:        incbin 'frankiki.snd'
BackGround:   incbin 'backg.doo'

  ds.b 256-34     ;for alignement
Title:      incbin 'title.pi1'

  SECTION BSS

FadePalette:  ds.w 16*33
AdressesSpritesRoutines: ds.l 16*2*(NBSPRITES+NBNAMES)
SpritesRoutines: ds.l 500000/4
