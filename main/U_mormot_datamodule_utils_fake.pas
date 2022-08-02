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

unit U_mormot_datamodule_utils_fake;

interface

uses
  System.SysUtils, System.Classes,
  u_mormot_server_read_ini,
  logthread4,U_BSX_mormot_interface,
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  {$ELSE}
   TcAdsDef, BOX_SCADA_PLC_rid,
  {$ENDIF}

  U_mormot_messager_utils;



const tipo_to_ll_beckhoff
    ='@BYTE=1,@BOOL=1,@SINT=1,@USINT=1,@WORD=2,@DWORD=4,@STRING=1,@DATETIME=4,@DT=4,@DATE_AND_TIME=4,@TIME=4,@INT=2,@UINT=2,@DINT=4,@UDINT=4,@REAL=4,@LREAL=8,@LINT=8,@POINTER=8,@REFERENCE=8,@GUID=16,@UXINT=8,@WSTRING=2,@BIT=1,'; //!!la virgola fina ci deve essere

const tipo_to_ll_siemens
    ='@BYTE=1,@BOOL=1,@SINT=1,@USINT=1,@WORD=2,@DWORD=4,@STRING=1,@DATETIME=8,@DT=8,@DATE_AND_TIME=8,@TIME=4,@INT=2,@UINT=2,@DINT=4,@UDINT=4,@REAL=4,@LREAL=8,@LINT=8,@POINTER=8,@REFERENCE=8,@GUID=16,@UXINT=8,@WSTRING=2,@BIT=1,'; //!!la virgola fina ci deve essere



type tgetXmlTypeOnPlc_back=record
     xml:string;
     error:TError;
end;

type tInfoVarOnPlcFisico_back=record
     xml:string;
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  {$ELSE}
     entry:tAdrVarEle;
  {$ENDIF}
     error:TError;
end;


type
  TDm_utils = class(TDataModule)
  private
    { Private declarations }
  public
     function getNomeFileParam:string;
     function getXMLParam: string;
     function getXMLParamFromFile(xfilename:string):string;
     procedure writelog(s:string);
     procedure writelogErr(s:string);
    { Public declarations }
  end;

var
  Dm_utils: TDm_utils;
  BSX_INIT_LOG:TLogThread4;



implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}



{ TDataModule1 }

function TDm_utils.getNomeFileParam: string;
begin

   result:=paramstr(1);
   if result='' then
      result:='C:\!mysw\MORMOT_SCADA\CONFIG_READER_XML\dati_server_plc_server.xml';
   mysendmessage(nil,99,'getNomeFileParam<'+result+'>');


end;


function TDm_utils.getXMLParamFromFile(xfilename:string):string;
var
  ts:tstringlist;
  filename:string;
  xml:string;
begin
   result:='';
   try
      filename:=xfilename;
      ts:=tstringlist.create;
      try
         ts.LoadFromFile(filename);
         xml:=ts.Text;
      finally
        freeandnil(ts);
      end;
      result:=xml;
   except
      on e:exception do
      begin
         writelog('TDm_utils.getXMLParam '+e.Message);
      end;
   end;
end;




function TDm_utils.getXMLParam: string;
var
  ts:tstringlist;
  filename:string;
  xml:string;
begin
   result:='';
   try
      filename:=Dm_utils.getNomeFileParam;
      ts:=tstringlist.create;
      try
         ts.LoadFromFile(filename);
         xml:=ts.Text;
      finally
        freeandnil(ts);
      end;
      result:=xml;
   except
      on e:exception do
      begin
         writelog('TDm_utils.getXMLParam '+e.Message);
      end;
   end;
end;


procedure TDm_utils.writelog(s: string);
begin
    if BSX_INIT_LOG<>nil then
      BSX_INIT_LOG.DoLogMess(s);
end;

procedure TDm_utils.writelogErr(s: string);
begin
    if BSX_INIT_LOG<>nil then
      BSX_INIT_LOG.DoLogMessErr(s);

end;

initialization

   read_Param_Dm_start_module; // lo faccio in ogni modulo perche non so quale initialize viene chiamata per prima


   try
      BSX_INIT_LOG:=TLogThread4.CreateFromExeDirPath('\log\Dm_BSX_MORMOT_SERVER_INIT.log');
      BSX_INIT_LOG.maxsizekbyte:=100000;

      BSX_INIT_LOG.setActive(true);

      BSX_INIT_LOG.DoLogMessErr('Started!');
      sleep(100);
   except
      BSX_INIT_LOG:=nil;
   end;

finalization
  try
    if assigned(BSX_INIT_LOG) then
    begin

      BSX_INIT_LOG.FreeOnTerminate:=true;

      BSX_INIT_LOG.SignalEnd();
      BSX_INIT_LOG.Terminate;
    end;
  except
     ;
  end;
   //logTBSXCLient.free;





end.
