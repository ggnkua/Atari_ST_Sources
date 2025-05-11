          ;****** STARBATTLE *******  Written 1989 by Daniel Hanelt & Lars Offe

          ; Parameterblock Spritedaten:
          ;    a1 :   Anzahl        .w
          ; $2(a1):   x-Ausdehnung  .w
          ; $4(a1):   y-Ausdehnung  .w
          ; $6(a1):   Daten...      .l

          ; Parameterblock Spr
          ;    a1 :   Set_flag      .w
          ; $2(a1):   Spritehoehe   .w
          ; $4(a1):   x-pos         .w
          ; $6(a1):   y-pos         .w
          ; $8(a1):   Summand       .w
          ; $a(a1):   x-Ausdehnung  .w
          ; $c(a1):   Wertadresse   .l
          ; $10(a1):  L”schadresse  .l
          ; $14(a1):  Zieladresse   .l

          .DC.w $a00a

          .MACRO copy
          movem.l   (a5),d3-d7/a0-a4
          movem.l   d3-d7/a0-a4,(a6)
          lea.l     -80(a5),a5
          lea.l     -80(a6),a6
          .ENDM 

          .MACRO print
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp
          .ENDM 

          bsr       init_joy

          ; ********************************* SETBLOCK
          movea.l   sp,a5
          movea.l   #stack,sp
          movea.l   4(a5),a5
          move.l    $c(a5),d0
          add.l     $14(a5),d0
          add.l     $1c(a5),d0
          addi.l    #$100,d0
          move.l    d0,-(sp)
          move.l    a5,-(sp)
          move.w    #0,-(sp)
          move.w    #$4a,-(sp)
          trap      #1
          lea.l     12(sp),sp
          tst.l     d0
          bne       quit

          move.w    #2,-(sp)
          trap      #14
          addq.w    #2,sp
          move.l    d0,physbase
          move.l    d0,xbios2

          move.l    #log_adr,d0
          andi.l    #%11111111111111111111111100000000,d0
          move.l    d0,logbase

          movea.l   #param,a1
          movea.l   #shapes,a6
          movea.l   #spr_puf,a5
loop:     
          move.w    (a6)+,anzahl

          cmpi.w    #0,anzahl
          beq       weiter

          move.w    (a6)+,d4
          move.w    (a6)+,d5

          move.l    a5,wertadr

          move.w    d5,d7
          lsl.w     #2,d7
          subq.w    #1,d5

          move.w    #16,d3
next_block:         
          move.w    d5,d2

          movea.l   a6,a4
          movea.l   a4,a3
          adda.w    d7,a3

shift_spr:          
          move.w    #16,d1
          sub.w     d3,d1

          move.l    (a3),d0
          lsr.l     d1,d0
          not.l     d0
          move.l    d0,(a5)+

          move.l    (a4),d0
          lsr.l     d1,d0
          move.l    d0,(a5)+

          move.w    $2(a3),d0
          lsl.w     d3,d0
          not.w     d0
          move.w    d0,(a5)+

          move.w    $2(a4),d0
          lsl.w     d3,d0
          move.w    d0,(a5)+

          lea.l     4(a3),a3
          lea.l     4(a4),a4

          dbra      d2,shift_spr

          subq.w    #1,d3
          cmpi.w    #0,d3
          bgt       next_block

          move.l    a5,loeschadr
          move.w    d5,d1
          mulu      #192,d1
          adda.w    d1,a5

          move.l    #1,d6
          add.w     d5,d6
          mulu      #6,d6
          move.w    d6,d3
          lsl.w     #1,d3

          move.w    anzahl,d1
          subi.w    #1,d1
mehr_sprites:       
          clr.w     (a1)
          move.w    d5,$2(a1)
          move.w    d3,$8(a1)
          move.w    d4,$a(a1)

          move.l    wertadr,$c(a1)
          move.l    loeschadr,$10(a1)
          add.l     d6,loeschadr
          lea.l     32(a1),a1

          dbra      d1,mehr_sprites

          lsl.w     #1,d7
          adda.w    d7,a6

          bra       loop
weiter:   
          bsr       switch

          ; ********************************* Set_chars
          pea       numbers
          print 

          movea.l   logbase,a0
          adda.l    #12810,a0
          movea.l   #char,a1
          move.w    #10,d7
put_char: 
          move.w    #15,d6
get_line: 
          move.b    (a0),(a1)+
          lea.l     80(a0),a0

          dbra      d6,get_line
          suba.l    #1279,a0
          dbra      d7,put_char
          ;***

          ;** Clear_Highscore

          movea.l   #scores,a1
          move.w    #10,d7
clr_h:    clr.l     (a1)+
          dbra      d7,clr_h

          movea.l   #names,a1
          move.w    #300,d7
clr_n:    move.b    #32,(a1)+
          dbra      d7,clr_n

          move.w    #0,-(sp)  ;Anzeige lesen
          pea       anz_name
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,d1
          ;
          pea       anz_puf
          move.l    #16000,-(sp)
          move.w    d1,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea.l     $c(sp),sp
          ;
          move.w    d1,-(sp)
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

          bsr       read_high

b_high:   move.w    #1,start
          bsr       init_screen
begin:    
          ; ********************************* SET-SCREEN
          cmpi.w    #1,start
          beq       new

          cmpi.w    #1,complete
          beq       over1

          pea       message1
          print 
          bra       over2
over1:    bsr       switch
          pea       success
          print 
          bsr       switch
          move.w    #2999,d7
inc_scr:  addi.l    #1,score
          bsr       show_score
          dbra      d7,inc_scr
          clr.w     complete
          pea       success
          print 

over2:    pea       message2
          print 
          bra       n_m3
new:      pea       message3
          print 
n_m3:     
          bsr       switch

          move.w    #2,-(sp)
          move.w    #2,-(sp)
          trap      #13
          addq.l    #4,sp
          cmpi.w    #0,start
          bne       n_high

          bsr       high_score
n_high:   bsr       read_levels
          bsr       init_screen

          clr.w     start
          pea       leveltxt
          print 

          move.l    level,d0
          move.w    #12829,d1
          bsr       dez_aus

          ;********************************** MAIN-LOOP **********************
          move.l    backdat,datp
          movea.l   datp,a0
          clr.w     ex_sh

          clr.l     timer
          clr.w     game_timer
          movea.l   #param,a0
          move.w    #2,(a0)
          move.l    44(a0),12(a0)
          move.w    #144,$4(a0)
          move.w    #340,$6(a0)

          bra       first_jump
main:               ; ********************* BEGIN LOOP
          subi.l    #4,timer
          cmpi.l    #0,timer
          bge       sprung1

          addi.l    #10,datp
          move.l    #124,timer
sprung1:  
          move.l    logbase,scrlb
          addi.l    #80,scrlb

          movea.l   physbase,a5
          movea.l   scrlb,a6
          bsr       scrolling

          bsr       clear_sprites

first_jump:         
          move.w    #-1,-(sp)
          move.w    #$b,-(sp)
          trap      #13
          addq.l    #4,sp

          btst      #0,d0
          beq       n_quit

links:    btst      #1,d0
          bne       quit

n_quit:   btst      #3,d0
          beq       no_shield

          move.w    #1,shieldflag
          move.w    #160,shield_timer
          movea.l   #param,a0
          move.l    76(a0),12(a0)
          ; **********************
no_shield:          
          cmpi.w    #0,deadflag
          bgt       no_steuern

          bsr       steuern
          bra       alive
no_steuern:         
          movea.l   #param,a2
          bsr       not_mo
          subi.w    #1,deadflag
          cmpi.w    #0,deadflag
          bgt       alive

          movea.l   #param,a1
          move.w    #144,$4(a1)
          move.w    #340,$6(a1)
          bsr       clr_alien
          clr.w     deadflag

          cmpi.w    #0,lifes
          beq       begin

          movea.l   #param,a0
          move.l    108(a0),12(a0)

          bsr       set_sprites
          bsr       switch

          move.l    #0,d1
lop0:     addi.l    #1,d1
          cmpi.l    #200000,d1
          bls       lop0

          move.w    #1,shieldflag
          move.w    #64,shield_timer

          bra       dead_jump
alive:    
          bsr       set_feinde

          movea.l   #param,a0
          move.l    #6,d0
          bsr       kollosion

          cmpi.b    #6,d0
          bne       no_exlife
          addi.w    #1,lifes
          move.w    #32,shield
          move.b    #1,(a1)   ;***** Extraleben
          move.l    #1,d0
          bsr       put_field
          bsr       show_lifes

no_exlife:          
          cmpi.b    #7,d0
          bne       no_exshoot
          move.w    #1,ex_sh
          move.b    #1,(a1)
          move.l    #1,d0
          bsr       put_field

no_exshoot:         
          cmpi.b    #8,d0
          bne       no_refresh
          move.w    #2784,fuel
          move.b    #1,(a1)
          move.l    #1,d0
          bsr       put_field

no_refresh:         
          cmpi.b    #2,d0
          blt       ok
          bsr       delete_shield
ok:       
          subq.w    #1,fuel
          move.w    fuel,d7
          bsr       show_fuel
not_fuel: 
          cmpi.w    #0,shield_timer
          beq       w_main

          subi.w    #1,shield_timer

          cmpi.w    #1,shieldflag
          bne       not_shield
          subi.w    #4,fuel
          bra       sprA

not_shield:         
          movea.l   #param,a1
          move.l    12(a1),d0
          cmp.l     44(a1),d0
          beq       set_ship
          move.l    44(a1),12(a1)
          bra       sprA
set_ship: 
          move.l    76(a1),12(a1)
sprA:     
          cmpi.w    #1,shield_timer
          bgt       w_main

          clr.w     shield_timer
          clr.w     shieldflag
          movea.l   #param,a1
          move.l    44(a1),12(a1)
w_main:   
          addq.w    #1,game_timer
          move.w    max_timer,d6
          sub.w     game_timer,d6
          move.w    d6,lev_ch

          cmpi.w    #1,d6
          bne       no_levchange

          pea       leveltxt
          print 
          addi.l    #100,score

          addi.l    #1,level
          move.l    level,d0
          move.w    #12829,d1
          bsr       dez_aus

          movea.l   #param,a1
          bsr       clr_alien

no_levchange:       

          bsr       set_sprites
          bsr       switch

dead_jump:          
          move.w    #37,-(sp)
          trap      #14       ; VSYNC
          addq.l    #2,sp

          cmpi.w    #1,lev_ch
          bgt       main


          ; ********************************* Next Level
          move.w    #2784,fuel

          movea.l   #fname,a0
          addq.b    #1,6(a0)
          bsr       read_levels
          clr.w     game_timer

          move.l    backdat,datp
          bra       main

quit:     
          pea       joy_quit
          move.w    #0,-(sp)
          move.w    #25,-(sp)
          trap      #14
          lea.l     8(sp),sp

          move.w    #34,-(sp)
          trap      #14
          lea.l     2(sp),sp
          movea.l   d0,a0
          move.l    old_stick,24(a0)


          move.l    xbios2,logbase
          move.l    xbios2,physbase
          bsr       switch
          clr.l     (sp)
          trap      #1


          ; ************************************ STEUERN *********************
steuern:  
          movea.l   #param,a2
          movea.l   #joy1,a0
          move.b    (a0),d0

          btst      #3,d0
          beq       not_r
          cmpi.w    #290,$4(a2)
          bhi       not_r
          addq.w    #3,$4(a2)
not_r:    btst      #2,d0
          beq       not_l
          cmpi.w    #2,$4(a2)
          blt       not_l
          subq.w    #3,$4(a2)
not_l:    btst      #1,d0
          beq       not_u
          cmpi.w    #360,$6(a2)
          bhi       not_u
          addq.w    #3,$6(a2)
not_u:    btst      #0,d0
          beq       not_d
          cmpi.w    #140,$6(a2)
          blt       not_d
          subq.w    #3,$6(a2)
not_d:    
          ; ********************************* Schuž
          cmpi.w    #0,sht_timer
          beq       shoot
          subq.w    #1,sht_timer
          bra       not_mo
shoot:    
          movea.l   #joy1,a3
          btst.b    #7,(a3)
          beq       not_mo

          movea.l   a2,a6
          lea.l     128(a6),a6
          movea.l   #feindpar,a3

          move.w    #3,d4

schleife1:          
          cmpi.w    #0,(a6)
          bne       weiter1

          move.w    #2,(a6)
          move.w    #-10,(a3)
          move.w    $4(a2),$4(a6)
          move.w    $6(a2),$6(a6)
          addi.w    #9,$4(a6)
          subi.w    #9,$6(a6)

          cmpi.w    #0,ex_sh
          bne       extend_shoot

          move.w    #-10,(a3)
          move.w    #5,sht_timer
          bra       no_extend
extend_shoot:       
          move.w    #-16,(a3)
          move.w    #4,sht_timer
no_extend:          
          move.l    #schuss,d0
          bsr       sound

          bra       not_mo
weiter1:  
          adda.w    #32,a6
          adda.w    #16,a3
          dbra      d4,schleife1
not_mo:   
          movea.l   a2,a6
          lea.l     128(a6),a6
          movea.l   #feindpar,a3
          move.w    #3,d6
schleife: 
          move.w    (a3),d0
          add.w     d0,$6(a6)

          cmpi.w    #0,(a6)
          beq       next_sh

          cmpi.w    #384,$6(a6)
          bgt       clr_s
          cmpi.w    #0,$6(a6)
          bgt       sh_go
clr_s:    
          clr.w     (a6)
          bra       next_sh
sh_go:    
          movea.l   a2,a5
          bsr       test_kol
          cmpi.w    #1,d2
          blt       no_expl
          bsr       delete_shield
no_expl:  
          movea.l   a6,a0
          move.l    #2,d0
          bsr       kollosion
          cmpi.b    #3,d0
          bne       no_block

          clr.w     (a6)
          move.b    #2,(a1)

          move.l    #2,d0
          bsr       put_field

          move.l    #explosion,d0
          bsr       sound

          addi.l    #1,score
          bsr       show_score

          bra       next_sh
no_block: 
          cmpi.b    #4,d0
          bne       no_block2
          clr.w     (a6)
          bra       next_sh
no_block2:          
          cmpi.b    #5,d0
          bne       no_reflekt
          move.w    #5,(a3)
no_reflekt:         
          movea.l   a2,a5
          lea.l     640(a5),a5
          movea.l   #feindpar,a4
          lea.l     224(a4),a4
          move.w    #20,d7
test_feind:         
          bsr       test_kol
          cmpi.w    #1,d2
          blt       no_treffer

          move.l    #explosion,d0
          bsr       sound

          move.l    #27,d0
          sub.w     d7,d0
          divu      #7,d0
          mulu      #10,d0
          add.l     d0,score
          bsr       show_score

          move.w    #1,(a5)
          move.l    588(a2),$c(a5)
          move.w    #12,14(a4)

          clr.w     (a6)
          bra       next_sh
no_treffer:         
          lea.l     32(a5),a5
          lea.l     16(a4),a4
          dbra      d7,test_feind
next_sh:  
          adda.w    #32,a6
          adda.w    #16,a3
          dbra      d6,schleife
          rts       

          ; ********************************* Kollosion
kollosion:          
          movem.l   d3-d7/a2-a6,-(sp)

          move.w    d0,d1
          add.w     $4(a0),d1
          move.w    d0,d2
          add.w     $6(a0),d2

          lsl.w     #1,d0
          movea.w   $a(a0),a4
          suba.w    d0,a4
          movea.w   $2(a0),a5
          suba.w    d0,a5
          move.l    timer,d5

          clr.w     d4
          move.l    #1,d7
y_kl:     
          clr.w     d3
          move.l    #1,d6
x_kl:     
          movea.l   datp,a1
          move.w    d1,d0
          add.w     d3,d0
          lsr.w     #5,d0
          adda.l    d0,a1

          move.w    d5,d0
          lsr.w     #2,d0
          add.w     d2,d0
          add.w     d4,d0
          lsr.w     #5,d0
          mulu      #10,d0
          suba.l    d0,a1
          move.b    (a1),d0
          cmpi.b    #2,d0
          bgt       touched

          add.w     a4,d3
          dbra      d6,x_kl
          add.w     a5,d4
          dbra      d7,y_kl
          clr.w     d0
touched:  
          movem.l   (sp)+,d3-d7/a2-a6
          rts       

          ;******************************* FEINDE ****************************
          ;                     Parameterblock:
          ;    Tempo      .w   (2-3)                a3
          ;    Frequenz   .w   (1-3)              2(a3)
          ;    Amplitude  .w   (1,2)              4(a3)
          ;    x-Achse    .w                      6(a3)
          ;    Sin-pointer.l                      8(a3)  bzw. Schužtimer
          ;    x-Addition .w                     12(a3)
          ;    Dead-Timer .w                     14(a3)

set_feinde:         
          movea.l   #param,a5

          ;******************************** Wave-Riders
feinde0:  
          movea.l   a5,a4
          lea.l     640(a4),a4
          move.l    a4,remem
          movea.l   #feindpar,a3
          lea.l     224(a3),a3
          move.w    #6,d7

          move.w    #1,d0
          bsr       feind_check

f_loop0:  
          cmpi.w    #0,(a4)
          bne       bewegen0

          cmpi.w    #0,fcheck
          bne       nextf0

          cmp.w     fzahl,d7
          bgt       nextf0

          move.w    #1,d0
          bsr       random256
          cmpi.w    #255,d0
          blt       nextf0

          move.w    #2,(a4)
          clr.w     $6(a4)

          move.w    #128,d0
          bsr       random256
          addq.w    #1,d0
          move.w    d0,(a3)

          move.w    #128,d0
          bsr       random256
          move.w    d0,$2(a3)

          move.w    #85,d0
          bsr       random256
          move.w    d0,$4(a3)

          move.w    #96,$6(a3)
          move.w    #2,d0
          bsr       random256
          add.w     d0,$6(a3)

          clr.w     $8(a3)
bewegen0: 
          movea.l   #sintab,a2

          move.w    $6(a3),d5
          cmpi.w    #180,$8(a3)
          bne       lt_180
          clr.w     $8(a3)
lt_180:   
          clr.w     d4
          adda.w    $8(a3),a2
          cmpi.w    #90,$8(a3)
          bgt       gt_90
          move.b    (a2),d4
          lsr.b     #1,d4
          add.w     d4,d5
          bra       lt_90
gt_90:    
          suba.l    #90,a2
          move.b    (a2),d4
          lsr.b     #1,d4
          sub.w     d4,d5
lt_90:    
          move.w    d5,$4(a4)
          move.w    (a3),d0
          add.w     d0,$6(a4)
          move.w    $2(a3),d0
          add.w     d0,$8(a3)
          cmpi.w    #180,$8(a3)
          bne       aha
          clr.w     $8(a3)
aha:      
          bsr       test_feindexpl

          ;***

          cmpi.w    #400,$6(a4)
          blt       nextf0
          clr.w     (a4)
nextf0:   
          lea.l     32(a4),a4
          lea.l     16(a3),a3
          subi.w    #1,d7
          cmpi.w    #0,d7
          bgt       f_loop0

          ;******************************** Bouncing Balls
feinde1:  
          movea.l   a5,a4
          lea.l     864(a4),a4
          move.l    a4,remem
          movea.l   #feindpar,a3
          lea.l     336(a3),a3
          move.w    #6,d7

          move.w    #2,d0
          bsr       feind_check
f_loop1:  
          cmpi.w    #0,(a4)
          bne       bewegen1

          cmpi.w    #0,fcheck
          bne       nextf1

          cmp.w     fzahl,d7
          bgt       nextf1

          move.w    #1,d0
          bsr       random256
          cmpi.w    #255,d0
          blt       nextf1

          move.w    #2,(a4)
          clr.w     $6(a4)

          move.w    #1,d0
          bsr       random256
          addi.w    #8,d0
          move.w    d0,$4(a4)

          move.w    #2,(a3)

          move.w    #4,12(a3)
          move.w    #1,d0
          bsr       random256
          cmpi.w    #128,d0
          bgt       bewegen1
          neg.w     12(a3)
bewegen1: 
          cmpi.w    #286,$4(a4)
          blt       nneg1
          neg.w     12(a3)
nneg1:    
          cmpi.w    #4,$4(a4)
          bgt       nneg2
          neg.w     12(a3)
nneg2:    
          move.w    12(a3),d0
          add.w     d0,$4(a4)

          move.w    (a3),d0
          add.w     d0,$6(a4)

          bsr       test_feindexpl

          cmpi.w    #400,$6(a4)
          blt       nextf1
          clr.w     (a4)
nextf1:   
          lea.l     32(a4),a4
          lea.l     16(a3),a3
          subi.w    #1,d7
          cmpi.w    #0,d7
          bgt       f_loop1

          ;******************************** Shooting Ship
feinde2:  
          movea.l   a5,a4
          lea.l     1088(a4),a4
          move.l    a4,remem
          movea.l   #feindpar,a3
          lea.l     448(a3),a3
          move.w    #6,d7

          move.w    #3,d0
          bsr       feind_check
f_loop2:  
          cmpi.w    #0,(a4)
          bne       bewegen2

          cmpi.w    #0,fcheck
          bne       nextf2

          cmp.w     fzahl,d7
          bgt       nextf2

          move.w    #1,d0
          bsr       random256
          cmpi.w    #255,d0
          blt       nextf2

          move.w    #2,(a4)
          clr.w     $6(a4)
          move.w    #2,(a3)

          move.w    #1,d0
          bsr       random256
          move.w    d0,$4(a4)

          clr.w     12(a3)
bewegen2: 
          cmpi.w    #286,$4(a4)
          bgt       s_gt
          cmpi.w    #1,$4(a4)
          blt       lower_one

          move.w    $4(a5),d1
          move.w    $4(a4),d2

          sub.w     d1,d2

          cmpi.w    #6,d2
          bgt       s_gt

          cmpi.w    #-6,d2
          bgt       s_lt
lower_one:          
          move.w    #1,12(a3)
          bra       s_lt
s_gt:     
          move.w    #-1,12(a3)
s_lt:     

          ; ******* Schiessen ***

          cmpi.w    #0,8(a3)
          beq       sht_ok

          subi.w    #1,8(a3)
          bra       shoot_ready
sht_ok:   
          move.w    #26,8(a3)

          movea.l   a5,a6
          lea.l     352(a6),a6

          move.w    #6,d6
feind_shoot:        
          cmpi.w    #2,(a6)
          beq       not_fre

          move.w    #2,(a6)
          move.w    $4(a4),$4(a6)
          addi.w    #14,$4(a6)
          move.w    $6(a4),$6(a6)
          addi.w    #22,$6(a6)
          bra       shoot_ready
not_fre:  
          lea.l     32(a6),a6
          dbra      d6,feind_shoot
shoot_ready:        
          ; ******************

          move.w    12(a3),d0
          add.w     d0,$4(a4)
          move.w    (a3),d0
          add.w     d0,$6(a4)

          bsr       test_feindexpl

          cmpi.w    #400,$6(a4)
          blt       nextf2
          clr.w     (a4)
nextf2:   
          lea.l     32(a4),a4
          lea.l     16(a3),a3
          subi.w    #1,d7
          cmpi.w    #0,d7
          bgt       f_loop2

          ;******************************** Shots
feinde3:  
          movea.l   a5,a4
          lea.l     352(a4),a4

          move.w    #7,d7
f_loop3:  
          cmpi.w    #2,(a4)
          bne       nextf3

          addi.w    #5,$6(a4)

          movea.l   a4,a6
          bsr       test_kol

          cmpi.w    #0,d2
          beq       no_kol3

          bsr       delete_shield
no_kol3:  
          cmpi.w    #400,$6(a4)
          blt       nextf3
          clr.w     (a4)

nextf3:   lea.l     32(a4),a4
          subi.w    #1,d7
          cmpi.w    #0,d7
          bgt       f_loop3

          ;******************************** Meteors
feinde4:  
          movea.l   a5,a4
          lea.l     1312(a4),a4
          movea.l   #feindpar,a3
          lea.l     560(a3),a3
          move.w    #6,d7

          move.w    #4,d0
          bsr       feind_check
f_loop4:  
          cmpi.w    #2,(a4)
          beq       bewegen4

          cmpi.w    #0,fcheck
          bne       nextf4

          cmp.w     fzahl,d7
          bgt       nextf4

          move.w    #2,(a4)
          clr.w     $6(a4)
          move.w    #1,d0
          bsr       random256
          addi.w    #16,d0
          move.w    d0,$4(a4)
          move.w    #46,d0
          bsr       random256
          addi.w    #1,d0
          move.w    d0,(a3)
bewegen4: 
          move.w    (a3),d0
          add.w     d0,$6(a4)

          movea.l   a4,a6
          bsr       test_kol

          cmpi.w    #0,d2
          beq       no_kol4

          bsr       delete_shield
no_kol4:  
          cmpi.w    #400,$6(a4)
          blt       nextf4
          clr.w     (a4)

nextf4:   lea.l     32(a4),a4
          lea.l     16(a3),a3
          subi.w    #1,d7
          cmpi.w    #0,d7
          bgt       f_loop4

          rts       

          ; *** Feindexplosion ? ***
test_feindexpl:     
          cmpi.w    #0,14(a3)
          beq       fn_expl   ;        Feind noch "heil"?
          subi.w    #1,14(a3)

          cmpi.w    #0,14(a3)
          bne       no_kol1
          clr.w     (a4)

          movea.l   remem,a0
          lea.l     192(a0),a0
          move.l    $c(a0),$c(a4)

          bra       no_kol1
fn_expl:  

          ;********************************** Kollosionstest
          movea.l   a4,a6
          bsr       test_kol

          cmpi.w    #0,d2
          beq       no_kol1

          bsr       delete_shield
no_kol1:  
          rts       

          ; *********************************
          ; *** Feind-Check          ( d0 = Zu berprfende Feindart )
feind_check:                  ;      ( fcheck=0 -> Bereich ok, 255 -> nein )
          movea.l   feindblock,a0       ;
          move.w    #255,fcheck
next_f:   
          movem.w   (a0)+,d1-d4
          cmpi.w    #0,d1
          beq       end_f

          cmp.w     d0,d1
          bne       next_f

          cmp.w     game_timer,d4
          blt       next_f
          cmp.w     game_timer,d3
          bgt       end_f

          clr.w     fcheck
end_f:    
          move.w    d2,fzahl
          rts       

          ; ********************************* Random(256)
random256:          
          move.w    d0,dummy
          move.w    #$11,-(sp)
          trap      #14       ; RANDOM
          addq.l    #2,sp
          andi.l    #%00000000000000000000000011111111,d0   ;(RND: 0 bis 256)
          divu      dummy,d0
          addq.l    #1,d0
          rts       

          ; ********************************* Teste auf Kollosion
test_kol: 
          clr.l     d2

          cmpi.w    #2,(a5)
          bne       not_kol
          cmpi.w    #2,(a6)
          bne       not_kol

          move.w    $6(a5),d0
          lsl.w     #1,d0
          add.w     $2(a5),d0

          move.w    $6(a6),d1
          lsl.w     #1,d1
          add.w     $2(a6),d1

          sub.w     d1,d0
          bpl       not_neg1
          neg.w     d0
not_neg1: 
          move.w    $2(a5),d1
          add.w     $2(a6),d1

          cmp.w     d0,d1
          blt       not_kol

          move.w    $4(a5),d0
          lsl.w     #1,d0
          add.w     $a(a5),d0

          move.w    $4(a6),d1
          lsl.w     #1,d1
          add.w     $a(a6),d1

          sub.w     d1,d0
          bpl       not_neg2
          neg.w     d0
not_neg2: 
          move.w    $a(a5),d1
          add.w     $a(a6),d1

          cmp.w     d0,d1
          blt       not_kol

          move.w    #1,d2
not_kol:  
          rts       

          ; ********************************* Put Field
put_field:          
          move.l    datp,d4
          sub.l     a1,d4
          addi.w    #9,d4

          move.w    d4,d2
          divu      #10,d2

          move.w    d2,d3
          mulu      #10,d3
          move.w    #10,d1
          add.w     d3,d1
          sub.w     d4,d1
          lsl.w     #2,d1

          mulu      #2560,d2

          move.l    timer,d3
          addq.w    #4,d3
          mulu      #20,d3

          movea.l   logbase,a0
          adda.w    d1,a0
          adda.w    d2,a0
          suba.w    d3,a0
          suba.w    #4,a0

          movea.l   #weltall,a2
          mulu      #128,d0
          adda.l    d0,a2

          move.w    #31,d7
put_f:    
          move.l    (a2)+,(a0)
          lea.l     80(a0),a0
          dbra      d7,put_f
          rts       

          ; ********************************* DELETE SHIELD
delete_shield:      
          cmpi.w    #0,shield_timer
          bgt       ret_del
          cmpi.w    #0,deadflag
          bgt       ret_del

          move.l    #shieldsound,d0
          bsr       sound

          subi.w    #8,shield
          cmpi.w    #0,shield
          bls       dead

          cmpi.w    #6,lifes
          bgt       no_clsh

          ; ****************
          movea.l   physbase,a1
          move.l    a1,d2
          sub.l     logbase,d2

          adda.l    #21164,a1

          move.w    lifes,d0
          lsl.w     #2,d0
          adda.w    d0,a1

          move.w    #1,d7
phlo:     
          move.w    #32,d1
          sub.w     shield,d1
          movea.l   a1,a2
clear_shld:         
          clr.l     (a2)
          lea.l     80(a2),a2
          dbra      d1,clear_shld

          suba.l    d2,a1
          dbra      d7,phlo
          ; ****************
no_clsh:  
          move.w    #40,shield_timer
          movea.l   #param,a0
          move.l    76(a0),12(a0)
ret_del:  
          rts       

          ; ********************************* DEAD
dead:     
          move.l    #explosion,d0
          bsr       sound
          move.w    #80,deadflag
          clr.w     ex_sh

          move.w    #32,shield
          move.w    #2784,fuel
          subi.w    #1,lifes
          bsr       show_lifes

          movea.l   #param,a1
          move.l    588(a1),$c(a1)
          subi.w    #2,4(a1)

          rts       

          ; ******************************* CLEAR SPRITES ********************
clear_sprites:      
          movea.l   #param,a1
          lea.l     1472(a1),a1

          move.w    #46,d7
clear_loop:         
          movea.l   a1,a3
          movem.w   (a3)+,d3/d4
          cmpi.w    #0,d3
          beq       no_clear
          lea.l     12(a3),a3
          movem.l   (a3)+,a5/a6

          adda.l    scrlb,a6
          suba.l    physbase,a6
clr:      
          move.l    (a5)+,(a6)+
          move.w    (a5)+,(a6)
          lea.l     76(a6),a6
          dbra      d4,clr
no_clear: 
          suba.l    #32,a1
          dbra      d7,clear_loop
          rts       

          ; ***************************** SET SPRITES ************************
set_sprites:        
          movea.l   #param,a1

          move.w    #46,d7
sprite_loop:        
          movea.l   a1,a3
          movem.w   (a3)+,d2-d6
          cmpi.w    #0,d2
          beq       no_sprite
          lea.l     2(a3),a3
          movem.l   (a3)+,a4/a5

          movea.l   logbase,a0

          move.w    d4,d2
          lsr.w     #3,d2
          andi.w    #%1111111111111110,d2

          mulu      #80,d5
          adda.w    d5,a0
          adda.w    d2,a0
          move.l    a0,(a3)+

          move.w    d4,d0
          andi.w    #%1111111111110000,d0
          sub.w     d0,d4
          mulu      d4,d6
          adda.w    d6,a4

next_row: 
          move.l    (a0),d0
          move.l    d0,(a5)+
          and.l     (a4)+,d0
          or.l      (a4)+,d0
          move.l    d0,(a0)+

          move.w    (a0),d0
          move.w    d0,(a5)+
          and.w     (a4)+,d0
          or.w      (a4)+,d0
          move.w    d0,(a0)

          lea.l     76(a0),a0
          dbra      d3,next_row
no_sprite:          
          lea.l     32(a1),a1
          dbra      d7,sprite_loop
          rts       

          ; **************************** SCROLLING ***************************
scrolling:          
          adda.l    #32000,a5
          adda.l    #32000,a6
          move.w    #401,d1
sc_l:     
          copy 
          dbra      d1,sc_l

          movea.l   #weltall,a5
          adda.l    timer,a5
          movea.l   datp,a4

          move.w    #9,d1
s_loop:   
          clr.w     d0
          move.b    (a4)+,d0
          lsl.w     #7,d0
          movea.w   d0,a0
          adda.l    a5,a0
          move.l    (a0),(a6)+
          dbra      d1,s_loop

          rts       

          ; ********************************* Switch
switch:   
          move.l    logbase,d0
          move.l    physbase,logbase
          move.l    d0,physbase

          move.w    #-1,-(sp)
          move.l    physbase,-(sp)
          move.l    logbase,-(sp)
          move.w    #5,-(sp)
          trap      #14
          lea.l     12(sp),sp
          rts       

          ; ********************************* Show_score
show_score:         
          move.l    score,d0
          move.w    #9021,d1
          bsr       dez_aus

          rts       

          ; ********************************* Show_lifes
show_lifes:         
          movea.l   physbase,a1
          clr.w     d7
both_screens:       
          move.w    lifes,d0
          subq.w    #1,d0

          cmpi.w    #5,d0
          blt       less_five
          move.w    #5,d0
less_five:          
          adda.l    #21168,a1
          cmpi.w    #0,d0
          blt       no_plot
next_l:   
          movea.l   #shapes,a0
          lea.l     6(a0),a0

          move.w    #31,d1
plot_life:          
          move.l    (a0)+,(a1)
          lea.l     80(a1),a1
          dbra      d1,plot_life

          suba.l    #2556,a1
          dbcs      d0,next_l
no_plot:  
          cmpi.w    #5,lifes
          bgt       no_clearl

          move.w    #31,d1
clear_life:         
          move.l    #0,(a1)
          lea.l     80(a1),a1
          dbra      d1,clear_life

no_clearl:          
          cmpi.w    #1,d7
          beq       ready

          movea.l   logbase,a1
          move.w    #1,d7
          bra       both_screens
ready:    
          rts       

          ; ********************************* Show_fuel
show_fuel:          
          cmpi.w    #0,fuel
          bgt       enough_fuel
          move.w    #2784,fuel
          bsr       dead
enough_fuel:        
          lsr.w     #4,d7

          move.w    #400,d3
          move.w    #192,d4
          move.w    #400,d5
          add.w     d7,d5
          subi.w    #4,d5
          move.w    #208,d6
          move.w    #%1111111111111111,-(sp)
          move.w    #%1010101010101010,-(sp)
          bsr       draw_box

          move.w    #400,d3
          add.w     d7,d3
          move.w    #192,d4
          move.w    #576,d5
          move.w    #208,d6
          move.w    #0,-(sp)
          move.w    #0,-(sp)
          bsr       draw_box

          addq.l    #8,sp
          rts       

          ; *** Dezimal_aus *** (in d0 und d1)  ;Benutzt: d5,d6,d7,a0,a1,a2,a3
dez_aus:  
          movem.l   d6/d7/a0-a3,-(sp)

          andi.l    #$ffff,d0
          movea.l   #zeile,a0
          clr.w     d5
do_dez:   
          move.l    d0,d7
          divu      #10,d7
          move.w    d7,d0
          swap.w    d7

          move.b    d7,(a0)+
          addi.w    #1,d5

          cmpi.w    #0,d0
          bne       do_dez

          movea.l   logbase,a2
          movea.l   physbase,a3
          adda.w    d1,a2
          adda.w    d1,a3

          movea.l   #zeile,a0
aus:      cmpi.w    #0,d5
          beq       dez_ende

          subi.w    #1,d5
          move.b    (a0)+,d0
          andi.w    #$ff,d0

          movea.l   #char,a1

          mulu      #16,d0
          adda.l    d0,a1
          move.w    #15,d6
print_char:         
          move.b    (a1),(a2)
          move.b    (a1)+,(a3)
          lea.l     80(a2),a2
          lea.l     80(a3),a3
          dbra      d6,print_char

          suba.l    #1281,a2
          suba.l    #1281,a3
          bra       aus

dez_ende: 
          movem.l   (sp)+,d6/d7/a0-a3
          rts       

          ; *************************** INIT SCREEN **************************
init_screen:        
          movea.l   #box,a6
          movem.w   (a6)+,d3-d6
          move.l    (a6)+,-(sp)
          bsr       draw_box
          lea.l     4(sp),sp

          movea.l   #anz_puf,a5
          movea.l   logbase,a6
          move.w    #400,d1
anz_line: move.w    #9,d2
          lea.l     40(a6),a6
anz_col:  move.l    (a5)+,(a6)+
          dbra      d2,anz_col
          dbra      d1,anz_line

          pea       script
          print 
          clr.l     score
          move.l    #1,level
          move.w    #3,lifes
          move.w    #2700,fuel
          move.w    #32,shield
          clr.w     shield_timer
          clr.w     deadflag

          movea.l   #fname,a0
          move.b    #65,6(a0) ;Filename

          bsr       show_lifes
          bsr       show_score

          ; *** Copy Screens ***
          movea.l   logbase,a5
          movea.l   physbase,a6
          move.w    #8000,d1
c1:       
          move.l    (a5)+,(a6)+
          dbra      d1,c1
          ; ********************

          rts       

          ; ********************************* READ LEVELS
read_levels:        
          move.w    #0,-(sp)
          pea       fname
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,d1

          cmpi.w    #-33,d0
          bne       not_complete
          move.w    #1,complete
          bsr       switch
          bra       begin
not_complete:       
          pea       leveldat
          move.l    #4000,-(sp)
          move.w    d1,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea.l     $c(sp),sp

          move.w    d1,-(sp)
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

          movea.l   #leveldat,a0
          move.w    (a0)+,max_timer
          move.w    (a0)+,d0
          clr.l     -4(a0)

          move.l    a0,backdat
          adda.w    d0,a0
          move.l    a0,feindblock

          rts       

          ;********************************** READ HIGHSCORE-DATEI

read_high:          
          move.w    #0,-(sp)
          pea       fname1
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          cmpi.w    #-33,d0
          bne       dat_vor
          bra       end_read
dat_vor:  move.w    d0,d1

          movea.l   #scores,a0
          move.l    #48,d3
          bsr       read

          movea.l   #names,a0
          move.l    #240,d3
          bsr       read

          move.w    d1,-(sp)
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

end_read: rts       

read:     pea       (a0)
          move.l    d3,-(sp)
          move.w    d1,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea.l     $c(sp),sp
          rts       

          ;********************************** WRITE HIGHSCORE-DATEI

write_high:         
          move.w    #0,-(sp)
          pea       fname1
          move.w    #$3c,-(sp)
          trap      #1
          addq.l    #8,sp
          cmpi.w    #-33,d0
          bne       dat_vorh
          bra       end_write
dat_vorh: move.w    d0,d1

          movea.l   #scores,a0
          move.l    #48,d3
          bsr       write

          movea.l   #names,a0
          move.l    #240,d3
          bsr       write

          move.w    d1,-(sp)
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

end_write:          rts       

write:    pea       (a0)
          move.l    d3,-(sp)
          move.w    d1,-(sp)
          move.w    #$40,-(sp)
          trap      #1
          lea.l     $c(sp),sp
          rts       


          ;*************** HALL OF FAME *************
high_score:         

          ;*** clr_tastatur ***
          move.w    #$b,-(sp)
          trap      #1
          lea.l     2(sp),sp
          cmpi.w    #-1,d0
          bne       f_clr
          move.w    #1,-(sp)
          trap      #1
          lea.l     2(sp),sp
          bra       high_score
          ;******************

f_clr:    movea.l   logbase,a5
          movea.l   physbase,a4
          move.l    xbios2,logbase
          move.l    xbios2,physbase
          bsr       switch

          movea.l   #names,a2
          lea.l     200(a2),a2
          movea.l   #nam_aus,a0
          movea.l   #text,a1
          move.w    #19,d0
clr_nam:  move.b    #32,(a0)+
          move.b    #32,(a1)+
          move.b    #32,(a2)+
          dbra      d0,clr_nam

          movea.l   #boxes1,a6
          move.w    (a6)+,d7
draw_rout1:         
          movem.w   (a6)+,d3-d6
          move.l    (a6)+,-(sp)
          bsr       draw_box
          dbra      d7,draw_rout1
          move.l    logbase,d0
          movea.l   d0,a0
          move.l    d0,d1
          adda.l    #9347,a0
          move.l    #9347,d0
sloop:    move.b    #1,(a0)
          suba.l    #13,a0
          move.b    #%11100000,(a0)
          lea.l     93(a0),a0
          addi.l    #80,d0
          cmpi.l    #24370,d0
          blt       sloop

          move.w    #9,d3
nl:       pea       null
          print 
          movea.l   #null,a2
          addq.b    #1,2(a2)
          dbra      d3,nl
          move.b    #40,2(a2)

          ;*** Sort-Routine ***

          movea.l   #scores,a1
          lea.l     40(a1),a1
          move.l    score,(a1)
          movea.l   #names,a6
          lea.l     196(a6),a6
          move.l    #10,d3
sort_l:   move.l    -(a1),d0
          cmp.l     4(a1),d0
          bgt.l     end_sort
          subi.w    #1,d3
          move.l    (a1),d0
          move.l    4(a1),(a1)
          move.l    d0,4(a1)

          move.w    #4,d7
name_loop:          
          move.l    (a6),d0
          move.l    20(a6),(a6)
          move.l    d0,20(a6)
          suba.l    #4,a6
          dbra      d7,name_loop

          cmpa.l    #scores,a1
          bhi.l     sort_l
end_sort: 
          suba.l    #scores,a1
          lsr.l     #2,a1

          ;********  (d3 = Position)

          movea.l   #scores,a1
          move.w    #9024,d1

          move.w    #9,d7
score_ausgabe:      
          move.l    (a1)+,d0
          cmpi.l    #0,d0
          beq       n_zero
          addi.w    #1280,d1
          bsr       dez_aus
n_zero:   dbra      d7,score_ausgabe

          pea       textg
          print 

          ;************************

          movea.l   #names,a3
          move.w    #6,d2
          move.w    #9,d4
lop1:     movea.l   #nam_aus,a0
          move.w    #19,d0
n_aus:    move.b    (a3)+,(a0)+
          dbra      d0,n_aus
          addi.w    #1,d2
          move.w    d2,d1
          bsr       locate
          pea       nam_aus
          print 
          dbra      d4,lop1

          ;*******************

          add.w     d3,d1
          addi.w    #8,d1
          cmpi.w    #16,d1
          bgt       n_inp
          bsr       locate
          bsr       input

          movea.l   #text,a1
          movea.l   #names,a2
          mulu      #20,d3
          adda.l    d3,a2

          move.w    #19,d0
kop:      move.b    (a1)+,(a2)+
          dbra      d0,kop
n_inp:    
          bsr       write_high
          move.l    #0,d1
lop:      addi.l    #1,d1
          cmpi.l    #800000,d1
          bls       lop

          move.w    #1,start
          move.l    a5,logbase
          move.l    a4,physbase
          bsr       switch
          bra       b_high

          ;******** Locate ******
locate:   
          pea       rechts
          print 
y:        pea       unten
          print 
          dbra      d1,y
          rts       

          ;********************************** INPUT
input:    
          pea       curs
          print 
          pea       buffer
          move.w    #$000a,-(sp)
          trap      #1
          lea.l     6(sp),sp
          pea       ncurs
          print 
          rts       

          ; ********************************* Sound
sound:    move.l    d0,-(sp)
          move.w    #$20,-(sp)
          trap      #14
          addq.l    #6,sp
          rts       
          ; ********************************* Clear Aliens
clr_alien:          
          lea.l     64(a1),a1
          move.w    #46,d7
clr_l:    clr.w     (a1)
          adda.w    #32,a1
          dbcs      d7,clr_l
          rts       

          ; ***************** BOX (x1,y1,x2,y2,Muster => d3-d6,sp) ***********
draw_box: 
          addq.l    #4,sp

          movea.l   logbase,a1
          move.w    d4,d0
          mulu      #80,d0
          adda.w    d0,a1
          move.w    d3,d0
          lsr.w     #4,d0
          lsl.w     #1,d0
          adda.w    d0,a1
b2:       
          movea.l   a1,a0
          move.w    d3,d0
b1:       
          addq.l    #4,sp
          move.w    -(sp),80(a0)
          move.w    -(sp),(a0)+

          addi.w    #16,d0
          cmp.w     d0,d5
          bgt       b1
          lea.l     160(a1),a1
          addq.w    #2,d4
          cmp.w     d6,d4
          blt       b2

          subq.l    #4,sp
          rts       

          ;********************* Init Joy (Interrupt) ************************

init_joy: move.w    #34,-(sp)
          trap      #14
          lea.l     2(sp),sp
          movea.l   d0,a0
          move.l    24(a0),old_stick
          move.l    #stick,24(a0)

          pea       joy_kmd
          move.w    #1,-(sp)
          move.w    #25,-(sp)
          trap      #14
          lea.l     8(sp),sp
          rts       

          ;******************** Neue Joy-Routine (Interrupt) **************
stick:    movea.l   #joy1,a1
          lea.l     1(a0),a0
          move.b    1(a0),(a1)
          rts       



          .BSS 
physbase: .DS.l 1
logbase:  .DS.l 1
anzahl:   .DS.w 1
wertadr:  .DS.l 1
maskadr:  .DS.l 1
loeschadr:          .DS.l 1
scrlb:    .DS.l 1
xbios2:   .DS.l 1
timer:    .DS.l 1
datp:     .DS.l 1
game_timer:         .DS.w 1
max_timer:          .DS.w 1
sht_timer:          .DS.w 1
hx:       .DS.w 1
hy:       .DS.w 1
shield:   .DS.w 1
shieldflag:         .DS.w 1
shield_timer:       .DS.w 1
deadflag: .DS.w 1
complete: .DS.w 1
fcheck:   .DS.w 1
fzahl:    .DS.w 1
dummy:    .DS.l 1

fuel:     .DS.w 1
lifes:    .DS.w 1
score:    .DS.l 1
level:    .DS.l 1

ex_sh:    .DS.w 1
speed:    .DS.w 1
remem:    .DS.l 1
start:    .DS.w 1
lev_ch:   .DS.w 1
end_zeile:          .DS.w 1

backdat:  .DS.l 1
feindblock:         .DS.l 1

joy1:     .DS.w 1
old_stick:          .DS.l 1

scores:   .DS.l 24
nam_aus:  .DS.l 20
names:    .DS.l 64
zeile:    .DS.b 80
char:     .DS.b 160
feindpar: .DS.l 512
param:    .DS.l 2400
stack:    .DS.l 512
leveldat: .DS.l 4000

log_adr:  .DS.l 10000
anz_puf:  .DS.l 4800
spr_puf:  .DS.l 16000

          .DATA 
shipnr:   .DC.l 0
shapes:   
          ;ship: (Anzahl, x-Ausdehnung, y-Ausdehnung)
          .DC.w 2,26,32
          .DC.l 262144,262144,262144,917504,917504,917504,917504,2031616
          .DC.l 1900544,1769472,1114112,3768320,3178496,7979008,11575296,16769024
          .DC.l 29011968,25153536,46049280,58578944,113224704,90133504,179218944,223696384
          .DC.l 447654656,358307072,716089984,897308032,1809808064,-566554784,-265190944,8372224

          .DC.l 262144,262144,262144,917504,917504,917504,917504,2031616
          .DC.l 2031616,2031616,2031616,4161536,4161536,8372224,16769024,16769024
          .DC.l 33550336,33550336,67106816,67106816,134216704,134216704,268434944,268434944
          .DC.l 536870656,536870656,1073741696,1073741696,2145353664,-29421600,-264273440,8372224
          ;shieldship:
          .DC.w 2,26,32
          .DC.l 262144,262144,262144,917504,917504,655360,917504,1638400
          .DC.l 1638400,1376256,1638400,3440640,7913472,7651328,12099584,11804672
          .DC.l 24809472,20746240,39520256,37488640,73335808,69010432,137232896,135135744
          .DC.l 269746432,268697856,569307264,640781440,1238725184,-1908863456,-264601120,8372224

          .DC.l 262144,262144,262144,917504,917504,917504,917504,2031616
          .DC.l 2031616,2031616,2031616,4161536,4161536,8372224,16769024,16769024
          .DC.l 33550336,33550336,67106816,67106816,134216704,134216704,268434944,268434944
          .DC.l 536870656,536870656,1073741696,1073741696,2145353664,-29421600,-264273440,8372224
          ;schuss:
          .DC.w 14,8,18
          .DC.l 0,201326592,201326592,436207616,436207616,436207616,436207616,436207616
          .DC.l 436207616,956301312,2088763392,2055208960,2105540608,1518338048,436207616 ;,436207616
          .DC.l 503316480,201326592,0

          .DC.l 201326592,503316480,503316480,1056964608,1056964608,1056964608,1056964608,1056964608
          .DC.l 1056964608,2139095040,-4194304,-4194304,-4194304,-4194304,-4194304        ; ,1056964608
          .DC.l 1056964608,503316480,201326592
          ;explode1:
          .DC.w 2,31,32
          .DC.l 460800,573440,8704,55739752,201490436,283220354,547855360,86733602
          .DC.l 52017408,285175196,568023560,1109316900,91203728,-2072257982,-1648888208,444594050
          .DC.l -2116035936,54242626,648374828,75488528,40872576,567730818,564876354,622250144
          .DC.l 8891432,15545280,337207296,17794064,268570656,134349056,44073472,13312

          .DC.l 460800,776192,372224,56343912,213036796,335404982,635952572,535786490
          .DC.l 907917632,486501788,635133544,1514141092,897579408,-1526727846,-1644169616,1593835434
          .DC.l -1646265604,864025950,922745468,486530968,376433400,1073147562,904615658,1033816816
          .DC.l 184528248,65896384,389905120,39833584,401767968,193083648,44077568,13312
          ;waves:
          .DC.w 7,24,22
          .DC.l 4161536,64059392,205800960,285217024,611697792,1366413632,1144357952,-50325536
          .DC.l -2084276192,-58734624,1470807360,1795156672,894784896,464173824,248868352,78291968
          .DC.l 81093632,155161088,285217024,620762240,956306304,117447680

          .DC.l 4161536,67106816,268434944,536870656,1073741696,2147483584,2147483584,-32
          .DC.l -32,-32,2147483584,2147483584,1073741696,536870656,268434944,134216704
          .DC.l 134216704,255827456,520101632,1056972672,1056972672,117447680
          ;balls:
          .DC.w 7,28,25
          .DC.l 4161536,33550336,67024896,133915648,267292160,536691456,1073644160,2146324928
          .DC.l 2147328192,2147166656,-10528,-1133152,-4128,-1312,-147488,2147483584
          .DC.l 2147481536,2147483584,1073741696,536870656,268434944,134216704,67106816,33550336
          .DC.l 4161536

          .DC.l 4161536,33550336,67106816,134216704,268434944,536870656,1073741696,2147483584
          .DC.l 2147483584,2147483584,-32,-32,-32,-32,-32,2147483584
          .DC.l 2147483584,2147483584,1073741696,536870656,268434944,134216704,67106816,33550336
          .DC.l 4161536
          ;shooter:
          .DC.w 7,30,23
          .DC.l 16776704,117440960,134217760,284679696,553115144,536870920,1073741828,2147483644
          .DC.l 2145390588,54524288,78993984,168812704,142672416,304318608,411640368,304318608
          .DC.l 680075816,891799896,1792833196,1970814300,-605020234,-2093058,-8387586

          .DC.l 16776704,134217664,268435424,536870896,1073741816,1073741816,2147483644,2147483644
          .DC.l 2147483644,67108736,134217664,268435424,268435424,536870896,536870896,536870896
          .DC.l 1073741816,1073741816,2147254268,2146975740,-1040386,-2093058,-8387586
          ;meteor:
          .DC.w 7,28,29
          .DC.l 1536,26745728,65809728,87183600,239445296,496320592,977440800,933790368
          .DC.l 490750016,244465792,1027613568,1983382592,-341835088,-594882520,-96436204,1964048680
          .DC.l 1044518992,487851552,989856224,1984562256,-383746000,2107810384,979968160,265622592
          .DC.l 112234880,52229248,1010432,177152,6144

          .DC.l 1536,26746752,66863040,134119408,268435440,536870896,1073741792,1073741792
          .DC.l 536870848,268435328,1073741696,2147483584,-16,-8,-4,2147483640
          .DC.l 1073741808,536870880,1073741792,2147483632,-16,2147483632,1073741792,268435392
          .DC.l 130023296,52428672,1048320,244736,6144
          .DC.l 0,0

weltall:  .DC.l -1,-1,-32769,-16777217,-65,-1,-1,-1
          .DC.l -65537,-1,-536870913,-4194305,-14680577,-4194305,-1,-1
          .DC.l -1,-1,-33554441,-8193,-1,-1,-1,-1048577
          .DC.l -1,-1,-1025,-3585,-1025,-201326601,-1,-1
platte:   .DC.l -1,-2147483647,-2147483647,-2147483647,-2147483647,-2013265951,-2057166175,-2037872287
          .DC.l -2061360479,-2037872415,-2044583391,-2071426911,-2044583391,-2071426911,-2044583391,-2071426911
          .DC.l -2044583391,-2071426911,-2044583391,-2071426911,-2044583391,-2071426911,-2044583327,-2054649695
          .DC.l -2036194463,-2058843487,-2013265951,-2147483647,-2147483647,-2147483647,-2147483647,-1
krater:   .DC.l -1,-1878786047,-2113921015,-1608219391,-2130161647,-2144947839,-2002021375,-2105913675
          .DC.l -2132020959,-1516241599,-2094006751,-2067792023,-1558184023,-1994391627,-2022703183,-1522532395
          .DC.l -1976565807,-1768423463,-1975517199,-1491599427,-1823211663,-1886471191,-2104822043,-1916445287
          .DC.l -1503566909,-2118645847,-2110882143,-2003176059,-2146710511,-1592614775,-2147483647,-1
hinder1:  .DC.l -1,-787410669,-465288123,-1324281575,-599505835,-1391390415,-700169147,-1409286255
          .DC.l -704643131,-1417674351,-713031227,-1417592431,-712437307,-1417338479,-711736891,-1417414255
          .DC.l -710950459,-1417426543,-712728123,-1417113199,-712867387,-1417674351,-713031227,-1409286255
          .DC.l -704643131,-1414878511,-682273435,-1364546895,-581610147,-1163220307,-178956969,-1
hinder2:  .DC.l -1,-393705329,-232644049,-1199011687,-568188365,-1366783767,-671088669,-1409802295
          .DC.l -673183773,-1413479479,-674483229,-1411482679,-673285149,-1411482679,-674483229,-1410084919
          .DC.l -671088669,-1409978423,-696525213,-1415824951,-672140317,-1410232375,-671604765,-1410865207
          .DC.l -685770525,-1342177303,-581610125,-1163220295,-178956961,-357913937,-715827881,-1
reflekt:  .DC.l -1,-2147483647,-1861152495,-2147483647,-1861152495,-1,-2111692255,-930576245
          .DC.l -501079513,-1333229425,-635297251,-1073741829,-536870915,-1073741829,-543195907,-1083821189
          .DC.l -554053699,-1073741829,-536870915,-1073741829,-536870915,-1163220305,-178956969,-357913941
          .DC.l -715827883,-1431655765,-1,-1,-2147483647,-1002159035,-2147483647,-1
ext_ship: .DC.l -1,-2147483647,-2147483647,-2139095295,-2122317631,-2113929183,-2046787551,-2080341999
          .DC.l -1946124271,-1946042351,-1946042351,-1946042351,-1946075119,-1945935855,-1945636847,-1945776111
          .DC.l -1945249775,-1945249775,-1944327151,-1944726511,-1943393775,-1942628847,-1938851055,-1929818223
          .DC.l -1933319791,-1912602591,-2046820319,-2021654335,-2080374911,-2130706943,-2147483647,-1
ext_shot: .DC.l -1,-2147483647,-2145387519,-2145385983,-2143256319,-2139062143,-2122284927,-2122203007
          .DC.l -2122203007,-2122235775,-2122203007,-2122112895,-2122080127,-2122112895,-2122080127,-2122112895
          .DC.l -2122080127,-2122112895,-2122080127,-2122112895,-2122145663,-2122018687,-2121758591,-2120969087
          .DC.l -2120221567,-2122317695,-2118123263,-2132803071,-2139096063,-2143291391,-2147483647,-1
fuelcan:  .DC.l -1,-1073741821,-1073741827,-805240823,-1341669367,-805142519,-1340153847,-790487543
          .DC.l -1325235959,-771294071,-1291353527,-757064247,-1283459831,-755021559,-1275088119,-759240439
          .DC.l -1275079415,-754996983,-1283591415,-754996983,-1275112695,-755111671,-1283468023,-755008759
          .DC.l -1279284983,-780274167,-1325417463,-803217399,-1342177271,-3,-357913941,-1

box:      .DC.w 0,0,320,400,%1111111111111111,%0000000000000000

boxes1:   .DC.w 5
          .DC.w 0,0,640,400,%1111111111111111,%0
          .DC.w 48,48,592,352,0,0
          .DC.w 96,106,528,320,%1111111111111111,%1111111111111111
          .DC.w 112,80,544,304,0,0
          .DC.w 112,90,544,116,%1010101010101010,%0101010101010101
          .DC.w 528,304,544,305,%1111111111111111,%0

numbers:  .DC.b 27,"Y",42,42,"0123456789",0

leveltxt: .DC.b 27,"Y",42,43,"APPROACHING LEVEL ",0
success:  .DC.b 27,"Y",40,40,"** CONGRATULATIONS  ! **"
          .DC.b 27,"Y",42,42,"ALL LEVELS COMPLETED",0
message1: .DC.b 27,"Y",44,43,"*** GAME  OVER ***",0
message2: .DC.b 27,"Y",46,45," PRESS ANY KEY ",0
message3: .DC.b 27,"Y",46,41,"PRESS ANY KEY TO BEGIN",0

anz_name: .DC.b "ANZEIGE.DAT",0
fname:    .DC.b "LEVEL.A",0
fname1:   .DC.b "HIGH.DAT",0
script:   .DC.b 27,"Y",39,88,"0000000"


explosion:          
          .DC.b $04,%00000000,$05,%00001111
          .DC.b $06,%00011111,$07,%00011010
          .DC.b $08,%00000000,$0a,%00010000
          .DC.b $0b,%00000000,$0c,%01000000
          .DC.b $0d,%00000011
          .DC.b $82,0
schuss:   
          .DC.b $00,%00000000,$01,%00000001
          .DC.b $08,%00001100,$80,%00000000
          .DC.b $81,0,20,240
          .DC.b $08,0
          .DC.b $82,0
shieldsound:        
          .DC.b $04,%00000000,$05,%00001111
          .DC.b $06,%00001111,$07,%00011010
          .DC.b $08,%00000000,$0a,%00010000
          .DC.b $0b,%00000000,$0c,%00000111
          .DC.b $0d,%00001111,$82,12
          .DC.b $0c,%00011111,$0d,%00000011
          .DC.b $82,0

sintab:   
          .DC.b 0,3,6,10,13,17,20,24,27,30,34,37
          .DC.b 40,43,46,50,52,55,58,61,64,66,69
          .DC.b 71,74,76,78,80,82,84,86,88,89,91
          .DC.b 92,93,95,96,97,97,98,99,99,99,100,100
          .DC.b 100,100,99,99,99,98,97,97,96,95,93,92
          .DC.b 91,89,88,86,84,82,80,78,76,74,71
          .DC.b 69,66,64,61,58,55,52,50,46,43,40
          .DC.b 37,34,30,27,24,20,17,13,10,6,3,0

high:     .DC.b 27,"Y",0,0,0

textg:    .DC.b 27,"Y",38,65,27,"p","  HALL OF FAME  ",27,"q"
          .DC.b 27,"Y",40,48,"1.",27,"Y",41,48,"2.",27,"Y",42,48,"3."
          .DC.b 27,"Y",43,48,"4.",27,"Y",44,48,"5.",27,"Y",45,48,"6."
          .DC.b 27,"Y",44,48,"5.",27,"Y",45,48,"6.",27,"Y",46,48,"7."
          .DC.b 27,"Y",47,48,"8.",27,"Y",48,48,"9.",27,"Y",49,47,"10.",0

joy_kmd:  .DC.b $12,$14
joy_quit: .DC.b $8


buffer:   .DC.b 20
          .DC.b 0
text:     .DC.b 32,32,32,32,32,32,32,32,32,32,32
          .DC.b 32,32,32,32,32,32,32,32,32,32,32

curs:     .DC.b 27,"e",0
ncurs:    .DC.b 27,"f",0
rechts:   .DC.b 27,"Y",32,50,0
unten:    .DC.b 27,"B",0
null:     .DC.b 27,"Y",40,97,"0"

          .END 
