       ;routine de son
dsound:
       pea	sound
       move.w	#32,-(sp)
       trap	#14
       addq.l	#6,sp
       rts
