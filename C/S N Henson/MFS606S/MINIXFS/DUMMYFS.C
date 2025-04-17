/* 
 * This file contains a 'dummy' filesystem; which does almost nothing. In fact
 * all it does do is to allow changes to call the 'real' m_root.
 * Why have such a thing you may ask? Two reasons, firstly if a minix filesystem
 * on the disk is inaccesible for some reason (directory increment too big for
 * example) then minixfs shouldn't touch it; however we don't want it sent to 
 * other filesystems where it could get trashed. The second case is for physical
 * partitions: minit has to have some way of finding out the currently invalid
 * partition's parameters.
 */

#include "minixfs.h"
#include "proto.h"
#include "global.h"

FILESYS dummy_filesys = {
	(FILESYS *) 0,0,
	m_root, no_lookup, no_creat, no_getdev,
	no_getxattr, no_chattr, no_chown,
	no_chmode, no_mkdir,
	no_rmdir, no_remove, no_getname,
	no_rename, no_opendir, no_readdir,
	no_rewinddir, no_closedir,
	no_pathconf, no_dfree,
	no_wlabel, no_rlabel,
	no_symlink, no_readlink,
	no_hardlink, dummy_fscntl, m_dskchng,
	m_release,m_dupcookie
};

long no_lookup(dir,name,entry)
fcookie *dir; 
char *name;
fcookie *entry;
{
	return EFILNF;
}

long no_creat(dir,name,mode,attr,entry)
fcookie *dir;
char *name;
unsigned mode;
int attr;
fcookie *entry;
{
	return EACCDN;
}

DEVDRV * no_getdev(file,special)
fcookie *file;
long *special;
{
	*special=EINVFN;
	return NULL;
}

long no_getxattr(file,xattr)
fcookie *file;
XATTR *xattr;
{
	return EACCDN;
}

long no_chown(file, uid , gid)
fcookie *file;
int uid,gid;
{
        return EINVFN;
}

long no_chmode(file, mode)
fcookie *file;
unsigned mode;
{
        return EINVFN;
}


long no_mkdir(dir,name,mode)
fcookie *dir;
char *name;
unsigned mode;
{
	return EACCDN;
}

long no_rmdir(dir,name)
fcookie *dir;
char *name;
{
        return EACCDN;
}

long no_remove(dir,name)
fcookie *dir;
char *name;
{
	return EACCDN;
}

long no_getname(root,dir,pathname,length)
fcookie *root,*dir;
char *pathname;
short length;
{
	return EACCDN;
}


long no_opendir(dirh,flag)
DIR *dirh;
int flag;
{
	return 0;
}

long no_readdir(dirh,name,namelen,fc)
DIR *dirh;
char *name;
int namelen;
fcookie *fc;
{
        return ENMFIL;
}

long no_rewinddir(dirh)
DIR *dirh;
{
	return 0;
}

long no_closedir(dirh)
DIR *dirh;
{
	return 0;
}

long no_rlabel(dir,name,namelen)
fcookie *dir;
char *name;
int namelen;
{
	return EFILNF;
}

long no_wlabel(dir,name)
fcookie *dir;
char *name;
{
	return EACCDN;
}

long no_dfree(dir,buffer)
fcookie *dir;
long *buffer;
{
	return EINVFN;
}

long dummy_fscntl(dir,name,cmd,arg)
fcookie *dir;
char *name;
int cmd;
long arg;
{
	if(cmd!=MFS_PHYS) return EINVFN;
	return m_fscntl(dir,name,cmd,arg);
}

long no_rename(olddir,oldname,newdir,newname)
fcookie *olddir;
char *oldname;
fcookie *newdir;
char *newname;
{
        return EACCDN;
}

long no_hardlink(fromdir,fromname,todir,toname)
fcookie *fromdir;
char *fromname;
fcookie *todir;
char *toname;
{
        return EINVFN;
}

long no_symlink(dir,name,to)
fcookie *dir;
char *name;
char *to;
{
        return EINVFN;
}

long no_readlink(file,buf,len)
fcookie *file;
char *buf;
int len;
{
	return EINVFN;
}

long no_chattr(file,attr)
fcookie *file;
int attr;
{
	return EFILNF;
}

long no_pathconf(dir,which)
fcookie *dir;
int which;
{
	return EINVFN;
}
