#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <ctype.h>

/********************************************************************
*																	*
*				R‚cupŠre le fichier sur le dernier cluster			*
*			Suite … un bug du TOS, ce fichier est inaccessible		*
*																	*
********************************************************************/

int main(void)
{
	unsigned int first_sector = 0;
	long size = 0;
	char device = 0;
	int size_in_sector = 0;
	char ligne[80], name[80] = "", *buff;
	int fd, err;
	BPB bpb;

	printf("R‚cup‚ration du fichier en fin de disque inaccessible avec le TOS 4.0?\nR‚alis‚ par Ludovic Rousseau le 7 Novembre 1993.\nMise … jour le 4 F‚vrier 1994.\n\n");

	printf("Premier secteur (d‚cimal) : ");
	gets(ligne);
	sscanf(ligne, "%u", &first_sector);

	printf("taille en octets : ");
	gets(ligne);
	sscanf(ligne, "%ld", &size);

	printf("device (lettre) : ");
	gets(ligne);
	sscanf(ligne, "%c", &device);
	device = toupper(device) - 'A';

	printf("nom complet de la copie : ");
	gets(name);

	printf("start %u, size %ld, device %c:, copie %s\nOK ? (O/N)", first_sector, size, device+'A', name);

	if ((Cconin() & 0xFF) != 'o')
		return 2;

	bpb = *Getbpb(device);

	size_in_sector = (int)((size + bpb.recsiz) / bpb.recsiz);
	if ((buff = malloc(size_in_sector * bpb.recsiz)) == NULL)
	{
		puts("Pas assez de m‚moire");
		return 1;
	}
	
	if ((err = (int)Rwabs(0, buff, size_in_sector, first_sector, device)) < 0)
	{
		printf("Error du Rwabs : %ld\n", err);
		return 1;
	}
	
	if ((fd = (int)Fcreate(name, 0)) < 0)
	{
		printf("Error du Fcreate : %d\n", fd);
		return 1;
	}

	Fwrite(fd, size, buff);
	Fclose(fd);

	free(buff);

	return 0;
} /* main */
