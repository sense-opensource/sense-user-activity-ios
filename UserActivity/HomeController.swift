

import UIKit
import SenseOSUserActivity

class HomeController: UIViewController,SenseOSUserActivityDelegate, UIScrollViewDelegate {

    @IBOutlet weak var jsonTextView: UITextView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnSubmit: UIButton!

    @IBOutlet weak var textViewConstantHeightOutlet: NSLayoutConstraint!
    @IBOutlet weak var viewConstantHeightOutlet: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        SenseOSUserActivity.initKeyStrokeBehaviour(for: [txtUsername, txtPassword]);
        SenseOSUserActivity.initScrollBehaviour(for: [scrollView]);
        SenseOSUserActivity.initTouchBehaviour(for: self.view)
        
        mainView.applyBorderAndShadow(borderWidth: 0.3, borderColor: UIColor.lightGray, cornerRadius: 10)
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        txtUsername.resignFirstResponder()
        txtPassword.resignFirstResponder()
        view.endEditing(true)
        guard let username = txtUsername.text, !username.isEmpty,
                 let password = txtPassword.text, !password.isEmpty else {
               showToast(message: "Username or Password cannot be empty", duration: 2.0)
               return
           }
        jsonTextView.text = ""
        SenseOSUserActivity.getBehaviourData(withDelegate: self)
    }
    @IBAction func btnReset(_ sender: Any) {
        txtUsername.text = ""
        txtPassword.text = ""
        jsonTextView.text = ""
        txtPassword.resignFirstResponder()
        txtPassword.resignFirstResponder()
       
        
    }
    
    func showToast(message: String, duration: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
    func onFailure(message: String) {
        DispatchQueue.main.async {
          
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onSuccess(data: String) {
        
        let encodedString = "\(data)"
        let jsonStringWithLineNumbers = addLineNumbersToJson(jsonString: encodedString)
        self.jsonTextView.text = jsonStringWithLineNumbers
    }
    
    func addLineNumbersToJson(jsonString: String) -> String {
        let lines = jsonString.split(separator: "\n")
        let linesCountss = jsonString.split(separator: "\n").count
        var numberedLines: [String] = []
        
        let maxLineNumberWidth = String(lines.count).count
        
        for (index, line) in lines.enumerated() {
            let lineNumber = String(index + 1)
            let paddedLineNumber = lineNumber.padding(toLength: maxLineNumberWidth, withPad: " ", startingAt: 0)
            let numberedLine = "\(paddedLineNumber) \(line)"
            numberedLines.append(numberedLine)
        }
        
        let baseHeight: CGFloat = 50
        let lineHeight: CGFloat = 18.5
        let newHeight = baseHeight + CGFloat(linesCountss) * lineHeight
         let viewConstantHeight = CGFloat(textViewConstantHeightOutlet.constant)
        let totalConstant = viewConstantHeight + CGFloat(linesCountss)
        textViewConstantHeightOutlet.constant = newHeight
        viewConstantHeightOutlet.constant = newHeight + 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return numberedLines.joined(separator: "\n")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
}
