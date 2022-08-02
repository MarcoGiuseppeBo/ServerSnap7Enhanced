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

unit U_BSX_mormot_interface;

{$IFDEF FPC}
   {$MODE DELPHI}
   {$DEFINE BOXLAZ}
   {$DEFINE BOXLAZ_ERRORI_DA_RISOLVERE}
   {$DEFINE BOXLAZ_NO_TMESSAGE}
   {$I Synopse.inc} // define HASINLINE CPU32 CPU64 OWNNORMTOUPPER

{$ENDIF}



interface

uses
  {$IFDEF FPC}
//  {$I SynDprUses.inc} // define HASINLINE CPU32 CPU64 OWNNORMTOUPPER
  {$ENDIF}


  SynCommons,mORMot(*,classes*);

const vers_ServerMormotBSXHIGH=1;
const vers_ServerMormotBSXLOW=0;




const
  ROOT_NAME = 'root';
  PORT_NAME = '8181';
  APPLICATION_NAME = 'BSXService';


type TPlcSourceValue=packed record
     PlcSourceName:string;
     xml:string;
     lastdateAgg:tdatetime;
     changed:Boolean;
     val:variant;
     verr:variant;
end;


type TarrayMinMax=packed record
      min:integer;
      max:integer;
      numEle:integer;
end;

type tPathAndIndexArray=packed record
    rpath:string;
    indexArray:integer;    // reurn -1 if no array at level

end;


type tProprietaNodo=packed record

     isArray:boolean;
     xtype:string;
     llGlobal:integer;
     llElement:integer;
     llSTRING:integer;
     Voff:integer;
     Vsize:integer;
     BiTpos:smallint;
     prop_arr : TarrayMinMax;
     fullpath:string;
     level:integer;
     cumulativeOffset:integer;
end;

type TBSX_ENGINE_Error=(BSXE_ALL_OK,
                        BSXE_DM_ERROR_CREATE_BSX_ENGINE,
                        BSXE_DM_GetPlcInfoList,
                        BSXE_dm_GetPlcSourceInfoList_generic,
                        BSXE_dm_GetPlcSourceInfoList_GetPlc,
                        BSXE_dm_getPlcSourceInfoList_getPlcSourceInfoList,
                        BSXE_dm_GetPlcSourceInfoXML,

                        BSXE_DM_GetPlcInfo,


                        BSXE_dm_GetPlcSourceValue_generic,
                        BSXE_dm_GetPlcSourceValue_getPlc,

                        BSXE_dm_putPlcSourceValue_generic,
                        BSXE_dm_putPlcSourceValue_getPlc,
                        BSXE_dm_putPlcSourceValueByPath_generic,
                        BSXE_dm_putPlcSourceValueByPath_getPlc,
                        BSXE_dm_getPlcSource_offset_and_size_ByPath_generic,
                        BSXE_dm_getPlcSource_offset_and_size_ByPath_getPlc,


                        BSXE_dm_Regenerate_xml_of_Path_From_DS_generic,
                        BSXE_dm_Regenerate_xml_of_Path_From_DS_getPlc,


                        BSXE_error3,
                        BSXE_error4,
                        BSXE_error5,

                        BSXE_Plc_error9999,
                        BSXE_Plc_GetPlcSourceInfoList,
                        BSXE_PLC_GetPlcSourceInfoXML,
                        BSXE_PLC_GetPlcSourceValueByName,
                        BSXE_PLC_PutPlcSourceValueByName,

                        BSX_ENGINE_BeckHoff_Definition_generic,
                        BSX_ENGINE_BeckHoff_Definition_plc_not_found,
                        BSX_ENGINE_BeckHoff_Definition_plc_Type_not_found,
                        BSX_ENGINE_BeckHoff_Definition_plc_Var_not_found,

                        BSXE_PLC_GetPlcSource_offset_and_size_ByNameAndPath_generic,

                        BSXE_PLC_Regenerate_xml_of_Path_From_DS,



                        BSXE_Plc_error1,
                        BSXE_Plc_error2,
                        BSXE_Plc_error3,
                        BSXE_Plc_error4,
                        BSXE_Plc_error5,
                        BSXE_Plc_error6,

                        BSXE_PlcSource_getValueSource_generic,
                        BSXE_PlcSource_getValueSource_ReadBufferFromPlcFisico,
                        BSXE_PlcSource_getValueSource_createjsonString,
                        BSXE_PlcSource_getValueSource_To_json,
                        BSXE_PlcSource_putValueSource_generic,
                        BSXE_PlcSource_putValueSource_moveVariantToArrayOfByte,
                        BSXE_PlcSource_putValueSource_writeBuffertoPlcFisico,
                        BSXE_PlcSource_putValueByPahtSource_generic,
                        BSXE_PlcSource_putValueByPahtSource_calcolaOffsetPathAndSize,
                        BSXE_PlcSource_putValueByPahtSource_moveVariantToArrayOfByteByPath,
                        BSXE_PlcSource_putValueByPahtSource_writeBuffertoPlcFisicoWithOffset,
                        BSXE_PlcSource_error2,
                        BSXE_PlcSource_error3,
                        BSXE_PlcSource_error4,
                        BSXE_PlcSource_error5,
                        BSXE_PlcSource_error6,
                        BSXE_PlcSource_Get_offset_and_size_SourceByPath_generic,
                        BSXE_PlcSource_Get_offset_and_size_SourceByPath_calcolaOffsetPathAndSize,

                        BSXE_PlcSource_Regenerate_xml_of_Path_From_DS_generic,
                        BSXE_PlcSource_Regenerate_xml_of_Path_From_DS_calcolaOffsetPathAndSize,


                        BSXE_PlcSource_calcolaOffsetPathAndSize_generic,
                        BSXE_PlcSource_calcolaOffsetPathAndSize_Path_not_found,






                        BSXE_BSXCLient_GetPlcInfo_generic,
                        BSXE_BSXCLient_GetPlcSourceInfoList_generic,
                        BSXE_BSXCLient_GetPlcSourceInfoXML_generic,
                        BSXE_BSXCLient_GetPlcInfoList_generic,
                        BSXE_BSXCLient_GetPlcSourceValue_generic,
                        BSXE_BSXCLient_putPlcSourceValue_generic,
                        BSXE_BSXCLient_putPlcSourceValueByPath_generic,
                        BSXE_BSXCLient_GetPlcSourceValue_In_GetPlcSourceValue_from_server ,
                        BSXE_BSXCLient_GetPlcSourceInfoXML_In_GetPlcSourceValue_from_server,
                        BSXE_BSXCLient_GetBECKHOFFListVarInfo_generic,
                        BSXE_BSXCLient_GetBECKHOFFVarInfo_generic,
                        BSXE_BSXCLient_GetInterface,

                        BSXE_PlcSource_getValueSource_ReadBufferFromPlcFisicoTimeout //AGGIUNTO IL 16/05/2022
                        );

type  TDELPhI_O_FPC=(SERVER_DELPHI,SERVER_FPC);


const
  __TGetVersionServerMormot_back = 'vers_high:integer; vers_low:integer; nameServer:variant;DELPhI_O_FPC:BYTE';
type TGetVersionServerMormot_back= packed record
   vers_high:integer;
   vers_low:integer;
   nameServer:variant;
   DELPhI_O_FPC:TDELPhI_O_FPC;

end;

const
  __TError = 'error BYTE errors string';
type TError=packed record
   error:TBSX_ENGINE_Error; // e un byte
   errors:string;
end;



type  TProtocolKind=(pkBeckhoffADS,pkSiemensS7,pkModbusTCP);

const
  __TPlcInfo = 'NAME_PLC:STRING;'
               +'TYPE_AND_MANUFACTURER:string;'
               +'DESCRIPTION:string;'
               +'BCK_ADR_ADS:string;'
               +'BCK_PORT_ADS:integer;'
               +'SIE_IPADR:string;'
               +'SIE_IPADR_RACK:integer;'
               +'SIE_IPADR_SLOT:integer;'
               +'marcaPlc:BYTE;' //tmarcaplc;'
               +'ALIGN_SIZE_SYSTEM:integer;'
               +'xml:string';

type TPlcInfo= packed record   // deve essere packed per usarlo con RecordLoadJSON/RecordSaveJSON(
     NAME_PLC:STRING; // serve solo come descrittivo
     TYPE_AND_MANUFACTURER:string;
     DESCRIPTION:string;
     BCK_ADR_ADS:string;
     BCK_PORT_ADS:integer;
     SIE_IPADR:string;
     SIE_IPADR_RACK:integer;
     SIE_IPADR_SLOT:integer;
     PLCProtocol:TProtocolKind;
     ALIGN_SIZE_SYSTEM:integer;
     xml:string;
end;


  const
    __TGetPlcInfoList_back = 'error:TError;PlcinfoArr:array of TPlcInfo';
type TGetPlcInfoList_back=packed record // deve essere packed per usarlo con RecordLoadJSON/RecordSaveJSON(
   error:TError;
   PlcinfoArr:array of TPlcInfo;
end;


const
  __TInfoPlcSource =
   'name:string;'
 + 'LLBuf:integer;'
 + 'MODE_LETTURA:string;'
 + 'time_read_interval:integer;'
 + 'NAME_ON_PLC:string;'
 + 'OFFSET_ON_PLC:integer;'
 + 'CHECK_PLC_DEF:Boolean;'
 + 'PLCVAR_VSIZE:integer;'
 + 'XML_checked:Boolean;'
 + 'XML_OK:Boolean;'
 + 'XML_ERROR:string;'
 + 'xml:string;';

type TInfoPlcSource= packed record   // deve essere packed per usarlo con RecordLoadJSON/RecordSaveJSON(
    name:string;
    LLBuf:integer;
    MODE_LETTURA:string;
    time_read_interval:integer;
    NAME_ON_PLC:string;
    OFFSET_ON_PLC:integer;
    CHECK_PLC_DEF:Boolean;
    PLCVAR_VSIZE:integer;
    XML_checked:Boolean;
    XML_OK:Boolean;
    XML_ERROR:string;

    xml:string;
end;

const __TGetPlcInfo_back =
       'error:TError;'
      +'PlcInfo:tplcinfo;';

type TGetPlcInfo_back=packed record
    error:TError;
    PlcInfo:tplcinfo;
end;


const __TGetPlcSourceInfoList_back =
       'error:TError;'
      +'InfoPlcSourceArr:array of TInfoPlcSource';

type TGetPlcSourceInfoList_back=packed record // deve essere packed per usarlo con RecordLoadJSON/RecordSaveJSON(
   error:TError;
   InfoPlcSourceArr:array of TInfoPlcSource;

end;

//ddd
const __TGetPlcSourceInfoXML_back =
       'error:TError;'
      +'Xml:String;';

type TGetPlcSourceInfoXML_back=packed record // deve essere packed per usarlo con RecordLoadJSON/RecordSaveJSON(
   error:TError;
   Xml:String;
end;


  const __TGetPlcSourceValue_back =
       'error:TError;'
      +'value:variant';

type TGetPlcSourceValue_back = packed record
   error:TError;
   value:variant;
end;


const __TputPlcSourceValue_back =
     'error:TError;';

type TputPlcSourceValue_back =packed record
   error:TError;
end;

// not used by server for now!
type TGetPlcSource_offset_and_size_ByNameAndPath_ret =packed record
   offset:integer;
   size:integer;
   error:TError;
end;

// not used by server for now!
type tRegenerate_xml_of_Path_From_DS_back=packed record
   xml:string;
   offset:integer;
   size:integer;
   error:TError;
end;



//type TGetPlcList_back = RawUTF8;

/// dati specifici solo per beckhoff, letti tramite ads
const __TBECKHOFFVarInfo =
     'Name:string;'
    +'Size:integer;'
    +'TypeName:String;'
    +'igroup:Cardinal;'
    +'Ioff:Cardinal;'
    +'arrayType:boolean;'
    +'ArrayLow:integer;'
    +'ArrayHigh:integer;';

type TBECKHOFFVarInfo=packed record
   Name:string;
   Size:integer;
   TypeName:String;
   igroup:Cardinal;
   Ioff:Cardinal;
   arrayType:boolean;
   ArrayLow:integer;
   ArrayHigh:integer;
end;


type TarrayOfBECKHOFFVarInfo= packed array of TBECKHOFFVarInfo;


const __TBECKHOFFListVarInfo_back =
     'error:TError;'
    +'listVar:TarrayOfBECKHOFFVarInfo;';

type TBECKHOFFListVarInfo_back=packed record
     error:TError;
     listVar:TarrayOfBECKHOFFVarInfo;
end;

const __TBECKHOFFVarInfo_back=
    'error:TError;'
   +'info:TBECKHOFFVarInfo;'
   +'InfoTypeXml:string;';

type TBECKHOFFVarInfo_back = packed record
     error:TError;
     info:TBECKHOFFVarInfo;
     InfoTypeXml:string;
end;





type
  IBSX = interface(IInvokable)
    ['{62B137A3-6A8B-4A1F-B579-6341266BA01F}']
    function Add(n1,n2: integer): integer;

    procedure registerClient(const clientname:string);

    function GetVersionServerMormot(Const BSXClientName:string):TGetVersionServerMormot_back;
    function GetVersionServerMormot_LAZ(Const BSXClientName:string):RawUTF8;


 // le funzioni Dm_... usano un unico datamodule e servono per le info richieste da ads al plc al momento dello starup
  function  dm_BECKHOFFListVarInfo(Const BSXClientNameDebug:string;const namePlc:string):TBECKHOFFListVarInfo_back;
  function  dm_BECKHOFFVarInfo(Const BSXClientNameDebug:string;const namePlc:string;const NameVar:string):TBECKHOFFVarInfo_back;


 // ritorna la lista dei plc gestiti

  function  GetPlcInfoList(Const BSXClientName:string):TGetPlcInfoList_back;
  function  GetPlcInfoList_LAZ(Const BSXClientName:string):RawUTF8;


  function  GetPlcInfo(Const BSXClientName:string;const plcName:string):TGetPlcInfo_back;
  function  GetPlcInfo_LAZ(Const BSXClientName:string;const plcName:string):RawUTF8;


  //  ritorna la lista delle datasource definite su un plc
  function  GetPlcSourceInfoList(Const BSXClientName:string;const plcname:string):TGetPlcSourceInfoList_back;
  function  GetPlcSourceInfoList_LAZ(Const BSXClientName:string;const plcname:string):RawUTF8;//TGetPlcSourceInfoList_back;

// ritorna l xml di definizione di un datasource presente sul plc
  function  GetPlcSourceInfoXML(Const BSXClientName:string;const plcName:string;const PlcSourceName:string):TGetPlcSourceInfoXML_back;
  function  GetPlcSourceInfoXML_LAZ(Const BSXClientName:string;const plcName:string;const PlcSourceName:string):RawUTF8;//:TGetPlcSourceInfoXML_back;

// ritorna il valore di un datasource  presente sul plc leggendolo o dal plc fisico o dal buffer
  function GetPlcSourceValue (Const BSXClientName:string;const plcName:string;const PlcSourceName:string; const maxage:integer=0):TGetPlcSourceValue_back;
  function GetPlcSourceValue_LAZ(Const BSXClientName:string;const plcName:string;const PlcSourceName:string;const maxage:integer=0):RawUTF8;//TGetPlcSourceValue_back;

  // Invia  il valore di un datasource  al  plc scrivendolo immediatamente
  function putPlcSourceValue(Const BSXClientName:string;const plcName:string;const PlcSourceName:string;const value:variant):TputPlcSourceValue_back;
  function putPlcSourceValue_LAZ(Const BSXClientName:string;const plcName:string;const PlcSourceName:string;const value:variant):RawUTF8;//TputPlcSourceValue_back;

 // Invia  parte di un datasource  al  plc scrivendolo immediatamente  in base al path
  function putPlcSourceValueByPath(Const BSXClientName:string;const plcName:string;const PlcSourceName:string;const Path:string; const value:variant):TputPlcSourceValue_back;
  function putPlcSourceValueByPath_LAZ(Const BSXClientName:string;const plcName:string;const PlcSourceName:string;const Path:string; const value:variant):RawUTF8;


end;

///// classi per convertire json to record

type TLAZ_CNV_TError=class(Tobject)
   ferror:TBSX_ENGINE_Error;
   ferrors:string;
public
   function getRecord : TError;
published
   property error:TBSX_ENGINE_Error read ferror write ferror ;
   property errors:string read ferrors write ferrors;


end;

type TLAZ_CNV_TgetPlcSourceValue_back = class(Tobject)
   ferror:TLAZ_CNV_TError;
   fvalue:variant;
public
   function getRecord : TgetPlcSourceValue_back;
   constructor Create;
   destructor  destroy;override;
published
   property error:TLAZ_CNV_TError read ferror write ferror ;
   property value:variant read fvalue write fvalue;

end;




var
 Error_All_ok:TError;

function beckhoff_DT_To_DateTime(UnixTime: LongWord): TDateTime;
function beckhoff_DateTime_TO_DT(DelphiTime : TDateTime): LongWord;
function BSX_ErrorNum_to_string(x:TBSX_ENGINE_Error):string;
function BSX_tmarcaplc_to_string(x:TProtocolKind):string;



function Conv_json_to_TGetPlcSourceValue_back(json:RawUTF8):TGetPlcSourceValue_back;
function Conv_json_to_TGetPlcInfo_back(json:RawUTF8):TGetPlcInfo_back;
function Conv_json_to_TGetPlcInfoList_back(json:RawUTF8):TGetPlcInfoList_back;
function Conv_json_to_TputPlcSourceValue_back(json:RawUTF8):TputPlcSourceValue_back;

function Conv_json_to_TGetPlcSourceInfoList_back(json:RawUTF8):TGetPlcSourceInfoList_back;
function Conv_json_to_TGetPlcSourceInfoXML_back(json:RawUTF8):TGetPlcSourceInfoXML_back;

function Conv_json_to_TGetVersionServerMormot_back(json:RawUTF8):TGetVersionServerMormot_back;

implementation


uses
  {$IFDEF FPC}
    SysUtils,
    typinfo,
  {$ELSE}
    System.SysUtils,
  {$ENDIF}
  RTTI;



function beckhoff_DT_To_DateTime(UnixTime: LongWord): TDateTime;
begin
  Result := (UnixTime / 86400) + 25569;
end;

function beckhoff_DateTime_TO_DT(DelphiTime : TDateTime): LongWord;
begin
  Result := Round((DelphiTime - 25569) * 86400);
end;


function BSX_ErrorNum_to_string(x:TBSX_ENGINE_Error):string;
begin
  {$IFDEF FPC}
  result:=GetEnumName(TypeInfo(TBSX_ENGINE_Error), integer(x));

  {$ELSE}
     result := TRttiEnumerationType.GetName(x);

  {$ENDIF}
end;


function BSX_tmarcaplc_to_string(x:TProtocolKind):string;
begin
  {$IFDEF FPC}
  result:=GetEnumName(TypeInfo(tmarcaplc), integer(x));

  {$ELSE}
     result := TRttiEnumerationType.GetName(x);

  {$ENDIF}
end;





//********************************************************************

// funzioni  ritorno lazarus


//*********************************************************************

function Conv_json_to_TGetVersionServerMormot_back(json:RawUTF8):TGetVersionServerMormot_back;
var
   v:variant;


begin
    RecordLoadJSON(result,json,TypeInfo(TGetVersionServerMormot_back));

    (*
    v:=JSONToVariant(json,[]);

    result.vers_high:=v.vers_high;
    result.vers_low:=v.vers_low;
    result.nameServer:=v.nameServer ;
    *)
end;


function Conv_json_to_TGetPlcSourceValue_back(json:RawUTF8):TGetPlcSourceValue_back;
var
   v:variant;
   e:variant;

  r_laz_O:TLAZ_CNV_TgetPlcSourceValue_back;
 //  t:tstringlist;
begin

    RecordLoadJSON(result,json,TypeInfo(TGetPlcSourceValue_back));

 (* try

    r_laz_O:=TLAZ_CNV_TgetPlcSourceValue_back.create;
   //  ObjectLoadJSON(r_laz_O,json,TLAZ_CNV_TgetPlcSourceValue_back,[]);
     result:=r_laz_O.getRecord;
  finally
     freeandnil(r_laz_O);
  end;*)

 (*

    v:=JSONToVariant(json,[]);
    e:=TDocVariantData(v).GetValueOrNull('error');
    result.error.error:=e.error;
    result.error.errors:=e.errors;
    result.value:=TDocVariantData(v).GetValueOrNull('VALUE');
    *)
(*
    t:=tstringlist.Create;
    {$IFDEF FPC}
    t.text:=result.value;
    t.savetofile('C:\aaa\CazzoX1.txt');


    {$ELSE}
    t.text:=recordsavejson(result,TypeInfo(TGetPlcSourceValue_back));
    t.savetofile('C:\aaa\CazzoX.txt');

    {$ENDIF}

    freeandnil(t);
  *)





end;

function Conv_json_to_TputPlcSourceValue_back(json:RawUTF8):TputPlcSourceValue_back;
var
   v:variant;
   e:variant;
begin
    RecordLoadJSON(result,json,TypeInfo(TputPlcSourceValue_back));
(*
    v:=JSONToVariant(json,[]);
    e:=TDocVariantData(v).GetValueOrNull('error');
    result.error.error:=e.error;
    result.error.errors:=e.errors;*)

end;







function Conv_json_to_TGetPlcInfo_back(json:RawUTF8):TGetPlcInfo_back;
var
   v:variant;
   e:variant;

begin

    RecordLoadJSON(result,json,TypeInfo(TGetPlcInfo_back));

   (* v:=JSONToVariant(json,[]);
    e:=TDocVariantData(v).GetValueOrNull('error');
    result.error.error:=e.error;
    result.error.errors:=e.errors;
    e:=TDocVariantData(v).GetValueOrNull('PlcInfo');

      result.PlcInfo.NAME_PLC             :=E.NAME_PLC             ;
      result.PlcInfo.TYPE_AND_MANUFACTURER:=E.TYPE_AND_MANUFACTURER;
      result.PlcInfo.DESCRIPTION          :=E.DESCRIPTION          ;
      result.PlcInfo.BCK_ADR_ADS          :=E.BCK_ADR_ADS          ;
      result.PlcInfo.BCK_PORT_ADS         :=E.BCK_PORT_ADS         ;
      result.PlcInfo.SIE_IPADR            :=E.SIE_IPADR            ;
      result.PlcInfo.SIE_IPADR_RACK       :=E.SIE_IPADR_RACK       ;
      result.PlcInfo.SIE_IPADR_SLOT       :=E.SIE_IPADR_SLOT       ;
      result.PlcInfo.marcaPlc             :=E.marcaPlc             ;
      result.PlcInfo.xml                  :=E.xml                  ;

     *)
end;

function Conv_json_to_TGetPlcSourceInfoList_back(json:RawUTF8):TGetPlcSourceInfoList_back;
var
   v:variant;
   e:variant;
   lista:variant;
   numEle:integer;
   k:integer;
   elem:variant;
begin

          RecordLoadJSON(result,json,TypeInfo(TGetPlcSourceInfoList_back));

(*
    v:=JSONToVariant(json,[]);
    e:=TDocVariantData(v).GetValueOrNull('error');
    result.error.error:=e.error;
    result.error.errors:=e.errors;

    lista:=TDocVariantData(v).GetValueOrNull('InfoPlcSourceArr');
    numEle:=lista._Count;
    setlength(result.InfoPlcSourceArr,numEle);
    for k := 0 to numEle-1 do
    begin
      elem:=TDocVariantData(lista).VALUES[k];
      result.InfoPlcSourceArr[k].name              :=Elem.name              ;
      result.InfoPlcSourceArr[k].LLBuf             :=Elem.LLBuf             ;
      result.InfoPlcSourceArr[k].MODE_LETTURA      :=Elem.MODE_LETTURA      ;
      result.InfoPlcSourceArr[k].time_read_interval:=Elem.time_read_interval;
      result.InfoPlcSourceArr[k].NAME_ON_PLC       :=Elem.NAME_ON_PLC       ;
      result.InfoPlcSourceArr[k].OFFSET_ON_PLC     :=Elem.OFFSET_ON_PLC     ;
      result.InfoPlcSourceArr[k].CHECK_PLC_DEF     :=Elem.CHECK_PLC_DEF     ;
      result.InfoPlcSourceArr[k].PLCVAR_VSIZE      :=Elem.PLCVAR_VSIZE      ;
      result.InfoPlcSourceArr[k].xml               :=Elem.xml               ;
    end;
  *)
end;

function Conv_json_to_TGetPlcSourceInfoXML_back(json:RawUTF8):TGetPlcSourceInfoXML_back;
var
   v:variant;
   e:variant;

begin
    RecordLoadJSON(result,json,TypeInfo(TGetPlcSourceInfoXML_back));
(*
    v:=JSONToVariant(json,[]);
    e:=TDocVariantData(v).GetValueOrNull('error');
    result.error.error:=e.error;
    result.error.errors:=e.errors;
    result.Xml:=v.Xml;*)
end;


function Conv_json_to_TGetPlcInfoList_back(json:RawUTF8):TGetPlcInfoList_back;
var
   v:variant;
   e:variant;
   lista:variant;
   numEle:integer;
   k:integer;
   elem:variant;
begin
    RecordLoadJSON(result,json,TypeInfo(TGetPlcInfoList_back));
(*
   // t:=tstringlist.Create;
   // t.LoadFromFile('C:\aaa\Cazzo.txt');
   // laz_ret:=t.Text;
   // freeandnil(t);

//    v:=_obj(laz_ret);

    v:=JSONToVariant(json,[]);
    e:=TDocVariantData(v).GetValueOrNull('error');
    result.error.error:=e.error;
    result.error.errors:=e.errors;
    lista:=TDocVariantData(v).GetValueOrNull('PlcinfoArr');
    numEle:=lista._Count;
    setlength(result.PlcinfoArr,numEle);
    for k := 0 to numEle-1 do
    begin
      elem:=TDocVariantData(lista).VALUES[k];
      result.PlcinfoArr[k].NAME_PLC             :=Elem.NAME_PLC             ;
      result.PlcinfoArr[k].TYPE_AND_MANUFACTURER:=Elem.TYPE_AND_MANUFACTURER;
      result.PlcinfoArr[k].DESCRIPTION          :=Elem.DESCRIPTION          ;
      result.PlcinfoArr[k].BCK_ADR_ADS          :=Elem.BCK_ADR_ADS          ;
      result.PlcinfoArr[k].BCK_PORT_ADS         :=Elem.BCK_PORT_ADS         ;
      result.PlcinfoArr[k].SIE_IPADR            :=Elem.SIE_IPADR            ;
      result.PlcinfoArr[k].SIE_IPADR_RACK       :=Elem.SIE_IPADR_RACK       ;
      result.PlcinfoArr[k].SIE_IPADR_SLOT       :=Elem.SIE_IPADR_SLOT       ;
      result.PlcinfoArr[k].marcaPlc             :=Elem.marcaPlc             ;
      result.PlcinfoArr[k].xml                  :=Elem.xml                  ;

    end;
    *)
end;







{ TLAZ_CNV_TgetPlcSourceValue_back }

constructor TLAZ_CNV_TgetPlcSourceValue_back.Create;
begin
  inherited;
  ferror:=TLAZ_CNV_TError.Create;
end;

destructor TLAZ_CNV_TgetPlcSourceValue_back.destroy;
begin
  freeandnil(ferror);
  inherited;
end;

function TLAZ_CNV_TgetPlcSourceValue_back.getRecord: TgetPlcSourceValue_back;
begin
   result.error:=ferror.getRecord;
   result.value:=fvalue;

end;



{ TError_Laz }

function TLAZ_CNV_TError.getRecord: TError;
begin
   result.error:=ferror;
   result.errors:=ferrors;

end;



initialization
  // so that we could use directly ICalculator instead of TypeInfo(ICalculator)
    TInterfaceFactory.RegisterInterfaces([TypeInfo(IBSX)]);
    Error_All_ok.error:=BSXE_ALL_OK;
    Error_All_ok.errors:='';

    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TGetVersionServerMormot_back),__TGetVersionServerMormot_back);

    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TError),__TError);

    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TPlcInfo),__TPlcInfo);

    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TGetPlcInfoList_back),__TGetPlcInfoList_back);

    TTextWriter.RegisterCustomJSONSerializerFromText(
       TypeInfo(TInfoPlcSource),__TInfoPlcSource);

    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TGetPlcInfo_back),__TGetPlcInfo_back);

    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TGetPlcSourceInfoList_back),__TGetPlcSourceInfoList_back);



    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TGetPlcSourceInfoXML_back),__TGetPlcSourceInfoXML_back );



    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TGetPlcSourceValue_back), __TGetPlcSourceValue_back);


    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TputPlcSourceValue_back), __TputPlcSourceValue_back);

    TTextWriter.RegisterCustomJSONSerializerFromText(
       TypeInfo(TBECKHOFFVarInfo),__TBECKHOFFVarInfo);



//type TarrayOfBECKHOFFVarInfo= packed array of TBECKHOFFVarInfo;

    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TputPlcSourceValue_back), __TputPlcSourceValue_back);


    TTextWriter.RegisterCustomJSONSerializerFromText(
      TypeInfo(TBECKHOFFVarInfo_back), __TBECKHOFFVarInfo_back);









end.
