fonction_type::
	dc.l	null			;0
	dc.l	gemdos			;1
	dc.l	aes			;2
	dc.l	null			;3
	dc.l	null			;4
	dc.l	null			;5
	dc.l	null			;6
	dc.l	null			;7
	dc.l	null			;8
	dc.l	null			;9	
	dc.l	null			;10
	dc.l	null			;11
	dc.l	null			;12
	dc.l	bios			;13	
	dc.l	xbios			;14
	dc.l	null			;15
	dc.l	vdi			;16
	dc.l	fct_base		;17
	dc.l	fct_esc			;18
null
	dc.l	0
	
gemdos
	dc.l	g0
	dc.l	g1
	dc.l	g2
	dc.l	g3
	dc.l	g4
	dc.l	g5
	dc.l	g6
	dc.l	g7
	dc.l	g8
	dc.l	g9
	dc.l	ga
	dc.l	gb
	dc.l	rien
	dc.l	rien
	dc.l	ge
	dc.l	rien
	dc.l	g10
	dc.l	g11
	dc.l	g12
	dc.l	g13
	dc.l	g14
	dc.l	g15
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	g19
	dc.l	g1a
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	g20
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	g2a
	dc.l	g2b
	dc.l	g2c
	dc.l	g2d
	dc.l	rien
	dc.l	g2f
	dc.l	g30
	dc.l	g31
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	g36
	dc.l	rien
	dc.l	rien
	dc.l	g39
	dc.l	g3a
	dc.l	g3b
	dc.l	g3c
	dc.l	g3d
	dc.l	g3e
	dc.l	g3f
	dc.l	g40
	dc.l	g41
	dc.l	g42
	dc.l	g43
	dc.l	g44
	dc.l	g45
	dc.l	g46
	dc.l	g47
	dc.l	g48
	dc.l	g49
	dc.l	g4a
	dc.l	g4b
	dc.l	g4c
	dc.l	rien
	dc.l	g4e
	dc.l	g4f
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	g56
	dc.l	g57
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	g60
	dc.l	rien
	dc.l	g62
	dc.l	g63
	dc.l	g64
	dc.l	g65
	dc.l	g66
	rept	$7b-$66-1
	dc.l	rien
	endr
	dc.l	g7b
	dc.l	g7c
	rept	$ff-$7c-1
	dc.l	rien
	endr	
	dc.l	gff
	dc.l	g100
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	g104
	dc.l	g105
	dc.l	g106
	dc.l	g107
	dc.l	g108
	dc.l	g109
	dc.l	g10a
	dc.l	g10b
	dc.l	g10c
	dc.l	g10d
	dc.l	g10e
	dc.l	g10f
	dc.l	g110
	dc.l	g111
	dc.l	g112
	dc.l	g113
	dc.l	g114
	dc.l	g115
	dc.l	g116
	dc.l	g117
	dc.l	g118
	dc.l	g119
	dc.l	g11a
	dc.l	g11b
	dc.l	g11c
	dc.l	g11d
	dc.l	g11e
	dc.l	g11f
	dc.l	g120
	dc.l	g121
	dc.l	g122
	dc.l	g123
	dc.l	g124
	dc.l	g125
	dc.l	g126
	dc.l	g127
	dc.l	g128
	dc.l	g129
	dc.l	g12a
	dc.l	g12b
	dc.l	g12c
	dc.l	g12d
	dc.l	g12e
	dc.l	g12f
	dc.l	g130
	dc.l	g131
	dc.l	g132
	dc.l	g133
	dc.l	g134
	dc.l	g135
	dc.l	g136
	
aes	
	dc.l	rien		;0
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes10
	dc.l	aes11
	dc.l	aes12
	dc.l	aes13
	dc.l	aes14
	dc.l	aes15
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes19
	dc.l	aes20
	dc.l	aes21
	dc.l	aes22
	dc.l	aes23
	dc.l	aes24
	dc.l	aes25
	dc.l	aes26
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes30
	dc.l	aes31
	dc.l	aes32
	dc.l	aes33
	dc.l	aes34
	dc.l	aes35
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes40
	dc.l	aes41
	dc.l	aes42
	dc.l	aes43
	dc.l	aes44
	dc.l	aes45
	dc.l	aes46
	dc.l	aes47
	dc.l	rien
	dc.l	rien
	dc.l	aes50
	dc.l	aes51
	dc.l	aes52
	dc.l	aes53
	dc.l	aes54
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien		;60
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes70
	dc.l	aes71
	dc.l	aes72
	dc.l	aes73
	dc.l	aes74
	dc.l	aes75
	dc.l	aes76
	dc.l	aes77
	dc.l	aes78
	dc.l	aes79
	dc.l	aes80
	dc.l	aes81
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes90
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes100
	dc.l	aes101
	dc.l	aes102
	dc.l	aes103
	dc.l	aes104
	dc.l	aes105
	dc.l	aes106
	dc.l	aes107
	dc.l	aes108
	dc.l	rien
	dc.l	aes110
	dc.l	aes111
	dc.l	aes112
	dc.l	aes113
	dc.l	aes114
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	aes120
	dc.l	aes121
	dc.l	aes122
	dc.l	aes123
	dc.l	aes124
	dc.l	aes125

vdi	
	dc.l	rien
	dc.l	vdi1
	dc.l	vdi2
	dc.l	vdi3
	dc.l	vdi4
	dc.l	vdi5
	dc.l	vdi6
	dc.l	vdi7
	dc.l	vdi8
	dc.l	vdi9
	dc.l	rien
	dc.l	vdi11
	dc.l	vdi12
	dc.l	vdi13
	dc.l	vdi14
	dc.l	vdi15
	dc.l	vdi16
	dc.l	vdi17
	dc.l	vdi18
	dc.l	vdi19
	dc.l	vdi20
	dc.l	vdi21
	dc.l	vdi22
	dc.l	vdi23
	dc.l	vdi24
	dc.l	vdi25
	dc.l	vdi26
	dc.l	vdi27
	dc.l	vdi28
	dc.l	vdi29
	dc.l	vdi30
	dc.l	vdi31
	dc.l	vdi32
	dc.l	vdi33
	dc.l	rien
	dc.l	vdi35
	dc.l	vdi36
	dc.l	vdi37
	dc.l	vdi38
	dc.l	vdi39
	
	rept	60
	dc.l	rien
	endr
	dc.l	vdi100
	dc.l	vdi101
	dc.l	vdi102
	dc.l	vdi103
	dc.l	vdi104
	dc.l	vdi105
	dc.l	vdi106
	dc.l	vdi107
	dc.l	vdi108
	dc.l	vdi109
	dc.l	vdi110
	dc.l	vdi111
	dc.l	vdi112
	dc.l	vdi113
	dc.l	vdi114
	dc.l	vdi115
	dc.l	vdi116
	dc.l	vdi117
	dc.l	vdi118
	dc.l	vdi119
	dc.l	vdi120
	dc.l	vdi121
	dc.l	vdi122
	dc.l	vdi123
	dc.l	vdi124
	dc.l	vdi125
	dc.l	vdi126
	dc.l	vdi127
	dc.l	vdi128
	dc.l	vdi129
	dc.l	vdi130
	dc.l	vdi131
	
	rept	100
	dc.l	rien
	endr
	
	
	dc.l	vdi232
	dc.l	rien
	dc.l	vdi234
	dc.l	vdi235
	dc.l	vdi236
	dc.l	vdi237
	dc.l	rien
	dc.l	vdi239
	dc.l	vdi240
	dc.l	vdi241
	dc.l	vdi242
	dc.l	vdi243
	dc.l	vdi244
	dc.l	vdi245
	dc.l	vdi246
	dc.l	vdi247
	dc.l	vdi248
	dc.l	vdi249
	dc.l	vdi250
	dc.l	vdi251
	dc.l	vdi252
	dc.l	vdi253
	dc.l	vdi254
	dc.l	vdi255

fct_base	
	dc.l	rien
	dc.l	fct1
	dc.l	fct2
	dc.l	fct3
	dc.l	fct4
	dc.l	fct5
	dc.l	fct6
	dc.l	fct7
	dc.l	fct8
	dc.l	fct9
	dc.l	fct10
	dc.l	rien
	dc.l	rien
	dc.l	fct13
	

fct_esc
	dc.l	rien
	dc.l	esc1
	dc.l	esc2
	dc.l	esc3
	dc.l	esc4
	dc.l	esc5
	dc.l	esc6
	dc.l	esc7
	dc.l	esc8
	dc.l	esc9
	dc.l	esc10
	dc.l	esc11
	dc.l	esc12
	dc.l	esc13
	dc.l	esc14
	dc.l	esc15
	dc.l	esc16
	dc.l	esc17
	dc.l	esc18
	dc.l	esc19
	dc.l	esc20
	dc.l	esc21
	dc.l	esc22
	dc.l	esc23
	dc.l	esc24
	dc.l	esc25
	
	rept	34
	dc.l	rien
	endr
	
	dc.l	esc60
	
	rept	30
	dc.l	rien
	endr
	
	dc.l	esc91
	dc.l	esc92
	dc.l	esc93
	dc.l	esc94
	dc.l	esc95
	dc.l	esc96
	dc.l	esc98
	dc.l	esc99
	dc.l	esc100

bios
	dc.l	b0
	dc.l	b1
	dc.l	b2
	dc.l	b3
	dc.l	b4
	dc.l	b5
	dc.l	b6
	dc.l	b7
	dc.l	b8
	dc.l	b9
	dc.l	ba
	dc.l	bb
	
xbios
	dc.l	x0
	dc.l	x1
	dc.l	x2
	dc.l	x3
	dc.l	x4
	dc.l	x5
	dc.l	x6
	dc.l	x7
	dc.l	x8
	dc.l	x9
	dc.l	xa
	dc.l	rien
	dc.l	xc
	dc.l	xd
	dc.l	xe
	dc.l	xf
	dc.l	x10
	dc.l	x11
	dc.l	x12
	dc.l	x13
	dc.l	x14
	dc.l	x15
	dc.l	x16
	dc.l	x17
	dc.l	x18
	dc.l	x19
	dc.l	x1a
	dc.l	x1b
	dc.l	x1c
	dc.l	x1d
	dc.l	x1e
	dc.l	x1f
	dc.l	x20
	dc.l	x21
	dc.l	x22
	dc.l	x23
	dc.l	x24
	dc.l	x25
	dc.l	x26
	dc.l	x27
	dc.l	rien
	dc.l	x29
	dc.l	x2a
	dc.l	x2b
	dc.l	x2c
	dc.l	x2d
	dc.l	x2e
	dc.l	x2f
	dc.l	x30
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	x37
	dc.l	x38
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	rien
	dc.l	x40
	dc.l	x41
	dc.l	x42
	dc.l	x43
	dc.l	x44
	dc.l	x45
	dc.l	x46
	dc.l	x47
	dc.l	x48
	dc.l	x49
	dc.l	x4a
	dc.l	x4b
	dc.l	x4c
	dc.l	x4d
	dc.l	x4e
	dc.l	x4f
	dc.l	x50
	dc.l	x51
	dc.l	x52
	dc.l	x53
	dc.l	x54
	dc.l	x55
	dc.l	x56
	dc.l	x57
	dc.l	x58
	dc.l	x59
	dc.l	x5a
	dc.l	x5b
	dc.l	x5c
	dc.l	x5d
	dc.l	x5e
	dc.l	x5f
	dc.l	x60
	dc.l	x61
	dc.l	x62
	dc.l	x63
	dc.l	x64
	dc.l	x65
	dc.l	x66
	dc.l	x67
	dc.l	x68
	dc.l	x69
	dc.l	x6a
	dc.l	x6b
	dc.l	x6c
	dc.l	x6d
	dc.l	x6e
	dc.l	x6f
	dc.l	x70
	dc.l	x71
	dc.l	x72
	dc.l	x73
	dc.l	x74
	dc.l	x75
	dc.l	x76
	dc.l	x77
	dc.l	x78
	dc.l	x79
	dc.l	x7a
	dc.l	x7b
	dc.l	x7c
	dc.l	x7d
	dc.l	x7e
	dc.l	x7f
	dc.l	x80
	dc.l	x81
	dc.l	x82
	dc.l	x83
	dc.l	x84
	dc.l	x85
	dc.l	x86
	dc.l	x87
	dc.l	x88
	dc.l	x89
	dc.l	x8a
	dc.l	x8b
	dc.l	x8c
	dc.l	x8d
	rept 8
	dc.l	rien
	endr
	dc.l	x96	
*********************
** fonction gemdos **
*********************
	
g0	dc.b	'Pterm0',0
	even
g1	dc.b	'Cconin',0
	even
g2	dc.b	'Cconout',0
	even
g3	dc.b	'Cauxin',0
	even
g4	dc.b	'Cauxout',0
	even
g5	dc.b	'Cprout',0
	even
g6	dc.b	'Crawio',0
	even
g7	dc.b	'Crawin',0
	even
g8	dc.b	'Cnecin',0
	even
g9	dc.b	'Cconws',0
	even
ga	dc.b	'Cconrs',0
	even
gb	dc.b	'Cconis',0
	even
ge	dc.b	'Dsetdrv',0
	even
g10	dc.b	'Cconos',0
	even
g11	dc.b	'Cprnos',0
	even
g12	dc.b	'Cauxis',0
	even
g13	dc.b	'Cauxos',0
	even
g14	dc.b	'Maddalt',0
	even
g15	dc.b	'Srealloc',0
	even
g19	dc.b	'Dgetdrv',0
	even
g1a	dc.b	'Fsetdta',0
	even
g20	dc.b	'Super',0
	even
g2a	dc.b	'Tgetdate',0
	even
g2b	dc.b	'Tsetdate',0
	even
g2c	dc.b	'Tgettime',0
	even
g2d	dc.b	'Tsettime',0
	even
g2f	dc.b	'Fgetdta',0
	even
g30	dc.b	'Sversion',0
	even
g31	dc.b	'Ptermres',0
	even
g36	dc.b	'Dfree',0
	even
g39	dc.b	'Dcreate',0
	even
g3a	dc.b	'Ddelete',0
	even
g3b	dc.b	'Dsetpath',0
	even
g3c	dc.b	'Fcreate',0
	even
g3d	dc.b	'Fopen',0
	even
g3e	dc.b	'Fclose',0
	even
g3f	dc.b	'Fread',0
	even
g40	dc.b	'Fwrite',0
	even
g41	dc.b	'Fdelete',0
	even
g42	dc.b	'Fseek',0
	even
g43	dc.b	'Fattrib',0
	even
g44	dc.b	'Mxalloc',0
	even
g45	dc.b	'Fdup',0
	even
g46	dc.b	'Fforce',0
	even
g47	dc.b	'Dgetpath',0
	even
g48	dc.b	'Malloc',0
	even
g49	dc.b	'Mfree',0
	even
g4a	dc.b	'Mshrink',0
	even
g4b	dc.b	'Pexec',0
	even
g4c	dc.b	'Pterm',0
	even
g4e	dc.b	'Fsfirst',0
	even
g4f	dc.b	'Fsnext',0
	even
g56	dc.b	'Frename',0
	even
g57	dc.b	'Fdatime',0
	even
g60	dc.b	'Nversion',0
	even
g62	dc.b	'Frlock',0
	even
g63	dc.b	'Frunlock',0
	even
g64	dc.b	'Flock',0
	even
g65	dc.b	'Funlock',0
	even
g66	dc.b	'Fflush',0
	even
g7b	dc.b	'Unlock',0
	even
g7c	dc.b	'Lock',0
	even
gff	dc.b	'Syield',0
	even
g100	dc.b	'Fpipe',0
	even
g104	dc.b	'Fcntl',0
	even
g105	dc.b	'Finstat',0
	even
g106	dc.b	'Foutstat',0
	even
g107	dc.b	'Fgetchar',0
	even
g108	dc.b	'Fputchar',0
	even
g109	dc.b	'Pwait',0
	even
g10a	dc.b	'Pnice',0
	even
g10b	dc.b	'Pgetpid',0
	even
g10c	dc.b	'Pgetppid',0
	even
g10d	dc.b	'Pgetpgrp',0
	even
g10e	dc.b	'Psetpgrp',0
	even
g10f	dc.b	'Pgetuid',0
	even
g110	dc.b	'Psetuid',0
	even
g111	dc.b	'Pkill',0
	even
g112	dc.b	'Psignal',0
	even
g113	dc.b	'Pvfork',0
	even
g114	dc.b	'Pgetgid',0
	even
g115	dc.b	'Psetgid',0
	even
g116	dc.b	'Psigblock',0
	even
g117	dc.b	'Psigsetmask',0
	even
g118	dc.b	'Pusrval',0
	even
g119	dc.b	'Pdomain',0
	even
g11a	dc.b	'Psigreturn',0
	even
g11b	dc.b	'Pfork',0
	even
g11c	dc.b	'Pwait3',0
	even
g11d	dc.b	'Fselect',0
	even
g11e	dc.b	'Prusage',0
	even
g11f	dc.b	'Psetlimit',0
	even
g120	dc.b	'Talarm',0
	even
g121	dc.b	'Pause',0
	even
g122	dc.b	'Sysconf',0
	even
g123	dc.b	'Psigpending',0
	even
g124	dc.b	'Dpathconf',0
	even
g125	dc.b	'Pmsg',0
	even
g126	dc.b	'Fmidipip',0
	even
g127	dc.b	'Prenice',0
	even
g128	dc.b	'Dopendir',0
	even
g129	dc.b	'Dreaddir',0
	even
g12a	dc.b	'Drewinddir',0
	even
g12b	dc.b	'Dclosedir',0
	even
g12c	dc.b	'Fxattr',0
	even
g12d	dc.b	'Flink',0
	even
g12e	dc.b	'Fsymlink',0
	even
g12f	dc.b	'Freadlink',0
	even
g130	dc.b	'Dcntl',0
	even
g131	dc.b	'Fchown',0
	even
g132	dc.b	'Fchmod',0
	even
g133	dc.b	'Pumask',0
	even
g134	dc.b	'Psemaphore',0
	even
g135	dc.b	'Dlock',0
	even
g136	dc.b	'Psigpause',0
	even



*******************
** fonction bios **
*******************

b0	dc.b	'Getmpb',0
	even
b1	dc.b	'Bconstat',0
	even
b2	dc.b	'Bconin',0
	even
b3	dc.b	'Bconout',0
	even
b4	dc.b	'Rwabs',0
	even
b5	dc.b	'Setexec',0
	even
b6	dc.b	'Tickcal',0
	even
b7	dc.b	'Getbpb',0
	even
b8	dc.b	'Bcostat',0
	even
b9	dc.b	'Mediach',0
	even
ba	dc.b	'Drvmap',0
	even
bb	dc.b	'Kbshift',0
	even






********************
** fonction xbios **
********************
x0	dc.b	'Initmous',0
	even
x1	dc.b	'Ssbrk',0
	even
x2	dc.b	'Physbase',0
	even
x3	dc.b	'Logbase',0
	even
x4	dc.b	'Getrez',0
	even
x5	dc.b	'Setscreen',0
	even
x6	dc.b	'Setpalette',0
	even
x7	dc.b	'Setcolor',0
	even
x8	dc.b	'Floprd',0
	even
x9	dc.b	'Flopwr',0
	even
xa	dc.b	'Flopfmt',0
	even
xc	dc.b	'Midiws',0
	even
xd	dc.b	'Mfpint',0
	even
xe	dc.b	'Iorec',0
	even
xf	dc.b	'Rsconf',0
	even
x10	dc.b	'Keytbl',0
	even
x11	dc.b	'Random',0
	even
x12	dc.b	'Protobt',0
	even
x13	dc.b	'Flopver',0
	even
x14	dc.b	'Scrdmp',0
	even
x15	dc.b	'Cursconf',0
	even
x16	dc.b	'Settime',0
	even
x17	dc.b	'Gettime',0
	even
x18	dc.b	'Bioskeys',0
	even
x19	dc.b	'Ikbdws',0
	even
x1a	dc.b	'Jdisint',0
	even
x1b	dc.b	'Jenabint',0
	even
x1c	dc.b	'Giaccess',0
	even
x1d	dc.b	'Offgibit',0
	even
x1e	dc.b	'Ongibit',0
	even
x1f	dc.b	'Xbtimer',0
	even
x20	dc.b	'Dosound',0
	even
x21	dc.b	'Setprt',0
	even
x22	dc.b	'Kbdvbase',0
	even
x23	dc.b	'Kbrate',0
	even
x24	dc.b	'Ptrblk',0
	even
x25	dc.b	'Vsync',0
	even
x26	dc.b	'Supexec',0
	even
x27	dc.b	'Puntaes',0
	even
x29	dc.b	'Floprate',0
	even
x2a	dc.b	'DMAread',0
	even
x2b	dc.b	'DMAwrite',0
	even
x2c	dc.b	'Bconmap',0
	even
x2d	dc.b	'GetCookie',0
	even
x2e	dc.b	'NVMaccess',0
	even
x2f	dc.b	'PutCookie',0
	even
x30	dc.b	'Initpad',0
	even
x37	dc.b	'PutVBLqueue',0
	even
x38	dc.b	'KillVBLqueue',0
	even
x40	dc.b	'Blitmode',0
	even
x41	dc.b	'Vread',0
	even
x42	dc.b	'Vwrite',0
	even
x43	dc.b	'Vattrib',0
	even
x44	dc.b	'Vcreate',0
	even
x45	dc.b	'Vdelete',0
	even
x46	dc.b	'Vfirst',0
	even
x47	dc.b	'Vnext',0
	even
x48	dc.b	'Vvalid',0
	even
x49	dc.b	'Vload',0
	even
x4a	dc.b	'Vsave',0
	even
x4b	dc.b	'Vopen',0
	even
x4c	dc.b	'Vclose',0
	even
x4d	dc.b	'Vscroll',0
	even
x4e	dc.b	'Voffset',0
	even
x4f	dc.b	'Vseek',0
	even
x50	dc.b	'Setmon',0
	even
x51	dc.b	'Multimon',0
	even
x52	dc.b	'SizeComp',0
	even
x53	dc.b	'_Esetbank',0
	even
x54	dc.b	'_Esetcolor',0
	even
x55	dc.b	'_Esetpalette',0
	even
x56	dc.b	'_Egetpalette',0
	even
x57	dc.b	'_Esetgray',0
	even
;x58	dc.b	'_Esetsmear',0
;	even
x58	dc.b	'Vsetmode',0
	even
x59	dc.b	'Vmontype',0
	even
x5a	dc.b	'Vsetsync',0
	even
x5b	dc.b	'Vgetsize',0
	even
x5c	dc.b	'Vsetvars',0
	even
x5d	dc.b	'VsetRGB',0
	even
x5e	dc.b	'VgetRGB',0
	even
x5f	dc.b	'Vmodevalid',0
	even
x60	dc.b	'DspDoBlock',0
	even
x61	dc.b	'DspBlkHandShake',0
	even
x62	dc.b	'DspBlkUnpacked',0
	even
x63	dc.b	'DspInStream',0
	even
x64	dc.b	'DspOutStream',0
	even
x65	dc.b	'DspIOStream',0
	even
x66	dc.b	'DspRemoveInterrupts',0
	even
x67	dc.b	'DspGetWordSize',0
	even
x68	dc.b	'DspLock',0
	even
x69	dc.b	'DspUnlock',0
	even
x6a	dc.b	'DspAvailable',0
	even
x6b	dc.b	'DspReserve',0
	even
x6c	dc.b	'DspLoadProg',0
	even
x6d	dc.b	'DspExecProg',0
	even
x6e	dc.b	'DspExecBoot',0
	even
x6f	dc.b	'DspLodToBinary',0
	even
x70	dc.b	'DspTriggerHC',0
	even
x71	dc.b	'DspRequestUniqueAbility',0
	even
x72	dc.b	'DspGetProgAbility',0
	even
x73	dc.b	'DspFlushSubroutines',0
	even
x74	dc.b	'DspLoadSubroutine',0
	even
x75	dc.b	'DspInqSubrAbility',0
	even
x76	dc.b	'DspRunSubroutine',0
	even
x77	dc.b	'DspHf0',0
	even
x78	dc.b	'DspHf1',0
	even
x79	dc.b	'DspHf2',0
	even
x7a	dc.b	'DspHf3',0
	even
x7b	dc.b	'DspBlkWords',0
	even
x7c	dc.b	'DspBlkBytes',0
	even
x7d	dc.b	'DspHStat',0
	even
x7e	dc.b	'DspSetVectors',0
	even
x7f	dc.b	'DspMultBlocks',0
	even
x80	dc.b	'SndLock',0
	even
x81	dc.b	'SndUnlock',0
	even
x82	dc.b	'SndCmd',0
	even
x83	dc.b	'SndSetBuffer',0
	even
x84	dc.b	'SndSetMode',0
	even
x85	dc.b	'SndSetTrack',0
	even
x86	dc.b	'SndSetMonTrack',0
	even
x87	dc.b	'SndSetInterrupt',0
	even
x88	dc.b	'SndBufOper',0
	even
x89	dc.b	'SndDspTriState',0
	even
x8a	dc.b	'SndGpio',0
	even
x8b	dc.b	'SndDevConnect',0
	even
x8c	dc.b	'SndStatus',0
	even
x8d	dc.b	'SndBufPtr',0
	even
x96	dc.b	'Vsetmask',0
	even


	*--- les fonctions aes ---*
	
aes10	dc.b	'Appl_Init',0
	even	
aes11	dc.b	'Appl_Read',0
	even	
aes12	dc.b	'Appl_Write',0
	even	
aes13	dc.b	'Appl_Find',0
	even	
aes14	dc.b	'Appl_Tplay',0
	even	
aes15	dc.b	'Appl_Trecord',0
	even	
aes19	dc.b	'Appl_Exit',0
	even	
aes20	dc.b	'Evnt_Keybd',0
	even	
aes21	dc.b	'Evnt_Button',0
	even	
aes22	dc.b	'Evnt_Mouse',0
	even	
aes23	dc.b	'Evnt_Mesag',0
	even
aes24	dc.b	'Evnt_Timer',0
	even	
aes25	dc.b	'Evnt_Multi',0
	even	
aes26	dc.b	'Evnt_Dclick',0
	even	
aes30	dc.b	'Menu_Bar',0
	even	
aes31	dc.b	'Menu_Icheck',0
	even	
aes32	dc.b	'Menu_Ienable',0
	even	
aes33	dc.b	'Menu_Tnormal',0
	even	
aes34	dc.b	'Menu_Text',0
	even	
aes35	dc.b	'Menu_Register',0
	even	
aes40	dc.b	'Objc_Add',0
	even	
aes41	dc.b	'Objc_Delete',0
	even	
aes42	dc.b	'Objc_Draw',0
	even	
aes43	dc.b	'Objc_Find',0
	even	
aes44	dc.b	'Objc_Offset',0
	even	
aes45	dc.b	'Objc_Order',0
	even	
aes46	dc.b	'Objc_Edit',0
	even	
aes47	dc.b	'Objc_Change',0
	even	
aes50	dc.b	'Form_Do',0
	even	
aes51	dc.b	'Form_Dial',0
	even	
aes52	dc.b	'Form_Alert',0
	even	
aes53	dc.b	'Form_Error',0
	even	
aes54	dc.b	'Form_Center',0
	even	
aes70	dc.b	'Graf_Rubberbox',0
	even	
aes71	dc.b	'Graf_Dragbox',0
	even	
aes72	dc.b	'Graf_Movebox',0
	even	
aes73	dc.b	'Graf_Growbox',0
	even	
aes74	dc.b	'Graf_Shrinkbox',0
	even	
aes75	dc.b	'Graf_Watchbox',0
	even	
aes76	dc.b	'Graf_Slidebox',0
	even	
aes77	dc.b	'Graf_Handle',0
	even	
aes78	dc.b	'Graf_Mouse',0
	even	
aes79	dc.b	'Graf_Mkstate',0
	even	
aes80	dc.b	'Scrp_Read',0
	even
aes81	dc.b	'Scrp_Write',0
	even
aes90	dc.b	'Fsel_Input',0
	even
aes100	dc.b	'Wind_Create',0
	even	
aes101	dc.b	'Wind_open',0
	even	
aes102	dc.b	'Wind_Close',0
	even	
aes103	dc.b	'Wind_Delete',0
	even	
aes104	dc.b	'Wind_Get',0
	even	
aes105	dc.b	'Wind_Set',0
	even	
aes106	dc.b	'Wind_Find',0
	even	
aes107	dc.b	'Wind_Update',0
	even	
aes108	dc.b	'Wind_Calc',0
	even	
aes110	dc.b	'Rsrc_Load',0
	even	
aes111	dc.b	'Rsrc_Free',0
	even	
aes112	dc.b	'Rsrc_Gaddr',0
	even	
aes113	dc.b	'Rsrc_Saddr',0
	even	
aes114	dc.b	'Rsrc_Obfix',0
	even	
aes120	dc.b	'Shel_Read',0
	even	
aes121	dc.b	'Shel_Write',0
	even	
aes122	dc.b	'Shel_Get',0
	even	
aes123	dc.b	'Shel_Put',0
	even	
aes124	dc.b	'Shel_Find',0
	even	
aes125	dc.b	'Shel_Envrn',0
	even	


	*--- Les fonction vdi ---*
	
vdi1	dc.b	'v_opnwk',0
	even	
vdi2	dc.b	'v_clswk',0
	even	
vdi3	dc.b	'v_clrwk',0
	even	
vdi4	dc.b	'v_updwk',0
	even	
vdi6	dc.b	'v_pline',0
	even	
vdi7	dc.b	'v_pmarker',0
	even	
vdi8	dc.b	'v_gtext',0
	even	
vdi9	dc.b	'v_fillarea',0
	even	
vdi10	dc.b	'v_cellarray',0
	even	
vdi12	dc.b	'vst_height',0
	even	
vdi13	dc.b	'vst_rotation',0
	even	
vdi14	dc.b	'vs_color',0
	even	
vdi15	dc.b	'vsl_type',0
	even	
vdi16	dc.b	'vsl_width',0
	even	
vdi17	dc.b	'vsl_color',0
	even	
vdi18	dc.b	'vsm_type',0
	even	
vdi19	dc.b	'vsm_height',0
	even	
vdi20	dc.b	'vsm_color',0
	even	
vdi21	dc.b	'vst_font',0
	even	
vdi22	dc.b	'vst_color',0
	even	
vdi23	dc.b	'vsf_interior',0
	even	
vdi24	dc.b	'vsf_style',0
	even	
vdi25	dc.b	'vsf_color',0
	even	
vdi26	dc.b	'vq_color',0
	even	
vdi27	dc.b	'vq_cellarray',0
	even	
vdi28	dc.b	'v_locator',0
	even	
vdi29	dc.b	'v_valuator',0
	even	
vdi30	dc.b	'v_choice',0
	even	
vdi31	dc.b	'v_string',0
	even	
vdi32	dc.b	'vswr_mode',0
	even	
vdi33	dc.b	'vsin_mode',0
	even	
vdi35	dc.b	'vql_attribute',0
	even	
vdi36	dc.b	'vqm_attribute',0
	even	
vdi37	dc.b	'vqf_attribute',0
	even	
vdi38	dc.b	'vqt_attribute',0
	even	
vdi39	dc.b	'vst_alignment',0
	even	
vdi100	dc.b	'v_opnvwk',0
	even	
vdi101	dc.b	'v_clsvwk',0
	even	
vdi102	dc.b	'vq_extend',0
	even	
vdi103	dc.b	'Countour_fill',0
	even	
vdi104	dc.b	'vsf_perimeter',0
	even	
vdi105	dc.b	'v_get_pixel',0
	even	
vdi106	dc.b	'vst_effects',0
	even	
vdi107	dc.b	'vst_points',0
	even	
vdi108	dc.b	'vsl_ends',0
	even	
vdi109	dc.b	'vro_cpyfm',0
	even	
vdi110	dc.b	'vr_trn_fm',0
	even	
vdi111	dc.b	'vsc_form',0
	even	
vdi112	dc.b	'vsf_updat',0
	even	
vdi113	dc.b	'vsl_udsty',0
	even	
vdi114	dc.b	'vr_recfl',0
	even	
vdi115	dc.b	'vqin_mode',0
	even	
vdi116	dc.b	'David mets a jour ta lib !',0
	even	
vdi117	dc.b	'David mets a jour ta lib !',0
	even	
vdi118	dc.b	'vex_timv',0
	even	
vdi119	dc.b	'vst_load_fonts',0
	even	
vdi120	dc.b	'vst_unload_fonts',0
	even	
vdi121	dc.b	'vrt_cpyfm',0
	even	
vdi122	dc.b	'v_show_c',0
	even	
vdi123	dc.b	'v_hide_c',0
	even	
vdi124	dc.b	'vq_mouse',0
	even	
vdi125	dc.b	'vex_butv',0
	even	
vdi126	dc.b	'vex_motv',0
	even	
vdi127	dc.b	'vex_curv',0
	even	
vdi128	dc.b	'vs_key_s',0
	even	
vdi129	dc.b	'vs_clip',0
	even	
vdi130	dc.b	'vqt_name',0
	even	
vdi131	dc.b	'vqt_font_info',0
	even	
vdi232	dc.b	'vqt_font_header',0
	even	
vdi234	dc.b	'vqt_track_kern',0
	even	
vdi235	dc.b	'vqt_pairkern',0
	even	
vdi236	dc.b	'vst_charmap',0
	even	
vdi237	dc.b	'vst_kern',0
	even	
vdi239	dc.b	'vget_bitmap_info',0
	even	
vdi240	dc.b	'vqt_f_extent',0
	even	
vdi241	dc.b	'v_ftext',0
	even	
vdi242	dc.b	'v_getoutline',0
	even	
vdi243	dc.b	'vst_scratch',0
	even	
vdi244	dc.b	'vst_error',0
	even	
vdi245	dc.b	'vst_arbpt',0
	even	
vdi246	dc.b	'vqt_advance',0
	even	
vdi247	dc.b	'vqt_devinfo',0
	even	
vdi248	dc.b	'v_savecache',0
	even	
vdi249	dc.b	'v_loadcache',0
	even	
vdi250	dc.b	'v_flushcache',0
	even	
vdi251	dc.b	'vst_setsize',0
	even	
vdi252	dc.b	'vst_skew',0
	even	
vdi253	dc.b	'vqt_get_table',0
	even	
vdi254	dc.b	'vqt_cachesize',0
	even	
vdi255	dc.b	'v_set_app_buff',0
	even	



vdi5	dc.b	'Function ESC',0
	even
vdi11	dc.b	'Graphics Base',0
	even




	

fct1	dc.b	'Bar',0
	even
fct2	dc.b	'Arc',0
	even
fct3	dc.b	'Pieslice',0
	even
fct4	dc.b	'Circle',0
	even
fct5	dc.b	'Ellipse',0
	even
fct6	dc.b	'Ellarc',0
	even
fct7	dc.b	'Ellpie',0
	even
fct8	dc.b	'Rbox',0
	even
fct9	dc.b	'Rfbox',0
	even
fct10	dc.b	'Justified',0
	even
fct13	dc.b	'Bez con',0
	even


esc1	dc.b	'vq_chcells',0
	even
esc2	dc.b	'v_exit_cur',0
	even
esc3	dc.b	'v_enter_cur',0
	even
esc4	dc.b	'v_curup',0
	even
esc5	dc.b	'v_curdown',0
	even
esc6	dc.b	'v_curright',0
	even
esc7	dc.b	'v_curleft',0
	even
esc8	dc.b	'v_curhome',0
	even
esc9	dc.b	'v_eeos',0
	even
esc10	dc.b	'v_eeol',0
	even
esc11	dc.b	'vs_vuradress',0
	even
esc12	dc.b	'v_curtext',0
	even
esc13	dc.b	'v_rvon',0
	even
esc14	dc.b	'v_rvoff',0
	even
esc15	dc.b	'vq_curaddress',0
	even
esc16	dc.b	'vq_tabstatus',0
	even
esc17	dc.b	'v_hardcopy',0
	even
esc18	dc.b	'v_dspcur',0
	even
esc19	dc.b	'v_rmcur',0
	even
esc20	dc.b	'v_form_adv',0
	even
esc21	dc.b	'v_output_window',0
	even
esc22	dc.b	'v_clear_diqp_list',0
	even
esc23	dc.b	'v_bit_image',0
	even
esc24	dc.b	'vq_scan',0
	even
esc25	dc.b	'v_alpha_text',0
	even
esc60	dc.b	'vs_palette',0
	even
esc91	dc.b	'vqp_fims',0
	even
esc92	dc.b	'vqp_state',0
	even
esc93	dc.b	'vsp_state',0
	even
esc94	dc.b	'vsp_save',0
	even
esc95	dc.b	'vsp_message',0
	even
esc96	dc.b	'vqp_error',0
	even
esc98	dc.b	'v_meta_extents',0
	even
esc99	dc.b	'vm_coords',0
	even
esc100	dc.b	'v_bez_qual',0
	even


rien	dc.b	0
	even


