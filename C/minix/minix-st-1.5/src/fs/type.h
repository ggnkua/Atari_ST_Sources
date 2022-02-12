/* Type definitions local to the File System. */

typedef struct {		/* directory entry */
  ino_t d_inum;			/* inode number */
  char d_name[NAME_MAX];	/* character string */
} dir_struct;

/* Declaration of the disk inode used in rw_inode(). */
typedef struct {		/* disk inode.  Memory inode is in "inode.h" */
  mode_t i_mode;		/* file type, protection, etc. */
  uid_t i_uid;			/* user id of the file's owner */
  off_t i_size;			/* current file size in bytes */
  time_t i_mtime;		/* when was file data last changed */
  gid_t i_gid;			/* group number */
  nlink_t i_nlinks;		/* how many links to this file */
  zone_nr i_zone[NR_ZONE_NUMS];	/* block nums for direct, ind, and dbl ind */
} d_inode;
