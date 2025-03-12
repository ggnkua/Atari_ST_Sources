oldrez	ds.w 1
oldvbl	ds.l	1
oldusp	ds.l	1
oldpal ds.w 16
old8260 ds.l 1
old820a ds.l 1
old8265	ds.b 1
old820f	ds.b 1
	even

physbase	ds.l 1
old8203 ds.b 1
old8201 ds.b 1
old820d ds.b 1
old484 ds.b 1

	ifne enablehbl
old07	ds.b 1
old09	ds.b 1
old13	ds.b 1
old1b	ds.b 1
old21	ds.b 1
	even
oldhbl	ds.l 1
	endc

	even
startupsp ds.l 1
