	ifnd	GEMDOS_H
GEMDOS_H:	set 1

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
dta_ssize:	= __RS

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
bp_cmdlin	rs.b 128
bp_ssize:	= __RS

*** XATTR structuer ***
	rsreset
xattr_mode:	rs.w 1
xattr_index:	rs.l 1
xattr_dev:	rs.w 1
xattr_reserved1:rs.w 1
xattr_nlink:	rs.w 1
xattr_uid:	rs.w 1
xattr_gid:	rs.w 1
xattr_size:	rs.l 1
xattr_blksize:	rs.l 1
xattr_nblocks:	rs.l 1
xattr_mtime:	rs.w 1
xattr_mdate:	rs.w 1
xattr_atime:	rs.w 1
xattr_adate:	rs.w 1
xattr_ctime:	rs.w 1
xattr_cdate:	rs.w 1
xattr_attr:	rs.w 1
xattr_reserved2:rs.w 1
xattr_reserved3:rs.l 1
xattr_reserved4:rs.l 1
xattr_ssize	= __RS

FA_RDONLY:	= 1
FA_HIDDEN:	= 2
FA_SYSTEM:	= 4
FA_LABEL:	= 8
FA_DIR:		= $10
FA_CHANGED:	= $20
FA_VFAT:	= $F
FA_SYMLINK:	= $40

*** Pexec() modes ***
PE_LOADGO:	= 0
PE_LOAD:	= 3
PE_GO:		= 4
PE_BASEPAGE:	= 5
PE_GOTHENFREE:	= 6
PE_CLOADGO:	= 100
PE_CGO:		= 104
PE_NOSHARE:	= 106
PE_REPLACE:	= 200

	endc	;GEMDOS_H
*EOF*
