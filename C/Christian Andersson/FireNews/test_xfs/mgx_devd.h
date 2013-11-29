/*********************************************************************
*
* Strukturen zum Einbinden eines MagiC-Ger„tetreibers nach
* u:\dev
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
     LONG      ddev_open;
     LONG      ddev_close;
     LONG      ddev_read;
     LONG      ddev_write;
     LONG      ddev_stat;
     LONG      ddev_seek;
     LONG      ddev_datime;
     LONG      ddev_ioctl;
     LONG      ddev_delete;
     LONG      ddev_getc;
     LONG      ddev_getline;
     LONG      ddev_putc;
} MX_DDEV;


typedef struct _mx_cdecl_ddev {
     LONG cdecl     (*ddev_open)   (MX_DOSFD *f);
     LONG cdecl     (*ddev_close)  (MX_DOSFD *f);
     LONG cdecl     (*ddev_read)   (MX_DOSFD *f, LONG len, void *buf );
     LONG cdecl     (*ddev_write)  (MX_DOSFD *f, LONG len, void *buf);
     LONG cdecl     (*ddev_stat)   (MX_DOSFD *f, LONG *unsel,
     							WORD rwflag, LONG apcode);
     LONG cdecl     (*ddev_seek)   (MX_DOSFD *f, LONG where, WORD mode);
     LONG cdecl     (*ddev_datime) (MX_DOSFD *f, WORD *buf, WORD rwflag);
     LONG cdecl     (*ddev_ioctl)  (MX_DOSFD *f, WORD cmd, void *buf);
     LONG cdecl     (*ddev_delete) (MX_DOSFD *p, MX_DOSDIR *dir);
     LONG cdecl     (*ddev_getc)   (MX_DOSFD *f, WORD mode );
     LONG cdecl     (*ddev_getline)(MX_DOSFD *f, char *buf,
                                        LONG size, WORD mode );
     LONG cdecl     (*ddev_putc)   (MX_DOSFD *f, WORD mode, LONG val );
} CDECL_MX_DDEV;


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
     void    	*d_dfs;		/* eigentlich "struct _mx_dfs *" */
} MX_DOSDMD;
