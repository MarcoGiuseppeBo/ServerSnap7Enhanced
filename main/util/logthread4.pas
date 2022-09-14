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

unit logthread4;

  {$IFDEF FPC}
 {$mode objfpc}{$H+}
      {$ELSE}

      {$ENDIF}


interface
uses
  Classes, SysUtils ,SynCommons,
///
///
///  *****************************
///
 ////// non togliere MORMOT,  mORMotHttpClient serve per creare package bxlog_pack che poi e usato in package bxdix e bsx
  MORMOT,  mORMotHttpClient ,
 ////// non togliere MORMOT,  mORMotHttpClient
  {$IFDEF FPC}
      {$ELSE}
  SyncObjs,
      {$ENDIF}
 {$define NO_SOCKET}

{$IFDEF NO_SOCKET}
      {$ELSE}
      sss
      blcksock,
     synsock,
     synautil,
     {$ENDIF}
     inifiles;

//  U_pathname_ini_p19_358


  type TLogThread4 = class (tthread)
    private
      id:integer;
     logfilename:ansistring;
{$IFDEF NO_SOCKET}
      {$ELSE}
     priv_SYNAPSE_UDPClient_log: TUDPBlockSocket;
     {$ENDIF}
//     timeEvent:tdatetime;
//     logMess:ansistring;
     mess_code:tstringlist;
     Fmaxsizekbyte:integer;
     Active:boolean;

//     CritReg_Access_listMess:trtlcriticalSection;
  {$IFDEF FPC}
        CritReg_Access_listMess:TRTLCriticalSection;
      {$ELSE}
        CritReg_Access_listMess:TSynLocker;
    FpathnamefileonDisk: string;
    procedure SetpathnamefileonDisk(const Value: string);
    function getpathnamefileonDisk: string;// : tcriticalSection;
      {$ENDIF}
  protected
    procedure Execute; override;
    function  exec_writeMessOnFile():boolean;
    procedure init();
  //  procedure execWork;
  public

    constructor CreateLogWithName(xLogFileName:ansistring);
    constructor CreateFromExeDirPath(xLogFileName:ansistring);
    constructor Create();
    destructor  destroy (); override;
    procedure DoLogMess(xlogMess:string;forcedWrite:boolean=false);
    procedure DoLogMessDEB(xlogMess:string;forcedWrite:boolean=false);
    procedure DoLogMessErr(xlogMess:string);
    procedure SignalEnd();
    procedure setActive(value:boolean);
    property maxsizekbyte : integer read Fmaxsizekbyte write Fmaxsizekbyte;
    property pathnamefileonDisk:string read getpathnamefileonDisk;
//    property MyTerminated: boolean read Priv_MyTerminated;
  end;
procedure getDirLog(var LOG_DIRECTORY:string;var SIZE_LOG:integer);
implementation
uses U_get_version;


constructor TLogThread4.CreateLogWithName(xLogFileName:ansistring);
  var LOG_DIRECTORY:string;
      SIZE_LOG:integer;
      filen:string;
      x:tstringlist;
begin
  inherited Create(true);
  if (copy(xLogFileName,1,1)='\') or (ExtractFileDrive(xLogFileName)>'') or (copy(xLogFileName,1,1)='@')  then
  begin
    if copy(xLogFileName,1,1)='@' then
    begin
       logfilename:=copy(xLogFileName,2,9999);
    end
    else
    begin
       filen:=ExtractFileName(xLogFileName);
       logfilename:=ExtractFilePath(xLogFileName)+ getversion_Only_name+'_'+filen;
    end;
  end
  else
  begin
     getDirLog(LOG_DIRECTORY,SIZE_LOG);
     if copy(LOG_DIRECTORY,length(LOG_DIRECTORY),1)<>'\' then
        LOG_DIRECTORY:=LOG_DIRECTORY+'\';
     logfilename:=LOG_DIRECTORY+getversion_Only_name+'_'+Xlogfilename;
  end;
//  x:=tstringlist.Create;
//  x.Text:=logfilename;
//  x.SaveToFile('c:\aaa\aaa.txt');
//  x.Free;
  init;
  maxsizekbyte:=SIZE_LOG;
end;


constructor TLogThread4.CreateFromExeDirPath(xLogFileName:ansistring);
var dir_of_exe_file:string;
    exeFileComo:string;
begin
      inherited Create(true);

        dir_of_exe_file:=ParamStr(0);

        dir_of_exe_file:=uppercase(dir_of_exe_file);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\DEBUG','',[rfReplaceAll, rfIgnoreCase]);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\RELEASE','',[rfReplaceAll, rfIgnoreCase]);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\WIN32','',[rfReplaceAll, rfIgnoreCase]);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\WIN64','',[rfReplaceAll, rfIgnoreCase]);

        dir_of_exe_file:=ExtractFilePath(dir_of_exe_file);
        if dir_of_exe_file='' then
           dir_of_exe_file:='\';

        if copy(xLogFileName,1,1)='\' then
           xLogFileName:=copy(xLogFileName,2);


        logfilename:=dir_of_exe_file+xLogFileName;
  init;
  maxsizekbyte:=1000;


end;

constructor TLogThread4.Create();
begin
  inherited Create(true);
  logfileName:=ParamStr(0);
  if (pos('.exe',logfileName)>0) then
     logfileName:=copy(logfileName,1,length(logfileName)-4);
  logfileName:=logfileName+'.log';
  INIT();
end;
destructor TLogThread4.destroy() ;
begin
//   doneCriticalSection(CritReg_Access_listMess);
     {$IFDEF FPC}
         doneCriticalSection(CritReg_Access_listMess);
      {$ELSE}
       CritReg_Access_listMess.done; //  try freeandnil(CritReg_Access_listMess);except ;end;
      {$ENDIF}

   try
     freeandnil(mess_code);
   except
       ;
   end;
   inherited destroy();
end;

procedure TLogThread4.setActive(value:boolean);
begin
   Active:=value;
end;

procedure TLogThread4.init();
begin
  Active:=true;
//  writeln('inizio TLogThread.Create<'+XlogMess+'>');
  Fmaxsizekbyte:=1000;
  id:=0;
  //initCriticalSection(CritReg_Access_listMess);

  {$IFDEF FPC}
      initCriticalSection(CritReg_Access_listMess);
   {$ELSE}
    CritReg_Access_listMess.Init; //  CritReg_Access_listMess:=tcriticalSection.create;
   {$ENDIF}

  self.FreeOnTerminate:=true;
  mess_code:=tstringlist.Create;
  self.Resume;
end;
procedure TLogThread4.SetpathnamefileonDisk(const Value: string);
begin
  FpathnamefileonDisk := Value;
end;

procedure TLogThread4.SignalEnd();
begin
  ;
end;
procedure TLogThread4.DoLogMessErr(xlogMess:string);
var
   comomess:ansistring;
   flgCritOn:boolean;
   handlethread:TThreadID;
begin
   try
      handlethread:=TThread.CurrentThread.ThreadID;
   except
      handlethread:=9999999;
   end;
   comomess:=formatdatetime('yyyy/mm/dd hh:nn:ss.zzz',now)+'['+inttostr(handlethread)+'] [ERROR] '+xlogMess+#13#10;
   flgCritOn:=false;
       try
        //  EnterCriticalsection(CritReg_Access_listMess);

         {$IFDEF FPC}
             enterCriticalSection(CritReg_Access_listMess);
          {$ELSE}
              CritReg_Access_listMess.lock;// //CritReg_Access_listMess.Enter;
          {$ENDIF}
          flgCritOn:=True;
          inc(id);
          comomess:='['+mess_code.Count.ToString+']'+comomess;
      //    mess_code.insert(0,formatfloat('000000000 ',id)+comomess);
          mess_code.append(formatfloat('000000000 ',id)+comomess);
       finally
          if flgCritOn then
          {$IFDEF FPC}
              leaveCriticalSection(CritReg_Access_listMess);
           {$ELSE}
              CritReg_Access_listMess.UnLock;  //               CritReg_Access_listMess.leave;
           {$ENDIF}
//            leaveCriticalsection(CritReg_Access_listMess);
       end;

end;
procedure TLogThread4.DoLogMess(xlogMess:string;forcedWrite:boolean=false);
var
   comomess:ansistring;
   flgCritOn:boolean;
   handlethread:TThreadID;
begin
  if (Active=false) and (forcedWrite = false) then
    exit;
    try
      handlethread:=CurrentThread.Handle;
    except;
      handlethread:=999999999;
    end   ;
   comomess:=formatdatetime('yyyy/mm/dd hh:nn:ss.zzz',now)+'['+inttostr(handlethread)+'] [INFO] '+ xlogMess+#13#10;
   flgCritOn:=false;
       try
          try
        //  EnterCriticalsection(CritReg_Access_listMess);

         {$IFDEF FPC}
             enterCriticalSection(CritReg_Access_listMess);
          {$ELSE}
            CritReg_Access_listMess.Lock;            //  CritReg_Access_listMess.Enter;
          {$ENDIF}
          flgCritOn:=True;
          inc(id);
          comomess:='['+mess_code.Count.ToString+']'+comomess;
          mess_code.append(formatfloat('000000000 ',id)+comomess);
          except
              ;
          end;
    //      mess_code.insert(0,formatfloat('000000000 ',id)+comomess);
       finally
          if flgCritOn then
          {$IFDEF FPC}
              leaveCriticalSection(CritReg_Access_listMess);
           {$ELSE}
                CritReg_Access_listMess.UnLock; //               CritReg_Access_listMess.leave;
           {$ENDIF}
//            leaveCriticalsection(CritReg_Access_listMess);
       end;

end;

procedure TLogThread4.DoLogMessDEB(xlogMess:string;forcedWrite:boolean=false);
var
   comomess:ansistring;
   flgCritOn:boolean;
   handlethread:TThreadID;
begin
  if (Active=false) and (forcedWrite = false) then
    exit;
    try
      handlethread:=CurrentThread.Handle;
    except;
      handlethread:=999999999;
    end   ;
   comomess:=formatdatetime('yyyy/mm/dd hh:nn:ss.zzz',now)+'['+inttostr(handlethread)+'] [DEBU] '+ xlogMess+#13#10;
   flgCritOn:=false;
       try
        //  EnterCriticalsection(CritReg_Access_listMess);

         {$IFDEF FPC}
             enterCriticalSection(CritReg_Access_listMess);
          {$ELSE}
             CritReg_Access_listMess.LOCK; //   CritReg_Access_listMess.Enter;
          {$ENDIF}
          flgCritOn:=True;
          inc(id);
          comomess:='['+mess_code.Count.ToString+']'+comomess;
          mess_code.append(formatfloat('000000000 ',id)+comomess);
    //      mess_code.insert(0,formatfloat('000000000 ',id)+comomess);
       finally
          if flgCritOn then
          {$IFDEF FPC}
              leaveCriticalSection(CritReg_Access_listMess);
           {$ELSE}
             CritReg_Access_listMess.UnLock;//               CritReg_Access_listMess.leave;
           {$ENDIF}
//            leaveCriticalsection(CritReg_Access_listMess);
       end;

end;


procedure TLogThread4.Execute;
var k:integer;
    esci:Boolean;
begin
  esci := false;
  try
    // writeln('start TLogThread.Execute');
    repeat
      if not self.Terminated then
      begin
        try
          exec_writeMessOnFile()
        except
          break;
        end;
      end
      else
        break;
      sleep(10);
    until Terminated;
  finally
  end;
  // writeln('end TLogThread.Execute');
end;
function TLogThread4.exec_writeMessOnFile():boolean;
//var F:TextFile;
  var f       :longint;
      comomess:ansistring;
      flgCritOn:boolean;
      serv:ansistring;
      port:integer;
      p1:integer;
      fileofbyte: file of Byte;
      size:int64;
      i:integer;
begin
       flgCritOn:=false;
       comomess:='';
       try
          {$IFDEF FPC}
              enterCriticalSection(CritReg_Access_listMess);
           {$ELSE}
              CritReg_Access_listMess.Lock; //CritReg_Access_listMess.Enter;
           {$ENDIF}
//          EnterCriticalsection(CritReg_Access_listMess);
          flgCritOn:=True;
          if (mess_code.Count>0) then
          begin
//             for I :=mess_code.Count-1 downto 0  do
(*             for I :=0 to mess_code.Count-1 do
             begin
                comomess:=comomess+mess_code.Strings[i];//+#13#10;// mess_code.strings[mess_code.Count-1];
             end;*)
             comomess:=comomess+mess_code.Text;
             mess_code.Clear;
//             mess_code.Delete(mess_code.Count-1);
          end;
       finally
          if flgCritOn then
          {$IFDEF FPC}
              leaveCriticalSection(CritReg_Access_listMess);
           {$ELSE}
               CritReg_Access_listMess.UnLock; //               CritReg_Access_listMess.leave;
           {$ENDIF}
          //  leaveCriticalsection(CritReg_Access_listMess);
       end;
   if (comomess='') then
   begin
      result:=true;
      exit;
   end;
   ///   '*server=123.123.123.123-12345'
   ///                       12345678
{$IFDEF NO_SOCKET}
      {$ELSE}
   if copy(logfilename,1,8)='*server=' then
   begin
      result:=False;
      priv_SYNAPSE_UDPClient_log:=nil;
      try
         serv:=copy(logfilename,9,9999);
         p1:=pos('-',serv);
         if p1>0 then
         begin
          //  writeln('SERVER LOG data <'+ serv+'>');
            port:=strtoint(copy(serv,p1+1,9999));
            serv:=copy(serv,1,p1-1);
          //  writeln('SERVER LOG serv<'+ serv+'> port<'+inttostr(port)+'>');
             priv_SYNAPSE_UDPClient_log := TUDPBlockSocket.Create;
             try
         //send to server
                 priv_SYNAPSE_UDPClient_log.Connect(serv, inttostr(port) );
                 priv_SYNAPSE_UDPClient_log.Sendstring(comomess);
                 priv_SYNAPSE_UDPClient_log.CloseSocket;
                 result:=true;
             except
             end;
         end;
      finally
         if priv_SYNAPSE_UDPClient_log<>nil then
            freeandnil(priv_SYNAPSE_UDPClient_log);
      end;
   end
   else
           {$ENDIF}
   begin
      result:=false;
      try
         if not FileExists(logfilename) { *Converted from FileExists*  } Then
         begin
            f:=filecreate(logfilename);
            if (f=-1) then
            begin
               result:=false;
               exit;
            end;
            fileclose(f);
         end
         else
         begin
             AssignFile(fileofbyte, logfilename);
             Reset(fileofbyte);
             try
                size := system.FileSize(fileofbyte);
             finally
                CloseFile(fileofbyte);
             end;
             if size>(Fmaxsizekbyte*1024) then
             begin
                try
                   deletefile(logfilename);
                   f:=filecreate(logfilename);
                   if (f=-1) then
                   begin
                     result:=false;
                     exit;
                   end;
                   fileclose(f);
                except
                   ;
                end;
             end;
         end;
         F:=FileOpen(logfilename,fmOpenWrite);
         if (f=-1) then
         begin
            result:=false;
            exit;
         end;
         if (fileseek(f,0,soFromEnd )>-1) then
         begin
            if (fileWrite(f,comomess[1],length(comomess))>-1) then
            begin
               result:=true;
            end;
         end;
         fileclose(f);
      except
         result:=false;
      end;
   end;
end;

function TLogThread4.getpathnamefileonDisk: string;
begin
  result:=self.logfilename;
end;

procedure getDirLog(var LOG_DIRECTORY:string;var SIZE_LOG:integer);
var
  ini:TIniFile;
  var xDIRECTORY_INI_APP:string;
      xDIRECTORY_LOG_DEFAULT:string;
      xSIZE_LOG_DEFAULT:integer;
      zz:integer;
begin
  xSIZE_LOG_DEFAULT:=100;
  xDIRECTORY_LOG_DEFAULT:='.\log\';
  try
     try
        for zz:=1 to ParamCount do
        begin
           if copy(ParamStr(zz),1,4)='LOG=' then
           begin
              xDIRECTORY_INI_APP:=System.SysUtils.trim(copy(ParamStr(zz),5));
           end;
        end;

      //  xDIRECTORY_INI_APP:=paramstr(1);
        if xDIRECTORY_INI_APP='' then
           raise exception.create('Error Message');

     except
        try
          xDIRECTORY_INI_APP:=extractfilepath(ParamStr(0));
        except
           xDIRECTORY_INI_APP:='.\';
        end;
     end;
     xDIRECTORY_LOG_DEFAULT:=xDIRECTORY_INI_APP+'log\';
     try
        ini:=TIniFile.create(xDIRECTORY_INI_APP+'APP.INI');
        LOG_DIRECTORY      :=ini.ReadString('LOG','LOG_DIRECTORY',xDIRECTORY_LOG_DEFAULT);
//        NUMERO_LOG_STORICI :=ini.ReadInteger('LOG','NUMERO_LOG_STORICI',NUMERO_LOG_STORICI_DEFAULT);
        SIZE_LOG           :=ini.ReadInteger('LOG','SIZE_LOG',xSIZE_LOG_DEFAULT);
//        comoUseConsole     :=ini.ReadString('LOG','USE_CONSOLE_LOG',USE_CONSOLE_LOG_DEFAULT);

     finally
        freeandnil(ini);
     end;

  except
   LOG_DIRECTORY:=xDIRECTORY_LOG_DEFAULT;
//   NUMERO_LOG_STORICI:=NUMERO_LOG_STORICI_DEFAULT;
   SIZE_LOG:=xSIZE_LOG_DEFAULT;
//   comoUseConsole :=USE_CONSOLE_LOG_DEFAULT;
  end;
end;


(*
//unit logthread;

  {$IFDEF FPC}
 {$mode objfpc}{$H+}
      {$ELSE}

      {$ENDIF}


interface
uses
 System.SysUtils,  u_logger_pro ;

  type TLogThread4 = class (tobject)
    private
    tagname:string;
    Active:boolean;
  protected
    procedure init();
  //  procedure execWork;
  public

    constructor CreateLogWithName(xLogFileName:string);
    constructor Create();
    destructor  Destroy ();override;
    procedure DoLogMess(xlogMess:string;forcedWrite:boolean=false);
    procedure DoLogMessErr(xlogMess:string);
    procedure SignalEnd();
    procedure setActive(value:boolean);
//    property MyTerminated: boolean read Priv_MyTerminated;
  end;

implementation
procedure TLogThread4.SignalEnd();
begin
end;

procedure TLogThread4.setActive(value:boolean);
begin
   Active:=value;
end;

constructor TLogThread4.CreateLogWithName(xLogFileName:string);

begin
  inherited Create;
  Active:=true;
  tagname:=extractfilename(xLogFileName);

end;
constructor TLogThread4.Create();
begin
  inherited Create;
  Active:=true;
end;
destructor TLogThread4.Destroy() ;
begin
   inherited destroy();
end;

procedure TLogThread4.init();
begin
end;
procedure TLogThread4.DoLogMess(xlogMess:string;forcedWrite:boolean=false);
var
   comomess:string;
   flgCritOn:boolean;
begin
  if Active or forcedWrite then
  try
     log.Info(xlogMess,tagname);
  except
      ;
  end;
//   exit;
end;

procedure TLogThread4.DoLogMessErr(xlogMess:string);
var
   comomess:string;
   flgCritOn:boolean;
begin
  try
     log.Error(xlogMess,tagname);
  except
      ;
  end;
//   exit;
end;



  *)

end.

