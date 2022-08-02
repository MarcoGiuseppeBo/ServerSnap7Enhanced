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

unit u_mormot_server_read_ini;

interface
uses inifiles,sysutils;

type TParam_BSX_SERVER=record
     FILEINIUSED:string;
     FILEINI_SERACHED1:string;
     FILEINI_SERACHED2:string;
     file_export_address_map_beckhoff:string;
     Verboseindex_Main:integer;
     Verboseindex_dm_bsx_start_module:integer;
     Verboseindex_Log_chiamate:integer;
     Verboseindex_mormot:integer;
     Verboseindex_log_BSX_ENGINE:integer;
     Verboseindex_logSnap7_reader_and_writer_block:integer;
     Verboseindex_logbeckhoff_reader_and_writer_block:integer;
     Verboseindex_BSX_MORMOT_SERVER_INIT:integer;
     Verboseindex_LOG_BSX_beckhoffDataEntry        :integer;
     Verboseindex_LOG_BSX_beckhoffDescritptionData :integer;
     Verboseindex_Dm_BSX_ENGINE_BeckHoff_Definition:integer;
     Verboseindex_Messager:integer;
     Verboseindex_logDm_message_util:integer;
     ReportMemoryLeaksOnShutdown:boolean;

     useHttpApi:boolean;
     debug_check_getValueSource_convert_json:boolean;
     file_xml_def_Plc:string;//     C:\!mysw\MORMOT_SCADA\CONFIG_READER_XML\dati_server_plc_server.xml

     file_test_json:string;
     PLCSharedConnection:boolean;
     PLCCacheEnabled: Boolean;

     Snap7_p_i32_PingTimeout:integer;
     Snap7_p_i32_SendTimeout:integer;
     Snap7_p_i32_RecvTimeout:integer;
     Snap7_p_i32_PDURequest:integer;


     BSX_SESSION_TIMEOUT_SEC:integer;

end;

var flagParam_BSX_SERVER_readed:boolean; /// essendo globale e sempre inizializzata a false;
    Param_BSX_SERVER:TParam_BSX_SERVER;

procedure read_Param_Dm_start_module;

implementation


procedure read_Param_Dm_start_module;
var name_exe_file:string;
    exeFileComo:string;
    name_ini_file:string;
    ini:tinifile;
    como:string;
begin
    if flagParam_BSX_SERVER_readed=False then
    begin

        Param_BSX_SERVER.Verboseindex_dm_bsx_start_module:=0;
        Param_BSX_SERVER.Verboseindex_Log_chiamate:=0;
        Param_BSX_SERVER.Verboseindex_mormot:=0;
        Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE:=0;
        Param_BSX_SERVER.Verboseindex_logSnap7_reader_and_writer_block:=0;

        Param_BSX_SERVER.Verboseindex_LOG_BSX_beckhoffDataEntry          :=0;
        Param_BSX_SERVER.Verboseindex_LOG_BSX_beckhoffDescritptionData   :=0;
        Param_BSX_SERVER.Verboseindex_Dm_BSX_ENGINE_BeckHoff_Definition  :=0;




        Param_BSX_SERVER.Verboseindex_Messager:=0;

        Param_BSX_SERVER.ReportMemoryLeaksOnShutdown:=False;
        Param_BSX_SERVER.useHttpApi:=False;
        Param_BSX_SERVER.debug_check_getValueSource_convert_json:=False;

        Param_BSX_SERVER.PLCSharedConnection:= False;
        Param_BSX_SERVER.PLCCacheEnabled:= False;

        Param_BSX_SERVER.Snap7_p_i32_PingTimeout:=-1;
        Param_BSX_SERVER.Snap7_p_i32_SendTimeout:=-1;
        Param_BSX_SERVER.Snap7_p_i32_RecvTimeout:=-1;
        Param_BSX_SERVER.Snap7_p_i32_PDURequest:=-1;
        Param_BSX_SERVER.BSX_SESSION_TIMEOUT_SEC:=60;


     try
        name_exe_file:=ParamStr(0);

        name_exe_file:=uppercase(name_exe_file);
        name_exe_file:=stringreplace(name_exe_file,'\DEBUG','',[rfReplaceAll, rfIgnoreCase]);
        name_exe_file:=stringreplace(name_exe_file,'\RELEASE','',[rfReplaceAll, rfIgnoreCase]);
        name_exe_file:=stringreplace(name_exe_file,'\WIN32','',[rfReplaceAll, rfIgnoreCase]);
        name_exe_file:=stringreplace(name_exe_file,'\WIN64','',[rfReplaceAll, rfIgnoreCase]);
        name_ini_file:=ChangeFileExt(name_exe_file,'.ini');


        Param_BSX_SERVER.FILEINI_SERACHED1:=name_ini_file;
        Param_BSX_SERVER.FILEINI_SERACHED2:='c:\esse\cfg\'+ExtractFileName(name_ini_file);


        if not FileExists(name_ini_file) then
           name_ini_file:='c:\esse\cfg\'+ExtractFileName(name_ini_file);

        Param_BSX_SERVER.file_test_json:=ExtractFilePath(name_ini_file)+'test.json';

        Param_BSX_SERVER.FILEINIUSED:=name_ini_file;
        ini:=tinifile.Create(name_ini_file);
        try
           Param_BSX_SERVER.file_export_address_map_beckhoff                :=ini.ReadString('GLOBAL','file_export_address_map_beckhoff','');

           Param_BSX_SERVER.Verboseindex_Main                               :=ini.ReadInteger('GLOBAL','Verboseindex_Main',0);
           Param_BSX_SERVER.Verboseindex_dm_bsx_start_module                :=ini.ReadInteger('GLOBAL','Verboseindex_dm_bsx_start_module',0);
           Param_BSX_SERVER.Verboseindex_Log_chiamate                       :=ini.ReadInteger('GLOBAL','Verboseindex_Log_chiamate',0);
           Param_BSX_SERVER.Verboseindex_mormot                             :=ini.ReadInteger('GLOBAL','Verboseindex_mormot',0);
           Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE                     :=ini.ReadInteger('GLOBAL','Verboseindex_log_BSX_ENGINE',0);
           Param_BSX_SERVER.Verboseindex_BSX_MORMOT_SERVER_INIT             :=ini.ReadInteger('GLOBAL','Verboseindex_BSX_MORMOT_SERVER_INIT',0);
           Param_BSX_SERVER.Verboseindex_logSnap7_reader_and_writer_block   :=ini.ReadInteger('GLOBAL','Verboseindex_logSnap7_reader_and_writer_block',0);
           Param_BSX_SERVER.Verboseindex_Messager                           :=ini.ReadInteger('GLOBAL','Verboseindex_Messager',0);
           Param_BSX_SERVER.Verboseindex_logbeckhoff_reader_and_writer_block:=ini.ReadInteger('GLOBAL','Verboseindex_logbeckhoff_reader_and_writer_block',0);

           Param_BSX_SERVER.file_test_json                     := ini.Readstring('GLOBAL','file_test_json', Param_BSX_SERVER.file_test_json);
           Param_BSX_SERVER.file_xml_def_Plc                   := ini.Readstring('GLOBAL','file_xml_def_Plc', 'C:\!mysw\MORMOT_SCADA\CONFIG_READER_XML\dati_server_plc_server.xml');


//


           Param_BSX_SERVER.Verboseindex_LOG_BSX_beckhoffDataEntry          :=ini.ReadInteger('GLOBAL','Verboseindex_LOG_BSX_beckhoffDataEntry',0);
           Param_BSX_SERVER.Verboseindex_LOG_BSX_beckhoffDescritptionData   :=ini.ReadInteger('GLOBAL','Verboseindex_LOG_BSX_beckhoffDescritptionData',0);
           Param_BSX_SERVER.Verboseindex_Dm_BSX_ENGINE_BeckHoff_Definition  :=ini.ReadInteger('GLOBAL','Verboseindex_Dm_BSX_ENGINE_BeckHoff_Definition',0);
           Param_BSX_SERVER.Verboseindex_logDm_message_util                 :=ini.ReadInteger('GLOBAL','Verboseindex_logDm_message_util',0);

           como:=ini.Readstring('GLOBAL','SiemensSharedConnection','F'); //RETROCOMPATIBILITA
           if (como='T') or
              (como='t') or
              (como='S') or
              (como='s') or
              (como='Y') or
              (como='y') or
              (como='1') then
                Param_BSX_SERVER.PLCSharedConnection:=True;

           como:=ini.Readstring('GLOBAL','PLCSharedConnection','F');
           if (como='T') or
              (como='t') or
              (como='S') or
              (como='s') or
              (como='Y') or
              (como='y') or
              (como='1') then
                Param_BSX_SERVER.PLCSharedConnection:=True;

           como:=ini.Readstring('GLOBAL','SiemensCacheEnabled','F'); //RETROCOMPATIBILITA
           if (como='T') or
              (como='t') or
              (como='S') or
              (como='s') or
              (como='Y') or
              (como='y') or
              (como='1') then
                Param_BSX_SERVER.PLCCacheEnabled:=True;

           como:=ini.Readstring('GLOBAL','PLCCacheEnabled','F');
           if (como='T') or
              (como='t') or
              (como='S') or
              (como='s') or
              (como='Y') or
              (como='y') or
              (como='1') then
                Param_BSX_SERVER.PLCCacheEnabled:=True;

           como:=ini.Readstring('GLOBAL','ReportMemoryLeaksOnShutdown','F');
           if (como='T') or
              (como='t') or
              (como='S') or
              (como='s') or
              (como='Y') or
              (como='y') or
              (como='1') then
                Param_BSX_SERVER.ReportMemoryLeaksOnShutdown:=True;

           como:=ini.Readstring('GLOBAL','useHttpApi','F');
           if (como='T') or
              (como='t') or
              (como='S') or
              (como='s') or
              (como='Y') or
              (como='y') or
              (como='1') then
               Param_BSX_SERVER.useHttpApi:=True;

           como:=ini.Readstring('GLOBAL','debug_check_getValueSource_convert_json','F');

           if (como='T') or
              (como='t') or
              (como='S') or
              (como='s') or
              (como='Y') or
              (como='y') or
              (como='1') then
               Param_BSX_SERVER.debug_check_getValueSource_convert_json:=True;

           Param_BSX_SERVER.Snap7_p_i32_PingTimeout:=ini.ReadInteger('GLOBAL','Snap7_p_i32_PingTimeout',-1);
           Param_BSX_SERVER.Snap7_p_i32_SendTimeout:=ini.ReadInteger('GLOBAL','Snap7_p_i32_SendTimeout',-1);
           Param_BSX_SERVER.Snap7_p_i32_RecvTimeout:=ini.ReadInteger('GLOBAL','Snap7_p_i32_RecvTimeout',-1);
           Param_BSX_SERVER.Snap7_p_i32_PDURequest :=ini.ReadInteger('GLOBAL','Snap7_p_i32_PDURequest',-1);


           Param_BSX_SERVER.BSX_SESSION_TIMEOUT_SEC:=ini.ReadInteger('GLOBAL','BSX_SESSION_TIMEOUT_SEC',60);

        finally
          freeandnil(ini);
        end;
     except
        ;
     end;

     flagParam_BSX_SERVER_readed:=True;
    end;

     //   logfilename:=dir_of_exe_file+xLogFileName;
 // init;
//  maxsizekbyte:=1000;


end;

end.
