#define	KsCAPS		0x10
#define	KsALT			0x08
#define	KsCONTROL	0x04
#define	KsSHIFT		0x03
#define	KsLSHIFT		0x02
#define	KsRSHIFT		0x01

#define	KbSCAN		0x8000
#define	KbNUM			0x4000
#define	KbALT			0x0800
#define	KbCONTROL	0x0400
#define	KbSHIFT		0x0300
#define	KbKSHIFT		0x0200
#define	KbRSHIFT		0x0100

#define	KbISO			0x37

#define	KbF1			0x3b
#define	KbF2			0x3c
#define	KbF3			0x3d
#define	KbF4			0x3e
#define	KbF5			0x3f
#define	KbF6			0x40
#define	KbF7			0x41
#define	KbF8			0x42
#define	KbF9			0x43
#define	KbF10			0x44

#define	KbF11			0x54
#define	KbF12			0x55
#define	KbF13			0x56
#define	KbF14			0x57
#define	KbF15			0x58
#define	KbF16			0x59
#define	KbF17			0x5a
#define	KbF18			0x5b
#define	KbF19			0x5c
#define	KbF20			0x5d

#define	KbUNDO		0x61
#define	KbHELP		0x62
#define	KbINSERT		0x52
#define	KbHOME		0x47
#define	KbUP			0x48
#define	KbDOWN		0x50
#define	KbLEFT		0x4b
#define	KbRIGHT		0x4d

#define	KbALT1		0x78
#define	KbALT2		0x79
#define	KbALT3		0x7a
#define	KbALT4		0x7b
#define	KbALT5		0x7c
#define	KbALT6		0x7d
#define	KbALT7		0x7e
#define	KbALT8		0x7f
#define	KbALT9		0x80
#define	KbALT0		0x81

#ifdef	__PORTAB__
WORD	MapKey( WORD Key );
#endif