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

unit U_request_file_xml_db;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls;

type
  TF_ask_name_file_db_xml = class(TForm)
    Label8: TLabel;
    Edit_DB: TEdit;
    B_Search_DB: TButton;
    FileOpenDialog_DB: TFileOpenDialog;
    B_cancel: TBitBtn;
    B_ok: TBitBtn;
    procedure B_cancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure B_okClick(Sender: TObject);
    procedure B_Search_DBClick(Sender: TObject);
  private
    { Private declarations }
  public
    return_OK:boolean;
    { Public declarations }
  end;

var
  F_ask_name_file_db_xml: TF_ask_name_file_db_xml;

implementation

{$R *.dfm}

procedure TF_ask_name_file_db_xml.B_cancelClick(Sender: TObject);
begin
  return_OK:=False;
  close;
end;

procedure TF_ask_name_file_db_xml.B_okClick(Sender: TObject);
begin
  return_OK:=true;
end;

procedure TF_ask_name_file_db_xml.B_Search_DBClick(Sender: TObject);
begin
    if FileOpenDialog_DB.Execute then
  begin
    Edit_DB.Text:= FileOpenDialog_DB.FileName;
  end;
end;

procedure TF_ask_name_file_db_xml.FormCreate(Sender: TObject);
begin
  // showmessage('Create');
end;

procedure TF_ask_name_file_db_xml.FormDestroy(Sender: TObject);
begin
  // showmessage('destroy');
end;

end.
