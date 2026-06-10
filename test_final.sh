#!/bin/bash
echo "=== 验证1：并发提交的错误码应该是 400，不是 500 ==="

PAYLOAD='{"fromStoreId":1,"toStoreId":4,"itemType":"SUPPLY","itemName":"驱虫药","quantity":10,"applicant":"李店长"}'

curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/a1.json &
PID1=$!
curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/a2.json &
PID2=$!
curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/a3.json &
PID3=$!
wait $PID1 $PID2 $PID3

echo "请求1: $(cat /tmp/a1.json | python3 -m json.tool 2>/dev/null || cat /tmp/a1.json)"
echo "请求2: $(cat /tmp/a2.json | python3 -m json.tool 2>/dev/null || cat /tmp/a2.json)"
echo "请求3: $(cat /tmp/a3.json | python3 -m json.tool 2>/dev/null || cat /tmp/a3.json)"

SUCCESS=$(grep -l '"code":200' /tmp/a1.json /tmp/a2.json /tmp/a3.json | wc -l | tr -d ' ')
BAD_REQ=$(grep -l '"code":400' /tmp/a1.json /tmp/a2.json /tmp/a3.json | wc -l | tr -d ' ')
INT_ERR=$(grep -l '"code":500' /tmp/a1.json /tmp/a2.json /tmp/a3.json | wc -l | tr -d ' ')

echo ""
echo "成功(200): $SUCCESS 个，业务错误(400): $BAD_REQ 个，服务器错误(500): $INT_ERR 个"
if [ "$INT_ERR" -eq 0 ]; then
    echo "✅ 没有 500 错误，错误码正确"
else
    echo "❌ 仍有 $INT_ERR 个 500 错误"
fi

echo ""
echo "=== 验证2：数据库新增记录数 ==="
COUNT=$(mysql -u root -N -e "USE pet_transfer; SELECT COUNT(*) FROM transfer_request WHERE item_name='驱虫药' AND to_store_id=4;")
echo "驱虫药→武侯分店记录数: $COUNT"
if [ "$COUNT" -eq 1 ]; then
    echo "✅ 数据库只新增了 1 条记录"
else
    echo "❌ 数据库新增了 $COUNT 条记录"
fi

echo ""
echo "=== 验证3：审批接口并发（防止重复扣减库存） ==="
REQ_ID=$(mysql -u root -N -e "USE pet_transfer; SELECT id FROM transfer_request WHERE item_name='驱虫药' AND to_store_id=4 LIMIT 1;")
echo "待审批申请ID: $REQ_ID"

BEFORE_QTY=$(mysql -u root -N -e "USE pet_transfer; SELECT quantity FROM inventory WHERE store_id=1 AND item_name='驱虫药';")
echo "审批前总仓库驱虫药库存: $BEFORE_QTY"

curl -s -X PUT "http://localhost:8080/api/transfers/$REQ_ID/approve" -H 'Content-Type: application/json' -d '{"approver":"张总"}' > /tmp/b1.json &
PID4=$!
curl -s -X PUT "http://localhost:8080/api/transfers/$REQ_ID/approve" -H 'Content-Type: application/json' -d '{"approver":"张总"}' > /tmp/b2.json &
PID5=$!
curl -s -X PUT "http://localhost:8080/api/transfers/$REQ_ID/approve" -H 'Content-Type: application/json' -d '{"approver":"张总"}' > /tmp/b3.json &
PID6=$!
wait $PID4 $PID5 $PID6

echo "审批请求1: $(cat /tmp/b1.json | python3 -c "import sys,json; d=json.load(sys.stdin); print('code:',d['code'],',msg:',d['message'])" 2>/dev/null)"
echo "审批请求2: $(cat /tmp/b2.json | python3 -c "import sys,json; d=json.load(sys.stdin); print('code:',d['code'],',msg:',d['message'])" 2>/dev/null)"
echo "审批请求3: $(cat /tmp/b3.json | python3 -c "import sys,json; d=json.load(sys.stdin); print('code:',d['code'],',msg:',d['message'])" 2>/dev/null)"

AFTER_QTY=$(mysql -u root -N -e "USE pet_transfer; SELECT quantity FROM inventory WHERE store_id=1 AND item_name='驱虫药';")
echo "审批后总仓库驱虫药库存: $AFTER_QTY"

EXPECTED_QTY=$((BEFORE_QTY - 10))
if [ "$AFTER_QTY" -eq "$EXPECTED_QTY" ]; then
    echo "✅ 库存只扣减了 1 次（100 → $AFTER_QTY），没有重复扣减！"
else
    echo "❌ 库存扣减异常：预期 $EXPECTED_QTY，实际 $AFTER_QTY"
fi
