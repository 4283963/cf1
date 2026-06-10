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

export function getShippingTransfers() {
  return request.get('/transfers/shipping')
}

export function getTransferPets(transferId) {
  return request.get(`/transfers/${transferId}/pets`)
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

export function shipTransfer(id, data) {
  return request.put(`/transfers/${id}/ship`, data)
}

export function completeTransfer(id) {
  return request.put(`/transfers/${id}/complete`)
}

export function addHealthCheck(data) {
  return request.post('/health-checks', data)
}

export function getHealthChecksByTransfer(transferId) {
  return request.get(`/health-checks/transfer/${transferId}`)
}

export function getHealthChecksByPet(petId) {
  return request.get(`/health-checks/pet/${petId}`)
}

export function getPets(storeId) {
  const params = storeId ? { storeId } : {}
  return request.get('/pets', { params })
}

export function getPetDetail(id) {
  return request.get(`/pets/${id}`)
}
