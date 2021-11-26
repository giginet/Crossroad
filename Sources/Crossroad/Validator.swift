import Foundation

protocol ValidationRule {
    func validate<UserInfo>(for: Router<UserInfo>) throws
}

extension Router {
    private struct UnknownLinkSourceRule: ValidationRule {
        func validate<UserInfo>(for router: Router<UserInfo>) throws {
            for route in router.routes {
                guard case let .only(acceptSources) = route.acceptPolicy else {
                    continue
                }
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
                    acceptSources = linkSources
                }

                let count = router.routes.filter { other in
                    switch other.acceptPolicy {
                    case .any:
                        return route.path == other.path
                    case .only(let linkSources):
                        return route.path == other.path && !linkSources.isDisjoint(with: acceptSources)
                    }
                }.count
                guard count == 1 else {
                    throw ValidationError.duplicatedRoute(route.path.absoluteString, (route.acceptPolicy as? Route.AcceptPolicy) ?? .any) // need casting. it seems to be a compiler's bug
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
                    throw ValidationError.invalidLinkSource(route.pattern.absoluteString, patternLinkSource)
                }

                switch route.acceptPolicy {
                case .any:
                    continue
                case .only(let linkSources):
                    guard linkSources.contains(patternLinkSource) else {
                        throw ValidationError.invalidLinkSource(route.pattern.absoluteString, patternLinkSource)
                    }

                }
            }
        }

    }

    private struct InvalidUniversalLinkSourceRule: ValidationRule {
        func validate<UserInfo>(for router: Router<UserInfo>) throws {
            for linkSource in router.linkSources {
                switch linkSource {
                case .customURLScheme:
                    continue
                case .universalLink(let url):
                    guard !url.isFileURL else {
                        throw ValidationError.invalidUniversalLinkSource(url)
                    }

                    guard url.host != nil && url.scheme != nil else {
                        throw ValidationError.invalidUniversalLinkSource(url)
                    }

                    guard url.path.isEmpty || url.path == "/" else {
                        throw ValidationError.universalLinkSourceContainsPath(url)
                    }
                }
            }
        }
    }

    private struct InvalidSchemeLinkSourceRule: ValidationRule {
        private let wellKnownSchemes = [
            "http",
            "https",
            "tel",
            "facetime",
            "mailto",
        ]

        func validate<UserInfo>(for router: Router<UserInfo>) throws {
            for linkSource in router.linkSources {
                switch linkSource {
                case .customURLScheme(let scheme):
                    guard !scheme.contains("/") else {
                        throw ValidationError.invalidSchemeLinkSource(scheme)
                    }
                    guard !wellKnownSchemes.contains(scheme) else {
                        throw ValidationError.wellKnownScheme(scheme)
                    }
                case .universalLink:
                    continue
                }
            }
        }
    }

    public enum ValidationError: LocalizedError {
        case unknownLinkSource(Set<LinkSource>)
        case duplicatedRoute(String, Route.AcceptPolicy)
        case invalidLinkSource(String, LinkSource)
        case invalidSchemeLinkSource(String)
        case wellKnownScheme(String)
        case invalidUniversalLinkSource(URL)
        case universalLinkSourceContainsPath(URL)

        public var errorDescription: String? {
            switch self {
            case .unknownLinkSource(let linkSources):
                return "Unknown link sources \(linkSources) is registered"
            case .duplicatedRoute(let pathString, let acceptPolicy):
                return "Route definition for \(pathString) (accepting \(acceptPolicy)) is duplicated"
            case .invalidLinkSource(let pattern, let linkSource):
                return "Pattern '\(pattern)' contains invalid link source '\(linkSource)'."
            case .wellKnownScheme(let scheme):
                return "Link source '\(scheme)' should not be well known."
            case .universalLinkSourceContainsPath(let url):
                return "Link source '\(url.absoluteString)' should not contain any pathes."
            case .invalidUniversalLinkSource(let url):
                return "Link source '\(url.absoluteString)' must be absolute URL."
            case .invalidSchemeLinkSource(let scheme):
                return "Link source '\(scheme)' contains invalid characters."
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
            InvalidUniversalLinkSourceRule(),
            InvalidSchemeLinkSourceRule(),
        ]

        func validate() throws {
            for rule in rules {
                try rule.validate(for: router)
            }
        }
    }
}
