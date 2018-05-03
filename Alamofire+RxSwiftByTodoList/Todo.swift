//
//  Todo.swift
//  Alamofire+RxSwiftByTodoList
//
//  Created by gavinning on 2018/5/2.
//  Copyright © 2018年 gavinning. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class Todo: CustomStringConvertible {
    var id: Int?
    var title: String
    var completed: Bool
    var description: String {
        return """
        id: \(self.id ?? 0),
        title: \(self.title),
        completed: \(self.completed)
        """
    }
    
    init(id: Int, title: String, completed: Bool) {
        self.id = id
        self.title = title
        self.completed = completed
    }
    
    required init?(json: [String: Any]) {
        guard let todoId = json["id"] as? Int,
            let title = json["title"] as? String,
            let completed = json["completed"] as? Bool else {
                return nil
        }
        
        self.id = todoId
        self.title = title
        self.completed = completed
    }
}

enum GetTodoListError: Error {
    case cannotConvertServerResponse
}

extension Todo {
    class func getList(from route: TodoRouter) -> Observable<[[String: Any]]> {
        return Observable.create {
            observer -> Disposable in
            
            let request = Alamofire.request(route)
                .responseJSON { response in
                    guard response.result.error == nil else {
                        print(response.result.error!)
                        observer.onError(response.result.error!)
                        return
                    }
                    
                    guard let todos = response.result.value as? [[String: Any]] else {
                        print("Cannot read the Todo list from the server.")
                        observer.onError(GetTodoListError.cannotConvertServerResponse)
                        return
                    }
                    
                    observer.onNext(todos)
                    observer.onCompleted()
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
