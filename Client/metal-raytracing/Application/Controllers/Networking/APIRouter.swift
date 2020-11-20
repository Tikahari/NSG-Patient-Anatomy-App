////
////  Router.swift
////  NSG_Metal_Render3D
////
////  Created by Daniel Williamson on 11/1/20.
////
//
//import Foundation
//import Alamofire
//
//
//enum APIRouter: URLRequestConvertible {
//    
//    case login(username:String, password:String)
//    case scans
//    
//    // MARK: - HTTPMethod
//    private var method: HTTPMethod {
//        switch self {
//        case .login:
//            return .post
//        case .scans:
//            return .get
//        }
//    }
//    
//    // MARK: - Path
//    private var path: String {
//        switch self {
//        case .login:
//            return "/login?username"
//        case .scans:
//            return "/scans"
//        }
//    }
//    
//    // MARK: - Parameters
//    private var parameters: Parameters? {
//        switch self {
//        case .login(let username, let password):
//            return [Constants.APIParameterKey.username: username, Constants.APIParameterKey.password: password]
//        case .scans:
//            return nil
//        }
//    }
//    
//    // MARK: - URLRequestConvertible
//    func asURLRequest() throws -> URLRequest {
//        let url = try Constants.MedicalServer.baseURL.asURL()
//        
//        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
//        
//        // HTTP Method
//        urlRequest.httpMethod = method.rawValue
//        
//        // Common Headers
//        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
//        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
//                
//        // Parameters
//        if let parameters = parameters {
//            do {
//                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            } catch {
//                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
//            }
//        }
//        
//        return urlRequest
//    }
//}
