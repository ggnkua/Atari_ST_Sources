program Minimal;
{ minimales ObjectGEM-Programm }

  uses OWindows;

  var MyApplication: TApplication;

begin
  MyApplication.Init('Minimal');
  MyApplication.Run;
  MyApplication.Done
end.