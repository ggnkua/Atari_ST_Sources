
{ Oregon Software Pascal dynamic string package. }


{*VarFiles=0}  {INTF-ONLY}

function Len(var s : array [lo..hi:integer] of char) : integer; external;
{FuncMacro Len(lo,hi,s) = strlen(s)}

procedure Clear(var s : array [lo..hi:integer] of char); external;
{FuncMacro Clear(lo,hi,s) = (s[lo] = 0)}

procedure ReadString(var f : text;
		     var s : array [lo..hi:integer] of char); external;
{FuncMacro ReadString(f,lo,hi,s) = fgets(s, hi-lo+1, f)}

procedure WriteString(var f : text;
		      var s : array [lo..hi:integer] of char); external;
{FuncMacro WriteString(f,lo,hi,s) = fprintf(f, "%s", s)}

procedure Concatenate(var d : array [lod..hid:integer] of char;
		      var s : array [los..his:integer] of char); external;
{FuncMacro Concatenate(lod,hid,d,los,his,s) = strcat(d, s)}

function Search(var s : array [lo..hi:integer] of char;
		var s2 : array [lo2..hi2:integer] of char;
		i : integer) : integer; external;
{FuncMacro Search(lo,hi,s,lo2,hi2,s2,i) = strpos2(s,s2,i-lo)+lo}

procedure Insert(var d : array [lod..hid:integer] of char;
		 var s : array [los..his:integer] of char;
		 i : integer); external;
{FuncMacro Insert(lod,hid,d,los,his,s,i) = strinsert(s,d,i-lod)}

procedure Assign(var d : array [lo..hi:integer] of char;
		 var s : array [los..his:integer] of char); external;
{FuncMacro Assign(lo,hi,d,los,his,s) = strcpy(d,s)}

procedure AssChar(var d : array [lo..hi:integer] of char;
		  c : char); external;
{FuncMacro AssChar(lo,hi,d,c) = sprintf(d, "%c", c)}

function Equal(var s1 : array [lo1..hi1:integer] of char;
	       var s2 : array [lo2..hi2:integer] of char) : boolean; external;
{FuncMacro Equal(lo1,hi1,s1,lo2,hi2,s2) = !strcmp(s1,s2)}

procedure DelString(var s; i, j : integer); external;

procedure SubString(var d; var s; i, j : integer); external;

