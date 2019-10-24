/* structure interne de gestion d'un sample */

typedef struct
{
	int				numBits;			/* Nombre de bits */
	int				numBytes;			/* Nombre d'octets par samples */
	int				numVoices;			/* Nombre de cannaux */
	int				intel;				/* 1=format intel */
	unsigned long	numFrames;			/* Nombre de sample par voix */
	unsigned long	Length;				/* Taille en octets = (numFrames*numVoices*numBits)/8 */
	long double		Frequence;			/* Frequence */
	long			start_offset;		/* Debut dans le fichier */
}FALCON_SPL;

int open_sample(char *sample_name,FALCON_SPL *datas,unsigned long position);
