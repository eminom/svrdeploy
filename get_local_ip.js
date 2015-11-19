

///////////////////////////
// The working labor.

var os = require('os');
var fs = require('fs');

function getLocalIP() {
  var ifs = os.networkInterfaces();
  for(var i in ifs) {
    if(i.startsWith("Virtual"))
		  continue;
    for(var j=0;j<ifs[i].length;++j) {
      if(ifs[i][j].family === "IPv4" && !ifs[i][j].internal ){
        //console.log(ifs[i][j].address);
        return ifs[i][j].address;
	    }
	 }
  }
  return "127.0.0.1";
}

function formatCDN(){
	var rv = "http://" + getLocalIP() + ":12000";
	return rv;
}

console.log(formatCDN());
