100 dev$='flp1_'
110 qlf68k$='QLF68K'
120 config$='QLCONFIG'
130 len_QLf68k=3034
140 len_Config=754
150 d_qlf68k=2560
160 d_config=1024
170 :
180 MODE 4
190 make_exe dev$&qlf68k$,len_QLf68k,d_qlf68k
200 make_exe dev$&config$,len_Config,d_config
210 :
1000 DEFine PROCedure make_exe(file$,laenge,dat)
1010 LOCal a
1020 a=RESPR(laenge)
1030 LBYTES file$&'_cde',a
1040 DELETE file$&'_exe'
1050 SEXEC  file$&'_exe',a,laenge,dat
1060 END DEFine make_exe
