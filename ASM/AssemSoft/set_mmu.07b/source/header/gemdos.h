;======= GEMDOS stuff

*** File attribute defs ***
Fatrib_readonly	= 0
Fatrib_hidden	= 1
Fatrib_system	= 2
Fatrib_volume	= 3
Fatrib_dir	= 4
Fatrib_arch	= 5

*** Mxalloc modes ***
aloc_st		= 0
aloc_tt		= 1
aloc_preferst	= 2
aloc_prefertt	= 3

aloc_memprotsel	= 1<<3

aloc_private	= 1<<4
aloc_global	= 2<<4
aloc_super	= 3<<4
aloc_privread	= 4<<4

*** Structure DTA ***
	rsset 0
d_reserved	rs.b 21
d_attrib	rs.b 1
d_time		rs.w 1
d_date		rs.w 1
d_lenght	rs.l 1
d_fname		rs.b 14

*** Basepage strucutre ****
	rsset 0
bp_lowtpa	rs.l 1
bp_hitpa	rs.l 1
bp_tbase	rs.l 1
bp_tlen		rs.l 1
bp_dbase	rs.l 1
bp_dlen		rs.l 1
bp_bbase	rs.l 1
bp_blen		rs.l 1
bp_dta		rs.l 1
bp_parent	rs.l 1
bp_reserved	rs.l 1
bp_env		rs.l 1
bp_undef	rs.b 80
bp_cmdlin	rs.l 1

