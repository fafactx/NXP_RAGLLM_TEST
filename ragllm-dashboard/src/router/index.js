import { createRouter, createWebHistory } from 'vue-router';
import Dashboard from '../views/Dashboard.vue';
import TestCases from '../views/TestCases.vue';
import Settings from '../views/Settings.vue';

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: Dashboard
  },
  {
    path: '/testcases',
    name: 'testcases',
    component: TestCases
  },
  {
    path: '/results',
    name: 'results',
    component: () => import('../views/Results.vue')
  },
  {
    path: '/settings',
    name: 'settings',
    component: Settings
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
