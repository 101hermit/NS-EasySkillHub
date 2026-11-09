import { createRouter, createWebHashHistory } from 'vue-router';

/**
 * 路由表（hash 模式：任何静态托管都不需要 rewrite 规则）。
 *
 * meta.menu 表示"出现在侧栏第几组"，meta.cap 表示"需要哪个能力开关"。
 * 能力未启用的路由**仍然可直达**（便于排障），但不出现在菜单里。
 */
const routes = [
  {
    // 登录 / 注册 / 访客：三系统同一个页面，meta.public 表示不需要会话
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: '登录', public: true },
  },  { path: '/', name: 'home', component: () => import('@/views/HomeView.vue'), meta: { title: '首页', menu: 'explore' } },
  {
    path: '/skills',
    name: 'skills',
    component: () => import('@/views/SkillListView.vue'),
    meta: { title: 'Skill 库', menu: 'explore' },
  },
  {
    path: '/skills/:id',
    name: 'skillDetail',
    component: () => import('@/views/SkillDetailView.vue'),
    meta: { title: 'Skill 详情' },
  },
  {
    path: '/contributors',
    name: 'contributors',
    component: () => import('@/views/ContributorListView.vue'),
    meta: { title: '贡献者', menu: 'explore' },
  },
  {
    path: '/contributors/:source/:author',
    name: 'contributorDetail',
    component: () => import('@/views/ContributorDetailView.vue'),
    meta: { title: '贡献者详情' },
  },
  {
    path: '/contribute',
    name: 'contribute',
    component: () => import('@/views/ContributeView.vue'),
    meta: { title: '在线贡献', menu: 'contribute', cap: 'skill.contribute' },
  },
  {
    path: '/risk',
    name: 'risk',
    component: () => import('@/views/RiskView.vue'),
    meta: { title: '安全评估', menu: 'site', cap: 'risk.scan' },
  },
  {
    path: '/docs',
    name: 'docs',
    component: () => import('@/views/DocsView.vue'),
    meta: { title: '在线文档', menu: 'site' },
  },
  {
    path: '/docs/:key',
    name: 'docPage',
    component: () => import('@/views/DocsView.vue'),
    meta: { title: '在线文档', menu: 'site' },
  },
  {
    path: '/about',
    name: 'about',
    component: () => import('@/views/AboutView.vue'),
    meta: { title: '关于本版本', menu: 'site' },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'notFound',
    component: () => import('@/views/NotFoundView.vue'),
    meta: { title: '页面不存在' },
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior(to, from, saved) {
    if (saved) return saved;
    return { top: 0 };
  },
});

router.afterEach((to) => {
  const base = document.title.split(' · ')[0];
  if (to.meta?.title) document.title = `${to.meta.title} · ${base}`;
});

export default router;
