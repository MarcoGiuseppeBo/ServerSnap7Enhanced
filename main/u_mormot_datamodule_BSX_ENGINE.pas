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

unit u_mormot_datamodule_BSX_ENGINE;

interface

 {$DEFINE BOX_SNAP7_POOL}

uses
  System.SysUtils, System.Classes,
  Xml.XMLDoc,Xml.XMLIntf,ActiveX,
  Generics.Collections, System.DateUtils,
  dialogs,System.Math,snap7,
  system.StrUtils,
  System.Variants,
  u_mormot_server_read_ini,
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  u_def_Param_db,
  {$ELSE}
  BOX_SCADA_PLC_rid,
  {$ENDIF}




  SynCommons,mormot,U_BSX_mormot_interface,logthread4,
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  U_mormot_datamodule_utils_FAKE,
  {$ELSE}
     U_mormot_datamodule_utils,
  {$ENDIF}

//  U_mormot_Datamodule_BSX_ENGINE_BeckHoff_Definition,


  U_mormot_messager_utils,
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  U_Snap7_reader_and_writer_block_FAKE,
  {$ELSE}
  U_Snap7_reader_and_writer_block,
  {$ENDIF}




  U_tarrayofbyte,

{$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
{$ELSE}

   {$IFDEF BOX_SNAP7_POOL}
    U_Snap7PoolEngine,

    {$ELSE}
   {$ENDIF}
{$ENDIF}

{$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
{$ELSE}
    u_EngineBufferCache,
{$ENDIF}

  mormotSCADAUtils,
  Winapi.Windows,
  WinSvc;

// {$DEFINE BOXDEBUG}

//    {$IFDEF DEBUG}
//    Writeln('Debug is on.');  // This code executes.
//    {$ELSE}
//    Writeln('Debug is off.');  // This code does not execute.
//    {$ENDIF}
//    {$UNDEF DEBUG}
//    {$IFNDEF DEBUG}
//    Writeln('Debug is off.');  // This code executes.
//    {$ENDIF}

//const tipo_to_ll_beckhoff
//    ='@BYTE=1,@BOOL=1,@SINT=1,@USINT=1,@WORD=2,@DWORD=4,@STRING=1,@DATETIME=4,@TIME=4,@INT=2,@UINT=2,@DINT=4,@UDINT=4,@REAL=4,@LREAL=8,@POINTER=8,@REFERENCE=8,'; // la virgola finale ci deve essere!
  type TDATI_BIT_SINGOLO=record
       FLAGBIT_SINGOLO:boolean;
       bitpos:integer;
       Byte_of_bit:integer;
  end;
  type ToffsetAndSize=record
       offset:integer;
       size:integer;
       nodo:IXMLNode;
       DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;
       AllArrayPath:boolean;
       Error:terror;
  end;

type tcalcolaFullPathOfNode_ret=record
     fullPaht:string;
     cumulativeOffset:integer;
end;

(*
type toffset_and_indexArray=record
     cumulativeOffset:integer;
     indexArray:integer;
     sizeElem:integer;
end;
  *)




type tPlcSource=class(tcomponent)
  strict private
    sema_Self:TSynLocker;
    namePlc:string;// contiene il nome del plc del parent
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  {$ELSE}
    boxvar:TboxvarRid;
  {$ENDIF}

    RootVarPlc_node:IXMLNode;
    root_defVar:IXMLNode;
    XmlTypeFromPlcFisico:TXMLDocument; // contiene  xml letto dal plc fisico tramite ads
//    VarInfoFromPlcFisico:tAdrVarEle;   // contiene igroup,ioff, size  letti dal plc fisico  tramite ads
    Linfoplc:tplcInfo;
{$IFDEF BOX_SNAP7_POOL}
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
    Lsnap7client:TS7Client;
  {$ELSE}
    Lsnap7client:TBoxS7Client;
 {$ENDIF}
{$ELSE}
    Lsnap7client:TS7Client;
{$ENDIF}

    //f_llvar:integer;

///
///   da aggiungere per gestire lettura automatico
///
//    fbuffer:tarrayofbyte;
//    fdata:TDocVariant;

{$IFDEF BOXDEBUG}
    fbufferCopia_test:tarrayofbyte; // solo per debug
{$ENDIF}
    fInfo:TInfoPlcSource;
//    FMODE_LETTURA:string;
//    FTIME_READ_INTERVAL:integer;
//    FNAME_ON_PLC:string;
//    FOFFSET_ON_PLC:integer;
    function decodeArrayAttributeMINMAX(s:string):TarrayMinMax;
    function decodeArrayAttribute(s:string):integer;
    function DecodellString(s:string):integer;
    function DecodellWideString(s:string):integer;

    function decodebuffToStringjsonFormat(buf:tarrayofbyte):string;
    function decodebuffToWIDEStringjsonFormat(buf:tarrayofbyte):widestring;
    type DatoToJstring_back=record
        value:string;
        newoff:integer;
    end;

    function DatoToJstring(const np:tProprietaNodo;           /// func supporto conversione parte buffer in stringa * json string!
                           const bufferData:tarrayOfByte;
                           const offset:integer): DatoToJstring_back;

    function createjsonString1(node:IXMLNode;var offsetBuffer:integer;const bufferData:tarrayOfByte):string;
    function createjsonString2(node:IXMLNode;const offsetBuffer_iniziale:integer;const bufferData:tarrayOfByte):string;
    function pathWithoutArray(const path:string):string;
    procedure WriteBufferFromVariant(v:variant;
                                     node:IXMLNode;
                                     var offsetBuffer:integer;
                                     var DataBuf:tarrayofbyte;
                                     offsetVett:integer;
                                     const StartNode:IXMLNode);
    procedure WriteBufferFromVariantByPath(v:variant;node:IXMLNode;var offsetBuffer:integer;var DataBuf:tarrayofbyte;var DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;AllArrayPath:boolean);
    procedure  debugcaricabuffer;
    function  ReadBufferFromPlcFisico(const maxage:integer):tarrayofbyte;
    procedure  WriteBufferToPlcFisico(value:tarrayofbyte;offset:integer);
    procedure WriteBufferToPlcFisicoWithOffset(value:tarrayofbyte;offset:integer;DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO);
    procedure  lock_self;
    procedure  unlock_self;
    procedure test_variant_to_buffer;
    function calcola_ll_variabile(nodo:IXMLNode):integer;
//    function move_buffer_to_DocVariant:TDocVariant;
    function createjsonString(const bufferData:tarrayOfByte):string;
    function moveVariantToArrayOfByte(const v:variant;
                                      const startnode:ixmlnode;
                                      const llbuffer:integer):tarrayOfbyte;
    function moveVariantToArrayOfByteByPath(const v:variant;
                                      const startnode:ixmlnode;
                                      const llbuffer:integer;Var DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;
                                      AllArrayPath:boolean):tarrayOfbyte;
    function getProprietaNodo(nodo:IXMLNode):tProprietaNodo;
    function moveSingleDatoVariantToBuffer(const v:variant;
                                       const np:tProprietaNodo;
                                            bufferDEst:tarrayofbyte;
                                       const offsetBuf:integer
                                       ):integer;

    function extractPathAtLevelAnndIndexArray(const path:string; const level:integer):tPathAndIndexArray;
    function calcolaOffsetPathAndSize(const path:string):ToffsetAndSize;
    function calcolaOffsetPathAndSize1(const startoffset:integer;
                                       const path:string;
                                       const pathStop:string;
                                       const startnode:IXMLNode;
                                       const level:integer;
                                       var returnNode:IXMLNode;
                                       var returnsize:integer):integer;
    function calcolaOffsetPathAndSizeNew(const XpathSearched:string;const startnode:IXMLNode;
                                              var returnNode:IXMLNode;
                                              var returnsize:integer;
                                              var dati_bit_Singolo:Tdati_bit_Singolo;
                                              var returnAllArrayPath:boolean;
                                              var Error:terror):integer;

    function calcolaFullPathOfNode(node:IXMLNode):tcalcolaFullPathOfNode_ret;
    function calcolaRelativeOffsetOfNode(node: IXMLNode; Relativemainnode:IXMLNode):integer;
    function debug_buffer(const des_debug:string; const bufferData:tarrayOfByte):string; // crea buffer di debug per log
    function Check_xml_0(nodesup:IXMLNode):integer;
  protected
     procedure writelogDebug(const s:String);
     procedure writelog(const s:String);
     procedure writelogerr(const s:String);
     constructor create(aowner:tcomponent;
                        xfinfoplc:tplcInfo ;
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  {$ELSE}
                        plc:TboxPlcrid;
  {$ENDIF}
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
                        xsnap7client:TS7Client;
  {$ELSE}
     {$IFDEF BOX_SNAP7_POOL}
                        xsnap7client:TBoxS7Client;
     {$ELSE}
                        xsnap7client:TS7Client;
     {$ENDIF}
  {$ENDIF}
                        xRootVarPlc_node:IXMLNode;
                        const xnamePlc:string);

     Destructor  Destroy;override;
     procedure Check_xml;

     function getValueSource(const maxage:integer):tgetPlcSourceValue_back;
     function PutValueSource(const value:variant):tputPlcSourceValue_back;
     function PutValueSourceByPath(const path:string; const value:variant):tputPlcSourceValue_back;

     function Get_offset_and_size_SourceByPath(const path: string): TGetPlcSource_offset_and_size_ByNameAndPath_ret;


/// usato solo dal programma di importazione
     function Regenerate_xml_of_Path_From_DS(const path: string;
                                            const newSourceName:string): tRegenerate_xml_of_Path_From_DS_back;


     property Info:TInfoPlcSource read finfo;

end;


type tPlc=class(TComponent)
  strict private

  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  {$ELSE}
     fplcFisico:TboxPlcBeckHoff_rid;
  {$ENDIF}

  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
        fSnap7Client:TS7Client;
  {$ELSE}
    {$IFDEF BOX_SNAP7_POOL}
        fSnap7Client:TBoxS7Client;
    {$ELSE}
        fSnap7Client:TS7Client;
    {$ENDIF}
  {$ENDIF}

     fPlcSourceList:TDictionary<string,tPlcSource>;
     fsema_PlcSourceList:TSynLocker;
     fRootPlc_Node:IXMLNode;
     // dati da xml

     finfo:tplcInfo;
     fLoadError:string;

     procedure lock_PlcSourceList;
     procedure unlock_PlcSourceList;
     function GetPlcSourceByName(const xSourceName:string):tPlcSource;
  private
    function putSourceValueByName(const xSourceName: string;
      const value: variant): tputPlcSourceValue_back;

   public
      procedure writelog(const s:String);
      procedure writelogerr(const s:String);
      constructor Create(aowner:tcomponent;xRootPlc_Node : IXMLNode);
      Destructor  Destroy;override;
//      function  GetPlcInfo(Const BSXClientName:string;const plcName:string):TGetPlcInfo_back;
      function getPlcSourceInfoList:TGetPlcSourceInfoList_back;
      function GetPlcSourceInfoXML(const SourceName:string):TGetPlcSourceInfoXML_back;
      function GetPlcSourceValueByName(const xSourceName: string;const maxage:integer):tgetPlcSourceValue_back;
      function PutPlcSourceValueByName(const xSourceName: string;const value:variant):tputPlcSourceValue_back;
      function PutPlcSourceValueByNameAndPath(const xSourceName: string;const path:string; const value:variant):tputPlcSourceValue_back;


//////  non usata dal server ma solo per l import dei file beckhoff
      function GetPlcSource_offset_and_size_ByNameAndPath(const xSourceName: string;const path:string):TGetPlcSource_offset_and_size_ByNameAndPath_ret;

////// non usata dal server ma solo per l import dei file beckhoff
      function Regenerate_xml_of_Path_From_DS(const xSourceName: string;
                                              const path:string;
                                              const newSourceName:string
                                              ):tRegenerate_xml_of_Path_From_DS_back;

      function IsServiceRun(const checkservices:string):boolean;

      property info:tplcInfo read finfo;
      property LoadError:string read fLoadError;

end;

type
  TDm_BSX_ENGINE = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
     flagFromPrgImport:boolean;
     FileXmlFromImport:string;
     GdataPlcXMLDocument:TXMLDocument;
     listaPlc:tlist<tPlc>;
     sema_listaPlc:TSynLocker;
      fNAME_SERVER:string;
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
     GfileXml:string; /// serve per SNAP_ENHANCED
      paramDb:TparamDb;
  {$ELSE}
  {$ENDIF}


  protected
      procedure lock_listaPlc;
      procedure unlock_listaPlc;
      function getPlc(const xname:string):tplc;
      procedure writelog(const s:String);
      procedure writelogerr(const s:String);
  public
     LOG_CHIAMATE:boolean;
     ErrorDatamodule_engine:String;
//     constructor Create(AOwner: TComponent;
//     XflagFromPrgImport: boolean; xFileXmlFromImport: string);override;

     constructor Create(AOwner: TComponent;XflagFromPrgImport:boolean;xFileXmlFromImport:string);
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
        overload;
     constructor Create(AOwner: TComponent;const xfileXml:string);overload;
  {$ELSE}
  {$ENDIF}

     destructor destroy;override;

      property NAME_SERVER:string read fNAME_SERVER;


//  ritorna la informazioni su un plc e su un plc
  function  dm_GetPlcInfo(Const BSXClientNameDebug:string;const plcname:string):TGetPlcInfo_back;
  // ritorna la lista dei plc gestiti
  function  dm_GetPlcInfoList(Const BSXClientNameDebug:string):TGetPlcInfoList_back;
  //  ritorna la lista delle datasource definite su un plc
  function  dm_GetPlcSourceInfoList(Const BSXClientNameDebug:string;const plcname:string):TGetPlcSourceInfoList_back;
// ritorna l xml di definizione di un datasource presente sul plc
  function  dm_GetPlcSourceInfoXML(Const BSXClientNameDebug:string;const plcName:string;const PlcSourceName:string):TGetPlcSourceInfoXML_back;
// ritorna il valore di un datasource  presente sul plc leggendolo o dal plc fisico o dal buffer
  function dm_GetPlcSourceValue(Const BSXClientNameDebug:string;const plcName:string;const PlcSourceName:string;const maxage:integer):TgetPlcSourceValue_back;
// Invia  il valore di un datasource  al  plc scrivendolo immediatamente
  function dm_putPlcSourceValue(Const BSXClientNameDebug:string;const plcName:string;const PlcSourceName:string;const value:variant):TputPlcSourceValue_back;
// Invia  parte di un datasource  al  plc scrivendolo immediatamente  in base al path
  function dm_putPlcSourceValueByPath(Const BSXClientNameDebug:string;const plcName:string;const PlcSourceName:string;const Path:string; const value:variant):TputPlcSourceValue_back;



// not used by server for now! usata dal prg di import beckhoff
  function dm_getPlcSource_offset_and_size_ByPath(Const BSXClientNameDebug:string;const plcName:string;const PlcSourceName:string;const Path:string):TGetPlcSource_offset_and_size_ByNameAndPath_ret;
// not used by server for now! usata dal prg di import beckhoff
  function dm_Regenerate_xml_of_Path_From_DS(Const BSXClientNameDebug:string;
                                             const plcName:string;
                                             const PlcSourceName:string;
                                             const Path:string;
                                             const newSourceName:string):tRegenerate_xml_of_Path_From_DS_back;




end;
var
 // Dm_BSX_ENGINE: TDm_BSX_ENGINE;
  dummydebug:integer;
  dummyxxx: integer;
  dummydebug2:ToffsetAndSize;
  debug_aaa:integer;
  logDm_BSX_ENGINE:TLogThread4;

function ServiceRunning(sMachine, sService: PChar): Boolean;

implementation
{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function calc_LL_from_tipo_plc(tipo:string;const tipoplc:TProtocolKind):integer;
VAR P,pf:integer;
    s:string;
begin
    tipo:=UPPERCASE(TIPO);
    if tipoplc = TProtocolKind.pkBeckhoffADS then
    begin
      p:=pos('@'+tipo,tipo_to_ll_beckhoff);
    end
    else
    begin
      p:=pos('@'+tipo,tipo_to_ll_siemens);
    end;
    if p=0 then
       raise Exception.Create('tipo<'+tipo+'> non trovato!!');
    p:=p+length('@'+tipo+'=');
    pf:=system.StrUtils.PosEx(',',tipo_to_ll_beckhoff,p+1);
    s:=copy(tipo_to_ll_beckhoff,p,pf-p);
    result:=strtoint(s);

end;

procedure  String_to_stringBuffer_BK(s:string;var buffer:array of byte);
  var
      k:integer;
begin
    for k:=0 to high(buffer) do
        buffer[k]:=0;
    for k:=1 to length(s) do
    begin
       if k<=high(buffer) then
          buffer[k-1]:=byte(s[k]);
    end ;
end;
procedure  String_to_WidestringBuffer_BK(s:Widestring;var buffer:array of byte);
  var
      k:integer;
    x:array of word;
    wc:widechar;
    w:word;
    llinword:integer;
begin
    for k:=0 to high(buffer) do
        buffer[k]:=0;
    llinword:=length(buffer) div 2;
    setlength(x,llinword);
    for k:=0 to high(x) do
        x[k]:=0;

    for k:=1 to length(s) do
    begin
       wc:=s[k];
       move(wc,w,2);
       if k<=high(x) then
          x[k-1]:=w;
    end ;
    move (x[0],buffer[0],length(buffer));
end;



function tPlc.getPlcSourceInfoList:TGetPlcSourceInfoList_back;
var i:integer;
//    x:TPlcSourceInfoList_back;
  tmpPar:tPlcSource;
begin
   result.error:=Error_All_ok;
   try
      self.lock_PlcSourceList;
      try
         setlength(result.InfoPlcSourceArr,fPlcSourceList.count);
         i:=0;
         for tmpPar in self.fPlcSourceList.Values do
         begin
            Result.InfoPlcSourceArr[i]:=tmpPar.Info;
(*            Result.InfoPlcSourceArr[i].LLBuf:=tmpPar.Info.LLBuf;
            Result.InfoPlcSourceArr[i].MODE_LETTURA:=tmpPar.Info.MODE_LETTURA;
            Result.InfoPlcSourceArr[i].time_read_interval:=tmpPar.Info.time_read_interval;
            Result.InfoPlcSourceArr[i].NAME_ON_PLC:=tmpPar.Info.NAME_ON_PLC;
            Result.InfoPlcSourceArr[i].OFFSET_ON_PLC:=tmpPar.Info.OFFSET_ON_PLC;
            Result.InfoPlcSourceArr[i].CHECK_PLC_DEF:=tmpPar.Info.CHECK_PLC_DEF;
            Result.InfoPlcSourceArr[i].xml:=tmpPar.Info.xml;*)
            inc(i);
         end;
      finally
         self.unlock_PlcSourceList;
      end;
   except
      on  e:exception do
      begin
         Result.error.error:=BSXE_Plc_GetPlcSourceInfoList;
         Result.error.errors:='tPlc.getListaSourceOfPlcInfo '+e.Message;
         if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr(Result.error.errors);
      end;
   end;

end;

function tPlc.GetPlcSourceInfoXML(const SourceName: string): TGetPlcSourceInfoXML_back;
var i:integer;
    s:String;
   xPlcSource:tPlcSource;
begin
   result.error:=Error_All_ok;
   result.Xml:='';
   s:=UpperCase(SourceName);
   try
//      self.lock_PlcSourceList;   // lo fa gia GetPlcSourceByName!!!
//      try
         xPlcSource:=GetPlcSourceByName(SourceName);
         result.Xml:=xPlcSource.Info.xml;
//      finally
//         self.unlock_PlcSourceList;
//      end;
   except
      on  e:exception do
      begin
         Result.error.error:=BSXE_PLC_GetPlcSourceInfoXML;
         Result.error.errors:='tPlc.GetXmlVarNameInfo(<'+ SourceName+'>) '+e.Message;
         if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr(Result.error.errors);
      end;
   end;
end;


function tPlc.GetPlcSourceValueByName(const xSourceName: string;const maxage:integer):tgetPlcSourceValue_back;
var
    fase,func:string;
    XPlcSource:tPlcSource;
    s:string;
    comoOff:integer;
    errnum:TBSX_ENGINE_Error;
begin
   try
      result.value:=null;
      result.error:=Error_All_ok;
      func:='tPlc.GetPlcSourceValueByName(<'+xSourceName+'>)';
      fase:='GetPlcSourceByName(<'+xSourceName+'>);';
      XPlcSource:=GetPlcSourceByName(xSourceName); /// solleva eccezzione!!
      fase:='<'+xSourceName+'>.getValueSource';
      result:=XPlcSource.getValueSource(maxage);
   except
     on e:exception do
     begin
        Result.error.error:=BSXE_PLC_GetPlcSourceValueByName;
        Result.error.errors:=func+' '+fase+' '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(Result.error.errors);
     end;
   end;
end;


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////
/////           Dm_BSX_ENGINE   protected
/////
/////////////////////////////////////////////////////////////////////////////
procedure TDm_BSX_ENGINE.lock_listaPlc;
 begin
    sema_listaPlc.Lock;
 end;

 procedure TDm_BSX_ENGINE.unlock_listaPlc;
 begin
    sema_listaPlc.UnLock;
 end;

function TDm_BSX_ENGINE.getPlc(const xname:string):tplc;
var k:integer;
    s:string;
begin
   s:=uppercase(xname);
   result:=nil;
   self.lock_listaPlc;
   try
      for k := 0 to listaPlc.Count-1 do
      begin
         if listaPlc[k].info.NAME_PLC=xName then
         begin
            result:=listaPlc[k];
            break;
         end;
      end;
   finally
      unlock_listaPlc;
   end;
end;

procedure TDm_BSX_ENGINE.writelog(const s:String);
begin
    if logDm_BSX_ENGINE<>nil then
    try
       logDm_BSX_ENGINE.DoLogMess('-ENGINE['+self.fNAME_SERVER+']'+s);
    except
      ;
    end;
end;
procedure TDm_BSX_ENGINE.writelogerr(const s:String);
begin
    if logDm_BSX_ENGINE<>nil then
       logDm_BSX_ENGINE.DoLogMessErr('-ENGINE['+self.fNAME_SERVER+']'+s);
end;

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////
/////           Dm_BSX_ENGINE   public
/////
/////////////////////////////////////////////////////////////////////////////

destructor TDm_BSX_ENGINE.destroy;
begin
  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
     writelog('TDm_BSX_ENGINE.destroy 1');
  inherited;
  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
     writelog('TDm_BSX_ENGINE.destroy 99');
end;
function TDm_BSX_ENGINE.dm_GetPlcInfo(const BSXClientNameDebug,
  plcname: string): TGetPlcInfo_back;
var k:integer;
   fase,func:string;
   xplc :tplc;
begin
   result.error := Error_All_ok;
   func := 'dm_GetPlcInfo(BSXClient<' + BSXClientNameDebug + '>)';
   fase := 'lock_listaPlc';
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
         writelog(func);
   try
      result.error.error:=BSXE_DM_GetPlcInfo;
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      result.PlcInfo:=xplc.info;
      result.error:=Error_All_ok;
   except
     on e:exception do
     begin
//        Result.error.error:=integer(BSXE_error2);
        Result.error.errors:=func+' '+fase+' '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogErr(Result.error.errors);
     end;
   end;
end;


function TDm_BSX_ENGINE.dm_GetPlcInfoList(Const BSXClientNameDebug:string):TGetPlcInfoList_back;
var k:integer;
//   ListaPlcInfo:TPlcInfoList_back;
   fase,func:string;
begin
   result.error := Error_All_ok;
   func := 'dm_GetPlcInfoList(BSXClient<' + BSXClientNameDebug + '>)';
   fase := 'lock_listaPlc';
   if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
      if LOG_CHIAMATE then
          writelog(func);
   lock_listaPlc;
   try
      try
         fase := 'READ listaPlc';
         setlength(result.PlcinfoArr, listaPlc.count);
         for k := 0 to listaPlc.count - 1 do
         begin
            result.PlcinfoArr[k] := self.listaPlc[k].Info
         end;
      except
         on e: Exception do
         begin
            result.error.error := BSXE_dm_GetPlcInfoList;
            result.error.errors := func + ' ' + fase + ' err:[' + integer(result.error.error).ToString + '] ' + e.Message;
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               writelogerr(result.error.errors);
         end;
      end;
   finally
      unlock_listaPlc;
   end;
end;

function TDm_BSX_ENGINE.dm_GetPlcSourceInfoList(Const BSXClientNameDebug:string;const plcname:string):TGetPlcSourceInfoList_back;
var k:integer;
    j:integer;
    trovato:boolean;
    varplcx:tPlcSource;
    xplc:tplc;
    s:string;
    comoOff:integer;
    fase,func:string;
//                            BSXE_dm_GetPlcSourceInfoList_generic,
//                        BSXE_dm_GetPlcSourceInfoList_GetPlc,
//                        BSXE_dm_getPlcSourceInfoList_getPlcSourceInfoList,
begin
   func:='dm_GetPlcSourceInfoList(<'+BSXClientNameDebug+'>,<'+plcname+'>)';
   fase:='getplc(<'+plcname+'>)';
   result.error := Error_All_ok;
   result.error.error:=BSXE_dm_GetPlcSourceInfoList_generic;
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
         writelog(func);
   try
      result.error.error:=BSXE_dm_GetPlcSourceInfoList_GetPlc;
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      fase:='xplc.getPlcSourceInfoList';
      result.error.error:=BSXE_dm_getPlcSourceInfoList_getPlcSourceInfoList; // non verra mai fuori., siccome la fun dopo non da eccezzioni!
      result:=xplc.getPlcSourceInfoList;     /// non da eccezzioni ma rende result con errore
      if result.error.error<>BSXE_ALL_OK then
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr(func+' '+fase+' '+result.error.errors);
   except
     on e:exception do
     begin
//        Result.error.error:=integer(BSXE_error2);
        Result.error.errors:=func+' '+fase+' '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogERR(Result.error.errors);
     end;
   end;
end;

function TDm_BSX_ENGINE.dm_GetPlcSourceInfoXML(Const BSXClientNameDebug:string;
                                               const plcName,
                                               PlcSourceName: string): TGetPlcSourceInfoXML_back;
var k:integer;
    j:integer;
    trovato:boolean;
    varplcx:tPlcSource;
    xplc:tplc;
    s:string;
    comoOff:integer;
    fase,func:string;
    errnum:TBSX_ENGINE_Error;
begin
   func:='dm_GetPlcSourceInfoXML(<'+BSXClientNameDebug+'>,<'+plcname+'>,<'+PlcSourceName+'>)';
   fase:='getplc(<'+plcname+'>)';
   result.error:=Error_All_ok;
   result.error.error:=BSXE_dm_GetPlcSourceInfoXML;
   errnum:=BSXE_dm_GetPlcSourceInfoXML;
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
         writelog(func);
   try
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      fase:='xplc.GetPlcSourceInfoXML(<'+PlcSourceName+'>)';
      result:=xplc.GetPlcSourceInfoXML(PlcSourceName);
      if result.error.error<>BSXE_ALL_OK then
         if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogERR(func+' '+fase+' '+Result.error.errors);
   //   result.error.error:=0;   // vengono impostati da GetXmlVarNameInfo(varname);!!!!
   //   result.error.errors:='';
   except
     on e:exception do
     begin
        Result.error.errors:=func+' '+fase+' err:['+integer(errnum).ToString+ '] '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogERR(Result.error.errors);
     end;
   end;
end;

function TDm_BSX_ENGINE.dm_GetPlcSourceValue(
                              Const BSXClientNameDebug:string;
                              const plcName:string;const PlcSourceName:string;const maxage:integer):TgetPlcSourceValue_back;
var k:integer;
    j:integer;
    trovato:boolean;
    XPlcSource:tPlcSource;
    xplc:tplc;
    s:string;
    comoOff:integer;
    fase,func:string;
begin
   func:='dm_GetPlcSourceValue(<'+BSXClientNameDebug+'><'+plcName+'>,<'+PlcSourceName+'>)';
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
          writelog(func);
   result.error:=Error_All_ok;
   result.error.error:=BSXE_dm_GetPlcSourceValue_generic;

   try
      fase:='getplc(<'+plcName+'>)';
      result.error.error:=BSXE_dm_GetPlcSourceValue_getPlc;
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      fase:=xplc.info.NAME_PLC+'GetPlcSourceValueByName('+plcName+'>)';
      result:=xplc.GetPlcSourceValueByName(PlcSourceName,maxage);  /// non fa eccezzioni ma ritorna errore in result! !
      if result.error.error<>BSXE_ALL_OK then
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(func+' '+fase+' '+Result.error.errors);

   except
     on e:exception do
     begin
        result.value:=null;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(func+' '+fase+' '+e.Message);
        result.error.errors:=func+' '+fase+' '+e.Message;
//        result.error.error:= gia settato prima!
     end;
   end;
end;

function TDm_BSX_ENGINE.dm_putPlcSourceValue(const BSXClientNameDebug, plcName,
  PlcSourceName: string; const value: variant): TputPlcSourceValue_back;
var k:integer;
    j:integer;
    trovato:boolean;
    XPlcSource:tPlcSource;
    xplc:tplc;
    s:string;
    comoOff:integer;
    fase,func:string;
    valueDebug:string;
begin
   try
      valueDebug:=value;
   except
      valueDebug:='#value is not  a string!';
   end;
   func:='dm_putPlcSourceValue(<'+BSXClientNameDebug+'><'+plcName+'>,<'+PlcSourceName+'>,<'+ valueDebug+'>)';
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
         writelog(func);
   result.error:=Error_All_ok;
   result.error.error:=BSXE_dm_putPlcSourceValue_generic;

   try
      fase:='getplc(<'+plcName+'>)';
      result.error.error:=BSXE_dm_putPlcSourceValue_getPlc;
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      fase:=xplc.info.NAME_PLC+'putPlcSourceValueByName('+plcName+'>)';
      result:=xplc.putPlcSourceValueByName(PlcSourceName,value);  /// non fa eccezzioni ma ritorna errore in result! !
      if result.error.error<>BSXE_ALL_OK then
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogERR(func+' '+fase+' '+Result.error.errors);

   except
     on e:exception do
     begin
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(func+' '+fase+' '+e.Message);
        result.error.errors:=func+' '+fase+' '+e.Message;
//        result.error.error:= gia settato prima!
     end;
   end;
end;


function TDm_BSX_ENGINE.dm_putPlcSourceValueByPath(const BSXClientNameDebug,
  plcName, PlcSourceName, Path: string;
  const value: variant): TputPlcSourceValue_back;
var k:integer;
    j:integer;
    trovato:boolean;
    XPlcSource:tPlcSource;
    xplc:tplc;
    s:string;
    comoOff:integer;
    fase,func:string;
    valueDebug:string;
begin
   try
      valueDebug:=value;
   except
      valueDebug:='#value is not  a string!';
   end;
   func:='dm_putPlcSourceValueByPath(<'+BSXClientNameDebug+'><'+plcName+'>,<'+PlcSourceName+'>,<'+Path+'>,<'+ valueDebug+'>)';
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
         writelog(func);
   result.error:=Error_All_ok;
   result.error.error:=BSXE_dm_putPlcSourceValueByPath_generic;

   try
      fase:='getplc(<'+plcName+'>)';
      result.error.error:=BSXE_dm_putPlcSourceValueByPath_getPlc;
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      fase:=xplc.info.NAME_PLC+'PutPlcSourceValueByNameAndPath('+plcName+'><'+path+'>)';
      result:=xplc.PutPlcSourceValueByNameAndPath(PlcSourceName,path,value);  /// non fa eccezzioni ma ritorna errore in result! !
      if result.error.error<>BSXE_ALL_OK then
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogERR(func+' '+fase+' '+Result.error.errors);

   except
     on e:exception do
     begin
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(func+' '+fase+' '+e.Message);
        result.error.errors:=func+' '+fase+' '+e.Message;
//        result.error.error:= gia settato prima!
     end;
   end;
end;





// not used by server for now!
function TDm_BSX_ENGINE.dm_getPlcSource_offset_and_size_ByPath(Const BSXClientNameDebug:string;const plcName:string;const PlcSourceName:string;const Path:string):TGetPlcSource_offset_and_size_ByNameAndPath_ret;
var k:integer;
    j:integer;
    trovato:boolean;
    XPlcSource:tPlcSource;
    xplc:tplc;
    s:string;
    comoOff:integer;
    fase,func:string;
    valueDebug:string;
begin

   func:='dm_getPlcSource_offset_and_size_ByPath(<'+BSXClientNameDebug+'><'+plcName+'>,<'+PlcSourceName+'>,<'+Path+'>)';
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
         writelog(func);
   result.error:=Error_All_ok;
   result.error.error:=BSXE_dm_getPlcSource_offset_and_size_ByPath_generic;

   try
      fase:='getplc(<'+plcName+'>)';
      result.error.error:=BSXE_dm_getPlcSource_offset_and_size_ByPath_getPlc;
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      fase:=xplc.info.NAME_PLC+'dm_getPlcSource_offset_and_size_ByPath('+plcName+'><'+path+'>)';
      result:=xplc.GetPlcSource_offset_and_size_ByNameAndPath(PlcSourceName,path);  /// non fa eccezzioni ma ritorna errore in result! !
      if result.error.error<>BSXE_ALL_OK then
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogERR(func+' '+fase+' '+Result.error.errors);

   except
     on e:exception do
     begin
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(func+' '+fase+' '+e.Message);
        result.error.errors:=func+' '+fase+' '+e.Message;
//        result.error.error:= gia settato prima!
     end;
   end;
end;










/////////////////////////////////////////////////////////////////////
////
///               tvarplc
////
///////////////////////////////////////////////////
constructor tPlcSource.create(aowner:tcomponent;
                        xfinfoplc:tplcInfo ;
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  {$ELSE}
                        plc:TboxPlcrid;
  {$ENDIF}


{$IFDEF BOX_SNAP7_POOL}
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
                        xsnap7client:TS7Client;
  {$ELSE}
                        xsnap7client:TBoxS7Client;
  {$ENDIF}
{$ELSE}
                        xsnap7client:TS7Client;
{$ENDIF}

                        xRootVarPlc_node:IXMLNode;
                        const xnamePlc:string);

//(aowner:tcomponent; plc:TboxPlcrid;xRootVarPlc_node:IXMLNode;const xnamePlc:string);
var nodeRoot:IXMLNode;
    k:integer;
    node:IXMLNode;
    node2:IXMLNode;
    sss:string;
    offset:integer;
    tsdeb:tstringlist;
    xret:tInfoVarOnPlcFisico_back;
    comomes:string;

    flg_MODE_LETTURA:boolean;
    flg_TIME_READ_INTERVAL:boolean;
    flg_NAME_ON_PLC:boolean;
    flg_OFFSET_ON_PLC:boolean;
    flg_CHECK_PLC_DEF:boolean;
    flg_PLCVAR_VSIZE:boolean;

    comoLl:integer;
    nblocchi:integer;


begin
    flg_MODE_LETTURA:=false;
    flg_TIME_READ_INTERVAL:=false;
    flg_NAME_ON_PLC:=false;
    flg_OFFSET_ON_PLC:=false;
    flg_CHECK_PLC_DEF:=false;
    flg_PLCVAR_VSIZE:=false;


   inherited create(aowner);
   namePlc:=xnamePlc;
    Linfoplc:=xfinfoplc;
    Lsnap7client:=xsnap7client;
    XmlTypeFromPlcFisico:=nil;
    if Linfoplc.PLCProtocol=pkBeckhoffADS then
    begin
       XmlTypeFromPlcFisico:=TXMLDocument.Create(self); // contiene  xml letto dal plc fisico tramite ads
   // VarInfoFromPlcFisico:tAdrVarEle;   // contiene igroup,ioff, size  letti dal plc fisico  tramite ads
     end;

   sema_Self.Init;
   fInfo.LLBuf:=-1;
   fInfo.XML_checked:=false;
   fInfo.XML_OK:=True;
   fInfo.XML_ERROR:='';

//   f_llvar:=-1;
   if xRootVarPlc_node.Childnodes.count<>1 then
      raise exception.Create('errore xml su PLCVAR !!');
   RootVarPlc_node:=xRootVarPlc_node.Childnodes[0];
   finfo.name:=RootVarPlc_node.nodename;

   root_defVar:=nil;
   for k := 0 to RootVarPlc_node.ChildNodes.Count-1 do
   begin
      node:=RootVarPlc_node.ChildNodes[k];
      if node.NodeName='DEF_VAR_PLC' then
      begin
        root_defVar:=node;
        fInfo.xml:=root_defVar.XML;
        break;
      end;
   end;

   if root_defVar<>nil then
   begin
     fInfo.LLBuf:=calcola_ll_variabile(root_defVar);
   end;
///   setlength(self.fbuffer,fInfo.LLBuf);

   node:=root_defVar.ChildNodes.First;
   finfo.MODE_LETTURA :='MANUAL';
   finfo.TIME_READ_INTERVAL:=500;
   finfo.NAME_ON_PLC:='NAME_ON_PLC valore non definito';
   finfo.OFFSET_ON_PLC:=0;
   finfo.CHECK_PLC_DEF:=False;
   finfo.PLCVAR_VSIZE:=0;



   for k:=0 to RootVarPlc_node.AttributeNodes.Count-1   do
   begin
     node:=RootVarPlc_node.AttributeNodes[k];
     if node.NodeName='MODE_LETTURA' then
     begin
        finfo.MODE_LETTURA:=node.NodeValue;
        flg_MODE_LETTURA:=True;
     end;
     if node.NodeName='TIME_READ_INTERVAL' then
     begin
        finfo.TIME_READ_INTERVAL:=node.NodeValue;
        flg_TIME_READ_INTERVAL:=True;
     end;
     if node.NodeName='NAME_ON_PLC' then
     begin
        finfo.NAME_ON_PLC:=node.NodeValue;
        flg_NAME_ON_PLC:=True;
     end;
     if node.NodeName='OFFSET_ON_PLC' then
     begin
        finfo.OFFSET_ON_PLC:=node.NodeValue;
        flg_OFFSET_ON_PLC:=True;
     end;
     if node.NodeName='CHECK_PLC_DEF' then
     begin
        if uppercase(node.NodeValue)='TRUE' then
            finfo.CHECK_PLC_DEF:=true;
        flg_CHECK_PLC_DEF:=True;
     end;
     if node.NodeName='PLCVAR_VSIZE' then
     begin
        finfo.PLCVAR_VSIZE:=node.NodeValue;  // contiene la lunghezza della variabile plc letta dal plc!
        flg_PLCVAR_VSIZE:=True;
     end;
   end;

   if (flg_MODE_LETTURA=false) or
      (flg_TIME_READ_INTERVAL=false) or
      (flg_NAME_ON_PLC=false) or
      (flg_OFFSET_ON_PLC=false) or
//      (flg_CHECK_PLC_DEF=false) or
      (flg_PLCVAR_VSIZE=false) then
   begin
      fInfo.XML_checked:=True;
      fInfo.XML_OK:=False;
      fInfo.XML_ERROR:=' Manca uno dei seguenti parametri MODE_LETTURA,TIME_READ_INTERVAL,NAME_ON_PLC,OFFSET_ON_PLC,'+{CHECK_PLC_DEF+}'PLCVAR_VSIZE ';
   end;

      comoLl:=fInfo.LLBuf;

      if (comoLl mod xfinfoplc.ALIGN_SIZE_SYSTEM)<>0 then
      begin
         nblocchi:= comoLl div xfinfoplc.ALIGN_SIZE_SYSTEM;
         nblocchi:=nblocchi+1;
         comoLl:=nblocchi*xfinfoplc.ALIGN_SIZE_SYSTEM;
      end;

   if (fInfo.LLBuf<>fInfo.PLCVAR_VSIZE) and (fInfo.PLCVAR_VSIZE<>comoLl) then
   begin

      fInfo.XML_checked:=True;
      fInfo.XML_OK:=False;
      fInfo.XML_ERROR:=fInfo.XML_ERROR+'; fInfo.LLBuf (calculated)<'+fInfo.LLBuf.ToString+'> (fInfo.PLCVAR_VSIZE read from xml!)<'+fInfo.PLCVAR_VSIZE.ToString+'> non uguali!!! ';

     try
        comomes:='**************** '+  fInfo.name +'  fInfo.LLBuf (calculated)<'+fInfo.LLBuf.ToString+'> (fInfo.PLCVAR_VSIZE read from plc!)<'+fInfo.PLCVAR_VSIZE.ToString+'> NOT EQUAL!!! ';
        if Param_BSX_SERVER.Verboseindex_Messager>0 then
        begin
           mysendmessage(self,999,'');
           mysendmessage(self,999,'');
           mysendmessage(self,999,'');
           mysendmessage(self,999, comomes);
           mysendmessage(self,999,'');
           mysendmessage(self,999,'');
           mysendmessage(self,999,'');
        end;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(comomes);
     except
     end;
   end;

   if Linfoplc.PLCProtocol=pkBeckhoffADS then
   begin
(*      xret:=Dm_BSX_ENGINE_BeckHoff_Definition.getInfoVarOnPlcFisico(namePlc,finfo.NAME_ON_PLC);
      if xret.error.error=BSXE_ALL_OK then
      begin
         XmlTypeFromPlcFisico.LoadFromXML(xret.xml); // contiene  xml letto dal plc fisico tramite ads
         VarInfoFromPlcFisico:=xret.entry;   // contiene igroup,ioff, size  letti dal plc fisico  tramite ads
      end;
  *)
     {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
     {$ELSE}
      boxvar:=TboxvarRid.Create(nil);
      boxvar.VarType := VT_Byte;
      boxvar.VarStrLen := 0;
      boxvar.VarStartPos := 0;
      boxvar.VarNamePlc :=finfo.NAME_ON_PLC;
      boxvar.VarTimeout := 500;
      boxvar.Var_CicleTimeRead := 1;
      boxvar.var_CycleTimeWrite:=  0;
      boxvar.Var_nMaxDelayRead := 0;
      boxvar.VarNumElement := fInfo.PLCVAR_VSIZE ;// fInfo.LLBuf;
      if finfo.MODE_LETTURA='MANUAL' then
          boxvar.ModeUpdateRead := MURV_manual;
      if finfo.MODE_LETTURA='CYCLE' then
          boxvar.ModeUpdateRead := MURV_Cicle;
      boxvar.ModeUpdateWrite := MUWV_manual;
      boxvar.TaskPriority := tpIdle;
      boxvar.Connected := False;
      boxvar.Connected_on_run := False;
      boxvar.NoRaiseException := False;
      boxvar.parent:=plc;
     {$ENDIF}
   end;
 //   boxvar.Connected:=true;

    if finfo.name='dut_test' then
    begin
  (*    for k:=0 to   root_defVar.ChildNodes.Count-1 do
      begin
         if root_defVar.ChildNodes[k].NodeName='flag1' then
         begin
           dummydebug2:=calcola_ll_variabile(root_defVar.ChildNodes[k]);
           showmessage( 'calcolaOffsetPath( assi='+dummydebug2.ToString);
         end;
      end;
      ;
    *)
    //  dummydebug2:=calcolaOffsetPathAndSize('c[1].d.d2[2].e[1]')  ;
    //  showmessage( 'calcolaOffsetPath(c[1].d.d2[2].e[1])='+dummydebug2.offset.ToString+ ' size '+dummydebug2.size.ToString + ' node '+dummydebug2.nodo.NodeName);
    end;

//    if fInfo.name='DS_HMI' then
    begin
       try
          Check_xml;
       except
         on e:exception do
         begin
           fInfo.XML_checked:=True;
           fInfo.XML_OK:=False;
           fInfo.XML_ERROR:=fInfo.XML_ERROR+'; check xml err:'+e.Message;
         end;

       end;
    end;


// debug
{$IFDEF BOXDEBUG}
   if Linfoplc.marcaPlc=marcaplc_beckhoff then
   begin
    boxvar.Connected:=TRUE;
    boxvar.readManualVar;
    Self.fbuffer:=boxvar.GetBufferData;

    SetLength(fbufferCopia_test,length(fbuffer));
    move(fbuffer[0],fbufferCopia_test[0],length(fbuffer));
  end
  else
  begin
  end;


//   debugcaricabuffer();
   offset:=0;
//   sss:=createjson1(self.root_defVar,offset);

 //  test_variant_to_buffer;
{$ENDIF}

//   tsdeb:=tstringlist.Create;
//   tsdeb.Text:=sss;
//   tsdeb.SaveToFile('C:\!mysw\MORMOT_SCADA\CONFIG_READER_XML\ris.json');
//   tsdeb.free;
end;

destructor tPlcSource.Destroy;
begin
// da controllare
  if Linfoplc.PLCProtocol=pkBeckhoffADS then
  begin
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
  {$ELSE}
     if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
        writelog( 'tPlcSource.Destroy '+self.Info.name+' begin' );
     try
        self.boxvar.Connected:=False;
     except
       ;
     end;

     try
        self.boxvar.free;
        boxvar:=nil;//
     except
        on e:exception do
        begin
          boxvar:=nil;
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
              writelogerr('tPlcSource.Destroy -> self.boxvar.free err:='+e.Message);
        end;
     end;
  {$ENDIF}
  end;
  sema_Self.Done;
  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
     writelog( 'tPlcSource.Destroy '+self.Info.name+' begin 98' );
  inherited;
  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
      writelog( 'tPlcSource.Destroy end' );

end;

function tPlcSource.getValueSource(const maxage:integer):tgetPlcSourceValue_back;
var s2,s:String;
    bufferPlc:tarrayofbyte;
    fase,func:string;
    vtest:variant;
    stest,stest2,stest4:ansistring;
begin
  (* stest:=#27#41;
   vtest:=_Obj(['name',stest]);
   stest2:=VariantSaveJSON(vtest);
   stest4:=vtest.name;
   if stest<>stest4 then
      dummydebug:=1;
    *)
   (*
   if self.fInfo.name='DS_Allarmi_HMI' then
     dummydebug:=1;
   *)
   result.error.error:=BSXE_PlcSource_getValueSource_generic;
   result.value:='';
   fase:=' Begin ';
   func:='tPlcSource.getValueSource';
   try
     lock_self;
     try
        if finfo.MODE_LETTURA='MANUAL' then
        begin
           fase:=' bufferPlc:=ReadBufferFromPlcFisico ';
           result.error.error:=BSXE_PlcSource_getValueSource_ReadBufferFromPlcFisico;
           bufferPlc:=ReadBufferFromPlcFisico(maxage);
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>10 then
              writelog( debug_buffer('contenuto di <'+finfo.NAME_ON_PLC+'> ', bufferPlc));
        end;
        fase:=' createjsonString(bufferPlc); ';
        result.error.error:=BSXE_PlcSource_getValueSource_createjsonString;
        s:=createjsonString(bufferPlc);
        if s='' then
           raise Exception.Create('Error createjsonString(bufferPlc) return <"">!!');
        fase:=' result.value:=_Json(s); ';
        result.error.error:=BSXE_PlcSource_getValueSource_To_json;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>10 then
           writelog(s);
        result.value:=_Json(s);
        if Param_BSX_SERVER.debug_check_getValueSource_convert_json then
        begin
           s2:=VariantSaveJSON(result.value);
           if s<>s2 then
              raise Exception.Create('Error convert cazzo cazzo cazzo _json<'+s+'>,<'+s2+'> ');
        end;
        if result.value=null then
           raise Exception.Create('Errorresult.value=null');
        if (System.Variants.VarIsEmpty(result.value)) then
           raise Exception.Create('Errorresult.value=null');

        result.error:=Error_All_ok;
     except
        on e:exception do
        begin
            Result.error.errors:=func+' '+fase+ 'err:['+integer(result.error.error).ToString+'] '+e.Message;
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                writelogerr(Result.error.errors);
        end;
     end;
   finally
      unlock_self;
   end;
end;
function tPlcSource.PutValueSource(const value:variant):TputPlcSourceValue_back;
var s:String;
    BuffData:tarrayofbyte;
    fase,func:string;
begin
   result.error.error:=BSXE_PlcSource_putValueSource_generic;
   fase:=' Begin ';
   func:='tPlcSource.PutValueSource';
   try
     lock_self;
     try
        fase:=' moveVariantToArrayOfByte(value) ';
        result.error.error:=BSXE_PlcSource_putValueSource_moveVariantToArrayOfByte;
        BuffData:=moveVariantToArrayOfByte(value,self.root_defVar,fInfo.LLBuf);
        fase:=' writeBuffertoPlcFisico ';
        result.error.error:=BSXE_PlcSource_putValueSource_writeBuffertoPlcFisico;
        writeBuffertoPlcFisico(BuffData,0);
        result.error:=Error_All_ok;
     except
        on e:exception do
        begin
           Result.error.errors:=func+' '+fase+ 'err:['+integer(result.error.error).ToString+'] '+e.Message;
           if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
              writelogerr(Result.error.errors);
        end;
     end;
   finally
      unlock_self;
   end;
   ////////////////////////////////////////////////
   ///
   ///
(*   var s:String;
    BuffData:tarrayofbyte;
begin
   try
       lock_self;
       boxvar.putBufferData(BuffData);
       boxvar.writeManualVar;
   finally
      unlock_self;
   end;
end;
  *)
end;

function tPlcSource.PutValueSourceByPath(const path: string;
  const value: variant): tputPlcSourceValue_back;
var s:String;
    BuffData:tarrayofbyte;
    fase,func:string;
    offandsize:ToffsetAndSize;
    DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;
begin
   result.error.error:=BSXE_PlcSource_putValueByPahtSource_generic;
   fase:=' Begin ';
   func:='tPlcSource.PutValueSourceByPath';
   try
     lock_self;
     try
        fase:='tPlcSource.calcolaOffsetPathAndSize(<'+path+'>)';
        result.error.error:=BSXE_PlcSource_putValueByPahtSource_calcolaOffsetPathAndSize;
        DATI_BIT_SINGOLO.FLAGBIT_SINGOLO:=False;
        DATI_BIT_SINGOLO.bitpos:=-1;
        offandsize:=calcolaOffsetPathAndSize(path);
        if offandsize.Error.error<>BSXE_ALL_OK then
        begin
           raise exception.Create(offandsize.Error.errors);
        end;

        if offandsize.DATI_BIT_SINGOLO.FLAGBIT_SINGOLO then
        begin
           DATI_BIT_SINGOLO:=offandsize.DATI_BIT_SINGOLO;
        end;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
            writelog(fase+ ' offandsize.offset<'+ offandsize.offset.ToString+'> size <'+offandsize.size.ToString+'>');
        if Param_BSX_SERVER.Verboseindex_Messager>0 then
           mysendmessage(self,888, fase+ ' offandsize.offset<'+ offandsize.offset.ToString+'> size <'+offandsize.size.ToString+'>' );
        fase:=' moveVariantToArrayOfByteByPath ';
        result.error.error:=BSXE_PlcSource_putValueByPahtSource_moveVariantToArrayOfByteByPath;
        BuffData:=moveVariantToArrayOfByteByPath(value,offandsize.nodo,offandsize.size,DATI_BIT_SINGOLO,offandsize.AllArrayPath);
        fase:=' WriteBufferToPlcFisicoWithOffset ';
        result.error.error:=BSXE_PlcSource_putValueByPahtSource_writeBuffertoPlcFisicoWithOffset;
        WriteBufferToPlcFisicoWithOffset(BuffData,offandsize.offset,DATI_BIT_SINGOLO);
        result.error:=Error_All_ok;
     except
        on e:exception do
        begin
            Result.error.errors:=func+' '+fase+ 'err:['+integer(result.error.error).ToString+'] '+e.Message;
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               writelogerr(Result.error.errors);
        end;
     end;
   finally
      unlock_self;
   end;



;
end;



function tPlcSource.Get_offset_and_size_SourceByPath(const path: string): TGetPlcSource_offset_and_size_ByNameAndPath_ret;
var s:String;
    BuffData:tarrayofbyte;
    fase,func:string;
    offandsize:ToffsetAndSize;
    DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;
begin


   result.error.error:=BSXE_PlcSource_Get_offset_and_size_SourceByPath_generic;
   fase:=' Begin ';
   func:='tPlcSource.Get_offset_and_size_SourceByPath';
   try
     lock_self;
     try
        fase:='tPlcSource.calcolaOffsetPathAndSize(<'+path+'>)';
        result.error.error:=BSXE_PlcSource_putValueByPahtSource_calcolaOffsetPathAndSize;
        DATI_BIT_SINGOLO.FLAGBIT_SINGOLO:=False;
        DATI_BIT_SINGOLO.bitpos:=-1;
        offandsize:=calcolaOffsetPathAndSize(path);
        if offandsize.DATI_BIT_SINGOLO.FLAGBIT_SINGOLO then
        begin
           DATI_BIT_SINGOLO:=offandsize.DATI_BIT_SINGOLO;
        end;
        result.error:=Error_All_ok;
        result.offset:=offandsize.offset;
        result.size:=offandsize.size;

     except
        on e:exception do
        begin
            Result.error.errors:=func+' '+fase+ 'err:['+integer(result.error.error).ToString+'] '+e.Message;
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               writelogerr(Result.error.errors);
        end;
     end;
   finally
      unlock_self;
   end;
end;






procedure tPlcSource.test_variant_to_buffer;
var v:variant;
    s:string;
begin
(*
   s:=self.createjson();
   v:=_Json(s);

  FillZero(fbuffer[0],length(fbuffer));
  boxvar.putBufferData(Self.fbuffer);
  boxvar.writeManualVar;

   self.moveVariantToArrayOfByte(v);

    boxvar.putBufferData(Self.fbuffer);
    boxvar.writeManualVar;

  *)
end;

procedure  tPlcSource.writelogDebug(const s:string);
begin
    if logDm_BSX_ENGINE<>nil then
    try
       logDm_BSX_ENGINE.DoLogMessDEB('@PLCSOURCE ['+self.fInfo.name+'] '+ s);
    except
        ;
    end;
end;

procedure  tPlcSource.writelog(const s:string);
begin
    if logDm_BSX_ENGINE<>nil then
    try
       logDm_BSX_ENGINE.DoLogMess('@PLCSOURCE ['+self.fInfo.name+'] '+ s);
    except
        ;
    end;
end;
procedure  tPlcSource.writelogerr(const s:string);
begin
    try
       logDm_BSX_ENGINE.DoLogMessErr('@PLCSOURCE ['+self.fInfo.name+'] '+ s);
    except
        ;
    end;
end;

procedure tPlcSource.unlock_self;
begin
   sema_Self.unLock;
end;
procedure tPlcSource.lock_self;
begin
   sema_Self.Lock;
end;

function  tPlcSource.ReadBufferFromPlcFisico(const maxage:integer):tarrayofbyte;
var func,fase:string;
    NUMDB:integer;
begin
   if Linfoplc.PLCProtocol=pkBeckhoffADS then
   begin
    {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
    {$ELSE}

     try
        lock_self;
        try
           func := 'ReadBufferFromPlcFisico(BECKHOFF)';
           fase := 'boxvar.Connected:=true;';
           boxvar.Connected:=true;
           fase := 'boxvar.readManualVar';

           var xip:string;
            xip:=(boxvar.Parent as TboxPlcBeckHoff_rid).PLC_ipAddres+':'+(boxvar.Parent as TboxPlcBeckHoff_rid).PLC_Port.ToString;
           var xDb:string;
              xdb:=boxvar.VarNamePlc;
           var Xoffset:integer;
              Xoffset:=boxvar.VarStartPos;
           var xll:integer;
             xll:=boxvar.fieldCompo.SizeInByte;
           var Founded:boolean;

           result:=Dm_engineBufferCache.Retrivedata(xip,
                                     xdb,
                                     Xoffset,
                                     xll,
                                     maxage,
                                     Founded);
          if not Founded then
          begin
             boxvar.readManualVar;
             fase := 'result:=boxvar.GetBufferData';
             result := boxvar.GetBufferData;
             Dm_engineBufferCache.insdata(xip,
                                     xdb,
                                     Xoffset,
                                     xll,
                                     result);

          end;
        except
           on e: exception do
           begin
              if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                  self.writelogerr(fase + ' ' + func + ' ' + e.Message);
              raise exception.Create(fase + ' ' + func + ' ' + e.Message);
           end;
        end;
     finally
        unlock_self;
     end;
    {$ENDIF}
   end;
   if Linfoplc.PLCProtocol=pkSiemensS7 then
   begin
     try
        lock_self;
        func := 'ReadBufferFromPlcFisico(SIEMENS)';
        try
           fase := 'Snap7connect ';
           if not Lsnap7client.Connected then
{$IFDEF BOX_SNAP7_POOL}
               {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
                Snap7connect(Lsnap7client,Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
               {$ELSE}
                Lsnap7client.Snap7connect(Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
               {$ENDIF}
{$ELSE}
                Snap7connect(Lsnap7client,Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
{$ENDIF}
           fase := 'Snap7Readbuffer';
           TRY
             NUMDB:=strtoint(fInfo.NAME_ON_PLC);
           EXCEPT
              raise Exception.Create('ATTENZIONE NAME_ON_PLC SU SIEMENS DEVE CONTENERE IL NUMEO DEL DB!!! ');
           END;

{$IFDEF BOX_SNAP7_POOL}
          {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
           result:=Snap7Readbuffer(Lsnap7client,
                                   NUMDB,// db:integer;
                                   fInfo.OFFSET_ON_PLC,// offset:integer;
                                   fInfo.LLBuf,maxage);// ll:integer);
          {$ELSE}
           result:=Lsnap7client.Snap7Readbuffer(
                                   NUMDB,// db:integer;
                                   fInfo.OFFSET_ON_PLC,// offset:integer;
                                   fInfo.LLBuf,maxage);// ll:integer);
          {$ENDIF}

{$ELSE}
           result:=Snap7Readbuffer(Lsnap7client,
                                   NUMDB,// db:integer;
                                   fInfo.OFFSET_ON_PLC,// offset:integer;
                                   fInfo.LLBuf,maxage);// ll:integer);
{$ENDIF}


        except
           on e: exception do
           begin

{$IFDEF BOX_SNAP7_POOL}
  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
              try Lsnap7client.Disconnect;except;end;
  {$ELSE}
              try Lsnap7client.Snap7Disconnect;except;end;
  {$ENDIF}


{$ELSE}
              try Lsnap7client.Disconnect;except;end;
{$ENDIF}

              if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                 self.writelogerr(fase + ' ' + func + ' ' + e.Message);
              raise exception.Create(fase + ' ' + func + ' ' + e.Message);
           end;
        end;
     finally
        unlock_self;
     end;
   end;
end;

procedure  tPlcSource.WriteBufferToPlcFisico(value:tarrayofbyte;offset:integer);
var func,fase:string;
begin
   try
      lock_self;
      func := 'tVarPlc.WriteBufferToPlcFisico';
      if Linfoplc.PLCProtocol=pkBeckhoffADS then
      begin
        {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
        {$ELSE}

        try
           fase := 'boxvar.Connected:=true;';
           boxvar.Connected:=true;
  //       fase := 'result:=boxvar.putBufferData';
  //       if boxvar.ModeUpdateRead<>MURV_manual then
  //       begin
  //          boxvar.ModeUpdateRead:=MURV_manual;
  //       end;
           boxvar.putBufferData_and_write_to_plc(value);

           var xip:string;
            xip:=(boxvar.Parent as TboxPlcBeckHoff_rid).PLC_ipAddres+':'+(boxvar.Parent as TboxPlcBeckHoff_rid).PLC_Port.ToString;
           var xDb:string;
              xdb:=boxvar.VarNamePlc;

           Dm_engineBufferCache.ResetDataDb(xip,xDb)



  //       fase := 'boxvar.writeManualVar';
  //       boxvar.writeManualVar;
        except
           on e: exception do
           begin
              if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                 self.writelogerr(fase + ' ' + func + ' ' + e.Message);
              raise exception.Create(fase + ' ' + func + ' ' + e.Message);
           end;
        end;

       {$ENDIF}
      end;
      if Linfoplc.PLCProtocol=pkSiemensS7 then
      begin
        try
           fase := 'Snap7connect ';
           if not Lsnap7client.Connected then
{$IFDEF BOX_SNAP7_POOL}
               {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
                Snap7connect(Lsnap7client,Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
               {$ELSE}
                Lsnap7client.Snap7connect(Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
               {$ENDIF}
{$ELSE}
                Snap7connect(Lsnap7client,Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
{$ENDIF}

           fase := 'Snap7writebuffer';

{$IFDEF BOX_SNAP7_POOL}
          {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
           Snap7writebuffer(Lsnap7client,
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset,// offset:integer;
                                   length(value),value);// ll:integer);
          {$ELSE}
           Lsnap7client.Snap7Writebuffer(
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset,// offset:integer;
                                   length(value),value);// ll:integer);
          {$ENDIF}
{$ELSE}
           Snap7writebuffer(Lsnap7client,
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset,// offset:integer;
                                   length(value),value);// ll:integer);
{$ENDIF}

        except
           on e: exception do
           begin
{$IFDEF BOX_SNAP7_POOL}
             {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
              try Lsnap7client.Disconnect;except;end;
             {$ELSE}
              try Lsnap7client.Snap7Disconnect;except;end;
             {$ENDIF}
{$ELSE}
              try Lsnap7client.Disconnect;except;end;
{$ENDIF}
              if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                 self.writelogerr(fase + ' ' + func + ' ' + e.Message);
              raise exception.Create(fase + ' ' + func + ' ' + e.Message);
           end;
        end;
      end;
   finally
      unlock_self;
   end;
end;
 procedure  tPlcSource.WriteBufferToPlcFisicoWithOffset(value:tarrayofbyte;offset:integer;DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO);
var func,fase:string;

     tipoDatoBYTE:BYTE;
     byte_of_bit:integer;
     bitpos:integer;
     newbitpos:integer;
     bitset:boolean;
begin
   try
      lock_self;
      func := 'tVarPlc.WriteBufferToPlcFisicoWithOffset';
      try
         if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
         begin
           {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
           {$ELSE}
            if DATI_BIT_SINGOLO.FLAGBIT_SINGOLO then
               raise Exception.Create('SU BECKHOFF NON E POSSIBILE GESTIRE IL SINGOLO BIT!!!!!!!!!!!!!!!!!!');
            fase := 'boxvar.Connected:=true;';
            boxvar.Connected:=true;
            fase := 'result:=boxvar.putBufferData_and_write_to_plc_with_Offset';
   //       if boxvar.ModeUpdateRead<>MURV_manual then
   //       begin
   //          boxvar.ModeUpdateRead:=MURV_manual;
   //       end;
            var xip:string;
            xip:=(boxvar.Parent as TboxPlcBeckHoff_rid).PLC_ipAddres+':'+(boxvar.Parent as TboxPlcBeckHoff_rid).PLC_Port.ToString;
            var xDb:string;
            xdb:=boxvar.VarNamePlc;
            Dm_engineBufferCache.ResetDataDb(xip,xDb);

            boxvar.putBufferData_and_write_to_plc_with_Offset(value,offset);

            if boxvar.LastError.ErrorType<>ErrTypeAV_no_error then
            begin
               raise Exception.Create(boxvar.LastError.errorDesc);
            end;
           {$ENDIF}
         end;
         if self.Linfoplc.PLCProtocol=pkSiemensS7 then
         begin
           fase := 'Snap7connect ';
           if not Lsnap7client.Connected then
{$IFDEF BOX_SNAP7_POOL}
             {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
                Snap7connect(Lsnap7client,Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
             {$ELSE}
                Lsnap7client.Snap7connect(Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
             {$ENDIF}
{$ELSE}
                Snap7connect(Lsnap7client,Linfoplc.SIE_IPADR,Linfoplc.SIE_IPADR_RACK,Linfoplc.SIE_IPADR_SLOT);
{$ENDIF}
           if DATI_BIT_SINGOLO.FLAGBIT_SINGOLO then
           begin
              //procedure Snap7Writebuffer_BIT(snap7client:TS7Client;db:integer;offsetBYTE:integer;posBIT:integer;Value:boolean);
                bitpos:=DATI_BIT_SINGOLO.BiTpos;
                byte_of_bit:=(bitpos) div 8;
                newbitPos:=bitpos - (byte_of_bit * 8) ;
              //  da controllare quello che prepara il buffer!!
                /// qui leggo male value[offset]  offset=1 ??? sembra giusto!
                /// io leggo di value[1] ma value e solo lungo 0!
                /// pero la variabile ha offset 1
                tipoDatoBYTE:=value[byte_of_bit];
                bitset:=(tipoDatoBYTE and (1 shl newbitPos)) <> 0;
              fase := 'Snap7Writebuffer_BIT';
{$IFDEF BOX_SNAP7_POOL}
             {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
              Snap7Writebuffer_BIT(Lsnap7client,
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset+byte_of_bit,// offset:integer;
                                   newbitPos,bitset);// ll:integer);
             {$ELSE}
              Lsnap7client.Snap7Writebuffer_BIT(
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset+byte_of_bit,// offset:integer;
                                   newbitPos,bitset);// ll:integer);
             {$ENDIF}
{$ELSE}
              Snap7Writebuffer_BIT(Lsnap7client,
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset+byte_of_bit,// offset:integer;
                                   newbitPos,bitset);// ll:integer);
{$ENDIF}
           end
           else
           begin
              fase := 'Snap7writebuffer';

{$IFDEF BOX_SNAP7_POOL}
             {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
              Snap7writebuffer(Lsnap7client,
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset,// offset:integer;
                                   length(value),value);// ll:integer);
             {$ELSE}
              Lsnap7client.Snap7writebuffer(
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset,// offset:integer;
                                   length(value),value);// ll:integer);
             {$ENDIF}
{$ELSE}
              Snap7writebuffer(Lsnap7client,
                                   strtoint(fInfo.NAME_ON_PLC),// db:integer;
                                   fInfo.OFFSET_ON_PLC+offset,// offset:integer;
                                   length(value),value);// ll:integer);
{$ENDIF}
           end;
         end;

      except
         on e: exception do
         begin
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               self.writelogerr(fase + ' ' + func + ' ' + e.Message);
            raise exception.Create(fase + ' ' + func + ' ' + e.Message);
         end;
      end;
   finally
      unlock_self;
   end;
end;



function tPlcSource.decodebuffToStringjsonFormat(buf:tarrayofbyte):string;
var s:string;
   k:integer;
maxchar,   numchar:integer;
begin
   s:='';
   if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
   begin
     for k:=low(buf) to high(buf) do
     begin
        if buf[k]=0 then
           break;
        if buf[k]<32 then
        begin
           s:=s+'\u'+buf[k].ToHexString(4);
           continue
        end;
        if char(buf[k])='"' then
           s:=s+'\';
        s:=s+char(buf[k]);
     end;
   end;
   if self.Linfoplc.PLCProtocol=pkSiemensS7 then
   begin
        numchar:=buf[1];
        maxchar:=buf[0];
        if maxchar>length(buf)-2 then
            maxchar:=length(buf)-2;
        if numchar<=0 then numchar:=0;
        if numchar>maxchar then numchar:=maxchar;
        for k:=low(buf)+2 to high(buf) do
        begin
           if k-1> numchar then
               break;
           if buf[k]<32 then
           begin
              s:=s+'\u'+buf[k].ToHexString(4);
              continue
           end;
          if char(buf[k])='"' then
              s:=s+'\';
           s:=s+char(buf[k]);
        end;

        if numchar=0 then
           s:='';
   end;


  result:=s;
end;
function tPlcSource.decodebuffToWideStringjsonFormat(buf:tarrayofbyte):Widestring;
var s:string;
   k:integer;
   wc:widechar;
   bufW:array of word;
   ll:integer;
begin
   ll:=length(buf);
   if (ll mod 2)<>0  then
   begin
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
         writelogerr('$$$$$$$$$$$$$$$ decodebuffToWideStringjsonFormat buffer is non a multiple of 2 !!!!!! $$$$$$$$');
      raise Exception.Create(' $$$$$$$$$$$$$$$ decodebuffToWideStringjsonFormat buffer is non a multiple of 2 !!!!!! $$$$$$$$');
   end;
   setlength(bufw,ll div 2);
   move(buf[0],bufw[0],ll);
   for k:=low(bufW) to high(bufW) do
   begin
      if bufW[k]=0 then
         break;
      if widechar(bufW[k])='"' then
      begin
         s:=s+'\';
         continue
      end;
//      if buf[k]<32 then
      begin
         s:=s+'\u'+ bufw[k].ToHexString;
         continue
      end;
//      s:=s+char(buf[k]);
   end;
   result:=s;
end;
procedure  tPlcSource.debugcaricabuffer;
begin
(*    fbuffer[0]:=ord('A');
    fbuffer[1]:=ord('B');
    fbuffer[2]:=ord('C');
    fbuffer[3]:=ord('D');
    fbuffer[4]:=0;  /// fine sstinga;
    fbuffer[5]:=2;  //flag1
    fbuffer[6]:=3;  //filler1
    fbuffer[7]:=1;  //pos_x 1
    fbuffer[8]:=0;  //pos_x 2
    fbuffer[9]:=0;  //pos_x 3
    fbuffer[10]:=0; //pos_x 4
    fbuffer[11]:=2; //pos_y 1
    fbuffer[12]:=0; //pos_y 2
    fbuffer[13]:=0; //pos_y 3
    fbuffer[14]:=0; //pos_y 4
    fbuffer[15]:=3; //pos_z 1
    fbuffer[16]:=0; //pos_z 2
    fbuffer[17]:=0; //pos_z 3
    fbuffer[18]:=0; //pos_z 4
  *)

(*                 <nameRicetta NAME_ON_PLC="nameRicetta" TYPE_ON_PLC="STRING[4]"/>
                   <flag1 NAME_ON_PLC="flag1"     TYPE_ON_PLC="BYTE" />
                   <filler1 NAME_ON_PLC="filler1"     TYPE_ON_PLC="BYTE" />                   <velocita NAME_ON_PLC="velocita" TYPE_ON_PLC="REAL" />
                   <assi NAME_ON_PLC="assi" TYPE_ON_PLC="RECORD" >
                      <pos_x NAME_ON_PLC="pos_x" TYPE_ON_PLC="DINT"/>
                      <pos_y NAME_ON_PLC="pos_y" TYPE_ON_PLC="DINT"/>
                      <pos_z NAME_ON_PLC="pos_z" TYPE_ON_PLC="DINT"/>
                   </assi>
  *)
end;

function tPlcSource.debug_buffer(const des_debug:string; const bufferData: tarrayOfByte): string;
var s:string;
    k:integer;
begin
     s:=des_debug;
     for k:= Low(bufferData) to High(bufferData) do
     begin
        s:=s+'['+k.ToString+']=<'+bufferData[k].ToString+'>'+#10#13;
     end;
   result:=s;
end;
function tPlcSource.decodeArrayAttribute(s:string):integer;
var x:TarrayMinMax;
begin
   x:=decodeArrayAttributeMINMAX(s);
   result:=x.numEle;
end;

function tPlcSource.decodeArrayAttributeMINMAX(s:string):TarrayMinMax;
var ilow,ihigh:integer;
  var pippo:array[1..1] of integer;
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
         if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
             writelogerr('BSXERROR decodeArrayAttributeMINMAX(<'+s+'>) err:'+e.Message);
         raise Exception.Create('BSXERROR decodeArrayAttributeMINMAX(<'+s+'>) err:'+e.Message);
      end;
   end;
end;

function tPlcSource.DecodellString(s:string):integer;
    begin
       try
          s:=System.SysUtils.trim(s);
          //TOLGO'STRING['
          s:=copy(s,8,999);
          s:=copy(s,1,length(s)-1);//TOLGO ']'
          result:=strtoint(s);
          if result<1 then
             raise Exception.Create('error parametri');
       except
          on e:exception do
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                writelogerr('DecodellString Errore lunghezza stringa <'+s+'> ' +e.message);
             raise Exception.Create('DecodellString Errore lunghezza stringa <'+s+'> '+e.message);
          end;
       end;
    end;

function tPlcSource.DecodellWideString(s:string):integer;
    begin
       try
          s:=System.SysUtils.trim(s);
          //TOLGO'STRING['
          s:=copy(s,9,999);
          s:=copy(s,1,length(s)-1);//TOLGO ']'
          result:=strtoint(s);
          if result<1 then
             raise Exception.Create('error parametri');
       except
          on e:exception do
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                 writelogerr('DecodellWideString Errore lunghezza stringa <'+s+'> ' +e.message);
             raise Exception.Create('DecodellWideString Errore lunghezza stringa <'+s+'> '+e.message);
          end;
       end;
    end;


function tPlcSource.calcolaRelativeOffsetOfNode(node: IXMLNode; Relativemainnode:IXMLNode):integer;
var
    debug:string;
 como,   xcumulativeOffset:integer;

begin
    xcumulativeOffset:= 0;
    if node=nil then
    begin
       result:=0;
       exit;
    end;
    debug:=node.XML;
    while node.ParentNode<>nil do
    begin
       if node.ParentNode=Relativemainnode then
       begin
          break
       end;
       try
         //  s:=node.ParentNode.NodeName+'.'+s;
           try como:=node.Attributes['VOFF'];except;como:=0;end;
           xcumulativeOffset:=xcumulativeOffset+como;
       except
        on e:exception do
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                self.writelogerr('Error in calcolaFullPathOfNode XLM node <'+debug+'>') ;
            raise Exception.Create('Error in calcolaFullPathOfNode XLM node <'+debug+'>'+e.message);
          end
       end;
       node:=node.ParentNode;
    end;

    result:=xcumulativeOffset;

end;


function tPlcSource.calcolaFullPathOfNode(node: IXMLNode):tcalcolaFullPathOfNode_ret;
var s:string;
    debug:string;
 como,   xcumulativeOffset:integer;
    debu2:string;
begin
    xcumulativeOffset:= 0;
    s:= '';
    if node=nil then
    begin
       result.fullPaht:='';
       result.cumulativeOffset:=0;
       exit;
    end;
    debug:=node.XML;
    s:=node.NodeName;
    while node.ParentNode<>nil do
    begin
       if node=self.root_defVar then
       begin
          dummyxxx:=2;
          break
       end;

       (*
       if node.ParentNode=self.root_defVar then
       begin
          dummyxxx:=1;
          break
       end;
       *)

       try
           como:= 0;
           if node.ParentNode <> self.root_defVar then
              try s:=node.ParentNode.NodeName+'.'+s; except ; end;
           try como:=node.Attributes['VOFF'];except;como:=0;end;
           xcumulativeOffset:=xcumulativeOffset+como;
       except
        on e:exception do
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                self.writelogerr('Error in calcolaFullPathOfNode XLM node <'+debug+'>') ;
            raise Exception.Create('Error in calcolaFullPathOfNode XLM node <'+debug+'>'+e.message);
          end
       end;

       if node.ParentNode=self.root_defVar then //Spostato perché non completava il giro
       begin
          dummyxxx:=1;
          break
       end;


       node:=node.ParentNode;
       if node<>nil then
          debu2:='node = '+node.NodeName
       else
          debu2:='node = nill';



    end;
    result.fullPaht:=s;
    result.cumulativeOffset:= xcumulativeOffset;

end;

function tPlcSource.calcolaOffsetPathAndSize(const path: string): ToffsetAndSize;
var stoppath:string;
begin
   Result.Error.error:= BSXE_PlcSource_calcolaOffsetPathAndSize_Path_not_found;
   Result.Error.errors:='path <'+path+'> not found!';

//                          BSXE_PlcSource_calcolaOffsetPathAndSize_generic,




   stoppath:=uppercase(pathWithoutArray(path));
   result.size:=-1;
   result.nodo:=nil;
   result.DATI_BIT_SINGOLO.FLAGBIT_SINGOLO:=False;
   result.DATI_BIT_SINGOLO.bitpos:=-1;
   result.AllArrayPath:=False;
 //  result.offset:=calcolaOffsetPathAndSize1(0, uppercase(path),stoppath,self.root_defVar,1,Result.nodo,Result.size);
 try
   result.offset:=calcolaOffsetPathAndSizenew( uppercase(path),
                                               self.root_defVar,
                                               Result.nodo,
                                               Result.size,
                                               result.DATI_BIT_SINGOLO,
                                               result.AllArrayPath,
                                               result.Error);
  except
     on e:exception do
     begin
         Result.Error.error:= BSXE_PlcSource_calcolaOffsetPathAndSize_generic;
         Result.Error.errors:= 'Error on find path <'+path+'> Err: '+e.Message;
     end;
  end;
   // in realta calcola la lunghezza di tutti gli elementi prima di quello
   // cercato!
   // ma visto che l array di byte da scrivere parte da 0 va bene cosi!

end;

function tPlcSource.extractPathAtLevelAnndIndexArray(const path:string; const level:integer):tPathAndIndexArray;
var  j,k,p,Indexarray:integer;
     c:char;
     r:string;
     xpath:string;
     s:string;
     inarray:Boolean;
begin
   r:='';
   xpath:=System.SysUtils.trim(path);
   if (level=0) or (xpath='') then
   begin
      result.rpath:='';
      result.indexArray:=-1;
      exit;
   end;
   j:=0;  inarray:=false;
   for k :=1 to length(xpath) do
   begin
      c:=xpath[k];
      if c='.' then
      begin
         j:=j+1;
         if j=level then
            break;
      end;
      if j=level-1 then
      begin
         r:=r+c;
      end
      else
      begin
         if c='[' then
         begin
            inarray:=true;
         end
         else
         begin
            if c=']' then
            begin
               inarray:=false;
            end
            else
            begin
               if inarray=false then
                  r:=r+c;
            end;
         end
      end;
   end;

   if rightstr(r,1)=']' then
   begin
       p:=pos('[',r);
       s:=copy(r,p+1);
       S:=leftstr(s,length(s)-1);
       Indexarray:=strToInt(s);
       r:=leftstr(r,p-1);
   end
   else
   begin
      Indexarray:=-1;
   end;


   result.rpath:=r;
   result.indexArray:=Indexarray
end;
function calcolaLevel(fullpath:string):integer;
var p:integer;
begin
   result:=1;
   p:=pos('.',fullpath);
   while p>0 do
   begin
       inc(result);
       p:=pos('.',fullpath,p+1);
   end;

end;




function tPlcSource.getProprietaNodo(nodo:IXMLNode):tProprietaNodo;
var x:tProprietaNodo;
    k:integer;
    nomeattr:string;
    s:string;
    como:string;
    nodo_xml:string;
    s1:string;
begin
    if nodo = nil then
    begin
       if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
          writelogerr('getProprietaNodo Nodo nil!!!');
       raise Exception.Create('Error getProprietaNodo Nodo nil!!!');
    end;
    s1:=nodo.NodeName;
    try
       nodo_xml:=nodo.xml;
    except
      on e:exception do
      begin
         if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
             writelogerr('Err getProprietaNodo error retrieve xml err:'+e.Message);
         raise Exception.Create('Err getProprietaNodo error retrieve xml err:'+e.Message);
      end;
    end;

    x.isArray:=false;
    x.xtype:='';
    x.llGlobal:=0;
    x.llElement:=0;
    x.llSTRING:=0;
    x.prop_arr.min:=0;
    x.prop_arr.max:=0;
    x.prop_arr.numEle:=0;
    x.Voff:=0;
    x.Vsize:=0;
    x.level:=0;
    x.BiTpos:=-1;
    x.cumulativeOffset:=0;
    if self.root_defVar=nodo then
       exit;
    if nodo.HasAttribute('VOFF') then
    begin
        try
           como:=nodo.Attributes['VOFF'];
          x.Voff:=strtoint(como);
       except
          on e:exception do
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                 writelogerr('getProprietaNodo ERRORE LETTURA VOFF '+nodo_xml+' '+e.Message);
             raise Exception.Create('getProprietaNodo ERRORE LETTURA VOFF '+nodo_xml+' '+e.Message);
          end;
       end;
    end
    else
    begin
       if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
          writelogerr('getProprietaNodo ERRORE LETTURA VOFF non ha attributo VOFF '+nodo_xml);
       raise Exception.Create('getProprietaNodo ERRORE LETTURA VOFF non ha attributo VOFF '+nodo_xml);
    end;
    if nodo.HasAttribute('VSIZE') then
    begin
        try
          como:=nodo.Attributes['VSIZE'];
          x.Vsize:=strtoint(como);
       except
          on e:exception do
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               writelogerr('getProprietaNodo ERRORE LETTURA VSIZE '+nodo_xml);
             raise Exception.Create('getProprietaNodo ERRORE LETTURA VSIZE '+nodo_xml+' '+e.Message);
          end;
       end;
    end
    else
    begin
       if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
          writelogerr('getProprietaNodo ERRORE LETTURA VSIZE non ha attributo VSIZE '+nodo_xml);
       raise Exception.Create('getProprietaNodo ERRORE LETTURA VSIZE non ha attributo VSIZE '+nodo_xml);
    end;

    for k := 0 to nodo.AttributeNodes.Count-1 do
    begin
       try
          nomeattr:=uppercase(nodo.AttributeNodes[k].NodeName);
       except
          nomeattr:='';
       end;

       if nomeattr='TYPE_ON_PLC' then
       begin
         try
            x.xtype:=uppercase(nodo.AttributeNodes[k].NodeValue);
         except
            on e:exception do
            begin
               x.xtype:='UNKNOW';
               if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                  writelogerr('Error read getProprietaNodo TYPE_ON_PLC node xml <'+nodo_xml+'> err:'+e.Message );
               raise Exception.Create('Error read getProprietaNodo TYPE_ON_PLC node xml <'+nodo_xml+'> err:'+e.Message );
            end;
          end;
       end
       else
       begin
          if nomeattr='ARRAY' then
          begin
            try
              try
                 if nodo.AttributeNodes[k].NodeValue <> null then
                    s:=uppercase(nodo.AttributeNodes[k].NodeValue)
                 else
                    s:='';
              except
                s:='';
              end;
              if s>'' then
              begin
                 x.isArray:=true;
                 x.prop_arr:=decodeArrayAttributeMINMAX(s);
              end;
            except
               on e:exception do
               begin
                  x.isArray:=False;
                  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                     writelogerr('Error read getProprietaNodo ARRAY node xml <'+nodo_xml+'> err:'+e.Message );
                  raise Exception.Create('Error read getProprietaNodo ARRAY node xml <'+nodo_xml+'> err:'+e.Message );
               end;
            end
          end
          else
          begin
             if nomeattr='BITPOS' then
             try
                x.BiTpos:=strtoint(nodo.AttributeNodes[k].NodeValue);
             except
                on e:exception do
                begin
                   x.xtype:='UNKNOW';
                   if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                       writelogerr('Error read getProprietaNodo  BITPOS node xml <'+nodo_xml+'> err:'+e.Message );;
                  raise Exception.Create('Error read getProprietaNodo  BITPOS node xml <'+nodo_xml+'> err:'+e.Message );
                end;
             end;
          end;
       end
    end;

    if x.xtype='RECORD' then
    begin
     //  if pos(uppercase('xprova'),uppercase(s1))>0 then
       //   debuZZZ:=1;
       x.llElement:=calcola_ll_variabile(nodo); // calcola_ll_variabile non funziona se non e un record!

       if x.isArray then
       begin
          if (x.llElement mod x.prop_arr.numEle)<>0 then
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                writelogerr('Error read getProprietaNodo  llElement non congruo con num element array node xml <'+nodo_xml+'> ' );;
             raise Exception.Create('Error read getProprietaNodo  llElement non congruo con num element array node xml <'+nodo_xml+'> ' );

          end;
          x.llElement:=x.llElement div x.prop_arr.numEle;
       end
    end
    else
    begin
       if copy(x.xtype,1,6)='STRING' then
       begin
          try

            x.llElement:=calc_LL_from_tipo_plc('STRING',self.Linfoplc.PLCProtocol);
            x.llSTRING:=DecodellString(x.xtype);
            x.llElement:=x.llElement+x.llSTRING;
            x.xtype:='STRING';
            x.BiTpos:=-1;
          except
            on e:exception do
            begin
              if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                       writelogerr('Errore getProprietaNodo  parametri stringa <' + nodo_xml + '> ' + e.Message);
              raise Exception.Create('Errore getProprietaNodo  parametri stringa <' + nodo_xml + '> ' + e.Message);
            end;
          end;
       end
       else
       begin
          if copy(x.xtype,1,7)='WSTRING' then
          begin
            try
               x.llElement:=calc_LL_from_tipo_plc('WSTRING',self.Linfoplc.PLCProtocol);
               x.llSTRING:=DecodellWideString(x.xtype);
               x.llElement:=(x.llElement)+(x.llSTRING*2);
               x.xtype:='WSTRING';
               x.BiTpos:=-1;
            except
              on e:exception do
              begin
                 if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                    writelogerr('Errore getProprietaNodo  parametri WSTRING <' + nodo_xml + '> ' + e.Message);
                 raise Exception.Create('Errore getProprietaNodo  parametri WSTRING <' + nodo_xml + '> ' + e.Message);
              end;
            end;
          end
          else
          begin
              try
                x.llElement:=calc_LL_from_tipo_plc(x.xtype,self.Linfoplc.PLCProtocol);
              except
                on e:exception do
                begin
                   if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                      writelogerr('Errore getProprietaNodo  calc_LL_from_tipo_plc <' + nodo_xml + '> ' + e.Message);
                   raise Exception.Create('Errore parametri calc_LL_from_tipo_plc <' + nodo_xml + '> ' + e.Message);
                end;
              end;
              if x.xtype<>'BIT' then
                 x.BiTpos:=-1;
              if x.xtype='BIT' then
              begin
                 x.llElement:=1
              end;
          end;
       end;
    end;

    if x.isArray then
    begin
       if x.xtype='BIT' then
         x.llGlobal:=((x.prop_arr.numEle-1) div 8)+1
       else
         x.llGlobal:=x.llElement*x.prop_arr.numEle
    end
    else
    begin
       x.llGlobal:=x.llElement;
    end;
    if x.isArray then
    begin
     (*  if x.xtype<>'BIT' then
      begin
         x.llGlobal:=x.Vsize;
         x.llElement:= x.llGlobal div x.prop_arr.numEle;
         if (x.llElement*x.prop_arr.numEle) <> x.Vsize then
         begin
             writelogerr('ERRORE LETTURA VOFF/VSIZE su array (x.llElement*x.prop_arr.numEle) <> x.Vsize '+nodo.xml);
         end;
      end
      else
      begin
      end;*)
    end
    else
    begin
       x.llElement:=x.Vsize;
       x.llGlobal:=x.llElement;
    end;

    begin
       var calcolaFullPathOfNode_ret:tcalcolaFullPathOfNode_ret;
       calcolaFullPathOfNode_ret:=calcolaFullPathOfNode(nodo);
       x.fullpath         := calcolaFullPathOfNode_ret.fullPaht;
       x.cumulativeOffset := calcolaFullPathOfNode_ret.cumulativeOffset;

    end;
    x.level:=calcolaLevel(x.fullpath);


    result:=x;

    (* type tProprietaNodo=record
     isArray:boolean;
     xtype:string;
     llGlobal:integer;
     llElement:integer;
     minIndex:integer;
     maxIndex:integer;
    end;*)


end;

function is_the_same_path(pathstop:string;pathEleCurr:string):boolean;
var parentPathStop,parentpathEleCurr:string;
    last_point,k:integer;
begin
    last_point:=0;
    for k:=length(pathstop) downto 1 do
    begin
        if pathstop[k]='.' then
        begin
           last_point:=k;
           break;
        end;
    end;
    parentPathStop:=copy(  PathStop,1,last_point);
    last_point:=0;
    for k:=length(pathEleCurr) downto 1 do
    begin
        if pathEleCurr[k]='.' then
        begin
           last_point:=k;
           break;
        end;
    end;
    parentpathEleCurr:=copy(  pathEleCurr,1,last_point);
    if parentPathStop=parentpathEleCurr then
       result:=true
    else
       result:=False;

end;

function removearraydatafromPath(s:string):string;
var k:integer;
    flagin:boolean;
begin
    result:='';
    flagin:=false;
    for k:=1 to length(s) do
    begin
       if s[k]='[' then
         flagin:=true;
       if flagin then
             result:=result+s[k];
       if s[k]=']' then
         flagin:=False;
    end

end;


function tPlcSource.calcolaOffsetPathAndSizeNew(const XpathSearched:string;const startnode:IXMLNode;
                                              var returnNode:IXMLNode;
                                              var returnsize:integer ;
                                              var dati_bit_Singolo:Tdati_bit_Singolo;
                                              var returnAllArrayPath:boolean;
                                              var Error:terror):integer;
var nodeCurr:IXMLNode;
    fine:boolean;
    npCur:tProprietaNodo ;
    level:integer;
    radixCur:string;
    radixSearched:string;
    rPathAndIndexArrayCur:tPathAndIndexArray;
    rPathAndIndexArraySearched:tPathAndIndexArray;
    Trovato:boolean;
    offsetTrovato:integer;
 //   pathstop:string;
    s1,s2:string;
    como:integer;
    pathSearched:string;
    pathsearched_without_array:string;
    byte_of_bit:integer;
    flagPprendoTuttoIlvettore:boolean;
begin
    flagPprendoTuttoIlvettore:=False;
  //   pathstop:=uppercase(pathWithoutArray(pathSearched));
     pathSearched:=uppercase(XpathSearched) ;
     pathsearched_without_array:= pathWithoutArray( pathSearched) ;
     nodeCurr:=startnode.ChildNodes[0];
     s1:=nodeCurr.NodeName;
     offsetTrovato:=0;
     Trovato:=false;
     level:=1;
     rPathAndIndexArraySearched:= extractPathAtLevelAnndIndexArray(pathSearched,level);
     radixSearched:=rPathAndIndexArraySearched.rpath;
     fine:=False;
     while fine=false do
     begin
        s1:=nodeCurr.NodeName;
        npCur:=getProprietaNodo(nodeCurr);
        rPathAndIndexArrayCur:= extractPathAtLevelAnndIndexArray(npCur.fullpath,level);
        radixCur:=rPathAndIndexArrayCur.rpath;
        if uppercase(radixCur)=uppercase(radixSearched) then
        begin
            if npCur.isArray then
            begin
// *******************************************************************************
//             modifica del 8 dic 2021!
//             vecchio codice
             (*
               if pathSearched<>pathsearched_without_array then /// sto cercando un elemento  o  tutto l array ??
               begin
                  if (rPathAndIndexArraySearched.indexArray<npcur.prop_arr.min) or  (rPathAndIndexArraySearched.indexArray>npcur.prop_arr.max) then
                  begin
                    raise Exception.Create('BSX_ERROR '+nodeCurr.NodeName+'['+rPathAndIndexArraySearched.indexArray.ToString+'] out of bounds !');
                  end;
               end;
               *)

//             nuovo codice

               if not sametext(npcur.fullpath,pathsearched_without_array) then /// sto cercando un elemento  o  tutto l array ??
               begin
                  if (rPathAndIndexArraySearched.indexArray<npcur.prop_arr.min) or  (rPathAndIndexArraySearched.indexArray>npcur.prop_arr.max) then
                  begin
                    raise Exception.Create('BSX_ERROR '+nodeCurr.NodeName+'['+rPathAndIndexArraySearched.indexArray.ToString+'] out of bounds !');
                  end;
               end;
//            fine modifica!
// *******************************************************************************



// *******************************************************************************
//             modifica del 8 dic 2021!
//             vecchio codice
          (*     if pathSearched=pathsearched_without_array then /// sto cercando un elemento  o  tutto l array ??
               begin
                  como:=0;
                  flagPprendoTuttoIlvettore:=True;
               end
               else
                  como:=rPathAndIndexArraySearched.indexArray-npcur.prop_arr.min;
            *)
//             nuovo codice
               if sametext(npcur.fullpath,pathsearched_without_array) then
               begin
                 if rightStr(trim(pathSearched),1)<>']' then /// sto cercando un elemento  o  tutto l array ??
                 begin
                    como:=0;
                    flagPprendoTuttoIlvettore:=True;
                 end
                 else
                    como:=rPathAndIndexArraySearched.indexArray-npcur.prop_arr.min;
               end
               else
                  como:=rPathAndIndexArraySearched.indexArray-npcur.prop_arr.min;

//            fine modifica!
// *******************************************************************************




              if npcur.xtype='BIT' then
              begin
                 byte_of_bit:=como div 8;
                 offsetTrovato:=offsetTrovato+npcur.Voff+ byte_of_bit; // sommo l'offset dell elemento dell'array che mi interessa
                 dati_bit_Singolo.FLAGBIT_SINGOLO:=true;
                 dati_bit_Singolo.bitpos:=como mod 8;
                 dati_bit_Singolo.byte_of_bit:=byte_of_bit;
              end
              else
              begin
                 offsetTrovato:=offsetTrovato+npcur.Voff+ (npcur.llElement* como); // sommo l'offset dell elemento dell'array che mi interessa
              end;
            end
            else
            begin
               offsetTrovato:=offsetTrovato+npcur.Voff;
            end;
            if uppercase(npCur.fullpath)=pathsearched_without_array then
            begin
               Trovato:=true;
        //       offsetTrovato:=offsetTrovato+npcur.Voff;
               break;
            end;

            inc(level);
            rPathAndIndexArraySearched:= extractPathAtLevelAnndIndexArray(pathSearched,level);
            radixSearched:=rPathAndIndexArraySearched.rpath;
            if nodeCurr.ChildNodes.Count>0 then
               nodeCurr:=nodeCurr.ChildNodes[0]
            else
               break;
        end
        else
        begin
           nodeCurr:=nodeCurr.NextSibling;
           if nodeCurr=nil then
               break;
        end;
     end;
     if trovato then
     begin
        result:=offsetTrovato;
        returnNode:=nodeCurr;
        if npCur.xtype='BIT' then
        begin
           returnsize:=1;
           if npCur.isArray then
           begin
             if flagPprendoTuttoIlvettore=False then
             else
             begin
                 returnsize:=npCur.Vsize;
                 returnAllArrayPath:=True;
             end;
           end
        end
        else
        begin
          if npCur.isArray then
          begin
             if flagPprendoTuttoIlvettore=False then
                 returnsize:=npCur.llElement
             else
             begin
                returnsize:=npCur.Vsize;
                returnAllArrayPath:=True;
             end;
          end
          else
             returnsize:=npCur.Vsize;
        end;
        error.error:=BSXE_ALL_OK;
        error.errors:='';
     end;
end;

//////////////// non piu usata!
function tPlcSource.calcolaOffsetPathAndSize1(const startOffset:integer ;const path:string;
                                       const pathStop:string;
                                       const startnode:IXMLNode;
                                       const level:integer;
                                       var returnNode:IXMLNode;
                                       var returnsize:integer):integer;
var tipo:string;
    OFFSET:integer;
    llnodo:integer;
    k,j:integer;
    chidnode:IXMLNode;
 //   mul:integer;
 //   MULS:STRING;
    nodename:string;
 //   nomeattr:string;
    radix:string;
    radixSearched:string;
//    p:integer;
    trovato:boolean;
    flagPatharray:boolean;
    radixIndexarray:integer;
//    FullPathOfNode:string;
    xarrayminmax:TarrayMinMax;
    flagInPath:boolean;
    rPathAndIndexArray:tPathAndIndexArray;
    rPathAndIndexArraySearched:tPathAndIndexArray;
//    llnodoRec:integer;
    llRec:integer;
//    llArr:integer;
    np:tProprietaNodo ;
    como:integer;
    levelPathStop:integer;
begin
    OFFSET:=startOffset;
    levelPathStop:=calcolaLevel(pathStop)  ;
    ///  sCendo nei livelli e prendo gli offset dei vari campi solo se sono sul ramo del path!
    ///  SE E UN ARRAY CALCOLO OFFSET + LL LUNGHEZZA ELEMENTO ARRAY

     rPathAndIndexArray:= extractPathAtLevelAnndIndexArray(path,level);
     radix:= rPathAndIndexArray.rpath;
     radixIndexarray:=rPathAndIndexArray.indexArray;
     if radixIndexarray>-1 then
     begin
        flagPatharray:=True;
     end
     else
     begin
        flagPatharray:=False;
     end;


    trovato:=False;
    for k := 0 to startnode.ChildNodes.Count-1 do
    begin
       llnodo:=0;
       tipo:='';
       chidnode:=startnode.ChildNodes[k];
       nodename:=chidnode.NodeName;
       if copy(nodename,1,1)='#' then  // salto commenti!
          continue;
       np:=getProprietaNodo(chidnode);
       if np.xtype=''  then
       begin
          raise Exception.Create('BSX_ERRORE MANCA TYPE_ON_PLC !! ');
       end;
       flagInPath:=is_the_same_path(pathStop,np.fullpath);
       
(*       if  np.fullpath=copy(pathStop,1,length(np.fullpath)) then
       begin
          flagInPath:=true;
       end
       else
       begin
          flagInPath:=False;
       end;
*)
       
       if not flagInPath then
       begin
          // non e  l elemento che mi interessa! //   ll:=ll+np.llGlobal;
        //  OFFSET:=OFFSET+np.Voff;          
       end
       else
       begin
         // trovato:=true;
          if np.isArray<>flagPatharray then
          begin
             if flagPatharray then
                raise Exception.Create('BSX_ERROR '+chidnode.NodeName+' IS NOT ARRAY !')
             else
                raise Exception.Create('BSX_ERROR '+chidnode.NodeName+' IS AN ARRAY !');
          end;
          if np.isArray then
          begin
             if (radixIndexarray<np.prop_arr.min) or  (radixIndexarray>np.prop_arr.max) then
             begin
                raise Exception.Create('BSX_ERROR '+chidnode.NodeName+'['+radixIndexarray.ToString+'] out of bounds !');
             end;
             //
            como:=radixIndexarray-np.prop_arr.min;
            OFFSET:=OFFSET+np.Voff+ (np.llElement* como); // sommo l'offset dell elemento dell'array che mi interessa
          end
          else
          begin
             OFFSET:=OFFSET+np.Voff;
          end;
          if np.fullpath=pathStop then
          begin
             returnsize:=np.llElement;
           //  OFFSET:=OFFSET+np.Voff; li ho gia sommati prima, sia che sia un array, sia singolo;
             returnNode:=chidnode;
             trovato:=true;
             break;
          end;
          if np.xtype='RECORD' then
          begin
               // { TODO : DA VEIFICARE! }
                                                    // metto 0 perche ho gia tenuto conto dell offset a cui e il record!!!!
            OFFSET:=OFFSET+calcolaOffsetPathAndSize1(0, path,pathStop,chidnode,level+1,returnNode,returnsize);
          end
          else
          begin
//             offset:= offset+np.Voff; se e singolo lo gia sommato prima
          end;
         // break;
       end;
    end;
    if trovato=false then
    begin
     if flagInPath then
         raise Exception.Create('PATH NOT FOUND');
    end;
    result:=OFFSET;
end;


function tPlcSource.calcola_ll_variabile(nodo:IXMLNode):integer;
var tipo:string;
    ll:integer;
    llnodo:integer;
    k,j:integer;
    chidnode:IXMLNode;
    mul:integer;
    MULS:STRING;
    nodename:string;
    nomeattr:string;
    como:string;
   // np:tProprietaNodo;
  //   non posso richiamare getProprietaNodo perche entro in ricursiva!
    voff:integer;
    childnodeLast:IXMLNode;
    xtype:string;
    bitPos:integer;
    arrayData:string;
    arrayLimit:TarrayMinMax;
    childnodeLast_xml,nodo_xml:string;
    
begin
    try
       nodo_xml:=nodo.xml;
    except
       on e:exception do
       begin
          nodo_xml:=' Error retrieve xml err<'+e.Message+'>';
       end;
    end;
///  questa funzione usa l offset della ultima variabile sulla struttura
///  e gli sommma VSIZE ma se e la variablie e un bit si basa sul
///  numero del bit per calcolare quanto e lunga, siccome ogni bit ha un vsize di 1
///
    bitPos:=-1;
    ll:=0;
    if nodo=self.root_defVar then
    begin
       childnodeLast:=nodo.ChildNodes.Last;

       
       if childnodeLast=nil then
       begin
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
             writelogerr('ERRORE LETTURA in calcola_ll_variabile() self.root_defVar non ha child '+nodo_xml);
          raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() self.root_defVar non ha child '+nodo_xml);
          ll:=0;
       end
       else
       begin
          try 
             childnodeLast_xml:=childnodeLast.xml;
          except
             on e:exception do
             begin
                nodo_xml:=' Error retrieve xml err<'+e.Message+'>';
             end;
          end;   
            
          if childnodeLast.HasAttribute('VOFF') then
          begin
             try
               voff:=childnodeLast.Attributes['VOFF'];
             except
                voff:=0;
                if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                   writelogerr('ERRORE LETTURA in calcola_ll_variabile() VOFF '+childnodeLast_xml);
                raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() VOFF '+childnodeLast_xml);   
             end;
          end
          else
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                 writelogerr('ERRORE LETTURA in calcola_ll_variabile() VOFF non ha attributo VSIZE '+childnodeLast_xml);
             raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() VOFF non ha attributo VSIZE '+childnodeLast_xml);    
             voff:=0;
          end;
          llnodo:=calcola_ll_variabile(childnodeLast);
          ll:=llnodo+voff;
       end;
(*       for k := 0 to nodo.ChildNodes.Count-1 do
       begin
          llnodo:=calcola_ll_variabile(nodo.ChildNodes[k]);
          ll:=ll+llnodo;
       end;*)
    end
    else
    begin
       if nodo.HasAttribute('TYPE_ON_PLC') then
       begin
          try
              xtype:=nodo.Attributes['TYPE_ON_PLC'];
          except
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                 writelogerr('ERRORE LETTURA in calcola_ll_variabile() TYPE_ON_PLC '+nodo_xml);
             raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() TYPE_ON_PLC '+nodo_xml);
                 
          end;
       end
       else
       begin
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
              writelogerr('ERRORE LETTURA in calcola_ll_variabile() non ha attributo TYPE_ON_PLC '+nodo_xml);
          raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() non ha attributo TYPE_ON_PLC '+nodo_xml);    
          ll:=0;
       end;
       if xtype='BIT' then
       begin
          if nodo.HasAttribute('ARRAY') then
          begin
             arrayData:=nodo.Attributes['ARRAY'];
             arrayLimit:=decodeArrayAttributeMINMAX(arrayData);
             if arrayLimit.numEle=0 then
             begin
               if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                  writelogerr('ERRORE LETTURA in calcola_ll_variabile() BIT ARRAY DIMENSIONE 0! '+nodo_xml);
               raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() BIT ARRAY DIMENSIONE 0! '+nodo_xml);
                  
             end
             else
             begin
                ll:=((arrayLimit.numEle-1) DIV 8)+1 ;
             end;
          end
          else
          begin
             arrayLimit.numEle:=0;
          end;
          if arrayLimit.numEle=0 then
          begin
             if nodo.HasAttribute('BITPOS') then
             begin
                try
                  bitPos:=strtoint(nodo.Attributes['BITPOS']);
                   ll:=((bitPos) DIV 8) +1 ;
                except
                   if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                       writelogerr('ERRORE LETTURA in calcola_ll_variabile() BITPOS '+nodo_xml);
                   raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() BITPOS '+nodo_xml);
                end;
             end
             else
             begin
                if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                    writelogerr(' ERRORE LETTURA in calcola_ll_variabile() non ha attributo BITPOS '+nodo_xml);
                raise Exception.Create(' ERRORE LETTURA in calcola_ll_variabile() non ha attributo BITPOS '+nodo_xml);
                    
             end;
          end;
       end;
       if xtype<>'BIT' then
       begin
          if nodo.HasAttribute('VSIZE') then
          begin
             try
                 como:=nodo.Attributes['VSIZE'];
                 ll:=strtoint(como);
             except
                ll:=0;
                if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                   writelogerr('ERRORE LETTURA in calcola_ll_variabile() VSIZE '+nodo_xml);
                raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() VSIZE '+nodo_xml);
             end;
          end
          else
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                writelogerr('ERRORE LETTURA in calcola_ll_variabile() non ha attributo VSIZE '+nodo_xml);
             raise Exception.Create('ERRORE LETTURA in calcola_ll_variabile() VSIZE '+nodo_xml);   
                
             ll:=0;
          end;
       end;
    end;
    result:=ll;
    if Linfoplc.PLCProtocol=pkBeckhoffADS then
    begin
       // if True then

    end;

  (*  for k := 0 to node.ChildNodes.Count-1 do
    begin
       llnodo:=0;
       mul:=1;
       muls:='';
       tipo:='';
       chidnode:=node.ChildNodes[k];
       nodename:=chidnode.NodeName;


       if copy(nodename,1,1)='#' then  // salto commenti!
          continue;
       if nodename='assi' then  // salto commenti!
          dummydebug:=1;

       if chidnode.HasAttribute('TYPE_ON_PLC') then
       begin
          try
             tipo:=uppercase(chidnode.Attributes['TYPE_ON_PLC']);
          except
            tipo:='';
          end;
       end;
       if chidnode.HasAttribute('ARRAY') then
       begin
          try
             MULS:=uppercase(chidnode.Attributes['ARRAY']);
             MUL:=decodeArrayAttribute(MULS);
          except
              writelogerr('Attributes ARRAY  may be wrong! <'+node.xml +'>');
              muls:='';
              mul:=1;
          end;
       end;

       for j := 0 to chidnode.AttributeNodes.Count-1 do
       begin
           nomeattr:=uppercase(chidnode.AttributeNodes[j].NodeName);
           if nomeattr='TYPE_ON_PLC' then
           begin
              tipo:=uppercase(chidnode.AttributeNodes[j].NodeValue);
           end;
           if nomeattr='ARRAY' then
           begin
              try
                if nomeattr<>'' then
                begin
                   MULS:=uppercase(chidnode.AttributeNodes[j].NodeValue);
                   MUL:=decodeArrayAttribute(MULS);
                end;
              except
                muls:='';
                mul:=1;
              end;
           end;
       end;

       if tipo<>'' then
       begin
          if tipo='RECORD' then
          begin
              llnodo:=calcola_ll_variabile(chidnode);
          end
          else
          begin

             if copy(tipo,1,6)='STRING' then
             begin
                llnodo:=calc_LL_from_tipo_beckoff('STRING');
                llnodo:=llnodo+DecodellString(tipo);
             end
             else
             begin
                llnodo:=calc_LL_from_tipo_beckoff(tipo);
             end;
          end
       end
       else
       begin
          raise Exception.Create('ERRORE MANCA TYPE_ON_PLC !! on <'+node.XML+'>');
       end;
       ll:=ll+ (llnodo * mul);
    end;
    result:=ll;*)
end;


procedure tPlcSource.Check_xml;
var k:integer;
    node:IXMLNode;
    np:tProprietaNodo ;
     llsotto:integer;
     llTot:integer;
    s:string;
    s1:string;
begin
   llsotto:=0;
   try
      for k := 0 to root_defVar.ChildNodes.Count-1 do
      begin
         node:=root_defVar.ChildNodes[k];
         s1:=node.NodeName;
         if s1='CndStart' then
            dummydebug:=1;
         if s1='EncoderReset' then
            dummydebug:=1;


         try
             np:= getProprietaNodo(node);
         except
            on e:exception do
               raise Exception.Create('Error on node<'+s1+' on get property'+e.message);
         end;

         try
            llsotto:=Check_xml_0(node);
         except
            on e:exception do
               raise Exception.Create('Error on node<'+s1+' on explore tree '+e.message);
         end;

         if llsotto<>-1 then
         begin
            if np.isArray then
               llSotto:=llSotto*np.prop_arr.numEle;

            if np.Vsize< llSotto then
               raise Exception.Create('Error on node<'+s1+' ll<'+np.Vsize.ToString+'> non congrua con sottolementi ll<'+llsotto.ToString+'>');
         end;
         llTot:=llTot+np.vsize;
         if Linfoplc.PLCProtocol = TProtocolKind.pkBeckhoffADS then
         begin
            lltot:=np.Voff+np.llGlobal;
         end;
      end;

      if llTot > self.fInfo.LLBuf then
        raise Exception.Create('Error LL da Elementi,'+llTot.ToString+'> supera ll su DS<'+self.fInfo.LLBuf.ToString+'>');

   except
       raise
   end;


end;

function tPlcSource.Check_xml_0(nodesup:IXMLNode):integer;
var k,llSotto:integer;
    node:IXMLNode;
    np:tProprietaNodo;
    s:string;
    s1:string;
    last_bit_offsetGiaSommato:integer;
begin
   s:=nodesup.NodeName;
   result:=0;
   if nodesup.ChildNodes.Count=0 then
   begin
     result:=-1;
     exit;
   end;
   last_bit_offsetGiaSommato:=-1;
   for k:=0 to nodesup.ChildNodes.Count-1 do
   begin
      llSotto:=0;
      node:=nodesup.ChildNodes[k];
      s1:=node.NodeName;
      np:=getProprietaNodo(node);
      llSotto:=Check_xml_0(node);
      if llSotto<>-1 then
      begin
       //  if self.Linfoplc.PLCProtocol=PLCProtocol_siemens then
       //  begin

       //  end
         if np.isArray then
            llSotto:=llSotto*np.prop_arr.numEle;

         if np.Vsize<llSotto then
            raise Exception.Create('elem '+node.NodeName+'  Error ll record<'+np.llGlobal.tostring+'> diverso da somma dei componenti<'+llSotto.ToString+'>');
      end;
  (*    if np.xtype='BIT' then
      begin
        if last_bit_offsetGiaSommato<>np.Voff then
        begin
           last_bit_offsetGiaSommato:=np.Voff;
           result:=result+1;
        end
      end
      else*)
      begin
        result:=np.Voff+np.Vsize;
        last_bit_offsetGiaSommato:=-1;
      end;
   end;

end;


function tPlcSource.createjsonString(const bufferData:tarrayOfByte):string;
var offsetBuffer:integer;
begin
  offsetBuffer:=0;
  result:=createjsonString1(self.root_defVar,offsetBuffer,bufferData);
end;

function tPlcSource.createjsonString1(node:IXMLNode;var offsetBuffer:integer;const bufferData:tarrayOfByte):string;
var s:string;
begin
    result:='{'+createjsonString2(node,offsetBuffer,bufferData)+'}';
end;

function tPlcSource.createjsonString2(node:IXMLNode;const  offsetBuffer_iniziale:integer;const bufferData:tarrayOfByte):string;
var s:string;
   // llnodo:integer;
    k,j:integer;
    childnode:IXMLNode;
    nodename:string;
  offset:integer;
  e: Integer;
  flagPrimo:boolean;
  np:tProprietaNodo;
  rconv:DatoToJstring_back;
  elex:integer;
  comoOff:integer;
  byte_of_bit:integer;
begin
    s:='';
    flagPrimo:=true;
    offset:=offsetBuffer_iniziale;
    for k := 0 to node.ChildNodes.Count-1 do
    begin
       childnode:=node.ChildNodes[k];
       nodename:=childnode.NodeName;
       if copy(nodename,1,1)='#' then  // salto commenti!
          continue;
       if uppercase(nodename)='POS_Z' then  // salto commenti!
          dummydebug:=1;
       np:=getProprietaNodo(childnode);
       if np.xtype='RECORD' then
       begin
          if not np.isArray then
          begin
             if flagPrimo then flagprimo:=False else s:=s+',';
             comoOff:=np.Voff+offsetBuffer_iniziale;
             s:=s+'"'+nodename+'":{'+createjsonString2(childnode,comoOff,bufferData)+'}';
          end
          else
          begin
             for e:= 0 to np.prop_arr.numEle-1  do
             begin
                comoOff:=np.Voff+offsetBuffer_iniziale+(e*np.llElement);
                if e=0 then
                begin
                   if flagPrimo then flagprimo:=False else s:=s+',';
                   s:=s+'"'+nodename+'":[{'+createjsonString2(childnode,comoOff,bufferData)+'}';
                end
                else
                begin
                   s:=s+',{'+createjsonString2(childnode,comoOff,bufferData)+'}';
                end;
                offset:=offset+np.llElement;// se e un vettore incremento di un elemento ad ogni giro // rconv.newoff;
             end;
             s:=s+']' ;
          end;
       end
       else
       begin
          if  np.isArray=false then
          begin
             comoOff:=np.Voff+offsetBuffer_iniziale;
             rconv:=DatoToJstring(np,bufferData,comoOff);
             if flagPrimo then flagprimo:=False else s:=s+',';
            // s:=s+rconv.value;
             s:=s+'"'+nodename+'":'+rconv.value;// le virgolette doppie le mette gia +DatoToJstring in caso di stringa!//  '"'+rconv.value+'"';
            // offset:=rconv.newoff;
          end
          else
          begin
             elex:=np.prop_arr.numEle-1;
             for e := 0 to elex do
             begin
                comoOff:=np.Voff+offsetBuffer_iniziale+(e*np.llElement);
                if np.xtype='BIT' then
                begin
                   byte_of_bit:= e div 8;
                   comoOff:=np.Voff+offsetBuffer_iniziale+byte_of_bit;
                   np.BiTpos:=e mod 8;
                end;
                rconv:=DatoToJstring(np,bufferData,comoOff);
                if e=0 then
                begin
                   if flagPrimo then flagprimo:=False else s:=s+',';
                      s:=s+'"'+nodename+'":['+rconv.value// da gestire array
                end
                else
                begin
                   s:=s+','+ rconv.value;//a gestire array
                end;
             end;
             s:=s+']';
          end;
       end;
    end;
   // offsetBuffer:=offset;
    result:=s;
end;
type TreadSingleDatoFromBuffAndconvertTostring_back=record
    value:string;
    newoff:integer;
end;
function tPlcSource.DatoToJstring(const np:tProprietaNodo;
                                                             const bufferData:tarrayOfByte;
                                                             const offset:integer): DatoToJstring_back;
var lldato:integer ;
    buffdato:tarrayOfByte;
    datos:string;
    tipoDatoDINT:integer;
    tipoDatoINT:smallint;
    tipoDatoWORD:word;
    tipoDatoBYTE:Byte;
    tipoDatoUDINT:cardinal;
    tipoDatoREAL:single;
    tipoDatoUSINT:Shortint ;
    eleDt:cardinal;
    dtdelphi:tdatetime;
     eletime:cardinal;
     tipoDatoLREAL:double;
     ELAB:BOOLEAN;
     xint64:int64;
     xUint64:Uint64;
     xguid:System.TGUID;
     buf16bit:array[0..1] of BYTE;
     byte_of_bit:integer;
     bitpos:integer;
     newbitpos:integer;
     bitset:boolean;
begin
    ELAB:=false;
//    ='@BYTE=1,@BOOL=1,@SINT=1,@USINT=1,
//      @WORD=2, @INT=2,@UINT=2,
//
//   @STRING=1,
//    @DATETIME=4,@TIME=4,
//      @DWORD=4,@DINT=4,@UDINT=4,@REAL=4,
//    @LREAL=8';

   lldato:=np.llElement;// . //calc_LL_from_tipo_beckoff('STRING');
   setlength(buffdato,lldato);
   move(bufferData[offset],buffdato[0],lldato);
   datos:='';
   if np.xtype='STRING' then
   begin
      datos:='"'+decodebuffToStringjsonFormat(buffdato)+'"';
      ELAB:=True;
   end
   else
   begin
      /////////////// da fare  { TODO : SIEMENS DA FARE } esiste su siemens??
      if np.xtype='WSTRING' then
      begin
         if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
         begin
            datos:='"'+decodebuffToWIDEStringjsonFormat(buffdato)+'"';
            ELAB:=True;
         end;
      end
      else
      begin
         case np.llElement of
            4:// @DINT=4, - @UDINT=4, @DWORD=4- ,@DATETIME=4,@DT=4,@DATE_AND_TIME=4 - @TIME=4,@REAL=4,
            begin
                if np.xtype='DINT' then
                begin
                   if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                   begin
                      move(buffdato[0],tipoDatoUDINT,lldato);
                      tipoDatoUDINT:=BSwap32(tipoDatoUDINT); //BUG OVERFLOW RISOLTO 07/03/2022
                      move(tipoDatoUDINT,tipoDatoDINT,lldato);
                   end
                   else
                   begin
                      move(buffdato[0],tipoDatoDINT,lldato);
                   end;
                   datos:=tipoDatoDINT.ToString;
                   ELAB:=True;
                end
                else
                begin
                   if (np.xtype='UDINT') or (np.xtype='DWORD')   then
                   begin
                      move(buffdato[0],tipoDatoUDINT,lldato);
                      if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                      begin
                         tipoDatoUDINT:=BSwap32(tipoDatoUDINT);
                      end;
                      datos:=tipoDatoUDINT.ToString;
                      ELAB:=True;
                   end
                   else
                   begin
                      if (np.xtype='REAL') then
                      begin
                         move(buffdato[0],tipoDatoREAL,lldato);
                         if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                         begin
                            move(buffdato[0],tipoDatoUDINT,lldato);
                            tipoDatoUDINT:=BSwap32(tipoDatoUDINT);
                            move(tipoDatoUDINT,tipoDatoREAL,4);
                         end;
                         datos:=formatfloat('###############0.000000',tipoDatoREAL);
                         datos:='"'+datos+'"';
                          ELAB:=True;
                //         datos:=stringreplace(datos,',','.',[rfReplaceAll]);
                      end
                      else
                      begin
                         /////////////// da fare  { TODO : SIEMENS DA FARE }
                         if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
                         begin
                           if (np.xtype='DATETIME') OR (np.xtype='DT') OR (np.xtype='DATE_AND_TIME')   then
                           begin
                              move(buffdato[0],eleDt,lldato);
                              dtdelphi:=beckhoff_DT_To_DateTime(eleDt);
                              datos:=formatfloat('###############0.00000000',System.Math.roundto(dtdelphi,-8));
                              datos:='"'+datos+'"';
                              ELAB:=True;
                             // datos:=formatdatetime('YYYYMMDDHHNNSSZZZ',dtdelphi);
                           end
                           else
                           if (np.xtype='TIME') then
                           begin
                              move(buffdato[0],eletime,lldato);
                              datos:=eletime.ToString;
                              ELAB:=True;
                           end
                         end
                         else
                         begin
                           if (np.xtype='TIME') then
                           begin
                             move(buffdato[0],tipoDatoUDINT,lldato);
                             tipoDatoUDINT:=BSwap32(tipoDatoUDINT);
                             move(tipoDatoUDINT,tipoDatoDINT,lldato);
                             datos:= tipoDatoDINT.ToString;
                             (*
                             dtdelphi := tipoDatoUDINT /(SecsPerDay*1000.0);
                             datos:=formatfloat('###############0.00000000',System.Math.roundto(dtdelphi,-8));
                             datos:='"'+datos+'"';
                             *)
                             ELAB:=True;
                           end;
                         end;
                      end;
                   end;
                end;
            end;
            2: // @INT=2,@UINT=2,@WORD=2,
            begin
                if np.xtype='INT' then
                begin
                   move(buffdato[0],tipoDatoINT,lldato);
                   if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                   begin
                      move(tipoDatoINT,buf16bit[0],2);
                      tipoDatoBYTE:=buf16bit[0];buf16bit[0]:=buf16bit[1];buf16bit[1]:=tipoDatoBYTE;
                      move(buf16bit[0],tipoDatoINT,2);
                   end;
                   datos:=tipoDatoINT.ToString;
                   ELAB:=True;
                end
                else
                begin
                   if (np.xtype='UINT') or (np.xtype='WORD')   then
                   begin
                      move(buffdato[0],tipoDatoWORD,lldato);
                      if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                      begin
                         move(tipoDatoWORD,buf16bit[0],2);
                         tipoDatoBYTE:=buf16bit[0];buf16bit[0]:=buf16bit[1];buf16bit[1]:=tipoDatoBYTE;
                         move(buf16bit[0],tipoDatoWORD,2);
                      end;
                      datos:=tipoDatoWORD.ToString;
                      ELAB:=True;
                   end
                end;
            end;
            1:// '@BYTE=1,@BOOL=1,@SINT=1,@USINT=1,
            begin
               if (np.xtype='BYTE') or (np.xtype='BOOL') or  (np.xtype='USINT') then
               begin
                  move(buffdato[0],tipoDatoBYTE,lldato);
                  datos:=tipoDatoBYTE.ToString;
                  ELAB:=True;
               end
               else
               begin
               if np.xtype='USINT' then
                  begin
                     move(buffdato[0],tipoDatoUSINT,lldato);
                     datos:=tipoDatoUSINT.ToString;
                     ELAB:=True;
                  end
                  else
                  begin
                     if np.xtype='BIT' then
                     begin
                        bitpos:=np.BiTpos;
                        byte_of_bit:=(bitpos) div 8;
                        newbitPos:=bitpos - (byte_of_bit * 8) ;
                        move(buffdato[byte_of_bit],tipoDatoBYTE,1);
                        bitset:=(tipoDatoBYTE and (1 shl newbitPos)) <> 0;
                        if bitset then datos:='1' else datos:='0' ;
                        ELAB:=True;
                     end;
                  end;
               end;
            end;
            8:// @LREAL=8,@LINT=8,@POINTER=8,@REFERENCE=8,@UXINT=8, @DATETIME(Siemens)
                         /////////////// da fare  { TODO : SIEMENS DA FARE }
             if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
             begin
               if (np.xtype='LREAL') then
               begin
                  move(buffdato[0],tipoDatoLREAL,lldato);
                  datos:=formatfloat('###############0.000000',tipoDatoLREAL);
                  //datos:='"'+stringreplace(datos,',','.',[rfReplaceAll])+'"';
                  datos:='"'+tipoDatoLREAL.ToString+'"';
                  ELAB:=True;
               end
               else
               begin
                  if (np.xtype='LINT') then
                  begin
                       move(buffdato[0],xint64,lldato);
                       datos:=xint64.ToString;
                       ELAB:=True;
                  end
                  else
                  begin
                     if (np.xtype='POINTER') or (np.xtype='REFERENCE') or (np.xtype='UXINT') then
                     begin
                       move(buffdato[0],xUint64,lldato);
                       datos:=xUint64.ToString;
                       ELAB:=True;
                     end
                  end;
               end;
             end
             else
             begin
               if (np.xtype='DATETIME') OR (np.xtype='DT') OR (np.xtype='DATE_AND_TIME')   then
               begin
                  //move(buffdato[0],tipoDatoLREAL,lldato);
                  dtdelphi:= snap7.S7.ValDateTime[@buffdato[0]];
                  datos:=formatfloat('###############0.000000000',dtdelphi);
                  //datos:='"'+stringreplace(datos,',','.',[rfReplaceAll])+'"';
                  datos:='"'+datos+'"';
                  ELAB:=True;
               end
             end;
            16: // @GUID=16
             /////////////// da fare  { TODO : SIEMENS DA FARE }
             if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
             begin
                if (np.xtype='GUID')  then
                begin
                    move(buffdato[0],xguid,lldato);
                    datos:=xguid.ToString;
                    ELAB:=True;
                end;
             end;
         end;
      end;
//
//
//    ,';
//   ,,

   end;
   if not ELAB then
   begin
     if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
         writelogerr('Errore DatoToJstring '+ np.xtype+' NON TROVATO!!!!!!!!!!!!!' );
     raise exception.Create('Errore DatoToJstring '+ np.xtype+' NON TROVATO!!!!!!!!!!!!!' );
   end;
   result.value:=datos;
   Result.newoff:=offset+lldato;
end;



function tPlcSource.moveVariantToArrayOfByte(const v:variant;
                                      const startnode:ixmlnode;
                                      const llbuffer:integer):tarrayOfbyte;
//////////////////////////////////////////////////////////
///  questa funziona solo se il nodo passato e un record o il root_defVar!!!
/////////
var
    offset:integer;
    DataBuf:tarrayofbyte;

begin
    offset:=0;  //     sempre a 0 , e quando vado a scriverlo sul plc che uso un offset(nel caso di siemens)
    SetLength(DataBuf,llbuffer);
    FillZero(DataBuf[0],llbuffer);
   // if self.root_defVar<>startnode then
    //   npfather:=getProprietaNodo(startnode);
  //  else
  //     npfather:=getProprietaNodo(startnode)

    WriteBufferFromVariant(v,startnode,offset,DataBuf,0,self.root_defVar);
    result:=DataBuf;
end;

function tPlcSource.moveVariantToArrayOfByteByPath(const v:variant;
                                      const startnode:ixmlnode;
                                      const llbuffer:integer;
                                      Var DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;
                                      AllArrayPath:boolean):tarrayOfbyte;
//////////////////////////////////////////////////////////
///  questa funziona solo se il nodo passato e un record o un elemento Foglia !!!
/////////
var
    offset:integer;
    DataBuf:tarrayofbyte;
begin
    offset:=0;  //     sempre a 0 , e quando vado a scriverlo sul plc che uso un offset(nel caso di siemens)
    SetLength(DataBuf,llbuffer);
    FillZero(DataBuf[0],llbuffer);
    WriteBufferFromVariantByPath(v,startnode,offset,DataBuf,DATI_BIT_SINGOLO,AllArrayPath);
    result:=DataBuf;
end;



function tPlcSource.pathWithoutArray(const path: string): string;
var inArray:boolean;
    xresult:string;
    k:integer;
    c:char;
begin
   inArray:=False;
   xresult:='';
   for k:=1 to length(path)  do
   begin
      c:= path[k];
      if c='[' then
      begin
         inarray:=true
      end
      else
      begin
         if c=']' then
         begin
            inarray:=False
         end
         else
         begin
            if inarray=False then
               xresult:=xresult+c;
         end
      end;
   end;
   result:=xresult;
end;
procedure tPlcSource.WriteBufferFromVariant(v:variant;
                                     node:IXMLNode;
                                     var offsetBuffer:integer;
                                     var DataBuf:tarrayofbyte ;
                                     offsetVett:integer;
                                     const StartNode:IXMLNode
                                     );
var s:string;
    k,j:integer;
    childnode:IXMLNode;
    nodename:string;
    offset:integer;
    lldato:integer;
    e: Integer;
    v2,v3:variant;
    vELEARRAY:variant;
    np:tProprietaNodo;
   // npprec:tProprietaNodo;
  //  nppadre:tProprietaNodo;
    byte_of_bit:integer;
  //  childNodeprec:IXMLNode;


                        /// da rivedere e aggiustare con nuove func sui nodi!
begin
    s:='';
    offset:=offsetBuffer;


   // nppadre:=getProprietaNodo(node);
   // childNodeprec:=nil;
    for k := 0 to node.ChildNodes.Count-1 do
    begin
       childnode:=node.ChildNodes[k];
       nodename:=childnode.NodeName;
       if copy(nodename,1,1)='#' then  // salto commenti!
          continue;

       if nodename='start' then  // salto commenti!
          dummydebug:=1;




       np:=getProprietaNodo(childnode);
       if StartNode <> root_defVar then
       begin
         np.cumulativeOffset:= calcolaRelativeOffsetOfNode(childnode,StartNode);
       end;




       if np.xtype='RECORD' then
       begin
          if np.isArray=False then
          begin
             TDocVariantData(v).GetValueByPath(nodename, V2);
             WriteBufferFromVariant(v2,childnode,offset,DataBuf,offsetVett,StartNode)
          end
          else
          begin
             var xxx:TDocVariantData;
             xxx.InitJSON(v);
             xxx.GetValueByPath(nodename,v2);
             //TDocVariantData(v).GetValueByPath(nodename, V2);
             var newoffsetVett:integer;
             for e:= 0 to np.prop_arr.numEle-1  do
             begin
                newoffsetVett:= e * np.llElement;
                vELEARRAY:=TDocVariantData(v2).values[e];
                WriteBufferFromVariant(vELEARRAY,childnode,offset,DataBuf,offsetVett+newoffsetVett,StartNode)
             end;
          end;
       end
       else
       begin
          lldato:=np.llElement;
          var xxx:TDocVariantData;
          xxx.InitJSON(v);
          xxx.GetValueByPath(nodename,v2);
//          TDocVariantData(v).GetValueByPath(nodename, V2);
//          TDocVariantData(v).GetValueByPath(nodename, V2);
          if np.isArray=false then
          begin
             if np.xtype='BIT' then
             begin
               if np.Voff>offset then
                  offset:=np.Voff;
             end;
//             modifica di prova!!!  //  ma da testare

                offset:=np.cumulativeOffset+offsetVett;
//            fine  modifica di prova!!!


             moveSingleDatoVariantToBuffer(v2,np,databuf,offset);
             if np.xtype<>'BIT' then
                offset:=offset+lldato;
          end
          else
          begin
             if np.xtype='BIT' then
             begin
                for e := 0 to np.prop_arr.numEle-1 do
                begin
                  byte_of_bit:= e div 8;
                  np.BiTpos:=e mod 8;
                  vELEARRAY:=TDocVariantData(v2).values[e];
                  moveSingleDatoVariantToBuffer(vELEARRAY,np,databuf,offset+byte_of_bit);
                end;
                offset:=offset+np.llGlobal;
             end
             else
             begin
//             modifica di prova!!!    /// sembra funzionare, ma da testare
                offset:=np.cumulativeOffset+offsetVett;//
                //fine  modifica di prova!!!
                for e := 0 to np.prop_arr.numEle-1 do
                begin
                  vELEARRAY:=TDocVariantData(v2).values[e];
                  moveSingleDatoVariantToBuffer(vELEARRAY,np,databuf,offset+ (e * np.llElement));
//                  offset:=offset+lldato;
                end;
             end;
          end;
        //  childNodeprec:=childnode;
        //  npprec:=np;
       end;


    end;
    offsetBuffer:=offset;
end;

function tPlcSource.moveSingleDatoVariantToBuffer(const v:variant;
                                       const np:tProprietaNodo;
                                             bufferDEst:tarrayofbyte;
                                       const offsetBuf:integer
                                       ):integer;
var
   k,i:integer;
    tipoDatoByte: byte;
    tipoDatoDINT:integer;
    tipoDatoINT:smallint;
    tipoDatoWORD:word;
    tipoDatoUDINT:cardinal;
    tipoDatoREAL:single;
    tipoDatoUSINT:Shortint ;
    eleDt:cardinal;
    dtdelphi:tdatetime;
     eletime:cardinal;
     tipoDatoLREAL:double;
     xint64:int64;
     xUint64:Uint64;

    comodoBuf:tarrayofbyte;
    comos:string;
    convVariantString: string;
    DateS: string;
    TimeS: string;
    p: Integer;
    yyyy,mm,dd,hh,nn,ss,zzz:word;
    buf16bit:array[0..1] of BYTE;
     byte_of_bit:integer;
     bitpos:integer;
     newbitpos:integer;
     bitset:boolean;
     byteOrig:BYTE;
     dataS7:array[1..8] of BYTE;

//    ='@BYTE=1,@BOOL=1,@SINT=1,@USINT=1,
//      @WORD=2, @INT=2,@UINT=2,
//
//   @STRING=1,
//    @DATETIME=4,@TIME=4,
//      @DWORD=4,@DINT=4,@UDINT=4,@REAL=4,
//    @LREAL=8';
        trovato:boolean;
begin   { TODO : aggiungere altri tipi }
   trovato:=False;
   if uppercase(copy(np.xtype,1,6))='STRING' then
   begin
      if v=null then comos:='' else comos:=v;
      if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
      begin
         setlength(comodoBuf,np.llElement);
         String_to_stringBuffer_BK(comos,comodoBuf);
      end;
      if self.Linfoplc.PLCProtocol=pkSiemensS7 then
      begin
         setlength(comodoBuf,np.Vsize);
         fillchar(comodoBuf[0],np.Vsize,0);
         comodoBuf[0]:=np.Vsize-2;
         if  length(comos)>np.Vsize-2 then comos:=copy(comos,1,np.Vsize-2);
         comodoBuf[1]:=length(comos);
         for k := 1 to length(comos) do
             comodoBuf[k+1]:=ord(comos[k]);
      end;
      trovato:=true;
   end
   else
   begin
      if uppercase(copy(np.xtype,1,7))='WSTRING' then
      begin
         if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
         begin
           if v=null then comos:='' else comos:=v;
           setlength(comodoBuf,np.llElement);
           String_to_WidestringBuffer_BK(comos,comodoBuf);
           trovato:=true;
         end;
      end
      else
      begin
          case np.llElement of
             4:
             begin
                 if np.xtype='DINT' then
                 begin
                    tipoDatoDINT:=v;
                    if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                    begin
                      move(tipoDatoDINT,tipoDatoUDINT,np.llElement);
                      //tipoDatoDINT:=BSwap32(tipoDatoDINT); //BUG OVERFLOW RISOLTO 07/03/2022
                      tipoDatoUDINT:=BSwap32(tipoDatoUDINT);
                      setlength(comodoBuf,np.llElement);
                      move(tipoDatoUDINT,comodoBuf[0],np.llElement);
                    end
                    else
                    begin
                      setlength(comodoBuf,np.llElement);
                      move(tipoDatoDINT,comodoBuf[0],np.llElement);
                    end;
                    trovato:=true;
                 end
                 else
                 begin
                    if (np.xtype='UDINT') or (np.xtype='DWORD')   then
                    begin
                        tipoDatoUDINT:=v;
                        if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                        begin
                            tipoDatoUDINT:=BSwap32(tipoDatoUDINT);
                        end;
                        setlength(comodoBuf,np.llElement);
                        move(tipoDatoUDINT,comodoBuf[0],np.llElement);
                        trovato:=true;
                    end
                    else
                    begin
                       if (np.xtype='REAL') then
                       begin
                          tipoDatoREAL:= StrToFloatLocale(v);
                          if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                          begin
                             move(tipoDatoREAL,tipoDatoUDINT,4);
                             tipoDatoUDINT:=BSwap32(tipoDatoUDINT);
                             move(tipoDatoUDINT,tipoDatoREAL,4);
                          end;
                          setlength(comodoBuf,np.llElement);
                          move(tipoDatoREAL,comodoBuf[0],np.llElement);
                          trovato:=true;
                       end
                       else
                       begin
                          if (np.xtype='DATETIME') then
                          begin
                             if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
                             begin
                               dtdelphi:= StrToFloatLocale(v);
                               eleDt:= beckhoff_DateTime_TO_DT(dtdelphi);
                               setlength(comodoBuf,np.llElement);
                               move(eleDt,comodoBuf[0],np.llElement);
                               trovato:=true;
                             end;
                          end
                          else
                          if (np.xtype='TIME') then
                          begin
                                ///////   { TODO : SIEMENS DA FARE }
                             if self.Linfoplc.PLCProtocol=pkBeckhoffADS then
                             begin
                                eletime:=v;
                                setlength(comodoBuf,np.llElement);
                                move(eletime,comodoBuf[0],np.llElement);
                                trovato:=true;
                             end
                             else
                             begin
                                (*
                                convVariantString:= v;
                                p:= pos('T',convVariantString);
                                if p <> 0 then
                                begin
                                  DateS:= copy(convVariantString,1,p-1);
                                  TimeS:= copy(convVariantString,p); 
                                  try dd:= StrToInt(copy(DateS,9,2)); except; dd:= 0; end;
                                  try hh:= StrToInt(copy(TimeS,2,2)); except; hh:= 0; end;
                                  try nn:= StrToInt(copy(TimeS,5,2)); except; nn:= 0; end;
                                  try ss:= StrToInt(copy(TimeS,8,2)); except; ss:= 0; end;
                                  try zzz:= StrToInt(copy(TimeS,11,3)); except; zzz:= 0; end;
                                  if dd > 1 then
                                  begin
                                    yyyy:= 1900;
                                    mm:= 01;
                                    //Dec(dd);
                                  end
                                  else
                                  begin
                                    yyyy:= 1899;
                                    mm:= 12;                              
                                    dd:= 30 + dd;
                                  end;
                                  tipoDatoLREAL:= EncodeDateTime(yyyy,mm,dd,hh,nn,ss,zzz); 
                                end
                                else
                                begin
                                  tipoDatoLREAL:= StrToFloatLocale(convVariantString);
                                end;
                                //eletime:= Round(dtdelphi * (SecsPerDay*1000.0));
                                eletime:= Round(tipoDatoLREAL * (SecsPerDay*1000.0));
                                setlength(comodoBuf,np.llElement);
                                eletime:=BSwap32(eletime);
                                move(eletime,comodoBuf[0],np.llElement);
                                *)
                                tipoDatoDINT:= v;
                                move(tipoDatoDINT,eletime,np.llElement);
                                setlength(comodoBuf,np.llElement);
                                eletime:=BSwap32(eletime);
                                move(eletime,comodoBuf[0],np.llElement);
                                trovato:=true;
                             end;
                          end
                       end;
                    end;
                 end;
             end;
             2:
             begin
                 if np.xtype='INT' then
                 begin
                    tipoDatoINT:=v;
                    setlength(comodoBuf,np.llElement);
                    if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                    begin
                      move(tipoDatoINT,buf16bit[0],2);
                      tipoDatoBYTE:=buf16bit[0];buf16bit[0]:=buf16bit[1];buf16bit[1]:=tipoDatoBYTE;
                      move(buf16bit[0],tipoDatoINT,2);
                    end;
                    move(tipoDatoINT,comodoBuf[0],np.llElement);
                    trovato:=true;
                 end
                 else
                 begin
                    if (np.xtype='UINT') or (np.xtype='WORD')   then
                    begin
                       tipoDatoWORD:=v;
                       setlength(comodoBuf,np.llElement);
                       if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                       begin
                          move(tipoDatoWORD,buf16bit[0],2);
                          tipoDatoBYTE:=buf16bit[0];buf16bit[0]:=buf16bit[1];buf16bit[1]:=tipoDatoBYTE;
                          move(buf16bit[0],tipoDatoWORD,2);
                       end;
                       move(tipoDatoWORD,comodoBuf[0],np.llElement);
                       trovato:=true;
                    end
                 end;
             end;
             1:// BYTE=1,@BOOL=1,@SINT=1,@USINT=1
             begin
                if (np.xtype='BYTE') or (np.xtype='BOOL') or  (np.xtype='USINT') then
                begin
                   tipoDatoBYTE:=v;
                   setlength(comodoBuf,np.llElement);
                   move(tipoDatoBYTE,comodoBuf[0],np.llElement);
                   trovato:=true;
                end
                else
                begin
                   if np.xtype='USINT' then
                   begin
                      tipoDatoUSINT:=v;
                      setlength(comodoBuf,np.llElement);
                      move(tipoDatoUSINT,comodoBuf[0],np.llElement);
                      trovato:=true;
                   end
                   else
                   begin
                      if np.xtype='BIT' then
                      begin
                         bitset:=SIEMENS_BYTE_TO_Boolean(v);
                         bitpos:=np.BiTpos;
                         byte_of_bit:=(bitpos) div 8;
                         if Length(bufferDEst)<offsetBuf+byte_of_bit then
                         begin
                            setlength(bufferDEst,offsetBuf+byte_of_bit);
                            for I := offsetBuf  to offsetBuf+byte_of_bit do
                               bufferDEst[i]:=0;
                         end;
                         newbitPos:=bitpos - (byte_of_bit * 8) ;
                        // setlength(comodoBuf,byte_of_bit);
                        // non uso comodoBuff!!!!
                         byteOrig:=bufferDEst[offsetBuf+byte_of_bit];
                         if bitset then
                            byteOrig:=byteOrig OR (BYTE(1) shl newbitPos)
                         else
                           byteOrig := byteOrig and ((BYTE(1) shl newbitPos) xor High(BYTE));
                         bufferDEst[offsetBuf+byte_of_bit]:=byteOrig;
                        trovato:=true;
                      end
                   end;
                end;
             end;
             8:
              begin
                  if (np.xtype='DATETIME') OR (np.xtype='DT') OR (np.xtype='DATE_AND_TIME') then
                  begin
                    if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                    begin
                      tipoDatoLREAL:= StrToFloatLocale(v);
                      setlength(comodoBuf,np.llElement);
                      snap7.S7.ValDateTime[@dataS7]:= tipoDatoLREAL;
                      move(dataS7[1],comodoBuf[0],8);
                      trovato:=true;
                    end;
                  end;
                  if (np.xtype='LREAL') then
                  begin
                     tipoDatoLREAL:= StrToFloatLocale(v);
                     setlength(comodoBuf,np.llElement);
                     if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                     begin
                       move(tipoDatoLREAL,xUint64,8);
                       xUint64:=BSwap64(xUint64);
                       move(xUint64,tipoDatoLREAL,8);
                     end;
                     move(tipoDatoLREAL,comodoBuf[0],np.llElement);
                     trovato:=true;
                  end
                  else
                  begin
                      if (np.xtype='LINT') then
                      begin
                           xint64:=v;
                           if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                           begin
                               xint64:=BSwap64(xint64);
                           end;
                           move(xint64,comodoBuf[0],np.llElement);
                           trovato:=true;
                      end
                      else
                      begin
                         if (np.xtype='POINTER') or (np.xtype='REFERENCE') or (np.xtype='UXINT') then
                         begin
                           xUint64:=v;
                           if self.Linfoplc.PLCProtocol=pkSiemensS7 then
                           begin
                               xUint64:=BSwap64(xUint64);
                           end;
                           move(xUint64,comodoBuf[0],np.llElement);
                           trovato:=true;
                         end
                      end;
                  end;
              end;
          end;
      end;
   end;
   if not trovato then
   begin
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
         writelogerr('BSXERROR  moveSingleDatoVariantToBuffer Tipo<'+np.xtype+'> non gestito!' );
      raise Exception.Create('BSXERROR  moveSingleDatoVariantToBuffer Tipo<'+np.xtype+'> non gestito!');
   end;
   if Length(bufferDEst)<offsetBuf+np.llElement then
   begin
      setlength(bufferDEst,offsetBuf+np.llElement);
   end;
   if np.xtype<>'BIT' then
      move(comodoBuf[0],bufferDEst[offsetBuf],np.llElement);
end;
///-------------------------------------------------------------
///
///  questa elabora prima il nodo e poi ricorre sui figli
///  che e la situazione in cui mi trovo se devo scrivere buffer a
///  partire da un livello intermedio di un data source (non dalla radice!)
///
procedure tPlcSource.WriteBufferFromVariantByPath(v:variant;node:IXMLNode;var offsetBuffer:integer;var DataBuf:tarrayofbyte;var DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;AllArrayPath:boolean);
var
    np:tProprietaNodo ;
     sdeb:string;
begin


   // WriteBufferFromVariant(v,node,offsetBuffer,DataBuf,0,node);

  // Exit;

    ///////////////////////////

    np:=getProprietaNodo(node);
    if (AllArrayPath) and (np.isArray) then
    begin
       var vELEARRAY:variant;
       var i:integer;
       var  como_off:integer;
       var xxx:TDocVariantData;
       var comoDATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;
       xxx.InitJSON(v);
       como_off:=offsetBuffer;
       for I := 0 to np.prop_arr.numEle-1 do
       begin
          vELEARRAY:=xxx.values[i];
          if np.xtype<>'BIT' then
          begin
             if node.HasChildNodes then
               WriteBufferFromVariant(vELEARRAY,node,offsetBuffer,DataBuf,i * np.llElement,node)
             else
               moveSingleDatoVariantToBuffer(vELEARRAY,np,databuf,i * np.llElement);
//              WriteBufferFromVariantByPath(vELEARRAY,node,como_off,DataBuf,DATI_BIT_SINGOLO,false);
              como_off:=como_off+np.llElement;
          end
          else
          begin
             np.BiTpos:=i;
             moveSingleDatoVariantToBuffer(vELEARRAY,np,DataBuf,como_off);
          end;
       end;
       DATI_BIT_SINGOLO.FLAGBIT_SINGOLO:=False; // se e un array non puo essere un bit singolo
       exit;
    end;



    if np.xtype='BIT' then
    begin
       DATI_BIT_SINGOLO.FLAGBIT_SINGOLO:=TRUE;
       if np.isArray then
         np.BiTpos:=DATI_BIT_SINGOLO.bitpos
       else
         DATI_BIT_SINGOLO.bitpos:=np.BiTpos;
    end;
    if np.xtype='RECORD'  then
    begin
       var offset_from_func_by_path:integer;
       offset_from_func_by_path:=-np.cumulativeOffset-offsetBuffer;
       ////  CONTROLLARE  AGGIUNTO PARAMETRO OFFSETVET, VA A 0 ??????
       ///  arrayA[5].arrayB[3]
       WriteBufferFromVariant(v,node,offsetBuffer,DataBuf,0,node);
    end
    else
    begin
       if (np.xtype='BIT') then
       begin
          moveSingleDatoVariantToBuffer(v,np,DataBuf,offsetBuffer)
       end
       else
       begin
          moveSingleDatoVariantToBuffer(v,np,DataBuf,offsetBuffer);
       end;
    end;
end;
/////////------------------------




/////////
///////////////////////// tplc /////////////////////////////
///
            
constructor tPlc.Create(aowner:tcomponent; xRootPlc_Node : IXMLNode);
var
   k:integer;
   node_PLCVARS:IXMLNode;
   node_PLCVAR:IXMLNode;
   varplc:tPlcSource;
begin
   inherited Create(aowner);
   fLoadError:='';
   try
      fRootPlc_Node:=xRootPlc_Node;
      fsema_PlcSourceList.Init;
      fPlcSourceList:=TDictionary<string,tPlcSource>.Create; //tlist<tPlcSource>.create;

(*     NAME_PLC:STRING; // serve solo come descrittivo
     MARCA_E_TIPO:string;
     BCK_ADR_ADS:string;
     BCK_PORT_ADS:integer;
     SIE_IPADR:string;
     SIE_IPADR_RACK:integer;
     SIE_IPADR_SLOT:integer;
     PLCProtocol:tPLCProtocol;
  *)
      if fRootPlc_Node.HasAttribute('NAME_PLC') then
      begin
         finfo.NAME_PLC:=fRootPlc_Node.Attributes['NAME_PLC'];
      end;
      finfo.PLCProtocol:=pkBeckhoffADS;
      if fRootPlc_Node.HasAttribute('TYPE_AND_MANUFACTURER') then
      begin
         finfo.TYPE_AND_MANUFACTURER:=fRootPlc_Node.Attributes['TYPE_AND_MANUFACTURER'];
         if finfo.TYPE_AND_MANUFACTURER='SIEMENS' then
            finfo.PLCProtocol:=pkSiemensS7;
      end;

      finfo.SIE_IPADR:='';
      finfo.SIE_IPADR_RACK:=0;
      finfo.SIE_IPADR_SLOT:=0;
      finfo.BCK_ADR_ADS:='';
      finfo.BCK_PORT_ADS:=0;
      finfo.ALIGN_SIZE_SYSTEM:=8;
      if finfo.PLCProtocol=pkBeckhoffADS then
      begin
         if fRootPlc_Node.HasAttribute('BCK_ADR_ADS') then
         begin
            finfo.BCK_ADR_ADS:=fRootPlc_Node.Attributes['BCK_ADR_ADS'];
         end;
         if fRootPlc_Node.HasAttribute('BCK_PORT_ADS') then
         begin
            finfo.BCK_PORT_ADS:=fRootPlc_Node.Attributes['BCK_PORT_ADS'];
         end;
      end
      else
      begin
         if fRootPlc_Node.HasAttribute('SIE_IPADR') then
         begin
            finfo.SIE_IPADR:=fRootPlc_Node.Attributes['SIE_IPADR'];
         end;
         if fRootPlc_Node.HasAttribute('SIE_IPADR_RACK') then
         begin
            finfo.SIE_IPADR_RACK:=fRootPlc_Node.Attributes['SIE_IPADR_RACK'];
         end;

         if fRootPlc_Node.HasAttribute('SIE_IPADR_SLOT') then
         begin
            finfo.SIE_IPADR_SLOT:=fRootPlc_Node.Attributes['SIE_IPADR_SLOT'];
         end;
      end;
      var CHECKSERVICES:String;
      CHECKSERVICES:='';///usare forma 'ipaddress1:nomeservice1,ipaddress2:nomeservice2'

      if fRootPlc_Node.HasAttribute('CHECKSERVICES') then
      begin
        CHECKSERVICES:=fRootPlc_Node.Attributes['CHECKSERVICES'];
      end;
      if not IsServiceRun(CHECKSERVICES) then
         raise Exception.Create('Service '+CHECKSERVICES+' not running!');

      if fRootPlc_Node.HasAttribute('ALIGN_SIZE_SYSTEM') then
      begin
         try
            finfo.ALIGN_SIZE_SYSTEM:=strtoint(fRootPlc_Node.Attributes['ALIGN_SIZE_SYSTEM']);
         except
            ;
         end;
      end;

      if fRootPlc_Node.HasAttribute('DESCRIPTION') then
      begin
         finfo.DESCRIPTION:=fRootPlc_Node.Attributes['DESCRIPTION'];
      end;
      finfo.xml:= fRootPlc_Node.XML;



      fSnap7Client:=nil;
      {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
      {$ELSE}
         fplcFisico:=nil;
      {$ENDIF}
      if finfo.PLCProtocol=pkBeckhoffADS then
      begin
         {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
         {$ELSE}
         fplcFisico:=TboxPlcBeckHoff_rid.Create(nil);
         fplcFisico.Disabled := False;
         fplcFisico.connected := False;
         fplcFisico.PLC_Port := finfo.BCK_PORT_ADS;
         fplcFisico.PLC_ipAddres :=finfo.BCK_ADR_ADS;
         {$ENDIF}
      end
      else
      begin
{$IFDEF BOX_SNAP7_POOL}
         {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
         fSnap7Client:=TS7Client.Create;
         {$ELSE}
         fSnap7Client:=TBoxS7Client.Create;
         {$ENDIF}
{$ELSE}
         fSnap7Client:=TS7Client.Create;
{$ENDIF}
      end;




      node_PLCVARS:=nil;
      for k := 0 to fRootPlc_Node.ChildNodes.Count-1 do
      begin
         node_PLCVARS:=fRootPlc_Node.ChildNodes[k];
         if node_PLCVARS.NodeName='PLCVARS' then
         begin
            break;
         end;
      end;
      if node_PLCVARS<>nil then
      begin
         for k := 0 to node_PLCVARS.ChildNodes.Count-1 do
         begin
            node_PLCVAR:=node_PLCVARS.ChildNodes[k];
            if node_PLCVAR.NodeName='PLCVAR' then
            begin
               try
                  varplc:=tPlcSource.create(self,finfo,
                  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
                  {$ELSE}
                  fplcFisico,
                  {$ENDIF}
                  fSnap7Client, node_PLCVAR,self.finfo.NAME_PLC);
                  fPlcSourceList.Add(uppercase(varplc.Info.name), varplc)
               except
                  on e:exception do
                  begin
                     if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                        writelogerr('error on create tPlcSource<'#10#13+node_PLCVAR.XML+#10#13+'>');
                     fLoadError:= 'error on create tPlcSource<'#10#13+node_PLCVAR.XML+#10#13+'>';
                  end;
               end;
            end;
         end;
      end;
   except
      on e:exception do
      begin
         if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr('error on tPlc.Create<'+e.message+'>');
         fLoadError:= 'error on tPlc.Create<'+e.message+'>';
      end;
   end;

end;

destructor tPlc.Destroy;
var fine:boolean;
    xkeys:tarray<string>;
    val:tPlcSource;
    k:integer;
begin
  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
     writelog( 'tPlc.Destroy '+self.finfo.NAME_PLC+' begin1');

  try
     lock_PlcSourceList;
     try
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
           writelog( 'tPlc.Destroy -> freeandnil(fPlcSourceList) '+self.finfo.NAME_PLC+' ');
        fine:=false;
        xkeys:=fPlcSourceList.Keys.ToArray;
        for k := Low(xkeys) to High(xkeys) do
        begin
           if fPlcSourceList.TryGetValue(xkeys[k],val) then
           begin
              fPlcSourceList.remove(xkeys[k]);
              try
                 if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
                     writelog('tPlc.Destroy freeandnil(val.Info.name<'+xkeys[k]+'>)');
                 freeandnil(val);
              except
                 on e:exception do
                 begin
                    if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                       writelogerr('error tPlc.Destroy freeandnil(val.Info.name<'+xkeys[k]+'> err '+e.message);
                 end;
              end;
           end;
        end;

        freeandnil(fPlcSourceList)
     except
        on e:exception do
        begin
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
              writelog('tPlc.Destroy->freeandnil(fPlcSourceList);'+e.Message );
        end;
     end;
  finally
     unlock_PlcSourceList;
  end;
  if finfo.PLCProtocol=pkBeckhoffADS then
  begin
     {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
     {$ELSE}

     if fplcFisico<>nil then
     begin
       fplcFisico.connected:=False;
       try
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
              writelog( 'tPlc.Destroy -> freeandnil(fplcFisico) '+self.finfo.NAME_PLC+' ');
          freeandnil(fplcFisico);
       except
         on e:exception do
         begin
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               writelog('tPlc.Destroy->freeandnil(fplcFisico);'+e.Message );
         end;
       end;
     end;
    {$ENDIF}
  end
  else
  begin
     try
{$IFDEF BOX_SNAP7_POOL}
     {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
        fSnap7Client.Disconnect;
     {$ELSE}
        fSnap7Client.Snap7Disconnect;
     {$ENDIF}
{$ELSE}
        fSnap7Client.Disconnect;
{$ENDIF}

        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
            writelog( 'tPlc.Destroy -> fSnap7Client.Disconnect '+self.finfo.NAME_PLC+' ');
     except
       on e:exception do
       begin
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
              writelog('tPlc.Destroy->fSnap7Client.Disconnect;'+e.Message );
       end;
     end;
     try
        freeandnil(fSnap7Client);
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
           writelog( 'tPlc.Destroy -> freeandnil(fPlcSourceList) '+self.finfo.NAME_PLC+' ');
     except
       on e:exception do
       begin
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
              writelog('tPlc.Destroy->freeandnil(fplcFisico);'+e.Message );
       end;
     end;

  end;

  fsema_PlcSourceList.Done;
  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
     writelog( 'tPlc.Destroy  '+self.finfo.NAME_PLC+' begin 98');
  inherited;
  if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
      writelog( 'tPlc.Destroy  '+self.finfo.NAME_PLC+' begin 99');
end;

procedure tPlc.lock_PlcSourceList;
begin
   self.fsema_PlcSourceList.lock;
end;

function tPlc.PutPlcSourceValueByName(const xSourceName: string;
  const value: variant): tputPlcSourceValue_back;
var
    fase,func:string;
    XPlcSource:tPlcSource;
    s:string;
    comoOff:integer;
    errnum:TBSX_ENGINE_Error;
begin
   try
      result.error:=Error_All_ok;
      func:='tPlc.putPlcSourceValueByName(<'+xSourceName+'>)';
      fase:='GetPlcSourceByName(<'+xSourceName+'>);';
      XPlcSource:=GetPlcSourceByName(xSourceName); /// solleva eccezzione!!
      fase:='<'+xSourceName+'>.getValueSource';
      result:=XPlcSource.putValueSource(value);
   except
     on e:exception do
     begin
        Result.error.error:=BSXE_PLC_PutPlcSourceValueByName;
        Result.error.errors:=func+' '+fase+' '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr(Result.error.errors);
     end;
   end;
end;

function tPlc.PutPlcSourceValueByNameAndPath(const xSourceName:string; const path: string;
  const value: variant): tputPlcSourceValue_back;
var
    fase,func:string;
    XPlcSource:tPlcSource;
    s:string;
    comoOff:integer;
    errnum:TBSX_ENGINE_Error;
begin
   try
      result.error:=Error_All_ok;
      func:='tPlc.putPlcSourceValueByNameAndPath(<'+xSourceName+'>,<'+path+'>)';
      fase:='GetPlcSourceByName(<'+xSourceName+'>);';
      XPlcSource:=GetPlcSourceByName(xSourceName); /// solleva eccezzione!!
      fase:='<'+xSourceName+'>.getValueSource';
      result:=XPlcSource.putValueSourceByPath(path, value);
   except
     on e:exception do
     begin
        Result.error.error:=BSXE_PLC_PutPlcSourceValueByName;
        Result.error.errors:=func+' '+fase+' '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr(Result.error.errors);
     end;
   end;
end;



//////  non usata dal server ma solo per l import dei file beckhoff
function tPlc.GetPlcSource_offset_and_size_ByNameAndPath(const xSourceName: string;const path:string):TGetPlcSource_offset_and_size_ByNameAndPath_ret;
var
    fase,func:string;
    XPlcSource:tPlcSource;
    s:string;
    comoOff:integer;
    errnum:TBSX_ENGINE_Error;
begin
   try
      result.error:=Error_All_ok;
      func:='tPlc.GetPlcSource_offset_and_size_ByNameAndPath(<'+xSourceName+'>,<'+path+'>)';
      fase:='GetPlcSourceByName(<'+xSourceName+'>);';
      XPlcSource:=GetPlcSourceByName(xSourceName); /// solleva eccezzione!!
      fase:='<'+xSourceName+'>.Get_offset_and_size_SourceByPath';
      result:=XPlcSource.Get_offset_and_size_SourceByPath(path);
   except
     on e:exception do
     begin
        Result.error.error:=BSXE_PLC_GetPlcSource_offset_and_size_ByNameAndPath_generic;
        Result.error.errors:=func+' '+fase+' '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr(Result.error.errors);
     end;
   end;
end;



function tPlc.IsServiceRun(const checkservices:string):boolean;
var
  lSplitStr: TArray<string>;
  lSplit_IP_SERvice: TArray<string>;

  ind:integer;
  serviceParam:string;
  service:string;
  ip:string;
begin
   result:=True;
   try
      lSplitStr := checkservices.Split([',']);
      for ind:=low(lSplitStr) to high(lSplitStr) do
      begin
         ip:='';
         service:='';

         serviceParam:=trim(lSplitStr[ind]);
         lSplit_IP_SERvice:=serviceParam.Split([':']);
         if high(lSplit_IP_SERvice)=1 then
         begin
           ip:=trim(lSplit_IP_SERvice[0]);
           service:=trim(lSplit_IP_SERvice[1]);
         end;
         if high(lSplit_IP_SERvice)=0 then
         begin
            service:=trim(lSplit_IP_SERvice[0]);
         end;

         if service>'' then
         begin
            if ip>'' then
               result:=ServiceRunning(pchar(ip),pchar(service))
            else
               result:=ServiceRunning(nil,pchar(service));
            if not result then
               break;
         end;
      end;
   except
      result:=False;
   end;

end;

procedure tPlc.unlock_PlcSourceList;
begin
   self.fsema_PlcSourceList.unlock;
end;
procedure tPlc.writelog(const s:String);
begin
    if logDm_BSX_ENGINE<>nil then
    try
       logDm_BSX_ENGINE.DoLogMess('#PLC['+self.finfo.NAME_PLC+'] '+s);
    except
    end;
end;
procedure tPlc.writelogerr(const s:String);
begin
    if logDm_BSX_ENGINE<>nil then
    try
       logDm_BSX_ENGINE.DoLogMessErr('#PLC['+self.finfo.NAME_PLC+'] '+s);
    except
    end;
end;



function tPlc.GetPlcSourceByName(const xSourceName:string):tPlcSource;
var i:integer;
   s:string;
   fase,func:string;
   tmp:tPlcSource;
begin
   func:='GetPlcSourceByName<'+xSourceName+'>';
   fase:='Searching';
   result:=nil;
   s:=uppercase(xSourceName);
   self.lock_PlcSourceList;
   try
      try
        (*
         for I :=0 to fPlcSourceList.Count-1 do
         begin
            if s=uppercase(fPlcSourceList[i].info.Name) then
            begin
              result:=fPlcSourceList[i];
              break;
            end;
         end;
        *)
         if fPlcSourceList.TryGetValue(s,tmp) then
            result:=tmp
         else
            result:=nil;

         if result=nil then
            raise Exception.Create(' not Found ');
      except
         on e:exception do
         begin
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                writelogerr(func+' '+fase+ ' '+e.message);
            raise Exception.Create(func+' '+fase+ ' '+e.message);
         end;
      end;
   finally
      self.unlock_PlcSourceList;
   end;
end;
function tPlc.putSourceValueByName(const xSourceName: string;
  const value: variant): tputPlcSourceValue_back;
begin
end;


constructor TDm_BSX_ENGINE.Create(AOwner: TComponent;
  XflagFromPrgImport: boolean; xFileXmlFromImport: string);
begin
     flagFromPrgImport:=XflagFromPrgImport;
     FileXmlFromImport:=xFileXmlFromImport;
     inherited Create(AOwner);

end;

  {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}
constructor TDm_BSX_ENGINE.Create(AOwner: TComponent;const xfileXml:string);
begin
  GfileXml:=xfileXml;
  paramDb.numdb:=0; // serve per non gestire il paramdb, nel caso di un engine unico!
  inherited create(AOwner);
end;
  {$ELSE}

  {$ENDIF}


procedure TDm_BSX_ENGINE.DataModuleCreate(Sender: TObject);
var
    xml:string;
    StartItemNode : IXMLNode;
    ELEM_Node : IXMLNode;
    Attrib_Node:IXMLNode;
    k:integer;
    xPlc:tPlc;
begin
  ErrorDatamodule_engine:='';
  try
   sema_listaPlc.init;
   CoInitialize(nil);
   xml:='';
   listaPlc:=tlist<tPlc>.create;
  (* ts:=tstringlist.create;
   try
      ts.LoadFromFile('C:\!mysw\MORMOT_SCADA\CONFIG_READER_XML\dati_server_plc_server.xml');
      xml:=ts.Text;
   finally
     freeandnil(ts);
   end;
    *)

    /// questo parametro viene settato dal costruttore !!
    ///    nel caso che si usi questo modulo per gestrire il programma per creare i file xml
    ///    viene passato il nome del file che contiene tutto xml (full)
   if flagFromPrgImport then
   begin
      var ts:tstringlist;
      ts:=tstringlist.create;
      try
         ts.LoadFromFile(FileXmlFromImport);
         xml:=ts.Text;
      finally
        freeandnil(ts);
      end;
   end
   else
   begin
      {$IFDEF PROJECT_IS_PMY_SERVER_SNAP_ENHANCED}


      if paramDb.numdb>0 then
      begin
         xml:=Dm_utils.getXMLParamFromFile(paramDb.xmlDefine);//
      end
      else
      begin
        if self.GfileXml>'' then
        begin
           xml:=Dm_utils.getXMLParamFromFile(self.GfileXml);//
        end;
      end;
     {$ELSE}

       xml:=Dm_utils.getXMLParam();
     {$endif}
   end;




   freeandnil(GdataPlcXMLDocument);
   GdataPlcXMLDocument:=TXMLDocument.Create(self);
   GdataPlcXMLDocument.LoadFromXML(xml);
   GdataPlcXMLDocument.Active:=true;


   if GdataPlcXMLDocument.DocumentElement.HasAttribute('NAME_SERVER') then
   begin
      fNAME_SERVER:=GdataPlcXMLDocument.DocumentElement.Attributes['NAME_SERVER'];
   end;
   for k:=0 to GdataPlcXMLDocument.DocumentElement.ChildNodes.Count-1 do
   begin
       ELEM_Node:=GdataPlcXMLDocument.DocumentElement.ChildNodes[k];
       if uppercase(ELEM_Node.NodeName)='PLC' then
       begin
         xPlc:=tPlc.Create(self, ELEM_Node);
         if xPlc.LoadError='' then
            listaPlc.Add(xPlc)
         else
           raise exception.Create('Error '+xPlc.LoadError);
       end;
   end;

  except
     on e:exception do
     begin
        ErrorDatamodule_engine:=e.Message;
     end;
  end;
end;

procedure TDm_BSX_ENGINE.DataModuleDestroy(Sender: TObject);
begin
    if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
       writelog('TDm_BSX_ENGINE.DataModuleDestroy begin0');
    try
       if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
          writelog('TDm_BSX_ENGINE.DataModuleDestroy begin1');
       lock_listaPlc;
       try
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
             writelog('TDm_BSX_ENGINE.DataModuleDestroy begin 2');
          freeandnil(listaPlc);
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
             writelog('TDm_BSX_ENGINE.DataModuleDestroy begin3');
    except
         on e:exception do
         begin
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               writelog('TDm_BSX_ENGINE.DataModuleDestroy : freeandnil(listaPlc); '+e.Message);
         end;
       end;
    finally
       if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
          writelog('TDm_BSX_ENGINE.DataModuleDestroy begin4');
       unlock_listaPlc;
    end;
    if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
       writelog('TDm_BSX_ENGINE.DataModuleDestroy begin5');
       try
          freeandnil(GdataPlcXMLDocument);
          if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
              writelog('TDm_BSX_ENGINE.DataModuleDestroy begin6');
       except
          on e:exception do
          begin
             if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
                writelog('TDm_BSX_ENGINE.DataModuleDestroy : freeandnil(GdataPlcXMLDocument); '+e.Message);
          end;
       end;
       if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
          writelog('TDm_BSX_ENGINE.DataModuleDestroy begin7');
    sema_listaPlc.done;
    if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
       writelog('TDm_BSX_ENGINE.DataModuleDestroy end');
end;




// not used by server for now!
function TDm_BSX_ENGINE.dm_Regenerate_xml_of_Path_From_DS(Const BSXClientNameDebug:string;
                                                          const plcName:string;
                                                          const PlcSourceName:string;
                                                          const Path:string;
                                                          const newSourceName:string):tRegenerate_xml_of_Path_From_DS_back;
//**************************************************************************************************
// funzione usata solo dal prg di importazione!!!!!!!!
//**************************************************************************************************
var k:integer;
    j:integer;
    trovato:boolean;
    XPlcSource:tPlcSource;
    xplc:tplc;
    s:string;
    comoOff:integer;
    fase,func:string;
    valueDebug:string;
begin
   func:='dm_Regenerate_xml_of_Path_From_DS(<'+BSXClientNameDebug+'><'+plcName+'>,<'+PlcSourceName+'>,<'+Path+'>)';
   if LOG_CHIAMATE then
      if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>1 then
         writelog(func);
   result.error:=Error_All_ok;
   result.error.error:=BSXE_dm_Regenerate_xml_of_Path_From_DS_generic;

   try
      fase:='getplc(<'+plcName+'>)';
      result.error.error:=BSXE_dm_Regenerate_xml_of_Path_From_DS_getPlc;
      xplc:=self.getplc(plcName);
      if xplc=nil then
         raise Exception.Create('Plc<'+plcname+'> not found!');
      fase:=xplc.info.NAME_PLC+'dm_Regenerate_xml_of_Path_From_DS('+plcName+'><'+path+'>)';


      result:=xplc.Regenerate_xml_of_Path_From_DS(PlcSourceName,path,newSourceName);  /// non fa eccezzioni ma ritorna errore in result! !


      if result.error.error<>BSXE_ALL_OK then
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogERR(func+' '+fase+' '+Result.error.errors);

   except
     on e:exception do
     begin
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
           writelogerr(func+' '+fase+' '+e.Message);
        result.error.errors:=func+' '+fase+' '+e.Message;
//        result.error.error:= gia settato prima!
     end;
   end;



end;


function tPlc.Regenerate_xml_of_Path_From_DS(const xSourceName: string;
                                             const path:string;
                                             const newSourceName:string
                                            ):tRegenerate_xml_of_Path_From_DS_back;
//**************************************************************************************************
// funzione usata solo dal prg di importazione!!!!!!!!
//**************************************************************************************************
var
    fase,func:string;
    XPlcSource:tPlcSource;
    s:string;
    comoOff:integer;
    errnum:TBSX_ENGINE_Error;
begin
   try
      result.error:=Error_All_ok;
      func:='tPlc.dm_Regenerate_xml_of_Path_From_DS(<'+xSourceName+'>,<'+path+'>)';
      fase:='GetPlcSourceByName(<'+xSourceName+'>);';
      XPlcSource:=GetPlcSourceByName(xSourceName); /// solleva eccezzione!!
      fase:='<'+xSourceName+'>.getValueSource';
      result:=XPlcSource.Regenerate_xml_of_Path_From_DS(path,newSourceName);
   except
     on e:exception do
     begin
        Result.error.error:=BSXE_PLC_Regenerate_xml_of_Path_From_DS;
        Result.error.errors:=func+' '+fase+' '+e.Message;
        if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
            writelogerr(Result.error.errors);
     end;
   end;
end;


function tPlcSource.Regenerate_xml_of_Path_From_DS(const path: string;
                                                   const newSourceName:string): tRegenerate_xml_of_Path_From_DS_back;
//**************************************************************************************************
// funzione usata solo dal prg di importazione!!!!!!!!
//**************************************************************************************************
var s:String;
    BuffData:tarrayofbyte;
    fase,func:string;
    offandsize:ToffsetAndSize;
    DATI_BIT_SINGOLO:TDATI_BIT_SINGOLO;
    idx:integer;
    np:tProprietaNodo;
begin

//			<PLCVAR>
//				<DS_GVL_HMI_HMI_LampTest MODE_LETTURA="MANUAL" TIME_READ_INTERVAL="500" NAME_ON_PLC="GVL_HMI.HMI_LampTest" OFFSET_ON_PLC="0" PLCVAR_VSIZE="1">
//					<DEF_VAR_PLC >
//						<HMI_LampTest NAME_ON_PLC="GVL_HMI.HMI_LampTest" TYPE_ON_PLC="BOOL" VSIZE="1" VOFF="0"/>
//					</DEF_VAR_PLC>
//				</DS_GVL_HMI_HMI_LampTest>
//			</PLCVAR>

                       // BSXE_PlcSource_Regenerate_xml_of_Path_From_DS_calcolaOffsetPathAndSize,


   result.error.error:=BSXE_PlcSource_Regenerate_xml_of_Path_From_DS_generic;
   fase:=' Begin ';
   func:='tPlcSource.Regenerate_xml_of_Path_From_DS';
   try
     lock_self;
     try
        fase:='tPlcSource.Regenerate_xml_of_Path_From_DS(<'+path+'>)';
        result.error.error:=BSXE_PlcSource_Regenerate_xml_of_Path_From_DS_calcolaOffsetPathAndSize;
        DATI_BIT_SINGOLO.FLAGBIT_SINGOLO:=False;
        DATI_BIT_SINGOLO.bitpos:=-1;

        offandsize:=calcolaOffsetPathAndSize(path);
        s:=offandsize.nodo.XML;
        np:=getProprietaNodo(offandsize.nodo);


        var ComoXMLDOC:TXMLDocument;
        var nds,ndefvar, nplcVar:IXMLNode;
        try
           ComoXMLDOC:=TXMLDocument.Create(self);
           ComoXMLDOC.Active:=True;
           nplcVar:=ComoXMLDOC.AddChild('PLCVAR');
           nds:=nplcVar.AddChild(newSourceName);
           //MODE_LETTURA="MANUAL" TIME_READ_INTERVAL="500" NAME_ON_PLC="GVL_DATASET.HS_DataSet" OFFSET_ON_PLC="0" PLCVAR_VSIZE="1"
           nds.SetAttribute('MODE_LETTURA','MANUAL');
           nds.SetAttribute('TIME_READ_INTERVAL','500');
           nds.SetAttribute('NAME_ON_PLC','MANUAL');
           nds.SetAttribute('NAME_ON_PLC',self.fInfo.NAME_ON_PLC+'.'+path);
           nds.SetAttribute('OFFSET_ON_PLC',0);//offandsize.offset);
           nds.SetAttribute('PLCVAR_VSIZE',offandsize.size);
           nds.SetAttribute('DATASOURCE_GENERATE_FROM_DS_NAME',self.fInfo.name);
           nds.SetAttribute('DATASOURCE_GENERATE_FROM_DS_PATH',path);

           ndefvar:=nds.AddChild('DEF_VAR_PLC');

           ndefvar.ChildNodes.Add(LoadXMLData(offandsize.nodo.xml).DocumentElement);
           ndefvar.ChildNodes[0].SetAttribute('VOFF',0);


           if rightstr(trim(path),1)=']' then
           begin
              idx:=ndefvar.ChildNodes[0].AttributeNodes.IndexOf('ARRAY');
              if idx<>-1 then
                 ndefvar.ChildNodes[0].AttributeNodes.delete(idx);
              ndefvar.ChildNodes[0].SetAttribute('VSIZE',np.llElement);

           end;



           ComoXMLDOC.XML.Text:=FormatXMLData(ComoXMLDOC.XML.Text);
           ComoXMLDOC.Active:=True;
           ComoXMLDOC.SaveToXML(s);

           if offandsize.AllArrayPath then

           result.xml:=s;
           result.size:=offandsize.size;
           result.offset:=offandsize.offset;



        finally
           try ComoXMLDOC.Free;except;end;
        end;





//        if offandsize.DATI_BIT_SINGOLO.FLAGBIT_SINGOLO then
//        begin
//           DATI_BIT_SINGOLO:=offandsize.DATI_BIT_SINGOLO;
//        end;








        result.error:=Error_All_ok;
        result.xml:=s;
//        result.size:=offandsize.size;

     except
        on e:exception do
        begin
            Result.error.errors:=func+' '+fase+ 'err:['+integer(result.error.error).ToString+'] '+e.Message;
            if Param_BSX_SERVER.Verboseindex_log_BSX_ENGINE>0 then
               writelogerr(Result.error.errors);
        end;
     end;
   finally
      unlock_self;
   end;

end;






























function ServiceGetStatus(sMachine, sService: PChar): DWORD;
  {******************************************}
  {*** Parameters: ***}
  {*** sService: specifies the name of the service to open
  {*** sMachine: specifies the name of the target computer
  {*** ***}
  {*** Return Values: ***}
  {*** -1 = Error opening service ***}
  {*** 1 = SERVICE_STOPPED ***}
  {*** 2 = SERVICE_START_PENDING ***}
  {*** 3 = SERVICE_STOP_PENDING ***}
  {*** 4 = SERVICE_RUNNING ***}
  {*** 5 = SERVICE_CONTINUE_PENDING ***}
  {*** 6 = SERVICE_PAUSE_PENDING ***}
  {*** 7 = SERVICE_PAUSED ***}
  {******************************************}
var
  SCManHandle, SvcHandle: SC_Handle;
  SS: TServiceStatus;
  dwStat: DWORD;
begin
  dwStat := 0;
  // Open service manager handle.
  SCManHandle := OpenSCManager(sMachine, nil, SC_MANAGER_CONNECT);
  if (SCManHandle > 0) then
  begin
    SvcHandle := OpenService(SCManHandle, sService, SERVICE_QUERY_STATUS);
    // if Service installed
    if (SvcHandle > 0) then
    begin
      // SS structure holds the service status (TServiceStatus);
      if (QueryServiceStatus(SvcHandle, SS)) then
        dwStat := ss.dwCurrentState;
      CloseServiceHandle(SvcHandle);
    end;
    CloseServiceHandle(SCManHandle);
  end;
  Result := dwStat;
end;

function ServiceRunning(sMachine, sService: PChar): Boolean;
begin
  Result := SERVICE_RUNNING = ServiceGetStatus(sMachine, sService);
end;






initialization
   read_Param_Dm_start_module; // lo faccio in ogni modulo perche non so quale initialize viene chiamata per prima
   try
      logDm_BSX_ENGINE:=TLogThread4.CreateFromExeDirPath('\log\Dm_BSX_ENGINE.log');
      logDm_BSX_ENGINE.maxsizekbyte:=100000;
      logDm_BSX_ENGINE.setActive(true);
      logDm_BSX_ENGINE.DoLogMessErr('Started!');
      sleep(100);
   except
      logDm_BSX_ENGINE:=nil;
   end;
finalization
  try
    if assigned(logDm_BSX_ENGINE) then
    begin
      logDm_BSX_ENGINE.FreeOnTerminate:=true;
      logDm_BSX_ENGINE.SignalEnd();
      logDm_BSX_ENGINE.Terminate;
    end;
  except
     ;
  end;
   //logTBSXCLient.free;


end.
