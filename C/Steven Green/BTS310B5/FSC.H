/*
 * fsc.h
 *
 * Packet header for FSC-0048
 */

typedef struct
{
		MWORD origNode;			/* originating node			   */
		MWORD destNode;			/* destination node			   */
		MWORD year;				/* 0..99  when packet was created */
		MWORD month;			/* 0..11  when packet was created */
		MWORD day;				/* 1..31  when packet was created */
		MWORD hour;				/* 0..23  when packet was created */
		MWORD minute;			/* 0..59  when packet was created */
		MWORD second;			/* 0..59  when packet was created */
		MWORD baud;				/* destination's baud rate 	   */
		MWORD ver;				/* packet version				   */
		MWORD origNet;			/* originating network number	   */
		MWORD destNet;			/* destination network number	   */
		UBYTE productCode;		/* product type 				  */
		UBYTE revision;			/* serial number (some systems)   */

		byte password[8];		/* session/pickup password		  */
		MWORD origZone;			/* originating zone			   */
		MWORD destZone;			/* Destination zone			   */
		MWORD AuxNet;
		MWORD CWvalidationCopy;	/* NB This is in reverse order */
		UBYTE ProductCodeCopy;
		UBYTE RevisionCopy;
		MWORD CapabilWord;
		MWORD origZone2;
		MWORD destZone2;
		MWORD origPoint;
		MWORD destPoint;

		byte filler[4];

} PKT_HEADER;

