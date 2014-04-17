/* $Id: cldlod.c,v 1.20 92/02/14 15:55:24 tomc Exp $ */
#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <time.h>
#include <errno.h>
#if defined ( __WATCOMC__ ) || defined( __DGUX__ ) || defined( macintosh )
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#if !defined ( macintosh )
#include <sys/types.h>
#endif


/* Headers for working with COFF files */
#include "coreaddr.h"
#include "maout.h"
#include "dspext.h"

/* function definitions */
static void onintr();
static void cld_to_lod();
static void read_headers();
static void read_strings();
static void start_record();
static void read_sections();
static void dump_data();

#if defined ( __WATCOMC__ ) || defined( __DGUX__ ) || defined( macintosh )
static void eprintf( FILE*, char*, ... );
static void error( char*, ... );
#else
static void eprintf();
static void error();
#endif

/*  Global variables  */
FILHDR	file_header;	/* File header structure */
AOUTHDR	opt_header;	/* Optional header structure */
OPTHDR	link_header;	/* Linker header structure */
int	absolute;	/* Absolute file flag */

long num_sections;	/* Number of sections */
long section_seek;	/* Used to seek to first section */

long symptr;		/* File pointer to symbol table entries */
long num_symbols;	/* Number of symbols */

int  data_width;        /* width of data for printing */
int  addr_width;        /* width of address for printing */

char *str_tab;		/* Pointer to start of string char. array */
long str_length;	/* Length in bytes of string array */

FILE *ifile = NULL;	/* file pointer for input file */
char *ifn = NULL;	/* pointer to input file name */

/* init is to non valid memory space */
int  space = 777; /* 0=p, 1=x, 2=y, 3=l, 4=N */


main (argc, argv)
int argc;
char *argv[];
{
    void exit ();

    /* set up for signals, save program name, check for command line options */
    signal (SIGINT, onintr);

    /* check for correct command-line */
    if ( argc != 2 )
    {
	fprintf( stderr, "usage: cldlod cldfile > lodfile\n" );
	exit ( -1 );
    }


    if ( ( ifile = fopen( argv[1], "rb" ) ) == NULL )
	error( "cannot open input file %s", argv[1] );

    cld_to_lod();
    
    fclose( ifile );
    exit (0);
}


static void
cld_to_lod()
{
    read_headers ();
    read_strings ();

    /* blow out the _START record */
    if ( symptr != 0  && num_symbols != 0 )	/* no symbols */
	start_record();
    
    read_sections ();

    if ( symptr != 0  && num_symbols != 0 )	/* no symbols */
	dump_deb_symbols ();

    /* blow out the _END record */
    eprintf( stdout, "\n_END %01.*X\n", addr_width,
	    CORE_ADDR_ADDR (opt_header.entry) );
}


/* blow out the first .cmt symbol with:
        n_sclass == C_NULL
	n_type   == T_NULL
*/
static void
start_record()
{
    SYMENT se;
    int i = 0, sym_id = -709;
    
    if ( fseek( ifile, symptr, 0 ) != 0 )
	error ("cannot seek to symbol table");

    while ( i < num_symbols )
    {
	if ( freads( (char *)&se, sizeof (SYMENT), 1, ifile ) != 1 )
	    error ("cannot read symbol table entry %d", i);
#if !BIG_ENDIAN
	if ( se.n_zeroes )
		swapw( se.n_name, sizeof (long), 2 );
#endif
	if ( strcmp( se.n_name, ".cmt" ) == 0 &&
	     se.n_sclass == C_NULL &&
	     se.n_type == T_NULL )
	{
	    sym_id = CORE_ADDR_ADDR(se.n_value);
	    break;
	}
	
	i++;
    }
    
    /* */
    eprintf( stdout, "_START " );

    if ( sym_id >= 0 && str_length != 0 )
    {
	char *str_ptr = str_tab;
	int  len;
	long offset = (long) sizeof( str_length );
	
	do
	{
	    if ( offset == sym_id )
		break;
	    else
	    {
		len = strlen( str_ptr );
		offset += len + 1;
		str_ptr += len + 1;
	    }
	} while ( str_ptr < ( str_tab + str_length ) );
		
	eprintf( stdout, "%s", str_ptr );
    }
    
    eprintf( stdout, "\n\n" );
}


static void
read_headers ()
{
    if ( freads( (char *)&file_header, sizeof (FILHDR), 1, ifile ) != 1 )
	error ("cannot read file header");

    /* Save the global values */
    num_sections = file_header.f_nscns;
    num_symbols = file_header.f_nsyms;
    symptr = file_header.f_symptr;
    absolute = !!(file_header.f_flags & F_RELFLG);

    /* check the MAGIC number */
    if ( file_header.f_magic == M56KMAGIC )
    {
	data_width = 6;
	addr_width = 4;
    }
    else if ( file_header.f_magic == M96KMAGIC )
    {
	data_width = addr_width = 8;
    }
    else if ( file_header.f_magic == M16KMAGIC )
    {
	data_width = addr_width = 4;
    }
    else
    {
	error( "Header has a bad magic number" );
    }
    

    /* optional header present */
    if ( file_header.f_opthdr )
    {
	if ( absolute )
	{
	    if ( freads( (char *)&opt_header,
			(int)file_header.f_opthdr, 1, ifile ) != 1 )
		error( "cannot read optional file header" );
	}
	else
	{
	    if ( freads( (char *)&link_header,
			(int)file_header.f_opthdr, 1, ifile ) != 1 )
		error( "cannot read linker file header" );
	}
    }

    /* File offset for first section headers */
    section_seek = sizeof(FILHDR) + file_header.f_opthdr;
}


static void
read_strings ()
{
    long strings;

    strings = symptr + (num_symbols * SYMESZ);
    if ( fseek( ifile, strings, 0 ) != 0 )
	error ( "cannot seek to string table length" );
    if ( freads( (char *)&str_length, 4, 1, ifile ) != 1 && !feof( ifile ))
	error ( "cannot read string table length" );
    if ( feof( ifile ))
	str_length = 0L;
    else if ( str_length )
    {
	str_length -= 4;
	str_tab = (char *)malloc ((unsigned)str_length);
	if ( fseek( ifile, strings + 4, 0 ) != 0 )
	    error( "cannot seek to string table" );
	if (fread (str_tab, (int)str_length, 1, ifile) != 1)
	    error( "cannot read string table" );
    }
}


static void
read_sections()
{
    int i;
    XCNHDR sh;		/* Section header structure */

    for (i = 0; i < num_sections; i++)
    {
	if (fseek (ifile, section_seek, 0) != 0)
	    error ("cannot seek to section headers");
	if (freads ((char *)&sh, sizeof (XCNHDR), 1, ifile) != 1)
	    error ("cannot read section headers");
#if !BIG_ENDIAN
	if (sh._n._s_n._s_zeroes)
	    swapw (sh._n._s_name, sizeof (long), 2);
#endif
	section_seek += sizeof (XCNHDR);
	
	dump_data (&sh);
    }
}


char *
get_secname (sh)
XCNHDR *sh;
{
    char *secname;

    if ( sh->_n._s_n._s_zeroes )
	secname = sh->_n._s_name;
    else
    {
	if (sh->_n._s_n._s_offset < sizeof (str_length) ||
	    sh->_n._s_n._s_offset > str_length)
	    error ("invalid string table offset for section header name");
	secname = &str_tab[sh->_n._s_n._s_offset - sizeof (str_length)];
    }

    return (secname);
}


static void
dump_data (sh)
XCNHDR *sh;
{
    char *secname, *get_secname ();
    long *raw_data;
    int  j;

    if ( sh->_s.s_scnptr && sh->_s.s_size )
    {
	int memtype = CORE_ADDR_MAP( sh->_s.s_paddr );
	int address  = CORE_ADDR_ADDR( sh->_s.s_paddr );
	char *mem_field;
	
	secname = get_secname( sh );
	
	/* determine the memory field (optional counter ok) */
	switch ( memtype )
	{
	case memory_map_p:
	    mem_field = "P";
	    break;
	    
	case memory_map_pa:
	    mem_field = "PA";
	    break;
	    
	case memory_map_pb:
	    mem_field = "PB";
	    break;
	    
	case memory_map_pe:
	    mem_field = "PE";
	    break;
	    
	case memory_map_pi:
	    mem_field = "PI";
	    break;
	    
	case memory_map_pr:
	    mem_field = "PR";
	    break;
	    
	case memory_map_y:
	    mem_field = "Y";
	    break;
	    
	case memory_map_ya:
	    mem_field = "YA";
	    break;
	    
	case memory_map_yb:
	    mem_field = "YB";
	    break;
	    
	case memory_map_ye:
	    mem_field = "YE";
	    break;
	    
	case memory_map_yi:
	    mem_field = "YI";
	    break;
	    
	case memory_map_yr:
	    mem_field = "YR";
	    break;
	    
	case memory_map_x:
	    mem_field = "X";
	    break;
	    
	case memory_map_xa:
	    mem_field = "XA";
	    break;
	    
	case memory_map_xb:
	    mem_field = "XB";
	    break;
	    
	case memory_map_xe:
	    mem_field = "XE";
	    break;
	    
	case memory_map_xi:
	    mem_field = "XI";
	    break;
	    
	case memory_map_xr:
	    mem_field = "XR";
	    break;
	    
	case memory_map_l:
	    mem_field = "L";
	    break;
	    
	case memory_map_laa:
	    mem_field = "LAA";
	    break;
	    
	case memory_map_lab:
	    mem_field = "LAB";
	    break;
	    
	case memory_map_lba:
	    mem_field = "LBA";
	    break;
	    
	case memory_map_lbb:
	    mem_field = "LBB";
	    break;
	    
	case memory_map_le:
	    mem_field = "LE";
	    break;
	    
	case memory_map_li:
	    mem_field = "LI";
	    break;
	    
	default:
	    mem_field = "<ERROR>";
	    break;
	}
	

	raw_data = (long *)malloc((unsigned)(sh->_s.s_size * sizeof (long)));

	if (fseek (ifile, sh->_s.s_scnptr, 0) != 0)
	    error ("cannot seek to raw data in section %s", secname);

	if (freads ((char *)raw_data, (int)sh->_s.s_size,
		    sizeof (long), ifile) != sizeof (long))
	    error ("cannot read raw data in section %s",  secname);


	/* check for block data */
	if ( sh->_s.s_flags & STYP_BLOCK )
	{
	    if ( mem_field[0] == 'L' )
	    {
		eprintf( stdout, "_BLOCKDATA X %01.*X %01.*X %01.*X\n",
			addr_width, address,
			addr_width, CORE_ADDR_ADDR( sh->_s.s_vaddr ),
			data_width, *raw_data++ );

		eprintf( stdout, "_BLOCKDATA Y %01.*X %01.*X %01.*X\n",
			addr_width, address,
			addr_width, CORE_ADDR_ADDR( sh->_s.s_vaddr ),
			data_width, *raw_data++ );
	    }
	    else
	    {
		eprintf( stdout, "_BLOCKDATA %s %01.*X %01.*X %01.*X\n",
			mem_field,
			addr_width, address,
			addr_width, CORE_ADDR_ADDR( sh->_s.s_vaddr ),
			data_width, *raw_data++ );
	    }
	}
	
	else
	{
	    eprintf (stdout, "_DATA %s %01.*X\n", mem_field,
		     addr_width, address );
	    
	    j = 0;
	    while ( j < sh->_s.s_size )
	    {
		if ( mem_field[0] == 'L' )
		{
		    eprintf (stdout, "%01.*lX %01.*lX ",
			     data_width, *(raw_data+1),
			     data_width, *raw_data);
		    raw_data += 2;
		    j += 2;
		}
		else
		{
		    eprintf (stdout, "%01.*lX ", data_width, *raw_data++);
		    j++;
		}
		

		if ( j % 8 == 0 && j < sh->_s.s_size )
		    eprintf (stdout, "\n");
	    }
	    eprintf (stdout, "\n");
	}
    }
}


dump_deb_symbols ()
{
    SYMENT se;
    AUXENT ae;
    int    i, j, k;


    if (fseek (ifile, symptr, 0) != 0)
	error ("cannot seek to symbol table");

    i = 0;
    while (i < num_symbols)
    {
	if (freads ((char *)&se, sizeof (SYMENT), 1, ifile) != 1)
	    error ("cannot read symbol table entry %d", i);

	dump_se_d (&se); /* ek */
	k = i++;

	for (j = 0; j < se.n_numaux; j++)
	{
	    if (freads ((char *)&ae, sizeof (AUXENT), 1, ifile) != 1)
		error ("cannot read auxiliary entry %d for symbol entry %d", j, k);
	    i++;
	}
    }
}


dump_se_d (se) /* for debug symbol table */
SYMENT *se;
{
    int  old_space;
    char *name, *type, *sclass;
    char sym_type = 'I';
	

    if (se->n_zeroes)
    {
#if !BIG_ENDIAN
	swapw (se->n_name, sizeof (long), 2);
#endif
	name = se->n_name;
    }
    else
    {
	if (se->n_offset < sizeof (str_length) ||
	    se->n_offset > str_length)
	    error ("invalid string table offset for symbol table entry %d name", se - symptr);
	name = &str_tab[se->n_offset - sizeof (str_length)];
    }

    if ( name[0] == '.' )
    {
	return;
    }

    switch ( se->n_sclass )
    {
    case C_EFCN:
	sclass = "C_EFCN";
	break;

    case C_NULL:
	sclass = "C_NULL";
	break;

    case C_AUTO:
	sclass = "C_AUTO";
	break;

    case C_EXT:
	sclass = "C_EXT";
	break;

    case C_STAT:
	sclass = "C_STAT";
	break;

    case C_REG:
	sclass = "C_REG";
	break;

    case C_EXTDEF:
	sclass = "C_EXTDEF";
	break;

    case C_LABEL:
	sclass = "C_LABEL";
	break;

    case C_ULABEL:
	sclass = "C_REG";
	break;

    case C_MOS:
	sclass = "C_MOS";
	break;

    case C_ARG:
	sclass = "C_ARG";
	break;

    case C_STRTAG:
	sclass = "C_STRTAG";
	break;

    case C_MOU:
	sclass = "C_MOU";
	break;

    case C_UNTAG:
	sclass = "C_UNTAG";
	break;
    
    case C_TPDEF:
	sclass = "C_TPDEF";
	break;

    case C_USTATIC:
	sclass = "C_USTATIC";
	break;

    case C_ENTAG:
	sclass = "C_ENTAG";
	break;
	
    case C_MOE:
	sclass = "C_MOE";
	break;

    case C_REGPARM:
	sclass = "C_REGPARM";
	break;

    case C_FIELD:
	sclass = "C_FIELD";
	break;

    case C_BLOCK:
	sclass = "C_BLOCK";
	break;

    case C_FCN:
	sclass = "C_FCN";
	break;

    case C_EOS:
	sclass = "C_EOS";
	break;

    case C_FILE:
	sclass = "C_FILE";
	break;

    case C_LINE:
	sclass = "C_LINE";
	break;

    case C_ALIAS:
	sclass = "C_HIDDEN";
	break;

    case C_HIDDEN:
	sclass = "C_HIDDEN";
	break;

    default:
	sclass = "<unknown>";
	break;
    }


    switch ( BTYPE( se->n_type ) )
    {
    case T_NULL:
	type = "T_NULL";
	break;

	case T_CHAR:
	type = "T_CHAR";
	break;

    case T_SHORT:
	type = "T_SHORT";
	break;

    case T_INT:
	type = "T_INT";
	break;

    case T_LONG:
	type = "T_LONG";
	break;

    case T_FLOAT:
	type = "T_FLOAT";
	sym_type = 'F';
	break;

    case T_DOUBLE:
	type = "T_DOUBLE";
	sym_type = 'F';
	break;
    
    case T_STRUCT:
	type = "T_STRUCT";
	break;

    case T_UNION:
	type = "T_UNION";
	break;

    case T_ENUM:
	type = "T_ENUM";
	break;

    case T_MOE:
	type = "T_MOE";
	break;

    case T_UCHAR:
	type = "T_UCHAR";
	break;

	case T_USHORT:
	type = "T_USHORT";
	break;

    case T_UINT:
	type = "T_UINT";
	break;

    case T_ULONG:
	type = "T_ULONG";
	break;

    default:
	sclass = "<unknown>";
	break;
    }

    old_space = space;
    space = CORE_ADDR_MAP ( se->n_value );

    switch ( space )
    {
    case memory_map_none:
	if ( old_space != space ) eprintf( stdout, "_SYMBOL N\n" );

	/* print symbol name and value */
	eprintf (stdout, "%-19s  %c %01.*lX\n", name, sym_type,
		 data_width, CORE_ADDR_ADDR (se->n_value));
	break;

    case memory_map_p:
	/* print only pointers to functions (should be ext or stat...) */
	if ( ISFCN (se->n_type) )
	{
	    if ( old_space != space ) eprintf(stdout, "_SYMBOL P\n");
	
	    /* print symbol name and value */
	    eprintf (stdout, "%-19s  I %01.*lX\n", name, 
		     data_width, CORE_ADDR_ADDR (se->n_value));
	}

	else  /* restore last written space */
	    space = old_space;
	break;

    case memory_map_x:
	if (old_space != space) eprintf (stdout, "_SYMBOL X\n");
	
	/* print symbol name and value */
	eprintf (stdout, "%-19s  %c %01.*lX\n", name, sym_type,
		 data_width, CORE_ADDR_ADDR (se->n_value));
	break;

    case memory_map_y:
	if (old_space != space) eprintf (stdout, "_SYMBOL Y\n");

	/* print symbol name and value */
	eprintf (stdout, "%-19s  %c %01.*lX\n", name, sym_type,
		 data_width, CORE_ADDR_ADDR (se->n_value));
	break;

    case memory_map_l:
	if (old_space != space) eprintf (stdout, "_SYMBOL L\n");

	/* print symbol name and value */
	eprintf (stdout, "%-19s  %c %01.*lX\n", name, sym_type,
		 data_width, CORE_ADDR_ADDR (se->n_value));
	break;

    default:
	space = old_space; /* restore last written space */
	return;
	break;
    }
}


/**
*
* name		freads - swap bytes and read
*
* synopsis	freads (ptr, size, nitems, stream)
*		char *ptr;		pointer to buffer
*		int size;		size of buffer
*		int nitems;		number of items to read
*		FILE *stream;		file pointer
*
* description	Treats ptr as reference to union array; if necessary,
*		swaps bytes to maintain base format byte ordering
*		(big endian).  Calls fread to do I/O.
*
**/
freads (ptr, size, nitems, stream)
char *ptr;
int size, nitems;
FILE *stream;
{
    int rc;

    rc = fread (ptr, size, nitems, stream);
#if !BIG_ENDIAN
    swapw (ptr, size, nitems);
#endif
    return (rc);
}


#if !BIG_ENDIAN


union wrd
{   /* word union for byte swapping */
    unsigned long l;
    unsigned char b[4];
};

/**
*
* name		swapw - swap bytes in words
*
* synopsis	swapw (ptr, size, nitems)
*		char *ptr;		pointer to buffer
*		int size;		size of buffer
*		int nitems;		number of items to write
*
* description	Treats ptr as reference to union array; if necessary,
*		swaps bytes to maintain base format byte ordering
*		(big endian).
*
**/
swapw (ptr, size, nitems)
char *ptr;
int size, nitems;
{
    union wrd *w;
    union wrd *end = (union wrd *)ptr +	((size * nitems) / sizeof (union wrd));
    unsigned i;

    for (w = (union wrd *)ptr; w < end; w++)
    {
	i = w->b[0];
	w->b[0] = w->b[3];
	w->b[3] = i;
	i = w->b[1];
	w->b[1] = w->b[2];
	w->b[2] = i;
    }
}
#endif


static void
onintr ()			/* clean up from signal */
{
    void exit ();

    exit (1);
}


#ifdef va_dcl
#undef va_dcl
#define va_dcl char *va_alist;
#endif

/* VARARGS */

/* call fprintf, check for errors */
static void
#if defined ( __WATCOMC__ ) || defined( __DGUX__ ) || defined( macintosh )
eprintf (FILE *fp, char *fmt, ...)
#else
eprintf( va_alist )
va_dcl
#endif
{
    void exit ();
    va_list ap;
#if defined ( __WATCOMC__ ) || defined( __DGUX__ ) || defined( macintosh )
    va_start (ap, fmt);
#else
    FILE *fp;
    char *fmt;
    va_start (ap);
    fp = va_arg (ap, FILE *);
    fmt = va_arg (ap, char *);
#endif
    if (vfprintf (fp, fmt, ap) < 0)
	error ("cannot write to output file");
    va_end (ap);
}


/* VARARGS */
static void
#if defined ( __WATCOMC__ ) || defined( __DGUX__ ) || defined( macintosh )
error (char *fmt, ...)		/* display error on stderr, exit nonzero */
#else
error (va_alist)		/* display error on stderr, exit nonzero */
va_dcl
#endif
{
    void exit ();
    va_list ap;
#if !LINT
    int err = errno;
#endif
#if defined ( __WATCOMC__ ) || defined( __DGUX__ ) || defined( macintosh )
    va_start (ap, fmt);
#else
    char *fmt;
    va_start (ap);
    fmt = va_arg (ap, char *);
#endif
    fprintf  (stderr, "cldlod: ");
    vfprintf (stderr, fmt, ap);
    fprintf  (stderr, "\n");
    va_end (ap);
#if !LINT
    if (err)
    {
	errno = err;
	perror ( "cldlod" );
    }
#endif
    exit (1);
}
