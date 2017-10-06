
#define	PX_1COMP		0x01000000L										/* Pixel besteht aus einer benutzten Komponente: Farbindex */
#define	PX_3COMP		0x03000000L										/* Pixel besteht aus drei benutzten Komponenten, z.B. RGB */
#define	PX_4COMP		0x04000000L										/* Pixel besteht aus vier benutzten Komponenten, z.B. CMYK */

#define	PX_REVERSED	0x00800000L										/* Pixel wird in umgekehrter Bytreihenfolge ausgegeben */
#define	PX_xFIRST	0x00400000L										/* unbenutzte Bits liegen vor den benutzen (im Motorola-Format betrachtet) */
#define	PX_ALPHA		0x00200000L										/* Alphakanal */
#define	PX_aFIRST	0x00100000L										/* Alphakanal liegen vor den Farbbits (im Motorola-Format betrachtet) */

#define	PX_PACKED	0x00020000L										/* Bits sind aufeinanderfolgend abgelegt */
#define	PX_PLANES	0x00010000L										/* Bits sind auf mehrere Ebenen verteilt (Reihenfolge: 0, 1, ..., n) */
#define	PX_IPLANES	0x00000000L										/* Bits sind auf mehrere Worte verteilt (Reihenfolge: 0, 1, ..., n) */

#define	PX_USES1		0x00000100L										/* 1 Bit des Pixels wird benutzt */
#define	PX_USES2		0x00000200L										/* 2 Bit des Pixels werden benutzt */
#define	PX_USES3		0x00000300L										/* 3 Bit des Pixels werden benutzt */
#define	PX_USES4		0x00000400L										/* 4 Bit des Pixels werden benutzt */
#define	PX_USES8		0x00000800L										/* 8 Bit des Pixels werden benutzt */
#define	PX_USES15	0x00000f00L										/* 15 Bit des Pixels werden benutzt */
#define	PX_USES16	0x00001000L										/* 16 Bit des Pixels werden benutzt */
#define	PX_USES24	0x00001800L										/* 24 Bit des Pixels werden benutzt */
#define	PX_USES32	0x00002000L										/* 32 Bit des Pixels werden benutzt */
#define	PX_USES48	0x00002000L										/* 48 Bit des Pixels werden benutzt */

#define	PX_1BIT		0x00000001L										/* Pixel besteht aus 1 Bit */
#define	PX_2BIT		0x00000002L										/* Pixel besteht aus 2 Bit */
#define	PX_3BIT		0x00000003L										/* Pixel besteht aus 3 Bit */
#define	PX_4BIT		0x00000004L										/* Pixel besteht aus 4 Bit */
#define	PX_8BIT		0x00000008L										/* Pixel besteht aus 8 Bit */
#define	PX_16BIT		0x00000010L										/* Pixel besteht aus 16 Bit */
#define	PX_24BIT		0x00000018L										/* Pixel besteht aus 24 Bit */
#define	PX_32BIT		0x00000020L										/* Pixel besteht aus 32 Bit */
#define	PX_48BIT		0x00000030L										/* Pixel besteht aus 48 Bit */

#define	PX_CMPNTS	0x0f000000L										/* Maske fÅr Anzahl der Pixelkomponenten */
#define	PX_FLAGS		0x00f00000L										/* Maske fÅr diverse Flags */
#define	PX_PACKING	0x00030000L										/* Maske fÅr Pixelformat */
#define	PX_USED		0x00003f00L										/* Maske fÅr Anzahl der benutzten Bits */
#define	PX_BITS		0x0000003fL										/* Maske fÅr Anzahl der Bits pro Pixel */

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fÅr ATARI-Grafik																				*/
/*----------------------------------------------------------------------------------------*/
#define	PX_ATARI1	( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_ATARI2	( PX_IPLANES + PX_1COMP + PX_USES2 + PX_2BIT )
#define	PX_ATARI4	( PX_IPLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_ATARI8	( PX_IPLANES + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_FALCON15	( PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fÅr Macintosh																					*/
/*----------------------------------------------------------------------------------------*/
#define	PX_MAC1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_MAC4		( PX_PACKED + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_MAC8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_MAC15		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_MAC32		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fÅr Grafikkarten																				*/
/*----------------------------------------------------------------------------------------*/
#define	PX_VGA1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_VGA4		( PX_PLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_VGA8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_VGA15		( PX_REVERSED + PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_VGA16		( PX_REVERSED + PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )
#define	PX_VGA24		( PX_REVERSED + PX_PACKED + PX_3COMP + PX_USES24 + PX_24BIT )
#define	PX_VGA32		( PX_REVERSED + PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

#define	PX_MATRIX16	( PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )

#define	PX_NOVA32	( PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fÅr Drucker																					*/
/*----------------------------------------------------------------------------------------*/
#define	PX_PRN1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_PRN3		( PX_PLANES + PX_1COMP + PX_USES3 + PX_3BIT )
#define	PX_PRN4		( PX_PLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_PRN8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_PRN32		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

