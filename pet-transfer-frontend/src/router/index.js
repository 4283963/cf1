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
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
