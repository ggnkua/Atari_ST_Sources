/* --------------------------------------------------------------- */
/* Ajoute les infos n‚cessaires au d‚package avec NOISEPAKKER	   */
/* --------------------------------------------------------------- */

#include	<vdi.h>
#include	<aes.h>
#include	<stdlib.h>
#include	<ext.h>
#include	<tos.h>
#include	<string.h>
#define		TRUE	1
#define		FALSE	0

extern	long LENGHT_NDPK(void *);
void	lecture_fichier(void);

/* --------------------------------------------------------------- */
/* Programme													   */
/* --------------------------------------------------------------- */

int main(void)
	{
	int	i,gr_handle,work_out[57],work_in[20];
	int	 fin;
	
	appl_init();
	for (i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	gr_handle=graf_handle(&i,&i,&i,&i);
	v_opnvwk(work_in,&gr_handle,work_out);
	graf_mouse(ARROW,0);
	fin=FALSE;

	while(!fin)
		{
		wind_update(BEG_UPDATE);
		lecture_fichier();
		if (form_alert(1,"[2][ |An other module ?][ Yes | No ]")==2) fin=TRUE;
		}

	v_clsvwk(gr_handle);
	appl_exit();
	return 0;
	}	


void lecture_fichier(void)
	{
	char 	name[14];
	char 	path[200];
	int 	result;
	void	*buffer;
	int		handle;
	void	*buf2;
	long	taille,t_lue;

	name[0]=0;
	path[0]=Dgetdrv()+'A';
	path[1]=':';
	Dgetpath(&path[2],0);
	strcat(path,"\\*.MOD");
	fsel_exinput(path,name,&result,"Packed Module...");
	wind_update(END_UPDATE);
	if	(!result) return;
	Dsetdrv(path[0]-'A');
	*strrchr(path,'*')=0;
	Dsetpath(path);		
	strcat(path,name);
	handle=Fopen(path,FO_READ);
	if 	(handle<0) 
		{
		form_alert(1,"[3][ |An error has occured|during opening the file.|Check it and try again.][ OK ]");
		return;
		}
	taille=filelength(handle);
	buffer=malloc(taille+1024);
	buf2=(void *)((char *)buffer + 8);
	if  (buffer<0)
		{
		form_alert(1,"[3][ |An error has occured|during the memory|allocation ! Try again.][ OK ]");
		return;
		}
	t_lue=Fread(handle,taille,buf2);
	if	(t_lue!=taille)
		{
		form_alert(1,"[3][ |An error has occurred|during reading the file|Try again.][ OK ]");
		return;
		}
	Fclose(handle);
	*((long *)buffer)='NPKK';
	*((long *)buffer+1)=(LENGHT_NDPK(buf2));
	handle=Fcreate(path,0);
	if	(handle<0)
		{
		form_alert(1,"[3][ |An error has occured|during creating file|Try again.][ OK ]");
		return;
		}
	t_lue=Fwrite(handle,taille+8,buffer);
	if	(t_lue!=taille+8)
		{
		form_alert(1,"[3][ |An error has occured|during writing the file|Try again.][ OK ]");
		return;
		}
	Fclose(handle);
	}
	