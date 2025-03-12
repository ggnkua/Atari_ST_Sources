/*
*	Funktionsdeklarationen
*/

VOID oep_filldata(DATAINFO *datainfo, OEPD_HEADER *oepd);
VOID link_doc(DATAINFO *datainfo);
VOID unlink_doc(DATAINFO *datainfo);
VOID dd_rec(WORD msg[], DATAINFO *datainfo);
WORD dd_receive(WORD msg[], BYTE type[], LONG *adr, LONG *adrsize);
WORD dd_send(WORD apid, WORD winid, WORD mx, WORD my, BYTE ext[], BYTE *adr, LONG size);
