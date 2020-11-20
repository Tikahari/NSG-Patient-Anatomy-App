////
////  APIClient.swift
////  NSG_Metal_Render3D
////
////  Created by Daniel Williamson on 11/1/20.
////
//

//import Foundation
//import Alamofire
//import PromisedFuture
//
//class APIClient {
//    @discardableResult
//    private static func performRequest<T:Decodable>(route:APIRouter, decoder: JSONDecoder = JSONDecoder()) -> Future<T, AFError> {
//        print("Printing Route:")
//        print(route)
//        return Future(operation: { completion in
//            AF.request(route).responseDecodable (decoder: decoder, completionHandler: { (response: DataResponse<T, AFError>) in
//                print(response)
//                switch response.result {
//                    case .success(let value):
//                        completion(.success(value))
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//            })
//
//        })
//
//    }
//
//    static func login(username: String, password: String) -> Future<HeadScanJSONModel, AFError> {
//        return performRequest(route: APIRouter.login(username: username, password: password))
//    }
//
//}
//
