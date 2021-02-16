import Routing
import HTTP

public final class Resource<Model: Parameterizable> {
    public typealias Multiple = (Request) throws -> ResponseRepresentable
    public typealias Item = (Request, Model) throws -> ResponseRepresentable

    public var index: Multiple?
    public var create: Multiple?
    public var store: Multiple?
    public var show: Item?
    public var edit: Item?
    public var update: Item?
    public var replace: Item?
    public var destroy: Item?
    public var clear: Multiple?
    public var aboutItem: Item?
    public var aboutMultiple: Multiple?

    public init(
        index: Multiple? = nil,
        create: Multiple? = nil,
        store: Multiple? = nil,
        show: Item? = nil,
        edit: Item? = nil,
        update: Item? = nil,
        replace: Item? = nil,
        destroy: Item? = nil,
        clear: Multiple? = nil,
        aboutItem: Item? = nil,
        aboutMultiple: Multiple? = nil
    ) {
        self.index = index
        self.create = create
        self.store = store
        self.show = show
        self.edit = edit
        self.update = update
        self.replace = replace
        self.destroy = destroy
        self.clear = clear
        self.aboutItem = aboutItem
        self.aboutMultiple = aboutMultiple
    }
}

public protocol ResourceRepresentable {
    associatedtype Model: Parameterizable
    func makeResource() -> Resource<Model>
}

extension RouteBuilder {
    public func resource<Resource: ResourceRepresentable & EmptyInitializable>(_ path: String, _ resource: Resource.Type) throws {
        let resource = try Resource().makeResource()
        self.resource(path, resource)
    }
    
    public func resource<Resource: ResourceRepresentable>(_ path: String, _ resource: Resource) {
        let resource = resource.makeResource()
        self.resource(path, resource)
    }

    public func resource<Model>(_ path: String, _ resource: Resource<Model>) {
        var itemMethods: [Method] = []
        var multipleMethods: [Method] = []

        let pathId = path.makeBytes().split(separator: .forwardSlash).joined(separator: [.hyphen]).split(separator: .colon).joined().makeString() + "_id"

        func item(_ method: Method, subpath: String? = nil, _ item: Resource<Model>.Item?) {
            guard let item = item else {
                return
            }

            itemMethods.append(method)

            let closure: (HTTP.Request) throws -> HTTP.ResponseRepresentable = { request in
                let model = try request.parameters.next(Model.self)

                return try item(request, model).makeResponse()
            }

            if let subpath = subpath {
                self.add(method, path, Model.parameter, subpath) { request in
                    return try closure(request)
                }
            } else {
                self.add(method, path, Model.parameter) { request in
                    return try closure(request)
                }
            }
        }

        func multiple(_ method: Method, subpath: String? = nil, _ multiple: Resource<Model>.Multiple?) {
            guard let multiple = multiple else {
                return
            }

            multipleMethods.append(method)

            if let subpath = subpath {
                self.add(method, path, subpath) { request in
                    return try multiple(request).makeResponse()
                }
            } else {
                self.add(method, path) { request in
                    return try multiple(request).makeResponse()
                }
            }
        }

        multiple(.get, resource.index)
        multiple(.get, subpath: "create", resource.create)
        item(.get, subpath: "edit", resource.edit)
        multiple(.post, resource.store)
        item(.get, resource.show)
        item(.put, resource.replace)
        item(.patch, resource.update)
        item(.delete, resource.destroy)
        multiple(.delete, resource.clear)

        if let about = resource.aboutItem {
            item(.options, about)
        } else {
            item(.options) { _, _ in
                return try JSON(node: [
                    "resource": "\(path)/:\(pathId)",
                    "methods": try JSON(node: itemMethods.map { $0.description })
                ]) 
            }
        }

        if let about = resource.aboutMultiple {
            multiple(.options, about)
        } else {
            multiple(.options) { _ in
                let methods: [String] = multipleMethods.map { $0.description }
                return try JSON(node: [
                    "resource": path,
                    "methods": try JSON(node: methods)
                ])
            }
        }
    }

    public func resource<Model>(
        _ path: String,
        _ type: Model.Type = Model.self,
        closure: (Resource<Model>) -> Void
    ) {
        let resource = Resource<Model>()
        closure(resource)
        self.resource(path, resource)
    }
}
