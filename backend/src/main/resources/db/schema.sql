-- ============================================================================
-- EasySkillHub (ESKH 1.0) · 数据库 schema
-- 可移植 DDL：H2 2.2.224 (MODE=MySQL) 与 MySQL 8.0.45 均已实测通过
-- 规范见 docs/02-统一数据模型与DDL.md
-- 纪律：不使用 ENGINE= / DEFAULT CHARSET= / 前缀索引 / ON DUPLICATE KEY / JSON 函数
-- ---------------------------------------------------------------------------
-- 登录认证（三系统共有）：账号 + 会话令牌
-- 说明：密码用 PBKDF2WithHmacSHA256 加盐哈希（12 万次迭代），不存明文；
--       令牌是随机 32 位十六进制串，默认 7 天有效，可随时撤销。
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_account (
  id            BIGINT       AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(64)  NOT NULL,
  display_name  VARCHAR(96)  NOT NULL DEFAULT '',
  password_hash VARCHAR(255) NOT NULL,
  password_salt VARCHAR(64)  NOT NULL,
  role          VARCHAR(24)  NOT NULL DEFAULT 'viewer',
  status        VARCHAR(16)  NOT NULL DEFAULT 'active',
  last_login_at DATETIME,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_account_username (username)
);

CREATE TABLE IF NOT EXISTS auth_token (
  id         BIGINT       AUTO_INCREMENT PRIMARY KEY,
  token      VARCHAR(64)  NOT NULL,
  username   VARCHAR(64)  NOT NULL,
  role       VARCHAR(24)  NOT NULL DEFAULT 'viewer',
  expires_at DATETIME     NOT NULL,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_auth_token_token (token),
  KEY idx_auth_token_user (username)
);

-- ============================================================================

CREATE TABLE IF NOT EXISTS app_meta (
  meta_key    VARCHAR(64)  NOT NULL PRIMARY KEY,
  meta_value  LONGTEXT,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS category (
  code        VARCHAR(48)  NOT NULL PRIMARY KEY,
  label       VARCHAR(64)  NOT NULL,
  kind        VARCHAR(16)  NOT NULL DEFAULT 'general',
  scene_code  VARCHAR(24)  NOT NULL DEFAULT 'general',
  sort_no     INT          NOT NULL DEFAULT 0,
  skill_count INT          NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS skill (
  id             BIGINT       AUTO_INCREMENT PRIMARY KEY,
  skill_id       VARCHAR(191) NOT NULL,
  slug           VARCHAR(191) NOT NULL,
  name           VARCHAR(191) NOT NULL,
  title          VARCHAR(191) NOT NULL DEFAULT '',
  description    TEXT,
  category_code  VARCHAR(48)  NOT NULL DEFAULT 'general',
  scene_code     VARCHAR(24)  NOT NULL DEFAULT 'general',
  tags           VARCHAR(512) NOT NULL DEFAULT '',
  version        VARCHAR(48)  NOT NULL DEFAULT '1.0.0',
  source         VARCHAR(24)  NOT NULL DEFAULT 'library',
  source_url     VARCHAR(512),
  source_repo    VARCHAR(191),
  license        VARCHAR(191) NOT NULL DEFAULT 'UNKNOWN',
  author         VARCHAR(191) NOT NULL DEFAULT '',
  author_kind    VARCHAR(16)  NOT NULL DEFAULT 'department',
  risk_score     INT          NOT NULL DEFAULT 0,
  risk_level     VARCHAR(16)  NOT NULL DEFAULT 'unrated',
  status         VARCHAR(16)  NOT NULL DEFAULT 'published',
  content        LONGTEXT,
  content_bytes  INT          NOT NULL DEFAULT 0,
  file_count     INT          NOT NULL DEFAULT 0,
  package_bytes  BIGINT       NOT NULL DEFAULT 0,
  content_sha256 VARCHAR(64)  NOT NULL DEFAULT '',
  download_count INT          NOT NULL DEFAULT 0,
  install_count  INT          NOT NULL DEFAULT 0,
  star_count     INT          NOT NULL DEFAULT 0,
  eval_count     INT          NOT NULL DEFAULT 0,
  avg_score      DECIMAL(6,2) NOT NULL DEFAULT 0,
  skillset_code  VARCHAR(64)  NOT NULL DEFAULT 'default',
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_skill_skill_id (skill_id),
  KEY idx_skill_category (category_code),
  KEY idx_skill_status (status),
  KEY idx_skill_scene (scene_code),
  KEY idx_skill_risk (risk_level),
  KEY idx_skill_updated (updated_at),
  KEY idx_skill_skillset (skillset_code)
);

CREATE TABLE IF NOT EXISTS skill_file (
  id         BIGINT       AUTO_INCREMENT PRIMARY KEY,
  skill_id   VARCHAR(191) NOT NULL,
  path       VARCHAR(512) NOT NULL,
  bytes      BIGINT       NOT NULL DEFAULT 0,
  sha256     VARCHAR(64)  NOT NULL DEFAULT '',
  is_primary BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_skill_file_skill (skill_id)
);

CREATE TABLE IF NOT EXISTS skill_version (
  id         BIGINT       AUTO_INCREMENT PRIMARY KEY,
  skill_id   VARCHAR(191) NOT NULL,
  version    VARCHAR(48)  NOT NULL,
  content    LONGTEXT,
  notes      VARCHAR(512) NOT NULL DEFAULT '',
  size_bytes INT          NOT NULL DEFAULT 0,
  origin     VARCHAR(24)  NOT NULL DEFAULT 'library',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_skill_version_skill (skill_id),
  UNIQUE KEY uk_skill_version (skill_id, version)
);

CREATE TABLE IF NOT EXISTS risk_audit (
  id              BIGINT       AUTO_INCREMENT PRIMARY KEY,
  skill_id        VARCHAR(191) NOT NULL,
  risk_score      INT          NOT NULL DEFAULT 0,
  risk_level      VARCHAR(16)  NOT NULL DEFAULT 'unrated',
  engine          VARCHAR(32)  NOT NULL DEFAULT 'rule-1.0',
  dimension_json  LONGTEXT,
  signal_total    INT          NOT NULL DEFAULT 0,
  summary         VARCHAR(512) NOT NULL DEFAULT '',
  conclusion      TEXT,
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_risk_audit_skill (skill_id)
);

CREATE TABLE IF NOT EXISTS risk_signal (
  id            BIGINT       AUTO_INCREMENT PRIMARY KEY,
  audit_id      BIGINT       NOT NULL,
  signal_code   VARCHAR(32)  NOT NULL,
  indicator     VARCHAR(191) NOT NULL DEFAULT '',
  dimension     VARCHAR(64)  NOT NULL DEFAULT '',
  severity      VARCHAR(16)  NOT NULL DEFAULT 'MEDIUM',
  weight        INT          NOT NULL DEFAULT 0,
  file_path     VARCHAR(512) NOT NULL DEFAULT '',
  line_no       INT          NOT NULL DEFAULT 0,
  remediation   TEXT,
  KEY idx_risk_signal_audit (audit_id)
);

CREATE TABLE IF NOT EXISTS contributor (
  id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
  source      VARCHAR(24)  NOT NULL DEFAULT 'local',
  author      VARCHAR(191) NOT NULL,
  name        VARCHAR(191) NOT NULL DEFAULT '',
  kind        VARCHAR(16)  NOT NULL DEFAULT 'department',
  description TEXT,
  git_profile VARCHAR(512) NOT NULL DEFAULT '',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_contributor (source, author)
);

CREATE TABLE IF NOT EXISTS contribution (
  id               BIGINT       AUTO_INCREMENT PRIMARY KEY,
  kind             VARCHAR(16)  NOT NULL DEFAULT 'department',
  contributor_name VARCHAR(191) NOT NULL,
  name             VARCHAR(191) NOT NULL,
  title            VARCHAR(191) NOT NULL DEFAULT '',
  version          VARCHAR(48)  NOT NULL DEFAULT '1.0.0',
  description      TEXT,
  source_type      VARCHAR(24)  NOT NULL DEFAULT 'upload',
  source_url       VARCHAR(512),
  storage_dir      VARCHAR(512) NOT NULL DEFAULT '',
  status           VARCHAR(16)  NOT NULL DEFAULT 'draft',
  cla_signed       BOOLEAN      NOT NULL DEFAULT FALSE,
  cla_signature    VARCHAR(191) NOT NULL DEFAULT '',
  cla_signed_at    DATETIME,
  skill_id         VARCHAR(191),
  risk_score       INT          NOT NULL DEFAULT 0,
  risk_level       VARCHAR(16)  NOT NULL DEFAULT 'unrated',
  notes            VARCHAR(1024) NOT NULL DEFAULT '',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_contribution_status (status),
  KEY idx_contribution_skill (skill_id)
);

CREATE TABLE IF NOT EXISTS doc_page (
  id         BIGINT       AUTO_INCREMENT PRIMARY KEY,
  doc_key    VARCHAR(96)  NOT NULL,
  title      VARCHAR(191) NOT NULL,
  section    VARCHAR(64)  NOT NULL DEFAULT 'guide',
  summary    VARCHAR(512) NOT NULL DEFAULT '',
  body       LONGTEXT,
  sort_no    INT          NOT NULL DEFAULT 0,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_doc_page_key (doc_key)
);

CREATE TABLE IF NOT EXISTS op_log (
  id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
  actor       VARCHAR(96)  NOT NULL DEFAULT 'guest',
  role        VARCHAR(24)  NOT NULL DEFAULT 'viewer',
  action      VARCHAR(64)  NOT NULL,
  target_type VARCHAR(48)  NOT NULL DEFAULT '',
  target_id   VARCHAR(191) NOT NULL DEFAULT '',
  detail      TEXT,
  trace_id    VARCHAR(48)  NOT NULL DEFAULT '',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_op_log_created (created_at),
  KEY idx_op_log_action (action)
);
