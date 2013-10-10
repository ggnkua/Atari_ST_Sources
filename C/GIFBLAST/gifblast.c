/* gifblast.c - Special purpose GIF compressor, main program. */

#include <ctype.h>
#include <stdio.h>
#include <string.h>

#include "ubasic.h"
#include "uffile.h"
#include "gifcode.h"
#include "arith.h"
#include "arithcon.h"
#include "gb11code.h"

#define MAX_IM_WIDTH 3072
#define MAX_IM_HEIGHT 3072

static char *usage_message1[] = {
	"\n",
	"/| I s a a c |/\n",
	"/|Dimitrovsky|/ Presents GIFBLAST, a lossless GIF file compressor.\n",
	"/|  L a b s  |/ Generic C Version 1.1, Copyright (C) 1992 Isaac Dimitrovsky.\n",
	"GIFBLAST is a compressor designed especially for GIF files. The usual file\n",
	"compressors (PKZIP, ARJ, ZOO, etc.) do not work on GIF files; GIFBLAST does.\n",
	"When you run GIFBLAST X.GIF, you get a compressed file X.GFB that is usually\n",
	"20-25% smaller. In order to view this file you have to run GIFBLAST -D X.GFB\n",
	"to decompress X.GFB and get back the original X.GIF file. For convenience\n",
	"you can omit the .GIF and .GFB suffixes and give several files.\n",
	"\n",
	"GIFBLAST is recommended for applications such as storing GIF files on BBS's\n",
	"and posting GIF files to usenet. Because GIFBLAST perfectly preserves all\n",
	"images and other information in GIF files, the user need not be concerned\n",
	"with harming the images or introducing compression artifacts.\n",
	"\n",
	"This version of the GIFBLAST source is free and may be copied, distributed,\n",
	"and uploaded to bulletin boards. If you modify the source code significantly,\n",
	"please don't use the GIFBLAST name for your program to avoid confusion.\n",
	"Version 2.0 of GIFBLAST will be available on October 30, 1992.\n",
	"It will work faster and compress better than the current version.\n",
	"To order, make a $20 check payable to Isaac Dimitrovsky Labs and send it to:\n",
	"\tIsaac Dimitrovsky Labs, 147 Second Ave #484, New York NY 10003\n",
	"Be sure to include a full return address, and specify 3.5 or 5 inch disks.\n",
	"You will receive PC executable and generic C source on a PC-format disk.\n",
	NULL
};
static char *more_message =
	"                        (press return for more)"
;
static char *usage_message2[] = {
	"\n",
	"Legal Matters:\n",
	"\n",
	"This software is provided \"as is\" without any warranty express or implied,\n",
	"including but not limited to implied warranties of merchantability and\n",
	"fitness for a particular purpose.\n",
	"\n",
	"The Graphics Interchange Format(c) is the Copyright property of CompuServe\n",
	"Incorporated. GIF(sm) is a Service Mark property of CompuServe Incorporated.\n",
	NULL
};
static char *header_message[] = {
	"GIFBLAST Generic C Version 1.1, Copyright (C) 1992 Isaac Dimitrovsky.\n",
	"Type GIFBLAST -H for instructions.\n",
	NULL
};
static int usage=FALSE;
static int compress_opt=TRUE;
static OPTION opts[] = {
	{"-usage",SWITCHONOPT,&usage},
	{"-help",SWITCHONOPT,&usage},
	{"/help",SWITCHONOPT,&usage},
	{"-HELP",SWITCHONOPT,&usage},
	{"/HELP",SWITCHONOPT,&usage},
	{"-h",SWITCHONOPT,&usage},
	{"/h",SWITCHONOPT,&usage},
	{"-H",SWITCHONOPT,&usage},
	{"/H",SWITCHONOPT,&usage},
	{"-?",SWITCHONOPT,&usage},
	{"/?",SWITCHONOPT,&usage},
	{"-d",SWITCHOFFOPT,&compress_opt},
	{"/d",SWITCHOFFOPT,&compress_opt},
	{"-D",SWITCHOFFOPT,&compress_opt},
	{"/D",SWITCHOFFOPT,&compress_opt},
	{NULL}
};

static unsigned char buf[MAX_IM_WIDTH];
static int in_image;
static GIF_CODER *gc;
static GB11_CODER *gb11;

static int
has_suff(str,ploc)
char *str; int *ploc;
{
	int res,i;

	res = FALSE;
	for (i=strlen(str)-1; i>=0; i--) {
		res = (str[i] == '.');
		if (res || str[i]=='\\' || str[i]==':')
			break;
	}
	(*ploc) = i;
	return res;
}

static int
is_lowercase_fname(fname)
char *fname;
{
	for (; *fname!='\0'; fname++) {
		if (isascii(*fname) && islower(*fname))
			return TRUE;
	}
	return FALSE;
}

static void
add_suffs(argc,argv)
int argc; char **argv;
{
	int i,j;
	char *newarg;

	for (i=1; i<argc; i++) {
		if ((newarg=basic_alloc(strlen(argv[i])+5)) == NULL)
			uhalt(("out of memory while parsing command line arguments"));
		strcpy(newarg,argv[i]);
		basic_free(argv[i]);
		argv[i] = newarg;
		if (!has_suff(newarg,&j))
			strcat(newarg,(compress_opt
				? (is_lowercase_fname(newarg) ? ".gif" : ".GIF")
				: (is_lowercase_fname(newarg) ? ".gfb" : ".GFB")));
	}
}

static char *
change_to_out_suff(arg)
char *arg;
{
	int i;
	char *newarg;

	if (!has_suff(arg,&i))
		uhalt(("impossible command line argument %s",arg));
	if ((newarg=basic_alloc(strlen(arg)+5)) == NULL)
		return NULL;
	strcpy(newarg,arg);
	strcpy(newarg+i,(compress_opt
		? (is_lowercase_fname(newarg) ? ".gfb" : ".GFB")
		: (is_lowercase_fname(newarg) ? ".gif" : ".GIF")));
	return newarg;
}

static int
init_files(inff,outff)
FFILE *inff; FFILE *outff;
{
	in_image = FALSE;
	if (compress_opt)
		return gb11_start_encoding(gb11,outff);
	else
		return gb11_start_decoding(gb11,inff);
}

static int
end_files()
{
	if (compress_opt)
		return gb11_end_encoding(gb11);
	else
		return gb11_end_decoding(gb11);
}

static void
init_image(inff,outff,datasize)
FFILE *inff; FFILE *outff; int datasize;
{
	in_image = TRUE;
	if (compress_opt)
		gif_start_decoding(gc,inff,datasize);
	else
		gif_start_encoding(gc,outff,datasize);
}

static int
end_image()
{
	in_image = FALSE;
	if (compress_opt)
		return gif_end_decoding(gc);
	else
		return gif_end_encoding(gc);
}

static int
inff_getc(inff)
FFILE *inff;
{
	if (compress_opt && in_image)
		return gif_decode_c(gc);
	else if (compress_opt)
		return ff_getc(inff);
	else
		return gb11_decode_c(gb11);
}

static size_t
inff_read(buf,nbytes,inff)
unsigned char *buf; size_t nbytes; FFILE *inff;
{
	register size_t i;
	int c;

	if (compress_opt && in_image) {
		for (i=0; i<nbytes; i++) {
			if ((c=gif_decode_c(gc)) < 0)
				break;
			buf[i] = c;
		}
	} else if (compress_opt)
		i = ff_read(buf,nbytes,inff);
	else {
		for (i=0; i<nbytes; i++) {
			if ((c=gb11_decode_c(gb11)) < 0)
				break;
			buf[i] = c;
		}
	}
	return i;
}

static int
outff_putc(c,outff)
int c; FFILE *outff;
{
	if (compress_opt)
		return gb11_encode_c(c,gb11);
	else if (in_image)
		return gif_encode_c(c,gc);
	else
		return ff_putc(c,outff);
}

static size_t
outff_write(buf,nbytes,outff)
unsigned char *buf; size_t nbytes; FFILE *outff;
{
	register size_t i;

	if (compress_opt) {
		for (i=0; i<nbytes; i++)
			if (gb11_encode_c(buf[i],gb11) < 0)
				break;
	} else if (in_image) {
		for (i=0; i<nbytes; i++)
			if (gif_encode_c(buf[i],gc) < 0)
				break;
	} else
		i = ff_write(buf,nbytes,outff);
	return i;
}

static int
copyfile(inff,outff)
FFILE *inff; FFILE *outff;
{
	int c;

	while ((c=ff_getc(inff)) != EOF)
		if (ff_putc(c,outff) == EOF)
			return FALSE;
	return TRUE;
}

static void
gifblast(infname)
char *infname;
{
#define fail(args) {printf args ; failed=TRUE; goto endlabel;}
	FFILE *inff,*testf,*outff;
	char *outfname;
	int g_bpp,g_colmapsize,im_no,im_width,im_height,im_bpp;
	int im_colmapsize,im_datasize,im_v,c,extcode,size,pct_done,failed;
	long im_totbytes;

	printf("file %s:\n",infname);
	failed = FALSE;
	outfname = NULL;
	outff = NULL;
	if ((inff=ff_open(infname,FF_READ)) == NULL)
		fail(("\tunable to open file\n"));
	if ((outfname=change_to_out_suff(infname)) == NULL)
		fail(("\tout of memory while copying filename\n"));
	if ((testf=ff_open(outfname,FF_READ)) != NULL) {
		ff_close(testf);
		fail(("\twill not overwrite existing output file %s\n",outfname));
	}
	if ((outff=ff_open(outfname,FF_WRITE)) == NULL)
		fail(("\tunable to open output file %s\n",outfname));
	if (ff_read(buf,6,inff) != 6)
		fail(("\tincomplete header\n"));
	if ((!compress_opt) && strncmp(buf,"GIF",3)==0) {
		if (ff_write(buf,6,outff) != 6)
			fail(("\tunable to write header\n"));
		if (!copyfile(inff,outff))
			fail(("\tunable to write output file\n"));
		goto endlabel;
	}
	if (compress_opt ? strncmp(buf,"GIF",3)!=0 : strncmp(buf,"GB",2)!=0)
		fail(("\tinvalid header\n"));
	if (compress_opt) {
		buf[1] = 'B';
		buf[2] = 0x11;
	} else if (buf[2] != 0x11) {
		fail(("\tunable to decompress this code version (%d.%d)\n",
			buf[2]>>4,buf[2]&0xF));
	} else {
		buf[1] = 'I';
		buf[2] = 'F';
	}
	if (ff_write(buf,6,outff) != 6)
		fail(("\tunable to write header\n"));
	if (init_files(inff,outff) < 0)
		fail(("\tunable to initialize coder\n"));
	if (inff_read(buf,7,inff) != 7)
		fail(("\tunable to read screen descriptor\n"));
	if (outff_write(buf,7,outff) != 7)
		fail(("\tunable to write screen descriptor\n"));
	g_bpp = (buf[4]&0x7)+1;
	if ((buf[4]&0x80) != 0) {
		g_colmapsize = 3*(1<<g_bpp);
		if (inff_read(buf,g_colmapsize,inff) != g_colmapsize)
			fail(("\tunable to read global color map\n"));
		if (outff_write(buf,g_colmapsize,outff) != g_colmapsize)
			fail(("\tunable to write global color map\n"));
	}
	im_no = 0;
	do {
		if ((c=inff_getc(inff)) < 0)
			fail(("\tunexpected end of file\n"));
		if (outff_putc(c,outff) < 0)
			fail(("\tunable to write file\n"));
		switch (c) {
		case ',':
			if (inff_read(buf,9,inff) != 9)
				fail(("\tunable to read image descriptor\n"));
			im_width = ((((int)buf[4])&0xFF) | ((((int)buf[5])&0xFF)<<8));
			im_height = ((((int)buf[6])&0xFF) | ((((int)buf[7])&0xFF)<<8));
			if (im_width<=0 || MAX_IM_WIDTH<im_width
				|| im_height<=0 || MAX_IM_HEIGHT<im_height)
				fail(("\timage size out of range (%dx%d)\n",
					im_width,im_height));
			if ((buf[8]&0x80) != 0) {
				im_bpp = (buf[8]&0x7)+1;
				im_colmapsize = 3*(1<<im_bpp);
			} else {
				im_bpp = g_bpp;
				im_colmapsize = 0;
			}
			printf("\tprocessing image %d, %dx%d, %d bpp: ",
				++im_no,im_width,im_height,im_bpp);
			if (im_colmapsize>0
				&& inff_read(buf+9,im_colmapsize,inff)!=im_colmapsize)
				fail(("\n\t\tunable to read image color map\n"));
			if (outff_write(buf,im_colmapsize+9,outff) != im_colmapsize+9)
				fail(("\n\t\tunable to write image descriptor\n"));
			im_datasize = inff_getc(inff);
			if (im_datasize != (im_bpp==1 ? 2 : im_bpp))
				fail(("\n\t\tinvalid number of data bits in image (%d)\n",
					im_datasize));
			if (outff_putc(im_datasize,outff) < 0)
				fail(("\n\t\tunable to write image data bits\n"));
			init_image(inff,outff,im_datasize);
			im_totbytes = 0L;
			printf("     ");
			for (im_v=0; im_v<im_height; im_v++) {
				if (inff_read(buf,im_width,inff) != im_width)
					fail(("\n\t\terror detected reading image pixels\n"));
				if (outff_write(buf,im_width,outff) != im_width)
					fail(("\n\t\tunable to write image pixels\n"));
				im_totbytes += im_width;
				if (im_v<im_height-1 && (im_v%4)!=0)
					continue;
				pct_done =
					(int)((im_totbytes*100L)/(im_height*(long)im_width));
				printf("\b\b\b\b\b%c%c%c%% ",(pct_done==100?'1':' '),
					'0'+((pct_done/10)%10),'0'+(pct_done%10));
				fflush(stdout);
			}
			putchar('\n');
			if (end_image() < 0)
				fail(("\terror detected at end of image pixels\n"));
			break;
		case ';':
			break;
		case '!':
			if ((extcode=inff_getc(inff)) < 0)
				fail(("\tunexpected end of file\n"));
			if (outff_putc(extcode,outff) < 0)
				fail(("\tunable to write file\n"));
			do {
				if ((size=inff_getc(inff)) < 0)
					fail(("\tunexpected end of file\n"));
				buf[0] = size;
				if (size>0 && inff_read(buf+1,size,inff)!=size)
					fail(("\tunable to read extension block\n"));
				if (outff_write(buf,size+1,outff) != size+1)
					fail(("\tunable to write extension block\n"));
			} while (size > 0);
			break;
		default:
			fail(("\tunexpected character\n"));
		}
	} while (c != ';');
	if (end_files() < 0)
		fail(("\terror detected at end of file\n"));
	if (copy_if_larger && compress_opt && ff_tell(outff)>ff_tell(inff)) {
		ff_close(outff);
		if ((outff=ff_open(outfname,FF_WRITE)) == NULL)
			fail(("\tunable to reset output file\n"));
		ff_close(inff);
		if ((inff=ff_open(infname,FF_READ)) == NULL)
			fail(("\tunable to reset input file\n"));
		if (!copyfile(inff,outff))
			fail(("\tunable to rewrite output file\n"));
	}
	if (compress_opt)
		printf("done (%d%% savings)\n",
			(int)(((ff_tell(inff)-ff_tell(outff))*100L)/ff_tell(inff)));
endlabel:
	if (inff != NULL)
		ff_close(inff);
	if (outff != NULL) {
		ff_close(outff);
		if (failed)
			unlink(outfname);
	}
	if (outfname != NULL)
		basic_free(outfname);
}

main(argc,argv)
int argc; char **argv;
{
	int c,i;

	process_command_line(&argc,&argv,opts);
	if (usage || argc<=1) {
		for (i=0; usage_message1[i]!=NULL; i++)
			fprintf(stderr,"%s",usage_message1[i]);
		fprintf(stderr,"%s",more_message);
		do {
			c = getchar();
		} while (c != '\n');
		for (i=0; usage_message2[i]!=NULL; i++)
			fprintf(stderr,"%s",usage_message2[i]);
		uhalt((""));
	}
	for (i=0; header_message[i]!=NULL; i++)
		fprintf(stderr,"%s",header_message[i]);
	add_suffs(argc,argv);
	if ((gc=basic_alloc(sizeof(GIF_CODER)))==NULL
		|| (gb11=basic_alloc(sizeof(GB11_CODER)))==NULL)
		uhalt(("unable to allocate enough memory to start up"));
	for (i=1; i<argc; i++)
		gifblast(argv[i]);
}
