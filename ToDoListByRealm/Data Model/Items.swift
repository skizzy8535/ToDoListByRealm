//
//  Items.swift
//  ToDoListByRealm
//
//  Created by 林祐辰 on 2022/5/18.
//

import Foundation
import RealmSwift


class Items:Object {
    @objc dynamic var title:String = ""
    @objc dynamic var done:Bool = false
    @objc dynamic var addDate:Date?
    var parentCategory = LinkingObjects(fromType:Category.self,property:"items")
    
}
