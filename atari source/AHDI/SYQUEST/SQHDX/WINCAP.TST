# Hard disk format and partition configuration file.
#  2-Apr-1986 lmd, Atari Corp.
# 12-Jan-1988  ml, Atari Corp.

#
# Global parameters:
#	ms#count	Maximum partition size in sectors (***DON'T CHANGE***)
#
:@@=Parameters:ms#32752:

#
# Format parameters:
# 'mn' entries (default values in [brackets]):
#	mn=name		appears in menu, name of format parms
#	hd#count	number of heads [4]
#	cy#count	number of cylinders [612]
#	lz#n		landing zone [10]
#	rt#n		seek rate code [2]
#	in#n		interleave factor [1]
#	rw#cylno	reduced-write current cylinder [cy + 1]
#	wp#cylno	write precomp cylinder [cy + 1]
#	pt=name		name of default partition to use [4-6-10]
#	sp#count	number of sectors/track [17]
#	dp#data		data pattern used to test disk.
#
#  Bad Sector List parameters:
#	sl#count	number of sectors for vendor bad sector list [1]
#

60 Mb :mn=MEGAFILE 60:hd#6:cy#809:rw#809:wp#809:pt=15-15-15-15:sp#26:dp#0x6333:
40 Mb :mn=SH404:cy#782:rw#782:wp#782:pt=10-10-10-10:sp#26:dp#0x6333:
30 Mb :mn=MEGAFILE 30:cy#615:rw#615:wp#615:pt=10-10-10:sp#26:dp#0x6333:
20 Mb :mn=SH205:dp#0x6cd6:
20 Mb :mn=SH204:dp#0x6cd6:
10 Mb :mn=SH104:hd#2:pt=10:dp#0x6cd6:

#
# Partition selections
# '?0' entries (? is a digit)('N' is '0', '1', '2', or '3'):
#	pr=name		name of partition
#	pN#size		size of partition N in bytes [0]
#	fN#number	flag byte for partition N [0 if no pN, 1 otherwise]
#	iN=ccc		id bytes for partition N [GEM]
#
# Numbers are in bytes; may be followed by 'k' (x1024) or 'm' (megabytes).
#
:60=15-15-15-15:p0#15775k:p1#15776k:p2#15775k:p3#15776k:
:60=12-16-16-16:p0#13974k:p1#16376k:p2#16376k:p3#16376k:
:60=14-14-16-16:p0#15175k:p1#15175k:p2#16376k:p3#16376k:
:60=16-16-14-14:p0#16376k:p1#16376k:p2#15175k:p3#15175k:
:40=10-10-10-10:p0#10166k:p1#10166k:p2#10166k:p3#10166k:
:40=4-4-16-16:p0#4066k:p1#4067k:p2#16265k:p3#16266k:
:40=8-16-16:p0#8133k:p1#16265k:p2#16266k:
:40=16-16-8:p0#16265k:p1#16266k:p2#8133k:
:30=10-10-10:p0#10660k:p1#10660k:p2#10660k:
:30=6-8-16:p0#6396k:p1#8528k:p2#17056k:
:30=5-5-10-10:p0#5330k:p1#5330k:p2#10660k:p3#10660k:
:30=4-6-10-10:p0#4264k:p1#6396k:p2#10660k:p3#10660k:
:20=10-10:p0#10404k:p1#10404k:
:20=4-6-10:p0#4424k:p1#6m:p2#10m:
:20=5-5-10:p2#10568k:p0#5m:p1#5m:
:20=10-5-5:p0#10568k:p1#5m:p2#5m:
:20=5-5-5-5:p0#5448k:p1#5m:p2#5m:p3#5m:
:10=10:p0#10m:
:10=5-5:p0#5m:p1#5m:
