;    Short Program Using Trap-8 to Activate/De-activate Snoop Mode

     text

     move.w   #12,-(a7)        ; Enable/Disable Snoop
     trap     #8
     addq.l   #2,a7

     move.w   #0,-(a7)
     trap     #1
     addq.l   #2,a7
     rts

     end
 