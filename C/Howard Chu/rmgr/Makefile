# The following options can be set:
#
# -DGETTTYENT -- your system has the new format /etc/ttys (like 4.3 BSD)
#                and the getttyent(3) library functions.
#
# -DUSEBCOPY  -- use the bcopy() from the system's C-library.  If this
#                is set, bcopy must support overlapping source and
#                destination.  If USEBCOPY is not set, screen uses its
#                own version of bcopy.
#
# You should install as set-uid with owner root, so that it can read/write
# /etc/utmp, read /dev/kmem, and chown/chmod the allocated pseudo-ttys.

OPTIONS= -DUSEBCOPY -DGETTTYENT

CFLAGS= -O

rmgr: rmgr.o
	$(CC) $(CFLAGS) -o rmgr rmgr.o -lmgr

rmgr.o: rmgr.c rmgr.h
	$(CC) $(OPTIONS) $(CFLAGS) -c rmgr.c
