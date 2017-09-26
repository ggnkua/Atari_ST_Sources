.export new_200hz
.export old_200hz
.export my_200hz

my_200hz: dc.l 0

dc.l 'XBRA'
dc.l 'MANI'
old_200hz: ds.l 1
new_200hz:
				move.l $4ba,my_200hz
				addq.l #1,my_200hz
				move.l old_200hz,-(sp)
				rts
