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

unit u_def_param_db;

interface

uses  Vcl.StdCtrls,Vcl.ComCtrls,vcl.ExtCtrls,
      Vcl.Controls,System.Classes,System.SyncObjs,snap7,
      vcl.grids,SynCommons,
      System.Generics.Collections,
      System.SysUtils,
      mormot,U_BSX_mormot_interface,Xml.XMLDoc,Xml.XMLIntf,  u_mormot_server_read_ini;

type  tPlcSourceInfoxml=record
      PlcSourceName:string;
      dataPlcXMLDocument:TXMLDocument;
      xmlCreated:boolean;
      StartNode:ixmlNode;
end;


type TparamDb=record
       numdb:integer;
       desdb:string;
       NamePlc:string;
       NameDataSource:string;
       lendb:integer;
       indexGDataDb:integer;
       tabsheet:ttabSheet;
       pcdata:TPageControl;
       tabsheetDump:ttabSheet;
       tabsheetData:ttabSheet;
       panelButton:tpanel;
       buttonAdd:tbutton;
       buttonDel:tbutton;
       buttonSetvalue:tbutton;
       Split: TSplitter;

       StringGrid:TStringGrid;// TStringGrid;
       TV: TTreeView;
       PlcSourceInfoxml:tPlcSourceInfoxml;
      // XMLDocument:TXMLDocument;
       xml:string;


       memo:tmemo;
      // DB_changed : boolean;
       xmlDefine:string;
       Dm_BSX_ENGINE:TDatamodule;

  end;



  Tdatabuff = record
     buff:packed array of byte;
     changed:TEvent;
     LastValue:TGetPlcSourceValue_back;
     numDb:integer;
     rifServer:TS7Server;
     PointerlastWrite:pointer;

  end;




var

  GDizioDataDb:tdictionary<integer,TparamDb>;
  GDataDb :array [0..63] of Tdatabuff;
  GDataDbcount:integer;
  listaDbDaAggiornare:tlist<integer>;
  sema_listaDbDaAggiornare:TSynLocker;


function decodeArrayAttributeMINMAX(s:string):TarrayMinMax;


implementation


function decodeArrayAttributeMINMAX(s:string):TarrayMinMax;
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
         raise Exception.Create('BSXERROR decodeArrayAttributeMINMAX(<'+s+'>) err:'+e.Message);
      end;
   end;
end;



initialization
   read_Param_Dm_start_module; // lo faccio in ogni modulo perche non so quale initialize viene chiamata per prima

   GDizioDataDb:=tdictionary<integer,TparamDb>.create();
   GDataDbcount:=0;
   listaDbDaAggiornare:=tlist<integer>.create;
   sema_listaDbDaAggiornare.init;

finalization
  listaDbDaAggiornare.Free;
  GDizioDataDb.free;

end.
