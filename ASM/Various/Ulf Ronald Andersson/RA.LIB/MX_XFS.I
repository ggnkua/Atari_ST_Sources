;----------------------------------------------------------------------------
;File name:	MX_XFS.I			Revision date:	1999.12.10
;Revised by:	Ulf Ronald Andersson		Revision start:	1999.01.31
;----------------------------------------------------------------------------
	ifnd	MX_XFS_defined
MX_XFS_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I
;----------------------------------------------------------------------------
ELINK	= -300				;File attribute $FED4 == symlink
;----------------------------------------------------------------------------
	struct	MX_KERNEL
	int	mxk_version		;int	mxk_version;
	func_p	mxk_fast_clrmem		;void	fast_clrmem( void *base, void *end_excl );
	func_p	mxk_toupper		;char	toupper( char ch );
	func_p	mxk__sprintf		;void	CDECL sprintf( char *dest, char *src, ... )
	void_p	mxk_act_pd		;void	*act_pd;
	void_p	mxk_act_appl		;APPL	*act_appl;
	func_p	mxk_keyb_app		;APPL	*keyb_app;
	func_p	mxk_pe_slice		;int	*pe_slice;
	func_p	mxk_pe_timer		;int	*pe_timer;
	func_p	mxk_appl_yield		;void	appl_yield ( void );
	func_p	mxk_appl_suspend	;void	appl_suspend ( void );
	func_p	mxk_appl_begcritic	;void	appl_begcritic ( void );
	func_p	mxk_appl_endcritic	;void	appl_endcritic ( void );
	func_p	mxk_evnt_IO		;long	evnt_IO ( long ticks_50hz, void *unsel );
	func_p	mxk_evnt_mIO		;long	evnt_mIO ( long ticks_50hz, void *unsel, int cnt );
	func_p	mxk_evnt_emIO		;long	evnt_emIO ( APPL *app );
	func_p	mxk_appl_IOcomplete	;void	appl_IOcomplete ( APPL *app );
	func_p	mxk_evnt_sem		;long	evnt_sem ( int mode, void *sem, long timeout );
	func_p	mxk_Pfree		;void	Pfree ( PD *pd );
	int	mxk_int_msize		;int	int_msize;
	func_p	mxk_int_malloc		;void	*int_malloc ( void );
	func_p	mxk_int_mfree		;void	int_mfree ( void *memblk );
	func_p	mxk_resv_intmem		;void	resv_intmem ( void *mem, long size );
	func_p	mxk_diskchange		;long	diskchange ( int drv );
;------- kernel < 1 limit --------
	func_p	mxk_DMD_rdevinit	;long	DMD_rdevinit ( DMD *dmd );
;------- kernel < 2 limit --------
	func_p	mxk_proc_info		;long	proc_info ( word code, PD *pd );
;------- kernel < 4 limit --------
	func_p	mxk_mxalloc		;void	*mxalloc ( long size, word mode, PD *pd );
	func_p	mxk_mfree		;long	mfree ( void * block );
	func_p	mxk_mshrink		;long	mshrink ( void *block, long newsize );
	d_end	MX_KERNEL
;----------------------------------------------------------------------------
	struct	MX_DFSKERNEL;
	WORD	mxdk_version;
	LONG	mxdk__dir_srch;
	LONG	mxdk_reopen_FD;
	LONG	mxdk_close_DD;
	LONG	mxdk_match_8_3;
	LONG	mxdk_conv_8_3;
	LONG	mxdk_init_DTA;
	d_end	mxdk_MX_DFSKERNEL;
;----------------------------------------------------------------------------
	struct	MX_DEV
	func_p	mx_dev_close		;func(FD)
	func_p	mx_dev_read		;func(FD,count,buff)
	func_p	mx_dev_write		;func(FD,count,buff)
	func_p	mx_dev_stat		;func(FD,MX_UNSEL,rw_flag,apcode)
	func_p	mx_dev_seek		;func(FD,where,how)
	func_p	mx_dev_datime		;func(FD,DOSTIME,w_flag)
	func_p	mx_dev_ioctl		;func(FD,cmd,buf_p)
	func_p	mx_dev_getc		;func(FD,mode)
	func_p	mx_dev_getline		;func(FD,buf,size,mode)
	func_p	mx_dev_putc		;func(FD,mode,value)
	d_end	MX_DEV
;----------------------------------------------------------------------------
	struct	MX_DD
	struc_p	mx_dd_dmd		;-> DMD
	int16	mx_dd_refcnt		;reference counter
	d_end	MX_DD
;----------------------------------------------------------------------------
	struct	MX_FD
	struc_p	mx_fd_dmd		;-> DMD
	int16	mx_fd_refcnt		;reference counter (or -1)
	uint16	mx_fd_mode		;open-mode and flags
	uint32	mx_fd_dev		;-> MX_DEV
	d_end	MX_FD
;----------------------------------------------------------------------------
	struct	MX_DHD
	struc_p	mx_dhd_dmd		;->DMD
	d_end	MX_DHD
;----------------------------------------------------------------------------
	struct	MX_DTA
	byte	mx_dta_res1,20		;20 bytes free for XFS to define
	uint8	mx_dta_drive		;GEMDOS drive number
	uint8	mx_dta_attribute	;found attribute
	uint16	mx_dta_time		;found time
	uint16	mx_dta_date		;found date
	uint32	mx_dta_len		;found length
	char	mx_dta_name,14		;found name
	d_end	MX_DTA
;----------------------------------------------------------------------------
	struct	MX_DMD
	struc_p	mx_dmd_xfs		;-> xfs owning this drive
	int16	mx_dmd_drive		;GEMDOS drive number (0..25)
	struc_p	mx_dmd_root		;-> DD of root directory
	int16	mx_dmd_biosdev		;BIOS drive number or -1
	uint32	mx_dmd_driver		;\/ If these two differ, this means
	uint32	mx_dmd_devcode		;/\ media has been changed. (lockup)
	d_end	MX_DMD
;----------------------------------------------------------------------------
	struct	MX_XFS
	char	mx_xfs_name,8		;name of XFS (unused)
	struc_p	mx_xfs_next		;-> next XFS (def as 0)
	uint32	mx_xfs_flags		;unused
	func_p	mx_xfs_init		;unused for loadable XFS
	func_p	mx_xfs_sync		;func(DMD) to flush buffers
	func_p	mx_xfs_pterm		;func(PD) to clean up after APP
	func_p	mx_xfs_garbcoll		;func(DMD) to release max internal RAM
	func_p	mx_xfs_freeDD		;func(DD) to release DD
	func_p	mx_xfs_drv_open		;func(DMD) to open drive
	func_p	mx_xfs_drv_close	;func(DMD,mode) to close drive
	func_p	mx_xfs_path2DD		;func(DD,name,mode)=>DD,restpath
	func_p	mx_xfs_sfirst		;func(DD,name,DTA,attr)
	func_p	mx_xfs_snext		;func(DTA,DMD)
	func_p	mx_xfs_fopen		;func(DD,name,omode,attr)=>FD
	func_p	mx_xfs_fdelete		;func(DD,name)
	func_p	mx_xfs_link		;func(olDD,nuDD,olname,nuname,linkflag)
	func_p	mx_xfs_xattr		;func(DD,name,XATTR,mode)
	func_p	mx_xfs_attrib		;func(DD,name,rwflag,attrib)
	func_p	mx_xfs_chown		;func(DD,name,uid,gid)
	func_p	mx_xfs_chmod		;func(DD,name,mode)
	func_p	mx_xfs_dcreate		;func(DD,name)
	func_p	mx_xfs_ddelete		;func(DD,name)
	func_p	mx_xfs_DD2name		;func(DD,name_p,buf_len)
	func_p	mx_xfs_dopendir		;func(DD,tosflag)=>DHD
	func_p	mx_xfs_dreaddir		;func(DHD,size,buff,XATTR,xr)
	func_p	mx_xfs_drewinddir	;func(DHD)
	func_p	mx_xfs_dclosedir	;func(DHD)
	func_p	mx_xfs_dpathconf	;func(DD,which)
	func_p	mx_xfs_dfree		;func(DD,result_p)
	func_p	mx_xfs_wlabel		;func(DD,name)
	func_p	mx_xfs_rlabel		;func(DD,name,buf_p,buf_len)
	func_p	mx_xfs_symlink		;func(DD,name,oldpathname)
	func_p	mx_xfs_readlink		;func(DD,name,buf_p,buf_len)
	func_p	mx_xfs_dcntl		;func(DD,name,cmd,arg)
	d_end	MX_XFS
;----------------------------------------------------------------------------
;	Dcntl(KER_DOSLIMITS) -> Pointer to pointer to: */
;----------------------------------------------------------------------------
	struct	MX_DOSLIMITS
	UWORD	mx_dlim_version		;Version number
	UWORD	mx_dlim_num_drives	;Max. number of drives
	ULONG	mx_dlim_max_secsizb	;Max. sector size in bytes
	UWORD	mx_dlim_min_nfats	;Min. number of FATs
	UWORD	mx_dlim_max_nfats	;Max. number of FATs
	ULONG	mx_dlim_min_nclsiz	;Min. number of sectors/clusters
	ULONG	mx_dlim_max_nclsiz	;Max. number of sectors/clusters
	ULONG	mx_dlim_max_ncl		;Max. number of clusters
	ULONG	mx_dlim_max_nsec	;Max. number of sectors
	d_end	MX_DOSLIMITS;
;----------------------------------------------------------------------------
;Schreib-/Lesemodi fÅr Fgetchar und Fputchar
;
CMODE_RAW	=	0
CMODE_COOKED	=	1
BCMODE_COOKED	=	0
CMODE_ECHO	=	2
BCMODE_ECHO	=	1
;----------------------------------------------------------------------------
;Open- Modus von Dateien (Mag!X- intern)
;NOINHERIT wird nicht unterstÅtzt, weil nach TOS- Konvention nur die
;Handles 0..5 vererbt werden
;HiByte wie unter MiNT verwendet
;
OM_RPERM	=	1	;Datei ist zum Lesen geîffnet
OM_WPERM	=	2	;Datei ist zum Schreiben geîffnet
OM_EXEC		=	4	;Datei ist zum AusfÅhren geîffnet
OM_APPEND	=	8	;Schreibzugriffe ans Ende (Kernel!)
OM_RDENY	=	16	;andere dÅrfen nicht gleichz. lesen
OM_WDENY	=	32	;andere dÅrfen nicht gleichz. schreiben
OM_NOCHECK	=	64	;KEINE öberprÅfung durch den Kernel
BOM_RPERM	=	0
BOM_WPERM	=	1
BOM_EXEC	=	2
BOM_APPEND	=	3
BOM_RDENY	=	4
BOM_WDENY	=	5
BOM_NOCHECK	=	6
;----------------------------------------------------------------------------
;Open- Modus von Dateien (MiNT)
;
O_RWMODE	=	3	;Maske fÅr r/w- Modi
O_RDONLY	=	0
O_WRONLY	=	1
O_RDWR		=	2
O_EXEC		=	3
;
O_APPEND	=	8	;Schreiben geht immer ans Dateiende
BO_APPEND	=	3
;
O_SHMODE	=	$70
O_COMPAT	=	0
O_DENYRW	=	$10
O_DENYW		=	$20
O_DENYR		=	$30
O_DENYNONE	=	$40
;
O_NOINHERIT	=	$80	; von Mag!X nicht unterstÅtzt
O_NDELAY	=	$100	; von Mag!X nicht unterstÅtzt
O_CREAT		=	$200
O_TRUNC		=	$400
O_EXCL		=	$800
BO_CREAT	=	9
BO_TRUNC	=	10
BO_EXCL		=	11
O_TTY		=	$2000	; von Mag!X nicht unterstÅtzt
O_HEAD		=	$4000	; von Mag!X nicht unterstÅtzt
O_LOCK		=	$8000	; von Mag!X nicht unterstÅtzt
;----------------------------------------------------------------------------
LASTDRIVE	=	'Z'-'A'	; hîchste Laufwerknummer
;----------------------------------------------------------------------------
;FÅr Psemaphore, die Modi 0/1 werden z.Zt. nicht unterstÅtzt
;
PSEM_CRGET	=	0	;create and get
PSEM_DESTROY	=	1
PSEM_GET	=	2
PSEM_RELEASE	=	3
;----------------------------------------------------------------------------
	endc	;MX_XFS_defined
;----------------------------------------------------------------------------
;End of file:	MX_XFS.I
;----------------------------------------------------------------------------
