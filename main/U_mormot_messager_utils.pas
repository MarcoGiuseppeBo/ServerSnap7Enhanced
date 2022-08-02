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

unit U_mormot_messager_utils;
interface
 uses  system.messaging,  u_mormot_server_read_ini,logthread4,system.Classes,sysutils;
 type TBSXMessage=record
     bsxCode:integer;
     bsxDesc:string;
  end;
  type TBSXContanierOfBSXMessage = Class(tmessage<TBSXMessage>);
procedure mysendmessage(const Sender: TObject; const cod:integer;const des:string);

var
logDm_message_util:TLogThread4;

implementation

procedure writemessage_utils(const s:string);
begin
  if Param_BSX_SERVER.Verboseindex_logDm_message_util>0 then
  begin
     if logDm_message_util<>nil then
        logDm_message_util.DoLogMess(s);
  end;


end;

procedure mysendmessage(const Sender: TObject; const cod:integer;const des:string);
var t:TBSXMessage;
    flagSendMsg:boolean;
begin
  if Param_BSX_SERVER.Verboseindex_logDm_message_util>0 then
  begin
     if logDm_message_util<>nil then
        logDm_message_util.DoLogMess('cod['+cod.ToString+'] Des<' +des+'>' );
  end;

   case Param_BSX_SERVER.Verboseindex_Messager of
      0:flagSendMsg:=False;
      1:if cod=1 then flagSendMsg:=True;
      2:if cod=2 then flagSendMsg:=True;
      else
        flagSendMsg:=True;

   end;
   if flagSendMsg then
   begin

      t.bsxCode:=cod;
      t.bsxDesc:=des;
      TMessageManager.DefaultManager.SendMessage(sender,TBSXContanierOfBSXMessage.Create(t));
   end;
end;
initialization
   read_Param_Dm_start_module; // lo faccio in ogni modulo perche non so quale initialize viene chiamata per prima
   try
      logDm_message_util:=TLogThread4.CreateFromExeDirPath('\log\Dm_message_util.log');
      logDm_message_util.maxsizekbyte:=100000;
      logDm_message_util.setActive(true);
      logDm_message_util.DoLogMessErr('Started!');
      sleep(100);
   except
      logDm_message_util:=nil;
   end;
finalization
  try
    if assigned(logDm_message_util) then
    begin
      logDm_message_util.FreeOnTerminate:=true;
      logDm_message_util.SignalEnd();
      logDm_message_util.Terminate;
    end;
  except
     ;
  end;
   //logTBSXCLient.free;






end.
