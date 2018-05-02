//
//  ViewController.swift
//  Alamofire+RxSwiftByTodoList
//
//  Created by gavinning on 2018/5/2.
//  Copyright © 2018年 gavinning. All rights reserved.
//

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
        reloadData()
        self.view.addSubview(listView)
    }
    
    func reloadData() {
        // 清空listView
        listView.subviews.forEach { listView.removeSubview($0) }
        // 根据数据重新创建UI
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

