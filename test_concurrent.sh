#!/bin/bash
echo "=== 并发测试：模拟连续3次快速点击 ==="
BEFORE=$(mysql -u root -N -e "USE pet_transfer; SELECT COUNT(*) FROM transfer_request WHERE item_name='金毛寻回犬' AND to_store_id=3;")
echo "测试前金毛→锦江分店记录数: $BEFORE"

echo ""
echo "开始并行发送3个完全相同的请求..."

PAYLOAD='{"fromStoreId":1,"toStoreId":3,"itemType":"LIVE","itemName":"金毛寻回犬","breed":"金毛寻回犬","quantity":2,"applicant":"王店长","remark":"测试并发"}'

curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/r1.json &
PID1=$!
curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/r2.json &
PID2=$!
curl -s -X POST http://localhost:8080/api/transfers -H 'Content-Type: application/json' -d "$PAYLOAD" > /tmp/r3.json &
PID3=$!

wait $PID1 $PID2 $PID3

echo ""
echo "=== 3个请求的响应结果 ==="
echo "请求1: $(cat /tmp/r1.json)"
echo "请求2: $(cat /tmp/r2.json)"
echo "请求3: $(cat /tmp/r3.json)"

echo ""
sleep 1
AFTER=$(mysql -u root -N -e "USE pet_transfer; SELECT COUNT(*) FROM transfer_request WHERE item_name='金毛寻回犬' AND to_store_id=3;")
echo "测试后金毛→锦江分店记录数: $AFTER"

echo ""
echo "=== 数据库中的实际记录 ==="
mysql -u root -e "USE pet_transfer; SELECT id, request_no, status, applicant, quantity FROM transfer_request WHERE item_name='金毛寻回犬' ORDER BY id DESC;"

SUCCESS_COUNT=$(grep -c '"code":200' /tmp/r1.json /tmp/r2.json /tmp/r3.json 2>/dev/null || echo "0")
FAIL_COUNT=$(grep -c '"code":' /tmp/r1.json /tmp/r2.json /tmp/r3.json 2>/dev/null || echo "0")
FAIL_COUNT=$((FAIL_COUNT - SUCCESS_COUNT))

echo ""
echo "=== 测试结果汇总 ==="
echo "成功请求数: $SUCCESS_COUNT"
echo "被拦截请求数: $FAIL_COUNT"
echo "数据库新增记录数: $((AFTER - BEFORE))"

if [ "$((AFTER - BEFORE))" -eq 1 ] && [ "$SUCCESS_COUNT" -eq 1 ] && [ "$FAIL_COUNT" -eq 2 ]; then
    echo "✅ 测试通过！3个请求只有1个成功插入，另外2个被幂等拦截"
else
    echo "❌ 测试失败！预期新增1条，实际新增$((AFTER - BEFORE))条"
fi
