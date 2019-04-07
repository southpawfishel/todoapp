//
//  TodosViewControllerRx
//  todoapp
//
//  Created by Dave Fishel on 4/5/19.
//  Copyright © 2019 Dave Fishel. All rights reserved.
//

import RxSwift
import UIKit

class TodosViewControllerRx: UIViewController {
    
    let todos: TodoListRx
    var dbag: DisposeBag? = nil
    
    var addButton: UIButton? = nil
    var todoTable: UITableView? = nil
    
    init(withTodos: TodoListRx) {
        self.todos = withTodos
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dbag = DisposeBag()
        todos.asObservable().subscribe(onNext: { list in
            self.updateView()
        }).disposed(by: dbag!)
        
        updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dbag = nil
    }
    
    func updateView() {
        todoTable?.reloadData()
    }
    
    func createView() {
        view.backgroundColor = .purple
        
        addButton = UIButton()
        view.addSubview(addButton!)
        addButton?.backgroundColor = .yellow
        addButton?.setTitleColor(.purple, for: .normal)
        addButton?.setTitle("+ Add Todo", for: .normal)
        addButton?.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
        addButton?.translatesAutoresizingMaskIntoConstraints = false
        addButton?.topAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        addButton?.leftAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
        addButton?.rightAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
        addButton?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        todoTable = UITableView()
        view.addSubview(todoTable!)
        todoTable?.delegate = self
        todoTable?.dataSource = self
        todoTable?.separatorColor = .purple
        todoTable?.backgroundColor = .yellow
        todoTable?.translatesAutoresizingMaskIntoConstraints = false
        todoTable?.topAnchor.constraint(equalTo: addButton!.bottomAnchor, constant: 20).isActive = true
        todoTable?.bottomAnchor.constraint(equalTo: view!.bottomAnchor).isActive = true
        todoTable?.leftAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.leftAnchor).isActive = true
        todoTable?.rightAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.rightAnchor).isActive = true
    }

    @objc func buttonPressed(sender: UIButton!) {
        todos.value = todos.value + [Todo(name: "test todo", complete: false)]
    }
}

extension TodosViewControllerRx : UITableViewDelegate, UITableViewDataSource {
    static var cellId = "TodoCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TodosViewControllerRx.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: TodosViewControllerRx.cellId)
            cell?.tintColor = .purple
            cell?.textLabel?.textColor = .purple
            cell?.backgroundColor = .yellow
            cell?.selectionStyle = .none
        }
        let todo = todos.value[indexPath.row]
        cell?.textLabel?.text = todo.name
        cell?.accessoryType = todo.complete ? .checkmark : .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        todos.value = todos.value.enumerated().map { index, todo in
            return index == indexPath.row ? Todo(name: todo.name, complete: !todo.complete) : todo
        }
    }
}