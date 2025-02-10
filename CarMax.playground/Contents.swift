import Foundation

// property wrapper to validate price
@propertyWrapper
struct ValidatePrice{
    private var value:Double;
    
    var wrappedValue:Double{
        get{ value }
        set{ value = max(0,newValue) }
    }
    
    init(wrappedValue:Double){
        self.value = max(0, wrappedValue)
    }
    
    
}

// struct to represent a car
// make model year

// class for person, subclass for salesMan and customer

struct Car {
    var make: String
    var model: String
    var year: Int
    
    @ValidatePrice var price: Double
    
    func carDescription()->String{
        return "\(self.year) \(self.make) \(self.model) : $\(price)"
    }
}

// base class for person

class Person{
    var name: String
    var contactNumber: String
    
    init(name: String, contactNumber: String) {
        self.name = name
        self.contactNumber = contactNumber
    }
    
    func contactInfo()->String{
        return "Name: \(self.name), Contact: \(self.contactNumber)"
    }
}

// subclass for a customer

class Customer: Person{
    var purchasedCars: [Car] = []
    
    func addCar(car: Car)->Void{
        purchasedCars.append(car)
    }
    
    func listPurchasedCars()->String{
        return purchasedCars.map{
            $0.carDescription()
        }.joined(separator: "\n")
    }
    
}

//subclass for salesperson
class SalesPerson: Person{
    var employeeID: String
    
    init(name: String, contactNumber: String, employeeID: String) {
        self.employeeID = employeeID
        super.init(name: name, contactNumber: contactNumber)
    }
    
    override func contactInfo() -> String {
        return super.contactInfo() + ", Employee ID:  \(self.employeeID)"
    }
}

let car1 = Car(make: "Toyota", model: "Camry", year: 2020, price: -100)
let car2 = Car(make: "Ford", model: "Mustang", year: 2024, price: 200000)

var customer1 = Customer(name: "John Doe", contactNumber: "111-111-1111")
customer1.addCar(car: car1)
customer1.addCar(car: car2)
print("Customer Info: ")
print(customer1.contactInfo())
print("Customer Purchased: ")
print(customer1.listPurchasedCars())

print(car1.carDescription())

