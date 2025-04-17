/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N.Henson */

#include "minixfs.h"
#include "proto.h"
#include "global.h"


/* search_dir serves 3 functions dependent on 'mode'
0 Search a directory for the entry 'name' if found return its inode number.
1 Create an entry 'name' return position of d_inum .
2 Delete an entry 'name' return inode num for success .
3 Find entry 'name', return position of d_inum.
In all cases failure is denoted by a negative error number .
*/

long search_dir(name,inum,drive,flag)
const char *name;
unsigned inum;
int drive;
int flag;
{
    int entry,count;
    long zone;		/* Zone number within dir */
    long lstfree;	/* Last unused dir entry */
    d_inode rip;
    bufr *tmp;
    int tflag;
    int incr;
    int mfname;
    static char tname[MNAME_MAX];

    incr=super_ptr[drive]->increment;
    mfname=MMAX_FNAME(incr);

    if( (tflag=do_trans(SRCH_TOS,drive)) )
                strcpy(tname,tosify(name,tflag,mfname));

    read_inode(inum,&rip,drive);
    /* Must be a directory ! */
    if(!IS_DIR(rip)) return EPTHNF;

    lstfree=-1l;
    for(zone=0; (count=cnext_zone(&rip,zone,&tmp,drive)>>L_DIR_SIZE);
	zone++)
    {
	dir_struct *try;
    	for(entry=0,try=tmp->bdir;entry<count;entry+=incr,try+=incr) {
    		 unshort inumtemp;
    		 inumtemp=try->d_inum;
    		 if(inumtemp &&
    		(!strncmp(name,try->d_name,mfname) || (tflag && 
		(!strcmp(tname,tosify(try->d_name,tflag,mfname)) ) )))

	    	{
    		    if(flag==KILL)
		    {
			      /* Never ever allow unlinking of '.' or '..' */
			      if(zone==0 && entry<2)return EACCDN;
    			      try->d_inum=0;

    		/* Next bit pinched from Minix,
    		 * store old inode num in last 2 bytes of name
    		 * This allows recovery in case of accident
    		 */
    	*((unshort *)&try->d_name[MMAX_FNAME(incr)-2])=inumtemp;

    			write_zone(find_zone(&rip,zone,drive,0),tmp
				,drive,&syscache);
    		    }
    		if(flag==ADD) return  EACCDN;
		if(flag==FIND || flag==KILL ) return inumtemp;
    		if(flag==POS) return entry*DIR_ENTRY_SIZE+zone*BLOCK_SIZE;
		}
    		if(lstfree==-1l && !inumtemp)
    		lstfree=zone*BLOCK_SIZE+entry*DIR_ENTRY_SIZE;
    	}
    }

    if(flag==ADD) {
	dir_struct add[MAX_INCREMENT];
	strncpy(tname,name,mfname );
	tname[mfname]=0;
	if(badname(tname)) return EACCDN;
	if( do_trans(LWR_TOS,drive) ) Strlwr(tname);
      	strncpy(add[0].d_name,tname,mfname);
	add[0].d_inum=0;
	if(l_write(inum,lstfree,(long)(mfname+2),add,drive)
			!=(mfname+2) ) return EACCDN;
	return( lstfree==-1l ? rip.i_size : lstfree);
    }
    return EFILNF;
}

/* Return '1' if 'name' has any illegal characters in it */

int badname(name)
char *name;
{
	for(;*name;name++) if(BADCHR(*name)) 
	{
		DEBUG("minixfs: Bad character in filename");
		return 1;
	}
	return 0;
}

/* Return '1' if dir2 is a parent of dir1 , otherwise 0 or negative error 
 * number 
 */

long is_parent(dir1,dir2,drive)
unsigned dir1,dir2;
int drive;
{
	long itemp=dir1;
	for(;;)
	{
		if(itemp==dir2)
		{
			DEBUG("minixfs: invalid directory move");
			return 1;
		}
		if(itemp==ROOT_INODE)break;
		itemp=search_dir("..",itemp,drive,FIND);
		if(itemp < 0)
		{
			ALERT("Couldn't trace inode %d back to root",dir1);
			return EACCDN;
		}	
	}
	return 0;
}


