//
//  AppDelegate.swift
//  todoapp
//
//  Created by Dave Fishel on 4/5/19.
//  Copyright © 2019 Dave Fishel. All rights reserved.
//

import ReSwift
import RxSwift
import UIKit

// MARK: - Model
struct Todo {
    let name: String
    let complete: Bool
}

let homeTodos = [
    Todo(name: "Buy dog food", complete: false),
    Todo(name: "Do my laundry", complete: true)
]

let workTodos = [
    Todo(name: "Something something scrum", complete: false),
    Todo(name: "1 on 1 with so and so", complete: false)
]

// MARK: - Rx app stuff
typealias TodoListRx = Variable<[Todo]>

let homeTodosRx = TodoListRx(homeTodos)
let workTodosRx = TodoListRx(workTodos)

// MARK: - Redux app stuff
struct AppState: StateType {
    let todos: [String:[Todo]]
}

let mainStore = Store<AppState>(
    reducer: mainReducer,
    state: AppState(todos: [
        "home": homeTodos,
        "work": workTodos
    ])
)

struct UpdateTodosAction: Action {
    let listId: String
    let todos: [Todo]
    let note: String
}

func mainReducer(action: Action, state: AppState?) -> AppState {
    return AppState(
        todos: todosReducer(action: action, state: state!.todos)
    )
}

func todosReducer(action: Action, state: [String:[Todo]]) -> [String:[Todo]] {
    var newState = state
    
    switch action {
    case let updateAction as UpdateTodosAction:
        newState = Dictionary(uniqueKeysWithValues:
            state.map { return ($0.key,
                                $0.key == updateAction.listId ? updateAction.todos : $0.value) }
        )
        break;
    default:
        break;
    }
    
    return newState
}
// MARK: -

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        
        //initRxApp()
        initReduxApp()
        
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func initRxApp() {
        let tabController = UITabBarController()
        tabController.tabBar.tintColor = .purple
        
        let homeTodosController = TodosViewControllerRx(withTodos: homeTodosRx)
        homeTodosController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "first"), tag: 0)
        
        let workTodosController = TodosViewControllerRx(withTodos: workTodosRx)
        workTodosController.tabBarItem = UITabBarItem(title: "Work", image: UIImage(named: "second"), tag: 1)
        
        tabController.viewControllers = [homeTodosController, workTodosController]
        window!.rootViewController = tabController
    }
    
    func initReduxApp() {
        let tabController = UITabBarController()
        tabController.tabBar.tintColor = .purple
        
        let homeTodosController = TodosViewControllerRedux(withListId: "home")
        homeTodosController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "first"), tag: 0)
        
        let workTodosController = TodosViewControllerRedux(withListId: "work")
        workTodosController.tabBarItem = UITabBarItem(title: "Work", image: UIImage(named: "second"), tag: 1)
        
        tabController.viewControllers = [homeTodosController, workTodosController]
        window!.rootViewController = tabController
    }
}

