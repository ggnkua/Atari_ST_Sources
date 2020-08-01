/*****************************************************************
 *
 *                stat.h
 *
 *****************************************************************/

#include <time.h>
extern int macstat(char *path, struct stat *buf, short nVRefNum, long lDirID );
typedef long dev_t;
typedef long ino_t;
typedef long off_t;

struct stat {
    dev_t    st_dev;
    ino_t    st_ino;
    unsigned short    st_mode;
    short    st_nlink;
    short    st_uid;
    short    st_gid;
    dev_t    st_rdev;
    off_t    st_size;
    time_t   st_atime, st_mtime, st_ctime;
    long     st_blksize;
    long     st_blocks;
};

#define S_IFMT     0xF000
#define S_IFIFO    0x1000
#define S_IFCHR    0x2000
#define S_IFDIR    0x4000
#define S_IFBLK    0x6000
#define S_IFREG    0x8000
#define S_IFLNK    0xA000
#define S_IFSOCK   0xC000
#define S_ISUID    0x800
#define S_ISGID    0x400
#define S_ISVTX    0x200
#define S_IREAD    0x100
#define S_IWRITE   0x80
#define S_IEXEC    0x40
