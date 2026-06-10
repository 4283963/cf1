<template>
  <el-container style="min-height: 100vh">
    <el-header style="background: #545c64; display: flex; align-items: center; padding: 0 24px">
      <h2 style="color: #fff; margin: 0; font-size: 18px">🐾 宠物调拨管理系统</h2>
      <el-menu
        :default-active="$route.path"
        mode="horizontal"
        background-color="#545c64"
        text-color="#fff"
        active-text-color="#ffd04b"
        style="margin-left: 40px; flex: 1"
        router
      >
        <el-menu-item index="/inventory">📦 库存管理</el-menu-item>
        <el-menu-item index="/transfer">🔄 调拨管理</el-menu-item>
        <el-menu-item index="/pets">🐱 宠物管理</el-menu-item>
        <el-menu-item index="/driver">🚚 司机打卡</el-menu-item>
      </el-menu>
    </el-header>
    <el-main>
      <router-view />
    </el-main>
  </el-container>
</template>

<script setup>
</script>
