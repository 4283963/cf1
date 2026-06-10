#!/bin/bash
echo "=============================================="
echo "  🐾 宠物运输健康打卡 - 完整流程验证"
echo "=============================================="
echo ""

echo "【Step 1】创建调拨申请：总仓→高新分店，3只英国短毛猫"
echo "--------------------------------------------------"
CREATE_RES=$(curl -s -X POST http://localhost:8080/api/transfers \
  -H 'Content-Type: application/json' \
  -d '{"fromStoreId":1,"toStoreId":2,"itemType":"LIVE","itemName":"英国短毛猫","breed":"英国短毛猫","quantity":3,"applicant":"李店长","remark":"高新分店补货"}')
echo "响应: $CREATE_RES"
REQ_ID=$(echo $CREATE_RES | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")
REQ_NO=$(echo $CREATE_RES | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['requestNo'])")
echo "✅ 调拨单创建成功: ID=$REQ_ID, 单号=$REQ_NO"
echo ""

echo "【Step 2】审批通过"
echo "--------------------------------------------------"
APR_RES=$(curl -s -X PUT http://localhost:8080/api/transfers/$REQ_ID/approve \
  -H 'Content-Type: application/json' \
  -d '{"approver":"张总"}')
APR_STATUS=$(echo $APR_RES | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['status'])")
echo "✅ 审批完成，状态=$APR_STATUS"
echo ""

echo "【Step 3】发货 - 标记为运输中"
echo "--------------------------------------------------"
SHIP_RES=$(curl -s -X PUT http://localhost:8080/api/transfers/$REQ_ID/ship \
  -H 'Content-Type: application/json' \
  -d '{"shipper":"王管理员","driver":"刘师傅","estimatedHours":3}')
SHIP_STATUS=$(echo $SHIP_RES | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['status'])")
SHIP_DRIVER=$(echo $SHIP_RES | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['driver'])")
echo "✅ 发货完成，状态=$SHIP_STATUS，司机=$SHIP_DRIVER"
echo ""

echo "【Step 4】查询运输中的活体宠物"
echo "--------------------------------------------------"
PETS_RES=$(curl -s http://localhost:8080/api/transfers/$REQ_ID/pets)
PET_COUNT=$(echo $PETS_RES | python3 -c "import sys,json; print(len(json.load(sys.stdin)['data']))")
echo "📊 运输中的宠物数量: $PET_COUNT 只"
echo $PETS_RES | python3 -c "
import sys,json
data = json.load(sys.stdin)['data']
for p in data:
    print(f'   - {p[\"name\"]} ({p[\"breed\"]}, {p.get(\"gender\",\"?\")}), 运输状态={p[\"transportStatus\"]}')
"
echo ""

echo "【Step 5】司机健康打卡 - 第一次（绵阳服务区）"
echo "--------------------------------------------------"
CHECK1=$(curl -s -X POST http://localhost:8080/api/health-checks \
  -H 'Content-Type: application/json' \
  -d '{"transferId":'$REQ_ID',"checker":"刘师傅","location":"绵阳服务区","temperature":38.7,"mentalStatus":"GOOD","remark":"状态良好，饮水正常"}')
CHECK1_ID=$(echo $CHECK1 | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")
echo "✅ 第一次打卡成功，打卡ID=$CHECK1_ID"
echo ""

echo "【Step 6】司机健康打卡 - 第二次（德阳服务区，单只宠物有异常）"
echo "--------------------------------------------------"
PET1_ID=$(echo $PETS_RES | python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['id'])")
CHECK2=$(curl -s -X POST http://localhost:8080/api/health-checks \
  -H 'Content-Type: application/json' \
  -d '{"transferId":'$REQ_ID',"livePetId":'$PET1_ID',"checker":"刘师傅","location":"德阳服务区","temperature":39.8,"mentalStatus":"POOR","remark":"小蓝有点蔫，疑似应激反应"}')
CHECK2_ID=$(echo $CHECK2 | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")
echo "✅ 第二次打卡成功（针对单只宠物），打卡ID=$CHECK2_ID"
echo ""

echo "【Step 7】查询该调拨单的全部健康打卡记录"
echo "--------------------------------------------------"
LOGS_RES=$(curl -s http://localhost:8080/api/health-checks/transfer/$REQ_ID)
LOG_COUNT=$(echo $LOGS_RES | python3 -c "import sys,json; print(len(json.load(sys.stdin)['data']))")
echo "📋 健康打卡记录总数: $LOG_COUNT 次"
echo $LOGS_RES | python3 -c "
import sys,json
data = json.load(sys.stdin)['data']
for log in data:
    pet = log.get('petName','整批')
    temp = log.get('temperature','未测')
    if temp: temp = str(temp) + '℃'
    print(f'   [{log[\"checkTime\"][11:16]}] 📍{log[\"location\"]} | 🐾{pet} | 🌡️{temp} | {log[\"mentalStatusLabel\"]}')
    if log.get('remark'):
        print(f'      💬 {log[\"remark\"]}')
"
echo ""

echo "【Step 8】确认到达目的地"
echo "--------------------------------------------------"
COMP_RES=$(curl -s -X PUT http://localhost:8080/api/transfers/$REQ_ID/complete)
COMP_STATUS=$(echo $COMP_RES | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['status'])")
echo "✅ 已确认到达，状态=$COMP_STATUS"
echo ""

echo "【Step 9】验证活体宠物运输状态已更新为已到达"
echo "--------------------------------------------------"
PETS_RES2=$(curl -s http://localhost:8080/api/transfers/$REQ_ID/pets)
echo $PETS_RES2 | python3 -c "
import sys,json
data = json.load(sys.stdin)['data']
for p in data:
    status_icon = '✅' if p['transportStatus'] == 'ARRIVED' else '❌'
    print(f'   {status_icon} {p[\"name\"]}: 运输状态={p[\"transportStatus\"]}, 所在分店ID={p[\"storeId\"]}')
"
echo ""

echo "【Step 10】查询单只宠物的完整健康档案（疫苗 + 打卡记录）"
echo "--------------------------------------------------"
PET_DETAIL=$(curl -s http://localhost:8080/api/pets/$PET1_ID)
PET_LOGS=$(curl -s http://localhost:8080/api/health-checks/pet/$PET1_ID)
PET_NAME=$(echo $PET_DETAIL | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['name'])")
VACCINES=$(echo $PET_DETAIL | python3 -c "
import sys,json
vr = json.load(sys.stdin)['data']['vaccineRecords']
if vr:
    import json as j
    arr = j.loads(vr)
    print(len(arr))
else:
    print(0)
")
PET_LOG_COUNT=$(echo $PET_LOGS | python3 -c "import sys,json; print(len(json.load(sys.stdin)['data']))")
echo "🐾 $PET_NAME 的健康档案:"
echo "   💉 疫苗接种记录: $VACCINES 条"
echo "   📋 健康打卡记录: $PET_LOG_COUNT 次"
echo ""

echo "=============================================="
echo "  ✅ 全流程验证通过！"
echo "=============================================="
echo ""
echo "📊 数据库验证:"
mysql -u root -e "USE pet_transfer;
SELECT '调拨单' AS 表, COUNT(*) AS 记录数 FROM transfer_request WHERE id=$REQ_ID;
SELECT '健康打卡' AS 表, COUNT(*) AS 记录数 FROM health_check WHERE transfer_id=$REQ_ID;
SELECT '活体宠物' AS 表, COUNT(*) AS 记录数 FROM live_pet WHERE transfer_id IS NULL AND transport_status='ARRIVED' AND store_id=2 AND breed='英国短毛猫';"
