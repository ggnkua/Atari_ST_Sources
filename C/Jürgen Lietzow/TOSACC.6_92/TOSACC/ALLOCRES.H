/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC und AUTOTACC.PRG					*/
/*																		*/
/*		M O D U L E		:	ALLOCRES.H									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#if !defined (__ALLOCRES)

#define		__ALLOCRES

typedef struct
{
		long	reserved1;
		long	rmMagic;
		int		rmClrCookie;			/*	1 == clear cookie jar on reset */
		long	reserved2[3];
		void	(*rmPageCode)(void);	/* optional mem page function */
		void	(*rmResCode)(void);		/* optional reset handler fuction */
		void	*rmDataStart;			/* points to start of resident */
										/* user memory */
		long	rmDataSize;				/* size of resident user memory */
		long	rmHeadLen;				/* size of internal data */
}	RES_MEM;

RES_MEM	*AllocResMem( long size, long magic );
RES_MEM	*GetResMem( long magic );

#endif
