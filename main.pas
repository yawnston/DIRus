unit main;

{$mode objfpc}{$H+}

interface

uses
  {TODO: TEST THIS ON UNIX}
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  FileCtrl, EditBtn, ComCtrls, ShellCtrls, ExtCtrls, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    goButton: TBitBtn;
    Image1: TImage;
    ImageList1: TImageList;
    Label2: TLabel;
    upButton: TSpeedButton;
    StatusBar1: TStatusBar;
    userPath: TEdit;
    Label1: TLabel;
    listBox: TListView;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure goButtonClick(Sender: TObject);
    procedure listBoxDblClick(Sender: TObject);
    procedure listBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure listBoxSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure upButtonClick(Sender: TObject);
  private
    procedure listDirectory(filePath: String);

  public


  end;

var
  currentDirectory:string;
  Form1: TForm1;


implementation

{$R *.lfm}

function addSep(path:String):String;
var pom:integer;
begin
  pom:=Length(path);
  if path[pom]<>'\' then
     addSep:=path+'\'
  else
     addSep:=path;
end;

function convertSize(inSize:double):String;
begin
     {no idea what this will do with large file sizes
      possible fix: remove the if from the last line}
     if (inSize<1024) then convertSize:=(floatToStr(inSize)+' B')
     else if (inSize<(1024*1024)) then convertSize:=(formatFloat('0.00',(inSize/1024))+' kB')
     else if (inSize<(1024*1024*1024)) then convertSize:=(formatFloat('0.00',(inSize/1024/1024))+' MB')
     else if (inSize<(1024*1024*1024*1024)) then convertSize:=(formatFloat('0.00',(inSize/1024/1024/1024))+' GB');
end;


procedure TForm1.goButtonClick(Sender: TObject);
begin
  {if entered directory is valid, show it, else stay where you are}
  if DirectoryExists(userPath.Text) then
    begin
     CurrentDirectory:=userPath.text;
     listDirectory(userPath.Text);
    end
  else
    userPath.Text:=CurrentDirectory;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  halt; {program stopping thingy, prevents exit exception for whatever reason}
end;

procedure TForm1.listBoxDblClick(Sender: TObject);
begin
    if listBox.selected.ImageIndex=1 then
    begin
         {this line is overkill, but leaving it in just in case}
         {CurrentDirectory:=addSep(addSep(currentDirectory)+listBox.selected.Caption);}
         listDirectory(addsep(addSep(currentDirectory)+listBox.selected.Caption));

    end;
end;

procedure TForm1.listBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if(listBox.ItemIndex=-1) then exit;
  if(Key=$0D) then begin
       Form1.listBoxDblClick(nil);
  end;
end;

procedure TForm1.listBoxSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var fileType,tempName,c:string;
    validImage:Boolean;
    dotIndex,i,extLength:integer; currChar:char;
    picFile:Tpicture; otherFile:TextFile;
begin
    Image1.Canvas.Clear;
     try
        begin

                {this loops finds the last dot in the file name(the last dot separates file extension)}
                {TODO: handle files with no extension(low priority)}
                dotIndex:=0; tempName:=item.Caption;
                for i:=1 to length(tempName) do begin
                    currChar:=tempName[i];
                    if(currChar='.') then dotIndex:=i;
                end;
                {now we either have the extension, or the index is 0(file has no extension)}
                if(dotIndex=0) then exit;
                {now we have an existing extension}
                extLength:=length(tempName)-dotIndex+1;
                fileType:=copy(tempName,dotIndex,extLength);
                {fileType now holds the ext, formatted:  .EXT}
                if((fileType='.jpeg') or (fileType='.bmp') or (fileType='.jpg') or (fileType='.png')) then begin
                    picFile:=TPicture.Create;
                    try
                       if not fileExists(currentDirectory+tempName) then exit;
                       picFile.LoadFromFile(currentDirectory+tempName);
                       {TODO: play around with drawing images and allow scrolling or opening image in new tab}
                       Image1.Canvas.Draw(10,10,picFile.Graphic);
                    finally
                      picFile.Free;
                    end;
                end
                {if it's not an image, we try to display it as a text file
                 NOTE: results in nonsense when used on an unsupported file format}
                else begin

                     try
                        {showmessage(currentDirectory+tempName);}
                        if not fileExists(currentDirectory+tempName) then exit;
                        AssignFile(otherFile,currentDirectory+tempName);
                        reset(otherFile);
                       for i:=1 to 30 do begin
                            readln(otherFile,c);
                            Image1.Canvas.TextOut(1,i*15,c);
                       end;
                     finally
                     end;
                end;
           end;
        finally
        end;
end;

procedure TForm1.upButtonClick(Sender: TObject);
var tempString:String;
    currL:integer;
    currChar:char;
begin
     Image1.Canvas.Clear;
     {CurrentDirectory is maintained with a backslash at the end,
      this means that by removing characters until hitting another backslash, we can go up one level}
      tempString:=CurrentDirectory;
      currL:=length(tempString);
      {3 is chosen because that's the length of the drive name, like C:\
       this means that when you are at that level, the function will do nothing}
      if(currL>3) then begin
                  delete(tempString,currL,1);
                  currChar:=tempString[currL-1];
                  while(ord(currChar)<>92) do begin
                        delete(tempString,currL,1);
                        currL:=length(tempString);
                        currChar:=tempString[currL];
                  end;
                  listDirectory(tempString);
      end;

end;

procedure Tform1.listDirectory(filePath:String);
var
  fileInfo:TSearchRec;
  {useful:Time(longint),Size(int64),Name(TFilename)}
  fileCount:integer; {if something overflows it's probably this}
  listItem:TListItem; {image index: 1=folder,2=file}
  fileTime:TDateTime;

begin
  Image1.Canvas.Clear;
  filePath:=addSep(filePath); {adds backslash separator if there isn't one}
  userPath.text:=filePath; {update the display path}
  currentDirectory:=filePath;
  listBox.items.clear; fileCount:=0; listbox.items.beginUpdate; {init}

  try {catches exception when no more files are found}
   {findFirst returns 0 if a matching file is found}
   if findFirst(filePath+'*',faDirectory and faAnyfile,fileInfo)=0 {add faHidden?} then
    begin
     repeat
      if (fileInfo.Name <> '.') and (fileInfo.Name <> '..') then begin
         listItem:=listBox.items.add;
         listItem.caption:=fileInfo.name;
         {this file is a directory}
         if (fileInfo.Attr and faDirectory) <> 0 then begin
            listItem.imageIndex:=1;
            listItem.SubItems.add('N/A');
         end
         {a file was found instead}
         else begin
            listItem.imageIndex:=2;
            listItem.SubItems.Add(convertSize(fileInfo.size));
         end;
         {updates date and time regardless of file type}
         fileTime:=FileDateToDateTime(fileInfo.Time);
         {the FormatDateTIme parameter is very specific
         DON'T CHANGE THIS FUTURE ME}
         listItem.SubItems.Add(FormatDateTime('ddddd t',fileTime));
         inc(fileCount);

      end;
     until findNext(fileInfo)<>0; {this means no more records were found}
                                  {IMPORTANT: this line updates the file info for the whole cycle}
    end;

  finally
    {finalizes the item list
    TODO: test no files found/a LOT of files found}
    listBox.items.endUpdate;
  end;

  findClose(fileInfo);
  StatusBar1.SimpleText:=(inttostr(fileCount)+' items'); {displays folder file count}

end;

end.

