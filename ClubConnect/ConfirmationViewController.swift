import UIKit

final class ConfirmationViewController: UIViewController {
    var studentName = "Club Member"
    var wantsMeetingReminders = false
    var role = "Member"

    @IBOutlet private weak var messageLabel: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Confirmation"
        let reminderStatus = wantsMeetingReminders ? "ON" : "OFF"
        messageLabel.text = "Thanks, \(studentName)! You've signed up as a \(role). Meeting reminders: \(reminderStatus)."
    }
}
