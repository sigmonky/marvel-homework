import UIKit

class ComicDetailsViewController: UIViewController {
  let auteurs = Auteur.auteursFromBundle()
  @IBOutlet weak var tableView: UITableView!
  var comicVM = ComicViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 600
    self.view.alpha = 0
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    comicVM.getComic(comicId: 61537) { (comicMetaData,thumbNail, error) in
      DispatchQueue.main.async {
        if error != nil {
          print(error!.errorDescription)
        } else {
          self.tableView.reloadData()
        }
      }
    }
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
    return 3
  }
 
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch indexPath.row {
      case 0:
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainInfoCell
        let auteur = auteurs[indexPath.row]
        
        cell.comicInfo.text = auteur.bio
        cell.thumbnail.image = UIImage(named: auteur.image)
        cell.title.text = auteur.name
        cell.selectionStyle = .none
        return cell
      case 1:
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contributors", for: indexPath) as! ContributorCell
        cell.contributorTitle.text = "Cover"
        cell.contributors.text = "Colorist: Steve Buccellato\nEditor: Tom Defalco\nEditor: Bob Harras\nInker: Josef Rubinstein\nLetterer: Joe Rosen\nPenciller: Guang Yap\nWriter: Louise Simonson"
        cell.selectionStyle = .none
        return cell
      case 2:
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contributors", for: indexPath) as! ContributorCell
        cell.contributorTitle.text = "Interior"
        cell.contributors.text = "Penciller: Rob Liefield"
        cell.selectionStyle = .none
        return cell
      default:
        return UITableViewCell()
      }
    
  }
}
