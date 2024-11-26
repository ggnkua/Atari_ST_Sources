/*****************************************************************************/
/*                                                                           */
/* MSDOS.H                                                                   */
/* Date: 16/06/89                                                            */
/*                                                                           */
/*****************************************************************************/

#ifndef __MSDOS__
#define __MSDOS__

#define dos_gdrv                         Dgetdrv
#define dos_sdrv                         Dsetdrv

#define dos_chdir                        Dsetpath
#define dos_gdir(drive, pdrvpath)        Dgetpath (pdrvpath, drive)
#define dos_rmdir                        Ddelete
#define dos_mkdir                        Dcreate

#define dos_setdt                        Fsetdatime
#define dos_delete                       Fdelete
#define dos_rename(oldname, newname)     Frename (0, oldname, newname)
#define dos_chmod                        Fattrib

#define dos_sdta                         Fsetdta
#define dos_sfirst                       Fsfirst
#define dos_snext                        Fsnext

#define dos_create                       Fcreate
#define dos_open                         Fopen
#define dos_read                         Fread
#define dos_write                        Fwrite
#define dos_lseek(handle, smode, sofst)  Fseek(sofst, handle, smode)
#define dos_close                        Fclose

#define dos_alloc                        Malloc
#define dos_avail                        (LONG)Malloc (-1L)
#define dos_free                         Mfree

#endif /* __MSDOS__ */
