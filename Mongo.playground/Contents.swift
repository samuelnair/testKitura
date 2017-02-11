//: Playground - noun: a place where people can play

import MongoKitten
import Foundation
import SwiftyJSON

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

let searchTerm: Document = ["_id": "Green Lantern"]
let query: Query = Query(searchTerm)

let docs = try contentImageCollection.find(matching: query)
var large: String?
var small: String?
var medium: String?

for doc: Document in docs {
    large = doc.dictionaryValue["large"]?.string
    small = doc.dictionaryValue["small"]?.string
    medium = doc.dictionaryValue["meidum"]?.string
}
print(large ?? "No value available")


