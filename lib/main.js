/**
 * Copyright (C) 2013 Boucher, Antoni
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

'use strict';

const { XMLHttpRequest } = require("sdk/net/xhr"),
    self = require('sdk/self'),
    tabs = require('sdk/tabs'),
    { clearInterval, setTimeout } = require('sdk/timers'),
    TIMEOUT = 5000;

/**
 * Down for Everyone or Just Me is a Firefox Add-on showing whether
 * the requested website is down or not when Firefox cannot load it.
 */
function main() {
    tabs.on('ready', function(tab) {
        let xhr;
        let attached = true;
        
        let worker = tab.attach({
            contentScriptFile: self.data.url('down.js'),
            onDetach: function() {
                attached = false;
                if(xhr !== undefined) {
                    xhr.abort();
                    xhr = undefined;
                }
            },
            onMessage: function(data) {
                if(data === 'error' || data === 'retry') {
                    worker.port.emit('fetching', self.data.url('ajax-loader.gif'));
                    
                    let intervalID;
                    
                    xhr = new XMLHttpRequest();
                    xhr.open('GET', 'http://www.downforeveryoneorjustme.com/' + tab.url);
                    xhr.onreadystatechange = function() {
                        if(xhr.readyState === 4) {
                            if(xhr.status === 200) {
                                if(xhr.responseText.indexOf('It\'s not just you!') > -1) {
                                    worker.port.emit('result', 'down');
                                }
                                else if(xhr.responseText.indexOf('It\'s just you.') > -1) {
                                    worker.port.emit('result', 'up');
                                }
                                else {
                                    worker.port.emit('result', 'unknown');
                                }
                            }
                            else {
                                if(attached) {
                                    worker.port.emit('result', 'unknown');
                                }
                            }
                        }
                        clearInterval(intervalID);
                    };
                    xhr.send(null);
                    
                    intervalID = setTimeout(function() {
                        xhr.abort();
                        worker.port.emit('result', 'unknown');
                    }, TIMEOUT);
                }
            }
        });
    });
}

exports.main = main;
