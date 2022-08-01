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

unit U_Snap7_reader_and_writer_block_fake;
interface
uses System.SysUtils,snap7,U_tarrayofbyte,logthread4,u_def_param_db,u_mormot_server_read_ini;
//type tarrayofbyte=array of byte;
procedure Snap7connect(snap7client:TS7Client;ipadr:string;rack:Integer;slot:integer);
function Snap7Readbuffer(snap7client:TS7Client;db:integer;offset:integer;ll:integer;dummyMaxage:integer):tarrayofbyte;
procedure Snap7Writebuffer(snap7client:TS7Client;db:integer;offset:integer;ll:integer;buff:tarrayofbyte);
procedure Snap7Writebuffer_BIT(snap7client:TS7Client;db:integer;offsetBYTE:integer;posBIT:integer;Value:boolean);

Function SIEMENS_BYTE_TO_Boolean(x:BYTE):boolean;overload;
Function SIEMENS_boolean_TO_BYTE(x:boolean):BYTE;
Function SIEMENS_BYTE_TO_Boolean(v:variant):boolean;overload;
function Siem_GetBit(val:BYTE; BitIndex: integer): boolean;
function Siem_GetBit_UNO_ZERO(val:BYTE; BitIndex: integer): Byte;
var logSnap7_reader_and_writer_block:TLogThread4;


implementation

function Set_a_Bit(const aValue: BYTE; const Bitnum: Byte): byte;
begin
  Result := aValue or (1 shl Bitnum);
end;

//set a particular bit as 0
function Clear_a_Bit(const aValue: BYTE; const Bitnum: Byte): Byte;
begin
  Result := aValue and not (1 shl Bitnum);
end;


function Siem_GetBit(val:BYTE; BitIndex: integer): boolean;
Const
  Mask : array[0..7] of byte = ($01,$02,$04,$08,$10,$20,$40,$80);
begin
  if BitIndex<0 then BitIndex:=0;
  if BitIndex>7 then BitIndex:=7;
  Result:=val and Mask[BitIndex] <> 0;
end;
function Siem_GetBit_UNO_ZERO(val:BYTE; BitIndex: integer): Byte;
begin
  if Siem_GetBit(val,BitIndex) then
     result:=1
  else
     result:=0;
end;
procedure logSnap7_reader_and_writer_block_writelog(const s:String);
begin
    if logSnap7_reader_and_writer_block<>nil then
    try
       logSnap7_reader_and_writer_block.DoLogMess(s);
    except
      ;
    end;
end;

procedure logSnap7_reader_and_writer_block_writelogerr(const s:String);
begin
    if logSnap7_reader_and_writer_block<>nil then
       logSnap7_reader_and_writer_block.DoLogMessErr(s);
end;

procedure Check(iResult : integer; sFunction : string);
var s:string;
begin
    if (iResult<>0) then
    begin
       s:='';
        if (iResult<0) then
            s:=sFunction +' Library Error (-1)'
        else
            s:=sFunction +' '+CliErrorText(iResult);
        logSnap7_reader_and_writer_block_writelogerr(s);
        raise exception.Create(s);
    end;
end;


procedure Snap7connect(snap7client:TS7Client;ipadr:string;rack:Integer;slot:integer);
var r:integer;
    s:string;
begin
    exit;
  //r:=snap7client.ConnectTo(ipadr,rack,slot);
  //s:='---------- Try to Connect Client IP =<'+ipadr+'> rack=<'+rack.ToString+'>slot=<'+slot.ToString+'>';
  //logSnap7_reader_and_writer_block_writelog(s);
  //check(r,'Connect');
  //logSnap7_reader_and_writer_block_writelog('Connected!');
end;
function Snap7Readbuffer(snap7client:TS7Client;db:integer;offset:integer;ll:integer;dummyMaxage:integer):tarrayofbyte;
var r:integer;
    s:string;
     xparamdb:TparamDb;
    i:integer;
    isou:integer;
    idest:integer;
begin
    setlength(result,ll);
    FillChar(result[0],ll, 0);
    if not GDizioDataDb.TryGetValue(db,xparamdb) then
    begin
       r:=9999;
       check(r,'DBRead db<'+db.ToString+' pos<'+offset.ToString+' ll<'+ll.ToString+'>');
    end;
    try
       if GDataDb[xparamdb.indexGDataDb].rifServer<>nil then
          GDataDb[xparamdb.indexGDataDb].rifServer.LockArea(srvAreaDB,
                                xparamdb.numdb);
       for I := 0  to ll-1 do
       begin
          idest:=i;
          isou:= i+offset;
          result[idest]:=GDataDb[xparamdb.indexGDataDb].buff[isou];
       //move(@GDataDb[xparamdb.indexGDataDb].buff[offset],@result[0],ll);
       end;
       r:=0;
    finally
       if GDataDb[xparamdb.indexGDataDb].rifServer<>nil then
          GDataDb[xparamdb.indexGDataDb].rifServer.unLockArea(srvAreaDB,
                                xparamdb.numdb);

    end;
//    r:=snap7client.DBRead(db,offset,ll,@result[0]);
//    check(r,'DBRead db<'+db.ToString+' pos<'+offset.ToString+' ll<'+ll.ToString+'>');
end;
procedure Snap7Writebuffer(snap7client:TS7Client;db:integer;offset:integer;ll:integer;buff:tarrayofbyte);
var r:integer;
    s:string;
    k:integer;
    fine:boolean;
     xparamdb:TparamDb;
    i:integer;
    isou:integer;
    idest:integer;
    maxpos:integer;
begin

   (*
    if logSnap7_reader_and_writer_block<>nil then
    begin
      s:='';
      fine:=False;
      k:=0;
      while k<ll+1 do
      begin
        if k<ll then
        begin
          if ((k) mod 16)=0 then
          begin
             s:=s+#13#10;
             s:=s+ IntToHex(k+offset,4)+ ' ('+IntToHex(k,4)+')  ';
          end;
        end;
        if k<ll then
           s:=s+IntToHex(buff[k],2)+' ';
          inc(k);
      end;
      s:='Write Buffer db=<'+db.ToString+'> offset=<'+offset.ToString+'> size=<'+ll.ToString+'>'+#13#10+s;
      logSnap7_reader_and_writer_block_writelog(s);
    end;
    *)
    if not GDizioDataDb.TryGetValue(db,xparamdb) then
    begin
       r:=9999;
       check(r,'DBRead db<'+db.ToString+' pos<'+offset.ToString+' ll<'+ll.ToString+'>');
    end;
    try
       if GDataDb[xparamdb.indexGDataDb].rifServer<>nil then
          GDataDb[xparamdb.indexGDataDb].rifServer.LockArea(srvAreaDB,
                                xparamdb.numdb);
       maxpos:=xparamdb.lendb;
       if length(GDataDb[xparamdb.indexGDataDb].buff)>maxpos then
          maxpos:=length(GDataDb[xparamdb.indexGDataDb].buff);
       dec(maxpos);
       for I := 0  to ll-1 do
       begin
          idest:=i+offset;;
          isou:= i;
          if (idest>maxpos) then
          begin
            raise Exception.Create('write over max ('+maxpos.ToString+') siemens buffer size');
          end;
          GDataDb[xparamdb.indexGDataDb].buff[idest]:= buff[isou];
       //move(@GDataDb[xparamdb.indexGDataDb].buff[offset],@result[0],ll);
       end;
       r:=0;
    finally
       if GDataDb[xparamdb.indexGDataDb].rifServer<>nil then
          GDataDb[xparamdb.indexGDataDb].rifServer.unLockArea(srvAreaDB,
                                xparamdb.numdb);

    end;


//    r:=snap7client.DBWrite(db,offset,ll,@buff[0]);
    check(r,'DBWrite db<'+db.ToString+' pos<'+offset.ToString+' ll<'+ll.ToString+'>');
    logSnap7_reader_and_writer_block_writelog('Writed!!');
end;
procedure Snap7Writebuffer_BIT(snap7client:TS7Client;db:integer;offsetBYTE:integer;posBIT:integer;Value:boolean);
var r:integer;
    buff:array[0..0] of byte;
    absolutebit:integer;
    byteIndex:integer;
  s:string;
  bitpos:integer;
   xparamdb:TparamDb;
   BYTEONBUFF:BYTE;
begin

      buff[0]:=SIEMENS_boolean_TO_BYTE(value);
      absolutebit:=(offsetBYTE*8)+posBIT;

      byteIndex:=absolutebit div 8;
      bitpos:=  absolutebit mod 8;


    if not GDizioDataDb.TryGetValue(db,xparamdb) then
    begin
       r:=9999;
       check(r,'Snap7Writebuffer_BIT<'+db.ToString+' pos<'+offsetBYTE.ToString+' posBIT<'+posBIT.ToString+'>');
    end;


      s:='Write BIT db=<'+db.ToString+'> absolutebit=<'+absolutebit.ToString+'>' ;
      if value then
         s:=s+' TO TRUE '
      else
         s:=s+' TO FALSE ';

    try
       if GDataDb[xparamdb.indexGDataDb].rifServer<>nil then
          GDataDb[xparamdb.indexGDataDb].rifServer.LockArea(srvAreaDB,
                                xparamdb.numdb);
         BYTEONBUFF:=  GDataDb[xparamdb.indexGDataDb].buff[byteIndex];
         if value then
            BYTEONBUFF:=Set_a_Bit(BYTEONBUFF,bitpos)
         else
            BYTEONBUFF:=Clear_a_Bit(BYTEONBUFF,bitpos);

         GDataDb[xparamdb.indexGDataDb].buff[byteIndex]:= BYTEONBUFF;

    finally
       if GDataDb[xparamdb.indexGDataDb].rifServer<>nil then
          GDataDb[xparamdb.indexGDataDb].rifServer.unLockArea(srvAreaDB,
                                xparamdb.numdb);

    end;


(*     s:=s+' (value byte=<'+IntToHex(buff[0],2)+'>)';
     logSnap7_reader_and_writer_block_writelog(s);
     r:=snap7client.WriteArea(S7AreaDB,DB,absolutebit,1,S7WLBit,@buff[0]);
//    r:=snap7client.DBWrite(db,(offsetBYTE*8)+posBIT,S7WLBit,@buff[0]);
//    r:=snap7client.DBWrite(db,2,S7WLBit,@buff[0]);
    check(r,'DBWrite BIT db<'+db.ToString+' pos<'+offsetBYTE.ToString+'>/posBIT<'+posBIT.tostring+'> ');
     logSnap7_reader_and_writer_block_writelog('Writed!!');
     *)
end;
Function SIEMENS_BYTE_TO_Boolean(x:BYTE):boolean;overload;
begin
   if x<>0 then
      result:=False
   else
      result:=True;
///   !!!!! attenzione funziona al contrario di siemens, percio inverto
///
      result:=not result;

end;
Function SIEMENS_BYTE_TO_Boolean(v:variant):boolean;overload;
var s:string;
    x:int64;
begin
   x:=0;
   try
     s:=v;
     x:=strtoint(s);
   except
     x:=0
   end;
   if x<>0 then
      result:=False
   else
      result:=True;

///   !!!!! attenzione funziona al contrario di siemens, percio inverto
///
   result:=not result;


end;
Function SIEMENS_boolean_TO_BYTE(x:boolean):BYTE;
begin
   if x then
      result:=0
   else
      result:=255;
end;
initialization
   read_Param_Dm_start_module; // lo faccio in ogni modulo perche non so quale initialize viene chiamata per prima

   try
      logSnap7_reader_and_writer_block:=TLogThread4.CreateLogWithName('logSnap7_reader_and_writer_block_fake');
      logSnap7_reader_and_writer_block.maxsizekbyte:=100000;
      logSnap7_reader_and_writer_block.setActive(true);
      logSnap7_reader_and_writer_block.DoLogMessErr('Started!');
      sleep(100);
   except
      logSnap7_reader_and_writer_block:=nil;
   end;
finalization
  try
    if assigned(logSnap7_reader_and_writer_block) then
    begin
      logSnap7_reader_and_writer_block.FreeOnTerminate:=true;
      logSnap7_reader_and_writer_block.SignalEnd();
      logSnap7_reader_and_writer_block.Terminate;
    end;
  except
     ;
  end;
   //logTBSXCLient.free;

end.
end.
