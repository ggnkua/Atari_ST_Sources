;Small prog (in the auto folder?) to kill the keyborad click.
main:
  move.l    #$0,-(sp)
  move.w    #$20,-(sp)
  trap	    #$1
  addq.l    #$6,sp
  bclr.b    #$0,$484.w  ;Fuck the key click
exit_program:
  clr.w	    -(sp)
  trap      #$1
