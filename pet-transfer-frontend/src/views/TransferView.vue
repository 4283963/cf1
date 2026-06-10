<template>
  <div>
    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header>
        <span style="font-size: 16px; font-weight: bold">🔄 发起调拨申请</span>
      </template>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        style="max-width: 600px"
      >
        <el-form-item label="调出方" prop="fromStoreId">
          <el-select v-model="form.fromStoreId" placeholder="选择调出分店" style="width: 100%" @change="onFromStoreChange">
            <el-option v-for="s in stores" :key="s.id" :label="s.name" :value="s.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="调入方" prop="toStoreId">
          <el-select v-model="form.toStoreId" placeholder="选择调入分店" style="width: 100%">
            <el-option v-for="s in targetStores" :key="s.id" :label="s.name" :value="s.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="物品类型" prop="itemType">
          <el-radio-group v-model="form.itemType">
            <el-radio label="LIVE">🐾 活体</el-radio>
            <el-radio label="SUPPLY">📦 用品</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="品名" prop="itemName">
          <el-select
            v-model="form.itemName"
            placeholder="选择品名"
            filterable
            allow-create
            style="width: 100%"
          >
            <el-option
              v-for="item in fromStoreItems"
              :key="item.itemName"
              :label="item.itemName + (item.breed ? '(' + item.breed + ')' : '') + ' [库存:' + item.quantity + item.unit + ']'"
              :value="item.itemName"
            />
          </el-select>
        </el-form-item>

        <el-form-item v-if="form.itemType === 'LIVE'" label="品种" prop="breed">
          <el-select v-model="form.breed" placeholder="选择品种" filterable allow-create style="width: 100%">
            <el-option
              v-for="item in fromStoreItems.filter(i => i.itemName === form.itemName)"
              :key="item.breed"
              :label="item.breed"
              :value="item.breed"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="数量" prop="quantity">
          <el-input-number v-model="form.quantity" :min="1" :max="999" />
        </el-form-item>

        <el-form-item label="申请人" prop="applicant">
          <el-input v-model="form.applicant" placeholder="请输入申请人姓名" />
        </el-form-item>

        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="可选" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitForm" :loading="submitting" :disabled="submitting">提交申请</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span style="font-size: 16px; font-weight: bold">📋 调拨申请记录</span>
          <el-button type="success" size="small" @click="loadTransfers">刷新</el-button>
        </div>
      </template>

      <el-table :data="transfers" stripe border style="width: 100%">
        <el-table-column prop="requestNo" label="调拨单号" width="210" />
        <el-table-column prop="fromStoreName" label="调出方" width="120" />
        <el-table-column prop="toStoreName" label="调入方" width="120" />
        <el-table-column prop="itemType" label="类型" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.itemType === 'LIVE' ? 'danger' : 'info'" size="small">
              {{ row.itemType === 'LIVE' ? '活体' : '用品' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="itemName" label="品名" width="130" />
        <el-table-column prop="breed" label="品种" width="120">
          <template #default="{ row }">
            {{ row.breed || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="quantity" label="数量" width="70" align="center" />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="applicant" label="申请人" width="90" />
        <el-table-column prop="approver" label="审批人" width="90">
          <template #default="{ row }">
            {{ row.approver || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="申请时间" width="170" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <template v-if="row.status === 'PENDING'">
              <el-button type="success" size="small" @click="handleApprove(row)">通过</el-button>
              <el-button type="danger" size="small" @click="handleReject(row)">驳回</el-button>
            </template>
            <span v-else style="color: #999; font-size: 13px">已处理</span>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getStores, getInventories, getTransfers, createTransfer, approveTransfer, rejectTransfer } from '../api/transfer'

const stores = ref([])
const transfers = ref([])
const fromStoreItems = ref([])
const submitting = ref(false)
const formRef = ref(null)

const form = ref({
  fromStoreId: null,
  toStoreId: null,
  itemType: 'LIVE',
  itemName: '',
  breed: '',
  quantity: 1,
  applicant: '',
  remark: ''
})

const rules = {
  fromStoreId: [{ required: true, message: '请选择调出方', trigger: 'change' }],
  toStoreId: [{ required: true, message: '请选择调入方', trigger: 'change' }],
  itemType: [{ required: true, message: '请选择物品类型', trigger: 'change' }],
  itemName: [{ required: true, message: '请选择品名', trigger: 'change' }],
  quantity: [{ required: true, message: '请输入数量', trigger: 'blur' }],
  applicant: [{ required: true, message: '请输入申请人', trigger: 'blur' }]
}

const targetStores = computed(() => {
  return stores.value.filter(s => s.id !== form.value.fromStoreId)
})

onMounted(async () => {
  const res = await getStores()
  stores.value = res.data
  await loadTransfers()
})

async function onFromStoreChange(storeId) {
  form.value.toStoreId = null
  form.value.itemName = ''
  form.value.breed = ''
  if (storeId) {
    const res = await getInventories(storeId)
    fromStoreItems.value = res.data
  } else {
    fromStoreItems.value = []
  }
}

async function loadTransfers() {
  const res = await getTransfers()
  transfers.value = res.data
}

async function submitForm() {
  if (submitting.value) return
  submitting.value = true

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) {
    submitting.value = false
    return
  }

  try {
    const payload = { ...form.value }
    if (payload.itemType !== 'LIVE') {
      delete payload.breed
    }
    await createTransfer(payload)
    ElMessage.success('调拨申请提交成功！')
    resetForm()
    await loadTransfers()
  } catch (e) {
    ElMessage.error(e.message || '提交失败')
  } finally {
    submitting.value = false
  }
}

function resetForm() {
  formRef.value?.resetFields()
  fromStoreItems.value = []
}

async function handleApprove(row) {
  try {
    await ElMessageBox.confirm(
      `确认通过调拨申请 ${row.requestNo}？审批后库存将自动调整。`,
      '审批确认',
      { type: 'warning', confirmButtonText: '确认通过', cancelButtonText: '取消' }
    )
    await approveTransfer(row.id, '管理员')
    ElMessage.success('审批通过，库存已调整')
    await loadTransfers()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error(e.message || '审批失败')
    }
  }
}

async function handleReject(row) {
  try {
    await ElMessageBox.confirm(
      `确认驳回调拨申请 ${row.requestNo}？`,
      '驳回确认',
      { type: 'error', confirmButtonText: '确认驳回', cancelButtonText: '取消' }
    )
    await rejectTransfer(row.id, '管理员')
    ElMessage.success('已驳回')
    await loadTransfers()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error(e.message || '操作失败')
    }
  }
}

function statusTagType(status) {
  const map = { PENDING: 'warning', APPROVED: 'success', REJECTED: 'danger', COMPLETED: 'info' }
  return map[status] || 'info'
}

function statusLabel(status) {
  const map = { PENDING: '待审批', APPROVED: '已通过', REJECTED: '已驳回', COMPLETED: '已完成' }
  return map[status] || status
}
</script>
