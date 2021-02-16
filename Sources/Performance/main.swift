import Vapor

let drop = try Droplet(middleware: [])

drop.get("plaintext") { _ in
    return "Hello, world!"
}

try drop.run()
