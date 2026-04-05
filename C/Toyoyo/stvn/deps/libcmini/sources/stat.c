#include <stdlib.h>
#include <mint/osbind.h>
#include <errno.h>
#include <ext.h>
#include "lib.h"

#define X_MAGIC   0x601a

#define S_IFMT    0170000  // bit mask for the file type bit fields
#define S_IFSOCK  0140000  // socket
#define S_IFLNK   0120000  // symbolic link
#define S_IFREG   0100000  // regular file
#define S_IFBLK   0060000  // block device
#define S_IFDIR   0040000  // directory
#define S_IFCHR   0020000  // character device
#define S_IFIFO   0010000  // FIFO
#define S_ISUID   0004000  // set UID bit
#define S_ISGID   0002000  // set-group-ID bit
#define S_ISVTX   0001000  // sticky bit
#define S_IRWXU   00700    // mask for file owner permissions
#define S_IRUSR   00400    // owner has read permission
#define S_IWUSR   00200    // owner has write permission
#define S_IXUSR   00100    // owner has execute permission
#define S_IRWXG   00070    // mask for group permissions
#define S_IRGRP   00040    // group has read permission
#define S_IWGRP   00020    // group has write permission
#define S_IXGRP   00010    // group has execute permission
#define S_IRWXO   00007    // mask for permissions for others (not in group)
#define S_IROTH   00004    // others have read permission
#define S_IWOTH   00002    // others have write permission
#define S_IXOTH   00001    // others have execute permission

int stat(const char *path, struct stat *buff)
{
    _DTA* old_dta = Fgetdta();
    _DTA dta;
    long ret;
    _DOSTIME* timeptr;

    Fsetdta(&dta);

    ret = Fsfirst(path, FA_DIR | FA_RDONLY | FA_HIDDEN | FA_SYSTEM);

    Fsetdta(old_dta);

    if (ret != 0)
    {
        __set_errno(ENOENT);
        return -1;
    }

    timeptr = (_DOSTIME*)&buff->st_atime;
    timeptr->time = dta.dta_time;
    timeptr->date = dta.dta_date;

    buff->st_dev   = (path[0] != '\0' && path[1] == ':') ? ((path[0] & ~0x20 /* toupper */) - 'A') : Dgetdrv();
    buff->st_ino   = 0;
    buff->st_mode  = S_IRUSR;
    buff->st_nlink = 1;
    buff->st_uid   = 0;
    buff->st_gid   = 0;
    buff->st_rdev  = buff->st_dev;
    buff->st_size  = dta.dta_size;
    buff->st_mtime = buff->st_atime;
    buff->st_ctime = buff->st_atime;

    if ((dta.dta_attribute & FA_RDONLY) == 0)
        buff->st_mode |= S_IWUSR;

    if ((dta.dta_attribute & FA_DIR) != 0)
    {
        buff->st_mode |= S_IFDIR | S_IXUSR;
    } else
    {
        long fh;

        buff->st_mode |= S_IFREG;

        fh = Fopen(path, FO_READ);

        if (fh >= 0)
        {
            unsigned short magic;

            if (Fread(fh, sizeof(magic), &magic) == sizeof(magic) && magic == X_MAGIC)
                buff->st_mode |= S_IXUSR;

            Fclose(fh);
        }
    }

    return 0;
}
