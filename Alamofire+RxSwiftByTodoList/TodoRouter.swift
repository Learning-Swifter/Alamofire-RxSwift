//
//  TodoRouter.swift
//  Alamofire+RxSwiftByTodoList
//
//  Created by gavinning on 2018/5/2.
//  Copyright © 2018年 gavinning. All rights reserved.
//

import Foundation
import Alamofire

enum TodoRouter: URLRequestConvertible {
    static let baseURL = "https://jsonplaceholder.typicode.com/"
    
    case get(Int?)
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            /// TODO: Add other HTTP methods here
            }
        }
        
        var params: [String: Any]? {
            switch self {
            case .get:
                return nil
            /// TODO: Add other HTTP methods here
            }
        }
        
        var url: URL {
            var relativeURL = "todos"
            
            switch self {
            case .get(let todoId):
                if let tid = todoId {
                    relativeURL = "todos/\(tid)"
                }
            /// TODO: Add other HTTP methods here
            }
            
            let url = URL(string: TodoRouter.baseURL)!.appendingPathComponent(relativeURL)
            return url
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // JSONEncoding.default 带参数请求会失败
        return try URLEncoding.default.encode(request, with: params)
    }
}
