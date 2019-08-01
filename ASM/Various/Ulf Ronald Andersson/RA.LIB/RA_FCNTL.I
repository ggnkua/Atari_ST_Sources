;----------------------------------------------------------------------------
;File name:	RA_FCNTL.I			Revision date:	1999.12.10
;Revised by:	Ulf Ronald Andersson		Revision start:	1999.12.10
;----------------------------------------------------------------------------
	ifnd	RA_FCNTRL_defined
RA_FCNTL_defined	set	1
;----------------------------------------------------------------------------
F_DUPFD		= 0			;MiNT/MagiC
F_GETFD		= 1			;MiNT/MagiC
F_SETFD		= 2			;MiNT/MagiC
F_GETFL		= 3			;MiNT/MagiC
F_SETFL		= 4			;MiNT/MagiC
F_GETLK		= 5			;MiNT/MagiC
F_SETLK		= 6			;MiNT/MagiC
F_SETLKW	= 7			;MiNT/MagiC
;----------------------------------------------------------------------------
FSTAT		= (('F'<<8)|0)		;MiNT/MagiC
FIONREAD	= (('F'<<8)|1)		;MiNT/MagiC
FIONWRITE	= (('F'<<8)|2)		;MiNT/MagiC
FUTIME		= (('F'<<8)|3)		;MiNT
FTRUNCATE	= (('F'<<8)|4)		;MiNT
;----------------------------------------------------------------------------
TIOCGETP	= (('T'<<8)|0)
TIOCSETN	= (('T'<<8)|1)
TIOCGETC	= (('T'<<8)|2)
TIOCSETC	= (('T'<<8)|3)
TIOCGLTC	= (('T'<<8)|4)
TIOCSLTC	= (('T'<<8)|5)
TIOCGPGRP	= (('T'<<8)|6)		;MiNT
TIOCSPGRP	= (('T'<<8)|7)		;MiNT
TIOCFLUSH	= (('T'<<8)|8)
TIOCSTOP	= (('T'<<8)|9)
TIOCSTART	= (('T'<<8)|10)
TIOCGWINSZ	= (('T'<<8)|11)
TIOCSWINSZ	= (('T'<<8)|12)
TIOCGXKEY	= (('T'<<8)|13)		;MiNT
TIOCSXKEY	= (('T'<<8)|14)		;MiNT
TIOCIBAUD	= (('T'<<8)|18)
TIOCOBAUD	= (('T'<<8)|19)
TIOCCBRK	= (('T'<<8)|20)
TIOCSBRK	= (('T'<<8)|21)
TIOCGFLAGS	= (('T'<<8)|22)
TIOCSFLAGS	= (('T'<<8)|23)
TIOCOUTQ	= (('T'<<8)|24)		;MiNT
TIOCSETP	= (('T'<<8)|25)		;MiNT
TIOCHPCL	= (('T'<<8)|26)		;MiNT
TIOCCAR		= (('T'<<8)|27)		;MiNT
TIOCNCAR	= (('T'<<8)|28)		;MiNT
TIOCWONLINE	= (('T'<<8)|29)		;MiNT
TIOCSFLAGSB	= (('T'<<8)|30)		;MiNT
TIOCGSTATE	= (('T'<<8)|31)		;MiNT
TIOCSSTATEB	= (('T'<<8)|32)		;MiNT
TIOCGVMIN	= (('T'<<8)|33)		;MiNT
TIOCSVMIN	= (('T'<<8)|34)		;MiNT
TIOCBUFFER	= (('T'<<8)|128)
TIOCCTLMAP	= (('T'<<8)|129)
TIOCCTLGET	= (('T'<<8)|130)
TIOCCTLSET	= (('T'<<8)|131)
TIOCCTLSFAST	= (('T'<<8)|132)
TIOCCTLSSLOW	= (('T'<<8)|133)
TIONOTSEND	= (('T'<<8)|134)
TIOCERROR	= (('T'<<8)|135)
;----------------------------------------------------------------------------
PPROCADDR	= (('P'<<8)|1)		;MiNT only
PBASEADDR	= (('P'<<8)|2)		;MiNT/MagiC
PCTXTSIZE	= (('P'<<8)|3)		;MiNT only
PSETFLAGS	= (('P'<<8)|4)		;MiNT only
PGETFLAGS	= (('P'<<8)|5)		;MiNT only
PLOADINFO	= (('P'<<8)|12)		;MiNT/MagiC 6.1
;----------------------------------------------------------------------------
SHMGETBLOCK	= (('M'<<8)|0)		;MiNT/MagiC
SHMSETBLOCK	= (('M'<<8)|1)		;MiNT/MagiC
;----------------------------------------------------------------------------
CDROMREADOFFSET		= (('C'<<8)|0)
CDROMPAUSE		= (('C'<<8)|1)
CDROMRESUME		= (('C'<<8)|2)
CDROMPLAYMSF		= (('C'<<8)|3)
CDROMPLAYTRKIND		= (('C'<<8)|4)
CDROMREADTOCHDR		= (('C'<<8)|5)
CDROMREADTOCENTRY	= (('C'<<8)|6)
CDROMSTOP		= (('C'<<8)|7)
CDROMSTART		= (('C'<<8)|8)
CDROMEJECT		= (('C'<<8)|9)
CDROMVOLCTRL		= (('C'<<8)|10)
CDROMSUBCHNL		= (('C'<<8)|11)
CDROMREADMODE2		= (('C'<<8)|12)
CDROMREADMODE1		= (('C'<<8)|13)
CDROMPREVENTREMOVAL	= (('C'<<8)|14)
CDROMALLOWREMOVAL	= (('C'<<8)|15)
CDROMAUDIOCTRL		= (('C'<<8)|16)
CDROMREADDA		= (('C'<<8)|17)
CDROMGETMCN		= (('C'<<8)|19)
CDROMGETTISRC		= (('C'<<8)|20)
;----------------------------------------------------------------------------
;	Codes for TIOCCTLMAP
;-------------------------------------
TIOCM_LE	= $0001 /* line enable output, Ausgang */
TIOCM_DTR	= $0002 /* data terminal ready, Ausgang */
TIOCM_RTS	= $0004 /* ready to send, hat heute andere Bedeutung, Ausgang */
TIOCM_CTS	= $0008 /* clear to send, hat heute andere Bedeutung, Eingang */
TIOCM_CAR	= $0010 /* data carrier detect, Eingang */
TIOCM_CD	= TIOCM_CAR /* alternativer Name */
TIOCM_RNG	= $0020 /* ring indicator, Eingang */
TIOCM_RI	= TIOCM_RNG /* alternativer Name */
TIOCM_DSR	= $0040 /* data set ready, Eingang */
TIOCM_LEI	= $0080 /* line enable input, Eingang */
TIOCM_TXD	= $0100 /* Sendedatenleitung, Ausgang */
TIOCM_RXD	= $0200 /* Empfangsdatenleitung, Eingang */
TIOCM_BRK	= $0400 /* Break erkannt, Pseudo-Eingang */
TIOCM_TER	= $0800 /* Sendefehler, Pseudo-Eingang */
TIOCM_RER	= $1000 /* Empfangsfehler, Pseudo-Eingang */
TIOCM_TBE	= $2000 /* Hardware-Sendepuffer leer, Pseudo-Eingang */
TIOCM_RBF	= $4000 /* Hardware-Empfangspuffer voll, Pseudo-Eingang */
;----------------------------------------------------------------------------
	endc	;RA_FCNTRL_defined
;----------------------------------------------------------------------------
;End of file:	RA_FCNTRL.I
;----------------------------------------------------------------------------
