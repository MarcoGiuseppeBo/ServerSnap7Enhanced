{****** BEGIN BO MARCO LICENZE ******}
(*

    This file is part of BOMARCO_SCADA  framework.

    BOMARCO_SCADA Copyright (C) 2018 Bo Marco
      Marcogiuseppe.bo@gmail.com


  Version: MPL 1.1/GPL 2.0/LGPL 2.1

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.

  The Original Code is By BOMARCO_SCADA framework.
   The Initial Developer of the Original Code is Bo Marco.

  Portions created by the Initial Developer are Copyright (C) 2018
  the Initial Developer. All Rights Reserved.

  Contributor(s):
    Lorenzo Bardi  lorenzo.bardi@hotmail.com

  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.




  This framework use Synopse mORMot framework.
      Copyright (C) 2021 Arnaud Bouchez
      Synopse Informatique - https://synopse.info .

  This  framework use Snap7  Copyright (C) 2013, 2014 Davide Nardella
        snap7.sourceforge.net

*)

{****** END BO MARCO LICENZE ******}

unit u_tfrmserver;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,System.SyncObjs,
  Vcl.CheckLst, Vcl.ComCtrls,snap7,inifileS,u_mormot_datamodule_BSX_ENGINE,u_def_param_db,
  U_BSX_mormot_interface, System.ImageList, Vcl.ImgList,Xml.XMLDoc,Xml.XMLIntf, SynCommons,
  U_dm_import_data_engine, Vcl.Grids,  u_mormot_server_read_ini;

Const
  DBSize = 2048;

type
  PItemRecord = ^TItemRecord;
  TItemRecord = record
     path: string;
     arrayMinMax:TarrayMinMax;
     flagArrayPri:boolean;
     tipo:string;
  end;
  type TThreadDisplayData = class (tthread)
    private
  protected
    procedure Execute; override;
  //  procedure execWork;
  public
       myterminated:boolean;
  end;

type
  TFrmServer = class(TForm)
    SB: TStatusBar;
    Panel1: TPanel;
    Label1: TLabel;
    StartBtn: TButton;
    EdIP: TEdit;
    StopBtn: TButton;
    PC: TPageControl;
    TabSheet1: TTabSheet;
    Label2: TLabel;
    lblMask: TLabel;
    List: TCheckListBox;
    LogTimer: TTimer;
    ImageList1: TImageList;
    Timer1: TTimer;
    CheckBox1: TCheckBox;
    B_uncheck_all: TButton;
    B_check_all: TButton;
    Panel2: TPanel;
    Log: TMemo;
    Splitter1: TSplitter;
    E_TimeDelay: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LogTimerTimer(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure B_uncheck_allClick(Sender: TObject);
    procedure B_check_allClick(Sender: TObject);
    procedure PCResize(Sender: TObject);

  private
   GDm_BSX_ENGINE:TDatamodule;
   Gfilexml:string;
   Gnameplc:string;
   Server : TS7Server;
    FMask : longword;
    TIM : packed array[0..DBSize-1] of byte;
//    DB1 : packed array[0..DBSize-1] of byte;
//    DB2 : packed array[0..DBSize-1] of byte;
//    DB3 : packed array[0..DBSize-1] of byte;
    FServerStatus: integer;
    FClientsCount: integer;
    procedure UpdateMask;
    procedure MaskToForm;
    procedure MaskToLabel;
    procedure SetFMask(const Value: longword);
    procedure DumpData(P : PS7Buffer; Memo : TMemo; Count : integer);
    procedure SetFServerStatus(const Value: integer);
    procedure SetFClientsCount(const Value: integer);
    procedure loadTvDataSource(xml:string;TV:TTreeView;XMLDocument:TXMLDocument);
    procedure treeDeletion(Sender: TObject; Node: TTreeNode);
    //da bsx_core
    function mygetValueByPath(path:string;v:variant;const node:ixmlnode):variant;
    function findnodeBypath(const path:string;const StartNode:ixmlnode):ixmlnode; /// serve da supporto per  mygetValueByPath
    function CreatePlcSourceInfoxml(const xPlcSourceName:string;const xml:string):TPlcSourceInfoxml;
    function GetPathNode(node:TTreeNode):string;
    function GetTipoNode(node:TTreeNode):string;
    procedure AddVariableToGrid(x:tstringGrid;path:sTring;tipo:string);
    procedure updateDisplayDataDb;
  public
    { Public declarations }
   // paramDb:array of TparamDb;
//    DB1_changed : boolean;
//    DB2_changed : boolean;
//    DB3_changed : boolean;
    property LogMask : longword read FMask write SetFMask;
    property ServerStatus : integer read FServerStatus write SetFServerStatus;
    property ClientsCount : integer read FClientsCount write SetFClientsCount;
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonDelClick(Sender: TObject);
    procedure buttonSetvalueClick(Sender: TObject);
    procedure setvalueOfGrid(numdb:integer);
    procedure onGrid_dblClick(Sender: TObject);
    function convert_file_db_to_xml(var filename:string):boolean;
  end;
var
  FrmServer: TFrmServer;
  ThreadDisplayData:TThreadDisplayData;
  sema_InReadcallback:TSynLocker;
implementation

uses u_change_value,
     U_request_file_xml_db,
     U_Snap7_reader_and_writer_block_fake;

{$R *.dfm}
 // function RWAreaCallback(usrPtr : pointer; Sender, Operation : integer; PTag : PS7Tag; pUsrData : pointer) : integer; stdcall;

function readcallback(usrPtr : pointer; Sender, Operation : integer; PTag : PS7Tag; pUsrData : pointer) : integer;
//procedure ReadEventsCallback(usrPtr : pointer; PEvent : PSrvEvent ; Size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

type myuser = record
  x: array[0..10000] of byte;
end;

type P = ^myuser;

var xparmaDb:TparamDb;
    numDb:integer;
    Tag:TS7Tag;
    Pt: P;
    k:integer;
  //  x: array [0..10000] of byte;
    start,len:integer;
    bitType:boolean;
    bytestart:integer;
    bitstart:integer;
    bytex:byte;
    function extracbit(bytex:byte;bitpos:integer):byte;
    begin
        result:=Siem_GetBit_UNO_ZERO(bytex,bitpos);
    end;
begin
  sema_InReadcallback.Lock;
  try
    if Operation = 0 then
    begin
      try
        FrmServer.Log.Lines.Add('sleep');
        sleep(StrToInt(FrmServer.E_TimeDelay.Text)); //TEST!!!!!!!!
      except;
      end;



      Tag:= PTag^;
      numDb:= Tag.DBNumber;
      start:=Tag.Start;
      len:=Tag.Size;
      bitType:=Tag.WordLen=S7WLBit;

      if GDizioDataDb.TryGetValue(numDb,xparmaDb) then
      begin
         if not bitType then
         begin

            Pt:= pUsrData;
            move(GDataDb[xparmaDb.indexGDataDb].buff[start],Pt.x[0],len);
    //      pUsrData:= @GDataDb[xparmaDb.indexGDataDb].buff[start];
            {


            Pt:= pUsrData;

            move(GDataDb[xparmaDb.indexGDataDb].buff[0],x[0],SizeOf(GDataDb[xparmaDb.indexGDataDb].buff));

            for k := 0 to High(GDataDb[xparmaDb.indexGDataDb].buff) do
            begin
                Pt.x[k]:= x[k];
            end;}
         end
         else
         begin
            Pt:= pUsrData;
            bytestart:= start div 8;
            bitstart:=start mod 8;
            for k := 0 to len-1  do
            begin
               bytex:=extracbit(GDataDb[xparmaDb.indexGDataDb].buff[bytestart],bitstart);
               Pt.x[k]:=bytex;
               inc(bitstart);
               if bitstart>7 then
               begin
                  bitstart:=0;
                  inc(bytestart);
               end
            end;
         end;
         result:=0;
      end;

    end;
  finally
    sema_InReadcallback.unLock;

  end;
end;

procedure ServerCallback(usrPtr : pointer; PEvent : PSrvEvent; Size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var k:integer;
    xparmaDb:TparamDb;
    numDb:integer;
begin
  // Checks if we are interested in this event.
  // We need to update DB Memo contents only if our DB changed.
  // To avoid this check, an alternative way could be to mask
  // the Server.EventsMask property.
  if (PEvent^.EvtCode=evcDataWrite) and  // write event
     (PEvent^.EvtRetCode=0) and          // succesfully
     (PEvent^.EvtParam1=S7AreaDB) then   // it's a DB
  begin
     numDb:=PEvent^.EvtParam2;
     if GDizioDataDb.TryGetValue(numDb,xparmaDb) then
     begin
         GDataDb[xparmaDb.indexGDataDb].changed.SetEvent;
         // GDizioDataDb.AddOrSetValue(numDb,xparmaDb);
     end;


//    case PEvent^.EvtParam2 of
//      1 : TFrmServer(usrPtr).DB1_changed:=true;
//      2 : TFrmServer(usrPtr).DB2_changed:=true;
//      3 : TFrmServer(usrPtr).DB3_changed:=true;
//    end;
  end;

end;
{ TFrmServer }
procedure TFrmServer.DumpData(P: PS7Buffer; Memo: TMemo; Count: integer);
Var
  SHex, SChr, SOfs : string;
  Ch : AnsiChar;
  c, cnt, ofs : integer;
begin
  Memo.Lines.Clear;
  Memo.Lines.BeginUpdate;
  SHex:='';SChr:='';cnt:=0;ofs:=0;
  try
    for c := 0 to Count - 1 do
    begin
      SHex:=SHex+IntToHex(P^[c],2)+' ';
      Ch:=AnsiChar(P^[c]);
      if not (Ch in ['a'..'z','A'..'Z','0'..'9','_','$','-',#32]) then
        Ch:='.';
      SChr:=SChr+String(Ch);
      inc(cnt);
      if cnt=16 then
      begin
        SOfs:=IntToHex(ofs,4);
        Memo.Lines.Add(SOfs+' - '+SHex+'  '+SChr);
        SHex:='';SChr:='';
        cnt:=0;
        ofs:=ofs+16;
      end;
    end;
    // Dump remainder
    if cnt>0 then
    begin
      while Length(SHex)<48 do
        SHex:=SHex+' ';
      SOfs:=IntToHex(ofs,4);
      Memo.Lines.Add(SOfs+' - '+SHex+'  '+SChr);
    end;
  finally
    Memo.Lines.EndUpdate;
  end;
end;

procedure TFrmServer.FormCreate(Sender: TObject);
var
  ThePlatform : string;
  Wide : string;
  ini:tinifile;
  k:integer;
  indexs:string;
  XparamDb:tparamDb;
  comoArea:packed array[0..$FFFF] of byte;
  File_def_xml:string;
  r:TGetPlcSourceInfoList_back;
  fileini:string;
  filenameDb:String;
  x:TF_ask_name_file_db_xml;
  GetPlcInfoList_back:TGetPlcInfoList_back;
  GetPlcSourceInfoList_back:TGetPlcSourceInfoList_back;
begin

//C:\!mysw\MORMOT_SCADA\my_server_snap7_enhanced\param.ini

   filenameDb:='';
   if paramStr(1)='' then
   begin
       x:=TF_ask_name_file_db_xml.Create(nil);
       try
         x.ShowModal;
         if x.return_OK then
         begin
           filenameDb:=trim(x.Edit_DB.Text);
         end
       finally
         freeandnil(x);
       end;

   end
   else
   begin
      filenameDb:=trim(paramStr(1));
   end;
   if filenameDb<>'' then
   begin
     if not FileExists(filenameDb) then
     begin
        showmessage(filenameDb+' not present, bye');
        filenameDb:='';
     end;
   end;
   if filenameDb='' then
   begin
      application.Terminate;
      exit;
   end;

  if uppercase(ExtractFileExt(filenameDb))<>'.XML' then
  begin
     try
        if convert_file_db_to_xml(filenameDb) = false then
        begin
            application.Terminate;
            exit;
        end;
     except
        on e:Exception do
        begin
           showmessage('error on convert to xml '+e.Message);
           application.Terminate;
           exit;
        end;
     end;



  end
  else
  begin
    Gfilexml:=filenameDb;
  end;

  Server:=TS7Server.Create;
  GDm_BSX_ENGINE:=tDm_BSX_ENGINE.Create(self,Gfilexml);


  GetPlcInfoList_back:=(GDm_BSX_ENGINE as TDm_BSX_ENGINE).dm_GetPlcInfoList('como');

  if length(GetPlcInfoList_back.PlcinfoArr)<1 then
  begin
     showmessage('No plc param find on xml <'+Gfilexml+'>');
     application.Terminate;
     exit;
  end;

  Gnameplc:=GetPlcInfoList_back.PlcinfoArr[0].NAME_PLC;


  GetPlcSourceInfoList_back:=(GDm_BSX_ENGINE as TDm_BSX_ENGINE).dm_GetPlcSourceInfoList('como',Gnameplc);

  var nameds:string;
  for k:=low(GetPlcSourceInfoList_back.InfoPlcSourceArr) to high(GetPlcSourceInfoList_back.InfoPlcSourceArr) do
  begin
     nameds:=GetPlcSourceInfoList_back.InfoPlcSourceArr[k].name;
     try
        XparamDb.numdb:=-1;
        XparamDb.Dm_BSX_ENGINE:=GDm_BSX_ENGINE;

          XparamDb.NamePlc:=Gnameplc;
          XparamDb.NameDataSource:=nameds;//trim(ini.readstring ('DB'+indexs,'NameDs',''));
          XparamDb.xmlDefine:=Gfilexml;

          XparamDb.lendb:=GetPlcSourceInfoList_back.InfoPlcSourceArr[k].LLBuf;
          XparamDb.numdb:=strtoint(GetPlcSourceInfoList_back.InfoPlcSourceArr[k].NAME_ON_PLC);
          XparamDb.desdb:=GetPlcSourceInfoList_back.InfoPlcSourceArr[k].name;

          XparamDb.xml:=GetPlcSourceInfoList_back.InfoPlcSourceArr[k].xml;
          XparamDb.PlcSourceInfoxml:=CreatePlcSourceInfoxml(XparamDb.NameDataSource,XparamDb.xml);
          XparamDb.PlcSourceInfoxml.xmlCreated:=true;
          if  XparamDb.numdb<>-1 then
          begin
             setlength(GDataDb[GDataDbcount].buff,XparamDb.lendb);
             FillChar(GDataDb[GDataDbcount].buff[0],XparamDb.lendb,0);
             GDataDb[GDataDbcount].changed:=tevent.Create(nil,false,false,GDataDbcount.ToString);
             GDataDb[GDataDbcount].numDb:=XparamDb.numdb;
             GDataDb[GDataDbcount].rifServer:=server;
             XparamDb.indexGDataDb:=GDataDbcount;
             XparamDb.tabsheet:=ttabsheet.Create(pc);
             XparamDb.tabsheet.Caption:=XparamDb.desdb+'('+ XparamDb.numdb.tostring+')';
             XparamDb.tabsheet.PageControl:=pc;
             if XparamDb.Dm_BSX_ENGINE<>nil then
             begin
                XparamDb.pcdata:=TPageControl.Create(self);
                XparamDb.pcdata.parent:=XparamDb.tabsheet;
                XparamDb.pcdata.Align:=talign.alClient;
                XparamDb.tabsheetData:=ttabSheet.Create(self);
                XparamDb.tabsheetData.Caption:='Data';
                XparamDb.tabsheetData.PageControl:=XparamDb.pcdata;
                XparamDb.TV:=TTreeView.create(self);
                XparamDb.TV.tag:=XparamDb.numdb;
                XparamDb.TV.onclick:=TreeView1Click;
                XparamDb.TV.OnDblClick:=TreeView1DblClick;

                XparamDb.TV.OnDeletion:=treeDeletion;
                XparamDb.TV.Left:=2;
                XparamDb.TV.Height :=136;
                XparamDb.TV.Align := alBottom;
                XparamDb.TV.Images:= ImageList1;
              //  XparamDb.TV.Indent := 19;
//                XparamDb.TV.Items.NodeData. = {
//    0303000000200000000000000000000000FFFFFFFFFFFFFFFF00000000000000
//    000000000001013100200000000000000000000000FFFFFFFFFFFFFFFF000000
//    00000000000000000001013200200000000000000000000000FFFFFFFFFFFFFF
//    FF00000000000000000000000001013300}
//                   ExplicitTop = 460
                XparamDb.TV.parent:=XparamDb.tabsheetData;
                loadTvDataSource(XparamDb.xml,XparamDb.tv,XparamDb.PlcSourceInfoxml.dataPlcXMLDocument);
                XparamDb.panelButton:=tpanel.Create(self);
                XparamDb.panelButton.Caption:='';
                XparamDb.panelButton.Align:=alTop;
                XparamDb.panelButton.Left := 224     ;
                XparamDb.panelButton.Top  := 366     ;
                XparamDb.panelButton.Width := 632    ;
                XparamDb.panelButton.Height := 30    ;
                XparamDb.panelButton.parent:=XparamDb.tabsheetData;
                XparamDb.buttonAdd:=tbutton.create(self);
                XparamDb.buttonAdd.Caption:='Add';
                XparamDb.buttonAdd.Left := 2     ;
                XparamDb.buttonAdd.Top  := 1     ;
                XparamDb.buttonAdd.Width := 60    ;
                XparamDb.buttonAdd.Height := 26    ;
                XparamDb.buttonAdd.parent:=XparamDb.panelButton;
                XparamDb.buttonAdd.tag:=XparamDb.numdb;
                XparamDb.buttonAdd.OnClick:= ButtonAddClick;
                XparamDb.buttonDel:=tbutton.create(self);
                XparamDb.buttonDel.Caption:='Del';
                XparamDb.buttonDel.Left := 65     ;
                XparamDb.buttonDel.Top  := 1     ;
                XparamDb.buttonDel.Width := 60    ;
                XparamDb.buttonDel.Height := 26    ;
                XparamDb.buttonDel.parent:=XparamDb.panelButton;
                XparamDb.buttonDel.tag:=XparamDb.numdb;
                XparamDb.buttonDel.OnClick:= ButtonDelClick;
                XparamDb.buttonSetvalue:=tbutton.create(self);
                XparamDb.buttonSetvalue.Caption:='Set value';
                XparamDb.buttonSetvalue.Left := 128     ;
                XparamDb.buttonSetvalue.Top  := 1     ;
                XparamDb.buttonSetvalue.Width := 60    ;
                XparamDb.buttonSetvalue.Height := 26    ;
                XparamDb.buttonSetvalue.parent:=XparamDb.panelButton;
                XparamDb.buttonSetvalue.tag:=XparamDb.numdb;
                XparamDb.buttonSetvalue.OnClick:= buttonSetvalueClick;

                XparamDb.Split:= TSplitter.Create(Self);
                XparamDb.Split.Align:= alBottom;
                XparamDb.Split.Parent:= XparamDb.tabsheetData;

                XparamDb.StringGrid:= TStringGrid.Create(self); // TStringGrid.Create(self);
                XparamDb.StringGrid.Options:=XparamDb.StringGrid.Options+[gocolsizing];
                XparamDb.StringGrid.Align:=alclient;
                XparamDb.StringGrid.Left := 224     ;
                XparamDb.StringGrid.Top  := 366     ;
                XparamDb.StringGrid.Width := 632    ;
                XparamDb.StringGrid.Height := 202   ;


                XparamDb.StringGrid.ColCount := 3   ;
                XparamDb.StringGrid.FixedCols := 0  ;
                XparamDb.StringGrid.RowCount := 2   ;
                XparamDb.StringGrid.FixedRows := 1  ;

//                JvStringGrid2.ColCount := 3   ;
//                JvStringGrid2.FixedCols := 0  ;
//                JvStringGrid2.RowCount := 2   ;
//                JvStringGrid2.FixedRows := 1  ;








                XparamDb.StringGrid.TabOrder := 0   ;
                XparamDb.StringGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign];
                XparamDb.StringGrid.ColWidths[0]:=113;
                XparamDb.StringGrid.ColWidths[1]:=64;
                XparamDb.StringGrid.ColWidths[2]:=500;
//                XparamDb.StringGrid.DefaultColAlignment[2]:=ca
                XparamDb.StringGrid.Cells[0,0]:='Variable name';
                XparamDb.StringGrid.Cells[1,0]:='Type';
                XparamDb.StringGrid.Cells[2,0]:='Value';
                XparamDb.StringGrid.OnDblClick:=onGrid_dblClick;
                XparamDb.StringGrid.tag:=XparamDb.numdb;
                XparamDb.StringGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign];
//                XparamDb.StringGrid.  OnClick = StringGrid1Click
//                XparamDb.StringGrid.  ColWidths = (
//    64
//    113
//    249)
                XparamDb.StringGrid.parent:=XparamDb.tabsheetData;

                XparamDb.tabsheetDump:=ttabSheet.Create(self);
                XparamDb.tabsheetDump.Caption:='Dump';
                XparamDb.tabsheetDump.PageControl:=XparamDb.pcdata;




             end;
             XparamDb.memo:=tmemo.Create(self);
             XparamDb.memo.Align:=talign.alClient;
             if XparamDb.Dm_BSX_ENGINE<>nil then
             begin
                XparamDb.memo.Parent:=XparamDb.tabsheetDump;
             end
             else
             begin
                XparamDb.memo.Parent:=XparamDb.tabsheet;
             end;
             GDizioDataDb.Add(XparamDb.numdb,XparamDb);
             inc(GDataDbcount);
             // solo per test freeandnil(XparamDb.Dm_BSX_ENGINE);

          end;
     except
       XparamDb.numdb:=-1;
     end;



  end;

 (*  setlength(paramDb,100);
   for k:=0 to 99 do
   begin
     paramDb[k].numdb:=-1;
   end;
   *)
//  [DB01]
// NUMDB=1
// DESDB='DESDB1'
// LENDB=10
(*
   fileini:=trim(paramstr(1));
   if fileini='' then fileini:='C:\!mysw\MORMOT_SCADA\my_server_snap7_enhanced\param.ini';

   ini:=tinifile.create(fileini);
   GDataDbcount:=0;
   File_def_xml:=trim(ini.readstring('XML_DEFINE','FILEXML',''));
   for k:=0 to 99 do
   begin
     indexs:=formatfloat('00',k);
     try
        XparamDb.numdb:=-1;
        XparamDb.Dm_BSX_ENGINE:=nil;

          XparamDb.NamePlc:=trim(ini.readstring ('DB'+indexs,'NamePlc',''));
          XparamDb.NameDataSource:=trim(ini.readstring ('DB'+indexs,'NameDs',''));
          XparamDb.xmlDefine:=File_def_xml;

          if (XparamDb.NamePlc<>'') and (XparamDb.NameDataSource<>'NameDs') and (File_def_xml<>'') then
          begin
              XparamDb.desdb:=XparamDb.NameDataSource;
              XparamDb.Dm_BSX_ENGINE:=tDm_BSX_ENGINE.Create(self,XparamDb);
              r:=(XparamDb.Dm_BSX_ENGINE as tDm_BSX_ENGINE).dm_GetPlcSourceInfoList('Dummy',XparamDb.NamePlc);
              if Length(r.InfoPlcSourceArr)=1 then
              begin
                XparamDb.lendb:=r.InfoPlcSourceArr[0].LLBuf;
                XparamDb.numdb:=strtoint(r.InfoPlcSourceArr[0].NAME_ON_PLC);
                XparamDb.xml:=r.InfoPlcSourceArr[0].xml;
                XparamDb.PlcSourceInfoxml:=CreatePlcSourceInfoxml(XparamDb.NameDataSource,XparamDb.xml);
                XparamDb.PlcSourceInfoxml.xmlCreated:=true;
              end;
              //XparamDb.numdb:= lo setta nella creazione!
              //XparamDb.lendb:=
          end
          else
          begin
             XparamDb.numdb:=ini.readinteger('DB'+indexs,'NUMDB',-1);
             XparamDb.desdb:=ini.readstring ('DB'+indexs,'DESDB','');
             XparamDb.lendb:=ini.readinteger('DB'+indexs,'LENDB',0);
          end;
          if  XparamDb.numdb<>-1 then
          begin


             setlength(GDataDb[GDataDbcount].buff,XparamDb.lendb);
             FillChar(GDataDb[GDataDbcount].buff[0],XparamDb.lendb,0);
             GDataDb[GDataDbcount].changed:=tevent.Create(nil,false,false,GDataDbcount.ToString);
             GDataDb[GDataDbcount].numDb:=XparamDb.numdb;
             GDataDb[GDataDbcount].rifServer:=server;
             XparamDb.indexGDataDb:=GDataDbcount;
             XparamDb.tabsheet:=ttabsheet.Create(pc);
             XparamDb.tabsheet.Caption:=XparamDb.desdb+'('+ XparamDb.numdb.tostring+')';
             XparamDb.tabsheet.PageControl:=pc;
             if XparamDb.Dm_BSX_ENGINE<>nil then
             begin
                XparamDb.pcdata:=TPageControl.Create(self);
                XparamDb.pcdata.parent:=XparamDb.tabsheet;
                XparamDb.pcdata.Align:=talign.alClient;
                XparamDb.tabsheetData:=ttabSheet.Create(self);
                XparamDb.tabsheetData.Caption:='Data';
                XparamDb.tabsheetData.PageControl:=XparamDb.pcdata;
                XparamDb.TV:=TTreeView.create(self);
                XparamDb.TV.tag:=XparamDb.numdb;
                XparamDb.TV.onclick:=TreeView1Click;
                XparamDb.TV.OnDblClick:=TreeView1DblClick;

                XparamDb.TV.OnDeletion:=treeDeletion;
                XparamDb.TV.Left:=2;
                XparamDb.TV.Height :=136;
                XparamDb.TV.Align := alBottom;
                XparamDb.TV.Images:= ImageList1;
              //  XparamDb.TV.Indent := 19;
//                XparamDb.TV.Items.NodeData. = {
//    0303000000200000000000000000000000FFFFFFFFFFFFFFFF00000000000000
//    000000000001013100200000000000000000000000FFFFFFFFFFFFFFFF000000
//    00000000000000000001013200200000000000000000000000FFFFFFFFFFFFFF
//    FF00000000000000000000000001013300}
//                   ExplicitTop = 460
                XparamDb.TV.parent:=XparamDb.tabsheetData;
                loadTvDataSource(XparamDb.xml,XparamDb.tv,XparamDb.PlcSourceInfoxml.dataPlcXMLDocument);
                XparamDb.panelButton:=tpanel.Create(self);
                XparamDb.panelButton.Caption:='';
                XparamDb.panelButton.Align:=alTop;
                XparamDb.panelButton.Left := 224     ;
                XparamDb.panelButton.Top  := 366     ;
                XparamDb.panelButton.Width := 632    ;
                XparamDb.panelButton.Height := 30    ;
                XparamDb.panelButton.parent:=XparamDb.tabsheetData;
                XparamDb.buttonAdd:=tbutton.create(self);
                XparamDb.buttonAdd.Caption:='ADD';
                XparamDb.buttonAdd.Left := 2     ;
                XparamDb.buttonAdd.Top  := 1     ;
                XparamDb.buttonAdd.Width := 60    ;
                XparamDb.buttonAdd.Height := 26    ;
                XparamDb.buttonAdd.parent:=XparamDb.panelButton;
                XparamDb.buttonAdd.tag:=XparamDb.numdb;
                XparamDb.buttonAdd.OnClick:= ButtonAddClick;
                XparamDb.buttonDel:=tbutton.create(self);
                XparamDb.buttonDel.Caption:='Del';
                XparamDb.buttonDel.Left := 65     ;
                XparamDb.buttonDel.Top  := 1     ;
                XparamDb.buttonDel.Width := 60    ;
                XparamDb.buttonDel.Height := 26    ;
                XparamDb.buttonDel.parent:=XparamDb.panelButton;
                XparamDb.buttonDel.tag:=XparamDb.numdb;
                XparamDb.buttonDel.OnClick:= ButtonDelClick;
                XparamDb.buttonSetvalue:=tbutton.create(self);
                XparamDb.buttonSetvalue.Caption:='Set value';
                XparamDb.buttonSetvalue.Left := 128     ;
                XparamDb.buttonSetvalue.Top  := 1     ;
                XparamDb.buttonSetvalue.Width := 60    ;
                XparamDb.buttonSetvalue.Height := 26    ;
                XparamDb.buttonSetvalue.parent:=XparamDb.panelButton;
                XparamDb.buttonSetvalue.tag:=XparamDb.numdb;
                XparamDb.buttonSetvalue.OnClick:= buttonSetvalueClick;


                XparamDb.StringGrid:=TStringGrid.Create(self);
                XparamDb.StringGrid.Align:=alclient;
                XparamDb.StringGrid.Left := 224     ;
                XparamDb.StringGrid.Top  := 366     ;
                XparamDb.StringGrid.Width := 632    ;
                XparamDb.StringGrid.Height := 202   ;
                XparamDb.StringGrid.ColCount := 3   ;
                XparamDb.StringGrid.FixedCols := 0  ;
                XparamDb.StringGrid.RowCount := 1   ;
                XparamDb.StringGrid.FixedRows := 0  ;
                XparamDb.StringGrid.TabOrder := 0   ;
                XparamDb.StringGrid.ColWidths[0]:=113;
                XparamDb.StringGrid.ColWidths[1]:=64;
                XparamDb.StringGrid.ColWidths[2]:=500;
                XparamDb.StringGrid.Cells[0,0]:='Name Variab';
                XparamDb.StringGrid.Cells[1,0]:='Type';
                XparamDb.StringGrid.Cells[2,0]:='Value';

//                XparamDb.StringGrid.  OnClick = StringGrid1Click
//                XparamDb.StringGrid.  ColWidths = (
//    64
//    113
//    249)
                XparamDb.StringGrid.parent:=XparamDb.tabsheetData;

                XparamDb.tabsheetDump:=ttabSheet.Create(self);
                XparamDb.tabsheetDump.Caption:='Dump';
                XparamDb.tabsheetDump.PageControl:=XparamDb.pcdata;




             end;
             XparamDb.memo:=tmemo.Create(self);
             XparamDb.memo.Align:=talign.alClient;
             if XparamDb.Dm_BSX_ENGINE<>nil then
             begin
                XparamDb.memo.Parent:=XparamDb.tabsheetDump;
             end
             else
             begin
                XparamDb.memo.Parent:=XparamDb.tabsheet;
             end;
             GDizioDataDb.Add(XparamDb.numdb,XparamDb);
             inc(GDataDbcount);
             // solo per test freeandnil(XparamDb.Dm_BSX_ENGINE);

          end;
     except
       XparamDb.numdb:=-1;
     end;
   end;
   ini.Free;

*)









   for k := 0 to GDataDbcount-1 do
   begin
     GDataDb[k].changed.SetEvent;
   end;


  // Cosmetics
  // Infamous trick to get the platform size
  // Maybe it could not work ever, but we need only a form caption....
  case SizeOf(NativeUint) of
     4 : Wide := ' [32 bit]';
     8 : Wide := ' [64 bit]';
    else Wide := ' [?? bit]';
  end;
  {$IFDEF MSWINDOWS}
     ThePlatform:='Windows platform';
  {$ELSE}
     ThePlatform:='Unix platform';
  {$ENDIF}
  Caption:='Snap7 Server Enhanced - '+//+ThePlatform+Wide+
  {$IFDEF FPC}
    'By Marco Bo, Lorenzo Bardi [FPC]';
  {$ELSE}
    'By Marco Bo, Lorenzo Bardi';
  {$ENDIF}
  PC.ActivePageIndex:=0;
//  Button1Click(Button1);
(*  for xparamdb in gDizioDataDb.values do
  begin
    if xparamdb.numdb>-1 then
    begin
       move(GDataDb[xparamdb.indexGDataDb].buff[0],comoArea,xparamdb.lendb);
       DumpData(@comoArea[0],xparamdb.Memo,xparamdb.lendb);
    end;
  end;
  *)
//  DumpData(@DB1,MemoDB1,SizeOf(DB1));
//  DumpData(@DB2,MemoDB2,SizeOf(DB2));
//  DumpData(@DB3,MemoDB3,SizeOf(DB3));
  StopBtn.Enabled:=false;
  FServerStatus:=-1; // to force update on start
  FClientsCount:=-1;
  // Server creation
//  Server:=TS7Server.Create;
  // Add some shared resources
(*  Server.RegisterArea(srvAreaDB,      // it's DB
                      1,              // Number 1 (DB1)
                      @DB1,           // Its address
                      SizeOf(DB1));   // Its size
  Server.RegisterArea(srvAreaDB,2,@DB2,SizeOf(DB2)); // same as above
  Server.RegisterArea(srvAreaDB,3,@DB3,SizeOf(DB3)); // same as above
  *)
  for xparamdb in gDizioDataDb.values do
  begin
    if xparamdb.numdb>-1 then
    begin
      Server.RegisterArea(srvAreaDB,      // it's DB
                      xparamdb.numdb,              // Number 1 (DB1)
                      @GDataDb[xparamdb.indexGDataDb].buff[0],           // Its address
                      xparamdb.lendb);   // Its size
    end;
  end;

  Server.RegisterArea(srvAreaTM,0,@TIM,SizeOf(TIM));
  // Setup the callback
  Server.SetEventsCallback(@ServerCallback, self);

  // Note
  //   Set the callback and set Events/Log mask are optional,
  //   we call them only if we need.
  //   Also Register area is optional, but a server without shared areas is
  //   not very useful :-) however it works and it's recognized by simatic manager.
  LogMask:=Server.LogMask; // Get the current mask, always $FFFFFFFF on startup
  ThreadDisplayData:=TThreadDisplayData.Create(false);
end;




function TFrmServer.convert_file_db_to_xml(var filename:string):boolean;
var x:TDm_import_data_engine;
    PLC_properties:tPLC_properties;
    Result_convert:tImportaFile_back;

    Ts:TStringList;
begin

   result:=false;

    PLC_properties.SERVERNAME:=stringreplace(extractfilename(filename),'.','_',[rfReplaceAll]);
    PLC_properties.PLCNAME:='PLC_'+PLC_properties.SERVERNAME;
    PLC_properties.DESC:= 'converted from'+PLC_properties.SERVERNAME;
    PLC_properties.IP:=   '127.0.0.1';
    PLC_properties.RACK:=  '0';
    PLC_properties.Slot:=  '0';


    x:=TDm_import_data_engine.Create(self);
    try
       try
          Result_convert:=x.importafile(Trim(filename),PLC_properties,nil,nil,nil,nil);

       except
          raise;
       end
    finally
      x.Free;
    end;
    if Result_convert.warning<>'' then
    begin
      case MessageDlg('Error/warnig convert file db '+Result_convert.warning+' continue ?', mtConfirmation, [mbOK, mbCancel], 0) of
         mrCancel:
         begin

            exit;
         end;
      end;
    end;
    gfilexml:=ChangeFileExt(filename,'.xml');
    if FileExists(gfilexml) then
    begin
        if not (MessageDlg('File '+gfilexml+' already exists. Overwrite?',mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes) then
        begin

           Exit;
        end;
    end;
    try
       Ts:= TStringList.Create;
       Ts.Text:= Result_convert.xml;
       Ts.SaveToFile(gfilexml);
       result:=true;
    finally
       FreeAndNil(Ts);
    end;



end;










procedure TFrmServer.LogTimerTimer(Sender: TObject);
Var
  Event : TSrvEvent;
  s:string;
  var xparamdb:tparamdb;
begin
  // Update Log memo
  if Server.PickEvent(Event) then
  begin
    if Log.Lines.Count>1024 then  // In case you want to run this demo for several hours....
      Log.Lines.Clear;
    s:='';
    if GDizioDataDb.TryGetValue(event.EvtParam2,xparamdb) then
    begin
      s:=xparamdb.NameDataSource+' ';
    end;
    s:=s+SrvEventText(Event);
    Log.Lines.Append(s);
  end;
  // Update other Infos
  ServerStatus:=Server.ServerStatus;
  ClientsCount:=Server.ClientsCount;
end;
procedure TFrmServer.FormDestroy(Sender: TObject);
var xparamdb:tparamDb;
    comokeys:array of integer;
    key:integer;
    fine:boolean;
    k:integer;
begin
//  EvtTimer.Enabled:=False;
  sleep(1000);
  if Server<>nil then
     Server.Free;
  if ThreadDisplayData<>nil  then
  begin

     ThreadDisplayData.Terminate;
     while ThreadDisplayData.myterminated<>true do
     begin
       sleep(600);
     end;
     ThreadDisplayData.Free;
  end;

  setlength(comokeys ,GDizioDataDb.keys.Count);
  k:=0;
  if GDizioDataDb<>nil  then
  begin
     for key in  GDizioDataDb.Keys  do
     begin
        comokeys[k]:=key;
        inc(k);
     end;

     for k:=low(comokeys)  to High(comokeys) do
     begin
       if GDizioDataDb.TryGetValue(comokeys[k],xparamdb) then
       begin
         if xparamdb.Dm_BSX_ENGINE <>nil then
       //   (xparamdb.Dm_BSX_ENGINE as tDm_BSX_ENGINE ).Free;
               xparamdb.Dm_BSX_ENGINE:=nil;

          xparamdb.PlcSourceInfoxml.dataPlcXMLDocument.Free;
          xparamdb.PlcSourceInfoxml.dataPlcXMLDocument:=nil;
          GDizioDataDb.AddOrSetValue(xparamdb.numdb,xparamdb);
          GDizioDataDb.Remove(xparamdb.numdb);
       end;
     end;
     for k:=0 to GDataDbcount-1 do
     begin
        GDataDb[k].changed.Free;
        GDataDb[k].rifServer:=nil;
        setlength(GDataDb[k].buff,0);
     end;
   end;
   freeandnil(GDm_BSX_ENGINE);

end;
procedure TFrmServer.UpdateMask;
Var
  c: Integer;
  BitMask : longword;
begin
  BitMask:=$00000001;
  for c := 0 to 31 do
  begin
    if List.Checked[c] then
      FMask:=FMask or BitMask
    else
      FMask:=FMask and not BitMask;
    BitMask:=BitMask shl 1;
  end;
  Server.LogMask:=FMask;
end;

procedure TFrmServer.B_check_allClick(Sender: TObject);
var
  I: Integer;
begin
  for I :=0 to list.Items.Count-1 do
     list.Checked[i]:=true;
  UpdateMask;
  MaskToLabel;
end;

procedure TFrmServer.B_uncheck_allClick(Sender: TObject);
var
  I: Integer;
begin
  for I :=0 to list.Items.Count-1 do
     list.Checked[i]:=False;
  UpdateMask;
  MaskToLabel;
end;


procedure TFrmServer.ListClick(Sender: TObject);
begin
  UpdateMask;
  MaskToLabel;
end;
procedure TFrmServer.Button1Click(Sender: TObject);
var k:integer;
    comoArea:packed array[0..$FFFF] of byte;
    xparamdb:TparamDb;
begin

//      DumpData(@DB1,MemoDB1, SizeOf(DB1));
//      DumpData(@DB2,MemoDB2, SizeOf(DB2));
//      DumpData(@DB3,MemoDB3, SizeOf(DB3));
(*  for xparamdb in gDizioDataDb.values do
  begin
    if xparamdb.numdb>-1 then
    begin
       move(GDataDb[xparamdb.indexGDataDb].buff[0],comoArea[0],xparamdb.lendb);
       DumpData(@comoArea[0],xparamdb.Memo,xparamdb.lendb);
          if xparamDb.Dm_BSX_ENGINE<>nil then
          begin
           GDataDb[xparamDb.indexGDataDb].lastValue:=
              (xparamDb.Dm_BSX_ENGINE as tDm_BSX_ENGINE).dm_GetPlcSourceValue('prova',
                          xparamDb.NamePlc,
                          xparamDb.NameDataSource);
          end;
    end;
  end;
  *)
end;
procedure TFrmServer.MaskToForm;
Var
  c: Integer;
  BitMask : longword;
begin
  BitMask:=$00000001;
  for c := 0 to 31 do
  begin
    List.Checked[c]:=(FMask and BitMask)<>0;
    BitMask:=BitMask shl 1;
  end;
end;
procedure TFrmServer.MaskToLabel;
begin
  lblMask.Caption:='$'+IntToHex(FMask,8);
end;
procedure TFrmServer.SetFClientsCount(const Value: integer);
begin
  if FClientsCount <> Value then
  begin
    FClientsCount := Value;
    SB.Panels[1].Text:='Clients : '+IntToStr(FClientsCount);
  end;
end;
procedure TFrmServer.SetFMask(const Value: longword);
begin
  if FMask <> Value then
  begin
    FMask := Value;
    MaskToForm;
    MaskToLabel;
  end;
end;
procedure TFrmServer.SetFServerStatus(const Value: integer);
begin
  if FServerStatus <> Value then
  begin
    FServerStatus := Value;
    case FServerStatus of
      SrvStopped : SB.Panels[0].Text:='Stopped';
      SrvRunning : SB.Panels[0].Text:='Running';
      SrvError   : SB.Panels[0].Text:='Error';
    end;
  end;
end;
procedure TFrmServer.StartBtnClick(Sender: TObject);
Var
  res : integer;
begin
  Server.SetRWAreaCallback(@readcallback, Server);
  LogTimer.Enabled:=True;
  res :=Server.StartTo(EdIP.Text);
  if res=0 then
  begin
    StartBtn.Enabled:=false;
    EdIP.Enabled:=false;
    StopBtn.Enabled:=true;
  end
  else
  begin
    SB.Panels[2].Text:=
    SrvErrorText(res) +  ' try to use < use sudo setcap ''cap_net_bind_service=+ep'' ./serverdemo >';
    log.lines.add( ' try to use < use sudo setcap ''cap_net_bind_service=+ep'' ./serverdemo >');
  end;

  // EvtTimer.Enabled:=true;
end;
procedure TFrmServer.StopBtnClick(Sender: TObject);
begin
  try
    sema_InReadcallback.Lock;
    Server.SetRWAreaCallback(nil, Server);
    Server.Stop;
  finally
    sema_InReadcallback.unLock;
  end;
  StopBtn.Enabled:=false;
  StartBtn.Enabled:=true;
  EdIP.Enabled:=true;
 // EvtTimer.Enabled:=false;
end;



procedure TFrmServer.Timer1Timer(Sender: TObject);
begin
  if CheckBox1.Checked then
  begin

   if StartBtn.Enabled then
      StartBtn.Click
   else
      StopBtn.Click;

  end;



end;

procedure TFrmServer.TreeView1Click(Sender: TObject);
var index:integer;
    xparamDb:tparamdb;
    xtv:tTreeView;
    node:TTreeNode;
    pdata: PItemRecord;
    path:String;
    value:variant;
    s:string;
    row:integer;
begin
exit;
   if sender is tTreeView then
   begin
      xtv:= (sender as tTreeView);
      index:=xtv.tag;
      if GDizioDataDb.TryGetValue(index,xparamDb) then
      begin
         xparamDb.buttonAdd.Click;
      end;
   end;
   exit;
(*   if sender is tTreeView then
   begin
      xtv:= (sender as tTreeView);
      index:=xtv.tag;
      if GDizioDataDb.TryGetValue(index,xparamDb) then
      begin
         node:=xtv.Selected;
         if node<>nil then
         begin
            if node.Data<>nil then
            begin
               pdata:=node.Data;
               path:=pdata^.path;
//               Label3.Caption:=path;
               if xparamDb.Dm_BSX_ENGINE<>nil then
               begin
                  log.Lines.add('');
                  log.Lines.add(GDataDb[xparamDb.indexGDataDb].LastValue.value);
               end;
               if (pdata^.flagArrayPri=false) and (pdata^.tipo<>'RECORD') then
               begin
                  value:=mygetValueByPath(path,GDataDb[xparamDb.indexGDataDb].LastValue.value,
                  xparamDb.PlcSourceInfoxml.StartNode);
                  s:=value;
                  Label3.Caption:=Label3.Caption+' <'+s+'>';
                  row:=XparamDb.StringGrid.RowCount;
                  XparamDb.StringGrid.RowCount:=row+1;
                  XparamDb.StringGrid.Cells[0, row] := path;
                  XparamDb.StringGrid.Cells[1, row] := pdata^.tipo;
                  XparamDb.StringGrid.Cells[2, row] := s;
               end
               else
               begin
                  Label3.Caption:=Label3.Caption+' no value for record or array data';
               end;

            end;
         end;

      end;
   end;
  *)
end;
procedure TFrmServer.TreeView1DblClick(Sender: TObject);
var bt:tbutton;
    index:integer;
    xparamDb:tparamDb;
begin
   index:=(sender as tTreeView).tag;
   if GDizioDataDb.TryGetValue(index,xparamDb) then
   begin
       xparamDb.buttonAdd.Click;
   end;
end;

procedure TFrmServer.loadTvDataSource(xml:string;TV:TTreeView;XMLDocument:TXMLDocument);
var //r:TXmlVarNameInfo;
    i:integer;
    StartItemNode : IXMLNode;
    XxmlNode : IXMLNode;
    Xtvnode:ttreenode;
    s:string;
    procedure AddNodo(xmlNode:IXMLNode; tvnode:ttreenode);
    var xmlchild:IXMLNode;
        tvChild:ttreenode;
        tvChildArrayPri:ttreenode;
        s:string;
        NAME_ON_PLC:string;
        TYPE_ON_PLC:string;
        path:string;
        pdata: PItemRecord;
        z:integer;
        s1:string;
        arrayMinMax:TarrayMinMax;
    begin
        if xmlNode=nil then
           exit;
         path:='';
         if tvnode<>nil then
         begin
            pdata:=tvnode.Data;
            path:=pdata^.path;
         end;
        xmlchild:=xmlNode.ChildNodes.First;
        while xmlchild<>nil do
        begin
           TYPE_ON_PLC:='';
           s:= xmlchild.NodeName;
           arrayMinMax.numEle:=0;arrayMinMax.min:=0;arrayMinMax.max:=0;
           if xmlchild.HasAttribute('NAME_ON_PLC') then
           begin
              NAME_ON_PLC:=xmlchild.Attributes['NAME_ON_PLC'];
           end;
           if xmlchild.HasAttribute('TYPE_ON_PLC') then
              TYPE_ON_PLC:=xmlchild.Attributes['TYPE_ON_PLC'];
           if xmlchild.HasAttribute('ARRAY') then
           begin
             // S:=s+xmlchild.Attributes['ARRAY'];
              arrayMinMax:=decodeArrayAttributeMINMAX(xmlchild.Attributes['ARRAY']);
           end;
           if arrayMinMax.numEle>0 then
           begin
             tvChildArrayPri:=TV.Items.AddChild(tvnode,s+' Array['+arrayMinMax.min.ToString+'..'+arrayMinMax.max.ToString+'] of '+TYPE_ON_PLC);
             New(pdata);
             if path='' then   pdata^.path :=xmlchild.NodeName else  pdata^.path :=path+'.'+xmlchild.NodeName;
             pdata^.arrayMinMax:=arrayMinMax;
             pdata^.flagArrayPri:=True;
             pdata^.tipo:=TYPE_ON_PLC;
             tvChildArrayPri.Data := pdata;
             tvChildArrayPri.ImageIndex:=1;
             tvChildArrayPri.SelectedIndex:=1;

             for z := arrayMinMax.min to arrayMinMax.max do
             begin
                 s1:=s+'['+z.ToString+']    '+TYPE_ON_PLC;
                 tvChild:=TV.Items.AddChild(tvChildArrayPri,s1);
                 New(pdata);
                 if path='' then   pdata^.path :=xmlchild.NodeName else  pdata^.path :=path+'.'+xmlchild.NodeName;
                 pdata^.path :=pdata^.path+'['+z.ToString+']';
                 pdata^.arrayMinMax:=arrayMinMax;
                 pdata^.flagArrayPri:=False;
                 pdata^.tipo:=TYPE_ON_PLC;
                 tvChild.Data := pdata;
                 if xmlchild.HasChildNodes then
                 begin
                    tvChild.ImageIndex:=1;
                    tvChild.SelectedIndex:=1;
                 end
                 else
                 begin
                    tvChild.ImageIndex:=2;
                    tvChild.SelectedIndex:=2;
                 end;
                 AddNodo(xmlchild,tvChild);
             end;
           end
           else
           begin
              S:=s+' '+TYPE_ON_PLC;
              tvChild:=TV.Items.AddChild(tvnode,s);
              New(pdata);
              if path='' then   pdata^.path :=xmlchild.NodeName else  pdata^.path :=path+'.'+xmlchild.NodeName;
              pdata^.arrayMinMax:=arrayMinMax;
              pdata^.flagArrayPri:=False;
              pdata^.tipo:=TYPE_ON_PLC;
              tvChild.Data := pdata;
              if xmlchild.HasChildNodes then
              begin
                 tvChild.ImageIndex:=1;
                 tvChild.SelectedIndex:=1;
              end
              else
              begin
                 tvChild.ImageIndex:=2;
                 tvChild.SelectedIndex:=2;
              end;
              AddNodo(xmlchild,tvChild);
           end;
           xmlchild:=xmlchild.NextSibling;
        end;
    end;
begin
  try  tv.Items.Clear;except;end;
  try
   try
      s:=xml;
   except
     s:='';
   end;
   if s='' then
     exit;
   XMLDocument.LoadFromXML(s);
   XMLDocument.Active:=true;
   StartItemNode:=XMLDocument.ChildNodes.First;
   addnodo(StartItemNode,nil);
   for i:=0 to tv.Items.Count-1 do
      tv.items[i].Expand(true);
   if tv.Items.Count>0 then
       tv.Selected:=tv.items[0];
  except
    on e:exception do
    begin
     //  Memo1.Lines.Clear;
     //  Memo1.Lines.Add('XMLDocument.LoadFromXML(<'+s+'> err='+e.Message);
    end;
  end;
end;
procedure TFrmServer.treeDeletion(Sender: TObject; Node: TTreeNode);
begin
   if node.Data<>nil then
      Dispose(PItemRecord(Node.Data));
end;
//// queste copiate da BSX_core
//// queste copiate da BSX_core
//// queste copiate da BSX_core
//// queste copiate da BSX_core
//// queste copiate da BSX_core
//// queste copiate da BSX_core
function TFrmServer.mygetValueByPath(path:string;v:variant;const node:ixmlnode):variant;
var pf, p:integer;
    elem:integer;
    elems:string;
    newpath:string;
    r:variant;
    s:string;
    k:integer;
    childNode:ixmlnode;
  //  xpath:string;
    xarray:string;
    minmax:TarrayMinMax;
begin
   if v=null then
   begin
      result:=null;
      exit;
   end;
   s:='';
    if node<>nil then
      s:=node.NodeName;

    elem:=-1;
    p:=POS('[',PATH);
    if p>0 then
    begin
      pf:=POS(']',PATH);
      elems:=copy(PATH,p+1,(pf-p)-1);
      elem:=strtoint(elems);
      newpath:=copy(path,pf+1);
      if copy(newpath,1,1)='.' then
         newpath:=copy(newpath,2);
      path:=copy(path,1,P-1);
    end;
    childNode:= findnodeBypath(path, node);
    if node=nil then
    begin
        raise Exception.Create(' Wrong path');
    end;



    if elem=-1 then
    begin
       TDocVariantData(v).GetValueByPath(path, r);
       result:=r;
       exit;
    end
    else
    begin
      xarray:='';
      if childNode.HasAttribute('ARRAY') then
      begin
         xarray:= childNode.Attributes['ARRAY'];
      end;
      if xarray='' then
      begin
         raise Exception.Create('path<'+path+'> is not an array!');
      end;
      try
         minmax:=decodeArrayAttributeMINMAX(xarray)
      except
         on e:exception do begin  raise Exception.Create('path<'+path+'> Error '+e.message);end;
      end;
      if (elem<minmax.min) or (elem>minmax.max)  then
          Exception.Create('path<'+path+'> index<'+elem.ToString+' out of bounds['+xarray+']');

       TDocVariantData(v).GetValueByPath(path, r);
       elem:= ELEM-minmax.min;
       V:=TDocVariantData(R).VALUES[ELEM];
       if newpath>'' then
           result:=mygetValueByPath(newpath,v,childNode )
       else
         result:=v;
    end;
end;
procedure TFrmServer.onGrid_dblClick(Sender: TObject);
var numdb:integer;
begin
   numdb:=(sender as TStringGrid).tag;
   setvalueOfGrid(numdb);


end;

procedure TFrmServer.PCResize(Sender: TObject);
var k:integer;
   xparamDb:tparamDb;
begin
exit;
   for xparamDb  in  GDizioDataDb.Values do
   begin
      if xparamDb.StringGrid<>nil then
      begin
         try
           xparamDb.StringGrid.ColWidths[2]:=xparamDb.StringGrid.ClientWidth-xparamDb.StringGrid.ColWidths[0]-xparamDb.StringGrid.ColWidths[1];
         except

         end;
      end;
   end;



end;

function  TFrmServer.findnodeBypath(const path:string;const StartNode:ixmlnode):ixmlnode;
var p,k:integer;
    childnode:ixmlnode;
    nodename:string;
    radixPath:string;
    newpath:string;
begin
   result:=nil;
   if StartNode=nil then
   begin
     exit;
   end;
   p:=pos('.',path);
   if p=0 then
   begin
      radixPath:=path;
      newpath:='';
   end
   else
   begin
      radixPath:=copy(path,1,p-1);
      newpath:= System.SysUtils.trim(copy(path,p+1));
   end;
   radixPath:=uppercase(radixPath);
   for k := 0 to StartNode.ChildNodes.Count-1 do
   begin
      childnode:=StartNode.ChildNodes[k];
      nodename:=uppercase(childnode.NodeName);
      if radixPath=nodename then
      begin
         if newpath='' then
         begin
            result:=childnode;
            break;
         end
         else
         begin
            result:=findnodeBypath(newpath,childnode);
            break;
         end;
      end
   end;
end;


procedure TFrmServer.ButtonAddClick(Sender: TObject);
var
  numdb: Integer;
  xparamDb:tparamDb;
  node:ttreenode;
  path:string;
  tipo:string;
begin
   numdb:=(sender as tbutton).tag ;
   if GDizioDataDb.TryGetValue(numDb,Xparamdb) then
   begin

//      TreeView1Click(Xparamdb.TV);
      node:=Xparamdb.TV.Selected;
      tipo:=GetTipoNode(node);
      path:=GetpathNode(node);
      if path<>'' then
      begin
         AddVariableToGrid(Xparamdb.StringGrid,path,tipo);
         GDataDb[Xparamdb.indexGDataDb].changed.SetEvent;
      end;

   end;

end;
procedure TFrmServer.ButtonDelClick(Sender: TObject);
var
  numdb: Integer;
  xparamDb:tparamDb;
  row:integer;
  i:integer;
begin
   numdb:=(sender as tbutton).tag ;
   if GDizioDataDb.TryGetValue(numDb,Xparamdb) then
   begin
      if Xparamdb.StringGrid.Rowcount=2 then
      begin
         Xparamdb.StringGrid.Cells[0,1]:='';
         Xparamdb.StringGrid.Cells[1,1]:='';
         Xparamdb.StringGrid.Cells[2,1]:='';
         exit
      end;


      row :=Xparamdb.StringGrid.Row;
      if row>0 then
      begin
           for i := Row to Xparamdb.StringGrid.RowCount - 2 do
              Xparamdb.StringGrid.Rows[i].Assign(Xparamdb.StringGrid.Rows[i + 1]);
           Xparamdb.StringGrid.RowCount := Xparamdb.StringGrid.RowCount - 1;

      end;

//      TreeView1Click(Xparamdb.TV);
(*      node:=Xparamdb.TV.Selected;
      tipo:=GetTipoNode(node);
      path:=GetpathNode(node);
      if path<>'' then
      begin
         AddVariableToGrid(Xparamdb.StringGrid,path,tipo);
         GDataDb[Xparamdb.indexGDataDb].changed.SetEvent;
      end;
  *)
   end;

end;


procedure TFrmServer.buttonSetvalueClick(Sender: TObject);
var
  numdb: Integer;
begin
   numdb:=(sender as tbutton).tag ;
   setvalueOfGrid(numdb);
end ;

procedure TFrmServer.setvalueOfGrid(numdb:integer);
var
  xparamDb:tparamDb;
  row:integer;
  i:integer;
  x:Tfchange_value;

begin
   if GDizioDataDb.TryGetValue(numDb,Xparamdb) then
   begin
      row :=Xparamdb.StringGrid.Row;
      if trim(Xparamdb.StringGrid.Cells[0,row])='' then
         exit;
      if row>0 then
      begin
           x:=Tfchange_value.create(self);
           x.E_name_variab.text:=Xparamdb.StringGrid.Cells[0,row];
           x.E_valueVariab.text:=Xparamdb.StringGrid.Cells[2,row];
           x.xparamdb:=Xparamdb;

           x.ShowModal;

           x.Free;

      end;
   end;

end;


function TFrmServer.CreatePlcSourceInfoxml(const xPlcSourceName:string;const xml:string):TPlcSourceInfoxml;
begin
   if xml='' then
   begin
      result.xmlCreated:=False;
      result.dataPlcXMLDocument:=nil;
      result.StartNode:=nil;
      exit;
   end;

//   CoInitialize(nil);
   try
      result.PlcSourceName:=xPlcSourceName;
      result.dataPlcXMLDocument:=TXMLDocument.Create(self);
      result.dataPlcXMLDocument.LoadFromXML(xml);
      result.dataPlcXMLDocument.Active:=true;
      result.StartNode:=result.dataPlcXMLDocument.Node.ChildNodes.First;
      result.xmlCreated:=True;
   except
      result.xmlCreated:=False;
      result.StartNode:=nil;
   end;
end;

//// queste copiate da BSX_core fineeeeeee
///
///


function TFrmServer.GetPathNode(node:TTreeNode):string;
var     pdata: PItemRecord;
begin
         if node<>nil then
         begin
            if node.Data<>nil then
            begin
               pdata:=node.Data;
               result:=pdata^.path;
            end;
         end;
end;
function TFrmServer.GetTipoNode(node:TTreeNode):string;
var     pdata: PItemRecord;
begin
         if node<>nil then
         begin
            if node.Data<>nil then
            begin
               pdata:=node.Data;
               result:=pdata^.tipo;
            end;
         end;
end;

procedure TFrmServer.AddVariableToGrid(x:tstringGrid;path:sTring;tipo:string);
var row:integer;
begin
                  row:=x.RowCount;
                  if row=2 then
                  begin
                    if trim(x.Cells[0, 1])='' then
                       row:=1
                    else
                    begin
                      x.RowCount:=row+1;
                    end
                  end
                  else
                    x.RowCount:=row+1;

                  x.Cells[0, row] := path;
                  x.Cells[1, row] := tipo;
//                  x.Cells[2, row] := s;


end;

procedure TFrmServer.updateDisplayDataDb;
var k:integer;
    comoArea:packed array[0..$FFFF] of byte;
    xparamdb:TparamDb;
    local_DB_da_aggiornare:array of integer;
    j:integer;
    path:string;
    value:variant;
    s:string;
    maxage_dummy:integer;
begin

      try
          sema_listaDbDaAggiornare.Lock;
          setlength(local_DB_da_aggiornare,listaDbDaAggiornare.count);
          for k:=0 to listaDbDaAggiornare.count-1 do
          begin
            local_DB_da_aggiornare[k]:=GDataDb[listaDbDaAggiornare.Items[k]].numDb;
          end;
          listaDbDaAggiornare.Clear;
      finally

          sema_listaDbDaAggiornare.UnLock;
      end;


//      DumpData(@DB1,MemoDB1, SizeOf(DB1));
//      DumpData(@DB2,MemoDB2, SizeOf(DB2));
//      DumpData(@DB3,MemoDB3, SizeOf(DB3));
  for k:=low(local_DB_da_aggiornare) to high(local_DB_da_aggiornare) do
  begin
    if GDizioDataDb.TryGetValue(local_DB_da_aggiornare[k],xparamdb) then
    begin
       if xparamdb.numdb>-1 then
       begin
          try
            Server.LockArea(srvAreaDB,
                                xparamdb.numdb);
            move(GDataDb[xparamdb.indexGDataDb].buff[0],comoArea[0],xparamdb.lendb);
          finally
            Server.unLockArea(srvAreaDB,
                                xparamdb.numdb);
          end;
          DumpData(@comoArea[0],xparamdb.Memo,xparamdb.lendb);
          if xparamDb.Dm_BSX_ENGINE<>nil then
          begin
            GDataDb[xparamDb.indexGDataDb].lastValue:=
              (xparamDb.Dm_BSX_ENGINE as tDm_BSX_ENGINE).dm_GetPlcSourceValue('prova',
                          xparamDb.NamePlc,
                          xparamDb.NameDataSource,maxage_dummy);
            for j := 1 to xparamDb.StringGrid.RowCount-1 do
            begin
                  path:= xparamDb.StringGrid.Cells[0,j];
                  value:=mygetValueByPath(path,GDataDb[xparamDb.indexGDataDb].LastValue.value,
                  xparamDb.PlcSourceInfoxml.StartNode);
                  s:=value;
             //     Label3.Caption:=Label3.Caption+' <'+s+'>';
                  XparamDb.StringGrid.Cells[2, j]:= s;
            end;

          end;
       end;
    end;
  end;
end;


{ TThreadDisplayData }

procedure TThreadDisplayData.Execute;
var  hArr  : Array[0..63]  of THandle;
    i:integer;
    rWait : Cardinal;
begin
  inherited;

  for I := 0 to  GDataDbcount-1 do
     hArr[i]:=GDataDb[i].changed.Handle;

  while not terminated do
  begin
    rWait:=WaitForMultipleObjects(GDataDbcount,@hArr,false,1000);
    if Terminated then
       break;
    if rwait<GDataDbcount then
    begin
       try
          sema_listaDbDaAggiornare.Lock;
          listaDbDaAggiornare.add(rwait);
       finally
          sema_listaDbDaAggiornare.UnLock;
       end;

            tthread.Synchronize(nil,
            procedure
            begin
             FrmServer.updateDisplayDataDb;
            end
             );
    end;


  end;

  myterminated:=true;


end;


initialization
   read_Param_Dm_start_module; // lo faccio in ogni modulo perche non so quale initialize viene chiamata per prima
   sema_InReadcallback.Init;

finalization
   sema_InReadcallback.Done;
end.
