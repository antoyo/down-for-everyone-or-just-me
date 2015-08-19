/**
 * Copyright (C) 2013-2015 Boucher, Antoni
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

let stylesheets = document.styleSheets;
if(stylesheets.length > 0 && (stylesheets[0].href.toLowerCase().indexOf('neterror') >= 0)) {
    self.postMessage('error');
    
    let errorPageContainer = document.getElementById('errorPageContainer');
    if(errorPageContainer !== null) {
        let statusIndicator = document.createElement('div');
        statusIndicator.style.display = 'none';
        errorPageContainer.appendChild(statusIndicator);
        
        let ajaxLoader = new Image();
        ajaxLoader.alt = 'Ajax Loader';
        ajaxLoader.style.cssFloat = 'left';
        ajaxLoader.style.marginLeft = '20px';
        ajaxLoader.style.marginTop = '2px';
        
        let button = document.createElement('button');
        button.innerHTML = 'Fetch status again';
        button.style.display = 'none';
        button.style.margin = 'auto';
        button.addEventListener('click', function() {
            button.style.display = 'none';
            self.postMessage('retry');
        }, false);
        errorPageContainer.appendChild(button);
        
        self.port.on('fetching', function(ajaxLoaderUrl) {
            statusIndicator.style.backgroundColor = '#808080';
            statusIndicator.style.borderRadius = '5px';
            statusIndicator.style.color = 'white';
            statusIndicator.style.display = 'block';
            statusIndicator.style.fontWeight = 'bold';
            statusIndicator.style.margin = '5px auto';
            statusIndicator.style.padding = '5px';
            statusIndicator.style.textAlign = 'center';
            statusIndicator.style.width = '200px';
            statusIndicator.innerHTML = 'Fetching status';
            
            ajaxLoader.src = ajaxLoaderUrl;
            ajaxLoader.style.display = 'inline';
            statusIndicator.appendChild(ajaxLoader);
        });

        self.port.on('result', function(data) {
            let colors = {
                down: 'red',
                unknown: '#808080',
                up: 'green'
            };
            ajaxLoader.style.display = 'none';
            
            if(data === 'unknown') {
                button.style.display = 'block';
            }
            else {
                button.style.display = 'none';
            }
            
            statusIndicator.style.backgroundColor = colors[data];
            statusIndicator.innerHTML = 'Status: ' + data;
            statusIndicator.style.display = 'block';
        });
    }
}
