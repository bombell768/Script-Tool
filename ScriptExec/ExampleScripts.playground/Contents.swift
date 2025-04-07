import Foundation


// 1. Sortowanie tablicy liczb
var numbers = [5, 2, 9, 1, 5, 6, 8, 3]
numbers.sort()
print("Posortowane liczby:")

for number in numbers {
    print(number)
    sleep(1)
}


// Zdefiniowanie struktury
struct Person {
    var name: String
    var age: Int
    
    // Funkcja do sprawdzania, czy osoba jest pełnoletnia
    func isAdult() -> Bool {
        return age >= 18
    }
}

// Funkcja próbująca konwertować tekst na liczbę całkowitą
func stringToInt(_ input: String) throws -> Int {
    if let number = Int(input) {
        return number
    } else {
        throw ConversionError.invalidInput
    }
}

// Funkcja, która rzuca wyjątek w przypadku nieznalezienia osoby
func findPerson(by name: String, in persons: [Person]) throws -> Person {
    if let person = persons.first(where: { $0.name == name }) {
        return person
    } else {
        throw PersonError.notFound
    }
}

// Enum do obsługi błędów
enum ConversionError: Error {
    case invalidInput
}

enum PersonError: Error {
    case notFound
}

// Przykład użycia słów kluczowych

let persons = [
    Person(name: "Alice", age: 28),
    Person(name: "Bob", age: 17),
    Person(name: "Charlie", age: 22)
]

func main() {
    // Tworzenie instancji osoby
    let person = Person(name: "Alice", age: 28)
    
    // Użycie 'if' do sprawdzenia pełnoletności
    if person.isAdult() {
        print("\(person.name) is an adult.")
    } else {
        print("\(person.name) is not an adult.")
    }
    
    // Użycie 'for' do iteracji po osobach
    for person in persons {
        print("\(person.name), \(person.age) years old.")
    }
    
    // Użycie 'try', 'catch' oraz 'throw' do konwersji tekstu na liczbę
    let userInput = "100"
    do {
        let number = try stringToInt(userInput)
        print("Converted number: \(number)")
    } catch {
        print("Failed to convert input: \(error)")
    }
    
    // Użycie 'guard' w celu sprawdzenia, czy osoba istnieje
    do {
        let foundPerson = try findPerson(by: "Bob", in: persons)
        print("Found person: \(foundPerson.name), Age: \(foundPerson.age)")
    } catch PersonError.notFound {
        print("Person not found.")
    } catch {
        print("An unknown error occurred.")
    }
    
    // Zastosowanie 'switch' do sprawdzenia różnych wartości
    let result = 2
    switch result {
    case 1:
        print("Result is one.")
    case 2:
        print("Result is two.")
    default:
        print("Result is something else.")
    }
    
    // Zastosowanie 'in' w pętli 'for'
    for person in persons where person.age > 18 {
        print("\(person.name) is older than 18.")
    }
    
    // Zastosowanie 'is' do sprawdzenia typu obiektu
    if person is Person {
        print("\(person.name) is a Person.")
    }
    
    // Użycie 'defer' w funkcji
    func fetchData() {
        defer {
            print("Data fetching completed.")
        }
        print("Fetching data...")
    }
    
    fetchData()
    
    // Zastosowanie 'return' w funkcji
    func multiply(_ a: Int, _ b: Int) -> Int {
        return a * b
    }
    
    let resultMultiply = multiply(3, 4)
    print("Multiplication result: \(resultMultiply)")
}

main()
