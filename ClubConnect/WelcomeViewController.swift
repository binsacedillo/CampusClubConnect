import UIKit

final class WelcomeViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var reminderSwitch: UISwitch!
    @IBOutlet private weak var roleSegmentedControl: UISegmentedControl!

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
