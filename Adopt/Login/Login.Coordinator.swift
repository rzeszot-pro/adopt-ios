//
//  Adopt
//
//  Created by Damian Rzeszot on 31/12/2019.
//  Copyright © 2019 Damian Rzeszot. All rights reserved.
//

import Foundation

extension Login {

    class Coordinator: LoginViewControllerDelegate {
        let login: (Coordinator.Output) -> Void
        let close: () -> Void

        init(login: @escaping (Coordinator.Output) -> Void, close: @escaping () -> Void) {
            self.login = login
            self.close = close
        }

        struct Request: Codable {
            struct User: Codable {
                let email: String
                let password: String
            }
            let user: User
        }

        typealias Response = Result<Success, Failure>

        struct Success: Codable {
            let token: String
        }
        enum Failure: Error {
            case invalid
            case parsing(Error)
            case unknown
        }

        struct Output {
            let email: String
            let token: String
        }

        // MARK: -

        func login(email: String, password: String, completion: @escaping (Response) -> Void) {
            var request = URLRequest(url: URL(string: "https://adopt.rzeszot.pro/api/auth/sign_in")!)
            request.httpMethod = "POST"
            request.httpBody = try! JSONEncoder().encode(Request(user: Request.User(email: email, password: password)))
            request.allHTTPHeaderFields?["Content-Type"] = "application/json"

            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                print("sign in | done")

                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 400 {
                        completion(.failure(.invalid))
                        return
                    }
                }

                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(Success.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.parsing(error)))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }

            task.resume()
        }

        // MARK: - LoginViewControllerDelegate

        func login(_ vc: LoginViewController, didLoginWith email: String, and password: String) {
            login(email: email, password: password) { response in
                switch response {
                case .success(let success):
                    DispatchQueue.main.async {
                        let output = Output(email: email, token: success.token)
                        self.login(output)
                    }
                    break
                case .failure:
                    print("failure")
                    break
                }
            }
        }

        func loginDidClose(_ vc: LoginViewController) {
            close()
        }

    }
}
