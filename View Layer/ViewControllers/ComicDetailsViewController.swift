import UIKit

class ComicDetailsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  var comicVM = ComicViewModel(networkServices: MarvelAPIClient())
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 600
    self.view.alpha = 0
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let returnDataClosure: (ComicMetaData?, CustomError?) -> () = { (comicMetaData, error) in
      DispatchQueue.main.async {
        if error != nil {
          print(error!.errorDescription)
        } else {
          self.tableView.reloadData()
        }
      }
    }
    
    let returnImageClosure:(UIImage?, CustomError?) -> () = {(image,error) in
      DispatchQueue.main.async {
       if error != nil {
         print(error!.errorDescription)
       } else {
         //self.tableView.reloadData()
        self.tableView.reloadRows(at: [IndexPath(item:0, section:0)], with: .none)
       }
      }}
    
    comicVM.getComic(comicId: 61537, onReturnData: returnDataClosure
   , onReturnImage: returnImageClosure)
  }
  
  override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
    UIView.animate(withDuration: 1.5) {
          self.view.alpha = 1.0
      }
  }
}

extension ComicDetailsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comicVM.displayCells.count
  }
 
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cellData = comicVM.displayCells[indexPath.row]
    
    switch cellData.cellType {
    case .mainCell:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainInfoCell
      let mainCellData = cellData as! MainDisplayCell
      cell.comicInfo.text = mainCellData.description
      cell.title.text = mainCellData.title
      if let thumbNail = mainCellData.thumbNail {
        cell.thumbnail.image = thumbNail
      }
      return cell
      
    case .contributorCell:
      let cell = tableView.dequeueReusableCell(withIdentifier: "Contributors", for: indexPath) as! ContributorCell
      let contributorCellData = cellData as! ContributeDisplayCell
      cell.contributorTitle.text = contributorCellData.title
      cell.contributors.text = contributorCellData.contributors
      return cell
    case .publishDateCell:
      print("just date here")
    }
    return UITableViewCell()
    
  }
}
