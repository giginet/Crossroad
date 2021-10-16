import Foundation

protocol ValidationRule {
    func validate<UserInfo>(for: Router<UserInfo>) throws
}

extension Router {
    private struct UnknownLinkSourceRule: ValidationRule {
        func validate<UserInfo>(for router: Router<UserInfo>) throws {
            for route in router.routes {
                guard case let .onlyFor(group) = route.acceptPolicy else {
                    return
                }
                let acceptSources = group.extract()
                guard acceptSources.isSubset(of: router.linkSources) else {
                    let notContains = acceptSources.subtracting(router.linkSources)
                    throw ValidationError.unknownLinkSource(notContains)
                }
            }
        }
    }

    private struct DuplicatedRouteRule: ValidationRule {
        func validate<UserInfo>(for router: Router<UserInfo>) throws {
            for route in router.routes {
                let count = router.routes.filter { other in
                    route.path == other.path && route.acceptPolicy == other.acceptPolicy
                }.count
                guard count == 1 else {
                    throw ValidationError.duplicatedRoute(route.path, (route.acceptPolicy as? Route.AcceptPolicy) ?? .any)
                }
            }
        }
    }

    public enum ValidationError: LocalizedError {
        case unknownLinkSource(Set<LinkSource>)
        case duplicatedRoute(Path, Route.AcceptPolicy)

        public var errorDescription: String? {
            switch self {
            case .unknownLinkSource(let linkSources):
                return "Unknown link sources \(linkSources) is registered"
            case .duplicatedRoute(let path, let acceptPolicy):
                return "Route definition for \(path) (accepts \(acceptPolicy)) is duplicated"
            }
        }
    }

    struct Validator {
        init(router: Router<UserInfo>) {
            self.router = router
        }

        private let router: Router<UserInfo>
        private let rules: [ValidationRule] = [
            UnknownLinkSourceRule(),
            DuplicatedRouteRule(),
        ]

        func validate() throws {
            for rule in rules {
                try rule.validate(for: router)
            }
        }
    }
}
