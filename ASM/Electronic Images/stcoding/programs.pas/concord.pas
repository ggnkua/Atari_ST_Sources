
{ Concordance program }

program concordance(input,output);

type

tree = ^treenode;

treenode =
  record
    word  : string;
    count : integer; 
    leftptr, rightptr : tree
  end;
      
procedure createtree(var treeroot : tree);
begin
  treeroot := nil;
end;

procedure insert(foundword : string ; var treeroot : tree);
begin
  if treeroot = nil then
  begin
    new (treeroot);
    treeroot^.word := foundword;
    treeroot^.count := 1;
    treeroot^.leftptr := nil;
    treeroot^.rightptr := nil;
  end
  else
    if foundword < treeroot^.word then
      insert(foundword,treeroot^.leftptr)
    else if foundword > treeroot^.word then
      insert(foundword,treeroot^.rightptr)
    else
      treeroot^.count := treeroot^.count + 1;      
end;

procedure printentry (treeroot : tree);
begin
  writeln (treeroot^.word,'  ',treeroot^.count);
end;

procedure inorder(treeroot : tree);
begin
  if treeroot <> nil then
  begin
    inorder(treeroot^.leftptr);
    printentry (treeroot);
    inorder(treeroot^.rightptr);
  end;
end;

procedure read_word(var rstring : string);
var
  rchar : char;
  exit  : boolean;
begin
  exit :=false;
  rstring :='';
  repeat
    read(rchar);  
    if ((ord(rchar) >= 65) and (ord(rchar) <= 91)) then
      rstring := rstring + rchar
    else exit := TRUE;
  until exit or eoln
end;

procedure main_program;
var
  treeroot : tree;
  rstring  : string;
begin
  createtree(treeroot);
  while not eoln do
  begin
    read_word(rstring);
    if rstring <> '' then
      insert(rstring,treeroot);
  end;
  inorder(treeroot);
end;

begin
  main_program;
end.
