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

unit U_dm_import_data_engine;

interface

uses
  System.SysUtils, System.Classes,System.Generics.Collections,strutils,Vcl.StdCtrls;

const tipo_to_ll
    ='@BYTE=1,@BOOL=1,@SINT=1,@USINT=1,@WORD=2,@DWORD=4,@STRING=1,@DATETIME=8,@DT=8,@DATE_AND_TIME=8,@TIME=4,@INT=2,@UINT=2,@DINT=4,@UDINT=4,@REAL=4,@LREAL=8,@LINT=8,@POINTER=8,@REFERENCE=8,@GUID=16,@UXINT=8,@WSTRING=2,@BIT=1,'; //!!la virgola fina ci deve essere

type tPLC_properties=record
    SERVERNAME:string;
    PLCNAME:string;
    DESC:string;
    IP:string;
    RACK:string;
    Slot:string

end;

type TarrayMinMax=packed record
      min:integer;
      max:integer;
      numEle:integer;
end;
type TDataType = record
     DataTypeName:string;
     datatypeDef:tstringlist;
     startigaFileOrig:integer;
end;


type
    TDBS=record // struttura che contiene il risultato del singo db
      nomeDb:string;
      lldb:integer;
      numDb:integer;
      numDati:integer;
      dati:array [0..10000] of record
        level:integer;
        nome:string;
        tipo:string;
        arraylin : TarrayMinMax;
        offset:integer;
        lenEle:integer;
        commento:string;
        posbit:integer;
        lentotale:integer;
      end;
end;

  type tImportaFile_back=record
     xml:string;
     warning:string;
  end;


type
  TDm_import_data_engine = class(TDataModule)
  private
    { Private declarations }
  private
    GlobalXMLOutput: string;
    GlobalMessWarning: string;

  protected
    datatypes:tdictionary<string,tdatatype>;

  procedure importa(ts_s: tstrings;
                                         PLC_properties:tPLC_properties;
                                         memo_xml_out:TMEMO;
                                         Memo_deb:tmemo;
                                         memo_warning:tmemo
                                         );

  procedure ElaboraDb(db:tstringlist;startline:integer;Memo_deb:tmemo;memo_warning:tmemo);
  procedure ElaboraDb2(var dbs:TDBS);
  procedure calcOffset(var dbs:TDBS;index:integer);
  function  creaxml_dataSource(dbs:TDBS):string;

  procedure EspandiType(                              var level:integer;
                                                      tipo: string;
                                                      var dbs: tdbs;
                                                      linenunb: integer);
  procedure caricaDatatype(ty:tstringlist;startline:integer);
  procedure Elabora_dato(                              var level:integer;
                                                       s: string;
                                                       var dbs: tdbs;
                                                       linenunb: integer  );
 function calcolaLLElemento(dbs:TDBS;index:integer):integer;
 procedure Espandixml_dataSource(var xml:string;var dbs: TDBS;index:integer;
                                                 LLMaxNameChar:integer;
                                                 max_lltipoChar:integer;
                                                 max_llOFFChar:integer;
                                                 max_llVsizeChar:integer
                                                 );
  procedure AddNewDs(nomedb:string;Memo_deb:tmemo);

public
    function  importafile(nomefile:string;
                        PLC_properties:tPLC_properties;
                                                      MEMOSOURCE:TMEMO;
                                                      memo_xml_out:TMEMO;
                                                      Memo_debug:TMEMO;
                                                      memo_warning:tmemo):tImportaFile_back;


end;



  var
//  Dm_import_data_engine: TDm_import_data_engine;

  debug:integer;
  function escludeCommentFromString(s:string;linenunb:integer):string;
  function escludeCommentFromStringDoppiaBarra(s:string;linenunb:integer;var commento:string):string;
  function decodeArrayAttributeMINMAX(s:string):TarrayMinMax;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}



function decodeArrayAttributeMINMAX(s:string):TarrayMinMax;
var ilow,ihigh:integer;
   pippo:array[1..1] of integer;
begin
   try
      try
       s:=System.SysUtils.trim(s);
       if s='' then
       begin
         result.min:=0;
         result.max:=0;
         result.numEle:=0;
         exit;
       end;
       s:=copy(s,2,999);
       s:=copy(s,1,length(s)-1);
       ilow :=strtoint(copy(s,1,pos('..',s)-1));
       ihigh:=strtoint(copy(s,pos('..',s)+2));
      except
         on e:exception do
         begin
             raise Exception.Create('parametri ARRAY decode Error '+e.Message);
         end;
      end;
     //  result:=ihigh-ilow+1;
      result.numEle:=ihigh-ilow+1;
      if result.numEle<1 then
          raise Exception.Create('parametri ARRAY LOW-HIGH error');
       result.min:=ilow;
       result.max:=ihigh;
   except
      on e:exception do
      begin
         raise Exception.Create('BSXERROR decodeArrayAttributeMINMAX(<'+s+'>) err:'+e.Message);
      end;
   end;
end;

function calc_LL_from_tipo(tipo:string):integer;
VAR P,pf:integer;
    s:string;
begin
    tipo:=UPPERCASE(TIPO);
    p:=pos('@'+tipo,tipo_to_ll);
    if p=0 then
       raise Exception.Create('tipo<'+tipo+'> non trovato!!');
    p:=p+length('@'+tipo+'=');
    pf:=PosEx(',',tipo_to_ll,p+1);
    s:=copy(tipo_to_ll,p,pf-p);
    result:=strtoint(s);

end;





procedure TDm_import_data_engine.Elabora_dato(var level:integer;
                                                       s: string;
                                                       var dbs: tdbs;
                                                       linenunb: integer  );
var p,pe,pa:integer;
    nomedato:string;
    defTipo:string;
    tipo:string;
    llTipo:integer;
    indicedato:integer;
    arraS:string;
   tminmax: TarrayMinMax;
   comos:string;
   commento:string;
   tipoDatatype:string;
   flagIncrementaLevel:boolean;
begin
//   isrecord:=false;
   tminmax.min:=0;tminmax.numEle:=0;tminmax.max:=0;
   flagIncrementaLevel:=False;
   tipoDatatype:='';
   p:=pos(':',s);
   s:=escludeCommentFromStringDoppiaBarra(s,linenunb,commento);
   if p>0 then
   begin
     nomedato:=trim(copy(s,1,p-1));
     nomedato:= StringReplace(nomedato,'"','',[rfReplaceAll]);
     nomedato:= StringReplace(nomedato,' ','_',[rfReplaceAll]);
     nomedato:= Trim(nomedato);
     defTipo:=uppercase(trim(copy(s,p+1)));

     pa:=pos('ARRAY[',defTipo);
     if pa>0 then
     begin
        arraS:=copy(defTipo,pa+length('ARRAY['),99);
        pe:=pos('] OF',arraS);
        if pe=0 then
          raise Exception.Create('ARRAY DEFINITION ERROR line '+linenunb.tostring+'<'+s+'>');
        arraS:=copy(arraS,1,pe-1);
        try
          tminmax:=decodeArrayAttributeMINMAX('['+trim(arraS)+']');
        except
           on e:exception do
           begin
             raise Exception.Create('ARRAY DEFINITION ERROR line '+linenunb.tostring+'<'+s+'>');
           end;
        end;
        pe:=pos('] OF',defTipo);
        p:= pe+ 4;
     end
     else
        p:=0;
     tipo:=trim(copy(defTipo,p+1));

     if copy(tipo,p,length('STRUCT'))='STRUCT' then
     begin
        tipo:='RECORD';
        flagIncrementaLevel:=True;
     end
     else
     begin
        tipo:=copy(defTipo,p+1);
        tipo:=trim(copy(tipo,1,length(tipo)-1));
     end;
     if tipo<>'RECORD' then
     begin
        try
          if Copy(tipo,1,length('STRING['))='STRING[' then
          begin
              p:=pos(']',tipo);
              if p<>length(tipo)  then
                 raise Exception.Create('STRING[??] ' );
              comos:=copy(tipo,length('STRING[')+1);
              comos:=copy(comos,1,length(comos)-1);
              tipo:='STRING';
              try
                 llTipo:=strtoint(comos);
                 lltipo:=llTipo+2
              except
                 raise Exception.Create(' STRING[??] ');
              end;
          end
          else
          begin
             if (copy(tipo,1,1)='"') or (tipo = 'DTL') then
             begin
//                 espandiType(tipo,Dbx,linenunb);
                tipoDatatype:=tipo;
                tipo:='RECORD';
             end
             else
             begin
                llTipo:=calc_LL_from_tipo(tipo);
             end;
          end;
        except
           on e:exception do
           begin
              raise Exception.Create('TIPO  DEFINITION ERROR line '+linenunb.tostring+' '+e.message+'<'+s+'>');
           end;
        end;
     end;
     indicedato:=dbs.numDati;
     dbs.numDati:=indicedato+1;
     dbs.dati[indicedato].nome:=nomedato;
     dbs.dati[indicedato].tipo:=tipo;
     dbs.dati[indicedato].commento:=commento;
     dbs.dati[indicedato].arraylin:=tminmax;
//     dbs.dati+[indicedato].level:=level;
     if tipo<>'RECORD' then
     begin
        dbs.dati[indicedato].lenEle:=llTipo;
     end
     else
     begin
        dbs.dati[indicedato].lenEle:=-99;
     end;
     dbs.dati[indicedato].arraylin:= tminmax;
     if tipoDatatype<>'' then
     begin
       inc(level);
       if tipoDatatype = 'DTL' then
        tipoDatatype:= '"DTL"';
       EspandiType(level ,tipoDatatype,dbs,linenunb);
       dec(level);
     end;
     dbs.dati[indicedato].level:=level;
   end;
   if flagIncrementaLevel then
      inc(level);

end;


procedure TDm_import_data_engine.AddNewDs(nomedb: string;Memo_deb:tmemo);
begin
  if Memo_deb<>nil then
  begin
     Memo_deb.Lines.Add('      <PLCVAR>');
     Memo_deb.Lines.Add(' 			<DS_'+nomedb+' MODE_LETTURA="MANUAL" TIME_READ_INTERVAL="500" NAME_ON_PLC="3" OFFSET_ON_PLC="0" PLCVAR_VSIZE="523">');
  end;
end;




function   TDm_import_data_engine.importafile(nomefile:string;
                                             PLC_properties:tPLC_properties;
                                                      MEMOSOURCE:TMEMO;
                                                      memo_xml_out:TMEMO;
                                                      Memo_debug:TMEMO;
                                                      memo_warning:tmemo):tImportaFile_back;
var source:tstringlist;
begin
  result.xml:='';
  result.warning:='';

//  ms.Lines.LoadFromFile('C:\Users\Administrator\Downloads\DB\hmi.db') ;
 // if nomefile = '' then
 // begin
//    nomefile:= Edit_DB.Text;
 // end;
  try
    source:=tstringlist.create;
    source.LoadFromFile(nomefile);
    if MEMOSOURCE<>nil then
    begin
       MEMOSOURCE.WordWrap:=False;
       MEMOSOURCE.Lines.Text:=source.Text;
    end;
    importa(source,PLC_properties,memo_xml_out,Memo_debug,memo_warning);
  finally
    source.Free;
  end;

  result.xml:=GlobalXMLOutput;
  result.warning:=GlobalMessWarning;

//
end;

procedure TDm_import_data_engine.ElaboraDb(db: tstringlist;startline:integer;Memo_deb:tmemo;memo_warning:tmemo);
var k:integer;
    s:string;
    s1:string;
    p:integer;
    nomedb:string;
    StartData:boolean;
    levelSTRUCT:integer;
    dbs:TDBS;
    isrecord:boolean;
   comocommento:string;
     s3:string;
     xml:String;
     maxPos:integer;
     DBNum: string;
    s111:string;//debug
     comox:integer;//debug
begin
   dbs.nomeDb:= '';
   dbs.lldb:= 0;
   dbs.numDb:= 0;
   dbs.numDati:= 0;
   for k := Low(dbs.dati) to High(dbs.dati) do
   begin
     dbs.dati[k].level:= 0;
     dbs.dati[k].nome:= '';
     dbs.dati[k].tipo:= '';
     dbs.dati[k].arraylin.min:= 0;
     dbs.dati[k].arraylin.max:= 0;
     dbs.dati[k].arraylin.numEle:= 0;
     dbs.dati[k].offset:= 0;
     dbs.dati[k].lenEle:= 0;
     dbs.dati[k].commento:= '';
     dbs.dati[k].posbit:= 0;
     dbs.dati[k].lentotale:= 0;
   end;
   StartData:=False;
   levelSTRUCT:=0;
   for k:=0 to db.Count-1 do
   begin
     s:=db[k];
     s:=escludeCommentFromString(s,startline+k);
     /// qui mi serve solo per non elaborare il dato se la linea e completamente vuota,
     ///  ma se invece e solo un commento a fine riga elaboro comunque per lasciare la riga completa
     ///   in s!
     s1:=escludeCommentFromStringDoppiaBarra(s,startline+k,comocommento);
     if s1='' then
        continue;
     s:=trim(s);
     if s='' then
        continue;
     if copy(trim(s),1,length('DATA_BLOCK "'))='DATA_BLOCK "' then
     begin
       s:=copy(trim(s),length('DATA_BLOCK "')+1);
       p:=pos('"',s);
       if p=0 then
          raise Exception.Create('Error decode db name on line(manca<"> on line '+inttostr(startline+k));
       nomedb:=copy(s,1,p-1);
       dbs.nomeDb:=nomedb;
       dbs.numDati:=0;
       StartData:=true;
       continue;
     end;
     if StartData then
     begin
       if copy(trim(s),1,length('STRUCT'))='STRUCT' then
       begin
         inc(levelSTRUCT);
         continue;
       end;
       if copy(trim(s),1,length('END_STRUCT;'))='END_STRUCT;' then
       begin
         dec(levelSTRUCT);
         continue;
       end;
       if levelSTRUCT>0 then
       begin
         Elabora_dato(levelSTRUCT,s,dbs,startline+k+1);//,isrecord);
//         if isrecord then
//            inc(levelSTRUCT);
       end
       else
       begin
         //NAME : 'XXX' All'ID utente va assegnato il numero del DB su TIA Portal
         if copy(trim(s),1,length('NAME : '))='NAME : ' then
         begin
           DBNum:= trim(copy(trim(s),7));
           DBNum:= trim(copy(DBNum,2,Length(DBNum)-2));
           try
             dbs.numDb:= StrToInt(DBNum);
           except
             on e:exception do
             begin
               if memo_warning<>nil then
                  memo_warning.Lines.Add('Wrong DB Num from TIA Portal (written in User ID) -> ' + s);
                GlobalMessWarning:=GlobalMessWarning+'Wrong DB Num from TIA Portal (written in User ID) -> ' + s+#10#13;
             end;
           end;
         end;
       end;
     end;
   end;
   if dbs.numDb = 0 then
   begin
      if memo_warning<>nil then
         memo_warning.Lines.Add('No DB Num from TIA Portal (written in User ID) -> ' + nomedb);
      GlobalMessWarning:=GlobalMessWarning+'No DB Num from TIA Portal (written in User ID) -> ' + nomedb+#10#13;

   end;
   ElaboraDb2(dbs);
   calcOffset(dbs,0);
   dbs.lldb:=0;
   for k:=0 to dbs.numDati-1 do
   begin
//     s111:=dbs.dati[k].nome;
//     comoX:=dbs.dati[k].lentotale;
//     comoX:=dbs.dati[k].level;
     if dbs.dati[k].level=1 then
     begin
        maxPos:=dbs.dati[k].offset+dbs.dati[k].lentotale;
        if maxpos>dbs.lldb then
           dbs.lldb:=maxpos;
     end;
   end;
   for k:=0 to dbs.numDati-1 do
   begin
     if (dbs.dati[k].tipo='BOOL') and (dbs.dati[k].arraylin.numEle=0) then
        dbs.dati[k].posbit:=dbs.dati[k].posbit mod 8;
   end;

  xml:=creaxml_dataSource(dbs);
   /// qui ho la struttura completa
   ///

   GlobalXMLOutput:= GlobalXMLOutput + #13#10 + #13#10 + xml;
   if Memo_deb<>nil then
     Memo_deb.Lines.Add('--------------------------------');
 //  mo.Lines.Add(xml);
   for k:=0 to dbs.numDati-1 do
   begin
      s3:='['+dbs.dati[k].level.ToString+']'
        +'offset('+dbs.dati[k].offset.ToString+')'+
                   ' '+ dbs.dati[k].nome;
      if dbs.dati[k].arraylin.numEle>0 then
         s3:=s3+' ar['+dbs.dati[k].arraylin.min.ToString+'..'
                  +dbs.dati[k].arraylin.max.ToString+'] of ';
         s3:=s3+' '+ dbs.dati[k].tipo+
                   ' LL='+ dbs.dati[k].lenEle.ToString;
       //  if dbs.dati[k].arraylin.numEle>0 then
         s3:=s3+' LLT='+ dbs.dati[k].lentotale.ToString;
      if (dbs.dati[k].tipo='BOOL') and (dbs.dati[k].arraylin.numEle=0) then
        s3:=s3+' posbit='+ dbs.dati[k].posbit.ToString   ;
     if Memo_deb<>nil then
        Memo_deb.Lines.Add(s3    );
   end;


end;
function escludeCommentFromStringDoppiaBarra(s:string;linenunb:integer;var commento:string):string;
var p:integer;
    r:string;
begin
 commento:='';
 p:=pos('//',s);
 if p>0 then
 begin
     r:=trim(copy(s,1,p-2));
     commento:=copy(s,p+2);
 end
 else
   r:=s;
 result:=r;
end;

function escludeCommentFromString(s:string;linenunb:integer):string;
var p:integer;
    r:string;
begin
 p:=pos('{',s);
 if p>0 then
 begin
     r:=copy(s,1,p-1);
     s:=copy(s,p+1);
     p:=pos('}',s);
     if p>0 then
       r:=r+copy(s,p+1)
     else
       raise Exception.Create('Comment not terminate on line '+linenunb.tostring);
 end
 else
   r:=s;
 result:=r;
end;

procedure TDm_import_data_engine.importa(ts_s: tstrings;
                                         PLC_properties:tPLC_properties;
                                         memo_xml_out:TMEMO;
                                         Memo_deb:tmemo;
                                         memo_warning:tmemo
                                         );

var s:string;
k:integer;
db:tstringlist;
ty:tstringlist;
flagDentroDb:boolean;
flagDentroType:boolean;
flagEunDbCheMiInteressa:boolean;
dbInElab:string;
value:tdatatype;
v:string;
begin
   v:='''';
   flagDentroDb:=False;
   flagEunDbCheMiinteressa:=False;
   flagDentroType:=false;
   try
     if memo_xml_out<>nil then
        memo_xml_out.Lines.Text:= '';

     if Memo_deb<>nil then
        Memo_deb.Lines.Text:= '';

     if memo_warning<>nil then
        memo_warning.Lines.Text:= '';
     GlobalMessWarning:='';

     GlobalXMLOutput:= '<data_plc_server NAME_SERVER="' + Trim(PLC_properties.SERVERNAME{ Edit_SERVERNAME.Text}) + '">' + #13#10;
     GlobalXMLOutput:= GlobalXMLOutput + '   <' +
                       'PLC NAME_PLC="' + Trim(PLC_properties.PLCNAME {Edit_PLCNAME.Text}) + '" ' +
                       'TYPE_AND_MANUFACTURER="SIEMENS" ' +
                       'DESCRIPTION="' + Trim(PLC_properties.DESC {Edit_DESC.Text}) + '" ' +
                       'BCK_ADR_ADS="" BCK_PORT_ADS="" ' +
                       'SIE_IPADR="' + Trim(PLC_properties.IP {Edit_IP.Text}) + '" ' +
                       'SIE_IPADR_RACK="' + Trim(PLC_properties.RACK {Edit_RACK.Text}) + '" ' +
                       'SIE_IPADR_SLOT="' + Trim(PLC_properties.Slot {Edit_SLOT.Text}) + '"' +
                       '>' + #13#10;
     GlobalXMLOutput:= GlobalXMLOutput + '      <PLCVARS>' +#13#10;
     datatypes:=tdictionary<string,tdatatype>.create;
     db:=tstringlist.create;
     Ty:=tstringlist.create;
     Ty.Add('TYPE "DTL"');
     Ty.Add('VERSION : 0.1');
     Ty.Add('STRUCT');
     Ty.Add('YEAR : UInt;');
     Ty.Add('MONTH : USInt;');
     Ty.Add('DAY : USInt;');
     Ty.Add('WEEKDAY : USInt;');
     Ty.Add('HOUR : USInt;');
     Ty.Add('MINUTE : USInt;');
     Ty.Add('SECOND : USInt;');
     Ty.Add('NANOSECOND : UDInt;');
     Ty.Add('END_STRUCT;');
     Ty.Add('END_TYPE');
     caricaDatatype(ty,1);
     ty.Clear;
     for k:=0 to ts_s.Count-1 do
     begin

        s:=ts_s[k];
        if copy(trim(s),1,length('TYPE "'))='TYPE "' then
        begin
          flagDentroType:=true;
        end;
        if flagDentroType then
        begin
          ty.Add(s);
          if s='END_TYPE' then
          begin
             flagDentroType:=False;
             caricaDatatype(ty,k-db.Count+1);
             ty.Clear;
          end;
        end;
        if copy(trim(s),1,length('DATA_BLOCK "'))='DATA_BLOCK "' then
        begin
           flagDentroDb:=true;
           dbInElab:=s;
        end;
        if flagDentroDb then
        begin
           db.Add(s);
           if trim(s)='{ S7_Optimized_Access := '+v+'FALSE'+v+' }' then
              flagEunDbCheMiInteressa:=true;
          if trim(s)='END_DATA_BLOCK' then
          begin
            if  flagEunDbCheMiinteressa then
            begin
               ElaboraDb(db,k-db.Count+1,Memo_deb,memo_warning);
               db.Clear;
               flagEunDbCheMiinteressa:=False;
            end
            else
            begin
                if memo_warning<>nil then
                  memo_warning.Lines.Add(dbInElab+' db ottimizzato, non considero! ');
                GlobalMessWarning:=dbInElab+' db ottimizzato, non considero! '+#10#13;
            end;
          end;
        end;
     end;
   finally
     db.Free;
     Ty.Free;
     for Value in datatypes.Values do
     begin
       try freeandnil(value.datatypeDef);except;end;
     end;
     datatypes.Clear;
     datatypes.free;

   end;
   GlobalXMLOutput:= GlobalXMLOutput + #13#10 + #13#10 +
                     '      </PLCVARS>' + #13#10 +
                     '   </PLC>' + #13#10 +
                     '</data_plc_server>';
   if memo_xml_out<>nil then
       memo_xml_out.Lines.Text:= GlobalXMLOutput;

end;


procedure TDm_import_data_engine.caricaDatatype(ty:tstringlist;startline:integer);
var k:integer;
    s1,s:string;
    comocommento:string;
    level:integer;
    r:tdatatype;
    ts:tstringlist;
    nomedatatype:string;
    startRiga:integer;
begin
   Startriga:=-1;
   level:=0;
   try
      ts:=tstringlist.Create;
      for k:=0 to ty.Count-1 do
      begin
         s:=ty[k];
         s:=escludeCommentFromString(s,startline+k);
         /// qui mi serve solo per non elaborare il dato se la linea e completamente vuota,
         ///  ma se invece e solo un commento a fine riga elaboro comunque per lasciare la riga completa
         ///   in s!
         s1:=escludeCommentFromStringDoppiaBarra(s,startline+k,comocommento);
         if (s1='')   and (level>0) then
            continue;
         s:=trim(s);
         if (s='')   and (level>0) then
            continue;
         if trim(s)='END_STRUCT;' then
            dec(level);
         if level>0 then
         begin
            if Startriga=-1 then
               Startriga:=k;
            ts.Add(s);
         end;

         if (level=0) and (copy(trim(s),1,length('TYPE "'))='TYPE "') then
         begin
            nomedatatype:=trim(s);
            nomedatatype:=trim(copy(nomedatatype,6));
         end;
         if trim(s)='STRUCT' then
         begin
              inc(level);
         end;

           //TYPE "T_EncoderReset"
           //VERSION : 0.1
           //   STRUCT
           //      cmd : Bool;
           //      Value : Real;
           //   END_STRUCT;
           //END_TYPE
      end;
      if ts.Count>0 then
      begin
         r.datatypeDef:=tstringlist.create;
         r.datatypeDef.Text:=ts.Text;
         r.DataTypeName:=nomedatatype;
         r.startigaFileOrig:=Startriga;
         datatypes.AddOrSetValue(uppercase(nomedatatype),r);
      end;
   finally
      ts.Free;
   end;

end;


procedure TDm_import_data_engine.EspandiType(var level:integer;
                                                      tipo: string;
                                                      var dbs: tdbs;
                                                      linenunb: integer);
var   r:tdatatype;
      k:integer;
      s:string;
      s1:string;
      comocommento:string;
      isrecord:boolean;
begin
   if not datatypes.TryGetValue(uppercase(tipo),r) then
   begin
       raise Exception.Create(tipo+' TIPO NON TROVATO!');
   end;
   for k := 0 to r.datatypeDef.Count-1 do
   begin
     s:=r.datatypeDef[k];
     s:=escludeCommentFromString(s,r.startigaFileOrig+k+1);
     /// qui mi serve solo per non elaborare il dato se la linea e completamente vuota,
     ///  ma se invece e solo un commento a fine riga elaboro comunque per lasciare la riga completa
     ///   in s!
     s1:=escludeCommentFromStringDoppiaBarra(s,r.startigaFileOrig+k+1,comocommento);
     if s1='' then
        continue;
     s:=trim(s);
     if s='' then
        continue;
     Elabora_dato(level,s,dbs,r.startigaFileOrig+k+1);//,isrecord);
   end;


end;


procedure TDm_import_data_engine.ElaboraDb2(var dbs:TDBS);
var k:integer;
    newk:integer;
    maxlevel:integer;
  j: Integer;
  indice_su_cui_calc_ll:integer;
  level:integer;
  s:string;
  llele:integer;
  sdebug:string;
begin
  k:=0;
  while k<(dbs.numDati) do
  begin
    s:=dbs.dati[k].nome+' '+dbs.dati[k].tipo+' '+dbs.dati[k].arraylin.numEle.ToString;
    if s='asa' then
       k:=5;
    if dbs.dati[k].tipo='BOOL' then
    begin
      if dbs.dati[k].arraylin.numEle=0 then
      begin
        dbs.dati[k].posbit:=0;
        newk:=k+1;
        for j := k+1 to dbs.numDati-1 do
        begin
          if dbs.dati[j].nome='ackCnd7'  then
             debug:=1;
          newk:=j;
          if (dbs.dati[j].tipo<>'BOOL') or (dbs.dati[j].level<>dbs.dati[k].level) then
          begin
             break;
          end;
          dbs.dati[j].posbit:=j-k;
        end;
        k:=newk;
      end
      else
      begin
        dbs.dati[k].lenEle:=(dbs.dati[k].arraylin.numEle+7) div 8;
      end;
    end;
    inc(k);
  end;

  maxlevel:=0;
  for k:=0 to dbs.numDati-1 do
  begin
     if maxlevel< dbs.dati[k].level then
        maxlevel:=dbs.dati[k].level;
  end;
  //indice_su_cui_calc_ll:=-99;
  for level:=maxlevel downto 1 do
  begin
    for j:=0 to dbs.numDati-1 do
    begin
       if dbs.dati[j].level=level then
       begin
         sdebug:=dbs.dati[j].nome;
         llele:=calcolaLLElemento(dbs,j);
         if dbs.dati[j].tipo='RECORD' then
         begin
            if (llele mod 2)=1 then
               llele:=llele+1;
         end;
         dbs.dati[j].lenEle:=llele;
         dbs.dati[j].lentotale:=llele;
         if (dbs.dati[j].arraylin.numEle>0)and (dbs.dati[j].tipo<>'BOOL')  then
            dbs.dati[j].lentotale:=dbs.dati[j].lentotale*dbs.dati[j].arraylin.numEle;
         if (dbs.dati[j].arraylin.numEle>0)and (dbs.dati[j].tipo='BOOL')  then
         begin
            dbs.dati[j].lentotale:= (dbs.dati[j].arraylin.numEle+7) div 8
         end;
       end;
    end;
  end;


  ////////////// calcolo offset


end;


function TDm_import_data_engine.calcolaLLElemento(dbs:TDBS;index:integer):integer;
var k:integer;
   ll:integer;
   llele:integer;
   tipo_precedente:string;
   s:string;
   s1:string;
   flagConteggiaLL:boolean;
levelCercato,   levelLetto:integer;
   levelmaster:integer;
begin
// questa func calcola solo ll dei componenti ma solo a un unico livello sotto
    s:=dbs.dati[index].nome+' '+dbs.dati[index].tipo+' array '+dbs.dati[index].arraylin.numEle.ToString+' ll'+dbs.dati[index].lenEle.ToString;
    if s='asa' then
       k:=5;
    if dbs.dati[index].level=1 then
            k:=6;
    if dbs.dati[index].nome='msg' then
            k:=7;
   ll:=0;
   if dbs.dati[index].tipo<>'RECORD' then
   begin
      result:=dbs.dati[index].lenEle;
      exit;
   end;
   levelmaster:=dbs.dati[index].level;
   levelCercato:=levelmaster+1;
   for k := index+1 to dbs.numDati-1 do
   begin
     levelLetto:=dbs.dati[k].level;
     if levelLetto<=levelmaster then
        break;
     if dbs.dati[k].level=levelCercato then
     begin
      s1:=dbs.dati[k].nome+' '+dbs.dati[k].tipo+' array '+dbs.dati[k].arraylin.numEle.ToString+' ll'+dbs.dati[k].lenEle.ToString;
       tipo_precedente:='';
       if k>0 then
          tipo_precedente:=dbs.dati[k-1].tipo;

       llele:=dbs.dati[k].lenEle;
       if dbs.dati[k].tipo='BOOL' then
       begin
          if dbs.dati[k].arraylin.numEle=0 then
          begin
             if (dbs.dati[k].posbit mod 8)=0 then
                 llele:=1
             else
                continue;
          end
          else
          begin
             llele:=(dbs.dati[k].arraylin.numEle+7) div 8;
          end;
       end;
       if (dbs.dati[k].arraylin.numEle>0) and ( dbs.dati[k].tipo<>'BOOL') then
          llele:=llele*dbs.dati[k].arraylin.numEle;


       if (llele=1 ) and (tipo_precedente<>'RECORD') then
       begin
          ll:=ll+llele//dbs.dati[k].lenEle;
       end
       else            //
       begin
          if (ll mod 2 )=1 then
             ll:=ll+1;
          ll:=ll+llele//dbs.dati[k].lenEle;
       end;
     end;

   end;
   result:=ll;

end;

procedure TDm_import_data_engine.calcOffset(var dbs:TDBS;index:integer);
var levelmaster:integer;
    k:integer;
    levelLetto:integer;
    offset:integer;
    byteofbit:integer;
    byteofbit_suc:integer;
   daSommare:boolean;
   s:string;
begin
    offset:=0;
    levelmaster:=dbs.dati[index].level;
    k := index;
    while k<dbs.numDati do
    begin
        s:=dbs.dati[k].nome+' '+dbs.dati[k].tipo+' array '+dbs.dati[k].arraylin.numEle.ToString+' ll'+dbs.dati[k].lenEle.ToString;
        levelLetto:=dbs.dati[k].level;
        if dbs.dati[k].nome='xackCnd9' then
           debug:=1;
        if levelLetto<levelmaster then
           exit;
        if dbs.dati[k].tipo='BOOL' then
        begin
              if dbs.dati[k].arraylin.numEle=0 then
              begin
                 byteofbit:=dbs.dati[k].posbit div 8;
                 dbs.dati[k].offset:=offset+byteofbit;
                 daSommare:=True;
                 if dbs.dati[k+1].level<>levelmaster then
                 begin
                   /// esco dal livello quindi l offset non mi serve piu!
                 end
                 else
                 begin
                    if (dbs.dati[k+1].tipo='BOOL') and (dbs.dati[k+1].arraylin.numEle=0)  then
                    begin
                    end
                    else
                    begin
                       offset:=offset+byteofbit+1;
                    end;
                 end
              end
              else
              begin
                /// se e un array parte comunque da un byte pari
                 if (offset mod 2) = 1 then
                    inc(offset);
                 dbs.dati[k].offset:=offset;
                 offset:=offset+dbs.dati[k].lentotale;
              end;
        end
        else
        begin
           if dbs.dati[k].lentotale <>1 then
           begin
              if (offset mod 2) = 1 then
                inc(offset);
           end;
           dbs.dati[k].offset:=offset;
           offset:=offset+dbs.dati[k].lentotale;
        end;
        if dbs.dati[k].tipo='RECORD' then
        begin
           calcOffset(dbs,k+1);
           while k<dbs.numDati do
           begin
              inc(k);
              levelLetto:=dbs.dati[k].level;
              if levelLetto=levelmaster then
                 break;
           end;
        end
        else
        begin
           k:=k+1;
        end;
    end;

end;

function TDm_import_data_engine.creaxml_dataSource(dbs: TDBS): string;
var r:string;
    spc:string;
    fl:string;
    tab:integer;
    I: Integer;
    MaxLength: Integer;
    LL_letta: Integer;
    lltipo_letta:integer;
    max_lltipo:integer;
    max_llOFF_letto:integer;
    max_llVsize_letto:integer;
    max_llOFF:integer;
    max_llVsize:integer;


begin
    fl:=#10#13;
    tab:=3;
    spc:=stringofchar(' ',tab*3);
    r:=r+spc+'<PLCVAR>'+fl;
    tab:=4;
    spc:=stringofchar(' ',tab*3);
    r:=r+spc+'<DS_'+dbs.nomeDb+' MODE_LETTURA="MANUAL" TIME_READ_INTERVAL="500" NAME_ON_PLC="'+dbs.numDb.ToString+'" OFFSET_ON_PLC="0" PLCVAR_VSIZE="'+dbs.lldb.ToString+'">'+fl;
    tab:=5;
    spc:=stringofchar(' ',tab*3);
    r:=r+spc+'<DEF_VAR_PLC>'+fl;
    MaxLength:= 0;
    max_lltipo:=0;
    LL_letta:= 0;
    max_llOFF:= 0;
    max_llVsize:= 0;
    for I := 0 to dbs.numDati - 1 do
    begin
      LL_letta:= dbs.dati[I].nome.Length +  (dbs.dati[I].level*3);
      if LL_letta > MaxLength then
        MaxLength:= LL_letta;

      lltipo_letta:=dbs.dati[I].tipo.Length;
      if dbs.dati[I].tipo='STRING' then
             lltipo_letta:= length('STRING['+ (dbs.dati[i].lenEle - 2).ToString + ']');
      if lltipo_letta>max_lltipo then
         max_lltipo:=lltipo_letta;

      max_llOFF_letto:=dbs.dati[I].offset.tostring.Length;
      if max_llOFF_letto> max_llOFF then
        max_llOFF:=max_llOFF_letto;


      max_llVsize_letto:=dbs.dati[I].lentotale.tostring.Length;
      if max_llVsize_letto>max_llVsize then
        max_llVsize:= max_llVsize_letto;



    end;


    Espandixml_dataSource(r,dbs,0,MaxLength,max_lltipo,max_llOFF,max_llVsize);
//					   <alm NAME_ON_PLC="alm" TYPE_ON_PLC="BIT" VSIZE="64" VOFF="0" ARRAY="[1..512]"  />
    r:=r+spc+'</DEF_VAR_PLC>'+fl;
    tab:=4;
    spc:=stringofchar(' ',tab*3);
    r:=r+spc+'</DS_'+dbs.nomeDb+'>'+fl;;
    tab:=3;
    spc:=stringofchar(' ',tab*3);
    r:=r+spc+'</PLCVAR>'+fl;

   result:=r;
end;

procedure TDm_import_data_engine.Espandixml_dataSource(var xml:string;var dbs: TDBS;index:integer;
                                                 LLMaxNameChar:integer;
                                                 max_lltipoChar:integer;
                                                 max_llOFFChar:integer;
                                                 max_llVsizeChar:integer
                                                 );
var levelmaster:integer;
    k:integer;
    levelLetto:integer;
    offset:integer;
    byteofbit:integer;
    byteofbit_suc:integer;
   daSommare:boolean;
   s:string;
   fl:string;
    spc:string;
    tab:integer;
    tipo:string;
    varname: string;
    varnameonplc: string;
    LLMaxNameNodo:integer;
    tipodato:string;
    voffset:string;
    vSize:string;
begin
    levelmaster:=dbs.dati[index].level;
    fl:=#10#13;
    spc:=stringofchar(' ',(levelmaster+4)*3);
    k := index;
    while k<dbs.numDati do
    begin
        LLMaxNameNodo:=LLMaxNameChar-(dbs.dati[k].level*3);
        varname:= copy(dbs.dati[k].nome + StringOfChar(' ', LLMaxNameNodo),1,LLMaxNameNodo);
        varnameonplc:= copy(dbs.dati[k].nome + '"' + StringOfChar(' ', LLMaxNameChar + 1),1,LLMaxNameChar + 1);
        voffset:=copy(dbs.dati[k].offset.ToString + '"' + StringOfChar(' ', max_llOFFChar + 1),1,max_llOFFChar + 1);
        vSize:=copy(dbs.dati[k].lentotale.ToString + '"' + StringOfChar(' ', max_llVsizeChar + 1),1,max_llVsizeChar + 1);


        s:=dbs.dati[k].nome+' '+dbs.dati[k].tipo+' array '+dbs.dati[k].arraylin.numEle.ToString+' ll'+dbs.dati[k].lenEle.ToString;
        levelLetto:=dbs.dati[k].level;
        if levelLetto<levelmaster then
           exit;
        if dbs.dati[k].tipo='RECORD' then
        begin
           tipodato:= copy(dbs.dati[k].tipo + '"' + StringOfChar(' ', max_lltipoChar + 1),1,max_lltipoChar + 1);
           xml:=xml+spc+'<'+varname+
               '  NAME_ON_PLC="'+varnameonplc+
               ' TYPE_ON_PLC="'+tipodato+
               ' VOFF="'+voffset+
               ' VSIZE="'+vSize;
           if dbs.dati[k].arraylin.numEle>0  then
           begin
              xml:=xml+' ARRAY="['+ dbs.dati[k].arraylin.min.ToString+'..'+
              dbs.dati[k].arraylin.max.ToString+']"';
           end;
           xml:=xml+' >'+fl;
           Espandixml_dataSource(xml,dbs,k+1,LLMaxNameChar,max_lltipoChar,max_llOFFChar,max_llVsizeChar);
           xml:=xml+spc+'</'+dbs.dati[k].nome+'>'+fl;
           while k<dbs.numDati do
           begin
              inc(k);
              levelLetto:=dbs.dati[k].level;
              if levelLetto=levelmaster then
                 break;
           end;
        end
        else
        begin
           tipo:=dbs.dati[k].tipo;
           if tipo='BOOL' then
                 tipo:='BIT';
           if tipo='STRING' then
                 tipo:= 'STRING['+ (dbs.dati[k].lenEle - 2).ToString + ']';

           tipodato:= copy(tipo + '"' + StringOfChar(' ', max_lltipoChar + 1),1,max_lltipoChar + 1);
           xml:=xml+spc+'<'+varname+
               '  NAME_ON_PLC="'+varnameonplc+
               ' TYPE_ON_PLC="'+tipodato+
               ' VOFF="'+voffset+
               ' VSIZE="'+vSize;
           if dbs.dati[k].arraylin.numEle>0  then
           begin
              xml:=xml+' ARRAY="['+ dbs.dati[k].arraylin.min.ToString+'..'+
              dbs.dati[k].arraylin.max.ToString+']"';
           end;
           if tipo='BIT' then
           begin
              if dbs.dati[k].arraylin.numEle=0 then
                 xml:=xml+' BITPOS="'+ dbs.dati[k].posbit.ToString+'"';
           end;
           xml:=xml+' />'+fl;
           k:=k+1;
        end;
    end;

end;



end.
