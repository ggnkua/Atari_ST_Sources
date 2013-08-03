
/*****************************/
/* OSIFX interface structure */
/*****************************/
/* Extended O.S. Interface routine: _OSIFX(iptr,optr)
   Where:	OSIFX *iptr, *optr;
   Note: UseFlag determines whether some of the registers get loaded
	from the OSIFX structure before calling the O.S.
		Value	Reg
		0x10	di
		0x20	si
		0x40	ds
		0x80	es
   All registers are loaded into the optr structure after the OS call,
	including the FlagsWord.
*/

#define OSIFX struct osifx_str
OSIFX {
	UWORD ax,bx,cx,dx,di,si,ds,es;
	UWORD	 flagsword;
	UWORD	 useflag;
};

#define ERROR 01
#define UDI   0x10
#define USI   0x20
#define UDS   0x40
#define UES   0x80

