#include	<stdio.h>
#include	<string.h>
#include	<tos.h>
#include	<vdi.h>		/* needed only for MFDB declaration in jpgdh.h */
#include	"jpgdh.h"

#define	unused(x)	(x)=(x)

typedef struct {
	long	magic;
	long	data;
} COOKIE_STRUCT;
typedef	COOKIE_STRUCT	*COOKIE_PTR;

long	GetJar(void);
short	GetCookie(long,long *);
short	JPGDecode(JPGDDRV_PTR,char *,char *);

long	GetJar()
{
	return(*(long *)0x5a0);
}

short	GetCookie(long magic,long *data)
{
	short	err=-1;
	COOKIE_PTR	cookie;

	if ((cookie=(COOKIE_PTR *)Supexec((long)GetJar))!=NULL) {	/* Cookie jar present */
		while ((cookie->magic)!=0L) {	/* End not reached */
			if ((cookie->magic)==magic) {
				*data=cookie->data;
				err=0;
				break;
			}
			cookie++;
		}
	}
	return(err);
}

short	UserRoutine(JPGD_PTR jpgd)
{
	unused(jpgd);
	Cconout('.');
	return(0);
}

short	JPGDecode(JPGDDRV_PTR drv,char *srcname,char *dstname)
{
	short	err;
	DTA	dta,*olddta;
	FILE	*fd;

	long	jpgdsize;
	JPGD_PTR	jpgd;

	long	srcsize;
	void	*src;
	char	pad[]={-1,-1,-1,-1,-1,-1,-1,-1,0,0};

/*	** Only if decoding to memory **
	long	dstsize;
	void	*dst;
*/

	olddta=Fgetdta();
	Fsetdta(&dta);
	err=Fsfirst(srcname,0x22);
	Fsetdta(olddta);
	if (err) {
		printf("File %s not found.\n",srcname);
		return(-2);
	}
	printf("Loading picture %s...\n",srcname);
	srcsize=dta.d_length;			/* JPEG file size */
	if ((srcsize==0L) || (src=malloc(srcsize+sizeof(pad)))==NULL) {	/* +8 for padding */
		puts("Can't allocate JPEG Picture.");
		return(-3);
	}

	if ((fd=fopen(srcname,"rb"))==NULL) {
		printf("Can't open file %s.\n",srcname);
		return(-2);
	}
	if (fread(src,srcsize,1L,fd)!=1L) {
		printf("Read error in file %s.\n",srcname);
		return(-4);
	}
	fclose(fd);

	memcpy((char *)src+srcsize,pad,sizeof(pad));	/* padding */

	jpgdsize=JPGDGetStructSize(drv);	/* JPGD struct size */
	if ((jpgdsize==0L) || ((jpgd=malloc(jpgdsize))==NULL)) {
		puts("Can't allocate JPEG Decoder structure.");
		return(-5);
	}
	memset(jpgd,0,jpgdsize);		/**** CLEAR STRUCT ****/
	if ((err=JPGDOpenDriver(drv,jpgd))!=0) {
		printf("Error opening JPEG Decoder driver: %d\n",err);
		return(err);
	}
	jpgd->InPointer=src;			/* JPEG file ptr */
	jpgd->InSize=srcsize;			/* JPEG file size */
	if ((err=JPGDGetImageInfo(drv,jpgd))!=0) {
		printf("Error getting image info: %d\n",err);
		return(err);
	}

	jpgd->OutComponents=3;			/* RGB */
	jpgd->OutPixelSize=3;			/* 24 bits */
	if ((err=JPGDGetImageSize(drv,jpgd))!=0) {	/* Always do it */
		printf("Error getting image size: %d\n",err);
		return(err);
	}

/*	** This is needed if decoding to memory **
	dstsize=jpgd->OutSize;
	if ((dstsize==0L) || ((dst=malloc(dstsize))==NULL)) {
		puts("Can't allocate destination picture.");
		free(jpgd);
		return(-2);
	}
	jpgd->OutPointer=dst;
*/
	/* Otherwise decode to disk */
	jpgd->OutFlag=-1;			/* Output to disk */
	jpgd->UserRoutine=UserRoutine;		/* User Routine */
	jpgd->OutPointer=dstname;		/* Could stay NULL */
	printf("Decoding picture %s into %s ",srcname,dstname);
	if ((err=JPGDDecodeImage(drv,jpgd))!=0) {
		printf("\nError decoding picture %s into %s: %d\n",srcname,dstname,err);
		return(err);
	}
	if ((err=JPGDCloseDriver(drv,jpgd))!=0) {
		printf("\nError closing JPEG Decoder driver: %d\n",err);
		return(err);
	}
	free(src);	/* release jpeg picture */
	puts("Done.");

/*	Use image here if decoding to memory */

	free(jpgd);	/* release decoder structure */
/*	free(dst);*/	/* Only if image in memory */
	return(0);
}

main(short argc,char **argv)
{
	short	err;
	JPGDDRV_PTR	drv;
	char	*dstname;

	if (GetCookie(JPGD_MAGIC,(long *)&drv)) {	/* get decoder struct @ */
		puts("JPEG Decoder driver not installed.");
		return(-1);
	}
	if (argc<2) {
		puts("Sample use of JPEG cookie decoder.\nUsage: disk <srcname> [dstname].");
		return(0);
	}
	if (argc>2)
		dstname=argv[2];
	else
		dstname="OUTPUT.TGA";
	err=JPGDecode(drv,argv[1],dstname);
	Crawcin();
	return(err);
}
