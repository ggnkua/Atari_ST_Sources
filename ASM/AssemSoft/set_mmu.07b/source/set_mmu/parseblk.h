		rsreset
pblk_config:	rs.l 1	;Address of the config text/file
pblk_varibs:	rs.l 1	;Start of a table of understood variables - see below for the structure of this table
pblk_numvars:	rs.w 1	;Number of variables in "understood variables" table
pblk_res0:	rs.w 1
pblk_functs:	rs.l 1	;Pointer to an array of function adresses.
pblk_next:	rs.l 1	;This will point past the block if sucessful or to the line parse error happened.

*************************************************************************************************
* The table of understood variable is constructed as follows;					*
*												*
*variable name, function number.								*
*												*
* That is, the first element is a null-terminated variable name, and the second element is a	*
* byte indicating the function number to use to parse the value of this variable. That is, the	*
* function number is used to index into the pblk_functs array of functions to find the correct	*
* function to use.										*
* example;											*
*												*
*varibs:	dc.b "logical=",0,0 	;This means variable name "logical" uses function #0 to	*
*				   	;interpret the variable value.				*
*		dc.b "physical=",0,1	;And to interpret the value of physical, function #1 is	*
*					;used.							*
* This means that pblk_functs contains an array of function addresses, which corresponds to a	*
* variable entry in the table pointed to by pblk_varibs.					*
*												*
* The function that is called is passed the start of the variable value in A3.			*
*************************************************************************************************

