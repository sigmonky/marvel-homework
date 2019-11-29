import UIKit

class ComicDetailsViewController: UIViewController {
  let auteurs = Auteur.auteursFromBundle()
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let apiClient = MarvelAPIClient()
    apiClient.send(GetComic(comicId: 61537)) { response in
      print("\nGetComic finished:")

      switch response {
      case .success(let dataContainer):
        let comic = dataContainer.results.first

        print("  Title: \(comic?.title ?? "Unnamed comic")")
        print("  Thumbnail: \(comic?.thumbnail?.url.absoluteString ?? "None")")
        print("description -- \(comic?.description ?? "mystery")")
        print("\(String(describing: comic?.creators) )")
        print("\(String(describing: comic?.dates) )")
      case .failure(let error):
        print(error)
      }
    }
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 600
    self.view.alpha = 0
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
