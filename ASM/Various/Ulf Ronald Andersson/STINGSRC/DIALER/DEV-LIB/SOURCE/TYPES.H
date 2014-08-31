/*
 * TYPES.H
 *
 * global type definitions of project "device.lib"
 *
 */

#ifndef __TYPES_H__
#define __TYPES_H__

/*--- includes              ---*/

#include <tos.h>
#include <mint\mintbind.h>

/*--- defines               ---*/

/*
 * Mode um Device nicht-blockierend zu îffnen:
 */
#define		O_NDELAY		0x0100

/*
 * Ermittlung, wieviel Byte nichtblockierend Åbertragen werden kînnen:
 */
#define		FIONREAD		(('F' << 8) | 1)
#define		FIONWRITE		(('F' << 8) | 2)

/*
 * Leeren der seriellen Puffer
 */
#define		TIOCFLUSH		(('T' << 8) | 8)

/*
 * Stoppen des Empfangs
 */
#define		TIOCSTOP		(('T' << 8) | 9)

/*
 * Starten des Empfangs
 */
#define		TIOCSTART		(('T' << 8) | 10)

/*
 * Setzen/Abfragen der Eingabegeschwindigkeit und Steuerung der
 * DTR-Leitung:
 */
#define		TIOCIBAUD		(('T' << 8) | 18)

/*
 * Setzen und RÅcksetzen von Break:
 */
#define		TIOCCBRK		(('T' << 8) | 20)
#define		TIOCSBRK		(('T' << 8) | 21)

/*
 * öbertragungsprotokolleinstellungen erfragen und setzen:
 */
#define		TIOCGFLAGS		(('T' << 8) | 22)
#define		TIOCSFLAGS		(('T' << 8) | 23)

#define		TF_STOPBITS		0x0003
#define		TF_1STOP		0x0001
#define		TF_15STOP		0x0002
#define		TF_2STOP		0x0003

#define		TF_CHARBITS		0x000c
#define		TF_8BIT			0x0000
#define		TF_7BIT			0x0004
#define		TF_6BIT			0x0008
#define		TF_5BIT			0x000c

#define		TF_FLAG			0xf000
#define		T_TANDEM		0x1000
#define		T_RTSCTS		0x2000
#define		T_EVENP			0x4000
#define		T_ODDP			0x8000

/*
 * Erfragen/Setzen der Puffereinstellungen
 */
#define		TIOCBUFFER		(('T' << 8) | 128)

/*
 * Erfragen der I/O-Leitungen und SignalisierungsfÑhigkeiten
 */
#define		TIOCCTLMAP		(('T' << 8) | 129)

/*
 * Abfragen und setzen der I/O-Leitungen und Signalisierungen
 */
#define		TIOCCTLGET		(('T' << 8) | 130)
#define		TIOCCTLSET		(('T' << 8) | 131)

#define		TIOCM_LE		0x0001		/* line enable output, Ausgang */
#define		TIOCM_DTR		0x0002		/* data terminal ready, Ausgang */
#define		TIOCM_RTS		0x0004		/* ready to send, hat heute andere Bedeutung, Ausgang */
#define		TIOCM_CTS		0x0008		/* clear to send, hat heute andere Bedeutung, Eingang */
#define		TIOCM_CAR		0x0010		/* data carrier detect, Eingang */
#define		TIOCM_CD		TIOCM_CAR	/* alternativer Name */
#define		TIOCM_RNG		0x0020		/* ring indicator, Eingang */
#define		TIOCM_RI		TIOCM_RNG	/* alternativer Name */
#define		TIOCM_DSR		0x0040		/* data set ready, Eingang */
#define		TIOCM_LEI		0x0080		/* line enable input, Eingang */
#define		TIOCM_TXD		0x0100		/* Sendedatenleitung, Ausgang */
#define		TIOCM_RXD		0x0200		/* Empfangsdatenleitung, Eingang */
#define		TIOCM_BRK		0x0400		/* Break erkannt, Pseudo-Eingang */
#define		TIOCM_TER		0x0800		/* Sendefehler, Pseudo-Eingang */
#define		TIOCM_RER		0x1000		/* Empfangsfehler, Pseudo-Eingang */
#define		TIOCM_TBE		0x2000		/* Hardware-Sendepuffer leer, Pseudo-Eingang */
#define		TIOCM_RBF		0x4000		/* Hardware-Empfangspuffer voll, Pseudo-Eingang */

/*
 * Erfragen der Anzahl noch nicht gesendeter Byte
 */
#define		TIONOTSEND		(('T' << 8) | 134)

/*
 * Terminal-Parameter setzen:
 */
#define TIOCGETP	(('T'<< 8) | 0)
#define TIOCSETP	(('T'<< 8) | 1)

/* terminal control constants (tty.sg_flags) */
#define		T_CRMOD			0x0001
#define		T_CBREAK		0x0002
#define		T_ECHO			0x0004
#define		T_RAW			0x0010
#define		T_TOS			0x0080
#define		T_TOSTOP		0x0100
#define		T_XKEY			0x0200
#define		T_ECHOCTL		0x0400

/*--- types                 ---*/

/*
 * MiNT-Strukturen:
 */
typedef struct
{
	BYTE	sg_ispeed,
			sg_ospeed,
			sg_erase,
			sg_kill;
	USHORT	sg_flags;
} SGTTYB;

/*
 * HSModem RSVF-Strukturen:
 */
typedef struct
{
	UWORD	device		: 1;
	UWORD	file_io		: 1;
	UWORD	bios		: 1;
	UWORD	unused		: 13;
} HS_TYPES;

typedef struct
{
	VOID		*ptr;
	HS_TYPES	typ;
	UBYTE		bios_nr;
	UBYTE		unused;
} RSVF_DEV;

/*
 * FAST_SER Strukturen:
 */
typedef struct
{
	UWORD	version;
	UWORD	unused			: 15;
	UWORD	baud_table_flag	: 1;
	BASPAG	*mem_blk;
} FSER_INFO;

typedef struct
{
	LONG	baudrate;
	UWORD	SCC_BRG_value;
	UWORD	SCC_MISC_value;
} BAUD_INFO;

typedef struct
{
	BAUD_INFO	*baud_table;
	BAUD_INFO	*alt_baud_table;
	UWORD		**chip_address;
	UWORD		flags		: 14;
	UWORD		extrd_flag	: 1;
	UWORD		irq_flag	: 1;
	WORD		task;
	UBYTE		WR5;
	UBYTE		RR0;
	WORD		resv[2];
	ULONG		dcd_on;
	ULONG		dcd_off;
	UWORD		rxbuffer_overflow;
	UWORD		framing_errs;
	UWORD		parity_errs;
	UWORD		charlost_errs;
} CHAN_INFO;

/*--- variables             ---*/

/*--- prototypes            ---*/

/*--- End of types.h module  ---*/
#endif
