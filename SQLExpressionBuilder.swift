//
//  SQLExpressionBuilder.swift
//  FoodCollect
//
//  Created by mothule on 2015/07/17.
//  Copyright (c) 2015年 mothule. All rights reserved.
//

import Foundation


protocol SQLPhrase {
    // 前のフレーズ
    var previous:SQLPhrase?{set get}
    
    // 次のフレーズ
    var next:SQLPhrase?{set get}
    
    // INNER JOIN句
    func innerJoin(table:String, lhs:String, rhs:String) -> SQLPhrase
    
    // WHERE句
    func where_(phrase:String, args:Array<AnyObject> ) -> SQLPhrase
    
    // SELECT句
    func select(phrase:String) -> SQLPhrase
    
    // SQL文字列に変換
    func toString() -> String
}

class Error:SQLPhrase{
        var previous:SQLPhrase? { set{} get{ return Error() }}
        var next:SQLPhrase? { set{} get{ return Error() }}
        func innerJoin(table:String, lhs:String, rhs:String) -> SQLPhrase{ return Error() }
        func where_(phrase:String, args:Array<AnyObject> ) -> SQLPhrase{ return Error() }
        func select(phrase:String) -> SQLPhrase{ return Error() }
        func toString() -> String{
            return "ERROR"
        }
    
}

extension SQLPhrase
{
//    var previous:SQLPhrase? { set{} get{ return Error() }}
//    var next:SQLPhrase? { set{} get{ return Error() }}
//    func innerJoin(table:String, lhs:String, rhs:String) -> SQLPhrase{ return Error() }
//    func where_(phrase:String, args:Array<AnyObject> ) -> SQLPhrase{ return Error() }
//    func select(phrase:String) -> SQLPhrase{ return Error() }
//    func toString() -> String{
//        return "ERROR"
//    }
}

class BaseSQLPhrase : SQLPhrase{
    var previous:SQLPhrase?
    var next:SQLPhrase?

    func innerJoin(table:String, lhs:String, rhs:String) -> SQLPhrase{ return Error() }
    func where_(phrase:String, args:Array<AnyObject> ) -> SQLPhrase{ return Error() }
    func select(phrase:String) -> SQLPhrase{ return Error() }
    func toString() -> String{      return "ERROR"    }
}


// FROM句
class From : BaseSQLPhrase {
    private var table:String
    
    init(table:String){
        self.table = table
    }
    
    override func innerJoin(table:String, lhs:String, rhs:String) -> SQLPhrase {
        self.next = InnerJoin(table: table, lhs: lhs, rhs: rhs)
        self.next!.previous = self
        return self.next as! InnerJoin
    }
    override func toString() -> String{
        return "FROM \(table)"
    }
}

// INNER JOIN句
class InnerJoin : BaseSQLPhrase {
    private var table:String
    private var rhs:String
    private var lhs:String
    
    init(table:String, lhs:String, rhs:String){
        self.table = table
        self.lhs = lhs
        self.rhs = rhs
    }
    
    override func innerJoin(table:String, lhs:String, rhs:String) -> SQLPhrase{
        self.next = InnerJoin(table: table, lhs: lhs, rhs: rhs)
        self.next!.previous = self
        return self.next as! InnerJoin
    }
    
    override func where_(phrase:String, args:Array<AnyObject> ) -> SQLPhrase{
        next = Where(phrase: phrase, args: args)
        next!.previous = self
        return self.next!
    }
    
    override func toString() -> String{
        return " INNER JOIN \(table) ON \(lhs) = \(rhs)"
    }
}

// WHERE句
class Where : BaseSQLPhrase {
    
    private var phrase:String
    private var args:Array<AnyObject>
    
    init(phrase:String, args:Array<AnyObject>){
        self.phrase = phrase
        self.args = args
    }
    
    override func select(phrase:String) -> SQLPhrase{
        next = Select(phrase: phrase)
        next!.previous = self
        return self.next!
    }
    
    override func toString() -> String{
        var i = 0
        var str = ""
        " WHERE \(phrase)".characters.forEach{
            if $0 == "?" {
                str += "\(self.args[i])"
                i += 1
            }else{
                str.append($0)
            }
        }
        return str
    }
}

// SELECT句
class Select : BaseSQLPhrase {

    private var phrase:String
    
    init(phrase:String){
        self.phrase = phrase
    }

    override  func toString() -> String{
        
        var cur = self.previous
        repeat{
            if cur!.previous != nil {
                cur = cur!.previous
            }
        }while cur!.previous != nil;
        
        
        var sql = ""
        while cur != nil {
            if let _ = cur as? Select {
                sql = "SELECT \(self.phrase) " + sql
            }else{
                sql += cur!.toString()
            }
            cur = cur!.next
        }
        
        return sql
    }
}