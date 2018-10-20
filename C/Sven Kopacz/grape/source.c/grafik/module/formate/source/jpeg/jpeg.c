#include <stdio.h>#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <fiodef.h>
#include <atarierr.h>
#include <tos.h>
#include <aes.h>
#include <setjmp.h>#include <jpeglib.h>
#define numcat(a, b)	itoa(b, &(a[strlen(a)]), 10)void cdecl	mod_init(void);	/* Initialisierung des Moduls */
int cdecl		identify(FILE_DSCR *fd);
int cdecl		load_file(FILE_DSCR *fd, GRAPE_DSCR *dd);
int cdecl		save_file(FILE_DSCR *fd, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options);

GLOBAL(int) read_JPEG_file (char * filename, GRAPE_DSCR *dd);GLOBAL(int) write_JPEG_file (char * filename, int ex_format, int quality, int *options, GRAPE_DSCR *dd);
char *comp_names[]={"0-max. quality","1","2","3","4","5","6","7","8","9","10-min. size"};
char *option1[]={"Baseline"};
char *option2[]={"Progressive"};
char *option3[]={"Fast"};
char *option4[]={"Opt. Huffman"};
char *option5[]={"Smooth 0","Smooth 1","Smooth 2","Smooth 3","Smooth 4","Smooth 5","Smooth 6","Smooth 7","Smooth 8","Smooth 9","Smooth 10"};
OPTION opts[]=
{
	1,option1,
	1,option2,
	1,option3,
	1,option4,
	11,option5
};

static MODULE_FIOFN mod_fn=
{
	/* Meine Funktionen */	
	mod_init,
	identify,
	load_file,
	save_file
};

static FIOMODBLK fblock=
{
	"GRAPEFIOMOD",
	'0101',
	
	/* id */
	'JPEG',
	
	/* name */
	"JPEG/JFIF",

	/* Exportformate */
	SUP8G|SUP24RGB,
	
	/* Anzahl der Kompressionsverfahren */
	11,
	/* Namen */
	comp_names,
	
	/* Anzahl der Optionen */
	5,
	/* Optionen */
	opts,
	
		
	/* Meine Funktionen */	
	&mod_fn,
	
	/* Grape-Functions */
	NULL
};

void main(void)
{
	appl_init();
	if(fblock.magic[0])
		form_alert(1,"[3][Ich bin ein Grape-Modul!][Abbruch]");
	appl_exit();
}

void cdecl mod_init(void)
{
}
int	cdecl	identify(FILE_DSCR *fd)
{

	typedef struct
	{
		unsigned int	id;
		unsigned int		size;
		char	jfif[5];
		char	version[2];
	}APP0_HEADER;
	typedef struct
	{
		unsigned int	id;
		unsigned int		size;
		char	pic_data[6];
		/* 0 = precision
			1,2 = height
			3,4 = width
			 5  = bps
		*/
	}SOF_HEADER;
	typedef struct
	{
		unsigned int id;
		unsigned int	size;
	}JFIF_BLOCK;
	APP0_HEADER		*ahd;
	SOF_HEADER		*sof=NULL;
	JFIF_BLOCK		*jbl;
	uchar					mbuf[2048], *jblk=mbuf;
	int						ret, precision, height, width, bps;
	long					offset=0;
	static char 	dscr[120];
	
	Fread(fd->fh, 2048, mbuf);
	jblk+=2;
	ahd=(APP0_HEADER*)jblk;
	if(ahd->id!=0xffe0l) return(UNKNOWN);
	if((ahd->jfif[0]!='J')||(ahd->jfif[1]!='F')||(ahd->jfif[2]!='I')||(ahd->jfif[3]!='F')||(ahd->jfif[4]!=0))
	 return(UNKNOWN);

	ret=REL_REC;

	/* Bl”cke nach SOF absuchen, bis SOS-Block gefunden wird */
	jbl=(JFIF_BLOCK*)jblk;
	while((jbl->id != 0xffdal) && (sof==NULL))
	{
		if((sof==NULL)&&(jbl->id>=0xffc0l)&&(jbl->id<=0xffcfl)&&(jbl->id!=0xffc2l)&&(jbl->id!=0xffc4l)&&(jbl->id!=0xffccl))
			sof=(SOF_HEADER*)jbl;
		jblk+=jbl->size+2;
		jbl=(JFIF_BLOCK*)jblk;
		if((long)jbl - (long)mbuf > 2048)
		{/* Buffer neu laden */
			offset+=(long)jbl-(long)mbuf;
			Fseek(offset, fd->fh, 0);
			Fread(fd->fh, 2048, mbuf);
		}
	}

	if(sof!=NULL)
	{
		if((long)sof-(long)mbuf < sizeof(SOF_HEADER))
		{
			Fseek((long)sof-(long)mbuf+offset, fd->fh, 0);
			Fread(fd->fh, sizeof(SOF_HEADER), mbuf);
			sof=(SOF_HEADER*)mbuf;
		}
		precision=sof->pic_data[0];
		height=*(int*)(&(sof->pic_data[1]));
		width=*(int*)(&(sof->pic_data[3]));
		bps=sof->pic_data[5];
	}
	strcpy(dscr, "JPEG/JFIF File, Version ");
	numcat(dscr, ahd->version[0]);
	strcat(dscr, ".");
	numcat(dscr, ahd->version[1]);
	if(sof==NULL)
	{/* Kein Bilddatenblock gefunden */
		strcat(dscr, "|Die Datei enth„lt keinen Bilddatenblock.");
		strcat(dscr, "|Vermutlich ist die Datei defekt.");
	}
	else if((width<=0)||(height<=0))
	{/* Ungltige Ausmaže oder DHL-File (H”he wird erst durch Auspacken bekannt) */
		strcat(dscr, "|Die Ausmaže sind als ");
		numcat(dscr, width);
		strcat(dscr, " x ");
		numcat(dscr, height);
		strcat(dscr, "|Pixel angegeben.");
		strcat(dscr, "|Entweder handelt es sich um eine nicht");
		strcat(dscr, "|untersttzte Variation (DNL) oder die");
		strcat(dscr, "|Datei ist defekt.");
	}
	else
	{/* Sieht gut aus */
		strcat(dscr, "|Gr”že: ");
		numcat(dscr, width);
		strcat(dscr, " x ");
		numcat(dscr, height);
		strcat(dscr, " Pixel in ");
		if(bps==3)
		{
			strcat(dscr, "Farbe");	/* CAN_LOAD */
			ret|=CAN_LOAD;
		}
		else if(bps==1)
		{
			strcat(dscr, "Graustufen"); /* CAN_LOAD */
			ret|=CAN_LOAD;
		}
		else
		{
			numcat(dscr, bps);
			strcat(dscr, " Farbebenen");
		}
		strcat(dscr, "|Aufl”sung: ");
		numcat(dscr, bps*precision);
		strcat(dscr, " Bit pro Pixel");
		if(precision!=8)
			ret=REL_REC;/* CAN NOT LOAD */
	}
	
	fd->descr=dscr;
	if(sof!=NULL)
	{
		fd->width=width;
		fd->height=height;
	}
	return(ret);
}

int cdecl		load_file(FILE_DSCR *fd, GRAPE_DSCR *dd)
{
	char	total_path[128];
	
	Fclose(fd->fh); /* Sonst kriegt das jpeg-gelumpe das nicht auf */

	strcpy(total_path, fd->path);
	strcat(total_path, fd->name);
	strcat(total_path, fd->ext);
	if(read_JPEG_file(total_path, dd)==1)	/* Successive */		return(0);
	else
		return(-1);
}

int	cdecl	save_file(FILE_DSCR *fd, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options)
{
	char	total_path[128];
	
	Fclose(fd->fh); /* Sonst kriegt das jpeg-gelumpe das nicht auf */
	
	strcpy(total_path, fd->path);
	strcat(total_path, fd->name);
	strcat(total_path, fd->ext);
	if(write_JPEG_file(total_path, ex_format, 100-cmp_format*10, options, sd)==1)	/* Successive */		return(0);
	else
		return(-1);
}

/* JPEG-Error-Handler */
struct my_error_mgr {  struct jpeg_error_mgr pub;	/* "public" fields */  jmp_buf setjmp_buffer;	/* for return to caller */};typedef struct my_error_mgr * my_error_ptr;/* * Here's the routine that will replace the standard error_exit method: */METHODDEF(void)my_error_exit (j_common_ptr cinfo){
	char	alert[128];  /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */  my_error_ptr myerr = (my_error_ptr) cinfo->err;  /* Always display the message. */  strcpy(alert, "[3][JPEG-Import:|");	(*cinfo->err->format_message) (cinfo, &(alert[strlen(alert)]));
	strcat(alert, "][Cancel]");
	_GF_ form_alert(1,alert);
  /* Return control to the setjmp point */  longjmp(myerr->setjmp_buffer, 1);}/******************** JPEG COMPRESSION SAMPLE INTERFACE *******************/GLOBAL(int)write_JPEG_file (char * filename, int ex_format, int quality, int *options, GRAPE_DSCR *dd){  struct jpeg_compress_struct cinfo;  struct my_error_mgr jerr;  /* We use our private extension JPEG error handler. */  FILE * outfile=NULL;		/* target file */  JSAMPROW row_pointer[1];	/* pointer to JSAMPLE row[s] */	BLOCK_DSCR	mblock;
	
	/* Init mblock */
	if(ex_format==SUP8G)
	{
		mblock.format=B8;
		mblock.subcode=B8_GBWPP;
		mblock.data=_GF_ malloc(dd->width);
	}
	else
	{		mblock.format=B24;
		mblock.subcode=B24_RGBPP;
		mblock.data=_GF_ malloc(dd->width*3);
	}
	mblock.height=dd->height;
	mblock.width=dd->width;
	mblock.x=mblock.y=0;
	mblock.w=mblock.lw=dd->width;
	mblock.h=1;
	row_pointer[0]=mblock.data;
	
  /* Step 1: allocate and initialize JPEG compression object */	cinfo.err = jpeg_std_error(&jerr.pub);  jerr.pub.error_exit = my_error_exit;  /* Establish the setjmp return context for my_error_exit to use. */  if (setjmp(jerr.setjmp_buffer)) {    /* If we get here, the JPEG code has signaled an error.     * We need to clean up the JPEG object, close the input file, and return.     */    jpeg_destroy_compress(&cinfo);
    _GF_ free(mblock.data);
    if(outfile!=NULL)	    fclose(outfile);    return 0;  }  /* Now we can initialize the JPEG compression object. */  jpeg_create_compress(&cinfo);  /* Step 2: specify data destination (eg, a file) */  if ((outfile = fopen(filename, "wb")) == NULL) {
  	_GF_ form_alert(1,"[3][JPEG-module:|Can't open output-file.][Cancel]");    return(0);  }  jpeg_stdio_dest(&cinfo, outfile);  /* Step 3: set parameters for compression */  /* First we supply a description of the input image.   * Four fields of the cinfo struct must be filled in:   */  cinfo.image_width = dd->width; 	/* image width and height, in pixels */  cinfo.image_height = dd->height;
  if(ex_format==SUP8G)
  {/* 8 Bit Grayscale */
 	  cinfo.input_components = 1;		/* # of color components per pixel */		cinfo.in_color_space = JCS_GRAYSCALE; 	/* colorspace of input image */
 }
  else
  { /* 24 Bit RGB */	  cinfo.input_components = 3;		/* # of color components per pixel */		cinfo.in_color_space = JCS_RGB; 	/* colorspace of input image */
	}  /* Now use the library's routine to set default compression parameters.   * (You must set at least cinfo.in_color_space before calling this,   * since the defaults depend on the source color space.)   */  jpeg_set_defaults(&cinfo);  /* Now you can set any non-default parameters you wish to.   * Here we just illustrate the use of quality (quantization table) scaling:   */
	/* Baseline ? */
  if(options[0]==1)	  jpeg_set_quality(&cinfo, quality, TRUE /* limit to baseline-JPEG values */);
	else	  jpeg_set_quality(&cinfo, quality, FALSE);
	/* Progressive ? */
	if(options[1]==1)
		jpeg_simple_progression(&cinfo);
		
	/* Fast ? */
	if(options[2]==0) /* No, slow */
		cinfo.dct_method=JDCT_ISLOW;
	else
		cinfo.dct_method=JDCT_IFAST;
		
	/* Optimize Huffman tables? */
	if(options[3]==0) /* No */
		cinfo.optimize_coding=FALSE;
	else
		cinfo.optimize_coding=TRUE;

	/* Smooth? */
	cinfo.smoothing_factor=options[4]*10;
	  /* Step 4: Start compressor */  /* TRUE ensures that we will write a complete interchange-JPEG file.   * Pass TRUE unless you are very sure of what you're doing.   */  jpeg_start_compress(&cinfo, TRUE);  /* Step 5: while (scan lines remain to be written) */  /*           jpeg_write_scanlines(...); */  /* Here we use the library's state variable cinfo.next_scanline as the   * loop counter, so that we don't have to keep track ourselves.   * To keep things simple, we pass one scanline per call; you can pass   * more if you wish, though.   */
  while (cinfo.next_scanline < cinfo.image_height) {    /* jpeg_write_scanlines expects an array of pointers to scanlines.     * Here the array is only one element long, but you could pass     * more than one scanline at a time if that's more convenient.     */
     _GF_ get_block(&mblock, dd);    (void) jpeg_write_scanlines(&cinfo, row_pointer, 1);
    ++mblock.y;  }  /* Step 6: Finish compression */  jpeg_finish_compress(&cinfo);  /* After finish_compress, we can close the output file. */  fclose(outfile);  /* Step 7: release JPEG compression object */  /* This is an important step since it will release a good deal of memory. */  jpeg_destroy_compress(&cinfo);
	_GF_ free(mblock.data);  /* And we're done! */
  return(1);}/* * SOME FINE POINTS: * * In the above loop, we ignored the return value of jpeg_write_scanlines, * which is the number of scanlines actually written.  We could get away * with this because we were only relying on the value of cinfo.next_scanline, * which will be incremented correctly.  If you maintain additional loop * variables then you should be careful to increment them properly. * Actually, for output to a stdio stream you needn't worry, because * then jpeg_write_scanlines will write all the lines passed (or else exit * with a fatal error).  Partial writes can only occur if you use a data * destination module that can demand suspension of the compressor. * (If you don't know what that's for, you don't need it.) * * If the compressor requires full-image buffers (for entropy-coding * optimization or a multi-scan JPEG file), it will create temporary * files for anything that doesn't fit within the maximum-memory setting. * (Note that temp files are NOT needed if you use the default parameters.) * On some systems you may need to set up a signal handler to ensure that * temporary files are deleted if the program is interrupted.  See libjpeg.doc. * * Scanlines MUST be supplied in top-to-bottom order if you want your JPEG * files to be compatible with everyone else's.  If you cannot readily read * your data in that order, you'll need an intermediate array to hold the * image.  See rdtarga.c or rdbmp.c for examples of handling bottom-to-top * source data using the JPEG code's internal virtual-array mechanisms. *//******************** JPEG DECOMPRESSION SAMPLE INTERFACE *******************//* * Sample routine for JPEG decompression.  We assume that the source file name * is passed in.  We want to return 1 on success, 0 on error. */GLOBAL(int)read_JPEG_file (char * filename, GRAPE_DSCR *dd){
  struct jpeg_decompress_struct cinfo;  struct my_error_mgr jerr;  /* We use our private extension JPEG error handler. */  FILE * infile;		/* source file */  JSAMPARRAY buffer;		/* Output row buffer */
  BLOCK_DSCR	my_block;  int row_stride;		/* physical row width in output buffer */
  if ((infile = fopen(filename, "rb")) == NULL) {		/* This shouldn't happen, since the file was opened by Grape, so
			opening should be no problem */
   	_GF_ form_alert(1,"[3][JPEG-module:|Can't open input-file.][Cancel]");   return 0;  }  /* Step 1: allocate and initialize JPEG decompression object */  /* We set up the normal JPEG error routines, then override error_exit. */  cinfo.err = jpeg_std_error(&jerr.pub);  jerr.pub.error_exit = my_error_exit;  /* Establish the setjmp return context for my_error_exit to use. */  if (setjmp(jerr.setjmp_buffer)) {    /* If we get here, the JPEG code has signaled an error.     * We need to clean up the JPEG object, close the input file, and return.     */    jpeg_destroy_decompress(&cinfo);    fclose(infile);    return 0;  }  /* Now we can initialize the JPEG decompression object. */  jpeg_create_decompress(&cinfo);  /* Step 2: specify data source (eg, a file) */  jpeg_stdio_src(&cinfo, infile);  /* Step 3: read file parameters with jpeg_read_header() */  (void) jpeg_read_header(&cinfo, TRUE);  /* Step 4: set parameters for decompression */
  /* If a mask is loaded, force JPEG-Lib to output grayscale */	if(dd->mask != NULL)
		cinfo.out_color_space=JCS_GRAYSCALE;
		
  /* Step 5: Start decompressor */  (void) jpeg_start_decompress(&cinfo);  /* We may need to do some setup of our own at this point before reading   * the data.  After jpeg_start_decompress() we have the correct scaled   * output image dimensions available, as well as the output colormap   * if we asked for color quantization.   * In this example, we need to make an output work buffer of the right size.   */ 
	/* Setup my_block */
  if(cinfo.output_components==3)
  {
		my_block.format=B24;
		my_block.subcode=B24_RGBPP;
	}
	else
	{
		my_block.format=B8;
		my_block.subcode=B8_GBWPP;
	}
		
	/* data is assigned a few lines below */
	my_block.width=cinfo.output_width;
	my_block.height=cinfo.output_height;
	my_block.x=my_block.y=0;
	my_block.w=my_block.lw=my_block.width;
	my_block.h=1;
	  /* JSAMPLEs per row in output buffer */  row_stride = cinfo.output_width * cinfo.output_components;  /* Make a one-row-high sample array that will go away when done with image */  buffer = (*cinfo.mem->alloc_sarray)		((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);  my_block.data=(uchar*)(buffer[0]);

  /* Step 6: while (scan lines remain to be read) */  /*           jpeg_read_scanlines(...); */  /* Here we use the library's state variable cinfo.output_scanline as the   * loop counter, so that we don't have to keep track ourselves.   */  while (cinfo.output_scanline < cinfo.output_height) {    /* jpeg_read_scanlines expects an array of pointers to scanlines.     * Here the array is only one element long, but you could ask for     * more than one scanline at a time if that's more convenient.     */    (void) jpeg_read_scanlines(&cinfo, buffer, 1);    /* Assume put_scanline_someplace wants a pointer and sample count. */		_GF_ store_block(&my_block, dd);
		++my_block.y;

  }  /* Step 7: Finish decompression */  (void) jpeg_finish_decompress(&cinfo);  /* We can ignore the return value since suspension is not possible   * with the stdio data source.   */  /* Step 8: Release JPEG decompression object */  /* This is an important step since it will release a good deal of memory. */  jpeg_destroy_decompress(&cinfo);  /* After finish_decompress, we can close the input file.   * Here we postpone it until after no more JPEG errors are possible,   * so as to simplify the setjmp error logic above.  (Actually, I don't   * think that jpeg_destroy can do an error exit, but why assume anything...)   */  fclose(infile);  /* At this point you may want to check to see whether any corrupt-data   * warnings occurred (test whether jerr.pub.num_warnings is nonzero).   */  /* And we're done! */  return 1;}