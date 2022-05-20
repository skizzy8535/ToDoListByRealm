//
//  Category.swift
//  ToDoListByRealm
//
//  Created by 林祐辰 on 2022/5/18.
//

import Foundation
import RealmSwift


class Category:Object {
    @objc dynamic var categoryName:String = ""
    @objc dynamic var color:String = ""
    let items = List<Items>()
}
