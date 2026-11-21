import UIKit
import PhotosUI

final class WelcomeViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var reminderSwitch: UISwitch!
    @IBOutlet private weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var profileImageView: UIImageView!

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Campus Club Connect"
        titleLabel.text = "Campus Club Connect"

        let feuGreen = UIColor(red: 0 / 255, green: 122 / 255, blue: 51 / 255, alpha: 1)
        let feuGold = UIColor(red: 242 / 255, green: 169 / 255, blue: 0 / 255, alpha: 1)

        titleLabel.textColor = feuGreen
        reminderSwitch.onTintColor = feuGreen
        roleSegmentedControl.selectedSegmentTintColor = feuGold
        roleSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)
        roleSegmentedControl.setTitleTextAttributes([.foregroundColor: feuGreen], for: .normal)
        nameTextField.layer.borderColor = feuGreen.withAlphaComponent(0.35).cgColor
        nameTextField.layer.borderWidth = 1
        profileImageView.layer.cornerRadius = 12
        profileImageView.layer.masksToBounds = true
        loadSavedProfilePhoto()
    }

    @IBAction private func choosePhotoTapped(_ sender: UIButton) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error {
                print("Photo selection failed: \(error.localizedDescription)")
                return
            }
            guard let image = object as? UIImage else { return }

            self?.saveProfilePhoto(image)

            DispatchQueue.main.async {
                self?.profileImageView.image = image
                self?.profileImageView.contentMode = .scaleAspectFill
            }
        }
    }

    private var profilePhotoURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("profile-photo.jpg")
    }

    private func saveProfilePhoto(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let url = profilePhotoURL else { return }
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print("Profile photo could not be saved: \(error.localizedDescription)")
        }
    }

    private func loadSavedProfilePhoto() {
        guard let url = profilePhotoURL,
              let image = UIImage(contentsOfFile: url.path) else { return }
        profileImageView.image = image
        profileImageView.contentMode = .scaleAspectFill
    }

    @IBAction private func joinClubTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        performSegue(withIdentifier: "ShowConfirmationSegue", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowConfirmationSegue",
              let destination = segue.destination as? ConfirmationViewController else {
            return
        }

        let enteredName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        destination.studentName = enteredName.isEmpty ? "Club Member" : enteredName
        destination.wantsMeetingReminders = reminderSwitch.isOn
        destination.role = roleSegmentedControl.selectedSegmentIndex == 1 ? "Officer" : "Member"
    }
}
