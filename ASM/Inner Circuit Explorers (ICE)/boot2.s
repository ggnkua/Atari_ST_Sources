                pea       $00
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

start:          move.w    #1,-(sp)
                move.w    #0,-(sp)
                move.w    #0,-(sp)
                move.w    #1,-(sp)
                move.w    #0,-(sp)
                clr.l     -(sp)
                move.l    #old_boot,-(sp)
                move.w    #8,-(sp)                ; read boot
                trap      #14
                lea       20(sp),sp
                tst.l     d0
                bmi       error

                lea       old_boot+2,a0
                lea       new_boot+2,a1

              rept $1c/2-2
                move.w    (a0)+,(a1)+
              endr

                move.w    #7,-(sp)
                trap      #1
                addq.l    #2,sp

                cmp.b     #"w",d0
                beq.s     write
                cmp.b     #"W",d0
                beq.s     write

                clr.w     -(sp)
                trap      #1

write:

                move.w    #1,-(sp)                ; exec
                move.w    #-1,-(sp)
                move.l    #-1,-(sp)
                move.l    #new_boot,-(sp)
                move.w    #18,-(sp)               ; make boot
                trap      #14
                lea       14(sp),sp

                move.w    #$0700,$ffff8240.w

                move.w    #1,-(sp)
                move.w    #0,-(sp)
                move.w    #0,-(sp)
                move.w    #1,-(sp)
                move.w    #0,-(sp)
                clr.l     -(sp)
                move.l    #new_boot,-(sp)         ; save boot
                move.w    #9,-(sp)
                trap      #14
                lea       20(sp),sp
                tst.l     d0
                bmi.s     error

                move.w    #$0777,$ffff8240.w
                clr.w     -(sp)
                trap      #1

error:          addq.b    #1,$ffff8240.w
                bra.s     error

**********************************************************************
old_boot:     ds.b 512

              dc.b "END OF OLDBOOT"
**********************************************************************
              even
new_boot:       bra.s     rout
              ds.b $1e

rout:
                pea       text(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.l    #6,sp

                move.l    #0,$042a
                movea.l   $05a0,a0
                cmpa.l    #0,a0
                beq.s     ST
                move.w    20(a0),d0               ; _MCH  (1,3 = STE,TT)
                beq.s     ST
                rts

ST:             pea       ST_mess(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.l    #6,sp
no_end:         bra.s     no_end


text:
              dc.b 27,69,13,10
              dc.b "A virus free disk, pal!  No shit here!"
              dc.b 27,89,34,32
              dc.b "Happy journey... ",0
ST_mess:
              dc.b 27,89,38,32
              dc.b "Oups!  Sorry, but you need a STE!",0
              even
              ds.b 512
              end
