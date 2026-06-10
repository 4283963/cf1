<template>
  <div>
    <el-card shadow="never">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span style="font-size: 16px; font-weight: bold">📦 各分店库存列表</span>
          <el-select
            v-model="selectedStoreId"
            placeholder="按分店筛选"
            clearable
            style="width: 220px"
            @change="loadInventories"
          >
            <el-option
              v-for="s in stores"
              :key="s.id"
              :label="s.name"
              :value="s.id"
            />
          </el-select>
        </div>
      </template>

      <el-table :data="inventories" stripe border style="width: 100%">
        <el-table-column prop="storeName" label="所属分店" width="160" />
        <el-table-column prop="itemType" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.itemType === 'LIVE' ? 'danger' : 'info'" size="small">
              {{ row.itemType === 'LIVE' ? '活体' : '用品' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="itemName" label="品名" width="160" />
        <el-table-column prop="breed" label="品种" width="140">
          <template #default="{ row }">
            {{ row.breed || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="quantity" label="数量" width="100" align="center" />
        <el-table-column prop="unit" label="单位" width="80" align="center" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getStores, getInventories } from '../api/transfer'

const stores = ref([])
const inventories = ref([])
const selectedStoreId = ref(null)

onMounted(async () => {
  const res = await getStores()
  stores.value = res.data
  await loadInventories()
})

async function loadInventories() {
  const res = await getInventories(selectedStoreId.value || undefined)
  inventories.value = res.data
}
</script>
