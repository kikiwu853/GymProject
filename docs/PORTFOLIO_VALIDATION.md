# 作品集整理與驗證紀錄

日期：2026-11-17（Asia/Taipei）。團隊來源版本：`80fbafca0e2f5304daff1fa6f38a616768b20c08`。

## 使用者 Windows 本機驗證

- 從團隊 main 下載，Eclipse／STS 使用 JDK 21.0.12.1；Node.js 24.21.0。
- 以環境變數設定 SQL Server 連線，沒有把本機帳密寫入共用 properties。
- 舊資料庫結構修正後，Hibernate validate 與 JPA 初始化成功。
- 啟動紀錄包含 `Tomcat started on port 8080` 與 `Started GymApplication`。
- React 登入頁成功顯示；使用者回報會員、教練與管理員帳號測試成功。
- 沒有逐項取得新增／改期／取消、出席／量測／續約的實際操作證據，因此不宣稱整套系統已完成端到端驗收。

## 本次工作環境驗證

環境：Linux、Node.js 24.22.1，以專案 package-lock.json 安裝依賴。

| 項目 | 結果 |
|---|---|
| `npm ci --ignore-scripts` | 安裝成功 |
| `npm test` | 26 項通過，0 失敗 |
| `npm run build` | TypeScript 檢查及 Vite 建置通過 |
| `npm run lint` | 原有一項 no-control-regex 錯誤；在有意比對 Java 控制空白字元的那一行增加局部 ESLint 例外註解後重跑通過 |
| Markdown 相對路徑／新增檔案 | 已檢查目標存在 |
| `git diff --check` | 通過 |

Vite 建置有單一 JavaScript chunk 超過 500 kB 的提醒，屬後續效能改善項目，並未造成建置失敗。

此環境沒有 Maven 與可連線的 SQL Server，未重跑後端 Maven 測試，也未執行整合版 SQL。`v001_portfolio_legacy_alignment.sql` 是本機已分階段執行之修改的整合與防呆版本，完整檔仍需在相符測試庫另行驗證。

## 公開內容檢查

- 保留團隊 43 筆來源提交歷史與明確來源連結。
- 對可達 Git 物件執行常見 Token／私鑰及硬編碼資料庫帳密模式檢查，另檢查目前設定與展示文件；未發現需移除的真實資料庫登入密碼、常見 Token 或私鑰。
- 本檢查是有限模式與人工檢視，不是涵蓋所有秘密格式或所有個資的保證。
- 原始文件中的共用登入密碼明確標示為本機虛構展示帳號用途；不是 SQL Server 連線密碼。
- 新增本機環境檔、IDE launch、資料庫備份／檔案與上傳目錄的忽略規則。`.gitignore` 不會自動移除已追蹤檔案，因此本機 Eclipse 修改不在本次提交範圍內。

## 本次交付範圍

- 新增作品集 README、真實登入頁截圖、本機啟動與驗證文件。
- 新增舊版資料庫修正紀錄，保留原始建表與展示腳本及其限制。
- 更新忽略規則；新增一處僅影響 lint 的註解，不改業務邏輯。
- 未建立公開線上服務，未修改原小組儲存庫。
