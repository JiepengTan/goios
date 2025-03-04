import Foundation

class GoIOSBridge {
    
    static func addNumbers(a: Int, b: Int) -> Int {
        return Int(Simple(Int32(a), Int32(b)))
    }
    
    static func sayHello(name: String) -> String {
        guard let cString = name.cString(using: .utf8) else {
            return "Error converting string"
        }
        
        guard let result = Hello(cString) else {
            return "Error calling Go function"
        }
        
        let resultString = String(cString: result)
        free(UnsafeMutableRawPointer(mutating: result))
        
        return resultString
    }
    
    static func calculateFactorial(n: Int) -> Int {
        return Int(CalculateFactorial(Int32(n)))
    }
    
    static func testGoroutines(count: Int, workload: Int) -> Int {
        return Int(TestGoroutines(Int32(count), Int32(workload)))
    }
}
