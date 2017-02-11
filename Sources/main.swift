import Kitura
import HeliumLogger
import MongoKitten
import Foundation
import SwiftyJSON

// Create a new router
let router = Router()
HeliumLogger.use()

//let username = "chenguser"
//let password = "1qaz@WSX"
//let hostname = "localhost"
//let db = "chengdb"
//let collection = "cleancontent"

guard let conf = FileHandle(forReadingAtPath: "/usr/local/etc/chengd.conf") else {
    print("Cannot read conf file")
    exit(255)
}

var data: Data = conf.readDataToEndOfFile()
let params = JSON(data:data)

guard let username = params["username"].string,
    let password = params["password"].string,
    let hostname = params["hostname"].string,
    let db = params["db"].string,
    let collection = params["collection"].string else {
        print("Incorrect JSON")
        exit(255)
}



let connectParams = MongoCredentials(username: username , password: password)
let server = try Server(hostname: hostname, authenticatedAs: connectParams)
let contentCollection = server[db][collection]
let contentImageCollection = server[db]["contentimages"]

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}

// Search request
router.get("/q") { request, response, _ in
    if let name = request.queryParameters["name"] {
        let searchTerm: Document = [ "_id": name ]
        let query = Query(searchTerm)
        let doc = try contentCollection.findOne(matching: query)
        if var content = doc  {
            let poster = try contentImageCollection.findOne(matching: query)
            if let large = poster?.dictionaryValue["large"],
                let small = poster?.dictionaryValue["small"],
                let medium = poster?.dictionaryValue["medium"] {
                content.append(large, forKey: "large")
                content.append(small, forKey: "small")
                content.append(medium, forKey: "medium")
            }
        }
        else {
            response.send("No Film found")
            return

        }
        
    }
}


// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 9099, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()


