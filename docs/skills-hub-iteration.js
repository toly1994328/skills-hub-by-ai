const pptxgen = require("pptxgenjs");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";

// 配色
const C = {
  primary: "FF6D00",    // 橙色品牌色
  dark: "1E2530",       // 深色背景
  white: "FFFFFF",
  light: "F8F9FA",
  gray: "666666",
  lightGray: "999999",
  accent: "FF6D00",
};

// ─── Slide 1: 封面 ───
let slide = pptx.addSlide();
slide.background = { color: C.dark };
slide.addText("Skills Hub", {
  x: 1, y: 1.5, w: 8, h: 1.2,
  fontSize: 48, bold: true, color: C.white, fontFace: "Arial Black",
});
slide.addText("AI 技能社区 — 迭代复盘", {
  x: 1, y: 2.7, w: 8, h: 0.6,
  fontSize: 24, color: C.accent, fontFace: "Arial",
});
slide.addText("v0.0.1 → v0.0.2  |  2026.06.12 — 2026.06.13", {
  x: 1, y: 3.5, w: 8, h: 0.5,
  fontSize: 14, color: C.lightGray, fontFace: "Arial",
});
slide.addText("全栈 · Rust + Flutter · AI 驱动开发", {
  x: 1, y: 4.2, w: 8, h: 0.5,
  fontSize: 14, color: C.lightGray, fontFace: "Arial",
});

// ─── Slide 2: 项目概览 ───
slide = pptx.addSlide();
slide.background = { color: C.white };
slide.addText("项目概览", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.dark, fontFace: "Arial",
});
slide.addText(
  "Skills Hub 是一个全栈、全平台的 AI 技能社区。\n用户可以浏览、查看、发布 AI 编程技能（SKILL.md）。",
  { x: 0.8, y: 1.4, w: 11, h: 0.8, fontSize: 16, color: C.gray, fontFace: "Arial", lineSpacingMultiple: 1.5 }
);

// 技术栈
const stacks = [
  { label: "后端", value: "Rust + Axum + SQLx + MySQL" },
  { label: "前端", value: "Flutter (全平台) + fx_dio + BLoC" },
  { label: "工具链", value: "Python 脚本 (db/seed/test)" },
  { label: "开发流程", value: "12 步流水线 + AI 驱动" },
];
stacks.forEach((item, i) => {
  const y = 2.6 + i * 0.7;
  slide.addShape(pptx.ShapeType.roundRect, { x: 0.8, y, w: 0.08, h: 0.5, fill: { color: C.accent } });
  slide.addText(item.label, { x: 1.1, y, w: 2, h: 0.5, fontSize: 14, bold: true, color: C.dark, fontFace: "Arial", valign: "middle" });
  slide.addText(item.value, { x: 3, y, w: 8, h: 0.5, fontSize: 14, color: C.gray, fontFace: "Arial", valign: "middle" });
});

// ─── Slide 3: v0.0.1 总览 ───
slide = pptx.addSlide();
slide.background = { color: C.dark };
slide.addText("v0.0.1 — 基础版", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.white, fontFace: "Arial",
});
slide.addText("列表浏览 + 详情查看 + API 测试链", {
  x: 0.8, y: 1.2, w: 8, h: 0.5,
  fontSize: 16, color: C.accent, fontFace: "Arial",
});

const v1Items = [
  "后端分层架构: Router → Service → Repository",
  "GET /api/skills (分页列表)",
  "GET /api/skills/:id (详情含 Markdown)",
  "POST /api/skills (供 seed 脚本使用)",
  "前端: fx_dio Host + Cubit 状态管理",
  "列表页 + 卡片组件 + 详情页",
  "API 测试链 (7/7 PASS) + 自动生成接口文档",
  "数据库管理脚本 db.py + 种子数据 seed.py",
];
v1Items.forEach((item, i) => {
  slide.addText(`•  ${item}`, {
    x: 1, y: 2 + i * 0.5, w: 11, h: 0.45,
    fontSize: 14, color: C.white, fontFace: "Arial",
  });
});

// ─── Slide 4: v0.0.1 架构图 ───
slide = pptx.addSlide();
slide.background = { color: C.white };
slide.addText("v0.0.1 — 系统架构", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.dark, fontFace: "Arial",
});

// 简化的架构层次
const layers = [
  { label: "Flutter 视图层", desc: "SkillListPage · SkillDetailPage · SkillCard", color: "E8F5E9", y: 1.5 },
  { label: "Flutter 状态层", desc: "SkillListCubit · SkillDetailCubit", color: "FFF3E0", y: 2.5 },
  { label: "Flutter 数据层", desc: "SkillRepository (fx_dio)", color: "E3F2FD", y: 3.5 },
  { label: "Axum API 层", desc: "skill_router (GET/POST)", color: "FFEBEE", y: 4.5 },
  { label: "Rust 服务层", desc: "skill_service + skill_repository", color: "FFF8E1", y: 5.2 },
  { label: "MySQL", desc: "skills 表", color: "ECEFF1", y: 5.9 },
];
layers.forEach((l) => {
  slide.addShape(pptx.ShapeType.roundRect, { x: 2, y: l.y, w: 9, h: 0.6, fill: { color: l.color }, line: { color: "E0E0E0", width: 1 } });
  slide.addText(l.label, { x: 2.2, y: l.y, w: 3, h: 0.6, fontSize: 12, bold: true, color: C.dark, fontFace: "Arial", valign: "middle" });
  slide.addText(l.desc, { x: 5.2, y: l.y, w: 5.5, h: 0.6, fontSize: 11, color: C.gray, fontFace: "Arial", valign: "middle" });
});

// ─── Slide 5: v0.0.2 总览 ───
slide = pptx.addSlide();
slide.background = { color: C.dark };
slide.addText("v0.0.2 — UI 改造 + 发布功能", {
  x: 0.8, y: 0.4, w: 10, h: 0.8,
  fontSize: 36, bold: true, color: C.white, fontFace: "Arial",
});
slide.addText("微信简洁风 · 橙色品牌色 · 全面优化", {
  x: 0.8, y: 1.2, w: 8, h: 0.5,
  fontSize: 16, color: C.accent, fontFace: "Arial",
});

const v2Items = [
  "技能发布页: 表单 + Markdown 文件选择 + 实时预览",
  "底部导航栏: 首页(技能广场) + 我的",
  "详情页: SliverAppBar 折叠头部 + Tab 面板",
  "代码块语法高亮 (flutter_highlighter + github theme)",
  "Markdown front-matter 自动转 yaml 代码块",
  "列表: 三行卡片布局 + 橙色版本标签 + 时间",
  "条目间 6px 灰色色块分隔",
  "种子数据: content_file 本地引用机制",
];
v2Items.forEach((item, i) => {
  slide.addText(`•  ${item}`, {
    x: 1, y: 2 + i * 0.5, w: 11, h: 0.45,
    fontSize: 14, color: C.white, fontFace: "Arial",
  });
});

// ─── Slide 6: UI 设计规范 ───
slide = pptx.addSlide();
slide.background = { color: C.white };
slide.addText("UI 设计规范", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.dark, fontFace: "Arial",
});
slide.addText("微信简洁风 — 克制、安静、信息优先", {
  x: 0.8, y: 1.2, w: 8, h: 0.5,
  fontSize: 16, italic: true, color: C.gray, fontFace: "Arial",
});

// 配色表
const colors = [
  { name: "品牌色", hex: "FF6D00", textColor: C.white },
  { name: "背景", hex: "EDEDED", textColor: C.dark },
  { name: "主文字", hex: "181818", textColor: C.white },
  { name: "副文字", hex: "666666", textColor: C.white },
  { name: "链接蓝", hex: "576B95", textColor: C.white },
  { name: "分割线", hex: "E5E5E5", textColor: C.dark },
];
colors.forEach((c, i) => {
  const x = 0.8 + i * 2;
  slide.addShape(pptx.ShapeType.roundRect, { x, y: 2, w: 1.8, h: 1.2, fill: { color: c.hex }, line: { color: "E0E0E0", width: 0.5 } });
  slide.addText(`#${c.hex}`, { x, y: 2, w: 1.8, h: 0.8, fontSize: 10, color: c.textColor, fontFace: "Consolas", align: "center", valign: "middle" });
  slide.addText(c.name, { x, y: 2.7, w: 1.8, h: 0.5, fontSize: 11, color: c.textColor, fontFace: "Arial", align: "center", valign: "middle" });
});

// 规则
const rules = [
  "❌ 不用阴影 / 渐变 / 水波纹",
  "❌ 不用圆形头像 / FAB",
  "✅ 分割线代替阴影",
  "✅ 点击态: 背景变灰",
  "✅ 字体: 17/15/13/11 四级",
  "✅ 间距: 16px 统一边距",
];
rules.forEach((r, i) => {
  const col = i < 3 ? 0 : 1;
  const row = i % 3;
  slide.addText(r, {
    x: 0.8 + col * 6, y: 3.8 + row * 0.5, w: 5.5, h: 0.45,
    fontSize: 13, color: C.dark, fontFace: "Arial",
  });
});

// ─── Slide 7: 开发流程 ───
slide = pptx.addSlide();
slide.background = { color: C.light };
slide.addText("12 步开发流水线", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.dark, fontFace: "Arial",
});

const steps = [
  ["1. 需求分析", "2. 后端设计", "3. 后端任务", "4. 交叉审查"],
  ["5. 后端实现", "6. 后端测试", "7. 前端设计", "8. 前端任务"],
  ["9. 前端审查", "10. 前端实现", "11. 前端测试", "12. 归档"],
];
steps.forEach((row, ri) => {
  row.forEach((step, ci) => {
    const x = 0.8 + ci * 3;
    const y = 1.6 + ri * 1.6;
    slide.addShape(pptx.ShapeType.roundRect, { x, y, w: 2.7, h: 1.1, fill: { color: C.white }, line: { color: C.accent, width: 1.5 } });
    slide.addText(step, { x, y, w: 2.7, h: 1.1, fontSize: 13, bold: true, color: C.dark, fontFace: "Arial", align: "center", valign: "middle" });
  });
});

// ─── Slide 8: 功能网络 ───
slide = pptx.addSlide();
slide.background = { color: C.white };
slide.addText("功能节点网络", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.dark, fontFace: "Arial",
});

const nodes = [
  { id: "I-01", name: "数据库基础", x: 5.5, y: 5.5, color: "ECEFF1" },
  { id: "D-01", name: "技能存储", x: 4.5, y: 4.5, color: "FFF8E1" },
  { id: "D-02", name: "技能服务", x: 6.5, y: 4.5, color: "FFF8E1" },
  { id: "P-01", name: "技能API路由", x: 5.5, y: 3.5, color: "FFEBEE" },
  { id: "F-01", name: "技能列表页", x: 3.5, y: 2, color: "E8F5E9" },
  { id: "F-02", name: "技能详情页", x: 5.5, y: 2, color: "E8F5E9" },
  { id: "F-03", name: "技能发布页", x: 7.5, y: 2, color: "E8F5E9" },
  { id: "F-04", name: "底部导航", x: 9.5, y: 2, color: "F3E5F5" },
];
nodes.forEach((n) => {
  slide.addShape(pptx.ShapeType.roundRect, { x: n.x, y: n.y, w: 2, h: 0.7, fill: { color: n.color }, line: { color: "BDBDBD", width: 1 } });
  slide.addText(`${n.id}\n${n.name}`, { x: n.x, y: n.y, w: 2, h: 0.7, fontSize: 9, color: C.dark, fontFace: "Arial", align: "center", valign: "middle", lineSpacingMultiple: 1.1 });
});

// ─── Slide 9: 数据统计 ───
slide = pptx.addSlide();
slide.background = { color: C.dark };
slide.addText("两次迭代数据", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.white, fontFace: "Arial",
});

const stats = [
  { num: "8", label: "功能节点" },
  { num: "60+", label: "文件变更" },
  { num: "5500+", label: "新增代码行" },
  { num: "7/7", label: "API 测试通过" },
  { num: "5/5", label: "单元测试通过" },
  { num: "0", label: "编译错误" },
];
stats.forEach((s, i) => {
  const col = i % 3;
  const row = Math.floor(i / 3);
  const x = 1.5 + col * 3.8;
  const y = 1.8 + row * 2.2;
  slide.addText(s.num, { x, y, w: 3, h: 1, fontSize: 48, bold: true, color: C.accent, fontFace: "Arial", align: "center", valign: "bottom" });
  slide.addText(s.label, { x, y: y + 1, w: 3, h: 0.5, fontSize: 14, color: C.lightGray, fontFace: "Arial", align: "center" });
});

// ─── Slide 10: 下一步 ───
slide = pptx.addSlide();
slide.background = { color: C.white };
slide.addText("下一步计划", {
  x: 0.8, y: 0.4, w: 8, h: 0.8,
  fontSize: 36, bold: true, color: C.dark, fontFace: "Arial",
});

const nextSteps = [
  { title: "v0.0.3 — 用户系统", desc: "注册/登录、个人主页、我发布的技能" },
  { title: "v0.0.4 — 搜索筛选", desc: "按标签/作者/关键词搜索和筛选" },
  { title: "v0.0.5 — 社区互动", desc: "收藏、评分、评论" },
  { title: "v0.0.6 — 技能安装", desc: "一键安装技能到本地 IDE" },
];
nextSteps.forEach((item, i) => {
  const y = 1.5 + i * 1.2;
  slide.addShape(pptx.ShapeType.roundRect, { x: 0.8, y, w: 11.5, h: 0.9, fill: { color: C.light }, line: { color: "E0E0E0", width: 0.5 } });
  slide.addText(item.title, { x: 1.2, y, w: 4, h: 0.9, fontSize: 16, bold: true, color: C.dark, fontFace: "Arial", valign: "middle" });
  slide.addText(item.desc, { x: 5.2, y, w: 6.8, h: 0.9, fontSize: 14, color: C.gray, fontFace: "Arial", valign: "middle" });
});

// ─── 输出 ───
pptx.writeFile({ fileName: "docs/Skills-Hub-迭代复盘.pptx" })
  .then(() => console.log("PPT 已生成: docs/Skills-Hub-迭代复盘.pptx"))
  .catch(err => console.error(err));
