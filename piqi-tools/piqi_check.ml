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


module C = Piqi_common  
open C


module Main = Piqi_main
open Main


(* command-line arguments *)

let usage = "Usage: piqi check [options] <.piqi|.piq file>\nOptions:"


let speclist = Main.common_speclist @
  [
  ]


let check_piqi filename =
  (* in order to check JSON names: *)
  Piqi_json.init ();
  ignore (Piqi.load_piqi filename)


let check_piq filename =
  let piq_parser = Piq.open_piq filename in
  try
    while true
    do
      ignore (Piq.load_piq_obj piq_parser)
    done
  with
    Piq.EOF -> ()


let check_file filename =
  match Piqi_file.get_extension filename with
    | "piq" -> check_piq filename
    | "piqi" -> check_piqi filename
    | x -> piqi_error ("unknown input file extension: " ^ x)


let run () =
  Main.parse_args () ~speclist ~usage ~min_arg_count:1 ~max_arg_count:1;
  check_file !ifile

 
let _ =
  Main.register_command run "check" "check %.piqi or %.piq validity"

