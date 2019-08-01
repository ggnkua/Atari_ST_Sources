;----------------------------------------------------------------------------
;File name:	RAMDISK.I			Revision date:	1999.01.31
;Created by:	Ulf Ronald Andersson		Creation date:	1999.01.31
;----------------------------------------------------------------------------
; Purpose:	Header file for MagiC ramdisk XFS
;----------------------------------------------------------------------------
	ifnd	RAMDISK_defined
RAMDISK_defined	set	1
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_JAR.I
	include	RA_ENV.I
;----------------------------------------------------------------------------
MAX_FD		=	200
MAX_DHD		=	100
ROOTSIZE	=	100
DIRENTRY_size	=	128
DEFAULTFILE	=	4096
DEFAULTDIR	=	(DEFAULTFILE/DIRENTRY_size)
ROOT		=	0
ROOT_DE		=	1
LEAVE_FREE	=	(512L * 1024L)
RAM_TYPE	=	3
;
is_file	MACRO	exp
	move	\1,d0
	and	#S_IFMT,d0
	eor	#S_IFREG,d0
	ENDM	;is_file
;
is_dir	MACRO	exp
	move	\1,d0
	and	#S_IFMT,d0
	eor	#S_IFDIR,d0
	ENDM	;is_dir
;
is_link	MACRO	exp
	move	\1,d0
	and	#S_IFMT,d0
	eor	#S_IFLNK,d0
	ENDM	;is_link
;
waccess	MACRO	
;;;waccess(x)		((x)->de_xattr.mode & S_IWUSR)
;;;raccess(x)		((x)->de_xattr.mode & S_IRUSR)
;;;xaccess(x)		((x)->de_xattr.mode & S_IXUSR)
;;;
;;;parentfd(x)		((x)->fd_parent->fd_file)
;----------------------------------------------------------------------------
	struct	DIRENTRY
	char	de_fname,34
	char_p	de_faddr
	word	de_nr
	word	de_maxnr
	byte	de_xattr,sizeof_XATTR
	d_phase	128
	d_end	DIRENTRY
;----------------------------------------------------------------------------
	struct RAMDISK_FD
	byte	fd_main,sizeof_MX_FD
	long	fd_fpos
	struc_p	fd_file		;DIRENTRY	*fd_file;
	word	fd_is_parent
	struc_p	fd_parent	;RAMDISK_FD	*fd_parent;
	struc_p	fd_owner	;BASPAG		*fd_owner;
	d_end	RAMDISK_FD
;----------------------------------------------------------------------------
	struct	RAMDISK_DHD
	byte	dhd_main,sizeof_MX_DHD
	struc_p	dhd_dir		;DIRENTRY	*dhd_dir;
	word	dhd_pos
	word	dhd_tosmode
	struc_p	dhd_owner	;BASPAG		*dhd_owner;
	d_end	RAMDISK_DHD;
;----------------------------------------------------------------------------
	struct	RAMDISK_DTA
	struc_p	dta_dir		;DIRENTRY	*dta_dir;
	word	dta_pos
	char	dta_mask,13
	char	dta_attr
	char	dta_drive
	d_phase	sizeof_DTA
	d_end	RAMDISK_DTA
;----------------------------------------------------------------------------
	struct	FBLK
	char	FB_data,DEFAULTFILE
	struc_p	FB_next		;FBLK	*next;
	d_end	FBLK
;----------------------------------------------------------------------------
	endc	;RAMDISK_defined
;----------------------------------------------------------------------------
;End of file:	RAMDISK.I
;----------------------------------------------------------------------------
