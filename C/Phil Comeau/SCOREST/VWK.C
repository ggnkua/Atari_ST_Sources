/* vwk:	Functions to open and close a virtual workstation.
 * phil comeau 17-apr-88
 * last edited 31-aug-89 0003
 *
 * Copyright 1990 Antic Publishing Inc.
 */

/* Globals used by AES/VDI */
int work_in[11];
int work_out[57];
int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

/* OpenVWk:	Open a VDI Virtual Workstation */
int OpenVWk()
{
	register int i;
	int physHandle, handle, junk;

	physHandle = graf_handle(&junk, &junk, &junk, &junk);

	for (i = 0; i < 10; ++i) {
		work_in[i] = 1;
	}
	work_in[i] = 2;
	handle = physHandle;
	v_opnvwk(work_in, &handle, work_out);

	return (handle);
}

/* CloseVWk:	Close a VDI Virtual Workstation */
void CloseVWk(handle)
int handle;
{
	v_clsvwk(handle);
}
