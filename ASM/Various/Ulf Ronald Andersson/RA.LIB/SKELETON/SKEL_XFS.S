;----------------------------------------------------------------------------
;File name:	SKEL_XFS.I			Revision date:	1999.01.31
;Revised by:	Ulf Ronald Andersson		Revision start:	1999.01.31
;----------------------------------------------------------------------------
Remarks:
;
;This file is a DevPac skeleton source for MagiC XFS file systems.  It was
;inspired mainly by Thomas Binder's skeleton for programming in Pure C.
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;Functions defined:
;
;MX_XFS	*install_my_xfs ( void );
;long	MagX_Pdomain ( word domain );
;void	*MagX_Mxalloc ( long amount, word mode);
;long	MagX_Mfree ( void *block );
;long	MagX_Mshrink ( long newsize, void *block );
;
;----------------------------------------------------------------------------
Required definitions:
;
;M_XFS_NAME	macro to initialize the XFS name string (eg: "dc.b 'Ramdsk'")
;long	my_sync( DMD *dmd);
;void	my_pterm( PD *pd);
;long	my_garbcoll( DMD *dmd );	
;void	my_freeDD( DD *dd);
;long	my_drv_open( DMD *dmd );
;long	my_drv_close( DMD *dmd, word mode );
;regmix	my_path2DD( DD *dd, word mode );
;regmix	my_sfirst( DD *srchdir, char *name, long DTA_p, int attrib );
;regmix	my_snext( DTA *dta_p, DMD *dmd );
;regmix my_fopen( DD *dd, char *name, int omode, int cattrib );
;long	my_fdelete( DD *dd, char *name );
;long	my_link(DD *olddir,DD *newdir,long oldname_p,long newname_p,int link_f);
;regmix	my_xattr( DD *dd, char *name, long xattr_p, int mode );
;regmix my_attrib( DD *dd, char *name, int rwflag, int attrib );
;long	my_chown( DD *dd, char *name, word uid, word gid );
;long	my_chmod( DD *dd, char *name, WORM mode );
;long	my_dcreate( DD *dd, char *name );
;long	my_ddelete( DD *dd );
;long	my_DD2name( DD *dd, char *buf, int bufsize );
;DHD	*my_dopendir( DD *dd, int tosmode_f );
;long	my_dreaddir( DHD *dhd, char *buf, int bsz, long xattr_p, long *xr );
;long	my_drewinddir( DHD *dhd );
;long	my_dclosedir( DHD *dhd );
;long	my_dpathconf( DD *dd, int opcode);
;long	my_dfree( DD *dd, long (* result)[4] );
;long	my_wlabel( DD *dd, char *name );
;long	my_rlabel( DD *dd, char *name, long buf_p, int bsz );
;long	my_symlink( DD *lk_dir, char *lk_name, long oldpathname_p );
;long	my_readlink( DD *dd, char *name, long buf_p, int bsz );
;long	my_Dcntl( DD *dd, char *name, int cmd, long arg );
;----------------------------------------------------------------------------
install_my_xfs:				;MagX_XFS *install_my_xfs ( void );
	gemdos	Dcntl,#KER_INSTXFS,!,#my_xfs
	move.l	d0,kernel_p
	ble.s	.exit
	move.l	d0,a3			;a3 -> MagiC kernel struct
	cmp	#2,mxk_version(a3)	;version < 2 ?
	blt.s	.have_Pdomain_usage
	pea	basepage(pc)		;push -> pd
	clr	-(sp)			;push proc_info code to ask for opcode range
	move.l	mxk_proc_info(a3),a0	;a0 -> kernel proc_info function
	jsr	(a0)			;call kernel to get proc_info opcode range
	cmp	#2,d0			;range < 2 ?
	blt.s	.have_Pdomain_usage	;then we will use gemdos Pdomain
	st	Pdomain_ker_f		;else we will use kernel proc_info(0,pd)
.have_Pdomain_usage:
	cmp	#3,mxk_version(a3)	;kernel 3 or newer (better reentrancy) ?
	sge	MagX_3_plus_f		;remember this in a flag
	cmp	#4,mxk_version(a3)	;kernel 4 or newer (more kernel functions) ?
	sge	MagX_4_plus_f		;remember this in a flag
.exit:
	move.l	kernel_p(pc),d0
	rts
;----------------------------------------------------------------------------
;This allows kernel proc_info function to be used for finding domain if that
;is available in the kernel.  (For all modern versions of MagiC it is.)
;
MagX_Pdomain:				;long MagX_Pdomain ( word domain );
	move.b	Pdomain_ker_f(pc),d2
	bne.s	.use_kernel
	gemdos	Pdomain,d0
	rts
;
.use_kernel:
	moveq	#1,d0			;d0 = proc_info opcode for Pdomain
	move.l	kernel_p(pc),a2		;a2 -> kernel struct
	move.l	mxk_act_pd(a2),a0	;a0 ->-> active pd
	move.l	(a0),a0			;a0 -> active pd
	move.l	mxk_proc_info(a2),a2	;a2 -> proc_info function of kernel
	jmp	(a2)			;jump to kernel function
;----------------------------------------------------------------------------
;This allows a fast mxalloc function in kernel to be used if available.
;That will be the case for MagiC kernel >= 4  (MagiC 5.xx ?)
;
MagX_Mxalloc:				;void *MagX_Mxalloc ( long amount, word mode);
	move.b	MagX_4_plus_f(pc),d2
	bne.s	.use_kernel
	gemdos	Mxalloc,d0,d1
	rts
;
.use_kernel:
	move.l	kernel_p(pc),a2		;a2 -> kernel struct
	lea	basepage(pc),a0		;a0 -> owner pd  (basepage)
	move.l	mxk_mxalloc(a2),a2	;a2 -> mxalloc function of kernel
	jmp	(a2)			;jump to kernel function
;----------------------------------------------------------------------------
;This allows a fast mfree function in kernel to be used if available.
;That will be the case for MagiC kernel >= 4  (MagiC 5.xx ?)
;
MagX_Mfree:				;long MagX_Mfree ( void *block );
	move.b	MagX_4_plus_f(pc),d2
	bne.s	.use_kernel
	gemdos	Mfree,(a0)
	rts
;
.use_kernel:				;word Mfree_kernel(void *block)
	move.l	kernel_p(pc),a2		;a2 -> kernel struct
	move.l	mxk_mfree(a2),a2	;a2 -> mfree function of kernel
	jmp	(a2)			;jump to kernel function
;----------------------------------------------------------------------------
;This allows a fast mshrink function in kernel to be used if available.
;That will be the case for MagiC kernel >= 4  (MagiC 5.xx ?)
;
MagX_Mshrink:				;long MagX_Mshrink ( void *block, long newsize );
	move.b	MagX_4_plus_f(pc),d2
	bne.s	.use_kernel
	gemdos	Mshrink,!,(a0),d0
	rts
;
.use_kernel:				;word Mfree_kernel(void *block)
	move.l	kernel_p(pc),a2		;a2 -> kernel struct
	move.l	mxk_mshrink(a2),a2	;a2 -> mfree function of kernel
	jmp	(a2)			;jump to kernel function
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
Pdomain_ker_f:	dc.b	0	;set if proc_info can check Pdomain
MagX_3_plus_f:	dc.b	0	;set for MagiC 4.01 or newer (kernel >= 3)
MagX_4_plus_f:	dc.b	0	;set for MagiC 5.xx or newer (kernel >= 4)
	EVEN
kernel_p:	dc.l	NULL
;
my_xfs:
	iz_beg	sizeof_MX_XFS
;-------
	iz_beg	8
	M_XFS_NAME	;char	xfs_name[8];
	iz_end	;ends xfs_name string initialization
;-------
	dc.l	0		;MX_XFS	*xfs_next
	dc.l	0		;long	xfs_flags
	dc.l	0		;long	xfs_init
	dc.l	my_sync		;xfs_sync
	dc.l	my_pterm	;xfs_pterm
	dc.l	my_garbcoll	;xfs_garbcoll
	dc.l	my_freeDD	;xfs_freeDD
	dc.l	my_drv_open	;xfs_drv_open
	dc.l	my_drv_close	;xfs_drv_close
	dc.l	my_path2DD	;xfs_path2DD
	dc.l	my_sfirst	;xfs_sfirst
	dc.l	my_snext	;xfs_snext
	dc.l	my_fopen	;xfs_fopen
	dc.l	my_fdelete	;xfs_fdelete
	dc.l	my_link		;xfs_link
	dc.l	my_xattr	;xfs_xattr
	dc.l	my_attrib	;xfs_attrib
	dc.l	my_chown	;xfs_chown
	dc.l	my_chmod	;xfs_chmod
	dc.l	my_dcreate	;xfs_dcreate
	dc.l	my_ddelete	;xfs_ddelete
	dc.l	my_DD2name	;xfs_DD2name
	dc.l	my_dopendir	;xfs_dopendir
	dc.l	my_dreaddir	;xfs_dreaddir
	dc.l	my_drewinddir	;xfs_drewinddir
	dc.l	my_dclosedir	;xfs_dclosedir
	dc.l	my_dpathconf	;xfs_dpathconf
	dc.l	my_dfree	;xfs_dfree
	dc.l	my_wlabel	;xfs_wlabel
	dc.l	my_rlabel	;xfs_rlabel
	dc.l	my_symlink	;xfs_symlink
	dc.l	my_readlink	;xfs_readlink
	dc.l	my_dcntl	;xfs_dcntl
;-------
	iz_end	;ends my_xfs structure definition
;----------------------------------------------------------------------------
;End of file:	SKEL_XFS.S
;----------------------------------------------------------------------------
