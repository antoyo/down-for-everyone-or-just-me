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

open Dom
open Dom_html
open Dom_html.Event
open Js

open Script

let is_error url = StringUtils.starts_with url "chrome://" && StringUtils.contains (String.lowercase url) "neterror"

let show_ajax_loader ajax_loader ajax_loader_url status_indicator =
    ajax_loader##src <- string ajax_loader_url;
    ajax_loader##style##display <- string "inline";
    appendChild status_indicator ajax_loader

let show_status_indicator status_indicator ajax_loader ajax_loader_url =
    status_indicator##style##backgroundColor <- string "#808080";
    status_indicator##style##borderRadius <- string "5px";
    status_indicator##style##color <- string "white";
    status_indicator##style##display <- string "block";
    status_indicator##style##fontWeight <- string "bold";
    status_indicator##style##left <- string "15px";
    status_indicator##style##margin <- string "5px auto";
    status_indicator##style##padding <- string "5px";
    status_indicator##style##textAlign <- string "center";
    status_indicator##style##top <- string "15px";
    status_indicator##style##width <- string "200px";
    status_indicator##innerHTML <- string "Fetching status";
    show_ajax_loader ajax_loader ajax_loader_url status_indicator

let create_ajax_loader () =
    let ajax_loader = createImg document in
    ajax_loader##alt <- string "Ajax Loader";
    ajax_loader##style##cssFloat <- string "left";
    ajax_loader##style##marginLeft <- string "20px";
    ajax_loader##style##marginTop <- string "2px";
    ajax_loader

let create_button () =
    let button = createButton document in
    button##innerHTML <- string "Fetch status again";
    button##style##display <- string "none";
    button##style##left <- string "230px";
    button##style##margin <- string "auto";
    button##style##position <- string "fixed";
    button##style##top <- string "19px";
    ignore (addEventListener button click (handler (fun _ ->
        button##style##display <- string "none";
        Self.post_message "retry";
        Js._false
    )) Js._false);
    appendChild document##body button;
    button

let create_status_indicator () =
    let status_indicator = createDiv document in
    status_indicator##style##display <- string "none";
    status_indicator##style##position <- string "fixed";
    appendChild document##body status_indicator;
    (status_indicator, create_ajax_loader ())

let get_color = function
    | "down" -> "red"
    | "up" -> "green"
    | _ -> "#808080"

let show_result status_indicator ajax_loader button data =
    let color = get_color data in
    ajax_loader##style##display <- string "none";
    if data = "unknown"
        then button##style##display <- string "block"
        else button##style##display <- string "none"
    ;
    status_indicator##style##backgroundColor <- string color;
    status_indicator##innerHTML <- string ("Status: " ^ data);
    status_indicator##style##display <- string "block"

let () =
    let links = document##getElementsByTagName(string "link") in
    let first_link = Opt.to_option (Opt.bind links##item(0) CoerceTo.link) in
    let link_url = match first_link with
                    | Some link -> to_string link##href
                    | None -> ""
    in
    if is_error link_url then (
        Self.post_message "error";
        let (status_indicator, ajax_loader) = create_status_indicator () in
        let button = create_button () in
        Self.port#on "fetching" (show_status_indicator status_indicator ajax_loader);
        Self.port#on "result" (show_result status_indicator ajax_loader button);
    )
