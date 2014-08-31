/************************************************************************/
/* File name:	DUMP_TOS.S				Revision date:	1994.12.03		*/
/* Created by:	Ulf Ronald Andersson	Creation date:	1994.12.03		*/
/************************************************************************/

#include	<stdlib.h>
#include	<stdio.h>
#include	<string.h>
#include	<tos.h>
#include	<aes.h>
#include	<vdi.h>

typedef	unsigned long	ulong;
typedef unsigned int	uint;
typedef unsigned char	uchar;

extern	int	_app;

int		appl_id;
int		phys_handle;
int		work_handle;
int		gl_wchar,                      /* Gr”že und Breite eines Buchsta-  */
		gl_hchar,                      /* ben (wichtig falls mit unter-    */
		gl_wbox,                       /* schiedlichen Bildschirmaufl”-    */
		gl_hbox;                       /* sungen gearbeitet wird) bzw.     */
                                    /* einer Box.                       */
char	fs_path[128];
char	fs_name[16];
int		fs_retv, fs_exbt, fs_drive;
char	*tempsp;
char FileString[80];

ulong	errorcnt;
char	errstr[80];

/************************************************************************/

void	my_exit(int errcode, char *errmes)
{	if	(errmes != NULL  &&  *errmes != 0)
	{	printf(errmes);
		getchar();
	}
	if	(errcode > 0)
		v_clsvwk(work_handle);
	if	(errcode > -1)
		appl_exit();
	exit(0);
}	/* ends void my_exit(int errcode, char *errmes) */

/************************************************************************/

void select_file(void)
{	fs_drive = Dgetdrv();
	strcpy(fs_path,"a:\\");
	*fs_path += (char) fs_drive;
	Dgetpath(fs_path+3, fs_drive+1);
	tempsp = "\\*.*";
	if	(fs_path[3] == 0)
		tempsp++;
	strcat(fs_path, tempsp);
	*fs_name=0;
	fs_retv = fsel_input(fs_path, fs_name, &fs_exbt);
	if	(fs_retv < 0  ||  fs_exbt == 0  ||  *fs_name == 0)
		my_exit(1,NULL);
	tempsp = strrchr(fs_path,'\\');
	if	(tempsp != NULL)
		tempsp[1] = 0;
	strcpy(FileString,fs_path);
	strcat(FileString,fs_name);
}	/* ends void select_file(void) */

/************************************************************************/

void main()
{
	long	index, old_ssp;
	long	rom_size;
	char	*ROM_p;	
	char	*RAM_p, *high_p, *dest_p;
	int		work_in[11] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 };
	int		work_out[57];
	int		handle;

	appl_id = appl_init();
	if (appl_id == -1)	my_exit(-1,"No application slot!\n");
	work_in[10] = 2;
	phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox,&gl_hbox );
	work_handle = phys_handle;
	v_opnvwk( work_in, &work_handle, work_out );

	old_ssp=Super((void *)0L);
	ROM_p=(char *)(*((long *)(0x4F2)));
	ROM_p=(char *)(*((long *)(ROM_p+8)));
	Super((void *)old_ssp);

	if (((long)ROM_p & 0xFFFFFFL) == 0xFC0000L)
		rom_size = 0x30000L;
	else
		rom_size = 0x40000L;

	if ((RAM_p = (char *) malloc(rom_size)) == NULL)
		my_exit(2, "Insufficient RAM available!\n");
	select_file();

	if ((handle = (int) Fopen(FileString,0) ) > -1)
	{	Fclose(handle);
		my_exit(3, "File already exists!\n");
	} /* endif */

	high_p = ROM_p;
	dest_p = RAM_p;
	for (index=0; index<rom_size; index++)
		*dest_p++ = *high_p++;

	if ((handle = (int) Fcreate(FileString,0) ) < 0)
	{	Fclose(handle);
		my_exit(4, "File creation failed!\n");
	} /* endif */

	if (0 > Fwrite(handle, rom_size, RAM_p))
	{	Fclose(handle);
		my_exit(5, "File write error!\n");
	} /* endif */

	my_exit(1,"TOS File creation complete!\n");
}	/* ends void main(argc,argv) */

/************************************************************************/
/* End of file:	DUMP_TOS.C												*/
/************************************************************************/
