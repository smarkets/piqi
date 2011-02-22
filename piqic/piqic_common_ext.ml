(*pp camlp4o -I $PIQI_ROOT/camlp4 pa_labelscope.cmo pa_openin.cmo *)
(*
   Copyright 2009, 2010, 2011 Anton Lavrik

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

(* This module contains functionality that Piqic_common module would contain,
 * but if it did, it would break Piqicc bootstrap that doesn't support
 * functionality from Piqi_ext module such as PIiq_ext.expand_piqi *)

module C = Piqi_common
open C


let rec get_piqi_deps piqi =
  if C.is_boot_piqi piqi
  then [] (* boot Piqi is not a dependency *)
  else
    let imports =
      List.map (fun x -> some_of x.T.Import#piqi) piqi.P#resolved_import
    in
    (* get all imports' dependencies recursively *)
    let import_deps =
      flatmap (fun piqi ->
          flatmap get_piqi_deps piqi.P#included_piqi
        ) imports
    in
    (* remove duplicate entries *)
    let deps = C.uniqq (import_deps @ imports) in
    deps @ [piqi]


let encode_embedded_piqi piqi =
  (* XXX: or just use piqi.orig_piqi and also get includes in get_piqi_deps? *)
  let res_piqi = Piqi_ext.expand_piqi piqi in
  (* add the Module's name even if it wasn't set *)
  res_piqi.P#modname <- piqi.P#modname;
  (* generate embedded object (i.e. without field header) *)
  let iodata = T.gen_piqi (-1) res_piqi in
  Piqirun.to_string iodata


(* build a list of all import dependencies including the specified module and
 * encode each Piqi module in the list using Protobuf encoding *)
let build_piqi_deps piqi =
  let deps = get_piqi_deps piqi in
  List.map encode_embedded_piqi deps

