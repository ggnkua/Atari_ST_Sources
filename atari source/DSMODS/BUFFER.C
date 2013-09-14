/*
	This module contains the routines for manipulating the text buffer.
	The text buffer looks as follows:

	+-----------------------+	 <== buf_end
	|					|
2	|					|
	|					|
	+-----------------------+	 <== current_char
	|					|
	|	free_area			|
	|					|
	+-----------------------+	 <== free_start
	|					|
1	|					|
	|					|
	+-----------------------+	 <== buf_start

	buf_end:	points at the last	character in the 2nd partition.
	current_char:	points at the first	character in the 2nd partition.
	free_start:	points at the first	free byte in the buffer.
	buf_start:	points at the first	character in the 1st partition.
*/
#include	<stdio.h>
#include	<osbind.h>
#include	"defs.h"

#define		MIN_LEFT	10	/* minimum edit space left	*/
#define		MIN_FREE	80L	/* minimum editing space	*/

extern	unsigned char	**upd_ptr;	/* region pointer tag array	*/
extern	int		upd_tags;	/* number of ptrs in array	*/

unsigned	cb_size = 0;		/* size of	copy buffer	*/
unsigned char	*cb_start = (char *)0;	/* pointer to	copy buffer	*/

/*
	Function to set Text Window tag pointer to current_char
*/
unsigned char	*setwptr(tag)
unsigned	tag;
{
	return(wdw_ptr[tag] = current_char);
}

/*
	Function to set Composition tag pointer to current_char
*/
unsigned char	*setbptr(tag)
unsigned	tag;
{
	return(buf_ptr[tag] = current_char);
}

init_buffer(bp,ep)
unsigned char	*bp, *ep;
{
	int	i;

	buf_start	= bp;		/* initialize buffer variables	*/
	buf_end		= ep;
	free_start	= buf_start;
	current_char	= buf_end;
	for (i = 0;i < num_tags;) setbptr(i++);
	for (i = 0;i < wdw_tags;) setwptr(i++);
}

set_buffer(txtsize)
unsigned long	txtsize;
{
	unsigned char	*start = free_start;

	setwptr(TMP4);				/* set end   marker	*/
	free_start += txtsize;			/* add new text size	*/
	TWrewindow(start);			/* to start position	*/
	setwptr(TMP1);				/* set begin marker	*/
	backup(0);				/* to start of line	*/
	word_wrap(current_char,0,0);		/* word wrap text	*/
	TWrewindow(wdw_ptr[TMP1]);		/* to start position	*/
	CPrewindow(wdw_ptr[TMP1]);		/* reset CP tag array	*/
}

unsigned long free_space()			/* number of free bytes */
{
	return((unsigned long)(current_char - free_start));
}

/*
	Function to read in a file to cuurent article...
	Returns -1	if an I/O error occured
		2	if no room in buffer
		1	if file is larger than buffer
		0	if read OK
*/
read_file(file_ptr)
char	*file_ptr;
{
	int		file;
	unsigned long	rdsize, attempt;

	if (free_space() < MIN_FREE * 2)		/* no buffer space.. */
		return(2);
	if ((file = Fopen(file_ptr,FREAD)) == -1)	/* open read mode    */
		return(-1);
	attempt	= free_space() - MIN_FREE;
	rdsize	= Fread(file,attempt,free_start);
	Fclose(file);
	if (rdsize == -1L)
		return(-1);				/* file IO error.... */
	set_buffer(rdsize);
	return(rdsize == attempt);			/* test large file.. */
}
	
/*
	Function to write out an updated article...
	Returns 0  if write OK
		-1 if write error
*/
write_file(file_ptr)
char	*file_ptr;
{
	int	file;
	long	status;

	file = Fcreate(file_ptr,NWFIL);
	if (file == -1) return(-1);
	CPrewindow(buf_end);
	status = Fwrite(file,(long)(free_start - buf_start),buf_start);
	Fclose(file);
	if (status != (long)(free_start - buf_start))
		return(-1);
	else	return(0);
}

/*
	Move the free area window and adjust 'buf_ptr' accordingly.
*/
CPrewindow(new_end)
unsigned char	*new_end;
{
	mv_f_area(new_end,&buf_ptr[0],&buf_ptr[num_tags]);
}

/*
	Move the free area window and adjust 'wdw_ptr' accordingly.
*/
TWrewindow(new_end)
unsigned char	*new_end;
{
	unsigned char	**bptr, **eptr;

	mv_f_area(new_end,&wdw_ptr[0],&wdw_ptr[wdw_tags]);
	if (upd_ptr) {
		bptr = &upd_ptr[0];
		eptr = &upd_ptr[upd_tags];
		mv_f_area(new_end,bptr,eptr);
		while (bptr < eptr) {
			if (!*bptr) *bptr = current_char;
			++bptr;
		}
	}
}

/*
	Move the free area window with 'current_char' set to 'new_end'
	and adjust all pointers in the array pointer.
*/
mv_f_area(new_end,bptr,eptr)
unsigned char	*new_end, **bptr, **eptr;
{
	if (!new_end)
		new_end = current_char;
	if (new_end < free_start) {		/* if in 1st partition	*/
	  if (new_end < buf_start)
		new_end = buf_start;
	  while (bptr < eptr) {
		if (*bptr) {
		  if (*bptr >= new_end && *bptr < free_start)
			*bptr = current_char - (long)(free_start - *bptr);
		  else
		  if (*bptr >= free_start && *bptr < current_char)
			*bptr = 0L;
		}
		++bptr;
	  }
	  Lr_move(free_start-1,current_char-1,(long)(free_start - new_end));
	  current_char -= (long)(free_start - new_end);
	  free_start	= new_end;
	}
	else
	if (new_end > current_char) {		/* if in 2nd partition	*/
	  if (new_end > buf_end)
		new_end = buf_end;
	  while (bptr < eptr) {
		if (*bptr) {
		  if (*bptr >= current_char && *bptr < new_end)
			*bptr = free_start + (long)(*bptr - current_char);
		  else
		  if (*bptr >= free_start && *bptr < current_char)
			*bptr = 0L;
		}
		++bptr;
	  }
	  Lf_move(current_char,free_start,(long)(new_end - current_char));
	  free_start	+= (long)(new_end - current_char);
	  current_char	= new_end;
	}
	else
	for (;bptr < eptr;++bptr)
		if (*bptr >= free_start && *bptr < current_char)
			*bptr = 0L;
}

/*
	Function to copy data out of the copy buffer
*/
cb_bufout(ptr)
unsigned char *ptr;
{
	f_move(cb_start,ptr,cb_size);
}

/*
	Function to copy data into the copy buffer.
	It will overwrite the previous contents of the copy buffer.
*/
cb_bufin(ptr,len)
unsigned char	*ptr;
unsigned long	len;
{
	unsigned long	fsp;

	fsp = free_space();
	if (len > 65535L || fsp <= MIN_FREE || len > fsp - MIN_LEFT)
		return(1);			/* no space for command	*/
	if (cb_start)				/* free old one...	*/
		free(cb_start);
	cb_start = malloc((unsigned)len + 2);	/* malloc save buffer	*/
	if (!cb_start)
		return(1);			/* no memory buffer...	*/
	f_move(ptr,cb_start,cb_size = (unsigned)len);
	return(0);
}
