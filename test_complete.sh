#!/bin/bash
echo "=============================================="
echo "  宠物调拨系统 - 并发防抖完整验证"
echo "=============================================="
echo ""

# ========== 验证1：并发提交（模拟连续点击3次） ==========
echo "【验证1】并发提交：模拟分店长连续点击3次提交"
echo "--------------------------------------------------"

BEFORE_COUNT=$(mysql -u root -N -e "USE pet_transfer; SELECT COUNT(*) FROM transfer_request WHERE item_name='皇家猫粮K36' AND to_store_id=4;")
echo "测试前: 总仓→武侯分店的猫粮调拨记录数 = $BEFORE_COUNT"

PAYLOAD='{"fromStoreId":1,"toStoreId":4,"itemType":"SUPPLY","itemName":"皇家猫粮K36","quantity":10,"applicant":"赵店长","remark":"武侯分店补货"}'

echo ""
echo "正在并行发送 3 个完全相同的请求..."
curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/c1.json &
curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/c2.json &
curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/c3.json &
wait

echo ""
echo "3个请求的响应结果："
for i in 1 2 3; do
  CODE=$(python3 -c "import json; d=json.load(open('/tmp/c$i.json')); print(d['code'])" 2>/dev/null)
  MSG=$(python3 -c "import json; d=json.load(open('/tmp/c$i.json')); print(d['message'])" 2>/dev/null)
  echo "  请求$i: code=$CODE, msg=$MSG"
done

SUCCESS=0
BAD_REQ=0
INT_ERR=0
for i in 1 2 3; do
  CODE=$(python3 -c "import json; d=json.load(open('/tmp/c$i.json')); print(d['code'])" 2>/dev/null)
  [ "$CODE" = "200" ] && SUCCESS=$((SUCCESS+1))
  [ "$CODE" = "400" ] && BAD_REQ=$((BAD_REQ+1))
  [ "$CODE" = "500" ] && INT_ERR=$((INT_ERR+1))
done

echo ""
echo "统计: 成功(200)=$SUCCESS 次, 业务拦截(400)=$BAD_REQ 次, 服务器错误(500)=$INT_ERR 次"

sleep 1
AFTER_COUNT=$(mysql -u root -N -e "USE pet_transfer; SELECT COUNT(*) FROM transfer_request WHERE item_name='皇家猫粮K36' AND to_store_id=4;")
echo "测试后: 总仓→武侯分店的猫粮调拨记录数 = $AFTER_COUNT"
NEW_COUNT=$((AFTER_COUNT - BEFORE_COUNT))

echo ""
if [ "$NEW_COUNT" -eq 1 ] && [ "$SUCCESS" -eq 1 ] && [ "$INT_ERR" -eq 0 ]; then
  echo "✅ 验证1通过：3次点击只有1次成功，数据库只新增1条记录，无500错误"
else
  echo "❌ 验证1失败：新增$NEW_COUNT条记录，成功$SUCCESS次，500错误$INT_ERR次"
fi

echo ""
echo "=================================================="

# ========== 验证2：并发审批（防止重复扣减库存） ==========
echo ""
echo "【验证2】并发审批：防止连续点击审批按钮重复扣库存"
echo "--------------------------------------------------"

REQ_ID=$(mysql -u root -N -e "USE pet_transfer; SELECT id FROM transfer_request WHERE item_name='皇家猫粮K36' AND to_store_id=4 AND status='PENDING' ORDER BY id DESC LIMIT 1;")
REQ_NO=$(mysql -u root -N -e "USE pet_transfer; SELECT request_no FROM transfer_request WHERE id=$REQ_ID;")
echo "待审批申请ID=$REQ_ID, 单号=$REQ_NO"

BEFORE_STOCK=$(mysql -u root -N -e "USE pet_transfer; SELECT quantity FROM inventory WHERE store_id=1 AND item_name='皇家猫粮K36';")
echo "审批前: 总仓库皇家猫粮K36库存 = $BEFORE_STOCK 袋"

echo ""
echo "正在并行发送 3 个审批请求..."
curl -s -X PUT "http://localhost:8080/api/transfers/$REQ_ID/approve" -H 'Content-Type: application/json' -d '{"approver":"李总"}' > /tmp/d1.json &
curl -s -X PUT "http://localhost:8080/api/transfers/$REQ_ID/approve" -H 'Content-Type: application/json' -d '{"approver":"李总"}' > /tmp/d2.json &
curl -s -X PUT "http://localhost:8080/api/transfers/$REQ_ID/approve" -H 'Content-Type: application/json' -d '{"approver":"李总"}' > /tmp/d3.json &
wait

echo ""
echo "3个审批请求的响应结果："
for i in 1 2 3; do
  CODE=$(python3 -c "import json; d=json.load(open('/tmp/d$i.json')); print(d['code'])" 2>/dev/null)
  MSG=$(python3 -c "import json; d=json.load(open('/tmp/d$i.json')); print(d['message'])" 2>/dev/null)
  echo "  请求$i: code=$CODE, msg=$MSG"
done

APR_SUCCESS=0
APR_FAIL=0
APR_ERR=0
for i in 1 2 3; do
  CODE=$(python3 -c "import json; d=json.load(open('/tmp/d$i.json')); print(d['code'])" 2>/dev/null)
  [ "$CODE" = "200" ] && APR_SUCCESS=$((APR_SUCCESS+1))
  [ "$CODE" = "400" ] && APR_FAIL=$((APR_FAIL+1))
  [ "$CODE" = "500" ] && APR_ERR=$((APR_ERR+1))
done

echo ""
echo "统计: 审批通过(200)=$APR_SUCCESS 次, 状态拦截(400)=$APR_FAIL 次, 服务器错误(500)=$APR_ERR 次"

AFTER_STOCK=$(mysql -u root -N -e "USE pet_transfer; SELECT quantity FROM inventory WHERE store_id=1 AND item_name='皇家猫粮K36';")
echo "审批后: 总仓库皇家猫粮K36库存 = $AFTER_STOCK 袋"
DEDUCTED=$((BEFORE_STOCK - AFTER_STOCK))

echo ""
if [ "$DEDUCTED" -eq 10 ] && [ "$APR_SUCCESS" -eq 1 ] && [ "$APR_ERR" -eq 0 ]; then
  echo "✅ 验证2通过：库存只扣减了1次（10袋），从$BEFORE_STOCK → $AFTER_STOCK"
else
  echo "❌ 验证2失败：扣减了$DEDUCTED袋（预期10袋），成功$APR_SUCCESS次，500错误$APR_ERR次"
fi

echo ""
echo "=============================================="
echo "  验证完成"
echo "=============================================="
