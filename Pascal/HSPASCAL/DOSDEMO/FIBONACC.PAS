(* Recursive Fibonacci calculation. 26.06.90 *)
{$R-,S+}

program Fibonacci(input, output);

function fib(n : LongInt) : LongInt;
begin
  if n <= 1 then fib := n else fib := fib(n-1) + fib(n-2);
end;

var
  n : LongInt;

begin
  Writeln('Calculate some Fibonacci numbers');
  If RunFromMemory then
    Writeln('You can stop a calculation by pressing both shift keys');
  Writeln;
  repeat
    write('Enter number : ');  read(n);  writeln;
    writeln('Result       = ',fib(n))
  until n = 0
end.
