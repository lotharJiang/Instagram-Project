//
//  Item.swift
//  Instagram Project
//
//  Created by LiuYuHan on 14/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class Item {
    let count: Int
    
    init(number: Int) {
        count = number
    }
    
    static func creatItems(count: Int) -> [Item] {
        var items = [Item]()
        
        for index in 0..<count {
            items.append(Item(number: index))
        }
        return items
    }
    
    func imageUrl(urlString:String) -> URL? {
        return URL(string:urlString)
    }
}
