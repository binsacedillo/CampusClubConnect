import CoreData
import UIKit

final class ClubListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var statusLabel: UILabel!

    private let service = ClubService()
    private var clubs: [NSManagedObject] = []

    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Clubs"
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ClubCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLocalClubs()
        syncRemoteClubs()
    }

    @IBAction private func refreshTapped(_ sender: UIBarButtonItem) {
        syncRemoteClubs()
    }

    private func loadLocalClubs() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Club")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            clubs = try context.fetch(request)
            tableView.reloadData()
            statusLabel.text = clubs.isEmpty ? "No clubs loaded yet." : "\(clubs.count) clubs"
        } catch {
            statusLabel.text = "Saved clubs could not be loaded."
            print("Core Data fetch failed: \(error.localizedDescription)")
        }
    }

    private func syncRemoteClubs() {
        statusLabel.text = "Refreshing clubs…"
        service.fetchClubs { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.statusLabel.text = "Refresh failed. Showing saved clubs."
                    print("Club refresh failed: \(error.localizedDescription)")
                }
            case .success(let remoteClubs):
                DispatchQueue.main.async {
                    self?.replaceLocalClubs(with: remoteClubs)
                }
            }
        }
    }

    private func replaceLocalClubs(with remoteClubs: [ClubDTO]) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Club")
        do {
            try context.fetch(request).forEach(context.delete)
            for dto in remoteClubs {
                let club = NSEntityDescription.insertNewObject(forEntityName: "Club", into: context)
                club.setValue(dto.name, forKey: "name")
                club.setValue(dto.category, forKey: "category")
                club.setValue(dto.iconName, forKey: "iconName")
            }
            try context.save()
            loadLocalClubs()
        } catch {
            context.rollback()
            statusLabel.text = "Clubs could not be saved."
            print("Core Data sync failed: \(error.localizedDescription)")
        }
    }
}

extension ClubListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        clubs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClubCell", for: indexPath)
        let club = clubs[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = club.value(forKey: "name") as? String
        content.secondaryText = club.value(forKey: "category") as? String
        if let iconName = club.value(forKey: "iconName") as? String {
            content.image = UIImage(systemName: iconName)
        }
        content.imageProperties.tintColor = UIColor(red: 0, green: 122 / 255, blue: 51 / 255, alpha: 1)
        cell.contentConfiguration = content
        return cell
    }
}
