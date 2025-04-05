/*
 *      UniTerm demo program by Simon Poole 16.03.88
 *
 *      THIS IS REALLY JUST A QUICK HACK
 */

#include <stdio.h>
#include <ctype.h>
#include <osbind.h>
#include "uni.h"

#define E_PINVALID 1
#define E_PCORUP   2
#define E_FOPEN    3

#define TMP    "TMPDIR"
#define EDITOR "E:\\TEMPUS.PRG"

#define TRUE  1
#define FALSE 0

char *getenv();
UniStruct *atol();
void exec_editor();
char *get_tmp();
void usage();
void error();
void dump_clip();
void read_clip();
void dump_hist();

main(argc, argv)

int  argc;
char **argv;

{
        char clip_name[127],hist_name[127],tmpname[255];
        UniStruct  *UniParm;    
        int history,clip,i;

        /* less than one argument is no good */
        if (argc < 2) usage();

        /* init */
        history=clip=FALSE;

        /*******************************************************/
        /* Work thru commandline arguments                     */
        /*******************************************************/        
        for (i = 0;i < argc;i++) {
           if (*argv[i] == '-') {
              argv[i]++; /* strip off '-' */
              switch(*argv[i]++) {
                 case 'U' : if (*argv[i] == (char)0) {
                               if (i < argc) {
                                  i++;
                                  UniParm = atol(argv[i]);
                               }
                               else usage();
                            }
                            else UniParm = atol(argv[i]);
                            break;
                 case 'H' : history = TRUE;
                            break;
                 case 'C' : clip = TRUE;
                            break; 
                 default  : usage();
                            break;
              }
           }
        }
        if (!(history || clip)) usage();  /* we want to do something! */

        /* some probably useless checks */
        if (UniParm == 0) error(E_PINVALID);
        if (UniParm->PBLength < 50) error(E_PCORUP);

        /* assume everything is ok if we got this far */

        
        clip_name[0] = '\000';
        if (clip) {
           /* get name of tmp file  */
           strcpy(clip_name,get_tmp("C_XXXXXX"));
           /* dump the clipboard    */
           dump_clip(UniParm,clip_name);
        }

        hist_name[0] = '\000';
        if (history) {
           /* get name of tmp file  */
           strcpy(hist_name,get_tmp("H_XXXXXX"));
           /* dump the clipboard    */
           dump_hist(UniParm,hist_name);
        }

        /* startup the editor    */
        strcpy(tmpname,clip_name);
        strcat(tmpname," ");
        strcat(tmpname,hist_name); 
        exec_editor(tmpname);

        /***************************************************/
        /* remove the files and bye-bye                    */
        /***************************************************/
        if (history) unlink(hist_name);        
        if (clip) {
           /* read file back into clipboard */
           read_clip(UniParm,clip_name);
           unlink(clip_name);
        }
        exit(0);
}

/**********************************************************/
/* open the file for writing and dump the history to it   */
/**********************************************************/
void dump_hist(UniParm,tmpname)

char *tmpname;
UniStruct  *UniParm;

{
        FILE *fd;
        register long i;
        register char *Buf;     /* only needed for efficency */
        long top,bottom;

        if ((fd = fopen(tmpname,"w")) == (FILE *)NULL) error(E_FOPEN);
        Buf = UniParm->PBHistBuffer;
        top = *UniParm->PBHistPtrAdr - (long)Buf;
        bottom = *UniParm->PBHistBotAdr - (long)Buf;
        if (top >= bottom) 
           for (i=bottom;i < top;i++) putc(Buf[i],fd);
        else {
           for (i=bottom;i < UniParm->PBHistSize;i++) putc(Buf[i],fd);
           for (i=0;i < top;i++) putc(Buf[i],fd);
        }
        fclose(fd);
}

/**********************************************************/
/* open the file for writing and dump the clipboard to it */
/* map CR to \n                                           */
/**********************************************************/
void dump_clip(UniParm,tmpname)

char *tmpname;
UniStruct  *UniParm;

{
        FILE *fd;
        register long i;
        register char *ClipBuf,ch;
        ClipStruct *ClipRec;           /* only needed for efficency */

        if ((fd = fopen(tmpname,"w")) == (FILE *)NULL) error(E_FOPEN);
        ClipRec = UniParm->PBClipRecAdr;
        ClipBuf = ClipRec->ClipBuffer;
        for (i=0;i < ClipRec->ClipLen;i++) {
           ch = ClipBuf[i];
           if (ch=='\r') putc('\n',fd);
           else putc(ch,fd);
        }
        fclose(fd);
}

/****************************************************/
/* copy the file back into the clipboard            */
/* map \n to CR                                     */
/****************************************************/
void read_clip(UniParm,tmpname)

char *tmpname;
UniStruct  *UniParm;

{
        FILE *fd;
        register long i;
        register char *ClipBuf;
        ClipStruct *ClipRec;           /* only needed for efficency */

        if ((fd = fopen(tmpname,"r")) == (FILE *)NULL) error(E_FOPEN);
        ClipRec = UniParm->PBClipRecAdr;
        ClipBuf = ClipRec->ClipBuffer;
        if (fd != (FILE*)NULL) {
           for (i=0;(!feof(fd))&&(i<UniParm->PBClipSize);i++){
              ClipBuf[i]=getc(fd);
              if (ClipBuf[i] == '\n') ClipBuf[i] = '\r';
           }
           ClipRec->ClipLen = --i;
        }
        else error(E_FOPEN); 
        fclose(fd);
}

/********************************************************/
/* get a unique (hopefully) filename on tmp if possible */
/********************************************************/
char *get_tmp(fname)

char *fname;

{
        char *tmpdir,tmpname[255];

        mktemp(fname); /* get a temp name */
        if ((tmpdir = getenv(TMP)) != (char *)NULL) {
           strcpy(tmpname,tmpdir);
           strcat(tmpname,fname);
           return(tmpname);
        } 
        else return(fname);
}

/*****************************************************/
/* startup the editor with the file(s) as argument(s)*/
/*****************************************************/ 
void exec_editor(fname)

char *fname;

{
        char *editor,args[255];
        int  result;

        editor = EDITOR;
        /* args is a Pascal type string, copy fname in to it */
        args[0] = (char)strlen(fname);
        args[1] = '\000';
        strcat(args,fname);
        /* and exec the editor */
        result = Pexec(0,editor,args,0L);
        if (result) error(result);
}

/**************************************/
/* hey we've got a really stupid user */
/**************************************/
void usage()

{
   puts("Usage: unidemo.prg -H -C -U address");
   getchar(); 
   exit(0);
}

/**************************************/
/* something went really wrong        */
/**************************************/
void error(num)

int num;

{
   exit(num);
}
