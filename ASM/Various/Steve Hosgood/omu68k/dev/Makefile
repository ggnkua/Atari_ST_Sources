MBDEVLIB:
	cd MBfd; make fdhand
	cd null; make null.o
	cd MBtty; make ttyhand
	cd MBtime; make timehand
	cd ramdisk; make ramd.o
	cd MBhd; make hdhand
	rm -f MBdevlib
	ar rc MBdevlib MBfd/fdhand null/null.o MBtty/ttyhand MBtime/timehand\
		ramdisk/ramd.o MBhd/hdhand
