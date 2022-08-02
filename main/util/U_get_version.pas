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

unit U_get_version;

interface
uses Windows,Classes,SysUtils;

function getVersion_and_name:string;
function getversion_Only_name:string;
function createpathformExeFile(xFileName:string):string;

implementation


function createpathformExeFile(xFileName:string):string;
var dir_of_exe_file:string;
begin


        dir_of_exe_file:=ParamStr(0);

        dir_of_exe_file:=uppercase(dir_of_exe_file);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\DEBUG','',[rfReplaceAll, rfIgnoreCase]);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\RELEASE','',[rfReplaceAll, rfIgnoreCase]);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\WIN32','',[rfReplaceAll, rfIgnoreCase]);
        dir_of_exe_file:=stringreplace(dir_of_exe_file,'\WIN64','',[rfReplaceAll, rfIgnoreCase]);

        dir_of_exe_file:=ExtractFilePath(dir_of_exe_file);
        if dir_of_exe_file='' then
           dir_of_exe_file:='\';

        if copy(xFileName,1,1)='\' then
           xFileName:=copy(xFileName,2);


        result:=dir_of_exe_file+xFileName;
end;






function getVersion_and_name:string;
var
  verblock:PVSFIXEDFILEINFO;
  versionMS,versionLS:cardinal;
  verlen:cardinal;
  rs:TResourceStream;
  m:TMemoryStream;
  p:pointer;
  s:cardinal;
begin
  m:=TMemoryStream.Create;
  try
    rs:=TResourceStream.CreateFromID(HInstance,1,RT_VERSION);
    try
      m.CopyFrom(rs,rs.Size);
    finally
      rs.Free;
    end;
    m.Position:=0;
    if VerQueryValue(m.Memory,'\',pointer(verblock),verlen) then
      begin

        VersionMS:=verblock.dwFileVersionMS;
        VersionLS:=verblock.dwFileVersionLS;
        result:=
          IntToStr(versionMS shr 16)+'.'+
          IntToStr(versionMS and $FFFF)+'.'+
          IntToStr(VersionLS shr 16)+'.'+
          IntToStr(VersionLS and $FFFF);
      end;
    if VerQueryValue(m.Memory,PChar('\\StringFileInfo\\'+
      IntToHex(GetThreadLocale,4)+IntToHex(GetACP,4)+'\\FileDescription'),p,s) or
        VerQueryValue(m.Memory,'\\StringFileInfo\\040904E4\\FileDescription',p,s) then //en-us
          result:=PChar(p)+' '+result;
  finally
    m.Free;
  end;
end;



function getversion_Only_name:string;
var
  verblock:PVSFIXEDFILEINFO;
  versionMS,versionLS:cardinal;
  verlen:cardinal;
  rs:TResourceStream;
  m:TMemoryStream;
  p:pointer;
  s:cardinal;
begin
  result:='';
  m:=TMemoryStream.Create;
  try
    rs:=TResourceStream.CreateFromID(HInstance,1,RT_VERSION);
    try
      m.CopyFrom(rs,rs.Size);
    finally
      rs.Free;
    end;
    m.Position:=0;

    if VerQueryValue(m.Memory,'\',pointer(verblock),verlen) then
      begin

        VersionMS:=verblock.dwFileVersionMS;
        VersionLS:=verblock.dwFileVersionLS;
        result:=
          IntToStr(versionMS shr 16)+'.'+
          IntToStr(versionMS and $FFFF)+'.'+
          IntToStr(VersionLS shr 16)+'.'+
          IntToStr(VersionLS and $FFFF);
      end;

    if VerQueryValue(m.Memory,PChar('\\StringFileInfo\\'+
      IntToHex(GetThreadLocale,4)+IntToHex(GetACP,4)+'\\FileDescription'),p,s) or
        VerQueryValue(m.Memory,'\\StringFileInfo\\040904E4\\FileDescription',p,s)
    then //en-us
    begin
          result:=PChar(p);
    end;
  finally
    m.Free;
  end;
end;


end.
