;----------------------------------------------------------------------------
;File name:	MX_DFS.I			Revision date:	1999.12.10
;Revised by:	Ulf Ronald Andersson		Revision start:	1999.01.31
;----------------------------------------------------------------------------
	ifnd	MX_DFS_defined
MX_DFS_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I
;----------------------------------------------------------------------------
	struct	MX_DDEV
	func_p	mx_ddev_open		;func(FD)
	func_p	mx_ddev_close		;func(FD)
	func_p	mx_ddev_read		;func(FD,count,buff)
	func_p	mx_ddev_write		;func(FD,count,buff)
	func_p	mx_ddev_stat		;func(FD,MX_UNSEL,rw_flag,apcode)
	func_p	mx_ddev_seek		;func(FD,where,how)
	func_p	mx_ddev_datime		;func(FD,DOSTIME,w_flag)  (NULL ok)
	func_p	mx_ddev_ioctl		;func(FD,cmd,buf_p)
	func_p	mx_ddev_delete		;func(FD) => kill driver
	func_p	mx_ddev_getc		;func(FD,mode)            (NULL ok)
	func_p	mx_ddev_getline		;func(FD,buf,size,mode)   (NULL ok)
	func_p	mx_ddev_putc		;func(FD,mode,value)      (NULL ok)
	d_end	MX_DDEV
;----------------------------------------------------------------------------
	struct	MX_DOSFD
	struc_p	mx_dfd_dmd		;-> DMD
	int16	mx_dfd_refcnt		;reference counter (or -1)
	uint16	mx_dfd_mode		;open-mode and flags
	uint32	mx_dfd_dev		;-> MX_DEV
	struc_p	mx_dfd_ddev		;-> MX_DDEV
	char	mx_dfd_name,11		;only valid for proto-FD in subfolder
	uint8	mx_dfd_attr		;attribute, only valid in proto-FD
	struc_p	mx_dfd_owner		;->PD of owning process (0 = unused)
	struc_p	mx_dfd_parent		;superior DD  (only in proto-FD)
	struc_p	mx_dfd_children		;inferior DDs/FDs (only in proto-FD)
	struc_p	mx_dfd_next		;next DD/FD at same level (only in proto-FD)
	struc_p	mx_dfd_multi		;-> list of clone-FDs, NULL at end
	struc_p	mx_dfd_multi1		;-> proto-FD (even in proto-FD)
	uint32	mx_dfd_fpos		;position in file (0 for a device)
	uint8	mx_dfd_dirch		;bit 0 flags changes affecting directory
	uint8	mx_dfd_unused		;
	uint16	mx_dfd_time		;time (8086)
	uint16	mx_dfd_date		;date (8086)
	uint16	mx_dfd_stcl		;start cluster
	uint32	mx_dfd_len		;file length (bytes)
	uint32	mx_dfd_dirpos		;position in directory (only in proto-FD)
	uint32	mx_dfd_user1		;\/ Free for the DFS to define
	uint32	mx_dfd_user2		;/\ for proto-FD (copied to clones at open)
	d_end	MX_DOSFD
;----------------------------------------------------------------------------
	struct	MX_DOSDTA
	char	mx_ddta_sname,12	;search name from Fsfirst
	uint32	mx_ddta_usr1		;free for DFS to define
	uint32	mx_ddta_usr2		;free for DFS to define	
	uint8	mx_ddta_drive		;GEMDOS drive number
	uint8	mx_ddta_attribute	;found attribute
	uint16	mx_ddta_time		;found time
	uint16	mx_ddta_date		;found date
	uint32	mx_ddta_len		;found length
	char	mx_ddta_name,14		;found name
	d_end	MX_DOSDTA
;----------------------------------------------------------------------------
	struct	MX_DOSDMD
	struc_p	mx_ddmd_xfs		;-> xfs owning this drive
	int16	mx_ddmd_drive		;GEMDOS drive number (0..25)
	struc_p	mx_ddmd_root		;-> DD of root directory
	int16	mx_ddmd_biosdev		;BIOS drive number or -1
	uint32	mx_ddmd_driver		;\/ If these two differ, this means
	uint32	mx_ddmd_devcode		;/\ media has been changed. (lockup)
	struc_p	mx_ddmd_dfs		;-> dfs  (only for DFS filesystems)
	d_end	MX_DOSDMD
;----------------------------------------------------------------------------
	struct	MX_DOSDIR
	char	mx_ddir_name,11
	uint8	mx_ddir_attr
	uint16	mx_ddir_usr1
	uint32	mx_ddir_usr2
	uint32	mx_ddir_usr3
	uint16	mx_ddir_time		;(8086)
	uint16	mx_ddir_date		;(8086)
	uint16	mx_ddir_stcl
	uint32	mx_ddir_flen		;(8086)
	d_end	MX_DOSDIR
;----------------------------------------------------------------------------
	struct	MX_DFS
	char	mx_dfs_name,8		;name of DFS (unused)
	struc_p	mx_dfs_next		;-> next DFS (def as 0)
	func_p	mx_dfs_init		;unused for loadable XFS
	func_p	mx_dfs_sync		;func(DMD) to flush buffers
	func_p	mx_dfs_drv_open		;func(DMD) to open drive
	func_p	mx_dfs_drv_close	;func(DMD,mode) to close drive
	func_p	mx_dfs_dfree		;func(FD,result_p)
	func_p	mx_dfs_sfirst		;func(FD,DIR,pos,DTA)
	func_p	mx_dfs_snext		;func(DTA,DMD)
	func_p	mx_dfs_ext_fd		;func(FD) (extend file or folder ???)
	func_p	mx_dfs_fcreate		;func(FD,DIR,cmd,arg)
	func_p	mx_dfs_fxattr		;func(FD,DIR,mode,XATTR)
	func_p	mx_dfs_dir2index	;func(FD,DIR)
	func_p	mx_dfs_readlink		;func(FD,DIR)
	func_p	mx_dfs_dir2FD		;func(FD,DIR)
	func_p	mx_dfs_fdelete		;func(FD,DIR)
	func_p	mx_dfs_pathconf		;func(FD,which)
	d_end	MX_DFS
;----------------------------------------------------------------------------
	endc	;MX_DFS_defined
;----------------------------------------------------------------------------
;End of file:	MX_DFS.I
;----------------------------------------------------------------------------
