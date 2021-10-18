import Foundation

protocol ValidationRule {
    func validate<UserInfo>(for: Router<UserInfo>) throws
}

extension Router {
    private struct UnknownLinkSourceRule: ValidationRule {
        func validate<UserInfo>(for router: Router<UserInfo>) throws {
            for route in router.routes {
                guard case let .only(group) = route.acceptPolicy else {
                    continue
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
                let acceptSources: Set<LinkSource>
                switch route.acceptPolicy {
                case .any:
                    acceptSources = router.linkSources
                case .only(let linkSources):
                    acceptSources = linkSources.extract()
                }

                let count = router.routes.filter { other in
                    switch other.acceptPolicy {
                    case .any:
                        return route.path == other.path
                    case .only(let linkSources):
                        return route.path == other.path && !linkSources.extract().isDisjoint(with: acceptSources)
                    }
                }.count
                guard count == 1 else {
                    throw ValidationError.duplicatedRoute(route.path, (route.acceptPolicy as? Route.AcceptPolicy) ?? .any) // need casting. it seems to be a compiler's bug
                }
            }
        }
    }

    private struct InvalidLinkSourceRule: ValidationRule {
        func validate<UserInfo>(for router: Router<UserInfo>) throws {
            for route in router.routes {
                guard let patternLinkSource = route.pattern.linkSource else {
                    continue
                }
                guard router.linkSources.contains(patternLinkSource) else {
                    throw ValidationError.invalidLinkSource(route.pattern, patternLinkSource)
                }

                switch route.acceptPolicy {
                case .any:
                    continue
                case .only(let linkSources):
                    guard linkSources.extract().contains(patternLinkSource) else {
                        throw ValidationError.invalidLinkSource(route.pattern, patternLinkSource)
                    }

                }
            }
        }

    }

    public enum ValidationError: LocalizedError {
        case unknownLinkSource(Set<LinkSource>)
        case duplicatedRoute(Path, Route.AcceptPolicy)
        case invalidLinkSource(Pattern, LinkSource)

        public var errorDescription: String? {
            switch self {
            case .unknownLinkSource(let linkSources):
                return "Unknown link sources \(linkSources) is registered"
            case .duplicatedRoute(let path, let acceptPolicy):
                return "Route definition for \(path) (accepts \(acceptPolicy)) is duplicated"
            case .invalidLinkSource(let pattern, let linkSource):
                return "Pattern '\(pattern)' contains invalid link source '\(linkSource)'."
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
            InvalidLinkSourceRule(),
        ]

        func validate() throws {
            for rule in rules {
                try rule.validate(for: router)
            }
        }
    }
}
