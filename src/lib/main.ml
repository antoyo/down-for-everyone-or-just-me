(*
 * Copyright (C) 2015  Boucher, Antoni <bouanto@gmail.com>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

open Sdk
open Sdk.Net.Xhr
open Sdk.Timers

let timeout = 5000

let tab_close tab =
    ()

let tab_message url worker message =
    if message = "error" || message = "retry" then (
        worker#port#emit "fetching" (Self.data#url "ajax-loader.gif");

        let timeout_id = ref 0 in

        let xhr = new xml_http_request in
        xhr#_open "GET" ("http://www.downforeveryoneorjustme.com/" ^ url);
        xhr#onreadystatechange (fun () ->
            if xhr#ready_state = DONE then (
                if xhr#status = 200 then (
                    if StringUtils.contains xhr#response_text "It's not just you!" then
                        worker#port#emit "result" "down"
                    else if StringUtils.contains xhr#response_text "It's just you." then
                        worker#port#emit "result" "up"
                    else
                        worker#port#emit "result" "unknown"
                )
                else (
                    worker#port#emit "result" "unknown"
                );
                clear_timeout !timeout_id
            )
        );
        xhr#send;

        timeout_id := set_timeout (fun () ->
            xhr#abort;
            worker#port#emit "result" "unknown";
        ) timeout;
    )

let () =
    Tabs.on_ready (fun tab ->
        tab#on_close tab_close;
        let url = tab#url in
        ignore (tab#attach_file
            ~on_message: (tab_message url)
            (Self.data#url "down.js")
        )
    )
