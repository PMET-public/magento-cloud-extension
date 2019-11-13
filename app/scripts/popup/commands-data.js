// const sampleCmdObj = {
//   text: '',
//   scriptsInValue: [''],
//   additionalEnvVarsInValue: '',
//   suffixToValue: '',
//   tags: ['cloud', 'vm', 'prerequiste', 'magento', 'monitor', 'maintenance', 'access'],
//   help: ''
// }
[
  {
    text: '1) Install the Cloud CLI',
    scriptsInValue: ['install-cli-and-login.sh'],
    tags: ['prerequiste'],
    help: 'You should only need to run this command on your computer once.'
  },
  {
    text: '2) Setup local ssh keys',
    scripts: ['setup-ssh-key.sh'],
    tags: ['prerequiste'],
    help: 'You should only need to run this command on your computer once.'
  },
  {
    text: 'SSH',
    scripts: ['lib.sh', 'ssh.sh'],
    tags: ['cloud', 'vm', 'access'],
    suffixToValue: ' | bash'
  },
  {
    text: 'Backup',
    scripts: ['lib.sh', 'backup-env.sh', 'maintenance'],
    tags: ['cloud', 'vm'],
  },
  {
    text: 'Reindex',
    scripts: ['lib.sh', 'reindex.sh', 'magento'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Run Magento cron jobs',
    scripts: ['lib.sh', 'run-cron.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Run Magento cron jobs each min for 1 hr'
  },
  {
    text: 'Warm cache',
    scripts: ['lib.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Flush; then warm cache',
    scripts: ['lib.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Reindex; flush; warm',
    scripts: ['lib.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Check current load',
    scripts: ['lib.sh', 'check-load.sh'],
    tags: ['cloud', 'vm', 'monitor'],
  },
  {
    text: 'Check services',
    scripts: ['lib.sh', 'check-services.sh'],
    tags: ['cloud', 'vm', 'monitor'],
  },
  {
    text: 'Send imgs to env',
    scripts: ['lib.sh', 'copy-imgs-to-env.sh'],
    tags: ['cloud', 'vm'],
  },
  {
    text: 'Watch logs',
    scripts: ['lib.sh', 'watch-logs.sh'],
    tags: ['cloud', 'vm', 'monitor'],
  },
  {
    text: 'Install PWA',
    scripts: ['lib.sh', 'sc-pwa-setup.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Access private repos',
    scripts: ['lib.sh', 'configure-proxies.sh'],
    tags: ['cloud', 'vm', 'access'],
  },
  {
    text: 'Local access; bypass firewall',
    scripts: ['lib.sh', 'bypass-waf-for-pb.sh'],
    tags: ['cloud', 'vm', 'access'],
  },
  {
    text: 'Turn email on/off',
    scripts: ['lib.sh', 'toggle-email.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Deploy a language',
    scripts: ['lib.sh', 'deploy-lang.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Delete env immediately',
    scripts: ['lib.sh', 'delete-env.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Restore env',
    scripts: ['lib.sh', 'restore-env.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
    help: 'Immediately restore database and media to previous state using local backup.'
  },
  {
    text: 'Create env from backup',
    scripts: ['lib.sh', 'create-new-cloud-env-from-backup.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Force rebuild env',
    scripts: ['lib.sh', 'rebuild-cloud-env.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
    help: 'Some operations (e.g. enabling email) require the env to be rebuilt. Please backup first.'
  },
]