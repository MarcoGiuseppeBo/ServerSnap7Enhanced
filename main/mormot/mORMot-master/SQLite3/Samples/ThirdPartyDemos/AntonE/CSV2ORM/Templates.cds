???             EName I    WIDTH   Files     FileName I    WIDTH  ? Source K    SUBTYPE I  Binary WIDTH    
LINK_FIELD  	    
CHANGE_LOG ? H                                                                                                  	          
             	         
                                                                                                 
CHANGE_LOG ? W                   @         @         @         @         @         @         @         @                  @         @                            @         @                  @         @         @         @         @         @         @         @         @         @         @         @    CDS Form	   DataMyObj.pas   MyObjFormU.pas   MyObjFormU.dfm    DataMyObj.pas   Hello
    MyObjFormU.pas   blou    DataMyObj.pas1  unit DataMyObj;

interface

uses mORMot,SynCommons;

type TSQLMyObj         = class(TSQLRecord)
                         private
                          [Field]fMyField        : MyType;[/Field]
                         public
                          procedure SetDefaults;
                         published
                          [Field]property MyField   : MyType          read fMyField     write fMyField;[/Field]
                        end;

implementation

{ TSQLMyObj }

procedure TSQLMyObj.SetDefaults;
begin

end;

end.
    DataMyObj.pas#  unit DataMyObj;

interface

uses mORMot,SynCommons;

type TSQLMyObj         = class(TSQLRecord)
                         private
                          [Fields]fMyField        : MyType;
                         public
                          procedure SetDefaults;
                         published
                          [Fields]property MyField   : MyType          read fMyField     write fMyField;
                        end;

implementation

{ TSQLMyObj }

procedure TSQLMyObj.SetDefaults;
begin

end;

end.
    DataMyObj.pas  unit DataMyObj;

interface

uses mORMot,SynCommons;

type TSQLMyObj         = class(TSQLRecord)
                         private
                          [Fields]fMyName        : MyType;
                         public
                          procedure SetDefaults;
                         published
                          [Fields]property MyName   : MyType          read fMyName     write fMyName;
                        end;

implementation

{ TSQLMyObj }

procedure TSQLMyObj.SetDefaults;
begin

end;

end.
    DataMyObj.pas1  unit DataMyObj;

interface

uses mORMot,SynCommons;

type TSQLMyObj         = class(TSQLRecord)
                         private
                          [Fields]fMyName        : MyType;[/Fields]
                         public
                          procedure SetDefaults;
                         published
                          [Fields]property MyName   : MyType          read fMyName     write fMyName;[/Fields]
                        end;

implementation

{ TSQLMyObj }

procedure TSQLMyObj.SetDefaults;
begin

end;

end.
   Data unit only Data+CDS based form   MyObjFormU.pas	   MyObjFormU.dfm
    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;
                    [Controls]LabelMyName : TLabel;
                    [Controls]MyControlNAme : MyControl;
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
2          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
    MyObjFormU.dfm?  object MyObjForm: TMyObjForm
  Left = 0
  Top = 0
  Caption = 'MyObj'
  ClientHeight = 420
  ClientWidth = 838
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    838
    420)
  PixelsPerInch = 96
  TextHeight = 13
[Controls] object LabelMyName: TLabel
    Left = 56
    Top = MyTop
    Width = 23
    Height = 13
    Alignment = taRightJustify
    Caption = 'MyName'
  end
  object MyControlName: MyControl
    Left = 84
    Top = MyTop
    Width = 121
    Height = 21
    DataField = 'MyName'
    DataSource = DS
  end[/Controls]

  object BtnSave: TBitBtn
    Left = 742
    Top = 8
    Width = 41
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save'
    TabOrder = 0
    OnClick = BtnSaveClick
  end
  object BtnCancel: TBitBtn
    Left = 789
    Top = 8
    Width = 41
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object CDS: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    Left = 368
    Top = 24
    [Fields]object CDSMyName: MyField
      FieldName = 'MyField'
      [Size]Size = MySize
    end[/Fields]
  end
  object DS: TDataSource
    DataSet = CDS
    Left = 368
    Top = 80
  end
  object BalloonHint1: TBalloonHint
    Left = 368
    Top = 144
  end
end    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;[/Fields]
                    [Controls]LabelMyName : TLabel;
                    MyControlNAme : MyControl;[/Controls]
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
2          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;[/Fields]
                    [Controls]LabelMyName : TLabel;
                    MyControlName : MyControl;[/Controls]
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
2          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;[/Fields]
                    [Controls]LabelMyName : TLabel;
                    MyControlName : MyControl;[/Controls]
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;[/Fields]
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
2          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;[/Fields]
                    [Controls]LabelMyName : TLabel;
                    MyControlName : MyControl;[/Controls]
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;[/Fields]
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);[/Fields]
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
    MyObjFormU.dfm?  object MyObjForm: TMyObjForm
  Left = 0
  Top = 0
  Caption = 'MyObj'
  ClientHeight = 420
  ClientWidth = 838
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    838
    420)
  PixelsPerInch = 96
  TextHeight = 13
[Controls] object LabelMyName: TLabel
    Left = 56
    Top = MyTop
    Width = 23
    Height = 13
    Alignment = taRightJustify
    Caption = 'MyName'
  end
  object MyControlName: MyControl
    Left = 84
    Top = MyTop
    Width = 121
    Height = 21
    DataField = 'MyName'
    DataSource = DS
  end[/Controls]

  object BtnSave: TBitBtn
    Left = 742
    Top = 8
    Width = 41
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save'
    TabOrder = 0
    OnClick = BtnSaveClick
  end
  object BtnCancel: TBitBtn
    Left = 789
    Top = 8
    Width = 41
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object CDS: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    Left = 368
    Top = 24
    [Fields]object CDSMyName: MyField
      FieldName = 'MyName'
      [Size]Size = MySize
    end[/Fields]
  end
  object DS: TDataSource
    DataSet = CDS
    Left = 368
    Top = 80
  end
  object BalloonHint1: TBalloonHint
    Left = 368
    Top = 144
  end
end    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;[/Fields]
                    [Controls]LabelMyName : TLabel;
                    MyControlName : MyControl;[/Controls]
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;[!Size]
CDSMyName   .MyFieldAs      :=StringToRawUTF8(AObj.MyName);[Size]
[/Fields]
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);[/Fields]
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;[/Fields]
                    [Controls]LabelMyName : TLabel;
                    MyControlName : MyDBControl;[/Controls]
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;[!Size]
CDSMyName   .MyFieldAs      :=StringToRawUTF8(AObj.MyName);[Size]
[/Fields]
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);[/Fields]
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
    MyObjFormU.dfm?  object MyObjForm: TMyObjForm
  Left = 0
  Top = 0
  Caption = 'MyObj'
  ClientHeight = 420
  ClientWidth = 838
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    838
    420)
  PixelsPerInch = 96
  TextHeight = 13
[Controls] object LabelMyName: TLabel
    Left = 56
    Top = MyTop
    Width = 23
    Height = 13
    Alignment = taRightJustify
    Caption = 'MyName'
  end
  object MyControlName: MyDBControl
    Left = 84
    Top = MyTop
    Width = 121
    Height = 21
    DataField = 'MyName'
    DataSource = DS
  end[/Controls]

  object BtnSave: TBitBtn
    Left = 742
    Top = 8
    Width = 41
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save'
    TabOrder = 0
    OnClick = BtnSaveClick
  end
  object BtnCancel: TBitBtn
    Left = 789
    Top = 8
    Width = 41
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object CDS: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    Left = 368
    Top = 24
    [Fields]object CDSMyName: MyField
      FieldName = 'MyName'
      [Size]Size = MySize
    end[/Fields]
  end
  object DS: TDataSource
    DataSet = CDS
    Left = 368
    Top = 80
  end
  object BalloonHint1: TBalloonHint
    Left = 368
    Top = 144
  end
end    MyObjFormU.pas?
  unit TmpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, JvExMask, JvToolEdit,
  JvDBControls,DataMyObj;

type
  TMyObjForm = class(TForm)
                    CDS:TClientDataset;
                    DS :TDatasource;
                    BalloonHint1: TBalloonHint;
                    [Fields]CDSMyName : MyField;[/Fields]
                    [Controls]LabelMyName : TLabel;
                    MyControlName : MyDBControl;[/Controls]
                    BtnSave  : TBitBtn;
                    BtnCancel: TBitBtn;
                    procedure BtnCancelClick(Sender: TObject);
                    procedure BtnSaveClick(Sender: TObject);
                  private
                    { Private declarations }
                  public
                    { Public declarations }
                   ID : Integer;
                   procedure LoadFromMyObj(AID :Integer);overload;
                   procedure LoadFromMyObj(AObj:TSQLMyObj);overload;
                   function Save:Boolean;
                  end;

implementation

{$R *.dfm}

uses ClientEngineU,SynCommons;

procedure TMyObjForm.BtnCancelClick(Sender: TObject);
begin
 CDS.CancelUpdates;
 CDS.RevertRecord;
 ModalResult:=mrCancel;
end;

procedure TMyObjForm.BtnSaveClick(Sender: TObject);
begin
 Save;
 ModalResult:=mrOk;
end;

procedure TMyObjForm.LoadFromMyObj(AID: Integer);
var Obj : TSQLMyObj;
begin
 Obj:=TSQLMyObj.Create;
 if AID=0
    then Obj.SetDefaults
    else Engine.DB.Retrieve(AID,Obj,False);
 LoadFromMyObj(Obj);
 Obj.Free;
end;

procedure TMyObjForm.LoadFromMyObj(AObj: TSQLMyObj);
begin
 ID:=AObj.ID;
 CDS.EmptyDataSet;
 CDS.Insert;
 [Fields]CDSMyName   .MyFieldAs      :=AObj.MyName;[/Fields]
 CDS.Post;

 CDS.MergeChangeLog;
 CDS.LogChanges:=True;
end;

function TMyObjForm.Save: Boolean;
var Obj : TSQLMyObj;
begin
 (*Validate*)
 if CDS.State<>dsBrowse
    then CDS.Post;
{ if CDSDesc.AsString=''
    then begin
          EditDesc.SetFocus;
          BalloonHint1.Title      :='Incomplete input';
          BalloonHint1.Description:='Please enter a Desc';
          BalloonHint1.Delay:=1000;
          BalloonHint1.ShowHint;
          exit;
         end;}

 (*Persist*)
 Obj:=TSQLMyObj.Create;
 if ID<>0
    then Engine.DB.Retrieve(ID,Obj,True);
[Fields][Size]Obj.MyName           :=StringToUTF8(CDSMyName             .MyFieldAs);
[!Size]Obj.MyName           :=CDSMyName             .MyFieldAs;[/Fields]
 if ID<>0
    then Engine.DB.Update(Obj)
    else Engine.DB.Add(Obj,True);
 ID:=Obj.ID;
 Obj.Free;
end;

end.
   CDS based formCDS based form (1 record)