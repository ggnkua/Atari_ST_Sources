/*****************************************************************************
 * GST2GNU - Convert DRI and GST object modules to GNU-style a.out modules.
 *
 *          Wherever the term GST appears herein, it means either DRI-format
 *          or GST-format object modules.  The only difference between the
 *          two is that DRI has 8-char symbols, GST allows 22-char symbols.
 *          We handle both types automatically.
 *
 *          GEMDOS file I/O and memory allocation is used, not because I
 *          have anything against runtime libraries so much as that it
 *          provides independence from size_t/int/long portability issues.
 *
 *          This file is self-contained; there are no other source modules
 *          or header files other than standard compiler headers.  It was
 *          written for HSC and syntax-checked during development with
 *          MSDOS Borland C++ 3.1, and thus should compile fine on most
 *          any compiler.
 *
 *          Don't let the appearance of the term 'GNU' fool you:  this is
 *          public domain software, free of any encumbrances whatsoever.
 *          There are no facist restrictions on copying or using this code
 *          in any way you see fit.
 *
 * 06/16/93 v1.0 (Ian Lepore)
 *          Created.
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <osbind.h>

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

#ifdef __BORLANDC__     /* %@#!^@%#$@# Borland compiler won't define    */
  #define __STDC__      /* __STDC__ unless you ask for Pure-ANSI mode.  */
#endif                  /* (And nothing works right in its Pure-ANSI.)  */

#define MAXERRORS 15    /* stop trying after seeing this many reloc errors */

/*----------------------------------------------------------------------------
 *  structures and constants used with a.out modules.
 *    cobbled together from the manpage for a.out on a Sun system,
 *    mainly by deleting massive amounts of unneeded (by me) stuff.
 *--------------------------------------------------------------------------*/

typedef struct {                /* a.out module file header... */
  unsigned long     a_info;     /* typical magic value identifies file */
  unsigned long     a_text;     /* length of text, in bytes */
  unsigned long     a_data;     /* length of data, in bytes */
  unsigned long     a_bss;      /* length of uninitialized data area in bytes */
  unsigned long     a_syms;     /* length of symbol table data in bytes */
  unsigned long     a_entry;    /* start address (unused in object modules) */
  unsigned long     a_trsize;   /* length of relocation info for text, in bytes */
  unsigned long     a_drsize;   /* length of relocation info for data, in bytes */
} EXEC;

#define A_OUT_MAGIC 0407        /* value of exec.a_info for object module */

typedef struct {                /* symbol for a.out file... */
  long              n_strx;
  unsigned char     n_type;
  char              n_other;
  short             n_desc;
  unsigned long     n_value;
} NLIST;

#define N_UNDF      0           /* symbol n_type flag values... */
#define N_EXT       1
#define N_ABS       2
#define N_TEXT      4
#define N_DATA      6
#define N_BSS       8
#define N_FN       15
#define N_COMM     18

typedef struct {                /* reloc directive for a.out file... */
  unsigned long     r_address;
  unsigned long     r_symboldat;
} RINFO;

#define RINFO_PCREL 0x80        /* values ORed into low byte of */
#define RINFO_LONG  0x40        /* rinfo.r_symboldat */
#define RINFO_WORD  0x20
#define RINFO_EXT   0x10

/*----------------------------------------------------------------------------
 * structures and constants used with GST modules.
 *--------------------------------------------------------------------------*/

typedef struct {                /* GST module file header... */
    short           magic;
    long            tsize;
    long            dsize;
    long            bsize;
    long            ssize;
    long            stksize;
    long            entry;
    short           rlbflg;
} GHEADER;

#define GMAGIC      0x601A

typedef struct {                /* symbol for GST file... */
    char            name[8];
    unsigned short  flags;
    long            value;
} GSYM;

#define GS_BSS         0x0100   /* GST symbol flags... */
#define GS_TXT         0x0200
#define GS_DAT         0x0400
#define GS_EXTERN      0x0800
#define GS_GLOBAL      0x2000
#define GS_EQUATED     0x4000
#define GS_DEFINED     0x8000
#define GS_EXTENDED    0x0048   /* name extension block follows sym in file */

#define GR_ABS         0        /* GST relocation word values... */
#define GR_DAT         1
#define GR_TXT         2
#define GR_BSS         3
#define GR_EXT         4
#define GR_UPPER       5
#define GR_PCREL       6
#define GR_FIRST       7

/*----------------------------------------------------------------------------
 * internal structures and data.
 *--------------------------------------------------------------------------*/

typedef struct {                    /* our internal-format symbol... */
    char            name[24];
    unsigned short  flags;
    long            value;
} SYM;

static GHEADER          inhdr;      /* GST module header */
static SYM              *symtab;    /* internal-format symbol table */
static unsigned short   *text;      /* GST module text segment contents */
static unsigned short   *data;      /* GST module data segment contents */
static unsigned short   *treloc;    /* GST module text relocation contents */
static unsigned short   *dreloc;    /* GST module data relocation contents */
static unsigned long    symcount;   /* number of symbols */
static unsigned long    trcount;    /* number of text segment relocs */
static unsigned long    drcount;    /* number of data segment relocs */
static unsigned long    strtaboff;  /* cumulative index into string table */
static unsigned short   errcount;   /* error counter */

/*----------------------------------------------------------------------------
 * prototypes.
 *--------------------------------------------------------------------------*/

#ifdef __STDC__
  void fatal(char *,...);
  void error(char *,...);
  void gfree(void *);
  void *emalloc(long);
  void load_gst_header(short);
  void load_gst_body(short);
  void load_gst_symbols(short);
  void load_gst_reloc(short);
  long preprocess_relocs(unsigned short *,unsigned short *,long);
  void load_gst_module(char *);
  void write_unix_header(short,long,long,long);
  void write_unix_body(short);
  void write_unix_reloc(short,unsigned short *,long);
  void write_unix_symbols(short);
  void write_unix_stringtable(short);
  void write_unix_module(char *);
  int main(int,char **);
#endif

/*----------------------------------------------------------------------------
 * service routines.
 *--------------------------------------------------------------------------*/

#ifdef __STDC__
  static void fatal(char *fmt, ...)
#else
  static void fatal(fmt)
    char *fmt;
#endif
/*****************************************************************************
 * whine and die.
 ****************************************************************************/
{
    va_list args;

    fputs("gst2gnu (fatal): ", stderr);
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
    fputc('\n', stderr);
    exit(1);
}

#ifdef __STDC__
  static void error(char *fmt, ...)
#else
  static void error(fmt)
    char *fmt;
#endif
/*****************************************************************************
 * whine without dying unless we've seen MAXERRORS errors already.
 ****************************************************************************/
{
    va_list args;

    fputs("gst2gnu (error): ", stderr);
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
    fputc('\n', stderr);

    ++errcount;

    if (errcount > MAXERRORS) {
        fatal("too many errors; aborting");
    }
}

static void gfree(block)
    void *block;
/*****************************************************************************
 * gentle-free; free the block if the pointer is non-NULL.
 ****************************************************************************/
{
    if (block) {
        Mfree(block);
    }
}

static void *emalloc(size)
    long size;
/*****************************************************************************
 * allocate a block; whine and die if it fails.
 ****************************************************************************/
{
    void *block;

    if (NULL == (block = (void*)Malloc(size))) {
        fatal("out of memory, asked for %ld bytes", size);
    }
    return block;
}

/*----------------------------------------------------------------------------
 * routines for reading GST modules.
 *--------------------------------------------------------------------------*/

static void load_gst_header(h)
    short h;
/*****************************************************************************
 * load the input module header; whine and die if not a GST module.
 ****************************************************************************/
{
    if (sizeof(GHEADER) != Fread(h, (long)sizeof(GHEADER), &inhdr)) {
        fatal("error reading file header");
    }

    if (inhdr.magic != GMAGIC) {
        fatal("bad magic in file header (not a GST object module)");
    }

}

static void load_gst_body(h)
    short h;
/*****************************************************************************
 * the the text and data segments (if present) from the input module.
 ****************************************************************************/
{
    if (inhdr.tsize != 0) {
        text = emalloc(inhdr.tsize);
        if (inhdr.tsize != Fread(h, inhdr.tsize, text)) {
            fatal("error reading text segment");
        }
    }

    if (inhdr.dsize != 0) {
        data = emalloc(inhdr.dsize);
        if (inhdr.dsize != Fread(h, inhdr.dsize, data)) {
            fatal("error reading data segment");
        }
    }
}

static void load_gst_symbols(h)
    short h;
/*****************************************************************************
 * load the symbols (if any) from the input module.
 * converts both DRI and GST symbols to our internal format as it loads them.
 ****************************************************************************/
{
    long    nsyms;
    SYM     *cursym;
    GSYM    gsym;

    symcount = 0;

    if (inhdr.ssize == 0) {
        return;
    }

    nsyms = inhdr.ssize / sizeof(GSYM);
    symtab = emalloc(nsyms * sizeof(SYM));

    cursym = symtab;
    while (nsyms) {
        if (sizeof(GSYM) != Fread(h, (long)sizeof(GSYM), &gsym)) {
            fatal("error reading symbol table");
        }
        --nsyms;
        cursym->flags = gsym.flags;
        cursym->value = gsym.value;
        strncpy(cursym->name, gsym.name, 8);
        cursym->name[8] = 0;
        if ((gsym.flags & GS_EXTENDED) == GS_EXTENDED) {
            if (sizeof(GSYM) != Fread(h, (long)sizeof(GSYM), &cursym->name[8])) {
                fatal("error reading symbol table");
            }
            --nsyms;
            cursym->name[22] = 0;
        }
        ++cursym;
        ++symcount;
    }
}

static void load_gst_reloc(h)
    short h;
/*****************************************************************************
 * load the text and/or data relocation words from the input module.
 ****************************************************************************/
{
    trcount = inhdr.tsize / 2;
    drcount = inhdr.dsize / 2;

    if (inhdr.tsize != 0) {
        treloc = emalloc(inhdr.tsize);
        if (inhdr.tsize != Fread(h, inhdr.tsize, treloc)) {
            fatal("error reading text-segment relocation info");
        }
    }

    if (inhdr.dsize != 0) {
        dreloc = emalloc(inhdr.dsize);
        if (inhdr.dsize != Fread(h, inhdr.dsize, dreloc)) {
            fatal("error reading data-segment relocation info");
        }
    }
}

static void load_gst_module(fname)
    char *fname;
/*****************************************************************************
 * open the input file; call the functions which load it; close it.
 ****************************************************************************/
{
    short   handle;

    if (0 > (handle = Fopen(fname, 0))) {
        fatal("can't open input file %s", fname);
    }

    load_gst_header(handle);
    load_gst_body(handle);
    load_gst_symbols(handle);
    load_gst_reloc(handle);

    Fclose(handle);

}

/*----------------------------------------------------------------------------
 * routines for converting/writing a.out modules.
 *--------------------------------------------------------------------------*/

static void write_unix_header(h, nsyms, ntrelocs, ndrelocs)
    short   h;
    long    nsyms;
    long    ntrelocs;
    long    ndrelocs;
/*****************************************************************************
 * fill in and write the a.out file header.
 ****************************************************************************/
{
    EXEC    outhdr;

    outhdr.a_info   = A_OUT_MAGIC;
    outhdr.a_text   = inhdr.tsize;
    outhdr.a_data   = inhdr.dsize;
    outhdr.a_bss    = inhdr.bsize;
    outhdr.a_syms   = nsyms    * sizeof(NLIST);
    outhdr.a_trsize = ntrelocs * sizeof(RINFO);
    outhdr.a_drsize = ndrelocs * sizeof(RINFO);
    outhdr.a_entry  = 0;

    if (sizeof(EXEC) != Fwrite(h, (long)sizeof(EXEC), &outhdr)) {
        fatal("error writing file header");
    }
}

static void write_unix_body(h)
    short h;
/*****************************************************************************
 * write the text and/or data segments.
 ****************************************************************************/
{
    if (inhdr.tsize != Fwrite(h, inhdr.tsize, text)) {
        fatal("error writing text segment");
    }

    if (inhdr.dsize != Fwrite(h, inhdr.dsize, data)) {
        fatal("error writing data segment");
    }
}

static long preprocess_relocs(seg, relocs, count)
    unsigned short  *seg;
    unsigned short  *relocs;
    long            count;
/*****************************************************************************
 * preprocess the GST reloc info before converting it to a.out format.
 * this is called twice; once for the text seg and again for the data seg.
 *
 * some magical stuff happens here...
 *
 * first, we validate the existing relocation info as we cruise through it.
 * this is mainly a debugging tool for me, in my work with other software
 * which emits object modules.  (I can run modules through this program to
 * validate them.)  But, it takes very little time to do since we have to
 * walk the relocation words anyway, and it might help catch odd situations
 * I didn't anticipate when the input module was created by non-HSC tools.
 *
 * in regards to conversion, we have to do some fixups in the text and data
 * segments before we can convert the relocs to a.out format.  For a
 * segment-relative fixup, a GST module contains a value in the data or
 * text segment and the reloc directs the linker to add the base address of
 * the appropriate segment at fixup time.  in an a.out module, the value in
 * the text or data segment is relative to the base of the text segment, and
 * the linker adds the base of the text segment at fixup time.  so, as we
 * encounter data- or bss-relative fixup directives, we have to patch the
 * value referred to in the text or data segment, to make it relative to
 * the start of the text segment instead of the start of the segment the
 * fixup refers to.
 *
 * and finally, not every GST reloc word turns into a corresponding
 * a.out reloc directive, so as we walk the GST words we count up the
 * ones that will result in an a.out reloc and return the total to the
 * caller; these counts eventually end up in the a.out file header.
 ****************************************************************************/
{
    int             is_long = FALSE;
    unsigned short  rval;
    long            *fixup;
    long            nrelocs = 0;

    for (; count--; ++seg, ++relocs) {
        rval = *relocs;
        switch (rval & 0x0007) {

          case GR_UPPER:
            if (is_long) {
                error("bad relocation - two longword markers in a row");
            }
            fixup   = (long *)seg;
            is_long = TRUE;
            break;

          case GR_ABS:
            /* this needs no checking */
            is_long = FALSE;
            break;

          case GR_PCREL:
            /* I don't know enough about this to handle it correctly */
            fatal("can't handle pc-relative relocation directives");
            break;

          case GR_FIRST:
            if (is_long) {
                error("bad relocation - 32-bit fixup of 16-bit instruction word");
            }
            is_long = FALSE;
            break;

          case GR_BSS:
            if (!is_long) {
               error("bad relocation - 16-bit bss-segment-relative fixup");
            }
            if (*fixup < 0 || *fixup > inhdr.bsize) {
                error("bad relocation - bss-relative fixup is outside bss segment");
            }
            *fixup += inhdr.tsize + inhdr.dsize;
            ++nrelocs;
            is_long = FALSE;
            break;

          case GR_DAT:
            if (!is_long) {
               error("bad relocation - 16-bit data-segment-relative fixup");
            }
            if (*fixup < 0 || *fixup > inhdr.dsize) {
                error("bad relocation - data-relative fixup is outside data segment");
            }
            *fixup += inhdr.tsize;
            ++nrelocs;
            is_long = FALSE;
            break;

          case GR_TXT:
            if (!is_long) {
               error("bad relocation - 16-bit text-segment-relative fixup");
            }
            if (*fixup < 0 || *fixup > inhdr.tsize) {
                error("bad relocation - text-relative fixup is outside data segment");
            }
            ++nrelocs;
            is_long = FALSE;
            break;

          case GR_EXT:
            if ((rval >> 3) >= symcount) {
                error("bad relocation - reference to symbol # %d; only %ld symbols in file",
                        (rval >> 3), symcount);
            }
            ++nrelocs;
            is_long = FALSE;
            break;
        }
        if ((rval & 0x0007) != GR_EXT && (rval >> 3) != 0) {
            error("bad relocation - symbol index found in non-symbol fixup command");
        }
    }
    return nrelocs;
}

static long write_unix_reloc(h, relocs, count)
    short           h;
    unsigned short *relocs;
    long            count;
/*****************************************************************************
 * write the a.out relocation directives.
 * this is called twice; once for the text seg and again for the data seg.
 ****************************************************************************/
{
    unsigned long   i;
    unsigned short  rval;
    unsigned long   symnum;
    RINFO           rinfo;
    unsigned short  symtyp = RINFO_WORD;
    unsigned long   nrelocs = 0;

    for (i = 0; i < count; ++i) {
        rval = *relocs++;
        switch (rval & 0x0007) {

          case GR_UPPER:
            symtyp = RINFO_LONG;    /* no output; just remember that the   */
            continue;               /* next reloc is a longword operation. */

          case GR_PCREL:            /* (pc-rel filtered out by preproc)     */
          case GR_ABS:
          case GR_FIRST:
            symtyp = RINFO_WORD;    /* no output; just reset to shortword   */
            continue;               /* operation and get next reloc.        */

          case GR_BSS:
            symnum = N_BSS;
            break;

          case GR_DAT:
            symnum = N_DATA;
            break;

          case GR_TXT:
            symnum = N_TEXT;
            break;

          case GR_EXT:
            symnum  = rval >> 3;
            symtyp |= RINFO_EXT;
            break;
        }
        rinfo.r_address   = (symtyp & RINFO_LONG) ? i*2 - 2 : i*2;
        rinfo.r_symboldat = (symnum << 8) | symtyp;
        if (sizeof(RINFO) != Fwrite(h, (long)sizeof(RINFO), &rinfo)) {
            fatal("error writing relocation info");
        }
        ++nrelocs;
        symtyp = RINFO_WORD;
    }
    return nrelocs;
}

static void write_unix_symbols(h)
    short h;
/*****************************************************************************
 * write the non-string part of the a.out symbol table.
 *
 * we keep track of offsets into the 'string table' part of the module as
 * we go, but we don't actually build up a string table in memory. we just
 * walk our internal symbol table, converting and dumping the non-string
 * parts of each symbol as we go.  symbols defined in the input module in
 * the data or bss segments have to be adjusted so that their values are
 * relative to the start of the text segment.  (really, one starts to wonder
 * why a.out files have any notion of segments at all. ::grin::)
 ****************************************************************************/
{
    unsigned long   i;
    NLIST           nlist;
    SYM             *cursym;

    strtaboff = 4;      /* string table offset starts at 4 */

    for (i = 0, cursym = symtab; i < symcount; ++i, ++cursym) {
        nlist.n_other = 0;
        nlist.n_desc  = 0;
        nlist.n_strx  = strtaboff;
        nlist.n_value = cursym->value;
        switch (cursym->flags & (GS_TXT|GS_DAT|GS_BSS|GS_EQUATED)) {
          default:
            nlist.n_type   = N_UNDF;
            break;
          case GS_EQUATED:
            nlist.n_type   = N_ABS;
            break;
          case GS_TXT:
            nlist.n_type   = N_TEXT;
            break;
          case GS_DAT:
            nlist.n_type   = N_DATA;
            nlist.n_value += inhdr.tsize;
            break;
          case GS_BSS:
            nlist.n_type   = N_BSS;
            nlist.n_value += inhdr.tsize + inhdr.dsize;
            break;
        }
        if (cursym->flags & (GS_EXTERN|GS_GLOBAL)) {
            nlist.n_type |= N_EXT;
        }
        if (sizeof(NLIST) != Fwrite(h, (long)sizeof(NLIST), &nlist)) {
            fatal("error writing symbol table");
        }
        strtaboff += strlen(cursym->name) + 1;
    }
}

static void write_unix_stringtable(h)
    short h;
/*****************************************************************************
 * write the a.out symbol string table.
 *
 * the first longword in the string table is the size of the string table,
 * including the longword size value itself.  since we didn't bother to
 * build an in-memory string table, we just walk our internal symbol table
 * again; this time dumping only the string part of each symbol.
 ****************************************************************************/
{
    unsigned long   i;
    unsigned long   len;
    SYM             *cursym;

    if (sizeof(strtaboff) != Fwrite(h, (long)sizeof(strtaboff), &strtaboff)) {
        fatal("error writing string table");
    }

    for (i = 0, cursym = symtab; i < symcount; ++i, ++cursym) {
        len = 1 + strlen(cursym->name);
        if (len != Fwrite(h, len, cursym->name)) {
            fatal("error writing string table");
        }
    }
}

static void write_unix_module(fname)
    char *fname;
/*****************************************************************************
 * open output file; call conversion/output routines; close file.
 ****************************************************************************/
{
    short   handle;
    long    ntrelocs;
    long    ndrelocs;

    ntrelocs = preprocess_relocs(text, treloc, trcount);
    ndrelocs = preprocess_relocs(data, dreloc, drcount);

    if (errcount != 0) {
        fatal("relocation errors encountered; aborting");
    }

    if (0 > (handle = Fcreate(fname, 0))) {
        fatal("can't create output file %s", fname);
    }

    write_unix_header(handle, symcount, ntrelocs, ndrelocs);
    write_unix_body(handle);

    if (ntrelocs != write_unix_reloc(handle, treloc, trcount)) {
        fatal("internal error - didn't write proper number of text relocs");
    }

    if (ndrelocs != write_unix_reloc(handle, dreloc, drcount)) {
        fatal("internal error - didn't write proper number of data relocs");
    }

    write_unix_symbols(handle);
    write_unix_stringtable(handle);

    if (0 != Fclose(handle)) {
        fatal("error close output file");
    }

    gfree(text);
    gfree(data);
    gfree(treloc);
    gfree(dreloc);
    gfree(symtab);
}

int main(argc, argv)
    int  argc;
    char **argv;
/*****************************************************************************
 * a typical simplistic main routine.
 ****************************************************************************/
{
    char *in_name;
    char *out_name;

    switch (argc) {
      default:
        fputs("usage: GST2GNU infile [outfile]\n"
              "       if outfile not specified, infile is overwritten.\n"
              "\n"
              "Converts a DRI or GST object module to an a.out module\n"
              "which can be used with the GNU LD linker and other tools.\n"
              , stderr);
        exit(1);
      case 2:
        in_name  = argv[1];
        out_name = argv[1];
        break;
      case 3:
        in_name  = argv[1];
        out_name = argv[2];
        break;
    }

    load_gst_module(in_name);
    write_unix_module(out_name);

    return 0;

}
