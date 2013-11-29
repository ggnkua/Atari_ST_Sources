/*
 * fullgrp.c  
 *
 * remove extraneous stuff from fullgrp.txt
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

#if (0)
long filesize( char *filename )
{
	FILE *fid;
	int x;
	long count=0;
	fpos_t pos;

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {		/* if file exists... */
		x = fseek( fid, 0, SEEK_END );
		x = fgetpos( fid, &pos );
	/*	fprintf( log, "Size of %s is %ld\n", filename, pos ); */
		count = (long)pos;
		fclose( fid );
	}
	return(count);
}

int xcmp( const void *a, const void *b )
{
	return ( strcmp( a,b ) );
}

void sortfile(char *infile, char *outfile)
{
	FILE *in,*out;
	char buff[200],*p,*sort;
	register size_t c=0,d;
	long fsize,max,buffer,slen,smax=0;
	
	in = fopen( infile, "ra");
	if (in!=NULL) {
		fsize = filesize( infile );
		printf( "File size is %ld bytes\n", fsize );
		max = fsize/25;
		if (max>28000) { max=28000; }	/* set a maximum of 28000 entries */
		buffer = max*80;
		printf( "Allocating memory for %ld entries= %ld bytes\n", max, buffer );
		sort = calloc( max, 80 );
		if (sort!=NULL) {
			printf( "Reading file\n" );
			while (fgets( buff, sizeof(buff), in )!=NULL) {
				p = strtok( buff, " \n" );
				slen = strlen(buff);
				if (slen>smax) { smax=slen; }
				if (slen>64) { printf( "::%s\n", buff ); }
				if (slen>1) { strcpy( sort+(80*c++), buff ); }
				if (c>=max) {
					printf( "Exceeded maximum of %ld entries\n", max );
					break;
				}
			}
			fclose( in );
			printf( "Maximum newsgroup name was %ld bytes\n", smax );

			printf( "Sorting %ld entries\n", (long)c );
			qsort( sort, c, (size_t)80, xcmp );
			printf( "Sort completed, Writing File\n" );

			out = fopen( outfile, "wa");
			for (d=0;d<c;d++) { fprintf(out, "%s\n", sort+(d*80) ); }
			fclose( out );
			free( sort );
		} else { printf( "Insufficient memory for sort\n" ); }
	}
}
#endif

int nxcmp( const void *a, const void *b )
{
	return ( strcmp( *(const char **)a, *(const char **)b ) );	/* inputs are pointers to char strings */
}

void new_sortfile(char *input, char *output )
{
	struct FILEINFO finfo;
	char far **grp,**tmp;
	char far *file,*p,*q;
	FILE *infile,*outfile,*idx;
	char temp[80],*alert;
	size_t slen,c=1,d=0;

	if (dfind(&finfo, input, 0)) { return; }	/* file does not exist */
	/* allocate space for entire file and read file into area. (i.e 1.2Meg) */
	if ((file = malloc( finfo.size+1 ))!=NULL) {
		if ((infile = fopen( input, "ra" ))!=NULL) {
			memset( file, 0, finfo.size+1 );
			fread( file, finfo.size, 1, infile ); 
			fclose( infile );
		} else { free( file ); return; }	/* could not open file */
		printf( "Read in File\n" );
	} else /* if (file==NULL) */ {
	/*	rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
	/*	sprintf( temp, alert, "Sort" ); */
	/*	form_alert( 1, temp ); */
		return;		/* unable to sort */
	}

	p = file;
	while ((p=strchr(p, '\n'))!=NULL) { d++; p++; }
	printf( "Found %ld lines\n", d );

	/* allocate space for list of newsgroups, each is far pointer to a group name */
	if ((grp = calloc( sizeof(size_t), d+10))!=NULL) { 	/* 50000 = 200K */
	/*	keep address of every line start (i.e. after crlf) in *grp array. */
		printf( "Allocated %ld indexes\n", d+10 );
		p = file;
		tmp = grp;
		*tmp = p;
		while ((q=strchr(p, '\n'))!=NULL) {
			*q = ' ';	/* change newline to a space */
			slen = q-p;
			p = q;
			if (slen>80) { continue; }
			if (*(p+1)=='.') { break; }
			++tmp;	*tmp = p+1; c++;		
		}
		printf( "Found %ld newsgroups in file\n", c );
	/*	scan thru file and change spaces to nulls. */
		printf( "Converting spaces to Nulls\n" );
		p = file;
		while ((p=strchr(p, ' '))!=NULL) { *p='\0'; p++; }

	/*	sort grp array */
		printf( "Sorting newsgroups\n" );
		qsort( grp, c, sizeof(size_t), nxcmp );

	/*	unload file indexed by grp array */
		if ((outfile = fopen( output, "wa"))!=NULL) {
			printf( "Unloading %ld newsgroups\n", c );
		 	tmp = grp;
		/*	while (tmp) { fprintf( outfile, "%s\n", *tmp ); tmp++; } */
			for (d=0;d<=c;d++) {
				fprintf( outfile, "%s\n", *tmp ); tmp++;
			}
			fclose( outfile );
		}
		free( grp );
	} else /* if (grp==NULL) */ {
	/*	rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
	/*	sprintf( temp, alert, "Sort" ); */
	/*	form_alert( 1, temp ); */
	}
	free( file );
}

void main(void)
{
	int full=0;

	if (full) {
		new_sortfile( "D:\\FULLGRP.TXZ", "D:\\FULLGRP.OUT" );
	} else {
		new_sortfile( "D:\\79.TXT", /*NEWGRP.TXT",*/ "D:\\NEWGRP.OUT" );
	}
}



