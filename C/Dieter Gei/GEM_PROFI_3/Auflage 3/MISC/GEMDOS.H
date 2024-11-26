/*****************************************************************************/
/*                                                                           */
/* GEMDOS.H                                                                  */
/* Date: 30/08/89                                                            */
/*                                                                           */
/*****************************************************************************/

#ifndef __GEMDOS__
#define __GEMDOS__

#define Dgetdrv                          dos_gdrv
#define Dsetdrv                          dos_sdrv

#define Dsetpath                         dos_chdir
#define Dgetpath(pdrvpath, drive)        dos_gdir (drive, pdrvpath)
#define Ddelete                          dos_rmdir
#define Dcreate                          dos_mkdir

#define Fsetdatime                       dos_setdt
#define Fdelete                          dos_delete
#define Frename(zero, oldname, newname)  dos_rename (oldname, newname)
#define Fattrib                          dos_chmod

#define Fsetdta                          dos_sdta
#define Fgetdta                          dos_gdta
#define Fsfirst                          dos_sfirst
#define Fsnext                           dos_snext

#define Fcreate                          dos_create
#define Fopen                            dos_open
#define Fread                            dos_read
#define Fwrite                           dos_write
#define Fseek(sofst, handle, smode)      dos_lseek (handle, smode, sofst)
#define Fclose                           dos_close

#define Malloc                           dos_alloc
#define Mavail                           dos_avail
#define Mfree                            dos_free

#endif /* __GEMDOS__ */
