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

int fstat(int handle, struct stat *buff)
{
    long fpos;
    long ftime;
    size_t fsize;

    fpos = Fseek(0, handle, SEEK_CUR);

    if (fpos < 0)
    {
        __set_errno(-fpos);
        return -1;
    }

    Fdatime(&ftime, handle, 0);

    fsize = Fseek(0, handle, SEEK_END);

    // intialize struct
    // Pure C did not initialize members which cannot be set with a handle!

    buff->st_dev   = 0; // cannot be determined
    buff->st_ino   = 0;
    buff->st_mode  = S_IFREG | S_IRUSR;
    buff->st_nlink = 1;
    buff->st_uid   = 0;
    buff->st_gid   = 0;
    buff->st_rdev  = buff->st_dev;
    buff->st_size  = fsize;
    buff->st_atime = ftime;
    buff->st_mtime = ftime;
    buff->st_ctime = ftime;

    if (fsize > 0)
    {
        unsigned char byte;

        Fseek(0, handle, SEEK_SET);

        if (Fread(handle, 1, &byte) == 1)
        {
            Fseek(0, handle, SEEK_SET);

            if (Fwrite(handle, 1, &byte) == 1)
                buff->st_mode |= S_IWUSR;

            if (fsize > 1)
            {
                unsigned short magic;

                Fseek(0, handle, SEEK_SET);

                if (Fread(handle, sizeof(magic), &magic) == sizeof(magic) && magic == X_MAGIC)
                    buff->st_mode |= S_IXUSR;
            }
        }
    }

    Fseek(fpos, handle, SEEK_SET);

    return 0;
}
