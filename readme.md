Alamofire+RxSwift
---
学习``Alamofire``配合``RxSwift``进行网络请求

```swift
// in ViewController.swift
import UIKit
import GLEKit
import FlexView
import Alamofire
import RxSwift

class ViewController: UIViewController {
    var todoList = [Todo]()
    var listView = FlexView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // list init
        self.list()
        
        let todoId: Int? = nil
        // 用 todoId 创建 Observable
        _ = Observable.just(todoId)
            // 切换 Observable
            .map { tid in TodoRouter.get(tid) }
            // 切换 Observable
            .flatMap { route in Todo.getList(from: route) }
            // 订阅 Observable
            // 此时 Observable 为自定义封装了Alamofire请求的Observable
            .subscribe(onNext: { (todos: [[String: Any]]) in
                // 拿到格式化后的数据
                self.todoList = todos.compactMap { Todo(json: $0) }
                // 刷新UI
                self.reloadData()
            })
    }

    func list() {
        listView.frame = self.view.frame
        listView.alwaysBounceVertical = true
        self.reloadData()
        self.view.addSubview(listView)
    }
    
    func reloadData() {
        // 清空listView
        listView.subviews.forEach { listView.removeSubview($0) }
        // 重建listView
        todoList.forEach { todo in
            let label = UILabel()
            label.frame.size = CGSize(width: self.view.frame.width, height: 44)
            label.frame.origin.x = 12
            label.text = todo.title
            label.textColor = .black
            let line = UIView()
            line.frame.size = CGSize(width: self.view.frame.width, height: 0.5)
            line.frame.origin.x = 12
            line.backgroundColor = .gray
            listView.addSubview(label)
            listView.addSubview(line)
            
            if todo.completed {
                label.textColor = .lightGray
            }
        }
        // 重设contentSize
        listView.contentSizeToFit(by: .height)
    }
}
```

```swift
// in TodoRouter.swift
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
        
        return try JSONEncoding.default.encode(request, with: params)
    }
}
```

```swift
// in todo.swift
import Foundation
import RxSwift
import Alamofire

// Todo Model
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

// Todo Request Observable
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
```
