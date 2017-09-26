/********************** Device locking support *********************/
/* 
	  Pure-C/Turbo-C Library 
  	  by Hans-Juergen Richstein
	  (c) 1994 Kaktus GbR

  This library makes it easy to support device locking for programs
  that operate on storage devices via direct bios access. It uses
  any available device locking mechanism, i.e. gemdos-Dlock() in the 
  first place -- if available --, and CHK_OFLS next, if installed.
  On startup of your program you have to call 'init_device_locking()'
  once. When you intend to operate on a device, first call 
  'lock_device(drive)' and check if access is granted (return code
  DEVICE_LOCKED or NO_DEVICE_LOCKING). When your operations on that
  device are finished, call 'unlock_device(drive)'. This frees that
  drive and forces a mediachange. Even if there was no device locking
  mechanism available, at least the mediachange is forced, so always
  call 'unlock_device(drive)', even if 'lock_device(drive)' returned
  NO_DEVICE_LOCKING.
  
  Remark: Never do a mediachange on your own. This may cause the system
  to crash if it supports Dlock(). Always use only lock_device/unlock_-
  device!
*/   
/* ---------- Return codes of 'lock_device' ----------------------------------------------------*/

#define DEVICE_LOCKED     0   /* OK */
#define NO_DEVICE_LOCKING 1   /* No device locking vailable */
                              /* You can, however, perform 'unlock_device' for forcing */
                              /* a mediachange. In any case, a 'lock_device' has to preceed */
                              /* the 'unlock_device' call, because it is ignored otherwise! */
#define ALREADY_LOCKED    2   /* The device is locked by another process */
#define FILES_OPEN        3   /* The device cannot be locked because of open files */
#define NOT_INITIALIZED   4   /* You forgot to perform 'init_device_locking' at program startup */

/*----------------------------------------------------------------------------------------------*/
void init_device_locking(void);

/* init_device_locking has to be called once at program startup, i.e. before */
/* the first call of 'lock_device' */
/*----------------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------------*/
int lock_device(int drive);

/* lock_device locks the given drive (0=A, 1=B, ...). Return codes are explained above. */ 
/*----------------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------------*/
void unlock_device(int drive);

/* unlock_device frees a locked device _and_ forces a mediachange! */
/* A mediachange is forced even if the system does not support any */
/* device locking, so you have to do a 'lock_device' in any case   */
/* before operating on a device. After finishing operation, do a   */
/* 'unlock_device' to force mediachange, even if the drive couldn't*/
/* be locked!                                                      */
/*----------------------------------------------------------------------------------------------*/

