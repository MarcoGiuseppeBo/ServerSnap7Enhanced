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


(* Part of this program is based on a example server finded on Snap7 *)

program Pmy_server_snap7_enhanced;
uses
  Vcl.Forms,
  Winapi.ActiveX,
  u_tfrmserver in 'u_tfrmserver.pas' {FrmServer},
  snap7 in '..\My_server_snap_7\snap7.pas',
  U_Snap7_reader_and_writer_block_fake in 'U_Snap7_reader_and_writer_block_fake.pas',
  U_tarrayofbyte in '..\boxscada_driver\U_tarrayofbyte.pas',
  U_BSX_mormot_interface in '..\BSX_compo\U_BSX_mormot_interface.pas',
  U_mormot_datamodule_utils_fake in 'U_mormot_datamodule_utils_fake.pas' {Dm_utils: TDataModule},
  U_mormot_messager_utils in '..\CONFIG_READER_XML\U_mormot_messager_utils.pas',
  u_def_param_db in 'u_def_param_db.pas',
  u_change_value in 'u_change_value.pas' {fchange_value},
  u_mormot_server_read_ini in '..\CONFIG_READER_XML\u_mormot_server_read_ini.pas',
  U_dm_import_data_engine in '..\import_siemems\U_dm_import_data_engine.pas' {Dm_import_data_engine: TDataModule},
  U_request_file_xml_db in 'U_request_file_xml_db.pas' {F_ask_name_file_db_xml},
  u_mormot_datamodule_BSX_ENGINE in '..\CONFIG_READER_XML\u_mormot_datamodule_BSX_ENGINE.pas',
  logthread4 in '..\util\logthread4.pas',
  U_get_version in '..\util\U_get_version.pas',
  mORMotSCADAUtils in '..\util\mORMotSCADAUtils.pas';

{$R *.res}
begin
  CoInitialize(nil);
   ReportMemoryLeaksOnShutdown:=True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmServer, FrmServer);
  application.Run;
end.
