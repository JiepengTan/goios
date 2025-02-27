import UIKit

class ViewController: UIViewController {
    
    private let stackView = UIStackView()
    private let resultLabel = UILabel()
    private let inputField1 = UITextField()
    private let inputField2 = UITextField()
    private let addButton = UIButton(type: .system)
    private let helloButton = UIButton(type: .system)
    private let factorialButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Configure result label
        resultLabel.text = "Result will appear here"
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        resultLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        // Configure input fields
        inputField1.placeholder = "Enter first number"
        inputField1.borderStyle = .roundedRect
        inputField1.keyboardType = .numberPad
        inputField1.translatesAutoresizingMaskIntoConstraints = false
        
        inputField2.placeholder = "Enter second number/name/factorial"
        inputField2.borderStyle = .roundedRect
        inputField2.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure buttons
        addButton.setTitle("Add Numbers", for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        helloButton.setTitle("Say Hello", for: .normal)
        helloButton.addTarget(self, action: #selector(helloButtonTapped), for: .touchUpInside)
        
        factorialButton.setTitle("Calculate Factorial", for: .normal)
        factorialButton.addTarget(self, action: #selector(factorialButtonTapped), for: .touchUpInside)
        
        // Add views to stack
        stackView.addArrangedSubview(resultLabel)
        stackView.addArrangedSubview(inputField1)
        stackView.addArrangedSubview(inputField2)
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(helloButton)
        stackView.addArrangedSubview(factorialButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            inputField1.widthAnchor.constraint(equalToConstant: 200),
            inputField2.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func addButtonTapped() {
        guard let num1 = Int(inputField1.text ?? "0"),
              let num2 = Int(inputField2.text ?? "0") else {
            resultLabel.text = "Please enter valid numbers"
            return
        }
        
        let result = GoIOSBridge.addNumbers(a: num1, b: num2)
        resultLabel.text = "Result: \(result)"
    }
    
    @objc private func helloButtonTapped() {
        let name = inputField2.text ?? "World"
        let greeting = GoIOSBridge.sayHello(name: name)
        resultLabel.text = greeting
    }
    
    @objc private func factorialButtonTapped() {
        guard let num = Int(inputField1.text ?? "0") else {
            resultLabel.text = "Please enter a valid number"
            return
        }
        
        let result = GoIOSBridge.calculateFactorial(n: num)
        resultLabel.text = "Factorial: \(result)"
    }
}
