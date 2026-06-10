import request from './request'

export function getStores() {
  return request.get('/stores')
}

export function getInventories(storeId) {
  const params = storeId ? { storeId } : {}
  return request.get('/inventories', { params })
}

export function getTransfers() {
  return request.get('/transfers')
}

export function createTransfer(data) {
  return request.post('/transfers', data)
}

export function approveTransfer(id, approver) {
  return request.put(`/transfers/${id}/approve`, { approver })
}

export function rejectTransfer(id, approver) {
  return request.put(`/transfers/${id}/reject`, { approver })
}
