<template>
  <div class="driver-page" style="max-width: 500px; margin: 0 auto; padding: 12px">
    <div style="text-align: center; margin-bottom: 16px">
      <h2 style="margin: 0 0 8px; font-size: 18px">🚚 运输途中健康打卡</h2>
      <p style="margin: 0; color: #666; font-size: 13px">每到一个服务区，请为宠物记录一次健康状态</p>
    </div>

    <el-card v-if="transfer" shadow="never" style="margin-bottom: 16px">
      <div style="display: flex; justify-content: space-between; margin-bottom: 8px">
        <span style="font-weight: bold">{{ transfer.requestNo }}</span>
        <el-tag type="primary" size="small">运输中</el-tag>
      </div>
      <div style="font-size: 13px; color: #666; line-height: 1.8">
        <div>📤 {{ transfer.fromStoreName }} → 📥 {{ transfer.toStoreName }}</div>
        <div>🐾 {{ transfer.itemName }} ({{ transfer.breed }}) × {{ transfer.quantity }}只</div>
        <div>👤 司机: {{ transfer.driver }}</div>
        <div v-if="transfer.estimatedArrival">⏱️ 预计到达: {{ formatDateTime(transfer.estimatedArrival) }}</div>
      </div>
    </el-card>

    <el-card shadow="never" style="margin-bottom: 16px">
      <template #header>
        <span style="font-weight: bold; font-size: 14px">📝 本次打卡</span>
      </template>

      <el-form :model="checkForm" label-width="70px" size="default">
        <el-form-item label="打卡地点" prop="location">
          <el-input v-model="checkForm.location" placeholder="如：绵阳服务区" maxlength="50" />
        </el-form-item>

        <el-form-item label="打卡人">
          <el-input v-model="checkForm.checker" placeholder="请输入司机姓名" maxlength="20" />
        </el-form-item>

        <el-form-item label="打卡范围">
          <el-radio-group v-model="checkForm.checkScope">
            <el-radio label="ALL">整批打卡</el-radio>
            <el-radio label="SINGLE">单只打卡</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item v-if="checkForm.checkScope === 'SINGLE'" label="选择宠物">
          <el-select v-model="checkForm.livePetId" placeholder="选择宠物" style="width: 100%">
            <el-option
              v-for="p in pets"
              :key="p.id"
              :label="`${p.name} (${p.gender || '未知'})`"
              :value="p.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="体温">
          <el-input-number v-model="checkForm.temperature" :min="35" :max="43" :step="0.1" :precision="1" placeholder="38.5" />
          <span style="color: #999; font-size: 12px; margin-left: 8px">℃ (正常38-39.5)</span>
        </el-form-item>

        <el-form-item label="精神状态">
          <el-radio-group v-model="checkForm.mentalStatus">
            <el-radio label="GOOD" border>好 😊</el-radio>
            <el-radio label="NORMAL" border>一般 😐</el-radio>
            <el-radio label="POOR" border>差 😟</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="备注">
          <el-input v-model="checkForm.remark" type="textarea" :rows="2" placeholder="可选，如：有轻微流鼻水..." maxlength="200" />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            style="width: 100%; height: 44px; font-size: 16px"
            @click="submitCheck"
            :loading="submitting"
            :disabled="submitting"
          >
            ✅ 提交打卡
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span style="font-weight: bold; font-size: 14px">📋 历史打卡记录 ({{ checkLogs.length }}次)</span>
          <el-button type="primary" size="small" link @click="loadLogs">刷新</el-button>
        </div>
      </template>

      <el-timeline v-if="checkLogs.length > 0">
        <el-timeline-item
          v-for="(log, idx) in checkLogs"
          :key="log.id"
          :timestamp="formatDateTime(log.checkTime)"
          :type="log.mentalStatus === 'GOOD' ? 'success' : log.mentalStatus === 'POOR' ? 'danger' : 'warning'"
          :hollow="idx % 2 === 1"
        >
          <el-card shadow="never" style="background: #f5f7fa; padding: 8px; margin: 0">
            <div style="font-size: 13px">
              <div style="margin-bottom: 4px">
                <span style="font-weight: bold">📍 {{ log.location }}</span>
                <span style="float: right">👤 {{ log.checker }}</span>
              </div>
              <div v-if="log.petName" style="color: #666; margin-bottom: 4px">
                🐾 {{ log.petName }} ({{ log.petBreed }})
              </div>
              <div style="color: #666">
                <span v-if="log.temperature">🌡️ {{ log.temperature }}℃ </span>
                <span :style="{ color: log.mentalStatus === 'GOOD' ? '#67c23a' : log.mentalStatus === 'POOR' ? '#f56c6c' : '#e6a23c' }">
                  {{ log.mentalStatusLabel }}
                </span>
              </div>
              <div v-if="log.remark" style="color: #999; margin-top: 4px; font-size: 12px">
                💬 {{ log.remark }}
              </div>
            </div>
          </el-card>
        </el-timeline-item>
      </el-timeline>

      <el-empty v-else description="暂无打卡记录，请完成第一次打卡" :image-size="80" />
    </el-card>

    <div style="text-align: center; margin-top: 20px; color: #999; font-size: 12px">
      <el-button type="info" size="small" @click="goBack">← 返回调拨管理</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getShippingTransfers, getTransferPets, addHealthCheck, getHealthChecksByTransfer } from '../api/transfer'

const route = useRoute()
const router = useRouter()

const transfer = ref(null)
const pets = ref([])
const checkLogs = ref([])
const submitting = ref(false)

const checkForm = ref({
  location: '',
  checker: '',
  checkScope: 'ALL',
  livePetId: null,
  temperature: 38.5,
  mentalStatus: 'GOOD',
  remark: ''
})

onMounted(async () => {
  const transferId = route.query.transferId
  if (transferId) {
    await loadTransferDetail(parseInt(transferId))
  } else {
    await loadShippingList()
  }
})

async function loadShippingList() {
  const res = await getShippingTransfers()
  if (res.data && res.data.length > 0) {
    await loadTransferDetail(res.data[0].id)
  }
}

async function loadTransferDetail(id) {
  const [transfersRes, petsRes] = await Promise.all([
    getShippingTransfers(),
    getTransferPets(id)
  ])
  transfer.value = transfersRes.data.find(t => t.id === id) || null
  pets.value = petsRes.data
  await loadLogs()
}

async function loadLogs() {
  if (!transfer.value) return
  const res = await getHealthChecksByTransfer(transfer.value.id)
  checkLogs.value = res.data
}

async function submitCheck() {
  if (submitting.value) return
  if (!checkForm.value.location.trim()) {
    ElMessage.warning('请输入打卡地点')
    return
  }
  if (!checkForm.value.checker.trim()) {
    ElMessage.warning('请输入打卡人姓名')
    return
  }

  submitting.value = true
  try {
    const payload = {
      transferId: transfer.value.id,
      location: checkForm.value.location.trim(),
      checker: checkForm.value.checker.trim(),
      temperature: checkForm.value.temperature,
      mentalStatus: checkForm.value.mentalStatus,
      remark: checkForm.value.remark || ''
    }
    if (checkForm.value.checkScope === 'SINGLE' && checkForm.value.livePetId) {
      payload.livePetId = checkForm.value.livePetId
    }
    await addHealthCheck(payload)
    ElMessage.success('✅ 打卡成功！已记录健康状态')
    checkForm.value.location = ''
    checkForm.value.remark = ''
    checkForm.value.livePetId = null
    await loadLogs()
  } catch (e) {
    ElMessage.error(e.message || '打卡失败')
  } finally {
    submitting.value = false
  }
}

function formatDateTime(dt) {
  if (!dt) return '-'
  return dt.replace('T', ' ').substring(0, 16)
}

function goBack() {
  router.push('/transfer')
}
</script>

<style scoped>
.driver-page {
  min-height: 100vh;
  background: #f0f2f5;
}
</style>
