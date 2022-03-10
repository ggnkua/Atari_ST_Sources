

program factorials(input, output);


var
   i : integer;



function fact(n : integer) : integer;
   begin
      if n > 1 then
         fact := n * fact(n-1)
      else
         fact := 1;
   end;



begin
   for i := 1 to 10 do
      writeln('The factorial of ', i:1, ' is ', fact(i):1);
end.



