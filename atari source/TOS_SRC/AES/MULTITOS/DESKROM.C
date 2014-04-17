/*	NEW	DESKROM.C	01/11/88 - 1/19/88	Derek Mui	*/
/*	Look for TOS.RSC and read in GEM.RSC,DESKTOP.RSC,DESKTOP.INF	*/
/*	Make sure you set the switches right at machine.h		*/
/*	Change at rsc_read do_cdir	1/28/88		D.Mui		*/	
/*	Change at rsc_read for TOS and ROM system 3/11/88		*/
/*	Put in all the resources		6/10/92	D.Mui		*/ 
/* 	02/16/93	cjg	Converted to Lattice C 5.51		*/
/*	02/23/93	cjg	Force the use of prototypes		*/
/*	Add sofloaded resources			02/93   H.M.Krober	*/
/*	Renamed to DESKROM.C			03/18/93 C.Gee		*/
/*	Extensive brain-surgery and support for compressed resources	*/
/*						05/12/93 E.Smith	*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	


/*
 *	Set the SOFTLOAD flag to implement softloaded GEM AES/DESKTOP
 *	resources. The AES will then try to read its resource file from
 *	[A|C]:\MULTITOS\GEM.RSC.  
 *
 *	NOTE: You have to define SOFTLOAD in desktop.c too.
 *	See the Defines SOFTLOAD.H
 */
/*
 *	Turn on resource file version number checking by setting the
 *	GEMRSVER to 1. Use "rscvers versnr GEM.RSC" create
 *	create a GEM.RSC with a version number in the first byte of the
 *	resource header. This is to prevent user from using the wrong
 *	resource file.
 *	See the Defines in SOFTLOAD.H
 */
/* 
 * 	Set the ONERSC flag to indicate that the system just has the
 *	U.S. desktop resource in ROMs. If the system cannot load the
 *	GEM.RSC from disk, it will displaying a warning, saying that
 *	the U.S. version from ROM will be used.
 *	See the Defines in SOFTLOAD.H
 *
 *	-> This message has to get internationalized?!
 */

/*
 *	Set the DESKPRG flag to compile as a desktop replacement.
 *	Otherwise, this will compile for GEM.SYS
 *	Change the flags also in DESKTOP.C, DESKVARI.C, DESKSTAR.S
 *	See the Defines in SOFTLOAD.H
 */




#include "softload.h"

#if DESKPRG
#include "pdesk.h"
#include "pmisc.h"
#include "pboth.h"
#else
#include "pgem.h"
#include "pmisc.h"
#endif

#include "machine.h"
#include "objaddr.h"
#include "mintbind.h"
#include "rslib.h"
#include "osbind.h"
#include "gemdos.h"


EXTERN	LONG	rs_global;
EXTERN	LONG	rs_hdr;

EXTERN	UWORD	USARSC[];
EXTERN	UWORD	GRMRSC[];
EXTERN	UWORD	FRERSC[];
EXTERN	UWORD	ITARSC[];
EXTERN	UWORD	SWERSC[];
EXTERN	UWORD	SPARSC[];

MLOCAL	LONG		gl_pglue;
MLOCAL	LONG		gemptr;		/* GEM's rsc pointer		*/
#if SOFTLOAD
MLOCAL	LONG		rgemptr;	/* GEM's rsc pointer (ROM vers)	*/
MLOCAL	WORD		romuse;
#endif
MLOCAL	LONG		rgemsiz;	/* GEM's rsc size */
MLOCAL	BYTE		*romrsdata;

VOID		rom_read( VOID );

#if SOFTLOAD

MLOCAL UWORD		*rscaddr; 	/* addr of the loaded rsc file */
MLOCAL LONG		rsc_load( VOID );
MLOCAL BYTE GEMRSC[20]; /*  = 	"C:\\MULTITOS\\GEM.RSC"; */
#endif

#if ONERSC
MLOCAL	BYTE	*RSCTABLE[] =
{
	( BYTE *)USARSC		/* USA, UK	*/
};			/* only US version in ROMs */

#else
MLOCAL	BYTE	*RSCTABLE[] =
{
	( BYTE *)USARSC,		/* USA, UK	*/
	( BYTE *)GRMRSC,		/* GERMAN	*/
	( BYTE *)FRERSC,		/* FRENCH	*/
	( BYTE *)USARSC,		/* reserved	*/
	( BYTE *)SPARSC,		/* SPANISH	*/
	( BYTE *)ITARSC,		/* ITALIAN	*/
	( BYTE *)USARSC		/* suppose to be SWEDISH	*/
};	
#endif

GLOBAL	WORD		st_lang;	/* Language code	*/
GLOBAL	LONG		deskptr;	/* DESKTOP'S rsc pointer	*/
GLOBAL	LONG		infptr;
#if SOFTLOAD
GLOBAL	LONG		rdeskptr;	/* DESKTOP'S rsc pointer	*/
GLOBAL	LONG		rinfptr;	/* ROM version			*/
#endif
MLOCAL	LONG		rdesksiz;	/* DESKTOP's rsc size */
MLOCAL	LONG		rinfsiz;	/* DESKTOP's inf size */

MLOCAL	WORD		uncrunch( UBYTE *inbuf, LONG insize, UBYTE *outbuf,
					LONG outsize );

/* do this whenever the Gem or desktop is ready		*/

	WORD
rom_ram( which, pointer )
	WORD		which;
	REG LONG	pointer;
{
	WORD		size;

	switch( which )
	{
#if !DESKPRG
	  case 0:		/* get the gem resource	*/
	    rs_global = pointer;
	    rs_hdr = gemptr;
	    LLSET( pointer + 14, rs_hdr );
	    size = ((WORD *)gemptr)[17];
	    LWSET( pointer + 18, size );
	    do_rsfix( rs_hdr, size ); 
	    rs_fixit( pointer );
	    return (WORD)rgemsiz;
#endif


	  case 1:		/* copy the desktop resource	*/
				/* ok, the rsc file was not found 	*/
				/* on disk, so we have to use the 	*/
				/* rom version.				*/
#if SOFTLOAD
	    if (!romuse) {
		rom_read();
		
	    }  
	    deskptr = rdeskptr;
	    if (pointer == NULL)
		pointer = deskptr;
#endif
	    if (pointer != rdeskptr)
	        LBCOPY( ( BYTE *)pointer, (BYTE *)rdeskptr, (WORD)rdesksiz );
	    return (WORD)rdesksiz;

	  case 3:		/* read in desktop.inf		*/
#if SOFTLOAD
	    if (!romuse) {
		rom_read();
		
	    }
	    infptr = rinfptr;
	    if (pointer == NULL)
		pointer = infptr;
#endif
	    if (pointer != rinfptr)
	    LBCOPY( ( BYTE *)pointer, (BYTE *)rinfptr, rinfsiz );
	    return (WORD)rinfsiz;
	}

	return 0;
}



/*	Free the system resource	*/

	VOID
rsc_free( VOID )
{
	
#if SOFTLOAD	
	
	if (romuse) {
#if DESKPRG
		free( ( VOIDP )gl_pglue );
#else
		dos_free( gl_pglue );
#endif
		gemptr = rgemptr = NULL;
		deskptr = rdeskptr = NULL;
		infptr = rinfptr = NULL;
		romuse = FALSE;	
	} else if (gemptr) {
#if DESKPRG
		free( ( VOIDP )gemptr);
#else
		dos_free( gemptr );
#endif
	}
	gemptr = NULL;
	rgemptr = NULL;
#else
#if DESKPRG
	free( ( VOIDP )gl_pglue );
#else
	dos_free( gl_pglue );
#endif

#endif
}



/*	Read in the resource file (gem, desk, inf)  from ROM */	

	WORD
rsc_read( VOID )
{

#if DESKPRG	
	/* moved to geminit.c 12/8/92 -- ERS */
	/* Restored here for desktop separation 03/18/93 -- CJG */

	LONG		value;

	/* The value is defined as 	*/
	/* X, X,  LANGUAGE, KEYVBOARD	*/


	if ( getcookie( 0x5F414B50L, &value ) )	/* get _AKP cookie */
	  st_lang = (( WORD )( value >> 8L ) & 0x00FF);	/* get the keyboard preferences */
	else
	  st_lang = 0;

	if ( ( st_lang > 6 ) || ( st_lang < 0 ) || ( st_lang == 3 ) )
	  st_lang = 0;
#endif

#if SOFTLOAD
#if ONERSC
	romrsdata = (BYTE *)RSCTABLE[0];	/* only US version in roms */
#else
	romrsdata = (BYTE *)RSCTABLE[st_lang];
#endif

#if DESKPRG
	rom_read();
	gemptr = rgemptr;
#else
	gemptr = rsc_load();	/* try to load version from disk */

	if( gemptr == NULL )
	{
	   rom_read();
	   gemptr = rgemptr;
	}
#endif


#else /* #else SOFLOAD */
	romrsdata = (BYTE *)RSCTABLE[st_lang];
	rom_read();
#endif
	
	return( TRUE );
}


MLOCAL VOID
die_with_msg( BYTE *s )
{
	Cconws(s);
	Cconws("Please reboot the machine!");
	while (!Bconstat( 2 ) );
}

#define GLUEHEADERSIZE 12

VOID
rom_read( VOID )
{
	LONG		totsize, insize;
	UBYTE		*a;
	UBYTE		*b;
	LONG		*longptr;


	totsize = *((LONG *)(romrsdata+2));
	insize = *((LONG *)(romrsdata+6));

#if DESKPRG
	if ( !( gl_pglue = (LONG) lmalloc( totsize + 4096 ) ) )
#else
	if ( !( gl_pglue = dos_xalloc( totsize + 4096, 3 ) ) )
#endif
	{
	  die_with_msg( "Unable to install AES resource!\r\n" );
	}

	a = ( UBYTE *)(romrsdata+10);	/* 2 bytes magic + 2 long words */
	b = ( UBYTE *)gl_pglue;

	if (*((WORD *)romrsdata) == 0)
	{
	  while( totsize )
	  {
	    *b++ = *a++;
	    totsize--;	   
	  }
	} else {
	  if ( *((UWORD *)romrsdata) != 0xab08U ) {
		die_with_msg("Unknown compression in ROM resource\r\n");
	  }
	  if (!uncrunch(a, insize, b, totsize)) {
		die_with_msg("Decompression failure\r\n");
		return;
	  }
	}
	longptr = (LONG *)gl_pglue;
	rgemsiz = longptr[0];
	rdesksiz = longptr[1];
	rinfsiz = longptr[2];

#if SOFTLOAD
	rgemptr = (LONG)(gl_pglue + GLUEHEADERSIZE);	/* Gem Resource */
	rdeskptr = rgemptr + rgemsiz;		/* Desktop Resource */
	rinfptr = rdeskptr + rdesksiz;		/* Inf file resource */
	romuse = TRUE;
#else
	gemptr = (LONG)(gl_pglue + GLUEHEADERSIZE);	/* Gem Resource */
	deskptr = gemptr + rgemsiz;		/* Desktop Resource */
	infptr = deskptr + rdesksiz;		/* Inf file resource */
#endif
}



#if SOFTLOAD

#if !DESKPRG
/* read gem.rsc from disk */

LONG rsc_load()
{
	WORD	fd;
	LONG    rsl_hdr = NULL;
	LONG	rslsize;
	UWORD	hdr_buff[HDR_LENGTH/2];
	BYTE	vers;

	strcpy("C:\\MULTITOS\\GEM.RSC", GEMRSC);
	GEMRSC[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';
	if ( ( fd = dos_open(GEMRSC, RMODE_RD) ) >= 0 )
	{
	  if ( dos_read( fd, HDR_LENGTH, (LONG)&hdr_buff[0] ) > 0 )
	  {
	     /*
 	      *	Check the version number in the 1st byte of the rsc header.
	      * The format is: %1xxxxxxx
 	      *                 |  |
	      *                 |  +- version number
	      *                 +---- always one
	      */
	     vers = (BYTE) (hdr_buff[0] >> 8);
#if GEMRSVER
	     if (vers != (GEMRSVER | 0x80)) {
#if 0
					/* wrong version number */ 
			Cconws("> Incorrect version of GEM.RSC in\r\n");
			Cconws("> MULTITOS directory. Using ROM\r\n");
			Cconws("> version of GEM.RSC instead.\r\n");
			Fselect(3000, 0L, 0L, 0L); 
#endif
			goto rs_end;
	     }
#endif
					/* get size of resource	*/

						/* New format		*/
	     if ( hdr_buff[RT_VRSN] & 0x0004 )		
	     {					/* seek to the 1st entry*/
						/* of the table		*/
	       if ( dos_lseek( fd, SMODE, (LONG)(hdr_buff[RS_SIZE]) ) 
		    != hdr_buff[RS_SIZE] )
	       {
	         goto rs_end;
	       }
						/* read the size	*/
	       if ( dos_read( fd, sizeof(LONG), (LONG)&rslsize ) != sizeof(LONG) )
	       {
	         goto rs_end;
	       }

	     }
	     else 	
	       rslsize = hdr_buff[RS_SIZE];
						/* allocate memory	*/
	     if ( rsl_hdr = dos_xalloc( rslsize, 3 ) )
	     {
						/* read it all in 	*/
	        dos_lseek( fd, SMODE, 0x0L );
	        if ( Fread( fd, rslsize, rsl_hdr ) == rslsize )
		{
	       		;
		}
		else
		  dos_free( rs_hdr );
	     }
	  }
rs_end:
	  dos_close( fd );
	}
	return rsl_hdr;
}
#endif
#endif



/*
 * uncompression routines
 * the algorithm used to compress is fairly straight-forward:
 * (1) first, we find the least frequently occuring bytes
 * (2) next, we use 8 of those bytes, as follows:
 *       (a) to mark 0000
 *       (b) to mark ffff
 *       (c) to mark a run of 0s (next byte gives the run length)
 *       (d) to mark a run of ffs (next byte gives the run length)
 *       (e) to mark a run of arbitrary characters (next byte is the char,
 *            and the one following that is the run length)
 *	 (f) to mark 00000000
 *	 (g) to mark ffffffff
 *	 (h) to mark a token
 *
 * The run character is also used as an escape character, i.e. to output
 * one of the reserved bytes, we output a 1-length run.
 *
 * The compressed file contains a header giving the size of the uncompressed
 * data (as a LONG), followed by the 8 special bytes above, followed by
 * the number of tokens (1 byte), followed by the token table, followed
 * by the compressed data.
 * Each token table entry consists of a length (1 byte) followed by n bytes of
 * token. When a token marker is found in the compressed data, the next
 * byte is used as an index into the token table to find the corresponding
 * data for the token.
 */

MLOCAL WORD zeroc, ffffc, zerorunc, ffffrunc, runc;
MLOCAL WORD longzeroc, longffffc;
MLOCAL WORD tokenesc;

MLOCAL WORD numtokens;

/*
 * untokenize function:
 * returns # of bytes in the untokenized version
 */
MLOCAL long
untokenize(unsigned char *inp, long insize, unsigned char *outp)
{
	unsigned char **tokenptr;
	unsigned char *ptr;
	long outsize = 0;
	int c;
	int j;

	tokenptr = (unsigned char **)dos_xalloc(1024,3);

	for (j = 1; j < numtokens; j++) {
		tokenptr[j] = inp;
		insize -= (*inp)+1;
		inp += (*inp)+1;
	}

	while (insize > 0) {
		c = *inp++; insize--;
		if (c == tokenesc) {
			c = *inp++; insize--;
			if (c == 0)
				outp[outsize++] = tokenesc;
			else {
				ptr = tokenptr[c];
				if (!ptr) {
					die_with_msg("bad compression in RSC\r\n");
					return 0;
				}
				j = *ptr++;
				while (j-- > 0)
					outp[outsize++] = *ptr++;
			}
		} else {
			outp[outsize++] = c;
		}
	}
	dos_free((LONG)tokenptr);
	return outsize;
}

MLOCAL WORD
uncrunch( UBYTE *inbuf, LONG insize, UBYTE *outbuf, LONG outsize )
{
	int j, c;
	long i;
	long cursize;
	UBYTE *tmpbuf;

	tmpbuf = (UBYTE *) dos_xalloc(outsize+4096, 3);
	if (!tmpbuf) {
		die_with_msg("out of memory\r\n");
		return(0);
	}

/* now do the decompression */
	i = 0;
	zeroc = inbuf[i++];
	ffffc = inbuf[i++];
	zerorunc = inbuf[i++];
	ffffrunc = inbuf[i++];
	runc = inbuf[i++];
	longzeroc = inbuf[i++];
	longffffc = inbuf[i++];
	tokenesc = inbuf[i++];
	numtokens = inbuf[i++] + 1;

	insize = untokenize(&inbuf[i], insize-i, tmpbuf);

	i = 0;
	cursize = 0;

#define nextchar() tmpbuf[i++]
#define output(c) outbuf[cursize++] = c

	while (i < insize) {
		c = nextchar();
		j = 0;
		if (c == runc) {
			c = nextchar();
			j = nextchar();
		} else if (c == zeroc) {
			c = 0;
			j = 1;
		} else if (c == ffffc) {
			c = 0xff;
			j = 1;
		} else if (c == zerorunc) {
			c = 0;
			j = nextchar();
		} else if (c == ffffrunc) {
			c = 0xff;
			j = nextchar();
		} else if (c == longzeroc) {
			c = 0;
			j = 3;
		} else if (c == longffffc) {
			c = 0xff;
			j = 3;
		}
		while (j >= 0) {
			output(c);
			--j;
		}
		if (cursize > outsize) {
			die_with_msg("TOO MUCH DATA in resources\r\n");
			return 0;
		}
	}

	dos_free((LONG)tmpbuf);

	return 1;
}
