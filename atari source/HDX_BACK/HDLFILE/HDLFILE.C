#include "osbind.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "stat.h"
#include "hdl.h"


#define OK 		1
#define FALSE   -1
#define ERROR   -1
#define FTOF	1
#define FTOD	2
#define DTOD	3
#define DIRLEN  8
#define FILELEN 12

OBJECT 	*cpbox;			/* cp or rm or mv dialog box */
OBJECT 	*samename;		/* name conflict dialog box */
char 	*cntopen;		/* can't open file alert box */
char	*cntcrtdr;		/* can't create directory alert box */
char	*cntcrtfl;		/* can't create file alert box */
char	*cntdelf;		/* can't delete file alert box */
char	*cntdeld;		/* can't delete directory alert box */
char	*wrerror;		/* write file error alert box */
char	*rderror;		/* read file error alert box */
char	*nomemory;		/* not sufficient memory alert box */

int  srclen, dstlen;	/* the size of source and target buffer */
long numfiles = 0L;		/* the number of files show in the dialog box */
long numdirs = 0L;		/* the number of directories */
long tolsize = 0L;		/* the total size of all files in the path */
int  srcbuf, dstbuf;	/* the size of source and target buffer be define */
int	 editdir;			/* the flag for the user edit the name conflict */
char *fixsrc, *fixdst;	/* the source and target string pointer */
long _stksize = 25000;	/* resize the stack size */
char *getall = "*.*";
char *bckslsh = "\\\0";

/* AES (windows and messages) related variables */
int formw, formh, sx, sy, lx, ly;	/* dialogue box dimensions */
int hdesk, wdesk;					/* window X, Y, width, height */

char *filestr = "abcdefgh.abcb";	/* the buffer for the file */
char *cptitle = " COPY FILE(S) ";	/* the title for the cp dialog box */
char *mvtitle = " MOVE FILE(S) ";	/* the title for the mv dialog box */
char *rmtitle = "DELETE FILE(S)";	/* the title for the rm dialog box */


main(argc, argv) 

int argc;
char **argv;

{
	char *convert();
	char *src, *dst;
	long ndirs,nfiles,tsize;

	if(argc < 4)	{
		Cconws("Usage: hdlfile source destination code\r\n");
		Pterm0();
	}
	convert(&src, argv[1]);
	convert(&dst, argv[2]);
	dofiles(src, dst, atoi(argv[3]), &ndirs, &nfiles, &tsize);

}

char *
convert(ret, src)
char **ret;
char *src;
{
	char *tmp, *tmp1;

	tmp1 = (char *)Malloc((long)(sizeof(src)+10));
	strcpy(src, tmp1);
	tmp = tmp1;
	while(*tmp)	++tmp;
	if (*(tmp-1) == 'a')	{
		*(tmp-1) = '\0';
		strcat("*.*", tmp1);
	}
	*ret = tmp1;
}

d_next(s)
char **s;
{ 
	*s = fixdst;
	return (0); 
}

dofiles(s, d, code, ndirs, nfiles, tsize)

char *s, *d;
int code;
long *ndirs, *nfiles, *tsize;

{

	/* 
	extern int d_next();
	*/

	if (code == 3)	{	/* do for information use */
		count(s);
		*ndirs = numdirs;
		*nfiles = numfiles;
		*tsize = tolsize;
		return OK;
	}
	appl_init();
	if (!rsrc_load("HDL.RSC"))	{
		goto cleanup;
	}

	if (getalladdr() != OK)		{
		goto cleanup;
	}

	do	{
		count(s);
		if (!code)	{				/* do rm files and dirs */
			rmfile(getinfo(s, d, code));
		} else if (code == 1)	{	/* do cp files and dirs */
			cpfile(getinfo(s, d, code));
		} else 	{					/* do rm files and dirs */
			mvfile(getinfo(s, d, code));
		} 
	} while (d_next(&s));

cleanup:
	appl_exit();
	return OK;
}


/* do the rm file job */

rmfile(flag)
int flag;

{

	int ret;

	if (showbox(rmtitle) == CANCEL)		{
		goto endrm;
	}
	if (flag == FTOD) 	{ 	/* one file from dir rm */
		updatedir();
		updatefile();
	redel:
		if ((ret = Fdelete(fixsrc)))	{
			if ((ret == 0xFFFA) || (ret == 0xFFFE))	{ /* seek error or */
				Pterm(1);							  /* drive not ready */
			}
			if (err(cntdelf) == 2)	{	/* retry */
				goto redel;
			} else {					/* quit */
				goto endrm;
			}
		}
	} else {					/* rm dir or files */
		fixdst = fixsrc;
		dormfd();
	}

endrm:
	erasemsg();
	Mfree(fixsrc);
	Mfree(fixdst);
	return OK;
}


/* do the cp file job */

cpfile(flag)

int flag;

{

	if (showbox(cptitle) == CANCEL)		{
		goto endcp;
	}
	if (flag == DTOD) 	{	/* files and directories cp */
		docpfd();
	} else {				/* a file cp */
		updatedir();
		updatefile();
		wrfile(fixsrc, fixdst);
	}

endcp:
	erasemsg();
	Mfree(fixsrc);
	Mfree(fixdst);
	return OK;
}



/* do the mv file job */

mvfile(flag)
int flag;

{

	if (showbox(mvtitle) == CANCEL)		{
		goto endmv;
	}
	if (flag == DTOD)	{	/* files and directories mv */
		domvfd();
	} else {				/* a file mv */
		updatedir();
		updatefile();
		wrfile(fixsrc, fixdst);
	remvdel:
		if (Fdelete(fixsrc))	{
			if (err(cntdelf) == 2)	{	/* retry */
				goto remvdel;
			} else {					/* quit */
				goto endmv;
			}
		}
	}

endmv:
	erasemsg();
	Mfree(fixsrc);
	Mfree(fixdst);
	return OK;
}





/* recursively rm dir or files form a given path */

dormfd()

{
	char *saved;
	extern char *strcat();
	extern char *strcpy();
	DMABUFFER dumb;
	int ret;

	saved = (DMABUFFER *)Fgetdta();
	Fsetdta(&dumb);
	strcat(getall, fixsrc);
	if (!Fsfirst(fixsrc, 0xFF))	{
		do 	{
			if (dumb.d_fname[0] != '.')	{
				if (S_IFDIR & dumb.d_fattr)	{
					chksrcbuf(DIRLEN);		/* check buf size */
					addfile(fixsrc, dumb.d_fname);/* add a dir to the path */
					strcat(bckslsh, fixsrc);
					dormfd();				/* to the recursion */
					rmstarb(fixsrc);		/* rm the star and back slash */
					getlastpath(filestr, fixsrc); 
					unpack(filestr);
					strcpy(filestr,
							((TEDINFO *)(cpbox[CPDIR].ob_spec))->te_ptext); 
					strcpy("_", ((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext);
					objc_draw(cpbox, CPFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);
					objc_draw(cpbox, CPDIR, MAX_DEPTH, 0, 0, wdesk, hdesk);
					/* delete a dir from source */
				redeld:
					if (Ddelete(fixsrc))	{
						if ((ret = err(cntdeld)) == 2)	{ /* retry */
							goto redeld;
						} else if (ret == 3)	{ 		/* abort */
							Pterm(1);
						}
					}
					backdir(fixsrc);		/* back one dir */
					updatndir();
					srclen -= DIRLEN;		/* subtract the add lenth */

				} else {
					chksrcbuf(FILELEN);		/* check buf size */
					addfile(fixsrc, dumb.d_fname);
					updatedir();
					/* update the file box */
					unpack(dumb.d_fname); 
					strcpy(dumb.d_fname,
							((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext); 
					objc_draw(cpbox, CPFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);
				redelf:
					if ((ret = Fdelete(fixsrc)))	{
						if ((ret == 0xFFFA) || (ret == 0xFFFE))	{ 
							/* seek error or  drive not ready */
							Pterm(1);							  
						}
						if ((ret = err(cntdelf)) == 2)	{	/* retry */
							goto redelf;
						} else if (ret == 3)	{			/* abort */
							Pterm(1);
						}
					}
					updatnfile();
					backdir(fixsrc);
					srclen -= FILELEN;		/* subtract the add lenth */
				}
			} 
		} while (!Fsnext());
	} else {
		Pterm(1);
	}
	Fsetdta(saved);
	return OK;
}



/* recursively cp files and directories from the given path */


docpfd()

{
	char *saved;
	extern char *strcat();
	extern char *strcpy();
	DMABUFFER dumb;
	int ret, code;

	saved = (DMABUFFER *)Fgetdta();
	Fsetdta(&dumb);
	strcat(getall, fixsrc);
	if (!Fsfirst(fixsrc, 0xFF))	{
		do 	{
			if (dumb.d_fname[0] != '.')	{
				if (S_IFDIR & dumb.d_fattr)	{
					chksrcbuf(DIRLEN);		/* check buf size */
					addfile(fixsrc, dumb.d_fname);/* add a dir to the path */
					strcat(bckslsh, fixsrc);
					chkdstbuf(DIRLEN);		/* check buf size */
					strcat(dumb.d_fname, fixdst);
					unpack(dumb.d_fname);
					strcpy(dumb.d_fname,
							((TEDINFO *)(cpbox[CPDIR].ob_spec))->te_ptext);
					strcpy("_", ((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext);
					objc_draw(cpbox, CPFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);
					objc_draw(cpbox, CPDIR, MAX_DEPTH, 0, 0, wdesk, hdesk);
					/* update check the dir existing or not */
					if ((code = chkdir(dumb.d_fname, cpbox)) == QUIT)	{
						Pterm(1);
					} else if (code == SKIP)	{
						/* update the number of dir */
						updatndir();
						backdir(fixsrc);
						backdir(fixdst);
						srclen -= DIRLEN;		/* subtract the add lenth */
						dstlen -= DIRLEN;		/* subtract the add lenth */
						continue;
					}

					if ((editdir) || (code == OK))	{
					recreate:
						if (Dcreate(fixdst))	{
							if ((ret = err(cntcrtdr)) == 1)	{	/* skip */
								backdir(fixsrc);
								backdir(fixdst);
								srclen -= DIRLEN;	/* subtract the add lenth */
								dstlen -= DIRLEN;	/* subtract the add lenth */
								/* update the number of dir */
								updatndir();
								continue;
							} else if (ret == 2)	{	/* retry */
								goto recreate;
							} else 	{					/* quit */
								Pterm(1);
							}
						}
					}
					/* update the number of dir */
					updatndir();
					strcat(bckslsh, fixdst);/* fixdst -> c:\d1\d2\ */
					docpfd();				/* do the recursion */
					backdir(fixsrc);		/* back one dir */
					backdir(fixdst);		/* back one dir */
					srclen -= DIRLEN;		/* subtract the add lenth */
					dstlen -= DIRLEN;		/* subtract the add lenth */

				} else {
					chksrcbuf(FILELEN);		/* check buf size */
					addfile(fixsrc, dumb.d_fname);
					chkdstbuf(FILELEN);		/* check buf size */
					addfile(fixdst, dumb.d_fname);
					updatedir(); 			/* update the folder */
					/* update the file box */
					unpack(dumb.d_fname); 
					strcpy(dumb.d_fname,
							((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext); 
					objc_draw(cpbox, CPFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);
					wrfile(fixsrc, fixdst);	/* cp a file to the destination */
					backdir(fixsrc);		/* back one dir */
					backdir(fixdst);		/* back one dir */
					srclen -= FILELEN;		/* subtract the add lenth */
					dstlen -= FILELEN;		/* subtract the add lenth */
				}
			} 
		} while (!Fsnext());
	} else {
		Pterm(1);
	}
	Fsetdta(saved);
	return OK;
}


/* recursively mv files or directoies from a given path */


domvfd()


{
	char *saved;
	extern char *strcat();
	extern char *strcpy();
	DMABUFFER dumb;
	int ret, code;

	saved = (DMABUFFER *)Fgetdta();
	Fsetdta(&dumb);
	strcat(getall, fixsrc);
	if (!Fsfirst(fixsrc, 0xFF))	{
		do 	{
			if (dumb.d_fname[0] != '.')	{
				if (S_IFDIR & dumb.d_fattr)	{
					chksrcbuf(DIRLEN);		/* check buf size */
					addfile(fixsrc, dumb.d_fname); /* add a dir into the path */
					strcat(bckslsh, fixsrc);
					chkdstbuf(DIRLEN);		/* check buf size */
					strcat(dumb.d_fname, fixdst);
					unpack(dumb.d_fname);
					strcpy(dumb.d_fname,
							((TEDINFO *)(cpbox[CPDIR].ob_spec))->te_ptext);
					strcpy("_", ((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext);
					objc_draw(cpbox, CPFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);
					objc_draw(cpbox, CPDIR, MAX_DEPTH, 0, 0, wdesk, hdesk);
					/* update check the dir existing or not */
					if ((code = chkdir(dumb.d_fname, cpbox)) == QUIT)	{
						Pterm(1);
					} else if (code == SKIP)	{
						backdir(fixsrc);
						backdir(fixdst);
						updatndir();
						srclen -= DIRLEN;		/* subtract the add lenth */
						dstlen -= DIRLEN;		/* subtract the add lenth */
						continue;
					}

					if ((editdir) || (code == OK))	{
					recrtd:
						if (Dcreate(fixdst))	{
							if ((ret = err(cntcrtdr)) == 1)	{	/* skip */
								backdir(fixsrc);
								backdir(fixdst);
								updatndir();
								srclen -= DIRLEN;	/* subtract the add lenth */
								dstlen -= DIRLEN;	/* subtract the add lenth */
								continue;
							} else if (ret == 2)	{	/* retry */
								goto recrtd;
							} else 	{					/* quit */
								Pterm(1);
							}
						}
					}
					updatndir();
					strcat(bckslsh, fixdst);
					domvfd();				/* do the recursion */
					rmstarb(fixsrc);		/* after call, -> c:\d1\ */
				remvd:
					if (Ddelete(fixsrc))	{ /* delete a dir */
						if ((ret = err(cntdeld)) == 2)	{ /* retry */
							goto remvd;
						} else if (ret == 3)	{ 		/* abort */
							Pterm(1);
						}
					}
					backdir(fixsrc);		/* back one dir */
					backdir(fixdst);		/* back one dir */
					srclen -= DIRLEN;		/* subtract the add lenth */
					dstlen -= DIRLEN;		/* subtract the add lenth */

				} else {
					chksrcbuf(FILELEN);		/* check buf size */
					addfile(fixsrc, dumb.d_fname);
					chkdstbuf(FILELEN);		/* check buf size */
					addfile(fixdst, dumb.d_fname);
					updatedir();
					/* update the file */
					unpack(dumb.d_fname); 
					strcpy(dumb.d_fname,
							((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext); 
					objc_draw(cpbox, CPFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);
					wrfile(fixsrc, fixdst);		/* cp one file to destination */
					/* rm the file from source */
				remvf:
					if (Fdelete(fixsrc))	{
						if ((ret = err(cntdelf)) == 2)	{	/* retry */
							goto remvf;
						} else if (ret == 3)	{			/* abort */
							Pterm(1);
						}
					}
					backdir(fixsrc);		/* back one dir */
					backdir(fixdst);		/* back one dir */
					srclen -= FILELEN;		/* subtract the add lenth */
					dstlen -= FILELEN;		/* subtract the add lenth */
				}
			} 
		} while (!Fsnext());
	} else {
		Pterm(1);
	}
	Fsetdta(saved);
	return OK;
}


/* set the right drive and call the recursive routine to do the counting */


count(s)

char *s;

{
	char *buf, *tmp;
	int drv;

	buf = (char *)Malloc((long)sizeof(s));
	strcpy(s, buf);
	tmp = buf;
	drv = *buf;
	if (drv >= 'a')		{
		drv -= 'a';
	} else {
		drv -= 'A';
	}
	Dsetdrv(drv); 
	while (*tmp)	{
		tmp++;
	}
	if (*(tmp-1) == '*')	{
		*(tmp-4) = '\0';
		while(*buf != '\\')		{
			buf++;
		}
		if (Dsetpath(buf))	{
			Pterm(1);
		}
		countrec();
	} else	{
		numfiles = 1;
	}
	Mfree(buf);
	return OK;
}


/* counte the file and directory recursivly */

countrec()


{
	char *saved;
	DMABUFFER dumb;

	saved = (DMABUFFER *)Fgetdta();
	Fsetdta(&dumb);
	if (!Fsfirst(".\\*.*", 0xFF))	{
		do 	{
			if (dumb.d_fname[0] != '.')	{
				if (S_IFDIR & dumb.d_fattr)	{
					/* setpath to one more down */
					if (Dsetpath(dumb.d_fname))	{
						Pterm(1);
					}
					numdirs++;
					countrec();		/* to the recursion */
					/* setpath to one back */
					if (Dsetpath(".\\.."))	{
						Pterm(1);
					}
				} else {
					numfiles++;
					tolsize += dumb.d_fsize;
				}
			} 
		} while (!Fsnext());
	}
	Fsetdta(saved);
	return OK;
}


/* Copy the file from the s to d */

wrfile(s, d)

char *s, *d;

{
	int code, ret, status;
	int inhand;
	int outhand;
	DMABUFFER *mydta;
	char *buffer, *saved;
	long copysize;

open:

	if ((inhand = Fopen(s, 0)) < 0)	{
		if ((inhand == 0xFFFA) || (inhand == 0xFFFE))	{/* seek error or */
			Pterm(1);									/* drive not ready */
		}
		if ((ret = err(cntopen)) == 1)	{ 	/* skip */
			return OK;
		} else if (ret == 2)	{			/* retry */
			goto open;
		} else {							/* abort */
			Pterm(1);
		}
	}

	saved = (DMABUFFER *)Fgetdta();
	Fsetdta(mydta=(DMABUFFER *)Malloc((long)sizeof(DMABUFFER)));

	if (Fsfirst(s, 0xF7))	{
		if (err(rderror) == 1)	{ 	/* skip */
			goto doup;
		} else { 					/* abort */
			Fclose(inhand);
			Mfree(mydta);
			Pterm(1);
		}
	}

	/* check the created file existing or not */
	if ((code = chkfile(d, cpbox)) == QUIT)	{
		Fclose(inhand);
		Mfree(mydta);
		Pterm(1);
	} else if (code == SKIP)	{
		goto doup;
	}

	status = mydta->d_fattr & 7;
create:

	if ((outhand = Fcreate(d, status)) < 0)	{
		if ((ret = err(cntcrtfl)) == 1)	{	/* skip */
			goto doup;
		} else if (ret == 2)	{			/* retry */
			goto create;
		} else {							/* abort */
			Fclose(inhand);
			Mfree(mydta);
			Pterm(1);
		}
	}

	buffer = (char *)Malloc(8192L);
	copysize = mydta->d_fsize;
	while (copysize > 8192)	{
		if (Fread(inhand, 8192L, buffer) < 0)	{
			if (err(rderror) == 1)	{	/* skip */
				Fdelete(d);
				goto okup;
			} else {					/* abort */
				goto quitup;
			}
		}

		if ((status = Fwrite(outhand, 8192L, buffer)) < 0)	{
			if (err(wrerror) == 1)	{	/* skip */
				Fdelete(d);
				goto okup;
			} else {					/* abort */
				goto quitup;
			}
		}
		/* check if there are sufficent memory */
		if (status != 8192)		{ /* not sufficent memory ??*/
			err(nomemory);
			goto quitup;
		}
		copysize -= 8192;
	}

	if (copysize > 0)	{
		if (Fread(inhand, copysize, buffer) < 0)	{
			if (err(rderror) == 1)	{		/* skip */
				Fdelete(d);
				goto okup;
			} else {						/* abort */
				goto quitup;
			}
		}

		if ((status = Fwrite(outhand, copysize, buffer)) < 0)	{
			if (err(wrerror) == 1)	{	/* skip */
				Fdelete(d);
				goto okup;
			} else {					/* abort */
				goto quitup;
			}
		}
		/* check if there are sufficent memory */
		if (status != copysize)		{
			/* update not sufficent memory ??*/
			err(nomemory);
			goto quitup;
		}
	}

okup:
	Fclose(outhand);
	Mfree(buffer);

doup:

	Fclose(inhand);
	Mfree(mydta);
	Fsetdta(saved);
	updatnfile();
	return(OK);

quitup:

	Fclose(inhand);
	Fclose(outhand);
	Fdelete(d);
	Mfree(buffer);
	Mfree(mydta);
	Fsetdta(saved);
	Pterm(1);
}


/* Copy s and d into fixsrc and fixdst. Also check it is one file
   copy or files and directories copy */

getinfo(s, d, code)

char *s, *d;
int code;

{

	int sdir=0, ddir=0;
	char *ptrs, *ptrd;
	extern char *strcat();

	ptrs = s;
	ptrd = d;
	srclen = strlen(s) + 5; 	/* 1 for null and 4 for \*.* */
	dstlen = strlen(d) + 5; 
	srcbuf = 500;
	dstbuf = 500;
	while (srclen > srcbuf)	{
		srcbuf *= 2;
	}
	while (dstlen > dstbuf)	{
		dstbuf *= 2;
	}
	fixsrc = (char *)Malloc((long)srcbuf);
	fixdst = (char *)Malloc((long)dstbuf);
	mystrcp(fixsrc, &ptrs);	/* ptrs -> c:\d1\*.* or c:\d1\f; */
							/*after ptrs->*.* or f */
	if (*ptrs == '*')	{	/* source are dir */
		sdir = 1;
	} 

	if (code)	{		/* do directories or files cp or mv */
		mystrcp(fixdst, &ptrd);	/* ptrd -> c:\d1\*.* or c:\d1\f; */
								/*after ptrd->*.* or f */
		if (*ptrd == '*')	{	/* target are dir */
			ddir = 1;
		}
		if ((sdir) && (ddir))	{ 				/* dir to dir */
			return (DTOD);
		} else if ((!sdir) && (!ddir))	{ 		/* file to file */
			return (FTOF);
		} else {								/* one file to dir */
			chkdstbuf(FILELEN);					/* check buf size */
			strcat(ptrs, fixdst);
			return (FTOD);
		}
	} else 	{					/* else do directories or files rm */
		if (sdir)	{
			return(DTOD);
		} else {
			return(FTOD);
		}
	}
}




/*  this call will copy the string inside the s to 
 * 	the fixs. For example,
 * 	if s -> c:\d1\d2\*.* or c:\d1\d2\f, after the call,
 *	fixs -> \d1\d2\  or \d1\d2\f ; s -> *.* or f			*/

mystrcp(fixs, s)

char *fixs;
char **s;

{
	char *ptr;

	ptr = *s;
	while ((*ptr) && (*ptr != '*'))		{
		*fixs++ = *ptr++;
	}
	*fixs = '\0';
	if (*ptr == '*')		{
		*s = ptr;
	} else {
		while (*ptr != '\\')	{
			ptr--;
		}
		*s = ++ptr;
	}

}


/* check the size of source buffer */

chksrcbuf(addlen)

int addlen;

{

	char *ptr;

	if ((srclen + addlen) > srcbuf)		{
		srcbuf *= 2;
		ptr = fixsrc;
		fixsrc = (char *)Malloc((long)srcbuf);
		strcpy(ptr, fixsrc);
		Mfree(ptr);
	}
	srclen += addlen;
}


/* check the size of target buffer */

chkdstbuf(addlen)

int addlen;

{

	char *ptr;

	if ((dstlen + addlen) > dstbuf)		{
		dstbuf *= 2;
		ptr = fixdst;
		fixdst = (char *)Malloc((long)dstbuf);
		strcpy(ptr, fixdst);
		Mfree(ptr);
	}
	dstlen += addlen;
}


/* s -> c:\d1\d2\*.* or c:\d1\d2\, obj -> f; after the call
 * s -> c:\d1\d2\f							*/

addfile(s, obj)

char *s, *obj;

{
	char *ptr;
	extern char *strcat();

	ptr = s;
	while (*ptr)	{
		ptr++;
	}
	if (*(ptr-1) == '*')	{
		*(ptr-3) = '\0';
	}
	strcat(obj, s);
}



/* src -> c:\d1\d2\*.* or -> c:\d3\d5\, after the call,
 * src -> c:\d1\d2 or -> c:\d3\d5						*/

rmstarb(src)

char *src;

{

	char *ptr;

	ptr = src;
	while (*ptr)		{
		ptr++;
	}
	if (*(ptr-1) == '\\')	{	/* src -> c:\d3\d5\ */
		*(ptr-1) = '\0';
	} else {					/* src -> c:\d3\d5\*.*  */
		*(ptr-4) = '\0';
	}
}




/* str -> c:\d1\d2\*.* or c:\d1\d2\ or c:\d2\d4; after the call,
 * str -> c:\d1\*.* or c:\d1\  or c:\d2\		*/

backdir(str)

char *str;

{
	char *ptr;

	ptr = str;
	while (*ptr)  	{
		ptr++;
	}
	if (*(ptr-1) == '*')	{		/* str -> c:\d1\d2\*.*	*/
		ptr -= 5;					/* ptr -> 2 of c:\d1\d2 */
		while (*ptr != '\\')	{
			ptr--;
		}
		*ptr++;
		*ptr++ = '*';
		*ptr++ = '.';
		*ptr++ = '*';
		*ptr = '\0';
	} else if (*(ptr-1) == '\\')		{	/* str -> c:\d1\d2\ */
		ptr -= 2;
		while (*ptr != '\\')	{
			ptr--;
		}
		*(ptr + 1) = '\0';
	} else 	{					/* str -> c:\d1\d2  */
		while (*ptr != '\\')	{
			ptr--;
		}
		*(ptr + 1) = '\0';
	}
}




/* check the directory is exist or not */


chkdir(dir, prvobjtree)

char *dir;
OBJECT *prvobjtree;

{

	int ret, but, drv;
	char *buf;

	buf = fixdst;
	editdir = 0;

	drv = *buf;
	if (drv >= 'a')		{
		drv -= 'a';
	} else {
		drv -= 'A';
	}
	Dsetdrv(drv);
	buf += 2;				/* set buf -> \d1\x */
	if (!(ret = Dsetpath(buf)))	{	/* direcory exist */
		/* update name conflict box */
		strcpy(dir, ((TEDINFO *)(samename[FNAME].ob_spec))->te_ptext);
		strcpy(dir, ((TEDINFO *)(samename[EDFNAME].ob_spec))->te_ptext);
		samename[COPY].ob_state = NORMAL;
		samename[SKIP].ob_state = NORMAL;
		samename[QUIT].ob_state = NORMAL;
		graf_mouse(ARROW, 0x0L);
		dsplymsg(samename);
		switch((but = form_do(samename, 0)))	{
			case COPY:	
					if (!strcmp(((TEDINFO *)
								(samename[EDFNAME].ob_spec))->te_ptext, dir)) {
						strcpy(
						((TEDINFO *)(samename[EDFNAME].ob_spec))->te_ptext,dir);
						strcpy(dir,
								((TEDINFO *)(cpbox[CPDIR].ob_spec))->te_ptext);
						dopack(dir);
						/* user edit the new name */
						changelast(fixdst, dir);
						editdir = 1;
					}
						break;
			case SKIP:	break;
			case QUIT:	break;
		}
		graf_mouse(HOURGLASS, 0x0L);
		dsplymsg(prvobjtree);
		return but;
	} else if (ret == 0xFFDE)	{ /* path not found */
		return OK;
	} else {
		Pterm(1);
	}

}




/* check the file is exist or not */

chkfile(d, prvobjtree)

char *d;
OBJECT *prvobjtree;

{

	int ret, but;

	if ((ret = Fopen(d, 0)) >= 0)	{	/* file exist */
		/* update name conflict box */
		getlastpath(filestr, d);
		unpack(filestr);
		strcpy(filestr, ((TEDINFO *)(samename[FNAME].ob_spec))->te_ptext);
		strcpy(filestr, ((TEDINFO *)(samename[EDFNAME].ob_spec))->te_ptext);
		samename[COPY].ob_state = NORMAL;
		samename[SKIP].ob_state = NORMAL;
		samename[QUIT].ob_state = NORMAL;
		graf_mouse(ARROW, 0x0L);
		dsplymsg(samename);
		switch((but = form_do(samename, 0)))	{
			case COPY:	
					if (!strcmp(filestr, 
						((TEDINFO *)(samename[EDFNAME].ob_spec))->te_ptext)) {
						/* user edit the new name */
						strcpy(
						((TEDINFO *)(samename[EDFNAME].ob_spec))->te_ptext,
																	filestr);
						strcpy(filestr,
							((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext);
						dopack(filestr);
						changelast(d, filestr);
					}
						break;
			case SKIP:	break;
			case QUIT:	break;
		}
		graf_mouse(HOURGLASS, 0x0L);
		dsplymsg(prvobjtree);
		return but;
	} else if (ret == 0xFFDF)	{ 	/* file not found */
		return OK;
	} else {
		Pterm(1);
	}

}


/* if buf -> unpack.rsc, after the call, buf -> unpack  rsc.  */

unpack(buf)

char *buf;

{
	int i=0;
	char *ptr;

	ptr = buf;
	while ((*ptr != '.') && (*ptr))	{
		ptr++;
		i++;
	}
	if ((*ptr == '.') && (i != 8))	{ /* src -> abcx.x */
		*(buf+11) = '\0';
		*(buf+10) = *(buf+i+3);
		*(buf+9) = *(buf+i+2);
		*(buf+8) = *(buf+i+1);
		for (; i < 8; i++)	{
			*(buf+i) = ' ';
		}
	} else if ((i == 8)	&& (*ptr == '.')) 	{	/* src -> abcdefgh.x */
		*(buf+8) = *(buf+9);
		*(buf+9) = *(buf+10);
		*(buf+10) = *(buf+11);
		*(buf+11) = '\0';
	}

}




/* src -> file    rsc, after the call;
   src -> file.rsc						*/

dopack(src)

char *src;

{
	char *ptr;
	int i=0;

	ptr = src;
	while ((*ptr != ' ') && (*ptr))	{
		ptr++;
		i++;
	}
	if (*ptr == ' ')	{
		*ptr++ = '.';
		*ptr++ = *(src+8);
		*ptr++ = *(src+9);
		*ptr++ = *(src+10);
		*ptr = '\0';
	} else if (i > 8)	{
		*(src+12) = '\0';
		*(src+11) = *(src+10);
		*(src+10) = *(src+9);
		*(src+9) = *(src+8);
		*(src+8) = '.';
	}
}


/* d -> c:\d1\d2\f1, name -> f2, after the call, d-> c:\d1\d2\f2 	*/

changelast(d, name)

char *d, *name;

{
	backdir(d);
	strcat(name, d);
}


/* src -> c:\d1\d2\ or c:\d1\ or c:\; or
   src -> c:\d1\d2\f or c:\d1\f or c:\f; after the call,
   buf -> d2 or d1 or c:\ 								*/


getndlast(buf, src)

char *buf, *src;

{
	char *tmp;

	tmp = src;
	while (*tmp)	{
		tmp++;
	}
	tmp--;
	if (*tmp == '\\')	{	/* src -> c:\d1\d2\ or c:\d1\ or c:\ */
		if (*(tmp-1) == ':')	{ /* src -> c:\ */
			while ((*buf++ = *src++) != '\\')	{
				;
			}
			*buf = '\0';
		} else {
			tmp--;
			while (*tmp != '\\')		{
				tmp--;
			}
			tmp++;
			while ((*buf = *tmp++) != '\\')	{
				buf++;
			}
			*buf = '\0';
		}
	} else {	/* src -> c:\d1\d2\f or c:\d1\f or c:\f */
		while (*tmp-- != '\\')		{
			;
		}
		if (*tmp == ':')	{ /* src -> c:\f */
			while ((*buf++ = *src++) != '\\')	{
				;
			}
			*buf = '\0';
		} else {	/* src -> c:\d1\d2\f or c:\d1\f */
			while (*tmp != '\\')		{
				tmp--;
			}
			tmp++;
			while ((*buf = *tmp++) != '\\')	{
				buf++;
			}
			*buf = '\0';
		}
	}
}



/* src -> c:\f or c:\d1\f or c:\f\, after the call,
   buf -> f 								*/

getlastpath(buf, src)

char *buf, *src;

{
	char *tmp;

	tmp = src;
	while (*tmp)	{
		tmp++;
	}
	if (*(tmp-1) == '\\')	{
		*(tmp-1) = '\0';
	}
	while (*tmp != '\\')		{
		tmp--;
	}
	tmp++;
	strcpy(tmp, buf);
}



/* draw the cp or mv or rm dialog box */

showbox(title)

char *title;

{

	itoa(numdirs, ((TEDINFO *)(cpbox[NUMDIR].ob_spec))->te_ptext);
	itoa(numfiles, ((TEDINFO *)(cpbox[NUMFILE].ob_spec))->te_ptext); 
	((TEDINFO *)(cpbox[TITLE].ob_spec))->te_ptext = title;
	graf_mouse(ARROW, 0x0L);
	cpbox[HIDEBOX].ob_flags = HIDETREE;
	dsplymsg(cpbox);
	if (form_do(cpbox, 0) == CANCEL)	{
		return CANCEL;
	}
	cpbox[HIDEBOX].ob_flags = NORMAL;
	graf_mouse(HOURGLASS, 0x0L);
	return OK;

}

/* up date the number of file in the dialog box */

updatnfile()

{

	itoa(--numfiles, ((TEDINFO *)(cpbox[NUMFILE].ob_spec))->te_ptext);
	objc_draw(cpbox, NUMFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);
}

/* up date the number of directory in the dialog box */

updatndir()

{

	itoa(--numdirs, ((TEDINFO *)(cpbox[NUMDIR].ob_spec))->te_ptext);
	objc_draw(cpbox, NUMDIR, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/* up date the directory in the dialog box */


updatedir()

{
	getndlast(filestr, fixdst) ;
	unpack(filestr);
	strcpy(filestr, ((TEDINFO *)(cpbox[CPDIR].ob_spec))->te_ptext);
	objc_draw(cpbox, CPDIR, MAX_DEPTH, 0, 0, wdesk, hdesk);
}



/* up date the file in the dialog box */

updatefile()

{
	getlastpath(filestr, fixdst) ;
	unpack(filestr);
	strcpy(filestr, ((TEDINFO *)(cpbox[CPFILE].ob_spec))->te_ptext);
	objc_draw(cpbox, CPFILE, MAX_DEPTH, 0, 0, wdesk, hdesk);

}



/* convert the integer to the ascci */

itoa(n, s)

char *s;
long n;

{
	int i=0, j=0;
	char tmp[10];

	do {
		tmp[i++] = n % 10 + '0';
	} while ((n /= 10) > 0);
	for (; i > 0; )	{
		*s++ = tmp[--i];
		j++;
	}
	for(; j < 4; j++)	{
		*s++ = ' ';
	}
}



/* get the dialog box string */

getalladdr()
{

    /* Error messages */
    if (!rsrc_gaddr(5, CNTOPEN, &cntopen)
        || !rsrc_gaddr(5, CNTCRTDR, &cntcrtdr)
        || !rsrc_gaddr(5, CNTCRTFL, &cntcrtfl)
        || !rsrc_gaddr(5, WRERROR, &wrerror)
        || !rsrc_gaddr(5, NOMEMORY, &nomemory)
        || !rsrc_gaddr(5, CNTDELF, &cntdelf)
        || !rsrc_gaddr(5, CNTDELD, &cntdeld)
        || !rsrc_gaddr(5, RDERROR, &rderror))
        return ERROR;
        

	if (!rsrc_gaddr(0, CPBOX, &cpbox)
		|| !rsrc_gaddr(0, SAMENAME, &samename))	{
			return ERROR;
	}
    return OK;
}



/*
 *  Display a dialogue box on the screen.
 *	Input:
 *		tree - object tree for dialogue box to be displayed.
 *	Output:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
dsplymsg(tree)
OBJECT *tree;
{
    form_center(tree,&lx, &ly, &formw, &formh);
    form_dial(1, 0, 0, 0, 0, lx, ly, formw, formh);
    objc_draw(tree, 0, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/*
 *  Erase a dialogue box from the screen.
 *	Input:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
erasemsg()
{
    form_dial(3, 0, 0, 0, 0, lx, ly, formw, formh);
}




err(s)

char *s;

{
	int ret;

	graf_mouse(ARROW, 0x0L);
	ret = form_alert(1, s);
	graf_mouse(HOURGLASS, 0x0L);
	return (ret);
}


