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

// MARK: - Redux w/lenses
extension Todo {
    static func nameLens() -> Lens<Todo, String> { return Lens<Todo, String>(
        get: { $0.name },
        set: { Todo(name: $1, complete: $0.complete) }
    )}
    
    static func completeLens() -> Lens<Todo, Bool> { return Lens<Todo, Bool>(
        get: { $0.complete },
        set: { Todo(name: $0.name, complete: $1) }
    )}
}

struct AppState: StateType {
    let todos: [String:[Todo]]
    
    static func todosLens() -> Lens<AppState, [String:[Todo]]> { return Lens<AppState, [String:[Todo]]>(
        get: { $0.todos },
        set: { AppState(todos: $1) }
    )}
}

let mainStore = Store<AppState>(
    reducer: mainReducer,
    state: AppState(todos: [
        "home": homeTodos,
        "work": workTodos
    ])
)

protocol LensSetActionProtocol : Action {
    func updatedState(previousState: AppState) -> AppState
}

struct LensSetAction<SubStateType> : LensSetActionProtocol {
    let lens: Lens<AppState, SubStateType>
    let newSubState: SubStateType
    
    func updatedState(previousState: AppState) -> AppState {
        return lens.set(previousState, newSubState)
    }
}

func mainReducer(action: Action, state: AppState?) -> AppState {
    var newState: AppState = state!
    
    switch action {
    case let lensAction as LensSetActionProtocol:
        newState = lensAction.updatedState(previousState: newState)
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
        
        let homeLens = KeyLens<String, [Todo]>.ForKey("home")
        let homeTodosController = TodosViewControllerRedux(withLens: AppState.todosLens() ~> homeLens)
        homeTodosController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "first"), tag: 0)
        
        let workLens = KeyLens<String, [Todo]>.ForKey("work")
        let workTodosController = TodosViewControllerRedux(withLens: AppState.todosLens() ~> workLens)
        workTodosController.tabBarItem = UITabBarItem(title: "Work", image: UIImage(named: "second"), tag: 1)
        
        tabController.viewControllers = [homeTodosController, workTodosController]
        window!.rootViewController = tabController
    }
}

