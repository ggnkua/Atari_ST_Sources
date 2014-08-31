#if 0																			/* 512 * 512 Pixel */

#define	RSTEP				(65535L/63)									/* 64 Schnitte entlang der Rot-Achse */
#define	GSTEP				(65535L/63)									/* 64 Schnitte entlang der GrÅn-Achse */
#define	BSTEP				(65535L/63)									/* 64 Schnitte entlang der Blau-Achse */
#define	RCUT				(16-6)										/* 10 bedeutungslose Rot-Bits */
#define	RROW				8												/* 8 VerlÑufe pro Reihe */
#define	RROWSHIFT		3
#define	RWIDTHSHIFT		6												/* Verlauf ist 2^6 Pixel breit */
#define	RHEIGHTSHIFT	6												/* Verlauf ist 2^6 Pixel hoch */

#endif

#if 0																			/* 256 * 256 Pixel */

#define	RSTEP				(65535L/15)									/* 16 Schnitte entlang der Rot-Achse */
#define	GSTEP				(65535L/63)									/* 64 Schnitte entlang der Rot-Achse */
#define	BSTEP				(65535L/63)									/* 64 Schnitte entlang der Rot-Achse */
#define	RCUT				(16-4)										/* 12 bedeutungslose Rot-Bits */
#define	RROW				4												/* 4 VerlÑufe pro Reihe */
#define	RROWSHIFT		2
#define	RWIDTHSHIFT		6												/* Verlauf ist 2^6 Pixel breit */
#define	RHEIGHTSHIFT	6												/* Verlauf ist 2^6 Pixel hoch */

#endif

#if 0																			/* 128 * 128 Pixel */

#define	RSTEP				(65535L/15)									/* 16 Schnitte entlang der Rot-Achse */
#define	GSTEP				(65535L/31)									/* 32 Schnitte entlang der Rot-Achse */
#define	BSTEP				(65535L/31)									/* 32 Schnitte entlang der Rot-Achse */
#define	RCUT				(16-4)										/* 12 bedeutungslose Rot-Bits */
#define	RROW				4												/* 4 VerlÑufe pro Reihe */
#define	RROWSHIFT		2
#define	RWIDTHSHIFT		5												/* Verlauf ist 2^5 Pixel breit */
#define	RHEIGHTSHIFT	5												/* Verlauf ist 2^5 Pixel hoch */

#endif

#if 0																			/* 64 * 64 Pixel */

#define	RSTEP				(65535L/15)									/* 16 Schnitte entlang der Rot-Achse */
#define	GSTEP				(65535L/15)									/* 16 Schnitte entlang der Rot-Achse */
#define	BSTEP				(65535L/15)									/* 16 Schnitte entlang der Rot-Achse */
#define	RCUT				(16-4)										/* 12 bedeutungslose Rot-Bits */
#define	RROW				4												/* 4 VerlÑufe pro Reihe */
#define	RROWSHIFT		2
#define	RWIDTHSHIFT		4												/* Verlauf ist 2^4 Pixel breit */
#define	RHEIGHTSHIFT	4												/* Verlauf ist 2^4 Pixel hoch */

#endif
