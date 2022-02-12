# Makefile for lib/posix.

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS)
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= $(LIBC)
all:	$(LIBRARY)

OBJECTS	= \
	__exit.o \
	_access.o \
	_alarm.o \
	_cfgetispeed.o \
	_cfgetospeed.o \
	_cfsetispeed.o \
	_cfsetospeed.o \
	_chdir.o \
	_chmod.o \
	_chown.o \
	_chroot.o \
	_close.o \
	_closedir.o \
	_creat.o \
	_dup.o \
	_dup2.o \
	_exec.o \
	_execn.o \
	_fcntl.o \
	_fork.o \
	_fpathconf.o \
	_fstat.o \
	_getcwd.o \
	_getegid.o \
	_geteuid.o \
	_getgid.o \
	_getgroups.o \
	_getpgrp.o \
	_getpid.o \
	_getppid.o \
	_getuid.o \
	_ioctl.o \
	_isatty.o \
	_kill.o \
	_link.o \
	_lseek.o \
	_mkdir.o \
	_mkfifo.o \
	_mknod.o \
	_mktemp.o \
	_mount.o \
	_open.o \
	_opendir.o \
	_pathconf.o \
	_pause.o \
	_pipe.o \
	_ptrace.o \
	_read.o \
	_readdir.o \
	_rename.o \
	_rewinddir.o \
	_rmdir.o \
	_setgid.o \
	_setsid.o \
	_setuid.o \
	_sigaction.o \
	_sigpending.o \
	_sigprocmask.o \
	_sigreturn.o \
	_sigset.o \
	_sigsetjmp.o \
	_sigsuspend.o \
	_sleep.o \
	_stat.o \
	_stime.o \
	_sync.o \
	_tcdrain.o \
	_tcflow.o \
	_tcflush.o \
	_tcgetattr.o \
	_tcsendbreak.o \
	_tcsetattr.o \
	_time.o \
	_times.o \
	_umask.o \
	_umount.o \
	_uname.o \
	_unlink.o \
	_utime.o \
	_wait.o \
	_waitpid.o \
	_write.o \

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o

clean:
	rm -f *.o

__exit.o:	__exit.c
	$(CC1) __exit.c

_access.o:	_access.c
	$(CC1) _access.c

_alarm.o:	_alarm.c
	$(CC1) _alarm.c

_cfgetispeed.o:	_cfgetispeed.c
	$(CC1) _cfgetispeed.c

_cfgetospeed.o:	_cfgetospeed.c
	$(CC1) _cfgetospeed.c

_cfsetispeed.o:	_cfsetispeed.c
	$(CC1) _cfsetispeed.c

_cfsetospeed.o:	_cfsetospeed.c
	$(CC1) _cfsetospeed.c

_chdir.o:	_chdir.c
	$(CC1) _chdir.c

_chmod.o:	_chmod.c
	$(CC1) _chmod.c

_chown.o:	_chown.c
	$(CC1) _chown.c

_chroot.o:	_chroot.c
	$(CC1) _chroot.c

_close.o:	_close.c
	$(CC1) _close.c

_closedir.o:	_closedir.c
	$(CC1) _closedir.c

_creat.o:	_creat.c
	$(CC1) _creat.c

_dup.o:	_dup.c
	$(CC1) _dup.c

_dup2.o:	_dup2.c
	$(CC1) _dup2.c

_exec.o:	_exec.c
	$(CC1) _exec.c

_execn.o:	_execn.c
	$(CC1) _execn.c

_fcntl.o:	_fcntl.c
	$(CC1) _fcntl.c

_fork.o:	_fork.c
	$(CC1) _fork.c

_fpathconf.o:	_fpathconf.c
	$(CC1) _fpathconf.c

_fstat.o:	_fstat.c
	$(CC1) _fstat.c

_getcwd.o:	_getcwd.c
	$(CC1) _getcwd.c

_getegid.o:	_getegid.c
	$(CC1) _getegid.c

_geteuid.o:	_geteuid.c
	$(CC1) _geteuid.c

_getgid.o:	_getgid.c
	$(CC1) _getgid.c

_getgroups.o:	_getgroups.c
	$(CC1) _getgroups.c

_getpgrp.o:	_getpgrp.c
	$(CC1) _getpgrp.c

_getpid.o:	_getpid.c
	$(CC1) _getpid.c

_getppid.o:	_getppid.c
	$(CC1) _getppid.c

_getuid.o:	_getuid.c
	$(CC1) _getuid.c

_ioctl.o:	_ioctl.c
	$(CC1) _ioctl.c

_isatty.o:	_isatty.c
	$(CC1) _isatty.c

_kill.o:	_kill.c
	$(CC1) _kill.c

_link.o:	_link.c
	$(CC1) _link.c

_lseek.o:	_lseek.c
	$(CC1) _lseek.c

_mkdir.o:	_mkdir.c
	$(CC1) _mkdir.c

_mkfifo.o:	_mkfifo.c
	$(CC1) _mkfifo.c

_mknod.o:	_mknod.c
	$(CC1) _mknod.c

_mktemp.o:	_mktemp.c
	$(CC1) _mktemp.c

_mount.o:	_mount.c
	$(CC1) _mount.c

_open.o:	_open.c
	$(CC1) _open.c

_opendir.o:	_opendir.c
	$(CC1) _opendir.c

_pathconf.o:	_pathconf.c
	$(CC1) _pathconf.c

_pause.o:	_pause.c
	$(CC1) _pause.c

_pipe.o:	_pipe.c
	$(CC1) _pipe.c

_ptrace.o:	_ptrace.c
	$(CC1) _ptrace.c

_read.o:	_read.c
	$(CC1) _read.c

_readdir.o:	_readdir.c
	$(CC1) _readdir.c

_rename.o:	_rename.c
	$(CC1) _rename.c

_rewinddir.o:	_rewinddir.c
	$(CC1) _rewinddir.c

_rmdir.o:	_rmdir.c
	$(CC1) _rmdir.c

_setgid.o:	_setgid.c
	$(CC1) _setgid.c

_setsid.o:	_setsid.c
	$(CC1) _setsid.c

_setuid.o:	_setuid.c
	$(CC1) _setuid.c

_sigaction.o:	_sigaction.c
	$(CC1) _sigaction.c

_sigpending.o:	_sigpending.c
	$(CC1) _sigpending.c

_sigprocmask.o:	_sigprocmask.c
	$(CC1) _sigprocmask.c

_sigreturn.o:	_sigreturn.c
	$(CC1) _sigreturn.c

_sigset.o:	_sigset.c
	$(CC1) _sigset.c

_sigsetjmp.o:	_sigsetjmp.c
	$(CC1) _sigsetjmp.c

_sigsuspend.o:	_sigsuspend.c
	$(CC1) _sigsuspend.c

_sleep.o:	_sleep.c
	$(CC1) _sleep.c

_stat.o:	_stat.c
	$(CC1) _stat.c

_stime.o:	_stime.c
	$(CC1) _stime.c

_sync.o:	_sync.c
	$(CC1) _sync.c

_tcdrain.o:	_tcdrain.c
	$(CC1) _tcdrain.c

_tcflow.o:	_tcflow.c
	$(CC1) _tcflow.c

_tcflush.o:	_tcflush.c
	$(CC1) _tcflush.c

_tcgetattr.o:	_tcgetattr.c
	$(CC1) _tcgetattr.c

_tcsendbreak.o:	_tcsendbreak.c
	$(CC1) _tcsendbreak.c

_tcsetattr.o:	_tcsetattr.c
	$(CC1) _tcsetattr.c

_time.o:	_time.c
	$(CC1) _time.c

_times.o:	_times.c
	$(CC1) _times.c

_umask.o:	_umask.c
	$(CC1) _umask.c

_umount.o:	_umount.c
	$(CC1) _umount.c

_uname.o:	_uname.c ../../include/minix/config.h
	$(CC1) _uname.c

_unlink.o:	_unlink.c
	$(CC1) _unlink.c

_utime.o:	_utime.c
	$(CC1) _utime.c

_wait.o:	_wait.c
	$(CC1) _wait.c

_waitpid.o:	_waitpid.c
	$(CC1) _waitpid.c

_write.o:	_write.c
	$(CC1) _write.c
