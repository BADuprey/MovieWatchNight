// Example Code (from google AI, it might not be good)
import Foundation

func doRequest(url: URL, parameters: [String: String], completion: @escaping (Result<Data, Error>) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Construct the x-www-form-urlencoded body
    var components = URLComponents()
    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    let queryString = components.query ?? ""
    request.httpBody = queryString.data(using: .utf8)

    // Set the Content-Type header
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let error = NSError(domain: "HTTPError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP request failed with status code \(statusCode)"])
            completion(.failure(error))
            return
        }

        guard let data = data else {
            let error = NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
            completion(.failure(error))
            return
        }

        completion(.success(data))
    }
    task.resume()
}

// Example usage:
let targetURL = URL(string: "https://baduprey.w3.uvm.edu/cs3750/<functionName>")!
let postParameters = ["field1": "value1"]

performPostRequestWithoutJSON(url: targetURL, parameters: postParameters) { result in
    switch result {
    case .success(let data):
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
