TARGET := monscape.tos

include ../common.mk

#
# Voxel
#

forth.o : hmap.dat tmap.dat

hmap.dat: ../voxel/hmap.dat
	ln -s $< $@

tmap.dat: ../voxel/tmap.dat
	ln -s $< $@

clean_hmap_tmap:
	rm -f hmap.dat tmap.dat

clean: clean_hmap_tmap

#
# Replay
#

$(TARGET) : replay.o

replay.o: replay.s ../replay/gas/pt_src50.s ../replay/gas/replay.s $(MAKEFILE_LIST)
replay.o: nomore.mod

nomore.mod: dimlig09.mod
	ln -s $< $@

replay.o: replay.s
	$(CROSS_DEV_PREFIX)as --mri -march=68030 -I../replay/gas $< -o $@

clean_mod:
	rm -f nomore.mod

clean: clean_mod
