var express = require('express');
var router = express.Router();
var visualStudio = require('../application/visualstudio');

// Declare acceptable values for query parameter
const actionlist = ['register'];

/* GET Visual Studio user listing. */
router.get('/', function(req, res, next) {
  res.send('respond with a resource');
});

/* POST Visual Studio entry for every installation 

  URL Sample: /ver/2017/user/jdoe/host/jdoe/ip/0.0.0.0&action=register
  user: Username
  site: Organization development site
  ver: Visual studio version
  Ip: IP address of the machine
  host: Installation host

  */
router.post('/ver/:version/user/:username/site/:site/host/:hostname/ip/:ip', function(req, res) {
  // Check if action is defined to acceptable options or not
  if(! req.query.action || actionlist.indexOf(req.query.action) === -1 ) {
    res.send('Action is missing', 404);
  }
  // Convert all req.params values to lowercase
  var payload = req.params;
  for(var item in payload) {
    payload[item] = payload[item].toLowerCase();
  }

  // Send the payload for further processing
  if(visualStudio.newInstall(payload)) {
    res.send('Failed to make an entry in db', 404);
  }
  res.send('OK',200);

});
module.exports = router;
