CREATE TABLE IF NOT EXISTS skills (
    id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)    NOT NULL COMMENT '技能名称',
    description VARCHAR(5000)    NOT NULL DEFAULT '' COMMENT '简短描述',
    author      VARCHAR(100)    NOT NULL DEFAULT '' COMMENT '作者',
    tags        VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
    icon_url    VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '图标URL',
    source_url  VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '来源网站URL',
    version     VARCHAR(50)     NOT NULL DEFAULT '0.0.1' COMMENT '语义化版本号',
    download_url VARCHAR(500)   NOT NULL DEFAULT '' COMMENT '下载链接',
    content     TEXT            NOT NULL COMMENT 'Markdown说明文档',
    status      VARCHAR(20)     NOT NULL DEFAULT 'published' COMMENT '状态: draft/published/archived',
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_status (status),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='技能表';
