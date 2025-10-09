
import { Metrics, Section } from './types';

export const METRICS_DATA: Metrics = {
    revenueStreams: "6 (5 Fiat Streams + $AIS Token Staking/Fees)",
    y1Projection: "~$2.7M ARR (DAO liquidity & accelerated adoption)",
    y3Projection: "$15M+ ARR (Token governance driving enterprise)",
    complianceStatus: "100% (Fiat: 20+ State Compliant | Crypto: Audit/KYC Ready)",
    architecture: [
        { label: "Frontend/Backend", detail: "Next.js / FastAPI" },
        { label: "Data Stack", detail: "Postgres 15 / Redis 7 / Qdrant" },
        { label: "DAO Service", detail: "Polygon/Ethereum Smart Contracts (gRPC link)" },
        { label: "Monitoring", detail: "Prometheus 3.6.0 / Grafana 11.2.0" }
    ]
};

export const INITIAL_SECTIONS_DATA: Section[] = [
    {
        id: 'prereq_keys',
        title: '1. Prerequisites & Key Management',
        icon: '🔑',
        description: 'Verify the environment and gather all live production secrets required for the deployment process, ensuring all API keys and credentials are secure.',
        tasks: [
            { id: 'P1.1', action: 'Provision VPS', requirement: 'VPS: Ubuntu 22.04+ (4GB RAM/2vCPU; e.g., DigitalOcean $5/mo).', refs: 'Guide Step 1', completed: false },
            { id: 'P1.2', action: 'Install Tools', requirement: 'Tools: Docker 27.0+/Compose 2.24+, Git, SSH.', refs: 'Guide Step 1', completed: false },
            { id: 'P1.3', action: 'Gather Live Keys', requirement: 'Keys: Stripe live, OpenAI, Google OAuth, Twilio, Cloudflare API token (Zone:Read+Edit).', refs: 'Guide Step 1', completed: false },
            { id: 'P1.4', action: 'Download & Extract', requirement: 'SSH VPS and execute: `wget [PROD_ZIP_URL]` and `unzip ai-marketplace-production_*.zip`.', refs: 'Guide Step 3', completed: false },
        ]
    },
    {
        id: 'dns_ssl',
        title: '2. IONOS to Cloudflare DNS & SSL',
        icon: '🌐',
        description: 'Configure the domain nameservers, set up Cloudflare protection (CDN/DDoS/WAF), and secure the origin with a fresh, trusted SSL certificate.',
        tasks: [
            { id: 'D2.1', action: 'IONOS Nameservers to CF', requirement: 'In IONOS, change ai-solutions.store nameservers to Cloudflare-assigned (e.g., dawn.ns.cloudflare.com). Propagation 1-24h.', refs: 'Guide Step 2', completed: false },
            { id: 'D2.2', action: 'Cloudflare Configuration', requirement: 'SSL/TLS: Full Strict, Always HTTPS On, Min TLS 1.3. Import A/@/www records to VPS IP.', refs: 'Guide Step 2', completed: false },
            { id: 'D2.3', action: 'Origin Cert Generation', requirement: 'Generate Cloudflare Origin Cert: `openssl req...` and copy/verify to `ssl/origin.crt`.', refs: 'Guide Step 2', completed: false },
            { id: 'D2.4', action: 'Let\'s Encrypt for Nginx', requirement: 'Run `certbot certonly --standalone -d ai-solutions.store...` and copy files to `ssl/` folder for Nginx.', refs: 'Guide Step 5', completed: false },
        ]
    },
    {
        id: 'config_nginx',
        title: '3. Environment Configuration & Nginx Setup',
        icon: '⚙️',
        description: 'Finalize the .env secrets, configure the Nginx reverse proxy for secure traffic routing, and install the required Certificate Authority.',
        tasks: [
            { id: 'C3.1', action: 'Initialize .env', requirement: 'Run `./deploy-enhanced.sh --init-env`.', refs: 'Guide Step 4', completed: false },
            { id: 'C3.2', action: 'Finalize Live .env Keys', requirement: 'Edit `.env` with all **live keys** (Stripe, OpenAI, Twilio, Cloudflare) and secure secrets (DB/Redis/JWT/Grafana). Set `ENABLE_AGE_VERIFICATION=true`.', refs: 'Guide Step 4', completed: false },
            { id: 'C3.3', action: 'Nginx Cloudflare Config', requirement: 'Configure `nginx.conf` with `ngx_http_realip_module` and `set_real_ip_from [cloudflare-ranges]` to properly log client IPs.', refs: 'Guide Step 5', completed: false },
            { id: 'C3.4', action: 'Nginx Proxy Setup', requirement: 'Verify Nginx proxies traffic: 443 -> marketplace-app:3000; /prometheus -> prometheus:9090; Redirect 80 -> 443.', refs: 'Guide Step 5', completed: false },
        ]
    },
    {
        id: 'deploy_ops',
        title: '4. Deployment Execution & Operations',
        icon: '🚀',
        description: 'Run the primary deployment script, establish cron jobs for maintenance and reporting, and verify the successful launch and health of all microservices.',
        tasks: [
            { id: 'E4.1', action: 'Execute Full Deployment', requirement: 'Run `./scripts/deploy-full.sh` (handles Docker up/scale, DB migration, webhook/datasource init).', refs: 'Guide Step 6', completed: false },
            { id: 'E4.2', action: 'Initial Health Check', requirement: 'Wait 60s, then verify: `curl -k https://ai-solutions.store/health` returns `{"status":"healthy"}`.', refs: 'Guide Step 6', completed: false },
            { id: 'E4.3', action: 'Setup Crontab Automation', requirement: 'Set up cron jobs for daily backup, compliance audit, revenue reporting, and alerts monitoring.', refs: 'Guide Step 7', completed: false },
            { id: 'E4.4', action: 'Verify Monitoring Access', requirement: 'Verify access to Grafana (localhost:3010) and Prometheus (/prometheus). Check dashboards for revenue and compliance data.', refs: 'Guide Step 9', completed: false },
        ]
    },
    {
        id: 'compliance_audit',
        title: '5. Legal Compliance & Audit Logging',
        icon: '⚖️',
        description: 'Confirm that all legal safety measures are active: age verification, TOS enforcement, data retention policies, and daily audit reporting.',
        tasks: [
            { id: 'A5.1', action: 'Age Verification Enforcement', requirement: 'Verify pre-login DOB + TOS checkbox + Stripe $0 auth is required; blocks <18; logs timestamps.', refs: 'Guide Step 8', completed: false },
            { id: 'A5.2', action: 'TOS/Privacy Enforcement', requirement: 'Mandatory TOS/Privacy checkbox pre-purchase. Verify liability cap, "as-is" disclaimer, and GDPR/CCPA rights are active.', refs: 'Guide Step 8', completed: false },
            { id: 'A5.3', action: 'Verify Data Purge Policy', requirement: 'Confirm 30-day log purge (DB scan) is active and running daily via the cron job.', refs: 'Guide Step 7/8', completed: false },
            { id: 'A5.4', action: 'Security & Audit Check', requirement: 'Verify Cloudflare WAF/DDoS is On. Confirm daily compliance PDF report is generated and emailed (audit-compliance.py).', refs: 'Guide Step 7/9', completed: false },
        ]
    },
    {
        id: 'dao_ecosystem',
        title: '6. DAO & Tokenized Ecosystem',
        icon: '💎',
        description: 'The final, 300% growth layer: Deploying the $AIS governance token and activating the DAO for perpetual funding and community alignment.',
        tasks: [
            { id: 'Z6.1', action: 'Final Smart Contract Audit', requirement: 'Engage a firm (CertiK/PeckShield) for a formal, third-party audit of the $AIS Token and DAO Governance smart contracts.', refs: 'DAO Mandate', completed: false },
            { id: 'Z6.2', action: 'Deploy Smart Contract', requirement: 'Deploy the audited $AIS Token (ERC-20) and Governance (DAO) contracts to the **Polygon Mainnet**.', refs: 'DAO Mandate', completed: false },
            { id: 'Z6.3', action: 'Initial Liquidity Injection', requirement: 'Establish the DEX pool (e.g., Uniswap V3) with Stripe-derived fiat converted to stablecoins to create the initial $AIS price floor.', refs: 'DAO Mandate', completed: false },
            { id: 'Z6.4', action: 'Integrate DAO Service', requirement: 'Deploy the new `dao-contract-service` Docker container and update the Next.js/FastAPI to allow user **Wallet Connection** and **Token Staking**.', refs: 'DAO Mandate', completed: false },
            { id: 'Z6.5', action: 'Activate Governance', requirement: 'Hold the first on-chain vote (e.g., setting the initial commission rate) to officially activate the DAO structure and treasury control.', refs: 'DAO Mandate', completed: false },
        ]
    },
];
