; Exemple de programme pour faire planter Magic

	include	tos_030.s
	opt	brw,bdw,p=68030
	opt	o+,w-,x+
	output	d:\test.tos

	section	text

	StartUp	$500

	Gemdos	Pterm0
