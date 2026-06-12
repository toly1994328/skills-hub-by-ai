# skill - API test link

Base URL: `http://localhost:3000`

| # | Interface | Status | Result | Doc |
|---|-----------|--------|--------|-----|
| 1 | `POST /api/skills` | `200` | PASS | [01_create_skill.md](01_create_skill.md) |
| 2 | `POST /api/skills` | `400` | PASS | [02_create_skill_empty_name.md](02_create_skill_empty_name.md) |
| 3 | `POST /api/skills` | `400` | PASS | [03_create_skill_empty_content.md](03_create_skill_empty_content.md) |
| 4 | `GET /api/skills` | `200` | PASS | [04_list_skills.md](04_list_skills.md) |
| 5 | `GET /api/skills?page=1&page_size=1` | `200` | PASS | [05_list_skills_paged.md](05_list_skills_paged.md) |
| 6 | `GET /api/skills/:id` | `200` | PASS | [06_get_skill.md](06_get_skill.md) |
| 7 | `GET /api/skills/99999` | `404` | PASS | [07_get_skill_not_found.md](07_get_skill_not_found.md) |
