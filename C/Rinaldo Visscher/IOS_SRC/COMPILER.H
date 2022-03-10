#if defined LATTICE
#define			ff_reserved	d_resvd
#define			ff_attrib	d_fattr
#define			ff_fsize	d_fsize
#define			ff_name		d_fname

#define			b_free		free
#define			b_clsiz		cpd
#define			b_secsiz	bps

#define FA_READONLY     S_IJRON
#define FA_HIDDEN       S_IJHID
#define FA_SYSTEM       S_IJSYS
#define FA_VOLUME       S_IJVOL
#define FA_SUBDIR       S_IJDIR
#define FA_ARCHIVE      S_IJWAC

#define FO_READ			0
#define FO_WRITE		1
#define FO_RW			2


#endif
