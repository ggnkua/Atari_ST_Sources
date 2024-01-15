DD_OK:		= 0
DD_NAK:		= 1
DD_EXT:		= 2
DD_LEN:		= 3
DD_TRASH:	= 4
DD_PRINTER:	= 5
DD_CLIPBRD:	= 6

ddf_extofst	= 17	;offset to the extender in U:\PIPE\DRAGDROP.XX

		rsreset
	;The first two elements are filled by the caller
dd_ext:		rs.w 1	;Extender of the filename
dd_support:	rs.l 1	;Address to a table of supported data-types

	;These members are filled in by the recipient routine
dd_headsize:	rs.w 1	;Size of the header
dd_header:	rs.l 1	;Address of the loaded header (use this address to release mem)
dd_datalen:	rs.l 1	;Lenght of data sent
dd_datatype:	rs.l 1	;Type of the data
dd_dataformat:	rs.l 1	;Format string.
dd_datafile:	rs.l 1	;Address of the filename in header
dd_databuff:	rs.l 1	;When data is loaded using dd_load, address of the loaded data.
dd_fhandle:	rs.l 1	;Filehandle, to be used by the caller to load data
dragdrop_ssize:	= __RS
