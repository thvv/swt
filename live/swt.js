// support fuctions for Super Webtrax
// THVV 08/12/06
// THVV 01/18/07 add hideshow
// ================================================================
// find object n (in document d)
function findObj(n, d) { //v4.0
    var p,i,x = null;  
    if (!d) d = document; 
    if (!(x = d[n]) && d.all) x = d.all[n]; // MSIE
    for (i = 0; !x && i<d.forms.length; i++) x = d.forms[i][n];
    for (i = 0; !x && d.layers && i<d.layers.length; i++) x = findObj(n, d.layers[i].document);
    if (!x && document.getElementById) x = document.getElementById(n); 
    return x;
} // findObj
// hide object x and show y or vice versa, called as onClick from a control
// switches between "display: block" and "display: none"
function peekaboo(x, y) {
    var obj1, obj2;
    if ((obj1 = findObj(x)) != null) { 
	if (obj1.style) {
	    obj1 = obj1.style; 
	}
        if ((obj2 = findObj(y)) != null) { 
	    if (obj2.style) {
	        obj2 = obj2.style; 
	    }
	    //alert("peekaboo "+obj1.display+" "+obj2.display);
            if ((obj1.display == 'none') || (obj1.display == '')) {
	        obj1.display = 'block';
	        obj2.display = 'none';
            } else {
	        obj2.display = 'block';
	        obj1.display = 'none';
            }
        } // obj2 found
    } // obj1 found
} // peekaboo
// hide/show all items of type t with class c .. called on long detail report to hide/show DD and DT of indexers
function hideshow(t, c) {
    var lis, i;
    lis = document.getElementsByTagName(t);
    for(i=0; i<lis.length; i++) {
      if (lis[i].className == c) { // assumes that it has one class
	// alert(lis[i]); // too many
	if (lis[i].style.display == "none") {
	  lis[i].style.display = "block";
	} else {
	  lis[i].style.display = "none";
	}
      }
    } // for
} // hideshow

// document.getElementsByClassName = function(cl) {
// var retnode = [];
// var myclass = new RegExp('\\b'+cl+'\\b');
// var elem = this.getElementsByTagName('*');
// for (var i = 0; i < elem.length; i++) {
// var classes = elem[i].className;
// if (myclass.test(classes)) retnode.push(elem[i]);
// }
// return retnode;
// };
// ================================================================
//  Permission is hereby granted, free of charge, to any person obtaining 
//  a copy of this software and associated documentation files (the 
//  "Software"), to deal in the Software without restriction, including 
//  without limitation the rights to use, copy, modify, merge, publish, 
//  distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to 
//  the following conditions: 
// 
//  The above copyright notice and this permission notice shall be included 
//  in all copies or substantial portions of the Software. 
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
// ================================================================
