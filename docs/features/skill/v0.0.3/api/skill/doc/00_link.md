# skill - API test link

Base URL: `http://localhost:3000`

| # | Interface | Status | Result | Doc |
|---|-----------|--------|--------|-----|
| 1 | `POST /api/skills/upload` | `200` | PASS | [01_upload.md](01_upload.md) |
| 2 | `POST /api/skills/upload` | `400` | PASS | [02_upload_no_skill.md](02_upload_no_skill.md) |
| 3 | `GET /api/skills` | `200` | PASS | [03_list.md](03_list.md) |
| 4 | `GET /api/skills/:id` | `200` | PASS | [04_detail.md](04_detail.md) |
| 5 | `GET /api/skills/:id/files` | `200` | PASS | [05_files.md](05_files.md) |
| 6 | `GET /api/skills/:id/files/*path` | `200` | PASS | [06_file_content.md](06_file_content.md) |
| 7 | `GET /api/skills/:id/files/references/guide.md` | `200` | PASS | [07_file_subdir.md](07_file_subdir.md) |
| 8 | `GET /api/skills/:id/files/nonexist.md` | `404` | PASS | [08_file_not_found.md](08_file_not_found.md) |
| 9 | `DELETE /api/skills/:id` | `200` | PASS | [09_delete.md](09_delete.md) |
| 10 | `GET /api/skills/:id` | `404` | PASS | [10_deleted_404.md](10_deleted_404.md) |
