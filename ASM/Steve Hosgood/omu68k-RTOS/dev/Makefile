EDEVLIB:
	cd Efd; make fdhand
	cd null; make null.o
	cd Etty; make ttyhand
	cd Etime; make timehand
	cd ramdisk; make ramd.o
	cd Ehd; make hdhand
	cd inbus; make inbus.o
	cd net; make netd.o
	rm -f Edevlib
	ar rc Edevlib Efd/fdhand null/null.o Etty/ttyhand Etime/timehand\
		ramdisk/ramd.o Ehd/hdhand inbus/inbus.o net/netd.o
