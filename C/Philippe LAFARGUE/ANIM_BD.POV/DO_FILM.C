/*	*******************************************************
	Assemblage d'images TGA pour animations Before Dawn
	Philippe LAFARGUE F‚vrier 1994
	*******************************************************
*/

/*	Usage do_film.ttp nom nn	( 0 < nn < 100 )	*/	

#include	<stdio.h>
#include	<stdlib.h>
#include	<setjmp.h>
#include	<tos.h>

void  *memset( void *s, int val, size_t len );

#define MAX_IMAGES	99

/*	Constantes fichier Targa	*/
#define	SIZE_HEADER	18		/*	taille en-tete fichier TARGA */
#define MAXXRES		2048	/* huge max x resolution allowable, infinite y res. */
#define REVERSE(a)	(((a>>8)&0xFF)+((a&0xFF)<<8))

char	*nomf,nomfich[256];
int		nb_images,in_w,in_h,out_w,out_h,append;
long	seek_out;

FILE	*in,*out;

typedef struct tga_head {
	char a[12];	
	int	w,h;
	char b[2];
}TGA_HEAD;

TGA_HEAD head_in;

TGA_HEAD head_out = {
	{	0,0,2,
		0,0,0,0, 0,0,0,0, 0,
	},
	0,0,
	{	24,32	}
};

int write_header(FILE *fdest,int w,int h)
{	long	nb;

/*	On initialise l'entete du fichier Targa */

	w=REVERSE(w);
	h=REVERSE(h);
	head_out.w = w;
	head_out.h = h;
	nb = fwrite(&head_out,SIZE_HEADER,1L,fdest);

	return (nb != 1L);
}

void usage(void)
{
	printf("Usage : Do_film.ttp nomfich nombre\n");
}

/*	Traitement erreurs	*/
enum { OK=0,NO_PARAMS,NO_FICH,ERR_READ,ERR_WRITE,ERR_NUMBER,ERR_MEM,ERR_FICH	};

void traite_erreur(int err)
{
	switch(err)
	{	case NO_PARAMS:		usage();							break;
		case NO_FICH:		printf("Fichier %s inexistant..\n",nomfich);	break;
		case ERR_READ:		printf("Erreur de lecture..\n");	break;
		case ERR_WRITE:		printf("Erreur d'ecriture..\n");	break;
		case ERR_NUMBER:	printf("Nombre d'images incorrect..\n");	break;
		case ERR_MEM:		printf("Pas assez de m‚moire..\n");	break;
		case ERR_FICH:		printf("Fichier %s incorrect..\n");	break;
	}
	exit(1);
}

int cree_out(void)
{	size_t	nb;
	char	*buf;

/*	Lit 1er fichier	et en deduit la taille du fichier resultat	*/
	sprintf(nomfich,"%s%d.TGA",nomf,1);
	in = fopen(nomfich,"rb");
	if (in == NULL)	return NO_FICH;

	nb = fread(&head_in,SIZE_HEADER,1L,in);
	if (nb != 1L)	return ERR_READ;
	fclose(in);

	in_h = REVERSE(head_in.h);
	in_w = REVERSE(head_in.w);
	out_h = in_h;
	out_w = in_w * nb_images;

/*	Regarde si le fichier existe deja et s'il est de meme largeur	*/
	sprintf(nomfich,"%s.TGA",nomf);
	out = fopen(nomfich,"rb");
	if (out != NULL)
	{	nb = fread(&head_out,SIZE_HEADER,1L,out);
		if (nb != 1L)	return ERR_FICH;
		if ( REVERSE(head_out.w) != out_w)		return ERR_FICH;
		if ((REVERSE(head_out.h) %  in_h)!=0)	return ERR_FICH;
		seek_out = SIZE_HEADER + ((long)REVERSE(head_out.w) * (long)REVERSE(head_out.h) * 3L);
		fclose(out);
		out_h  += REVERSE(head_out.h);
		append = 1;
	}
	else
	{	seek_out = SIZE_HEADER;
		append = 0;
	}

/*	Ecrit un fichier blanc de la taille requise */

	out = fopen(nomfich,(append)?"ab+":"wb");
	if (out == NULL)	return ERR_WRITE;
	if (append)	fseek(out,0L,SEEK_SET);
	write_header(out,out_w,out_h);

	if (append)	fseek(out,0L,SEEK_END);
	buf = malloc((size_t)out_w*3L);
	if (buf == NULL)	return ERR_MEM;
	memset(buf,0,(size_t)out_w*3L);

	nb = fwrite(buf,(size_t)out_w*3L,(size_t)in_h,out);
	if (nb != (size_t)in_h)	return ERR_WRITE;

	free(buf);

	return OK;
}

char buffer[MAXXRES][3];

void main(int argc,char *argv[])
{	jmp_buf env;
	int	ret,i,j;
	size_t	nb;

	ret = setjmp(env);
	if (ret != OK) traite_erreur(ret);

	if (argc < 3)	traite_erreur(NO_PARAMS);

	nomf = argv[1];
	nb_images = atoi(argv[2]);
	if (nb_images < 1 || nb_images > MAX_IMAGES)	traite_erreur(ERR_NUMBER);

	ret = cree_out();
	if (ret != OK) traite_erreur(ret);

	for(i=0;	i<nb_images;	i+=1)
	{
/*	Ouvre la Ieme image	*/
		sprintf(nomfich,"%s%d.TGA",nomf,i+1);
		in = fopen(nomfich,"rb");
		if (in == NULL)	traite_erreur(NO_FICH);

/*	Position lecture apres en-tete	*/
		fseek(in,SIZE_HEADER,SEEK_SET);

/*	Lecture du fichier et ecriture dans fichier resultat	*/
		for(j=0;	j<in_h;	j+=1)
		{
/*	Lit une ligne du fichier d'entree	*/
			nb = fread(buffer,(size_t)in_w*3L,1L,in);
			if (nb != 1L)	traite_erreur(ERR_READ);

/*	Se positionne dans le fichier sortie et ecrit buffer	*/
			fseek(out,seek_out+
					((long)j*(long)out_w*3L)+
					((long)i*(long)in_w*3L),	SEEK_SET);
			nb = fwrite(buffer,(size_t)in_w*3L,1L,out);
			if (nb != 1L)	traite_erreur(ERR_WRITE);
		}
		fclose(in);
	}

	fclose(out);
	exit(0);
}
