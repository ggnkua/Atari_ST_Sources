# Makefile for lib/syscall.

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS)

CC1	= ./gasasm.sh

LIBRARY	= $(LIBC)
all:	$(LIBRARY)

OBJECTS	= \
	_exit.o \
	access.o \
	alarm.o \
	brk.o \
	cfgetispeed.o \
	cfgetospeed.o \
	cfsetispeed.o \
	cfsetospeed.o \
	chdir.o \
	chmod.o \
	chown.o \
	chroot.o \
	close.o \
	closedir.o \
	creat.o \
	dup.o \
	dup2.o \
	execl.o \
	execle.o \
	execv.o \
	execve.o \
	fcntl.o \
	fork.o \
	fpathconf.o \
	fstat.o \
	getcwd.o \
	getegid.o \
	geteuid.o \
	getgid.o \
	getgroups.o \
	getpgrp.o \
	getpid.o \
	getppid.o \
	getuid.o \
	ioctl.o \
	isatty.o \
	kill.o \
	link.o \
	lseek.o \
	lstat.o \
	mkdir.o \
	mkfifo.o \
	mknod.o \
	mktemp.o \
	mount.o \
	open.o \
	opendir.o \
	pathconf.o \
	pause.o \
	pipe.o \
	ptrace.o \
	read.o \
	readdir.o \
	readlink.o \
	reboot.o \
	rename.o \
	rewinddir.o \
	rmdir.o \
	sbrk.o \
	seekdir.o \
	setgid.o \
	setsid.o \
	setuid.o \
	sigaction.o \
	sigaddset.o \
	sigdelset.o \
	sigemptyset.o \
	sigfillset.o \
	sigismember.o \
	sigpending.o \
	sigprocmask.o \
	sigreturn.o \
	sigsuspend.o \
	sleep.o \
	stat.o \
	stime.o \
	symlink.o \
	sync.o \
	tcdrain.o \
	tcflow.o \
	tcflush.o \
	tcgetattr.o \
	tcsendbreak.o \
	tcsetattr.o \
	time.o \
	times.o \
	umask.o \
	umount.o \
	uname.o \
	unlink.o \
	utime.o \
	wait.o \
	waitpid.o \
	write.o \

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o

clean:
	$(RM) *.o

_exit.o:	_exit.s
	$(CC1) _exit.s

access.o:	access.s
	$(CC1) access.s

alarm.o:	alarm.s
	$(CC1) alarm.s

brk.o:	brk.s
	$(CC1) brk.s

cfgetispeed.o:	cfgetispeed.s
	$(CC1) cfgetispeed.s

cfgetospeed.o:	cfgetospeed.s
	$(CC1) cfgetospeed.s

cfsetispeed.o:	cfsetispeed.s
	$(CC1) cfsetispeed.s

cfsetospeed.o:	cfsetospeed.s
	$(CC1) cfsetospeed.s

chdir.o:	chdir.s
	$(CC1) chdir.s

chmod.o:	chmod.s
	$(CC1) chmod.s

chown.o:	chown.s
	$(CC1) chown.s

chroot.o:	chroot.s
	$(CC1) chroot.s

close.o:	close.s
	$(CC1) close.s

closedir.o:	closedir.s
	$(CC1) closedir.s

creat.o:	creat.s
	$(CC1) creat.s

dup.o:	dup.s
	$(CC1) dup.s

dup2.o:	dup2.s
	$(CC1) dup2.s

execl.o:	execl.s
	$(CC1) execl.s

execle.o:	execle.s
	$(CC1) execle.s

execv.o:	execv.s
	$(CC1) execv.s

execve.o:	execve.s
	$(CC1) execve.s

fcntl.o:	fcntl.s
	$(CC1) fcntl.s

fork.o:	fork.s
	$(CC1) fork.s

fpathconf.o:	fpathconf.s
	$(CC1) fpathconf.s

fstat.o:	fstat.s
	$(CC1) fstat.s

getcwd.o:	getcwd.s
	$(CC1) getcwd.s

getegid.o:	getegid.s
	$(CC1) getegid.s

geteuid.o:	geteuid.s
	$(CC1) geteuid.s

getgid.o:	getgid.s
	$(CC1) getgid.s

getgroups.o:	getgroups.s
	$(CC1) getgroups.s

getpgrp.o:	getpgrp.s
	$(CC1) getpgrp.s

getpid.o:	getpid.s
	$(CC1) getpid.s

getppid.o:	getppid.s
	$(CC1) getppid.s

getuid.o:	getuid.s
	$(CC1) getuid.s

ioctl.o:	ioctl.s
	$(CC1) ioctl.s

isatty.o:	isatty.s
	$(CC1) isatty.s

kill.o:	kill.s
	$(CC1) kill.s

link.o:	link.s
	$(CC1) link.s

lseek.o:	lseek.s
	$(CC1) lseek.s

lstat.o:	lstat.s
	$(CC1) lstat.s

mkdir.o:	mkdir.s
	$(CC1) mkdir.s

mkfifo.o:	mkfifo.s
	$(CC1) mkfifo.s

mknod.o:	mknod.s
	$(CC1) mknod.s

mktemp.o:	mktemp.s
	$(CC1) mktemp.s

mount.o:	mount.s
	$(CC1) mount.s

open.o:	open.s
	$(CC1) open.s

opendir.o:	opendir.s
	$(CC1) opendir.s

pathconf.o:	pathconf.s
	$(CC1) pathconf.s

pause.o:	pause.s
	$(CC1) pause.s

pipe.o:	pipe.s
	$(CC1) pipe.s

ptrace.o:	ptrace.s
	$(CC1) ptrace.s

read.o:	read.s
	$(CC1) read.s

readdir.o:	readdir.s
	$(CC1) readdir.s

readlink.o:	readlink.s
	$(CC1) readlink.s

reboot.o:	reboot.s
	$(CC1) reboot.s

rename.o:	rename.s
	$(CC1) rename.s

rewinddir.o:	rewinddir.s
	$(CC1) rewinddir.s

rmdir.o:	rmdir.s
	$(CC1) rmdir.s

sbrk.o:	sbrk.s
	$(CC1) sbrk.s

seekdir.o:	seekdir.s
	$(CC1) seekdir.s

setgid.o:	setgid.s
	$(CC1) setgid.s

setsid.o:	setsid.s
	$(CC1) setsid.s

setuid.o:	setuid.s
	$(CC1) setuid.s

sigaction.o:	sigaction.s
	$(CC1) sigaction.s

sigaddset.o:	sigaddset.s
	$(CC1) sigaddset.s

sigdelset.o:	sigdelset.s
	$(CC1) sigdelset.s

sigemptyset.o:	sigemptyset.s
	$(CC1) sigemptyset.s

sigfillset.o:	sigfillset.s
	$(CC1) sigfillset.s

sigismember.o:	sigismember.s
	$(CC1) sigismember.s

sigpending.o:	sigpending.s
	$(CC1) sigpending.s

sigprocmask.o:	sigprocmask.s
	$(CC1) sigprocmask.s

sigreturn.o:	sigreturn.s
	$(CC1) sigreturn.s

sigsuspend.o:	sigsuspend.s
	$(CC1) sigsuspend.s

sleep.o:	sleep.s
	$(CC1) sleep.s

stat.o:	stat.s
	$(CC1) stat.s

stime.o:	stime.s
	$(CC1) stime.s

symlink.o:	symlink.s
	$(CC1) symlink.s

sync.o:	sync.s
	$(CC1) sync.s

tcdrain.o:	tcdrain.s
	$(CC1) tcdrain.s

tcflow.o:	tcflow.s
	$(CC1) tcflow.s

tcflush.o:	tcflush.s
	$(CC1) tcflush.s

tcgetattr.o:	tcgetattr.s
	$(CC1) tcgetattr.s

tcsendbreak.o:	tcsendbreak.s
	$(CC1) tcsendbreak.s

tcsetattr.o:	tcsetattr.s
	$(CC1) tcsetattr.s

time.o:	time.s
	$(CC1) time.s

times.o:	times.s
	$(CC1) times.s

umask.o:	umask.s
	$(CC1) umask.s

umount.o:	umount.s
	$(CC1) umount.s

uname.o:	uname.s
	$(CC1) uname.s

unlink.o:	unlink.s
	$(CC1) unlink.s

utime.o:	utime.s
	$(CC1) utime.s

wait.o:	wait.s
	$(CC1) wait.s

waitpid.o:	waitpid.s
	$(CC1) waitpid.s

write.o:	write.s
	$(CC1) write.s
