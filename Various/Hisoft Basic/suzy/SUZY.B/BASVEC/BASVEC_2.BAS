
DEFINT a-z
'$option y-
' Basvec Example - 10/03/91-10/04/91


init:
  rem $option k14 ' Set basic keep to 14K (not incl. prog.)
  deflng a-z  ' All basvec values are longs
  const true=-1,false=0,k=1024,keep=28  ' Set total keep ASSUMING 14K prog.

  ' Basvec init
  restore basvec_dat:read bl,bx,bd:bl=bl-2
  dim b(bl+bx-1):ba=varptr(b(0)):for i=0 to bl-1:read b(i):next i
  ' Define basvec local parameters
  const pv_p=2,pv_reent_c=3,pt_c=5,pt_reset_c=6,pt_io_c=7
  const pb_sr=10,pb_v=20,pb_call_f=21,ph_v=23
  ' Global parameters
  const h_vec_f=0,h_keep_c=2
  h_super_e=varptr(b(3)):h_init_e=varptr(b(4)):h_exit_e=varptr(b(5))
  basvec_dat:
    data &h65,&h18,&h40,&h0,&h0,&h0
    data &h60000012,&h6000001E,&h60000068,&h0,&h0,&h42A73F3C
    data &h204E41,&h5C4F2040,&h4E604E75,&h203AFFD2,&h6700003E,&h224041FA
    data &h5045D1,&h703F24D8,&h51C8FFFC,&h43E9000E,&h48EA78F8,&h2C41FA
    data &hFFA42488,&h41FAFFC2,&h25500004,&h208A70FF,&h2540000C,&h206A0008
    data &h2550005C,&h20894E75,&h45FA0116,&h43FA0020,&h60CE4267,&h2F3AFF86
    data &h3F3C0031,&h4E410000,&h60000006,&h0,&h46FA0120,&h4E7548E7
    data &hFFFE45FA,&hEC41EA,&h132252,&h4A29000B,&h660000BA,&h52AA000C
    data &h6E0000B2,&h202A0014,&h6B0000A2,&h4A78043E,&h66000062,&h53806C00
    data &h6E256A,&h180014,&h4A2A0057,&h6C000018,&h487A0014,&h40E7206A
    data &h5C302A,&h5A6700,&h446C0,&h4ED0254F,&h204E68,&h25480024
    data &h4CEA78F8,&h2C302A,&h2A6E00,&h86B00,&h3640C0,&h46FC2700
    data &h4B80000,&h2A04A2,&h487A0032,&h2F2A0050,&h46C04E75,&h222A001C
    data &hB0816C00,&h302541,&h146000,&h282540,&h146000,&h20302F
    data &h3C0240,&h7000040,&h200060C0,&h45FA003A,&h6B80000,&h2A04A2
    data &h41EA0057,&h257CFFFF,&hFFFF000C,&h4A106600,&h184CDF,&h7FFF2F3A
    data &h743F3A,&h6E6600,&h6544F,&h4E754E73,&h4CDF7FFF,&h4E730000


  r$=chr$(13)

SUB bv(p%,v)  ' Set basvec parameter - p% = param #, v = value
  SHARED b(),bl
  b(p%+bl)=v
END SUB

main:
  '
  bv pv_p,&h70              ' Vector = VBI
  bv pb_v,VARPTRS(example)  ' Subprog = example
  bv pt_c,180               ' Initial delay = 3 seconds
  bv pt_reset_c,2           ' Period = 1/30th second
  bv pt_io_c,60             ' I/O delay = 1 second
  bv pb_call_f,true         ' Call type = postfix
  '
  call loc h_super_e        ' Set supervisor mode
  calls h_init_e            ' Install exception - here we go...


done:
  out 2,7
  'pokel b(pv_p+po),b(ph_v+po):system
  ' ^ no-TSR-exit for running here during debugging
  b(h_keep_c)=keep*k:call loc h_exit_e  ' Set mem to keep and TSR


sub example ' Basvec example exception-driven subprogram
  shared r$
  static n%,junk%
  incr n%
  
	IF n%=100 THEN
	' PRINT n%;r$;
'		junk%=form_alert%(2,"[0][ n%="+STR$(n%)+" | r$"+r$+" ][ OK ]")
		OPEN "J:\BV.ASC" FOR INPUT AS #1
			PRINT #1,n%;r$
		CLOSE #1
	END IF
END SUB

