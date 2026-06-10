import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/inventory'
  },
  {
    path: '/inventory',
    name: 'Inventory',
    component: () => import('../views/InventoryView.vue')
  },
  {
    path: '/transfer',
    name: 'Transfer',
    component: () => import('../views/TransferView.vue')
  },
  {
    path: '/pets',
    name: 'Pets',
    component: () => import('../views/LivePetView.vue')
  },
  {
    path: '/driver',
    name: 'Driver',
    component: () => import('../views/DriverCheckinView.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
