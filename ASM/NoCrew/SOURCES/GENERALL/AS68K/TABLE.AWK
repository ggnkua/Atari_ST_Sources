#
#       convert mnemonic/templates to C structures
#
BEGIN{
	print "#include \"table.h\""
	print
	print "struct tmpl template[] = {"
}

{
	if( NF == 0 )
		;
	else if( NF == 1 ){             # a new mnemonic
		nmne++
		mne[nmne] = $1
		tidx[nmne] = lastidx
		}
	else{                           # a template
		if( NF == 4 )
			lastf = "0"
		else
			lastf = $5
		printf "{ %s, {%s}, %s, 0x%s, 0x%s },", $1, $2, $3, $4, lastf
		if( tidx[nmne] == lastidx )
			printf "        /* %d = %s */\n", lastidx, mne[nmne]
		else
			printf "\n"
		tcount[nmne]++
		lastidx++
		}
}

END{
	print "};"
	print
	printf "/*  %d mnemonics, %d templates  */\n",nmne,lastidx
	print
	print "struct mne mnemonic[] = {"
	for(i=1;i<=nmne;i++)
		printf "\"%s\", %d, &template[%d],\n", mne[i], tcount[i], tidx[i] | "sort >mne.sort"
}
