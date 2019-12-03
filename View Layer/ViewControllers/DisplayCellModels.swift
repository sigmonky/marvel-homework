//Marvel Homework by Randy Weinstein

import UIKit

protocol ComicDisplayCell {
  var cellType: DisplayCellType { get set }
}

enum DisplayCellType {
  case mainCell
  case contributorCell
  case publishDateCell
}

struct MainDisplayCell: ComicDisplayCell {
  var cellType: DisplayCellType = .mainCell
  var title: String?
  var description: String?
  var thumbNail: UIImage?
  
  init( initTitle: String? = nil, initDescription: String? = nil, initThumbNail: UIImage? = nil) {
    self.title = initTitle
    self.description = initDescription
    self.thumbNail = initThumbNail
  }
}

struct ContributeDisplayCell: ComicDisplayCell {
  var cellType: DisplayCellType = .contributorCell
  var title: String?
  var contributors: String?
  
  init( initTitle: String? = nil, initContributors: String? = nil) {
    self.title = initTitle
    self.contributors = initContributors
  }
}

