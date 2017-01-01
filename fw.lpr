program fw;

{$mode objfpc}{$H+}

uses
  {TODO: test this on unix}
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces,
  Forms, main, dialogs
  ;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  {this loads the initial directory
   defaults to C:\}

  Form1.goButtonClick(nil);

  Application.Run;


end.

