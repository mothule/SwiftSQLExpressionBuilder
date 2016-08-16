# SwiftSQLExpressionBuilder
This is SQL expressions builder using Swift.

# How to use

~~~swift
let sql = From(table: "food").innerJoin("food_info", lhs: "food.info_id", rhs: "food_info.info_id")
.innerJoin("food_unit", lhs: "food_info.unit_id", rhs: "food_unit.unit_id").where_("food.state = ? And food.state != ?", args: [1,3])
.select("*").toString()
print(sql)
return true__
~~~