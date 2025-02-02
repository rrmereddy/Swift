// data types: Int, Str, Bool, doubles

let a:Int = 100;
var b = 200.20;

print(a)
print(b)

// Writing an if-else

var language:String = "none";
var reading:String?; // If initializing, do it to the default state

if language == "English"{
    reading = "Hello"
}
else if language == "French"{
    reading = "Bonjour"
}

print(reading ?? "Unknown") // A default value(not recommended for me, better to initialize with a default value)

print(Int(b)) // Type Casting double -> Int


//Function

func greeting(greet:String) -> String{
    if (greet == "English"){
        return "Hello"
    }
    else if (greet == "French"){
        return "Bonjour"
    }
    else{
        return "Unknown in Function"
    }
}

print(greeting(greet: "Hello"))

/*
 var language:String = "French";
 var reading:String; // If initializing, do it to the default state

 if language == "English"{
     reading = "Hello"
 }
 else if language == "French"{
     reading = "Bonjour"
 }
 else {
     reading = "Unknown language"
 }
 */



//

class car_attributes{
    var year:Int?
    var make:String?
    var model:String?
    
}

class car_stats: car_attributes{
    var miles:Int?
    var age:Int?
    var type:String?
    var accidents:Bool?
    var price:Double?
}

class test{
    var testing:Bool?
}
