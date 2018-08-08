	.OFFSET

*** DEV_LIST device:
name:		ds.l	1
curr_dte:	ds.l	1
next:		ds.l	1
	
*** Sytemdaten:

bios:		ds.w	1
func_num:	ds.w	1
dopen:		ds.l	1
	
*** Daten zur Verwaltung des Devices:

type:		ds.w	1
is_open:	ds.w	1
dhandle:	ds.w	1
curr_pos:	ds.w	1
num_read:	ds.w	1
	
buf:		ds.l	1
speeds:		ds.l	1
chan_info:	ds.l	1

maptab:		ds.l	1
oIbufsize:	ds.w	1
oObufsize:	ds.w	1
oIbufptr:	ds.l	1
oObufptr:	ds.l	1
ioctrlmap:	ds.l	6

		.EVEN
DEVICES:

		.OFFSET
		
*** MAPTAB *func_map:
bconstat:	ds.l	1
bconin:		ds.l	1
bcostat:	ds.l	1
bconout:	ds.l	1
bsconf:		ds.l	1
iorec:		ds.l	1

		.EVEN
MAPTAB:
