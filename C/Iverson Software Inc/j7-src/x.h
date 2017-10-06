/* ----------------------------------------------------------------------- */
/* J-Source Version 7 - COPYRIGHT 1993 Iverson Software Inc.               */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 7 license agreement:  You may use, copy, and           */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* Macros and Defined Constants for !:                                     */


#define XC(m,n)         (64*m+n)

#if (SYS & SYS_VAX)
#define FAPPEND         "a"
#define FREAD           "r"
#define FUPDATE         "r+"
#define FWRITE          "w"
#define SAPPEND         "a"     /* script output        */
#endif

#if (SYS & SYS_ARCHIMEDES)
#define FAPPEND         "ab"
#define FREAD           "rb"
#define FUPDATE         "r+b"
#define FWRITE          "wb"
#define SAPPEND         "a"
#endif

#define WREAD           1
#define WUPDATE         2
#define WWRITE          3

#ifndef FAPPEND
#define FAPPEND         "ab"
#define FREAD           "rb"
#define FUPDATE         "r+b"
#define FWRITE          "wb"
#define SAPPEND         "at"
#endif


#ifndef SEEK_SET
#define SEEK_SET        0
#endif
#ifndef SEEK_CUR
#define SEEK_CUR        1
#endif
#ifndef SEEK_END
#define SEEK_END        2
#endif

#ifndef L_tmpnam
#define L_tmpnam        59
#endif

extern A        arx();
extern A        boxq();
extern A        boxs();
extern A        copy1();
extern A        copy2();
extern A        dbnxt();
extern A        dbpop();
extern A        dbr();
extern A        dbret();
extern A        dbrun();
extern A        dbs();
extern A        dbss();
extern A        dbsq();
extern A        dispq();
extern A        disps();
extern A        dl();
extern A        drx();
extern A        evmq();
extern A        evms();
extern A        ex55();
extern A        ex56();
extern I        fsize();
extern A        fxx();
extern A        host();
extern A        hostne();
extern A        ir();
extern C        jc();
extern A        jfappend();
extern A        jfdir();
extern A        jferase();
extern FILE    *jfopen();
extern A        jfread();
extern A        jfsize();
extern A        jfwrite();
extern A        jiread();
extern A        jiwrite();
extern A        line1();
extern A        line2();
extern A        lrx();
extern A        ncx();
extern A        nl1();
extern A        nl2();
extern A        promptq();
extern A        prompts();
extern A        pcopy1();
extern A        pcopy2();
extern A        psave1();
extern A        psave2();
extern A        rd();
extern A        ri();
extern A        rlq();
extern A        rls();
extern A        save1();
extern A        save2();
extern A        script1();
extern A        script2();
extern A        sline1();
extern A        sline2();
extern A        sp();
extern A        spit();
extern A        sps();
extern A        srx();
extern A        sscript1();
extern A        sscript2();
extern A        stype();
extern D        tod();
extern A        trx();
extern A        ts();
extern A        tsit1();
extern A        tsit2();
extern A        tss();
extern A        wa();
extern A        wex();
extern A        wnc();
extern A        wnl();

#if (SYS & SYS_PC+SYS_PC386)
extern A        cgaq();
extern A        cgas();
extern A        colorq();
extern A        colors();
extern A        edit();
extern A        refresh();
#endif

#if (SYS & SYS_MACINTOSH)
extern A        fontq();
extern A        fonts();
extern A        prtscr();
extern void     setftype(A,OSType,OSType);
#endif

#if (SYS & SYS_PCWIN)
extern A        wd();
extern A        wdvedit();
#endif
