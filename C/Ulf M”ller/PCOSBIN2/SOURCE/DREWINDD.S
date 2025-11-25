;long Drewinddir( long dir );			/* GEMDOS 0x12a */

.export Drewinddir
Drewinddir:
move.l a2,-(sp)
move.l d0,-(sp)
move.w #$12a,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
