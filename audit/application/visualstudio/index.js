// Import Mongoose for mongoDb operations
var mongoose = require('mongoose');

// Create an mongodb Schema object
var schema = mongoose.Schema;
var newInstallSchema =  new schema({
    username: String,
    hostname: String,
    version: String,
    site: String,
    ip: String,
    date: {type: Date, default: Date.now},
    count: {type: Number, default: 1}
});




// Module: Register new installation of Visual Studio
var newInstall = function(newInstall) {
    // Establish connection to MongoDb to Visualstudio model
    mongoose.connect('mongodb://localhost:27017/audit', function(err) {
        // console.log("Connection error: " + err);
        return false;
    });

    // Create a visualstudio model and a collection
    var visualStudioModel = mongoose.model('Visualstudio', newInstallSchema);
    visualStudioModel.createCollection();
    var query = {username: newInstall.username, ip: newInstall.ip, version: newInstall.version};

    // Step 1: Get record from documents that matches Username, VisualStudio version and hostname
    visualStudioModel.findOne(query, function(err, docs) {
        if(err) { return false; }
        if(docs === null) {
            // Step 2.1: If no document retrieved, insert it as a new document 
            visualStudioModel.insertMany([newInstall], function(err, docs) {
                if(err) { console.log(err); return false; }
                return true;
            });
        } else {
            // Step 2.2: If document retrieved, update installation date and count
            visualStudioModel.findOneAndUpdate(query, {count: docs.count + 1}, function(err, docs) {
                if(err) { console.log(err); return false; }
                return true;
            });
        }
    });
};


module.exports = {
    newInstall: newInstall
}