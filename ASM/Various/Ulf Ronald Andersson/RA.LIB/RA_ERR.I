;----------------------------------------------------------------------------
;File name:	RA_ERR.I			Revision date:	1998.08.28
;Creator:	Ulf Ronald Andersson		Creation date:	1997.01.02
;(c)1997 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sale forbidden)
;----------------------------------------------------------------------------
;Purpose:	Defines error codes for TOS functions
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_ERR_defined
RA_ERR_defined	set	1
;----------------------------------------------------------------------------
;NB:	System error messages were badly defined by Atari to have a prefix
;	simply consisting of the letter 'E', which makes mixups inevitable.
;	There is no way I am ever going to accept using such codes, so do
;	not waste your breath discussing this subject with me...  ;-)
;
;	Using underscore at prefix end would make this 'E_', but this is used
;       by many packages for proprietary error messages, since Atari had left
;	them 'free'.  Nevertheless, this is the only simple and useful prefix
;	that is guaranteed to be compatible with all assemblers, so that is
;	what I use.  For proprietary error messages I suggest that the 'E__'
;	prefix be used instead.
;
;	eg: Use E_OK, E_NSMEM, E_ACCESS, instead of EOK, ENSMEM, EACCESS,
;           but for proprietary application error codes with similar names,
;	    rename those to be E__OK, E__NSMEM, E__ACCESS etc...
;----------------------------------------------------------------------------
;	Error code definitions
;
;NB: The first group ONLY represents codes relevant to 'etv_critic'
;
E_OK		=	  0	;normal, no error
E_ERROR		=	 -1	;generic error
E_IO		=	E_ERROR
E_DRVNR		=	 -2	;drive not ready
E_UNCMD		=	 -3	;unknown command
E_CRC		=	 -4	;CRC error
E_BADRQ		=	 -5	;bad request
E_SEEK		=	 -6	;seek error
E_MEDIA		=	 -7	;unknown media
E_SECNF		=	 -8	;sector not found
E_PAPER		=	 -9	;out of paper
E_WRITF		=	-10	;write fault
E_READF		=	-11	;read fault
E_GENRL		=	-12	;general error
E_WRPRO		=	-13	;write protected
E_CHNG		=	-14	;media change detected
E_AGAIN		=	E_CHNG
E_UNDEV		=	-15	;unknown device
E_BADSF		=	-16	;bad sectors on format
E_OTHER		=	-17	;insert other disk request
;
;	--------
;
E_INSERT	=	-18
E_DEVNRSP	=	-19
;
;	--------
;
E_INVFN		=	-32	;invalid function
E_FILNF		=	-33	;file not found
E_NOENT		=	E_FILNF
E_RSCH		=	E_FILNF
E_PTHNF		=	-34	;path not found
E_NOTDIR	=	E_PTHNF
E_NHNDL		=	-35	;no more handles
E_ACCDN		=	-36	access denied
E_ACCESS	=	E_ACCDN
E_EXIST		=	E_ACCDN
E_IHNDL		=	-37	;invalid handle
; ???		=	-38
E_NSMEM		=	-39	;not sufficient memory
;;;E_NOMEM	=	E_NSMEM	;voided due to STING conflict
E_IMBA		=	-40	;invalid memory block address
; ???		=	-41
E_DFULL		=	-42
; ???		=	-43
; ???		=	-44
; ???		=	-45
E_DRIVE		=	-46	;invalid drive spec
; ???		=	-47
E_NSAME		=	-48	;cross device rename
E_XDEV		=	E_NSAME
E_NMFIL		=	-49	;no more files (fsfirst/fsnext)
; ???		=	-50
; ???		=	-51
; ???		=	-52
; ???		=	-53
; ???		=	-54
; ???		=	-55
; ???		=	-56
; ???		=	-57
E_RLCKD		=	-58	;record already locked
E_LOCK		=	E_RLCKD
;;;E_LOCKED	=	E_RLCKD	;voided due to STING conflict
E_MLNF		=	-59	;invalid lock removal request
E_NSLOCK	=	E_MLNF
; ???		=	-60
; ???		=	-61
; ???		=	-62
; ???		=	-63
E_RANGE		=	-64	;range error
E_NAMETOOLONG	=	E_RANGE
E_INTRN		=	-65	;internal error
E_PLFMT		=	-66	;invalid program load format
E_NOEXEC	=	E_PLFMT
E_GSBF		=	-67	;memory block growth failure
E_BREAK		=	-68
E_XCPT		=	-69	;MagiC
E_PTHOV		=	-70
;
;	--------
;
E_LOOP		=	-80	;too many symbolic links
E_MOUNT		=	-200
E_LINK		=	-300	;def by Thomas Binder for MagiC XFS
;----------------------------------------------------------------------------
	ENDC	;RA_ERR_defined
;----------------------------------------------------------------------------
;End of file:	URAn_ERR.I
;----------------------------------------------------------------------------
