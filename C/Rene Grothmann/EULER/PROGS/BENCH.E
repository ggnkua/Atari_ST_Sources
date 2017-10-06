.. Bench function.

leert=0;

function leer
	return 0
endfunction

function bench(ffunction)
## bench("f",...) returns the time needed by f in milliseconds.
## ... is passed to f.
	global leert;
	func=ffunction;
	t=time(); count=0;
	repeat;
		if (time()>t+5); break; endif;
		func(args(2)); count=count+1;
	end;
	argt=(time()-t)/count;
	return round(argt-leert,6);
endfunction

leert=bench("leer");

function f1
	loop 1 to 1000;
	end;
	return 0;
endfunction

function f2
	loop 1 to 1000;
		endif;
	end;
	return 0;
endfunction

function f3
	x=0;
	loop 1 to 1000;
		x=3;
	end;
	return 0;
endfunction

function f4
	x=0;
	loop 1 to 1000;
		x;
	end;
	return 0;
endfunction

function f5
	A=zeros([2,2]);
	loop 1 to 1000;
		A=[1,2;3,4];
	end;
	return 0;
endfunction

function f6
	A=zeros([2,2]);
	loop 1 to 1000;
		A[1,1]=A[1,2];
	end;
	return 0;
endfunction

function f7
	loop 1 to 1000;
		v=1:10;
	end;
	return 0;
endfunction

function f8
	v=1:10;
	loop 1 to 1000;
		v{4}=5;
	end;
	return 0;
endfunction

function f9
	x=3;
	loop 1 to 1000;
		(x+x)*(x+x);
	end;
	return 0;
endfunction

function f10
	v=1:10;
	x=0;
	loop 1 to 1000;
		x=v{4};
	end;
	return 0;
endfunction

function f11
	v=1:10;
	x=0;
	loop 1 to 1000;
		v*v;
	end;
	return 0;
endfunction

looptime=0;

function musec (ffunction)
	global looptime;
	res=bench(ffunction,args(2))*1000-looptime;
	return {printf("%12.0f musec ",res),res};
endfunction

function test
	global looptime;
	format(14,6);
	{text,looptime}=musec("f1");
	text|" for one loop.",
	musec("f2")|" for: endif;",
	musec("f3")|" for: x=3;",
	musec("f9")|" for: (x+x)*(x+x);",
	musec("f4")|" for: x;",
	musec("f5")|" for: A=[1,2;3,4];",
	musec("f6")|" for: A[1,1]=A[1,2];",
	musec("f7")|" for: v=1:10;",
	musec("f8")|" for: v{4}=3;",
	musec("f10")|" for: x=v{4};",
	musec("f11")|" for: v*v;",
	looptime=0;
	return 0;
endfunction

comment
		ATARI ST values:
		 376 musecfor one loop.
		 253 musecfor: endif;
		2317 musecfor: x=3;
		5912 musecfor: (x+x)*(x+x);
		1312 musecfor: x;
		6397 musecfor: A=[1,2;3,4];
		7707 musecfor: A[1,1]=A[1,2];
		6362 musecfor: v=1:10;
		3552 musecfor: v{4}=3;
		3654 musecfor: x=v{4};
		4589 musecfor: v*v;
endcomment

test();

