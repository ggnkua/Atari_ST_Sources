/*---------------------------------------------------------------------------

  vms.c (version 2.2-5)                                    Igor Mandrichenko

  This file contains routines to extract VMS file attributes from a zipfile
  extra field and create a file with these attributes.  The code was almost
  entirely written by Igor, with a couple of routines by CN.

  ---------------------------------------------------------------------------

     Copyright (C) 1992-93 Igor Mandrichenko.
     Permission is granted to any individual or institution to use, copy,
     or redistribute this software so long as all of the original files
     are included unmodified and that this copyright notice is retained.

  Revision history:

     1.x   [moved to History.510 for brevity]
     2.0   Mandrichenko    7-apr-1993
            Implement PKWARE style VMS file attributes
     2.0-1 Mandrichenko    10-apr-1993
            ACL handling code added.
     2.1   Mandrichenko    24-aug-1993
            Get both PKWARE and new INFO-ZIP signatures as equivalent
            Use vmsmunch.h instead of fatdef.h
     2.2   Cave Newt       3-oct-1993
            Merged GRR 5.1e changes with latest Igor version:  open_outfile,
            close_outfile, check_for_newer, UpdateCRC, flush, no ZIPINFO,
            ctype.h, pInfo->textmode, etc.  Also merged new do_wild/mapname/
            checkdir routines from Igor and moved VMSmunch.h into vms.h.
     2.2-1 Mandrichenko    14-dec-1993
            Bug fixes in mapname/checkdir stuff.
            _flush_stream() rewritten to fix some bugs.
     2.2-2 Goathunter      3 Jan 94
            Fixes for Alpha-VMS.
     2.2-3 Cave Newt       11 Jan 94
            Disabled version-check by default; enable with CHECK_VERSIONS.
            Installed Igor's ctrl-Z patch.
     2.2-4 Mandrichenko    18 Jan 94
            Fixed auto-appending of ".zip" and inability to create second
            level of directory structure.
     2.2-5 Cave Newt, Mike Freeman  28 Jan 94
            Changed close_outfile() to return void for compatibility;
            fixed declaration of second parameter to flush() (ulg size);
            changed str[n]icmp() to STR[N]ICMP().
     2.2-6 Christian Spieler  9 Apr 94
            Numerous bug fixes/improvements.
     2.2-7 Cave Newt       11 Apr 94
            Fixed version-number/semicolon bug.
     2.3   Cave Newt       21 Jun 94
            Added prototype version() routine.
     2.3-1 Cave Newt       1 Jul 94
            *Really* fixed version-number/semicolon bug.
     2.3-2 Rodney Brown    10 Jul 94
            Added VMS status/severity level (define RETURN_SEVERITY)

  ---------------------------------------------------------------------------*/

#ifdef VMS			/*      VMS only !      */

#include "unzip.h"
#include "vms.h"		/* now includes VMSmunch.h */

#define BUFS512 8192*2		/* Must be a multiple of 512 */

#define	OK(s)	((s)&1)		/* VMS success or warning status */
#define	STRICMP(s1,s2)	STRNICMP(s1,s2,2147483647)

/*
*   Local static storage
*/
static struct FAB	fileblk;
static struct XABDAT	dattim;
static struct XABRDT	rdt;
static struct RAB	rab;
static struct NAM	nam;

static struct FAB *outfab = 0;
static struct RAB *outrab = 0;
static struct XABFHC *xabfhc = 0;
static struct XABDAT *xabdat = 0;
static struct XABRDT *xabrdt = 0;
static struct XABPRO *xabpro = 0;
static struct XABKEY *xabkey = 0;
static struct XABALL *xaball = 0;
struct XAB *first_xab = 0L, *last_xab = 0L;

static char query = 0;
static int  text_output = 0,
	    raw_input,
	    hostnum;

static uch rfm;

static uch locbuf[BUFS512];
static int loccnt = 0;
static uch *locptr;
static char got_eol = 0;

static int  _flush_blocks(),
	    _flush_stream(),
	    _flush_varlen(),
	    _flush_qio(),
	    _close_qio(),
	    _close_rms(),
	    WriteRecord(),
	    WriteBuffer(),
	    find_eol();

static int  (*_flush_routine)(),
	    (*_close_routine)();

static int get_vms_version();
static int replace();
static uch *extract_block();
static void init_buf_ring();
static void decompress_bits();
static void UpdateCRC();
static void message();
static void free_up();

struct bufdsc
{
    struct bufdsc *next;
    uch *buf;
    int bufcnt;
};

static struct bufdsc b1, b2, *curbuf;
static uch buf1[BUFS512];

int check_format()
{
    int rtype;
    struct FAB fab;

    fab = cc$rms_fab;
    fab.fab$l_fna = zipfn;
    fab.fab$b_fns = strlen(zipfn);

    sys$open(&fab);
    rtype = fab.fab$b_rfm;
    sys$close(&fab);

    if (rtype == FAB$C_VAR || rtype == FAB$C_VFC)
    {
	fprintf(stderr,
		"\n     Error:  zipfile is in variable-length record format.  Please\n\
     run \"bilf l %s\" to convert the zipfile to stream-LF\n\
     record format.  (bilf.c and make_bilf.com are included in the\n\
     VMS UnZip source distribution.)\n\n", zipfn);
	return PK_ERR;
    }

    return PK_COOL;
}



#define PRINTABLE_FORMAT(x)	( (x) == FAB$C_VAR 		\
				|| (x) == FAB$C_STMLF		\
				|| (x) == FAB$C_STMCR		\
				|| (x) == FAB$C_STM		)

/* VMS extra field types */
#define	VAT_NONE    0
#define	VAT_IZ	    1	/* Old INFO-ZIP format */
#define VAT_PK	    2	/* PKWARE format */

static int  vet;

static int  create_default_output(),
	    create_rms_output(),
	    create_qio_output();

/*
 *  open_outfile() assignments:
 *
 *  VMS attributes ?	    create_xxx	    _flush_xxx
 *  ----------------	    ----------	    ----------
 *  not found		    'default'	    text mode ?
 *					    yes -> 'stream'
 *					    no  -> 'block'
 *
 *  yes, in IZ format	    'rms'	    text mode ?
 *					    yes -> switch(fab.rfm)
 *						VAR  -> 'varlen' 
 *						STM* -> 'stream'
 *					        default -> 'block'
 *					    no -> 'block'
 *
 *  yes, in PK format	    'qio'	    'qio'
 *
 *  "text mode" == pInfo -> text || cflag
 */

int open_outfile()
{
    switch(vet = find_vms_attrs())
    {	case VAT_NONE:
	default:
	    return  create_default_output();
	case VAT_IZ:
	    return  create_rms_output();
	case VAT_PK:
	    return  create_qio_output();
    }
}

static void init_buf_ring()
{
    locptr = &locbuf[0];
    loccnt = 0;

    b1.buf = &locbuf[0];
    b1.bufcnt = 0;
    b1.next = &b2;
    b2.buf = &buf1[0];
    b2.bufcnt = 0;
    b2.next = &b1;
    curbuf = &b1;
}



static int create_default_output()
{
    int ierr, yr, mo, dy, hh, mm, ss;
    char timbuf[24];		/* length = first entry in "stupid" + 1 */
    int attr_given;		/* =1 if VMS attributes are present in
				 *    extra_field */

    rab = cc$rms_rab;		/* fill FAB & RAB with default values */
    fileblk = cc$rms_fab;

    text_output = pInfo->textmode || cflag;	/* extract the file in text
    						 * (variable-length) format */
    hostnum = pInfo -> hostnum;

    outfab = &fileblk;
    outfab->fab$l_xab = 0L;
    rfm = FAB$C_STMLF;	/* Default, stream-LF format from VMS
			    *   or UNIX */
    if (text_output)
    {   /* Default format for output text file */

	outfab->fab$b_rfm = FAB$C_VAR;	/* variable length records */
	outfab->fab$b_rat = FAB$M_CR;	/* carriage-return carriage ctrl */
    }
    else
    {   /* Default format for output binary file */

	outfab->fab$b_rfm = FAB$C_STMLF;	/* stream-LF record format */
	outfab->fab$b_rat = FAB$M_CR;	/* carriage-return carriage ctrl */
    }

    if (!cflag)	/* Redirect output */
	outfab->fab$l_fna = filename;
    else
	outfab->fab$l_fna = "sys$output:";

    outfab->fab$b_fns = strlen(outfab->fab$l_fna);

    {
	static char *month[] =
	    {"JAN", "FEB", "MAR", "APR", "MAY", "JUN",
	     "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

	/*  fixed-length string descriptor: */
	struct dsc$descriptor stupid =
	    {23, DSC$K_DTYPE_T, DSC$K_CLASS_S, timbuf};

	yr = ((lrec.last_mod_file_date >> 9) & 0x7f) + 1980;
	mo = ((lrec.last_mod_file_date >> 5) & 0x0f) - 1;
	dy = (lrec.last_mod_file_date & 0x1f);
	hh = (lrec.last_mod_file_time >> 11) & 0x1f;
	mm = (lrec.last_mod_file_time >> 5) & 0x3f;
	ss = (lrec.last_mod_file_time & 0x1f) * 2;

	dattim = cc$rms_xabdat;	/* fill XABs with default values */
	rdt = cc$rms_xabrdt;
	sprintf(timbuf, "%02d-%3s-%04d %02d:%02d:%02d.00", dy, month[mo], yr,
		hh, mm, ss);
	sys$bintim(&stupid, &dattim.xab$q_cdt);
	memcpy(&rdt.xab$q_rdt, &dattim.xab$q_cdt, sizeof(rdt.xab$q_rdt));

	dattim.xab$l_nxt = outfab->fab$l_xab;
	outfab->fab$l_xab = &dattim;
    }

    outfab->fab$w_ifi = 0;	/* Clear IFI. It may be nonzero after ZIP */

    ierr = sys$create(outfab);
    if (ierr == RMS$_FEX)
	ierr = replace();

    if (ierr == 0)		/* Canceled */
	return free_up(), 1;

    if (ERR(ierr))
    {
	char buf[256];

	sprintf(buf, "[ Cannot create output file %s ]\n", filename);
	message(buf, ierr);
	message("", outfab->fab$l_stv);
	free_up();
	return PK_WARN;
    }

    if (!text_output)    /* Do not reopen text files and stdout
			*  Just open them in right mode         */
    {
	/*
	*       Reopen file for Block I/O with no XABs.
	*/
	if ((ierr = sys$close(outfab)) != RMS$_NORMAL)
	{
#ifdef DEBUG
	    message("[ create_output_file: sys$close failed ]\n", ierr);
	    message("", outfab->fab$l_stv);
#endif
	    fprintf(stderr, "Can't create output file:  %s\n", filename);
	    free_up();
	    return PK_WARN;
	}


	outfab->fab$b_fac = FAB$M_BIO | FAB$M_PUT;	/* Get ready for block
							 * output */
	outfab->fab$l_xab = 0L;	/* Unlink all XABs */

	if ((ierr = sys$open(outfab)) != RMS$_NORMAL)
	{
	    char buf[256];

	    sprintf(buf, "[ Cannot open output file %s ]\n", filename);
	    message(buf, ierr);
	    message("", outfab->fab$l_stv);
	    free_up();
	    return PK_WARN;
	}
    }

    outrab = &rab;
    rab.rab$l_fab = outfab;
    if (!text_output)
    {   rab.rab$l_rop |= RAB$M_BIO;
        rab.rab$l_rop |= RAB$M_ASY;
    }
    rab.rab$b_rac = RAB$C_SEQ;

    if ((ierr = sys$connect(outrab)) != RMS$_NORMAL)
    {
#ifdef DEBUG
	message("create_output_file: sys$connect failed.\n", ierr);
	message("", outfab->fab$l_stv);
#endif
	fprintf(stderr, "Can't create output file:  %s\n", filename);
	free_up();
	return PK_WARN;
    }

    init_buf_ring();

    _flush_routine = text_output? got_eol=0,_flush_stream : _flush_blocks;
    _close_routine = _close_rms;
    return PK_COOL;
}



static int create_rms_output()
{
    int ierr, yr, mo, dy, hh, mm, ss;
    char timbuf[24];		/* length = first entry in "stupid" + 1 */

    rab = cc$rms_rab;		/* fill FAB & RAB with default values */
    fileblk = cc$rms_fab;

    text_output = cflag;	/* extract the file in text (variable-length)
				 * format; ignore -a when attributes saved */
    hostnum = pInfo -> hostnum;

    if (cflag)
    {
	if(!PRINTABLE_FORMAT(rfm=outfab->fab$b_rfm))
	{	printf("[ File %s has illegal record format to put to screen ]\n",
	       filename);
	    free_up();
	    return PK_DISK;
	}
    }

    if (!cflag)	/* Redirect output */
	outfab->fab$l_fna = filename;
    else
	outfab->fab$l_fna = "sys$output:";

    outfab->fab$b_fns = strlen(outfab->fab$l_fna);

    if (!(xabdat && xabrdt))	/* Use date/time info
				 *  from zipfile if
				 *  no attributes given
				 */
    {
	static char *month[] =
	    {"JAN", "FEB", "MAR", "APR", "MAY", "JUN",
	     "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

	/*  fixed-length string descriptor: */
	struct dsc$descriptor stupid =
	    {23, DSC$K_DTYPE_T, DSC$K_CLASS_S, timbuf};

	yr = ((lrec.last_mod_file_date >> 9) & 0x7f) + 1980;
	mo = ((lrec.last_mod_file_date >> 5) & 0x0f) - 1;
	dy = (lrec.last_mod_file_date & 0x1f);
	hh = (lrec.last_mod_file_time >> 11) & 0x1f;
	mm = (lrec.last_mod_file_time >> 5) & 0x3f;
	ss = (lrec.last_mod_file_time & 0x1f) * 2;

	dattim = cc$rms_xabdat;	/* fill XABs with default values */
	rdt = cc$rms_xabrdt;
	sprintf(timbuf, "%02d-%3s-%04d %02d:%02d:%02d.00", dy, month[mo], yr,
		hh, mm, ss);
	sys$bintim(&stupid, &dattim.xab$q_cdt);
	memcpy(&rdt.xab$q_rdt, &dattim.xab$q_cdt, sizeof(rdt.xab$q_rdt));

	if (xabdat == 0L)
	{
	    dattim.xab$l_nxt = outfab->fab$l_xab;
	    outfab->fab$l_xab = &dattim;
	}
    }

    outfab->fab$w_ifi = 0;	/* Clear IFI. It may be nonzero after ZIP */

    ierr = sys$create(outfab);
    if (ierr == RMS$_FEX)
	ierr = replace();

    if (ierr == 0)		/* Canceled */
	return free_up(), 1;

    if (ERR(ierr))
    {
	char buf[256];

	sprintf(buf, "[ Cannot create output file %s ]\n", filename);
	message(buf, ierr);
	message("", outfab->fab$l_stv);
	free_up();
	return PK_WARN;
    }

    if (!text_output)    /* Do not reopen text files and stdout
			*  Just open them in right mode         */
    {
	/*
	*       Reopen file for Block I/O with no XABs.
	*/
	if ((ierr = sys$close(outfab)) != RMS$_NORMAL)
	{
#ifdef DEBUG
	    message("[ create_output_file: sys$close failed ]\n", ierr);
	    message("", outfab->fab$l_stv);
#endif
	    fprintf(stderr, "Can't create output file:  %s\n", filename);
	    free_up();
	    return PK_WARN;
	}


	outfab->fab$b_fac = FAB$M_BIO | FAB$M_PUT;	/* Get ready for block
							 * output */
	outfab->fab$l_xab = 0L;	/* Unlink all XABs */

	if ((ierr = sys$open(outfab)) != RMS$_NORMAL)
	{
	    char buf[256];

	    sprintf(buf, "[ Cannot open output file %s ]\n", filename);
	    message(buf, ierr);
	    message("", outfab->fab$l_stv);
	    free_up();
	    return PK_WARN;
	}
    }

    outrab = &rab;
    rab.rab$l_fab = outfab;
    if (!text_output)
    {   rab.rab$l_rop |= RAB$M_BIO;
        rab.rab$l_rop |= RAB$M_ASY;
    }
    rab.rab$b_rac = RAB$C_SEQ;

    if ((ierr = sys$connect(outrab)) != RMS$_NORMAL)
    {
#ifdef DEBUG
	message("create_output_file: sys$connect failed.\n", ierr);
	message("", outfab->fab$l_stv);
#endif
	fprintf(stderr, "Can't create output file:  %s\n", filename);
	free_up();
	return PK_WARN;
    }

    init_buf_ring();

    if( text_output )
	switch(rfm)
	{
		case FAB$C_VAR:
			_flush_routine = _flush_varlen;
			break;
		case FAB$C_STM:
		case FAB$C_STMCR:
		case FAB$C_STMLF:
			_flush_routine = _flush_stream;
			got_eol = 0;
			break;
		default:
			_flush_routine = _flush_blocks;
			break;
	}
    else
	_flush_routine = _flush_blocks;
    _close_routine = _close_rms;
    return PK_COOL;
}



static	int pka_devchn;
static	int pka_vbn;

static struct
{   short   status;
    long    count;
    short   dummy;
} pka_io_sb;

static struct
{   short   status;
    short   dummy;
    void    *addr;
} pka_acp_sb;

static struct fibdef	pka_fib;
static struct atrdef	pka_atr[VMS_MAX_ATRCNT];
static int		pka_idx;
static ulg		pka_uchar;
static struct fatdef	pka_rattr;

static struct dsc$descriptor	pka_fibdsc =
{   sizeof(pka_fib), DSC$K_DTYPE_Z, DSC$K_CLASS_S, &pka_fib	};

static struct dsc$descriptor_s	pka_devdsc =
{   0, DSC$K_DTYPE_T, DSC$K_CLASS_S, &nam.nam$t_dvi[1]	};

static struct dsc$descriptor_s pka_fnam =
{   0, DSC$K_DTYPE_T, DSC$K_CLASS_S, 0	};



static int create_qio_output()
{   int status;
    static char exp_nam[NAM$C_MAXRSS];
    static char res_nam[NAM$C_MAXRSS];
    int	i;

    if( cflag )
    {	fprintf(stderr,"[ Cannot put to screen ]\n");
	return PK_DISK;
    }

    fileblk = cc$rms_fab;
    fileblk.fab$l_fna = filename;
    fileblk.fab$b_fns = strlen(filename);

    nam = cc$rms_nam;
    fileblk.fab$l_nam = &nam;
    nam.nam$l_esa = &exp_nam;
    nam.nam$b_ess = sizeof(exp_nam);
    nam.nam$l_rsa = &res_nam;
    nam.nam$b_rss = sizeof(res_nam);

    if( ERR(status = sys$parse(&fileblk)) )
    {	message("create_output_file: sys$parse failed.\n", status);
	return PK_DISK;
    }       

    pka_devdsc.dsc$w_length = (unsigned short)nam.nam$t_dvi[0];

    if( ERR(status = sys$assign(&pka_devdsc,&pka_devchn,0,0)) )
    {	message("sys$assign failed.\n",status);
	return PK_DISK;
    }

    pka_fnam.dsc$a_pointer = nam.nam$l_name;
    pka_fnam.dsc$w_length  = nam.nam$b_name + nam.nam$b_type;
    if( V_flag /* keep versions */ )
	pka_fnam.dsc$w_length += nam.nam$b_ver;

    for (i=0;i<3;i++)
    {	pka_fib.FIB$W_DID[i]=nam.nam$w_did[i];
    	pka_fib.FIB$W_FID[i]=0;
    }

    pka_fib.FIB$L_ACCTL = FIB$M_WRITE;
    /* Allocate space for the file */
    pka_fib.FIB$W_EXCTL = FIB$M_EXTEND;
    if( pka_uchar & FCH$M_CONTIG )
	pka_fib.FIB$W_EXCTL |= FIB$M_ALCON | FIB$M_FILCON;
    if( pka_uchar & FCH$M_CONTIGB )
	pka_fib.FIB$W_EXCTL |= FIB$M_ALCONB;

#define SWAPW(x)	( (((x)>>16)&0xFFFF) + ((x)<<16) )

    pka_fib.fib$l_exsz = SWAPW(pka_rattr.fat$r_hiblk_overlay.fat$l_hiblk);

    status = sys$qiow(0, pka_devchn, IO$_CREATE|IO$M_CREATE|IO$M_ACCESS,
	&pka_acp_sb, 0, 0,
	&pka_fibdsc, &pka_fnam, 0, 0, &pka_atr, 0);

    if( !ERR(status) )
	status = pka_acp_sb.status;

    if( ERR(status) )
    {	message("[ Create file QIO failed.\n",status);
	return PK_DISK;
	sys$dassgn(pka_devchn);
    }

    pka_vbn = 1;
    _flush_routine = _flush_qio;
    _close_routine = _close_qio;
    return PK_COOL;
}



static int replace()
{			/*
			*	File exists. Inquire user about further action.
			*/
    char answ[10];
    struct NAM nam;
    int ierr;

    if (query == 0)
    {
	do
	{
	    fprintf(stderr,
		    "%s exists:  [o]verwrite, new [v]ersion or [n]o extract?\n\
  (uppercase response [O,V,N] = do same for all files): ",
		    filename);
	    fflush(stderr);
	} while (fgets(answ, 9, stderr) == NULL && !isalpha(answ[0])
		 && tolower(answ[0]) != 'o'
		 && tolower(answ[0]) != 'v'
		 && tolower(answ[0]) != 'n');

	if (isupper(answ[0]))
	    query = answ[0] = tolower(answ[0]);
    }
    else
	answ[0] = query;

    switch (answ[0])
    {
	case 'n':
	    ierr = 0;
	    break;
	case 'v':
	    nam = cc$rms_nam;
	    nam.nam$l_rsa = filename;
	    nam.nam$b_rss = FILNAMSIZ - 1;

	    outfab->fab$l_fop |= FAB$M_MXV;
	    outfab->fab$l_nam = &nam;

	    ierr = sys$create(outfab);
	    if (!ERR(ierr))
	    {
		outfab->fab$l_nam = 0L;
		filename[outfab->fab$b_fns = nam.nam$b_rsl] = 0;
	    }
	    break;
	case 'o':
	    outfab->fab$l_fop |= FAB$M_SUP;
	    ierr = sys$create(outfab);
	    break;
    }
    return ierr;
}



#define W(p)    (*(unsigned short*)(p))
#define L(p)    (*(unsigned long*)(p))
#define EQL_L(a,b)      ( L(a) == L(b) )
#define EQL_W(a,b)      ( W(a) == W(b) )

/****************************************************************
 * Function find_vms_attrs scans ZIP entry extra field if any   *
 * and looks for VMS attribute records. Returns 0 if either no  *
 * attributes found or no fab given.                            *
 ****************************************************************/
int find_vms_attrs()
{
    uch *scan = extra_field;
    struct  EB_header *hdr;
    int len;
    int	type=VAT_NONE;

    outfab = xabfhc = xabdat = xabrdt = xabpro = first_xab = last_xab = 0L;

    if (scan == NULL)
	return PK_COOL;
    len = lrec.extra_field_length;

#define LINK(p) {	/* Link xaballs and xabkeys into chain */	\
                if( first_xab == 0L )                   \
                        first_xab = p;                  \
                if( last_xab != 0L )                    \
                        last_xab -> xab$l_nxt = p;      \
                last_xab = p;                           \
                p -> xab$l_nxt = 0;                     \
        }
    /* End of macro LINK */

    while (len > 0)
    {
	hdr = (struct EB_header *) scan;
	if (EQL_W(&hdr->tag, IZ_SIGNATURE))
	{
	    /*
	    *	INFO-ZIP style extra block decoding
	    */
	    struct IZ_block *blk;
	    uch *block_id;

	    type = VAT_IZ;	    

	    blk = (struct IZ_block *)hdr;
	    block_id = &blk->bid;
	    if (EQL_L(block_id, FABSIG))
	    {
		outfab = (struct FAB *) extract_block(blk, 0,
						      &cc$rms_fab, FABL);
	    }
	    else if (EQL_L(block_id, XALLSIG))
	    {
		xaball = (struct XABALL *) extract_block(blk, 0,
							 &cc$rms_xaball, XALLL);
		LINK(xaball);
	    }
	    else if (EQL_L(block_id, XKEYSIG))
	    {
		xabkey = (struct XABKEY *) extract_block(blk, 0,
							 &cc$rms_xabkey, XKEYL);
		LINK(xabkey);
	    }
	    else if (EQL_L(block_id, XFHCSIG))
	    {
		xabfhc = (struct XABFHC *) extract_block(blk, 0,
							 &cc$rms_xabfhc, XFHCL);
	    }
	    else if (EQL_L(block_id, XDATSIG))
	    {
		xabdat = (struct XABDAT *) extract_block(blk, 0,
							 &cc$rms_xabdat, XDATL);
	    }
	    else if (EQL_L(block_id, XRDTSIG))
	    {
		xabrdt = (struct XABRDT *) extract_block(blk, 0,
							 &cc$rms_xabrdt, XRDTL);
	    }
	    else if (EQL_L(block_id, XPROSIG))
	    {
		xabpro = (struct XABPRO *) extract_block(blk, 0,
							 &cc$rms_xabpro, XPROL);
	    }
	    else if (EQL_L(block_id, VERSIG))
	    {
#ifdef CHECK_VERSIONS
		char verbuf[80];
		int verlen = 0;
		uch *vers;
		char *m;

		get_vms_version(verbuf, 80);
		vers = extract_block(blk, &verlen, 0, 0);
		if ((m = strrchr(vers, '-')) != NULL)
		    *m = 0;	/* Cut out release number */
		if (strcmp(verbuf, vers) && qflag < 2)
		{
		    printf("[ Warning: VMS version mismatch.");

		    printf("   This version %s --", verbuf);
		    strncpy(verbuf, vers, verlen);
		    verbuf[verlen] = 0;
		    printf(" version made by %s ]\n", verbuf);
		}
		free(vers);
#endif
	    }
	    else
		fprintf(stderr, "[ Warning: Unknown block signature %s ]\n",
			block_id);
	}
	else if (hdr->tag == PK_SIGNATURE || hdr->tag == IZ_NEW_SIGNATURE)
	{
	    /*
	    *	PKWARE style extra block decoding
	    */
	    struct  PK_header	*blk;
	    register byte   *scn;
	    register int    len;

	    type = VAT_PK;	    

	    blk = (struct PK_header *)hdr;
	    len = blk -> size;
	    scn = (byte *)(&blk->data);
	    pka_idx = 0;
	    
	    while(len > PK_FLDHDR_SIZE)
	    {	register struct  PK_field	*fld;
		int	skip=0;

		fld = (struct PK_field *)scn;
		switch(fld->tag)
		{   case ATR$C_UCHAR:
			pka_uchar = L(&fld->value);
			break;
		    case ATR$C_RECATTR:
			pka_rattr = *(struct fatdef *)(&fld->value);
			break;
		    case ATR$C_UIC:
		    case ATR$C_ADDACLENT:
			skip = !secinf;
			break;
		}

		if( !skip )
		{   pka_atr[pka_idx].atr$w_size = fld->size;
		    pka_atr[pka_idx].atr$w_type = fld->tag;
		    pka_atr[pka_idx].atr$l_addr = &fld->value;
		    ++pka_idx;
		}
		len -= fld->size + PK_FLDHDR_SIZE;
		scn += fld->size + PK_FLDHDR_SIZE;
	    }
	    pka_atr[pka_idx].atr$w_size = 0;	/* End of list */
	    pka_atr[pka_idx].atr$w_type = 0;
	    pka_atr[pka_idx].atr$l_addr = 0L;
	}
	len -= hdr->size + 4;
	scan += hdr->size + 4;
    }


    if( type == VAT_IZ )
    {	if (outfab != 0)
	{	/* Do not link XABPRO,XABRDT now. Leave them for sys$close() */

	    outfab->fab$l_xab = 0L;
	    if (xabfhc != 0L)
	    {
		xabfhc->xab$l_nxt = outfab->fab$l_xab;
		outfab->fab$l_xab = xabfhc;
	    }
	    if (xabdat != 0L)
	    {
		xabdat->xab$l_nxt = outfab->fab$l_xab;
		outfab->fab$l_xab = xabdat;
	    }
	    if (first_xab != 0L)	/* Link xaball,xabkey subchain */
	    {
		last_xab->xab$l_nxt = outfab->fab$l_xab;
		outfab->fab$l_xab = first_xab;
	    }
	}
        else
	    type = VAT_NONE;
    }
    return type;
}



static void free_up()
{				/*
				*	Free up all allocated xabs
				*/
    if (xabdat != 0L) free(xabdat);
    if (xabpro != 0L) free(xabpro);
    if (xabrdt != 0L) free(xabrdt);
    if (xabfhc != 0L) free(xabfhc);
    while (first_xab != 0L)
    {
	struct XAB *x;

	x = first_xab->xab$l_nxt;
	free(first_xab);
	first_xab = x;
    }
    if (outfab != 0L && outfab != &fileblk)
	free(outfab);
}



#ifdef CHECK_VERSIONS

static int get_vms_version(verbuf, len)
    char *verbuf;
    int len;
{
    int i = SYI$_VERSION;
    int verlen = 0;
    struct dsc$descriptor version;
    char *m;

    version.dsc$a_pointer = verbuf;
    version.dsc$w_length = len - 1;
    version.dsc$b_dtype = DSC$K_DTYPE_B;
    version.dsc$b_class = DSC$K_CLASS_S;

    if (ERR(lib$getsyi(&i, 0, &version, &verlen, 0, 0)) || verlen == 0)
	return 0;

    /* Cut out trailing spaces "V5.4-3   " -> "V5.4-3" */
    for (m = verbuf + verlen, i = verlen - 1; i > 0 && verbuf[i] == ' '; --i)
	--m;
    *m = 0;

    /* Cut out release number "V5.4-3" -> "V5.4" */
    if ((m = strrchr(verbuf, '-')) != NULL)
	*m = 0;
    return strlen(verbuf) + 1;	/* Transmit ending 0 too */
}

#endif /* CHECK_VERSIONS */



/*
 * Extracts block from p. If resulting length is less then needed, fill
 * extra space with corresponding bytes from 'init'.
 * Currently understands 3 formats of block compression:
 * - Simple storing
 * - Compression of zero bytes to zero bits
 * - Deflation (see memextract() in extract.c)
 */
static uch *extract_block(p, retlen, init, needlen)
    struct IZ_block *p;
    int *retlen;
    uch *init;
    int needlen;
{
    uch *block;		/* Pointer to block allocated */
    int cmptype;
    int usiz, csiz, max;

    cmptype = p->flags & BC_MASK;
    csiz = p->size - EXTBSL - RESL;
    usiz = (cmptype == BC_STORED ? csiz : p->length);

    if (needlen == 0)
	needlen = usiz;

    if (retlen)
	*retlen = usiz;

#ifndef MAX
#define MAX(a,b)	( (a) > (b) ? (a) : (b) )
#endif

    if ((block = (uch *) malloc(MAX(needlen, usiz))) == NULL)
	return NULL;

    if (init && (usiz < needlen))
	memcpy(block, init, needlen);

    switch (cmptype)
    {
	case BC_STORED:	/* The simplest case */
	    memcpy(block, &(p->body[0]), usiz);
	    break;
	case BC_00:
	    decompress_bits(block, usiz, &(p->body[0]));
	    break;
	case BC_DEFL:
	    memextract(block, usiz, &(p->body[0]), csiz);
	    break;
	default:
	    free(block);
	    block = NULL;
    }
    return block;
}



/*
 *  Simple uncompression routine. The compression uses bit stream.
 *  Compression scheme:
 *
 *  if(byte!=0)
 *      putbit(1),putbyte(byte)
 *  else
 *      putbit(0)
 */
static void decompress_bits(outptr, needlen, bitptr)
    uch *bitptr;	/* Pointer into compressed data */
    uch *outptr;	/* Pointer into output block */
    int needlen;	/* Size of uncompressed block */
{
    ulg bitbuf = 0;
    int bitcnt = 0;

#define _FILL   if(bitcnt+8 <= 32)                      \
                {       bitbuf |= (*bitptr++) << bitcnt;\
                        bitcnt += 8;                    \
                }

    while (needlen--)
    {
	if (bitcnt <= 0)
	    _FILL;

	if (bitbuf & 1)
	{
	    bitbuf >>= 1;
	    if ((bitcnt -= 1) < 8)
		_FILL;
	    *outptr++ = (uch) bitbuf;
	    bitcnt -= 8;
	    bitbuf >>= 8;
	}
	else
	{
	    *outptr++ = 0;
	    bitcnt -= 1;
	    bitbuf >>= 1;
	}
    }
}



static void UpdateCRC(s, len)
    register uch *s;
    register int len;
{
    register ulg crcval = crc32val;

    /* update running CRC calculation with contents of a buffer */
    while (len--)
        crcval = crc_32_tab[((uch)crcval ^ (*s++)) & 0xff] ^ (crcval >> 8);
    crc32val = crcval;
}



/* flush contents of output buffer */
int flush(rawbuf, size, unshrink)    /* return PK-type error code */
    uch *rawbuf;
    ulg size;
    int unshrink;
{
    UpdateCRC(rawbuf, size);
    if (tflag)
	return PK_COOL;	/* Do not output. Update CRC only */
    else
	return (*_flush_routine)(rawbuf, size, 0);
}



static int _flush_blocks(rawbuf, size, final_flag)   /* Asynchronous version */
    uch *rawbuf;
    unsigned size;
    int final_flag;   /* 1 if this is the final flushout */
{
    int round;
    int rest;
    int off = 0;
    int status;

    while (size > 0)
    {
	if (curbuf->bufcnt < BUFS512)
	{
	    int ncpy;

	    ncpy = size > (BUFS512 - curbuf->bufcnt) ?
			    BUFS512 - curbuf->bufcnt :
			    size;
	    memcpy(curbuf->buf + curbuf->bufcnt, rawbuf + off, ncpy);
	    size -= ncpy;
	    curbuf->bufcnt += ncpy;
	    off += ncpy;
	}
	if (curbuf->bufcnt == BUFS512)
	{
	    status = WriteBuffer(curbuf->buf, curbuf->bufcnt);
	    if (status)
		return status;
	    curbuf = curbuf->next;
	    curbuf->bufcnt = 0;
	}
    }

    return (final_flag && (curbuf->bufcnt > 0)) ?
	WriteBuffer(curbuf->buf, curbuf->bufcnt) :
	PK_COOL;
}



static int _flush_qio(rawbuf, size, final_flag)
    uch *rawbuf;
    unsigned size;
    int final_flag;   /* 1 if this is the final flushout -- currently ignored */
{
    int status;
    uch	*out_ptr=rawbuf;

    if( final_flag )
    {	
	if( loccnt > 0 )
	{   status = sys$qiow(0, pka_devchn, IO$_WRITEVBLK, 
		&pka_io_sb, 0, 0,
		locbuf, ((loccnt+1)/2)*2,   /* Round to event byte count */
		pka_vbn,
		0, 0, 0);
	    if(!ERR(status))	    
		status = pka_io_sb.status;
	    if(ERR(status))
	    {   message("[ Write QIO failed ]\n",status);
		return PK_DISK;
	    }
	}
	return PK_COOL;	
    }

    if( loccnt > 0 )
    {	/*
	*   Fill local buffer upto 512 bytes then put it out
	*/
	int ncpy;

	ncpy = 512-loccnt;
	if( ncpy > size )
	    ncpy = size;

	memcpy(locptr,rawbuf,ncpy);
	locptr += ncpy;
	loccnt += ncpy;
	size -= ncpy;
	out_ptr += ncpy;
	if( loccnt == 512 )
	{	 
	    status = sys$qiow(0, pka_devchn, IO$_WRITEVBLK, 
		&pka_io_sb, 0, 0,
		locbuf, loccnt, pka_vbn,
		0, 0, 0);
	    if(!ERR(status))	    
		status = pka_io_sb.status;
	    if(ERR(status))
	    {   message("[ Write QIO failed ]\n",status);
		return PK_DISK;
	    }

	    pka_vbn++;
	    loccnt = 0;
	    locptr = locbuf;
	}
    }

    if( size >= 512 )
    {	int nblk,put_cnt;

	/*
	*   Put rest of buffer as a single VB
	*/
	put_cnt = (nblk = size>>9)<<9;
	status = sys$qiow(0, pka_devchn, IO$_WRITEVBLK, 
	    &pka_io_sb, 0, 0,
	    out_ptr, put_cnt, pka_vbn,
	    0, 0, 0);
	if(!ERR(status))	    
	    status = pka_io_sb.status;
	if(ERR(status))
	{   message("[ Write QIO failed ]\n",status);
	    return PK_DISK;
	}

	pka_vbn += nblk;
	out_ptr += put_cnt;
	size -= put_cnt;
    }

    if( size > 0 )
    {	memcpy(locptr,out_ptr,size);
	loccnt += size;
	locptr += size;
    }


    return PK_COOL;
}



static int _flush_varlen(rawbuf, size, final_flag)
    uch *rawbuf;
    unsigned size;
    int final_flag;
{
	ush nneed;
	ush reclen;
	uch *inptr=rawbuf;

	/*
	*	Flush local buffer
	*/

	if( loccnt > 0 )
	{	reclen = *(ush*)locbuf;
		if( (nneed = reclen + 2 - loccnt) > 0 )
		{	if( nneed > size )
			{	if( size+loccnt > BUFS512 )
				{	fprintf(stderr,"[ Record too long (%d bytes) ]\n",reclen );
					return PK_DISK;
				}
				memcpy(locbuf+loccnt,rawbuf,size);
				loccnt += size;
				size = 0;
			}
			else
			{	memcpy(locbuf+loccnt,rawbuf,nneed);
				loccnt += nneed;
				size -= nneed;
				inptr += nneed;
				if( reclen & 1 )
				{	size--;
					inptr++;
				}
				if( WriteRecord(locbuf+2,reclen) )
					return PK_DISK;
				loccnt = 0;
			}
		}
		else
		{	if(WriteRecord(locbuf+2,reclen))
				return PK_DISK;
			loccnt -= reclen+2;
		}
	}
	/*
	*	Flush incoming records
	*/
	while(size > 0)
	{	reclen = *(ush*)inptr;
		if( reclen+2 <= size )
		{	if(WriteRecord(inptr+2,reclen))
				return PK_DISK;
			size -= 2+reclen;
			inptr += 2+reclen;
			if( reclen & 1)
			{	--size;
				++inptr;
			}
		}
		else
		{	memcpy(locbuf,inptr,size);
			loccnt = size;
			size = 0;
		}
					
	}
	/*
	*	Final flush rest of local buffer
	*/
	if( final_flag && loccnt > 0 )
	{	fprintf(stderr,
			"[ Warning, incomplete record of length %d ]\n",
			*(ush*)locbuf);
		if( WriteRecord(locbuf+2,loccnt-2) )
			return PK_DISK;
	}
	return PK_COOL;
}



/*
*   Routine _flush_stream breaks decompressed stream into records
*   depending on format of the stream (fab->rfm, pInfo->textmode, etc.)
*   and puts out these records. It also handles CR LF sequences.
*   Should be used when extracting *text* files.
*/

#define VT	0x0B
#define FF	0x0C

/* The file is from MSDOS/OS2/NT -> handle CRLF as record end, throw out ^Z */

/* GRR NOTES:  cannot depend on hostnum!  May have "flip'd" file or re-zipped
 * a Unix file, etc. */

#ifdef	USE_ORIG_DOS
# define ORG_DOS	(hostnum==FS_FAT_ || hostnum==FS_HPFS_ || hostnum==FS_NTFS_)
#else
# define ORG_DOS    1
#endif

/* Record delimiters */
#ifdef	undef
#define RECORD_END(c,f)							\
( 	   ( ORG_DOS || pInfo->textmode ) && c==CTRLZ			\
	|| ( f == FAB$C_STMLF && c==LF )				\
	|| ( f == FAB$C_STMCR || ORG_DOS || pInfo->textmode ) && c==CR	\
	|| ( f == FAB$C_STM && (c==CR || c==LF || c==FF || c==VT) )	\
)
#else
#   define  RECORD_END(c,f)   ((c) == LF || (c) == (CR))
#endif

static int  find_eol(p,n,l)
/*
 *  Find first CR,LF,CR-LF or LF-CR in string 'p' of length 'n'.
 *  Return offset of the sequence found or 'n' if not found.
 *  If found, return in '*l' length of the sequence (1 or 2) or
 *  zero if sequence end not seen, i.e. CR or LF is last char
 *  in the buffer.
 */
char	*p;
int	n;
int	*l;
{   int	off = n;
    char    *q;

    *l = 0;

    for(q=p ; n > 0 ; --n,++q)
	if( RECORD_END(*q,rfm) )
	{   off = q-p;
	    break;
	}

    if( n > 1 )
    {
	*l = 1;
	if( ( q[0] == CR && q[1] == LF ) || ( q[0] == LF && q[1] == CR ) )
	    *l = 2;
    }

    return off;
}

/* Record delimiters that must be put out */
#define PRINT_SPEC(c)	( (c)==FF || (c)==VT )



static int _flush_stream(rawbuf, size, final_flag)
    uch *rawbuf;
    unsigned size;
    int final_flag; /* 1 if this is the final flushout */
{
    int rest;
    int end = 0, start = 0;
    int off = 0;
				 
    if (size == 0 && loccnt == 0)
	return PK_COOL;		/* Nothing to do ... */

    if( final_flag )
    {	int recsize;

	/*
	 * This is flush only call. size must be zero now.
	 * Just eject everything we have in locbuf.
	 */
	recsize = loccnt - (got_eol ? 1:0);
	/*
	 *  If the last char of file was ^Z ( end-of-file in MSDOS ),
	 *  we will see it now.
	 */
	if( recsize==1 && locbuf[0] == CTRLZ )
	    return PK_COOL;

	return WriteRecord(locbuf, recsize) ? PK_DISK : PK_COOL;
    }


    if ( loccnt > 0 )
    {	/* Find end of record partialy saved in locbuf */

	int recsize;
	int complete=0;

	if( got_eol )
	{   recsize = loccnt - 1;
	    complete = 1;

	    if( (got_eol == CR && rawbuf[0] == LF) || (got_eol == LF && rawbuf[0] == CR) )
		end = 1;

	    got_eol = 0;
	}
	else
	{   int	eol_len;
	    int	eol_off;

	    eol_off = find_eol(rawbuf,size,&eol_len);

	    if( loccnt+eol_off > BUFS512 )
	    {	/*
		 *  No room in locbuf. Dump it and clear
		 */
		recsize = loccnt;
		start = 0;
		fprintf(stderr, "[ Warning: Record too long (%d) ]\n",
		    loccnt+eol_off);
		complete = 1;
		end = 0;
	    }
	    else
	    {	if( eol_off >= size )
		{   end = size;
		    complete = 0;
		}
		else if( eol_len == 0 )
		{   got_eol = rawbuf[eol_off];
		    end = size;
		    complete = 0;
		}
		else
		{   memcpy(locptr, rawbuf, eol_off);
		    recsize = loccnt + eol_off;
		    locptr += eol_off;
		    loccnt += eol_off;
		    end = eol_off + eol_len;
		    complete = 1;
		}
	    }
	}

	if( complete )
	{   if (WriteRecord(locbuf, recsize))
		return PK_DISK;
	    loccnt = 0;
	    locptr = locbuf;
	}
    }				/* end if( loccnt ) */

    for(start = end; start < size && end < size; )
    {	int eol_off,eol_len;

	got_eol = 0;

#ifdef undef
        if (cflag)
	    /* skip CR's at the beginning of record */
            while (start < size && rawbuf[start] == CR)
                ++start;
#endif

	if( start >= size )
	    continue;

	/* Find record end */
	end = start+(eol_off = find_eol(rawbuf+start, size-start, &eol_len));

    	if( end >= size )
	    continue;

	if( eol_len > 0 )
	{   if( WriteRecord(rawbuf+start, end-start) )
		return PK_DISK;
	    start = end + eol_len;
	}
	else
	{   got_eol = rawbuf[end];
	    end = size;
	    continue;
	}
    }

    rest = size - start;

    if (rest > 0)
    {	if( rest > BUFS512 )
	{   int	recsize;

	    recsize = rest - (got_eol ? 1:0 );
	    fprintf(stderr, "[ Warning: Record too long (%d) ]\n", recsize);
	    got_eol = 0;
	    return WriteRecord(rawbuf+start,recsize) ? PK_DISK : PK_COOL;
	}
	else
	{   memcpy(locptr, rawbuf + start, rest);
	    locptr += rest;
	    loccnt += rest;
	}
    }
    return PK_COOL;
}



static int WriteBuffer(buf, len)
    unsigned char *buf;
    int len;
{
    int status;

    status = sys$wait(outrab);
    if (ERR(status))
    {
	message("[ WriteBuffer failed ]\n", status);
	message("", outrab->rab$l_stv);
    }
    outrab->rab$w_rsz = len;
    outrab->rab$l_rbf = buf;

    if (ERR(status = sys$write(outrab)))
    {
	message("[ WriteBuffer failed ]\n", status);
	message("", outrab->rab$l_stv);
	return PK_DISK;
    }
    return PK_COOL;
}



static int WriteRecord(rec, len)
    unsigned char *rec;
    int len;
{
    int status;

    if (ERR(status = sys$wait(outrab)))
    {
	message("[ WriteRecord failed ]\n", status);
	message("", outrab->rab$l_stv);
    }
    outrab->rab$w_rsz = len;
    outrab->rab$l_rbf = rec;

    if (ERR(status = sys$put(outrab)))
    {
	message("[ WriteRecord failed ]\n", status);
	message("", outrab->rab$l_stv);
	return PK_DISK;
    }
    return PK_COOL;
}



void close_outfile()
{
    int status;

    status = (*_flush_routine)(0, 0, 1);     
    if (status)
        return /* PK_DISK */;
    if (cflag)
        return;         /* Don't close stdout */
    /* return */ (*_close_routine)();
}



static int _close_rms()
{
    int status;
    struct XABPRO pro;

    /* Link XABRDT,XABDAT and optionaly XABPRO */
    if (xabrdt != 0L)
    {
	xabrdt->xab$l_nxt = 0L;
	outfab->fab$l_xab = xabrdt;
    }
    else
    {
	rdt.xab$l_nxt = 0L;
	outfab->fab$l_xab = &rdt;
    }
    if (xabdat != 0L)
    {
	xabdat->xab$l_nxt = outfab->fab$l_xab;
	outfab->fab$l_xab = xabdat;
    }

    if( xabpro != 0L )
    {
	if( !secinf )
	    xabpro->xab$l_uic = 0;    /* Use default (user's) uic */
	xabpro->xab$l_nxt = outfab->fab$l_xab;
	outfab->fab$l_xab = xabpro;
    }
    else
    {	pro = cc$rms_xabpro;
	pro.xab$w_pro = pInfo->file_attr;
	pro.xab$l_nxt = outfab->fab$l_xab;
	outfab->fab$l_xab = &pro;
    }

    sys$wait(outrab);

    status = sys$close(outfab);
#ifdef DEBUG
    if (ERR(status))
    {
	message("\r[ Warning: cannot set owner/protection/time attributes ]\n",
	  status);
	message("", outfab->fab$l_stv);
    }
#endif
    free_up();
    return PK_COOL;
}



static int _close_qio()
{   int status;

    pka_fib.FIB$L_ACCTL =
	FIB$M_WRITE | FIB$M_NOTRUNC ;
    pka_fib.FIB$W_EXCTL = 0;

    pka_fib.FIB$W_FID[0] =
    pka_fib.FIB$W_FID[1] =
    pka_fib.FIB$W_FID[2] =
    pka_fib.FIB$W_DID[0] =
    pka_fib.FIB$W_DID[1] =
    pka_fib.FIB$W_DID[2] = 0;

    status = sys$qiow(0, pka_devchn, IO$_DEACCESS, &pka_acp_sb,
	    0, 0,
	    &pka_fibdsc, 0, 0, 0,
	    &pka_atr, 0);

    sys$dassgn(pka_devchn);
    if( !ERR(status) )
	status = pka_acp_sb.status;
    if( ERR(status) )
    {	message("[ Deaccess QIO failed ]\n",status);
	return PK_DISK;
    }
    return PK_COOL;
}



#ifdef DEBUG
dump_rms_block(p)
    unsigned char *p;
{
    unsigned char bid, len;
    int err;
    char *type;
    char buf[132];
    int i;

    err = 0;
    bid = p[0];
    len = p[1];
    switch (bid)
    {
	case FAB$C_BID:
	    type = "FAB";
	    break;
	case XAB$C_ALL:
	    type = "xabALL";
	    break;
	case XAB$C_KEY:
	    type = "xabKEY";
	    break;
	case XAB$C_DAT:
	    type = "xabDAT";
	    break;
	case XAB$C_RDT:
	    type = "xabRDT";
	    break;
	case XAB$C_FHC:
	    type = "xabFHC";
	    break;
	case XAB$C_PRO:
	    type = "xabPRO";
	    break;
	default:
	    type = "Unknown";
	    err = 1;
	    break;
    }
    printf("Block @%08X of type %s (%d).", p, type, bid);
    if (err)
    {
	printf("\n");
	return;
    }
    printf(" Size = %d\n", len);
    printf(" Offset - Hex - Dec\n");
    for (i = 0; i < len; i += 8)
    {
	int j;

	printf("%3d - ", i);
	for (j = 0; j < 8; j++)
	    if (i + j < len)
		printf("%02X ", p[i + j]);
	    else
		printf("   ");
	printf(" - ");
	for (j = 0; j < 8; j++)
	    if (i + j < len)
		printf("%03d ", p[i + j]);
	    else
		printf("    ");
	printf("\n");
    }
}

#endif				/* DEBUG */



static void message(string, status)
    int status;
char *string;
{
    char msgbuf[256];

    $DESCRIPTOR(msgd, msgbuf);
    int msglen = 0;

    if (ERR(lib$sys_getmsg(&status, &msglen, &msgd, 0, 0)))
	fprintf(stderr, "%s[ VMS status = %d ]\n", string, status);
    else
    {
	msgbuf[msglen] = 0;
	fprintf(stderr, "%s[ %s ]\n", string, msgbuf);
    }
}



#ifndef SFX

char *do_wild( wld )
    char *wld;
{
    int	status;

    static	char	filename[256];
    static	char	efn[256];
    static	char	last_wild[256];
    static	struct	FAB fab;
    static	struct	NAM nam;
    static	int	first_call=1;
    static	char	deflt[] = "*.zip";
    static	int	use_default = 1;

    if( first_call || strcmp(wld, last_wild) )
    {	/* (Re)Initialize everything */

	strcpy( last_wild, wld );
	first_call = 1;			/* New wild spec */

	fab = cc$rms_fab;
	fab.fab$l_fna = last_wild;
	fab.fab$b_fns = strlen(last_wild);
	fab.fab$l_nam = &nam;
	nam = cc$rms_nam;
	nam.nam$l_esa = efn;
	nam.nam$b_ess = sizeof(efn)-1;
	nam.nam$l_rsa = filename;
	nam.nam$b_rss = sizeof(filename)-1;

	if(!OK(sys$parse(&fab)))
	    return 0L;	/* Initialization failed */

	first_call = 0;
	use_default = 1;
    }

    if( !OK(sys$search(&fab)) )
    {
	if( !fab.fab$l_dna && use_default )
	{
		first_call = 1;	/* Try to use default file type ".zip"	*/

		fab = cc$rms_fab;
		fab.fab$l_fna = last_wild;
		fab.fab$b_fns = strlen(last_wild);
		fab.fab$l_nam = &nam;
		fab.fab$l_dna = deflt;
		fab.fab$b_dns = strlen(deflt);
		nam = cc$rms_nam;
		nam.nam$l_esa = efn;
		nam.nam$b_ess = sizeof(efn)-1;
		nam.nam$l_rsa = filename;
		nam.nam$b_rss = sizeof(filename)-1;

		if(!OK(sys$parse(&fab)))
			return 0L;
		if( !OK(sys$search(&fab)) )
			return 0L;
		first_call = 0;
	}
	else
	{	first_call = 1;	/* Reinitialize next time */
		return 0L;
	}
    }
    use_default = 0;	/* Do not append ".zip" next time since at least
			   one file is found. */
    filename[nam.nam$b_rsl] = 0;
    return filename;
}

#endif /* !SFX */



static ulg unix_to_vms[8]={ /* Map from UNIX rwx to VMS rwed */
			    /* Note that unix w bit is mapped to VMS wd bits */
    XAB$M_NOREAD | XAB$M_NOWRITE | XAB$M_NODEL | XAB$M_NOEXE,    /* --- no access*/
    XAB$M_NOREAD | XAB$M_NOWRITE | XAB$M_NODEL,                  /* --x */
    XAB$M_NOREAD |                               XAB$M_NOEXE,    /* -w- */
    XAB$M_NOREAD,                                                /* -wx */
                   XAB$M_NOWRITE | XAB$M_NODEL | XAB$M_NOEXE,    /* r-- */
                   XAB$M_NOWRITE | XAB$M_NODEL,                  /* r-x */
                                                 XAB$M_NOEXE,    /* rw- */
    0                                                            /* rwx full access*/
};

#define SETDFPROT   /* We are using undocumented VMS System Service	*/
		    /* SYS$SETDFPROT here. If your version of VMS does	*/
		    /* not have that service, undef SETDFPROT.		*/
		    /* IM: Maybe it's better to put this to Makefile	*/
		    /* and DESCRIP.MMS */



int mapattr()
{
    ulg  tmp=crec.external_file_attributes, theprot;
    static ulg  defprot = -1L,
		sysdef,owndef,grpdef,wlddef;  /* Default protection fields */


    /* IM: The only field of XABPRO we need to set here is */
    /*     file protection, so we need not to change type */
    /*     of pInfo->file_attr. WORD is quite enough. */

    if( defprot == -1L )
    {
	/*
	* First time here -- Get user default settings
	*/

#ifdef SETDFPROT    /* Undef this if linker cat't resolve SYS$SETDFPROT */
	defprot = 0L;
	if( !ERR(SYS$SETDFPROT(0,&defprot)) )
	{
	    sysdef = defprot & ( (1L<<XAB$S_SYS)-1 ) << XAB$V_SYS;
	    owndef = defprot & ( (1L<<XAB$S_OWN)-1 ) << XAB$V_OWN;
	    grpdef = defprot & ( (1L<<XAB$S_GRP)-1 ) << XAB$V_GRP;
	    wlddef = defprot & ( (1L<<XAB$S_WLD)-1 ) << XAB$V_WLD;
	}
	else
	{
#endif /* ?SETDFPROT */
	    umask(defprot = umask(0));
	    defprot = ~defprot;
	    wlddef = unix_to_vms[defprot & 07] << XAB$V_WLD;
	    grpdef = unix_to_vms[(defprot>>3) & 07] << XAB$V_GRP;
	    owndef = unix_to_vms[(defprot>>6) & 07] << XAB$V_OWN;
	    sysdef = owndef << (XAB$V_SYS - XAB$V_OWN);
	    defprot = sysdef | owndef | grpdef | wlddef;
#ifdef SETDFPROT
	}
#endif	/* ?SETDFPROT */
    }

    switch (pInfo->hostnum) {
        case UNIX_:
        case VMS_:  /*IM: ??? Does VMS Zip store protection in UNIX format ?*/
                    /* GRR:  Yup.  Bad decision on my part... */
            tmp = (unsigned)(tmp >> 16);  /* drwxrwxrwx */
	    theprot  = (unix_to_vms[tmp & 07] << XAB$V_WLD)
	             | (unix_to_vms[(tmp>>3) & 07] << XAB$V_GRP)
	             | (unix_to_vms[(tmp>>6) & 07] << XAB$V_OWN);

	    if( tmp & 0x4000 )
	    	/* Directory -- set D bits */
		theprot |= (XAB$M_NODEL << XAB$V_SYS)
			| (XAB$M_NODEL << XAB$V_OWN)
			| (XAB$M_NODEL << XAB$V_GRP)
			| (XAB$M_NODEL << XAB$V_WLD);
	    pInfo->file_attr = theprot;
	    break;

        case AMIGA_:
            tmp = (unsigned)(tmp>>16 & 0x0f);   /* Amiga RWED bits */
            pInfo->file_attr = (tmp << XAB$V_OWN) | grpdef | sysdef | wlddef;
            break;

        /* all remaining cases:  expand MSDOS read-only bit into write perms */
        case FS_FAT_:
        case FS_HPFS_:
        case FS_NTFS_:
        case MAC_:
        case ATARI_:             /* (used to set = 0666) */
        case TOPS20_:
        default:
	    theprot = defprot;
	    if( tmp & 1 )   /* Test read-only bit */
	    {	/* Bit is set -- set bits in all fields */
		tmp = XAB$M_NOWRITE | XAB$M_NODEL;
		theprot |= (tmp << XAB$V_SYS) | (tmp << XAB$V_OWN) |
			   (tmp << XAB$V_GRP) | (tmp << XAB$V_WLD);
	    }
            pInfo->file_attr = theprot;
            break;
    } /* end switch (host-OS-created-by) */

    return 0;

} /* end function mapattr() */



#ifndef	EEXIST
#  include <errno.h>	/* For mkdir() status codes */
#endif

#include <fscndef.h> /* for filescan */

#   define FN_MASK   7
#   define USE_DEFAULT	(FN_MASK+1)

/*
 * Checkdir function codes:
 *	ROOT	    -   set root path from unzip qq d:[dir]
 *	INIT	    -   get ready for "filename"
 *	APPEND_DIR  -	append pathcomp
 *	APPEND_NAME -	append filename
 *	APPEND_NAME | USE_DEFAULT   -	expand filename using collected path
 *	GETPATH     -	return resulting filespec
 */

static	int created_dir;

int mapname(renamed)  /* return 0 if no error, 1 if caution (filename trunc),*/
    int renamed;      /* 2 if warning (skip file because dir doesn't exist), */
{                     /* 3 if error (skip file), 10 if no memory (skip file) */
    char pathcomp[FILNAMSIZ];   /* path-component buffer */
    char *pp, *cp=NULL;         /* character pointers */
    char *lastsemi = NULL;      /* pointer to last semi-colon in pathcomp */
    char *last_dot = NULL;      /* last dot not converted to underscore */
    int quote = FALSE;          /* flag:  next char is literal */
    int dotname = FALSE;        /* flag:  path component begins with dot */
    int error = 0;
    register unsigned workch;   /* hold the character being tested */

    if( renamed )
    {
            if( !(error = checkdir(pathcomp, APPEND_NAME | USE_DEFAULT)) )
            strcpy(filename, pathcomp);
        return error;
    }
        
/*---------------------------------------------------------------------------
    Initialize various pointers and counters and stuff.
  ---------------------------------------------------------------------------*/

    /* can create path as long as not just freshening, or if user told us */
    create_dirs = !fflag;

    created_dir = FALSE;        /* not yet */

/* GRR:  for VMS, convert to internal format now or later? or never? */
    if (checkdir(pathcomp, INIT) == 10)
        return 10;              /* initialize path buffer, unless no memory */

    *pathcomp = '\0';           /* initialize translation buffer */
    pp = pathcomp;              /* point to translation buffer */
    if (jflag)              /* junking directories */
/* GRR:  watch out for VMS version... */
        cp = (char *)strrchr(filename, '/');
    if (cp == NULL)             /* no '/' or not junking dirs */
        cp = filename;          /* point to internal zipfile-member pathname */
    else
        ++cp;                   /* point to start of last component of path */

/*---------------------------------------------------------------------------
    Begin main loop through characters in filename.
  ---------------------------------------------------------------------------*/

    while ((workch = (uch)*cp++) != 0) {

        if (quote) {              /* if character quoted, */
            *pp++ = (char)workch; /*  include it literally */
            quote = FALSE;
        } else
            switch (workch) {
            case '/':             /* can assume -j flag not given */
                *pp = '\0';
                if (last_dot) {   /* one dot in directory name is legal */
                    *last_dot = '.';
                    last_dot = NULL;
                }
                if ((error = checkdir(pathcomp, APPEND_DIR)) > 1)
                    return error;
                pp = pathcomp;    /* reset conversion buffer for next piece */
                lastsemi = NULL;  /* leave directory semi-colons alone */
                break;

            case ':':
                *pp++ = '_';      /* drive names not stored in zipfile, */
                break;            /*  so no colons allowed */

            case '.':
                if (pp == pathcomp) {     /* nothing appended yet... */
                    if (*cp == '/') {     /* don't bother appending a "./" */
                        ++cp;             /*  component to the path:  skip */
                        break;            /*  to next char after the '/' */
                    } else if (*cp == '.' && cp[1] == '/') {   /* "../" */
                        *pp++ = '.';      /* add first dot, unchanged... */
                        ++cp;             /* skip second dot, since it will */
                    }                     /*  added next (as '_' for now) */
                }
                last_dot = pp;    /* point at last dot so far... */
                *pp++ = '_';      /* convert dot to underscore for now */
                break;

            case ';':             /* start of VMS version? */
                if (lastsemi)
                    *lastsemi = '_';   /* convert previous one to underscore */
                lastsemi = pp;
                *pp++ = ';';      /* keep for now; remove VMS vers. later */
                break;

            case ' ':
                *pp++ = '_';
                break;

            default:
                if( isalpha(workch) || isdigit(workch) ||
                    workch=='$' || workch=='-' )
                    *pp++ = (char)workch;
                else
                    *pp++ = '_';  /* convert everything else to underscore */
                break;
            } /* end switch */

    } /* end while loop */

    *pp = '\0';                   /* done with pathcomp:  terminate it */

    /* if not saving them, remove VMS version numbers (appended "###") */
    if (lastsemi) {
        pp = lastsemi + 1;        /* expect all digits after semi-colon */
        while (isdigit((uch)(*pp)))
            ++pp;
        if (*pp)                  /* not version number:  convert ';' to '_' */
            *lastsemi = '_';
        else if (!V_flag)         /* only digits between ';' and end:  nuke */
            *lastsemi = '\0';
        /* else only digits and we're saving version number:  do nothing */
    }

    if (last_dot != NULL)         /* one dot is OK:  put it back in */
        *last_dot = '.';          /* (already done for directories) */

/*---------------------------------------------------------------------------
    Report if directory was created (and no file to create:  filename ended
    in '/'), check name to be sure it exists, and combine path and name be-
    fore exiting.
  ---------------------------------------------------------------------------*/

    if (filename[strlen(filename) - 1] == '/') {
        checkdir("", APPEND_NAME);   /* create directory, if not found */
        checkdir(filename, GETPATH);
        if (created_dir && QCOND2) {
            fprintf(stdout, "   creating: %s\n", filename);
            return IZ_CREATED_DIR;   /* set dir time (note trailing '/') */
        }
        return 2;   /* dir existed already; don't look for data to extract */
    }

    if (*pathcomp == '\0') {
        fprintf(stderr, "mapname:  conversion of %s failed\n", filename);
        return 3;
    }

    checkdir(pathcomp, APPEND_NAME);   /* returns 1 if truncated:  care? */
    checkdir(filename, GETPATH);

    return error;

} /* end function mapname() */



int checkdir(pathcomp,fcn)
/*
 * returns:  1 - (on APPEND_NAME) truncated filename
 *           2 - path doesn't exist, not allowed to create
 *           3 - path doesn't exist, tried to create and failed; or
 *               path exists and is not a directory, but is supposed to be
 *           4 - path is too long
 *          10 - can't allocate memory for filename buffers
 */
    char *pathcomp;
    int fcn;
{
    int function=fcn & FN_MASK;
    static char pathbuf[FILNAMSIZ];
    static char lastdir[FILNAMSIZ]="\t"; /* directory created last time */
				         /* initially - impossible dir. spec. */
    static char *pathptr=pathbuf;        /* For debugger */
    static char *devptr, *dirptr, *namptr;
    static int  devlen, dirlen, namlen;
    static int  root_dirlen;
    static char *end;
    static int  first_comp,root_has_dir;
    static int  rootlen=0;
    static char *rootend;
    static int  mkdir_failed=0;
    int status;

/************
 *** ROOT ***
 ************/

    if(function==ROOT)
    {        /*  Assume VMS root spec */
        char  *p = pathcomp;
        char  *q;

        struct
        {   short  len;
            short  code;
            char   *addr;
        } itl [4] =
        {
            {  0,  FSCN$_DEVICE,    0  },
            {  0,  FSCN$_ROOT,      0  },
            {  0,  FSCN$_DIRECTORY, 0  },
            {  0,  0,               0  }   /* End of itemlist */
        };
        int fields = 0;
        struct dsc$descriptor  pthcmp;

        /*
         *  Initialize everything
         */
        end = devptr = dirptr = rootend = pathbuf;
        devlen = dirlen = rootlen = 0;

        pthcmp.dsc$a_pointer = pathcomp;
        if( (pthcmp.dsc$w_length = strlen(pathcomp)) > 255 )
            return 4;

        status = sys$filescan(&pthcmp, itl, &fields);
        if( !OK(status) )
            return 3;

        if( fields & FSCN$M_DEVICE )
        {   strncpy(devptr = end, itl[0].addr, itl[0].len);
            dirptr = (end += (devlen = itl[0].len));
        }

        root_has_dir = 0;

        if( fields & FSCN$M_ROOT )
        {   int   len;

            strncpy(dirptr = end, itl[1].addr,
                len = itl[1].len - 1);        /* Cut out trailing ']' */
            end += len;
            root_has_dir = 1;
        }

        if( fields & FSCN$M_DIRECTORY )
        {   char  *ptr;
            int   len;

            len = itl[2].len-1;
            ptr = itl[2].addr;

            if( root_has_dir /* i.e. root specified */ )
            {   --len;                            /* Cut out leading dot */
                ++ptr;                            /* ??? [a.b.c.][.d.e] */
            }

            strncpy(dirptr=end, ptr, len);  /* Replace trailing ']' */
            *(end+=len) = '.';                    /* ... with dot */
            ++end;
            root_has_dir = 1;
        }

        /* When user specified "[a.b.c.]" or "[qq...]", we have too many
        *  trailing dots. Let's cut them out. Now we surely have at least
        *  one trailing dot and "end" points just behind it. */

        dirlen = end - dirptr;
        while( dirlen > 1 && end[-2] == '.' )
            --dirlen,--end;

        first_comp = !root_has_dir;
        root_dirlen = end - dirptr;
        *(rootend = end) = 0;
        rootlen = rootend - devptr;
        return 0;
    }


/************
 *** INIT ***
 ************/

    if( function == INIT )
    {
        if( strlen(filename) + rootlen + 13 > 255 )
            return 4;

	if( rootlen == 0 )	/* No root given, reset everything. */
	{   devptr = dirptr = rootend = pathbuf;
	    devlen = dirlen = 0;
	}
        end = rootend;
        first_comp = !root_has_dir;
        if( dirlen = root_dirlen )
	    end[-1] = '.';
	*end = 0;
        return        0;
    }


/******************
 *** APPEND_DIR ***
 ******************/
    if( function == APPEND_DIR )
    {        int cmplen;

	cmplen = strlen(pathcomp);

        if( first_comp )
        {   *end++ = '[';
	    if( cmplen )
		*end++ = '.';	/*       "dir/..." --> "[.dir...]"    */
	    /*                     else  "/dir..." --> "[dir...]"     */
	    first_comp = 0;
	}		

	if( cmplen == 1 && *pathcomp == '.' )
            ; /* "..././..." -- ignore */

        else if( cmplen == 2 && pathcomp[0] == '.' && pathcomp[1] == '.' )
        {   /* ".../../..." -- convert to "...-..." */
            *end++ = '-';
            *end++ = '.';
        }

        else if( cmplen + (end-pathptr) > 255 )
            return 4;

        else
        {   strcpy(end, pathcomp);
            *(end+=cmplen) = '.';
            ++end;
        }
        dirlen = end - dirptr;
        *end = 0;
        return        0;
    }


/*******************
 *** APPEND_NAME ***
 *******************/
    if( function == APPEND_NAME )
    {        if( fcn & USE_DEFAULT )
        {   /* Expand renamed filename using collected path, return
            *  at pathcomp */
            struct        FAB fab;
            struct        NAM nam;

            fab = cc$rms_fab;
            fab.fab$l_fna = filename;
            fab.fab$b_fns = strlen(filename);
            fab.fab$l_dna = pathptr;
            fab.fab$b_dns = end-pathptr;

            fab.fab$l_nam = &nam;
            nam = cc$rms_nam;
            nam.nam$l_esa = pathcomp;
            nam.nam$b_ess = 255;            /* Assume large enaugh */

            if(!OK(status = sys$parse(&fab)) && status == RMS$_DNF )    /* Directory not found: */
            {   char    save;            /* ... try to create it */
                char    *dirend;
                int     mkdir_failed;

                dirend = (char*)nam.nam$l_dir + nam.nam$b_dir;
                save = *dirend;
                *dirend = 0;
                if( (mkdir_failed = mkdir(nam.nam$l_dev)) && errno == EEXIST )
                    mkdir_failed = 0;
                *dirend = save;
                if( mkdir_failed )
                    return 3;
                created_dir = TRUE;
            }                                /* if (sys$parse... */
            pathcomp[nam.nam$b_esl] = 0;
            return 0;
        }                                /* if (USE_DEFAULT) */
        else
        {
	    *end = 0;
            if( dirlen )
            {	dirptr[dirlen-1] = ']'; /* Close directory */

		/*
		 *	Try to create the target directory.
		 *  Don't waste time creating directory that was created
		 *	last time.
		 */
		if( STRICMP(lastdir,pathbuf) )
		{
		    mkdir_failed = 0;
		    if( mkdir(pathbuf,0) )
		    {   if( errno != EEXIST )
			    mkdir_failed = 1;   /* Mine for GETPATH */
		    }
		    else
			created_dir = TRUE;
		    strcpy(lastdir,pathbuf);
		}
	    }
	    else
	    {	/*
		 * Target directory unspecified.
		 * Try to create "sys$disk:[]"
		 */
		if( strcmp(lastdir,"sys$disk:[]") )
		{   strcpy(lastdir,"sys$disk:[]");
		    mkdir_failed = 0;
		    if( mkdir(lastdir,0) && errno != EEXIST )
			mkdir_failed = 1;   /* Mine for GETPATH */
		}		
	    }
            if( strlen(pathcomp) + (end-pathbuf) > 255 )
                return 1;
            strcpy(end, pathcomp);
            end += strlen(pathcomp);
            return 0;
        }
    }


/***************
 *** GETPATH ***
 ***************/
    if( function == GETPATH )
    {
        if( mkdir_failed )
            return 3;
        *end = 0;                        /* To be safe */
        strcpy( pathcomp, pathbuf );
        return 0;
    }
}



int check_for_newer(filename)   /* return 1 if existing file newer or equal; */
    char *filename;             /*  0 if older; -1 if doesn't exist yet */
{
    unsigned short timbuf[7];
    int dy, mo, yr, hh, mm, ss, dy2, mo2, yr2, hh2, mm2, ss2;
    struct FAB fab;
    struct XABDAT xdat;


    if (stat(filename, &statbuf))
        return DOES_NOT_EXIST;

    fab  = cc$rms_fab;
    xdat = cc$rms_xabdat;

    fab.fab$l_xab = (char *) &xdat;
    fab.fab$l_fna = filename;
    fab.fab$b_fns = strlen(filename);
    fab.fab$l_fop = FAB$M_GET | FAB$M_UFO;

    if ((sys$open(&fab) & 1) == 0)       /* open failure:  report exists and */
        return EXISTS_AND_OLDER;         /*  older so new copy will be made  */
    sys$numtim(&timbuf,&xdat.xab$q_cdt);
    fab.fab$l_xab = 0L;

    sys$dassgn(fab.fab$l_stv);
    sys$close(&fab);   /* be sure file is closed and RMS knows about it */

    yr = timbuf[0];
    yr2 = ((lrec.last_mod_file_date >> 9) & 0x7f) + 1980;
    if (yr > yr2)
        return EXISTS_AND_NEWER;
    else if (yr < yr2)
        return EXISTS_AND_OLDER;

    mo = timbuf[1];
    mo2 = ((lrec.last_mod_file_date >> 5) & 0x0f);
    if (mo > mo2)
        return EXISTS_AND_NEWER;
    else if (mo < mo2)
        return EXISTS_AND_OLDER;

    dy = timbuf[2];
    dy2 = (lrec.last_mod_file_date & 0x1f);
    if (dy > dy2)
        return EXISTS_AND_NEWER;
    else if (dy < dy2)
        return EXISTS_AND_OLDER;

    hh = timbuf[3];
    hh2 = (lrec.last_mod_file_time >> 11) & 0x1f;
    if (hh > hh2)
        return EXISTS_AND_NEWER;
    else if (hh < hh2)
        return EXISTS_AND_OLDER;

    mm = timbuf[4];
    mm2 = (lrec.last_mod_file_time >> 5) & 0x3f;
    if (mm > mm2)
        return EXISTS_AND_NEWER;
    else if (mm < mm2)
        return EXISTS_AND_OLDER;

    /* round to nearest 2 secs--may become 60, but doesn't matter for compare */
    ss = (int)((float)timbuf[5] + (float)timbuf[6]*.01 + 1.) & -2;
    ss2 = (lrec.last_mod_file_time & 0x1f) * 2;
    if (ss >= ss2)
        return EXISTS_AND_NEWER;

    return EXISTS_AND_OLDER;
}



void return_VMS(zip_error)
    int zip_error;
{
#ifdef RETURN_CODES
/*---------------------------------------------------------------------------
    Do our own, explicit processing of error codes and print message, since
    VMS misinterprets return codes as rather obnoxious system errors ("access
    violation," for example).
  ---------------------------------------------------------------------------*/

    switch (zip_error) {

    case PK_COOL:
        break;   /* life is fine... */
    case PK_WARN:
        fprintf(stderr, "\n[return-code 1:  warning error \
(e.g., failed CRC or unknown compression method)]\n");
        break;
    case PK_ERR:
    case PK_BADERR:
        fprintf(stderr, "\n[return-code %d:  error in zipfile \
(e.g., can't find local file header sig)]\n",
                zip_error);
        break;
    case PK_MEM:
    case PK_MEM2:
    case PK_MEM3:
    case PK_MEM4:
    case PK_MEM5:
        fprintf(stderr, "\n[return-code %d:  insufficient memory]\n",
          zip_error);
        break;
    case PK_NOZIP:
        fprintf(stderr, "\n[return-code 9:  zipfile not found]\n");
        break;
    case PK_PARAM:   /* the one that gives "access violation," I think */
        fprintf(stderr, "\n[return-code 10:  bad or illegal parameters \
specified on command line]\n");
        break;
    case PK_FIND:
        fprintf(stderr,
          "\n[return-code 11:  no files found to extract/view/etc.]\n");
        break;
    case PK_DISK:
        fprintf(stderr,
  "\n[return-code 50:  disk full or other I/O error]\n");
        break;
    case PK_EOF:
        fprintf(stderr,
          "\n[return-code 51:  unexpected EOF in zipfile (i.e., truncated)]\n");
        break;
    default:
        fprintf(stderr, "\n[return-code %d:  unknown return-code (screw-up)]\n",
          zip_error);
        break;
    }
#endif /* RETURN_CODES */

/*---------------------------------------------------------------------------
    Return an intelligent status/severity level if RETURN_SEVERITY defined:

    $STATUS          $SEVERITY = $STATUS & 7
    31 .. 16 15 .. 3   2 1 0
                       -----
    VMS                0 0 0  0    Warning
    FACILITY           0 0 1  1    Success
    Number             0 1 0  2    Error
             MESSAGE   0 1 1  3    Information
             Number    1 0 0  4    Severe (fatal) error

    0x7FFF0000 was chosen (by experimentation) to be outside the range of
    VMS FACILITYs that have dedicated message numbers.  Hopefully this will
    always result in silent exits--it does on VMS 5.4.  Note that the C li-
    brary translates exit arguments of zero to a $STATUS value of 1 (i.e.,
    exit is both silent and has a $SEVERITY of "success").
  ---------------------------------------------------------------------------*/

#ifdef RETURN_SEVERITY
    exit(                                        /* $SEVERITY: */
         (zip_error == PK_COOL) ? 1 :            /*   success  */
         (zip_error == PK_WARN) ? 0x7FFF0001 :   /*   warning  */
         (0x7FFF0002 | (zip_error << 4))         /*   error    */
         );
#else
    exit(0);   /* everything okey-dokey as far as VMS concerned */
#endif

} /* end function return_VMS() */





#ifndef SFX

/************************/
/*  Function version()  */
/************************/

void version()
{
#ifdef VMS_VERSION
    char buf[40];
#endif

    printf(LoadFarString(CompiledWith),

#ifdef __GNUC__
      "gcc ", __VERSION__,
#else
#  if 0
      "cc ", (sprintf(buf, " version %d", _RELEASE), buf),
#  else
#  if defined(DECC) || defined(__DECC) || defined (__DECC__)
      "DEC C", "",
#  else
#  ifdef VAXC
      "VAX C", "",
#  else
      "unknown compiler", "",
#  endif
#  endif
#  endif
#endif

#ifdef VMS_VERSION
#  if defined(__alpha)
      "OpenVMS",   /* version has trailing spaces ("V6.1   "), so truncate: */
      (sprintf(buf, " (%.4s for Alpha)", VMS_VERSION), buf),
#  else /* VAX */
      (VMS_VERSION[1] >= '6')? "OpenVMS" : "VMS",
      (sprintf(buf, " (%.4s for VAX)", VMS_VERSION), buf),
#  endif
#else
      "VMS",
      "",
#endif /* ?VMS_VERSION */

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

} /* end function version() */

#endif /* !SFX */
#endif /* VMS */
