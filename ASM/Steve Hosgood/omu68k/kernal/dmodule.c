/******************************************************************************
 *	Dmodule.c	Loads relocatable device module
 ******************************************************************************
 *
 */

# include	"../include/param.h"
# include       "../include/inode.h"
# include       "../include/file.h"
# include       "../include/dev.h"
# include	"../include/stat.h"
# include	"../include/dmodule.h"
# include	"../include/memory.h"
# include	<a.out.h>

# define	DMAGIC	FMAGIC

struct	Dmodule dmod[NDMODULES];


/*
 *	Dmodopen()	Loads a device driver module if necesary
 */
dmodopen(file)
struct	file *file;
{
	int	m, d, ino, max;
	struct	inode *iptr;
	struct	dev *devptr;

	ino = file->f_inode->i_addr[1];

	/* Checks if device is already loaded return 0 if so */
	for(m = 0; m < NDMODULES; m++){
		if(ino == dmod[m].ino){
			dmod[m].nopens++;
			file->f_handler = dmod[m].dmaj;
			return 0;
		}
	}

	if(iptr = getiptr(file->f_inode->i_mdev, file->f_inode->i_minor, ino)){
		/* Not loaded so get a free entry in module data base */
		/* Gets a free entry in module table */
		for(m = 0; m < NDMODULES; m++){
			if(!dmod[m].ino) break;
		}
		if(m == NDMODULES){
			printf("Dmodopen no more table entries\n");
			return -1;
		}

		if(file->f_type == B_SPECL){
			devptr = bdevsw;
			max = NBDEVS;
		}
		else{
			devptr = cdevsw;
			max = NCDEVS;
		}
		for(d = 0; d < max; d++){
			if(!devptr->inuse) break;
			devptr++;
		}
		if(d == max) return -1;

		/* Load the device driver */
		if((dmod[m].memseg = dmodload(iptr, devptr)) == -1){
			freeiptr(iptr);
			return -1;
		}

		file->f_handler = devptr;
		dmod[m].nopens = 1;
		dmod[m].ino = ino;
		dmod[m].dmaj = devptr;
		
		freeiptr(iptr);
		return 0;
	}
	return -1;
}

/*
 *	Load the given device driver
 */
dmodload(iptr, devptr)
struct	inode *iptr;
struct	dev *devptr;
{
	int	seg;
	long	address;
	struct	file file;
	struct	bhdr hdr;

	/* Not loaded, load it, link it and set device switch entries */

	/* First open the file */
	if(f_open(&file, iptr, READABLE) == -1){
		printf("Kernal: Unable to open device module inode %x\n",iptr);
		return -1;
	}

	/* Get size info on file */
	if(f_read(&file, &hdr, sizeof(struct bhdr)) != sizeof(struct bhdr)){
		printf("Kernal: Unable to read device module inode %x\n",iptr);
		f_close(&file);
		return -1;
	}

	if(hdr.fmagic != DMAGIC){
		printf("Kernal: Not device module inode %x\n",iptr);
		f_close(&file);
		return -1;
	}

	/* Get memory for the device driver */
	if((seg = getmem(MODULESEG, (hdr.tsize + hdr.dsize + hdr.bsize)))== -1){
		printf("Kernal: No memory for device module inode %x\n",iptr);
		f_close(&file);
		return -1;
	}

	/* Start address of memory segment */
	address = memstart(MODULESEG, seg);

	/* Move to start of file */
	f_seek(&file, 0L, 0);

	/* Link load the device driver */
	linkld(&file, address);

	/* Sets up device entry */
	devptr->inuse = 1;
	devptr->openfnc = (int (*)())address;
	devptr->closefnc = (int (*)())(address+6);
	devptr->stratfnc = (int (*)())(address+12);
	devptr->rd_fnc = (int (*)())(address+18);
	devptr->wr_fnc = (int (*)())(address+24);
	devptr->sig_fnc = (int (*)())(address+30);

	f_close(&file);
	return seg;
}

/*
 *	Dmodclose()	Decrements device open entry
 */
dmodclose(file)
struct	file *file;
{
	int	m, ino;

	ino = file->f_inode->i_addr[1];

	/* Finds device driver entry */
	for(m = 0; m < NDMODULES; m++){
		if(ino == dmod[m].ino){
			if(--dmod[m].nopens < 0) dmod[m].nopens = 0;

			/* If last close end memory and clear inonde number */
			if(!dmod[m].nopens){
				dmod[m].dmaj->inuse = 0;
				endmem(MODULESEG, dmod[m].memseg);
				dmod[m].ino = 0;
			}
			return 0;
		}
	}
	return -1;
}

/*
 *	Modclear()	Clears all unused device drivers from dev driver space
 */
modclear(){
	int	m;

	/* Clears all device driver entrys if not being used */
	for(m = 0; m < NDMODULES; m++){
		if(dmod[m].ino){
			/* If last close end memory and clear inonde number */
			if(!dmod[m].dmaj->inuse){
				dmod[m].dmaj->inuse = 0;
				endmem(MODULESEG, dmod[m].memseg);
				dmod[m].ino = 0;
			}
		}
	}
	return 0;
}
