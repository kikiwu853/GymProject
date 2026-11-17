# 本機啟動說明

## 環境

- JDK 21；終端機與 IDE 可能使用不同 JDK，請確認實際 Run Configuration。
- Node.js >= 22.12；本機使用 Node 24。
- SQL Server、SSMS。
- Eclipse／STS 的 Maven 支援，或命令列 Maven。本專案目前沒有 Maven Wrapper。

## 資料庫先決條件

2026-11-17 的成功測試使用既有 `GymProject` 資料庫，並補齊舊結構與 `80fbafc` 程式之間的差異。這不是空資料庫的一鍵初始化驗證。

| 情境／腳本 | 用途與限制 |
|---|---|
| 已有舊版 GymProject | 先備份並比對欄位；[舊庫修正腳本](../database/migrations/v001_portfolio_legacy_alignment.sql)記錄本次修改。已完成這些修改的本機不需要再次執行。 |
| `02_create_tables_integrated.sql` | 團隊完整建表參考，會刪除其目標庫既有表與資料；不是升級腳本。不要在要保留資料的資料庫執行。 |
| `03_team_reset_and_seed.sql` | 團隊隔離展示庫重建腳本，僅允許 `gymproject_seed_verify_20261030`，初始化日期限制為 2026-10-30～2026-11-13；目前已過期。保留原限制，不以移除防呆的方式執行。 |
| 全新環境 | 需先準備專用空測試資料庫、審閱建表腳本的目標庫與結構，並準備有效測試帳號、購課及未來課表；本版尚未提供經 SQL Server 驗證的全新環境一鍵種子資料。 |

舊庫修正腳本不是適用所有版本的通用遷移。它要求缺少關聯欄位的 `inbodyrecords`／`renewal` 為空表，不會臆測既有紀錄的出席／新購課對應。不要用 `ddl-auto=update` 掩蓋不明結構差異。

SQL Server 的登入、資料庫使用者與權限需在自己的執行個體設定；Git 不會建立這些帳號。

## 後端：Eclipse／STS

1. 以 **Existing Maven Projects** 匯入根目錄 `pom.xml`。工作區有同名專案時，可在 Advanced → Name template 使用不同顯示名稱。
2. 選用 JDK 21。專案使用 Spring Boot 內嵌 Tomcat，不需要綁定本機外部 Tomcat。
3. 在 Run Configurations 中選擇本專案與主類別 `tw.gymproject.GymApplication`。
4. 在 Environment 分頁新增下列環境變數：

| 變數 | 範例或填寫方式 |
|---|---|
| `DB_URL` | `jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=GymProject;encrypt=true;trustServerCertificate=true` |
| `DB_USERNAME` | 自己的 SQL Server 登入帳號 |
| `DB_PASSWORD` | 自己的 SQL Server 登入密碼 |

以上 URL 是本機開發範例，請依實際 SQL Server 執行個體、埠號及資料庫名稱調整。不要把真實帳密寫入 Git 或分享的 `.launch` 檔案。

5. 按 Run；看到 `Tomcat started on port 8080` 和 `Started GymApplication` 代表啟動完成。

若使用命令列，先在目前程序環境中設定同樣變數，再執行 `mvn spring-boot:run`。`application.properties` 中保留 `${DB_URL}` 等設定與 `spring.jpa.hibernate.ddl-auto=validate`。

## 前端

```bash
cd frontend
npm ci
npm run dev
```

Windows PowerShell 若阻擋 `npm.ps1`，可改用 `npm.cmd ci` 與 `npm.cmd run dev`，不用修改整台電腦的執行原則。

開啟 http://localhost:5173；前後端程序都要保持運行。Vite 預設代理到 http://localhost:8080。若後端位址不同，複製 `frontend/.env.example` 成 `.env.local` 後調整 `BACKEND_URL`，再重啟 Vite。

團隊展示帳號詳見 [原始展示說明](../database/README_team_demo.md)；它們只有在資料庫中已建立對應帳號時才有效，並非安裝程式就會自動建立。

## 測試與建置

```bash
# 在 frontend 目錄
npm test
npm run lint
npm run build
```

`build` 會先執行 TypeScript 檢查。後端測試可在已安裝 Maven 的根目錄執行 `mvn test`。

`npm run preview` 與正式部署不會自動使用 Vite 開發代理；部署時仍需設定 API 反向代理、Session Cookie 與 SPA fallback。本版未完成正式部署驗證。

## 測試順序

1. 三角色登入與登出。
2. 會員已購課程、預約列表；教練課表；管理員日期切換。
3. 使用測試紀錄完成新增預約 → 改期 → 取消，確認各角色畫面一致。
4. 檢查不能預約今天／過去日期、未購課程、其他會員方案或已被預約時段。
5. 出席、InBody、續約與關懷另外驗證；不能由「成功登入」推論所有寫入流程都已通過。
