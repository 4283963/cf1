<template>
  <div>
    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span style="font-size: 16px; font-weight: bold">🐱 活体宠物管理</span>
          <el-select
            v-model="selectedStoreId"
            placeholder="按分店筛选"
            clearable
            style="width: 200px"
            @change="loadPets"
          >
            <el-option v-for="s in stores" :key="s.id" :label="s.name" :value="s.id" />
          </el-select>
        </div>
      </template>

      <el-table :data="pets" stripe border>
        <el-table-column prop="name" label="宠物名" width="100" />
        <el-table-column prop="species" label="物种" width="80" align="center">
          <template #default="{ row }">
            <el-tag size="small">{{ row.species === '猫' ? '🐱 猫' : '🐶 狗' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="breed" label="品种" width="130" />
        <el-table-column prop="gender" label="性别" width="80" align="center" />
        <el-table-column prop="birthDate" label="出生日期" width="120" />
        <el-table-column prop="healthStatus" label="健康状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.healthStatus === '健康' ? 'success' : 'danger'" size="small">
              {{ row.healthStatus }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="transportStatus" label="运输状态" width="110" align="center">
          <template #default="{ row }">
            <el-tag :type="transportTagType(row.transportStatus)" size="small">
              {{ transportLabel(row.transportStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastVaccineDate" label="最近接种" width="120" />
        <el-table-column label="操作" width="120" fixed="right" align="center">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="viewPet(row)">健康档案</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="detailVisible" title="🐾 宠物健康档案" width="600px">
      <div v-if="selectedPet">
        <el-descriptions :column="2" border size="small" style="margin-bottom: 16px">
          <el-descriptions-item label="宠物名">{{ selectedPet.name }}</el-descriptions-item>
          <el-descriptions-item label="物种/品种">{{ selectedPet.species }} / {{ selectedPet.breed }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ selectedPet.gender || '未知' }}</el-descriptions-item>
          <el-descriptions-item label="出生日期">{{ selectedPet.birthDate || '未知' }}</el-descriptions-item>
          <el-descriptions-item label="健康状态">
            <el-tag :type="selectedPet.healthStatus === '健康' ? 'success' : 'danger'" size="small">
              {{ selectedPet.healthStatus }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="运输状态">
            <el-tag :type="transportTagType(selectedPet.transportStatus)" size="small">
              {{ transportLabel(selectedPet.transportStatus) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="最近接种">{{ selectedPet.lastVaccineDate || '未接种' }}</el-descriptions-item>
          <el-descriptions-item label="所在分店">{{ getStoreName(selectedPet.storeId) }}</el-descriptions-item>
        </el-descriptions>

        <el-divider content-position="left">📋 健康打卡记录</el-divider>

        <el-timeline v-if="healthLogs.length > 0">
          <el-timeline-item
            v-for="log in healthLogs"
            :key="log.id"
            :timestamp="formatDateTime(log.checkTime)"
            :type="log.mentalStatus === 'GOOD' ? 'success' : log.mentalStatus === 'POOR' ? 'danger' : 'warning'"
          >
            <div style="font-size: 13px">
              <div style="margin-bottom: 4px">
                <span style="font-weight: bold">📍 {{ log.location }}</span>
                <span style="float: right; color: #666">👤 {{ log.checker }}</span>
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
          </el-timeline-item>
        </el-timeline>

        <el-empty v-else description="暂无健康打卡记录" :image-size="80" />

        <el-divider content-position="left" v-if="selectedPet.vaccineRecords">💉 疫苗接种记录</el-divider>
        <div v-if="selectedPet.vaccineRecords" style="background: #f5f7fa; padding: 12px; border-radius: 4px">
          <div v-for="(v, idx) in vaccineList" :key="idx" style="font-size: 13px; margin-bottom: 6px">
            {{ v.date }} - {{ v.name }}
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getStores, getPets, getPetDetail, getHealthChecksByPet } from '../api/transfer'

const stores = ref([])
const pets = ref([])
const selectedStoreId = ref(null)
const detailVisible = ref(false)
const selectedPet = ref(null)
const healthLogs = ref([])

const vaccineList = computed(() => {
  if (!selectedPet.value?.vaccineRecords) return []
  try {
    return JSON.parse(selectedPet.value.vaccineRecords)
  } catch (e) {
    return []
  }
})

onMounted(async () => {
  const res = await getStores()
  stores.value = res.data
  await loadPets()
})

async function loadPets() {
  const res = await getPets(selectedStoreId.value || undefined)
  pets.value = res.data
}

async function viewPet(pet) {
  selectedPet.value = pet
  const [petRes, logsRes] = await Promise.all([
    getPetDetail(pet.id),
    getHealthChecksByPet(pet.id)
  ])
  selectedPet.value = petRes.data
  healthLogs.value = logsRes.data
  detailVisible.value = true
}

function getStoreName(storeId) {
  const s = stores.value.find(x => x.id === storeId)
  return s ? s.name : '-'
}

function transportTagType(status) {
  const map = { IN_STORE: 'info', SHIPPING: 'primary', ARRIVED: 'success' }
  return map[status] || 'info'
}

function transportLabel(status) {
  const map = { IN_STORE: '在店', SHIPPING: '运输中', ARRIVED: '已到达' }
  return map[status] || status
}

function formatDateTime(dt) {
  if (!dt) return '-'
  return dt.replace('T', ' ').substring(0, 16)
}
</script>
