---
name: code-review-pr
description: 对比当前分支与最新 dev 分支并生成标准化中文 PR 内容（标题、描述、Code Review 追加结论），并通过 gh CLI 创建 PR。当用户要求代码评审、准备 PR、整理变更说明、检查无关改动或提交 PR 时使用。
---

# Code Review PR

按以下流程执行并产出结果，保持中文、客观、克制，不臆测。

---

# 1. 基线与差异采集

先以最新 `dev` 为基线，再分析当前分支。

## 同步远端

```bash
git fetch --all --prune
````

## 获取当前分支

```bash
git branch --show-current
```

## 选择基线

优先：

```
origin/dev
```

若不存在则使用：

```
dev
```

若仍不存在则使用：

```
origin/main
```

---

## 收集差异

提交级别：

```bash
git log --oneline <base>..HEAD
```

文件级别：

```bash
git diff --name-status <base>...HEAD
```

代码级别：

```bash
git diff <base>...HEAD
```

聚焦 PR 目标相关改动。

识别疑似无关改动：

* 纯格式化变更
* 自动生成文件
* 与当前功能无关文件
* 顺手修复

若仓库信息不足，必须明确说明限制条件。

---

# 2. PR 标题生成规则

标题格式：

```
<type>(<scope?>): <subject>
```

允许的 `type`：

* feat
* fix
* refactor
* perf
* style
* test
* chore

示例：

```
feat(login): 支持邮箱登录
fix(cart): 修复商品数量计算错误
refactor(api): 重构用户接口调用
```

要求：

* 简洁
* 不超过 50 字符
* 不使用空泛词

---

# 3. PR 描述输出模板

必须输出完整结构：

```md
## 背景

为什么要做这个改动？解决什么问题？

## 变更内容

- 做了什么
- 改了哪些模块

## 影响范围

- 是否影响现有功能
- 是否涉及数据库 / 接口 / 路由变更

## 测试情况

- 本地是否验证
- 覆盖了哪些场景

## 关联

- 需求 / Issue / 文档
```

未知信息必须标注：

```
未提供 / 待补充
```

---

# 4. Code Review 追加输出

在 PR 描述后追加：

## Code Review

### 关键改动总结

* 概括本次 diff 的核心变化

### 潜在问题

* 逻辑风险
* 边界条件
* 可维护性问题

### 优化建议

* 是否建议拆分提交
* 是否建议补测试
* 是否存在更优实现

若无法判断：

```
依据不足
```

---

# 5. 输出顺序

严格按照以下顺序输出：

1. PR Title
2. PR Description
3. Code Review
4. 无关改动
5. 信息不足

---

# 6. 提交前检查

## 检查未提交代码

```bash
git status
```

若存在未提交文件：

提示：

```
存在未提交修改，请先 commit 或 stash
```

---

## push 当前分支

```bash
git push -u origin HEAD
```

---

## 检查是否已有 PR

```bash
gh pr list --head $(git branch --show-current)
```

若已有 PR：

* 不重复创建
* 输出已有 PR 链接

---

# 7. 使用 gh CLI 创建 PR

创建 PR：

```bash
gh pr create \
  --base dev \
  --head $(git branch --show-current) \
  --title "<PR Title>" \
  --body "<PR Description>"
```

若 `dev` 不存在：

使用：

```
main
```

---

# 8. 创建 PR 后输出

执行：

```bash
gh pr view --web
```

输出内容：

```
PR 已创建
PR URL
PR Title
目标分支
当前分支
```

若失败：

* 输出真实错误信息
* 不伪造结果

---

# 行为约束

必须遵守：

* 不臆测代码意图
* 不编造测试结果
* 不自动修改代码
* 不创建重复 PR
* 不忽略无关改动
