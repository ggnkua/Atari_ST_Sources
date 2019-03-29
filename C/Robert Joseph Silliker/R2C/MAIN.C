/***************************************************/
/*  						   */
/*  		     RSCTOC  V1.0		   */
/*  						   */
/*  Copyright (c) 1988, by Robert Joseph Silliker  */
/*  		  All Rights Reserved   	   */
/*  	Permission is granted for unrestricted     */
/*  		 non-commercial use		   */
/*  						   */
/***************************************************/

#include <stdio.h>
#include <fcntl.h>
#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

static char *copyright[] = "RSCTOC V1.0\nCopyright (c) 1988, by\
 Robert Joseph Silliker\nAll Rights Reserved\n\
 Permission is granted for unrestricted non-commercial use\n";

long _stksize = 16000;

RSHDR *rschead;			/* Pointer to the resource file header. */
char *out_path = NULL;		/* Path to output file. */
char *rsc_path = NULL;		/* Path to input file.  */
FILE *fp = stdout;		/* Default output file. */
char *prefix= "";		/* Prefix to the names of arrays. */

#define MAXTREES 512		/* Maximum number of object trees per file. */

OBJECT *objects;		/* Pointer to the base of the objects. */
OBJECT *trindex[MAXTREES];	/* One pointer per object tree. */

char *progname = "rsctoc.ttp";	/* Program name (no argv[0]) */


main(argc, argv)
int argc;
char *argv[];
{
  int i;
  extern char *rsc_path, *out_path, *prefix;
  extern FILE *fp;
  
  if((argc != 2) && (argc != 4) && (argc != 6))
    usage("Incorrect number of arguments.");

  rsc_path = argv[1];

  for(i=2; i<argc; i+=2) {	    /* This lets option arguments like */
    if(!strcmp(argv[i], "-p"))	    /* rsctoc.ttp rsc_file -f file1 -f file2 */
      prefix = argv[i+1];	    /* rsctoc.ttp rsc_file -p XXXX -p YYYY */
    else if(!strcmp(argv[i], "-o")) /* without a usage error. */
      out_path = argv[i+1];
    else
      usage("Illegal option.");
  }

  if(!init_prog()) {
    put_header();
    make_tedinfo();
    make_icon();
    make_bitblk();
    make_object();
    make_index();
    make_fix();
  }

  clean_up();
}


/*----------------------------------------*/
/* Output the usage message and terminate */
/* the program.                           */
/*----------------------------------------*/

usage(s)
char *s;
{
  extern char *progname;

  if(s)
    fprintf(stderr, "%s: %s\n", progname, s);

  fprintf(stderr, "Usage: %s rsc_file [-p prefix] [-o outfile]\n", progname);

  exit(2);
}


/*-------------------------------------------*/
/* Output an error message and terminate the */
/* program gracefully if the caller sets the */
/* terminate flag.  The value of the flag    */
/* used to terminate is returned by the      */
/* program.                                  */
/*-------------------------------------------*/

mperror(terminate, s)
int terminate;
char *s;
{
  extern char *progname;

  fprintf(stderr, "%s: %s\n", progname, s);

  if(terminate) {
    clean_up();
    exit(terminate);
  }
}


/*-------------------------*/
/* Initialize the program. */
/*-------------------------*/

int init_prog()
{
  int i;
  extern char *rsc_path, *out_path;
  extern FILE *fp;
  extern RSHDR *rschead;

  if(!myrsrc_load(rsc_path))
    mperror(1, "Error getting resource file.");

  if(out_path != NULL) {
    if((fp = fopen(out_path, "w")) == NULL)
      mperror(1, "Can't open output file.");
  }

  if(rschead->rsh_nobs <= 0)
    mperror(1, "No object trees to dump.");

  return(0);
}


/*--------------------------------------------*/
/* Clean up open files, close the workstation */
/* and close the aes application.             */
/*--------------------------------------------*/

clean_up()
{
  extern FILE *fp;

  if((fp != stdout) && (fp != NULL))
    fclose(fp);
}


/*------------------------------*/
/* Extract tedinfo information. */
/*------------------------------*/

make_tedinfo()
{
  int i, first_one;
  register OBJECT *g;
  TEDINFO *t;
  extern char *prefix;
  extern FILE *fp;
  extern OBJECT *objects;
  extern RSHDR *rschead;

  fprintf(fp, "TEDINFO %srs_tedinfo[] = {\n", prefix);

  for(i=0, first_one=1, g=objects; i < rschead->rsh_nobs; i++, g++) {
    if(g->ob_type == G_FTEXT || g->ob_type == G_FBOXTEXT ||
       g->ob_type == G_TEXT  || g->ob_type == G_BOXTEXT) {

      if(first_one) {
  	first_one = 0;
      }
      else
        fprintf(fp, ",\n");

      t = (TEDINFO *)(g->ob_spec);

      if(strlen(t->te_ptext))
        fprintf(fp, "  {\"%s\", ", t->te_ptext);
      else
        fprintf(fp, "  {%sp_to_nul, ", prefix);

      if(strlen(t->te_ptmplt))
        fprintf(fp, "\"%s\", ", t->te_ptmplt);
      else
        fprintf(fp, "%sp_to_nul, ", prefix);

      if(strlen(t->te_pvalid))
        fprintf(fp, "\"%s\",\n  ", t->te_pvalid);
      else
        fprintf(fp, "%sp_to_nul,\n   ", prefix);

      fprintf(fp, "%3d, ", t->te_font);
      fprintf(fp, "%3d, ", t->te_junk1);
      fprintf(fp, "%3d, ", t->te_just);
      fprintf(fp, "%3d, ", t->te_color);
      fprintf(fp, "%3d, ", t->te_junk2);
      fprintf(fp, "%3d, ", t->te_thickness);
      fprintf(fp, "%3d, ", t->te_txtlen);
      fprintf(fp, "%3d}", t->te_tmplen);
    }
  }

  if(!first_one)
    fprintf(fp, "\n};\n\n");
  else
    fprintf(fp, "  0L\n};\n\n");
}


/*---------------------------*/
/* Extract icon information. */
/*---------------------------*/

make_icon()
{
  int i, j, k, numb;
  int first_one, *p;
  register OBJECT *g;
  extern char *prefix;
  ICONBLK *icon;
  extern FILE *fp;
  extern OBJECT *objects;
  extern RSHDR *rschead;

  for(i=0, numb=0, g=objects; i < rschead->rsh_nobs; i++, g++) {
    /*----------------------*/
    /* First do the images. */
    /*----------------------*/

    if(g->ob_type == G_ICON) {
      icon = (ICONBLK *)(g->ob_spec);

      fprintf(fp, "int %simask%03d[] = {", prefix, numb);
      k = icon->ib_hicon * (icon->ib_wicon/16);

      for(j=0, p=icon->ib_pmask; k > 0; j++, p++, k--) {
        if(!(j % 8))
          fprintf(fp, "\n  ");
        fprintf(fp, "0x%04x", *p);

	if(k != 1)
          fprintf(fp, ",");
      }
      fprintf(fp, "\n};\n\n");

      fprintf(fp, "int %sidata%03d[] = {", prefix, numb);
      k = icon->ib_hicon * (icon->ib_wicon/16);

      for(j=0, p=icon->ib_pdata; k > 0; j++, p++, k--) {
        if(!(j % 8))
	  fprintf(fp, "\n   ");
        fprintf(fp, "0x%04x", *p);

        if(k != 1)
	  fprintf(fp, ",");
      }

      fprintf(fp, "\n};\n\n");
      numb++;
    }
  }
 
  fprintf(fp, "ICONBLK %srs_iconblk[] = {\n", prefix);

  for(i=0, numb=0, g=objects, first_one=1; i < rschead->rsh_nobs; i++, g++) {
    /*-----------------------------*/
    /* Now do the icon structures. */
    /*-----------------------------*/

    if(g->ob_type == G_ICON) {

      if(first_one)
        first_one = 0;
      else
        fprintf(fp, ",\n");

      icon = (ICONBLK *)(g->ob_spec);

      fprintf(fp, "  {%simask%03d, %sidata%03d, ", prefix, numb, prefix, numb);

      if(strlen(icon->ib_ptext))
        fprintf(fp, "\"%s\",\n", icon->ib_ptext);
      else
        fprintf(fp, "%sp_to_nul, \n", prefix);

      fprintf(fp, "   0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x,\n",
	          icon->ib_char, icon->ib_xchar, icon->ib_ychar,
                  icon->ib_xicon, icon->ib_yicon, icon->ib_wicon);

      fprintf(fp, "   0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x}",
		  icon->ib_hicon, icon->ib_xtext, icon->ib_ytext,
		  icon->ib_wtext, icon->ib_htext);
      numb++;
    }
  }

  if(!first_one)
    fprintf(fp, "\n};\n\n");
  else
    fprintf(fp, "  0L\n};\n\n");
}



/*-----------------------------*/
/* Extract bitblk information. */
/*-----------------------------*/

make_bitblk()
{
  int i, j, k, numb;
  int first_one, *p;
  register OBJECT *g;
  BITBLK *bitblk;
  extern char *prefix;
  extern FILE *fp;
  extern OBJECT *objects;
  extern RSHDR *rschead;

  for(i=0, numb=0, g=objects; i < rschead->rsh_nobs; i++, g++) {
    /*----------------------*/
    /* First do the images. */
    /*----------------------*/

    if(g->ob_type == G_IMAGE) {
      bitblk = (BITBLK *)(g->ob_spec);

      fprintf(fp, "int %sbblock%03d[] = {", prefix, numb);
      k = bitblk->bi_hl * (bitblk->bi_wb/2);

      for(j=0, p=bitblk->bi_pdata; k > 0; j++, p++, k--) {
        if(!(j % 8))
          fprintf(fp, "\n  ");
        fprintf(fp, "0x%04x", *p);

	if(k != 1)
          fprintf(fp, ",");
      }
      fprintf(fp, "\n};\n\n");

      numb++;
    }
  }

  fprintf(fp, "BITBLK %srs_bitblk[] = {\n", prefix);
 
  for(i=0, numb=0, g=objects, first_one=1; i < rschead->rsh_nobs; i++, g++) {
    /*-------------------------------*/
    /* Now do the bitblk structures. */
    /*-------------------------------*/

    if(g->ob_type == G_IMAGE) {

      if(first_one)
        first_one = 0;
      else
        fprintf(fp, ",\n");

      bitblk = (BITBLK *)(g->ob_spec);

      fprintf(fp, "  {%sbblock%03d, ", prefix, numb);

      fprintf(fp, " 0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x}",
	                    bitblk->bi_wb, bitblk->bi_hl, bitblk->bi_x,
                            bitblk->bi_y, bitblk->bi_color);

      numb++;
    }
  }

  if(!first_one)
    fprintf(fp, "\n};\n\n");
  else
    fprintf(fp, "  0L\n};\n\n");
}


/*-----------------------------------------------*/
/* Extract object information and change into C. */
/*-----------------------------------------------*/

make_object()
{
  int i, ic, bb, ted;
  int first_one;
  register OBJECT *g;
  extern char *prefix;
  extern FILE *fp;
  extern OBJECT *objects;
  extern RSHDR *rschead;

  for(i=0,ic=0,bb=0,ted=0,g=objects,first_one=1; i<rschead->rsh_nobs;i++,g++) {
    if(first_one) {
      fprintf(fp, "OBJECT %srs_object[] = {\n", prefix);
      first_one = 0;
    }
    else
      fprintf(fp, ",\n");

    print_index_comment(g);

    fprintf(fp, "  {%4d,%4d,%4d,0x%04x,0x%04x,0x%04x, ",
                                g->ob_next, g->ob_head, g->ob_tail,
                                g->ob_type, g->ob_flags, g->ob_state);

    if(g->ob_type == G_STRING || g->ob_type == G_TITLE
                              || g->ob_type == G_BUTTON) {

      if(strlen(g->ob_spec))
        fprintf(fp, "\"%s\",", g->ob_spec);
      else
        fprintf(fp, "%sp_to_nul,", prefix);
    }
    else if(g->ob_type == G_FTEXT || g->ob_type == G_FBOXTEXT
                                  || g->ob_type == G_TEXT
                                  || g->ob_type == G_BOXTEXT) {
      fprintf(fp, "\&%srs_tedinfo[%d],", prefix, ted);
      ted++;
    }
    else if(g->ob_type == G_ICON) {
      fprintf(fp, "\&%srs_iconblk[%d],", prefix, ic);
      ic++;
    }
    else if(g->ob_type == G_IMAGE) {
      fprintf(fp, "\&%srs_bitblk[%d],", prefix, bb);
      bb++;
    }
    else
      fprintf(fp, "0x%08lxL,", g->ob_spec);

    fprintf(fp, "%4d,%4d,%4d,%4d}",
		g->ob_x, g->ob_y, g->ob_width, g->ob_height);
  }

  if(!first_one)
    fprintf(fp, "\n};\n\n");
}


/*-----------------------------------------------*/
/* Build the array of tree pointers and generate */
/* the structure size macros.                    */
/*-----------------------------------------------*/

make_index()
{
  int i, index, first_one;
  extern char *prefix;
  extern FILE *fp;
  extern OBJECT *objects, *trindex[];
  extern RSHDR *rschead;

  for(i=0, first_one=1; i < rschead->rsh_ntree; i++) {
    if(first_one) {
      fprintf(fp, "OBJECT *%srs_trindex[] = {\n", prefix);
      first_one = 0;
    }
    else
      fprintf(fp, ",\n");

    index = (trindex[i] - objects);

    fprintf(fp, "  &%srs_object[%d]", prefix, index);
  }
  if(!first_one)
    fprintf(fp, "\n};\n\n");

  fprintf(fp, "#define %sNUM_TI %d\n", prefix, rschead->rsh_nted);
  fprintf(fp, "#define %sNUM_IB %d\n", prefix, rschead->rsh_nib);
  fprintf(fp, "#define %sNUM_BB %d\n", prefix, rschead->rsh_nbb);
  fprintf(fp, "#define %sNUM_OBS %d\n", prefix, rschead->rsh_nobs);
  fprintf(fp, "#define %sNUM_TREE %d\n\n\n", prefix, rschead->rsh_ntree);
}


/*------------------------------------------------------*/
/* Output the include #ifdef for the object definition  */
/* header file.  Output a single NUL character pointer  */
/* into the C source.  This will be used as the pointer */
/* to an empty character string wherever strings have   */
/* zero length.                                         */
/*------------------------------------------------------*/

put_header()
{
  extern FILE *fp;

  fprintf(fp, "#ifndef OBJECT\n");
  fprintf(fp, "#include <obdefs.h>\n");
  fprintf(fp, "#endif\n\n");
  fprintf(fp, "static char %sp_to_nul[1] = \"\";\n\n", prefix);
}


/*-------------------------------------------*/
/* Output code that will fix up the objects. */
/*-------------------------------------------*/

make_fix()
{
  extern char *prefix;
  extern FILE *fp;

  fprintf(fp, "%sfix_objects()\n{\n", prefix);
  fprintf(fp, "  register int i;\n\n");
  fprintf(fp, "  for(i=0; i<%sNUM_OBS; i++)\n", prefix);
  fprintf(fp, "    rsrc_obfix(%srs_object, i);\n", prefix);
  fprintf(fp, "}\n\n");
}


/*--------------------------------*/
/* Open and read in the rsc file. */
/* Then call the routine to fix   */
/* the object pointers.           */
/*--------------------------------*/

char *pbase;			/* Pointer to base of file in memory */
#define BLKSIZE 8192		/* Number of bytes per read call */
				/* Don't make this larger than 32767 */

myrsrc_load(path)
char *path;
{
  long fsize, lseek();
  int rsc, size;
  char *p;
  extern char *pbase;

  if((rsc = open(path, O_RDONLY | O_BINARY)) < 0) {
    fprintf(stderr, "%s: Can't open '%s'.\n", progname, path);
    return(0);
  }

  if((fsize = lseek(rsc, 0L, 2)) < 0)
    return(0);

  lseek(rsc, 0L, 0);

  if(fsize < sizeof(RSHDR)) {
    fprintf(stderr, "%s: Resource file is too small.\n", progname);
    close(rsc);
    return(0);
  }

  p = pbase = (char *)(Malloc(fsize));
  if(pbase == NULL) {
    fprintf(stderr, "%s: Not enough memory.\n", progname);
    close(rsc);
    return(0);
  }

  do {
    size = (fsize >= BLKSIZE) ? BLKSIZE : (int)(fsize);
    if(read(rsc, p, size) != size) {
      fprintf(stderr, "%s: Read error on '$s'.\n", progname, path);
      Mfree(pbase);
      close(rsc);
      return(0);
    }
    p += size;
    fsize -= (long)(size);
  } while(fsize > 0L);

  close(rsc);

  fix_pointers();

  return(1);
}


/*------------------------------------------*/
/* Routine to fix up the resource pointers. */
/*------------------------------------------*/

fix_pointers()
{
  int i;
  long *t;
  extern char *pbase;
  extern OBJECT *objects, *trindex[];
  extern RSHDR *rschead;

  /*----------------------------------------------------*/
  /* Initialize the pointer to the resource file header */
  /* and a pointer to the base of the object array.     */
  /*----------------------------------------------------*/

  rschead = (RSHDR *)(pbase);
  objects = (OBJECT *)(pbase + rschead->rsh_object);

  t = (long *)(pbase + rschead->rsh_trindex);	/* Get pointer to trindex */

  for(i=0; i<rschead->rsh_ntree; i++)
    trindex[i] = (OBJECT *)(pbase + *(t+i));	/* Build tree pointer */

  /*---------------------------------------------------*/
  /* Fix all the objects.  No need to go into the maze */
  /* of head, tail, next because all objects are in a  */
  /* nice array of size 'rsh_nobs'.                    */
  /*---------------------------------------------------*/

  for(i=0; i<rschead->rsh_nobs; i++)
    fix_one_object(objects + i);
}


/*-------------------------------------*/
/* Fix up the pointers for one object. */
/*-------------------------------------*/

fix_one_object(g)
register OBJECT *g;
{
  TEDINFO *t;
  ICONBLK *icon;
  BITBLK *bitblk;
  extern char *pbase;

  switch(g->ob_type) {
    case(G_STRING):
    case(G_TITLE):
    case(G_BUTTON):
      g->ob_spec = (char *)(pbase + (long)(g->ob_spec));
      break;
    case(G_FTEXT):
    case(G_FBOXTEXT):
    case(G_TEXT):
    case(G_BOXTEXT):
      t = (TEDINFO *)(pbase + (long)(g->ob_spec));
      g->ob_spec = (char *)(t);
      t->te_ptext = (char *)(pbase + (long)(t->te_ptext));
      t->te_ptmplt = (char *)(pbase + (long)(t->te_ptmplt));
      t->te_pvalid = (char *)(pbase + (long)(t->te_pvalid));
      break;
    case(G_ICON):
      icon = (ICONBLK *)(pbase + (long)(g->ob_spec));
      g->ob_spec = (char *)(icon);
      icon->ib_pmask = (int *)(pbase + (long)(icon->ib_pmask));
      icon->ib_pdata = (int *)(pbase + (long)(icon->ib_pdata));
      icon->ib_ptext = (char *)(pbase + (long)(icon->ib_ptext));
      break;
    case(G_IMAGE):
      bitblk = (BITBLK *)(pbase + (long)(g->ob_spec));
      g->ob_spec = (char *)(bitblk);
      bitblk->bi_pdata = (int *)(pbase + (long)(bitblk->bi_pdata));
      break;
  }
}


/*---------------------------------*/
/* Print the rs_trindex[] comment. */
/*---------------------------------*/

print_index_comment(g)
OBJECT *g;
{
  register int i;
  extern OBJECT *trindex[];
  extern FILE *fp;
  extern RSHDR *rschead;

  for(i=0; i<rschead->rsh_ntree; i++) {
    if(trindex[i] == g)
      fprintf(fp, "  /* Tree #%d*/\n", i);
  }
}

/* END OF FILE */

