<h1>Sense User Activity iOS</h1>

<p width="100%">
    <a href="https://github.com/sense-opensource/sense-user-activity-ios/blob/main/LICENSE">
        <img width="9%" src="https://custom-icon-badges.demolab.com/github/license/denvercoder1/custom-icon-badges?logo=law">
    </a>
    <img width="12.6%" src="https://badge-generator.vercel.app/api?icon=Github&label=Last%20Commit&status=May&color=6941C6"/> 
    <a href="https://discord.gg/hzNHTpwt">
        <img width="10%" src="https://badge-generator.vercel.app/api?icon=Discord&label=Discord&status=Live&color=6941C6"> 
    </a>
</p>

<h2>Welcome to Sense’s open source repository</h2>

<p width="100%">  
<img width="4.5%" src="https://custom-icon-badges.demolab.com/badge/Fork-orange.svg?logo=fork">
<img width="4.5%" src="https://custom-icon-badges.demolab.com/badge/Star-yellow.svg?logo=star">
<img width="6.5%" src="https://custom-icon-badges.demolab.com/badge/Commit-green.svg?logo=git-commit&logoColor=fff"> 
</p>

   ### 🖱️ User Activity

![Keystroke](https://img.shields.io/badge/Keystroke-blue)
![Scroll](https://img.shields.io/badge/Scroll_Metrics-green)
![Touch](https://img.shields.io/badge/Touch_Metrics-orange)
![Orientation](https://img.shields.io/badge/Orientation-purple)

<p> Sense is a client side library that enables you to identify users by pinpointing their hardware and software characteristics. This is done by computing a token that stays consistent in spite of any manipulation.</p>                           
<p> This tracking method works even in the browser's incognito mode and is not cleared by flushing the cache, closing the browser or restarting the operating system, using a VPN or installing AdBlockers. Sense is available as SenseOS for every open source requirement and is different from Sense PRO, our extremely accurate and detailed product.</p>

<h3>Getting started with Sense </h3>

<h3>Sense - iOS SDK</h3>

Sense is a device intelligence and identification tool. This tool collects a comprehensive set of attributes unique to a device or browser, forming an identity that will help businesses.
Requirements

<h3>Requirements</h3>

* OS 12.0 or above
* Swift version 5.0 and above

Note: If the application does not have the listed permissions, the values collected using those permissions will be ignored. To provide a valid device details, we recommend employing as much permission as possible based on your use-case.

Note: In your controller, there are at least two text fields and a scrollview.

Step 1 - Install SDK

```swift
 pod 'SenseOSUserActivity', '~> 0.0.2'
````

Step 2 - Import SDK

```swift
  import SenseOSUserActivity
````
Step 3 - Add Delegate Method

Add the delegate method in your Controller Class file
````swift
SenseOSUserActivityDelegate
````

Step 4 - Detect User Activity

Use the lines below to invoke ViewDidLoad.

```swift
SenseOSUserActivitySDK.initKeyStrokeBehaviour(for: [txtUsername, txtPassword]);
SenseOSUserActivitySDK.initScrollBehaviour(for: [scrollView]);
SenseOSUserActivitySDK.initTouchBehaviour(for: self.view)
```

Step 5 - Get Device Details

Use the line below to invoke any button action or ViewDidLoad to get the DeviceDetails.

```swift
 SenseOSUserActivitySDK.getBehaviourData(withDelegate: self)

```

Step 6 - Implement Delegate Method

Set and Implement our Delegate method to receive the Callback details

```swift
 extension ViewController: SenseOSUserActivityDelegate{
    func onFailure(message: String) {
        // Failure Callback.
    }
    func onSuccess(data: [String : Any]) {
        // Success Callback
    }
}

```

Sample Program

Here you can find the demonstration to do the integration.

```swift
import UIKit
import SenseOSUserActivity

class SenseOSController: UIViewController, SenseOSUserActivityDelegate {

  override func viewDidLoad() {
      super.viewDidLoad()
	SenseOSUserActivitySDK.initKeyStrokeBehaviour(for: [txtUsername, txtPassword]);
	SenseOSUserActivitySDK.initScrollBehaviour(for: [scrollView]);
	SenseOSUserActivitySDK.initTouchBehaviour(for: self.view)
      
  }

 @IBAction func btnSense(_ sender: Any) {
     
      SenseOSUserActivitySDK.getBehaviourData(withDelegate: self)
  }

  @objc func onSuccess(data: String) {     
      // Handle success callback
  }
  @objc func onFailure(message: String) {
      // Handle failure callback
  }
}
  
``` 

<h4>Plug and play, in just 4 steps</h3>  

1️⃣ Visit the GitHub Repository</br>
2️⃣ Download or Clone the Repository. Use the GitHub interface to download the ZIP file, or run.</br>
3️⃣ Run the Installer / Setup Script. Follow the setup instructions provided below.</br>
4️⃣ Start Testing. Once installed, begin testing and validating the accuracy of the metrics you're interested in.</br>

#### With Sense, you can  

✅ Predict user intent : Identify the good from the bad visitors with precision  
✅ Create user identities : Tokenise events with a particular user and device  
✅ Custom risk signals : Developer specific scripts that perform unique functions  
✅ Protect against Identity spoofing : Prevent users from impersonation  
✅ Stop device or browser manipulation : Detect user behaviour anomalies 

### Resources 

#### MIT license : 

Sense OS is available under the <a href="https://github.com/sense-opensource/sense-user-activity-ios/blob/main/LICENSE"> MIT license </a>

#### Contributors code of conduct : 

Thank you for your interest in contributing to this project! We welcome all contributions and are excited to have you join our community. Please read these <a href="https://github.com/sense-opensource/sense-user-activity-ios/blob/main/code_of_conduct.md"> code of conduct </a> to ensure a smooth collaboration.

#### Where you can get support :     
![Gmail](https://img.shields.io/badge/Gmail-D14836?logo=gmail&logoColor=white)       product@getsense.co 

Public Support:

For questions, bug reports, or feature requests, please use the Issues and Discussions sections on our repository. This helps the entire community benefit from shared knowledge and solutions.

Community Chat:

Join our Discord server (link) to connect with other developers, ask questions in real-time, and share your feedback on Sense.

Interested in contributing to Sense?

Please review our <a href="https://github.com/sense-opensource/sense-user-activity-ios/blob/main/CONTRIBUTING.md"> Contribution Guidelines </a> to learn how to get started, submit pull requests, or run the project locally. We encourage you to read these guidelines carefully before making any contributions. Your input helps us make Sense better for everyone!
