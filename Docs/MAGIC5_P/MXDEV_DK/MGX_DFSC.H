/*********************************************************************
*
* Mag!X 3.00
* ==========
*
* Strukturen fÅr die Einbindung eines DFS Åber einen "Glue"-
* Code in 'C'.
*
* SÑmtliche Parameter werden auf dem Stapel Åbergeben, dies
* ermîglicht die Verwendung eines beliebigen Compilers.
*
* Version: 1.12.94
*
*********************************************************************/

typedef struct _mx_dosdir {
     char      dir_name[11];
     char      dir_attr;
     WORD      dir_usr1;
     ULONG     dir_usr2;
     ULONG     dir_usr3;
     WORD      dir_time;
     WORD      dir_date;
     WORD      dir_stcl;
     ULONG     dir_flen;
} MX_DOSDIR;

typedef struct _mx_dosfd {
     MX_DMD    *fd_dmd;
     WORD      fd_refcnt;
     WORD      fd_mode;
     MX_DEV    *fd_dev;
     struct    _mx_ddev *fd_ddev;
     char      fd_name[11];
     char      fd_attr;
     PD        *fd_owner;
     struct _mx_dosfd  *fd_parent;
     struct _mx_dosfd  *fd_children;
     struct _mx_dosfd  *fd_next;
     struct _mx_dosfd  *fd_multi;
     struct _mx_dosfd  *fd_multi1;
     ULONG     fd_fpos;
     char      fd_dirch;
     char      fd_unused;
     WORD      fd_time;
     WORD      fd_date;
     WORD      fd_stcl;
     ULONG     fd_len;
     ULONG     fd_dirpos;
     ULONG     fd_user1;
     ULONG     fd_user2;
} MX_DOSFD;

typedef struct _mx_ddev {
     LONG cdecl     (*ddev_open)   (MX_DOSFD *f);
     LONG cdecl     (*ddev_close)  (MX_DOSFD *f);
     LONG cdecl     (*ddev_read)   (MX_DOSFD *f, void *buf, LONG len);
     LONG cdecl     (*ddev_write)  (MX_DOSFD *f, void *buf, LONG len);
     LONG cdecl     (*ddev_stat)   (MX_DOSFD *f, WORD rwflag,
                                        void *unsel, APPL *appl);
     LONG cdecl     (*ddev_seek)   (MX_DOSFD *f, LONG where, WORD mode);
     LONG cdecl     (*ddev_datime) (MX_DOSFD *f, WORD *buf, WORD rwflag);
     LONG cdecl     (*ddev_ioctl)  (MX_DOSFD *f, WORD cmd, void *buf);
     LONG cdecl     (*ddev_delete) (MX_DOSFD *p, MX_DOSDIR *dir);
     LONG cdecl     (*ddev_getc)   (MX_DOSFD *f, WORD mode );
     LONG cdecl     (*ddev_getline)(MX_DOSFD *f, char *buf,
                                        LONG size, WORD mode );
     LONG cdecl     (*ddev_putc)   (MX_DOSFD *f, WORD mode, LONG val );
} MX_DDEV;


typedef struct _mx_dosdta {
     char      dta_sname[12];
     ULONG     dta_usr1;
     ULONG     dta_usr2;
     char      dta_drive;
     char      dta_attr;
     WORD      dta_time;
     WORD      dta_date;
     ULONG     dta_len;
     char      dta_name[14];
} MX_DOSDTA;


typedef struct _mx_dosdmd {
     MX_XFS    *d_xfs;
     WORD      d_drive;
     MX_DOSFD  *d_root;
     WORD      biosdev;
     LONG      driver;
     LONG      devcode;
     struct _mx_dfs    *d_dfs;
} MX_DOSDMD;


typedef struct _mx_dfs {
     char           dfs_name[8];
     struct _mx_dfs *dfs_next;
     LONG cdecl     (*dfs_init)( void );
     LONG cdecl     (*dfs_sync)( MX_DOSDMD *d );
     LONG cdecl     (*dfs_drv_open)( MX_DOSDMD *d );
     LONG cdecl     (*dfs_drv_close)( MX_DOSDMD *d, int mode );
     LONG cdecl     (*dfs_dfree)( MX_DOSFD *dd, LONG df[4] );
     LONG cdecl     (*dfs_sfirst)( MX_DOSFD *dd, MX_DOSDIR *dir,
                                   LONG pos, MX_DOSDTA *dta,
                                   void *link );
     LONG cdecl     (*dfs_snext)( MX_DOSDTA *dta, MX_DOSDMD *d,
                                   void *link );
     LONG cdecl     (*dfs_ext_fd)( MX_DOSFD *dd );
     LONG cdecl     (*dfs_fcreate)( MX_DOSFD *fd, MX_DOSDIR *dir,
                                   WORD cmd, LONG arg );
     LONG cdecl     (*dfs_fxattr)( MX_DOSFD *dd, MX_DOSDIR *dir,
                                   WORD mode, XATTR *xattr,
                                   void *link );
     LONG cdecl     (*dfs_dir2index)( MX_DOSFD *dd, MX_DOSDIR *dir,
                                   void *link );
     LONG cdecl     (*dfs_readlink)( MX_DOSFD *dd, MX_DOSDIR *dir,
                                   void *link );
     LONG cdecl     (*dfs_dir2FD)( MX_DOSFD *dd, MX_DOSDIR *dir,
                                   void *link );
     LONG cdecl     (*dfs_fdelete)( MX_DOSFD *dd, MX_DOSDIR *dir,
                                   LONG pos );
     LONG cdecl     (*dfs_pathconf)( MX_DOSFD *dd, WORD cmd );
} MX_DFS;

/* unterstÅtzte Dcntl- Modi */
#define   DFS_GETINFO    0x1100
#define   DFS_INSTDFS    0x1200
#define   DEV_M_INSTALL  0xcd00
