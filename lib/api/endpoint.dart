const health = "/health";
const snapshotLatest = "/api/v1/snapshot/latest";
const summariesLatest = "/api/v1/summaries/latest";
const appUpdateCheck = "/api/v1/app/update-check";
const analyticsPing = "/api/v1/analytics/ping";
const marketAnalysisLatest = "/api/v1/market-analysis/latest";
const feedback = "/api/v1/feedback";

String summaryByCategory(String category) => "/api/v1/summaries/$category";
