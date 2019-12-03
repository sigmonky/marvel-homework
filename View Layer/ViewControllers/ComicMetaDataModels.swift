//Marvel Homework by Randy Weinstein

import UIKit

enum DesignDomain {
    case cover
    case interior
}

struct ComicBookCreator {
    var name: String
    var role: String
    var domain: DesignDomain
}

struct ComicMetaData {
    var title: String
    var description: String
    var creators: [ComicBookCreator]
}

