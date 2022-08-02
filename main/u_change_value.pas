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

unit u_change_value;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,U_BSX_mormot_interface,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,u_def_param_db,u_mormot_datamodule_BSX_ENGINE,
  Vcl.ExtCtrls;

type
  Tfchange_value = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    B_canc: TBitBtn;
    b_ok: TBitBtn;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    E_name_variab: TEdit;
    E_valueVariab: TEdit;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;

    procedure b_okClick(Sender: TObject);
    procedure B_cancClick(Sender: TObject);
  private
    { Private declarations }
  public
    xparamDb:tparamdb;
    { Public declarations }
  end;

var
  fchange_value: Tfchange_value;

implementation

{$R *.dfm}

procedure Tfchange_value.B_cancClick(Sender: TObject);
begin
  close;
end;

procedure Tfchange_value.b_okClick(Sender: TObject);
var
 r:TputPlcSourceValue_back;
 v:variant;
begin
 v:=E_valueVariab.Text;
 r:=(xparamDb.Dm_BSX_ENGINE as tDm_BSX_ENGINE).dm_putPlcSourceValueByPath('xxx',
                          xparamDb.NamePlc,
                          xparamDb.NameDataSource,
                          E_name_variab.Text ,
                          E_valueVariab.Text);
  if r.error.error<>BSXE_ALL_OK then
  begin
    showmessage('Error '+ BSX_ErrorNum_to_string(r.error.error)+' '+r.error.errors)
  end
  else
  begin
    GDataDb[xparamDb.indexGDataDb].changed.SetEvent;
    close;
  end;
end;

end.
