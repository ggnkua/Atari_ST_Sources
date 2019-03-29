                       *******************************
                       *     Rasters in GfA-Basic    *
                       * Coded by Jedi of Sector One *
                       *    from The Heavy Killers   *
                       *                             *
                       * Call format :               *
                       * ~C:rout%(color register,    *
                       *rastering frequency,L:buffer)*
                       *******************************

        movem.l a0/a1,-(sp)                     Save registers
        btst #3,$fffffa1b.w                     Is the routine already
        bne restore                             present ? => restore
        movea.w 12(sp),a0                       Color register...
        adda.w a0,a0                            ...*2...
        lea $ffff8240(a0),a0                    ...+$ffff8240
        lea hbl+6(pc),a1                        Self-modified code !
        move 14(sp),frq-hbl-4(a1)               Rastering rate  
        move.l 16(sp),buffer-hbl-6(a1)          Base of the buffer
        move.w a0,(a1)                          Palette register
        subq.l #4,a1                            a1-4=hbl+2=addq address 
        move.l a1,inc-hbl(a1)                   put it in inc+2
        sf $fffffa1b.w                          stop the timer B
        lea saves(pc),a0                        saving buffer
        move.l $120.w,(a0)+                     old timer B vector
        lea $fffffa09.w,a1                      MFP vector              
        move.b (a1),(a0)+                       save the old one
        andi.b #$df,(a1)                        disable some interrupts
        lea $fffffa07.w,a1                      The same thing...
        move.b (a1),(a0)+                       ...with dis...
        bset #0,(a1)                            ...register...
        lea $fffffa13.w,a1                      ...and also...
        move.b (a1),(a0)                        ...for dis...
        bset #0,(a1)                            ...one
        lea $118.w,a1                           Key vector
        lea key(pc),a0                          New key routine
        move.l (a1),keyjmp-key+2(a0)            But jump to the old one..
        move.l a0,(a1)                          anyway...
        lea $70.w,a1                            VBL interrupt vector
        lea vbl(pc),a0                          New VBL routine
        move.l (a1),vbljmp-vbl+2(a0)            But jump to the old one..
        move.l a0,(a1)                          anyway...
        bra.s sector1                           End of the inits 
        
vbl     sf $fffffa1b.w                          Stop the timer B
frq     move.b #0,$fffffa21.w                   Set its frequency
        move.b #8,$fffffa1b.w                   And let's start !
        pea (a0)                                Save a0
        lea hbl(pc),a0                          Our timer B routine
        move.l a0,$120.w                        Placed in the vector
        move.l buffer(pc),2(a0)                 Loop each VBL
        move.l (sp)+,a0                         Pop a0
vbljmp  jmp 0                                   Jump to the old VBL
        
hbl     move 0,$0.w                             Put the chosen color
inc     addq.l #2,0                             Next color
        bclr #0,$fffffa0f.w                     End of dis routine
        rte                                     Come back
        
key     move #$2500,sr                          Disable some interrupts
keyjmp  jmp 0                                   But exec the old rout
        
restore sf $fffffa1b.w                          Stop the timer B
        lea saves(pc),a0                        Saving address
        move.l (a0)+,$120.w                     Old timer B vector
        move.b (a0)+,$fffffa09.w                Finally, there isn't...
        move.b (a0)+,$fffffa07.w                ..anything better than..
        move.b (a0),$fffffa13.w                 ...the good old things !
        move.l keyjmp+2(pc),$118.w              Old key vector
        move.l vbljmp+2(pc),$70.w               Old VBL vector
sector1 movem.l (sp)+,a0/a1                     Old registers
        rts                                     And old PC !
        
buffer  dc.l 0                                  Address of the buffer
saves   ds.l 2                                  To put old values...
