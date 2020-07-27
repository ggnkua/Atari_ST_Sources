/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:22 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	doarc.c,v $
* Revision 1.1  88/08/23  14:20:22  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/doarc.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * doarc.c: archive routines for aln
 */

#include "aln.h"

char *obtain_directory();
char *get_module();

/*
 * doarchive: open the archive, validate it, get its directory, and get all
 * the object modules you need:  the modules which export symbols in the
 * unresolved list, and their dependencies.
 *
 * When you have the mask of needed object files, visit the files IN
 * REVERSE ORDER, so you get the correct precedence of multiply-exported
 * globals.
 */

doarchive(aname,afd)
char *aname;
int afd;			/* the already-open descriptor */
{
    register char *image;
    int nsymbols;
    int nfiles;
    int vecsize;
    char *nptr;			/* pointer to file name list in dir. */
    char *sptr;			/* pointer to symbol list in dir. */
    char *dptr;			/* pointer to dependency info in dir. */
    struct HREC *uptr;		/* unresolved-list pointer */
    char *mask;			/* mask of needed files from archive */
    int temp,i;
    char *fptr;			/* pointer to image of object file */
    struct ARHEADER Header;
    
    DEBUG1("Do archive file %s\n",aname);
    
    FSEEK(afd,2L,0);		/* set pointer past magic number */

    if (dolist()) return TRUE;
    if (unresolved == NULL) {
	DEBUG0("No need for archive; no unresolved symbols\n");
	CLOSE(afd);
	return FALSE;	/* all done */
    }
    
    if ((image = obtain_directory(aname,afd)) == NULL) {
	return TRUE;
    }
    
    /* shorten aname to just the tail */
    aname = path_tail(aname);

    DEBUG1("We have the directory, at 0x%lx\n",image);
    
    /* make an empty ofile record, with type O_USED | O_ARC */
    if (fflag) {
	if (plist == NULL) {
	    plist = Newofile();
	    plast = plist;
	}
	else {
	    plast->o_next = Newofile();
	    plast = plast->o_next;
	}
	if (plast == NULL) {
	    printf("Out of memory\n");
	    return TRUE;
	}
	strcpy(plast->o_name,aname);
	plast->o_arname[0] = '\0';
	plast->o_flags = O_USED | O_ARCHIVE;
	plast->o_image = NULL;
	plast->o_next = NULL;
    }
    
    /* for each unresolved, OR in the dependencies of its exporter */
    
    nsymbols = getword(image+2);
    nfiles = getword(image+4);
    vecsize = (nfiles + 7) >> 3;
    
    DEBUG3("There are %d symbols, %d files, vecsize is %d\n",
	   nsymbols, nfiles, vecsize);
    
    /* pointers into archive directory image: */
    nptr = image + HEADSIZE;		/* file name list */
    sptr = nptr + nfiles*FNSIZE;		/* symbol list */
    dptr = sptr + nsymbols*SYMSIZE;		/* dependency list */
    
    DEBUG3("nptr = 0x%lx, sptr = 0x%lx, dptr = 0x%lx\n",
	   nptr, sptr, dptr);
    
    if ((mask = calloc(1L,(long)vecsize)) == NULL) {
	printf("Out of memory processing archive %s\n",aname);
	return TRUE;
    }
    
    uptr = unresolved;
    
    while (uptr != NULL) {
	DEBUG1("Search for %s: ",uptr->h_sym);
	if ((temp = find_file_number(uptr->h_sym,sptr,nsymbols)) != -1) {
	    DEBUG2("in file #%d (%s); ",temp,nptr+temp*FNSIZE);
	    if (Testbit(mask,temp)) {
		DEBUG0("already have it\n");
	    }
	    else {
		DEBUG0("get the file\n");
		Setbit(mask,temp);
		vector_or(mask,dptr+temp*vecsize,vecsize);
	    }
	}
	else DEBUG0("not in archive\n");
	
	uptr = uptr->h_next;
    }
    
    DEBUG0("Now we have the mask of needed files\n");
    
    for (i=nfiles-1; i>=0; i--) {
	if (Testbit(mask,i)) {
	    DEBUG3("Get file %d (%s) at offset 0x%lx\n", 
		   i, nptr+i*FNSIZE, getlong(nptr + i*FNSIZE + FNLEN));

	    if (vflag > 2) printf("File %s:%s\n",aname,nptr+i*FNSIZE);

	    if ((fptr = get_module(afd,getlong(nptr+i*FNSIZE+FNLEN),&Header))
		== NULL) {
		    printf("Error extracting module %s from archive %s.\n",
			nptr+i*FNSIZE,aname);
		    printf("Possibly a bad index: re-run doindex on %s.\n",
			aname);
		    return TRUE;
		}
	    if (plist == NULL) {
		plist = Newofile();
		plast = plist;
	    }
	    else {
		plast->o_next = Newofile();
		plast = plast->o_next;
	    }
	    if (plast == NULL) {
		printf("Out of memory\n");
		return TRUE;
	    }
	    strcpy(plast->o_name,Header.a_fname);

	    if (strlen(aname) > FNLEN-1) {
		printf("Archive name too long: %s (sorry!)\n",aname);
		return TRUE;
	    }
	    strcpy(plast->o_arname,aname);
	    plast->o_image = fptr;
	    plast->o_flags = 0;		/* not USED yet */
	    plast->o_next = NULL;
	}
    }
    DEBUG1("Done with archive %s\n",aname);
    free(image);			/* don't need the image any more */
    free(mask);				/* nor the "needed" vector */

    /* make an empty ofile record, with type O_USED | O_ARC and no name */
    if (fflag) {
	if (plist == NULL) {
	    plist = Newofile();
	    plast = plist;
	}
	else {
	    plast->o_next = Newofile();
	    plast = plast->o_next;
	}
	if (plast == NULL) {
	    printf("Out of memory\n");
	    return TRUE;
	}
	plast->o_name[0] = '\0';
	plast->o_arname[0] = '\0';
	plast->o_flags = O_USED | O_ARCHIVE;
	plast->o_image = NULL;
	plast->o_next = NULL;
    }
    return FALSE;
}

char *obtain_directory(aname,afd)
char *aname;
int afd;
{
    int dfd;
    char dirfname[256];		/* reasonable size for a filename */
    char *dotptr, *rindex();
    char *ptr;
    long size;
    
    if (strlen(aname) > 255) {
	printf("Archive name too long: %s (sorry!)\n",aname);
	return NULL;
    }
    
    strcpy(dirfname,aname);
    dotptr = rindex(dirfname,'.');
    if (dotptr > rindex(dirfname,92) || dotptr > rindex(dirfname,'/')) {
	*dotptr = '\0';		/* clobber the name */
    }
    strcat(dirfname,DIRSUFFIX);
    
    DEBUG2("Archive name is `%s' - directory name is `%s'\n",
	   aname, dirfname);
    
    if ((dfd = OPEN(dirfname,0)) <= 0) {
	printf("Error: cannot find an index file for archive %s\n",aname);
	printf("Use the command \"doindex %s\" to create one.\n",aname);
	return NULL;
    }
    else {		/* we have a directory */
	size = FSIZE(dfd);
	if (size < HEADSIZE) {
	    printf("Bad index file: %s.",dirfname);
	    printf("Use the command \"doindex %s\" to create a new one.\n",
		   aname);
	    return NULL;
	}
	if ((ptr = malloc(size)) == NULL) {
	    printf("Out of memory\n");
	    CLOSE (dfd);
	    return NULL;
	}
	if (READ(dfd,ptr,size) != size) {
	    printf("Read error on index file\n");
	    CLOSE (dfd);
	    return NULL;
	}
	if (CLOSE(dfd)) {
	    printf("Error closing index file\n");
	    return NULL;
	}
    }
    DEBUG0("OBTAIN_DIRECTORY is finished.\n");
    return ptr;
}

char *get_module(fd,index,Header)
int fd;
long index;
struct ARHEADER *Header;
{
	register char *ptr;

	DEBUG1("Get_module at index 0x%lx\n",index);

	if (FSEEK(fd,index,0) != index) {
	    printf("Read error on archive\n");
	    return NULL;
	}

	if (get_header(fd,Header)) {
	    return NULL;	/* end of file or error */
	}
	if ((ptr = malloc(Header->a_fsize)) == NULL) {
	    printf("Out of memory\n");
	    return NULL;
	}
	if (READ(fd,ptr,Header->a_fsize) != Header->a_fsize) {
	    printf("Read error reading archived module\n");
	    free(ptr);
	    return NULL;
	}
	return ptr;		/* success! */
}

/*
 * Note: This function will mistakenly report no error if there is an error in
 * reading modules from the archive.
 */

get_all(afd,aname)
int afd;
char *aname;
{
	char *fptr;
	struct ARHEADER Header;

	aname = path_tail(aname);

	flush_handles();	/* do pending .o files before this one */

	while ((fptr = get_module(afd,FTELL(afd),&Header)) != NULL) {
	    if (vflag > 2) printf("File %s:%s\n",aname,Header.a_fname);

	    if (plist == NULL) {
		plist = Newofile();
		plast = plist;
	    }
	    else {
		plast->o_next = Newofile();
		plast = plast->o_next;
	    }
	    if (plast == NULL) {
		printf("Out of memory\n");
		return TRUE;
	    }
	    strcpy(plast->o_name,Header.a_fname);
	    if (strlen(aname) > FNLEN-1) {
		printf("Archive name too long: %s (sorry!)\n",aname);
		return TRUE;
	    }
	    strcpy(plast->o_arname,aname);
	    plast->o_image = fptr;
	    plast->o_flags = O_USED;
	    plast->o_next = NULL;
	}
	return FALSE;	/* no error */
}

